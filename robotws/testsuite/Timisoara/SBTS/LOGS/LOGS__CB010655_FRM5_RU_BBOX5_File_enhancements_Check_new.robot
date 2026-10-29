*** Settings ***
Documentation  Resource for CB010655
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/ping_utils.robot
Library     String
Library     OperatingSystem
Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot


*** Variables ***
${SNAPSHOT_TIMEOUT}    1800
${TOLERANCE}           60    # the allowed time (seconds) difference between the reset command send time and time in BBOX5
${JENKINS_URL}         ${BUILD_PATH}
@{ALL_REL5.1}  FHEM  AHEA  AHEB  AZNA  AHEGA  AHPMDA  AHPDA  AHCA  AHCA-B  AZHA  AHFB  AHIB  AHLB  AHCE  AHBB  AHBC  AZQC  AZQD
    ...    AZQR  AZRA  AHED  AHFIA  AHFIB  AHFIC  AHBCA  AHBCC  AHBCD  AHLOA  AHLBA  AHPB  AHDC  AHEC  AHGC  AHGA  AHDB  AHDA  AHEGB  AZNC  AZNB
    ...    AZND  AZHE  AZNE  AZQF  AZRB  AZFGA  AHHB  AHEE  AHMA  AHOA  ANEGA  AHHA  AAFIA  AREA  AHEH  AAIB  AAFB  AHPC  AAIC  AHLJA  AZQE  AHFIE
    ...    AHFIF  ARCA  ARGA  ARPA  ARHA  ARMA  AZRC  AHAA  AHPD  AHSA  AHCC  ARDB  AHEGC  AHFIG  AHBCB  AHPE  AHCF  AHPCA  AHPMDH  AHBOA  AHLBBA
    ...    AHPCDB  AHPMDB  ARDA  AHAB  AHGE  AHRA  AHPMDD  AHGD  AHNA  AHCG  AHEGF  FZQM  AHPG  AHPJ  AHGF  AHPMDJ  AHPL  AHPMDI  AHEGI  AHEGJ  AHPCB
    ...    AHSB  ARPB

*** Keywords ***
TC__LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27698
    ...  ******************
    ...  Author: Inna Melnyk
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.06.2024 - initial TC creation
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to verify if bbox5 file contents, and that they update correctly after BTS SW updates and resets.
    ...  *******************

    Set Tags   LOGS   AUTHOR-inna.melnyk@nokia.com    MAINTAINER-jakub.ozierski@nokia.com    GROUP_IN_CHARGE-WRO_5_Vrf    PHASE-CRT    SW-SBTS24R3

    Step 1: Preparation
    Step 2: Reset Site
    Step 3: Collect Snapshot
    Step 4: Extract And Analyze BBOX5
    Step 5: Perform SW Update And Site Reset
    Step 6: Download Snapshot
    Step 7: Extract And Analyze BBOX5
    Step 8: Check If BBOX5 Contents Are Correct

Step 1: Preparation
    [Documentation]    In this step release 5.1 radios are checked and one is selected at random. SSH connection is made to SMOD.

    Log  \nStep 1: Preparation  console=${True}
    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${BTS_ID}  ${btsInfo['mrbtsID']}
    Set Test Variable    ${BTS_SW_CHANGED}    ${FALSE}
    ${selected_radio}    Get Random Available Rel5.1 RMOD
    Set Test Variable    ${selected_radio}
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    SSHLibrary.Read

    ${serial_number}    Get From Dictionary    ${selected_radio}    serial_number
    Set Test Variable    ${serial_number}
    ${product_name}    Get From Dictionary    ${selected_radio}    product_name
    Set Test Variable    ${product_name}
    ${product_code}    Get From Dictionary    ${selected_radio}    product_code
    Set Test Variable    ${product_code}
    ${rmod_id}    Get From Dictionary   ${selected_radio}    rmod_id
    Set Test Variable    ${rmod_id}

    Log    BBOX5 from RMOD ${product_name} with SN ${serial_number} will be checked   console=${TRUE}
    Wait Until Keyword Succeeds    30 min  10 s  pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled

