(function () {
  const sidebar = document.getElementById("sidebar")
  const doc = document.getElementById("doc")
  const docMeta = document.getElementById("doc-meta")
  const search = document.getElementById("search")

  let manifest = null
  let allEntries = []
  let activePath = null

  function flattenEntries(data) {
    const grouped = data.groups.flatMap((group) =>
      group.entries.map((entry) => ({ ...entry, group: group.title }))
    )
    const extras = data.extras.map((entry) => ({ ...entry, group: "Reference" }))
    return [...grouped, ...extras]
  }

  function renderSidebar(filterText) {
    const q = (filterText || "").trim().toLowerCase()
    sidebar.innerHTML = ""

    const groups = [...manifest.groups, { title: "Reference", entries: manifest.extras }]

    groups.forEach((group) => {
      const entries = group.entries.filter((entry) => {
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

        button.addEventListener("click", () => {
          loadEntry(entry)
        })

        section.appendChild(button)
      })

      sidebar.appendChild(section)
    })
  }

  function updateUrl(path) {
    const url = new URL(window.location.href)
    url.searchParams.set("file", path)
    window.history.replaceState({}, "", url)
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

  async function loadEntry(entry) {
    activePath = entry.path
    renderSidebar(search.value)
    updateUrl(entry.path)

    docMeta.textContent = `${entry.group} - ${entry.path}`
    doc.innerHTML = "<p>Loading...</p>"

    const res = await fetch(entry.path)
    if (!res.ok) {
      doc.innerHTML = `<p>Could not load <code>${entry.path}</code>.</p>`
      return
    }

    const markdown = await res.text()
    doc.innerHTML = marked.parse(markdown)
    prettifySqlBlocks()
    highlightCodeBlocks()
    wireDocumentLinks(entry.path)
  }

  function entryFromUrl(entries) {
    const path = new URL(window.location.href).searchParams.get("file")
    if (!path) return entries[0]
    return entries.find((entry) => entry.path === path) || entries[0]
  }

  async function init() {
    const res = await fetch("book.json")
    manifest = await res.json()
    allEntries = flattenEntries(manifest)

    renderSidebar("")
    const initial = entryFromUrl(allEntries)
    await loadEntry(initial)

    search.addEventListener("input", () => {
      renderSidebar(search.value)
    })
  }

  init().catch((err) => {
    docMeta.textContent = "Error"
    doc.innerHTML = `<pre>${String(err)}</pre>`
  })
})()
