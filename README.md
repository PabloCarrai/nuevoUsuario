# nuevoUsuario
Script para crear usuario de manera desatendida uniendolo a un grupo en particular


# Documentación del script Bash (creación de usuario y grupo)
Este script automatiza la administración de cuentas en un sistema Linux: crea un **grupo secundario** (si no existe) y crea un **usuario** (si no existe), asignándole el **grupo secundario** y configurándole una **contraseña** a partir de un archivo de configuración externo.
---
## Estructura general
El script sigue este flujo:
1. Verifica que se ejecute como `root` (permisos de sudo).2. Verifica la existencia del archivo `config.env`.3. Carga variables desde `config.env`.4. Valida que las variables principales no estén vacías.5. Crea el grupo secundario si no existe.6. Verifica si el usuario ya existe; si existe, termina.7. Crea el usuario con home y asigna el grupo secundario, y establece la contraseña.
---
## Requisitos
- Ejecutar el script con privilegios de administrador (por ejemplo, usando `sudo`).- Tener un archivo `config.env` en el mismo directorio donde se ejecuta el script.- `config.env` debe definir las siguientes variables:  - `USUARIO`: nombre del usuario a crear.  - `CONTRASENA`: contraseña del usuario a crear.  - `GRUPO`: nombre del grupo secundario a usar/crear.
---
## Funcionamiento detallado
### 1) Verificación de permisos (sudo / root)El script comprueba si el proceso corre con privilegios de superusuario:
- Si `EUID` no es `0`, muestra:  - `Por favor, ejecuta este script usando sudo.`- Luego finaliza con código de error (`exit 1`).
**Motivo:** para poder crear usuarios y grupos, es necesario usar permisos elevados.
---
### 2) Verificación de `config.env`El script busca el archivo `config.env`:
- Si no existe, muestra:  - `El archivo config.env no existe.`- Luego termina (`exit 1`).
- Si existe, lo carga con `source config.env`.
**Motivo:** centralizar configuración (usuario, contraseña y grupo) en un archivo aparte.
---
### 3) Carga de variables desde `config.env`El script ejecuta:
- `source config.env`
Esto importa las variables definidas en el archivo al entorno del script.
---
### 4) Validación de variables principalesEl script valida que no estén vacías:
- `USUARIO`- `CONTRASENA`- `GRUPO`
Si falta alguna, muestra:
- `Faltan datos en el archivo de configuración.`- y finaliza con `exit 1`.
---
### 5) Grupo secundario: crear si no existeEl script comprueba si el grupo indicado existe:
- Si `getent group "$GRUPO"` encuentra el grupo:  - imprime `El grupo secundario $GRUPO ya existe.`- Si no existe:  - lo crea con `groupadd "$GRUPO"`  - imprime `El grupo secundario $GRUPO ha sido creado.`
---
### 6) Usuario: no permitir duplicadosEl script verifica si el usuario ya existe:
- Si `id "$USUARIO"` indica que ya existe:  - imprime `El usuario $USUARIO ya existe. No se puede crear de nuevo.`  - finaliza con `exit 1`- Si no existe:  - continúa con la creación.
---
### 7) Creación del usuario y asignación de contraseñaSi el usuario no existe, el script lo crea:
- Crea el usuario con home y asigna el grupo secundario:  - `useradd -m -G "$GRUPO" "$USUARIO"`
Luego configura la contraseña usando `chpasswd`:
- `echo "$USUARIO:$CONTRASENA" | chpasswd`
---
## Mensajes finalesSi el script termina correctamente, imprime:
- `Usuario $USUARIO creado con éxito.`- `Grupo principal: $USUARIO`- `Grupo secundario: $GRUPO`
**Nota:** el mensaje “Grupo principal” está impreso como `$USUARIO` (el script imprime ese valor), aunque el grupo principal real depende de la configuración del sistema y cómo se comporte `useradd` en la máquina donde se ejecute.
---
## Ejemplo de `config.env`
```bashUSUARIO=juanCONTRASENA=TuPasswordSeguraGRUPO=soporte
