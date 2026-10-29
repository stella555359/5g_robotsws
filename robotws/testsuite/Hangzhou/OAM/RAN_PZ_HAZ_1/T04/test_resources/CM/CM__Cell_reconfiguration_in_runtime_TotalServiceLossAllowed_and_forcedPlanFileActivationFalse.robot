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
${VALID_PARAMS_JSON_FILE_1}    TestDataSet/DeltaCommission/TotalServiceLossAllowed_and_forcedPlanFileActivationFalse_1.yaml
 # Json data file for step2
${VALID_PARAMS_JSON_FILE_2}    TestDataSet/DeltaCommission/TotalServiceLossAllowed_and_forcedPlanFileActivationFalse_2.yaml
# Json data file for step4
${VALID_PARAMS_JSON_FILE_3}    TestDataSet/DeltaCommission/TotalServiceLossAllowed_and_forcedPlanFileActivationFalse_3.yaml
${RECOVER_PARAMS_JSON_FILE}    TestDataSet/DeltaCommission/LNBTS_Recover.yaml    # Json data file for recovery in teardown
${FLAG}        ${False}    # The flag to check wheter need to perform commision to recovery BTS configuration

*** Keywords ***
CM__Cell_reconfiguration_in_runtime_TotalServiceLossAllowed_and_forcedPlanFileActivationFalse
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  - Delta plan validation and activation to test parameters TotalServiceLossAllowed and forcedPlanFileActivation
    ...  The main steps performed for the test are:
    ...  - DeltaCommission via ADMIN API Expect Fail
    ...  - VALID_PARAMS_JSON_FILE_2 DeltaCommission via ADMIN API
    ...  - Check if cell has been Disabled and BTS not reset
    ...  - VALID_PARAMS_JSON_FILE_3 DeltaCommission via ADMIN API
    ...  - Check if cell has been Disabled and BTS not reset
    ...  Pass criteria: All scf validate and activate are as expected.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.04.2021 - Commit to GIT
    ...  - 16.12.2022 - Add checkpoint from BOAM_ET_LTE2060,[TC_01]LTE2060-B-e-Cell_parameter_change-partial_service_loss

    Set Tags    CA-CM    OWNER-lixin.kang@nokia-sbell.com    MAINTAINER-lixin.kang@nokia-sbell.com
    ...    AUTHOR-bin.7.liu@nokia-sbell.com    PHASE-CRT    SW-SBTS21B    GROUP_IN_CHARGE-SRAN_PROD_HZ1   API
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: DeltaCommission via ADMIN API Expect Fail
    Step 2: VALID_PARAMS_JSON_FILE_2 DeltaCommission via ADMIN API
    Step 3: Check if all LTE cells has been Disabled and BTS not reset
    Step 4: VALID_PARAMS_JSON_FILE_3 DeltaCommission via ADMIN API
    Step 5: Check if all LTE cells has been Disabled and BTS not reset

Step ${index}: DeltaCommission via ADMIN API Expect Fail
    [Timeout]    5 min
    Log    Step ${index}: DeltaCommission via ADMIN API Expect Fail    console=True
    ${obj_path}    Get LNBTS Obj
    Create Random LNBTS TestData    ${VALID_PARAMS_JSON_FILE_1}
    ${rel_validate}    Run Keyword And Expect Error    *    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Log    ${rel_validate}

Step ${index}: ${validate_param_file} DeltaCommission via ADMIN API
    Log    Step ${index}: ${validate_param_file} DeltaCommission via ADMIN API    console=True
    Create Random LNBTS TestData    ${${validate_param_file}}
    ${rel_validate}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Set Test Variable    ${FLAG}    ${True}
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Log    ${rel_validate}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse Xml    ${BTS_scf}
    ${params}    Load Json File    tmp_data.json
    FOR    ${param}    IN    @{params}
        ${DN}    Get From Dictionary    ${param}    distName
        ${p_list}    Get From Dictionary    ${param}    parameters
        Should Be Equal As Integers    ${p_list.__len__()}    ${1}
        ${p_name}    Set Variable    ${p_list[0]["parameterName"]}
        ${p_value}    Set Variable If    "${p_name}"=="forcedPlanFileActivation"    false    ${p_list[0]["value"]}
        L_XML.Element Text Should Be    ${scf_xml}    ${p_value}    .//managedObject[@distName="${DN}"]/p[@name="${p_name}"]
    END

Step ${index}: Check if all LTE cells has been Disabled and BTS not reset
    Log    Step ${index}: Check if cell has been locked and BTS not reset    console=True
    Save infomodel log    ${BTS Files}/IM/InfoModel_log_for_reset_check_${index}.ims2
    Initialize ims2 validator    ${BTS Files}/IM/InfoModel_log_for_reset_check_${index}.ims2
    Add expected ims2 event    reset
    Run keyword and expect error    *    Validate ims2
    ${all_lte_cell}    Infomodel Get Objects Parameter   /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*   dist_name
    FOR    ${cell}    IN    @{all_lte_cell}
        Add expected ims2 event    change ${cell} [ stateInfo.operationalState: * -> Disabled ]
    END
    Validate ims2
    Log    BTS reset occurence hasn't been found inside InfoModel    console=True

CaseTearDown
    Log    CaseTearDown    console=True
    Create Random LNBTS TestData    ${RECOVER_PARAMS_JSON_FILE}
    ${rel_validate}    Run Keyword If    ${FLAG}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Log    ${rel_validate}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS
