*** Settings ***
Documentation  LTE3266
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600

*** Keywords ***
TC__LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24807
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step 1: Collect Snapshot
    ...  Step 2: Verify SOAP Logs Presence
    ...  *****************
    ...  Test case verifies if there are present SoapMessageTrace log files from each RMOD in Snapshot_file.
	...  ******************
    ...  Author: Damian Kotula
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.12.2023 - Initial creation
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com
    ...    MAINTAINER-damian.kotula@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R1
    ...    FEATURE-LTE3266-A-d

    Step 1: Collect Snapshot
    Step 2: Verify SOAP Logs Presence

Step 1: Collect Snapshot
    [Documentation]
    ...  In this step local snapshot is downloaded.

    Log  \nStep 1: Collect Snapshot  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Collect Snapshot
    pm_logs_general.Check Unexpected Active And Historical Alarms

Step 2: Verify SOAP Logs Presence
    [Documentation]
    ...  In this step SOAPMessageTrace logs are verifided in snapshot. From every RMOD SOAPMessageTracePM and SOAPMessageTraceCFG files
    ...  should be present in snapshot.

    Log  \nStep 2: Verify SOAP Logs Presence  console=${True}
    ${RMOD_serials}  Get Dict Of Radio Modules Serial Numbers
    ${snapshot_data_dict}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    ${expected_soap_files}  Create Dict Of Expected SOAP Files  ${RMOD_serials}
    ${matched_soap_files}  snapshot.Validate snapshot using custom data  ${snapshot_data_dict}  ${expected_soap_files}
    ${number_of_expected_files}  Get Length  ${expected_soap_files.mandatory_file}
    ${number_of_matched_files}  Get Length  ${matched_soap_files}
    Log  ${matched_soap_files}
    Log  \nExpected: ${number_of_expected_files} files, matched: ${number_of_matched_files} files   console=${True}
    Should Be Equal  ${number_of_expected_files}  ${number_of_matched_files}  msg=Number of found SOAP files is not equal to expected files!


Get Dict Of Radio Modules Serial Numbers
    [Documentation]
    ...  This keyword creates a dictionary with RMOD serial numbers.
    ${rmods_distnames}  coam.Get Ids For All  RMOD
    ${rmods_serial_numbers}  Create Dictionary
    FOR  ${rmod_single_distname}  IN  @{rmods_distnames}
        ${rmod_obj}  Query Infomodel  get object ${rmod_single_distname}
        Set To Dictionary  ${rmods_serial_numbers}  ${rmod_obj['serialNumber']}=${rmod_single_distname}
    END
    [Return]  ${rmods_serial_numbers}

Create Dict Of Expected SOAP Files
    [Documentation]
    ...  This keyword creates a dictionary with regex of expected SOAP files from every RMOD
    [Arguments]  ${rmod_serial_list}
    ${mandatory_patterns}=  Create list
    FOR  ${serial}  IN  @{rmod_serial_list}
        ${SOAPMessageTracePM_regex}  Set Variable  BTS${BTS_ID}_.011_${serial}_RMOD_(\\d+)_SOAPPM\.xml\.gz
        ${SOAPMessageTraceCFG_regex}  Set Variable  BTS${BTS_ID}_.011_${serial}_RMOD_(\\d+)_SOAPCFG\.xml\.gz
        Append to list  ${mandatory_patterns}  ${SOAPMessageTracePM_regex}  ${SOAPMessageTraceCFG_regex}
    END

    &{soap_files_dict}=  Create dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${Empty}
    [Return]  &{soap_files_dict}

Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log  Collecting Snapshot  console=${True}
    ${timestamp}  Get Time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    Set Test Variable  ${timestamp}
    ${log_status}  Run Keyword And Ignore Error  coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${log_status[0]}'=='FAIL'
    ...   Fail  Collecting snapshot failed
    ...   ELSE
    ...   Log  Full snapshot is successfully collected  console=${True}
    Set Test Variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND  Setup Scout And Send Configuration
    ...    AND  Common Test Teardown