Step 2: Reset Site
    [Documentation]    In this whole site is resetted and the time of reset is stored in a variable. This step waits until the BTS with all
    ...    its cells is back on air.

    Log    \nStep 2: Reset Site    console=${TRUE}
    ${RESET_DATE_TIME_unformatted}=  Evaluate    str(datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S%z"))  datetime
    ${RESET_DATE_TIME}=    Replace String    ${RESET_DATE_TIME_unformatted}    +0000    +00:00
    set test variable    ${RESET_DATE_TIME}
    coam.Reset Site
    Wait Until Keyword Succeeds    20m    30s    pm_logs_general.Check All Modules And All Cells Working States

Step 3: Collect Snapshot
    [Documentation]    In this step the snapshot is collected, and the path to this downloaded snapshot is stored in a variable.
    Log    \nStep 3: Collect Snapshot    console=${TRUE}
    ${path_to_snap_1}    Collect Snapshot
    Set Test Variable    ${path_to_snap_1}

Step 4: Extract And Analyze BBOX5
    [Documentation]    In this step the BBOX5 file is found and extracted from the snapshot, next this file is analyzed and the
    ...    initial (current) values for the reset counter, radio SW, NvmResetTrigger and previous radio SW
    ...    are found and stored in variables.

    Log    \nStep4: Extract And Analyze BBOX5    console=${TRUE}
    Locate BBOX5 File In Snapshot And Extract It    ${path_to_snap_1}

    ${initial_reset_counter}  ${initial_radio_sw}  ${initial_nvm_reset_trigger_count}
    ...    ${initial_prev_radio_sw}    Analyze BBOX5 Logs  ${path_to_log_file}
    Set Test Variable    ${initial_reset_counter}
    Set Test Variable    ${initial_radio_sw}
    Set Test Variable    ${initial_nvm_reset_trigger_count}
    ${initial_radio_sw_formatted}=    Fetch From Right    ${initial_radio_sw}    File[0] version:
    Set Test Variable    ${initial_radio_sw_formatted}

Step 5: Perform SW Update And Site Reset
    [Documentation]    In this step, the current build on BTS is compared to the latest releases. Downloads either the newest or 2nd newest build
    ...    and compares release 5.1 radio software from downladed SW to current SW. The downloaded SW is then installed, and the site is reset.

    Log    \nStep 5: Perform SW update and reset site    console=${TRUE}
    Check Current SW And Prepare Update
    Log    Start SW update    console=${TRUE}
    coam.Update Software    ${BTS_files}/${new_sw}.zip    timeout=3600
    Wait Until Keyword Succeeds    6m    5s    ping_utils.Check If Host Is Not Pingable    192.168.255.129
    Wait Until Keyword Succeeds    20m    30s    pm_logs_general.Check All Modules And All Cells Working States
    Run    rm -f ${BTS_files}/${new_sw}.zip
    Set Test Variable    ${BTS_SW_CHANGED}    ${TRUE}
    Log    Reset Site    console=${TRUE}
    ${RESET_DATE_TIME_unformatted}=  Evaluate    str(datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S%z"))  datetime
    ${RESET_DATE_TIME}=    Replace String    ${RESET_DATE_TIME_unformatted}    +0000    +00:00
    Set Test Variable    ${RESET_DATE_TIME}
    coam.Reset     detailed_output=${TRUE}
    Wait Until Keyword Succeeds    20m    30s    pm_logs_general.Check All Modules And All Cells Working States

Step 6: Download Snapshot
    [Documentation]    In this step the snapshot is collected, and the path to this downloaded snapshot is stored in a variable.

    Log    \nStep 6: Downlaod Snapshot    console=${TRUE}
    ${path_to_snap_2}    Collect Snapshot
    Set Test Variable    ${path_to_snap_2}

Step 7: Extract And Analyze BBOX5
    [Documentation]    In this step the BBOX5 file is found and extracted from the snapshot, next this file is analyzed and the
    ...    updated (current) values for the reset counter, radio SW, NvmResetTrigger and previous radio SW
    ...    are found and stored in variables.

    Log    \nStep 7: Extract and analyze BBOX5    console=${TRUE}
    Locate BBOX5 File In Snapshot And Extract It    ${path_to_snap_2}
    ${updated_reset_counter}  ${updated_radio_sw}  ${updated_nvm_reset_trigger_count}
    ...    ${previous_radio_sw}    Analyze BBOX5 Logs  ${path_to_log_file}
    Set Test Variable    ${updated_reset_counter}
    Set Test Variable    ${updated_radio_sw}
    Set Test Variable    ${updated_nvm_reset_trigger_count}
    Set Test Variable    ${previous_radio_sw}

Step 8: Check If BBOX5 Contents Are Correct
    [Documentation]    In this step, the initial and updated variables from BBOX5 are compared to check if they have changed and are as expected.
    ...    Checks include SW history of RMOD, reset counters, NvmResetTrigger counter.
    Log    \nStep 8: Check if BBOX5 contents are correct    console=${TRUE}
    Check If SW History Is Correct
    ${expected_increase}=    Set Variable If    ${RADIO_SW_UPDATE} == ${FALSE}    1    2
    Check If Reset Counters Are Correct    ${initial_reset_counter}    ${expected_increase}    ${updated_reset_counter}
    Log    Reset counter is correct    console=${TRUE}
    Check If Reset Counters Are Correct    ${initial_nvm_reset_trigger_count}    ${expected_increase}    ${updated_nvm_reset_trigger_count}
    Log    NvmFlushCounter reset trigger is correct    console=${TRUE}


Check If SW History Is Correct
    [Documentation]    Checks if SW on radio was supposed to change, if yes then checks whether the new SW is in newest sw_history index
    ...    and previous is in the previous index. If no, then checks if the same SW is in the newest index.

    Run Keyword If  ${RADIO_SW_UPDATE} == ${TRUE}  Run Keywords  Should Contain  ${updated_radio_sw}  ${new_radio_sw}  AND
    ...    Should Contain  ${previous_radio_sw}  ${initial_radio_sw_formatted}  AND  Log  Latest SW and previous are correctly found in history
    ...  console=${TRUE}
    ...    ELSE  Run Keywords  Should Contain  ${updated_radio_sw}  ${initial_radio_sw_formatted}  AND  Log  Radio SW should should not change
    ...  console=${TRUE}

Check If Reset Counters Are Correct
    [Documentation]    Takes values as arguments, adds expected_increase to initial value and checks if it is now the same as the actual counter.

    [Arguments]    ${initial_counter}    ${expected_increase}    ${actual_counter}
    ${expected_counter}=    Evaluate    ${initial_counter} + ${expected_increase}
    Should Be Equal As Integers    ${expected_counter}    ${actual_counter}

Analyze BBOX5 Logs
    [Documentation]    Takes the path to BBOX5 and calls other KWs to check its correctness.

    [Arguments]    ${path_to_BBOX5_log_file}
    ${BBOX5_contents}=    OperatingSystem.get file    ${path_to_BBOX5_log_file}
    @{lines}=    Split To Lines    ${BBOX5_contents}
    Set Test Variable    @{lines}
    Should Match Regexp    ${lines[0]}    ^BlackBox ver: 5\\.\\d+$
    Check Last Save Time    @{lines}
    Check HW Information    @{lines}
    ${reset_counter}=    Get Reset Counter    @{lines}
    ${radio_sw}    ${previous_radio_sw}    Get Latest SW From History    @{lines}
    ${nvm_reset_trigger_count}    Get NvmFlushCounter Reset Trigger Count    @{lines}
    [Return]    ${reset_counter}    ${radio_sw}    ${nvm_reset_trigger_count}    ${previous_radio_sw}

Locate BBOX5 File In Snapshot And Extract It
   [Documentation]    Find the BBOX5 in snapshot for desired radio and extracts it. Takes the path to snapshot as argument and returns
   ...    the path to the extracted BBOX5 file.

   [Arguments]    ${snapshot_path}
   Log  Looking for BBOX5 for desired radio in snapshot  console=${True}
   ${snapshot_dict}   snapshot.Get Data From Snapshot  ${snapshot_path}
   Set Test Variable    ${snapshot_dict}

   ${current_sw_version}=  coam.Get Sw Version
   ${release}=    Evaluate    '${current_sw_version}'.split('_')[0]
   Set Test Variable    ${release}

   Run Keyword If    '${release}'=='SBTS25R1'
   ...    Extract BBOX5 Files until 25R1    ${snapshot_path}
   ...    ELSE    Extract BBOX5 Files after 25R2    ${snapshot_path}

Extract BBOX5 Files until 25R1
    [Arguments]    ${snapshot_path}
    FOR    ${key}    IN    @{snapshot_dict.keys()}
       ${blackbox_file}    get regexp matches    ${snapshot_dict["${key}"][0]}    \.+BTS_${serial_number}_RMOD_\\w_\\d_BBOX5_all\.zip
       Exit For Loop If    ${blackbox_file}
   END

   Run Keyword If    ${blackbox_file}    Extract log file    ${snapshot_path}    ${blackbox_file[0]}
   ...    ELSE    Fail    BBOX5_all.zip file not found for ${product_name} with SN ${serial_number}

Extract BBOX5 Files after 25R2
    [Arguments]    ${snapshot_path}
    FOR    ${key}    IN    @{snapshot_dict.keys()}
       ${blackbox_file}    get regexp matches    ${snapshot_dict["${key}"][0]}    \.+BTS${BTS_ID}_${serial_number}_RMOD_\\w_\\d_techlog_BBOX5_all\.zip
       Exit For Loop If    ${blackbox_file}
   END

   Run Keyword If    ${blackbox_file}    Extract log file    ${snapshot_path}    ${blackbox_file[0]}
   ...    ELSE    Fail    BBOX5_all.zip file not found for ${product_name} with SN ${serial_number}

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
    ...    Log    ${\n}Newest SW installed on BTS - CAN'T UPGRADE,${\n}Download and downgrade to: ${latestBuild[1]['name']}     console=${TRUE}    AND
    ...    Set Test Variable    ${new_sw}    ${latestBuild[1]['name']}
    ...    ELSE    Run Keywords    Log    ${\n}Newer SW available, download and upgrade to: ${latestBuild[0]['name']}    console=${TRUE}    AND
    ...    Set Test Variable    ${new_sw}    ${latestBuild[0]['name']}

    Wget to file    ${BUILD_PATH}/SBTS00/${new_sw}/${new_sw}_release_BTSSM_downloadable_A54.zip    ${BTS_files}/${new_sw}.zip
    Log    Download complete    console=${TRUE}
    ${new_radio_sw}    Get Rel5.1 SW From BTS SW Zip    ${BTS_files}/${new_sw}.zip
    Set Test Variable    ${new_radio_sw}
    Log    SW for release 5.1 radios will be: ${new_radio_sw}    console=${TRUE}
    Run Keyword If    '${new_radio_sw}' in '${initial_radio_sw}'  Run Keywords    Log    SW on radio will not change    console=${TRUE}    AND
    ...    Set Test Variable    ${RADIO_SW_UPDATE}    ${FALSE}
    ...    ELSE    Run Keywords    Log    SW on radio will be updated    console=${TRUE}    AND
    ...    Set Test Variable    ${RADIO_SW_UPDATE}    ${TRUE}

Get Rel5.1 SW From BTS SW Zip
    [Documentation]    Finds what software will be uploaded to release 5.1 radios from BTS software .zip. Uses TargetBD XML file
    ...    to find this. Takes the argument of the path where the SW .zip is found.

    [Arguments]    ${bts_sw_path}
    unpacking.Unpack Archive Content To Directory    ${bts_sw_path}    ${BTS_Files}/${new_sw}_unpacked
    ${TargetBD_filename}=    Run    ls ${BTS_Files}/${new_sw}_unpacked/bts_sw | grep TargetBD
    ${TargetBD_contents}    OperatingSystem.get file    ${BTS_Files}/${new_sw}_unpacked/bts_sw/${TargetBD_filename}
    @{lines}    Split To Lines    ${TargetBD_contents}

    FOR    ${line}    IN    @{lines}
        ${matches}    Get Regexp Matches    ${line}    .*RF.FRM5.*
        Run Keyword If    ${matches}    Exit For Loop
    END
    ${planned_radio_sw_unformatted}    Fetch From Right    ${matches[0]}    resourceSWVersion="
    ${planned_radio_sw}    Fetch From Left    ${planned_radio_sw_unformatted}    ">
    Run    rm -rf ${BTS_Files}/${new_sw}_unpacked
    [Return]    ${planned_radio_sw}

Wget to file
    [Documentation]    Downloads file from url and savess to destination.

	[Arguments]       ${url}              ${destination}
	${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
	Run keyword if    '${status}'!='0'    Log    ${output}
	Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

Get Random Available Rel5.1 RMOD
    [Documentation]    Checks for release 5.1 radios in configuration. Selects one at random and returns it.

    ${list_of_modules}    coam.Get Parameters For All    RMOD
    ${rel5_1_radios}    Create List
    ${BTS_parameters}    coam.Get Parameters For All    BTS
    FOR    ${module}  IN  @{BTS_parameters}
        ${bts_id}    Get From Dictionary    ${module}     btsId
    END
    FOR    ${module}  IN  @{list_of_modules}
        ${serial_number}    Get From Dictionary    ${module}    serialNumber
        ${product_code}    Get From Dictionary    ${module}    productCode
        ${product_name}    Get From Dictionary    ${module}    productName
        ${ip_address}    Get From Dictionary    ${module}    ipAddress
        ${rmod_id}    Get From Dictionary   ${module}    id
        ${dist_name}    Fetch From Right    ${rmod_id}    RUNTIME_VIEW-1/
        ${mrbts_r_id}    Fetch From left    ${dist_name}    /
        ${dist_name}    Remove String    ${dist_name}    ${mrbts_r_id}
        ${dist_name}    Set Variable    MRBTS-${bts_id}${dist_name}
        ${radio_module}    Create Dictionary  serial_number=${serial_number}   product_name=${product_name}    dist_name=${dist_name}
        ...    ip_address=${ip_address}    rmod_id=${rmod_id}    product_code=${product_code}
        ${found}=    Get Match Count    ${ALL_REL5.1}    ${product_name}
        Run Keyword If    '${found}'=='1'     Append To List    ${rel5_1_radios}    ${radio_module}
    END
    ${random_5_1_radio}=    Evaluate    random.choice($rel5_1_radios)    random
    [Return]    ${random_5_1_radio}

Collect Snapshot
    [Documentation]    Downloads full snapshot from BTS and returns the path of saved snapshot on VM.

    Log  Collecting snapshot...    console=${TRUE}
    ${timestamp}    Get time
    ${timestamp}    replace String Using Regexp    ${timestamp}    (${SPACE}|:|-)  _
    Set Test Variable  ${timestamp}
    ${log_status}    Run Keyword And Ignore Error    coam.Collect snapshot    ${BTS_Files}/snapshot_${timestamp}.zip    timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    '${log_status[0]}'=='FAIL'
    ...    Fail    Collecting snapshot failed
    ...    ELSE    Log    Snapshot has been successfully downloaded    console=${TRUE}
    Set Test Variable    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}.zip
    [Return]    ${path_to_Snapshot}

Extract log file
    [Documentation]    Extracts the desired file from snapshot and sets the variable path_to_log_file.

    [Arguments]    ${path_to_snapshot}    ${file_to_extract}
    unpacking.Unpack Archive Content To Directory    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}    Get Regexp Matches    ${file_to_extract}    [\\w.]+
    ${log_to_extract}    Replace String Using Regexp    ${zip_from_extract[0]}    (.zip)    ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}    ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}    ${BTS_Files}/BBOX5/${timestamp}

    Set Test Variable  ${path_to_log_file}  ${BTS_Files}/BBOX5/${timestamp}/BBOX5

