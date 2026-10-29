*** Settings ***
Documentation
    ...  Validate blackbox
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/infomodel.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    OperatingSystem
Library    DateTime
Library    hran_file_operations
Library    taf.sbts.oam.coam.admin  WITH NAME  coam


*** Variables ***
${RESET_DATE}
${BLACKBOX_INFO}
${MATCHES}
${check_blackbox_date}
${STARTUP_TIMEOUT}      10  # Timeout value in minutes after startup for all modules to reach working state.
${GET_PROCESS}			pgrep -f ram/node_FHNET00/lxc.cfg
${SYSTEM_ENB_PORT_443}  443
${load_t1}    	   		        T1
${load_t2}    	   		        T2
${jenkins_url}                  ${BUILD_PATH}
${G_BTSAlias}                   BTSSession
${G_bts_host}                   192.168.255.129
${G_bts_user}                   toor4nsn
${G_bts_passwd}                 oZPS0POrRieRtu


*** Keywords ***
TC__LOGS__Validate_Blackbox_after_reset_actions_LBT2522
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24361
    ...  ******************
    ...  Author: Iuliia Taupeka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-01-02 - TC created due to BOAM_ET transfer. version 1.0
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  - 19.08.2023 - TAT-26138 - Solving problem with fail (exit code 8)
    ...  - 21.08.2023 - TAT-26150 - Fake fail by FID-6450 for TC: Automated__LOGS__Validate_Blackbox_after_reset_actions_LBT2522
    ...  - 23.01.2024 - TAT-26790 - Analyze blackbox log file - KW change: waiting time for SW update increased
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This Test Case is designed to verify proper Blackbox file content after reset actions.
    ...  Blackbox file is downloaded from BTS via SSH and checked locally.
    ...  Test should verify proper cause and timestamp of BTS reset in case of:
    ...  - Site reset,
    ...  - Commissioning reset,
    ...  - Software Update reset,
    ...  - Recovery reset.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Validate_Blackbox_after_reset_actions.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS23R1

    Step 1: Preconditions
    Step 2: Perform Site Reset And Validate Blackbox
    Step 3: Perform BTS Commissioning And Validate Blackbox
    Step 4: Perform Crash And Validate Blackbox
    Step 5: Perform SW Update And Validate Blackbox

Step 1: Preconditions
    [Documentation]
    ...  In this step test prepares variables and SW versions and path for later SW update purposes.

    Log  Step 1: Preconditions.  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Test Variable  ${SW_UPDATE}  ${False}
    set test variable  ${destination_dir}  ${BTS Files}/
    set test variable  ${TEST_LOG_DIR}  ${BTS Files}/
    Get SW load and Type
    Log  Prepare different build from passive partition  console=${True}
	Prepare different build from passive partition

Step 2: Perform Site Reset And Validate Blackbox
    [Documentation]
    ...  In this step BTS site reset is performed.
    ...  Blackbox file is checked if last entry contains proper timestamp and reset cause ('User (Execute reset.)').

    Log  Step 2: Perform BTS site reset and validate blackbox  console=${True}
    ${BLACKBOX_INFO}       set variable    'User (Execute reset.)'
    Site Reset
#    Run Keyword And Ignore Error   coam.Reset Site
#    Wait Until Keyword Succeeds  15m  15s  Check All Modules And All Cells Working States
    Get File from SMOD1    /ffs/run/logs/lifetimedata/blackbox
    Analyze blackbox log file

Step 3: Perform BTS Commissioning And Validate Blackbox
    [Documentation]
    ...  In this step BTS commissioning is performed. It causes BTS reset.
    ...  Blackbox file is checked if last entry contains proper timestamp and reset cause ('CommissioningChange').

    Log  Step 3: Perform BTS Commissioning And Validate Blackbox.  console=${True}
    coam.Get Current Scf File  ${BTS_Files}  scf.xml  export_type=configuration
    ${BLACKBOX_INFO}       set variable    'CommissioningChange'
    ADMIN Perform Commissioning
    Get File from SMOD1    /ffs/run/logs/lifetimedata/blackbox
    Analyze blackbox log file

Step 4: Perform Crash And Validate Blackbox
    [Documentation]
    ...  In this step is triggered binary crash that will cause BTS reset.
    ...  Blackbox file is checked if last entry contains proper timestamp and reset cause ('Recovery').

    Log  Step 4: Perform Crash And Validate Blackbox   console=${True}
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    Log  Crash triggered at: ${RESET_DATE}    console=${True}
    set test variable  ${RESET_DATE}
    ${BLACKBOX_INFO}=  Set Variable  'Recovery'
    Connect to SMOD Via SSH
    Kill FHNETNODE Proces
    SSHLibrary.Close Connection
    Wait For Device Reboot And Then For Startup    reboot_timeout=600
    Get File from SMOD1    /ffs/run/logs/lifetimedata/blackbox
    Analyze blackbox log file
    #The two KWs added in TAT-26150:
    Collect Snapshot to clear FID-6450
    Log    Checking if FID-6450 was cleaned    console=${True}
    Wait Until Keyword Succeeds    20m    1s    Check If Expected Alarm is cleared    6450

Collect Snapshot to clear FID-6450
    Log    Collect Snapshot to clear FID-6450    console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

Check If Expected Alarm is cleared
    [Documentation]  This KW downloads list of active alarms and checks if expected fault is NOT on the list.
    [Arguments]  ${fault_ID}
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${active_faults_ids}  Get Fault IDs From Active Alarms  ${active_alarms}
    ${expected_fault}  Convert To Integer  ${fault_ID}
    Log    Active FIDs: ${active_faults_ids}    console=${True}
    List Should Not Contain Value  ${active_faults_ids}  ${expected_fault}  msg=Fail: The fault ${fault_ID} was not cleared!

Get Fault IDs From Active Alarms
    [Documentation]  This KW creates a list of fault IDs from list of active alarms.
    [Arguments]  ${alarms}
    ${faults_ids}  Create List
    FOR  ${alarm}  IN  @{alarms}
      ${fault_id}  Get From Dictionary  ${alarm}  faultId
      Append To list  ${faults_ids}  ${fault_id}
    END
    [Return]  ${faults_ids}

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded  console=${True}
    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Connect to SMOD Via SSH
    [Documentation]
    ...  SSH connection to primary SMOD is performed in this KW.
    SSHLibrary.Open Connection                          ${SMOD1['IP']}
    ${ssh_status}  Run Keyword And Return Status
    ...  SSHLibrary.Login                               ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    Run Keyword If  ${ssh_status}
    ...  Log  Opening SSH session succeeded  level=INFO   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Open SSH connection failure.  ${TRUE}

Kill FHNETNODE Proces
    [Documentation]
    ...  In this KW FHNETNODE Proces is killed to trigger BTS recovery reset
    ${id}=    SSHLibrary.Execute Command  ${GET_PROCESS}
    SSHLibrary.Execute Command    kill -9 ${id}

Wait For Device Reboot And Then For Startup
    [Arguments]    ${reboot_timeout}
    ...            ${ip_address}=${SMOD1['IP']}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    Log    \nWait for Device reboot ...    console=yes
    Check If Device Stops Responding To Nmap     timeout=${reboot_timeout}
    ...                                          ip_address=${ip_address}
    ...                                          port=${port}
    Log    Device stops responding to Nmap    console=yes
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All SMODs And RMODs States
    Log    All Modules are working after crash    console=yes

Check If Device Stops Responding To Nmap
    [Arguments]    ${timeout}
    ...            ${ip_address}=${SMOD1['IP']}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    FOR    ${time_index}    IN RANGE   ${timeout}
        sleep  1
        ${result}=    Run Keyword And Return Status    Nmap port on IP address and expect fail  ip_address=${ip_address}  port=${port}
        Exit For Loop If    ${result}
    END
    Run Keyword Unless    ${result}    Fail    Device with IP ${ip_address} still responded to nmap and it should not after ${timeout} seconds

Nmap Port On IP Address And Expect Fail
    [Arguments]    ${ip_address}=${SMOD1['IP']}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    ${output}=     Run       nmap -p ${port} ${ip_address}
    ${status_1}=   Run Keyword And Return Status    Should contain      ${output}   ${port}/tcp closed
    ${status_2}=   Run Keyword And Return Status    Should contain      ${output}   Host seems down
    Should Be True    ${status_1} or ${status_2}


Step 5: Perform SW Update And Validate Blackbox
    [Documentation]
    ...  In this step SW Update is performed that will cause BTS reset.
    ...  Blackbox file is checked if last entry contains proper timestamp and reset cause ('SwActivation').

    Log  Step 5: Perform SW Update And Validate Blackbox  console=${True}
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    Log   SW Update triggered at ${RESET_DATE}    console=${True}
    set test variable  ${RESET_DATE}
    ${BLACKBOX_INFO}=  Set Variable  'SwActivation'
    Log  Update software to ${active_build_T}  console=${True}
	coam.update software    ${destination_dir}${active_build_T}    timeout=3600
    Set Test Variable  ${SW_UPDATE}  ${True}
    Log  Wait until BTS will be pingable and for all SMODs and RMODs working  console=${True}
    Wait for Site is pingable
    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All SMODs And RMODs States
    Get File from SMOD1    /ffs/run/logs/lifetimedata/blackbox
    Analyze blackbox log file


