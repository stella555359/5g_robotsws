*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   Description:   Feature CB015316

Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB015316/resources/test_specific_keywords_15316.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.robot

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB015316/resources/test_specific_keywords_15316.py

Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB015316/resources/test_specific_keywords_15316.py


*** Variables ***
${UE_1}             REAL_UE_SA
${UE_1_alias}       UE_1
${CellFilter}           1
@{counter_id_15316}    M55308C11002
${test_name}            15316
${301_CELL_ID}          301
${iterationAmmount}     12


*** Keywords ***
CB013316_featureOn_featureOff_withCounters
	[Documentation]   This test case is for 8409 feature with interferences
    upload_scf_15316    CB015316_featureOff
    Wait for OnAir for all RATs     ${rats}
    Perform Site Reset
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${301_CELL_ID}
    Wait for next counter interval
    Attach Ue            ${UE_1_alias}
    Wait for next counter interval
    FOR    ${item}    IN RANGE  ${iterationAmmount}
        Data Transfer procedure 15316      ${UE_1_alias}
        Data transfer check procedure 15316     ${UE_1_alias}
        Data Transfer Stop procedure 15316      ${UE_1_alias}
    END
    Detach Ue   ${UE_1_alias}
    ${cell_counters_feature_off}    test_specific_keywords_15316.Collect Counters For Testcase 15316    ${301_CELL_ID}
    ...                             ${counter_id_15316}     ${test_name}
    AdminUtils.unlock_all_cells
    upload_scf_15316    CB015316_featureOn
    Wait for OnAir for all RATs     ${rats}
    Perform Site Reset
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${301_CELL_ID}
    Wait for next counter interval
    Attach Ue            ${UE_1_alias}
    FOR    ${item}     IN RANGE   ${iterationAmmount}
        Data Transfer procedure 15316      ${UE_1_alias}
        Data transfer check procedure 15316     ${UE_1_alias}
        Data Transfer Stop procedure 15316      ${UE_1_alias}
    END
    ${cell_counters_feature_on}    test_specific_keywords_15316.Collect Counters For Testcase 15316    ${301_CELL_ID}
    ...                            ${counter_id_15316}       ${test_name}
    Compare Feature on Feature off  ${cell_counters_feature_off}    ${cell_counters_feature_on}     ${iterationAmmount}
