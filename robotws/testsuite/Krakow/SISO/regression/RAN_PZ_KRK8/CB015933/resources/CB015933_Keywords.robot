*** Settings ***
Documentation
...    Author: Jacek Dziedzicki
...    Contact: Jacek.Dziedzicki@nokia.com
...    Description: Keywords for CB015933 5+5Mhz carrier overlapping configuration deployment support


Library      taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations    WITH NAME    rmod
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    CB015933_Keywords.py

*** Variables ***
${target_dir}               /home/ute/Downloads
${26R2_source_sw_version}   SBTS26R2_ENB_0000_000043_000000
${25R2_source_sw_version}   SBTS25R2_ENB_0000_000506_000007
${global_cell_id_178}       19255132
${global_cell_id_179}       19255122
${sw_config_path}           commissionings/Krakow/swconfig/default_swconfig.txt
@{CUSTOM_ALLOWED_ALARMS}    No X2 link available    Cell problem due to unavailability of associated links
...                         Cell blocked    Cell Activation timeout at gNB-DU
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console   \n--Start Suite Setup--\n
    tl_prep.Power On All Pdu Ports
    Restart Ue Proxy On Ue PC
    ${target_sw_version}=    Get gNB Sw Version
    Set Suite Variable    ${target_sw_version}
    logger.log_info_to_console   ---- gNB current SW Version: ${target_sw_version} ----\n
    Prepare Testline    scf_prefix_tag=CB015933_TSPY215_TC3    swconfig_from_path=${sw_config_path}
    Common Suite Setup
    logger.log_info_to_console   \n--Suite Setup DONE--\n

Test Setup
    [Arguments]    ${prefix_tag}=None
    Run Keyword If    '${prefix_tag}'!='None'    Prepare Testline    scf_prefix_tag=${prefix_tag}
    ...  ELSE    logger.log_info_to_console   \n-- No commissioning performed in Test Setup --\n
    keywords.Test Setup

Test Setup For SW Upgrade TC
    ${target_sw_version_converted}=    keywords.Convert Trunk Sw Version    ${target_sw_version}
    IF    '${target_sw_version_converted}' == 'SBTS26R3'
        Perform SW Upgrade    ${26R2_source_sw_version}
        Prepare Testline    scf_prefix_tag=CB015933_TSPY215_TC3_Feature_On
    ELSE IF  '${target_sw_version_converted}' == 'SBTS26R2'
        logger.log_info_to_console      \n--- Downloading BTS SW: ${25R2_source_sw_version} ---\n
        ${sw_package_dir}  Download SW package     ${25R2_source_sw_version}   ${target_dir}
        logger.log_info_to_console          \n--- Updating BTS SW to ${25R2_source_sw_version} ---\n
        Upgrade and Commission Gnb   builds_dir=${target_dir}  sw_build=${25R2_source_sw_version}  prefix_tag=CB015933_TSPY215_TC3_Feature_On
    ELSE
        logger.log_info_to_console   \n-- Wrong BTS SW: ${target_sw_version_converted} --\n
    END
    keywords.Test Setup

Test Teardown
    logger.log_info_to_console    \n-- Start Test Teardown --\n
    Prepare Testline    scf_prefix_tag=CB015933_TSPY215_TC3
    logger.log_info_to_console    \n---- Common Postconditions With Watching Alarms...----\n
    Common Postconditions With Watching Alarms
    logger.log_info_to_console    \n-- Test Teardown DONE --\n

Test Suite Teardown
    logger.log_info_to_console    \n--Start Test Suite Teardown--\n
    Common Suite Teardown
    Run keyword And Ignore Error    rmod.Lock Radio Unit    radio_unit_id=1
    logger.log_info_to_console    \n--Test Suite Teardown DONE--\n

Perform SW Upgrade
    [Arguments]    ${sw_version}
    logger.log_info_to_console      \n--- Downloading BTS SW: ${sw_version} ---\n
    ${sw_package_dir}  Download SW package     ${sw_version}   ${target_dir}
    logger.log_info_to_console          \n--- Updating BTS SW to ${sw_version} ---\n
    Update gNB software     ${sw_package_dir}    timeout=1800
    logger.log_info_to_console     \n--- Waiting For onAir... --- \n
    Sleep     400s
    gnbbbu.connect    bts_id=${0}  du_id=${0}  force=${True}
    Wait Until Keyword Succeeds     1200 sec     30 sec   Verify gNB is onAir
    Wait Until Keyword Succeeds     1200 sec     30 sec   gnbcell.Verify All Cells Are Onair
    ${current_sw_version}=    Get gNB Sw Version
    Should Be Equal  ${current_sw_version}  ${sw_version}  SW upgrade failed
    Set Global Variable    ${ENB_BUILD}    ${sw_version}
    logger.log_info_to_console     \n--- BTS updated successfully --- \n

Perform SW Upgrade If Needed
    ${sw_version}=    Get gNB Sw Version
    IF    '${sw_version}' != '${target_sw_version}'
        Perform SW Upgrade    ${target_sw_version}
    END

Attach UE
    [Arguments]    ${global_cell_id}    ${prepareUE}=${True}
    logger.log_info_to_console   \n\n--Attach UE...--\n
    Run Keyword If    '${prepareUE}'=='${True}'
    ...               ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    ue.Detach Ue    UE_1
    Sleep    60s
    ue.Attach Ue    UE_1    timeout=${60}
    ${LTE_CELL}      ue.Get Ue Info    UE_1    cell_id
    Run Keyword If  '${LTE_CELL}'=='${global_cell_id}'
    ...             logger.log_info_to_console    \nUE attached properly to the LTE cell: ${LTE_CELL} (E-UTRAN cell id)\n
    ...     ELSE    Fail And Log Error   msg= UE cannot attach to proper LTE cell

Block eNB Cells
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=91
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=92
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=81
    logger.log_info_to_console   \n\n--Cells blocked--\n

Unblock eNB Cells
    Run keyword And Ignore Error    gnbcell.Unblock Cell    cell_id=91
    Run keyword And Ignore Error    gnbcell.Unblock Cell    cell_id=82
    Run keyword And Ignore Error    gnbcell.Unblock Cell    cell_id=81
    logger.log_info_to_console   \n\n--Cells unblocked--\n

Lock Radio Units
    Run keyword And Ignore Error    rmod.Lock Radio Unit    radio_unit_id=1
    Run keyword And Ignore Error    rmod.Lock Radio Unit    radio_unit_id=4
    logger.log_info_to_console   \n\n--Radio units locked--\n

Unlock Radio Units
    Run keyword And Ignore Error    rmod.Unlock Radio Unit    radio_unit_id=1
    Run keyword And Ignore Error    rmod.Unlock Radio Unit    radio_unit_id=4
    logger.log_info_to_console   \n\n--Radio units unlocked--\n
