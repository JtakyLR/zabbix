#!/bin/bash
fun_error_reg_domains(){
	echo "Error! not found - reg_domains"
}
fun_error_reg_datepaid(){
	echo "Error! not found - reg_datepaid"
}
fun_error_reg_daysleft(){
	echo "Error! not found - reg_daysleft"
}
REG_DOMAINS=(/usr/lib/zabbix/externalscripts/check_domains/reg/reg_domains)
REG_CHECK=(/usr/lib/zabbix/externalscripts/check_domains/reg/reg_datepaid)

if [ $# -ne 0 ]
then
	case $1 in
		reg_domains)
			cat ${REG_DOMAINS} | awk -v ORS="" 'BEGIN { print "{\"data\":["} { print "{\"{#REG_DOMAINS}\":\""$1"\"}," } END { print "]}" }' | sed 's/,]}$/]}\n/' ;;
		reg_datepaid)
			if [ $# -eq 2 ]
			then
				DATEPAID=$(whois -I ${2} | grep -e "Registry Expiry Date" -e "paid-till" -e "expires" | cut -d ":" -f 2 | sed 's/^ *//' | cut -d " " -f 1 |sed -r 's/T.+//')
#				DATEPAID=$()
				if [ -z ${DATEPAID} ]; then
					DATEPAID=$(cat ${REG_CHECK}| grep ${2} | cut -d ":" -f 2)
					echo ${DATEPAID}
				else
					if grep -q ${2} "$REG_CHECK"; then
						OLD_DELETE=$(sed -i '/'${2}'/d' ${REG_CHECK})
						echo ${DATEPAID}
						echo ${2}:${DATEPAID} >> ${REG_CHECK}
					else
						echo ${DATEPAID}
                                                echo ${2}:${DATEPAID} >> ${REG_CHECK}
					fi
				fi
			else
				fun_error_reg_datepaid
			fi ;;
		reg_daysleft)
			if [ $# -eq 2 ]
			then
				DAYSLEFT=$(sort ${REG_CHECK} | uniq | grep ${2} | cut -d ":" -f 2)
				echo $((($(date --date="${DAYSLEFT}" +%s)-$(date --date="now" +%s))/(60*60*24)))
			else
				fun_error_reg_daysleft
			fi ;;
		*)
			fun_error_reg_daysleft ;;
	esac
else
	fun_error_reg_domains
fi
