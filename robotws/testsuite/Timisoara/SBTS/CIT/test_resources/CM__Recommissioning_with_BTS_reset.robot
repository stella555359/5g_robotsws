*** Settings ***
Documentation
    ...  SBTS recommissioning procedure. For recommissioning function purposes, user needs to pass PARAMETER_SCF_DIST_NAME
    ...  from SCFC MOC, in which desired PARAMETER_ABBREVIATION resides. After recommissioning PARAMETER_ABBREVIATION should have specified
    ...  PARAMETER_VALUE. This is verified in IM according to PARAMETER_IM_DIST_NAME in which specified PARAMETER_ABBREVIATION should be placed.
    ...  In PARAMETER_IM_DIST_NAME value wildcard notation can be used (or full distName path). SKIP_PARAM_RELATION_ERRORS will skip relation
    ...  errors and won't fail TC if these will occur.
    ...
    ...  * If the value has changed and BTS is fully operational - Test is PASSED
    ...
    ...  * If the value hasn't changed or BTS is not fully operational - Test is FAILED.
    ...
    ...  **NOTE**
    ...
    ...  * In default parameter 'timeZone' has been choosed because change of its value will trigger reset and won't affect BTS functionality,
    ...
    ...  * You can change all input params but you need to ensure that the change will trigger BTS reset,
    ...
    ...  * If you want to go back to previous value from commissioning, you need to launch TC again with previous data
    ...
    ...  * For now only 'update' operation is working
    ...
    ...  * PARAMETER_IM_DIST_NAME should contain path to object, which will reflect SCF structure in IM (object with _A postfix)
    ...
    ...  * Please follow http://doc.ute.inside.nsn.com/packages/ute_infomodel/interfaces/ute_infomodel.html#query-infomodel
    ...  to find how to define PARAMETER_IM_DIST_NAME using wildcards

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${PARAMETER_SCF_DIST_NAME}  MRBTS-18231/MNL-1/MNLENT-1/SYNC-1/TIME-1  # Parameter dist_name path from SCFC
${PARAMETER_IM_DIST_NAME}  //TIME_A-1  # Parameter dist_name path from IM (IM _A object) for verification
# before and after recommissioning
${PARAMETER_ABBREVIATION}  timeZone  # Parameter abbreviation from SCFC
${PARAMETER_OPERATION}  update  # Operation, which should be performed (update)
${PARAMETER_VALUE}  (GMT+1) Europe/Vienna  # Parameter value
${SKIP_PARAM_RELATION_ERRORS}  ${TRUE}  # Should recommissioning be done forcefully (True, False)
${RECOMMISSIONING_TIMEOUT}  600  # Timeout for recommissioning procedure (parameter change, reset indication,
# wait for reconnection after reset)


*** Keywords ***
TC__CM__Recommissioning_with_BTS_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4076
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.10.2016 - https://jira3.int.net.nokia.com/browse/TAT-4076 - Test creation
    ...  - 13.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4905 - Add SSH snapshot collecting to teardown
    ...  - 21.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-6040 - Minor modifications
    ...  - 05.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7017 - Adjust TC to working feature in SW
    ...  - 14.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7017 - Remove waiting for reset event in IM as ADMIN KW cover the BTS reconnection
    ...  - 07.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7622 - Add explicit reset check in step 3
    ...  - 12.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7441 - Correct bug with timeZone
    ...  - 26.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9490 - Remove timeout tag from commissioning step
    ...  - 30.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9980 - Move KW for reset check and BTS check to resources
    ...  - 07.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-12753 - Symlink this TC to SBTS18/RGT
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4076_01.png

    Set Tags  CA-SWM  OWNER-bogdan.butcovan@nokia.com  AUTHOR-patryk.furman@nokia.com  PHASE-CR1  SW-SBTS17  SW-SBTS18

    Step 1: Check Parameter Value In InfoModel Before Recommissioning
    Step 2: SBTS Recommissioning Via ADMIN API
    Step 3: Check If BTS Reset Was Triggered
    Step 4: Check Parameter Value In InfoModel After Recommissioning
    Step 5: Check SBTS State After Recommissioning


Step 1: Check Parameter Value In InfoModel Before Recommissioning
    [Timeout]  15 min

    Log  Step 1: Check parameter value from InfoModel before recommissioning  console=True
    Query Infomodel  check ${PARAMETER_IM_DIST_NAME} is [${PARAMETER_ABBREVIATION}!="${PARAMETER_VALUE}"]  timeout=10
    Log  Parameter ${PARAMETER_ABBREVIATION} value is different than ${PARAMETER_VALUE}. Recommissioning will proceed  console=True


Step 2: SBTS Recommissioning Via ADMIN API
    Log  Step 2: SBTS recommissioning via ADMIN API  console=True
    Perform Parameter Recommissioning  dist_name=${PARAMETER_SCF_DIST_NAME}  parameter=${PARAMETER_ABBREVIATION}  operation=${PARAMETER_OPERATION}
    ...  value=${PARAMETER_VALUE}  skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}  timeout=${RECOMMISSIONING_TIMEOUT}
    Log  Recommissioning done. Reset event check will be launched  console=True


Step 3: Check If BTS Reset Was Triggered
    [Timeout]  15 min

    Log  Step 3: Check reset event occurence in InfoModel  console=True
    ${was_triggered}  Infomodel Check IM Log If BTS Reset Was Triggered  ${BTS_FILES}/IM/InfoModel_log_for_reset_check.ims2
    Should Be True  ${was_triggered}  Reset event wasn't found inside IM log!
    Log  BTS reset occurence has been found inside InfoModel  console=True


Step 4: Check Parameter Value In InfoModel After Recommissioning
    [Timeout]  15 min

    Log  Step 4: Check parameter value in InfoModel after recommissioning  console=True
    Query Infomodel  check ${PARAMETER_IM_DIST_NAME} is [${PARAMETER_ABBREVIATION}="${PARAMETER_VALUE}"]  timeout=60
    Log  Parameter ${PARAMETER_ABBREVIATION} value has been changed to ${PARAMETER_VALUE}  console=True


Step 5: Check SBTS State After Recommissioning
    [Timeout]  20 min

    Log  Step 5: Check SBTS state after commissioning  console=True
    Wait Until Keyword Succeeds  15 min  15 sec
    ...  Admin Check SBTS Cells, Modules And Alarms TAF


TC Setup
    Common Test Setup  tc_name=CM__Recommissioning_with_BTS_reset


TC Teardown
    Common Test Teardown
