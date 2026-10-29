*** Settings ***
Documentation
...   This is for 2376-IA TA common keywords
...   squad group: MMW_SG1

Resource    ./5GC002376-IA_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/bts/robot/common/gnb_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./5GC002376-IA_Variables.robot
Variables   ../TestData/5GC002376_scf_modify.py
Library     OperatingSystem

*** Keywords ***
Update and verify actSecRatRep parameters on ENB
    [Documentation]
    ...      Description: update actSecRatRep parameters  false on ENB.
    [Arguments]    ${update_value}=${False}
    ...    ${parameters_to_update_via_api}=${MODIFY_ENB_ACTSECRATREP_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNBTS_A    connection=enblte
    &{actSecRatRep}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=actSecRatRep
    ...    connection=enblte
    Should be equal as strings    ${actSecRatRep['actSecRatRep']}    ${update_value}
    ...    msg=actSecRatRep is not ${update_value}
    [Teardown]    Enblte close down    connection=enblte

Update and verify actSecRatRepTrue parameters on ENB
    [Documentation]
    ...      Description: update actSecRatRep parameters  true on ENB, and verify the value
    [Arguments]    ${update_value_actSecRatRep_true}=${True}
    ...    ${parameters_to_update_via_api}=${MODIFY_ENB_ACTSECRATREP_TRUE_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNBTS_A    connection=enblte
    &{actSecRatRep}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=actSecRatRep
    ...    connection=enblte
    Should be equal as strings    ${actSecRatRep['actSecRatRep']}    ${update_value_actSecRatRep_true}
    ...    msg=actSecRatRep is not ${update_value_actSecRatRep_true}
    [Teardown]    Enblte close down    connection=enblte


Update and verify actEvtSecRatRep parameters on ENB
    [Documentation]
    ...      Description: update actEvtSecRatRep parameters  true on ENB, and verify the value
    [Arguments]    ${update_value_actEvtSecRatRep}=${False}
    ...    ${parameters_to_update_via_api}=${MODIFY_ENB_ACTEVTSECRATREP_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNBTS_A    connection=enblte
    &{actEvtSecRatRep}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=actEvtSecRatRep
    ...    connection=enblte
    Should be equal as strings    ${actEvtSecRatRep['actEvtSecRatRep']}    ${update_value_actEvtSecRatRep}
    ...    msg=actEvtSecRatRep is not ${update_value_actEvtSecRatRep}
    [Teardown]    Enblte close down    connection=enblte


Update and verify actEvtSecRatRepTrue parameters on ENB
    [Documentation]
    ...      Description: update actEvtSecRatRep parameters  true on ENB, and verify the value
    [Arguments]    ${MODIFY_ENB_ACTEVTSECRATREPTRUE_API}=${True}
    ...    ${parameters_to_update_via_api}=${MODIFY_ENB_ACTEVTSECRATREPTRUE_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNBTS_A    connection=enblte
    &{actEvtSecRatRep}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=actEvtSecRatRep
    ...    connection=enblte
    Should be equal as strings    ${actEvtSecRatRep['actEvtSecRatRep']}    ${MODIFY_ENB_ACTEVTSECRATREPTRUE_API}
    ...    msg=actEvtSecRatRep is not ${MODIFY_ENB_ACTEVTSECRATREPTRUE_API}
    [Teardown]    Enblte close down    connection=enblte


Update and verify tX2SgNBRelData parameters on ENB
    [Documentation]
    ...      Description: update tX2SgNBRelData parameters  true on ENB, and verify the value 16000
    [Arguments]    ${update_value_tX2SgNBRelData_true}=${16000}
    ...    ${parameters_to_update_via_api}=${MODIFY_ENB_ACTSECRATREP_TRUE_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNBTS_A    connection=enblte
    &{tX2SgNBRelData}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=tX2SgNBRelData
    ...    connection=enblte
    Should be equal as strings    ${tX2SgNBRelData['tX2SgNBRelData']}    ${update_value_tX2SgNBRelData_true}
    ...    msg=tX2SgNBRelData is not ${update_value_tX2SgNBRelData_true}
    [Teardown]    Enblte close down    connection=enblte

Check secondaryRATDataUsageReport exist in X2log
    [Documentation]    author: Wang LiYa
    ...      Description: check E1ap and X2ap secondaryRATType
    [Arguments]    ${tcpdump_log}    ${L3call}=${False}
    ##X2log
    ${filtered_packets}    Load pcap with filter    pcap_file=${tcpdump_log}    filter_expression=x2ap
    ...    command_template=${X2AP_COMMAND}
    @{x2_e_RAB}    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${X2_COMMANPATH}/${X2_RAB_ID}
    ...    attribute_name=showname
    @{X2_SECONDARYRATTYPE}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${X2_COMMANPATH}/${X2_SECONDARYRATTYPE}
    ...    attribute_name=showname
    ${x2_startTimeStamp}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${X2_COMMANPATH}/${X2AP_STARTTIMESTAMP}
    ...    attribute_name=value
    ${x2_endTimeStamp}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${X2_COMMANPATH}/${X2AP_ENDTIMESTAMP}
    ...    attribute_name=value
    ${x2_usageCountUL}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${X2_COMMANPATH}/${X2AP_USAGECOUNTUL}
    ...    attribute_name=value
    ${x2_usageCountDL}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${X2_COMMANPATH}/${X2AP_USAGECOUNTDL}
    ...    attribute_name=value
    ${endTime}    set variable    ${x2_endTimeStamp}[-2]
    ${startTime}    set variable    ${x2_startTimeStamp}[-2]
    ${countUL}    set variable    ${x2_usageCountUL}[-2]
    ${countDL}    set variable    ${x2_usageCountDL}[-2]
    ${countUL4}    set variable    ${x2_usageCountUL}[-1]
    ${countDL4}    set variable    ${x2_usageCountDL}[-1]
    ${x2_result_endTime}    Convert To Integer    ${endTime}    16
    ${x2_result_startTime}    Convert To Integer    ${startTime}    16
    ${x2_result_time}    Evaluate    ${x2_result_endTime}-${x2_result_startTime}
    ${result_10}    convert to integer    10
    ${countUL_int}    convert to integer    ${countUL}    16
    ${countDL_int}    convert to integer    ${countDL}    16
    ${countUL_int4}    convert to integer    ${countUL4}    16
    ${countDL_int4}    convert to integer    ${countDL4}    16
    ${result_0}    convert to integer    0
    should be equal as strings    ${x2_result_time}    ${result_10}
    Run Keyword If    ${L3call}
    ...    run keywords
    ...    Should Be True    ${countUL_int4}>${result_0}      AND
    ...    Should Be True    ${countDL_int4}>${result_0}
    ...    ELSE
    ...    run keywords
    ...    Should Be True    10000000>${countUL_int}>=${result_0}     AND
    ...    should be true    10000000>${countDL_int}>=${result_0}
    should Contain    ${x2_e_RAB}[0]    e-RAB
    should Contain    ${X2_SECONDARYRATTYPE}[0]    nr



Check secondaryRATDataUsageReport exist in S1log
    [Documentation]    author: Wang LiYa
    ...       Description: check s1ap secondaryRATType
    [Arguments]    ${tcpdump_log}    ${L3call}=${False}
    ${filtered_packets}    Load pcap with filter    pcap_file=${tcpdump_log}    filter_expression=s1ap
    ...    command_template=${S1AP_COMMAND}
    @{S1_SECONDARYRATTPYE}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${S1_SECONDARYRATTYPE}
    ...    attribute_name=showname
    ${s1_startTimeStamp}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${S1AP_STARTTIMESTAMP}
    ...    attribute_name=value
    ${s1_endTimeStamp}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${S1AP_ENDTIMESTAMP}
    ...    attribute_name=value
    ${s1_usageCountUL}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${S1AP_USAGECOUNTUL}
    ...    attribute_name=value
    ${s1_usageCountDL}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${S1AP_USAGECOUNTDL}
    ...    attribute_name=value
    ${endTime}    set variable    ${s1_endTimeStamp}[3]
    ${startTime}    set variable    ${s1_startTimeStamp}[3]
    ${countUL}    set variable    ${s1_usageCountUL}[3]
    ${countDL}    set variable    ${s1_usageCountDL}[3]
    ${s1_result_endTime}    Convert To Integer    ${endTime}    16
    ${s1_result_startTime}    Convert To Integer    ${startTime}    16
    ${s1_result_time}    Evaluate    ${s1_result_endTime}-${s1_result_startTime}
    ${result_10}    convert to integer    10
    ${countUL_int}    convert to integer    ${countUL}    16
    ${countDL_int}    convert to integer    ${countDL}    16
    ${result_0}    convert to integer    0
    should be equal as strings    ${s1_result_time}    ${result_10}
    Run Keyword If    ${L3call}
    ...    run keywords
    ...    Should Be True    ${countUL_int}>${result_0}      AND
    ...    Should Be True    ${countDL_int}>${result_0}
    ...    ELSE
    ...    run keywords
    ...    Should Be True    10000000>${countUL_int}>=${result_0}     AND
    ...    should be true    10000000>${countDL_int}>=${result_0}



Check secondaryRATDataUsageReport exist in E1log
    [Documentation]    author: Wang LiYa
    ...     Description: check E1ap  secondaryRATType
    [Arguments]    ${tcpdump_log}    ${L3call}=${False}
    ##e1log
    ${filtered_packets}    Load pcap with filter    pcap_file=${tcpdump_log}
    ...    filter_expression=e1ap
    ...    command_template=${E1AP_COMMAND}
    ${e1_startTimeStamp}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${E1_COMMANPATH}/${E1_ERAB_COMM}/${E1AP_STARTTIMESTAMP}
    ...    attribute_name=value
    ${e1_endTimeStamp}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${E1_COMMANPATH}/${E1_ERAB_COMM}/${E1AP_ENDTIMESTAMP}
    ...    attribute_name=value
    ${e1_usageCountUL}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${E1_COMMANPATH}/${E1_ERAB_COMM}/${E1AP_USAGECOUNTUL}
    ...    attribute_name=value
    ${e1_usageCountDL}    cap.get_field_value_by_xpath      pdml_list=${filtered_packets}
    ...    xpath=.//${E1_COMMANPATH}/${E1_ERAB_COMM}/${E1AP_USAGECOUNTDL}
    ...    attribute_name=value
    ${endTime}    set variable    ${e1_endTimeStamp}[-2]
    ${startTime}    set variable    ${e1_startTimeStamp}[-2]
    ${countUL}    set variable    ${e1_usageCountUL}[-2]
    ${countDL}    set variable    ${e1_usageCountDL}[-2]
    ${countUL4}    set variable    ${e1_usageCountUL}[-1]
    ${countDL4}    set variable    ${e1_usageCountDL}[-1]
    ${e1_result_endTime}    Convert To Integer    ${endTime}    16
    ${e1_result_startTime}    Convert To Integer    ${startTime}    16
    ${e1_result_time}    Evaluate    ${e1_result_endTime}-${e1_result_startTime}
    ${result_10}    convert to integer    10
    ${countUL_int}    convert to integer    ${countUL}    16
    ${countDL_int}    convert to integer    ${countDL}    16
    ${countUL_int4}    convert to integer    ${countUL4}    16
    ${countDL_int4}    convert to integer    ${countDL4}    16
    ${result_0}    convert to integer    0
    should be equal as strings    ${e1_result_time}    ${result_10}
    Run Keyword If    ${L3call}
    ...    run keywords
    ...    Should Be True    ${countUL_int4}>${result_0}      AND
    ...    Should Be True    ${countDL_int4}>${result_0}
    ...    ELSE
    ...    run keywords
    ...    Should Be True    10000000>${countUL_int}>=${result_0}     AND
    ...    should be true    10000000>${countDL_int}>=${result_0}


check Scondary RAT Data Usage Report in UE Context Release Complete message
    [Documentation]    author: Wang LiYa
    ...       Description: check s1ap secondaryRATType
    [Arguments]    ${tcpdump_log}
    ${filtered_packets}    Load pcap with filter    pcap_file=${tcpdump_log}    filter_expression=s1ap
    ...    command_template=${S1AP_COMMAND}
    @{path_s1_secondaryRAT}    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${S1_CONTEXTRELEASE_COMMONPATH}
    ...    attribute_name=showname
    should contain    ${path_s1_secondaryRAT}    SecondaryRATDataUsageReportList



Check secondaryRATDataUsageReport not exist in s1log
    [Documentation]    author: Wang LiYa
    ...    Description: check s1ap secondaryRATType
    [Arguments]    ${tcpdump_log}
    ${filtered_packets}    Load pcap with filter    pcap_file=${tcpdump_log}    filter_expression=s1ap
    ...    command_template=${S1AP_COMMAND}
    @{path_s1_secondaryRAT}    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${S1_COMMON_MESSAGE_ELEMENT}
    ...    attribute_name=showname
    should not contain    {path_s1_secondaryRAT}    id-SecondaryRATDataUsageReport

Suite preparation
    [Documentation]    Author: Wang liya
    [Timeout]    20 min
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}
    ...    is_all_cells_checking_needed=${True}
    ${UE_TYPE}    translate_power_ue_type_from_testline
    set suite variable    ${UE_TYPE}

Case env recovery
    [Documentation]    Author: Wang liya
    ...    Description: is_need_to_wait_cluster_ready, if set to ${True},
    ...    then need to wait for the cluster to recovery
    ...    if set to ${False}, then skip the waiting for recovery
    [Arguments]  ${is_traffic_need_to_be_stopped}=${False}    ${ue_type}=${UE_TYPE}
    Run keyword if    ${is_traffic_need_to_be_stopped}    Close iperf progress
    Run keyword and ignore error    Close all connection

Case preparation
    [Documentation]  Author: Wang liya
    ...              Description: Precondition for case 028, which need configuration for 2*2
    COAM Create log directory
    Cloud DU connect to gnb coam via ssl
