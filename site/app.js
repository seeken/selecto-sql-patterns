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
  let liveValidation = { patterns: {} }
  let allEntries = []
  let activePath = null
  let gapOnly = false
  let activeAdapterKey = null

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

  function adapterShortLabel(adapterKey) {
    switch (adapterKey) {
      case "postgresql":
        return "PG"
      case "sqlite":
        return "SQ"
      case "mysql":
        return "MY"
      case "mariadb":
        return "MA"
      case "mssql":
        return "MS"
      case "duckdb":
        return "DU"
      default:
        return adapterKey.slice(0, 2).toUpperCase()
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

    return {
      text,
      detail,
      missingKeys: missing.map((adapter) => adapter.key),
      missing
    }
  }

  function liveValidationResult(entry, adapterKey) {
    return liveValidation.patterns?.[entry.id]?.[adapterKey] || null
  }

  function liveValidationLabel(result) {
    if (!result) return null

    switch (result.status) {
      case "executed":
        return { text: "Executed", tone: "success" }
      case "failed":
        return { text: "Failed", tone: "error" }
      case "unsupported_expected":
        return { text: "Unsupported", tone: "warning" }
      case "generated_only":
        return { text: "Generated Only", tone: "muted" }
      case "skipped":
        return { text: "Skipped", tone: "muted" }
      default:
        return { text: result.status, tone: "muted" }
    }
  }

  function liveValidationSummary(entry) {
    const patternResults = liveValidation.patterns?.[entry.id]
    const adapters = liveValidation.adapters || []
    if (!patternResults || adapters.length === 0) return null

    const counts = { executed: 0, failed: 0, unsupported_expected: 0, generated_only: 0, skipped: 0 }

    adapters.forEach((adapter) => {
      const status = patternResults[adapter.key]?.status
      if (status && Object.prototype.hasOwnProperty.call(counts, status)) counts[status] += 1
    })

    const parts = []
    if (counts.executed) parts.push(`${counts.executed} executed`)
    if (counts.generated_only) parts.push(`${counts.generated_only} generated only`)
    if (counts.unsupported_expected) parts.push(`${counts.unsupported_expected} unsupported`)
    if (counts.failed) parts.push(`${counts.failed} failed`)
    if (counts.skipped) parts.push(`${counts.skipped} skipped`)

    if (parts.length === 0) return null
    return `Live smoke: ${parts.join(", ")}`
  }

  function sidebarValidationBadges(entry) {
    const patternResults = liveValidation.patterns?.[entry.id]
    const adapters = liveValidation.adapters || []
    if (!patternResults || adapters.length === 0) return []

    return adapters
      .map((adapter) => ({ adapter, result: patternResults[adapter.key] }))
      .filter(({ result }) => result && result.status !== "executed")
      .map(({ adapter, result }) => {
        const label = liveValidationLabel(result)
        return {
          adapter,
          result,
          label
        }
      })
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
        title.className = "item-title"
        title.textContent = entry.title

        button.appendChild(id)
        button.appendChild(title)

        const coverage = adapterCoverage(entry)
        let metaRow = null
        function ensureMetaRow() {
          if (!metaRow) {
            metaRow = document.createElement("span")
            metaRow.className = "item-meta-row"
            button.appendChild(metaRow)
          }
          return metaRow
        }

        if (coverage) {
          const icons = document.createElement("span")
          icons.className = "item-gap-icons"
          button.title = coverage.detail

          coverage.missing.forEach((adapter) => {
            const icon = document.createElement("span")
            icon.className = "item-gap-icon"
            icon.title = `${adapter.label} unavailable`
            icon.textContent = `${adapterShortLabel(adapter.key)} x`
            icon.addEventListener("click", (event) => {
              event.stopPropagation()
              loadEntry(entry, adapter.key)
            })
            icons.appendChild(icon)
          })

          ensureMetaRow().appendChild(icons)
        }

        const validationBadges = sidebarValidationBadges(entry)
        if (validationBadges.length > 0) {
          const validations = document.createElement("span")
          validations.className = "item-validation-icons"

          validationBadges.forEach(({ adapter, label, result }) => {
            const icon = document.createElement("span")
            icon.className = `item-validation-icon item-validation-${label ? label.tone : "muted"}`
            icon.title = `${adapter.label}: ${label ? label.text : result.status}`
            icon.textContent = `${adapterShortLabel(adapter.key)} ${label ? label.text[0] : "?"}`
            icon.addEventListener("click", (event) => {
              event.stopPropagation()
              loadEntry(entry, adapter.key)
            })
            validations.appendChild(icon)
          })

          ensureMetaRow().appendChild(validations)
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
    const escapedHeading = heading.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
    const pattern = new RegExp(
      `(^|\\n)## ${escapedHeading}\\r?\\n[\\s\\S]*?(?=(?:\\r?\\n## )|\\s*$)`,
      "m"
    )
    return markdown.replace(pattern, "\n")
  }

  function stripKnownPatternSections(markdown) {
    return ["Selecto", "Selecto Expr", "Selecto Yielded SQL"].reduce(
      (current, heading) => stripSection(current, heading),
      markdown
    )
  }

  function removeRenderedSections(headings) {
    const targets = new Set(headings)
    const nodes = Array.from(doc.querySelectorAll("h2, h3, h4"))

    nodes.forEach((heading) => {
      if (!targets.has(heading.textContent.trim())) return

      let cursor = heading.nextElementSibling
      const toRemove = [heading]

      while (cursor && !/^H[234]$/.test(cursor.tagName)) {
        toRemove.push(cursor)
        cursor = cursor.nextElementSibling
      }

      toRemove.forEach((node) => node.remove())
    })
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

  function stripAdapterLine(source) {
    if (!source) return ""
    return source
      .split("\n")
      .filter((line) => !line.includes("|> Map.put(:adapter,"))
      .join("\n")
      .trim()
  }

  function syntaxSummary(sharedSource, adapterSource) {
    const sharedLines = stripAdapterLine(sharedSource).split("\n")
    const adapterLines = stripAdapterLine(adapterSource).split("\n")
    const added = adapterLines.filter((line) => line && !sharedLines.includes(line))
    const removed = sharedLines.filter((line) => line && !adapterLines.includes(line))
    const fragments = []

    if (added.length > 0) {
      fragments.push(`adds ${added.slice(0, 2).map((line) => `\`${line.trim()}\``).join(", ")}`)
    }

    if (removed.length > 0) {
      fragments.push(`omits ${removed.slice(0, 2).map((line) => `\`${line.trim()}\``).join(", ")}`)
    }

    return fragments.length > 0
      ? `Differs from the shared syntax above: ${fragments.join("; ")}.`
      : "Differs from the shared syntax above."
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

  function buildSharedSyntaxPanel(entry, markdown) {
    const selectoSection = extractSectionCode(markdown, "Selecto")
    const exprSource = exprExampleForEntry(entry, "postgresql")

    if (!selectoSection && !exprSource) return null

    const section = document.createElement("section")
    section.className = "shared-syntax-panel"

    const title = document.createElement("h2")
    title.className = "shared-syntax-title"
    title.textContent = "Shared Selecto Syntax"

    const note = document.createElement("p")
    note.className = "shared-syntax-note"
    note.textContent = "These Selecto examples are shared across adapters unless an adapter tab calls out a syntax difference."

    const validationSummary = liveValidationSummary(entry)
    if (validationSummary) {
      const summary = document.createElement("p")
      summary.className = "shared-syntax-summary"
      summary.textContent = validationSummary
      section.appendChild(title)
      section.appendChild(note)
      section.appendChild(summary)
    } else {
      section.appendChild(title)
      section.appendChild(note)
    }

    section.appendChild(
      buildModeCard("Selecto", [
        {
          label: "Classic",
          language: selectoSection ? selectoSection.language : "elixir",
          source: selectoSection ? selectoSection.code : null
        },
        {
          label: "Expr",
          language: "elixir",
          source: exprSource ? stripAdapterLine(exprSource) : null
        }
      ])
    )

    return section
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

  function explainAdapterGap(error) {
    const message = error || "No adapter output available."

    if (message.includes("lateral/apply joins")) {
      return {
        title: "Join type not supported",
        detail:
          "This pattern depends on lateral or apply joins, and this adapter does not expose an equivalent join shape in Selecto yet."
      }
    }

    if (message.includes("FTS5-configured field")) {
      return {
        title: "SQLite FTS setup required",
        detail:
          "SQLite can only render this example when the searched field is backed by an FTS5 virtual table or equivalent text-search configuration."
      }
    }

    if (message.includes("does not support text search")) {
      return {
        title: "Text search not supported",
        detail:
          "This adapter currently lacks the full-text search feature needed for this pattern, so Selecto cannot generate adapter SQL for it."
      }
    }

    return {
      title: "Adapter gap",
      detail: message
    }
  }

  function buildAdapterPanel(entry, markdown, preferredAdapterKey) {
    const outputs = adapterOutputs.patterns[entry.id]
    const selectoSection = extractSectionCode(markdown, "Selecto")
    const sharedClassic = selectoSection ? selectoSection.code.trim() : null
    const sharedExpr = exprExampleForEntry(entry, "postgresql")

    if (!outputs) return null

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
      const adapterClassic = selectoSection ? transformSelectoCode(selectoSection.code, adapter.key) : null
      const adapterExpr = exprExampleForEntry(entry, adapter.key)
      const hasClassicDifference =
        sharedClassic && adapterClassic && stripAdapterLine(adapterClassic) !== sharedClassic.trim()
      const hasExprDifference =
        sharedExpr && adapterExpr && stripAdapterLine(adapterExpr) !== stripAdapterLine(sharedExpr)
      const hasAdapterSyntaxDifference = hasClassicDifference || hasExprDifference

      if (hasAdapterSyntaxDifference) {
        const commandCard = buildModeCard(`${adapter.label} Selecto`, [
          {
            label: "Classic",
            language: selectoSection ? selectoSection.language : "elixir",
            source: hasClassicDifference ? adapterClassic : null
          },
          {
            label: "Expr",
            language: "elixir",
            source: hasExprDifference ? adapterExpr : null
          }
        ])

        const syntaxNote = document.createElement("p")
        syntaxNote.className = "adapter-diff-note"
        syntaxNote.textContent = syntaxSummary(
          hasExprDifference ? sharedExpr : sharedClassic,
          hasExprDifference ? adapterExpr : adapterClassic
        )

        commandCard.appendChild(syntaxNote)
        panel.appendChild(commandCard)
      }

      const outputCard = document.createElement("div")
      outputCard.className = "adapter-card"

      const outputLabel = document.createElement("div")
      outputLabel.className = "adapter-card-header"

      const outputTitle = document.createElement("h3")
      outputTitle.className = "adapter-card-title"
      outputTitle.textContent = `${adapter.label} SQL`
      outputLabel.appendChild(outputTitle)

      const validation = liveValidationLabel(liveValidationResult(entry, adapter.key))
      if (validation) {
        const badge = document.createElement("span")
        badge.className = `adapter-validation adapter-validation-${validation.tone}`
        badge.textContent = validation.text
        outputLabel.appendChild(badge)
      }

      outputCard.appendChild(outputLabel)

      if (output && output.status === "ok") {
        outputCard.appendChild(buildCodeBlock("sql", prettifySqlString(output.sql)))

        const params = document.createElement("p")
        params.className = "adapter-params"
        params.innerHTML = `<strong>Params:</strong> <code>${JSON.stringify(output.params)}</code>`
        outputCard.appendChild(params)
      } else {
        const explanation = explainAdapterGap(output && output.error)
        const unavailable = document.createElement("div")
        unavailable.className = "adapter-unavailable"

        const unavailableTitle = document.createElement("strong")
        unavailableTitle.className = "adapter-unavailable-title"
        unavailableTitle.textContent = explanation.title

        const unavailableDetail = document.createElement("p")
        unavailableDetail.className = "adapter-unavailable-detail"
        unavailableDetail.textContent = explanation.detail

        const unavailableReason = document.createElement("p")
        unavailableReason.className = "adapter-unavailable-reason"
        unavailableReason.innerHTML = `<strong>Reason:</strong> <code>${
          output && output.error ? output.error : "No adapter output available."
        }</code>`

        unavailable.appendChild(unavailableTitle)
        unavailable.appendChild(unavailableDetail)
        unavailable.appendChild(unavailableReason)
        outputCard.appendChild(unavailable)
      }

      const validationResult = liveValidationResult(entry, adapter.key)
      if (validationResult && validationResult.reason) {
        const runtimeNote = document.createElement("p")
        runtimeNote.className = "adapter-runtime-note"
        runtimeNote.innerHTML = `<strong>Live validation:</strong> <code>${validationResult.reason}</code>`
        outputCard.appendChild(runtimeNote)
      }

      panel.appendChild(outputCard)

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
    const sharedSyntaxPanel = buildSharedSyntaxPanel(entry, markdown)
    const panel = buildAdapterPanel(entry, markdown, preferredAdapterKey)
    if (!panel && !sharedSyntaxPanel) return

    const notesHeading = Array.from(doc.querySelectorAll("h2")).find(
      (heading) => heading.textContent.trim() === "Notes"
    )

    if (notesHeading) {
      if (sharedSyntaxPanel) notesHeading.insertAdjacentElement("beforebegin", sharedSyntaxPanel)
      if (panel) notesHeading.insertAdjacentElement("beforebegin", panel)
      return
    }

    if (sharedSyntaxPanel) doc.appendChild(sharedSyntaxPanel)
    if (panel) doc.appendChild(panel)
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
    const cleanedMarkdown = stripKnownPatternSections(markdown)

    doc.innerHTML = marked.parse(cleanedMarkdown)
    removeRenderedSections(["Selecto", "Selecto Expr", "Selecto Yielded SQL"])
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
    const [manifestRes, adapterRes, exprRes, liveRes] = await Promise.all([
      fetch("book.json"),
      fetch("patterns/SELECTO_ADAPTER_OUTPUTS.json"),
      fetch("patterns/SELECTO_EXPR_EXAMPLES.json"),
      fetch("patterns/SELECTO_LIVE_VALIDATION.json")
    ])

    manifest = await manifestRes.json()

    if (adapterRes.ok) {
      adapterOutputs = await adapterRes.json()
    }

    if (exprRes.ok) {
      exprExamples = await exprRes.json()
    }

    if (liveRes.ok) {
      liveValidation = await liveRes.json()
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
