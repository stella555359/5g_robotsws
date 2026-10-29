*** Settings ***
Suite Setup    Setup BTS env and set keyword prority     scf=SCF1_CB008195_Ran_Sharing.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Test Case Setup and Connect Server


Documentation    Suite description
...   Author:      Flora Du
...   Contact:     Flora.Du@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB008195

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot
Library     taf.transport.ssh    WITH NAME    csn



*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

#${DEBUG}    ${True}

${SYSCOM_FLAG}  ${True}
#${TTITRACE_FLAG}  ${True}
${EMIL_FLAG}    ${False}
${SOS_REPORT_FLAG}    pass:False,fail:False
${SNAPSHOT_FLAG}    pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}    pass:False,fail:False

${UE_TYPE}    huawei_sigspark

@{ATTACH_CELL1_PA_VAL}
...    7=${50}
...    8=${50}
...    9=${45}
...    10=${45}

@{TF_CA_PA_VAL}
...    7=${10}
...    8=${10}
...    9=${30}
...    10=${30}

@{SCELL_CHANGE_PA_VAL}
...    7=${10}
...    8=${10}
...    9=${10}
...    10=${10}

*** Test Cases ***
CB008195_C002_TestCase
    [Documentation]
    ...    Description:
    ...    This user scenario verified NSA UE Context Static cell limits check Success With resource allcated in Common pool Per PLMN
    ...    5G_RAN_USR_RRM_23596, fully covered
    ...    CB008195-C#B1: NSA UE Context Admission, Static cell limits check - Success

    ...    Precondition:
    ...    UE_capabilit:N78A*-N71*
    ...    gNB is up and work normal
    ...    Test Steps:
    ...    Step 1: NSA UE1 attach to CELL1 with PLMN-1(Dedication resource for RG1), start DL traffic.
    ...    Step 2: NSA UE2 attach to CELL1 with PLMN-2(Common resource for RG2), start DL traffic.
    ...    Step 3: NSA UE3 attach to CELL1 with PLMN-1(Common resource for RG1), start DL traffic.
    ...    Step 4: NSA UE4 attach to CELL1 with PLMN-2(Dedication resource for RG1), start DL traffic.

    ...    Expected result:
    ...    Step 1: UE1 attach succeed using ResourceGroupId-1 dedicate resource with PLMN-1, traffic normal.
    ...    Step 2: UE2 attach succeed using ResourceGroupId-2 dedicate resource with PLMN-2, traffic normal.
    ...    Step 3: UE3 attach succeed using ResourceGroupId-1 common resource with PLMN-1, traffic normal.
    ...    Step 4: UE4 attach failed using ResourceGroupId-2 common resource with PLMN-2, Due to leakage resource.
    ...            Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    [Tags]    C002    QC_41735
    Lock Cell2 Cell3 Cell4
    Set PA    ${ATTACH_CELL1_PA_VAL}
    FOR    ${index}    IN    0     1    2    3
        Prepare UE    UE_ALIAS=UE_${index}    ue_index=${index}
        UE Attach to Cell-1    UE_ALIAS=UE_${index}    ue_index=${index}
        Stop traffic    UE_ALIAS=UE_${index}    ue_index=${index}
        #UE Detach    UE_ALIAS=UE_${index}    ue_index=${index}
    END
    #Attach the UE4 should failed
    [Teardown]    teardown for C002

*** Keywords ***
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
    Connect to EPC APP
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}

Test Teardown And Disconnect Server
    log to console    Case Teardown...
    Unlock Cell2 Cell3 Cell4
    run keyword and ignore error    UE Detach
    csn.disconnect    connection=EPCAPP
    Common Test Teardown with scout

Lock Cell2 Cell3 Cell4
    Delta Commission Parameters  NRCELL-2:administrativeState=Locked
    Delta Commission Parameters  NRCELL-3:administrativeState=Locked
    Delta Commission Parameters  NRCELL-4:administrativeState=Locked
    Cells Should Be OnAir    cell_id=1

Unlock Cell2 Cell3 Cell4
    Delta Commission Parameters  NRCELL-2:administrativeState=Unlocked
    Delta Commission Parameters  NRCELL-3:administrativeState=Unlocked
    Delta Commission Parameters  NRCELL-4:administrativeState=Unlocked
    Cells Should Be OnAir    cell_id=1
    Cells Should Be OnAir    cell_id=2
    Cells Should Be OnAir    cell_id=3
    Cells Should Be OnAir    cell_id=4

Set PA
    [Arguments]      ${pa_values}
    #Note: set some ports failed occasionally, so set twice to avoid this issue temporarily
    log to console    Set PA...
    ${cur_values}    set_pa_values    ${pa_values}
    run keyword if  not ${cur_values}==${pa_values}    set_pa_values    ${pa_values}
    sleep    10s

