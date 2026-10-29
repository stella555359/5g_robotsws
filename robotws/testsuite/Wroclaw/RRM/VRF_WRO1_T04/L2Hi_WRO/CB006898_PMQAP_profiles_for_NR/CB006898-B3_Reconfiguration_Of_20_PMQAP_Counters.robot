*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

*** Variables ***
${TRAFFIC_DURATION_SEC_B3}=   60s

*** Keywords ***
CB006898-B3_Reconfiguration_Of_20_PMQAP_Counters
    Register Ue With Default Pdu Session
    Start 10 Mbps Dl And Ul Data Traffic
    Display Uec Statistics
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=10    unit=mbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi
    Deregister Ue    ue_id=1
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Check Pmqap Counters For Dl And Ul

Enable 20PMQAP Counters And Set Interval
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_pminterval_15min.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_add_20_pmqap.json

Remove 5PMQAP Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_remove_5_pmqap.json

Add 5PMQAP Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_add_5_pmqap.json

Start 10 Mbps Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10
    Sleep    ${TRAFFIC_DURATION_SEC_B3}

Display Uec Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
