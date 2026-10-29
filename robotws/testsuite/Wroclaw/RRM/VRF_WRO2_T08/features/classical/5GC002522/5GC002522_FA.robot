*** Settings ***
Documentation
...   author: Rafal Kaczmarski, Marcin Bednarski
...   contact: rafal.kaczmarski@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC002522/resources/test_specific_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Force Tags      CA_VRF_WRO2

Suite Setup     Prepare Testline
Suite Teardown  Run Keywords      Release QXDM License  AND  Get Startup_DEFAULT Log In Case Of Error

*** Variables ***
${SW_FOR_UPDATE}                None
${ABSTRACT_LIB_CONFIG}          /home/ute/testline_configuration/7_16_UTE5GCLOUDT095/S20_UE.yaml
${CELL_1_ALIAS}                 GNB_1_CELL_1
${CELL_2_ALIAS}                 GNB_1_CELL_2
${CELL_3_ALIAS}                 GNB_1_CELL_3
${CELL_4_ALIAS}                 GNB_1_CELL_4
${L1L2 filter}      'ether[24:2] = 0xe201 || ether[24:2] = 0xe103 || ether[24:2] = 0x0130 || ether[24:2] = 0x0135 || ether[24:2] = 0x0249' -c 20000
${attach tcpdump L1L2 filter}   -c 200000
${dl_mcs_filed}                 DlData_PdschSendReq.grants_item_0.mcs
${ul_mcs_filed}                 UlData_PuschReceiveReq.grants_item_0.mcs
${dl_mcs_filed_old}             DlData_PdschSendReq.grants_item_15.mcs
${ul_mcs_filed_old}             UlData_PuschReceiveReq.grants_item_15.mcs

*** Test Cases ***
[1]5GC002522_TC06_Attach_to_single_subcell_configured_in_80MHz_bandwidth_higher_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 80MHz bandwidth cell, using an NRARFCN
    ...               from the higher part of the band. The basic idea is to verify that configured 80MHz bandwidth
    ...               cell is detectable by the UE and attach procedure can be properly performed.

    [Setup]    Run Keywords    Test Setup For Attach Scenario With Higher Nrarfcn    AND    Prepare Ue
    Attach UE And Save L1L2 Log
    [Teardown]  Test Teardown


[1]5GC002522_TC05_Attach_to_single_subcell_configured_in_80MHz_bandwidth_lower_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 80MHz bandwidth cell, using an NRARFCN
    ...               from the lower part of the band.  The basic idea is to verify that configured 80MHz bandwidth
    ...               cell is detectable by the UE and attach procedure can be properly performed.

    [Setup]    Run Keywords    Test Setup For Attach Scenario With Lower Nrarfcn    AND    Prepare Ue
    Attach UE And Save L1L2 Log
    [Teardown]  Test Teardown


[1]5GC002522_TC03_Check_Link_adaptation_in_DL_and_UL_with_64_QAM
    [Documentation]   The purpose of this test case is to check if the link adaptation mechanism is working properly.
    ...               The basic idea is to verify that 5GNB is able to evaluate and apply all supported MCSes related to
    ...               64QAM modulation.
    ...               Precondition: 64QAM on (by default)

    [Setup]   Run Keywords    Test Setup For UL And DL With 64QAM    AND    Prepare Ue
    Attach UE And Save L1L2 Log
    Check Maximum Throughput and Average Mcs For 64QAM
    Check Average MCS From Given Traffic For 64QAM
    [Teardown]  Test Teardown


[1]5GC002522_TC04_Check_Link_adaptation_in_DL_and_UL_with_256_QAM
    [Documentation]   The purpose of this test case is to check if the link adaptation mechanism is working properly.
    ...               The basic idea is to verify that 5GNB is able to evaluate and apply all supported MCSes related to
    ...               64QAM modulation.
    ...               Precondition: 64QAM on (by default)

    [Setup]   Run Keywords    Test Setup For UL And DL With 256QAM    AND    Prepare Ue
    Attach UE And Save L1L2 log
    Check Maximum Throughput and Average Mcs For 256QAM
    Check Average MCS From Given Traffic For 256QAM
    [Teardown]  Test Teardown
