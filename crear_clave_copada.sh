#!/bin/bash
#	Obtengo la longitud
LONGITUD=$(od -An -N1 -tu1 /dev/urandom | awk '{print 25 + ($1 % 28)}')

#	Obtengo la clave en base a la longitud
CLAVE=$(tr -dc 'A-Za-z0-9_!@#$%^&*' < /dev/urandom | head -c "$LONGITUD"; echo)

# Definimos el nuevo valor
NUEVA_CONTRA=$CLAVE

#	Verifica si el archivo de configuración existe
if [ ! -f "config.env" ]; then
    echo "El archivo config.env no existe."
    exit 1
fi

# 	Usamos sed -i para modificar el archivo directamente
sed -i 's/^CONTRASENA=.*/CONTRASENA="'"$NUEVA_CONTRA"'"/' config.env
