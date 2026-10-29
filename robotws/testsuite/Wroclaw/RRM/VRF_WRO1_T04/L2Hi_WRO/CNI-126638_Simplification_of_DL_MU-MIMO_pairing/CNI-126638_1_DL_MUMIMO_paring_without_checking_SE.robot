*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Resource    keywords_CNI126638.robot

Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release:24R3

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Get and Update BSR File
    ...       AND    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_1xAEHC_AP_LO.xml
    ...       AND    With Gnb Configuration    commissioning=full_scf_1cell_16DL_8UL_MUMIMO_AP_LO_GMC.xml
    ...       AND    Wait for gNB Configured state
    ...       AND    Disable Uplane Ciphering
    ...       AND    Reach Onair    lua_cfg=${CURDIR}/config/1c_TDD_n41_MUMIMO_AP_LO.lua
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Prepare Testmode For Ue Position

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   15s

*** Test Cases ***
CNI-126638_1_DL_MUMIMO_paring_without_checking_dlMuMimoSpectralEffThd
    Activate Testmode For Ue Position
    Attach Multiple Ues
    Change RI to 1
    Start Udp Traffic 450Mbps In DL For All Ues
    Check Data Traffic
    Collect L2PS TTI Trace      directory_name=1_with_rank_1_and_SE_20
    Collect Pm Counters
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_dlMuMimoSpectralEffThd_0.json
    Check Data Traffic
    Collect L2PS TTI Trace      directory_name=2_with_rank_1_and_SE_0
    Collect Pm Counters



