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
# ...            Run keyword If   '${gnb_instance}'!='@{diffTL_gnb_ID}[0]'    Prepare the enb cell onair on 1927   AND
# ...            set e1ap variable    AND
# ...            Enb use EPCsim    AND
# ...            Enb use Multi-DRB
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword And Ignore Error    Stop and Save classical Logs    x2logname=${x2logname1}    AND
# ...               Run Keyword And Ignore Error    teardown for UE detach    AND
# ...               Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
# ...               Enb use RealEPC    AND
# ...               Run keyword If   '${gnb_instance}'!='@{diffTL_gnb_ID}[0]'
# ...               Prepare the enb cell onair on 1927    scf_file=${SCF_file_name_Enb_restore}    AND
# ...               Enb use Single-DRB    AND
# ...               Disconnect connections
# 
# Resource    ./Resources/5GC001927-U_coam_common_keywords.robot
# 
# *** Variables ***
# ${x2logname1}    886D13_Samsungx201.pcap
# ${x2logname2}    886D13_Samsungx202.pcap
# ${x2logname3}    886D13_Samsungx203.pcap
# 
# ${epc_log_path}    /tmp/
# ${SCF_path}    /opt/workspace/SCF/
# ${SCF_file_name_cloud}    Full_Configuration_SCF_1881_886_7657.xml
# ${SCF_file_name_classical_34711}    gy_34712_GNB2_886D13.xml
# ${SCF_file_name_classical_23311}    gy_23312_GNB2_886D13.xml
# ${SCF_file_name_classical_34711_Enb}    gy_34712_GNB2_886D13_Enb.xml
# ${SCF_file_name_classical_23311_Enb}    gy_23312_GNB2_886D13_Enb.xml
# ${SCF_file_name_classical_34711_Enb_restore}    gy_34721_ENB1.xml
# ${SCF_file_name_classical_23311_Enb_restore}    gy_23321_ENB1.xml
# ${eNB_path}    /tmp
# ${x2ap_filter}    x2ap
# #${e1ap_filter}    e1ap
# ${s1ap_filter}    s1ap
# ${index0}    0
# ${index1}    1
# ${index2}    2
# 
# ${QXDM_log_D13}    QXDM_log_D13
# #${e1ap}    e1ap_15_3_0_1903_n01
# @{diffTL_gnb_ID}    356111    34711    23311
# 
# *** Test Cases ***
# [1]5GC000886_D_13_Secondary_RAT_Data_Usage_Report_Periodical_with_MultiDRB
#     [Documentation]
#     ...    This case is to verify Secondary RAT Data Usage Report predically with multi DRBs,
#     ...    If that was first DRB succesful addition for particular UE then 5G-CP-NRT shall start Periodical
#     ...    Secondary RAT Data Usage Report timer.
#     [Tags]     5GC001927-U    CRT_TRUNK    CRT_22R3    SBTS00    RAN_5G    RAN_5G_TDD    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     EPCsim load cfg file
#     Prepare the classical COAM BTS cell onair on 1927
#     RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the classical COAM BTS cell onair on 1927
#     should be equal    ${cell_status}    PASS
#     run keyword if   '${gnb_instance}'=='@{diffTL_gnb_ID}[0]'
#     ...    Modify NIDD parameter on gnb    parameters_to_update=${parameter_886_D13}
#     ...    ELSE    Modify NIDD parameter on gnb    parameters_to_update=${parameter_886_D13_GNB2}    gnb_index=${1}
#     lock gnb AMF1 on TL354 or TL355
#     run keyword if   '${gnb_instance}'=='@{diffTL_gnb_ID}[0]'
#     ...    Adjust the tl HBTE attenuation value    tl=${gnb_instance}    gnb_cell1_value=${12}    enb_cell1_value=${0}
#     ...    ELSE    Adjust the tl HBTE attenuation value    tl=${gnb_instance}    gnb_cell1_value=${0}    enb_cell1_value=${0}
#     run keyword if   '${gnb_instance}'!='@{diffTL_gnb_ID}[0]'
#     ...    Adjust the tl other port HBTE attenuation value    gnb_other_value=${127}
#     Check device exist with UE
#     Prepare ue attach on 5G
#     UE attach on 5G
#     delete 2nd drb for UE
#     run keyword if   '${gnb_instance}'=='@{diffTL_gnb_ID}[0]'
#     ...    Start Capture Classical Logs    x2logname=${x2logname1}    gnb_index=${0}
#     ...    ELSE    Start Capture Classical Logs    x2logname=${x2logname1}    gnb_index=${1}
#     sleep    5s
#     create second drb for UE
#     sleep    5s
#     run keyword if   '${gnb_instance}'=='@{diffTL_gnb_ID}[0]'
#     ...    Stop and Save classical Logs    x2logname=${x2logname1}    gnb_index=${0}
#     ...    ELSE    Stop and Save classical Logs    x2logname=${x2logname1}    gnb_index=${1}
#     Analysis wireshark log for case 886D13_01
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    unlock gnb AMF1 on TL354 or TL355    AND
#     ...    Teardown adjust the tl HBTE attenuation value    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Capture QXDM log_D13
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
# Check Volumn Value between report and UE side_D13
#     [Arguments]    ${QXDM_log_name}    ${Log_name}
#     Check Volumn on report on D13    Log_name=${Log_name}
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
# Check Volumn on report on D13
#     [Arguments]    ${Log_name}
#     cap.read_cap    cap_file=${epc_log_path}${Log_name}    display_filter=x2ap||${e1ap}
#     ${DataUsageCountUL_1} =    cap.get_element_value    element_expression=x2ap.usageCountUL    element_idx=${0}
#     ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
#     ${DataUsageCountUL_2} =    cap.get_element_value    element_expression=x2ap.usageCountUL    element_idx=${1}
#     ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
#     ${DataUsageCountDL_1} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
#     ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
#     ${DataUsageCountDL_2} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${1}
#     ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
#     ${SumUL_Volum1} =     Sum list value    ${DataUsageCountUL_1}
#     ${SumUL_Volum2} =     Sum list value    ${DataUsageCountUL_2}
#     ${SumDL_Volum1} =     Sum list value    ${DataUsageCountDL_1}
#     ${SumDL_Volum2} =     Sum list value    ${DataUsageCountDL_2}
#     ${SumUL_Volum} =    evaluate    ${SumUL_Volum1} + ${SumUL_Volum2} + float(2)
# #    ${SumDL_Volum} =    evaluate    ${SumDL_Volum1} + ${SumDL_Volum2}
#     ${SumDL_Volum} =    evaluate    ${SumDL_Volum2} + float(0)
#     set test variable    ${SumUL_Volum}
#     set test variable    ${SumDL_Volum}
#     [Return]    ${SumUL_Volum}    ${SumDL_Volum}
# 
# Analysis wireshark log for case 886D13_01
#     cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${x2ap_filter}
# 
#     ${Code38} =    Catenate    x2ap.procedureCode == 38 and x2ap.e_RAB_ID == 5 and x2ap.e_RAB_ID == 6
#     ${Code38_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code38}
#     should be equal    ${Code38_status}    ${True}
# 
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
# 
# #    cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${e1ap_filter}
# #
# #    ${Code_15} =    Catenate    ${e1ap_filter}.procedureCode == 15 and ${e1ap_filter}.dRB_ID == 4 and ${e1ap_filter}.dRB_ID == 6
# #    ${Code_15_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${Code_15}
# #    should be equal    ${Code_15_status}    ${True}
# #
# #    ${e1ap_id} =    cap.get_element_value    element_expression=${e1ap_filter}.id    element_idx=${0}
# #    ...    default_value=${True}
# #    ...    condition_expression=${Code_15}
# #    Should Contain    ${e1ap_id}    2
# #    ${e1ap_id} =    cap.get_element_value    element_expression=${e1ap_filter}.id    element_idx=${1}
# #    ...    default_value=${True}
# #    ...    condition_expression=${Code_15}
# #    Should Contain    ${e1ap_id}    3
# #    ${rAT_Type} =    cap.get_element_value    element_expression=${e1ap_filter}.rAT_Type    element_idx=${0}
# #    ...    default_value=${True}
# #    ...    condition_expression=${Code_15}
# #    Should Be Equal    ${rAT_Type[0]}    1
# #
# #    ${startTimeStamp} =    cap.get_element_value    element_expression=${e1ap_filter}.startTimeStamp    element_idx=${0}
# #    ...    default_value=${True}
# #    ...    condition_expression=${Code_15}
# #    Should Not Be Equal    ${startTimeStamp}    ${None}
# #    ${endTimeStamp} =    cap.get_element_value    element_expression=${e1ap_filter}.endTimeStamp    element_idx=${0}
# #    ...    default_value=${True}
# #    ...    condition_expression=${Code_15}
# #    Should Not Be Equal    ${endTimeStamp}    ${None}
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
# Analysis wireshark log for case 886D13_02
#     cap.read_cap      cap_file=${epc_log_path}${x2logname2}    display_filter=${x2ap_filter}
#     ${Code38} =    Catenate    x2ap.procedureCode == 38 and x2ap.e_RAB_ID == 5 and x2ap.e_RAB_ID == 6
#     ${usageCountDL} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${1}
#     ...    default_value=${True}
#     ...    condition_expression=${Code38}
#     ${length_usageCountDL}=    Get Length    ${usageCountDL}
#     Set Suite Variable    ${usageCountDL}    ${usageCountDL}
#     Set Suite Variable    ${length_usageCountDL}    ${length_usageCountDL}
#     ${Sum_traffic_value_via_Wireshark}=    Calculate DL_throughoutput of Bearers via Wireshark
#     Set Suite Variable    ${Sum_traffic_value_via_Wireshark}    ${Sum_traffic_value_via_Wireshark}
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
# Get License
# #    run keyword if    '${enb_instance}'=='39'    Get Qualcomm License    ue_index=${2}
# #    ...    ELSE    Get Qualcomm License    ue_index=${0}
#     Get Qualcomm License    ue_index=${0}
# 
# Capture QXDM logs to check
# #    run keyword if    '${enb_instance}'=='39'    Capture QXDM log_D13    ue_index=${2}    QXDM_log_name=${QXDM_log_D13}
# #    ...    ELSE    Capture QXDM log_D13    ue_index=${0}    QXDM_log_name=${QXDM_log_D13}
#     Capture QXDM log_D13    ue_index=${0}    QXDM_log_name=${QXDM_log_D13}
# 
# Forbidden the UE data on TLs
#     Forbidden the UE data on diff TL    ue_index=${0}
# 
# Forbidden the UE data on diff TL
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_0
#     csn.send command
#     ...    command=adb -s ${serial_number} root
#     ...    connection=cpc_0
#     ...    timeout=5
#     sleep  10s
#     csn.send command
#     ...    command=adb -s ${serial_number} shell iptables -A OUTPUT -p udp --dport 53 -j REJECT
#     ...    connection=cpc_0
#     ...    timeout=5
# 
# 5G isf decoder to txt and save to local on diff TLs
#     sleep    30s
# #    run keyword if    '${enb_instance}'=='39'    5G isf decoder to txt and save to local    ue_index=${2}    QXDM_log_name=${QXDM_log_D13}
# #    ...    ELSE    5G isf decoder to txt and save to local    ue_index=${0}    QXDM_log_name=${QXDM_log_D13}
#     5G isf decoder to txt and save to local    ue_index=${0}    QXDM_log_name=${QXDM_log_D13}
# 
# Teardown adjust the tl HBTE attenuation value
#     Adjust the tl HBTE attenuation value    tl=${gnb_instance}    gnb_cell1_value=${127}    enb_cell1_value=${127}
#     run keyword if   '${gnb_instance}'!='@{diffTL_gnb_ID}[0]'
#     ...    Adjust the tl other port HBTE attenuation value    gnb_other_value=${127}