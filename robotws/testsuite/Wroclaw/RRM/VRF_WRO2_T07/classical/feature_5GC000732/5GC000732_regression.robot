*** Settings ***
Documentation   CIT regression TCs for 5GC000732 shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CRT

Library          taf.ue
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000732/A/resources/keywords_732_A.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000732/F/resources/keywords_732_F.py

Suite Setup      prepare_testline


*** Test Cases ***
5GC000732-A_1_FDD_RLF_RRC_Connection_Re-establishment_Same_Serving_Cell_Valid_UE_Context
    [Documentation]    This TC checks whether reestablishment is performed correctly.
    keywords_732_A.TC_5GC000732_A_1_FDD_RLF_RRC_Connection_Reestablishment_Same_Serving_Cell_Valid_UE_Context
    [Teardown]  keywords_732_A.TC_teardown_732_A


5GC000732-A_3_FDD_RLF_RRC_Connection_Re-establishment_With_the_Same_Serving_Cell_Counters_Update
    [Documentation]    This TC checks whether PM counters are updated correctly during reestablishment.
    keywords_732_A.TC_5GC000732_A_3_FDD_RLF_RRC_Connection_Reestablishment_With_the_Same_Serving_Cell_Counters_Update
    [Teardown]  keywords_732_A.TC_teardown_732_A


5GC000732-F_7_FDD_TDD_RLF_RRC_Connection_Re-establishment_Same_Serving_Cell_Valid_UE_Context_int_2640
    [Documentation]    This TC checks whether reestablishment works correctly with carrier aggregation.
    keywords_732_F.TC_5GC000732_F_7
    [Teardown]  keywords_732_F.F_7_teardown


5GC000732-F_10_FDD_RLF_RRC_Connection_Re-establishment_Same_Serving_Cell_Valid_UE_Context_int_VoNR_with Counters
    [Documentation]    This TC checks whether reestablishment works correctly during VoNR.
    keywords_732_F.TC_5GC000732_F_10
    [Teardown]  keywords_732_F.F_10_teardown
