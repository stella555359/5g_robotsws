*** Settings ***
Documentation
    ...  This test was created to imitate X2 link break scenario.
    ...  X2 link will be configured by performing delta recommissioning of related LNADJ object.
    ...  Link break will be performed by modyfing iptables and drop incomming requests.
    ...  Link status is checked and corresponding fault 6203.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ADJ_ENB_ID}  ${EMPTY}  # [MANDATORY] this is the unique ID of the neighbor eNB
${COMMISSIONING_STATE}  ${FALSE}
# ${FALSE} or ${TRUE}. The value is used in check if recommissioning was done, keyword to apply recommissioning when test fails.
${RESTORE_STATUS}  ${FALSE}
# ${FALSE} or ${TRUE}. The value is used in check if link break was done and restore it when test fails.


*** Keywords ***
TC__FM__link_break_X2_long
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10241
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10241 - Initial TAT creation
    ...  - 09.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20629 - Modify iptables drop command for X2 link break scenarios
    ...  - 05.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21079 - Update filtering rule and command in X2 link break scenarios
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get MRBTS ID and Admin Get LNBTS ID from sbts_admin
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26100 - Add new IP range
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step0 : Check All Required States
    Step1 : Create Delta And Configure X2 Link
    Step2 : Provoke X2 Link Break
    Step3 : Restore X2 Link
    Step4 : Return Commissioning To Original State


