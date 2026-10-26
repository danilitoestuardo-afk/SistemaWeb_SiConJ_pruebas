<!--
  SiconJApp.vue - Catálogo SiConJ (v2)
    - Visitante: ve el catálogo y busca.
    - Cliente (entra con su clave de 6 caracteres): arma su pedido y elige cómo recibirlo
      (recoger en la tienda aliada o a domicilio con mapa, dirección escrita y horario).
    - Administrador (PIN y luego clave): productos con foto, pedidos, clientes y entregas.
-->
<script setup>
import { ref, reactive, computed, watch, onMounted, onUnmounted } from 'vue'
import MapaEntrega from './MapaEntrega.vue'

const API = (import.meta.env.VITE_API_URL || 'http://localhost:5000').replace(/\/$/, '')
const WHATSAPP = (import.meta.env.VITE_WHATSAPP || '').replace(/\D/g, '')
const MAX_FOTO = 3 * 1024 * 1024

/* ============ Formatos ============ */
const DIAS = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
const DIAS_ORDEN = [1, 2, 3, 4, 5, 6, 0] // la semana empieza el lunes
const dos = (n) => String(n).padStart(2, '0')
const Q = (n) => 'Q ' + Number(n || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const fecha = (d) => new Date(d).toLocaleString('es-GT', { dateStyle: 'short', timeStyle: 'short' })
const aISO = (d) => `${d.getFullYear()}-${dos(d.getMonth() + 1)}-${dos(d.getDate())}`
const fechaLarga = (iso) => { const d = new Date(`${iso}T00:00:00`); return `${DIAS[d.getDay()]} ${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}` }
const h12 = (s) => { const [h, m] = s.split(':').map(Number); return `${((h + 11) % 12) + 1}:${dos(m)} ${h < 12 ? 'am' : 'pm'}` }
const rango = (f) => { const [a, b] = f.split('-'); return `${h12(a)} a ${h12(b)}` }

/* ============ Avisos ============ */
const toast = reactive({ texto: '', tipo: 'ok' })
let tToast
function avisar(texto, tipo = 'ok') {
  Object.assign(toast, { texto, tipo })
  clearTimeout(tToast)
  tToast = setTimeout(() => (toast.texto = ''), 3800)
}

/* ============ Sesión (cliente o admin) ============ */
// El admin se guarda solo mientras la pestaña esté abierta; el cliente se recuerda en el equipo.
const sesion = reactive({ token: '', rol: '', nombre: '' })
const esAdmin = computed(() => sesion.rol === 'Admin')
const esCliente = computed(() => sesion.rol === 'Cliente')
const vista = ref('catalogo') // catalogo | pedidos | clientes | entregas

function cargarSesion() {
  const raw = sessionStorage.getItem('sj_ses') || localStorage.getItem('sj_ses')
  if (!raw) return
  try { Object.assign(sesion, JSON.parse(raw)) } catch { /* sesión dañada: se ignora */ }
}
function guardarSesion(s) {
  Object.assign(sesion, s)
  const almacen = s.rol === 'Admin' ? sessionStorage : localStorage
  almacen.setItem('sj_ses', JSON.stringify(s))
}
function salir() {
  sessionStorage.removeItem('sj_ses')
  localStorage.removeItem('sj_ses')
  Object.assign(sesion, { token: '', rol: '', nombre: '' })
  vista.value = 'catalogo'
}

async function api(ruta, { method = 'GET', body, token, noLogout = false } = {}) {
  const headers = {}
  const t = token ?? sesion.token
  if (t) headers.Authorization = `Bearer ${t}`
  let payload
  if (body instanceof FormData) payload = body
  else if (body !== undefined) { headers['Content-Type'] = 'application/json'; payload = JSON.stringify(body) }

  const res = await fetch(`${API}/api${ruta}`, { method, headers, body: payload })
  if (res.status === 401 && sesion.token && !noLogout) {
    salir()
    avisar('Tu sesión terminó. Ingresa de nuevo.', 'err')
    throw new Error('401')
  }
  return res
}
// Texto de error legible. Si el servidor no da motivo, se muestra el código para poder diagnosticar.
async function mensaje(res, porDefecto) {
  try {
    const j = await res.json()
    return j.mensaje || Object.values(j.errors || {}).flat()[0] || `${porDefecto} (código ${res.status})`
  } catch { return `${porDefecto} (código ${res.status})` }
}
const sinConexion = (e) => (e instanceof TypeError ? 'No hay conexión con el servidor.' : e.message)

/* ============ Cuadro de confirmación (Sí / No) ============ */
const confirma = reactive({ abierto: false, titulo: '', texto: '', si: 'Sí', peligro: false, error: '', trabajando: false, accion: null, extra: null })
function confirmar({ titulo, texto, si = 'Sí', peligro = false, accion }) {
  Object.assign(confirma, { abierto: true, titulo, texto, si, peligro, error: '', trabajando: false, accion, extra: null })
}
async function ejecutarConfirma(fn) {
  confirma.trabajando = true
  confirma.error = ''
  try {
    await (fn || confirma.accion)()
    confirma.abierto = false
  } catch (e) {
    if (e.message === '401') confirma.abierto = false
    else confirma.error = sinConexion(e)
  } finally {
    confirma.trabajando = false
  }
}

/* ============ Catálogo ============ */
const productos = ref([])
const categorias = ref([])
const condiciones = ref([])
const cargando = ref(false)
const error = ref('')
const filtros = reactive({ categoriaId: 0, q: '', soloDisponibles: false })
const fotosRotas = reactive(new Set())
const chips = computed(() => [{ id: 0, nombre: 'Todo' }, ...categorias.value])

let ctrl
async function cargar(silencioso = false) {
  ctrl?.abort()
  ctrl = new AbortController()
  if (!silencioso) cargando.value = true
  error.value = ''
  try {
    const qs = new URLSearchParams({
      categoriaId: filtros.categoriaId, q: filtros.q.trim(), soloDisponibles: filtros.soloDisponibles,
      incluirOcultos: esAdmin.value, // solo funciona si quien pregunta es el admin
    })
    const headers = esAdmin.value ? { Authorization: `Bearer ${sesion.token}` } : {}
    const res = await fetch(`${API}/api/productos?${qs}`, { headers, signal: ctrl.signal })
    if (!res.ok) throw new Error()
    productos.value = await res.json()
    sincronizarPedido()
  } catch (e) {
    if (e.name !== 'AbortError') error.value = 'No se pudo cargar el catálogo. Revisa tu conexión e intenta de nuevo.'
  } finally {
    cargando.value = false
  }
}
async function cargarListas() {
  try {
    const res = await fetch(`${API}/api/catalogos`)
    if (!res.ok) return
    const j = await res.json()
    categorias.value = j.categorias
    condiciones.value = j.condiciones
  } catch { /* se reintenta al recargar */ }
}

let espera
watch(filtros, () => { clearTimeout(espera); espera = setTimeout(() => cargar(), 250) })

/* ============ Entrega: punto de recogida y horarios (los define el admin) ============ */
const entrega = reactive({ recogida: { nombre: '', direccion: '', indicaciones: '', horario: '' }, horarios: [] })
async function cargarEntrega() {
  try {
    const res = await fetch(`${API}/api/entrega`)
    if (!res.ok) return
    const j = await res.json()
    entrega.recogida = j.recogida
    entrega.horarios = j.horarios
  } catch { /* se reintenta al abrir el pedido */ }
}
const horariosDelDia = (dia) => entrega.horarios
  .filter((h) => h.activo && h.diaSemana === dia)
  .sort((a, b) => a.inicio.localeCompare(b.inicio))
const hayHorarios = computed(() => entrega.horarios.some((h) => h.activo))

// Franjas que se pueden elegir un día concreto (si es hoy, solo las que no han terminado)
function franjasDe(iso) {
  let lista = horariosDelDia(new Date(`${iso}T00:00:00`).getDay())
  const hoy = new Date()
  if (iso === aISO(hoy)) {
    const ahora = `${dos(hoy.getHours())}:${dos(hoy.getMinutes())}`
    lista = lista.filter((h) => h.fin > ahora)
  }
  return lista
}

/* ============ Pedido (carrito + entrega) ============ */
const pedido = ref([])
const panelPedido = ref(false)
const nota = ref('')
const enviando = ref(false)
const confirmacion = ref(null)
const datos = reactive({ tipo: 'Recoger', direccion: '', coords: null, fecha: '', franja: '' })

const totalItems = computed(() => pedido.value.reduce((s, i) => s + i.cant, 0))
const totalPedido = computed(() => pedido.value.reduce((s, i) => s + i.cant * i.precio, 0))
const enPedido = (p) => pedido.value.find((i) => i.id === p.id)?.cant || 0

const fechasDisponibles = computed(() => {
  const salida = []
  const hoy = new Date()
  for (let i = 0; i < 21; i++) {
    const iso = aISO(new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate() + i))
    if (franjasDe(iso).length) salida.push({ valor: iso, texto: fechaLarga(iso) })
  }
  return salida
})
const franjasElegidas = computed(() => (datos.fecha ? franjasDe(datos.fecha) : []))
watch(() => datos.fecha, () => { datos.franja = '' })

