#!/bin/bash

rm -f ./index.html
cp ./template.html ./index.html


DAY_BY_HOUR=$(sqlite3 ./telemetry.sqlite "select strftime('%H', datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch')) intervals, ROUND(AVG(power), 1) avgpower from telemetry where date(timestamp) = date('now') group by intervals order by intervals ASC LIMIT 24;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_DAY_BY_HOUR_@$DAY_BY_HOUR@g" ./index.html
