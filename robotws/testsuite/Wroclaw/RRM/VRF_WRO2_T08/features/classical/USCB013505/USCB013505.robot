*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com
Resource        ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup    USCB013505 Suite Setup

Suite Teardown    Release 5g QXDM And Qcat License  ue_id=${0}

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT300/ue_config.yaml
${CELL_250}                 GNB_1_CELL_250
${CELL_252}                 GNB_1_CELL_252
${CELL_253}                 GNB_1_CELL_253
${CELL_254}                 GNB_1_CELL_254
${UE_ALIAS}                 UE_1

*** Test Cases ***
[1][1.0]TC01_USCB013505_SR_A_B1_EPIC_Feature_Activation
    [Setup]    A_B1 Setup
    TC01_USCB013505_SR_A_B1_EPIC_Feature_Activation
    [Teardown]    Common Test Teardown

[1][1.0]TC04_USCB013505_SR_B_B1_EPIC_MCS_Threshold
    [Setup]    B_B1 Setup
    TC04_USCB013505_SR_B_B1_EPIC_MCS_Threshold
    [Teardown]    Common Test Teardown
