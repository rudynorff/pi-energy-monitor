# mqtt-exporter

mqtt-exporter was built to run on a Raspberry Pi. It connects to an MQTT broker (tested with mosquitto) and subscribes to the topics "solar" and "grid". It then takes these values, stores them in a SQLite database on the Pi.

Every 5 minutes it takes the last 5 minutes worth of data from the SQLite database, puts them in a JSON and sends them off to a web service for further processing.

This is a JSON example:

```
    {
        "items": [
            {
                "id": "solar",
                "previous5MinutesWh": 55.2,
                "currentDayHoursWh": [0, 0, 0, 0, 0, 0, 0, 4.4, 22, 89.2, 212.2, 322, 350, 399, 455, 422, 378, 312, 222, 120, 23, 3, 0, 0, 0],
                "currentYearKWh": [8, 14, 19, 45, 60, 73, 70, 61, 52, 33, 19, 7],
            },
            {
                "id": "grid",
                "previous5Minutes": 123.2,
                "currentDayHours": [0, 0, 0, 0, 0, 0, 0, 990.4, 720, 89.2, 78.2, 77.2, 89.3, 88, 81, 422, 78, 88.3, 332, 800, 312, 333, 278, 0, 0, 0],
                "currentYearKWh": [411, 399, 340, 322, 278, 266, 269, 289, 311, 333, 378, 401],
            }
        ]
    }
```