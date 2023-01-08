#!/bin/bash
fun_error_ssl_domains(){
	echo "Error! not found - ssl_domains"
}
fun_error_ssl_daysleft(){
	echo "Error! not found - ssl_daysleft"
}
DATE=$(date +"%Y%m%d")
SSL_DOMAINS=(/usr/lib/zabbix/externalscripts/check_domains/ssl/ssl_domains)
SSL_CHECK=(/usr/lib/zabbix/externalscripts/check_domains/ssl/ssl_daysleft)

if [ $# -ne 0 ]
then
	case $1 in
		ssl_domains)
			cat ${SSL_DOMAINS} | awk -v ORS="" 'BEGIN { print "{\"data\":["} { print "{\"{#SSL_DOMAINS}\":\""$1"\"}," } END { print "]}" }' | sed 's/,]}$/]}\n/' ;;
		ssl_daysleft)
			if [ $# -eq 2 ]
			then
				DATEPAID=$(echo $((($(date +%s --date "$(echo | openssl s_client -connect ${2}:443 2>/dev/null | openssl x509 -noout -dates | tail -n 1 | cut -d '=' -f 2)") - $(date +%s)) / (3600 * 24))))
				echo ${DATEPAID}
					if grep -q ${2} "$SSL_CHECK"; then
					OLD_DELERE=$(sed -i '/'${2}'/d' ${SSL_CHECK})
					echo ${2}:${DATEPAID} >> ${SSL_CHECK}
					else
					echo ${2}:${DATEPAID} >> ${SSL_CHECK}
				fi
			else
				fun_error_ssl_daysleft
			fi ;;
		*)
			fun_error_ssl_daysleft ;;
	esac
else
	fun_error_ssl_domains
fi