const erroresEntrega = computed(() => {
  if (datos.tipo !== 'Domicilio') return []
  const e = []
  if (datos.direccion.trim().length < 6) e.push('Escribe la dirección donde quieres recibir tu pedido.')
  if (!datos.fecha) e.push('Elige el día de entrega.')
  else if (!datos.franja) e.push('Elige el horario de entrega.')
  return e
})

function abrirPedido() {
  panelPedido.value = true
  cargarEntrega() // siempre los horarios más recientes
}
function cerrarPedido() { panelPedido.value = false; confirmacion.value = null }

function agregar(p) {
  if (!p.disponible) return
  const it = pedido.value.find((i) => i.id === p.id)
  if (it) {
    if (it.cant >= p.stock) return avisar('No hay más unidades de esa pieza.', 'err')
    it.cant++
  } else {
    pedido.value.push({ id: p.id, nombre: p.nombre, precio: p.precio, stock: p.stock, cant: 1 })
  }
  avisar(`"${p.nombre}" agregado a tu pedido.`)
}
function cambiarCant(it, d) {
  const n = it.cant + d
  if (n <= 0) pedido.value = pedido.value.filter((x) => x.id !== it.id)
  else if (n <= it.stock) it.cant = n
}
function quitar(it) { pedido.value = pedido.value.filter((x) => x.id !== it.id) }

// Si el catálogo cambia (otro cliente se llevó la pieza), el pedido se ajusta solo.
function sincronizarPedido() {
  for (const p of productos.value) {
    const it = pedido.value.find((i) => i.id === p.id)
    if (!it) continue
    if (!p.disponible) {
      pedido.value = pedido.value.filter((i) => i.id !== p.id)
      avisar(`"${p.nombre}" ya no está disponible y salió de tu pedido.`, 'err')
    } else {
      it.stock = p.stock
      it.precio = p.precio
      it.cant = Math.min(it.cant, p.stock)
    }
  }
}

async function enviarPedido() {
  if (!pedido.value.length) return
  if (!esCliente.value) return abrirAcceso('Para enviar tu pedido, ingresa con tu clave de cliente o crea tu cuenta.')
  if (erroresEntrega.value.length) return avisar(erroresEntrega.value[0], 'err')

  const domicilio = datos.tipo === 'Domicilio'
  enviando.value = true
  try {
    const res = await api('/pedidos', {
      method: 'POST',
      body: {
        nota: nota.value.trim() || null,
        items: pedido.value.map((i) => ({ instanciaId: i.id, cantidad: i.cant })),
        tipoEntrega: datos.tipo,
        direccion: domicilio ? datos.direccion.trim() : null,
        latitud: domicilio && datos.coords ? datos.coords.lat : null,
        longitud: domicilio && datos.coords ? datos.coords.lng : null,
        fecha: domicilio ? datos.fecha : null,
        franja: domicilio ? datos.franja : null,
      },
    })
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo registrar el pedido.'))
    const r = await res.json()
    confirmacion.value = {
      id: r.id, total: r.total, lineas: pedido.value.map((i) => ({ ...i })),
      tipo: datos.tipo, direccion: datos.direccion.trim(), fecha: datos.fecha, franja: datos.franja,
      recogida: { ...entrega.recogida },
    }
    pedido.value = []
    nota.value = ''
    Object.assign(datos, { direccion: '', coords: null, fecha: '', franja: '' })
    cargar(true)
  } catch (e) {
    if (e.message !== '401') {
      avisar(sinConexion(e), 'err')
      cargar(true)
    }
  } finally {
    enviando.value = false
  }
}
const urlWhatsApp = computed(() => {
  const c = confirmacion.value
  if (!c || !WHATSAPP) return ''
  const lineas = c.lineas.map((i) => `- ${i.cant} x ${i.nombre} (${Q(i.precio)})`).join('\n')
  const como = c.tipo === 'Domicilio'
    ? `A domicilio: ${c.direccion}\n${fechaLarga(c.fecha)}, ${rango(c.franja)}`
    : `Recojo en: ${c.recogida.nombre}`
  const texto = `Hola SiConJ, hice el pedido #${c.id}:\n${lineas}\nTotal: ${Q(c.total)}\n${como}`
  return `https://wa.me/${WHATSAPP}?text=${encodeURIComponent(texto)}`
})

/* ============ Acceso: una sola entrada para clientes y administrador ============ */
const acceso = reactive({
  abierto: false, modo: 'clave', // clave | admin | registro | recuperar
  clave: '', tokenPin: '', nombre: '', correo: '', ofertas: true,
  error: '', info: '', cargando: false, motivo: '',
})
const claveMostrada = ref(null) // { titulo, nombre, clave, correo }

function abrirAcceso(motivo = '') {
  Object.assign(acceso, { abierto: true, modo: 'clave', clave: '', tokenPin: '', error: '', info: '', motivo })
  panelPedido.value = false
}
function cambiarModo(modo) { Object.assign(acceso, { modo, error: '', info: '' }) }
function iniciarSesion(r) {
  guardarSesion({ token: r.token, rol: r.tipo === 'admin' ? 'Admin' : 'Cliente', nombre: r.nombre })
  acceso.abierto = false
  avisar(`Bienvenido/a, ${r.nombre}.`)
}
function enviarAcceso() {
  if (acceso.modo === 'clave') return entrar()
  if (acceso.modo === 'admin') return entrarAdmin()
  if (acceso.modo === 'recuperar') return recuperar()
  return registrar()
}

async function entrar() {
  acceso.error = ''
  acceso.cargando = true
  try {
    const res = await api('/acceso', { method: 'POST', body: { clave: acceso.clave.trim() }, token: '', noLogout: true })
    if (res.status === 429) throw new Error('Demasiados intentos. Espera un minuto.')
    if (!res.ok) throw new Error(await mensaje(res, 'Clave incorrecta.'))
    const r = await res.json()
    if (r.tipo === 'admin-paso1') { acceso.tokenPin = r.token; acceso.modo = 'admin'; acceso.clave = '' }
    else iniciarSesion(r)
  } catch (e) {
    acceso.error = sinConexion(e)
  } finally {
    acceso.cargando = false
  }
}

async function entrarAdmin() {
  acceso.error = ''
  acceso.cargando = true
  try {
    const res = await api('/acceso/admin', { method: 'POST', body: { clave: acceso.clave }, token: acceso.tokenPin, noLogout: true })
    if (res.status === 401) {
      let m = ''
      try { m = (await res.json()).mensaje || '' } catch { /* sin cuerpo: el token del PIN venció */ }
      if (!m) { acceso.modo = 'clave'; acceso.clave = ''; throw new Error('La verificación expiró. Ingresa el PIN de nuevo.') }
      throw new Error(m)
    }
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo ingresar.'))
    iniciarSesion(await res.json())
    vista.value = 'catalogo'
  } catch (e) {
    acceso.error = sinConexion(e)
  } finally {
    acceso.cargando = false
  }
}

async function registrar() {
  acceso.error = ''
  if (!acceso.nombre.trim() || !acceso.correo.includes('@')) { acceso.error = 'Escribe tu nombre y un correo válido.'; return }
  acceso.cargando = true
  try {
    const res = await api('/acceso/registro', {
      method: 'POST', token: '', noLogout: true,
      body: { nombre: acceso.nombre.trim(), correo: acceso.correo.trim(), aceptaOfertas: acceso.ofertas },
    })
    if (res.status === 429) throw new Error('Demasiados intentos. Espera un minuto.')
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo crear la cuenta.'))
    const r = await res.json()
    iniciarSesion(r.sesion)
    claveMostrada.value = { titulo: 'Tu cuenta está lista', nombre: r.sesion.nombre, clave: r.clave, correo: r.correoEnviado }
  } catch (e) {
    acceso.error = sinConexion(e)
  } finally {
    acceso.cargando = false
  }
}

