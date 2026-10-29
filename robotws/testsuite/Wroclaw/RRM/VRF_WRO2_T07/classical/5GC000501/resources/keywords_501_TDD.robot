*** Settings ***
Documentation
...   author: Bartlomiej Swoboda and Hubert Grobelny
...   contact: bartlomiej.swoboda@nokia.com
...   maintainer:    bartlomiej.swoboda@nokia.com
...   Description:   This feature describes and verify graceful shutdown procedure according to 5GC000501 feauture

Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/test_specific_keywords_501.py
Library   testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
${first_cell_number}=    1
${second_cell_number}=   2
${third_cell_number}=   3
${rsrp_threshold}=    85


*** Keywords ***
[1.0] 5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling

    ${sgNB_params}=     Set sgNB release params     ${first_cell_number}    ${rsrp_threshold}
    Setup and check preconditions in scf    ${sgNB_params}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Start tracing on SMOD
    Prepare UE AT   REAL_UE_NSA
    BuiltIn.Sleep   30
    ${pcap_path}=   Stop tracing and download logs from SMOD
    BuiltIn.Sleep   30
    Check event a2 in pcap log     ${pcap_path}
    Update sw to testpackage t1
    Check messages in sys log

    [Teardown]   Run Keywords
    ...   Detach UE   ${UE_ALIAS}       AND
    ...   Unlock all cells


[1.0] 5GC000501_A_23_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_handovers_handling

    Preprate TL with swconfig    0x590072=1

    ${ho_params}=     Set HO params     ${first_cell_number}    ${second_cell_number}
    Setup and check preconditions in scf    ${ho_params}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    Prepare UE AT   REAL_UE_SA
    Perform shutting down    ${first_cell_number}
    BuiltIn.Sleep   100

    Check HO related Msg in BTS Log    ${BTS_LOGS_DIR}
    [Teardown]  Run Keywords
    ...         Cell unlock after shutdown      ${first_cell_number}   AND
    ...         Wait for all cells on air state


[1][1.0] 5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling
    Graceful Cell shutdown for concurrent mode NSA and SA configuration invalid parameters values handling      ${second_cell_number}


[1][1.0] 5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
    Graceful Cell shutdown for concurrent mode NSA and SA configuration operators parameters check     ${second_cell_number}
    Graceful Cell shutdown for concurrent mode NSA and SA configuration operators parameters check     ${third_cell_number}
