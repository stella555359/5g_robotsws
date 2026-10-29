*** Settings ***
Documentation
    ...  Collect_Local_SCREL
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     DateTime
Library     OperatingSystem
Library     String
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${load_t1}    	   		        T1
${load_t2}    	   		        T2

*** Keywords ***
TC__LOGS__CB010699_Collect_Local_SCREL
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27530
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the functionality of triggering local SCREL to local machine and
    ...  validates its content. In CB010699-A only metadata.txt, operationshistory.json, IMSCREL.ims2 and PM/FM files are checked,
    ...  rest of content will be delivered in subfeature CB010699-D
    ...  SCREL history file is checked to ensure it contains an entry about the SCREL triggered in first step.
    ...  Functionality of collecting SCREL history file with feature flag disabled is also verified.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 17.05.2024 - Initial creation
    ...  - 26.08.2024 - Add rest of the content of subfeature CB010699-D
    ...
    Set Tags   CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R3    FEATURE-CB010699

    Step 0: Test Preconditions
    Step 1: Collect Local SCREL
    Step 2: Check Content of SCREL
    Step 3: Collect And Check SCREL History File
    Step 4: Disable Feature Flag And Collect SCREL History

Step 0: Test Preconditions
    [Documentation]
    ...  In this step SW download is executed in current build and change reportingIntervalPm parameter to 5 mins.
    Log  Step 0: Preconditions.  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Test Variable  ${SW_UPDATE}  ${False}
    set test variable  ${destination_dir}  ${BTS Files}/
    set test variable  ${TEST_LOG_DIR}  ${BTS Files}/
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  parameter=reportingIntervalPm
    ...  operation=update  value=5min  skip_parameter_relation_errors=${True}
    coam.passive synchronize    copy_to_passive=1     timeout=600
    Get SW load and Type
    Log  Prepare different build from passive partition  console=${True}
	Prepare different build from passive partition
    coam.update software    sw_package=${destination_dir}${active_build_T}    should_activate=False     timeout=3600
    coam.passive synchronize    copy_to_passive=1     timeout=600

Step 1: Collect Local SCREL
    [Documentation]
    ...  In this step local SCREL is triggered to local machine.

    Log  \nStep 1: Collect local SCREL  console=${True}
    ${BTS_ID}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}
    Set Parameter actSysCriticalEventLogs  ${True}
    Log to console    Sleep 900s
    Sleep    900s
    ${timestamp}  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M
    Set Test Variable  ${timestamp}
    coam.Collect Local SCREL  include_pmfm_data=${True}  target_file_name=${bts_files}/SCREL_${timestamp}.zip   timeout=300

Step 2: Check Content of SCREL
    [Documentation]
    ...  In this step the content of the SCREL file is checked.
    ...  The SCREL file data is validated against the dictionary of mandatory files.

    Log  \nStep 2: Check Content of SCREL  console=${True}
    @{mandatory_files}  Create List  .*operationshistory.json  .*RawAlarmHistory.txt  .*AlarmHistory.txt  .*metadata.txt
    ...  .*PM\.BTS.*.xml  .*.ims2.*  .*RD\.BTS.*  .*NrCellMappingInfo.txt  .*SWDLreport.txt
    ...  .*swconfig.zip    .*swupdate.log     .*planfiles.tar
    ...  .*blackbox     .*blackbox_alarms   .*blackbox_temperature    .*runtime.zip
    ...  .*bro.xz
#    ...  .*BinaryTracing_IMS_DefaultIMSBuffer_.*.bro.xz
    &{SCREL_with_PMFM_dict}  Create Dictionary  mandatory_file=@{mandatory_files}  not_mandatory_file=${EMPTY}
    ${SCREL_file_dict}  snapshot.Get Data From Snapshot  ${bts_files}/SCREL_${timestamp}.zip
    ${validation_status}  Run Keyword And Return Status  snapshot.Validate Snapshot Using Custom Data  ${SCREL_file_dict}  ${SCREL_with_PMFM_dict}
    Run Keyword If  ${validation_status}  Log  SCREL file content is correct  console=${True}
    ...  ELSE  Fail  SCREL file content is incorrect !

