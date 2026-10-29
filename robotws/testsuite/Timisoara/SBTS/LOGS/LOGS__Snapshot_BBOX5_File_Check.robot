*** Settings ***
Documentation  Test for ASOE
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    SeleniumLibrary
Library    OperatingSystem
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot


*** Variables ***

${SNAPSHOT_TIMEOUT}    1200

*** Keywords ***
TC_LOGS__Snapshot_BBOX5_File_Check
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21295
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-05-04 - https://jira3.ext.net.nokia.com/browse/TAT-21295 - Initial Creation
    ...  - 2021-12-17 - https://jira3.ext.net.nokia.com/browse/TAT-22366 - RU list update
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-01-04 - TAT-22173-2  - Check RMOD Availability Status KW moved to resources -> Check RMOD States
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to verify if bbox5 file exist in snapshot for each 5.1 radio.
    ...  *******************
    ...  Test case flowchart:
    ...  *******************

    Set Tags   LOGS    OWNER-jakub.kokoszka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_5_Vrf    PHASE-CRT    SW-SBTS21

    Step 1: Preparation
    Step 2: 5.1 and 7.1 Radio check    ${list_of_rmods}
    Step 3: Snapshot collection
    Run Keyword If  '${TEST NAME}'=='[1]CB009514_KA_CB006622_Snapshot_BBOX5_File_Check'
    ...  Step 4: Verify snapshot for 7.1 Radios    ${list_of_rmods}
    ...  ELSE    Step 4: Verify snapshot for 5.1 Radios    ${list_of_rmods}

Set all 5.1 Radios
    @{ALL_REL5.1}  Set Variable  AAHF    AZHE    AZRA    AZRB    AZRC    AZND   AZFGA    AZNE    AREA    AZQF    AZQP    AZNC    AZNB    AZHC    AZHL
    ...  AZHB    AZQC    AZQS    AZQD    AZQU    AZNHA    AHEH    AZQB    AZQI    AZQJ    AZQR    AZQA    AZHA    AZNA    AHCA    AHCA-B    AHPD
    ...  AHPC   AHFB  AHMA  AHEE  AHBCB    AHBCA  AHFIC  AHGA    AHGC    AHPE  AHBCC  AHABCA  AHLOA  AHHB  AHHA  AHLBA  AHFIA  AHFIB  AHDA   AHPB
    ...  AHEGB  AHIB  AHBB  AHBA  AHLB  AHCE   AHCD  AHEGA  AHCB  AHAB  AHAA  AHDB  AHPMDA  AHLA  AHIA   AHIB  AHFA  AHED  AHEC  AHEA
    ...    AHEB  AEQP    AEQB    AEHB  AZQO  AEQN    AEQE   AEQV    AAFIA    AHCC+  FHEM   FZQN    AWHHD    AQQL
    Set Test Variable    @{ALL_REL5.1}

Set all 7.1 Radios
    @{ALL_REL7.1}  Set Variable  AVQL    AVQE    AVQQA    AVHA    AVQC    AVNB
    Set Test Variable    @{ALL_REL7.1}

Set Rel5.1 RMODs List
    ${list_of_rmods}    Get Rel5.1 RMODs List
    ${list_of_rmods}    Set Global Variable    ${list_of_rmods}

Set Rel7.1 RMODs List
    ${list_of_rmods}    Get Rel7.1 RMODs List
    ${list_of_rmods}    Set Global Variable    ${list_of_rmods}

Step 1: Preparation
    Log  \nStep 1: Preparation  console=${True}
    Log    Done    console=${TRUE}
    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${BTS_ID}  ${btsInfo['mrbtsID']}
    Run Keyword If  '${TEST NAME}'=='[1]CB009514_KA_CB006622_Snapshot_BBOX5_File_Check'
    ...  Set all 7.1 Radios
    ...  ELSE    Set all 5.1 Radios
    @{start_time}    Get Time    year month day hour min
    ${time_zone}    coam.Get Bts Time Zone
    ${time_zone_sign}    Get Substring    ${time_zone}    4    5
    ${time_zone_hour}    Get Substring    ${time_zone}    5    6
    ${time_zone_hour}    Evaluate    ${time_zone_hour}+1  #time shift +1h
    ${start_hour}    convert to integer    ${start_time[3]}
    ${t_minus}    Evaluate      ${start_hour}-${time_zone_hour}
    ${t_plus}    Evaluate      ${start_hour}-${time_zone_hour}
    Run Keyword If    '${time_zone_sign}'=='+'    Set List Value    ${start_time}    3    ${t_minus}
    ...    ELSE    Set List Value    ${start_time}    3    ${t_plus}
    ${start_time}    Set Global Variable    ${start_time}
    Run Keyword If  '${TEST NAME}'=='[1]CB009514_KA_CB006622_Snapshot_BBOX5_File_Check'
    ...  Set Rel7.1 RMODs List
    ...  ELSE    Set Rel5.1 RMODs List
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}

