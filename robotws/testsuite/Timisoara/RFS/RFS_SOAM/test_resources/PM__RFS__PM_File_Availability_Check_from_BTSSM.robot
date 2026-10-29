*** Settings ***
Documentation    TC__PM__RFS__PM_File_Availability_Check_from_BTSSM
Variables    tc_variables/PM__RFS__PM_File_Availability_Check_from_BTSSM.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${PM_DIR_PATH}               # Path for PM archive collection folder. Use as beneath (more details as in documentation): if empty, default PM archive
                             # collection folder: /home/ute/btsauto/Autotest/automated_<date_time>/<date_time>_TestName/PMFiles; if valued, create
                             # new PM archive collection folder with input value: /home/ute/PMFiles (for exemple)
${PM_CHECK_PERIOD}    90      # Time period in minutes for PM collection and check procedure
${PM_CHECK_INTERVAL}    10    # Time interval in minutes to repeat PM collection and check procedure in case of failure


*** Keywords ***
TC__PM__RFS__PM_File_Availability_Check_from_BTSSM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-8621
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case for LTE PM archive collection and check.
    ...  PM_DIR_PATH - variable value related to PM archive collection folder. Use as below:
    ...  - if empty, default PM archive collection folder: /home/ute/btsauto/Autotest/automated_<date_time>/<date_time>_TestName/PMFiles
    ...  - if valued, create new PM archive collection folder with input value: /home/ute/PMFiles (for exemple)
    ...  The main steps performed for the test are:
    ...  - set PM collection interval between 05-55 minutes of current hour
    ...  - collect PM archive from Master/Slave BTS to VM
    ...  - check PM archive for Master/Slave stored on VM
    ...  Pass criteria: Passed/Failed
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.12.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-8621 - Test delivered
    ...  - 26.01.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-7841 - Unified test format: Run Cycle, indentation and repeat variable
    ...                                                                   REPEAT_COUNTER
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 02.04.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-9628 - [RFS_SOAM] [P3.5] New TC, PM__RFS__PM_File_Availability_Check_from_BTSSM
    ...  - 03.08.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-11171 - Prefix all Test Cases inside all robots with [1]
    ...                                                                    to match the QC instances names
    ...  - 29.10.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-12890 - [daily_acceptance] RRM, LOGS and PM tests also need variable files
    ...  - 30.01.2020 -  https://jiradc.ext.net.nokia.com/browse/TAT-18765 - [RFS_SOAM][SBTS-GSM] SBTS_GSM_RFS_PM_File_Availability_Check_from_WebEM
    ...  - 05.04.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20862 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - SBTS_GSM, RRM,
    ...                                                                    Recovery
	...  - 03.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27196 - [5G] Include SCF validation with hardware check in common test setup
	...  - 12.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27020 -
    ...  [5G] Remove common part supporting WBTS (for WL, WCDMA_SBTS TC) -after TAT-27019    ...
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27717 - [Cloud][RF5] Update robotws testcases - NRL, NR_NR, NR_SBTS, RRM, PM, LOGS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-8621_PM__RFS__PM_File_Availability_Check_from_BTSSM.png


    Set Tags    CA-LOGS    OWNER-sergiu_bobeica@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-WBTS18,SBTS18
    ...    CABLING-RFS_01_UE

    PM archive collection and check from all BTS


PM archive collection and check from all BTS
    Wait Until Keyword Succeeds  ${PM_CHECK_PERIOD} min  ${PM_CHECK_INTERVAL} min  PM archive collection and check  Master
    Wait Until Keyword Succeeds  ${PM_CHECK_PERIOD} min  ${PM_CHECK_INTERVAL} min  PM archive collection and check  Slave