Extract DateTime From Last Save Line
    [Documentation]    Gets the datetime string of the last save from BBOX5.  Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    ${line}
    ${datetime}=    Fetch From Right    ${line}    Last save:
    [Return]    ${datetime.strip()}

Get Time Difference In Seconds
    [Documentation]    Calculated the time delta in seconds between two datetime strings.

    [Arguments]    ${datetime1}    ${datetime2}
    ${extracted_datetime_obj}=    Convert Date    ${datetime1}    date_format=%Y-%m-%dT%H:%M:%S%z
    ${provided_datetime_obj}=    Convert Date    ${datetime2}    date_format=%Y-%m-%dT%H:%M:%S%z
    ${delta}=    DateTime.Subtract Date From Date    ${extracted_datetime_obj}    ${provided_datetime_obj}
    [Return]    ${delta}

Get Reset Counter
    [Documentation]    Gets the reset counter for radio from BBOX5. Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    @{lines}
    ${len}=    Get Length    ${lines}
    FOR    ${index}    IN RANGE    ${len}
        ${line}=    Set Variable    ${lines[${index}]}
        Run Keyword Unless    'Item type: resets' in '${line}'    Continue For Loop
        ${matches}=    Get Regexp Matches    ${lines[${index + 1}]}    Reset Counter: (\\d+)
        Run Keyword If    ${matches}    Exit For Loop
    END
    ${reset_counter}    Fetch From Right    ${matches[0]}      Reset Counter:
    [Return]    ${reset_counter.strip()}

