*** Settings ***
Suite Setup    Setup BTS env and set keyword prority     scf=SCF1_CB008195_C018.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Test Case Setup and Connect Server
Test Teardown     Test Teardown And Disconnect Server

Documentation    Suite description
...   Author:      Teana Wang
...   Contact:     teana.wang@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB0080195

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot
Library     taf.transport.ssh    WITH NAME    csn

*** Variables ***
${IP_EXP_STRING}    ((25[0-5]\\.|2[0-5]\\d\\.|1\\d+\\.|[1-9]\\d?\\.){3}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d))

@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=3
...    maxNumPucchF1SRPerSlotL1Pool=30
...    maxNumPucchF3PCSIPerSlotL1Pool=30

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

${SYSCOM_FLAG}  ${True}

#${DEBUG}    ${True}
${SOS_REPORT_FLAG}    pass:False,fail:False
${SNAPSHOT_FLAG}    pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}    pass:False,fail:False

${UE_TYPE}    huawei_sigspark
${UE1_IPERF_PORT}     ${tl.ues[0].iperf_details.port}
${UE2_IPERF_PORT}     ${tl.ues[1].iperf_details.port}
${UE3_IPERF_PORT}     ${tl.ues[2].iperf_details.port}
${UE4_IPERF_PORT}     ${tl.ues[3].iperf_details.port}

@{ATTACH_CELL1_PA_VAL}
...    7=${110}
...    8=${110}
...    9=${40}
...    10=${40}

# Wireshark filter
#UE2 attach to cell-4 with PLMN-2 success
# SgNBAdditionRequest
${SgNBAdditionReq_Cell4_PLMN2}    SEPARATOR=
...    x2ap.PLMN_Identity == 64:f0:20 and nr-rrc.physCellId == 208 and x2ap.procedureCode == 27 and x2ap.E_RABs_ToBeAdded_SgNBAddReqList == 1
# SgNBAdditionRequestAcknowledge
${SgNBAdditionReqAck_Cell4}    SEPARATOR=
...    nr-rrc.physCellId == 208 and x2ap.procedureCode == 27 and x2ap.E_RABs_Admitted_ToBeAdded_SgNBAddReqAckList == 1
#UE1 attach to cell-4 with PLMN-1 success
# SgNBAdditionRequest
${SgNBAdditionReq_Cell4_PLMN1}    SEPARATOR=
...    x2ap.PLMN_Identity == 62:f2:30 and nr-rrc.physCellId == 208 and x2ap.procedureCode == 27 and x2ap.E_RABs_ToBeAdded_SgNBAddReqList == 1
#UE4 attach to cell-1 with PLMN-2 failed
# SgNBAdditionRequest
${SgNBAdditionReq_Cell1_PLMN2}    SEPARATOR=
...    x2ap.PLMN_Identity == 64:f0:20 and nr-rrc.physCellId == 205 and x2ap.procedureCode == 27 and x2ap.E_RABs_ToBeAdded_SgNBAddReqList == 1
# SgNBAdditionRequestReject: cause: no-radio-resources-available
${SgNBAdditionReqReject_Cell1}    SEPARATOR=
...    x2ap.procedureCode == 27 and x2ap.radioNetwork == 36
#UE3 attach to cell-1 with PLMN-1 success
# SgNBAdditionRequest
${SgNBAdditionReq_Cell1_PLMN1}    SEPARATOR=
...    x2ap.PLMN_Identity == 62:f2:30 and nr-rrc.physCellId == 205 and x2ap.procedureCode == 27 and x2ap.E_RABs_ToBeAdded_SgNBAddReqList == 1
# SgNBAdditionRequestAcknowledge
${SgNBAdditionReqAck_Cell1}    SEPARATOR=
...    nr-rrc.physCellId == 205 and x2ap.procedureCode == 27 and x2ap.E_RABs_Admitted_ToBeAdded_SgNBAddReqAckList == 1