async function recuperar() {
  acceso.error = ''
  acceso.info = ''
  if (!acceso.correo.includes('@')) { acceso.error = 'Escribe el correo con el que te registraste.'; return }
  acceso.cargando = true
  try {
    const res = await api('/acceso/recuperar', { method: 'POST', token: '', noLogout: true, body: { correo: acceso.correo.trim() } })
    if (res.status === 429) throw new Error('Demasiados intentos. Espera un minuto.')
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo enviar la clave.'))
    acceso.info = (await res.json()).mensaje
  } catch (e) {
    acceso.error = sinConexion(e)
  } finally {
    acceso.cargando = false
  }
}
async function copiar(texto, mensajeOk = 'Copiado.') {
  try { await navigator.clipboard.writeText(texto); avisar(mensajeOk) }
  catch { avisar('No se pudo copiar. Selecciona el texto y cópialo a mano.', 'err') }
}

/* ============ Administrador: productos ============ */
const modalProducto = ref(false)
const guardando = ref(false)
const intentado = ref(false)
const form = reactive({
  id: 0, nombre: '', descripcion: '', categoriaId: 0, condicionId: 0,
  precio: null, stock: 1, notas: '', archivo: null, previa: '', imagenActual: '',
})

function nuevo() {
  Object.assign(form, {
    id: 0, nombre: '', descripcion: '', categoriaId: categorias.value[0]?.id || 0,
    condicionId: condiciones.value[0]?.id || 0, precio: null, stock: 1, notas: '',
    archivo: null, previa: '', imagenActual: '',
  })
  intentado.value = false
  modalProducto.value = true
}
function editar(p) {
  Object.assign(form, {
    id: p.id, nombre: p.nombre, descripcion: p.descripcion, categoriaId: p.categoriaId,
    condicionId: p.condicionId, precio: p.precio, stock: p.stock, notas: p.notasCondicion || '',
    archivo: null, previa: '', imagenActual: p.imagenUrl || '',
  })
  intentado.value = false
  modalProducto.value = true
}
function onFoto(e) {
  const f = e.target.files?.[0]
  if (!f) return
  if (!['image/jpeg', 'image/png', 'image/webp'].includes(f.type)) { avisar('Usa una foto JPG, PNG o WEBP.', 'err'); e.target.value = ''; return }
  if (f.size > MAX_FOTO) { avisar('La foto no debe pasar de 3 MB.', 'err'); e.target.value = ''; return }
  if (form.previa) URL.revokeObjectURL(form.previa)
  form.archivo = f
  form.previa = URL.createObjectURL(f)
}
const errores = computed(() => {
  const e = {}
  if (!form.nombre.trim()) e.nombre = 'Escribe el nombre.'
  if (!form.categoriaId) e.categoria = 'Elige una categoría.'
  if (!form.condicionId) e.condicion = 'Elige la condición.'
  if (!(Number(form.precio) > 0)) e.precio = 'El precio debe ser mayor a 0.'
  if (!Number.isInteger(Number(form.stock)) || Number(form.stock) < 0) e.stock = 'Usa un número entero (0 o más).'
  return e
})
const fotoForm = computed(() => form.previa || (form.imagenActual ? API + form.imagenActual : ''))

async function guardarProducto() {
  intentado.value = true
  if (Object.keys(errores.value).length) return
  guardando.value = true
  try {
    const fd = new FormData()
    fd.append('nombre', form.nombre.trim())
    fd.append('descripcion', form.descripcion.trim())
    fd.append('categoriaId', form.categoriaId)
    fd.append('condicionId', form.condicionId)
    fd.append('precio', String(form.precio))
    fd.append('stock', String(form.stock))
    fd.append('notasCondicion', form.notas.trim())
    if (form.archivo) fd.append('imagen', form.archivo)

    const res = await api(form.id ? `/productos/${form.id}` : '/productos', { method: form.id ? 'PUT' : 'POST', body: fd })
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo guardar el producto.'))
    avisar(form.id ? 'Producto actualizado.' : 'Producto publicado.')
    if (form.previa) URL.revokeObjectURL(form.previa)
    modalProducto.value = false
    cargar(true)
  } catch (e) {
    if (e.message !== '401') avisar(sinConexion(e), 'err')
  } finally {
    guardando.value = false
  }
}

function pedirBorrar(p) {
  confirmar({
    titulo: '¿Está seguro de eliminar este producto?',
    texto: `"${p.nombre}" se borrará del catálogo para siempre.`,
    si: 'Sí, eliminar', peligro: true, accion: () => borrarProducto(p),
  })
}
async function borrarProducto(p) {
  const res = await api(`/productos/${p.id}`, { method: 'DELETE' })
  if (res.ok) { avisar('Producto eliminado.'); cargar(true); return }
  let j = {}
  try { j = await res.json() } catch { /* sin cuerpo */ }
  // Si ya tiene pedidos no se puede borrar: se ofrece ocultarlo del catálogo.
  if (res.status === 409 && j.puedeOcultar) confirma.extra = { texto: 'Ocultar del catálogo', accion: () => ocultar(p, true) }
  throw new Error(j.mensaje || `No se pudo eliminar (código ${res.status}).`)
}
async function ocultar(p, valor) {
  const res = await api(`/productos/${p.id}/ocultar?oculto=${valor}`, { method: 'POST' })
  if (!res.ok) throw new Error(await mensaje(res, 'No se pudo cambiar la visibilidad.'))
  avisar(valor ? 'La pieza quedó oculta del catálogo.' : 'La pieza vuelve a mostrarse.')
  cargar(true)
}

/* ============ Administrador: pedidos y clientes ============ */
const pedidos = ref([])
const clientes = ref([])
const filtroPedidos = ref('Pendiente')
const pedidosFiltrados = computed(() =>
  filtroPedidos.value === 'Todos' ? pedidos.value : pedidos.value.filter((p) => p.estado === filtroPedidos.value))
const pendientes = computed(() => pedidos.value.filter((p) => p.estado === 'Pendiente').length)

async function cargarPedidos(silencioso = false) {
  if (!esAdmin.value) return
  try {
    const res = await api('/pedidos')
    if (res.ok) pedidos.value = await res.json()
  } catch (e) { if (!silencioso && e.message !== '401') avisar(sinConexion(e), 'err') }
}
function pedirCambioEstado(p, estado) {
  const cancelar = estado === 'Cancelado'
  confirmar({
    titulo: cancelar ? '¿Está seguro de cancelar este pedido?' : '¿Marcar este pedido como vendido?',
    texto: cancelar ? `Pedido #${p.id}. Las piezas vuelven al catálogo.` : `Pedido #${p.id}. Las piezas quedan como vendidas.`,
    si: cancelar ? 'Sí, cancelar' : 'Sí, vendido', peligro: cancelar, accion: () => cambiarEstado(p, estado),
  })
}
async function cambiarEstado(p, estado) {
  const res = await api(`/pedidos/${p.id}/estado`, { method: 'PUT', body: { estado } })
  if (!res.ok) throw new Error(await mensaje(res, 'No se pudo actualizar el pedido.'))
  avisar(`Pedido #${p.id}: ${estado.toLowerCase()}.`)
  cargarPedidos(true)
  cargar(true)
}
async function cargarClientes() {
  if (!esAdmin.value) return
  try {
    const res = await api('/clientes')
    if (res.ok) clientes.value = await res.json()
  } catch (e) { if (e.message !== '401') avisar(sinConexion(e), 'err') }
}
function pedirNuevaClave(c) {
  confirmar({
    titulo: `¿Generar una clave nueva para ${c.nombre}?`,
    texto: 'La clave anterior dejará de funcionar.',
    si: 'Sí, generar', accion: () => nuevaClave(c),
  })
}
async function nuevaClave(c) {
  const res = await api(`/clientes/${c.id}/clave`, { method: 'POST' })
  if (!res.ok) throw new Error(await mensaje(res, 'No se pudo generar la clave.'))
  const r = await res.json()
  claveMostrada.value = { titulo: 'Clave nueva', nombre: c.nombre, clave: r.clave, correo: false }
}
function copiarCorreos() {
  const lista = clientes.value.filter((c) => c.aceptaOfertas).map((c) => c.correo)
  if (!lista.length) return avisar('Todavía no hay clientes que acepten ofertas.', 'err')
  copiar(lista.join(', '), `${lista.length} correo(s) copiados.`)
}

/* ============ Administrador: entregas (punto de recogida y horarios) ============ */
const recogidaForm = reactive({ nombre: '', direccion: '', indicaciones: '', horario: '' })
const guardandoRecogida = ref(false)
const horariosAdmin = (dia) => entrega.horarios
  .filter((h) => h.diaSemana === dia)
  .sort((a, b) => a.inicio.localeCompare(b.inicio))

async function abrirEntregas() {
  await cargarEntrega()
  Object.assign(recogidaForm, entrega.recogida)
}
async function guardarRecogida() {
  if (!recogidaForm.nombre.trim()) return avisar('Escribe el nombre del punto de recogida.', 'err')
  guardandoRecogida.value = true
  try {
    const res = await api('/entrega/recogida', { method: 'PUT', body: { ...recogidaForm } })
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo guardar.'))
    avisar('Punto de recogida guardado.')
    cargarEntrega()
  } catch (e) { if (e.message !== '401') avisar(sinConexion(e), 'err') }
  finally { guardandoRecogida.value = false }
}
async function agregarHorario(dia) {
  try {
    const res = await api('/entrega/horarios', { method: 'POST', body: { diaSemana: dia, inicio: '09:00', fin: '12:00', activo: true } })
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo agregar el horario.'))
    await cargarEntrega()
  } catch (e) { if (e.message !== '401') avisar(sinConexion(e), 'err') }
}
async function guardarHorario(h) {
  try {
    const res = await api(`/entrega/horarios/${h.id}`, {
      method: 'PUT', body: { diaSemana: h.diaSemana, inicio: h.inicio, fin: h.fin, activo: h.activo },
    })
    if (!res.ok) throw new Error(await mensaje(res, 'No se pudo guardar el horario.'))
    avisar('Horario guardado.')
  } catch (e) {
    if (e.message !== '401') avisar(sinConexion(e), 'err')
    cargarEntrega() // vuelve a mostrar lo que realmente quedó guardado
  }
}
function pedirBorrarHorario(h) {
  confirmar({
    titulo: '¿Está seguro de quitar este horario?',
    texto: `${DIAS[h.diaSemana]}, ${rango(`${h.inicio}-${h.fin}`)}. Los clientes ya no podrán elegirlo.`,
    si: 'Sí, quitar', peligro: true, accion: () => borrarHorario(h),
  })
}
async function borrarHorario(h) {
  const res = await api(`/entrega/horarios/${h.id}`, { method: 'DELETE' })
  if (!res.ok) throw new Error(await mensaje(res, 'No se pudo quitar el horario.'))
  avisar('Horario quitado.')
  await cargarEntrega()
}

watch(vista, (v) => {
  if (v === 'pedidos') cargarPedidos()
  if (v === 'clientes') cargarClientes()
  if (v === 'entregas') abrirEntregas()
})
watch(esAdmin, (v) => { cargar(true); if (v) cargarPedidos(true) })

/* ============ Actualización en vivo ============ */
let temporizador
onMounted(() => {
  cargarSesion()
  cargarListas()
  cargarEntrega()
  cargar()
  if (esAdmin.value) cargarPedidos(true)
  temporizador = setInterval(() => {
    if (document.hidden) return
    if (vista.value === 'catalogo') cargar(true)
    if (esAdmin.value) cargarPedidos(true)
  }, 20000)
})
onUnmounted(() => clearInterval(temporizador))
</script>

