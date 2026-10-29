*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Library with basic keywords responsible for creating admin and syslog session


Library  Collections
Library  DateTime
Library  String

Resource  ../Setup/setup_and_teardown.robot

*** Variables ***
${task_index}=  1
${MARVIN_SBB}=  ${False}

*** Keywords ***
ISBB Setup
  [Arguments]      ${index}  &{kwargs}
  Logging With Timestamp
  ...  message=${test_name} - Procedure started.
  ...  style=STEP
  ...  frame=${TRUE}
  IF  not ${REPETITION}
      IF  ${procedure_iteration}
        Create Testcase Directory Path For Each BTS  ${CFG.test_logs_path}/${task_index}_${test_name}/${index}/
        Set Test Variable  ${PROCEDURE_TEST_LOGS_PATH}  ${CFG.test_logs_path}/${task_index}_${test_name}/${index}/
      ELSE
        Create Testcase Directory Path For Each BTS  ${CFG.test_logs_path}/${task_index}_${test_name}/
        Set Test Variable  ${PROCEDURE_TEST_LOGS_PATH}  ${CFG.test_logs_path}/${task_index}_${test_name}/
      END
  ELSE
    IF  ${procedure_iteration}
      Create Testcase Directory Path For Each BTS  ${CFG.test_logs_path}/Loop_${ITERATION}/${task_index}_${test_name}/${index}/
      Set Test Variable  ${PROCEDURE_TEST_LOGS_PATH}  ${CFG.test_logs_path}/Loop_${ITERATION}/${task_index}_${test_name}/${index}/
    ELSE
      Create Testcase Directory Path For Each BTS  ${CFG.test_logs_path}/Loop_${ITERATION}/${task_index}_${test_name}/
      Set Test Variable  ${PROCEDURE_TEST_LOGS_PATH}  ${CFG.test_logs_path}/Loop_${ITERATION}/${task_index}_${test_name}/
    END
  END
  Logging Multinode Start  logs_dir=${PROCEDURE_TEST_LOGS_PATH}  tools_to_setup=${TOOLS_TO_SETUP}
  IF  ${procedure_iteration} and ${procedure_iteration_COUNT}!=${index}
    Set Suite Variable    ${task_index}
  ELSE IF  ${procedure_iteration} and ${procedure_iteration_COUNT}==${index}
    ${task_index}=  Evaluate    ${task_index}+1
    Set Suite Variable    ${task_index}
  ELSE
    ${task_index}=  Evaluate    ${task_index}+1
    Set Suite Variable    ${task_index}
  END
  ${check_faults_active}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.check_faults_active}
  ${check_faults_history}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.check_faults_history}
  ${check_madatory_faults}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.check_mandatory_faults}
  ${procedure_specific_faults}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.procedure_specific_faults}
  Set Suite Variable    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS_ORIGINAL}  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}
  IF  ${procedure_specific_faults}
    Append To List    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS.common}  ${kwargs.procedure_specific_faults}
  END
  IF  ${check_faults_active}
    Set Test Variable    ${CHECK_FAULTS_ACTIVE}  ${kwargs.check_faults_active}
  ELSE
    Set Test Variable    ${CHECK_FAULTS_ACTIVE}  ${False}
  END
  IF  ${check_faults_history}
    Set Test Variable    ${CHECK_FAULTS_HISTORY}  ${kwargs.check_faults_history}
  ELSE
    Set Test Variable    ${CHECK_FAULTS_HISTORY}  ${False}
  END
  IF  ${check_madatory_faults}
    Set Test Variable    ${CHECK_MANDATORY_FAULTS}  ${kwargs.check_mandatory_faults}
  ELSE
    Set Test Variable    ${CHECK_MANDATORY_FAULTS}  ${False}
  END
  FM Clear Allowed Alarms For All Nodes
  IF  ${CHECK_FAULTS_ACTIVE} or ${CHECK_FAULTS_HISTORY}
    Logging With Timestamp
    ...  message=Faults check is enabled.
    FM Add Global Faults To Allowed For All Nodes  ${GLOBAL_ALLOWED_FAULTS}
    FM Add Custom Global Faults To Allowed  node_id=${BTS_ID}
  END
#  IF  ${MARVIN_SBB}
#    marvin.Prepare And Start Marvin  test_case_name=${test_name}  marvin_side=${MARVIN_SITE}  organization=${MARVIN_ORGANIZATION}
#  END


ISBB Teardown
  [Arguments]    &{kwargs}
  ${tmp_snapshot_variable}=  Get Variable Value    ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}
  ${snapshot}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.snapshot}
  ${time_after_run}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.time_after_run}
  ${test_snapshot}=  Set Variable If  ${snapshot}  ${kwargs.snapshot}  ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}
  Set Test Variable    ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}  ${test_snapshot}
  Set Test Variable    ${PREVIOUS_TASK_LOGS_PATH}  ${PROCEDURE_TEST_LOGS_PATH}
  Set Test Variable    ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}  ${tmp_snapshot_variable}
  IF  ${time_after_run}
    Set Test Variable    ${time_after_run}  ${kwargs.time_after_run}
    Logging With Timestamp
    ...  message=Waiting ${time_after_run} seconds after run.
    sleep  ${time_after_run}
  END
  IF  ${CHECK_FAULTS_ACTIVE}
    FM Check Unexpected Active Faults  ${BTS_ID}
  END
  IF  ${CHECK_FAULTS_HISTORY}
    FM Check Unexpected History Faults  ${BTS_ID}
  END
#  IF  ${CHECK_MANDATORY_FAULTS}
#    FM Check Mandatory Faults  ${BTS_ID}
#  END
  Set To Dictionary    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}   common=@{additional_common_fault_list}
#  Set Suite Variable      ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS_ORIGINAL}
  Logging Multinode Stop  ${PROCEDURE_TEST_LOGS_PATH}  ${KEYWORD_STATUS}
#  IF  ${MARVIN_SBB}
#    marvin.Stop Marvin  wait_after_run=${False}
#  END

ISBB Check Faults Active
  [Arguments]    &{kwargs}
  Logging With Timestamp
  ...  message=Check Faults Active
  ...  style=STEP
  ...  frame=${TRUE}


ISBB Check Fault History
  [Arguments]    &{kwargs}
  Logging With Timestamp
  ...  message=Check Faults Active/History
  ...  style=STEP
  ...  frame=${TRUE}

Prepare Iteration Repetition Loop Variables
  [Arguments]    &{kwargs}
  [Documentation]
  ...  Description:
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  &{main_dict}=  Copy Dictionary    ${PARAMETERS}
  Set To Dictionary    ${main_dict}  &{kwargs}
  ${procedure_iteration}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.N}
  ${procedure_iteration_count}=  Set Variable If  ${procedure_iteration}  ${kwargs.N}  1

  ${procedure_iteration_list}=  Create List
  FOR  ${index}  IN RANGE  ${procedure_iteration_count}
    Append To List  ${procedure_iteration_list}  ${index+1}
  END
  Set Test Variable  ${MAIN_DICT}  ${main_dict}
  Set Test Variable  ${procedure_iteration_LIST}  ${procedure_iteration_list}
  Set Test Variable  ${procedure_iteration}  ${procedure_iteration}
  Set Test Variable  ${procedure_iteration_COUNT}  ${procedure_iteration_count}
  RETURN  ${procedure_iteration}  ${procedure_iteration_list}  ${PARAMETERS}
