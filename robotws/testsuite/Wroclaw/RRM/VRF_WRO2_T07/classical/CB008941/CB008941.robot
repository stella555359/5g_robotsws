*** Settings ***
Documentation
...   author: Adam Chamera
...   contact: adam.chamera@nokia.com
...   This is the TESTSUITE file for feature CB008941


Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/swconfig.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008941/resources/keywords_8941.robot


Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline        AND
...              prepare_swconfig    custom_swconfig_flags=${swconfig_flags_8941}


*** Test Cases ***
CB008941-5G_06_Verify_SRS_triggered_with_PUSCH_mapping_type_B_on_DU_with_Loki_BB_HW_eCPRI_TDD_FR1_FD_Beamforming_RU
    [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation
    ...               is activated and SRS is triggered with PUSCH mapping type B, the data transmission
    ...               in eCPRI uplink contains the NR IQ of scheduled PRBs for TDD FR1 deployments,
    ...               the NR carrier supports UL PRB dynamic fragmentation. No impact when the SRS is triggered
    ...               in last symbol with PUSCH mapping type B. This Test Case will check also counters from test 08:
    ...               M55308C10002 (PRBs used for PUSCH) and M55308C10004 (PRBs available for PUSCH)
    CB008941-5G_06_Verify_SRS_triggered_with_PUSCH_mapping_type_B_on_DU_with_Loki_BB_HW_eCPRI_TDD_FR1_FD_Beamforming_RU
