*** Settings ***
Documentation  Resource for CNI-42395_1SB_F1
Library    OperatingSystem
Library    taf.ul.verify_snapshot  WITH NAME  snapshot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/ping_utils.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${STARTUP_TIMEOUT}        20
${SNAPSHOT_TIMEOUT}       1200
${BUILD_PATH}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build

*** Keywords ***
TC__LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25486

    Set Tags    CA-LOGS    AUTHOR-radu.turcu@nokia.com    MAINTAINER-radu.turcu@nokia.com

    Step 0: Preconditions
    Step 1: Perform 4 Resets
    Step 2: Perform SW Update
    Step 3: Collect Snapshot, Perform 4 Resets, Collect Snapshot
    Step 4: Unpack Snapshots And Compare Startup Log Error Prints


Step 0: Preconditions
    [Documentation]
    ...  In this step BTS ID from current BTS is set to variable.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}=  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

Step 1: Perform 4 Resets
    log  \n4 site resets will be performed now  console=${True}
    Repeat Keyword  4 times  Reset Site And Wait For OnAir

Step 2: Perform SW Update
    [Documentation]    In this step, the current build on BTS is compared to the latest releases. Downloads either the newest or 2nd newest build
    ...    and compares release 5.1 radio software from downladed SW to current SW. The downloaded SW is then installed, and the site is reset.

    Log    \nStep 5: Perform SW update and reset site    console=${TRUE}
    Check Current SW And Prepare Update
    Log    Start SW update    console=${TRUE}
    coam.Update Software    ${BTS_files}/${new_sw}.zip    timeout=3600
    Wait Until Keyword Succeeds    3m    5s    ping_utils.Check If Host Is Not Pingable    192.168.255.129
    Wait Until Keyword Succeeds    20m    30s    pm_logs_general.Check All Modules And All Cells Working States
    Run    rm -f ${BTS_files}/${new_sw}.zip
    Set Test Variable    ${BTS_SW_CHANGED}    ${TRUE}

Step 3: Collect Snapshot, Perform 4 Resets, Collect Snapshot
    [Documentation]
    ...  In this step snapshot is collected, site reset is done twice and second snapshot is collected.

    Log  \nStep 1: Collect Snapshot, Perform 4 Resets, Collect Snapshot  console=${True}
    ${path_to_first_snapshot}  Collect Snapshot
    log  \n4 site resets will be performed now  console=${True}
    Repeat Keyword  4 times  Reset Site And Wait For OnAir
    ${path_to_second_snapshot}  Collect Snapshot
    Set Test Variable  ${path_to_first_snapshot}
    Set Test Variable  ${path_to_second_snapshot}

Step 4: Unpack Snapshots And Compare Startup Log Error Prints
    [Documentation]
    ...  In this step postmortem files from both snapshots are unpacked. Mechanism of creating and moving postmortem files after reset is checked.
    ...  Content of PM_1 file from first snapshot, after two resets, should be in PM_3 file in second snapshot.
    ...  Content of PM_2 file from first snapshot, after two resets, should be in PM_4 file in second snapshot.

    Log  \nStep 2: Unpack Snapshots And Compare Startup Log Error Prints  console=${True}

#    Set Test Variable  ${path_to_first_snapshot}
#    ...    /home/ute/results99/2025-10-23_12-45-30_TEST-[1]LOGS_CB008390_Snapshot_startup_Log_ERROR_prints/BTSFiles/snapshot_2025_10_23_12_45.zip
#    Set Test Variable  ${path_to_second_snapshot}
#    ...    /home/ute/results99/2025-10-23_12-45-30_TEST-[1]LOGS_CB008390_Snapshot_startup_Log_ERROR_prints/BTSFiles/snapshot_2025_10_23_13_14.zip

    unpacking.Unpack Archive Content To Directory  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    unpacking.Unpack Archive Content To Directory  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    Compare Files From MSM

Collect Snapshot
    [Documentation]
    ...  This keyword is used to collect snapshot
    @{time}=  Get Time  year month day hour min
    ${snapshot_status}=  Run Keyword And Return Status
    ...  coam.Collect Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  ${snapshot_status}
    ...  Log  Collecting snapshot succeeded  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Collecting snapshot has failed  ${True}
    ${path_to_snapshot}=  Set Variable  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    [Return]  ${path_to_snapshot}

