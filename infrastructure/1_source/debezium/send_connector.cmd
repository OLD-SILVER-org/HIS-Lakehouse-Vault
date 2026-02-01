:<<"::CMDLITERAL"
@ECHO OFF
GOTO :WINDOWS
::CMDLITERAL

# ==============================
# LINUX / MAC (BASH)
# ==============================
HOST=${1:-localhost}
HOST=$(echo "$HOST" | tr -d '\r')

SCRIPT_DIR=$(dirname "$0")
JSON_FILE="$SCRIPT_DIR/hospital_connector.json"
URL="http://$HOST:8083/connectors"

echo "Linux/Bash detected."
echo "Sending $JSON_FILE to $URL..."

if [ ! -f "$JSON_FILE" ]; then
  echo "Error: File $JSON_FILE not found."
  exit 1
fi

curl -i -X POST -H "Content-Type: application/json" -d @"$JSON_FILE" "$URL"
exit $?

:WINDOWS
REM ==============================
REM WINDOWS (CMD/BATCH)
REM ==============================
SET HOST=%1
IF "%HOST%"=="" SET HOST=localhost
SET SCRIPT_DIR=%~dp0
SET JSON_FILE=%SCRIPT_DIR%hospital_connector.json
SET URL=http://%HOST%:8083/connectors

ECHO Windows CMD detected.
ECHO Sending %JSON_FILE% to %URL%...

IF NOT EXIST "%JSON_FILE%" (
    ECHO Error: File %JSON_FILE% not found.
    EXIT /B 1
)

curl -i -X POST -H "Content-Type: application/json" -d "@%JSON_FILE%" "%URL%"
EXIT /B %ERRORLEVEL%