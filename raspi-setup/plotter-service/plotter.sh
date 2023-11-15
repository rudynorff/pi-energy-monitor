#!/bin/bash

rm -f ./index.html
cp ./template.html ./index.html


DAY_BY_HOUR=$(sqlite3 ./telemetry.sqlite "select strftime('%H', datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch')) intervals, ROUND(AVG(power), 1) avgpower from telemetry where date(timestamp) = date('now') group by intervals order by intervals ASC LIMIT 24;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_DAY_BY_HOUR_@$DAY_BY_HOUR@g" ./index.html

LAST_7_DAYS_BY_DAY=$(sqlite3 ./telemetry.sqlite "select date(timestamp) day, SUM(kWhPower) from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, AVG(value) kWhPower from telemetry where date(timestamp) > date('now', '-7 day') group by intervals order by intervals DESC LIMIT 168) group by day;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_LAST_7_DAYS_BY_DAY_@$LAST_7_DAYS_BY_DAY@g" ./index.html

LAST_FULL_WEEKDAYS=$(sqlite3 ./telemetry.sqlite "select strftime('%w', timestamp) AS dayofweek, SUM(kWhPower) from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, AVG(value) kWhPower from telemetry where date(timestamp) >=  date('now', 'weekday 0', '-7 days') group by intervals order by intervals DESC LIMIT 168) group by dayofweek;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_LAST_FULL_WEEKDAYS_@$LAST_FULL_WEEKDAYS@g" ./index.html
