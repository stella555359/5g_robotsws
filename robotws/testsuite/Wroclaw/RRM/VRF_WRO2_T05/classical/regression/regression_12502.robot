*** Settings ***
Documentation    Suite description
Library         ute_ue
Library         taf.ul.messaging.mtk      WITH NAME    mtk
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/resources/bts_log_check.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012502/CB012502.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-E.robot



Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASIBL_ABILB1_3xAHCA_ENB


Suite Setup     Run keywords
...             Prepare and check TL   AND
...             Setup attenuators    AND
...             Set attenuation and check    lines=${lines_gNB_T157_AQQL}   value=0

Test Setup      Run keywords
...             Require Ue    UE_1    capabilities=REAL_SAMSUNG_UE  AND
...             Require Ue    UE_4    capabilities=REAL_QUALCOMM_UE_1  AND    #lahaina
...             Require Ue    UE_3    capabilities=REAL_QUALCOMM_UE_2  AND    #taro
...             Require Ue    UE_2    capabilities=REAL_MTK_UE    AND
...             Run Keyword and Ignore Error   Start syslog collection  AND
...             Connect to Coam    AND
...             Get SCF   AND
...             Set global variable bts id    AND
...             Get number of cells and set ID    AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


Test Teardown   Run Keywords
...             Run Keyword and Ignore Error    Stop traffic    AND
...             Sleeping cell test    AND
...             Detach all ues   AND
...             Make snapshot in case of error    AND
...             Create And Commission Delta With All Cells barred with ID barr_cells     AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Verify Crash occurrence In Syslog  AND
...             Disconnect coam

*** Test Cases ***
[1][1.0] [09]CB012502-A_80MHz_20MHz_20MHz_20MHz_bandwidth_with_different_frame_structures_on_AQQL_RU
    [Tags]   SBTS00
    ...      SBTS25R1
    [1][1.0] [09]CB012502-A_80MHz_20MHz_20MHz_20MHz_bandwidth_with_different_frame_structures_on_AQQL_RU


[1][3.0] [11]CB012502-A_80MHz_30MHz_20MHz_20MHz_bandwidth_with_different_frame_structures_on_AQQL_RU
    [Tags]   SBTS00
    ...      SBTS25R1
    [1][3.0] [11]CB012502-A_80MHz_30MHz_20MHz_20MHz_bandwidth_with_different_frame_structures_on_AQQL_RU
