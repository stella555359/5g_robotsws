*** Settings ***
Documentation
...   maintainer: Marta Hendler
...   contact: marta.hendler@nokia.com
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB005750_CB006154/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Teardown  Run Keywords
...             Get Startup_DEFAULT Log In Case Of Error
...             Release QXDM License
...             Delete Files on UEPC

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT198/ue_config.yaml
${CELL_80MHz}               GNB_1_CELL_179
${CELL_70MHz}               GNB_1_CELL_55
${UE_ALIAS}                 UE_1

*** Test Cases ***
CB005750_TC03_Check_Link_adaptation_in_DL_and_UL_with_64_QAM
    [Documentation]   The purpose of this test case is to verify that 5GNB is able to evaluate and apply
    ...               all supported MCSes related to 64QAM modulation.
    [Setup]   Test Setup For UL And DL QAM Scenario   ${CELL_80MHz}   64QAM
    Attach UE And Save L1L2 Log   ${CELL_80MHz}
    Check Maximum Throughput And Average MCS     ${CELL_80MHz}   64QAM
    Check Average MCS For Given Attenuation      ${CELL_80MHz}   64QAM
    [Teardown]  Test Teardown

CB005750_TC04_Check_Link_adaptation_in_DL_and_UL_with_256_QAM
    [Documentation]   The purpose of this test case is to verify that 5GNB is able to evaluate and apply
    ...               all supported MCSes related to 256QAM modulation.
    [Setup]   Test Setup For UL And DL QAM Scenario   ${CELL_80MHz}   256QAM
    Attach UE And Save L1L2 Log   ${CELL_80MHz}
    Check Maximum Throughput And Average MCS     ${CELL_80MHz}   256QAM
    Check Average MCS For Given Attenuation      ${CELL_80MHz}   256QAM
    [Teardown]  Test Teardown

CB005750_TC06_Attach_to_single_subcell_configured_in_80MHz_bandwidth_higher_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 80MHz bandwidth cell, using an NRARFCN
    ...               from the higher part of the band.
    [Setup]   Test Setup For NRARFCN Attach Scenario   ${CELL_80MHz}   HIGH
    Attach UE And Save L1L2 Log   ${CELL_80MHz}
    [Teardown]  Test Teardown

CB005750_TC05_Attach_to_single_subcell_configured_in_80MHz_bandwidth_lower_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 80MHz bandwidth cell, using an NRARFCN
    ...               from the lower part of the band.
    [Setup]   Test Setup For NRARFCN Attach Scenario   ${CELL_80MHz}   LOW
    Attach UE And Save L1L2 Log   ${CELL_80MHz}
    [Teardown]  Test Teardown

CB006154-5G_TC03_Check_Link_adaptation_in_DL_and_UL_with_64_QAM
    [Documentation]   The purpose of this test case is to verify that 5GNB is able to evaluate and apply
    ...               all supported MCSes related to 64QAM modulation.
    [Setup]   Test Setup For UL And DL QAM Scenario   ${CELL_70MHz}   64QAM
    Attach UE And Save L1L2 Log   ${CELL_70MHz}
    Check Maximum Throughput And Average MCS     ${CELL_70MHz}   64QAM
    Check Average MCS For Given Attenuation      ${CELL_70MHz}   64QAM
    [Teardown]  Test Teardown

CB006154-5G_TC04_Check_Link_adaptation_in_DL_and_UL_with_256_QAM
    [Documentation]   The purpose of this test case is to verify that 5GNB is able to evaluate and apply
    ...               all supported MCSes related to 256QAM modulation.
    [Setup]   Test Setup For UL And DL QAM Scenario   ${CELL_70MHz}   256QAM
    Attach UE And Save L1L2 Log   ${CELL_70MHz}
    Check Maximum Throughput And Average MCS     ${CELL_70MHz}   256QAM
    Check Average MCS For Given Attenuation      ${CELL_70MHz}   256QAM
    [Teardown]  Test Teardown

CB006154-5G_TC06_Attach_to_single_subcell_configured_in_70MHz_bandwidth_higher_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 70MHz bandwidth cell, using an NRARFCN
    ...               from the higher part of the band.
    [Setup]   Test Setup For NRARFCN Attach Scenario   ${CELL_70MHz}   HIGH
    Attach UE And Save L1L2 Log   ${CELL_70MHz}
    [Teardown]  Test Teardown

CB006154-5G_TC05_Attach_to_single_subcell_configured_in_70MHz_bandwidth_lower_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 70MHz bandwidth cell, using an NRARFCN
    ...               from the lower part of the band.
    [Setup]   Test Setup For NRARFCN Attach Scenario   ${CELL_70MHz}   LOW
    Attach UE And Save L1L2 Log   ${CELL_70MHz}
    [Teardown]  Test Teardown
