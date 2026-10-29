*** Settings ***
Documentation
...   Test suite for regression testing of feature CB006488
...   author: Piotr Bacior
...   contact: piotr.bacior@nokia.com

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../../procedures/cell_setup_of_classical_gnb_configuration_with_mmwave_ecpri/procedure.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    STATE_SW_UPLOADED    RAN_5G    PY36    CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_AWGUC

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${current_config}    None

*** Test Cases ***
[1]Cell setup of Classical gNB configuration with mmWave eCPRI configuration block - successful scenario
    [Tags]    CIT    CDRT
    [Setup]    Common Preconditions With Commissioning    4CC
    [Timeout]    30m
    Cell setup of Classical gNB

