*** Settings ***
#Resource     ../../../robot/common_resource.robot
#Library   ta_a2a
Library    Collections
Library     ${CURDIR}/../../tak_files/

*** Test Cases ***
tset record
    filter_qcat_record    ${CURDIR}${/}log/12-09.14-17-22-551-ca-disable.txt     PDSCH Status Info     ${CURDIR}${/}log/record.csv

test report
    filter_qcat_report    ${CURDIR}${/}log/12-09.14-17-22-551-ca-disable.txt      CRI:RI:PMI:CQI:LI    ${CURDIR}${/}log/report.csv
	#check_log_with_au2anlysis    ${CURDIR}${/}qcat.ini    i    save_log_directory=${CURDIR}/log
    
test msg	
	filter_qcat_message    ${CURDIR}${/}log/12-09.14-17-22-551-ca-disable.txt      ::=    ${CURDIR}${/}log/msg.txt
    #check_log_with_au2anlysis    ${CURDIR}${/}qcat.ini    p    save_log_directory=${CURDIR}/log