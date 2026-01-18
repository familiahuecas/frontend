#!/bin/bash

# 1. LIMPIEZA PROFUNDA (Esto soluciona el error de share_plus)
echo "--> Limpiando caché y builds antiguos..."
flutter clean

# 2. Descargar dependencias frescas
echo "--> Descargando dependencias..."
flutter pub get

# 3. Generar código (Necesario si usas json_serializable, freezed, etc.)
# Si no usas generación de código, puedes comentar esta línea para ir más rápido.
echo "--> Ejecutando build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Compilar la Web para Producción
# Añado '--web-renderer html' para evitar problemas de iconos/fuentes en algunos servidores,
# pero puedes quitarlo si prefieres CanvasKit (por defecto).
echo "--> Compilando Flutter Web..."
flutter build web --release --web-renderer html --dart-define=FLEX_SCHEME=mango --dart-define=API_URL=API_URL_PLACE_HOLDER

# 5. Construir la imagen Docker
echo "--> Construyendo Imagen Docker..."
docker build . --tag backoffice-familiahuecas

echo "--> Proceso finalizado con éxito."