*** Settings ***
Documentation

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008152/CB008152-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # Beucause of Connect to coam kw, will
# be moved to common_keywords.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASIML_ABIPB1_1xAHFIB_ENB

Suite Setup     Run keywords
...             Setup attenuators  AND
...             Prepare and check TL  AND
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1  AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2

Test Setup      Run Keywords
...             Run Keyword and Ignore Error  Start syslog collection  AND
...             Connect To Coam

Test Teardown   Run keywords
...             Make snapshot in case of error    AND
...             Disconnect coam    AND
...             Detach Ue  UE_1    AND
...             Detach Ue  UE_2    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error   Verify Crash occurrence In Syslog  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test

*** Test Cases ***

[1]CB008152-B.B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP
    [1]CB008152-B.B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP

[1]CB008152-B.B4_05_02_SA_2UEs_FDD_35MHz_PeakTput_UL_DL_ABIQ
    [1]CB008152-B.B4_05_02_SA_2UEs_FDD_35MHz_PeakTput_UL_DL_ABIQ

[1]CB008152-B.B5_20_03_SA_FDD_35MHz_CB008532_4CC_DL_CA_1T+3F
    [1]CB008152-B.B5_20_03_SA_FDD_35MHz_CB008532_4CC_DL_CA_1T+3F
