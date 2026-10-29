*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/CB009262-I_AVHA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010801/CB010801_AVHA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/CB009208-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/CB009208-J.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # Beucause of Connect to coam kw, will
# be moved to common_keywords.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASIML_ABIPB1_1xAVHA

Suite Setup     Run keywords
...             Prepare and check TL  AND
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1  AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2  AND
...             Require Ue    UE_3    capabilities=REAL_ANDROID_UE_3  AND
...             Require Ue    UE_4    capabilities=REAL_ANDROID_UE_4

Test Setup      Run Keywords
...             Connect To Coam   AND
...             Run Keyword and Ignore Error   Start syslog collection

Test Teardown   Run keywords
...             Make snapshot in case of error    AND
...             Disconnect coam    AND
...             Detach Ue  UE_1    AND
...             Detach Ue  UE_2    AND
...             Detach Ue  UE_3    AND
...             Detach Ue  UE_4    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error   Syslog checker for suspicious logs  AND
...             Verify Crash occurrence In Syslog  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test

*** Test Cases ***

CB009262-SR-I_CB008701_16DL_4Ues_noRankDowngrade
    CB009262-SR-I_CB008701_16DL_4Ues_noRankDowngrade

CB010801-SR-C_2CC_16DL8UL+1CC8DL8UL_100_50_30_DL_MU-MIMO_with_CA
    [Tags]      SBTS00
    CB010801-SR-C_2CC_16DL8UL+1CC8DL8UL_100_50_30_DL_MU-MIMO_with_CA