Get Latest SW From History
    [Documentation]    Finds the two latest SW for radio from BBOX5 SW_history section. Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    @{lines}
    @{matches}=    Create List
    FOR    ${line}    IN    @{lines}
        ${match}    Run Keyword And Return Status    Should Match Regexp    ${line}    ^File\\[\\d\\] version: RF\\.FRM5.*
        Run Keyword If    ${match}    Append To List    ${matches}    ${line}
    END
    [Return]    ${matches[0]}    ${matches[1]}

Get NvmFlushCounter Reset Trigger Count
    [Documentation]    Gets the NvmFlushCounter for periodical and reset triggers from BBOX5. Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    @{lines}

    FOR    ${line}    IN    @{lines}
        ${matches_reset}    Get Regexp Matches    ${line}    ^Reset trigger occur times: (\\d+)
        Run Keyword If    ${matches_reset}    Exit For Loop
    END
    ${reset_trigger_count}=    Fetch From Right    ${matches_reset[0]}    Reset trigger occur times:

    [Return]    ${reset_trigger_count.strip()}

Check Last Save Time
    [Documentation]    Gets the time of last save from BBOX5, then calculated and compares the time difference between sending
    ...    the reset time command and last save. Uses TOLERANCE defined in variables section of this test case. Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    @{lines}
    ${extracted_datetime}=    Extract DateTime From Last Save Line   ${lines[1]}
    ${difference_in_seconds}=    Get Time Difference In Seconds    ${extracted_datetime}    ${RESET_DATE_TIME}
    Should Be True    ${difference_in_seconds} < ${TOLERANCE}
    Log    Last save time is correct    console=${TRUE}

