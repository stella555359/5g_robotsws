*** Settings ***
Resource     ../../../robot/common_resource.robot


*** Test Cases ***
Counter Value
    get_counter_value_from_counter_file    ${CURDIR}${/}pm.xml    M8020C9
    get_counter_value_from_counter_file    ${CURDIR}${/}pm.xml    M8020C9    1

Get Remian Time
    ${remian_time}=     get_counter_file_remaining_time   
	Sleep    ${remian_time}

Download Latest PM Counter File Example
     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${CURDIR}${/}
     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${CURDIR}${/}    source_path=/tmp/    suffix=xz
