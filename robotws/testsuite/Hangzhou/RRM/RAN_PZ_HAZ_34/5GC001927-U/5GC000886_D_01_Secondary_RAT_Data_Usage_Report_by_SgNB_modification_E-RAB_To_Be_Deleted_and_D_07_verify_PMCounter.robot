# *** Settings ***
# Documentation
# ...   author: Shi Ming
# ...   contact: ming.shi@nokia-sbell.com
# ...   squad group: SG_03
# ...   feature : 5GC0001927-U
# 
# Force Tags      5G_SISO    9.1800    10.1800    CRT_21A    CRT_20B    CRT_TRUNK    RAN_5G    RAN_5G_TDD
# ...    PY36
# ...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00    5G_RAN_TDD
# 
# Suite Setup    Run Keywords
# ...            robot_common_operations.Common Suite Setup    AND
# ...            5GC001927-T_coam_common_keywords.Get gnb release info    AND
# ...            run keyword if   '${gnb_instance}'=='@{diffTL_gnb_ID}[0]'    CI_interface.Common Suite Setup    AND
# ...            5GC001927-T_coam_common_keywords.Pre Condition    AND
# ...            Preparation UE on setup    AND
# ...            set e1ap variable    AND
# ...            Enb use EPCsim    AND
# ...            Enb use Multi-DRB
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown    AND
# ...               5GC000738_common_keywords.gNB connections    AND
# ...               Run Keyword And Ignore Error    Tests Recover    ${x2logname1}    AND
# ...               Run Keyword And Ignore Error    Tests Recover    ${x2logname4}    AND
# ...               enb connections    AND
# ...               Run Keyword And Ignore Error    teardown for UE detach    AND
# ...               Enb use RealEPC    AND
# ...               Enb use Single-DRB    AND
# ...               Disconnect connections
# 
# Resource    ./Resources/5GC001927-U_coam_common_keywords.robot
# 
# *** Variables ***
# ${x2logname1}    886D01_Samsungx201.pcap
# ${x2logname2}    886D01_Samsungx202.pcap
# ${x2logname3}    886D01_Samsungx203.pcap
# ${x2logname4}    886D01_Samsungx204.pcap
# ${S1logname1}    886D01_SamsungS101.pcap
# ${epc_log_path}    /tmp/
# @{counter_id}   M55110C02001
# ${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# ${SCF_file_name_cloud}    Full_Configuration_SCF_1881_886_7657.xml
# @{full_path}    BTS/NRBTS-${tl.gnbs[0].instance_id}/NX2CB/ENDC_X2_SEC_RAT_DATA_USAGE_REP
# ${eNB_path}    /tmp
# ${x2ap_filter}    x2ap
# #${e1ap_filter}    e1ap
# ${s1ap_filter}    s1ap
# ${index0}    0
# ${index1}    1
# ${index2}    2
# ${QXDM_log_D01}    QXDM_log_D01
# #${e1ap}    e1ap_15_3_0_1903_n01
# @{diffTL_gnb_ID}    356111    355    354
# 
# *** Test Cases ***
# [1]5GC000886_D_01_Secondary_RAT_Data_Usage_Report_by_SgNB_modification_E-RAB_To_Be_Deleted
#     [Documentation]
#     ...    This case is to verify Secondary RAT Data Usage Report generation and delivery
#     ...    triggered by E-RAB to be deleted on one UE.
#     [Tags]     5GC001927-U    CRT_TRUNK    CRT_22R2    SBTS00    RAN_5G    RAN_5G_TDD
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     EPCsim load cfg file
#     Prepare the classical COAM BTS cell onair on 1927
#     RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the classical COAM BTS cell onair on 1927
#     should be equal    ${cell_status}    PASS
#     Modify NIDD parameter on gnb    parameters_to_update=${parameter_886_D01}
#     Adjust the tl HBTE attenuation value    tl=${gnb_instance}    gnb_cell1_value=${0}    enb_cell1_value=${0}
#     Check UE device exist
#     Prepare ue attach on 5G
#     Start Capture Classical Logs    x2logname=${x2logname1}    interface=any
#     UE attach on 5G
#     Stop and Save classical Logs    x2logname=${x2logname1}
#     Analysis wireshark log for case 886D01_01
# #    Get Qualcomm License    ue_index=0
#     Start Capture Classical Logs    x2logname=${x2logname4}    interface=any
# #    Capture QXDM log_D01    ue_index=0    QXDM_log_name=${QXDM_log_D01}
#     start DL and UL make traffic on 5G
#     Forbidden the UE data
#     stop DL and UL make traffic on 5G
#     sleep    2s
#     delete 2nd drb for UE
#     Stop and Save classical Logs    x2logname=${x2logname4}
# #    5G isf decoder to txt and save to local    ue_index=0    QXDM_log_name=${QXDM_log_D01}
#     Analysis wireshark log for case 886D01_02
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# #[1]5GC000886_D_07_Verify_PMCounter_Secondary_RAT_Data_Usage_Report_by_SgNB_modification_E-RAB_To_Be_Deleted
# #    [Documentation]
# #    ...    This case is to verify the PM counter of Secondary RAT Data Usage Report generation and delivery triggered
# #    ...    by E-RAB to be deleted on one UE,PM counter name ENDC_X2_SEC_RAT_DATA_USAGE_REP,PI-ID is M55110C02001.
# #    [Tags]     5GC001927-U
# #    [Timeout]    1 hour
# #    [Setup]
# #    Check PM counter updated with M55110C02001
# #    [Teardown]
# 
# *** Keywords ***
# Capture QXDM log_D01
#     [Arguments]    ${ue_index}    ${QXDM_log_name}
#     Connect to control pc enhanced    ue_index=${ue_index}
#     csn.send command    command=taskkill /F /IM QXDM.exe    connection=cpc_${ue_index}
#     csn.send command    command=taskkill /F /IM QPSTServer.exe    connection=cpc_${ue_index}
#     csn.send command
#     ...    command=cmd /c python ${5G_QXDM_PATH}/QXDM5Logcatch.py -t 140 -p MDM -c ${5G_QXDM_PATH}/volume.dmc -s ${5G_QX
# ...DM_PATH}/${QXDM_log_name}.hdf
#     ...    connection=cpc_${ue_index}    timeout=300
#     Csn.disconnect      connection=cpc_${ue_index}
# 
# Check Volumn Value between report and UE side_D01
#     [Arguments]    ${QXDM_log_name}    ${Log_name}
#     Check Volumn on report on D01    Log_name=${Log_name}
#     ${context} =    Get Binary File     ${epc_log_path}${QXDM_log_name}.txt
# #    ${regx expression} =    Set variable     Data PDU Bytes[\\w\\|\\s]+\\r\\n[\\w\\|\\#\\s]+\\r\\n[\\-\\s]+\\r\\n([\\d\\|\\s]+)\\r\\n
# #    ${filter data lines} =    Get Regexp Matches      ${context}    ${regx expression}      1
# #    ${value_list} =    create list    @{empty}
# #    :FOR    ${data line}    IN    @{filter data lines[::-1]}
# #    \    ${filter values} =    Get Regexp Matches     ${data line}     \\d+
# #    \    ${item_vaule} =    convert to integer    ${filter values[7]}
# #    \    Append to list    ${value_list}    ${item_vaule}
# #    should contain    ${value_list}    ${SumDL_Volum}
#     ${regx expression} =    Set variable     Total Num RX Bytes[\\w\\|\\s]+\\r\\n[\\-\\s]+\\r\\n([\\w\\d\\|\\s]+)
#     ${filter data lines} =    Get Regexp Matches      ${context}    ${regx expression}      1
#     ${value_list} =    create list    @{empty}
#     :FOR    ${data line}    IN    @{filter data lines[::-1]}
#     \    ${filter values} =    Get Regexp Matches     ${data line}     \\d+
#     \    ${item_vaule} =    convert to integer    ${filter values[8]}
#     \    Append to list    ${value_list}    ${item_vaule}
#     should contain    ${value_list}    ${SumUL_Volum}
# 
# Check Volumn on report on D01
#     [Arguments]    ${Log_name}
#     cap.read_cap    cap_file=${epc_log_path}${Log_name}    display_filter=x2ap||${e1ap}
#     ${DataUsageCountUL_1} =    cap.get_element_value    element_expression=x2ap.usageCountUL    element_idx=${0}
#     ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
# #    ${DataUsageCountUL_2} =    cap.get_element_value    element_expression=x2ap.usageCountUL    element_idx=${1}
# #    ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
#     ${DataUsageCountDL_1} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
#     ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
# #    ${DataUsageCountDL_2} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${1}
# #    ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
#     ${SumUL_Volum1} =     Sum list value    ${DataUsageCountUL_1}
# #    ${SumUL_Volum2} =     Sum list value    ${DataUsageCountUL_2}
#     ${SumDL_Volum1} =     Sum list value    ${DataUsageCountDL_1}
# #    ${SumDL_Volum2} =     Sum list value    ${DataUsageCountDL_2}
# #    ${SumUL_Volum} =    evaluate    ${SumUL_Volum1} + ${SumUL_Volum2} + float(2)
#     ${SumUL_Volum} =    evaluate    ${SumUL_Volum1} + float(2)
# #    ${SumDL_Volum} =    evaluate    ${SumDL_Volum1} + ${SumDL_Volum2}
#     ${SumDL_Volum1}=    Convert To String    ${SumDL_Volum1}
#     ${SumDL_Volum} =    evaluate    ${SumDL_Volum1}
#     set test variable    ${SumUL_Volum}
#     set test variable    ${SumDL_Volum}
#     [Return]    ${SumUL_Volum}    ${SumDL_Volum}
# 
# Analysis wireshark log for case 886D01_01
#     cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${x2ap_filter}
#     ${CP_mdrb} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 4
#     ...    and x2ap.e_RAB_ID == 5 and x2ap.e_RAB_ID == 6
#     ${mdrb_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${CP_mdrb}
#     should be equal    ${mdrb_status}    ${True}
#     ${SEC_RAT_DATA_USAGE_REP_0} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=ip.src == ${tl.gnbs[0].cu.oam_ssh_connection_details.addr} and x2ap.procedureCode == 38
#     ${length_SEC_RAT_DATA_USAGE_REP_0}=    Get Length    ${SEC_RAT_DATA_USAGE_REP_0}
#     Set Suite Variable    ${length_SEC_RAT_DATA_USAGE_REP_0}    ${length_SEC_RAT_DATA_USAGE_REP_0}
# 
# Start capture wireshark log on gnb and enb for case 886D01_02
#     Start Capture Classical Logs    x2logname=${x2logname2}    interface=any
#     Start capture wireshark log on eNB    enb_path=${eNB_path}    filename=${S1logname1}    interface=any
# 
# Stop capture wireshark log on gnb and enb for case 886D01_02
#     Stop and Save classical Logs    x2logname=${x2logname2}
#     Stop and Save classical Logs on eNB    enb_path=${eNB_path}    filename=${S1logname1}
#     ...    epc_log_path=${epc_log_path}
# 
# Analysis wireshark log for case 886D01_03
#     cap.read_cap      cap_file=${epc_log_path}${x2logname3}    display_filter=${x2ap_filter}
#     ${Code29_0} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 29 and x2ap.e_RAB_ID == 6
#     ${Code29_0_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code29_0}
#     should be equal    ${Code29_0_status}    ${True}
#     ${Code29_0_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code29_0}
#     ${Code29_0_time} =     Caculate the wireshark timevalue    ${Code29_0_time}    ${index0}
# 
#     ${Code04} =    Catenate    x2ap.procedureCode == 4 and x2ap.e_RAB_ID == 6
#     ${Code04_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code04}
#     should be equal    ${Code04_status}    ${True}
#     ${Code04_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code04}
#     ${Code04_time} =     Caculate the wireshark timevalue    ${Code04_time}    ${index0}
# 
#     ${Code38} =    Catenate    x2ap.procedureCode == 38 and x2ap.e_RAB_ID == 6
#     ${Code38_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code38}
#     should be equal    ${Code38_status}    ${True}
#     ${Code38_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     ${Code38_time} =     Caculate the wireshark timevalue    ${Code38_time}    ${index0}
#     ${X2AP_ID} =    cap.get_element_value    element_expression=x2ap.id    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     Should Be Equal    ${X2AP_ID[0]}    111
#     ${secondaryRATType} =    cap.get_element_value    element_expression=x2ap.secondaryRATType    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     Should Be Equal    ${secondaryRATType[0]}    0
#     ${startTimeStamp} =    cap.get_element_value    element_expression=x2ap.startTimeStamp    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     Should Not Be Equal    ${startTimeStamp}    ${None}
#     ${endTimeStamp} =    cap.get_element_value    element_expression=x2ap.endTimeStamp    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     Should Not Be Equal    ${endTimeStamp}    ${None}
# 
#     ${Code29_1} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 29 and x2ap.e_RAB_ID == 6
#     ${Code29_1_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code29_1}
#     should be equal    ${Code29_1_status}    ${True}
#     ${Code29_1_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code29_1}
#     ${Code29_1_time} =     Caculate the wireshark timevalue    ${Code29_1_time}    ${index0}
# 
#     ${Code28} =    Catenate    x2ap.procedureCode == 28
#     ${Code28_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code28}
#     should be equal    ${Code28_status}    ${True}
#     ${Code28_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code28}
#     ${Code28_time} =     Caculate the wireshark timevalue    ${Code28_time}    ${index0}
# 
# 
#     cap.read_cap      cap_file=${epc_log_path}${x2logname3}    display_filter=${e1ap_filter}
#     ${Code_05_01} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.id == 18 and e1ap.dRB_ID == 5
#     ${Code_05_01_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code_05_01}
#     should be equal    ${Code_05_01_status}    ${True}
#     ${Code_05_01_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_05_01}
#     ${Code_05_01_time} =     Caculate the wireshark timevalue    ${Code_05_01_time}    ${index0}
# 
#     ${Code_05_02} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.id == 19 and e1ap.dRB_ID == 5
#     ${Code_05_02_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code_05_02}
#     should be equal    ${Code_05_02_status}    ${True}
#     ${Code_05_02_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_05_02}
#     ${Code_05_02_time} =     Caculate the wireshark timevalue    ${Code_05_02_time}    ${index0}
# 
#     ${Code_15} =    Catenate    e1ap.procedureCode == 15 and e1ap.dRB_ID == 5
#     ${Code_15_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code_15}
#     should be equal    ${Code_15_status}    ${True}
#     ${Code_15_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_15}
#     ${Code_15_time} =     Caculate the wireshark timevalue    ${Code_15_time}    ${index0}
#     ${e1ap_id} =    cap.get_element_value    element_expression=e1ap.id    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_15}
#     Should Contain    ${e1ap_id}    2
#     ${e1ap_id} =    cap.get_element_value    element_expression=e1ap.id    element_idx=${1}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_15}
#     Should Contain    ${e1ap_id}    3
#     ${rAT_Type} =    cap.get_element_value    element_expression=e1ap.rAT_Type    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_15}
#     Should Be Equal    ${rAT_Type[0]}    1
#     ${startTimeStamp} =    cap.get_element_value    element_expression=e1ap.startTimeStamp    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_15}
#     Should Not Be Equal    ${startTimeStamp}    ${None}
#     ${endTimeStamp} =    cap.get_element_value    element_expression=e1ap.endTimeStamp    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code_15}
#     Should Not Be Equal    ${endTimeStamp}    ${None}
# 
# #    ${Code38} =    Catenate    x2ap.procedureCode == 38 and x2ap.e_RAB_ID == 5
#     ${SEC_RAT_DATA_USAGE_REP_1} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=ip.src == ${tl.gnbs[0].cu.oam_ssh_connection_details.addr} and x2ap.procedureCode == 38
#     ${length_SEC_RAT_DATA_USAGE_REP_1}=    Get Length    ${SEC_RAT_DATA_USAGE_REP_1}
#     Set Suite Variable    ${length_SEC_RAT_DATA_USAGE_REP_1}    ${length_SEC_RAT_DATA_USAGE_REP_1}
# 
# 
#     cap.read_cap      cap_file=${epc_log_path}${S1logname1}    display_filter=${s1ap_filter}
#     ${Code07} =    Catenate    s1ap.S1AP_PDU == 1 and s1ap.procedureCode == 7
#     ...    and s1ap.e_RAB_ID == 6 and s1ap.secondaryRATType == 0
#     ${Code07_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code07}
#     should be equal    ${Code07_status}    ${True}
#     ${Code07_time} =    cap.get_element_value    element_expression=frame_info.time    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code07}
# 
# #    #####current the mmessage flow is as below according to CFAM#####
# #    Should Be True    ${Code29_0_time} < ${Code_05_01_time}
# #    Should Be True    ${Code_05_01_time} < ${Code_05_02_time}
# #    Should Be True    ${Code_05_02_time} < ${Code_15_time}
# #    Should Be True    ${Code_15_time} < ${Code04_time}
# #    Should Be True    ${Code04_time} < ${Code38_time}
# #    Should Be True    ${Code38_time} < ${Code29_1_time}
# #    Should Be True    ${Code29_1_time} < ${Code28_time}
# 
# start check traffic on gNB
#     gNB connections
#     csn.send_command    command=journalctl -f | grep -i "DL-PDCP numOfBearers" > /tmp/SRDUR.txt    connection=gnb
# 
# stop check traffic on gNB
# #    sleep    10s
#     csn.send_command    command=killall journalctl    connection=gnb
#     ${traffic_value}=    csn.execute    command=cat /tmp/SRDUR.txt | cut -d '|' -f 5 | cut -d 'p' -f -1    connection=gnb
#     ${traffic_value}=    Split String    ${traffic_value}
#     ${length_traffic_value}=    Get Length    ${traffic_value}
#     Set Suite Variable    ${traffic_value}    ${traffic_value}
#     Set Suite Variable    ${length_traffic_value}    ${length_traffic_value}
#     ${Sum_traffic_value}=    Calculate DL_throughoutput of Bearers
#     csn.disconnect      connection=gnb
#     Set Suite Variable    ${Sum_traffic_value}    ${Sum_traffic_value}
# 
# Calculate DL_throughoutput of Bearers
#     ${Sum_traffic_value}=    Set Variable    ${0}
#     :FOR	${index}	IN RANGE	${length_traffic_value}
#     \    ${Sum_traffic_value}    Evaluate    ${Sum_traffic_value} + ${traffic_value[${index}]}
#     ${Sum_traffic_value}    Evaluate    ${Sum_traffic_value} * 1052
#     [Return]      ${Sum_traffic_value}
# 
# Analysis wireshark log for case 886D01_02
#     cap.read_cap      cap_file=${epc_log_path}${x2logname4}    display_filter=${x2ap_filter}
#     ${Code38} =    Catenate    x2ap.procedureCode == 38 and x2ap.e_RAB_ID == 6
#     ${usageCountDL} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     ${length_usageCountDL}=    Get Length    ${usageCountDL}
#     Set Suite Variable    ${usageCountDL}    ${usageCountDL}
#     Set Suite Variable    ${length_usageCountDL}    ${length_usageCountDL}
#     ${Sum_traffic_value_via_Wireshark}=    Calculate DL_throughoutput of Bearers via Wireshark
#     Set Suite Variable    ${Sum_traffic_value_via_Wireshark}    ${Sum_traffic_value_via_Wireshark}
# 
# #    ${Code38} =    Catenate    x2ap.procedureCode == 38 and x2ap.e_RAB_ID == 5
#     ${SEC_RAT_DATA_USAGE_REP_2} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
#     ...    default_value=${True}
#     ...    condition_expression=ip.src == ${tl.gnbs[0].cu.oam_ssh_connection_details.addr} and x2ap.procedureCode == 38
# #    ${length_SEC_RAT_DATA_USAGE_REP_2}=    Get Length    ${SEC_RAT_DATA_USAGE_REP_2}
# #    Set Suite Variable    ${length_SEC_RAT_DATA_USAGE_REP_2}    ${length_SEC_RAT_DATA_USAGE_REP_2}
# 
# Calculate DL_throughoutput of Bearers via Wireshark
#     ${Sum_traffic_value_via_Wireshark}=    Set Variable    ${0}
#     :FOR	${index}	IN RANGE	${length_usageCountDL}
#     \    ${Sum_traffic_value_via_Wireshark}    Evaluate    ${Sum_traffic_value_via_Wireshark} + ${usageCountDL[${index}]}
#     [Return]      ${Sum_traffic_value_via_Wireshark}
# 
# Compare DL_throughoutput of Bearers via log and tcpdump
#     Should Be Equal    ${Sum_traffic_value}    ${Sum_traffic_value_via_Wireshark}
# 
# 
# 
# 
# Check PM counter updated with M55110C02001
# #    ${length_SEC_RAT_DATA_USAGE_REP}=
# #    ...    Evaluate    ${length_SEC_RAT_DATA_USAGE_REP_0} + ${length_SEC_RAT_DATA_USAGE_REP_1} + ${length_SEC_RAT_DATA_USAGE_REP_2}
#     sleep    150s
#     selenium_coam.enable_virtual_display
#     selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#     wait until keyword succeeds    10min    1min    Get counter1
#     ${result0}    get dictionary values   ${res0}
#     ${counter_value0}=    Get couter value    counter_result=${result0}
#     ${counter_value0}=    Convert To Integer    ${counter_value0}
# #    should be equal    ${counter_value0}    ${length_SEC_RAT_DATA_USAGE_REP}
#     should be equal    ${counter_value0}    ${1}
#     selenium_coam.logout