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
