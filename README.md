# nuevoUsuario
Script para crear usuario de manera desatendida uniendolo a un grupo en particular


# Documentación del Script de Creación de Usuario y Grupo (Bash)

## Propósito
Este script en Bash automatiza la creación de:
- Un grupo secundario (si no existe).
- Un usuario del sistema (si no existe).
- Asigna el usuario al grupo secundario.
- Crea el home del usuario (-m).
- Configura la contraseña del usuario usando un archivo de configuración.

## Requisitos
- Ejecutar el script con permisos de administrador (sudo o como root), ya que crea grupos y usuarios y configura contraseñas.
- Tener un archivo `config.env` en el mismo directorio del script.

## Flujo del Script

### 1) Verificación de permisos (root)
Si EUID != 0, el script muestra:
Por favor, ejecuta este script usando sudo.
y termina con exit 1.

Si se ejecuta como root, continúa.

### 2) Verificación del archivo de configuración
El script verifica si existe `config.env`:
- Si no existe: muestra
El archivo config.env no existe.
y termina con exit 1.
- Si existe: carga variables con:
source config.env

### 3) Validación de variables principales
El script exige que no estén vacías:
- USUARIO
- CONTRASENA
- GRUPO

Si alguna falta, muestra:
Faltan datos en el archivo de configuración.
y termina.

### 4) Chequeo del grupo secundario (o creación)
El script busca el grupo con:
getent group "$GRUPO"

- Si existe: muestra
El grupo secundario $GRUPO ya existe.
- Si no existe: lo crea con:
groupadd "$GRUPO"
y muestra:
El grupo secundario $GRUPO ha sido creado.

### 5) Chequeo del usuario (o creación)
El script verifica si el usuario existe con:
id "$USUARIO"

- Si existe: muestra
El usuario $USUARIO ya existe. No se puede crear de nuevo.
y termina.
- Si no existe: lo crea con:
useradd -m -G "$GRUPO" "$USUARIO"
y asigna la contraseña con:
echo "$USUARIO:$CONTRASENA" | chpasswd

### 6) Mensajes finales
Si todo sale bien, muestra:
Usuario $USUARIO creado con éxito.
Grupo principal: $USUARIO
Grupo secundario: $GRUPO

Nota: el grupo principal que imprime depende de la configuración/creación del usuario en tu sistema. El grupo secundario sí se asigna explícitamente con -G "$GRUPO".

## Archivo de configuración: config.env
`config.env` debe contener estas variables:


```bashUSUARIO=juanCONTRASENA=SuperPassword123GRUPO=developers


Recomendaciones:
- Evita espacios alrededor del =.
- Usa una contraseña válida para el sistema.

## Ejemplo de uso

### 1) Estructura de archivos (ejemplo)
tu-carpeta/
- crear_usuario.sh
- config.env

### 2) Dar permisos de ejecución al script
chmod +x crear_usuario.sh

### 3) Ejecutar con sudo
sudo ./crear_usuario.sh

## Ejemplos de salida

### Caso A: grupo no existe y usuario no existe
El grupo secundario developers ha sido creado.
Usuario juan creado con éxito.
Grupo principal: juan
Grupo secundario: developers

### Caso B: el usuario ya existe
El usuario juan ya existe. No se puede crear de nuevo.

## Comportamientos clave
- Si el usuario ya existe: el script termina y no crea nada nuevo.
- Si el grupo secundario no existe: lo crea.
- Si falta config.env o faltan variables requeridas: el script se detiene antes de crear recursos.

