*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
# Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)
${COMMISSIONING_TIMEOUT}    600
# Json data file for step1
${base_path}    /home/ute/testline_configuration/10_5_UTESRAN1813/testdata
${VALID_PARAMS_JSON_FILE1}    ${base_path}/TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationFalse.yaml
# Json data file for step4
${VALID_PARAMS_JSON_FILE2}    ${base_path}/TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationFalseFail.yaml
# Json data file for step6
${VALID_PARAMS_JSON_FILE3}    ${base_path}/TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationTrue.yaml
# Json data file for step3
${RECOV_PARAMS_JSON_FILE}    ${base_path}/TestDataSet/DeltaCommission/LNBTS_Recover.yaml
# The flag to check wheter need to perform commision to recovery BTS configuration
${FLAG}           ${false}

*** Keywords ***
CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Delta plan validation and activation to test parameters NoServiceLossAllowed and forcedPlanFileActivation
    ...  The main steps performed for the test are:
    ...  - NoServiceLossAllowed_and_forcedPlanFileActivationFalse
    ...  - Check if BTS reset wasn't triggered
    ...  - Recover the environment
    ...  - NoServiceLossAllowed_and_forcedPlanFileActivationFalse_Fail
    ...  - Check if BTS reset wasn't triggered
    ...  - NoServiceLossAllowed_and_forcedPlanFileActivationTrue
    ...  - Check if BTS reset wasn't triggered
    ...  Pass criteria: All scf validate and activate are as expected.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.04.2021 - Commit to GIT

    Set Tags    CA-CM    OWNER-lixin.kang@nokia-sbell.com    MAINTAINER-lixin.kang@nokia-sbell.com
    ...    AUTHOR-bin.7.liu@nokia-sbell.com    PHASE-CRT    SW-SBTS21B    GROUP_IN_CHARGE-SRAN_PROD_HZ1   API
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: NoServiceLossAllowed_and_forcedPlanFileActivationFalse
    Step 2: Check if BTS reset wasn't triggered
    Step 3: Recover the environment
    Step 4: NoServiceLossAllowed_and_forcedPlanFileActivationFalse_Fail
    Step 5: Check if BTS reset wasn't triggered
    Step 6: NoServiceLossAllowed_and_forcedPlanFileActivationTrue
    Step 7: Check if BTS reset wasn't triggered

Step ${index}: NoServiceLossAllowed_and_forcedPlanFileActivationFalse
    [Timeout]    5 min
    Log    Step ${index}: NoServiceLossAllowed_and_forcedPlanFileActivationFalse    console=True
    ${obj_path}    Get LNBTS Obj
    Create Random LNBTS TestData    ${VALID_PARAMS_JSON_FILE1}
    ${rel_validate}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Set Global Variable    ${FLAG}    ${True}
    Log    ${rel_validate}

Step ${index}: Check if BTS reset wasn't triggered
    [Timeout]    15 minutes
    Log    Step ${index}: Check if BTS reset wasn't triggered    console=True
    Save infomodel log    ${BTS Files}/IM/InfoModel_log_for_reset_check.ims2
    Initialize ims2 validator    ${BTS Files}/IM/InfoModel_log_for_reset_check.ims2
    Add expected ims2 event    reset
    Run keyword and expect error    *    Validate ims2
    Log    BTS reset occurence hasn't been found inside InfoModel    console=True

Step ${index}: Recover the environment
    Log    Step ${index}: Recover the environment    console=True
    Create Random LNBTS TestData    ${RECOV_PARAMS_JSON_FILE}
    ${rel_validate}    Run Keyword If    ${FLAG}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Log    ${rel_validate}

Step ${index}: NoServiceLossAllowed_and_forcedPlanFileActivationFalse_Fail
    Log    Step ${index}: NoServiceLossAllowed_and_forcedPlanFileActivationFalse_Fail    console=True
    Create Random LNBTS TestData    ${VALID_PARAMS_JSON_FILE2}
    ${rel_validate}    Run Keyword And Expect Error    *    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Set Global Variable    ${FLAG}    ${True}
    Log    ${rel_validate}

Step ${index}: NoServiceLossAllowed_and_forcedPlanFileActivationTrue
    Log    Step ${index}: NoServiceLossAllowed_and_forcedPlanFileActivationTrue    console=True
    Create Random LNBTS TestData    ${VALID_PARAMS_JSON_FILE3}
    ${rel_validate}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Set Global Variable    ${FLAG}    ${True}
    Log    ${rel_validate}

Case TearDown
    Log    Case TearDown    console=True
    Create Random LNBTS TestData    ${RECOV_PARAMS_JSON_FILE}
    ${rel_validate}    Run Keyword If    ${FLAG}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Log    ${rel_validate}
    Common Test Teardown SBTS
