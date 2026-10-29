*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CB008828.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Variables     CB008828_variables.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 24R2

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Enable Actslicenumext
    ...       AND    Enable 25 Snssai Objects
    ...       AND    Configure Additional Slices In Cfg

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs
Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout


*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
CB008828_Check_Pdcp_Sdu_Data_Pm_Counters
    Register Ue With Default Pdu Session
    Start Data Traffic 20Mbps In Dl Ul
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check If Expected Throughout Is Reached
    Verify That Pdcp Sdu Data Pm Counters Werent Updated When CB008828 Is Enabled
    Deregister Ue    ue_id=1

*** Keywords ***
Start Data Traffic 20Mbps In Dl Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=20
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=20

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check If Expected Throughout Is Reached
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=20    unit=mbps    margin=0.2    direction=bi

Verify That Pdcp Sdu Data Pm Counters Werent Updated When CB008828 Is Enabled
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00001
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00002
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00003
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00004
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00005
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00006
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Pm Counter Does Not Exist    counter_id=M55328C00007
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}


