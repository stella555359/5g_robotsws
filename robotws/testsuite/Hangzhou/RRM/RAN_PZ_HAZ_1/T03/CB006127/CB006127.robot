*** Settings ***
Documentation
...   author: Tengfei Chen
...   contact: tengfei.chen@nokia-sbell.com
...   This is CB006127 testing robot case
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
#...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBR_ABIO_ABIL2_AEHC_AHFIB_AHLOA_AHFIG
...                     SBTS00
#...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}          ${127}
${PA_MinValue}          ${0}
${PA_NormalValue}       ${5}
${PA_NormalValue2}      ${20}
${step_cmd}    proc node pcf 1 policy-update-notify all
${dn1}     MRBTS-887/NRBTS-887/NRCELL-22/PLMN-PLMN/NRPMQAP-1
${dn2}     MRBTS-887/NRBTS-887/NRCELL-22/PLMN-PLMN/NRPMQAP-2
${dn3}     MRBTS-887/NRBTS-887/NRCELL-22/PLMN-PLMN/NRPMQAP-3
${dn4}     MRBTS-887/NRBTS-887/NRCELL-22
${parameter}           maxNumOfNonGBRBearersSA
${dist_name}           MRBTS-887/NRBTS-887/NRCELL-22
${host}              10.56.218.70
${username}          ute
${password}          Nokia123!
${file_path1}         ${CURDIR}/UE_AMBR1.txt
${file_path2}         ${CURDIR}/UE_AMBR2.txt
${file_path3}         ${CURDIR}/UE_AMBR3.txt
${file_path4}         ${CURDIR}/PDU_AMBR1.txt

*** Test Cases ***
CB006127_A_01_NSA_Report_CGI_configuration_to_UE_based_on_RSRQ
    [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB006127
    Lock other unused cells
    Start Multi Bts Log
    Adjust signal of BTS2138 LTE CELL2
    AT Trigger UE Attach
    Adjust signal of BTS887 NR CELL22
    Check EN-DC State For BTS1
    sleep    10s
    HO from BTS887 NR Cell_22 to NR Cell_2
    sleep    200s
    Check CGI report For BTS0
    Check add NRREL For BTS0
    Unblock Other Cells

CB006127_A_02_SA_Report_CGI_configuration_to_UE_based_on_RSRP_RSRQ
    [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB006127_case02
    Lock other unused SA cells
    Start Multi Bts Log
    Adjust signal of BTS887 NR CELL22 case2
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    10s
    SA HO from 887 NR Cell_22 to NR Cell_2
    sleep    200s
    Check SA CGI report For BTS0
    Check add NRREL For BTS0
    Unblock Other SA Cells

Case18_Counter for 5QI modification success used by USCB008126-SR-A-B1
    [Documentation]    author:tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB008126
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf

	Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
    sleep    60s
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    60s
    Log To Console    add5QI9
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    sleep    10s
	Log To Console    modify5QI8
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    16 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Counter M55125C and M55163C for case18    starttime=${start_time}    endtime=${end_time}    dn=${dn4}
    Check Counter M55125C and M55163C for case18    starttime=${start_time}    endtime=${end_time}    dn=${dn2}


Case21_Counter for 5QI modification failure used by USCB008126-SR-A-B7
    [Documentation]    author:tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB008126_case21
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf

	Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
    sleep    60s
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    60s
    Log To Console    add5QI9
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    sleep    10s
	Log To Console    modify5QI8
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    16 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Counter M55125C and M55163C for case21    starttime=${start_time}    endtime=${end_time}    dn=${dn4}
    Check Counter M55125C and M55163C for case21    starttime=${start_time}    endtime=${end_time}    dn=${dn2}


USCB008234_C_B1_DL_and_UL_UE_AMBR_limitation_modification_for_UE_Context modification request
    [Documentation]    author:tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB008234

    Start tcpdump by command For Remote
    Sleep    10s
	Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
    sleep    60s
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    60s

	Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
	sleep    10s

    Stop tcpdump And download by command For Remote
    sleep    30s

    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    sleep    30s

    Check BitRate UE CONTEXT MODIFICATION REQUEST In Wireshark Log    ${capture_file_path_source}
	Check BitRate BEARER CONTEXT MODIFICATION REQUEST In Wireshark Log    ${capture_file_path_source}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path3}

USCB008234_counters_for_AMBR_value_distribution_with_newly_received_and_validated_AMBR_value
    [Documentation]    author:tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB008234

	Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
	Sleep    10s
	Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
    sleep    60s
    AT Trigger UE Attach      index_of_yaml=${1}

	Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path4}

	Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Counter SA_AMBR1    starttime=${start_time}    endtime=${end_time}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path3}