Site Reset
    [Documentation]
    ...  Site Reset is performed in this KW. Reset timestamp is gathered for further timestamp check in blackbox file.
    Log  Site reset will be done.  console=${True}
    ${RESET_DATE}      DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    Log  Site Reset trigger timestamp: ${RESET_DATE}
#    coam.Reset Site  600
#    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All SMODs And RMODs States
    Run Keyword And Ignore Error   coam.Reset Site
    Wait Until Keyword Succeeds  15m  15s  Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms


#####
ADMIN Perform Commissioning
    Log  Stepx: Perform BTS Commissioning
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    Log    Commissioning performed at ${RESET_DATE}    console=${True}
    set test variable  ${RESET_DATE}
    Run Keyword And Ignore Error    coam.Perform Commissioning    ${BTS_ID}    scf_file=${BTS_Files}/scf.xml
    ...    skip_parameter_relation_errors=True  should_activate=${True}   timeout=600
    Sleep    100s
    Wait Until Keyword Succeeds  15m  15s  Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes

Get File from SMOD1
    [Arguments]    ${file_path}
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    Log    Collecting ${file_path}    console=${True}
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${SMOD1['PASSWORD']}' scp -r ${SMOD1['USERNAME']}@${SMOD1['IP']}:${file_path} ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get ${file_path}. File may not exist.


Analyze blackbox log file
    [Documentation]
    ...  Keyword used to analyze blackbox log. It is checked if date and text info in last line of the blackbox log file is correct.
    ...  If date or test message inside blackbox log is not correct, test case fails.

    ${date_in_logs}  OperatingSystem.get file  ${BTS Files}/blackbox  encoding_errors=ignore
    ${current_year}  Get Time  return year
    ${number_of_entries}  get lines containing string  ${date_in_logs}  ${current_year}-
    ${last_line}  get line  ${number_of_entries}  -1
    set test variable  ${last_line}
    Log    Last line from blackbox file: ${last_line}    console=${True}

    FOR  ${i}  IN RANGE  1  40
        Check Date
        exit for loop if  '${check_blackbox_date[0]}'=='PASS'
    END

    ${check_blackbox_info}  run keyword and ignore error  should contain  ${last_line}  ${BLACKBOX_INFO}
    run keyword unless
    ...  '${check_blackbox_info[0]}'=='PASS' and '${check_blackbox_date[0]}'=='PASS'  fail  blackbox info ${last_line} incorrect  console=yes


Check Date
    ${reset_date_mod}  replace string  ${RESET_DATE}  ${space}  T
    ${reset_date_mod}  get substring  ${reset_date_mod}  0  16
    ${check_blackbox_date}  run keyword and ignore error  should contain  ${last_line}  ${reset_date_mod}
    ${RESET_DATE}  DateTime.add time to date  ${RESET_DATE}  00:01:00.000
    set test variable  ${RESET_DATE}
    set test variable  ${check_blackbox_date}


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
    ...     ELSE    Set Variable   ${current_build}
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
  ...  Wget to file 	     ${jenkins_url}/SBTS00/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
  ...  ELSE
  ...  Wget to file 	     ${jenkins_url}/SBTS${BRANCH}/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
  [Return]           ${download_relative_url}

Wget to file
    [Arguments]       ${url}              ${destination}
    Log    The URL link: ${url}    console=${True}
    ${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
    Run keyword if    '${status}'!='0'    Log    ${output}
    Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

Wait for eNB configure and RF swCheckDone status
    [Documentation]
    ...  This KW check if BTS in online after reset
    Wait for Site is pingable
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Wait for Site is pingable
    [Documentation]
    ...  This KW check if Site is pingable
    Log  Waiting Until Host:192.168.255.129 Is Available  console=${True}
    Sleep  180s
    ${is_SMOD_pingable}=    run keyword and return status    wait until keyword succeeds    10 min    30 sec    Check ping on SMOD
    run keyword if    '${is_SMOD_pingable}'=='False'    run keywords    log
    ...    SMOD is not responding still after SW update. Test suite is canceled.    level=WARN    AND    FAIL
	Log  The site is pingable  console=${True}

Check ping on SMOD
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 1 received

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If  ${SW_UPDATE}  Run Keywords
    ...  Log    Rollback Software      console=${True}
    ...  AND    coam.Rollback Software
    ...  AND    Set Test Variable      ${SW_UPDATE}  ${False}
    ...  AND    Run  rm ${BTS Files}/${active_build_T}
    ...  AND    Wait for eNB configure and RF swCheckDone status

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
