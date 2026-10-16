import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: './', // rutas relativas: funciona al subir el build a public_html de cPanel
})
