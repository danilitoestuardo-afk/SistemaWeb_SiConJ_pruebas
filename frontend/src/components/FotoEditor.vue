<script setup>
import { ref, watch, onMounted, onUnmounted, nextTick } from 'vue'

const props = defineProps({ archivo: { type: File, required: true } })
const emit = defineEmits(['listo', 'cerrar'])
const OBJETIVO = 350 * 1024
const MAX_FUENTE = 4000
const lienzo = ref(null)
const caja = ref(null)
const zoom = ref(1)
const cargando = ref(true)
const procesando = ref(false)
const error = ref('')
let fuente = null
let offX = 0, offY = 0, cerrado = false
let focoAnterior
const punteros = new Map()
let distIni = 1, zoomIni = 1
const peso = b => b >= 1048576 ? `${(b / 1048576).toFixed(1)} MB` : `${Math.round(b / 1024)} KB`

function dibujarEn(ctx, w, h) {
  if (!ctx || !fuente) throw new Error('No se pudo abrir el lienzo')
  const s = Math.max(w / fuente.width, h / fuente.height) * zoom.value
  const dw = fuente.width * s, dh = fuente.height * s
  const mx = Math.max(0, (dw - w) / (2 * w)), my = Math.max(0, (dh - h) / (2 * h))
  offX = Math.min(mx, Math.max(-mx, offX))
  offY = Math.min(my, Math.max(-my, offY))
  ctx.fillStyle = '#fff'
  ctx.fillRect(0, 0, w, h)
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.drawImage(fuente, (w - dw) / 2 + offX * w, (h - dh) / 2 + offY * h, dw, dh)
}
function dibujar() {
  const c = lienzo.value
  if (fuente && c) dibujarEn(c.getContext('2d'), c.width, c.height)
}
watch(zoom, dibujar)
function cerrar() { if (!procesando.value) emit('cerrar') }
function teclado(e) {
  if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); cerrar() }
  if (e.key !== 'Tab') return
  const elementos = [...caja.value.querySelectorAll('button:not(:disabled), input:not(:disabled), [tabindex="0"]')]
    .filter(el => el.getClientRects().length)
  const primero = elementos[0], ultimo = elementos.at(-1)
  if (!primero) { e.preventDefault(); caja.value.focus(); return }
  if (e.shiftKey && (document.activeElement === primero || document.activeElement === caja.value)) {
    e.preventDefault(); ultimo.focus()
  } else if (!e.shiftKey && (document.activeElement === ultimo || document.activeElement === caja.value)) {
    e.preventDefault(); primero.focus()
  }
}
onMounted(async () => {
  focoAnterior = document.activeElement
  caja.value.focus()
  const url = URL.createObjectURL(props.archivo)
  try {
    const img = new Image()
    img.src = url
    await img.decode()
    if (cerrado) return
    if (!img.naturalWidth || !img.naturalHeight) throw new Error('Foto vacía')
    const k = Math.min(1, MAX_FUENTE / Math.max(img.naturalWidth, img.naturalHeight))
    fuente = document.createElement('canvas')
    fuente.width = Math.max(1, Math.round(img.naturalWidth * k))
    fuente.height = Math.max(1, Math.round(img.naturalHeight * k))
    const ctx = fuente.getContext('2d')
    ctx.drawImage(img, 0, 0, fuente.width, fuente.height)
    cargando.value = false
    await nextTick()
    if (!cerrado) dibujar()
  } catch {
    if (!cerrado) { cargando.value = false; error.value = 'No se pudo abrir esta foto. Prueba con otra JPG, PNG o WEBP.' }
  } finally { URL.revokeObjectURL(url) }
})
onUnmounted(() => {
  cerrado = true
  punteros.clear()
  if (fuente) { fuente.width = 0; fuente.height = 0; fuente = null }
  if (focoAnterior?.isConnected) focoAnterior.focus()
})
function girar() {
  if (!fuente || procesando.value) return
  const n = document.createElement('canvas')
  n.width = fuente.height; n.height = fuente.width
  const c = n.getContext('2d')
  c.translate(n.width / 2, n.height / 2); c.rotate(Math.PI / 2)
  c.drawImage(fuente, -fuente.width / 2, -fuente.height / 2)
  fuente.width = 0; fuente.height = 0
  fuente = n; offX = 0; offY = 0; zoom.value = 1
  punteros.clear()
  dibujar()
}
const distancia = () => {
  const [a, b] = [...punteros.values()]
  return Math.hypot(a.x - b.x, a.y - b.y) || 1
}
function abajo(e) {
  if (!fuente || procesando.value) return
  lienzo.value.setPointerCapture(e.pointerId)
  punteros.set(e.pointerId, { x: e.clientX, y: e.clientY })
  if (punteros.size === 2) { distIni = distancia(); zoomIni = zoom.value }
}
function mover(e) {
  const previo = punteros.get(e.pointerId)
  if (!previo || !fuente || procesando.value) return
  const ahora = { x: e.clientX, y: e.clientY }
  punteros.set(e.pointerId, ahora)
  if (punteros.size === 2) zoom.value = Math.min(4, Math.max(1, zoomIni * distancia() / distIni))
  else if (punteros.size === 1) {
    offX += (ahora.x - previo.x) / lienzo.value.clientWidth
    offY += (ahora.y - previo.y) / lienzo.value.clientHeight
    dibujar()
  }
}
function arriba(e) {
  punteros.delete(e.pointerId)
  if (punteros.size === 2) { distIni = distancia(); zoomIni = zoom.value }
}
function rueda(e) {
  if (!procesando.value) zoom.value = Math.min(4, Math.max(1, zoom.value - e.deltaY * .002))
}
function desplazar(e) {
  const pasos = { ArrowLeft: [-.03, 0], ArrowRight: [.03, 0], ArrowUp: [0, -.03], ArrowDown: [0, .03] }
  const d = pasos[e.key]
  if (!d || procesando.value) return
  e.preventDefault(); offX += d[0]; offY += d[1]; dibujar()
}
const aBlob = (canvas, calidad) => new Promise(ok => canvas.toBlob(ok, 'image/jpeg', calidad))
async function usarFoto() {
  if (!fuente || procesando.value || cargando.value) return
  procesando.value = true
  punteros.clear()
  await new Promise(r => setTimeout(r, 30))
  try {
    // Se redibuja desde el original de trabajo en cada intento: no se recomprime un JPEG previo.
    for (const ancho of [1200, 1000, 800]) {
      const c = document.createElement('canvas')
      try {
        c.width = ancho; c.height = Math.round(ancho * 3 / 4)
        dibujarEn(c.getContext('2d'), c.width, c.height)
        for (const q of [.85, .78, .70, .62, .55]) {
          const blob = await aBlob(c, q)
          if (cerrado) return
          if (blob && blob.size <= OBJETIVO) {
            const nombre = (props.archivo.name.replace(/\.[^.]+$/, '') || 'foto') + '-catalogo.jpg'
            emit('listo', { archivo: new File([blob], nombre, { type: 'image/jpeg' }), original: props.archivo.size })
            return
          }
        }
      } finally { c.width = 0; c.height = 0 }
    }
    throw new Error('No se alcanzó el tamaño de salida')
  } catch {
    if (!cerrado) error.value = 'No se pudo preparar la foto. Cancela e intenta con otra.'
  } finally { if (!cerrado) procesando.value = false }
}
</script>

