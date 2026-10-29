*** Settings ***
Library     SSHLibrary    timeout=60s
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Keywords ***
TC__LOGS__Sanity_Check_triggered_by_NE_starts_up_successfully
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22036
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to check if Sanity Check occured after SMOD startup, based on requirement OM_GEN_SFS_SYSM.8086.
    ...  TC verifies path Sanity Check fails.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 12.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22036 - Initial creation
    ...  - 22.11.2021 - Test case enhanced: added check for SCF(model_5.ims2) presence on passive partition
    ...                 and check for alarm presence in RawAlarmHistory file
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-01-04 - TAT-22173-2  - Check All Modules And Cell State KW moved to resources -> Check All Modules And All Cells Working States
    ...  - 2022-01-10 - https://jira3.ext.net.nokia.com/browse/TAT-22443
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2022-10-06 - https://jiradc.ext.net.nokia.com/browse/TAT-23844 - solving the problem with "UnicodeDecodeError: utf-8"
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 20.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 01.06.2023 - TAT-25054 - due to CB008329 adding value: uboot_env set netboot=unknown
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Sanity_Check_triggered_by_NE_starts_up_successfully.png#
    ...



    Set Tags    CA-LOGS OWNER-justyna.durak@nokia.com AUTHOR-justyna.durak@nokia.com MAINTAINER-justyna.durak@nokia.com GROUP_IN_CHARGE-WRO_6_Vrf
    ...         PHASE-CRT SW-SBTS22 FEATURE-CB006772-SR

    Step 1: Check model_5.ims2 presence on BTS passive partition
    Step 2: Site Reset
    Step 3: Collect Snapshot
    Step 4: Find Sanity Checker Prints in BTSOM Log
    Step 5: Check Sanity Checker alarm in RawAlarmHistory file
    Step 6: Check trigger type via infomodel

Step 1: Check model_5.ims2 presence on BTS passive partition
    [Documentation]
    ...  Due to CB008329 (TAT-25054) netboot variable value is set to unknown in this step.

    Log  \nPreconditions  console=${True}

    #TAT-25054 BEGIN
    Set Test Variable  ${netboot_change_MSM}  ${False}
    Set Test Variable  ${netboot_change_ESM}  ${False}
    pm_logs_general.Check if MSM is FSMF
    Run Keyword If    ${MSM_is_FSMF}
    ...    Log    The MSM is FSMF in that case: "Set netboot to unknown on MSM" is not needed    console=${True}
    ...    ELSE
    ...    pm_logs_general.Set netboot to unknown on MSM
    pm_logs_general.Check if it is DualCore
    Run Keyword If    ${Dual}    pm_logs_general.Perform netboot to unknown for DualCore
    #TAT-25054 END

    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${file_presence}    Run Keyword and Return Status    SSHLibrary.File Should Exist    /ffs/stb/config/model_5.ims2
    Run Keyword If    ${file_presence}
    ...    SSHLibrary.Execute command    mount -o remount,rw /ffs/stb/; rm /ffs/stb/config/model_5.ims2
    SSHLibrary.Close Connection
    Log  \nFile model_5.ims2 missing from BTS passive partition, fault shoud be raised after Sanity Check  console=${True}

Step 2: Site Reset
    Log  \nStep 2: Site Reset  console=${True}
    coam.Reset Site    alias=default
    Wait Until Keyword Succeeds  15m  20s  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes

Step 3: Collect Snapshot
    Log  \nStep 3: Collect Snapshot  console=${True}
    @{time}=    Get Time    year month day hour min
    Set Test Variable  ${SNAPSHOT_LOCATION}  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}
    ${SNAPSHOT_TIMEOUT}  Set Variable  600
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${SNAPSHOT_LOCATION}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Log    Collecting snapshot via admin succeeded    console=yes
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

Step 4: Find Sanity Checker Prints in BTSOM Log
    Log  \nStep 4: Find Sanity Checker Prints in BTSOM Log  console=${True}
    Get Data From Snapshot and Set Test Variables for extracting SN
    ${log_file_location}  Extract Startup BTSOM Log File
    ${sanity_prints}    Run    grep 'Sanity' ${log_file_location}/startup_BTSOM.log
    ${sanity_check_status}  Run Keyword And Return Status   Should Contain   ${sanity_prints}   SanityCheckMsgReceiver
    Run Keyword If  ${sanity_check_status}
    ...  Log  Finding Sanity Checker prints in BTSOM Log succeed  console=true
    ...  ELSE
    ...  verdicts.Set Test Failed  Fail: No proper Sanity Checker prints in startup_BTSOM.log.  ${TRUE}

Get Data From Snapshot and Set Test Variables for extracting SN
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${bts_id}
    Set Test Variable  ${log_name_prefix}  BTS${bts_id}_1
    ${found_file_dict}  snapshot.Get Data From Snapshot  ${SNAPSHOT_LOCATION}.zip
    Set Test Variable  ${found_file_dict}

Extract Startup BTSOM Log File

    FOR  ${log_file}  IN  @{found_file_dict.keys()}
      ${startup_zip_file}  Get Regexp Matches  ${log_file}  ${log_name_prefix}011_startup.zip
      ${startup_zip_name}  Run Keyword If  ${startup_zip_file}  Fetch From Left  ${found_file_dict["${log_file}"][0]}  .zip
      Exit For Loop If  '${startup_zip_name}' != 'None'
    END

    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}.zip  ${SNAPSHOT_LOCATION}
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/${startup_zip_name}.zip  ${SNAPSHOT_LOCATION}/${startup_zip_name}
    unpacking.Unpack Archive Content To Directory
    ...  ${SNAPSHOT_LOCATION}/${startup_zip_name}/${log_name_prefix}011_startup.zip
    ...  ${SNAPSHOT_LOCATION}/${startup_zip_name}/${log_name_prefix}011_startup
    unpacking.Unpack Archive Content To Directory
    ...  ${SNAPSHOT_LOCATION}/${startup_zip_name}/${log_name_prefix}011_startup/startup_BTSOM.log.xz
    ...  ${SNAPSHOT_LOCATION}/${startup_zip_name}/${log_name_prefix}011_startup/startup_BTSOM_unpacked

    [Return]  ${SNAPSHOT_LOCATION}/${startup_zip_name}/${log_name_prefix}011_startup/startup_BTSOM_unpacked

Step 5: Check Sanity Checker alarm in RawAlarmHistory file
    Log  \nStep 5: Check Sanity Checker alarm in RawAlarmHistory file  console=${True}
    ${rah_location}  Extract RawAlarmHistory from SMOD1
    ${sanity_alarm_presence}  Run Keyword and Return Status  OperatingSystem.Grep File  ${rah_location}  SanityCheckErr
    Run Keyword If  ${sanity_alarm_presence}
    ...  Log  Finding Sanity Checker alarm in RawAlarmHistory succeed  console=true
    ...  ELSE
    ...  verdicts.Set Test Failed  Fail: No Sanity Checker alarm.  ${TRUE}

Extract RawAlarmHistory from SMOD1

    FOR  ${log_file}  IN  @{found_file_dict.keys()}
      ${rah_xz_file}  Get Regexp Matches  ${log_file}  ${log_name_prefix}011_RawAlarmHistory.txt.xz
      ${part_with_rah_xz}  Run Keyword If  ${rah_xz_file}  Fetch From Left  ${found_file_dict["${log_file}"][0]}  .zip
      Exit For Loop If  '${part_with_rah_xz}' != 'None'
    END

    ${rah_name}  Set Variable  ${log_name_prefix}011_RawAlarmHistory
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/${part_with_rah_xz}.zip  ${SNAPSHOT_LOCATION}/${part_with_rah_xz}
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/${part_with_rah_xz}/${rah_name}.txt.xz
    ...  ${SNAPSHOT_LOCATION}/${part_with_rah_xz}/${rah_name}_unpacked

    [Return]  ${SNAPSHOT_LOCATION}/${part_with_rah_xz}/${rah_name}_unpacked/${rah_name}.txt

Step 6: Check trigger type via infomodel
    Log  \nStep 6: Check trigger type via infomodel  console=${True}
    ${sanity_checker}=  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/CABINET_L-*/SMOD_L-*/SANITY_CHECK-*
    ...  timeout=60
    Run Keyword If  '${sanity_checker['triggerType']}'=='Startup' and '${sanity_checker['systemModuleResult'][0]['operationStatus']}'=='Failure'
    ...  Log  Sanity Check triggered correctly via Startup  console=true
    ...  ELSE
    ...  verdicts.Set Test Failed  Fail: Wrong trigger type for Sanity Check.  ${TRUE}

Custom Test Teardown
    [Documentation]
    ...  Due to CB008329 (TAT-25054) netboot variable value is back to netboot_first.

    Log  \nCustom Test Teardown  console=${True}
    #TAT-25054 BEGIN
    Run Keyword If    ${netboot_change_MSM}    pm_logs_general.Back netboot to netboot_first on MSM
    Run Keyword If    ${netboot_change_ESM}    pm_logs_general.Back netboot to netboot_first on ESM
    #TAT-25054 END

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
