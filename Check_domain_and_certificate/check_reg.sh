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

fun_extract_date() {
  local line="$1"
  local date=""

  #YYYY-MM-DD
   if [[ "$line" =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
    date="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"

  #DD-MM-YYYY
  elif [[ "$line" =~ ([0-9]{2})-([0-9]{2})-([0-9]{4}) ]]; then
    date="${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
  fi

  echo "$date"
}
fun_expiry_line() {
  local domain="$1"

  whois -H "$domain" | grep -Ei \
    "Expiry|Registry Expiry Date|paid-till|expires|Expiry Date|Record expires|Expiration Time|Registry Expiry Date"
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
				GETDATE=$(fun_expiry_line "$2")
				CORDATE=$(fun_extract_date "${GETDATE}")

				if [ -z ${CORDATE} ]; then
					CORDATE=$(cat ${REG_CHECK}| grep ${2} | cut -d ":" -f 2)
					echo ${CORDATE}
				else
					if grep -q ${2} "$REG_CHECK"; then
						OLD_DELETE=$(sed -i '/'${2}'/d' ${REG_CHECK})
						echo ${CORDATE}
						echo ${2}:${CORDATE} >> ${REG_CHECK}
					else
						echo ${CORDATE}
                                                echo ${2}:${CORDATE} >> ${REG_CHECK}
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
