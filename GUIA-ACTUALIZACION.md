# Guía de actualización SiConJ v2

## Qué contiene y qué se respetó

Se integró la actualización sobre el proyecto original, conservando los archivos de backend que no venían en el ZIP parcial. Se mantuvo frontend/public/logo-siconj.jpg y su presentación original de 90 × 90 píxeles. La página nueva exige elegir Recoger o Domicilio; el backend rechaza un pedido que omita esa elección.

Se conservaron el formato nuevo de las claves y el funcionamiento de registro y recuperación por correo de la actualización, según tu indicación. No se incorporó una transición para claves antiguas ni para el frontend anterior. La migración comprueba cada columna antes de crearla para permitir repetirla si una ejecución queda incompleta.

## 1. Preparar y detener la página

1. Guarda una copia del proyecto actual y un respaldo de MySQL.
2. Pon tu página en mantenimiento o retira temporalmente el acceso desde cPanel hasta terminar. Así evitas que se use el frontend anterior con la API nueva.
3. Descomprime este ZIP fuera de tu carpeta actual. Copia el contenido de siconj-app/ sobre tu proyecto, respetando las rutas backend/, frontend/ y database/. No borres tu .git ni tu frontend/.env. Puedes conservar los archivos antiguos que no se sobrescriban.
4. Si vas a vaciar datos de prueba, hazlo en esta etapa y verifica la base seleccionada. Este paquete NO borra datos automáticamente.

## 2. Actualizar la base de datos

Conecta MySQL Workbench a MySQL de Railway y selecciona la misma base que utiliza la API.

- Si la base actual ya tiene las tablas del sistema: ejecuta TODO database/migracion-v2.sql. Revisa el registro de ejecución completo y detente si aparece un error.
- Si creaste una base completamente vacía: usa SOLO database/schema-v2-instalacion-nueva.sql. No lo ejecutes encima de la base existente.

Después ejecuta database/verificar-v2.sql. La primera consulta debe mostrar siete columnas nuevas: oculto en inventario, y tipo_entrega, direccion, latitud, longitud, entrega_fecha y entrega_franja en pedidos. Las siguientes consultas deben devolver los ajustes de recogida y los horarios de ejemplo.

Vaciar registros y crear una base nueva son operaciones diferentes. Si solo vacías registros pero conservas las tablas, usa la migración.

## 3. Configurar el correo en cPanel

1. En cpanel-correo/enviar-correo.php modifica TOKEN, DESDE_CORREO y DESDE_NOMBRE. Usa un token largo y aleatorio.
2. Configura la cuenta remitente de tu dominio en cPanel.
3. Sube el archivo a public_html/correo/enviar-correo.php, o a la ruta equivalente de tu dominio.
4. En el servicio de la API de Railway agrega:

| Variable | Valor |
|---|---|
| Correo__Url | https://TU-DOMINIO/correo/enviar-correo.php |
| Correo__Token | El mismo TOKEN del archivo PHP |
| Correo__AvisoPedidos | Correo del administrador que recibirá los pedidos |

No publiques el token real en GitHub: edita la copia del PHP destinada a cPanel y deja la plantilla sin secretos en el repositorio. Si el correo no se configura, el catálogo y los pedidos siguen funcionando; la recuperación requiere tenerlo configurado.

## 4. Actualizar el backend en Railway

1. Conserva las variables existentes: Jwt__Key, Admin__Pin, Admin__Clave, Cors__Origins y las de conexión a MySQL (o ConnectionStrings__Default).
2. Desde la raíz de tu proyecto local revisa git status y git diff. Agrega únicamente los archivos que deseas publicar. No incluyas .env ni secretos del PHP.
3. Haz commit y push a la rama que usa tu servicio de Railway. Si el despliegue es automático, espera a que termine; de lo contrario ejecuta el despliegue manual habitual.
4. Mantén backend como directorio raíz del servicio y usa su Dockerfile actual.
5. Revisa que el despliegue termine correctamente y que la URL raíz de la API responda “SiConJ API en línea”. Esto confirma el arranque; las funciones se prueban al final.

Si tu repositorio también despliega el frontend automáticamente, prepara su configuración de producción antes del push o mantén el acceso público en mantenimiento hasta finalizar.

## 5. Compilar y subir el frontend

Conserva frontend/.env y revisa estos valores antes de compilar:

```dotenv
VITE_API_URL=https://TU-API-DE-RAILWAY
VITE_WHATSAPP=502TU-NUMERO
VITE_GOOGLE_MAPS_KEY=
VITE_GOOGLE_MAP_ID=
```

VITE_API_URL debe contener la API real, sin /api al final. No uses localhost en producción. Google Maps es opcional: para habilitarlo utiliza una clave configurada para Maps JavaScript API y restringida a tu dominio. Sin ella queda la dirección escrita y la opción de ubicación del dispositivo, sujeta al permiso del navegador.

En una terminal dentro de frontend/:

```bash
npm ci
npm run build
```

Si la compilación falla, corrige el error antes de publicar. Sube EL CONTENIDO de frontend/dist/ a la carpeta pública donde está la página, no la carpeta dist completa ni el proyecto fuente. Incluye logo-siconj.jpg. Conserva correo/ y otros archivos de tu alojamiento que no pertenecen al frontend.

Verifica que Cors__Origins incluya el origen exacto de la página, por ejemplo https://tudominio.com. Abre una ventana privada o recarga sin caché al probar la versión nueva.

## 6. Verificar antes de habilitar el acceso

1. Confirma que aparece el logo original.
2. Entra como administrador con el PIN y la clave actuales.
3. En Entregas, configura la tienda aliada y reemplaza los horarios de ejemplo por los reales.
4. Registra un cliente de prueba: comprueba la clave de seis caracteres, el acceso y la recepción del correo.
5. Crea un pedido para recoger y otro a domicilio con dirección, fecha y horario. Comprueba el descuento de existencias, los datos en Pedidos y el aviso al administrador.
6. Intenta enviar un pedido sin elegir entrega: debe impedirlo. Prueba un horario desactivado: no debe aceptarlo.
7. Cancela un pedido y comprueba que el stock se devuelve.
8. Elimina una pieza sin pedidos y revisa la confirmación Sí/No. Con una pieza que tenga historial, comprueba que se ofrezca ocultarla y que desaparezca del catálogo público.
9. Prueba “Olvidé mi clave” con tu cuenta de prueba y confirma la recepción antes de dar por validado el correo.
10. Cuando todo pase, retira el mantenimiento de la página.

## Validación de esta entrega

Se comparó el proyecto integrado con los dos ZIP de origen, se comprobó que el logo conserva exactamente sus bytes y se revisó la sintaxis JavaScript de los dos componentes Vue y se ejecutó npm run build con Vite 5.4.21 correctamente. La elección de entrega mantiene la validación obligatoria de la actualización.

En este entorno no se dispone del SDK de .NET, MySQL ni PHP para validar su ejecución. No se han probado conexiones reales a Railway, cPanel o al correo. Las pruebas de la sección anterior son necesarias antes de habilitar el acceso público.
