*** Settings ***
Documentation
    ...  Test case will verify fault duration and reset reason in additional fault information according to specifications
    ...  in various scenarios for CB007964 Alarm indication of operator triggered reset.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  1500  # [in seconds] Timeout for waiting until cells are onAir after site reset.
${RESTORE_TIMEOUT}  1800  # [in seconds] Timeout for waiting until cells are onAir after rollback.
${PING_LOSS_TIMEOUT}  900  # [in seconds] Timeout for ping loss during reset.
${PING_REGAIN_TIMEOUT}  600  # [in seconds] Timeout for ping regain during reset.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.
${VALUE_STEP_2}  900  # [in seconds] First value for test for fault4592CancellationTimer parameter.
${VALUE_STEP_4}  1200  # [in seconds] Second value for test for fault4592CancellationTimer parameter.
${VALUE_STEP_6}  1500  # [in seconds] Third value for test for fault4592CancellationTimer parameter.
${VALUE_STEP_8}  1800  # [in seconds] Fourth value for test for fault4592CancellationTimer parameter.


*** Keywords ***
TC__FM__FID4592_fault_available_in_NMS_with_late_integration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27809
    ...
    ...  *******************
    ...  History of changes
    ...  ******************
    ...  16.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27809 - Initial TAT creation
    ...  27.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27780 - Keyword moved to resource file
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  04.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29231 - Enhancement for to many objects found
    ...  01.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29097 - Enhancement replace the FaultGenerator for FID 2080 by cmd line command
    ...  20.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30073 - Remove Netact alarm verification after MRBTS is deintegrated from Netact
    ...  02.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30447 - Netact disconnected during test allowed once
    ...  ******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB007964-SR-A

    Step0: Set Testcase Preconditions
    Step1: Trigger A Fault That Will Cause BTS Secondary Core Autonomous Reset
    Step2: Set New Value For Fault4592 Cancellation Timer Parameter
    Step3: Trigger A Fault That Will Cause BTS Site Autonomous Reset
    Step4: Set New Value For Fault4592 Cancellation Timer Parameter
    Step5: Trigger Site Reset Via SWRESETREQ Object
    Step6: Set New Value For Fault4592 Cancellation Timer Parameter
    Step7: Perform CM Changes That Will Provoke BTS Site Reset
    Step8: Set New Value For Fault4592 Cancellation Timer Parameter
    Step9: Perform Software Rollback From WebEM


Step0: Set Testcase Preconditions
    Log  \nStep0: Set testcase preconditions.  console=true
    Log  MRBTS will be deintegrated from Netact.  console=true
    Deintegrate MRBTS From Netact  ${MRBTS_DN}
    Change FMCADM Parameter  actForceAutoReset  true
    Set Variables For Fault Signature Check
    Perform Site Reset


Step1: Trigger A Fault That Will Cause BTS Secondary Core Autonomous Reset
    Log  \nStep1: Trigger a fault that will cause BTS secondary core autonomous reset.  console=true

    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=fault_4592  admin_api_log_dir=${BTS_FILES}
    ${fault_4592}  Run Keyword In Background  Assert Alarm Active  parameters=fault_id=4592  timeout=${ALARM_TIMEOUT}  alias=fault_4592
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime

    Open Connection To Primary Core
    Open Connection To Secondary Core
    SSHLibrary.Write  rio hpdalm send hld
    SSHLibrary.Read Until Prompt
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2080_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} is active in WebEM for secondary core.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells

    ${check_status_4592}  Run Keyword And Return Status  Collect Keyword Result  ${fault_4592}  timeout=${ALARM_TIMEOUT}
    IF  ${check_status_4592}
      Fail  Fault 4592 was active in WebEM.
    ELSE
      Log  Fault 4592 was not active in WebEM.  console=true
    END

    Log  Checking fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM
    ...  fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    ...  info=${INFO}
    ...  scope=${SCOPE}
    ...  minor=${MINOR}
    ...  category=${CATEGORY}
    ...  load_name=${SW_VERSION}
    ...  reset_counter=${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}

    [Teardown]  Run Keyword And Continue On Failure  Teardown Admin  alias=fault_4592


