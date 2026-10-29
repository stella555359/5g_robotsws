*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com
Resource        ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup    CB012439 Suite Setup

Suite Teardown    Release 5g QXDM And Qcat License  ue_id=${0}

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT300/ue_config.yaml
${CELL_250}                 GNB_1_CELL_250
${CELL_252}                 GNB_1_CELL_252
${CELL_253}                 GNB_1_CELL_253
${CELL_254}                 GNB_1_CELL_254
${UE_ALIAS}                 UE_1

*** Test Cases ***
[1]CB012439_B_B2_A2_IntraFreq_A3A5_Reconfiguration_after_ProtectTimer_Expiry
    [Setup]    B_B2_A2 Setup
    CB012439_B_B2_A2_IntraFreq_A3A5_Reconfiguration_after_ProtectTimer_Expiry
    [Teardown]    B_B2_A2 Teardown

[1]CB012439_A_B10_Successful_reconfiguration_of_measurements_during_PDU_Session_Resource_Modification
    [Setup]    A_B10 Setup
    CB012439_A_B10_Successful_reconfiguration_of_measurements_during_PDU_Session_Resource_Modification
    [Teardown]    A_B10 Teardown

[1]CB012439_C_B11_Mobility_Profile_5QI_Criteria_Based_Measurement_Reconfiguration_After_A1_MR_Handling
    [Setup]    C_B11 Setup
    CB012439_C_B11_Mobility_Profile_5QI_Criteria_Based_Measurement_Reconfiguration_After_A1_MR_Handling
    [Teardown]    C_B11 Teardown
