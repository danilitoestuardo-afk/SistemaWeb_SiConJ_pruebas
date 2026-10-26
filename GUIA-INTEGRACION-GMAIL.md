# SiConJ: actualización integrada

## Contenido

- github/siconj-app/: proyecto fuente completo para copiar sobre tu proyecto local y subir a GitHub.
- CPANEL-SUBIR.zip: disponible en la raíz del paquete descargado; no forma parte del repositorio.
- Este documento: instrucciones de publicación y comprobación.

## Cambios integrados

Se tomó siconj-app(3).zip como base y se aplicó SiConJ-Gmail-local(1).zip:

- backend/Services/CorreoGmail.cs: envío SMTP de Gmail para pruebas locales.
- backend/Program.cs: usa Gmail únicamente si el entorno es Development y Correo:Modo es Gmail; en los demás casos conserva CorreoRelay.
- LEEME-GMAIL-LOCAL.md: pasos para configurar la cuenta mediante user-secrets.

Se conservaron las pantallas, controladores, modelos, SQL, logo y servicio de correo compartido del proyecto actual. No se necesitan paquetes nuevos ni migraciones de MySQL por esta integración. No vuelvas a ejecutar los scripts de instalación o migración solo por este cambio.

La plantilla cpanel-correo/enviar-correo.php se entrega con TOKEN y remitente de ejemplo para que pueda publicarse en GitHub. No reemplaces el PHP que ya tienes configurado en tu alojamiento. El ZIP de cPanel no contiene ese PHP.

## 1. Actualizar el proyecto y GitHub

1. Descomprime el paquete fuera de tu carpeta de trabajo.
2. Guarda una copia de tu proyecto actual.
3. Copia EL CONTENIDO de github/siconj-app/ dentro de tu carpeta local siconj-app/, aceptando reemplazar los archivos. No crees siconj-app/siconj-app/.
4. Conserva tu carpeta .git y los archivos frontend/.env y frontend/.env.development.local. El paquete no los reemplaza. Conserva también tus user-secrets y las variables existentes de Railway.
5. En una terminal situada en la raíz de tu proyecto, revisa:

```bash
git status
git diff
```

6. Comprueba que no se publiquen claves privadas o archivos .env. Después:

```bash
git add .
git commit -m "Integra correo Gmail para pruebas locales"
git push origin main
```

Si utilizas otra rama, cambia main por la rama conectada a Railway. Si Git muestra otros cambios tuyos, revísalos antes del commit.

7. Si Railway despliega automáticamente desde esa rama, espera a que termine y revisa sus registros. El directorio raíz del servicio continúa siendo backend y se conserva su Dockerfile.
8. No cambies el entorno de Railway a Development. En producción siguen utilizándose Correo__Url, Correo__Token y Correo__AvisoPedidos, además de las variables actuales de conexión, autenticación y CORS.

## 2. Actualizar cPanel

El cambio de Gmail no modifica el frontend. Se incluye una compilación nueva de la versión actual como solicitaste.

1. Respalda index.html, assets/ y logo-siconj.jpg de tu página actual.
2. En el Administrador de archivos de cPanel, abre public_html o la carpeta donde está publicada tu página.
3. Sube CPANEL-SUBIR.zip y extráelo en esa carpeta.
4. index.html debe quedar directamente en la carpeta de la página, al lado de assets/ y logo-siconj.jpg. Acepta reemplazar los archivos correspondientes.
5. Conserva correo/, enviar-correo.php, .htaccess y los demás archivos propios de tu alojamiento. No es necesario borrar las carpetas existentes.
6. Elimina el ZIP de la carpeta pública después de extraerlo y abre la página con Ctrl+F5 o en ventana privada.

La compilación utiliza la URL presente en el proyecto original:

https://backend-production-4406.up.railway.app

Si cambiaste de API, recompila antes de publicarla. En frontend/, copia .env.production.example a .env.production, ajusta VITE_API_URL y ejecuta npm ci y npm run build. Sube el contenido de dist/. Las opciones de WhatsApp y Google Maps permanecen vacías, igual que en la configuración suministrada.

## 3. Activar Gmail en tu computadora (opcional)

Subir este código no activa Gmail automáticamente. Para probarlo localmente, sigue LEEME-GMAIL-LOCAL.md y configura Correo:Modo, Correo:Gmail:Usuario, Correo:Gmail:ClaveAplicacion y Correo:AvisoPedidos mediante dotnet user-secrets dentro de backend/. Usa una contraseña de aplicación de Google; no la escribas en archivos del proyecto.

Para volver al relay en pruebas locales:

```powershell
dotnet user-secrets remove "Correo:Modo"
```

Reinicia la API después de cambiar la configuración. Gmail local no reemplaza al puente de cPanel en producción.

## 4. Verificaciones

Realizado al preparar el paquete:

- Comparación exacta del Program.cs y CorreoGmail.cs integrados contra el parche recibido.
- Conservación del servicio compartido Correo.cs, del código de pantallas y del logo original.
- Compilación del frontend con npm ci y npm run build: correcta, Vite 5.4.21, 15 módulos.
- Verificación de la URL de producción y de los archivos referenciados por index.html.
- Exclusión de .git, dependencias, binarios de compilaciones previas, archivos .env privados y el token del PHP original.

Pendiente en tu entorno:

1. Compilar el backend con dotnet build dentro de backend/ (este entorno de preparación no tiene el SDK de .NET).
2. Confirmar que el despliegue de Railway finaliza correctamente y que la API responde.
3. Abrir el catálogo, comprobar imágenes, entrar con tu cuenta y probar un pedido.
4. En local, probar el registro con una cuenta de prueba y confirmar recepción de Gmail. En producción, comprobar el correo mediante tu relay existente.

No se enviaron correos reales, no se conectó a MySQL y no se publicaron archivos en GitHub, Railway ni cPanel durante esta preparación. El envío conserva el comportamiento previo en segundo plano: la respuesta de la pantalla no confirma la recepción del correo.

Para esta integración sigue esta guía. GUIA-ACTUALIZACION.md corresponde a la actualización v2 anterior; no necesitas repetir su migración de base de datos.
