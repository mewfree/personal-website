const isDark = () =>
  localStorage.theme === "dark" ||
  (!("theme" in localStorage) &&
    window.matchMedia("(prefers-color-scheme: dark)").matches);

// Syntax-highlighting theme: one <link> whose href is swapped, only on pages with code.
const hasCode = document.querySelector("pre code") !== null;
const codeTheme = hasCode ? document.createElement("link") : null;
if (codeTheme) {
  codeTheme.rel = "stylesheet";
  document.head.append(codeTheme);
}

function applyTheme(dark) {
  document.documentElement.classList.toggle("dark", dark);
  document.getElementById("theme").innerText = dark ? "\u{1F31E}️" : "\u{1F31D}";
  if (codeTheme) codeTheme.href = `/highlight.${dark ? "dark" : "light"}.css`;
}

function toggleTheme() {
  const dark = !isDark();
  localStorage.theme = dark ? "dark" : "light";
  applyTheme(dark);
}

applyTheme(isDark());

document.addEventListener("DOMContentLoaded", () => {
  document
    .querySelectorAll("h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]")
    .forEach((el) => {
      const link = document.createElement("a");
      link.href = "#" + el.id;
      link.classList.add("header-anchor");
      el.prepend(link);
    });

  document.querySelectorAll("pre code").forEach((el) => {
    el.classList.remove("sourceCode");
    if (el.classList.length > 0) {
      el.classList.replace(el.classList[0], "language-" + el.classList[0]);
    }
    hljs.highlightElement(el);
  });

  if (typeof renderMathInElement === "function") {
    renderMathInElement(document.body, {
      delimiters: [
        { left: "$$", right: "$$", display: true },
        { left: "$", right: "$", display: false },
        { left: "\\(", right: "\\)", display: false },
        { left: "\\[", right: "\\]", display: true },
      ],
      ignoredClasses: ["no-katex"],
      throwOnError: false,
    });
  }
});