*** Test Cases ***
CB008195-ET-C0018_Verify_NSA_UE_Cont_multi-cell_pooled_res_limits_that_not_reach_minQuota_and_no_unused_unreserved_pooled_resources
    [Documentation]
    ...    Precondition:
    ...     UE1: PLMN-1:26203
    ...     UE2: PLMN-2:46002
    ...     UE3: PLMN-1:26203
    ...     UE4: PLMN-2:46002
    ...     Config:
    ...        maxNumOfUserL2Pool=3
    ...    Test steps:
    ...     step1: NSA UE1/UE2 attach to CELL4 with PLMN-2, Start traffic;
    ...     step2: NSA UE3 attach to cell1 with PLMN-1, Start traffic;
    ...     step3: NSA UE4 attach to cell1 with PLMN-2 
    ...    Expected result:
    ...     step1: UE1 success in ResourceGroupId-1 using last poolremaincommon with PLMN-1(now poolremaincommon=3-used-dedicated=0);
    ...            UE2 success in ResourceGroupId-2 using common resouce with PLMN-2(now poolremaincommon=3-used-dedicated=1);
    ...     step2: UE3 attach to cell-1 success in ResourceGroupId-1 and using dedicated resouce with PLMN-1;
    ...     step3: UE4 attach failed since no poolremaincommon anymore because maxNumOfUserL2Pool=3;
	...            Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    [Tags]    C018    QC_57054
    Set PA    ${ATTACH_CELL1_PA_VAL}
    Lock Cell1
    Prepare All UEs and detach all UEs
    Start To Capture Wireshark Log    C018
    UE1 Attach to Cell4 with PLMN1 Success     ue_index=0
    UE2 Attach to Cell4 with PLMN2 Success     ue_index=1
    Unlock Cell1
    UE3 Attach to Cell1 with PLMN1 Success     ue_index=2
    UE4 Attach to Cell1 with PLMN2 Failed      ue_index=3
    Stop Capture Wireshark Log
    #Check Wireshark Log
    [Teardown]      C018 Teardown


*** Keywords ***
Connect to Control PC
    [Arguments]    ${cpc_ip}=${UE_PC_IP}
    ...    ${cpc_usrname}=${UE_PC_USERNAME}
    ...    ${cpc_passwd}=${UE_PC_PASSWD}
    ${ret}    Wait Until Keyword Succeeds    5min    20s
    ...   csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=cpc_0
    should be true     ${ret}

Connect to EPC APP
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    Log to console    Connect to EPC APP...
    Wait Until Keyword Succeeds    2min    20s    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=EPCAPP

Test Case Setup and Connect Server
    Common Test Setup And Start To Capture Logs
#    Connect to Control PC
    Connect to EPC APP
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}

Test Teardown And Disconnect Server
    log to console    Case Teardown...
#    run keyword and ignore error    UE Detach
#    csn.disconnect    connection=cpc_0
    csn.disconnect    connection=EPCAPP
    Common Test Teardown with scout

C018 Teardown
    Release UEs
    UnLock Cell1
    Test Teardown And Disconnect Server

Lock Cell1
    Delta Commission Parameters  NRCELL-1:administrativeState=Locked
    Cells Should Be OnAir    cell_id=2
    Cells Should Be OnAir    cell_id=3
    Cells Should Be OnAir    cell_id=4

UnLock Cell1
    Delta Commission Parameters  NRCELL-1:administrativeState=Unlocked
    Cells Should Be OnAir

Set PA
    [Arguments]      ${pa_values}
    #Note: set some ports failed occasionally, so set twice to avoid this issue temporarily
    log to console    Set PA...
    ${cur_values}    set_pa_values    ${pa_values}
    run keyword if  not ${cur_values}==${pa_values}    set_pa_values    ${pa_values}
    sleep    5s

Prepare All UEs and detach all UEs
    [Documentation]    config all UEs to NSA mode, and release all UEs, then start test
    FOR    ${ue_index}    IN RANGE    0    4
        log to console    prepare UE ${ue_index}...
        power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}     ue_index=${ue_index}
        ...    power_reset=True     detach_request=True
		run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}
    END