Step 2: 5.1 and 7.1 Radio check
    [Arguments]    ${list_of_rmods}

   Log  \nStep 2: 5.1 and 7.1 Radio check  console=${True}
   FOR  ${radio_module}  IN  @{list_of_rmods}
       SSHLibrary.Read
       ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
       ${product_name}    Get From Dictionary    ${radio_module}    product_name
       ${ip_address}    Get From Dictionary    ${radio_module}    ip_address
       ${dist_name}    Get From Dictionary   ${radio_module}    dist_name
       ${rmod_id}    Get From Dictionary   ${radio_module}    rmod_id
       Wait Until Keyword Succeeds    30 min  10 s  pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled
       Log    ${product_name} with SN ${serial_number} is available    console=${TRUE}
   END

Step 3: Snapshot collection
    [Documentation]
    ...  in this step test collect snapshot

   Log  \nStep 3: Snapshot collection  console=${True}
    ${timestamp}  Get time
    ${timestamp}  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}  ${_}=  Run Keyword And Ignore Error
    ...  coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${collect_snapshot_status}' == 'PASS'
    ...     Set global variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
    ...     ELSE  verdicts.Set Test Failed  Collecting snapshot via Admin failed.  ${TRUE}
    Log    Snapshot was collected    console=${TRUE}

Step 4: Verify snapshot for 5.1 Radios
    [Arguments]    ${list_of_rmods}
    [Documentation]
    ...  in this step test check if bbox5 file exist in snapshot zip.
    ...  every 5.1 radio should have BBOX5 file with radio serial number.

    Log  \nStep 4: Verify if collected snapshot includes bbox5 file  console=${True}
    FOR  ${radio_module}  IN  @{list_of_rmods}
        SSHLibrary.Read
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
#        ${BBOX5_file_name}  Set Variable  BTS_${serial_number}_RMOD_*_*_BBOX5_all.zip
        ${BBOX5_file_name}  Set Variable  BTS${BTS_ID}_${serial_number}_RMOD_*_*_BBOX5*
        ${found_file_dict}   snapshot.Get Data From Snapshot  ${path_to_snapshot}
        ${found_BBOX5_file}    Get Match Count    ${found_file_dict}    ${BBOX5_file_name}
        Run Keyword If    ${found_BBOX5_file}==1  Log    BBOX5 file for ${product_name} SN ${serial_number} was found.    console=${TRUE}
        Run Keyword If    ${found_BBOX5_file}==0  Fail  BBOX5 file for ${product_name} SN ${serial_number} wasn`t found.
    END
    Log    \n    console=${TRUE}
    Sleep  10s

Step 4: Verify snapshot for 7.1 Radios
    [Arguments]    ${list_of_rmods}
    [Documentation]
    ...  in this step test check if bbox5 file exist in snapshot zip.
    ...  every 7.1 radio should have BBOX5 file with radio serial number.

    Log  \nStep 4: Verify if collected snapshot includes bbox5 file for   console=${True}
    FOR  ${radio_module}  IN  @{list_of_rmods}
        SSHLibrary.Read
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
        ${BBOX5_file_name}  Set Variable  BTS${BTS_ID}_${serial_number}_RMOD_*_*_BBOX5_all.zip
#        ${BBOX5_file_name}  Set Variable  BTS_${serial_number}_RMOD_*_*_BBOX5*
        ${found_file_dict}   snapshot.Get Data From Snapshot  ${path_to_snapshot}
        ${found_BBOX5_file}    Get Match Count    ${found_file_dict}    ${BBOX5_file_name}
        Run Keyword If    ${found_BBOX5_file}==1  Log    BBOX5 file for ${product_name} SN ${serial_number} was found.    console=${TRUE}
        Run Keyword If    ${found_BBOX5_file}==0  Fail  BBOX5 file for ${product_name} SN ${serial_number} wasn`t found.
    END
    Log    \n    console=${TRUE}
    Sleep  10s

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
    END
    [Return]    ${rel5.1_radios}

Get Rel7.1 RMODs List
    ${list_of_modules}    coam.Get Parameters For All    RMOD
    ${rel7.1_radios}    Create List
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
        ${found}=    Get Match Count    ${ALL_REL7.1}    ${product_name}
        Run Keyword If    '${found}'=='1'     Append To List    ${rel7.1_radios}    ${radio_module}
    END
    [Return]    ${rel7.1_radios}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown

