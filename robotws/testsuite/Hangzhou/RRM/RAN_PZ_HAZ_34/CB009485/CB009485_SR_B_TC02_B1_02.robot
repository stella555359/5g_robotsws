*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env    scf=SCFC_1_TMO_GMC_IWK.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-7_5_UTE5G402T2404
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
${EMIL_FLAG}    False
@{FAULTS_EXCLUDED_CHECKING}    8000    62003    62001    7306    7308    7107    7311    7307
${QNW_CELL_1}    410,520590,30,41
${QNW_CELL_2}    411,504270,30,41
${mba_ueReleaseRecord}    (nsetapx.traceActivationType == 0) && (nsetapx.CuVendorExtensionRecordDataType == 0) && (nsetapx.reason == 0)
${sba_ueReleaseRecord}    (nsetapx.traceActivationType == 1) && (nsetapx.CuVendorExtensionRecordDataType == 0) && (nsetapx.reason == 0)
@{ueReleaseRecord}    ueReleaseRecord/trigger=gNB .*
...                   ueReleaseRecord/reason=ueInactivity .*
...                   ueReleaseRecord/ueCtxReleaseReqSendTime/seconds=.*
...                   ueReleaseRecord/ueCtxReleaseReqSendTime/useconds=.*
...                   ueReleaseRecord/ueCtxReleaseCmdRcvTime/seconds=.*
...                   ueReleaseRecord/ueCtxReleaseCmdRcvTime/useconds=.*
...                   ueReleaseRecord/ueCtxReleaseCmplSendTime/seconds=.*
...                   ueReleaseRecord/ueCtxReleaseCmplSendTime/useconds=.*
...                   ueReleaseRecord/rrcReleaseSendTime/seconds=.*
...                   ueReleaseRecord/rrcReleaseSendTime/useconds=.*

*** Test Cases ***
CB009485_SR_B_TC02_B1_02_Verify gNB-CU UE Release Trace Record for transition from RRC-CONNECTED to RRC-IDLE triggered by UE Inactivity
    Block NRCell10
    Block NRCell11
    Block NRCell12
    Block NRCell13
    adjust pa all ports max value
    Start TCE    ${TCE_PORT}

    adjust_pa_for_cell    cell_id=1    value=30
    start to capture wireshark log    tag=ueInactivity
    prepare and attach UE with CGACT    ue_id=1    get_spark_license=${True}    qnwlock=${QNW_CELL_1}
    Sleep    5s
    prepare and attach UE with CGACT    ue_id=2    get_spark_license=${True}    qnwlock=${QNW_CELL_2}
    Sleep    45s
    download and check wireshark fields    tag=ueInactivity
    ...                                    filter=${mba_ueReleaseRecord}
    ...                                    check_fields=${ueReleaseRecord}

    [Teardown]    Run Keywords    Detach All UEs
    ...                           Unblock NRCell10
    ...                           Unblock NRCell11
    ...                           Unblock NRCell12
    ...                           Unblock NRCell13
    ...                           Common Test Teardown And Stop Capture Logs

*** Keywords ***
download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${decode_filter}=tcp.port==49100    ${packet_num}=-1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${decode_filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=${packet_num}

Prepare and attach UE with CGACT
    [Documentation]    this keyword includes prepare ue and attach ue. For single UE with 2 APN, suggest to use this keyword.
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${get_spark_license}=${true}    ${apn}=mdrb.nokia.com    ${qnwlock}=${QNW_CELL_1}
    Prepare UEs    ue_ids=${ue_id}    get_spark_license=${get_spark_license}
    run keyword and ignore error    start to capture gnb bip log    attach_ue${ue_id}
    Attach UE with CGACT    ${ue_id}    ${attach_mode}     ${apn}    ${qnwlock}
    [Teardown]    run keyword and ignore error    stop to capture gnb bip log    attach_ue${ue_id}

Attach UE with CGACT
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com    ${qnwlock}=${QNW_CELL_1}    ${retry_times}=6
    run keyword and ignore error    Execute AT Command    AT+QRNRU=1    ${ue_id}
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    Run Keyword If    '${attach_mode}' == '5G_SA'     Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",2    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",NR5G    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '5G_NSA'    Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '4G'       Execute AT Command    AT+QNWPREFCFG="mode_pref",LTE    ue_id=${ue_id}
    ...    ELSE    Fail    not support attach_mode=${attach_mode}
    Execute AT Command    AT+QNWLOCK="common/5g",0    ue_id=${ue_id}
    Execute AT Command    AT+QNWLOCK="common/5g",${qnwlock}    ue_id=${ue_id}
    wait until keyword succeeds    ${retry_times}x    10s    _Attach For Once with CGACT    ${ue_id}    ${attach_mode}    ${apn}

_Attach For Once with CGACT
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
    Execute AT Command    AT+CFUN=1,1   ${ue_id}
    Sleep    60s
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    run keyword and ignore error    Execute AT Command    at+cgact=1,1    ue_id=${ue_id}
    Sleep    2s
    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    ${apn}    Remove String    ${apn}    .
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

Detach All UEs
    Run Keyword And Ignore Error    Execute AT Command    AT+QNWLOCK="common/5g",0    ue_id=1
    Run Keyword And Ignore Error    Detach UE    ue_id=1
    Run Keyword And Ignore Error    Execute AT Command    AT+QNWLOCK="common/5g",0    ue_id=2
    Run Keyword And Ignore Error    Detach UE    ue_id=2
