*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource        ./resources/keywords_8509.robot
Library    ../5GC001167/resources/keywords_1167.py    WITH NAME    python_1167
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008509/resources/keywords_8509.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/mcs/mcs_parsing.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py

*** Variables ***
${DIAG_TEST_LOAD_50}    50
${DIAG_TEST_LOAD_FULL}    100
${DIAG_TEST_FDD_CELL}    100
${DIAG_TEST_TDD_CELL}    103

*** Keywords ***
TC09_CB008509_C_1_PDSCH_PDCCH_SSB_TRS_LowTS_PM
    ${result_without_load}    perform_rf_diagnostic_test    cells=${DIAG_TEST_TDD_CELL}

    ${result_with_load}=    Start Dummy Load And RF Diagnostic Test    cell=${DIAG_TEST_TDD_CELL}
    ...    target_load=${DIAG_TEST_LOAD_FULL}
    Assert Pdbm Is Higher During Dummy Load    ${result_without_load}    ${result_with_load}

    ${result_with_load}=    Start Dummy Load And RF Diagnostic Test    cell=${DIAG_TEST_TDD_CELL}
    ...    target_load=${DIAG_TEST_LOAD_50}
    Assert Pdbm Is Higher During Dummy Load    ${result_without_load}    ${result_with_load}

    Set Preferred Cell     103
    Set Initial Attenuation For Test
    counters.Wait For Pm Counters Interval    offset=0
    Attach UE To Pcell And Scell    UE_1    num_of_scells=0
    Start DL Traffic For Ue    UE_1    450Mbits/sec    duration=100s   protocol=udp

    L1L2.Start GnbMirroring    capturing_time_seconds=60    filename=no_art_load.pcap    new_l1l2=${TRUE}
    BuiltIn.Sleep   10   Collecting BIP
    ${no_art_load}=    L1L2.stop_gnbmirroring_and_download_logs
    Stop Data Transfer    DT_UE_1_default
    Verify DL Tput For Ue    UE_1

    Collect 8509 Counters
    Assert ARTIFICIAL_LOAD Counters Have Value 0    cell_id=103

    Run keyword and continue on failure    get_number_of_pdsch_for_real_ue    ${no_art_load}
    Run keyword and continue on failure    get_number_of_pdsch_for_al   ${no_art_load}

    Check Dummy Load Real Ue Tput First    ue_tput=200    cell_id=103    target_load=1
    Check Dummy Load Real Ue Tput First    ue_tput=200    cell_id=103    target_load=50
    Check Dummy Load Real Ue Tput First    ue_tput=200    cell_id=103    target_load=100

    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Stop Generate Dummy Load    cell_id=103

TC12_CB008509_C_4_DUMMY_PDSCH_PDCCH_SSB_TRS_HITS_noBF
    ${result_without_load}    perform_rf_diagnostic_test    cells=${DIAG_TEST_FDD_CELL}

    ${result_with_load}=    Start Dummy Load And RF Diagnostic Test    cell=${DIAG_TEST_FDD_CELL}
    ...    target_load=${DIAG_TEST_LOAD_FULL}
    Assert Pdbm Is Higher During Dummy Load    ${result_without_load}    ${result_with_load}

    ${result_with_load}=    Start Dummy Load And RF Diagnostic Test    cell=${DIAG_TEST_FDD_CELL}
    ...    target_load=${DIAG_TEST_LOAD_50}
    Assert Pdbm Is Higher During Dummy Load    ${result_without_load}    ${result_with_load}

    Set Preferred Cell     100
    Set Initial Attenuation For Test
    counters.Wait For Pm Counters Interval    offset=0
    Attach UE To Pcell And Scell    UE_1    num_of_scells=0
    Start DL Traffic For Ue    UE_1    100Mbits/sec    duration=100s   protocol=udp

    L1L2.Start GnbMirroring    capturing_time_seconds=60    filename=no_art_load.pcap    new_l1l2=${TRUE}
    BuiltIn.Sleep   10   Collecting BIP
    ${no_art_load}=    L1L2.stop_gnbmirroring_and_download_logs
    Stop Data Transfer    DT_UE_1_default
    Verify DL Tput For Ue    UE_1

    Collect 8509 Counters
    Assert ARTIFICIAL_LOAD Counters Have Value 0    cell_id=100

    Run keyword and continue on failure    get_number_of_pdsch_for_real_ue    ${no_art_load}
    Run keyword and continue on failure    get_number_of_pdsch_for_al   ${no_art_load}

    Check Dummy Load Real Ue Tput First    ue_tput=100    cell_id=100    target_load=1
    Check Dummy Load Real Ue Tput First    ue_tput=100    cell_id=100    target_load=50
    Check Dummy Load Real Ue Tput First    ue_tput=100    cell_id=100    target_load=100

    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Stop Generate Dummy Load    cell_id=100
