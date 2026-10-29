*** Settings ***
Documentation    Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library  taf.sbts.oam.coam.admin  WITH NAME  admin

Library  Collections
Library  DateTime
Library  String
Library    taf.sw.reporting_portal    WITH NAME    rp

*** Variables ***
${CUSTOM_LOOP_FIRST_FAIL}  ${False}  # True TC fails after first failed verdict, loop execution is ended
                                     # False -> (default value) TC doesn't fail after first fail, loop execution is continued
${CUSTOM_LOOP_LOGS_OPTIMIZATION}  ${True}  # True ->(default value) Only logs from Failed loop execution and
                                                    #Passed loop before Failed execution will be stored
                                           # False  All logs, from all loops will be stored
${CUSTOM_LOOP_RECOVERY}  ${False}    # True If TC leave BTS not onAir or with unexpected fault, site reset will be triggered
                                     # False -> (default value) No recosvery action in case not OnAir state after TC execution
${CUSTOM_LOOP_RECOVERY_COUNTER}    ${3}   # It's valid only if ${CUSTOM_LOOP_RECOVERY} True. Max amount of recovery action during loop execution,
                                          # loop will be stopped when ${CUSTOM_LOOP_RECOVERY_COUNTER}+1 recovery action should be triggered
${CUSTOM_LOOP_FAIL_IN_ROW_COUNTER}   ${2}   # max amount of Failed verdicts in the row after which loop should be stopped.
                                            # It's valid only if ${CUSTOM_LOOP_FIRST_FAIL}  ${False}


*** Keywords ***
Execute Test In Loop
    [Arguments]    ${TC_name}
    [Documentation]
    ...  Description:
    ...  Main KW for execution Test Case in loop. This KW also uses global variables.Check variables description in Variables section.
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Argument         | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | TC_name          | Yes  | Test case name, which will be executed in loop          |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com
    Run Keyword And Return If  ${REPETITION_COUNT}==1  ${TC_name}
    Loop Precondition
    FOR    ${iteration}  IN    @{REPETITION_LIST}
      Loop Iteration Precondition   ${iteration}  ${TC_name}
      TC  ${TC_name}
      Loop Iteration Postcondition
    END
     Run Keyword If  'FAIL' in @{LOOP_VERDICT_LIST}  Fail  Loops ${NUMBERS_OF_FAILS_LOOP_LIST} have failed verdict, check logs.

    [Teardown]  Loop Create Execution Report


TC
    [Arguments]    ${TC_name}
    Run Keyword And Continue On Failure  ${TC_name}

    [Teardown]   Run Keywords
                 ...    Set Test Variable    ${LOOP_VERDICT}   ${KEYWORD_STATUS}  AND
                 ...    Run Keyword if  '${KEYWORD_STATUS}'=='FAIL'  Set Test Variable    ${LOOP_MESSAGE}   ${KEYWORD_MESSAGE}


Loop Precondition
    [Documentation]
    ...  Description:
    ...  Precondition KW for execution TC in loop.Prepares needed lists and variables.
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com

    @{loop_verdict_list}  Create List
    Set Test Variable  ${LOOP_VERDICT_LIST}  ${loop_verdict_list}
    @{loop_fail_in_row_list}  Create List
    Set Test Variable  ${LOOP_FAIL_IN_ROW_LIST}  ${loop_fail_in_row_list}
    @{numbers_of_fails_loop_list}  Create List
    Set Test Variable  ${NUMBERS_OF_FAILS_LOOP_LIST}  ${numbers_of_fails_loop_list}
    Set Test Variable  ${INTERNAL_LOOP_RECOVERY_COUNTER}  ${0}


Loop Iteration Precondition
    [Arguments]  ${iteration}  ${TC_name}
    [Documentation]
    ...  Description:
    ...  Iteration precondition KW for execution TC in loop.
    ...
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | iteration              | Yes  | Loop iteration number                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | TC_name                | Yes  | Test Case name which will be executed in loop                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com

      Set Test Variable  ${ITERATION}  ${iteration}
#      Set Test Variable   ${TEST_LOGS_PATH}   ${CFG.test_logs_path}/Loop_${ITERATION}
      Logging With Timestamp   message=${TC_name}  style=TC
      Logging With Timestamp   message=-------LOOP_${ITERATION} EXECUTION-------   style=STEP