<template>
  <div class="app">
    <!-- ================= Encabezado ================= -->
    <header class="barra">
      <div class="marca">
        <img :src="'./logo-siconj.jpg'" alt="Logo de SiConJ: piezas con historia" class="logo-img" />
        <div class="nombre">
          <strong>SiConJ</strong>
          <small>Coleccionables de familia</small>
        </div>
      </div>

      <div class="acciones">
        <button class="btn contorno" @click="abrirPedido">
          Mi pedido <span v-if="totalItems" class="cuenta">{{ totalItems }}</span>
        </button>
        <template v-if="sesion.token">
          <span class="usuario" :class="{ admin: esAdmin }">{{ esAdmin ? 'Administrador' : sesion.nombre }}</span>
          <button class="btn texto" @click="salir">Salir</button>
        </template>
        <button v-else class="btn azul" @click="abrirAcceso()">Ingresar</button>
      </div>
    </header>

    <nav v-if="esAdmin" class="admin-tabs" aria-label="Panel de administración">
      <button :class="{ on: vista === 'catalogo' }" @click="vista = 'catalogo'">Catálogo</button>
      <button :class="{ on: vista === 'pedidos' }" @click="vista = 'pedidos'">
        Pedidos <span v-if="pendientes" class="cuenta rojo">{{ pendientes }}</span>
      </button>
      <button :class="{ on: vista === 'clientes' }" @click="vista = 'clientes'">Clientes</button>
      <button :class="{ on: vista === 'entregas' }" @click="vista = 'entregas'">Entregas</button>
    </nav>

    <main class="contenido">
      <!-- ================= Catálogo ================= -->
      <template v-if="vista === 'catalogo'">
        <section class="portada">
          <h1>Piezas con historia, listas para tu colección</h1>
          <p>Videojuegos, tarjetas, autos a escala y figuras. Lo que ves aquí es lo que hay en stock.</p>
        </section>

        <section class="filtros">
          <input v-model="filtros.q" class="buscar" type="search" placeholder="Buscar por nombre" aria-label="Buscar en el catálogo" />
          <div class="chips">
            <button
              v-for="c in chips" :key="c.id" class="chip" :class="[`t${c.id % 4}`, { on: filtros.categoriaId === c.id }]"
              @click="filtros.categoriaId = c.id"
            >{{ c.nombre }}</button>
          </div>
          <label class="check"><input v-model="filtros.soloDisponibles" type="checkbox" /> Solo disponibles</label>
        </section>

        <div v-if="esAdmin" class="franja-admin">
          <span>Estás editando el catálogo. Los cambios se ven al instante.</span>
          <button class="btn naranja" @click="nuevo">Agregar producto</button>
        </div>

        <p v-if="error" class="alerta">{{ error }} <button class="btn texto" @click="cargar()">Reintentar</button></p>
        <p v-else-if="cargando && !productos.length" class="vacio">Cargando el catálogo…</p>
        <p v-else-if="!productos.length" class="vacio">
          No encontramos piezas con esos filtros.
          <template v-if="esAdmin"> Agrega la primera con el botón "Agregar producto".</template>
        </p>

        <section class="grid">
          <article
            v-for="p in productos" :key="p.id" class="tarjeta"
            :class="[`t${p.categoriaId % 4}`, { agotado: !p.disponible, oculta: p.oculto }]"
          >
            <div class="franja"><span class="hueco" aria-hidden="true"></span><span class="etiqueta">{{ p.categoria }}</span></div>
            <div class="foto">
              <img
                v-if="p.imagenUrl && !fotosRotas.has(p.id)" :src="API + p.imagenUrl" :alt="p.nombre"
                loading="lazy" @error="fotosRotas.add(p.id)"
              />
              <div v-else class="sin-foto">Sin foto por ahora</div>
              <span v-if="p.oculto" class="sello gris">Oculto</span>
              <span v-else-if="!p.disponible" class="sello">Agotado</span>
            </div>
            <div class="info">
              <h3>{{ p.nombre }}</h3>
              <p v-if="p.descripcion" class="desc">{{ p.descripcion }}</p>
              <p class="cond"><b>{{ p.condicion }}</b><span v-if="p.notasCondicion">. {{ p.notasCondicion }}</span></p>
              <div class="precio-fila">
                <strong class="precio">{{ Q(p.precio) }}</strong>
                <span class="stock" :class="{ poco: p.disponible && p.stock <= 2 }">
                  {{ p.disponible ? (p.stock <= 2 ? `¡Últimas ${p.stock}!` : `${p.stock} disponibles`) : 'Sin existencias' }}
                </span>
              </div>
              <button class="btn naranja ancho" :disabled="!p.disponible || enPedido(p) >= p.stock" @click="agregar(p)">
                {{ !p.disponible ? 'No disponible' : enPedido(p) ? `En tu pedido (${enPedido(p)})` : 'Agregar al pedido' }}
              </button>
              <div v-if="esAdmin" class="admin-fila">
                <button class="btn contorno chico" @click="editar(p)">Editar</button>
                <button class="btn contorno chico" @click="ocultar(p, !p.oculto)">{{ p.oculto ? 'Mostrar' : 'Ocultar' }}</button>
                <button class="btn contorno chico peligro" @click="pedirBorrar(p)">Eliminar</button>
              </div>
            </div>
          </article>
        </section>
      </template>

      <!-- ================= Admin: pedidos ================= -->
      <template v-else-if="vista === 'pedidos'">
        <h2 class="titulo">Pedidos</h2>
        <div class="chips">
          <button
            v-for="f in ['Pendiente', 'Completado', 'Cancelado', 'Todos']" :key="f"
            class="chip t1" :class="{ on: filtroPedidos === f }" @click="filtroPedidos = f"
          >{{ f }}</button>
        </div>
        <p v-if="!pedidosFiltrados.length" class="vacio">No hay pedidos en esta lista.</p>
        <section class="lista">
          <article v-for="p in pedidosFiltrados" :key="p.id" class="fila-pedido">
            <header>
              <strong>Pedido #{{ p.id }}</strong>
              <span class="estado" :class="p.estado.toLowerCase()">{{ p.estado }}</span>
              <span class="fecha">{{ fecha(p.creado) }}</span>
            </header>
            <p class="quien">{{ p.cliente }} ({{ p.correo }})</p>
            <ul>
              <li v-for="d in p.detalles" :key="d.instanciaId">{{ d.cantidad }} x {{ d.nombre }} a {{ Q(d.precioUnitario) }}</li>
            </ul>
            <div class="entrega-pedido" :class="{ domicilio: p.tipoEntrega === 'Domicilio' }">
              <template v-if="p.tipoEntrega === 'Domicilio'">
                <b>Entrega a domicilio</b>
                <span>{{ p.direccion }}</span>
                <span v-if="p.entregaFecha">{{ fechaLarga(p.entregaFecha) }}<template v-if="p.entregaFranja">, {{ rango(p.entregaFranja) }}</template></span>
                <a
                  v-if="p.latitud != null && p.longitud != null"
                  :href="'https://www.google.com/maps?q=' + p.latitud + ',' + p.longitud" target="_blank" rel="noopener"
                >Ver el punto en Google Maps</a>
              </template>
              <template v-else><b>El cliente recoge en la tienda aliada</b></template>
            </div>
            <p v-if="p.nota" class="nota-cliente">Nota: {{ p.nota }}</p>
            <footer>
              <strong>Total {{ Q(p.total) }}</strong>
              <span v-if="p.estado === 'Pendiente'" class="botones">
                <button class="btn azul chico" @click="pedirCambioEstado(p, 'Completado')">Marcar vendido</button>
                <button class="btn contorno chico peligro" @click="pedirCambioEstado(p, 'Cancelado')">Cancelar</button>
              </span>
            </footer>
          </article>
        </section>
      </template>

      <!-- ================= Admin: clientes ================= -->
      <template v-else-if="vista === 'clientes'">
        <div class="titulo-fila">
          <h2 class="titulo">Clientes</h2>
          <button class="btn naranja" @click="copiarCorreos">Copiar correos que aceptan ofertas</button>
        </div>
        <p v-if="!clientes.length" class="vacio">Todavía no hay clientes registrados.</p>
        <section class="lista">
          <article v-for="c in clientes" :key="c.id" class="fila-cliente">
            <div>
              <strong>{{ c.nombre }}</strong>
              <p>{{ c.correo }}</p>
              <small>{{ c.pedidos }} pedido(s). {{ c.aceptaOfertas ? 'Acepta ofertas.' : 'No quiere ofertas.' }}</small>
            </div>
            <button class="btn contorno chico" @click="pedirNuevaClave(c)">Nueva clave</button>
          </article>
        </section>
      </template>

      <!-- ================= Admin: entregas ================= -->
      <template v-else-if="vista === 'entregas'">
        <h2 class="titulo">Entregas</h2>

        <section class="bloque">
          <h3>Punto de recogida (tienda aliada)</h3>
          <p class="aviso">Esto es lo que ve el cliente cuando elige recoger su pedido.</p>
          <form class="form-recogida" @submit.prevent="guardarRecogida">
            <label>Nombre de la tienda <input v-model="recogidaForm.nombre" type="text" maxlength="100" /></label>
            <label>Dirección <input v-model="recogidaForm.direccion" type="text" maxlength="300" /></label>
            <label>Indicaciones <input v-model="recogidaForm.indicaciones" type="text" maxlength="500" placeholder="Ej. Pregunta por el pedido a nombre de SiConJ" /></label>
            <label>Horario de la tienda <input v-model="recogidaForm.horario" type="text" maxlength="200" placeholder="Ej. Lunes a sábado de 9:00 am a 6:00 pm" /></label>
            <button class="btn azul" :disabled="guardandoRecogida">{{ guardandoRecogida ? 'Guardando…' : 'Guardar punto de recogida' }}</button>
          </form>
        </section>

        <section class="bloque">
          <h3>Horarios de entrega a domicilio</h3>
          <p class="aviso">
            El cliente solo puede elegir los horarios activos. Para quitar un horario de lunes a viernes, desmárcalo o quítalo.
            Los cambios se guardan al instante.
          </p>
          <div v-for="dia in DIAS_ORDEN" :key="dia" class="dia-horarios">
            <h4>{{ DIAS[dia] }}</h4>
            <p v-if="!horariosAdmin(dia).length" class="aviso">Sin entregas este día.</p>
            <div v-for="h in horariosAdmin(dia)" :key="h.id" class="fila-horario">
              <label class="check"><input v-model="h.activo" type="checkbox" @change="guardarHorario(h)" /> Activo</label>
              <label>De <input v-model="h.inicio" type="time" @change="guardarHorario(h)" /></label>
              <label>a <input v-model="h.fin" type="time" @change="guardarHorario(h)" /></label>
              <button class="btn contorno chico peligro" @click="pedirBorrarHorario(h)">Quitar</button>
            </div>
            <button class="btn texto chico" @click="agregarHorario(dia)">+ Agregar horario</button>
          </div>
        </section>
      </template>
    </main>

    <footer class="pie">
      <strong>SiConJ</strong> es un negocio familiar. Si tienes dudas sobre una pieza, haz tu pedido y te confirmamos.
    </footer>

    <!-- ================= Panel de pedido ================= -->
    <div v-if="panelPedido" class="velo" @click.self="cerrarPedido">
      <aside class="panel" role="dialog" aria-label="Mi pedido">
        <header>
          <h2>{{ confirmacion ? 'Pedido registrado' : 'Mi pedido' }}</h2>
          <button class="btn texto" @click="cerrarPedido">Cerrar</button>
        </header>

        <div v-if="confirmacion" class="confirmado">
          <p class="gran">Tu pedido #{{ confirmacion.id }} quedó guardado.</p>
          <p>Reservamos tus piezas. Total: <b>{{ Q(confirmacion.total) }}</b>.</p>

          <div v-if="confirmacion.tipo === 'Recoger'" class="caja-info">
            <b>Recógelo en: {{ confirmacion.recogida.nombre }}</b>
            <span v-if="confirmacion.recogida.direccion">{{ confirmacion.recogida.direccion }}</span>
            <span v-if="confirmacion.recogida.indicaciones">{{ confirmacion.recogida.indicaciones }}</span>
            <span v-if="confirmacion.recogida.horario">Horario: {{ confirmacion.recogida.horario }}</span>
            <span>Te avisaremos cuando esté listo para recoger.</span>
          </div>
          <div v-else class="caja-info">
            <b>Entrega a domicilio</b>
            <span>{{ confirmacion.direccion }}</span>
            <span>{{ fechaLarga(confirmacion.fecha) }}, {{ rango(confirmacion.franja) }}</span>
            <span>Te confirmaremos la entrega y el pago.</span>
          </div>

          <a v-if="urlWhatsApp" class="btn azul ancho" :href="urlWhatsApp" target="_blank" rel="noopener">Avisar por WhatsApp</a>
          <button class="btn contorno ancho" @click="cerrarPedido">Seguir viendo el catálogo</button>
        </div>

        <template v-else>
          <p v-if="!pedido.length" class="vacio">Tu pedido está vacío. Agrega piezas desde el catálogo.</p>
          <ul v-else class="items">
            <li v-for="it in pedido" :key="it.id">
              <div>
                <b>{{ it.nombre }}</b>
                <small>{{ Q(it.precio) }} c/u</small>
              </div>
              <div class="cant">
                <button class="mini" aria-label="Quitar uno" @click="cambiarCant(it, -1)">-</button>
                <span>{{ it.cant }}</span>
                <button class="mini" aria-label="Agregar uno" :disabled="it.cant >= it.stock" @click="cambiarCant(it, 1)">+</button>
              </div>
              <button class="btn texto chico" @click="quitar(it)">Quitar</button>
            </li>
          </ul>

          <div v-if="pedido.length" class="resumen">
            <fieldset class="entrega">
              <legend>¿Cómo recibes tu pedido?</legend>

              <label class="opcion" :class="{ on: datos.tipo === 'Recoger' }">
                <input v-model="datos.tipo" type="radio" value="Recoger" />
                <span><b>Recoger en tienda aliada</b></span>
              </label>
              <label class="opcion" :class="{ on: datos.tipo === 'Domicilio', off: !hayHorarios }">
                <input v-model="datos.tipo" type="radio" value="Domicilio" :disabled="!hayHorarios" />
                <span><b>Entrega a domicilio</b><small v-if="!hayHorarios">No hay horarios de entrega por ahora.</small></span>
              </label>

              <div v-if="datos.tipo === 'Recoger'" class="caja-info">
                <b>{{ entrega.recogida.nombre || 'Punto de recogida' }}</b>
                <span v-if="entrega.recogida.direccion">{{ entrega.recogida.direccion }}</span>
                <span v-if="entrega.recogida.indicaciones">{{ entrega.recogida.indicaciones }}</span>
                <span v-if="entrega.recogida.horario">Horario: {{ entrega.recogida.horario }}</span>
                <span v-if="!entrega.recogida.direccion">Te confirmaremos el lugar exacto cuando envíes el pedido.</span>
              </div>

              <div v-else class="domicilio">
                <label>Dirección (escríbela con detalle)
                  <textarea v-model="datos.direccion" rows="2" maxlength="300" placeholder="Zona, colonia, calle, número de casa, referencias"></textarea>
                </label>
                <MapaEntrega v-model="datos.coords" />
                <label>Día de entrega
                  <select v-model="datos.fecha">
                    <option value="" disabled>Elige un día</option>
                    <option v-for="f in fechasDisponibles" :key="f.valor" :value="f.valor">{{ f.texto }}</option>
                  </select>
                </label>
                <label>Horario
                  <select v-model="datos.franja" :disabled="!datos.fecha">
                    <option value="" disabled>{{ datos.fecha ? 'Elige un horario' : 'Primero elige el día' }}</option>
                    <option v-for="h in franjasElegidas" :key="h.id" :value="`${h.inicio}-${h.fin}`">{{ rango(`${h.inicio}-${h.fin}`) }}</option>
                  </select>
                </label>
                <p v-if="!fechasDisponibles.length" class="aviso">No hay días con horario de entrega disponibles. Elige recoger en la tienda.</p>
              </div>
            </fieldset>

            <label>Nota para la tienda (opcional)
              <textarea v-model="nota" rows="2" maxlength="300" placeholder="Ej. Llamar antes de llegar"></textarea>
            </label>
            <p class="total">Total <strong>{{ Q(totalPedido) }}</strong></p>
            <p v-if="!esCliente" class="aviso">Para enviar el pedido necesitas tu clave de cliente.</p>
            <p v-else-if="erroresEntrega.length" class="aviso">{{ erroresEntrega[0] }}</p>
            <button class="btn naranja ancho" :disabled="enviando" @click="enviarPedido">
              {{ enviando ? 'Enviando…' : esCliente ? 'Enviar pedido' : 'Ingresar para enviar' }}
            </button>
          </div>
        </template>
      </aside>
    </div>

    <!-- ================= Acceso ================= -->
    <div v-if="acceso.abierto" class="velo centro" @click.self="acceso.abierto = false">
      <form class="modal" @submit.prevent="enviarAcceso">
        <template v-if="acceso.modo === 'clave'">
          <h2>Ingresa con tu clave</h2>
          <p v-if="acceso.motivo" class="aviso">{{ acceso.motivo }}</p>
          <label>Clave
            <input v-model="acceso.clave" type="password" autocomplete="off" autocapitalize="characters" autofocus placeholder="Tu clave de 6 caracteres" required />
          </label>
          <p v-if="acceso.error" class="error">{{ acceso.error }}</p>
          <button class="btn azul ancho" :disabled="acceso.cargando">{{ acceso.cargando ? 'Verificando…' : 'Entrar' }}</button>
          <button type="button" class="btn texto ancho" @click="cambiarModo('registro')">No tengo clave. Crear mi cuenta</button>
          <button type="button" class="btn texto ancho" @click="cambiarModo('recuperar')">Olvidé mi clave</button>
        </template>

        <template v-else-if="acceso.modo === 'admin'">
          <h2>Un paso más</h2>
          <p class="aviso">Escribe la clave de administrador.</p>
          <label>Clave de administrador
            <input v-model="acceso.clave" type="password" autocomplete="off" autofocus required />
          </label>
          <p v-if="acceso.error" class="error">{{ acceso.error }}</p>
          <button class="btn azul ancho" :disabled="acceso.cargando">{{ acceso.cargando ? 'Verificando…' : 'Entrar' }}</button>
        </template>

        <template v-else-if="acceso.modo === 'recuperar'">
          <h2>Recuperar mi clave</h2>
          <p class="aviso">Escribe el correo con el que te registraste y te enviaremos una clave nueva.</p>
          <label>Correo <input v-model="acceso.correo" type="email" maxlength="120" autocomplete="email" required /></label>
          <p v-if="acceso.error" class="error">{{ acceso.error }}</p>
          <p v-if="acceso.info" class="exito">{{ acceso.info }}</p>
          <button class="btn azul ancho" :disabled="acceso.cargando">{{ acceso.cargando ? 'Enviando…' : 'Enviarme una clave nueva' }}</button>
          <button type="button" class="btn texto ancho" @click="cambiarModo('clave')">Ya tengo mi clave</button>
        </template>

        <template v-else>
          <h2>Crear mi cuenta</h2>
          <p class="aviso">Te daremos una clave personal de 6 caracteres para entrar y hacer pedidos.</p>
          <label>Nombre <input v-model="acceso.nombre" type="text" maxlength="80" autocomplete="name" required /></label>
          <label>Correo <input v-model="acceso.correo" type="email" maxlength="120" autocomplete="email" required /></label>
          <label class="check"><input v-model="acceso.ofertas" type="checkbox" /> Quiero recibir ofertas y novedades por correo</label>
          <p v-if="acceso.error" class="error">{{ acceso.error }}</p>
          <button class="btn azul ancho" :disabled="acceso.cargando">{{ acceso.cargando ? 'Creando…' : 'Crear cuenta' }}</button>
          <button type="button" class="btn texto ancho" @click="cambiarModo('clave')">Ya tengo clave</button>
        </template>
      </form>
    </div>

    <!-- ================= Clave generada (se muestra una sola vez) ================= -->
    <div v-if="claveMostrada" class="velo centro">
      <div class="modal" role="dialog" aria-label="Clave de cliente">
        <h2>{{ claveMostrada.titulo }}</h2>
        <p>Clave de {{ claveMostrada.nombre }}. Guárdala ahora: <b>no se vuelve a mostrar</b>.</p>
        <p v-if="claveMostrada.correo" class="aviso">También se la enviamos por correo.</p>
        <p class="clave-grande">{{ claveMostrada.clave }}</p>
        <button class="btn contorno ancho" @click="copiar(claveMostrada.clave, 'Clave copiada.')">Copiar clave</button>
        <button class="btn azul ancho" @click="claveMostrada = null">Ya la guardé</button>
      </div>
    </div>

    <!-- ================= Producto (admin) ================= -->
    <div v-if="modalProducto" class="velo centro" @click.self="modalProducto = false">
      <form class="modal ancho-modal" @submit.prevent="guardarProducto">
        <h2>{{ form.id ? 'Editar producto' : 'Nuevo producto' }}</h2>

        <div class="dos-col">
          <div>
            <label>Nombre
              <input v-model="form.nombre" type="text" maxlength="120" />
              <small v-if="intentado && errores.nombre" class="error">{{ errores.nombre }}</small>
            </label>
            <label>Descripción
              <textarea v-model="form.descripcion" rows="3" maxlength="255" placeholder="Qué es, edición, detalles importantes"></textarea>
              <small class="contador">{{ form.descripcion.length }}/255</small>
            </label>
            <div class="par">
              <label>Categoría
                <select v-model="form.categoriaId">
                  <option v-for="c in categorias" :key="c.id" :value="c.id">{{ c.nombre }}</option>
                </select>
              </label>
              <label>Condición
                <select v-model="form.condicionId">
                  <option v-for="c in condiciones" :key="c.id" :value="c.id">{{ c.nombre }}</option>
                </select>
              </label>
            </div>
            <div class="par">
              <label>Precio (Q)
                <input v-model.number="form.precio" type="number" min="0.01" step="0.01" />
                <small v-if="intentado && errores.precio" class="error">{{ errores.precio }}</small>
              </label>
              <label>Unidades
                <input v-model.number="form.stock" type="number" min="0" step="1" />
                <small v-if="intentado && errores.stock" class="error">{{ errores.stock }}</small>
              </label>
            </div>
            <label>Notas de condición (opcional)
              <input v-model="form.notas" type="text" maxlength="500" placeholder="Ej. caja con una esquina doblada" />
            </label>
          </div>

          <div>
            <label>Foto del producto
              <input type="file" accept="image/jpeg,image/png,image/webp" @change="onFoto" />
              <small>JPG, PNG o WEBP, hasta 3 MB.</small>
            </label>
            <div class="vista-previa">
              <img v-if="fotoForm" :src="fotoForm" alt="Vista previa de la foto" />
              <span v-else>La foto aparecerá aquí</span>
            </div>
          </div>
        </div>

        <div class="par">
          <button type="button" class="btn contorno ancho" @click="modalProducto = false">Cancelar</button>
          <button class="btn azul ancho" :disabled="guardando">{{ guardando ? 'Guardando…' : form.id ? 'Guardar cambios' : 'Publicar producto' }}</button>
        </div>
      </form>
    </div>

    <!-- ================= Confirmación Sí / No ================= -->
    <div v-if="confirma.abierto" class="velo centro" @click.self="!confirma.trabajando && (confirma.abierto = false)">
      <div class="modal confirmar" role="alertdialog" :aria-label="confirma.titulo">
        <h2>{{ confirma.titulo }}</h2>
        <p v-if="confirma.texto">{{ confirma.texto }}</p>
        <p v-if="confirma.error" class="error">{{ confirma.error }}</p>
        <div class="par">
          <button type="button" class="btn contorno ancho" :disabled="confirma.trabajando" @click="confirma.abierto = false">No</button>
          <button type="button" class="btn ancho" :class="confirma.peligro ? 'rojo' : 'azul'" :disabled="confirma.trabajando" @click="ejecutarConfirma()">
            {{ confirma.trabajando ? 'Un momento…' : confirma.si }}
          </button>
        </div>
        <button
          v-if="confirma.extra" type="button" class="btn naranja ancho" :disabled="confirma.trabajando"
          @click="ejecutarConfirma(confirma.extra.accion)"
        >{{ confirma.extra.texto }}</button>
      </div>
    </div>

    <!-- ================= Aviso flotante ================= -->
    <div v-if="toast.texto" class="toast" :class="toast.tipo" role="status">{{ toast.texto }}</div>
  </div>
