*** Settings ***
Documentation    CBRS CRT suite ASOF
...              = Maintainer = CBRS Team (I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com)

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_04_Grant_Update_Procedure_maxEirp_and_channelType.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure.robot

Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_106_when_SAS_not_support_WF_GRANT_UPDATE.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1_2.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT

*** Test Cases ***

[1][1.0] CBRS_CB009800_CB008735_FeVe_04_Grant_Update_Procedure_maxEirp_and_channelType
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_04_Grant_Update_Procedure_maxEirp_and_channelType

[1][1.0] CBRS_CB009800_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock
    [Timeout]     30min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock

[1][1.0] CBRS_CB009800_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure

[1][1.0] CBRS_CB009800_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish

[1][2.0] CBRS_CB009800_CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE

[1][2.0] CBRS_CB009800_CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_with_106_when_SAS_not_support_WF_GRANT_UPDATE
    [Timeout]     20min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_106_when_SAS_not_support_WF_GRANT_UPDATE

[1][1.0] CBRS_CB009800_CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit
    [Timeout]     20min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit

[1][1.0] CBRS_CB009800_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1.2
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS24R1    SBTS00
    CBRS_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1_2