Check HW Information
    [Documentation]    Checks if the format and content of lines containing radio product code and serial number. Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    @{lines}
    ${hw_info_index}    Find Line Index    @{lines}    target_line=Item type: HW_information

    Set Test Variable    ${EXPECTED_NEXT_LINE1}    None
    Set Test Variable    ${EXPECTED_NEXT_LINE2}    None
    Run Keyword If    '${release}'=='SBTS25R3'or'${release}'=='SBTS26R1'
   ...    Set HW Information format until 26R1
   ...    ELSE
   ...    Set HW Information format after 26R2

   ${extracted_product_code}=    Strip String    ${lines[${hw_info_index} + 1]}
   ${extracted_serial_number}=    Strip String    ${lines[${hw_info_index} + 2]}

    Should Be Equal As Strings    ${extracted_product_code}    ${EXPECTED_NEXT_LINE1}
    Should Be Equal As Strings    ${extracted_serial_number}    ${EXPECTED_NEXT_LINE2}
    Log    SN and product code in BBOX5 are correct    console=${TRUE}

Set HW Information format until 26R1
    Set Test Variable    ${EXPECTED_NEXT_LINE1}    radio product code: ${product_code}
    Set Test Variable    ${EXPECTED_NEXT_LINE2}    radio serial number: ${serial_number}

Set HW Information format after 26R2
    Set Test Variable    ${EXPECTED_NEXT_LINE1}    unit product code: ${product_code}
    Set Test Variable    ${EXPECTED_NEXT_LINE2}    unit serial number: ${serial_number}

Find Line Index
    [Documentation]    Finds the line number of target_line in a list of lines. Takes the argument of BBOX5 file
    ...    in the form of a list of lines, and the line that is being searched for.

    [Arguments]    @{lines}    ${target_line}
    ${i}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        Exit For Loop If    "${line}" == "${target_line}"
        ${i}=  Evaluate    ${i} +1
    END
    [Return]    ${i}

Get Latest ENB Build
    [Documentation]    Fetch newest and second newest build data from cloud-ute. KW uses external python script.

    Run    pip3 install ute_cloud_manager_api
    ${dir}=    Set Variable    ${BTS_Files}/AdditionalFiles
    Create Directory    ${dir}

    ${content}=    OperatingSystem.Get File    ${CURDIR}/../CBRS/Resources/Scripts/GetLatestBuildsFromCloud.py
    Create File    ${dir}/script.py    ${content}
    Run    chmod +x ${dir}/script.py

    ${token}=    Set Variable    b544df0b1ec8264cbde2f0a57e80984cf0e91f0f    # user API token from Cloud Manager

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

TC Setup
    Common Test Setup

Custom TC Teardown
    Run Keyword If    ${BTS_SW_CHANGED} is ${TRUE}    Run Keywords    Log    Rolling back to initial SW    console=${TRUE}    AND
    ...    coam.Rollback Software    AND
    ...    Wait Until Keyword Succeeds    6m   5s    ping_utils.Check If Host Is Not Pingable    192.168.255.129    AND
    ...    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States    AND
    ...    Wait Until Keyword Succeeds    15min    30s    coam.Assert alarm inactive    faultId=6327, severity=Major
    ...    ELSE    Log    Rollback not needed    console=${TRUE}
    Run    rm -rf ${BTS_Files}/snapshot*/

TC Teardown
    Custom TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown

