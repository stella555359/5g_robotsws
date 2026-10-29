*** Settings ***
Documentation
...    copyright: Nokia

*** Variables ***
${TMP_FULL_SCF} =    /tmp/scf_747_b2/scfc.xml
${RESTORE_WITH_FULL_COMMISSIONING} =    ${False}

*** Keywords ***
Prepare Testline And Collect Logs
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    Get Scfc File      output_filepath=${TMP_FULL_SCF}
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    Perform Parameter Commissioning    parameter=actETWS    value=true
    Check Radios Availability
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Stop VM Interfaces And Stop Default Logging And Restore Configuration
    Stop Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    Stop Default Processes And Gather Logs And Compress Logs
    Run Keyword If    ${RESTORE_WITH_FULL_COMMISSIONING}    Send Full Commissioning    input_filepath=${TMP_FULL_SCF}