USCB008234_counters_for_AMBR_value_distribution_with_DLAMBR_and_ULAMBR_value_set_0
    [Documentation]    author:tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB008234

	Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

    Sleep    10s
	Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
    sleep    60s
    AT Trigger UE Attach      index_of_yaml=${1}

    sleep    30s
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

	sleep    30s
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Counter SA_AMBR2    starttime=${start_time}    endtime=${end_time}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path3}

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
#    Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

AT Trigger UE Attach
    [Documentation]    send command by AT cmd,will auto find the ue type
    [Arguments]    ${ue_index}=${0}    ${index_of_yaml}=${0}
    Log to console    Attach ue ${index_of_yaml}
    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${UE_TYPE}    ${ue_type}
    run keyword    ${UE_TYPE}.Prepare UE    ue_index=${ue_index}    index_of_yaml=${index_of_yaml}
    Wait Until Keyword Succeeds   3x   1min    ${UE_TYPE}.UE Attach    ue_index=${ue_index}
    ...    index_of_yaml=${index_of_yaml}
    Sleep    40s     msg=wait for ue attach success

Lock other unused cells
    Log To Console    Lock other unused cells
    COAM_Admin.Block_CELL    global_cell_id=25 1 3    cell_type=lte    connection=COAM_1
    COAM_Admin.Block_CELL    global_cell_id=25    cell_type=nr    connection=COAM_0
    sleep    20s

Unblock Other Cells
    Log To Console    Unblock other unused cells
    COAM_Admin.unBlock_CELL    global_cell_id=25 1 3    cell_type=lte    connection=COAM_1
    COAM_Admin.unBlock_CELL    global_cell_id=25    cell_type=nr    connection=COAM_0
    Sleep    15s

Adjust signal of BTS2138 LTE CELL2
    Log To Console    Attach UE To ENB And GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_MinValue}

Adjust signal of BTS887 NR CELL22
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_NormalValue2}

HO from BTS887 NR Cell_22 to NR Cell_2
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

Check EN-DC State For BTS${i}
    Sleep    10s
    Log To Console    Check EN-DC Attach State
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "X2AP_SGNB_RECONFIGURATION_COMPLETE" | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check CGI report For BTS${i}
    Log To Console    Check CGI report
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "NrcgiReport for PCI" | grep -av grep
    Should Contain    ${ret}    NrcgiReport for PCI

Check add NRREL For BTS${i}
    Log To Console    Check add NRREL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "addNrRelMoc" | grep -av grep
    Should Contain    ${ret}    addNrRelMoc

Lock other unused SA cells
    Log To Console    Lock other unused cells
    COAM_Admin.Block_CELL    global_cell_id=1 41 25    cell_type=nr    connection=COAM_0
    sleep    20s

Unblock Other SA Cells
    Log To Console    Unblock other unused cells
    COAM_Admin.unBlock_CELL    global_cell_id=1 41 25    cell_type=nr    connection=COAM_0
    Sleep    15s

Adjust signal of BTS887 NR CELL22 case2
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${5}    gnb_id=${0}    value=${PA_MinValue}

SA HO from 887 NR Cell_22 to NR Cell_2
    Log    Intra Handover start
    ${increase_port_list}    Get Attenuation port    RU_id=${5}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${0}
    ${increase_value_list}    Create List    ${5}     ${10}    ${15}    ${20}    ${25}
    ${decrease_value_list}    Create List    ${63}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${4}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    15s

Check SA CGI report For BTS${i}
    Log To Console    Check CGI report
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "NRCGI value taken from cgi-info" | grep -av grep
    Should Contain    ${ret}    NRCGI value taken from cgi-info