Prepare UE
    [Arguments]      ${ue_index}=0
    log to console    prepare UE ${ue_index}...
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}     ue_index=${ue_index}
    ...    power_reset=True
    Config UE to NSA Mode    ue_index=${ue_index}

Config UE to NSA Mode
    [Arguments]      ${ue_index}=0
    log to console    Config UE ${ue_index} to NSA Mode...
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="nr5g_disable_mode",0    ue_alias=UE_${ue_index}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="nr5g_disable_mode",1    ue_alias=UE_${ue_index}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="mode_pref",auto    ue_alias=UE_${ue_index}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="ue_capability_band"    ue_alias=UE_${ue_index}

Release UEs
    FOR    ${index}    IN RANGE    0    4
        log to console    UE ${index} Detach...
        run keyword and ignore error    Stop traffic    ue_mode=NSA    ue_index=${index}    apn=stdata1
        run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_alias=UE_${index}
    END

Verify Attach Status
    [Arguments]    ${cell_pci}=205    ${ue_index}=0
    spark.send_at_command_on_ue     command=AT+CGDCONT?    ue_alias=UE_${ue_index}
    spark.send_at_command_on_ue     command=AT+CGACT?    ue_alias=UE_${ue_index}
    Check UE IMSI    ${ue_index}
    Check UE IP    ${ue_index}
    Check NR PCI    ${ue_index}    ${cell_pci}

Check UE IMSI
    [Arguments]    ${ue_index}=${0}
    ${ret}    spark.send_at_command_on_ue     command=AT+CIMI    ue_alias=UE_${ue_index}
#    ${imsi_list}    String.Get Regexp Matches    ${ret}    (\\d+)
#    Should Be True    ${imsi_list[0]}==${tl.ues[${ue_index}].imsi}

Check NR PCI
    [Arguments]    ${ue_index}=${0}    ${cell_pci}=205
    ${param_name_list}    create list     NR PCI
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=UE_${ue_index}    param=${param_name_list}
    Should Be True    ${value_list[0]}==${cell_pci}

Check UE IP
    [Arguments]    ${ue_index}=${0}
    ${UE_ip}    Run Keyword And Ignore Error    spark.get_ue_ip_on_ue    ue_mode=NSA    ue_alias=UE_${ue_index}    apnaddress=stdata1
#    Should Not Be Empty    ${UE_ip}
#    ${ret}    spark.send_at_command_on_ue     command=AT+CGPADDR=1    ue_alias=UE_${ue_index}
#    ${UE_ips}    String.Get Regexp Matches    ${ret}    1,"(\\d+\.\\d+\.\\d+\.\\d+)",    1
	

Send Traffic
    [Arguments]       ${ue_mode}=NSA    ${ue_index}=0    ${apn}=stdata1    ${send_dl}=35    ${send_ul}=10
    ...    ${duration}=1800
    log to console    UE ${ue_index} send traffic to ${apn}...
    power_ue.Start traffic    ue_mode=${ue_mode}    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    direction=dl    throughput=${send_dl}Mbits/sec
    ...    duration=${duration}    ue_index=${ue_index}    apn_address=${apn}    dt_name=UE${ue_index}_DL
    power_ue.Start traffic    ue_mode=${ue_mode}    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    direction=ul    throughput=${send_ul}Mbits/sec
    ...    duration=${duration}    ue_index=${ue_index}    apn_address=${apn}    dt_name=UE${ue_index}_UL
    sleep    15s

Stop Traffic
    [Arguments]      ${ue_mode}=NSA    ${ue_index}=0    ${apn}=stdata1
    log to console    UE ${ue_index} stop traffic...
    power_ue.Stop traffic    ue_mode=${ue_mode}    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    direction=dl    ue_index=${ue_index}
    ...    apn_address=${apn}    dt_name=UE_${ue_index}_DL
    power_ue.Stop traffic    ue_mode=${ue_mode}    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    direction=ul    ue_index=${ue_index}
    ...    apn_address=${apn}    dt_name=UE_${ue_index}_UL

