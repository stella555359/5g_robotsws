*** Settings ***
Documentation  Maintainers: daniel.bartkowiak@nokia.com
...  KWs used in TC setup and TC teardown.

Library    taf.ul.marvin  WITH NAME  marvin
Library  ./../../../resources/truck_roll.py
Resource  ./setup_and_teardown.robot
Resource  ./../Robot/logging_session.robot


*** Variables ***
${ITERATION}  ${0}
${CUSTOM_MARVIN_USAGE}=  ${False}  # Set to ${True} if you want to use Marvin in your test case

*** Keywords ***
Common Test Setup
    [Arguments]  ${expected_BTS_status}=OnAir  ${HW_check}=${TRUE}  ${cells_check}=${TRUE}  ${scf_check}=${TRUE}  ${tools_to_setup}=syslog_IM_ADMIN
    [Documentation]  KW starting TC common actions such as starting log sessions, Alarms check, state check.
    ...  KW is dependent on Loop conditions
    ...  Arguments:
    ...  +=======================+=======+====================================================================+
    ...  | Argument              | Man.  | Description                                                        |
    ...  +=======================+=======+====================================================================+
    ...  | expected_BTS_status   | No    | mrbts state to check, default OnAir                                |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | HW_check              | No    | HW check switch, default ${TRUE}                                   |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | cells_check           | No    | cells check switch, default ${TRUE}                                |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | scf_check             | No    | scf check switch, default ${TRUE}                                  |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | tools_to_setup        | No    | default logs to collect syslog_IM_ADMIN                            |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    Logging With Timestamp  message=TC SETUP start  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      Logging With Timestamp  message=Active SW version on BTS-${bts_id}: ${CFG['NODES']['${bts_id}']['software_active']}
    END
    IF  ${ITERATION}==0
      Set Test Variable  ${TEST_LOGS_PATH}  ${CFG.test_logs_path}/
    ELSE
      Set Test Variable  ${TEST_LOGS_PATH}  ${CFG.test_logs_path}/Loop_${ITERATION}/
    END
    Logging Multinode Start  logs_dir=${TEST_LOGS_PATH}  tools_to_setup=${tools_to_setup}
    IF  ${ITERATION}==0
      Create Testcase Directory Path For Each BTS  ${CFG.test_logs_path}
    ELSE
      Create Testcase Directory Path For Each BTS  ${CFG.test_logs_path}/Loop_${ITERATION}
    END
    Set Test Variable  ${GLOBAL_ALLOWED_FAULTS}  ${GLOBAL_ALLOWED_FAULTS}
    FM Clear Allowed Alarms For All Nodes
    FM Add Global Faults To Allowed For All Nodes  ${GLOBAL_ALLOWED_FAULTS}
    FM Add Custom Global Faults To Allowed For All Nodes
    FM Check Unexpected And Historical Faults For All Nodes  delay=5
    STATE Verify Multi Node State
    ...  expected_BTS_status=${expected_BTS_status}
    ...  HW_check=${HW_check}
    ...  cells_check=${cells_check}
    ...  scf_check=${scf_check}
    lmi.Setup LMI Flow
    ${correct_test_name}=  QC Mapping  ${CFG.NODES['${cfg.primary_node_bts_id}']['software_active']}
    IF  '${correct_test_name}'=='None'
      ${correct_test_name}=  Set Variable  ${TEST NAME}
    END
    IF  ${CUSTOM_MARVIN_USAGE}
      marvin.Prepare And Start Marvin  test_case_name=${correct_test_name}  marvin_side=${MARVIN_SITE}  organization=${MARVIN_ORGANIZATION}
    END
    Logging With Timestamp  message=TC SETUP finished  style=DONE

