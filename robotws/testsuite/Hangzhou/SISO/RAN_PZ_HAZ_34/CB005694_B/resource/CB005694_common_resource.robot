*** Settings ***
Resource  testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005958_D/resources/comm_5958D.robot

*** Keywords ***
Check New Counter Period
    [Arguments]    ${counter_id}
    Log To Console    Wait Until New Counter Period
    sleep    15min
    ${counter_list}    Get GNSS PM Counter    counter_id=${counter_id}
    [Return]    ${counter_list}

#Get GNSS PM Counter
#    [Arguments]    ${counter_id}    ${alias}=default
#    Log To Console    Get GNSS PM Counter
#    comm_5958D.Rest Login DU
#    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
#    ${path_par}    get dictionary values    ${result['BTS']['BTS']['MRBTS-${MRBTS_ID}']}
#    ${path_par_key}    get dictionary keys    ${path_par}
#    ${par_key}    Set Variable    ${path_par_key}[0]
#    ${status}    run keyword and return status    Should be equal as strings    ${par_key}    MNL-1
#    Run keyword if    ${status}    Counter_list_MNL   counter_id=${counter_id}    result=${result}
#    ...    Counter_list_CLOCK    counter_id=${counter_id}    result=${result}
#    [Return]    ${counter_list}
#    [Teardown]    comm_5958D.Rest Logout DU

Get GNSS PM Counter
    [Arguments]    ${counter_id}    ${alias}=default
    Log To Console    Get GNSS PM Counter
    comm_5958D.Rest Login DU
    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
    ${path_par}    get dictionary values    ${result['BTS']['BTS']['MRBTS-${MRBTS_ID}']}
    ${path_par_key_list_1}    get dictionary keys    ${path_par}
    ${path_par_key_1}    Set Variable    ${path_par_key_list_1}[0]
    ${path_par_value_list}    get dictionary values    ${path_par}
    ${path_par_value}    Set Variable    ${path_par_value_list}[0]
    ${path_par_key_list_2}    get dictionary keys    ${path_par_value}
    ${path_par_key_2}    Set Variable    ${path_par_key_list_2}[0]
    ${counter_list}    get dictionary values
    ...    ${result['BTS']['BTS']['MRBTS-${MRBTS_ID}'][${path_par_key_1}][${path_par_key_2}]['NGNS']['${counter_id}']}
    Set Suite Variable    ${counter_list}
    [Return]    ${counter_list}
    [Teardown]    comm_5958D.Rest Logout DU

#Counter_list_MNL
#    [Arguments]    ${counter_id}    ${result}
#    ${counter_list}    get dictionary values
#    ...    ${result['BTS']['BTS']['MRBTS-${MRBTS_ID}']['MNL-1']['MNLENT-1']['NGNS']['${counter_id}']}
#    Set Suite Variable    ${counter_list}
#    [Return]    ${counter_list}
#
#Counter_list_CLOCK
#    [Arguments]    ${counter_id}    ${result}
#    ${counter_list}    get dictionary values
#    ...    ${result['BTS']['BTS']['MRBTS-${MRBTS_ID}']['CLOCK-1']['GNSSE-1']['NGNS']['${counter_id}']}
#    Set Suite Variable    ${counter_list}
#    [Return]    ${counter_list}
    
Change gnssControlMode
    [Arguments]    ${Galileo_valueL}    ${GPS_valueL}     ${QZSS_valueL}
    ...    ${Galileo_state}     ${GPS_state}      ${QZSS_state}
    comm_5958D.Rest Login DU
    ${fault_name_list}     ${faultlist1}     Get Alarm Info     timeout=1
    sort list    ${faultlist1}
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Galileo_only}     value=${Galileo_valueL}
    ...    operation=update
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GPS_only}     value=${GPS_valueL}
    ...    operation=update
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${QZSS_only}     value=${QZSS_valueL}
    ...    operation=update
    comm_5958D.Rest Logout DU
    getPara and check    GNSSE_actual=${Galileo_only}    GNSSvalue=${Galileo_valueL}
    getPara and check    GNSSE_actual=${GPS_only}    GNSSvalue=${GPS_valueL}
    getPara and check    GNSSE_actual=${QZSS_only}    GNSSvalue=${QZSS_valueL}
    Sleep    5min
    comm_5958D.Rest Login DU
    ${fault_name_list}     ${faultlist2}     Get Alarm Info     timeout=1
    sort list    ${faultlist2}
    ${status}=    run keyword and return status    lists should be equal    ${faultlist1}    ${faultlist2}
    Run Keyword If    ${status}!=${True}    Collect snapshot coam
    should be equal   ${status}    ${True}
    [Teardown]     comm_5958D.Rest Logout DU

Change gnssControlMode1
    [Arguments]   ${Galileo_valueL}    ${GPS_valueL}     ${Beidou_valueL}   ${Glonass_valueL}    ${Qzss_valueL}
    ...    ${Galileo_state}     ${GPS_state}     ${Glonass_state}   ${Beidou_state}   ${Qzss_state}
    comm_5958D.Rest Login DU
    ${fault_name_list}     ${faultlist1}     Get Alarm Info     timeout=1
    sort list    ${faultlist1}
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Galileo_only}     value=${Galileo_valueL}
    ...    operation=update
     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Glonass_only}    value=${Glonass_valueL}
    ...    operation=update
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GPS_only}     value=${GPS_valueL}
    ...    operation=update
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Beidou_only}     value=${Beidou_valueL}
    ...    operation=update
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Qzss_only}     value=${Qzss_valueL}
    ...    operation=update
    run keyword and ignore error    comm_5958D.Rest Logout DU
    getPara and check    GNSSE_actual=${Galileo_name}    GNSSvalue=${Galileo_state}
    getPara and check    GNSSE_actual=${Glonass_name}    GNSSvalue=${Glonass_state}
    getPara and check    GNSSE_actual=${GPS_name}    GNSSvalue=${GPS_state}
    getPara and check    GNSSE_actual=${Beidou_name}    GNSSvalue=${Beidou_state}
    getPara and check    GNSSE_actual=${Qzss_name}    GNSSvalue=${Qzss_state}
    Sleep    5min
    comm_5958D.Rest Login DU
    ${fault_name_list}     ${faultlist2}     Get Alarm Info     timeout=1
    sort list    ${faultlist2}
    ${status}=    run keyword and return status    lists should be equal    ${faultlist1}    ${faultlist2}
    Run Keyword If    ${status}!=${True}    Collect snapshot coam
    should be equal   ${status}    ${True}
    [Teardown]    comm_5958D.Rest Logout DU

Change parameter
    [Arguments]      ${Galileo_valueL}         ${Galileo_state}
    comm_5958D.Rest Login DU
    perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Galileo_only}     value=${Galileo_valueL}
    ...    operation=update
    run keyword and ignore error    comm_5958D.Rest Logout DU
    getPara and check    GNSSE_actual=${Galileo_name}    GNSSvalue=${Galileo_state}

Case Teardown
    CI_interface.Common Case Teardown

Get length and Check sum counter value
    [Arguments]     ${list_input}
    ${length}      Get Length       ${list_input}
    ${counter_value_sum}       Set Variable          0
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
    END
    Should be true     ${counter_value_sum}>${0}
    [Return]   ${counter_value_sum}
