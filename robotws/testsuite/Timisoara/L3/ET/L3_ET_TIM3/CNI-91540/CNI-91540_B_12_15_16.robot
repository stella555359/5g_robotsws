*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    CRT    RAN_5G    SBTS00
...           NoResUsage

Resource     CNI-91540_Variables_And_Keywords.robot
Resource     CNI-91540_B_Keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot

Suite Setup    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND              Run    ${VM_ETH_IFACES}
...            AND              Get VM Password
...            AND              Mkdir for EMil script
...            AND              Start Xn And Ng Interfaces For Second Gnb
...            AND              Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup     Run Keywords        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...            AND                 Configure DCAP Session
...            AND                 Create DCAP BTS
...            AND                 Start DCAP Tracing
...            AND                 Add interfaces    ue_id=11
...            AND                 Find Scfc and Send Delta Commissioning    scfc_filename=delta_91540_B.json
...            AND                 Reach Onair    lua_cfg=${CURDIR}/config/wts_91540_B.cfg      

Test Teardown   Run Keywords   Delete DCAP BTS
...             AND            Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown  Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...             AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_91540_B_revert.json
...             AND             Run  docker stop $(docker ps -a -q)
...             AND             Cleanup EMil dir

*** Test Cases ***
16_CNI-91540-B_Scrambling_of_sensitive_information_for_CplaneXnIpAddress
#    Reset testline and reach onair      lua_cfg=${CURDIR}/config/wts_91540_B.cfg
    Stop DCAP
    Get DCAP Results     output_dirpath=${OUTPUT_DIR}/suite_setup_logs/DCAP_Traces_${TEST_NAME}.zip
    ${filepath}     set variable    ${OUTPUT_DIR}/suite_setup_logs/DCAP_Traces_${TEST_NAME}.zip
    wait until keyword succeeds     7min  15s      OperatingSystem.File should exist   path=${filepath}
    Send Emil script    dcap_filepath=${filepath}
    Unpack and prepare DCAP files to verify
    Generate text file
    Generate scrambled emil file
    Generate scrambled text file
    Check parameter in the message has scrambled    msg_name=CpIfNiddDeliveryRequest    para_name=GNbCuName
    log to console  Check parameter msg=CpIfNiddDeliveryRequest para_name=GNbCuName
    Check parameter in the message has scrambled    msg_name=CpIfX2IpAddressList    para_name=IpV4Address
    log to console  Check parameter msg=CpIfX2IpAddressList para_name=IpV4Address
    Check parameter in the message has scrambled    msg_name=CpIfX2IpAddressList    para_name=IpV6Address
    log to console  Check parameter msg=CpIfX2IpAddressList para_name=IpV6Address
    Check parameter in the message has scrambled    msg_name=CpIfXnIpAddressList    para_name=IpV4Address
    log to console  Check parameter msg=CpIfXnIpAddressList para_name=IpV4Address
    Check parameter in the message has scrambled    msg_name=CpIfXnIpAddressList    para_name=IpV6Address
    log to console  Check parameter msg=CpIfXnIpAddressList para_name=IpV6Address
