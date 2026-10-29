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
[1]CB008195-SR-C013_Verify Successful NSA UE Cont m-cell pooled res limits check that reach minQ and there has unused and unres m-cell p res
    [Documentation]
    ...    Precondition:
    ...     UE1: PLMN-1:26203
    ...     UE2: PLMN-1:26203
    ...     UE3: PLMN-2:310260
    ...     UE4: PLMN-2:310260
    ...    Test Steps:
    ...    Step 1: NSA UE3, UE4 attach to CELL311 with PLMN-2 to occupy ResourceGroupId-1 common resources.
    ...    Expected Result: UE attach successfully using ResourceGroupId-1 common resource with PLMN-2.
    ...    Step 2: NSA UE1 attach to CELL302 with PLMN-1 to occupy ResourceGroupId-2 dedicated resources.
    ...    Expected Result: UE attach successfully using ResourceGroupId-2 dedicated resource with PLMN-1,
    ...    and  left pool resources is 0.
    ...    Step 3: start DL traffic for UE1
    ...    Expected Result: Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...    Step 4: NSA UE2 attach to CELL302 with PLMN-1.
    ...    Expected Result: UE attach failed due to no pool resource left.
    ...    Step 7: Release NSA UE4 to release ResourceGroupId-1 common resource.
    ...    Expected Result: NSA UE4 release successsfully.
    ...    Step 8: NSA UE2 attach to CELL302 with PLMN-1.
    ...    Expected Result: UE attach successfully using ResourceGroup-2 common resource with PLMN-1(minQuota is reached by UE2).
    ...    Step 9: Also check reoucegroup relevant counters.
    [Tags]    C013    QC_59857
    OnlineParamChange    ${OnlineParamChange_extendinactivitytimer}
    OnlineParamChange    ${OnlineParamChange_PreconC013}
#    Clear Counter Files    wait=${True}
#    Lock NRCELL313and312
#    UE3 ENDC to NRCELL-311 with PLMN2
#    UE4 ENDC to NRCELL-311 with PLMN2
#    UE1 ENDC to NRCELL-302 with PLMN1
#    UE2 ENDC to NRCELL-302 with PLMN1 Failed
#    Detach UE4 and Stop traffic
#    UE2 ENDC to NRCELL-302 with PLMN1
#    Check Counters    ${CELL_COUNTER}
#    log    all test steps finished    console=True
#    [Teardown]    Run Keywords    Stop UL And DL traffic all UES
#    ...                           Detach all UEs
#    ...                           UnLock NRCELL313and312 and restore scf
#    ...                           Common Test Teardown And Stop Capture Logs


*** Keywords ***
UE3 ENDC to NRCELL-311 with PLMN2
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=21    value=20
    adjust_pa_for_cell    cell_id=311    value=20
    sleep    3s
    Prepare and attach UE    ue_id=3    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=3
#    Start UL And DL traffic    ue_id=3    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    120s    10s    Check Traffic    ue_id=3    check_dl=50    check_ul=1

UE4 ENDC to NRCELL-311 with PLMN2
    Prepare and attach UE    ue_id=4    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=4
#    Start UL And DL traffic    ue_id=4    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    180s    10s    Check Traffic    ue_id=1    check_dl=50    check_ul=1

UE1 ENDC to NRCELL-302 with PLMN1
    adjust_pa_for_cell    cell_id=302    value=10
    sleep    3s
    Prepare and attach UE    ue_id=1    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=1    cell_NRpci=571    cell_LTEpci=160    NR Center ARFCN DL=528000
#    Start UL And DL traffic    ue_id=1    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    60s    10s    Check Traffic    ue_id=4    check_dl=50    check_ul=1

UE2 ENDC to NRCELL-302 with PLMN1
    Prepare and attach UE    ue_id=2    attach_mode=5G_NSA    apn=dxdata1
    Check NSA PCI    ue_id=2    cell_NRpci=571    cell_LTEpci=160    NR Center ARFCN DL=528000
#    Start UL And DL traffic    ue_id=2    send_traffic_ul=1M    send_traffic_dl=50M    ue_mode=5G_NSA    send_duration=7200    apn_address=dxdata1
#    Wait Until Keyword Succeeds    60s    10s    Check Traffic    ue_id=1    check_dl=50    check_ul=1


UE2 ENDC to NRCELL-302 with PLMN1 Failed
    [Arguments]      ${ue_id}=2
    log to console    UE ${ue_id} Attach...
	Config UE to NSA Mode
	sleep    3s
	power_ue.UE Attach    ue_type=huawei_sigspark    attach_mode=NSA    ue_index=${${ue_id}-1}
    ${event_name_list}    create list     NR5G Cell Add Success
    ${count_list}    spark.get_event_count_on_ue    index=${${ue_id}-1}    ue_alias=UE_${${ue_id}-1}    event_name=${event_name_list}
    should be true      ${${count_list}[0]}==0

Config UE to NSA Mode
    [Arguments]      ${ue_id}=2    ${apn}=dxdata1
    log to console    Config UE ${ue_id} to NSA Mode...
    power_ue.Prepare UE    ue_type=huawei_sigspark    ue_alias=UE_${${ue_id}-1}     ue_index=${${ue_id}-1}
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}
    Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}
    Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}

Detach UE4 and Stop traffic
    Detach UE    ue_id=2
    Run Keyword And Ignore Error    Stop UL And DL traffic    ue_id=4    apn_address=dxdata1
    Detach UE    ue_id=4
    sleep    3s


Detach all UEs
    log to console    detach all UEs
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

Lock NRCELL313and312
    Delta Commission Parameters  NRCELL-313:administrativeState=Locked
    Delta Commission Parameters  NRCELL-312:administrativeState=Locked
    Cells Should Be OnAir    cell_id=311
    Cells Should Be OnAir    cell_id=302
    wait until keyword succeeds  60s    10s    Object Should Exist    MRBTS-2002/NRBTS-2002/LTEENB-0:x2LinkStatus=available

UnLock NRCELL313and312 and restore scf
    Delta Commission Parameters  NRCELL-313:administrativeState=Unlocked
    Delta Commission Parameters  NRCELL-312:administrativeState=Unlocked
    OnlineParamChange    ${OnlineParamChange_RestoreC013}
    Cells Should Be OnAir
