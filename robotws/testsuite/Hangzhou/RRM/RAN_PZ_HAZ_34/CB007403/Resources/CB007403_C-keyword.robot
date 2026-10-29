#*** Settings ***
#Documentation     author: Shenrao
#...               Group: 5G_PZ_MMW_HZ_3_SG
#...               contact: shushu.huang@nokia-sbell.com
#
#Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Library    OperatingSystem
#Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
#Library    taf.analyzer.pcap   WITH NAME   pcap
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
#
#Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
#Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
##Resource          ../../5GC001937_OTA/resources/5GC001937_keywords.robot
##Resource          ../../../../../resources/sites/Ulm/Common/pmcounters.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
#
#*** Variables ***
#
#${dltp}    10
#${ultp}    5
#${counter_path}    BTS/CELLS/NRCELL-1/NRACH
#${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T923
#${gnb_path}    /tmp/
#${epc_log_path}    /home/ute/testcase
#${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${filter}    /usr/bin/tshark -r {pcap_file} -Y  "x2ap" -T pdml
#
#${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
#${TSHARK_eventId}    ${TSHARK_5GC002177_COMMON} -T fields -e nr-rrc.eventId
#${TSHARK_eventId_pdml}    ${TSHARK_5GC002177_pdml} -T fields -e nr-rrc.eventId
#${TSHARK_a2_Threshold}    ${TSHARK_5GC002177_COMMON} -T fields -e nr-rrc.a2_Threshold
#${TSHARK_a2_Threshold_pdml}    ${TSHARK_5GC002177_pdml} -T fields -e nr-rrc.a2_Threshold
#${TSHARK_hysteresis}    ${TSHARK_5GC002177_COMMON} -T fields -e nr-rrc.hysteresis
#${TSHARK_hysteresis_pdml}    ${TSHARK_5GC002177_pdml} -T fields -e nr-rrc.hysteresis
#${TSHARK_timeToTrigger}    ${TSHARK_5GC002177_COMMON} -T fields -e nr-rrc.timeToTrigger
#${TSHARK_timeToTrigger_pdml}    ${TSHARK_5GC002177_pdml} -T fields -e nr-rrc.timeToTrigger
#${TSHARK_SgNBReleaseRequired}    ${TSHARK_5GC002177_COMMON} -T fields -e x2ap.SgNBReleaseRequired_element
#${TSHARK_SgNBReleaseRequired_pdml}    ${TSHARK_5GC002177_pdml} -T fields -e x2ap.SgNBReleaseRequired_element
#${TSHARK_SgNBReleaseConfirm}    ${TSHARK_5GC002177_COMMON} -T fields -e x2ap.SgNBReleaseConfirm_element
#${TSHARK_SgNBReleaseConfirm_pdml}    ${TSHARK_5GC002177_pdml} -T fields -e x2ap.SgNBReleaseConfirm_element
#${TSHARK_5GC002177_COMMON}    /usr/bin/tshark -r {pcap_file} -X lua_script:{luashark_path} -Y  \"x2ap\"
#${TSHARK_5GC002177_pdml}    /usr/bin/tshark -r ${epc_log_path}/${x2logname} -X lua_script:${luashark_path} -Y  \"x2ap\"
#
#*** Keywords ***
#Suite setup
#    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=COAM
#
#Suite teardown
#    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM   
#    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}
#
#Set parameter defaultLnRelGnbCellId to 7
#    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-239/LNBTS-239/LNCEL-1
#    enblte.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
#    ...    operation=update    value=${value}    connection=enblte
#    sleep    60s
#
#enb_lte.Connect to eNB via ssl
#    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
#    enblte.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
#    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
#
#Reboot UE for NSA
#    _Prepare Variables    ue_index=${0}
#     csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
#    ...    timeout=120    alias=cpc_${0}
#    _Reboot_UE    connection=cpc_${0}
#    csn.disconnect      connection=cpc_${0}
#
#
#Check X2 Status
#    ${X2linkstatus}    selenium_coam.get_parameter_value    dist_name=MRBTS-10042/NRBTS-10042/LTEENB-1    filter_param=X2C link status
#    Should be equal    ${X2linkstatus}    available
#
#
#Check GNB cell on air
#    [Documentation]  Author: Ding Binmei
#    ...              Description: Check if GNB is in cell on air status
#    [Arguments]    ${connection}=COAM
#    wait until keyword succeeds     2s    1s
#    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#    ...      username=Nemuadmin
#    ...      password=nemuuser
#    ...      name=${connection}
#    COAM Check All Cells Onair
#
#Set parameter
#    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917/NRCELL-1
#    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
#    ...    operation=update    value=${value}    connection=COAM
#    sleep    60s
#
#Modify actA2SgnbRelease
#    [Arguments]    ${actA2SgnbRelease}
#    BuiltIn.Log    Modify actA2SgnbRelease paramter...     console=${True}
#    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-917/NRBTS-917    parameter=actA2SgnbRelease
#    ...    operation=update    value=${actA2SgnbRelease}    connection=COAM
#    [Teardown]    Teardown cOAM session
#
#Modify srb3SupportEnabled
#    [Arguments]    ${srb3SupportEnabled}
#    BuiltIn.Log    Modify srb3SupportEnabled paramter...     console=${True}
#    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-917/NRBTS-917    parameter=srb3SupportEnabled
#    ...    operation=update    value=${srb3SupportEnabled}    connection=COAM
#    [Teardown]    Teardown cOAM session
#
#set a2MeasReleaseSsbRsrp list
#    [Arguments]    ${a2HysteresisReleaseSsbRsrp}    ${a2ThresholdReleaseSsbRsrp}    ${a2TimeToTriggerReleaseSsbRsrp}
#    @{parameter_list}    create list
#    ${parameters}=    create dictionary
#    ...    a2HysteresisReleaseSsbRsrp=${a2HysteresisReleaseSsbRsrp}
#    ...    a2ThresholdReleaseSsbRsrp=${a2ThresholdReleaseSsbRsrp}
#    ...    a2TimeToTriggerReleaseSsbRsrp=${a2TimeToTriggerReleaseSsbRsrp}
#    @{parameter_list}    create list    ${parameters}
#    ${dict}=    create dictionary    parameterName=a2MeasReleaseSsbRsrp
#    ...    operation=update
#    ...    value=@{parameter_list}
#    @{parameters}    create list    ${dict}
#
#    admin_cli.perform_object_recommissioning    dist_name=MRBTS-917/NRBTS-917/NRCELL-1   parameter=@{parameters}    operation=update
#    ...    connection=COAM
#    #Set parameter    dict_name=MRBTS-917/NRBTS-917/NRCELL-1    key=a2MeasReleaseSsbRsrp    value=${a2MeasReleaseSsbRsrp}
#
#Start Capture Classical x2_WS Logs
#    [Arguments]    ${x2logname}    ${ip_addr}=${asik_addr}    ${gnb}=gnb    ${interface}=br0
#    RUN KEYWORD AND IGNORE ERROR    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
#    Start To Capture Wireshark Logs    filename=${x2logname}    connection=${gnb}    interface=${interface}
#
#Start To Capture Wireshark Logs
#    [Arguments]     ${filename}    ${connection}    ${interface}
#    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${filename}    connection=${connection}
#
#gNB connections
#    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=gnb
#    csn.Connect To    hostname=${ip_addr}
#    ...               username=${asik_username}
#    ...               password=${asik_password}
#    ...               alias=${gnb}
#
#Stop and Save Logs
#    [Arguments]    ${x2logname}    ${ip_addr}=${asik_addr}    ${gnb}=gnb
#    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
#    Stop and download Logs    logname=${x2logname}    connection=${gnb}
#
#Stop and download Logs
#    [Arguments]    ${logname}    ${connection}
#    csn.send command    command=killall tcpdump     connection=${connection}
#    sleep    3
#    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}/${logname}   connection=${connection}
#    sleep    3
#
#
#Analysis capture log for case1
#    [Arguments]     ${x2log}
#    cap.read_cap      cap_file=${epc_log_path}/${x2log}
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.eventId == 1
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.a2_Threshold == 0
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.reportOnLeave == 0
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.hysteresis == 0
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.timeToTrigger == 8
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 32
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#
#Analysis X2 Log
#    ${A2_Event_value}    Get value from output pdml files    file_path=${epc_log_path}/${x2logname}
#    ...    command_template=${TSHARK_eventId}    command_to_convert_pdml=${TSHARK_eventId_pdml}
#    ${value1}    set variable    ${A2_Event_value[0]}
#    Should Be True    ${value1} == 1
#
#    ${a2_Threshold_value}    Get value from output pdml files    file_path=${epc_log_path}/${x2logname}
#    ...    command_template=${TSHARK_a2_Threshold}    command_to_convert_pdml=${TSHARK_a2_Threshold_pdml}
#    ${value1}    set variable    ${a2_Threshold_value[0]}
#    Should Be True    ${value1} == 0
#
#    ${hysteresis_value}    Get value from output pdml files    file_path=${epc_log_path}/${x2logname}
#    ...    command_template=${TSHARK_hysteresis}    command_to_convert_pdml=${TSHARK_hysteresis_pdml}
#    ${value1}    set variable    ${hysteresis_value[0]}
#    Should Be True    ${value1} == 0
#
#    ${timeToTrigger_value}    Get value from output pdml files    file_path=${epc_log_path}/${x2logname}
#    ...    command_template=${TSHARK_timeToTrigger}    command_to_convert_pdml=${TSHARK_timeToTrigger_pdml}
#    ${value1}    set variable    ${timeToTrigger_value[0]}
#    Should Be True    ${value1} == 8
#
#    ${SgNBRelease_Required}    Get value from output pdml files    file_path=${epc_log_path}/${x2logname}
#    ...    command_template=${TSHARK_SgNBReleaseRequired}    command_to_convert_pdml=${TSHARK_SgNBReleaseRequired_pdml}
#    should be true    len(${SgNBRelease_Required}) ==1
#
#     ${SgNBReleaseConfirm}    Get value from output pdml files    file_path=${epc_log_path}/${x2logname}
#     ...    command_template=${TSHARK_SgNBReleaseConfirm}    command_to_convert_pdml=${TSHARK_SgNBReleaseConfirm_pdml}
#    should be true    len(${SgNBReleaseConfirm}) ==1
#
#
#Analysis wireshark log for case2
#    cap.read_cap      cap_file=${epc_log_path}${x2logname}
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1
#    ${MeasConfig} =    Catenate    x2ap.X2AP_PDU == 1 && nr-rrc.measObjectToAddModList == 1
#    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${MeasConfig}
#    should be equal    '${status}'    'FAIL'
#    ${a2_check} =    Catenate    x2ap.X2AP_PDU == 1 && nr-rrc.eventId == 1
#    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${a2_check}
#    should be equal    '${status}'    'FAIL'
#
#Analysis capture log for Case3
#    [Arguments]     ${x2log}
#    cap.read_cap      cap_file=${epc_log_path}/${x2log}
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#    ${SgNBAdditionRequestACK_srb3} =  Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#    ...    and nr-rrc.srb_Identity == 3 and nr-rrc.physCellId == 51
#    cap.Check Expression    condition_expression=${SgNBAdditionRequestACK_srb3}
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.eventId == 1
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.a2_Threshold == 0
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.reportOnLeave == 0
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.hysteresis == 0
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.timeToTrigger == 8
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 32
#
##Teardown cOAM session
##    Run Keyword and Ignore Error           coam.teardown        connection=coam_admin
#
#teardown
#    log to console    \n in teardown stage
#    Run Keyword And Ignore Error     Modify actA2SgnbRelease    false
#    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
#    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

