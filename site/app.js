(function () {
  const sidebar = document.getElementById("sidebar")
  const doc = document.getElementById("doc")
  const docMeta = document.getElementById("doc-meta")
  const search = document.getElementById("search")
  const gapFilter = document.getElementById("gap-filter")
  const content = document.querySelector(".content")

  let manifest = null
  let adapterOutputs = { patterns: {} }
  let exprExamples = { patterns: {} }
  let allEntries = []
  let activePath = null
  let gapOnly = false
  let activeAdapterKey = null
  const canonicalSqlAdapterKey = "postgresql"

  function adapterModuleName(adapterKey) {
    switch (adapterKey) {
      case "sqlite":
        return "SelectoDBSQLite.Adapter"
      case "mysql":
        return "SelectoDBMySQL.Adapter"
      case "mariadb":
        return "SelectoDBMariaDB.Adapter"
      case "mssql":
        return "SelectoDBMSSQL.Adapter"
      case "duckdb":
        return "SelectoDBDuckDB.Adapter"
      case "postgresql":
      default:
        return "SelectoDBPostgreSQL.Adapter"
    }
  }

  function flattenEntries(data) {
    const grouped = data.groups.flatMap((group) =>
      group.entries.map((entry) => ({ ...entry, group: group.title }))
    )
    const extras = data.extras.map((entry) => ({ ...entry, group: "Reference" }))
    return [...grouped, ...extras]
  }

  function adapterCoverage(entry) {
    const patternOutputs = adapterOutputs.patterns[entry.id]
    const adapters = adapterOutputs.adapters || []

    if (!patternOutputs || adapters.length === 0) return null

    const missing = adapters.filter((adapter) => {
      const output = patternOutputs[adapter.key]
      return !output || output.status !== "ok"
    })

    if (missing.length === 0) return null

    const text = missing.length === 1 ? `${missing[0].label} gap` : "adapter gaps"
    const detail = missing
      .map((adapter) => {
        const output = patternOutputs[adapter.key]
        const reason = output && output.error ? `: ${output.error}` : ""
        return `${adapter.label}${reason}`
      })
      .join(" | ")

    return { text, detail, missingKeys: missing.map((adapter) => adapter.key) }
  }

  function renderSidebar(filterText) {
    const q = (filterText || "").trim().toLowerCase()
    sidebar.innerHTML = ""

    const groups = [{ title: "Reference", entries: manifest.extras }, ...manifest.groups]

    groups.forEach((group) => {
      const entries = group.entries.filter((entry) => {
        const coverage = adapterCoverage(entry)
        if (gapOnly && !coverage) return false
        if (!q) return true
        return (
          entry.id.toLowerCase().includes(q) ||
          entry.title.toLowerCase().includes(q) ||
          entry.path.toLowerCase().includes(q)
        )
      })

      if (entries.length === 0) return

      const section = document.createElement("section")
      section.className = "group"

      const h = document.createElement("h3")
      h.className = "group-title"
      h.textContent = group.title
      section.appendChild(h)

      entries.forEach((entry) => {
        const button = document.createElement("button")
        button.className = "item"
        if (entry.path === activePath) button.classList.add("active")

        const id = document.createElement("span")
        id.className = "item-id"
        id.textContent = entry.id

        const title = document.createElement("span")
        title.textContent = entry.title

        button.appendChild(id)
        button.appendChild(title)

        const coverage = adapterCoverage(entry)
        if (coverage) {
          const badge = document.createElement("span")
          badge.className = "item-badge"
          badge.textContent = coverage.text
          badge.title = coverage.detail
          button.title = coverage.detail
          badge.addEventListener("click", (event) => {
            event.stopPropagation()
            loadEntry(entry, coverage.missingKeys[0] || null)
          })
          button.appendChild(badge)
        }

        button.addEventListener("click", () => {
          loadEntry(entry)
        })

        section.appendChild(button)
      })

      sidebar.appendChild(section)
    })
  }

  function updateGapFilterUi() {
    if (!gapFilter) return
    gapFilter.classList.toggle("active", gapOnly)
    gapFilter.textContent = gapOnly ? "Showing gaps" : "Show gaps"
  }

  function updateUrl(path, adapterKey) {
    const url = new URL(window.location.href)
    url.searchParams.set("file", path)
    if (adapterKey) {
      url.searchParams.set("adapter", adapterKey)
    } else {
      url.searchParams.delete("adapter")
    }
    if (gapOnly) {
      url.searchParams.set("gaps", "1")
    } else {
      url.searchParams.delete("gaps")
    }
    url.hash = ""
    window.history.replaceState({}, "", url)
  }

  function scrollContentToTop() {
    if (content) content.scrollTop = 0
    window.scrollTo(0, 0)
  }

  function isExternalHref(href) {
    return /^(?:[a-z][a-z0-9+.-]*:|\/\/)/i.test(href)
  }

  function normalizePath(path) {
    const parts = path.split("/")
    const normalized = []

    parts.forEach((part) => {
      if (!part || part === ".") return
      if (part === "..") {
        if (normalized.length > 0) normalized.pop()
        return
      }
      normalized.push(part)
    })

    return normalized.join("/")
  }

  function resolvePath(baseFilePath, relativePath) {
    if (!relativePath) return baseFilePath
    if (relativePath.startsWith("/")) return normalizePath(relativePath.slice(1))

    const lastSlash = baseFilePath.lastIndexOf("/")
    const baseDir = lastSlash >= 0 ? baseFilePath.slice(0, lastSlash + 1) : ""
    return normalizePath(baseDir + relativePath)
  }

  function buildEntryUrl(path, hash) {
    const url = new URL(window.location.href)
    url.hash = ""
    url.searchParams.set("file", path)
    const query = url.searchParams.toString()
    return `${url.pathname}?${query}${hash ? `#${hash}` : ""}`
  }

  function wireDocumentLinks(currentPath) {
    const links = doc.querySelectorAll("a[href]")

    links.forEach((link) => {
      const href = link.getAttribute("href")
      if (!href || href.startsWith("#")) return

      if (isExternalHref(href)) {
        link.setAttribute("target", "_blank")
        link.setAttribute("rel", "noopener noreferrer")
        return
      }

      const [hrefPath, hrefHash = ""] = href.split("#", 2)
      const resolvedPath = resolvePath(currentPath, hrefPath)

      if (resolvedPath.endsWith(".md")) {
        link.setAttribute("href", buildEntryUrl(resolvedPath, hrefHash))
        link.addEventListener("click", (event) => {
          if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey)
            return

          event.preventDefault()

          const entry =
            allEntries.find((candidate) => candidate.path === resolvedPath) ||
            ({
              id: "DOC",
              title: resolvedPath,
              path: resolvedPath,
              group: "Reference"
            })

          loadEntry(entry)
        })
        return
      }

      const resolvedHref = hrefHash ? `${resolvedPath}#${hrefHash}` : resolvedPath
      link.setAttribute("href", resolvedHref)
    })
  }

  function prettifySqlBlocks() {
    if (!window.sqlFormatter || typeof window.sqlFormatter.format !== "function") return

    const sqlBlocks = doc.querySelectorAll("pre code.language-sql")

    sqlBlocks.forEach((block) => {
      const original = block.textContent || ""

      try {
        const pretty = window.sqlFormatter.format(original, {
          language: "postgresql",
          keywordCase: "upper"
        })

        block.textContent = pretty.trimEnd()
      } catch (_err) {
        block.textContent = original
      }
    })
  }

  function highlightCodeBlocks() {
    if (!window.hljs || typeof window.hljs.highlightElement !== "function") return

    const codeBlocks = doc.querySelectorAll("pre code")
    codeBlocks.forEach((block) => window.hljs.highlightElement(block))
  }

  function extractSectionCode(markdown, heading) {
    const pattern = new RegExp(
      "(^|\\n)## " + heading + "\\n\\n```([\\w-]+)?\\n([\\s\\S]*?)\\n```",
      "m"
    )
    const match = markdown.match(pattern)
    if (!match) return null
    return {
      language: match[2] || "text",
      code: match[3].trim()
    }
  }

  function stripSection(markdown, heading) {
    const pattern = new RegExp(`(^|\\n)## ${heading}\\n[\\s\\S]*?(?=\\n## |$)`, "m")
    return markdown.replace(pattern, "\n")
  }

  function transformSelectoCode(baseCode, adapterKey) {
    if (!baseCode) return null

    const adapterLine = `  |> Map.put(:adapter, ${adapterModuleName(adapterKey)})`

    const lines = baseCode.split("\n")
    const configureIndex = lines.findIndex((line) => line.includes("Selecto.configure("))

    if (configureIndex === -1) {
      return baseCode
    }

    const insertAt = configureIndex + 1
    const nextLine = lines[insertAt]

    if (nextLine && nextLine.trim().startsWith("|> Map.put(:adapter,")) {
      lines[insertAt] = adapterLine
      return lines.join("\n")
    }

    lines.splice(insertAt, 0, adapterLine)
    return lines.join("\n")
  }

  function exprExampleForEntry(entry, adapterKey) {
    const baseCode = exprExamples.patterns[entry.id]
    if (!baseCode) return null

    const lines = baseCode.split("\n")
    const prefix = ["import Selecto.Expr", ""]

    const hasAssignment = lines.some((line) => line.trimStart().startsWith("query ="))
    const body = hasAssignment ? lines.join("\n") : ["query =", ...lines.map((line) => `  ${line}`)].join("\n")

    return transformSelectoCode([...prefix, body].join("\n"), adapterKey)
  }

  function buildCodeBlock(language, source) {
    const pre = document.createElement("pre")
    const code = document.createElement("code")
    code.className = `language-${language}`
    code.textContent = source
    pre.appendChild(code)
    return pre
  }

  function buildModeCard(title, blocks) {
    const card = document.createElement("div")
    card.className = "adapter-card"

    const heading = document.createElement("h3")
    heading.className = "adapter-card-title"
    heading.textContent = title
    card.appendChild(heading)

    const modes = blocks.filter((block) => block && block.source)
    if (modes.length === 0) return card

    if (modes.length === 1) {
      card.appendChild(buildCodeBlock(modes[0].language, modes[0].source))
      return card
    }

    const tabs = document.createElement("div")
    tabs.className = "code-mode-tabs"

    const body = document.createElement("div")
    body.className = "code-mode-body"

    modes.forEach((mode, index) => {
      const button = document.createElement("button")
      button.className = "code-mode-tab"
      button.type = "button"
      button.textContent = mode.label

      const panel = document.createElement("div")
      panel.className = "code-mode-panel"
      panel.appendChild(buildCodeBlock(mode.language, mode.source))

      function setActive() {
        tabs.querySelectorAll(".code-mode-tab").forEach((item) => item.classList.remove("active"))
        body.querySelectorAll(".code-mode-panel").forEach((item) => item.classList.remove("active"))
        button.classList.add("active")
        panel.classList.add("active")
      }

      button.addEventListener("click", setActive)

      if (index === 0) {
        setActive()
      }

      tabs.appendChild(button)
      body.appendChild(panel)
    })

    card.appendChild(tabs)
    card.appendChild(body)
    return card
  }

  function prettifySqlString(sql) {
    if (!window.sqlFormatter || typeof window.sqlFormatter.format !== "function") return sql

    try {
      return window.sqlFormatter
        .format(sql, { language: "postgresql", keywordCase: "upper" })
        .trimEnd()
    } catch (_err) {
      return sql
    }
  }

  function buildAdapterPanel(entry, markdown, preferredAdapterKey) {
    const outputs = adapterOutputs.patterns[entry.id]
    const selectoSection = extractSectionCode(markdown, "Selecto")

    if (!outputs || !selectoSection) return null

    const section = document.createElement("section")
    section.className = "adapter-panel"

    const header = document.createElement("div")
    header.className = "adapter-header"

    const title = document.createElement("h2")
    title.className = "adapter-title"
    title.textContent = "Adapter Output"

    const note = document.createElement("p")
    note.className = "adapter-note"
    note.textContent = "Compare classic and Expr Selecto commands, then inspect yielded SQL by adapter."

    header.appendChild(title)
    header.appendChild(note)
    section.appendChild(header)

    const tabs = document.createElement("div")
    tabs.className = "adapter-tabs"

    const body = document.createElement("div")
    body.className = "adapter-body"

    const adapters = adapterOutputs.adapters || []

    let activated = false

    adapters.forEach((adapter, index) => {
      const button = document.createElement("button")
      button.className = "adapter-tab"
      button.type = "button"
      button.textContent = adapter.label

      const panel = document.createElement("div")
      panel.className = "adapter-view"

      const output = outputs[adapter.key]
      const commandCard = buildModeCard(`${adapter.label} Selecto`, [
        {
          label: "Classic",
          language: selectoSection.language,
          source: transformSelectoCode(selectoSection.code, adapter.key)
        },
        {
          label: "Expr",
          language: "elixir",
          source: exprExampleForEntry(entry, adapter.key)
        }
      ])

      panel.appendChild(commandCard)

      if (adapter.key === canonicalSqlAdapterKey) {
        panel.classList.add("single-card")

        const canonicalNote = document.createElement("p")
        canonicalNote.className = "adapter-reference-note"
        canonicalNote.textContent = "Reference SQL is shown above in the original SQL section."
        commandCard.appendChild(canonicalNote)
      } else {
        const outputCard = document.createElement("div")
        outputCard.className = "adapter-card"

        const outputLabel = document.createElement("h3")
        outputLabel.className = "adapter-card-title"
        outputLabel.textContent = `${adapter.label} SQL`
        outputCard.appendChild(outputLabel)

        if (output && output.status === "ok") {
          outputCard.appendChild(buildCodeBlock("sql", prettifySqlString(output.sql)))

          const params = document.createElement("p")
          params.className = "adapter-params"
          params.innerHTML = `<strong>Params:</strong> <code>${JSON.stringify(output.params)}</code>`
          outputCard.appendChild(params)
        } else {
          const unavailable = document.createElement("p")
          unavailable.className = "adapter-unavailable"
          unavailable.textContent = output && output.error ? output.error : "No adapter output available."
          outputCard.appendChild(unavailable)
        }

        panel.appendChild(outputCard)
      }

      body.appendChild(panel)
      tabs.appendChild(button)

      function setActive() {
        const tabButtons = tabs.querySelectorAll(".adapter-tab")
        const views = body.querySelectorAll(".adapter-view")

        tabButtons.forEach((tabButton) => tabButton.classList.remove("active"))
        views.forEach((view) => view.classList.remove("active"))

        button.classList.add("active")
        panel.classList.add("active")
        activeAdapterKey = adapter.key
        updateUrl(entry.path, adapter.key)
      }

      button.addEventListener("click", setActive)

      if (adapter.key === preferredAdapterKey || (!preferredAdapterKey && index === 0)) {
        setActive()
        activated = true
      }
    })

    if (!activated) {
      const firstTab = tabs.querySelector(".adapter-tab")
      if (firstTab) firstTab.click()
    }

    section.appendChild(tabs)
    section.appendChild(body)
    return section
  }

  function injectAdapterPanel(entry, markdown, preferredAdapterKey) {
    const panel = buildAdapterPanel(entry, markdown, preferredAdapterKey)
    if (!panel) return

    const sqlHeading = Array.from(doc.querySelectorAll("h2")).find(
      (heading) => heading.textContent.trim() === "SQL"
    )

    if (!sqlHeading) {
      doc.prepend(panel)
      return
    }

    let anchor = sqlHeading.nextElementSibling
    while (anchor && anchor.tagName !== "H2") {
      if (anchor.tagName === "PRE") {
        anchor.insertAdjacentElement("afterend", panel)
        return
      }
      anchor = anchor.nextElementSibling
    }

    sqlHeading.insertAdjacentElement("afterend", panel)
  }

  async function loadEntry(entry, preferredAdapterKey = activeAdapterKey) {
    activePath = entry.path
    renderSidebar(search.value)
    updateUrl(entry.path, preferredAdapterKey)
    scrollContentToTop()

    docMeta.textContent = `${entry.group} - ${entry.path}`
    doc.innerHTML = "<p>Loading...</p>"

    const res = await fetch(entry.path)
    if (!res.ok) {
      doc.innerHTML = `<p>Could not load <code>${entry.path}</code>.</p>`
      return
    }

    const markdown = await res.text()
    const cleanedMarkdown = stripSection(stripSection(markdown, "Selecto Yielded SQL"), "Selecto")

    doc.innerHTML = marked.parse(cleanedMarkdown)
    injectAdapterPanel(entry, markdown, preferredAdapterKey)
    prettifySqlBlocks()
    highlightCodeBlocks()
    wireDocumentLinks(entry.path)
  }

  function entryFromUrl(entries) {
    const defaultEntry =
      entries.find((entry) => entry.path === "README.md") ||
      entries.find((entry) => entry.path === "patterns/README.md") ||
      entries[0]

    const path = new URL(window.location.href).searchParams.get("file")
    if (!path) return defaultEntry
    return entries.find((entry) => entry.path === path) || defaultEntry
  }

  function adapterFromUrl() {
    return new URL(window.location.href).searchParams.get("adapter")
  }

  async function init() {
    const [manifestRes, adapterRes, exprRes] = await Promise.all([
      fetch("book.json"),
      fetch("patterns/SELECTO_ADAPTER_OUTPUTS.json"),
      fetch("patterns/SELECTO_EXPR_EXAMPLES.json")
    ])

    manifest = await manifestRes.json()

    if (adapterRes.ok) {
      adapterOutputs = await adapterRes.json()
    }

    if (exprRes.ok) {
      exprExamples = await exprRes.json()
    }

    allEntries = flattenEntries(manifest)

    gapOnly = new URL(window.location.href).searchParams.get("gaps") === "1"
    activeAdapterKey = adapterFromUrl()
    updateGapFilterUi()

    renderSidebar("")
    const initial = entryFromUrl(allEntries)
    await loadEntry(initial, activeAdapterKey)

    search.addEventListener("input", () => {
      renderSidebar(search.value)
    })

    if (gapFilter) {
      gapFilter.addEventListener("click", () => {
        gapOnly = !gapOnly
        updateGapFilterUi()
        renderSidebar(search.value)
        updateUrl(activePath || initial.path, activeAdapterKey)
      })
    }
  }

  init().catch((err) => {
    docMeta.textContent = "Error"
    doc.innerHTML = `<pre>${String(err)}</pre>`
  })
})()
