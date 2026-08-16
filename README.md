## Flujo de trabajo del proyecto

### 1) Generas una clave segura con el script crear_clave_copada.sh
### 2) Generas el usuario(en config.env) con el script crear_usuario.sh

# Documentación del script de generación y actualización de clave (Bash)

## Propósito
Este script genera una clave aleatoria y luego actualiza el campo `CONTRASENA` dentro del archivo `config.env`.

## Qué hace
1. Obtiene una longitud aleatoria para la clave.
2. Genera una clave usando caracteres permitidos.
3. Verifica que exista el archivo `config.env`.
4. Modifica `config.env` reemplazando la línea que empieza con `CONTRASENA=` por el nuevo valor.

## Flujo del Script

### 1) Obtención de la longitud
El script calcula `LONGITUD` usando un byte aleatorio del sistema:

- Lee 1 byte desde `/dev/urandom`
- Interpreta el byte como entero sin signo (`-tu1`)
- Luego usa `awk` para calcular una longitud con esta lógica:
  - `25 + ($1 % 28)`

Esto produce valores entre 25 y 52 (inclusive).

### 2) Generación de la clave
Con la longitud calculada (`LONGITUD`), genera `CLAVE` filtrando caracteres desde `/dev/urandom`.

- `tr -dc 'A-Za-z0-9_!@#$%^&*'`  
  Deja únicamente caracteres permitidos:
  - Letras mayúsculas y minúsculas
  - Dígitos 0-9
  - `_`
  - `! @ # $ % ^ & *`

- `head -c "$LONGITUD"`  
  Toma exactamente `LONGITUD` caracteres.

Luego asigna:
- `NUEVA_CONTRA=$CLAVE`

### 3) Verificación de `config.env`
Antes de modificar nada, valida que exista el archivo:

- Si `config.env` no existe:
  - imprime `El archivo config.env no existe.`
  - termina con `exit 1`

### 4) Actualización del campo CONSTRASENA en config.env
Usa `sed -i` para reemplazar la línea:

- Busca la línea que coincide con:
  - `^CONTRASENA=.*`
- La reemplaza por:
  - `CONTRASENA="NUEVA_CONTRA"`

Comando utilizado:
- `sed -i 's/^CONTRASENA=.*/CONTRASENA="'"$NUEVA_CONTRA"'"/' config.env

## Archivo esperado: config.env
El archivo debe existir en el mismo directorio donde se ejecuta el script, y debe contener una línea con formato similar a:

CONTRASENA=alguna_clave_anterior

La expresión reemplaza toda la línea que empiece con `CONTRASENA=`.

## Ejemplo de uso

### 1) Dar permisos de ejecución
```bash
chmod +x generar\_clave.sh

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

```bash
USUARIO=juan
CONTRASENA=SuperPassword123
GRUPO=developers
```

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

