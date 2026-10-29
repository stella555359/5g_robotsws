*** Settings ***
Documentation    Test Case CB007833_check_24h_save_period
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/verdicts.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     SeleniumLibrary
Library     OperatingSystem
Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot


*** Variables ***
${SNAPSHOT_TIMEOUT}    1200

*** Keywords ***
TC_LOGS__CB007833_BlackBox_check_24h_save_period
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22310
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-12-06 - https://jira3.ext.net.nokia.com/browse/TAT-22310 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-01-04 - TAT-22173-2  - Check RMOD Availability Status KW moved to resources -> Check RMOD States
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax, changed 'in range' operator to all caps to prevent warn
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to verify if bbox5 file exist in snapshot for each radio from list and check 24h save period
    ...  *******************
    ...  Test case flowchart:
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__CB007833_BlackBox_check_24h_save_period.png
    ...  *******************

    Set Tags   LOGS    OWNER-jakub.kokoszka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_5_Vrf    PHASE-CRT    SW-SBTS22R1


    Step 1: Preparation
    Step 2: Radio check
    Step 3: Snapshot collection
    Step 4: Verify snapshot
    Step 5: Waiting 24h for next BBOX5 save
    Step 6: Snapshot collection after 24h
    Step 7: Verify if collected snapshot includes bbox5 file after 24h
    Step 8: Last save item check



Step 1: Preparation
    Log  \nStep 1: Preparation  console=${True}
    Log    Done    console=${TRUE}
    @{ALL_REL5.1}  Set Variable  AAHF    AZHE    AZRA    AZRB    AZRC    AZND   AZFGA    AZNE    AREA    AZQF    AZQP    AZNC    AZNB    AZHC    AZHL
    ...  AZHB    AZQC    AZQS    AZQD    AZQU    AZNHA    AHEH    AZQB    AZQI    AZQJ    AZQR    AZQA    AHGC    AHPE  AHBCC  AHABCA  AHLOA  AHHB
    ...  AZHA    AZNA    AHCA    AHCA-B    AHPD    AHPC   AHFB  AHMA  AHEE  AHBCB    AHBCA  AHFIC  AHGA  AHHA  AHLBA  AHFIA  AHFIB  AHDA   AHPB
    ...  AHIB  AHBB    AEQE   AEQV    AAFIA    AHCC+  FHEM   FZQN    AWHHD    AQQL  AHEGB    AHEA  AHEB  AEQP    AEQB    AEHB  AZQO  AEQN
    ...  AHBA  AHLB  AHCE   AHCD  AHEGA  AHCB  AHAB  AHAA  AHDB   AHPMDA  AHLA  AHIA  AHFA  AHED  AHEC

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

    Set Test Variable    @{ALL_REL5.1}
    ${list_of_rmods}    Get Rel5.1 RMODs List
    ${list_of_rmods}    Set Test Variable    ${list_of_rmods}
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    ${RU_time_now_list}  Create List
    Set Test Variable  ${RU_time_now_list}
    ${RU_time_after_24h_list}  Create List
    Set Test Variable  ${RU_time_after_24h_list}


Step 2: Radio check
    [Documentation]
    ...  in this step test check if supported radio from list are available

    Log  \nStep 2: Radio check  console=${True}
    ${isEmpty}  Get length  ${rel5.1_radios}
    Log  ${isEmpty}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  detected not supported radio.  ${TRUE}
    ...  ELSE  Radio check


Step 3: Snapshot collection
    [Documentation]
    ...  in this step test collect snapshot

    Log  \nStep 3: Snapshot collection  console=${True}
    Snapshot collection


Step 4: Verify snapshot
    [Documentation]
    ...  in this step test check if bbox5 file exist in snapshot zip.
    ...  every radio from list should have BBOX5 file with radio serial number.

    Log  \nStep 4: Verify if collected snapshot includes bbox5 file  console=${True}
    Verify snapshot


Step 5: Waiting 24h for next BBOX5 save
    Log  \nStep 5: Waiting 24h for next BBOX5 save  console=${True}
    ${waiting_time}  Set Variable  86460
    Sleep  ${waiting_time}s  reason=Waiting 24h for next BBOX5 save. Waiting ${waiting_time} s...



Step 6: Snapshot collection after 24h
    Log  \ntep 6: Snapshot collection after 24h  console=${True}
    Snapshot collection


Step 7: Verify if collected snapshot includes bbox5 file after 24h
    [Documentation]
    ...  in this step test check if bbox5 file exist in snapshot zip

    Log  \nStep 7: Verify if collected snapshot includes bbox5 file after 24h  console=${True}
    Verify snapshot after 24h
    Log  ${RU_time_now_list}
    Log  ${RU_time_after_24h_list}


