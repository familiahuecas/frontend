#!/bin/sh

# Directorio raíz donde se encuentran los archivos servidos por NGINX
ROOT_DIR=/usr/share/nginx/html

# Imprimir los valores de las variables por consola
echo "Valor de BASE_HREF: $BASE_HREF"
echo "Valor de API_URL: $API_URL"

# Reemplazar las variables de entorno en los archivos servidos por NGINX
for file in $ROOT_DIR/*;
do
  echo "Procesando archivo: $file"
  sed -i 's|BASE_HREF_PLACE_HOLDER|'$BASE_HREF'|g' $file
  sed -i 's|API_URL_PLACE_HOLDER|'$API_URL'|g' $file
done

# Iniciar NGINX
nginx -g 'daemon off;'