<template>
  <div class="foto-velo" @click.self="cerrar" @keydown="teclado">
    <div ref="caja" class="foto-caja" role="dialog" aria-modal="true" aria-labelledby="foto-titulo" tabindex="-1" :aria-busy="cargando || procesando">
      <h2 id="foto-titulo">Ajusta tu foto</h2>
      <p v-if="cargando" class="nota" role="status">Abriendo la foto ({{ peso(archivo.size) }})…</p>
      <p v-if="error" class="error" role="alert">{{ error }}</p>
      <template v-if="!error">
        <p v-show="!cargando" class="nota">Arrastra para encuadrar y acerca para quitar lo que sobra. Así se verá en el catálogo.</p>
        <canvas v-show="!cargando" ref="lienzo" class="lienzo" width="480" height="360" tabindex="0"
          aria-label="Encuadrar foto: arrastra o usa las flechas del teclado"
          @keydown="desplazar" @pointerdown="abajo" @pointermove="mover" @pointerup="arriba"
          @pointercancel="arriba" @lostpointercapture="arriba" @wheel.prevent="rueda"></canvas>
        <div v-show="!cargando" class="controles">
          <label class="zoom">Acercar
            <input v-model.number="zoom" :disabled="procesando" type="range" min="1" max="4" step="0.01" aria-label="Acercar" />
          </label>
          <button type="button" class="btn contorno" :disabled="procesando" @click="girar">Girar</button>
        </div>
      </template>
      <div class="par">
        <button type="button" class="btn contorno" :disabled="procesando" @click="cerrar">Cancelar</button>
        <button type="button" class="btn azul" :disabled="cargando || procesando || !!error" @click="usarFoto">{{ procesando ? 'Reduciendo…' : 'Usar esta foto' }}</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.foto-velo { position: fixed; inset: 0; background: rgba(23,48,107,.55); z-index: 30; display:flex; justify-content:center; align-items:center; padding:14px; }
.foto-caja { background:#fff; border-radius:20px; border-top:6px solid #ff9f43; padding:18px; width:min(440px,100%); max-height:94dvh; overflow-y:auto; box-sizing:border-box; display:grid; gap:12px; font-family:'Nunito',system-ui,sans-serif; color:#1b2a4b; }
h2 { margin:0; font-family:'Fredoka','Nunito',system-ui,sans-serif; font-weight:600; color:#17306b; }
.nota { margin:0; color:#5b6a8c; font-size:.92rem; }
.error { margin:0; color:#c23b3b; font-weight:600; }
.lienzo { width:100%; height:auto; aspect-ratio:4/3; border-radius:14px; border:2px solid #d3e1fb; box-sizing:border-box; background:#eaf2ff; touch-action:none; cursor:grab; display:block; }
.lienzo:active { cursor:grabbing; }
.controles { display:flex; align-items:center; gap:12px; }
.zoom { flex:1; display:grid; gap:4px; font-weight:700; font-size:.9rem; }
.zoom input { width:100%; }
.par { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.btn { border:2px solid transparent; border-radius:14px; padding:10px 16px; font:inherit; font-weight:700; cursor:pointer; }
.btn:disabled { opacity:.5; cursor:not-allowed; }
.btn.azul { background:#2f6fed; color:#fff; }
.btn.contorno { background:#fff; color:#17306b; border-color:#d3e1fb; }
</style>
