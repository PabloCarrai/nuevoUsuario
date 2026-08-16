#!/bin/bash

# 1)	Verifico que tengan permisos de sudo
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script usando sudo."
  exit 1
fi

# 2)	Verifica si el archivo de configuración existe
if [ ! -f "config.env" ]; then
    echo "El archivo config.env no existe."
    exit 1
else
    # 3) Carga las variables del archivo externo
    source config.env
fi

# 4)	Valida que las variables principales no estén vacías
if [ -z "$USUARIO" ] || [ -z "$CONTRASENA" ] || [ -z "$GRUPO" ]; then
    echo "Faltan datos en el archivo de configuración."
    exit 1
fi

#  5)	Chequea si el grupo secundario existe o lo crea si no está
if getent group "$GRUPO" &>/dev/null; then
    echo "El grupo secundario $GRUPO ya existe."
else
    #	Creo el grupo secundario
    groupadd "$GRUPO"
    echo "El grupo secundario $GRUPO ha sido creado."
fi

#  6)	Chequea si el usuario ya existe
if id "$USUARIO" &>/dev/null; then
    echo "El usuario $USUARIO ya existe. No se puede crear de nuevo."
    exit 1
else
	# 7)	Creo el usuario 
    useradd -m -s /bin/bash  -G "$GRUPO" "$USUARIO"
    echo "$USUARIO:$CONTRASENA" | chpasswd
fi

echo "Usuario $USUARIO creado con éxito."
echo "Grupo principal: $USUARIO"
echo "Grupo secundario: $GRUPO"
