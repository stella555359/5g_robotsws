*** Settings ***
Documentation
...   author: Adrian Jakobik, Adam Chamera
...   contact: adrian.jakobik@nokia.com, adam.chamera@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB008434


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/test_specific_keywords_8985.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot


Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/test_specific_keywords_8985.py

*** Keywords ***
CB008434_A_01_SuperCellSetup_HalfABIO_1x3subcells_AZHM
    [Documentation]   The purpose of this TC is to check if one NR FR1 TDD super cell (up to 3 subcells)
    ...               can be set up for Half ABIO configuration.
    test_specific_keywords_8985.Remove CHANNELGROUP 4 5 6
    test_specific_keywords_8985.Suppress All Subcells Except One                   num_of_subcells=3
    test_specific_keywords_8985.Attach And Throughput To All Subcells With Logs    num_of_subcells=3
    [Teardown]   test_specific_keywords_8985.Add CHANNELGROUP 4 5 6

CB008434_B_01_SuperCellSetup_FullABIO_6Subcells_AZHM
    [Documentation]   The purpose of this TC is to check if one NR FR1 TDD super cell
    ...               (up to 6 subcells) can be set up for Full ABIO configuration.
    test_specific_keywords_8985.Suppress All Subcells Except One
    test_specific_keywords_8985.Attach And Throughput To All Subcells With Logs    num_of_subcells=6
