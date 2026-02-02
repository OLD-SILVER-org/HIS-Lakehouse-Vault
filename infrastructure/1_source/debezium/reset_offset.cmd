:<<"::CMDLITERAL"
@ECHO OFF
GOTO :WINDOWS
::CMDLITERAL

# ==============================
# LINUX / MAC (BASH)
# ==============================
echo "1. Deleting Connector..."
./delete_connector.cmd

echo "2. Deleting Offset Topic in Kafka..."
docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic hospital_connect_offsets

echo "3. Waiting for cleanup (5s)..."
sleep 5

echo "4. Registering Connector again..."
./register_connector.cmd

echo "Done! Debezium should perform a fresh snapshot now."
exit 0

:WINDOWS
REM ==============================
REM WINDOWS (CMD/BATCH)
REM ==============================
ECHO 1. Deleting Connector...
CALL .\infrastructure\1_source\debezium\delete_connector.cmd

ECHO 2. Deleting Offset Topic in Kafka...
docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic hospital_connect_offsets

ECHO 3. Waiting for cleanup (5s)...
TIMEOUT /T 5

ECHO 4. Registering Connector again...
CALL .\infrastructure\1_source\debezium\register_connector.cmd

ECHO Done! Debezium should perform a fresh snapshot now.
EXIT /B 0