*** Settings ***

Documentation
...    author: VRF ULM T06
...    Team: 'MN RAN RD VRF ULM 06'
...    Email: 'I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-E
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ../CB013142_Keywords.robot
Resource                        ../CB013142_Commissioning.robot
Resource                        ../CB013142_PM.robot

Suite Setup                     Run Keywords
...                             Prepare TL For CB013142          AND
...                             Prepare UE List For CB013142-E

Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions Of Test Scenario
Test Teardown                   Perform Postconditions Of Test Case

*** Variables ***
@{CA_MSG_SEQ}                   sCellToAddModList
...                             sCellIndex 1
...                             physCellId 53
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellIndex 2
...                             physCellId 54

@{CA_MSG_SEQ_1}                 sCellToAddModList
...                             sCellIndex 1
...                             physCellId 50
...                             downlinkConfigCommon
...                             sCellIndex 2
...                             physCellId 51

@{PCELL_SWITCH_MSG_SEQ}         spCellConfig
...                             spCellConfigCommon
...                             physCellId 53
...                             frequencyInfoDL
...                             absoluteFrequencySSB ${CARRIER_FREQ_4}
...                             frequencyInfoUL

@{A1_BASED_PCELL_SWITCH_MSG_SEQ}                spCellConfig
...                                             spCellConfigCommon
...                                             physCellId 50
...                                             frequencyInfoDL
...                                             absoluteFrequencySSB 518910
...                                             frequencyInfoUL
*** Test Cases ***
CB013142_E_ET_TC01_B1_SA_Secondary_measurement_on_PCell_using_UE_PC_based_meas_profile_during_A2_and_A1_MR_reception_for_PCell_change
    [Documentation]
    ...   Main scenario: This test intends to verify that when A2 measurement for PCell change (NRBTS/NRCELL/a2MeasPCellSwitchEnabled) is configured
    ...   as ?rsrpCombined?, upon receiving the A2 measurement report for PCell change gNB evaluates the secondary measurement quantity included in
    ...   the A2 measurement report using A2 measurement configuration from the measurement profile, which is selected based on effective UE power
    ...   class criterion. gNB ignores the measurement report, if the A2 event criteria is not fulfilled for the RSRQ quantity.
    ...   Upon receiving the A1 measurement report for PCell change gNB evaluates the secondary measurement quantity included in the
    ...   A1 measurement report using A1 measurement configuration from the measurement profile which is selected based on
    ...   effective UE power class criterion.  gNB ignores the measurement report, if the A1 event criteria is not fulfilled for the RSRQ quantity.
    ...
    ...   UE-2 supports pc2 for band combination n41&n71&66 and it selects measurement profile (NRMEASPR_MA_SA-4 points to NRMEASPR_IAF-20) because
    ...   it has pc2 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc2.
    ...   UE-3 does not define any power class supported for band combination n41&n71&66 and it selects measurement profile (NRMEASPR_MA_SA-9 points
    ...   to NRMEASPR_IAF-19) because it has pc3 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc3.
    [Tags]    E_B1
    [Setup]   Setup For CB013142-E-B1
    Update PM Reference Table With UE Count
    FOR    ${tc_identifier}   IN    @{KPI_TC_IDENTIFIER}
        Disable Feature For E Subfeature    ${tc_identifier}
        Wait Until The Next Measurement Period Starts
        Perform CB013142-E Test Steps In Loop
        Collect And Verify PM Counters For KPI    test_instance=E_B1    tc_identifier=${tc_identifier}
    END