Step 8: Last save item check
    [Documentation]
    ...  in this step test check if last save item was update after 24h

    Log  \nStep 8: Last save item check  console=${True}
    ${len_list}  get length  ${RU_time_now_list}
    FOR  ${i}  IN RANGE  ${len_list}
        ${BBOX5_Data_plusDay}  Add Time To Date  ${RU_time_now_list[${i}]}  1 day
        ${BBOX5_DataCheck}  Fetch From Left  ${BBOX5_Data_plusDay}  00:
        Run Keyword If    '${BBOX5_DataCheck.strip()}' == '${RU_time_after_24h_list[${i}].strip()}'
        ...   Log    Item Last save: in BBOX5 file correct.    console=${TRUE}
        ...     ELSE  verdicts.Set Test Failed  Last save item date incorrect.  ${TRUE}
    END



Verify snapshot
    [Documentation]
    ...  KW check if snapshot contain BBOX5 file ex.
    ...  BTS_${serial_number}_RMOD_*_*_BBOX5.xz = BTS_EA174113456_RMOD_L_5_BBOX5.xz
    ...  all radios on BTS listed on @{ALL_REL5.1} should have one BBOX5 .xz file
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
        ${BBOX5_file_name}  Set Variable  BTS${BTS_ID}_${serial_number}_RMOD_*_*_BBOX5_all.zip
        Set Test Variable    ${BBOX5_file_name}
        ${found_file_dict}   snapshot.Get Data From Snapshot  ${path_to_snapshot}
        ${found_BBOX5_file}    Get Match Count    ${found_file_dict}    ${BBOX5_file_name}
        Run Keyword If    ${found_BBOX5_file}==1
        ...   Log    BBOX5 file for ${product_name} SN ${serial_number} was found.    console=${TRUE}
        Run Keyword If    ${found_BBOX5_file}==0  Fail  BBOX5 file for ${product_name} SN ${serial_number} wasn`t found.
        Check BBOX5 Last save
    END
    Log    \n    console=${TRUE}
    Sleep  10s

Verify snapshot after 24h
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
        ${BBOX5_file_name}  Set Variable  BTS${BTS_ID}_${serial_number}_RMOD_*_*_BBOX5_all.zip
        Set Test Variable    ${BBOX5_file_name}
        ${found_file_dict}   snapshot.Get Data From Snapshot  ${path_to_snapshot}
        ${found_BBOX5_file}    Get Match Count    ${found_file_dict}    ${BBOX5_file_name}
        Run Keyword If    ${found_BBOX5_file}==1  Log    BBOX5 file for ${product_name} SN ${serial_number} was found.    console=${TRUE}
        Run Keyword If    ${found_BBOX5_file}==0  Fail  BBOX5 file for ${product_name} SN ${serial_number} wasn`t found.
        Check BBOX5 Last save after 24h
    END
    Log    \n    console=${TRUE}
    Sleep  10s

Snapshot collection
    ${timestamp}  Get time
    ${timestamp}  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}  ${ingnored_error}=  Run Keyword And Ignore Error
    ...     coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${collect_snapshot_status}' == 'PASS'
    ...     Set global variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
    ...     ELSE  verdicts.Set Test Failed  Collecting snapshot via Admin failed.  ${TRUE}
    Log    Snapshot was collected    console=${TRUE}

Radio check
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
        ${ip_address}    Get From Dictionary    ${radio_module}    ip_address
        ${dist_name}    Get From Dictionary   ${radio_module}    dist_name
        ${rmod_id}    Get From Dictionary   ${radio_module}    rmod_id
        Wait Until Keyword Succeeds    30 min    10 s    pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled
        Log    ${product_name} with SN ${serial_number} is available    console=${TRUE}
    END

