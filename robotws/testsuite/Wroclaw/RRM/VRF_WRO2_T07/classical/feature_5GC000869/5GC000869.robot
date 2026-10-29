*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com

Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000869/resources/keywords.py

Force Tags    PY36

Suite Setup     suite_setup


Test Setup      test_setup

Test Teardown   test_teardown


*** Variables ***
${dl_mcs_field}          DlData_PdschSendReq.grants_item_0.mcs
${ul_mcs_field}          UlData_PuschReceiveReq.grants_item_0.mcs
${dl_mcs_field_old}      DlData_PdschSendReq.grants_item_15.mcs
${ul_mcs_field_old}      UlData_PuschReceiveReq.grants_item_15.mcs

*** Test Cases ***
[1][1.0] 5GC000869-D_Attach_to_single_subcell_configured_in_80MHz_bandwidth_higher_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 80MHz bandwidth cell, using an NRARFCN
    ...               from the higher part of the band. The basic idea is to verify that configured 80MHz bandwidth
    ...               cell is detectable by the UE and attach procedure can be properly performed.
    attach_to_single_subcell_configured_in_higher_nrarfcn


[1][1.0] 5GC000869-D_Attach_to_single_subcell_configured_in_80MHz_bandwidth_lower_NRARFCN
    [Documentation]   The purpose of this test case is to perform attach to 80MHz bandwidth cell, using an NRARFCN
    ...               from the lower part of the band.  The basic idea is to verify that configured 80MHz bandwidth
    ...               cell is detectable by the UE and attach procedure can be properly performed.
    attach_to_single_subcell_configured_in_lower_nrarfcn


[1][1.0] 5GC000869_Check_Link_adaptation_in_DL_and_UL_with_64_QAM
    [Documentation]   The purpose of this test case is to check if the link adaptation mechanism is working properly.
    ...               The basic idea is to verify that 5GNB is able to evaluate and apply all supported MCSes related to
    ...               64QAM modulation.
    ...               Precondition: 64QAM on (by default)
    check_la_with_64_qam


[1][1.0] 5GC000869_Check_Link_adaptation_in_DL_and_UL_with_256_QAM
    [Documentation]   The purpose of this test case is to check if the link adaptation mechanism is working properly.
    ...               The basic idea is to verify that 5GNB is able to evaluate and apply all supported MCSes related to
    ...               64QAM modulation.
    ...               Precondition: 64QAM on (by default)
    check_la_with_256_qam
