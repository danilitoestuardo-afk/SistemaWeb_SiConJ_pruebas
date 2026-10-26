# SiConJ v2 — Proyecto integrado

Este proyecto integra los cambios de actualizacion-v2.zip sobre el proyecto original completo. Incluye claves de cliente de seis caracteres, entrega obligatoria, horarios y punto de recogida administrables, correo mediante cPanel y confirmaciones Sí/No para las acciones de la actualización. Conserva el archivo y la presentación del logo original.

Empieza por GUIA-ACTUALIZACION.md. No se agregó compatibilidad con el frontend anterior: debes actualizar ambos componentes antes de abrir la página.

Carpetas:
- database/: migración, consulta de verificación y esquema para una base nueva.
- backend/: API completa ASP.NET Core 8 y Dockerfile.
- frontend/: aplicación Vue y archivo .env.example.
- cpanel-correo/: puente de correo PHP.

No incluye credenciales, .env real, node_modules ni archivos compilados. Conserva tus variables actuales y tu .env real. No reemplaces tu proyecto por una carpeta vacía: copia estos archivos sobre él.
