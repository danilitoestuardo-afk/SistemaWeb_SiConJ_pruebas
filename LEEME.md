# SiConJ - Catálogo en línea

Catálogo de coleccionables con cuentas de cliente, pedidos guardados y panel de administración.

```
siconj-app/
├── database/schema.sql     Tablas, datos iniciales (categorías, condiciones, estados)
├── backend/                API en C# (ASP.NET Core 8) + Dockerfile para Railway
└── frontend/               Página en Vue 3 (se compila y se sube a cPanel)
```

Flujo final: navegador → página Vue en cPanel → API en Railway (Docker) → MySQL en Railway.

## Cómo funciona el acceso (una sola casilla de clave)

| Quién escribe qué | Resultado |
|---|---|
| Un visitante | Ve el catálogo sin ingresar nada. |
| Cliente nuevo: "Crear mi cuenta" (nombre + correo) | El sistema genera su clave `SJ-XXXX-XXXX-XXXX`, **se muestra una sola vez**. |
| Cliente con su clave | Entra como cliente y puede enviar pedidos. |
| Alguien escribe el **PIN de admin** | Recibe un token que dura 5 minutos y **no da ningún permiso**; solo abre el paso 2. |
| PIN correcto + **clave de admin** | Entra como administrador (sesión de 3 horas). |

Por qué la clave de cliente se genera y no se elige: entra por la misma casilla que el PIN del admin; si cada cliente
eligiera la suya, dos podrían repetirla o alguien podría elegir justo el PIN. Una clave al azar evita ambos problemas.

## Variables de entorno (aquí viven los secretos; nada va en el código)

| Variable | Para qué | Ejemplo |
|---|---|---|
| `Jwt__Key` | Firma de las sesiones (mínimo 32 caracteres) | texto largo al azar |
| `Admin__Pin` | PIN del admin (mínimo 8 caracteres) | |
| `Admin__Clave` | Clave del admin (mínimo 10 caracteres, distinta al PIN) | |
| `Cors__Origins` | Dominios que pueden usar la API, separados por coma | `https://tudominio.com,http://localhost:5173` |
| `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE` | Conexión a MySQL (Railway las crea en su servicio MySQL) | |
| `ConnectionStrings__Default` | Alternativa: cadena de conexión completa (útil en local) | |

Al arrancar, la API guarda el PIN y la clave del admin **solo como hash**. Si cambias `Admin__Pin` o `Admin__Clave` y
reinicias, se actualizan.

## Probar en tu computadora

1. **Base de datos**: en MySQL 8 ejecuta
   `CREATE DATABASE catalogo_coleccionables CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`, selecciónala y corre `database/schema.sql`.
2. **API** (necesitas el SDK de .NET 8 o superior):
   ```
   cd backend
   dotnet user-secrets set "Jwt:Key" "pon-aqui-un-texto-largo-de-32-o-mas-caracteres"
   dotnet user-secrets set "Admin:Pin" "tu-pin-de-8+"
   dotnet user-secrets set "Admin:Clave" "tu-clave-de-10+-caracteres"
   dotnet user-secrets set "ConnectionStrings:Default" "Server=localhost;Database=catalogo_coleccionables;User=root;Password=TU_PASSWORD;"
   dotnet run
   ```
   La API queda en `http://localhost:5000`.
3. **Página** (necesitas Node.js):
   ```
   cd frontend
   copy .env.example .env      (en Mac/Linux: cp .env.example .env)
   npm install
   npm run dev
   ```
   Abre `http://localhost:5173`.

Prueba rápida: entra con el PIN, luego con la clave de admin, agrega un producto con foto; abre otra ventana, crea una cuenta
de cliente, haz un pedido y mira cómo baja el stock; en el panel de admin cancela el pedido y el stock regresa.

## Publicar

**Railway** (mañana)
1. Proyecto nuevo, agrega un servicio **MySQL**. Ejecuta `database/schema.sql` sobre su base `railway`
   (sin `CREATE DATABASE` ni `USE`).
2. Agrega un servicio desde tu repositorio con **Root Directory = `backend`**: Railway detecta el `Dockerfile`.
3. En Variables del servicio de la API pon `Jwt__Key`, `Admin__Pin`, `Admin__Clave`, `Cors__Origins` y las variables
   `MYSQL*` (puedes referenciarlas desde el servicio MySQL; revisa el nombre exacto en la pestaña Variables).
4. Genera el dominio público de la API (Settings, Networking).

**cPanel**
1. En `frontend/.env` pon `VITE_API_URL=https://la-url-de-tu-api-en-railway` (y `VITE_WHATSAPP` si quieres el botón de WhatsApp).
2. `npm run build`
3. Sube **el contenido** de `frontend/dist/` a `public_html` (o la subcarpeta que uses).
4. Agrega ese dominio a `Cors__Origins` en Railway.

## El logo

El encabezado trae un recuadro "Aquí va el logo". Para cambiarlo: copia `logo.png` a `frontend/public/` y en
`SiconJApp.vue` reemplaza el `<div class="logo-ph">` por `<img src="./logo.png" alt="SiConJ" class="logo-img" />`.

## Reglas del inventario

- Cada tarjeta es una unidad con su precio, condición y stock.
- Al enviar un pedido el stock baja de inmediato (si dos clientes piden la última pieza, solo uno la consigue).
  Si se acaba, la pieza queda **Reservada**.
- **Marcar vendido** deja la pieza como Agotada. **Cancelar** devuelve las unidades y vuelve a estar Disponible.
- Una pieza con pedidos registrados no se puede eliminar (se deja en stock 0).

## Seguridad: lo que ya está y lo que falta

- Ya está: claves con hash, PIN en dos pasos, bloqueo del admin 15 minutos tras 5 fallos, límite de 8 intentos por minuto
  por IP, fotos validadas por su contenido real (JPG/PNG/WEBP, hasta 3 MB), consultas parametrizadas.
- Las fotos se guardan en la base de datos (el disco de Railway se borra en cada despliegue).
- Falta, si el negocio crece: enviar los correos de ofertas (hoy el admin copia los correos de quienes aceptaron y los usa
  desde su correo), pagos en línea y envíos (están fuera del alcance del proyecto).
