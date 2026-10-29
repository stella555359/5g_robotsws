*** Settings ***
Documentation
...   author: Adrian Jakobik, Adam Chamera
...   contact: adrian.jakobik@nokia.com, adam.chamera@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB008985


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/test_specific_keywords_8985.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot


Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/test_specific_keywords_8985.py

*** Keywords ***
CB008985_A_02_FeatureActivationDeactivation
    [Documentation]   The purpose of this TC is to verify if the feature can be activated and deactivated.

    Log to console                    >> Supercell should be activated by default, because of scf common for all tests
    Log to console                    >> Checking if SuperCell feature is activated
    ${feature_state}=                 test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    Should be true                    ${feature_state}
    Log to console                    actSuperCell=true
    test_specific_keywords_8985.suppress_all_subcells_except_one    not_suppressed_subcell=2   attenuation_value=50
    test_specific_keywords_8985.A_02 Require Ue
    test_specific_keywords_8985.A_02 Attach And Tput With Logs    custom_dt_name=first
    test_specific_keywords_8985.Check number of transmitted SSBs  expected_number=6
    ...                               pcap_file=${LOG_PATH}/CB008985_A_02_FeatureActivationDeactivation_L1L2.pcap
    Log to console                    Number of transmitted SSBs under NRCELLGRP are aligned with number of beams (6)

    Log to console                    >> SuperCell feature deactivation
    test_specific_keywords_8985.Supercell Deactivation

    Log to console                    >> Checking if SuperCell feature is deactivated
    AdminUtils.wait_for_all_cells_on_air_state
    ${feature_state}=                 test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    Should not be true                ${feature_state}
    Log to console                    actSuperCell=false
    Nullify attenuation on all ports
    test_specific_keywords_8985.A_02 Attach And Tput With Logs    custom_dt_name=second
    ...                               expected_tput_dl=16Mbits/sec
    ...                               expected_tput_ul=12Mbits/sec
    test_specific_keywords_8985.Check number of transmitted SSBs  expected_number=1
    ...                               pcap_file=${LOG_PATH}/CB008985_A_02_FeatureActivationDeactivation_L1L2.pcap
    Log to console                    Number of transmitted SSBs under NRCELLGRP are aligned with number of beams (1)

    Log to console                    >> Super cell feature activation
    test_specific_keywords_8985.Supercell Activation

    Log to console                    >> Checking if SuperCell feature is activated
    AdminUtils.wait_for_all_cells_on_air_state
    ${feature_state}=                 test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    Should be true                    ${feature_state}
    Log to console                    actSuperCell=true
    test_specific_keywords_8985.A_02 Logs
    test_specific_keywords_8985.Check number of transmitted SSBs  expected_number=6
    ...                               pcap_file=${LOG_PATH}/CB008985_A_02_FeatureActivationDeactivation_L1L2.pcap
    Log to console                    Number of transmitted SSBs under NRCELLGRP are aligned with number of beams (6)
    test_specific_keywords_8985.suppress_all_subcells_except_one    not_suppressed_subcell=2   attenuation_value=50
    test_specific_keywords_8985.Tput And Vonr Call Between All Subcells With Logs
    test_specific_keywords_8985.Check 5QI Setup
    ...    pcap_file=${LOG_PATH}/CB008985_A_02_FeatureActivationDeactivation_tcpdump_SMOD_MASTER.pcap


CB008985_A_06_SA_SingleUE_Attach_allSubcells_L3Call
    [Documentation]   The purpose of this TC is to verify if UE in SA mode get attach
    ...               and call can be performed in all sub-cells.
    test_specific_keywords_8985.Suppress All Subcells Except One
    test_specific_keywords_8985.Attach And Throughput To All Subcells With Logs

CB008985_A_07_SA_Subcell_Switch_failure_recovery
    [Documentation]   The purpose of this TC is to verify if UE can recover after subcell switch failure.
    test_specific_keywords_8985.Suppress All Subcells Except One    not_suppressed_subcell=4    attenuation_value=45
    GnbCounter.Wait for next pm period   interval=${pm_interval_8985}
    test_specific_keywords_8985.UE Recover After Subcell Switch Failure
    GnbCounter.Wait for next pm period   interval=${pm_interval_8985}
    test_specific_keywords_8985.Check Beam Recovery Counters
    test_specific_keywords_8985.Check RNTIs    pcap_file=${LOG_PATH}/CB008985_A_07_SA_Subcell_Switch_failure_recovery_tcpdump_SMOD_MASTER.pcap

CB008985_A_12_SA_VoNR_Call
    [Documentation]   The purpose of this TC is to verify if VoNR call can be performed in supercell.
    test_specific_keywords_8985.Suppress All Subcells Except Random One
    test_specific_keywords_8985.Call With Logs
    test_specific_keywords_8985.Check 5QI Setup
    ...    pcap_file=${LOG_PATH}/CB008985_A_12_SA_VoNR_Call_tcpdump_SMOD_MASTER.pcap

CB008985_B_04_HighSpeedCell_SA_VoNRCall_HSTCB
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell with
    ...               High Speed Cell Feature enabled and if VoNR call is possible to establish.
    test_specific_keywords_8985.Suppress All Subcells Except One
    test_specific_keywords_8985.Tput And Vonr Call Between All Subcells With Logs
    test_specific_keywords_8985.Check 5QI Setup
    ...    pcap_file=${LOG_PATH}/CB008985_B_04_HighSpeedCell_SA_VoNRCall_HSTCB_tcpdump_SMOD_MASTER.pcap