PM archive collection and check
    [Documentation]
    ...  KW to get UTC time from VM

    [Timeout]  15 min
    [Arguments]  ${alias}
    Set Test Variable  ${PM_collect}  ${True}
    Set Test Variable  ${PM_check}  ${True}
    Get time for PM archive collection
    Collect PM archive from BTS  alias=${alias}
    Run Keyword If  not ${PM_collect}  Run Keywords
    ...  Log  PM archive collection failed, retry PM procedure in ${PM_CHECK_INTERVAL} minutes ...  console=True
    ...  AND  Fail
    Check PM archive on VM  alias=${alias}
    Run Keyword If  not ${PM_check}  Run Keywords
    ...  Log  PM archive check failed, retry PM procedure in ${PM_CHECK_INTERVAL} minutes ...  console=True
    ...  AND  Fail

Get time for PM archive collection
    [Documentation]
    ...  KW to get UTC time from VM

    [Timeout]  15 min
    Wait Until Keyword Succeeds  12 min  1 min  Set time for PM archive collection
    ${VM_UTC_date}=  OperatingSystem.Run  date -u +"%Y%m%d.%H"
    Set Test Variable  ${VM_UTC_date}

Collect PM archive from BTS
    [Documentation]
    ...  Collect PM archive from BTS. Works for WCDMA and LTE.

    [Timeout]  15 min
    [Arguments]  ${alias}
    ${alias_upper}=  Convert To Uppercase  ${alias}
    ${folder_path}=  Run Keyword If  '${PM_DIR_PATH}' == ''  Set Variable  ${Test Results Dir}/PMFiles
    ...  ELSE  Set Variable  ${PM_DIR_PATH}
    Set Test Variable  ${folder_path}  ${folder_path}

    Log  ===== Collect PM archive from ${alias} ${${alias_upper}}[${alias_upper}_TECH] BTS =====  console=True
    Run Keyword If  '${${alias_upper}}[${alias_upper}_TECH]' in ['NR','LTE','SBTS']
    ...  Admin Collect PM Files  ${alias}  ${folder_path}  ${${alias_upper}}[${alias_upper}_TRS_IP_ADDRESS]_PMFiles.zip

Check PM archive on VM
    [Documentation]
    ...  Check PM archive from BTS. Works for LTE.

    [Timeout]  5 min
    [Arguments]  ${alias}
    ${alias_upper}=  Convert To Uppercase  ${alias}

    Log  ===== Check PM archive from ${${alias_upper}}[${alias_upper}_TECH] BTS =====  console=True
    Check PM files on VM  PM_folder_archive=${folder_path}/${${alias}_PM_ARCHIVE}  alias=${alias}

Set time for PM archive collection
    [Documentation]
    ...  KW to set time for PM collection as follows:
    ...  - if minute of current hour >= ${end_time_interval} wait until minute of next hour >= ${start_time_interval}
    ...  - if minute of current hour < ${start_time_interval} wait until minute of current hour >= ${start_time_interval}

    [Timeout]  15 min
    [Arguments]  ${start_time_interval}=5  ${end_time_interval}=55
    ${VM_UTC_current_date}=  OperatingSystem.Run  date -u +"%Y-%m-%d %T"
    ${VM_time_min}=  OperatingSystem.Run  date +"%M"
    ${VM_time_min}=  Convert To Integer  ${VM_time_min}
    Log  UTC current time on VM: ${VM_UTC_current_date}  console=True
    Run Keyword If  ${VM_time_min} < ${start_time_interval} or ${VM_time_min} >= ${end_time_interval}  Run Keywords
    ...  Log  Wait for PM collection interval: ${start_time_interval} - ${end_time_interval} minutes of current hour  console=True
    ...  AND  Log  - if minute of current hour >= ${end_time_interval} wait until minute of next hour >= ${start_time_interval}  console=True
    ...  AND  Log  - if minute of current hour < ${start_time_interval} wait until minute of current hour >= ${start_time_interval}  console=True
    ...  AND  Fail


TC Setup
    Common Test Setup    PrecheckConf=${FALSE}    PrecheckCells=${FALSE}    PrecheckModules=${FALSE}    PrecheckSCF=${FALSE}
    ...  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown


