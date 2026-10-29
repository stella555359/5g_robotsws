*** Settings ***
Documentation
...     Author: Marek Bodziony, marek.bodziony@nokia.com
...     Author: Dominik Baran, dominik.baran@nokia.com
...     Maintainer: Marek Bodziony, marek.bodziony@nokia.com
...     Keywords for verification of (Q)SFP dynamic and static parameters (based on feature 5GC000614).

Library      testsuite.Krakow.resources.RAN_VRF_KRK3.SFP.sfp_helper.SfpHelper               WITH NAME   sfp_helper
Library      testsuite.Krakow.resources.RAN_VRF_KRK3.SFP.snapshot_helper.SnapshotHelper     WITH NAME   snapshot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${NRBTS_ID}=            ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Suite Setup With OnAir Test Line Preparation and Get SFP links details
    Common Suite Setup With OnAir Test Line Preparation
    Set SFPs HW for test

Get all SFP links details
    ${sfp_links}=    sfp_helper.get_SFP_links_status
    [Return]    ${sfp_links}

Get SFP links details for RMOD
    ${SFPs_for_RMOD}=    sfp_helper.get_SFP_data_for_RMOD
    [Return]    ${SFPs_for_RMOD}

Get SFP links details for BBMOD
    ${SFPs_for_BBMOD}=    sfp_helper.get_SFP_data_for_BBMOD
    [Return]    ${SFPs_for_BBMOD}

Get SFP links details for SMOD
    ${SFPs_for_SMOD}=    sfp_helper.get_SFP_data_for_SMOD
    [Return]    ${SFPs_for_SMOD}

Check if SFP dynamic parameters have a valid values
    [Arguments]    ${sfp_list}
    sfp_helper.check_if_SFP_dynamic_parameters_have_valid_values   ${sfp_list}

Check if SFP static RX parameters have a valid values
    [Arguments]    ${sfp_list}  ${sfp_in_test}
    sfp_helper.check_if_SFP_static_RX_parameters_have_valid_values   ${sfp_list}    ${sfp_in_test}

Check if SFP static TX parameters have a valid values
    [Arguments]    ${sfp_list}  ${sfp_in_test}
    sfp_helper.check_if_SFP_static_TX_parameters_have_valid_values   ${sfp_list}    ${sfp_in_test}

Check if SFP static HW parameters have a valid values for BBMOD
    [Arguments]    ${sfps_list}  ${sfps_in_test}
    sfp_helper.check_if_SFP_static_HW_parameters_have_valid_values_for_BBMOD   ${sfps_list}     ${sfps_in_test}

Check if SFP static HW parameters have a valid values for RMOD
    [Arguments]    ${sfp_list}  ${sfp_in_test}
    sfp_helper.check_if_SFP_static_HW_parameters_have_valid_values_for_RMOD   ${sfp_list}     ${sfp_in_test}

Check if SFP static HW parameters have a valid values for SMOD
    [Arguments]    ${sfp_list}  ${sfp_in_test}
    sfp_helper.check_if_SFP_static_HW_parameters_have_valid_values_for_SMOD   ${sfp_list}     ${sfp_in_test}

Check if SFP static Temperature parameters have a valid values
    [Arguments]    ${sfps_list}  ${sfps_in_test}
    sfp_helper.check_if_sfp_static_temperature_parameters_have_valid_values   ${sfps_list}     ${sfps_in_test}

Check if SFP static parameters from NetAct have a valid values
    [Arguments]    ${sfp_in_test}    ${module_type}
    sfp_helper.check_if_sfp_static_parameters_from_netact_have_valid_values    ${sfp_in_test}    ${module_type}

Set SFPs HW for test
    Run Keyword If  "${NRBTS_ID}"=="147"    Set SFPs list for BTS-147
    Run Keyword If  "${NRBTS_ID}"=="83"     Set SFPs list for BTS-83
    Run Keyword If  "${NRBTS_ID}"=="75003"  Set SFPs list for BTS-75003
    Run Keyword If  "${NRBTS_ID}"=="79147"  Set SFPs list for BTS-79147

Set SFPs list for BTS-83
    Set Suite Variable      @{sfps_hw_BBMOD}  AOMC_FR213612015
    Set Suite Variable      @{sfps_hw_RMOD}   AOMC_FR213612647

Set SFPs list for BTS-147
    Set Suite Variable      @{sfps_hw_BBMOD}    AOME_AD2141C0PKA
    Set Suite Variable      @{sfps_hw_RMOD}     AOME_AD2141C0KBT

Set SFPs list for BTS-75003
    Set Suite Variable      @{sfps_hw_BBMOD}    AOSC_FR211710160
    Set Suite Variable      @{sfps_hw_RMOD}    AOSC_FR204762981

Set SFPs list for BTS-79147
    Set Suite Variable      @{sfps_hw_BBMOD}     AOSD_Finisar_VF2011001N6    AOSD_FR203332638    AOMC_A_VF2140001LI    AOMC_B_VF2008000KR

Get SFP links details from Snapshot
    [Arguments]     ${num_of_RMODs}=1
    ${sfps_for_RMOD}=   snapshot.get_latest_sfp_param_values_from_snapshot   ${num_of_RMODs}
    [Return]    ${sfps_for_RMOD}

Remove Snapshot TEMP_DIR after test
    snapshot.remove_snapshot_temp_dir

Get SFP dynamic parameters from PM counters for RMOD
    [Arguments]     ${num_of_RMODs}=1
    ${sfp_for_RMOD}=   snapshot.get_latest_sfp_param_values_from_pm_counters_for_rmod       ${NRBTS_ID}     ${num_of_RMODs}
    [Return]    ${sfp_for_RMOD}

Get SFP dynamic parameters from PM counters for BBMOD
    [Arguments]     ${num_of_BBMODs}=1
    ${sfp_for_BBMOD}=   snapshot.get_latest_sfp_param_values_from_pm_counters_for_bbmod     ${NRBTS_ID}     ${num_of_BBMODs}
    [Return]    ${sfp_for_BBMOD}

Check if SFP dynamic parameters retrieved from PM counters have a valid values for BBMOD
    [Arguments]    ${sfp_param_BBMODs}
    sfp_helper.check_if_sfp_dynamic_parameters_have_valid_values_in_pm_counters_for_bbmod    ${sfp_param_BBMODs}

Check if SFP dynamic parameters retrieved from PM counters have a valid values for RMOD
    [Arguments]    ${sfp_param_RMODs}
    sfp_helper.check_if_sfp_dynamic_parameters_have_valid_values_in_pm_counters_for_rmod   ${sfp_param_RMODs}

Check if SFP dynamic parameters retrieved from Snapshot have a valid values
    [Arguments]    ${sfp_list}
    sfp_helper.check_if_SFP_dynamic_parameters_from_Snapshot_have_valid_values   ${sfp_list}
