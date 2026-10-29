*** Settings ***
Documentation
...    author: Zhou Lingyan
...    contact: lingyan.zhou@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-7_5_UTE5G402T2500
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot



*** Variables ***
${EMIL_FLAG}    False
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}    8150

*** Test Cases ***
CB008195-SR-C018_Verify_NSA_UE_Cont_multi-cell_pooled_res_limits_that_not_reach_minQuota_and_no_unused_unreserved_pooled_resources
    [Documentation]
    ...    Precondition:
    ...     UE1: PLMN-1:26203
    ...     UE2: PLMN-1:26203
    ...     UE3: PLMN-2:310260
    ...     UE4: PLMN-2:310260
    ...     Config:
    ...        maxNumOfUserL2Pool=3
    ...    Test steps:
    ...     step1: NSA UE3 attach to CELL311 with PLMN-2, Start traffic;
    ...     step2: NSA UE1 attach to CELL311 with PLMN-1, Start traffic;
    ...     step3: NSA UE4 attach to cell302 with PLMN-1, Start traffic;
    ...     step4: NSA UE2 attach to cell302 with PLMN-2
    ...    Expected result:
    ...    step1: UE3 success in ResourceGroupId-1 using last poolremaincommon with PLMN-1(now poolremaincommon=3-used-dedicated=0);
    ...            UE1 success in ResourceGroupId-2 using common resouce with PLMN-2(now poolremaincommon=3-used-dedicated=1);
    ...     step2: UE4 attach to cell-1 success in ResourceGroupId-1 and using dedicated resouce with PLMN-1;
    ...     step3: UE2 attach failed since no poolremaincommon anymore because maxNumOfUserL2Pool=3;
	...            Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    [Tags]    C018    QC_57054
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=21    value=20
    adjust_pa_for_cell    cell_id=311    value=15
    Prepare UEs    ue_ids=1,2,3,4
    UE3 ENDC to NRCELL-311 with PLMN2
    UE1 ENDC to NRCELL-311 with PLMN1
    adjust_pa_for_cell    cell_id=302    value=10
    UE4 ENDC to NRCELL-302 with PLMN2
    UE2 ENDC to NRCELL-302 with PLMN1 Failed
    [Teardown]    Run Keywords    Detach all UEs
    ...                           Common Test Teardown And Stop Capture Logs


*** Keywords ***
Perform Steps After Onair
    OnlineParamChange    ${OnlineParamChange_extendinactivitytimer}
    OnlineParamChange    ${OnlineParamChange_PreconC018}
    Lock NRCELLs Not Used

UE3 ENDC to NRCELL-311 with PLMN2
#    adjust_pa_all_ports_max_value
#    adjust_pa_for_cell    cell_id=21    value=20
#    adjust_pa_for_cell    cell_id=311    value=15
#    sleep    3s
    attach UE    ue_id=3    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=3
#    Start UL And DL traffic    ue_id=3    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA
#     ...    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    120s    10s    Check Traffic    ue_id=3    check_dl=50    check_ul=1

UE1 ENDC to NRCELL-311 with PLMN1
    attach UE    ue_id=1    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=1
#    Start UL And DL traffic    ue_id=1    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA
#     ...    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    180s    10s    Check Traffic    ue_id=1    check_dl=50    check_ul=1

UE4 ENDC to NRCELL-302 with PLMN2
#    adjust_pa_for_cell    cell_id=302    value=10
#    sleep    3s
    attach UE    ue_id=4    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=4    cell_NRpci=571    cell_LTEpci=160    NR Center ARFCN DL=528000
#    Start UL And DL traffic    ue_id=4    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA
#    ...    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    60s    10s    Check Traffic    ue_id=4    check_dl=50    check_ul=1


UE2 ENDC to NRCELL-302 with PLMN1 Failed
    [Arguments]      ${ue_id}=2
#    log to console    UE ${ue_id} Attach...
#	Config UE to NSA Mode
#	sleep    3s
#	power_ue.UE Attach    ue_type=huawei_sigspark    attach_mode=NSA    ue_index=${${ue_id}-1}
#    ${event_name_list}    create list     NR5G Cell Add Success
#    ${count_list}    spark.get_event_count_on_ue    index=${${ue_id}-1}    ue_alias=UE_${${ue_id}-1}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==0
    Attach UE Should Fail    ${ue_id}    5G_NSA    apn=dxdata1

Config UE to NSA Mode
    [Arguments]      ${ue_id}=2    ${apn}=dxdata1
    log to console    Config UE ${ue_id} to NSA Mode...
#    power_ue.Prepare UE    ue_type=huawei_sigspark    ue_alias=UE_${${ue_id}-1}     ue_index=${${ue_id}-1}
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}
    Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}
    Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}

Detach all UEs
#    log to console    detach all UEs
	Run Keyword And Ignore Error    Detach UE    ue_id=3
    Run Keyword And Ignore Error    Detach UE    ue_id=1
    Run Keyword And Ignore Error    Detach UE    ue_id=4
    Run Keyword And Ignore Error    Detach UE    ue_id=2

Stop UL And DL traffic all UES
    log to console    Stop UL and DL traffics
	Stop UL And DL traffic    ue_id=3    apn_address=dxdata1
	Stop UL And DL traffic    ue_id=1    apn_address=dxdata1
	Stop UL And DL traffic    ue_id=4    apn_address=dxdata1


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Check Traffic
    [Arguments]      ${ue_id}=3    ${check_dl}=30    ${check_ul}=0
    log to console    UE ${ue_id} Check Traffic...
    wait until keyword succeeds  30s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=UE_${${ue_id}-1}
    ...    direction=dl    throughput=${check_dl}    deviation=0
    wait until keyword succeeds  30s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=UE_${${ue_id}-1}
    ...    direction=ul    throughput=${check_ul}    deviation=0

Check NSA PCI
    [Arguments]    ${ue_id}=3    ${params}=NR PCI    ${cell_NRpci}=672    ${cell_LTEpci}=160    ${NR Center ARFCN DL}=509058
    ${params}    create list    NR PCI    LTE PCI    NR Center ARFCN DL
    ${value_list}    Get Params Value From Spark    ue_id=${ue_id}    params=${params}
    Should Be True    ${value_list[0]}==${cell_NRpci}
    Run Keyword And Ignore Error    Should Be True    ${value_list[1]}==${cell_LTEpci}
    Should Be True    ${value_list[2]}==${NR Center ARFCN DL}

Lock NRCELLs Not Used
    ${delta}    Create List    NRCELL-301:administrativeState=Locked
    ...                        NRCELL-312:administrativeState=Locked
    ...                        NRCELL-303:administrativeState=Locked
    ...                        NRCELL-313:administrativeState=Locked
    ...                        NRCELL-22:administrativeState=Locked
    ...                        NRCELL-23:administrativeState=Locked
    ...                        NRCELL-1:administrativeState=Locked
    ...                        NRCELL-2:administrativeState=Locked
    ...                        NRCELL-3:administrativeState=Locked
    Delta Commission Parameters  ${delta}
    Cells Should Be OnAir    cell_id=311
    Cells Should Be OnAir    cell_id=302
    Object Should Exist    MRBTS-2002/NRBTS-2002/LTEENB-0:x2LinkStatus=available
