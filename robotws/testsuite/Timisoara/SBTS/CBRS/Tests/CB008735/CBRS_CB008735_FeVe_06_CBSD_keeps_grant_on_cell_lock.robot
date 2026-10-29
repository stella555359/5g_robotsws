*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Karol.Sadowski@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    Elzbieta.Wlodarczyk@nokia.com
...    Aleksandra.Chudzik@nokia.com
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1249/

*** Keywords ***
CBRS_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.520
    ...              Purpose: In this user scenario, when a cell is locked by operator or locked
    ...              automatically, the grant is maintained by the CBSD and is not relinquished
    ...              until LockCellTimer expires (default 60min)
    ...              Test Steps:
    ...              Step 1: Block all cells
    ...              Step 2: check if grant state does not change before expiry of LockCellTimer and no relinquishment
    ...                      is present in SAS log
    ...              Step 3: unblock all cells
    ...              Step 4: Block all cells
    ...              Step 5: check if grant state does change after expiry of LockCellTimer and relinquishment
    ...                      is present in SAS log


    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarms}   Create Dictionary    fault_id=49
    ...                                         fault_name=Cell blocked
    ...                                         severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarms}

    Log To Console    ${\n}Changing SWconfig flag. BTS reboot is expected afterwards ${\n}
    Change Swconfig Flag    flag=0x45000D    value=300    #LockCellTimer set to 300 sec
    Wait Until Keyword Succeeds    5x    30s    Reset Site    connection=RAT_1ST

    Kill All SAS Processes

    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/Feve06/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${grant_info}   Get Grant Details For Each CBSD Cell
    Block All Cells    connection=RAT_1ST    rat=LTE
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarms}[fault_id]
    ...                                   fault_name=${expected_alarms}[fault_name]
    ...                                   severity=${expected_alarms}[severity]
    ...                                   timeout=60
    Log To Console    All cells blocked
    Log To Console    Query GRANT_INFO objects for 4 min (shorter than LockCellTimer) to confirm all grants stay 'authorized'

    ${grant_query}   Run Keyword And Return Status    ute_admin_infomodel.Wait For Infomodel Event
    ...                                                 event=change /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*
    ...                                                 timeout=240
    ...                                                 alias=RAT_1ST
    IF  ${grant_query}  Fail  msg=Grants were relinquished after cell block and before expiry of LockCellTimer

    ${time_stop}   Get Time

    Log To Console    Checking SASSim.log. No relinquishmentRequest is expected.
    ${parsed_log_file}   Parse Sas Log File
    ...                    log_file_name=${sas_logs_dir}
    ...                    date_start=${time_start}
    ...                    date_stop=${time_stop}
    ${relinquishmentRequest}   Extract Values From Sas Log
    ...                          log_name=${parsed_log_file}
    ...                          parameter=grantId
    ...                          data_type=relinquishmentRequest
    Should Be Empty    ${relinquishmentRequest}
    ...                msg=With grant update procedure, CBSD should not relinquish old grant.
    Log To Console    SASSim.log correct. No relinquishmentRequest is recorded.

    Unblock All Cells    connection=RAT_1ST    rat=LTE
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarms}[fault_id]
    ...                                     fault_name=${expected_alarms}[fault_name]
    ...                                     severity=${expected_alarms}[severity]
    ...                                     timeout=60
    Log To Console    All cells unblocked
    Wait For All Cells To Be OnAir
    ${grantId_list}   List Values of GrantId For All Cells    ${enb_id}

    ${time_start}   Get Time
    Block All Cells    connection=RAT_1ST    rat=LTE
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarms}[fault_id]
    ...                                   fault_name=${expected_alarms}[fault_name]
    ...                                   severity=${expected_alarms}[severity]
    ...                                   timeout=60
    Log To Console    All cells blocked
    Log To Console    Query GRANT_INFO objects for 6 min (longer than LockCellTimer) to confirm grantState changes from 'authorized'

    ${grant_query}   Run Keyword And Return Status    ute_admin_infomodel.Wait For Infomodel Event
    ...                                                 event=change /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*
    ...                                                 timeout=360
    ...                                                 alias=RAT_1ST
    IF  ${grant_query}  Log To Console  grantState updated as expected.

    Sleep    10s    #to allow processing of grant relinquishment
    ${time_stop}   Get Time

    Log To Console    Checking SASSim.log. Relinquishment of four grants is expected.
    Verify Grant Relinquishment Procedure    time_start=${time_start}
    ...                                      time_stop=${time_stop}
    ...                                      sas_log_path=${sas_logs_dir}
    ...                                      grantId_list=${grantId_list}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Unblock All Cells    connection=RAT_1ST    rat=LTE    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Remove Swconfig Flag    0x45000D     AND
    ...                           Reset Site    connection=RAT_1ST
