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

function initWaveDivider() {
  const btn = document.getElementById("wave-divider");
  if (!btn) return;
  const path = btn.querySelector("path");
  const label = btn.querySelector(".wave-label");
  const waves = [
    { name: "sin(x)", fn: (t) => Math.sin(t * Math.PI * 6) },
    { name: "sin(2x)", fn: (t) => Math.sin(t * Math.PI * 12) },
    {
      name: "sin(x) + ½sin(3x)",
      fn: (t) => (Math.sin(t * Math.PI * 6) + 0.5 * Math.sin(t * Math.PI * 18)) / 1.35,
    },
    {
      name: "e⁻ˣ·sin(8x)",
      fn: (t) => Math.exp(-2.2 * t) * Math.sin(t * Math.PI * 16),
    },
  ];
  let idx = 0;
  let phase = 0;
  let raf = null;

  function draw(p) {
    const fn = waves[idx].fn;
    const pts = [];
    const steps = 160;
    for (let i = 0; i <= steps; i++) {
      const t = i / steps;
      const x = (t * 600).toFixed(1);
      const y = (11 - fn(t + p) * 7.5).toFixed(2);
      pts.push((i === 0 ? "M" : "L") + x + "," + y);
    }
    path.setAttribute("d", pts.join(" "));
  }

  draw(0);

  btn.addEventListener("click", () => {
    idx = (idx + 1) % waves.length;
    label.textContent = waves[idx].name;
    draw(phase);
  });

  if (!window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    btn.addEventListener("mouseenter", () => {
      if (raf) return;
      const tick = () => {
        phase += 0.0028;
        draw(phase);
        raf = requestAnimationFrame(tick);
      };
      raf = requestAnimationFrame(tick);
    });
    btn.addEventListener("mouseleave", () => {
      if (raf) {
        cancelAnimationFrame(raf);
        raf = null;
      }
    });
  }
}

document.addEventListener("DOMContentLoaded", () => {
  initWaveDivider();

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
