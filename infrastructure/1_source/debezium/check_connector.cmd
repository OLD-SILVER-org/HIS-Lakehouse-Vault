:<<"::CMDLITERAL"
@ECHO OFF
GOTO :WINDOWS
::CMDLITERAL

# ==============================
# LINUX / MAC (BASH)
# ==============================
HOST=${1:-localhost}
URL="http://$HOST:8083/connectors/hospital-connector/status"

echo "Checking status for hospital-connector at $URL..."
curl -s "$URL"
echo ""
exit $?

:WINDOWS
REM ==============================
REM WINDOWS (CMD/BATCH)
REM ==============================
SET HOST=%1
IF "%HOST%"=="" SET HOST=localhost
SET URL=http://%HOST%:8083/connectors/hospital-connector/status

ECHO Checking status for hospital-connector at %URL%...
curl -s "%URL%"
ECHO.
EXIT /B 0