Step${index}: Set New Value For Fault4592 Cancellation Timer Parameter
    Log  \nStep${index}: Set new value for fault4592 cancellation timer parameter.  console=true
    Change FMCADM Parameter  fault4592CancellationTimer  ${VALUE_STEP_${index}}


Step3: Trigger A Fault That Will Cause BTS Site Autonomous Reset
    Log  \nStep3: Trigger a fault that will cause BTS site autonomous reset.  console=true

    ${date_autonomous_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=fault_site_reset  admin_api_log_dir=${BTS_FILES}
    ${fault_site_auto_reset_parameters}  Get String With Alarm Parameters  ${FAULT_2080_SITE_AUTO_RST}
    ${fault_site_reset}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_site_auto_reset_parameters}  timeout=${ALARM_TIMEOUT}
    ...  alias=fault_site_reset

    Log  Prepare fault 2080.  console=true
    ${primary_core}  Query Infomodel  get object //SMOD_R-* is [activeRole=Primary]
    IF  ${primary_core}[horizontalPosition]==1
      ${sender}  ${receiver}  ${domain}  Get Variables For Left Side
    ELSE
      ${sender}  ${receiver}  ${domain}  Get Variables For Right Side
    END
    Send Hwapi Api2 Alarm Msg  ${sender}  ${receiver}  1  2080  ${domain}  timeout=120
    Log  Fault sent.  console=true

    ${check_status}  Collect Keyword Result  ${fault_site_reset}  timeout=${ALARM_TIMEOUT}
    IF  ${check_status}
      Log  Fault ${FAULT_2080_SITE_AUTO_RST} is active in WebEM.  console=true
    ELSE
      Fail  Fault ${FAULT_2080_SITE_AUTO_RST} was not active in WebEM.
    END
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_LOSS_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=true
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_REGAIN_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=true
    ELSE
      Set Test Failed  Ping has not been regained within timeout.
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells  check_cells=${FALSE}

    Log  Check for fault 4592 presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_4592}  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true

    Log  Integrate BTS to NMS.  console=true
    ${mplane_ip}  Admin Get MPLANE IP
    Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-COMMON/MR-COMMON  mrbts_address=${mplane_ip}  dist_name=${MRBTS_DN}
    ...  security_mode=no TLS
    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to recovery
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells

    Log  Check for fault 4592 state in WebEM.  console=true
    ${check_fault_4592}  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${VALUE_STEP_2}
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true
    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${VALUE_STEP_2}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592_MINOR}  time_from=${date_autonomous_reset}
    ...  additional_fault_id=${FAULT_4592_MINOR}[fault_id]  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to recovery
    Log  Fault ${FAULT_4592_MINOR} is inactive in Netact.  console=true

    Log  Deintegrate BTS from NMS.  console=true
    Deintegrate MRBTS From Netact  ${MRBTS_DN}
    Check Fault 4592 Information In WebEM Alarm History  recovery
    Check Fault 4592 Information In Netact Alarm History  recovery  ${date_autonomous_reset}

    [Teardown]  Run Keyword And Continue On Failure  Teardown Admin  alias=fault_site_reset