Common Test Teardown
    [Arguments]  ${delay}=60  ${expected_BTS_status}=OnAir  ${HW_check}=${TRUE}  ${cells_check}=${TRUE}  ${scf_check}=${TRUE}
    [Documentation]  KW finishing TC common actions such as gathering logs, files. Analyzing TC execution status and loop conditions
    ...  KW usage is limited to use only in TC teardown section
    ...  Arguments:
    ...  +=======================+=======+====================================================================+
    ...  | Argument              | Man.  | Description                                                        |
    ...  +=======================+=======+====================================================================+
    ...  | delay                 | No    | timeout for stabilizing BTS before faults check                    |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | expected_BTS_status   | No    | mrbts state to check, default OnAir                                |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | HW_check              | No    | HW check switch, default ${TRUE}                                   |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | cells_check           | No    | cells check switch, default ${TRUE}                                |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    ...  | scf_check             | No    | scf check switch, default ${TRUE}                                  |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    Logging With Timestamp  message=TC TEARDOWN start  style=ONGOING
    ${tc_status}  ${snapshot}=  Set Variable  ${KEYWORD_STATUS}  ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}
    lmi.Start LMI Flow On All Nodes
    ${state_status}=  Run Keyword And Ignore Error  STATE Verify Multi Node State
    ...  expected_BTS_status=${expected_BTS_status}
    ...  HW_check=${HW_check}
    ...  cells_check=${cells_check}
    ...  scf_check=${scf_check}
    ${faults_status}=  Run Keyword And Ignore Error  FM Check Unexpected And Historical Faults For All Nodes
    ...  delay=${delay}
    ${tc_status}=  Set Variable If  "${state_status[0]}"=="PASS" and "${faults_status[0]}"=="PASS"  ${tc_status}  FAIL
    Run Keyword And Continue On Failure  Run Keyword If  "${tc_status}"=="FAIL"  Fail  Teardown failed. Check logs.
    IF  ${ITERATION}==0
      Run Keyword And Continue On Failure
      ...  Run Keywords
      ...  Run Keyword And Continue On Failure
      ...  Collect RawAlarmHistory For All Nodes  destination_path=${TEST_LOGS_PATH}/BTSFiles
      ...  AND
      ...  Logging Multinode Stop  ${TEST_LOGS_PATH}  ${tc_status}
    ELSE
      Run Keyword And Continue On Failure
      ...  Run Keywords
      ...  Run Keyword And Continue On Failure
      ...  Collect RawAlarmHistory For All Nodes  destination_path=${TEST_LOGS_PATH}/BTSFiles
      ...  AND
      ...  Logging Multinode Stop  ${TEST_LOGS_PATH}  ${tc_status}
    END
    Analyze Truck Roll On All Nodes
    IF  ${CUSTOM_MARVIN_USAGE}
      marvin.Stop Marvin  wait_after_run=${False}
    END
    Logging With Timestamp  message=TC TEARDOWN finished  style=DONE

Collect RawAlarmHistory For All Nodes
    [Arguments]  ${destination_path}
    [Documentation]  KW for getting RawAlarmHistory file from smod on specific BTS
    ...  Arguments:
    ...  +=======================+=======+====================================================================+
    ...  | Argument              | Man.  | Description                                                        |
    ...  +=======================+=======+====================================================================+
    ...  | destination_path      | Yes   | Path to folder on VM where file should be stored                   |
    ...  +-----------------------+-------+--------------------------------------------------------------------+
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      ${status}=  Run Keyword And Ignore Error
      ...  Run Keyword If  '${CFG.NODES['${bts_id}']['bts_alias_type']}'=='localhost'
      ...  SSH Get File From System Module  source_path=/tmp/RawAlarmHistory.txt
      ...  destination_path=${destination_path}/${bts_id}/RawAlarmHistory_${bts_id}.txt
      ...  ELSE IF  '${CFG.configuration_setup_type}'=='mplane'
      ...  SSH Get File From System Module  source_path=/tmp/RawAlarmHistory.txt
      ...  destination_path=${destination_path}/${bts_id}/RawAlarmHistory_${bts_id}.txt
      ...  target_ip=${cfg.NODES['${bts_id}']['bts_ip_address']}
      ...  ELSE
      ...  SSH Get File From System Module  source_path=/tmp/RawAlarmHistory.txt
      ...  destination_path=${destination_path}/${bts_id}/RawAlarmHistory_${bts_id}.txt
      ...  via_ip=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
      IF  '${status[0]}'=='PASS'
        Logging With Timestamp  message=RawAlarmHistory.txt from System module on BTS-${bts_id} collected  logs_dir=${CFG.suite_logs_path}
      ELSE
        Logging With Timestamp
        ...  message=RawAlarmHistory.txt could not be retrieved from System Module! Error: ${status[1]}
        ...  logs_dir=${CFG.suite_logs_path}
        ...  style=WARNING
      END
    END

