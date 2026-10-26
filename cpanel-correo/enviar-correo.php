<?php
// =====================================================================
// enviar-correo.php - Puente de correo de SiConJ (se sube a tu cPanel)
//
// Por qué existe: Railway bloquea el envío directo por SMTP en los planes Free/Trial/Hobby.
// La API llama a este archivo por HTTPS y este archivo manda el correo desde tu dominio.
//
// ANTES DE SUBIRLO cambia estas 3 cosas:
//   1) TOKEN: un texto largo al azar. El MISMO va en Railway como Correo__Token.
//   2) DESDE_CORREO: la cuenta de correo que creaste en cPanel solo para enviar (ej. no-responder@tudominio.com).
//   3) DESDE_NOMBRE: el nombre que verá el cliente.
// Súbelo, por ejemplo, a public_html/correo/enviar-correo.php
// =====================================================================
const TOKEN = 'CAMBIA-ESTE-TEXTO-LARGO-Y-SECRETO';
const DESDE_CORREO = 'no-responder@tudominio.com';
const DESDE_NOMBRE = 'SiConJ';
const MAX_POR_HORA = 60; // freno por si alguien llegara a descubrir el token

header('Content-Type: application/json; charset=utf-8');

function salir(int $codigo, string $mensaje): void
{
    http_response_code($codigo);
    echo json_encode(['mensaje' => $mensaje], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') salir(405, 'Método no permitido');
if (TOKEN === 'CAMBIA-ESTE-TEXTO-LARGO-Y-SECRETO') salir(500, 'Falta configurar el TOKEN en enviar-correo.php');

$recibido = $_SERVER['HTTP_X_TOKEN'] ?? '';
if (!hash_equals(TOKEN, $recibido)) salir(401, 'No autorizado');

$datos = json_decode(file_get_contents('php://input', false, null, 0, 200000), true);
if (!is_array($datos)) salir(400, 'Datos inválidos');

$para = trim((string)($datos['para'] ?? ''));
$asunto = trim(preg_replace('/[\r\n]+/', ' ', (string)($datos['asunto'] ?? '')));
$html = (string)($datos['html'] ?? '');

if (!filter_var($para, FILTER_VALIDATE_EMAIL) || preg_match('/[\r\n,;]/', $para)) salir(400, 'Correo de destino inválido');
// (usa mb_strlen si el servidor lo tiene; si no, strlen: el resultado sirve igual como límite)
function largo(string $s): int { return function_exists('mb_strlen') ? mb_strlen($s) : strlen($s); }
if ($asunto === '' || largo($asunto) > 150) salir(400, 'Asunto inválido');
if ($html === '' || largo($html) > 100000) salir(400, 'Mensaje inválido');

// Límite por hora (un archivo contador en la carpeta temporal del servidor)
$contador = sys_get_temp_dir() . '/siconj_correo_' . date('YmdH') . '.cnt';
$enviados = (int)@file_get_contents($contador);
if ($enviados >= MAX_POR_HORA) salir(429, 'Límite de correos por hora alcanzado');
@file_put_contents($contador, (string)($enviados + 1), LOCK_EX);

$cuerpo = '<!doctype html><html><body style="font-family:Arial,sans-serif;color:#1b2a4b;line-height:1.5">'
        . $html
        . '<hr style="border:0;border-top:1px solid #d3e1fb;margin-top:24px">'
        . '<p style="color:#5b6a8c;font-size:12px">SiConJ. Este es un mensaje automático, no respondas a este correo.</p>'
        . '</body></html>';

$cabeceras = implode("\r\n", [
    'MIME-Version: 1.0',
    'Content-Type: text/html; charset=UTF-8',
    'From: =?UTF-8?B?' . base64_encode(DESDE_NOMBRE) . '?= <' . DESDE_CORREO . '>',
    'X-Mailer: SiConJ',
]);

$ok = mail($para, '=?UTF-8?B?' . base64_encode($asunto) . '?=', $cuerpo, $cabeceras, '-f' . DESDE_CORREO);
if (!$ok) salir(502, 'El servidor no pudo enviar el correo');

echo json_encode(['mensaje' => 'Enviado'], JSON_UNESCAPED_UNICODE);