Step0 : Check All Required States
    Log  \nStep 0: Check all required states.  console=true

    ${is_neighboring_defined}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${ADJ_ENB_ID}
    Run Keyword If  ${is_neighboring_defined}
    ...  Log  Neighboring enb is defined, test will continue [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Neighboring enb is not defined, test will be set as failed [NOK].

    ${id}  Get Substring  ${ADJ_ENB_ID}  2
    ${adress}  Get Substring  ${id}  1
    Run Keyword If  600 <= ${id} <= 699
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.236.${adress}
    ...  ELSE IF  700 <= ${id} <= 799
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.236.1${adress}
    ...  ELSE IF  400 <= ${id} <= 499
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.247.1${adress}
    ...  ELSE IF  800 <= ${id} <= 854
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.236.2${adress}
    ...  ELSE
    ...  Fail  msg= Neighboring MRBTS ID is out of supported range [NOK].

    Check Commissioned Technologies  LTE

    ${sctp_wait_time_init_seq_retry_x2_ini}  Get SctpWaitTimeInitSeqRetryX2 Value  sctpWaitTimeInitSeqRetryX2
    Set Test Variable  ${SCTP_WAIT_TIME_INIT_SEQ_RETRY_X2_INI}

    ${parameters}  Catenate  SEPARATOR=${SPACE}  faultId=6203,  faultName="Transport layer connection failure in X2 interface",  alarmId=7107,
    ...  severity=Major
    Set Test Variable  ${PARAMETERS}


Step1 : Create Delta And Configure X2 Link
    Log  \nStep 1: Create delta and configure X2 link.  console=true

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Log  Appending LNADJ object and related parameters to delta.  console=true
    Append Managed Object To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  adjEnbId  ${ADJ_ENB_ID}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  cPlaneIpAddr  ${LNADJ_ADRESS}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  cPlaneIpAddrCtrl  oamControlled  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  rlfBasedRCRsupported  false  ${delta_id}
    ${plmn_id_dict}  Create Dictionary
    Set To Dictionary  ${plmn_id_dict}  mcc  244
    Set To Dictionary  ${plmn_id_dict}  mnc  8
    Set To Dictionary  ${plmn_id_dict}  mncLength  2
    Append Complex Item To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  list_name=plmnId  &{plmn_id_dict}  delta_id=${delta_id}
    Append List Items To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-1  uPlaneIpAddrList  ${LNADJ_ADRESS}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${commissioning_state}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Set Test Variable  ${COMMISSIONING_STATE}
    Remove Delta  ${delta_id}

    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells
    Check Links Status  Available
    Run Keyword If  ${cells_status}
    ...  Log  All cells in configuration are : OnAirDone Enabled Online Active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Cells status is incorect [NOK].
    ${link_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list //MRBTS_R-1/LNBTS_R-${BTS_ID}/LNADJ_R-* is [x2LinkStatus="available"]  timeout=240
    Run Keyword If  ${link_status}
    ...  Log  x2LinkStatus is available [OK].  console=true
    ...  ELSE
    ...  Fail  msg=x2LinkStatus is not available [NOK].


Step2 : Provoke X2 Link Break
    Log  \nStep 2: Provoke X2 link break.  console=true

    Connect To SMOD  ${SMOD1['IP']}
    ${send_command}  ssh.Execute  iptables -S
    ${regex}  Get Regexp Matches  ${send_command}  S1X2_CHAIN -s ${LNADJ_ADRESS}/32.*--sport.*--dport
    Log  matches found : ${regex}  console=true
    ${value}  Fetch From Right  ${regex[0]}  --sport
    ${port}  Fetch From Left  ${value}  --dport
    ${sctp_port}  Remove String  ${port}  ${SPACE}
    Set Test Variable  ${SCTP_PORT}
    ${send_command_2_status}  Run Keyword And Return Status
    ...  ssh.Execute  iptables -I CP_TRAFFIC_LTE -p sctp -m sctp --sport ${SCTP_PORT} --dport ${SCTP_PORT} -j DROP
    Run Keyword If  ${send_command_2_status}
    ...  Set Test Variable  ${RESTORE_STATUS}  ${TRUE}

    Log  Test will sleep for ${SCTP_WAIT_TIME_INIT_SEQ_RETRY_X2_INI}s to wait for fault.  console=true
    Sleep  ${SCTP_WAIT_TIME_INIT_SEQ_RETRY_X2_INI}s

    ${link_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list //MRBTS_R-1/LNBTS_R-${BTS_ID}/LNADJ_R-* is [x2LinkStatus="unavailable"]  timeout=100
    Run Keyword If  ${link_status}
    ...  Log  x2LinkStatus is not available [OK].  console=true
    ...  ELSE
    ...  Fail  msg=x2LinkStatus is available after link break [NOK].

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6203}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=100
    Log  Fault ${FAULT_6203}[fault_id] "${FAULT_6203}[fault_name]" occured.  console=true

    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells
    Check Links Status  Available
    Run Keyword If  ${cells_status}
    ...  Log  All cells in configuration are : OnAirDone Enabled Online Active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Cells status is incorect [NOK].


Step3 : Restore X2 Link
    Log  \nStep 3: Restore X2 link.  console=true

    Connect To SMOD  ${SMOD1['IP']}
    ${send_command_2_status}  Run Keyword And Return Status
    ...  ssh.Execute  iptables -D CP_TRAFFIC_LTE -p sctp -m sctp --sport ${SCTP_PORT} --dport ${SCTP_PORT} -j DROP
    Run Keyword If  ${send_command_2_status}
    ...  Set Test Variable  ${RESTORE_STATUS}  ${FALSE}

    Log  Test will sleep for ${SCTP_WAIT_TIME_INIT_SEQ_RETRY_X2_INI}s to wait for fault canceling.  console=true
    Sleep  ${SCTP_WAIT_TIME_INIT_SEQ_RETRY_X2_INI}s

    ${link_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list //MRBTS_R-1/LNBTS_R-${BTS_ID}/LNADJ_R-* is [x2LinkStatus="available"]  timeout=100
    Run Keyword If  ${link_status}
    ...  Log  x2LinkStatus is available [OK].  console=true
    ...  ELSE
    ...  Fail  msg=x2LinkStatus is not available [NOK].
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6203}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=100
    Log  Fault ${FAULT_6203}[fault_id] "${FAULT_6203}[fault_name]" is not present.  console=true

    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells
    Check Links Status  Available
    Run Keyword If  ${cells_status}
    ...  Log  All cells in configuration are : OnAirDone Enabled Online Active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Cells status is incorect [NOK].


Step4 : Return Commissioning To Original State
    Log  \nStep 4: Return commissioning to original state.  console=true

    ${delta_id_2}  Set Variable  1
    Create Delta  ${delta_id_2}
    Log  Appending LNADJ object and related parameters to delta.  console=true
    ${lnadj_list}  Query Infomodel  get list //MRBTS_R-1/LNBTS_R-${BTS_ID}/LNADJ_R-*  timeout=100
    FOR  ${element}  IN  @{lnadj_list}
        ${lnadj}  Fetch From Right  ${element.dist_name}  /LNADJ_R-
        Append Managed Object To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNADJ-${lnadj}  delete  ${delta_id_2}
    END

    Get Delta  ${delta_id_2}
    Save Delta  ${BTS_FILES}/delta2.json  delta_id=${delta_id_2}
    Log  Performing delta recommissioning.  console=true
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta2.json  skip_parameter_relation_errors=True
    ${commissioning_state}  Set Variable  ${FALSE}
    Set Test Variable  ${COMMISSIONING_STATE}

    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells
    Check Links Status  Available
    Run Keyword If  ${cells_status}
    ...  Log  All cells in configuration are : OnAirDone Enabled Online Active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Cells status is incorect [NOK].


Restore Link And Check If Recommissioning Was Done
    [Documentation]  This KW is created to ensure recommissioning is performed when the test fails.
    ...    Additionally iptables rules will be modified to accept incomming request if link was not restored.

    Log  Check restore status.  console=true
    Run Keyword If  ${RESTORE_STATUS}
    ...  ssh.Execute  iptables -D CP_TRAFFIC_LTE -p sctp -m sctp --sport ${SCTP_PORT} --dport ${SCTP_PORT} -j DROP
    Log  Check If Recommissioning Was Done.  console=true
    Run Keyword If  ${COMMISSIONING_STATE}
    ...  Step4 : Return Commissioning To Original State


TC Setup
    Common Test Setup  tc_name=FM__link_break_X2_long


TC Teardown
    Restore Link And Check If Recommissioning Was Done
    Common Test Teardown