</template>

<style>
body { margin: 0; background: #f6f9ff; }
</style>

<style scoped>
.app {
  --azul: #2f6fed; --azul-osc: #17306b; --cielo: #eaf2ff; --borde: #d3e1fb;
  --rojo: #ff6b6b; --rojo-cl: #ffe3e3;
  --naranja: #ff9f43; --naranja-cl: #ffefd9;
  --lila: #9d86f2; --lila-cl: #efeaff;
  --verde: #2fb67c;
  --texto: #1b2a4b; --suave: #5b6a8c;
  font-family: 'Nunito', system-ui, sans-serif;
  color: var(--texto);
  min-height: 100vh;
  display: flex; flex-direction: column;
}
h1, h2, h3, .nombre strong, .precio, .gran { font-family: 'Fredoka', 'Nunito', system-ui, sans-serif; font-weight: 600; }
button, input, select, textarea { font: inherit; }
button:focus-visible, input:focus-visible, select:focus-visible, textarea:focus-visible, a:focus-visible {
  outline: 3px solid var(--naranja); outline-offset: 2px;
}

/* ----- botones ----- */
.btn { border: 2px solid transparent; border-radius: 14px; padding: 10px 18px; font-weight: 700; cursor: pointer; transition: transform .1s; text-decoration: none; display: inline-block; text-align: center; }
.btn:active:not(:disabled) { transform: translateY(1px); }
.btn:disabled { opacity: .5; cursor: not-allowed; }
.btn.azul { background: var(--azul); color: #fff; }
.btn.rojo { background: #e4484d; color: #fff; }
.btn.naranja { background: var(--naranja); color: #3a2200; }
.btn.contorno { background: #fff; color: var(--azul-osc); border-color: var(--borde); }
.btn.texto { background: none; color: var(--azul); padding: 8px 10px; }
.btn.peligro { color: #c23b3b; border-color: var(--rojo-cl); }
.btn.ancho { width: 100%; box-sizing: border-box; }
.btn.chico { padding: 6px 12px; font-size: .9rem; border-radius: 10px; }
.cuenta { background: var(--rojo); color: #fff; border-radius: 99px; padding: 1px 8px; font-size: .8rem; margin-left: 4px; }

/* ----- encabezado ----- */
.barra { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; justify-content: space-between; padding: 14px 24px; background: #fff; border-bottom: 4px solid var(--azul); position: sticky; top: 0; z-index: 5; }
.marca { display: flex; align-items: center; gap: 14px; }
.logo-ph { width: 92px; height: 56px; border: 2px dashed var(--azul); border-radius: 12px; display: grid; place-items: center; text-align: center; font-size: .72rem; line-height: 1.15; color: var(--azul); background: var(--cielo); padding: 4px; box-sizing: border-box; }
.logo-img { width: 90px; height: 90px; object-fit: cover; object-position: center; flex-shrink: 0; }
.nombre { display: flex; flex-direction: column; }
.nombre strong { font-size: 1.6rem; color: var(--azul); line-height: 1; }
.nombre small { color: var(--suave); }
.acciones { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.usuario { background: var(--lila-cl); color: #4a35b5; border-radius: 99px; padding: 6px 14px; font-weight: 700; }
.usuario.admin { background: var(--naranja-cl); color: #8a4b00; }

.admin-tabs { display: flex; flex-wrap: wrap; gap: 6px; padding: 10px 24px 0; background: var(--azul-osc); }
.admin-tabs button { border: 0; background: transparent; color: #cfe0ff; padding: 10px 18px; border-radius: 12px 12px 0 0; font-weight: 700; cursor: pointer; }
.admin-tabs button.on { background: #f6f9ff; color: var(--azul-osc); }

/* ----- contenido ----- */
.contenido { flex: 1; width: 100%; max-width: 1200px; margin: 0 auto; padding: 24px; box-sizing: border-box; }
.portada { margin-bottom: 22px; max-width: 62ch; }
.portada h1 { font-size: clamp(1.7rem, 3.6vw, 2.5rem); color: var(--azul-osc); margin: 0 0 6px; line-height: 1.15; }
.portada p { margin: 0; color: var(--suave); font-size: 1.05rem; }

.filtros { display: flex; flex-wrap: wrap; gap: 12px 16px; align-items: center; margin-bottom: 18px; }
.buscar { flex: 1 1 240px; max-width: 340px; padding: 11px 16px; border: 2px solid var(--borde); border-radius: 14px; background: #fff; }
.chips { display: flex; flex-wrap: wrap; gap: 8px; }
.chip { border: 2px solid transparent; border-radius: 99px; padding: 7px 16px; font-weight: 700; cursor: pointer; background: var(--cielo); color: var(--azul-osc); }
.chip.t1 { background: var(--cielo); }
.chip.t2 { background: var(--lila-cl); }
.chip.t3 { background: var(--naranja-cl); }
.chip.t0 { background: var(--rojo-cl); }
.chip.on { border-color: var(--azul-osc); box-shadow: 0 2px 0 var(--azul-osc); }
.check { display: inline-flex; align-items: center; gap: 8px; color: var(--suave); font-weight: 600; cursor: pointer; }

.franja-admin { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; justify-content: space-between; background: var(--naranja-cl); border: 2px dashed var(--naranja); border-radius: 14px; padding: 10px 16px; margin-bottom: 18px; }
.alerta { background: var(--rojo-cl); border-radius: 12px; padding: 12px 16px; }
.vacio { color: var(--suave); padding: 30px 0; font-size: 1.05rem; }

/* ----- tarjetas: empaque de juguete colgado ----- */
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(235px, 1fr)); gap: 22px; }
.tarjeta { --color: var(--azul); --suave-c: var(--cielo); background: #fff; border: 2px solid var(--color); border-radius: 18px; overflow: hidden; display: flex; flex-direction: column; }
.tarjeta.t0 { --color: var(--rojo); --suave-c: var(--rojo-cl); }
.tarjeta.t1 { --color: var(--azul); --suave-c: var(--cielo); }
.tarjeta.t2 { --color: var(--lila); --suave-c: var(--lila-cl); }
.tarjeta.t3 { --color: var(--naranja); --suave-c: var(--naranja-cl); }
.tarjeta.agotado { opacity: .78; }
.tarjeta.oculta { opacity: .6; border-style: dashed; }
.franja { background: var(--color); display: flex; align-items: center; justify-content: center; position: relative; padding: 12px 14px 8px; min-height: 38px; }
.hueco { position: absolute; top: 7px; left: 50%; width: 14px; height: 14px; margin-left: -7px; border-radius: 50%; background: #f6f9ff; box-shadow: inset 0 2px 0 rgba(0, 0, 0, .18); }
.etiqueta { color: #fff; font-weight: 700; font-size: .85rem; margin-top: 12px; text-shadow: 0 1px 0 rgba(0, 0, 0, .2); }
.foto { position: relative; aspect-ratio: 4 / 3; background: var(--suave-c); display: grid; place-items: center; }
.foto img { width: 100%; height: 100%; object-fit: cover; display: block; }
.sin-foto { color: var(--suave); font-size: .9rem; }
.sello { position: absolute; top: 12px; right: -6px; background: var(--rojo); color: #fff; font-weight: 700; padding: 4px 16px; border-radius: 8px 0 0 8px; transform: rotate(4deg); }
.sello.gris { background: #6b7794; }
.info { padding: 14px; display: flex; flex-direction: column; gap: 6px; flex: 1; }
.info h3 { margin: 0; font-size: 1.15rem; line-height: 1.2; }
.desc { margin: 0; color: var(--suave); font-size: .92rem; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.cond { margin: 0; font-size: .85rem; color: var(--suave); }
.cond b { color: var(--texto); }
.precio-fila { display: flex; justify-content: space-between; align-items: baseline; gap: 8px; margin-top: auto; padding-top: 6px; }
.precio { font-size: 1.4rem; color: var(--azul-osc); }
.stock { font-size: .85rem; color: var(--verde); font-weight: 700; }
.stock.poco { color: #d9570a; }
.agotado .stock { color: var(--suave); }
.admin-fila { display: flex; gap: 6px; }
.admin-fila .btn { flex: 1; padding-left: 6px; padding-right: 6px; }

/* ----- admin: pedidos, clientes y entregas ----- */
.titulo { font-size: 1.6rem; color: var(--azul-osc); margin: 0 0 12px; }
.titulo-fila { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px; margin-bottom: 8px; }
.lista { display: grid; gap: 14px; margin-top: 14px; }
.fila-pedido, .fila-cliente, .bloque { background: #fff; border: 2px solid var(--borde); border-radius: 16px; padding: 14px 16px; }
.fila-pedido header { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
.fila-pedido .fecha { color: var(--suave); margin-left: auto; font-size: .9rem; }
.fila-pedido .quien { margin: 6px 0; color: var(--suave); }
.fila-pedido ul { margin: 6px 0; padding-left: 20px; }
.fila-pedido footer { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px; margin-top: 8px; }
.entrega-pedido { display: grid; gap: 2px; background: var(--cielo); border-radius: 10px; padding: 8px 12px; margin: 6px 0; }
.entrega-pedido.domicilio { background: var(--naranja-cl); }
.entrega-pedido a { color: var(--azul); font-weight: 700; }
.botones { display: flex; gap: 8px; }
.nota-cliente { background: var(--lila-cl); border-radius: 10px; padding: 8px 12px; margin: 6px 0; }
.estado { border-radius: 99px; padding: 2px 12px; font-size: .85rem; font-weight: 700; }
.estado.pendiente { background: var(--naranja-cl); color: #8a4b00; }
.estado.completado { background: #d9f6e9; color: #1d7a53; }
.estado.cancelado { background: var(--rojo-cl); color: #a53030; }
.fila-cliente { display: flex; justify-content: space-between; align-items: center; gap: 12px; }
.fila-cliente p { margin: 2px 0; color: var(--suave); }
.fila-cliente small { color: var(--suave); }

.bloque { margin-bottom: 18px; }
.bloque h3 { margin: 0 0 4px; color: var(--azul-osc); }
.form-recogida { display: grid; gap: 10px; max-width: 560px; margin-top: 10px; }
.form-recogida label, .fila-horario label { display: grid; gap: 4px; font-weight: 700; font-size: .92rem; }
.form-recogida input, .fila-horario input[type='time'] { padding: 9px 12px; border: 2px solid var(--borde); border-radius: 12px; background: #fff; box-sizing: border-box; }
.dia-horarios { border-top: 2px dashed var(--borde); padding: 10px 0; }
.dia-horarios h4 { margin: 0 0 6px; color: var(--azul-osc); }
.fila-horario { display: flex; flex-wrap: wrap; align-items: flex-end; gap: 10px 14px; margin-bottom: 8px; }
.fila-horario .check { align-items: center; display: inline-flex; }

/* ----- paneles y modales ----- */
.velo { position: fixed; inset: 0; background: rgba(23, 48, 107, .45); z-index: 20; display: flex; justify-content: flex-end; }
.velo.centro { justify-content: center; align-items: center; padding: 16px; }
.panel { background: #fff; width: min(440px, 100%); height: 100%; overflow-y: auto; padding: 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 12px; }
.panel header { display: flex; justify-content: space-between; align-items: center; }
.panel h2, .modal h2 { margin: 0; color: var(--azul-osc); }
.items { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.items li { display: grid; grid-template-columns: 1fr auto auto; gap: 10px; align-items: center; background: var(--cielo); border-radius: 12px; padding: 10px 12px; }
.items small { display: block; color: var(--suave); }
.cant { display: flex; align-items: center; gap: 8px; }
.mini { width: 28px; height: 28px; border-radius: 50%; border: 2px solid var(--azul); background: #fff; color: var(--azul); font-weight: 700; cursor: pointer; }
.mini:disabled { opacity: .4; cursor: not-allowed; }
.resumen { display: grid; gap: 10px; margin-top: auto; }
.resumen label { display: grid; gap: 4px; font-weight: 700; font-size: .92rem; }
.resumen textarea, .resumen select, .modal input[type='text'], .modal input[type='email'], .modal input[type='password'], .modal input[type='number'], .modal select, .modal textarea { width: 100%; box-sizing: border-box; padding: 10px 12px; border: 2px solid var(--borde); border-radius: 12px; background: #fff; }
.total { display: flex; justify-content: space-between; font-size: 1.2rem; margin: 0; }
.aviso { color: var(--suave); margin: 0; }
.confirmado { display: grid; gap: 12px; }
.gran { font-size: 1.4rem; color: var(--verde); margin: 0; }

.entrega { border: 2px solid var(--borde); border-radius: 14px; padding: 12px; display: grid; gap: 10px; margin: 0; }
.entrega legend { font-family: 'Fredoka', 'Nunito', sans-serif; font-weight: 600; color: var(--azul-osc); padding: 0 6px; }
.opcion { display: flex !important; grid-template-columns: none; align-items: flex-start; gap: 10px; border: 2px solid var(--borde); border-radius: 12px; padding: 10px 12px; cursor: pointer; font-weight: 600; }
.opcion.on { border-color: var(--azul); background: var(--cielo); }
.opcion.off { opacity: .55; cursor: not-allowed; }
.opcion small { display: block; color: var(--suave); font-weight: 400; }
.opcion input { margin-top: 4px; }
.caja-info { display: grid; gap: 3px; background: var(--naranja-cl); border-radius: 12px; padding: 10px 12px; font-size: .95rem; }
.domicilio { display: grid; gap: 10px; }

.modal { background: #fff; border-radius: 20px; padding: 22px; width: min(400px, 100%); max-height: 92vh; overflow-y: auto; box-sizing: border-box; display: grid; gap: 12px; border-top: 6px solid var(--azul); }
.modal.ancho-modal { width: min(760px, 100%); border-top-color: var(--naranja); }
.modal.confirmar { border-top-color: var(--rojo); }
.modal label { display: grid; gap: 4px; font-weight: 700; font-size: .92rem; }
.modal label.check { display: flex; font-weight: 600; }
.modal small { color: var(--suave); font-weight: 400; }
.error { color: #c23b3b; margin: 0; font-weight: 600; font-size: .9rem; }
.exito { color: #1d7a53; margin: 0; font-weight: 600; font-size: .95rem; }
.clave-grande { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 2rem; text-align: center; background: var(--naranja-cl); border: 2px dashed var(--naranja); border-radius: 12px; padding: 14px; margin: 0; letter-spacing: 6px; user-select: all; }
.dos-col { display: grid; grid-template-columns: 1.3fr 1fr; gap: 20px; }
.par { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.vista-previa { margin-top: 8px; aspect-ratio: 4 / 3; border: 2px dashed var(--borde); border-radius: 14px; background: var(--cielo); display: grid; place-items: center; overflow: hidden; color: var(--suave); text-align: center; }
.vista-previa img { width: 100%; height: 100%; object-fit: cover; }
.contador { text-align: right; }

.toast { position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%); background: var(--azul-osc); color: #fff; padding: 12px 20px; border-radius: 14px; z-index: 40; max-width: min(92vw, 440px); font-weight: 600; box-shadow: 0 6px 20px rgba(23, 48, 107, .3); }
.toast.err { background: #c23b3b; }
.pie { text-align: center; padding: 22px 16px; color: var(--suave); border-top: 2px solid var(--borde); background: #fff; }

@media (max-width: 680px) {
  .barra { padding: 12px 14px; }
  .contenido { padding: 16px 14px; }
  .dos-col, .par { grid-template-columns: 1fr; }
  .fila-cliente { flex-direction: column; align-items: flex-start; }
}
@media (prefers-reduced-motion: reduce) {
  .btn { transition: none; }
}
</style>
