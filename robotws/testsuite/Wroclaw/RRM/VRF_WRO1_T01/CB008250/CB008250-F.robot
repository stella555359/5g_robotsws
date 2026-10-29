*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Resource    CB008250_keywords.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Library     keywords_CB008250.py
Documentation
...    author: Pawel Konieczny
...    maintainer:
...    testline:
...    release:

Suite Setup    Enable Syslog Info Level Prints

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...              cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_SUCI}
    ...       AND    Change Tdd Cells To 50 Mhz
    ...       AND    Disable Actrat1alloc
    ...       AND    Enable Minrccd
    ...       AND    Set Minrcellutilperplmn And Nrg To 5min
    ...       AND    Enable Slice Aware Scheduler
    ...       AND    Enable Plmn Aware Scheduler
    ...       AND    Enable Actslicenumext
    ...       AND    Enable Plmn Spid And Resource Groups And Set Shares To 40 40 10 10
    ...       AND    Disable ActarpbBasedac And Enable Actulcgtype2
    ...       AND    Set Nbr Settings And Admission Conrol
    ...       AND    Set Calibrate Settings For Grand Type 2
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
CB008250-F_Interaction_Of_Plmn_Aware_Gbr_Drb_Amission_with_Configured_Grand_Type_2
    Set Ue Cappa For Ul Grand Type 2
    Attach and Start Data Traffic For 4 Ues Per Plmn1 And Plmn2
    Sleep    ${TRAFFIC_DURATION_SEC}
    Attach Additional Ues For Plmn1 And Plmn2
    Display Ue Statistics
    Wait For Next Full Pm Interval
    Check If Cg Type 2 Pm Counters Are Incremented As Expected

*** Keywords ***
Set Ue Cappa For Ul Grand Type 2
    Add Cg Type 2 Nr Cappa       last_ue_id=16

Attach and Start Data Traffic For 4 Ues Per Plmn1 And Plmn2
    Attach Multiple Ues With Gbr    last_ue_id=8
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25

Attach Additional Ues For Plmn1 And Plmn2
    Attach Multiple Ues With Gbr    first_ue_id=9    last_ue_id=10
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25
    Sleep    ${TRAFFIC_DURATION_SEC}
    Attach Multiple Ues With Gbr    first_ue_id=11    last_ue_id=12
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25
    Sleep    ${TRAFFIC_DURATION_SEC}
    Attach Multiple Ues With Gbr    first_ue_id=13    last_ue_id=14
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=3 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=3 mbps=25
    Sleep    ${TRAFFIC_DURATION_SEC}
    Attach Multiple Ues With Gbr    first_ue_id=15    last_ue_id=16
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=3 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=3 mbps=25

Display Ue Statistics
    Display Qfi stats    ue_id=${1}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${2}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${3}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${4}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${5}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${6}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${7}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${8}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${9}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${10}    qfi_id=1    pdu_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check If Cg Type 2 Pm Counters Are Incremented As Expected
    [Arguments]    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55139C00017
    ...    value=0    local_moid=${localmoid}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55139C00018
    ...    value=0    local_moid=${localmoid}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55166C00005
    ...    value=0    local_moid=${localmoid}    filepath=${PM_COUNTERS}

