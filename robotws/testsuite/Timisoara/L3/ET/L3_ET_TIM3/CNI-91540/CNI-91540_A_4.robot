*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    CRT    RAN_5G    SBTS00
...           NoResUsage

Resource     CNI-91540_Variables_And_Keywords.robot

Suite Setup    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND              Get VM Password
...            AND              Mkdir for EMil script
...            AND              Start Xn And Ng Interfaces For Second Gnb
...            AND              Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup     Run Keywords        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...            AND                 Configure DCAP Session
...            AND                 Create DCAP BTS
...            AND                 Start DCAP Tracing

Test Teardown   Run Keywords   Delete DCAP BTS
...             AND            Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown  Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...             AND             Run  docker stop $(docker ps -a -q)
...             AND             Cleanup EMil dir

*** Test Cases ***
4_CNI-91540-A_Scrambling_of_sensitive_information_for_CpNb_NGLinkInfoUpdateInd
    Reach Onair    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa_2amf.lua
    Stop DCAP
    Get DCAP Results     output_dirpath=${OUTPUT_DIR}/suite_setup_logs/DCAP_Traces_${TEST_NAME}.zip
    ${filepath}     set variable    ${OUTPUT_DIR}/suite_setup_logs/DCAP_Traces_${TEST_NAME}.zip
    wait until keyword succeeds     7min  15s      OperatingSystem.File should exist   path=${filepath}
    Send Emil script    dcap_filepath=${filepath}
    Unpack and prepare DCAP files to verify
    Generate text file
    Generate scrambled emil file
    Generate scrambled text file
    Check parameter in the message has scrambled    msg_name=CpNbNGLinkInfoUpdateInd    para_name=AmfIpAddress
    Check parameter in the message has scrambled    msg_name=CpNbNGLinkInfoUpdateInd    para_name=AmfName
    Check parameter in the message has scrambled    msg_name=CpNbNGLinkInfoUpdateInd    para_name=AmfIpAddressSec
