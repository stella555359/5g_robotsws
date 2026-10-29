*** Settings ***
Documentation
    ...  1. Downloads SCF from ADMIN and saves it in TestFiles folder
    ...  2. Validates SCF from step1 in admin
    ...  3. Logs errors to console
    ...  4. Saves errors to files: relation_errors.txt, hardware_errors.txt and definition_errors.txt in TestFiles folder

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SKIP_PARAM_RELATION_ERRORS}  ${TRUE}  # Should relation errors be skipped -boolean (True, False)


*** Keywords ***
TC__SWM__SCF_validation_errors_check
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8889
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-8889 - Test creation
    ...  - 22.08.2018 - KW added for checking name of one of the keys (KW name:Checking key name in dict)
    ...           skippedElementsErrors/skippedElements - TAT-10888
    ...  - 27.08.2018 - added functionality of validating pdl errors on SBTS with admin revision < 14493
    ...           TAT-11932
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-8889

    Set Tags  CA-CM  CA-DEV  OWNER-wojciech.sikora@nokia.com  AUTHOR-wojciech.sikora@nokia.com  PHASE-CR1  PHASE-COMPA  SW-SBTS17  SW-SBTS18

    Step 1: Logging Relation And Definition Errors


Step 1: Logging Relation And Definition Errors
    [Timeout]  5 min

    Log  ${\n}======================================  console=true
    Log  Step 1: Logging relation and definition errors  console=true
    Log  ======================================  console=true

    Collect Scf  export_type=configuration  target_file_name=${TEST_FILES}/SCF_downloaded.xml  timeout=180

    ${errors_dict}  Validate Scf  scf_file=${TEST_FILES}/SCF_downloaded.xml  timeout=240
    ...  skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}

    Set Test Variable  ${ERRORS_DICT}

    Checking Key Name In Dict
    Set Test Variable  ${PDL_VALIDATION_DICT}  ${ERRORS_DICT["pdlValidationResult"]["logs"]}
    ${pdl_validation_status}  ${msg}  Run Keyword And Ignore Error
    ...  Dictionary Should Contain Key  ${PDL_VALIDATION_DICT}  hardwareErrors

    Log  ${\n}======================================  console=true
    Log  Validation errors(all): ${\n}${ERRORS_DICT}  console=true

    Run Keyword If  '${pdl_validation_status}'!='FAIL'
    ...  New Admin PDL Validation
    ...  ELSE
    ...  Old Admin PDL Validation

    Run Keyword If  "${ERRORS_DICT["pdlValidationResult"]["status"]}"=="FAIL"
    ...  Set Test Failed  Some relation/hardware/definition errors visible, please check your SCF file


Checking Key Name In Dict
    Set Test Variable  ${SKIPPEDELEMENTS_DICT}  ${ERRORS_DICT["niddValidationResult"]["logs"]}
    ${skipped_elements_key_status}  ${msg}  Run Keyword And Ignore Error
    ...  Dictionary Should Contain Key  ${SKIPPEDELEMENTS_DICT}  skippedElements
    Run Keyword If  '${skipped_elements_key_status}'!='FAIL'
    ...  Set Test Variable  ${SKIPPED_ELEMENTS_KEY}  skippedElements
    ...  ELSE
    ...  Set Test Variable  ${SKIPPED_ELEMENTS_KEY}  skippedElementsErrors


Old Admin PDL Validation
    Log  ======================================  console=true
    Log  ${\n}Validation results: (definition errors)  console=true
    Log  Status: ${ERRORS_DICT["niddValidationResult"]["status"]}  console=true
    Log  definitionErrors: ${ERRORS_DICT["niddValidationResult"]["logs"]["definitionErrors"]}  console=true
    Log  skippedElements: ${ERRORS_DICT["niddValidationResult"]["logs"]["${SKIPPED_ELEMENTS_KEY}"]}  console=true

    Log  ${\n}======================================  console=true
    Log  Validation results: (relation and hardware errors)  console=true
    Log  Status: ${ERRORS_DICT["pdlValidationResult"]["status"]}  console=true
    Log  hardwareErrors and relationErrors: ${\n}${ERRORS_DICT["pdlValidationResult"]["logs"]}  console=true

    ${pdl_err_evaluated}  Evaluate  str(${ERRORS_DICT["pdlValidationResult"]["logs"]})
    ${def_err_evaluated}  Evaluate  str(${ERRORS_DICT["niddValidationResult"]})

    Append To File  ${TEST_FILES}/hardware_errors__relation_errors.txt  ${pdl_err_evaluated}
    Append To File  ${TEST_FILES}/definition_errors.txt  ${def_err_evaluated}


New Admin PDL Validation
    Log  ======================================  console=true
    Log  ${\n}Validation results: (definition errors)  console=true
    Log  Status: ${ERRORS_DICT["niddValidationResult"]["status"]}  console=true
    Log  missingObjectsErrors: ${ERRORS_DICT["niddValidationResult"]["logs"]["missingObjectsErrors"]}  console=true
    Log  definitionErrors: ${ERRORS_DICT["niddValidationResult"]["logs"]["definitionErrors"]}  console=true
    Log  skippedElements: ${ERRORS_DICT["niddValidationResult"]["logs"]["${SKIPPED_ELEMENTS_KEY}"]}  console=true

    Log  ${\n}======================================  console=true
    Log  Validation results: (relation and hardware errors)  console=true
    Log  Status: ${ERRORS_DICT["pdlValidationResult"]["status"]}  console=true
    Log  hardwareErrors: ${\n}${ERRORS_DICT["pdlValidationResult"]["logs"]["hardwareErrors"]}  console=true
    Log  relationErrors: ${\n}${ERRORS_DICT["pdlValidationResult"]["logs"]["relationErrors"]}  console=true

    ${rel_err_evaluated}  Evaluate  str(${ERRORS_DICT["pdlValidationResult"]["logs"]["relationErrors"]})
    ${hard_err_evaluated}  Evaluate  str(${ERRORS_DICT["pdlValidationResult"]["logs"]["hardwareErrors"]})
    ${def_err_evaluated}  Evaluate  str(${ERRORS_DICT["niddValidationResult"]})

    Append To File  ${TEST_FILES}/hardware_errors.txt  ${hard_err_evaluated}
    Append To File  ${TEST_FILES}/relation_errors.txt  ${rel_err_evaluated}
    Append To File  ${TEST_FILES}/definition_errors.txt  ${def_err_evaluated}


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  tc_name=SWM__SCF_validation_errors_check


TC Teardown
    Common Test Teardown  collect_snapshot=never
