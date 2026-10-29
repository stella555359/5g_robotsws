*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com
Resource        ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup    CB014045 Suite Setup

Suite Teardown    Release 5g QXDM And Qcat License  ue_id=${0}

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT308/ue_config.yaml
${CELL_291}                 GNB_1_CELL_291
${CELL_292}                 GNB_1_CELL_292
${CELL_293}                 GNB_1_CELL_293
${CELL_295_298}             GNB_1_CELL_295_298
${CELL_294_297}             GNB_1_CELL_294_297
${CELL_296_299}             GNB_1_CELL_296_299
${UE_ALIAS}                 UE_1

*** Test Cases ***
[1]CB014045-B_B1_ALT3_UE_Full_buffer_throughput_verification_FDD_SA
    [Setup]    B_B1 Setup
    CB014045-B_B1_ALT3_UE_Full_buffer_throughput_verification_FDD_SA
    [Teardown]    B_B1 Teardown

[1]CB014045-A_B4_Uplink_LA_gains_with_Single_UE_in_256QAM_FDD_SA
    [Setup]    A_B4 Setup
    CB014045-A_B4_Uplink_LA_gains_with_Single_UE_in_256QAM_FDD_SA
    [Teardown]    A_B4 Teardown
