# mqtt-exporter

mqtt-exporter was built to run on a Raspberry Pi. It connects to an MQTT broker (tested with mosquitto) and subscribes to the topics "solar" and "grid". It then takes these values, stores them in a SQLite database on the Pi.
