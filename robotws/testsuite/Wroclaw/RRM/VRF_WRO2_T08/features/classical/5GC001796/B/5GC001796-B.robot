*** Settings ***
Library    taf.ue
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC001796/B/resources/test_specific_keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Documentation  Test Cases for feature 5GC001796-B execution

Force Tags      CA_VRF_WRO2

Suite Setup     Run Keywords
...             Prepare Testline                            AND
...             Setup default olla parameters               AND
...             Initialise attenuator                       AND
...             taf.ue.Require UE   UE_1   capabilities=REAL_UE    AND
...             taf.ue.Require Cell    alias=CELL_1    lnbts_id=${tl.enbs[0].global_bts_id}     lcr_id=1     AND
...             taf.ue.Set Ue Location    UE_1    CELL_1
Suite Teardown  Teardown attenuator
Test Setup      Set TESTNAME without spaces
Test Teardown   Test Teardown

*** Test Cases ***
[1]5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaSinr
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA

[1]5GC001796_BB_TC65_DL_LA_Check_NIDD_impact_on_Update_of_iniDeltaCqi_BW-5MHz_NSA
    [Documentation]  check that new improvement of 1796-B is not applied: update of iniDeltaCqi occurs when NIDD parameter is set to FALSE.
    ...              Also check that new improvement of 1796-B is applied and No update of iniDeltaCqi occurs for highest,
    ...              lowest MCS and 1796-A case when NIDD parameter is set to TRUE (default value).
    5GC001796_BB_TC65_DL_LA_Check_NIDD_impact_on_Update_of_iniDeltaCqi_BW-5MHz_NSA