Step5: Trigger Site Reset Via SWRESETREQ Object
    Log  \nStep5: Trigger site reset via SWRESETREQ object.  console=true

    ${date_swresetreq_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    Perform Delta Recommissioning With SWRESETREQ Object

    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_LOSS_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=true
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_REGAIN_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=true
    ELSE
      Set Test Failed  Ping has not been regained within timeout.
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells  check_cells=${FALSE}

    Log  Check for fault 4592 presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_4592}  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true

    Log  Integrate BTS to NMS.  console=true
    ${mplane_ip}  Admin Get MPLANE IP
    Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-COMMON/MR-COMMON  mrbts_address=${mplane_ip}  dist_name=${MRBTS_DN}
    ...  security_mode=no TLS
    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to user request
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells

    Log  Check for fault 4592 state in WebEM.  console=true
    ${check_fault_4592}  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${VALUE_STEP_4}
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true

    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${VALUE_STEP_4}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592_MINOR}  time_from=${date_swresetreq_reset}
    ...  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to user request
    Log  Fault ${FAULT_4592_MINOR} is inactive in Netact.  console=true

    Check Fault 4592 Information In WebEM Alarm History  user request
    Check Fault 4592 Information In Netact Alarm History  user request  ${date_swresetreq_reset}


Step7: Perform CM Changes That Will Provoke BTS Site Reset
    Log  \nStep7: Perform CM changes that will provoke BTS site reset.  console=true

    ${date_cm_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  Collect current SCF for backup purpose.  console=true
    coam.Get Current Scf File  local_dir_path=${BTS_FILES}  file_name=backup_scf.xml
    Log  Performing commissioning with backup SCF.  console=true
    ${bts_id}  Admin Get BTS ID
    coam.Perform Commissioning  bts_id=${bts_id}  scf_file=${BTS_FILES}/backup_scf.xml  skip_parameter_relation_errors=true  timeout=300

    Log  Check for fault 4592 presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_4592}  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true

    Log  Integrate BTS to NMS.  console=true
    ${mplane_ip}  Admin Get MPLANE IP
    Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-COMMON/MR-COMMON  mrbts_address=${mplane_ip}  dist_name=${MRBTS_DN}
    ...  security_mode=no TLS
    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to commissioning change
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells

    Log  Check for fault 4592 state in WebEM.  console=true
    ${check_fault_4592}  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${VALUE_STEP_6}
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true

    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${VALUE_STEP_6}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592_MINOR}  time_from=${date_cm_reset}
    ...  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to commissioning change
    Log  Fault ${FAULT_4592_MINOR} is inactive in Netact.  console=true

    Check Fault 4592 Information In WebEM Alarm History  commissioning change
    Check Fault 4592 Information In Netact Alarm History  commissioning change  ${date_cm_reset}


