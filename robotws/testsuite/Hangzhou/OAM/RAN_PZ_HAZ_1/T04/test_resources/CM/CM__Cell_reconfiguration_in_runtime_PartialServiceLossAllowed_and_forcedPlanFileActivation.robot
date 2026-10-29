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
${VALID_PARAMS_JSON_FILE}    TestDataSet/DeltaCommission/PartialServiceLossAllowed_and_forcedPlanFileActivationFalse.yaml
${FLAG}      ${false}    # The flag to check wheter need to perform commision to recovery BTS configuration
${COMMISSIONING_PATH}   /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
# The full commision SCF file location
${RECOVER_PARAMS_JSON_FILE}    TestDataSet/DeltaCommission/LNBTS_Recover.yaml    # Json data file for step3
# Json data file for step4
${VALID_PARAMS_JSON_FILE1}    TestDataSet/DeltaCommission/PartialServiceLossAllowed_and_forcedPlanFileActivationTrue.yaml

*** Keywords ***
CM__Cell_reconfiguration_in_runtime_PartialServiceLossAllowed_and_forcedPlanFileActivationFalse
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  - Delta plan validation and activation to test parameters
    ...    PartialServiceLossAllowed and forcedPlanFileActivationFalse
    ...  The main steps performed for the test are:
    ...  - PartialServiceLossAllowed_and_forcedPlanFileActivationFalse
    ...  - Check if cell has been locked and BTS not reset
    ...  - Recover the environment
    ...  - PartialServiceLossAllowed_and_forcedPlanFileActivationTrue
    ...  - Check if cell has been locked and BTS not reset
    ...  Pass criteria: All scf validate and activate are as expected.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.04.2021 - Commit to GIT
    ...  - 16.12.2022 - Add checkpoint from BOAM_ET_LTE2060,[TC_02]LTE2060-B-e-Cell_parameter_change-partial_service_loss_forcedPlanActivation=true

    Set Tags    CA-CM    OWNER-lixin.kang@nokia-sbell.com    MAINTAINER-lixin.kang@nokia-sbell.com
    ...    AUTHOR-bin.7.liu@nokia-sbell.com    PHASE-CRT    SW-SBTS21B    GROUP_IN_CHARGE-SRAN_PROD_HZ1
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: PartialServiceLossAllowed_and_forcedPlanFileActivationFalse
    Step 2: Check if cell has been locked and BTS not reset
    Step 3: Recover the environment
    Step 4: PartialServiceLossAllowed_and_forcedPlanFileActivationTrue
    Step 5: Check if cell has been locked and BTS not reset

Step ${index}: PartialServiceLossAllowed_and_forcedPlanFileActivationFalse
    [Timeout]    10 minutes
    Log    Step ${index}: PartialServiceLossAllowed_and_forcedPlanFileActivationFalse    console=True
    ${obj_path}    Get LNBTS Obj
    Create Random LNBTS TestData    ${VALID_PARAMS_JSON_FILE}
    ${rel_validate}    coam.perform_delta_recommissioning    tmp_data.json    ${True}    timeout=600s
    Set Test Variable    ${FLAG}    ${True}
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

Step ${index}: Check if cell has been locked and BTS not reset
    [Timeout]    15 minutes
    Log    Step ${index}: Check if cell has been locked and BTS not reset    console=True
    Save infomodel log    ${BTS Files}/IM/InfoModel_log_for_reset_check_${index}.ims2
    Initialize ims2 validator    ${BTS Files}/IM/InfoModel_log_for_reset_check_${index}.ims2
    ${all_cell}    Infomodel Get Objects Parameter    /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*    dist_name
    Sort List    ${all_cell}
    ${cell_count}    Get Length    ${all_cell}
    ${json_str}    OperatingSystem.Get File    tmp_data.json
    ${json_str}    Replace Variables    ${json_str}
    ${sl}    Get Regexp Matches    ${json_str}    MRBTS\-\\d\+\/LNBTS\-\\d+\/LNCEL\-\\d\+
    ${count}    Get Length    ${sl}
    FOR    ${index}    IN RANGE    0    ${count}
        Add expected ims2 event    change ${all_cell[${index}]} [ stateInfo.automaticBlockState: * -> Blocked ]
    END
    Validate ims2
    FOR    ${index}    IN RANGE    ${count}    ${cell_count}
        Add expected ims2 event    change ${all_cell[${index}]} \ [ stateInfo.automaticBlockState: * -> Blocked ]
        Run keyword and expect error    *    Validate ims2
    END
    Add expected ims2 event    reset
    Run keyword and expect error    *    Validate ims2
    Log    BTS reset occurence hasn't been found inside InfoModel    console=True

Step ${index}: Recover the environment
    Log    Step ${index}: Recover the environment    console=True
    Create Random LNBTS TestData    ${RECOVER_PARAMS_JSON_FILE}
    ${rel_validate}    Run Keyword If    ${FLAG}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
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
        ${p_value}    Set Variable    ${p_list[0]["value"]}
        L_XML.Element Text Should Be    ${scf_xml}    ${p_value}    .//managedObject[@distName="${DN}"]/p[@name="${p_name}"]
    END

Step ${index}: PartialServiceLossAllowed_and_forcedPlanFileActivationTrue
    Log    Step ${index}: PartialServiceLossAllowed_and_forcedPlanFileActivationTrue    console=True
    Create Random LNBTS TestData    ${VALID_PARAMS_JSON_FILE1}
    ${rel_validate}    coam.perform_delta_recommissioning    tmp_data.json    ${True}    timeout=600s
    Set Test Variable    ${FLAG}    ${True}
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

CaseTearDown
    Log    CaseTearDown    console=True
    Create Random LNBTS TestData    ${RECOVER_PARAMS_JSON_FILE}
    ${rel_validate}    Run Keyword If    ${FLAG}    coam.perform_delta_recommissioning    tmp_data.json    ${True}
    Log    ${rel_validate}
    Common Test Teardown SBTS