Step 3: Collect And Check SCREL History File
    [Documentation]
    ...  In this step the SCREL history file is checked if it contains the entry about SCREL triggered in Step 1.

    Log  \nStep 3: Collect And Check SCREL History File  console=${True}
    coam.Get SCREL history  ${bts_files}/SCREL_history.txt
    ${screl_history}  OperatingSystem.Get File  ${bts_files}/SCREL_history.txt
    Set Test Variable  ${screl_history}
    @{screl_history_lines}  Split To Lines  ${screl_history}
    ${last_entry}  Set Variable  ${screl_history_lines}[-1]
    Should Contain  ${last_entry}  "start_time":"${timestamp}    msg=start time in SCREL history is not correct!
    Should Contain  ${last_entry}  "trigger_type":"ON DEMAND"    msg=trigger type in SCREL history is not correct!
    Should Contain  ${last_entry}  "trigger_originator":"ADMIN"    msg=trigger originator in SCREL history is not correct!
    Should Contain  ${last_entry}  "coverage_level":"Screl"    msg=coverage level in SCREL history is not correct!
    Should Contain  ${last_entry}  "snapshot_result":"success"   msg=result in SCREL history is not correct!
    Log  SCREL history file contains correct entry about SCREL triggered in Step 1  console=${True}

Step 4: Disable Feature Flag And Collect SCREL History
    [Documentation]
    ...  In this step it is checked if SCREL history file can be collected with feature flag disabled.

    Log  \nStep 4: Disable Feature Flag And Collect SCREL History  console=${True}
    Set Parameter actSysCriticalEventLogs  ${False}
    coam.Get SCREL history  ${bts_files}/SCREL_history2.txt
    ${screl_history2}  OperatingSystem.Get File  ${bts_files}/SCREL_history2.txt
    Should Be Equal  ${screl_history}  ${screl_history2}  msg=SCREL history file changed after disabling feature flag!
    Log  SCREL history file is succesfully collected after disabling feature flag and it's content didn't change  console=${True}

Prepare different build from passive partition
    [Documentation]
    ...  This KW Prepare different build from passive partition
	${active_build_T}=     Run Keyword If  '${build_type}' != 'T1'    Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    ...  ELSE  Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t2}
	set test variable      ${active_build_T}

Get SW load and Type
    [Documentation]
    ...  This KW Get SW load and Type
	${pre_update_enb_sw}=  Get active and passive eNB sw versions
	${build_type}=  Should Match Regexp  ${pre_update_enb_sw['passive']}  .{2}$
	set test variable      ${pre_update_enb_sw}
	set test variable	   ${build_type}

Get active and passive eNB sw versions
    [Documentation]
    ...  This KW Get active and passive eNB sw versions
    ${active_sw}=  coam.Get Sw Version
    Log  Active SW - ${active_sw}  console=${True}
    ${passive_sw}=  infomodel.Infomodel Get Passive SW Version
    Log  Passive SW - ${passive_sw}  console=${True}
    ${output}=  Create Dictionary  active=${active_sw}  passive=${passive_sw}

    [Return]  ${output}

Prepare build ${destination_dir} ${current_build} ${load_type}
    [Documentation]
    ...  This KW Prepare build T1 or T2
    ${split_build}=    Split string          ${current_build}    separator=\_
    ${trunk_flag}=     Get from list         ${split_build}     2
    ${version_flag}=   Get from list         ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='9999'    Replace String  ${current_build}  ${version_flag}  SBTS00
                          ...    ELSE IF    '${trunk_flag}'=='9990'    Replace String  ${current_build}  ${version_flag}  SBTS00
                          ...    ELSE       Set Variable   ${current_build}
    ${t0_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_A54.zip
    ${t1_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ${t2_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ${download_relative_url}   Run keyword if     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
					 ...     ELSE IF        '${load_type}'=='T1'     Set Variable    ${t1_relative_url}
					 ...     ELSE IF        '${load_type}'=='T2'     Set Variable    ${t2_relative_url}
					 ...     ELSE           Fail  Unexpected load type
    ${SW}  coam.Get Sw Version
    Log    Active Sw Version: ${SW}  console=${true}
    @{SW_splited}    Split String    ${SW}    _
    ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
    Run Keyword If  ${SW_splited[2]}==9999
    ...  Wget to file 	     ${BUILD_PATH}/SBTS00/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
    ...  ELSE IF    ${SW_splited[2]}==9990
    ...  Wget to file 	     ${BUILD_PATH}/SBTS00/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
    ...  ELSE
    ...  Wget to file 	     ${BUILD_PATH}/SBTS${BRANCH}/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
    [Return]           ${download_relative_url}

Wget to file
    [Arguments]       ${url}              ${destination}
    Log    The URL link: ${url}    console=${True}
    ${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
    Run keyword if    '${status}'!='0'    Log    ${output}
    Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

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


Custom Test Teardown
    Set Parameter actSysCriticalEventLogs  ${True}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  parameter=reportingIntervalPm
    ...  operation=update  value=15min  skip_parameter_relation_errors=${True}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND  Setup Scout And Send Configuration
    ...    AND  Custom Test Teardown
    ...    AND  Common Test Teardown
