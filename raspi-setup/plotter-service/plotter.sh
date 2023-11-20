#!/bin/bash

rm -f ./index.html
cp ./template.html ./index.html
rm -f ./copy.html
cp ./telemetry.sqlite ./copy.sqlite


CURTIME=$(date +"%T")
sed -i "s@_CURTIME_@$CURTIME@g" ./index.html

LAST_5_MIN_AVG=$(sqlite3 ./copy.sqlite "select avgpower from (select datetime((strftime('%s', timestamp) / 300) * 300, 'unixepoch') intervals, ROUND(AVG(value), 1) avgpower from telemetry where date(timestamp) = date('now') group by intervals order by intervals DESC LIMIT 1);" | tr -d '\n')
sed -i "s@_LAST_5_MIN_AVG_@$LAST_5_MIN_AVG@g" ./index.html

LAST_15_MIN_AVG=$(sqlite3 ./copy.sqlite "select avgpower from (select datetime((strftime('%s', timestamp) / 900) * 900, 'unixepoch') intervals, ROUND(AVG(value), 1) avgpower from telemetry where date(timestamp) = date('now') group by intervals order by intervals DESC LIMIT 1);" | tr -d '\n')
sed -i "s@_LAST_15_MIN_AVG_@$LAST_15_MIN_AVG@g" ./index.html

LAST_30_MIN_AVG=$(sqlite3 ./copy.sqlite "select avgpower from (select datetime((strftime('%s', timestamp) / 1800) * 1800, 'unixepoch') intervals, ROUND(AVG(value), 1) avgpower from telemetry where date(timestamp) = date('now') group by intervals order by intervals DESC LIMIT 1);" | tr -d '\n')
sed -i "s@_LAST_30_MIN_AVG_@$LAST_30_MIN_AVG@g" ./index.html




DAY_BY_HOUR=$(sqlite3 ./copy.sqlite "select strftime('%H', datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch')) intervals, ROUND(AVG(value), 1) avgpower from telemetry where date(timestamp) = date('now') group by intervals order by intervals ASC LIMIT 24;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_DAY_BY_HOUR_@$DAY_BY_HOUR@g" ./index.html

LAST_7_DAYS_BY_DAY=$(sqlite3 ./copy.sqlite "select date(timestamp) day, SUM(kWhPower) from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, ROUND(AVG(value), 1) kWhPower from telemetry where date(timestamp) > date('now', '-7 day') group by intervals order by intervals DESC LIMIT 168) group by day;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_LAST_7_DAYS_BY_DAY_@$LAST_7_DAYS_BY_DAY@g" ./index.html

LAST_FULL_WEEKDAYS=$(sqlite3 ./copy.sqlite "select strftime('%w', timestamp) AS dayofweek, SUM(kWhPower) from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, ROUND(AVG(value), 1) kWhPower from telemetry where date(timestamp) >=  date('now', 'weekday 0', '-7 days') group by intervals order by intervals DESC LIMIT 168) group by dayofweek;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_LAST_FULL_WEEKDAYS_@$LAST_FULL_WEEKDAYS@g" ./index.html

LAST_31_DAYS=$(sqlite3 ./copy.sqlite "select date(timestamp) day, SUM(kWhPower) from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, ROUND(AVG(value), 1) kWhPower from telemetry where date(timestamp) > date('now', '-31 day') group by intervals order by intervals DESC LIMIT 768) group by day;" | tr '\n' ';')
sed -i "s@_GRAPH_OF_LAST_31_DAYS_@$LAST_31_DAYS@g" ./index.html

CURRENT_MONTH_BY_WEEK=$(sqlite3 ./copy.sqlite "select strftime('%W', timestamp) AS calweek, SUM(kWhPower), date(timestamp) day from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, ROUND(AVG(value), 1) kWhPower from telemetry where date(timestamp) >= date('now', 'start of month') group by intervals order by intervals DESC LIMIT 768) group by calweek;" | tr '\n' ';')
sed -i "s@_CURRENT_MONTH_BY_WEEK_@$CURRENT_MONTH_BY_WEEK@g" ./index.html

CURRENT_YEAR_BY_MONTH=$(sqlite3 ./copy.sqlite "select strftime('%m', timestamp) AS month, SUM(kWhPower) from (select timestamp, datetime((strftime('%s', timestamp) / 3600) * 3600, 'unixepoch') intervals, ROUND(AVG(value), 1) kWhPower from telemetry where date(timestamp) >= date('now', 'start of year') group by intervals order by intervals DESC LIMIT 8784) group by month;" | tr '\n' ';')
sed -i "s@_CURRENT_YEAR_BY_MONTH_@$CURRENT_YEAR_BY_MONTH@g" ./index.html