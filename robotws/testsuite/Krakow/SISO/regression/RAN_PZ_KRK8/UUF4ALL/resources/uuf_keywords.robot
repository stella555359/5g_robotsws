*** Settings ***
Documentation   Universal resources for basic UUF OAM tests in loop dedicated for Cloud testlines in VRF KRK T08
...   author: Mateusz Iwankiewicz, Aleksander Gospodarczyk, Jacek Dziedzicki, Bartosz Odziomek
...   contact: mateusz.iwankiewicz@nokia.com, aleksander.gospodarczyk@nokia.com, jacek.dziedzicki@nokia.com, bartosz.odziomek@nokia.com

Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library         taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library         on_air_tl_preparation.testline_preparation                   WITH NAME      tl_prep
Library         taf.rfrl.bts.commissioning
Library         testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Library         uuf4all_keywords.py
Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot

*** Variables ***
${build_dir}    /home/ute/UUF_SW

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console   ********************************************\n
    logger.log_info_to_console   ---- Catch CRITICAL_FAULTS: ${CRITICAL_FAULTS} ----\n
    logger.log_info_to_console   ---- Allow CUSTOM_ALLOWED_ALARMS: ${CUSTOM_ALLOWED_ALARMS} ----\n\n
    logger.log_info_to_console   ---- Start Suite Setup ----\n
    logger.log_info_to_console   ---- Prepare testline and wait for onAir ----\n
    tl_prep.Power On All Pdu Ports
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb    sw_config_path=${sw_config_path}
    Get BTS Instance Id
    ${all_cells_onair}    Run Keyword And Return Status    gnbcell.wait_for_all_cells_to_be_onair
    Run Keyword If    not '${all_cells_onair}' == '${True}'
    ...    Perform Commissioning on BTS    prefix_tag=${SCF_PREFIX}    build_directory=${build_dir}
    logger.log_info_to_console    ---- Common Suite Setup...----\n
    Common Suite Setup    check_truck_roll=${True}
    Collect Snapshot From gNB    log_dir=/home/ute/logs/
    logger.log_info_to_console   ---- Snapshot has been collected ----\n
    logger.log_info_to_console   ---- Test Suite Setup Done ----\n
    logger.log_info_to_console   ********************************************\n

Test Setup For Upgrade Test
    ${5G_SOURCE_SW_BEFORE_UPGRADE}=    Get gNB Sw Version
    ${5G_SOURCE_SW_BEFORE_UPGRADE}=    uuf4all_keywords.Convert Trunk Sw Version    ${5G_SOURCE_SW_BEFORE_UPGRADE}
    logger.log_info_to_console   ---- gNB current SW Version: ${5G_SOURCE_SW_BEFORE_UPGRADE} ----\n
    Upgrade and Commission Gnb    sw_build=${DEFINED_5G_SOURCE_SW}  prefix_tag=${SCF_PREFIX}  builds_dir=${build_dir}
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${400}
    Wait For Cells To Be Onair
    Run Keyword If    '${DEFINED_5G_SOURCE_SW}' == '${5G_SOURCE_SW_BEFORE_UPGRADE}'
    ...    Perform Commissioning on BTS    prefix_tag=${SCF_PREFIX}    build_directory=${build_dir}
    ${5G_SOURCE_SW_AFTER_UPGRADE}=    Get gNB Sw Version
    ${5G_SOURCE_SW_AFTER_UPGRADE}=    uuf4all_keywords.Convert Trunk Sw Version    ${5G_SOURCE_SW_AFTER_UPGRADE}
    Set Suite Variable    ${5G_SOURCE_SW}    ${5G_SOURCE_SW_AFTER_UPGRADE}
    Set Suite Variable    ${5G_TARGET_SW}    ${ENB_BUILD}
    logger.log_info_to_console   ---- gNB Source SW Version: ${5G_SOURCE_SW} ----\n
    logger.log_info_to_console   ---- gNB Target SW Version: ${5G_TARGET_SW} ----\n
