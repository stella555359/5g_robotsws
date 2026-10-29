*** Settings ***
Documentation
...  author:  Karol Palac
...  contact: karol.palac@nokia.com

Library     ute_ue    WITH NAME    ue
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/CB008717-5G-D.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/CB008717-5G-T.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/CB008717-5G-N.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.py

Test Setup       Run keywords
...              Connect to Coam   AND
...              ue.Require UE  UE_1  capabilities=REAL_ANDROID_UE_SA    AND
#...              ue.Require UE  UE_1  capabilities=REAL_ANDROID_QUALCOMM_SDX65    AND
...              Get Resource Usage before test  AND
...              Run keyword and ignore error    Delete active DCAP trace for BTS  10.45.173.40

Test Teardown    Run Keywords
...              keywords.Collect Snapshot    AND
...              Run keyword and ignore Error    ue.Detach UE   UE_1    AND
...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...              Run Keyword and Ignore Error    Get Resource Usage after test  AND
...              Disconnect coam

*** Test Cases ***
[1]CB008717-5G-D#B2_UL_data_transfer_over_MCGSCG
    [1]CB008717-5G-D#B2_UL_data_transfer_over_MCGSCG

[1]CB008717-5G-T#B4a_Verification_of_NRDC_preferred_path_selection_-_TCP_over_MCG_F1-U
    [1]CB008717-5G-T#B4a_Verification_of_NRDC_preferred_path_selection_-_TCP_over_MCG_F1-U

[1]CB008717-5G-T#B1a_Verification_of_ENDC_preferred_path_selection_-_TCP_over_F1-U
    [1]CB008717-5G-T#B1a_Verification_of_ENDC_preferred_path_selection_-_TCP_over_F1-U

[1]CB008717-5G-N#B4-2_[T+T+F]_Deconfiguration_of_FR1_SCells_upon_NR-DC_Setup_-_Measurement_based_SCell_Addition
    [1]CB008717-5G-N#B4-2_[T+T+F]_Deconfiguration_of_FR1_SCells_upon_NR-DC_Setup_-_Measurement_based_SCell_Addition

[1]CB008717-5G-N#B6A1_[T+F]_Activation_of_FR1_SCell_Addition_A1_measurement_upon_NR-DC_Release_-_oneShot_Dl_Fr1
    [1]CB008717-5G-N#B6A1_[T+F]_Activation_of_FR1_SCell_Addition_A1_measurement_upon_NR-DC_Release_-_oneShot_Dl_Fr1
