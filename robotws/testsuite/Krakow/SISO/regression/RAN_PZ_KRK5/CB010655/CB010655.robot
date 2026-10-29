*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010655
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com


Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600     prefix_tag=AWHQX
Suite Teardown     Common Suite Teardown

*** Variables ***
&{rfsw_credentials}=  username=serviceuser
...                                password=oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=

*** Test Cases ***
CB010655_RF6.2_C_1_2_support_fault_history_and_store_into_NVM
    [Setup]      Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[fault_history]
    Change timeBetweenSaveOnNVM On Ru         src=/tmp/black_box_logger.json       dst=/tmp/black_box_logger_bckp.json
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    Trigger Alarm On Ru     src=/ram/tempest_inst1.json        dst=/ram/tempest_inst1_bckp.json
    BuiltIn.Sleep       2m
    Verify Fault History        state=1
    Trigger Alarm On Ru     src=/ram/tempest_inst1_bckp.json        dst=/ram/tempest_inst1.json     replace_val=${False}
    BuiltIn.Sleep       2m
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    Verify Fault History        state=0
    Change timeBetweenSaveOnNVM On Ru         src=/tmp/black_box_logger.json       dst=/tmp/black_box_logger_bckp.json
    ...                                       replace_val=${False}
    [Teardown]      Actions after test

CB010655_RF6.2_G_1_enhancement_of_radio_SW_version_and_firmware_version
    [Setup]      Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[after_ru_reboot]
    Verify Radio SW Version And Firmware Version After Enhancement
    [Teardown]      Actions after test
