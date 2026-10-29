*** Settings ***
Documentation    Suite description
Library         ute_ue
Library         taf.ul.messaging.mtk      WITH NAME    mtk
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/5GC000865.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-E.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/resources/bts_log_check.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot


Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CIT
...             RAN_5GSC_CIT  RAN_5G_CIT
...             CLOUD_5G_CLASSICAL_QC_ASIBL_ABILB1_3xAHCA_ENB
# ...             CLOUD_5G_CLASSICAL_QC_ASIBL_ABILB1_3xAHCA_ENB_NOVMREINSTALL

Suite Setup     Run keywords
...             Prepare and check TL   AND
...             Setup attenuators

Test Setup      Run keywords
...             Reserve UEs MTK For tests  AND
...             Run Keyword and Ignore Error   Start syslog collection  AND
...             Connect to Coam   AND
...             Get SCF   AND
...             Set global variable bts id    AND
...             Get number of cells and set ID   AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Set initial attenuation

Test Teardown   Run Keywords
...             Sleeping cell test    AND
...             Detach UEs Used By Test   AND
...             Make snapshot in case of error    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Disconnect coam

*** Test Cases ***
[1]5GC000900-C_30_Successful_NSA_and_SA_calls_setup_in_NSA+SA_cell
    [Tags]   SBTS23R1
    ...      SBTS00
    [1]5GC000900-C_30_Successful_NSA_and_SA_calls_setup_in_NSA+SA_cell

[1]5GC002534-A_44_PDSCH traffic at SSB slot for multiple users with PRB blanking. NSA+SA. chBW=20MHz
    [Tags]   SBTS23R1
    ...      SBTS00
    [1]5GC002534-A_44_PDSCH traffic at SSB slot for multiple users with PRB blanking chBW=20MHZ
