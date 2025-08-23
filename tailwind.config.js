module.exports = {
  content: ["./src/**/*.html", "./src/*.html"],
  darkMode: "class",
  theme: {
    extend: {
      typography: {
        DEFAULT: {
          css: {
            /* Keep Tailwind's default prose styles; only small tweaks */
            h1: { marginBottom: "0.5rem" },
            a: { textDecoration: "none" },
            "a:hover": { textDecoration: "underline" },
          },
        },
      },
    },
  },
  plugins: [
      require("@tailwindcss/typography"),
  ],
}
