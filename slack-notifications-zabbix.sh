#!/bin/bash

# Slack Notifications for Zabbix

# Vladimir Mikhalev
# callvaldemar@gmail.com
# www.heyvaldemar.com

# Put the script in the folder /usr/lib/zabbix/alertscripts/ on your Zabbix server

# Zabbix URL (replace with yours)
zabbix_baseurl="https://zabbix.heyvaldemar.net"
channel="$1"
title="$2"
params="$3"
pretext="$4"

host="`echo \"${params}\" | grep 'HOST: ' | awk -F'HOST: ' '{print $2}' | tr -d '\r\n\'`"
trigger_status="`echo \"${params}\" | grep 'TRIGGER_STATUS: ' | awk -F'TRIGGER_STATUS: ' '{print $2}' | tr -d '\r\n\'`"
severity="`echo \"${params}\" | grep 'TRIGGER_SEVERITY: ' | awk -F'TRIGGER_SEVERITY: ' '{print $2}' | tr -d '\r\n\'`"
item_value="`echo \"${params}\" | grep 'ITEM_VALUE: ' | awk -F'ITEM_VALUE: ' '{print $2}' | tr -d '\r\n\'`"

item_value='`'$item_value'`'
problem_view="${zabbix_baseurl}/zabbix.php?action=problem.view"

if [[ "$severity" == 'Information' ]]; then
		color='#7499FF'
elif [ "$severity" == 'Warning' ]; then
		color='#FFC859'
elif [ "$severity" == 'Average' ]; then
		color='#FFA059'
elif [ "$severity" == 'High' ]; then
		color='#E97659'
elif [ "$severity" == 'Disaster' ]; then
		color='#E45959'
else
		color='#97AAB3'
fi

if [[ "$trigger_status" == 'OK' ]]; then
		color='good'
fi

ts=$(date +%s)

# Zabbix URL (replace with yours)
request_body=$(< <(cat <<EOF
{
	"channel": "#$channel",
	"mrkdwn": true,
	"attachments": [
		{
			"fallback": "$title",
			"color": "$color",
			"pretext": "$pretext",
			"author_name": "$host",
			"author_link": "$problem_view",
			"title": "$title",
			"fields": [
				{
					"title": "Severity",
					"value": "$severity",
					"short": true
				},
				{
					"title": "Value",
					"value": "$item_value",
					"short": true
				}
			],
			"footer": "https://zabbix.heyvaldemar.net",
			"ts": "$ts",
			"mrkdwn_in": [
				"pretext",
				"fields"
			]
		}
	]
}
EOF
))

# Webhook URL for Slack application (replace with yours)
curl -X POST \
-H 'Content-type: application/json' \
--data "$request_body"  \
https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX
