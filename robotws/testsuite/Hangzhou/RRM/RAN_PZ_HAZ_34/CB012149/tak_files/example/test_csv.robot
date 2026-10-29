*** setting ***
Library     Collections
Library     OperatingSystem
#Resource     ../../../robot/common_resource.robot
Library     ${CURDIR}/../../tak_files/

*** Variables ***
@{a}    1     2
@{b}    3     4
@{source list}    ${a}    ${b}
*** test cases ***
test write csv
    write csv     ${CURDIR}/log/data2.csv      ${source list} 
	
test tbsize
    ${a}   get_ues_tbsize_by_sfn   ${CURDIR}/log/dl.csv   ${CURDIR}/log/new.csv   1   filter=dlFdSchedData.ackNack\=ACK
    @{keys}   Get Dictionary Keys     ${a}
    FOR    ${key}   IN   @{keys}
        should be true      ${a[${key}]}>0
    END