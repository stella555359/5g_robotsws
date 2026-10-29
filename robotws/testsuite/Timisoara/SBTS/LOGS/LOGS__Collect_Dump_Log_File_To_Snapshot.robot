*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/infomodel.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     ute_fsmaccess


*** Variables ***
@{log_file_names}               swupdate.log.zip
${log_dir}=                     ${/}var${/}tmp
${keyword}=			            swupdate
${load_t1}    	   	        	T1
${load_t2}    	   		        T2
${TDD_TRUNK_VERSION}            TL19
${jenkins_url}                  ${BUILD_PATH}
${FileNumber}           	    25

*** Keywords ***
TC__LOGS__Collect_Dump_Log_File_To_Snapshot

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24235
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is check collect dump log file to Snapshot
    ...  ******************
    ...  History of changes
    ...  ******************

    ...  - 06.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24235 - Test rewritten based on BOAM ET test -
    ...  [1][1.0] Automated__Collect__Dump_Log_File_To_Snapshot
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 20.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/LOGS__Collect_Dump_Log_File_To_Snapshot.png
    ...

    Set Tags     CA-LOGS  OWNER-iuliia.taupeka@nokia.com  AUTHOR-jiajun.jin@nokia.com  MAINTAINER-jakub.kokoszka@nokia.com  GROUP_IN_CHARGE-WRO_6_Vrf
    ...          PHASE-CRT  SW-SBTS23R1  FEATURE-LTE3338-R-w  LTE655-a

    Step 0: Preconditions
    Step 1: Collect dump log file to snapshot




Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare path variable and create taf.sbts.oam.coam.admin connection
    ...  check SW on passive and active partition

    Log  \nStep 0: Preconditions  console=${True}
    Set Test Variable  ${SW_UPDATE}  ${False}
    ${bts_connection}=  coam.connect_to
    Setup Enb Fsm Access
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Get SW load and Type
    set test variable  ${destination_dir}  ${BTS Files}/


Step 1: Collect dump log file to snapshot
    [Documentation]
    ...  In this step test prepare different build from passive partition
    ...  Update software to T1 or T2 SW version
    ...  Check Log Files are present on eNB,
    ...  Trigger and check snapshot, searching swupdate.log file in snapshot


    Log  \nStep 1: Collect dump log file to snapshot  console=${True}
    Log  Prepare different build from passive partition  console=${True}
	Prepare different build from passive partition

    Log  Update software to ${active_build_T}  console=${True}
	coam.update software    ${destination_dir}${active_build_T}  timeout=3600
    Set Test Variable  ${SW_UPDATE}  ${True}

    Log  Wait for eNB configure and RF swCheckDone status  console=${True}
	Wait for eNB configure and RF swCheckDone status

	Log  Check Log Files are present on eNB  console=${True}
    Check Log Files are present on eNB

    Log  Trigger and Check Snapshot  console=${True}
    Trigger and Check Snapshot


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

Prepare different build from passive partition
    [Documentation]
    ...  This KW Prepare different build from passive partition
	${active_build_T}=     Run Keyword If  '${build_type}' != 'T1'    Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    ...  ELSE  Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t2}
	set test variable      ${active_build_T}