Reset Site And Wait For OnAir
    [Documentation]
    ...  This keyword performs site reset and waits until bts is back OnAir
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States
    log  \nReset complete  console=${True}

Compare Files From MSM
    [Documentation]
    ...  This keyword is used to check if 1011_pm_1 file content moved to 1011_pm_3 file and
    ...  1011_pm_2 file content moved to 1011_pm_4 file after two resets.

    ${1011_pm_1_runtime}  ${1011_pm_1_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_1_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${1011_pm_2_runtime}  ${1011_pm_2_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_2_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${1011_pm_3_runtime}  ${1011_pm_3_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_3_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${1011_pm_4_runtime}  ${1011_pm_4_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_4_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked

    ${1011_pm_5_runtime}  ${1011_pm_5_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_5_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    ${1011_pm_6_runtime}  ${1011_pm_6_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_6_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    ${1011_pm_7_runtime}  ${1011_pm_7_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_7_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    ${1011_pm_8_runtime}  ${1011_pm_8_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_8_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked

    Should Be Equal  ${1011_pm_2_runtime}  ${1011_pm_5_runtime}
    Should Be Equal  ${1011_pm_3_runtime}  ${1011_pm_6_runtime}
    Should Be Equal  ${1011_pm_4_runtime}  ${1011_pm_7_runtime}
    Should Be Equal As Integers  ${1011_pm_2_filesize}  ${1011_pm_5_filesize}
    Should Be Equal As Integers  ${1011_pm_3_filesize}  ${1011_pm_6_filesize}
    Should Be Equal As Integers  ${1011_pm_4_filesize}  ${1011_pm_7_filesize}


Find And Unpack File
    [Documentation]
    ...  This keyword is used to find specified file in snapshot and unpack it until runtime_SYSTEM.log
    ...  Works only for Runtime and PostMortem files.
    ...  Filename to unpack, snapshot path and output path are needed as argument.
    ...  Size of PM file and content of unpacked runtime_SYSTEM.log are returned from keyword.
    [Arguments]  ${filename}  ${snapshot_path}  ${unpacked_snapshot_path}
    ${Snapshot_dict}=  snapshot.Get Data From Snapshot  ${snapshot_path}
    ${file_entry_from_snapshot_dictionary}=  Set Variable  ${Snapshot_dict}[${filename}]
    ${file_container_and_file_name}=  Get From List  ${file_entry_from_snapshot_dictionary}  0
    ${File_container}=  Fetch From Left  ${file_container_and_file_name}  /

    unpacking.Unpack Archive Content To Directory  ${unpacked_snapshot_path}/${File_container}
    ...  ${unpacked_snapshot_path}/${File_container}_unpacked
    unpacking.Unpack Archive Content To Directory  ${unpacked_snapshot_path}/${File_container}_unpacked/${filename}
    ...  ${unpacked_snapshot_path}/${filename}_unzipped
    unpacking.Unpack Archive Content To Directory  ${unpacked_snapshot_path}/${filename}_unzipped/runtime_SYSTEM.log.xz
    ...  ${unpacked_snapshot_path}/${filename}_unpacked
    ${runtime_SYSTEM_file_path}=  Set Variable  ${unpacked_snapshot_path}/${filename}_unpacked/runtime_SYSTEM.log
    ${runtime_SYSTEM_file}=  OperatingSystem.Get File  ${runtime_SYSTEM_file_path}
    ${PM_filesize}=  OperatingSystem.Get File Size  ${unpacked_snapshot_path}/${File_container}_unpacked/${filename}
    [Return]  ${runtime_SYSTEM_file}  ${PM_filesize}

Check Current SW And Prepare Update
    [Documentation]    Compares current build on BTS to the latest releases. Downloads either the newest or 2nd newest build
    ...    and compares release 5.1 radio software.

    @{latestBuild}=    Get Latest ENB Build
    ${initial_sw}=  coam.Get Sw Version
    Set Test Variable    ${initial_sw}
    ${initial_sw_tr}=    Replace String Using Regexp    ${initial_sw}    SBTS.{2,5}_ENB    SBTS00_ENB
    Log    Installed build.........${initial_sw_tr}             console=${TRUE}
    Log    Newest build............${latestBuild[0]['name']}    console=${TRUE}
    Log    Second newest build.....${latestBuild[1]['name']}    console=${TRUE}

    Run Keyword If    '${latestBuild[0]['name']}' == '${initial_sw_tr}'    Run Keywords
    ...    Log    ${\n}Newest SW installed on BTS - CAN'T UPGRADE,${\n}Download and downgrade to: ${latestBuild[1]['name']}   console=${TRUE}   AND
    ...    Set Test Variable    ${new_sw}    ${latestBuild[1]['name']}
    ...    ELSE    Run Keywords    Log    ${\n}Newer SW available, download and upgrade to: ${latestBuild[0]['name']}    console=${TRUE}   AND
    ...    Set Test Variable    ${new_sw}    ${latestBuild[0]['name']}

    Wget to file    ${BUILD_PATH}/SBTS00/${new_sw}/${new_sw}_release_BTSSM_downloadable_A54.zip    ${BTS_files}/${new_sw}.zip
    Log    Download complete    console=${TRUE}

Get Latest ENB Build
    [Documentation]    Fetch newest and second newest build data from cloud-ute. KW uses external python script.

    Run    pip3 install ute_cloud_manager_api
    ${dir}=    Set Variable    ${BTS_Files}/AdditionalFiles
    Create Directory    ${dir}

    ${content}=    OperatingSystem.Get File    ${CURDIR}/../CBRS/Resources/Scripts/GetLatestBuildsFromCloud.py
    Create File    ${dir}/script.py    ${content}
    Run    chmod +x ${dir}/script.py
#8b48f8d1cdf86f276feadde04bfd9b8944743bd1
#fe1e82f09e26b2b563154a824521c103ceac31a1
    ${token}=    Set Variable    8b48f8d1cdf86f276feadde04bfd9b8944743bd1    # user API token from Cloud Manager

    ${branch}=    Set Variable    SBTS00

    ${output}=    Run    python3 ${dir}/script.py ${token} ${branch} 2
    ${builds}=    Get Regexp Matches    ${output}    (\\[output_start]\\\n)(.*)(\\\n\\[output_end])    2

    ${build_name}=    Get Regexp Matches
    ...    ${builds[0]}    (SBTS.{2,4}_ENB_\\d+_\\d+_\\d+)
    ${buildAddDate}=    Get Regexp Matches
    ...    ${builds[0]}    (\\d{4}-\\d{2}-\\d{2})(.)(\\d{2}:\\d{2}:\\d{2})    1
    ${buildAddTime}=    Get Regexp Matches
    ...    ${builds[0]}    (\\d{4}-\\d{2}-\\d{2})(.)(\\d{2}:\\d{2}:\\d{2})    3
    ${buildHardware}=    Get Regexp Matches
    ...    ${builds[0]}    ('supported_hardware')(.{1,3})(\\[.*?])    3
    ${buildActivate}=    Get Regexp Matches
    ...    ${builds[0]}    ('active')(.{1,3})(')(.{4,5})(')    4
    ${buildPromotion}=    Get Regexp Matches
    ...    ${builds[0]}    ('promotion')(..)(.*?(?=}))    3

    ${index}=    Set Variable    0
    @{latestBuildList}=    Create List
    FOR    ${i}    IN    @{build_name}
        &{dict}=    Create Dictionary
        ...    name=${buildName[${index}]}
        ...    addDate=${buildAddDate[${index}]}
        ...    addTime=${buildAddTime[${index}]}
        ...    hardware=${buildHardware[${index}]}
        ...    activate=${buildActivate[${index}]}
        ...    promotion=${buildPromotion[${index}]}

        Append To List    ${latestBuildList}    ${dict}
        ${index}=    Evaluate    ${index} + 1
    END

    [Return]    @{latestBuildList}

Wget to file
    [Documentation]    Downloads file from url and savess to destination.

	[Arguments]       ${url}              ${destination}
	${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
	Run keyword if    '${status}'!='0'    Log    ${output}
	Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Common Test Teardown
