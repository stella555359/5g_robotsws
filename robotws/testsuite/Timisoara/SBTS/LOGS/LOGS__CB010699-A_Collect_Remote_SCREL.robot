*** Settings ***
Documentation
    ...  Collect_Remote_SCREL
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     DateTime
Library     OperatingSystem
Library     String
Library     SSHLibrary
Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${lss_ip}          10.5.20.200
${lss_port}        22
${lss_username}    coam
${lss_password}    zO&n1W*ktp7!

*** Keywords ***
TC__LOGS__CB010699-A_Collect_Remote_SCREL
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27468
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the functionality of triggering remote SCREL with PM/FM data to the LSS server and
    ...  validation of its content. In CB010699-A only metadata.txt, operationshistory.json, IMSCREL.ims2 and PM/FM files are checked,
    ...  rest of content will be delivered in subfeature CB010699-D
    ...  SCREL history file is also checked to ensure it contains an entry about the SCREL triggered in first step.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 08.05.2024 - Initial creation
    ...
    Set Tags   CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R3    FEATURE-CB010699


    Step 0: Preconditions
    Step 1: Collect Remote SCREL
    Step 2: Check Content of SCREL
    Step 3: Collect And Check SCREL History File

Step 0: Preconditions
    [Documentation]
    ...  In this step necessary test variables are set. LSS address and credentials are configured on BTS.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
    ${screl_name}  Set Variable  SCREL_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${screl_name}
    ${TRBL_MNLENT_DISTNAME}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable  ${TRBL_MNLENT_DISTNAME}
    Set Parameter actSysCriticalEventLogs  ${True}
    Configure LSS address and credentials

Step 1: Collect Remote SCREL
    [Documentation]
    ...  In this step remote SCREL with PM/FM data is triggered to LSS server and than downloaded to local machine.

    Log  \nStep 1: Collect Remote SCREL  console=${True}
    ${timestamp}  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M
    Set Test Variable  ${timestamp}
    coam.Collect Remote SCREL  include_pmfm_data=${True}     timeout=300
    Download SCREL from LSS

Step 2: Check Content of SCREL
    [Documentation]
    ...  In this step the content of the SCREL file is checked.
    ...  The SCREL file data is validated against the dictionary of mandatory files.

    Log  \nStep 2: Check Content of SCREL  console=${True}
    @{mandatory_files}  Create List  .*operationshistory.json  .*RawAlarmHistory.txt  .*AlarmHistory.txt  .*metadata.txt
    ...  .*PM\.BTS.*  .*.ims2.*
    &{SCREL_with_PMFM_dict}  Create Dictionary  mandatory_file=@{mandatory_files}  not_mandatory_file=${EMPTY}
    ${SCREL_file_dict}  snapshot.Get Data From Snapshot  ${path_to_screl}
    ${validation_status}  Run Keyword And Return Status  snapshot.Validate Snapshot Using Custom Data  ${SCREL_file_dict}  ${SCREL_with_PMFM_dict}
    Run Keyword If  ${validation_status}  Log  SCREL file content is correct  console=${True}
    ...  ELSE  Fail  SCREL file content is incorrect !

Step 3: Collect And Check SCREL History File
    [Documentation]
    ...  In this step the SCREL history file is checked if it contains the entry about SCREL triggered in Step 1.

    Log  \nStep 3: Collect And Check SCREL History File  console=${True}
    coam.Get SCREL history  ${bts_files}/SCREL_history.txt
    ${screl_history}  OperatingSystem.Get File  ${bts_files}/SCREL_history.txt
    @{screl_history_lines}  Split To Lines  ${screl_history}
    ${last_entry}  Set Variable  ${screl_history_lines}[-1]
    Should Contain  ${last_entry}  "start_time":"${timestamp}    msg=start time in SCREL history is not correct!
    Should Contain  ${last_entry}  "trigger_type":"ON DEMAND"    msg=trigger type in SCREL history is not correct!
    Should Contain  ${last_entry}  "trigger_originator":"ADMIN"    msg=trigger originator in SCREL history is not correct!
    Should Contain  ${last_entry}  "coverage_level":"Screl"    msg=coverage level in SCREL history is not correct!
    Should Contain  ${last_entry}  "snapshot_result":"success"   msg=result in SCREL history is not correct!
    Log  SCREL history file contains correct entry about SCREL triggered in Step 1  console=${True}