Step9: Perform Software Rollback From WebEM
    Log  \nStep9: Perform software rollback from webEM.  console=true

    Log  Performing software rollback to pasive SW.  console=true
    Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check Active And Pasive Software Versions To Be Set Correctly  ${PASSIVE_SW_VERSION}  ${ACTIVE_SW_VERSION}

    ${date_sw_rollback}  Get Current Date  time_zone=UTC  result_format=datetime

    Log  Performing software rollback to target SW.  console=true
    Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}  ${FALSE}
    Check Active And Pasive Software Versions To Be Set Correctly  ${ACTIVE_SW_VERSION}  ${PASSIVE_SW_VERSION}

    Log  Check for fault 4592 presence in WebEM.  console=true
    ${fault_4592_minor_params}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${check_fault_4592}  Assert Alarm Active  parameters=${fault_4592_minor_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4592_MINOR} is active in WebEM.  console=true

    Log  Integrate BTS to NMS.  console=true
    ${mplane_ip}  Admin Get MPLANE IP
    Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-COMMON/MR-COMMON  mrbts_address=${mplane_ip}  dist_name=${MRBTS_DN}
    ...  security_mode=no TLS
    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to software rollback
    Log  Fault ${FAULT_4592_MINOR} is active in Netact.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells

    Log  Check for fault 4592 state in WebEM.  console=true
    ${check_fault_4592}  Assert Alarm Inactive  parameters=${fault_4592_minor_params}  timeout=${VALUE_STEP_8}
    Log  Fault ${FAULT_4592_MINOR} is inactive in WebEM.  console=true

    Log  Check for fault 4592 state in NMS.  console=true
    Wait Until Keyword Succeeds  ${VALUE_STEP_8}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592_MINOR}  time_from=${date_sw_rollback}
    ...  additional_fault_id=${FAULT_4592_MINOR}[fault_id]
    ...  suppl_info=BTS booted at [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ .* due to software rollback
    Log  Fault ${FAULT_4592_MINOR} is inactive in Netact.  console=true

    Check Fault 4592 Information In WebEM Alarm History  software rollback
    Check Fault 4592 Information In Netact Alarm History  software rollback  ${date_sw_rollback}


Get Variables For Right Side
    ${sender}  Set Variable  537985600
    ${receiver}  Set Variable  537989634
    ${domain_id}  Set Variable  32

    RETURN  ${sender}  ${receiver}  ${domain_id}


Get Variables For Left Side
    ${sender}  Set Variable  269550144
    ${receiver}  Set Variable  269554178
    ${domain_id}  Set Variable  16

    RETURN  ${sender}  ${receiver}  ${domain_id}


Set Variables For Fault Signature Check
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
      IF  '${smod}[activeRole]' == 'Secondary'  BREAK
      IF  '${smod}[activeRole]' == 'Primary'  CONTINUE
    END
    Set Test Variable  ${PRODUCT_CODE}  ${smod}[productCode]
    Set Test Variable  ${PRODUCT_NAME}  ${smod}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod}[serialNumber]
    Set Test Variable  ${INFO}  .*RapidIO host link down.*
    Set Test Variable  ${MINOR}  FCT SRIO
    Set Test Variable  ${SCOPE}  ESM
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${COUNTER}  [0-9]+
    ${extra_info}  Catenate  SEPARATOR=${SPACE}
    ...  faulty_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?[0-9]+;
    ...  gracefully_shutdown_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?[0-9]+
    Set Test Variable  ${EXTRA_INFO}  ${extra_info}
    Set Unit Position For Fault Signature  ${smod}[id][internal]


Create CMD Object
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    ${bts_id}  Admin Get BTS ID
    ${mnl_id}  Get MNL ID
    Append Managed Object To Delta  MRBTS-${bts_id}/MNL-${mnl_id}/CMD-1  create  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Remove File  ${BTS_FILES}/delta.json


Delete SWRESETREQ Object
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    ${bts_id}  Admin Get BTS ID
    ${mnl_id}  Get MNL ID
    ${cmd_id}  Get CMD ID
    Append Managed Object To Delta  MRBTS-${bts_id}/MNL-${mnl_id}/CMD-${cmd_id}/SWRESETREQ-1  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Remove File  ${BTS_FILES}/delta.json


Perform Delta Recommissioning With SWRESETREQ Object
    ${date_swresetreq_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  Perform delta recommissioning with SWRESETREQ object.  console=true
    ${status_cmd}  Query Infomodel  check //CMD_A-*  allow_negative_result=True
    IF  ${status_cmd}==${FALSE}  Create CMD Object
    ${status_swresetreq}  Query Infomodel  check //SWRESETREQ_A-*  allow_negative_result=True
    IF  ${status_swresetreq}  Delete SWRESETREQ Object
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    ${bts_id}  Admin Get BTS ID
    ${mnl_id}  Get MNL ID
    ${cmd_id}  Get CMD ID
    Append Managed Object To Delta  MRBTS-${bts_id}/MNL-${mnl_id}/CMD-${cmd_id}/SWRESETREQ-1  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/MNL-${mnl_id}/CMD-${cmd_id}/SWRESETREQ-1  swResetLevel  btsReset  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/MNL-${mnl_id}/CMD-${cmd_id}/SWRESETREQ-1  swResetReqId  1  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Remove File  ${BTS_FILES}/delta.json


TC Setup
    Common Test Setup  tc_name=FM__FID4592_fault_available_in_NMS_with_late_integration
    Setup NetAct


TC Teardown
    Change FMCADM Parameter  actForceAutoReset  false
    Change FMCADM Parameter  fault4592CancellationTimer  30
    Teardown NetAct  number_of_expected_disconnections=1
    Common Test Teardown