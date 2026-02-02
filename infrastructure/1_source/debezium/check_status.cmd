:<<"::CMDLITERAL"
@ECHO OFF
GOTO :WINDOWS
::CMDLITERAL

# ==============================
# LINUX / MAC (BASH)
# ==============================
HOST=${1:-localhost}
CONNECTOR_NAME=${2:-hospital-connector}
URL="http://$HOST:8083/connectors/$CONNECTOR_NAME/status"

echo "Checking status for '$CONNECTOR_NAME' at $URL..."
curl -s "$URL"
echo ""
exit $?

:WINDOWS
REM ==============================
REM WINDOWS (CMD/BATCH)
REM ==============================
SET HOST=%1
IF "%HOST%"=="" SET HOST=localhost

SET CONNECTOR_NAME=%2
IF "%CONNECTOR_NAME%"=="" SET CONNECTOR_NAME=hospital-connector

SET URL=http://%HOST%:8083/connectors/%CONNECTOR_NAME%/status

ECHO Checking status for '%CONNECTOR_NAME%' at %URL%...
curl -s "%URL%"
ECHO.
EXIT /B 0