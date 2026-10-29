*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Resource    keywords_CNI126638.robot
Library     ../resources/common_keywords.py

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
CNI-126638_3_DL_MUMIMO_paring_with_actExcludeLowBufferUser
    Activate Testmode For Ue Position
    Attach Multiple Ues
    Start Udp Full Buffer Traffic For 3 Ues And Small For Ue4
    Check Data Traffic
    Collect L2PS TTI Trace      directory_name=1_with_rank_4_and_actExcludeLowBufferUser_0
    Collect Pm Counters
    Collect snapshot from gNB    target_dir=${OUTPUTDIR}/1_with_rank_4_and_actExcludeLowBufferUser_0
    Stop Traffic For All Ues
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_actExcludeLowBufferUser_true.json
    Start Udp Full Buffer Traffic For 3 Ues And Small For Ue4
    Collect L2PS TTI Trace      directory_name=2_with_rank_4_and_actExcludeLowBufferUser_1
    Collect snapshot from gNB    target_dir=${OUTPUTDIR}/2_with_rank_4_and_actExcludeLowBufferUser_1
    Collect Pm Counters
    Check Data Traffic

*** Keywords ***
Start Udp Full Buffer Traffic For 3 Ues And Small For Ue4
    Execute Egate Command    cmd=sim_debug_log level=6
    [Arguments]    ${num_of_ues}=${3}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    END
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl mbps=50