Check Counter M55125C and M55163C for case18
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
    ${pi_list}    Create List    M55125C00044    M55125C00045    M55125C00047    M55163C00023    M55163C00024    M55163C00025
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044    ${dn}
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00045    ${dn}
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00047    ${dn}
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00023    ${dn}
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00024    ${dn}
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00025    ${dn}
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${0}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}==${1}
    Should be true    ${sum_5_val}==${1}
    Should be true    ${sum_6_val}==${0}

Run Script File On PCF Simulator
    [Arguments]  ${pcf_simulator}    ${cmdfile}
    Call Method    ${pcf_simulator}    exec_cli_command_file    ${cmdfile}

Run Command On PCF Simulator
   [Arguments]  ${pcf_simulator}    ${cmd}
   Call Method    ${pcf_simulator}    exec_cli_command    ${cmd}

Pet PCF Simulator Teardown
    [Arguments]  ${pcf_simulator}
    Call Method    ${pcf_simulator}    teardown

Check Counter M55125C and M55163C for case21
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
    ${pi_list}    Create List    M55125C00044    M55125C00045    M55125C00047    M55163C00023    M55163C00024    M55163C00025
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044    ${dn}
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00045    ${dn}
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00047    ${dn}
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00023    ${dn}
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00024    ${dn}
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00025    ${dn}
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${0}
    Should be true    ${sum_4_val}==${1}
    Should be true    ${sum_5_val}==${0}
    Should be true    ${sum_6_val}==${1}

# Run Cmd Of File In Remote Server
#     [Arguments]  ${host}    ${username}    ${password}    ${file_path}
#     ${context}    Get File    ${file_path}
#     csn.Connect To    hostname=${host}    username=${username}    password=${password}    alias=remote_server_${host}
#     csn.Execute    command=${context}    connection=remote_server_${host}
#     ssh .Disconnect    connection=remote_server_${host}

Check Counter SA_AMBR1
    [Arguments]    ${starttime}    ${endtime}
    PM_counters_collector
    ${pi_list}    Create List    M55125C13036    M55125C13037    M55125C13038    M55125C13039    M55138C03541
    ...    M55138C03542    M55125C13046    M55125C13047
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13036
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13037
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13038
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13039
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55138C03541
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55138C03542
    ${sum_7_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13046
    ${sum_8_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13047
	Should be true    ${sum_1_val}>=${40000000}
	Should be true    ${sum_2_val}>=${15000000}
	Should be true    ${sum_3_val}>=${1000000000000}
	Should be true    ${sum_4_val}>=${1000000000000}
	Should be true    ${sum_5_val}>${1}
	Should be true    ${sum_6_val}>${1}
    Should be true    ${sum_7_val}==${0}
	Should be true    ${sum_8_val}==${0}

Check Counter SA_AMBR2
    [Arguments]    ${starttime}    ${endtime}
    PM_counters_collector
    ${pi_list}    Create List    M55125C13040    M55125C13041    M55125C13042    M55125C13043    M55138C03541
    ...    M55138C03542    M55125C13046    M55125C13047
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13040
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13041
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13042
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13043
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55138C03541
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55138C03542
    ${sum_7_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13046
    ${sum_8_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13047
	Should be true    ${sum_1_val}==${1}
	Should be true    ${sum_2_val}==${1}
	Should be true    ${sum_3_val}==${1}
	Should be true    ${sum_4_val}==${1}
	Should be true    ${sum_5_val}>${1}
	Should be true    ${sum_6_val}>${1}
    Should be true    ${sum_7_val}==${1}
	Should be true    ${sum_8_val}==${1}

Check BitRate UE CONTEXT MODIFICATION REQUEST In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    UEContextModificationRequest

    ${output}    Parse Pcap by expressionbackup
    ...    filter='f1ap.BitRate == 15000000'
    ...    filter_expression='f1ap.BitRate == 15000000'
    ...    input_file=${capture_file_path}

Check BitRate BEARER CONTEXT MODIFICATION REQUEST In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=e1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    BearerContextModificationRequest

    ${output}    Parse Pcap by expressionbackup
    ...    filter='e1ap.BitRate == 40000000'
    ...    filter_expression='e1ap.BitRate == 40000000'
    ...    input_file=${capture_file_path}