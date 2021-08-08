#!/bin/bash
fun_error_trunks(){
	echo "Error! not found - trunks"
}
fun_error_status(){
	echo "Error! not found - status"
}
fun_error_ipaddr(){
	echo "Error! not found - ipaddr"
}

if [ $# -ne 0 ]
then
	case $1 in
		trunks)
			/usr/bin/sudo asterisk -rx "pjsip show endpoints" | grep Contact | grep -v Aor | grep -v NonQual | cut -d':' -f2 | cut -d'/' -f1 | awk -v ORS="" 'BEGIN { print "{\"data\":["} { print "{\"{#TRUNKNAME}\":\""$1"\"}," } END { print "]}" }' | sed 's/,]}$/]}\n/' ;;
			status)
			if [ $# -eq 2 ]
			then
				STATUS=$(/usr/bin/sudo asterisk -rx "pjsip show aor ${2}" | grep "Contact:  ${2}" | awk '{print$4}')
			if [[ $STATUS = "Avail" ]]
		        then echo 1
		        else
 		           echo 0
                        fi
			else
				fun_error_status
			fi ;;
		ipaddr)
			if [ $# -eq 2 ]
			then
				/usr/bin/sudo asterisk -rx "pjsip show aor ${2}" | grep "Contact:  ${2}" | awk '{print$2}' | cut -d':' -f2
			else
				fun_error_status
			fi ;;
		*)
			fun_error_ipaddr ;;
	esac
else
	fun_error_trunks
fi
