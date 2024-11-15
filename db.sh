#!/bin/bash

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
#flutter build web --dart-define=API_URL=${API_URL}

flutter build web --dart-define=FLEX_SCHEME=mango --dart-define=API_URL=API_URL_PLACE_HOLDER
docker build . --tag backoffice-familiahuecas