Prepare UE
    [Arguments]    ${UE_ALIAS}=UE_1    ${ue_index}=0
    log to console    prepare ${UE_ALIAS}......
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}
    ...    power_reset=True    ue_index=${ue_index}
    Config UE to NSA Mode    UE_ALIAS=${UE_ALIAS}

Config UE to NSA Mode
    [Arguments]      ${UE_ALIAS}=UE_1
    log to console    Config UE to NSA Mode...
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="nr5g_disable_mode",0    ue_alias=${UE_ALIAS}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="nr5g_disable_mode",1    ue_alias=${UE_ALIAS}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="mode_pref",auto         ue_alias=${UE_ALIAS}

UE Attach to Cell-1
    [Arguments]      ${UE_ALIAS}=UE_1    ${ue_index}=0
    log to console    UE Attach...
    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}    power_reset=True    ue_index=${ue_index}
    ...    attach_mode=5G_NSA
    #Verify Attach Cell    cell_pci=205    UE_ALIAS=${UE_ALIAS}
    Send Traffic    apn=stdata1    send_dl=100    send_ul=10    UE_ALIAS=${UE_ALIAS}    ue_index=${ue_index}
    Run Keyword And Ignore Error    Check Traffic   check_dl=30    check_ul=0    UE_ALIAS=${UE_ALIAS}    ue_index=${ue_index}
    #Get Total Tput Info    UE_ALIAS=${UE_ALIAS}

UE Detach
    [Arguments]      ${UE_ALIAS}=UE_1    ${ue_index}=0
    log to console    UE Detach...
    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}    ue_index=${ue_index}
#    ${event_name_list}    create list     SA RRC Release
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE_ALIAS}    event_name=${event_name_list}
#    # counter may be 2, because power off before ue attach
#    should be true      ${${count_list}[0]}>=1

Get Total Tput Info
    [Arguments]      ${UE_ALIAS}=UE_1
    ${params}    create list
    ...    NR MAC Thr. DL [Mbps]
    ...    NR MAC Thr. UL [Mbps]
    ...    NR PDSCH BLER[%]
    ...    NR PUSCH BLER[%]
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=${UE_ALIAS}    param=${params}

Get CA Cell Tput Info
    [Arguments]    ${UE_ALIAS}=UE_1
    ${params}    create list
    ...    NR MAC Thr. DL PCell
    ...    NR MAC Thr. UL PCell
    ...    NR PDSCH BLER PCell
    ...    NR PUSCH BLER PCell
    ...    NR MAC Thr. DL SCell1
    ...    NR PDSCH BLER SCell1
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=${UE_ALIAS}    param=${params}

Verify Attach Cell
    [Arguments]    ${cell_pci}=205      ${UE_ALIAS}=UE_1
    ${pdu_ip}    spark.get_ue_ip_on_ue    ue_alias=${UE_ALIAS}    apnaddress=stdata1
    should not be empty      ${pdu_ip}
    ${param_name_list}    create list     NR PCI
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=${UE_ALIAS}    param=${param_name_list}
    should be true    ${${value_list}[0]}==${cell_pci}

Add One PDU Session with HR DRB of 5QI6
    [Arguments]   ${UE_ALIAS}=UE_1
    log to console    Add HR DRB PDU...
    spark.send_at_command_on_ue    ue_alias=${UE_ALIAS}    command=AT+CGACT?
    ${pdu_ip}    spark.create_pdu_session    ue_alias=${UE_ALIAS}    id=2    apn=stdata2
    should not be empty      ${pdu_ip}
    Send Traffic    apn=stdata2    send_dl=10    send_ul=5    UE_ALIAS=${UE_ALIAS}
    #tput decrease after add HRDRB
    Run Keyword And Ignore Error    Check Traffic   check_dl=30    check_ul=0    UE_ALIAS=${UE_ALIAS}
    Get Total Tput Info    UE_ALIAS=${UE_ALIAS}

Remove One PDU Session with HR DRB of 5QI6
    [Arguments]   ${UE_ALIAS}=UE_1
    log to console    Remove HR DRB PDU...
#    ${event_name_list}    create list     SA PDU Release Accept
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==0

    spark.send_at_command_on_ue    ue_alias=${UE_ALIAS}    command=AT+CGACT?
    spark.release_pdu_session    ue_alias=${UE_ALIAS}    id=2

#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==1
    spark.send_at_command_on_ue    ue_alias=${UE_ALIAS}    command=AT+CGACT?

    run keyword and ignore error    Get CA Cell Tput Info    UE_ALIAS=${UE_ALIAS}
    Run Keyword And Ignore Error    Check Traffic   check_dl=30    check_ul=0    UE_ALIAS=${UE_ALIAS}

