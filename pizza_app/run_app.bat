@echo off
echo Ejecutando la aplicación Pizza App...
echo.
echo Primero, necesitas habilitar el Modo Desarrollador en Windows:
echo 1. Presiona Win+I para abrir Configuración
echo 2. Ve a "Privacidad y seguridad" > "Para desarrolladores"
echo 3. Activa "Modo desarrollador"
echo.
echo Después de habilitar el Modo Desarrollador, presiona cualquier tecla para continuar...
pause > nul

echo.
echo Ejecutando Flutter...
flutter run -d windows
pause