Analyze Truck Roll On All Nodes
    [Arguments]  ${truck_roll_alarms}=${TRUCK_ROLL_FID_LIST}  ${truck_roll_recipents}=${TRUCK_ROLL_RECIPIENTS_LIST}
    ...  ${truck_roll_cm_maintainers}=${TRUCK_ROLL_CM_MAINTAINERS_LIST}
    [Documentation]  KW stops execution of TS immidietly if any fault from "truck_roll_alarms" is found or
    ...  LMP connectivity is lost or MPLANE connectivity is lost. In case of truck_roll finds any unexcepted condition
    ...  e-mails to recipients from lists truck_roll_cm_maintainers and truck_roll_recipents are sent.
    ...  User can set test variable "SKIP_TRUCK_ROLL" and control execution of truck roll mechanism - truck_roll is skipped if variable exists
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ${started_multinode_logging}  Set Variable  ${False}  # For Teardown to work correctly if SKIP_TRUCK_ROLL flag set
    ${skip_tr_variable}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${SKIP_TRUCK_ROLL}
    ${is_cm_exec_based_on_file}=  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  /opt/ute/execution.context.json
    Run Keyword And Return If  ${SKIP_TRUCK_ROLL}
    ...  Logging With Timestamp  message=Skiping Truck Roll analysis due to flag set by the user  style=WARNING
    # Setup new connection to Admin
    ${started_multinode_logging}  Run Keyword And Return Status  Logging Multinode Start  ${TEST_LOGS_PATH}/truck_roll  tools_to_setup=ADMIN
    # Truck Roll checking for all nodes
    Logging With Timestamp  message=Starting analysis of Truck Roll for all nodes...
    FOR  ${bts_id}  IN  @{cfg.active_bts_list}
      Logging With Timestamp  message=Truck Roll analysis for node ${bts_id} begins...
      # Truck Roll LMP connectivity check
      ${trigger_lmp_connectivity}  ${mplane_ip}=  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll LMP Connectivity  lmp_addr=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}  log_path=${TEST_LOGS_PATH}/truck_roll
      IF  ${trigger_lmp_connectivity}
        Logging With Timestamp  message=Truck Roll LMP connectivity check on BTS ${bts_id} passed
      END
      IF  not ${trigger_lmp_connectivity}
        Logging With Timestamp  message=Truck Roll LMP connectivity check on BTS ${bts_id} FAILED!  style=FAIL
      END
      # Truck Roll M-Plane connectivity check
      IF  ${trigger_lmp_connectivity}
        ${trigger_mplane_connectivity}=  Run Keyword And Continue On Failure
        ...  Analyze Truck Roll MPlane Connectivity  mplane_addr=${mplane_ip}  log_path=${TEST_LOGS_PATH}/truck_roll
      ELSE
        ${trigger_mplane_connectivity}=  Set Variable  ${None}
      END
      IF  ${trigger_mplane_connectivity}
        Logging With Timestamp  message=Truck Roll M-Plane connectivity check on BTS ${bts_id} passed
      END
      IF  not ${trigger_mplane_connectivity}
        Logging With Timestamp  message=Truck Roll M-Plane connectivity check on BTS ${bts_id} FAILED!  style=FAIL
      END
      # Truck Roll HW detection check
      ${trigger_hw_detection}=  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll HW Detection  alias=${bts_id}
      ...  smod_list=${cfg.NODES['${bts_id}']['scf_hw_sm_list']}
      ...  bbmod_list=${cfg.NODES['${bts_id}']['scf_hw_bbmod_list']}
      ...  rmod_list=${cfg.NODES['${bts_id}']['scf_hw_fr_list']}
      IF  ${trigger_hw_detection}
        Logging With Timestamp  message=Truck Roll HW detection check on BTS ${bts_id} passed
      END
      IF  not ${trigger_hw_detection}
        Logging With Timestamp  message=Truck Roll HW detection check on BTS ${bts_id} FAILED!  style=FAIL
      END
      # Truck Roll alarms check
      ${trigger_alarms}=  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll Alarms  alias=${bts_id}  truck_roll_alarms=${truck_roll_alarms}
      IF  ${trigger_alarms}
        Logging With Timestamp  message=Truck Roll alarms check on BTS ${bts_id} passed
      END
      IF  not ${trigger_alarms}
        Logging With Timestamp  message=Truck Roll alarms check on BTS ${bts_id} FAILED!  style=FAIL
      END
      # Truck Roll result overall - True if Truck Roll failed, False otherwise
      ${truck_roll_result}=  Set Variable
      ...  not ${trigger_alarms} or not ${trigger_hw_detection} or not ${trigger_lmp_connectivity} or not ${trigger_mplane_connectivity}
      # Reason building for Stop&Fix email notification
      ${lmp_mplane_key_value}=  Set Variable  lmp=not ${trigger_lmp_connectivity}, mplane=not ${trigger_mplane_connectivity}
      ${truck_roll_email_reason}=  Evaluate
      ...  dict(alarms=not ${trigger_alarms}, hw=not ${trigger_hw_detection}, ${lmp_mplane_key_value})
      # Executing Stop&Fix action if Truck Roll any check failed
      IF  ${truck_roll_result}
        Exec Stop And Fix Action
        ...  recipients_list=${truck_roll_recipents}
        ...  reply_list=${truck_roll_cm_maintainers}
        ...  reason_dict=${truck_roll_email_reason}
      END
      IF  not ${truck_roll_result}
        Logging With Timestamp  message=All steps of Truck Roll analysis for node ${bts_id} passed
      END
    END
    Logging With Timestamp  message=End of analysis of Truck Roll for all nodes
    [Teardown]  Run Keyword If  ${started_multinode_logging}  Logging Multinode Stop  ${TEST_LOGS_PATH}/truck_roll
