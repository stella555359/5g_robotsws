*** Settings ***
Documentation
...  contact: Szymon Startek

Resource    ./resources/CB010823_keywords.robot


*** Variables ***
${RMOD_SN}                    # RU serial number
${CONNECTION}    gNB          # defined for ADMIN, connection type, default gNB
${EXPECTED_STATUS}            # Expected status of checkpoint
${CHECKPOINT_ID}              # Key in DC Report dict to checkpoint id
${DISTINGUISHED_NAME}         # Key in DC Report dict to path to rmod
${LAST_RESULT}                # Key in DC Report dict to last status of checkpoint


*** Keywords ***
TC__CB010823_CP41_Run_Diagnostic_check_from_WebEM
    Step 1: Preconditions
    Step 2: Execute Diagnostic Check CP 41
    Step 3: Get DC report and check memory usage OK status


Step 1: Preconditions
    Set Parameters Names

    Log to console  --------------------
    Log to console  Step 1: Preconditions
    Log to console  --------------------${\n}

    Check If RMOD Is Avaliable In Config And Prepare Distname For Diagnostic Check


Step 2: Execute Diagnostic Check CP 41
    Log to console  ${\n}---------------------------
    Log to console  Step 2: Run Diagnostic Check
    Log to console  ---------------------------${\n}
    ${DC_1_result}  Run Diagnostic Check  timeout=500  connection=${CONNECTION}
    Log to console  Diagnostic Check finished. [OK]


Step 3: Get DC report and check memory usage OK status
    Log to console  ${\n}---------------------------
    Log to console  Step 3: Get DC report and check memory usage '${EXPECTED_STATUS}' status
    Log to console  ---------------------------${\n}

    Get DC Report And Check CP Result  41


Set Parameters Names
    ${is_new}=  Evaluate  '${RELEASE_LOCAL}' >= 'SBTS25R1'
    ${checkpointId}=  Set Variable If  ${is_new}  checkpoint  checkpointId
    Set Test Variable  ${CHECKPOINT_ID}  ${checkpointId}
    ${distinguishedName}=  Set Variable If  ${is_new}  targetDistinguishedName  distName
    Set Test Variable  ${DISTINGUISHED_NAME}  ${distinguishedName}
    ${lastResult}=  Set Variable If  ${is_new}  lastDefinitiveCheckStatus  lastResult
    Set Test Variable  ${LAST_RESULT}  ${lastResult}
    ${expected_status}=  Set Variable If  ${is_new}  Check point successful  OK
    Set Test Variable  ${EXPECTED_STATUS}  ${expected_status}


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True

