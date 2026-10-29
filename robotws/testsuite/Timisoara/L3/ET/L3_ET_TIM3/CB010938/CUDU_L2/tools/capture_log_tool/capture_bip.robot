*** Settings ***
Resource    ../../common_setup_teardown.robot

*** Test Cases ***
Capture BIP Log
    Run    rm -rf ${OUTPUT_DIR}/5GBipL2L1_filtering_off*.pcap*
    Start GNB BIP By Admin Method
    Sleep    ${time}
    Stop Gnb BIP By Admin Method    log_path=${OUTPUT_DIR}
    Log To Console    Please Find BIP log In ${OUTPUT_DIR}
