*** Settings ***
Documentation     author: meiya.cheng
...    contact: meiya.cheng@nokia-sbell.com

*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ./resources/common_7608.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${log_namex2}    x2_1.pcap
${pcap_path}     ${logPath}
${x2_filter}     nr-rrc.pucch_Resource == 10
${x2_check_pucch}    .//nr-rrc.csi_MeasConfig//nr-rrc.pucch_Resource
${display_filter}    uldata_pucchreceiverespps
${uciBits_field}    uci.pucch.ucibits
${du_scf_name}    /home/ute/CB007608/SCF334_1937_4cc_1732.xml

*** Test Cases ***
[1]5GC001732-B_111_4CC_UE_Capability_Check_and_RRC_Configuration_coderate_0.35
    [Documentation]    To check UE capabilities, sends an according RRC configuration inlcuding multiplexing of one optional beam report
	...    and up to 4 CSI ACQ reports on a multiplexing PUCCH resource. pucchF2MaxCodeRate=0.35
    [Setup]    SISO Coam Test Setup
	Commissioning 4CC scf
	Modify pucchF2MaxCodeRate
	Start to collect X2log on eNB    log_name=${log_namex2}
	L3 call ULDL and check throughput
	Stop and get X2Logs on eNB    log_name=${log_namex2}
	Check pucch Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}
	${filter_result}    Get ucibits from bip    bip_file=${bip_log_path_1}
	Get and check field values    filtered_packets=${filter_result}
    Run Keyword And Ignore Error    Cases Common teardown
    [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown


*** Keywords ***
L3 call ULDL and check throughput
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=500MKbits/sec     ${apn_address}=dxdata1    ${duration}=900
    ...    ${ul_tp}=100MKbits/sec    ${ul_target}=50    ${dl_target}=100
    ...    ${avg_percent}=0.1    ${min_percent}=0.1    ${iperf_type}=via_command
    Get Ue Type    ue_index=${ue_index}
    Prepare UE 7608    ue_index=${ue_index}    power_reset=${power_reset}
    UE Attach 7608    ue_index=${ue_index}    power_reset=${power_reset}
    ${bip_log_path_1}    TL334 Capture BIP log and download
	Set Suite Variable    ${bip_log_path_1}    ${bip_log_path_1}
    Start DL Traffic 7608    ue_index=${ue_index}    dl_tp=${dl_tp}
    ...    apn_address=${apn_address}    duration=${duration}
    Start UL Traffic 7608    ue_index=${ue_index}    ul_tp=${ul_tp}    apn_address=${apn_address}
    ...    duration=${duration}    iperf_type=${iperf_type}
    Check Tput 7608    ul_target=${ul_target}    dl_target=${dl_target}
    ...    avg_percent=${avg_percent}    min_percent=${min_percent}
    [Teardown]    Run Keyword And Ignore Error    Stop L3Call    ue_index=${ue_index}
    ...    apn_address=${apn_address}    power_reset=${power_reset}

Cases Common teardown
    Stop L3Call
	Run Keyword And Ignore Error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Get and check field values
    [Arguments]    ${filtered_packets}
	${list0}    get_field_value_by_name    field_name=${uciBits_field}
    ...    attribute_name=value    pcap_parser="Parser"
	FOR    ${value}    IN    @{list0}
	    Should Not Be Equal As Integers    ${value}    0    base=16
    END

Commissioning 4CC scf
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${du_scf_name}
    ...                              timeout=${600}    is_pdl_checking_needed=${False}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air

Get Filter pucchF2MaxCodeRate
    [Documentation]  Author: meiya.cheng
    ...              Description: get pucchF2MaxCodeRate value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${pucchF2MaxCodeRate_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/NRBTS-1/NRCELLGRP-0
    ...   abbr=pucchF2MaxCodeRate
    ...   filter_param=Pucch F2 Max Code Rate
    set suite variable    ${pucchF2MaxCodeRate_value}

Restore pucchF2MaxCodeRateinwebui
    [Documentation]    Description: restore pucchF2MaxCodeRate value
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELLGRP-0
    ...    abbr=pucchF2MaxCodeRate
    ...    new_value=zeroDot35
    ...    filter_param=Pucch F2 Max Code Rate
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Modify pucchF2MaxCodeRate
	Du login page via webUI
	Get Filter pucchF2MaxCodeRate
    Run Keyword If    '${pucchF2MaxCodeRate_value}'!='zeroDot35'
    ...    Restore pucchF2MaxCodeRateinwebui
    Run Keyword And Ignore Error    DU COAM selenium logout

Check pucch Resource in x2 log
    [Documentation]    Author: cheng meiya
    ...                Description: Check pucch Resource value in x2 log
    [Arguments]    ${pcap_file}    ${filter}
    ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter}
    ${x2_result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${x2_check_pucch}    attribute_name=show
    ${length}    Get Length    ${x2_result}
    FOR    ${i}    IN RANGE    ${length}
         Should Be Equal As Integers    ${x2_result}[${i}]    10
    END
