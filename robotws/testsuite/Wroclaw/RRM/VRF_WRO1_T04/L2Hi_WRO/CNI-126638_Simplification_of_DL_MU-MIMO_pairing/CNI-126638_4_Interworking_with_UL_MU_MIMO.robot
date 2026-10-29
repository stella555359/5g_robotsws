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
    ...       AND    With Gnb Configuration    commissioning=full_scf_1cell_16DL_8UL_UL_MUMIMO_AP_LO.xml
    ...       AND    Wait for gNB Configured state
    ...       AND    Disable Uplane Ciphering
    ...       AND    Reach Onair    lua_cfg=${CURDIR}/config/1c_TDD_n41_MUMIMO_AP_LO.cfg
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Prepare Testmode For Ue Position

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   15s

*** Test Cases ***
CNI-126638_4_Interworking_with_UL_MU_MIMO
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_dlMuMimoSpectralEffThd_0.json
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_actExcludeLowBufferUser_true.json
    #Activate Testmode For Ue Position
    Attach Multiple Ues    num_of_ues=2
    Start Udp Traffic 450Mbps In DL For All Ues
    Check Data Traffic
    Collect L2PS TTI Trace      directory_name=DL_MU_MIMO_pair
    Collect Pm Counters
    Collect snapshot from gNB    target_dir=${OUTPUTDIR}/DL_MU_MIMO_pair
    Start Ul Full Buffer Traffic For 4 Ues
    Check Data Traffic
    Collect L2PS TTI Trace      directory_name=DL_and_UL_MU_MIMO_pair
    Collect Pm Counters
    Collect snapshot from gNB    target_dir=${OUTPUTDIR}/DL_and_UL_MU_MIMO_pair


*** Keywords ***
Start Ul Full Buffer Traffic For 4 Ues
    Execute Egate Command    cmd=sim_debug_log level=6
    [Arguments]    ${num_of_ues}=${4}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=150
    END