Check BBOX5 Last save after 24h
    Log  Check BBOX5 Last save after 24h  console=${True}
    ${zip_part}    ${blackbox5_file_name_with_bracket}  BlackBoxPartCheck
    ${zip_part_number_2}  Get Substring  ${zip_part}  8  11
    ${zip_part_number}  Fetch From Left  ${zip_part_number_2}  .
    ${blackbox5_file_name}  Convert To String  ${blackbox5_file_name_with_bracket[0]}
    ${SNAPSHOT_LOCATION}  Set Variable  ${BTS_Files}
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${SNAPSHOT_LOCATION}/ex24
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex24/BTS_part${zip_part_number}.zip  ${SNAPSHOT_LOCATION}/ex24/ex24_2
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex24/ex24_2/${blackbox5_file_name}  ${SNAPSHOT_LOCATION}/ex24/ex24_2/ex24_3
    ${blackbox5_file_name_without_qz}  Fetch From Left  ${blackbox5_file_name}  .
    ${UnpackedBlackBoXFile}  Set Variable  ${SNAPSHOT_LOCATION}/ex24/ex24_2/ex24_3/BBOX5
    ${BBOX5_LastSave_after24}  Grep File  ${SNAPSHOT_LOCATION}/ex24/ex24_2/ex24_3/BBOX5  save:
    Log  ${BBOX5_LastSave_after24}
    ${BBOX5_LastSave_after24_1}  Fetch From Left  ${BBOX5_LastSave_after24}  T
    Log  ${BBOX5_LastSave_after24_1}
    ${BBOX5_LastSave_after24h}  Fetch From Right  ${BBOX5_LastSave_after24_1}  :
    Log  ${BBOX5_LastSave_after24h}
    Append To List    ${RU_time_after_24h_list}    ${BBOX5_LastSave_after24h}

Check BBOX5 Last save
    Log  Check BBOX5 Last save  console=${True}
    ${zip_part}    ${blackbox5_file_name_with_bracket}  BlackBoxPartCheck
    ${zip_part_number_2}  Get Substring  ${zip_part}  8  11
    ${zip_part_number}  Fetch From Left  ${zip_part_number_2}  .
    ${blackbox5_file_name}  Convert To String  ${blackbox5_file_name_with_bracket[0]}
    ${SNAPSHOT_LOCATION}  Set Variable  ${BTS_Files}
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${SNAPSHOT_LOCATION}/ex
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/BTS_part${zip_part_number}.zip  ${SNAPSHOT_LOCATION}/ex/ex2
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/ex2/${blackbox5_file_name}  ${SNAPSHOT_LOCATION}/ex/ex2/ex3
    ${blackbox5_file_name_without_qz}  Fetch From Left  ${blackbox5_file_name}  .
    ${UnpackedBlackBoXFile}  Set Variable  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/BBOX5
    ${BBOX5_LastSave}  Grep File  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/BBOX5  save:
    Log  ${BBOX5_LastSave}
    ${BBOX5_LastSave_1}  Fetch From Left  ${BBOX5_LastSave}  T
    Log  ${BBOX5_LastSave_1}
    ${BBOX5_LastSave_now}  Fetch From Right  ${BBOX5_LastSave_1}  :
    Log  ${BBOX5_LastSave_now}
    Append To List    ${RU_time_now_list}    ${BBOX5_LastSave_now}

BlackBoxPartCheck
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    Log  ${found_file_dict}
    ${part_number_with_startup_zip}  Set variable  ${False}
    ${temp}   Create List
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
        Append to List   ${temp}    ${log_file}
        ${BBOX5_zip_file}  Get Matches  ${temp}  ${BBOX5_file_name}
        Remove From List   ${temp}   0
        ${BBOX5_zip_file_len}   Get Length   ${BBOX5_zip_file}
        Exit For Loop If  ${BBOX5_zip_file_len}>0
    END
    [Return]  ${found_file_dict["${log_file}"][0]}    ${BBOX5_zip_file}

Get Rel5.1 RMODs List
    ${list_of_modules}    coam.Get Parameters For All    RMOD
    ${rel5.1_radios}    Create List
    ${BTS_parameters}    coam.Get Parameters For All    BTS
    FOR    ${module}  IN  @{BTS_parameters}
        ${bts_id}    Get From Dictionary    ${module}     btsId
    END
    FOR    ${module}  IN  @{list_of_modules}
        ${serial_number}    Get From Dictionary    ${module}    serialNumber
        ${product_name}    Get From Dictionary    ${module}    productName
        ${ip_address}    Get From Dictionary    ${module}    ipAddress
        ${rmod_id}    Get From Dictionary   ${module}    id
        ${dist_name}    Fetch From Right    ${rmod_id}    RUNTIME_VIEW-1/
        ${mrbts_r_id}    Fetch From left    ${dist_name}    /
        ${dist_name}    Remove String    ${dist_name}    ${mrbts_r_id}
        ${dist_name}    Set Variable    MRBTS-${bts_id}${dist_name}
        ${radio_module}    Create Dictionary  serial_number=${serial_number}   product_name=${product_name}    dist_name=${dist_name}
        ...    ip_address=${ip_address}    rmod_id=${rmod_id}
        ${found}=    Get Match Count    ${ALL_REL5.1}    ${product_name}
        Run Keyword If    '${found}'=='1'     Append To List    ${rel5.1_radios}    ${radio_module}
        Set Test Variable  ${rel5.1_radios}
    END
    [Return]    ${rel5.1_radios}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