Loop Iteration Postcondition
    [Documentation]
    ...  Description:
    ...  Iteration postcondition KW for execution TC in loop.This KW also uses global variables.Check variables description in Variables section.
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com

    Run Keyword If  '${LOOP_VERDICT}'=='PASS'  Run Keywords
    ...  Logging With Timestamp  message=LOOP_${ITERATION} finished with verdict: ${LOOP_VERDICT}  style=PASS  AND
    ...  Logging With Timestamp  message=LOOP_${ITERATION} verdict: ${LOOP_VERDICT}  style=PASS  console=${False}  output_file=tc_verdicts_report.txt
    Run Keyword If  '${LOOP_VERDICT}'=='FAIL'  Run Keywords
    ...  Append To List  ${NUMBERS_OF_FAILS_LOOP_LIST}  ${ITERATION}  AND
    ...  Logging With Timestamp  message=LOOP_${ITERATION} finished with verdict: ${LOOP_VERDICT}  message_2=FAIL REASON: ${LOOP_MESSAGE}
    ...  style=FAIL  AND
    ...  Logging With Timestamp   message=LOOP_${ITERATION} verdict: ${LOOP_VERDICT}
    ...  style=FAIL  console=${False}  output_file=tc_verdicts_report.txt  AND
    ...  Logging With Timestamp  message=FAIL REASON: ${LOOP_MESSAGE}  frame=${True}  console=${False}  output_file=tc_verdicts_report.txt
    Run Keyword If  ${CUSTOM_LOOP_LOGS_OPTIMIZATION}==${True} and ${LOOP_VERDICT_LIST}!=@{EMPTY} and '${LOOP_VERDICT}'=='PASS'  Loop Remove Logs
    Append To List  ${LOOP_VERDICT_LIST}  ${LOOP_VERDICT}
    Run Keyword If  ${CUSTOM_LOOP_FIRST_FAIL}==${True} and '${LOOP_VERDICT}'=='FAIL'  Fail  ${LOOP_MESSAGE}
    Run Keyword If
    ...  ${CUSTOM_LOOP_RECOVERY}==${True} and '${LOOP_VERDICT}'=='FAIL' and ${INTERNAL_LOOP_RECOVERY_COUNTER}<${CUSTOM_LOOP_RECOVERY_COUNTER}
    ...  Run Keywords  Set Test Variable  ${INTERNAL_LOOP_RECOVERY_COUNTER}  ${INTERNAL_LOOP_RECOVERY_COUNTER+1}  AND  Loop Recovery Site Reset
    ...  ELSE IF
    ...  ${CUSTOM_LOOP_RECOVERY}==${True} and '${LOOP_VERDICT}'=='FAIL' and ${INTERNAL_LOOP_RECOVERY_COUNTER}==${CUSTOM_LOOP_RECOVERY_COUNTER}
    ...  Fail  ${CUSTOM_LOOP_RECOVERY_COUNTER} recoveries was done on user demand. No more recovery try after FAIL verdict.
    Run Keyword If  '${LOOP_VERDICT}'=='FAIL'  Append To List  ${LOOP_FAIL_IN_ROW_LIST}  ${LOOP_VERDICT}
    ...  ELSE  Set Test Variable  @{LOOP_FAIL_IN_ROW_LIST}  @{EMPTY}
    ${length}  Get Length  ${LOOP_FAIL_IN_ROW_LIST}
    Run Keyword If  ${length}==${CUSTOM_LOOP_FAIL_IN_ROW_COUNTER}
    ...  Fail  ${CUSTOM_LOOP_FAIL_IN_ROW_COUNTER} failed loops in the row.Stop TC execution.Check logs.


Loop Create Execution Report
    [Documentation]
    ...  Description:
    ...  KW creates loop execution report. Example:
    ...  TC_Name: TC_Dummy
    ...  TC_verdict: PASS
    ...  Expected_number_of_loops: 2
    ...  Executed_number_of_loops: 2
    ...  FAILED_number_of_loops: 0
    ...  PASSED_number_of_loops: 2
    ...  Numbers_of_FAILED_loops: []
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com

    Return From Keyword If  ${REPETITION_COUNT}==1
    &{loop_execution_report_dict}  Create Dictionary   TC_Name=${TEST_NAME}
    Set Test Variable  ${LOOP_EXECUTION_REPORT_DICT}  ${loop_execution_report_dict}
    Set To Dictionary  ${LOOP_EXECUTION_REPORT_DICT}  TC_verdict=${KEYWORD_STATUS}
    Set To Dictionary    ${LOOP_EXECUTION_REPORT_DICT}    Expected_number_of_loops=${REPETITION_COUNT}
    Set To Dictionary    ${LOOP_EXECUTION_REPORT_DICT}    Executed_number_of_loops=${ITERATION}
    ${fail_count}  Get Count  ${LOOP_VERDICT_LIST}  FAIL
    ${pass_count}  Get Count  ${LOOP_VERDICT_LIST}  PASS
    Set To Dictionary  ${LOOP_EXECUTION_REPORT_DICT}  FAILED_number_of_loops=${fail_count}
    Set To Dictionary  ${LOOP_EXECUTION_REPORT_DICT}  PASSED_number_of_loops=${pass_count}
    Set To Dictionary  ${LOOP_EXECUTION_REPORT_DICT}  Numbers_of_FAILED_loops=${NUMBERS_OF_FAILS_LOOP_LIST}
    rp.Add To Test Data  data={"test_loops":"${ITERATION}"}
    Set Test Variable  ${REPETITION}  ${False}


Loop Remove Logs
    [Documentation]
    ...  Description:
    ...  KW removes unnecessary logs from PASS loops executions
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com

    Run Keyword If  'PASS'=='${LOOP_VERDICT_LIST[-1]}'  Remove Directory  ${CFG.test_logs_path}/Loop_${ITERATION-1}  recursive=${True}
    Run Keyword If  ${ITERATION}==${REPETITION_COUNT} and 'FAIL' in @{LOOP_VERDICT_LIST}
    ...  Remove Directory  ${CFG.test_logs_path}/Loop_${ITERATION}  recursive=${True}


Loop Recovery Site Reset
    [Documentation]
    ...  Description:
    ...  KW for recovery site reset after FAIL loop execution. UNDER CONSTRUCTION
    ...
    ...  Author: anna.maciejewska@nokia.com
    ...  Maintainer: anna.maciejewska@nokia.com

    Logging With Timestamp  message=Recovery site reset execution.
    FOR  ${node_id}  IN  @{CFG.NODES}
      admin.Reset Site  connection=${node_id}
    END
    Sleep    300s
    Wait Until Keyword Succeeds  300  60  STATE Verify Multi Node State
    ...  expected_BTS_status=OnAir
    ...  HW_check=${True}
    ...  cells_check=${True}
    ...  scf_check=${True}