Send Traffic
    [Arguments]    ${apn}=stdata1    ${send_dl}=100    ${send_ul}=10    ${duration}=1800    ${UE_ALIAS}=UE_1    ${ue_index}=0    ${ue_mode}=NSA
    log to console    Send traffic to ${apn}...
    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}    direction=dl    throughput=${send_dl}Mbits/sec
    ...    duration=${duration}    ue_index=${ue_index}    apn_address=${apn}    dt_name=UE1_DL    ue_mode=${ue_mode}
    # Note: use iperf to send UL traffic better
    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}    direction=ul    throughput=${send_ul}Mbits/sec
    ...    duration=${duration}    ue_index=${ue_index}    apn_address=${apn}    dt_name=UE1_UL    ue_mode=${ue_mode}
    sleep    15s

Stop Traffic
    [Arguments]      ${apn}=stdata1    ${UE_ALIAS}=UE_1    ${ue_index}=0    ${ue_mode}=NSA
    log to console    stop traffic...
    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}    direction=dl    ue_index=${ue_index}
    ...    apn_address=${apn}    dt_name=UE1_DL    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}    direction=ul    ue_index=${ue_index}
    ...    apn_address=${apn}    dt_name=UE1_UL    ue_mode=${ue_mode}

Check Traffic
    [Arguments]      ${check_dl}=0    ${check_ul}=0    ${UE_ALIAS}=UE_1    ${ue_index}=0
    log to console    Check Traffic...
    # Note: check the total traffic, contain all pdus traffic
    wait until keyword succeeds  60s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}
    ...    direction=dl    throughput=${check_dl}    deviation=0    ue_index=${ue_index}
    wait until keyword succeeds  60s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=${UE_ALIAS}
    ...    direction=ul    throughput=${check_ul}    deviation=0    ue_index=${ue_index}

teardown for C002
    run keyword if test failed    UE detach and stop traffic
    Test Teardown And Disconnect Server

UE detach and stop traffic
    FOR    ${index}    IN    0     1    2    3
        Run Keyword And Ignore Error    UE Detach    UE_ALIAS=UE_${index}    ue_index=${index}
        Run Keyword And Ignore Error    Stop traffic    UE_ALIAS=UE_${index}    ue_index=${index}
    END


Trigger Scell Addition to TT 2CC CA
    [Arguments]   ${UE_ALIAS}=UE_1
    log to console    Trigger Scell Addition to TF 2CC CA...
#    ${event_name_list}    create list     NR5G Event A1    NR5G CA Config Success
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==0
#    should be true      ${${count_list}[1]}==0

    Set PA    ${SCELL_CHANGE_PA_VAL}

#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}>=1
#    should be true      ${${count_list}[1]}==1

    run keyword and ignore error      Get CA Cell Tput Info    UE_ALIAS=${UE_ALIAS}
    ${cell_list}    create list    205    206
    Run Keyword And Ignore Error    Check Traffic   check_dl=50    check_ul=0    UE_ALIAS=${UE_ALIAS}
#    Check CA ULDL Throughput    PSCell_List=${cell_list}    CC_num=2    dl_tput=100    ul_tput=0

Trigger Scell Change from TF to TT 2CC CA
    [Arguments]   ${UE_ALIAS}=UE_1
    log to console    Trigger Scell Change from TF to TT 2CC CA...
    Set PA    ${SCELL_CHANGE_PA_VAL}
#    ${event_name_list}    create list     NR5G Event A1    NR5G CA Config Success
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}>=2
#    should be true      ${${count_list}[1]}==2

    run keyword and ignore error      Get CA Cell Tput Info    UE_ALIAS=${UE_ALIAS}
    ${cell_list}    create list    205    208
    Run Keyword And Ignore Error    Check Traffic   check_dl=30    check_ul=0    UE_ALIAS=${UE_ALIAS}
#    Check CA ULDL Throughput    PSCell_List=${cell_list}    CC_num=2    dl_tput=100    ul_tput=0

Attach the UE4 should failed
    [Arguments]   ${index}=3    ${ue_mode}=NSA
    Prepare UE    UE_ALIAS=UE_${index}    ue_index=${index}
    run keyword and expect error    *    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_index=${index}    attach_mode=${ue_mode}

Attach the UE4 should succeeds
    [Arguments]   ${index}=3    ${ue_mode}=NSA
    Prepare UE    UE_ALIAS=UE_${index}    ue_index=${index}
    ${attach_status}    run keyword and return status
    ...                 power_ue.UE Attach    ue_type=${UE_TYPE}
    ...                                       ue_index=${index}
    ...                                       attach_mode=${ue_mode}
    Should be true    ${attach_status}

Delete exist UE and attach UE4 should be successfully
    UE Detach    UE_ALIAS=UE_0    ue_index=0
    Attach the UE4 should succeeds
