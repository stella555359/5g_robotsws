*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 23R3

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...         AND    Enable Tput Counters

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Enable PMQAP Counters
    ...       AND    Resources Usage At Test Begining
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Resources Usage At Test End
    ...       AND    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
CB006898-B1_PDCP_And_RLC_PMQAP_Counters_With_SA_UE
    Register Ue With Default Pdu Session
    Start Dl And Ul Data Traffic
    Display Ue Statistics
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=10    unit=mbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi
    Check Pmqap Counters For Dl And Ul
    Deregister Ue    ue_id=1

*** Keywords ***
Start Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10
    Sleep    ${TRAFFIC_DURATION_SEC}

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