Check Traffic
    [Arguments]      ${ue_index}=0    ${check_dl}=30    ${check_ul}=0
    log to console    UE ${ue_index} Check Traffic...
    wait until keyword succeeds  30s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}
    ...    direction=dl    throughput=${check_dl}    deviation=0
    wait until keyword succeeds  30s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index} 
    ...    direction=ul    throughput=${check_ul}    deviation=0

UE1 Attach to Cell4 with PLMN1 Success
    [Arguments]      ${ue_index}=0
    log to console    UE ${ue_index} Attach...
	power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}     ue_index=${ue_index}
    #power_ue.UE Attach    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    ue_index=${ue_index}    attach_mode=5G_NSA    power_reset=True
	Config UE to NSA Mode
	spark.send_at_command_on_ue     command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
	wait until keyword succeeds    60s    2s    Check NR PCI    ue_index=${ue_index}    cell_pci=208
    #Verify Attach Status    cell_pci=208    ue_index=${ue_index}
    Send Traffic    ue_index=${ue_index}    apn=stdata1    send_dl=30    send_ul=5
    run keyword and ignore error    Check Traffic   ue_index=${ue_index}    check_dl=25    check_ul=4

UE2 Attach to Cell4 with PLMN2 Success
    [Arguments]      ${ue_index}=0
    log to console    UE ${ue_index} Attach...
	power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}     ue_index=${ue_index}
    #power_ue.UE Attach    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    ue_index=${ue_index}    attach_mode=5G_NSA    power_reset=True
	Config UE to NSA Mode
	spark.send_at_command_on_ue     command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
    wait until keyword succeeds    60s    2s    Check NR PCI    ue_index=${ue_index}    cell_pci=208
	#Verify Attach Status    cell_pci=208    ue_index=${ue_index}
    Send Traffic    ue_index=${ue_index}    apn=stdata1    send_dl=30    send_ul=5
    run keyword and ignore error    Check Traffic   ue_index=${ue_index}    check_dl=25    check_ul=4

UE4 Attach to Cell1 with PLMN2 Failed
    [Arguments]      ${ue_index}=0
    log to console    UE ${ue_index} Attach...
	power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}     ue_index=${ue_index}
    #power_ue.UE Attach    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    ue_index=${ue_index}
    #...    attach_mode=5G_NSA    power_reset=True
	Config UE to NSA Mode
	spark.send_at_command_on_ue     command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
	sleep    20s
	run keyword and expect error    *    spark.send_at_command_on_ue     command=AT+CGACT?    ue_alias=UE_${ue_index}
    #Verify Attach Status    ue_index=${ue_index}   
    ${event_name_list}    create list     NR5G Cell Add Success
    ${count_list}    spark.get_event_count_on_ue    index=${ue_index}    ue_alias=UE_${ue_index}    event_name=${event_name_list}
    should be true      ${${count_list}[0]}==0

UE3 Attach to Cell1 with PLMN1 Success
    [Arguments]      ${ue_index}=0
    log to console    UE ${ue_index} Attach...
	power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}     ue_index=${ue_index}
    #power_ue.UE Attach    ue_type=${UE_TYPE}    ue_alias=UE_${ue_index}    ue_index=${ue_index}    attach_mode=5G_NSA    power_reset=True
	Config UE to NSA Mode
	spark.send_at_command_on_ue     command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
	wait until keyword succeeds    60s    2s    Check NR PCI    ue_index=${ue_index}    cell_pci=205
	#Verify Attach Status    cell_pci=205    ue_index=${ue_index}  
    Send Traffic    ue_index=${ue_index}    apn=stdata1    send_dl=30    send_ul=5
    run keyword and ignore error    Check Traffic   ue_index=${ue_index}    check_dl=0    check_ul=0

Check Wireshark Log
    log to console    Check Wireshark Log...
#    ${Count}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReq_Cell4_PLMN2}
#    Should Be True    ${Count}==1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReq_Cell4_PLMN2} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReqAck_Cell4} @2
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReq_Cell4_PLMN1} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReq_Cell1_PLMN2} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReqReject_Cell1} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReq_Cell1_PLMN1} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C018.pcap    ${SgNBAdditionReqAck_Cell1} @1