Prepare build ${destination_dir} ${current_build} ${load_type}
    [Documentation]
    ...  This KW Prepare build T1 or T2
   ${split_build}=    Split string          ${current_build}    separator=\_
   ${trunk_flag}=     Get from list         ${split_build}     2
   ${version_flag}=   Get from list         ${split_build}     0
   ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${current_build}
					 ...     ELSE IF       '${trunk_flag}'=='1000'    Set Variable   ${current_build}
					 ...     ELSE IF       '${trunk_flag}'=='2000'    Set Variable   ${current_build}
                     ...     ELSE IF       '${version_flag}'=='${TRUNK_VERSION}'  Replace String  ${current_build}  ${TRUNK_VERSION}  SBTS00   #FL00
					 ...     ELSE IF       '${version_flag}'=='${TDD_TRUNK_VERSION}'  Replace String   ${current_build}  ${TDD_TRUNK_VERSION}   TL00
					 ...     ELSE   		Set Variable   ${current_build}
  ${t0_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_A54.zip
  ${t1_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T1_A54.zip
  ${t2_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T2_A54.zip
  ${download_relative_url}   Run keyword if     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
					 ...     ELSE IF        '${load_type}'=='T1'     Set Variable    ${t1_relative_url}
					 ...     ELSE IF        '${load_type}'=='T2'     Set Variable    ${t2_relative_url}
					 ...     ELSE            Fail  Unexpected load type
  ${SW}  coam.Get Sw Version
  Log    Active Sw Version: ${SW}  console=${true}
  @{SW_splited}    Split String    ${SW}    _
  ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
  Run Keyword If  ${SW_splited[2]}==9999
  ...  Wget to file 	     ${jenkins_url}/SBTS00/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
  ...  ELSE
  ...  Wget to file 	     ${jenkins_url}/SBTS${BRANCH}/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
  [Return]              ${download_relative_url}

Wget to file
	[Arguments]       ${url}              ${destination}
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

Check Log Files are present on eNB
    [Documentation]
    ...  This KW Check Log Files are present on eNB
	FOR    ${fileName}  IN  @{log_file_names}
	   File Should Exist On Enb  ${log_dir}/${fileName}
    END

Trigger and Check Snapshot
    [Documentation]
    ...  This KW Check Trigger and Check Snapshot
    Log  Snapshot collecting...  console=${True}
    coam.Collect Snapshot     ${BTS Files}/snapshot.zip   Full
    Get Data From Snapshot and Set Test Variables for extracting SN
    Extract swupdate log File
    Log  Checking if swupdate file exist in snapshot  console=${True}
    OperatingSystem.File Should Exist  ${SN_EXTRACT_FILE_LOCATION}/${log_name_prefix}011_swupdate.log.zip
    Log  Swupdate file exist in snapshot, test end.  console=${True}

Get Data From Snapshot and Set Test Variables for extracting SN
    [Documentation]
    ...  This KW Get Data From Snapshot and Set Test Variables for extracting SN
    Set Test Variable    ${SNAPSHOT_LOCATION}   ${BTS Files}/snapshot
    Set Test Variable  ${log_name_prefix}  BTS${BTS_ID}_1
    ${found_file_dict}  snapshot.Get Data From Snapshot  ${SNAPSHOT_LOCATION}.zip
    Set Test Variable  ${found_file_dict}

Extract swupdate log File
    [Documentation]
    ...  This KW Extract swupdate log File
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
        ${swupdate_zip_file}  Get Regexp Matches  ${log_file}  ${log_name_prefix}011_swupdate.log.zip
        ${swupdate_zip_name}  Run Keyword If  ${swupdate_zip_file}  Fetch From Left  ${found_file_dict["${log_file}"][0]}  .zip
        Exit For Loop If  '${swupdate_zip_name}' != 'None'
    END
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}.zip  ${SNAPSHOT_LOCATION}
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/${swupdate_zip_name}.zip  ${SNAPSHOT_LOCATION}/${swupdate_zip_name}
    Set Test Variable    ${SN_EXTRACT_FILE_LOCATION}    ${SNAPSHOT_LOCATION}/${swupdate_zip_name}


Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If  ${SW_UPDATE}  Run Keywords
    ...  Log  Rollback Software  console=${True}
    ...  AND  coam.Rollback Software
    ...  AND  Set Test Variable   ${SW_UPDATE}  ${False}
    ...  AND  Wait for eNB configure and RF swCheckDone status
    ...  AND  Run  rm ${BTS Files}/${active_build_T}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    teardown_all_aliases_for_enb_fsmaccess
    ...    AND    Common Test Teardown
