/** @type {import('tailwindcss').Config} */
export default {
  // Herda os tokens do design system (submódulo em src/components/shared)
  presets: [require("./src/components/shared/tailwind.preset.cjs")],
  content: [
    "./index.html",
    "./src/**/*.{ts,tsx}",
    // inclui os componentes do submódulo para o Tailwind gerar as classes usadas
    "./src/components/shared/src/**/*.{ts,tsx}",
  ],
  theme: { extend: {} },
  plugins: [],
};
