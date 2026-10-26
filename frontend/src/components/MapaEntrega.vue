<!--
  MapaEntrega.vue - El cliente toca el mapa de Google para marcar dónde quiere recibir su pedido.
  Uso:  <MapaEntrega v-model="coords" />      (coords = { lat, lng } o null)
  Necesita VITE_GOOGLE_MAPS_KEY en el .env. Sin clave no se rompe nada: el cliente escribe la dirección
  y puede usar el botón "Usar mi ubicación actual" (ese no necesita Google).
-->
<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({ modelValue: { type: Object, default: null } })
const emit = defineEmits(['update:modelValue'])

const KEY = import.meta.env.VITE_GOOGLE_MAPS_KEY || ''
const MAP_ID = import.meta.env.VITE_GOOGLE_MAP_ID || 'DEMO_MAP_ID'
const GUATEMALA = { lat: 14.6349, lng: -90.5069 }

const contenedor = ref(null)
const estado = ref(KEY ? 'cargando' : 'sinllave') // cargando | listo | error | sinllave
const aviso = ref('')
let mapa = null
let marcador = null
let MarcadorAvanzado = null

function cargarGoogle() {
  if (window.google?.maps?.importLibrary) return Promise.resolve()
  if (window.__siconjMapas) return window.__siconjMapas
  window.__siconjMapas = new Promise((ok, mal) => {
    // Google llama a esta función si la clave es inválida, no tiene facturación o el dominio no está permitido.
    window.gm_authFailure = () => {
      estado.value = 'error'
      aviso.value = 'Google no aceptó la clave del mapa. Escribe la dirección con detalle o usa tu ubicación actual.'
    }
    const s = document.createElement('script')
    s.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(KEY)}&loading=async&v=weekly&language=es&region=GT`
    s.async = true
    s.onload = ok
    s.onerror = () => { window.__siconjMapas = null; mal(new Error('No se pudo cargar Google Maps.')) }
    document.head.appendChild(s)
  })
  return window.__siconjMapas
}

function redondear(p) {
  return { lat: Number(Number(p.lat).toFixed(6)), lng: Number(Number(p.lng).toFixed(6)) }
}

function marcar(pos, acercar = false) {
  const p = redondear(pos)
  if (mapa) {
    if (!marcador) marcador = new MarcadorAvanzado({ map: mapa, position: p })
    else marcador.position = p
    if (acercar) { mapa.setCenter(p); mapa.setZoom(17) }
  }
  emit('update:modelValue', p)
}

function quitar() {
  if (marcador) { marcador.map = null; marcador = null }
  emit('update:modelValue', null)
}

function usarMiUbicacion() {
  if (!navigator.geolocation) { aviso.value = 'Tu navegador no permite obtener la ubicación.'; return }
  aviso.value = 'Buscando tu ubicación…'
  navigator.geolocation.getCurrentPosition(
    (r) => { aviso.value = ''; marcar({ lat: r.coords.latitude, lng: r.coords.longitude }, true) },
    () => { aviso.value = 'No pudimos obtener tu ubicación. Márcala en el mapa o escribe la dirección.' },
    { enableHighAccuracy: true, timeout: 10000 },
  )
}

onMounted(async () => {
  if (!KEY) return
  try {
    await cargarGoogle()
    const { Map } = await window.google.maps.importLibrary('maps')
    const lib = await window.google.maps.importLibrary('marker')
    MarcadorAvanzado = lib.AdvancedMarkerElement

    mapa = new Map(contenedor.value, {
      center: props.modelValue || GUATEMALA,
      zoom: props.modelValue ? 17 : 12,
      mapId: MAP_ID,
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: false,
      clickableIcons: false,
      gestureHandling: 'greedy',
    })
    if (props.modelValue) marcar(props.modelValue)
    mapa.addListener('click', (e) => marcar(e.latLng.toJSON()))
    if (estado.value === 'cargando') estado.value = 'listo'
  } catch (e) {
    estado.value = 'error'
    aviso.value = e.message
  }
})
</script>

<template>
  <div class="mapa-caja">
    <div v-show="estado === 'cargando' || estado === 'listo'" ref="contenedor" class="mapa"></div>
    <p v-if="estado === 'cargando'" class="nota">Cargando el mapa…</p>
    <p v-else-if="estado === 'sinllave'" class="nota">El mapa todavía no está activado. Escribe la dirección con detalle o usa tu ubicación actual.</p>
    <p v-else-if="estado === 'listo' && !modelValue" class="nota">Toca el mapa para marcar dónde quieres recibir tu pedido.</p>
    <p v-if="modelValue" class="listo">Ubicación marcada. <button type="button" class="enlace" @click="quitar">Quitar</button></p>
    <p v-if="aviso" class="nota">{{ aviso }}</p>
    <button type="button" class="boton" @click="usarMiUbicacion">Usar mi ubicación actual</button>
  </div>
</template>

<style scoped>
.mapa-caja { display: grid; gap: 8px; }
.mapa { height: 230px; border-radius: 14px; border: 2px solid #d3e1fb; background: #eaf2ff; overflow: hidden; }
.nota { margin: 0; color: #5b6a8c; font-size: .9rem; }
.listo { margin: 0; color: #1d7a53; font-weight: 700; font-size: .9rem; }
.boton { border: 2px solid #d3e1fb; background: #fff; color: #17306b; border-radius: 12px; padding: 8px 14px; font: inherit; font-weight: 700; cursor: pointer; }
.enlace { background: none; border: 0; color: #2f6fed; font: inherit; font-weight: 700; cursor: pointer; padding: 0; text-decoration: underline; }
</style>
