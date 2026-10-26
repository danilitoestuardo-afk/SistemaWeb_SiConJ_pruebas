# Gmail para las pruebas locales de SiConJ

1. Detén el backend con Ctrl+C.
2. Copia backend/Program.cs sobre el de tu proyecto y agrega backend/Services/CorreoGmail.cs. Conserva Services/Correo.cs: contiene la interfaz y las plantillas compartidas. No hace falta modificar PHP, frontend o MySQL. No se requieren paquetes nuevos.
3. Activa la verificación en dos pasos de Google y crea una contraseña de aplicación llamada SiConJ local en https://myaccount.google.com/apppasswords . Usa esa contraseña, no tu contraseña habitual ni el token del PHP. No la compartas ni la guardes en el repositorio.
4. En PowerShell, dentro de backend/, ejecuta estos comandos reemplazando los valores de ejemplo:

```powershell
dotnet user-secrets set "Correo:Modo" "Gmail"
dotnet user-secrets set "Correo:Gmail:Usuario" "TU-CORREO@gmail.com"
dotnet user-secrets set "Correo:Gmail:ClaveAplicacion" "TU-CONTRASENA-DE-APLICACION"
dotnet user-secrets set "Correo:AvisoPedidos" "TU-CORREO@gmail.com"
dotnet run --launch-profile http
```

5. Con la API y el frontend locales abiertos, registra una cuenta de prueba con un correo tuyo que no esté registrado en la base local. Revisa Entrada y Spam. También puedes probar un pedido para verificar el aviso al administrador.

El modo Gmail se activa solo con Correo:Modo=Gmail y entorno Development (el perfil http del proyecto usa ese entorno). Los demás entornos conservan CorreoRelay. No se cambia Railway. Se conecta a smtp.gmail.com:587 con STARTTLS y una contraseña de aplicación.

El envío sigue siendo en segundo plano, igual que la versión existente: el aviso de la pantalla no confirma recepción. Revisa el buzón y la terminal del backend. Si hay un fallo, copia el error sin mostrar secretos. La recuperación de clave conserva el comportamiento previo y cambia la clave antes de confirmar el envío; usa una cuenta de prueba.

Verificación realizada: comparación de Program.cs para limitar el cambio al servicio de correo y revisión de las referencias a la interfaz existente. No hay SDK de .NET en el entorno de preparación: no se compiló este parche ni se envió correo real. Se validarán al ejecutarlo localmente con tu cuenta.

Ayuda oficial: https://support.google.com/mail/answer/185833?hl=es