Configure LSS address and credentials
    [Documentation]
    ...  This keyword is responsible for configuring the LSS address and credentials.
    ${lss_delta}  Set Variable  lss_config
    coam.Create Delta  ${lss_delta}
    ${dict_lss_config}  Create Dictionary  list_name=lssConfig  lssIPaddress=${lss_ip}  lssPortNo=${lss_port}
    coam.Append Complex Item To Delta  ${TRBL_MNLENT_DISTNAME}  list_name=lssConfig  &{dict_lss_config}  delta_id=${lss_delta}
    coam.Get Delta  ${lss_delta}
    coam.Save Delta  ${BTS Files}/lss_config_delta.json  ${lss_delta}
    coam.Perform Delta Recommissioning  ${BTS Files}/lss_config_delta.json  skip_parameter_relation_errors=${True}
    coam.Configure LSS account  ${lss_username}  ${lss_password}

Download SCREL from LSS
    [Documentation]
    ...  This keyword is responsible for downloading the SCREL from the LSS.
    ...  It establishes an SSH connection to the LSS server using the provided credentials.
    ...  It then searches for the SCREL file on the LSS server that was created within the last 15 minutes.
    ...  If the SCREL file is found, it is compressed into a zip file and downloaded to the local files directory.
    ...  After successful download, the SCREL file and its corresponding zip file are removed from the LSS server.
    ...  If the SCREL file is not found on the LSS server, the test is marked as failed.

    Log  Open SSH Connection to lss server  console=${true}
    SSHLibrary.Open Connection  ${lss_ip}
    ${ssh_status}  Run Keyword And Return Status  SSHLibrary.Login  ${lss_username}  ${lss_password}
    Run Keyword If  ${ssh_status}
    ...  Log  Opening SSH session to lss server succeeded  console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Open SSH connection to lss server failed.  ${TRUE}
    ${screl_location_on_lss}  SSHLibrary.Execute Command  find / -type d -name "${screl_name}" -cmin -15 2>/dev/null
    ${screl_filename}  Fetch From Right  ${screl_location_on_lss}    /
    Set Test Variable  ${screl_filename}
    ${isEmpty}  Get length  ${screl_location_on_lss}
    Log  ${isEmpty}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  SCREL wasn`t found on lss server.  ${TRUE}
    ...  ELSE  Log  SCREL was found on lss server.   console=${true}
    SSHLibrary.Execute Command  cd /home/coam && zip -r ${screl_filename}.zip ${screl_filename}
    Sleep  30s
    Run  sshpass -p '${lss_password}' scp ${lss_username}@${lss_ip}:/home/coam/${screl_filename}.zip ${BTS_Files}
    Sleep  60s
    SSHLibrary.Execute Command  rm -r /home/coam/${screl_filename}
    Log  ${screl_filename} was removed from LSS server  console=${true}
    SSHLibrary.Execute Command  rm /home/coam/${screl_filename}.zip
    Log  ${screl_filename}.zip was removed from LSS server  console=${true}
    ${path_to_screl}  Set Variable  ${BTS_Files}/${screl_filename}.zip
    OperatingSystem.File Should Exist  ${BTS_Files}/${screl_filename}.zip
    Log  SCREL was downloaded to local disk   console=${true}
    Set Test Variable  ${path_to_screl}
    SSHLibrary.Close Connection

Set Parameter actSysCriticalEventLogs
    [Documentation]
    ...  This keyword sets the parameter actSysCriticalEventLogs in FEATCADM to value passed as KW argument.
    [Arguments]  ${required_value}
    ${featcadm}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${feature_flag_status}  Query Infomodel  check //MNL_A-*/MNLENT_A-*/FEATCADM_A-* is [actSysCriticalEventLogs=${required_value}]
    ...  timeout=60  allow_negative_result=${True}
    Run Keyword If    ${feature_flag_status} != ${True}
    ...  Run Keywords  coam.Perform Parameter Recommissioning  dist_name=${featcadm}  parameter=actSysCriticalEventLogs
    ...  operation=update  value=${required_value}  skip_parameter_relation_errors=${True}
    ...  AND  Log  Parameter actSysCriticalEventLogs changed to ${required_value}  console=${True}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND  Setup Scout And Send Configuration
    ...    AND  Common Test Teardown
