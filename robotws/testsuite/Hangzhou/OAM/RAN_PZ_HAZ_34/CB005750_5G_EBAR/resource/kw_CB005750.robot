#-----------------------------------------------------------------------
Documentation
...    author: Zhu felix
...    contact: felix.zhu@nokia-sbell.com
...    Feature 5G_CB005750 in 5G21A program
#

#CB005750 cases keyword

#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
*** Settings ***
#-----------------------------------------------------------------------

# WARNING: assume that robot and TAF libraries are loaded in caller.


#-----------------------------------------------------------------------
*** Variables ***
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
*** Keywords ***
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# [1.0] CB005750_5G_EBAF_002_CB005750_5GC000169_Fault7516_EFaultId_IncorrectCellParameterSettingAl
#-----------------------------------------------------------------------

Precondition: NR cells can be on air and no fault 7516 visible
    log to console     \n *Precondition: NR cells can be on air and no fault 7516 visible*

    coam_admin.connect_to
    ...        bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...        username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...        password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    #...        name=${connection}


    ${RES}=    coam_admin.get_bts_statuses
    should be equal as strings    ${RES['proceduralState']}    OnAir    msg=gNB is not OnAir
    log to console       \n......wait 10min
    sleep    600s
    Check Alarm Not Active in Raw file    7516
    Check Alarm Cleared                   7516

    ${cell_list}=    coam_admin.get_cell_list
    FOR     ${cell}    IN    @{cell_list['cells']['nr']}
        ${operational_state}    Convert To Lower Case    ${cell['status']['operationalState']}
        continue for loop if   '${operational_state}' != 'enabled'
        ${cell_DN}=    set variable    ${cell['id']['configuration']}
    END
    should not be equal    ${cell_DN}    unknown     msg=no cell Online found
    log    \n....... NR cells are on air    console=${true}

    ${raw_alarms}=    Get Active Alarms From Raw file
    ${alarms_number}=     coam_admin.get_active_alarms_number


    set test variable    ${cell_DN}
    set test variable    ${raw_alarms}
    set test variable    ${alarms_number}

Step 1: change parameter 'gscn'
    log to console     \n Step 1: change parameter 'gscn'

    ${status}    run keyword and return status   Get Parameter    ${cell_DN}   gscn
    ${gscn_name}=     run keyword if   ${status}   set variable   gscn
    ...             ELSE    set variable   gscnOrSsPbchArfcn
    ${old_gscn}=    Get Parameter    ${cell_DN}   ${gscn_name}
    set test variable   ${old_gscn}
    set test variable   ${gscn_name}
    log    \n....... lock cell ${cell_DN} and change gscn value to ${new_gscn_value}    console=${true}
    Change Parameter    ${cell_DN}    administrativeState    Locked
    Wait Until Keyword Succeeds    3min    5s    Check Cell Disabled    ${cell_DN}
    Change Parameter    ${cell_DN}    ${gscn_name}    ${new_gscn_value}
    Change Parameter    ${cell_DN}    administrativeState    Unlocked

Step 2: check alarm 7516 is raised
    log to console     \n Step 2: check alarm 7516 is raised
    Wait Until Keyword Succeeds    3min    5s    Check Alarm Active in Raw file    7516
    Check Alarm Raised                7516
    log    \n....... alarm 7516 is raised    console=${true}

Step 3: revert parameter 'gscn'
    log to console     \n Step 3: revert parameter 'gscn'
    log    \n....... lock cell ${cell_DN} and change gscn value to ${old_gscn}    console=${true}
    Change Parameter    ${cell_DN}    administrativeState    Locked
    Wait Until Keyword Succeeds    3min    5s    Check Cell Disabled    ${cell_DN}
    Change Parameter    ${cell_DN}    ${gscn_name}    ${old_gscn}
    Change Parameter    ${cell_DN}    administrativeState    Unlocked
    Wait Until Keyword Succeeds    3min    5s    Check Cell Enabled    ${cell_DN}

Step 4: check alarm 7516 is cleared
    log to console     \n Step 4: check alarm 7516 is cleared
    Check Alarm Not Active in Raw file    7516
    Check Alarm Cleared                7516
    log    \n....... alarm 7516 is cleared    console=${true}

Step 5: check no new alarm should be raised after this testing
    log to console     \n Step 5: check no new alarm should be raised after this testing
    ${new_raw_alarms}=    Get Active Alarms From Raw file
    should be equal       ${raw_alarms}    ${new_raw_alarms}    msg=Active Alarms in Raw File Modified by the test
    ${new_alarms_number}=     coam_admin.get_active_alarms_number
    should be equal       ${alarms_number}    ${new_alarms_number}    msg=Number of Active Alarms Modified by the test
    log    \n....... there are no new alarm be raised after this testing    console=${true}

Check Cell Enabled
    [Arguments]    ${cell_DN}
    ${state}=    Get Parameter    ${cell_DN}   operationalState
    ${lower_state}    Convert To Lower Case    ${state}
    Should be equal    ${lower_state}    enabled    ignore_case=True

Check Cell Disabled
    [Arguments]    ${cell_DN}
    ${state}=    Get Parameter    ${cell_DN}   operationalState
    ${lower_state}    Convert To Lower Case    ${state}
    Should be equal    ${lower_state}    disabled    ignore_case=True

Check Alarm Raised
    [Arguments]    ${fault_id}
    ${fault_id_str}    Convert To String    ${fault_id}
    coam_admin.assert_alarm_active    parameters=faultId=${fault_id_str}    timeout=1

Check Alarm Cleared
    [Arguments]    ${fault_id}
    ${fault_id_str}    Convert To String    ${fault_id}
    coam_admin.assert_alarm_inactive    parameters=faultId=${fault_id_str}    timeout=1

Change Parameter
    [Arguments]    ${DN}    ${PARAM}    ${NEW_VALUE}    ${OP}=update
    ${res}=    coam_admin.perform_parameter_recommissioning    dist_name=${DN}    parameter=${PARAM}    operation=${OP}    value=${NEW_VALUE}
    ...    skip_parameter_relation_errors=${True}
    should be true    '${res['commissioningResult']['activationResult']['resultNode']['parameters']['result']}'=='Success'

Check Alarm Active in Raw file
    [Arguments]    ${fault_id}
    ${alarms}=    Get Active Alarms From Raw file
    should contain    ${alarms}    ${fault_id}    msg=alarm ${fault_id} not found in raw file

Check Alarm Not Active in Raw file
    [Arguments]    ${fault_id}
    ${alarms}=    Get Active Alarms From Raw file
    should not contain    ${alarms}    ${fault_id}    msg=alarm ${fault_id} found in raw file

Get Active Alarms From Raw file
    ${cmd}=    set variable    cat /tmp/RawAlarmHistory.txt |awk '/Active faults/,/Inactive faults/' | grep EFaultId | awk '{print $1,$2,$3,$4}'
    ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=BTS_SSH

    ssh.Force Reconnect    connection=BTS_SSH
    ssh.Send Command    command=${cmd}    connection=BTS_SSH
    ${stdout}    ssh.Read Output    connection=BTS_SSH
    ${stdout}    strip_string    ${stdout}
    should not be empty   ${stdout}

    [Return]          ${stdout}
    [Teardown]                       ssh.Disconnect    connection=BTS_SSH

Get Parameter
    [Arguments]    ${DN}    ${PARAM}

    ${SCF}=    coam_admin.get_scf    export_type=configurationAndRuntimeObjects
    ${xml_root}=    XML.Parse XML           ${SCF}
    ${value}=       XML.Get Element Text    ${xml_root}      //managedObject[@distName="${DN}"]/p[@name="${PARAM}"]
    [Return]    ${value}



#-----------------------------------------------------------------------
# [1]CB005750_5G_EBAC_101_5GC000159_gNB_state_management_in_WebUI
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# [1]CB005750_5G_EBAR_101_5GC000666_01_5G_Snapshot_collection_in_WebEM
#-----------------------------------------------------------------------
Collect snapshot
    [Arguments]    ${BTS_IP}
    log to console    \nstart collect snapshot
    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
    coam.collect_snapshot    target_file_name=${output_dir}/snapshot.zip   connection=${connection}
    log to console    collect snapshot successful
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Unzip and Check snapshot
    [Arguments]    ${BTS_IP}
    log to console     \nstart check snapshot
    ssh.Connect to     hostname=${TEST_VM_ADDR}    username=${TEST_VM_USERNAME}    password=${TEST_VM_PASSWORD}	alias=TESTPC
    ssh.Send Command    command=cd ${output_dir};ls |grep 'snapshot.zip'    connection=TESTPC
    ${data}    ssh.Read Output    connection=TESTPC
    ${data}    strip_string    ${data}
    should not be empty    ${data}

    ssh.execute    command=unzip -o ${output_dir}/snapshot.zip -d ${output_dir}/snapshot    connection=TESTPC
    Check data    point=pm_1_syslog.zip
    Check data    point=RMOD_L_1_journal
    #@Check data    point=SWDLreport.txt.xz
    Check data    point=AlarmHistory.txt.xz
    Check data    point=blackbox.xz
    Check data    point=ims2
    log to console    check snapshot successful

Check data
    [Arguments]    ${point}
    ssh.Send Command    command=cat ${target1}|grep '${point}'    connection=TESTPC
    ${check}    ssh.Read Output    connection=TESTPC
    ${check}    strip_string    ${check}
    should not be empty    ${check}

Clean files
    ssh.Send Command    command=cd ${output_dir};rm -rf ${target}    connection=TESTPC
    run keyword and ignore error    ssh.Disconnect	connection=TESTPC

#-----------------------------------------------------------------------
# [1.0] CB005750_5G_EBAE_004_5GC000165_Configuration_of_measurement_and_reporting_interval_default
#-----------------------------------------------------------------------
Precondition: check gNB can be on air

    log to console     \nPrecondition: gNB can be on air
    coam_admin.connect_to
    ...        bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...        username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...        password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    #...        name=${connection}

    ${RES}=    coam_admin.get_bts_statuses
    should be equal as strings    ${RES['proceduralState']}    OnAir    msg=gNB is not OnAir
    log to console     \n.....gNB is on air

Step 1: change measurement and reporting intervals

    log to console      \nStep 1: change measurement and reporting intervals
    ${miNrX2CB_MO}=    Get MO For Uniq Parameter    miNrX2CB
    ${miNrX2CB_old}=    get Parameter    ${miNrX2CB_MO}    miNrX2CB
    set test variable     ${miNrX2CB_old}
    set test variable     ${miNrX2CB_MO}

    ${reportingIntervalPm_MO}=    Get MO For Uniq Parameter    reportingIntervalPm
    ${reportingIntervalPm_old}=    Get Parameter    ${reportingIntervalPm_MO}    reportingIntervalPm
    set test variable      ${reportingIntervalPm_old}
    set test variable      ${reportingIntervalPm_MO}


    ${miNrX2CB_new}=    set variable   15min
    ${reportingIntervalPm_new}=    set variable    15min
    set test variable       ${miNrX2CB_new}
    set test variable       ${reportingIntervalPm_new}


    run keyword if   '${miNrX2CB_old}'!='${miNrX2CB_new}'    Change parameter    ${miNrX2CB_MO}    miNrX2CB    ${miNrX2CB_new}
    run keyword if   '${reportingIntervalPm_old}'!='${reportingIntervalPm_new}'
    ...    Change parameter    ${reportingIntervalPm_MO}    reportingIntervalPm    ${reportingIntervalPm_new}

Step 2: Check if PM WebEM presents Collector uploaded files using the new schedule of reporting interval

    log to console     \nStep 2: Check if PM WebEM presents Collector uploaded files using the new schedule of reporting interval
    ${miNrX2CB_num}=    Fetch From Left    ${miNrX2CB_new}    min
    ${reportingIntervalPm_num}=    Fetch From Left    ${reportingIntervalPm_new}   min
    set test variable     ${reportingIntervalPm_num}
    set test variable     ${miNrX2CB_num}

    ${start_time}=    DateTime.get current date    result_format=epoch
    set test variable    ${start_time}
    log to console     \n.......wait 15min
    #sleep    900s
    log to console     \n.......wait twice PM xml File
    ${real_interval}=    Wait next PM xml File
    ${real_interval}=    Wait next PM xml File
    Should be true    ${real_interval}==${reportingIntervalPm_num}    msg=ReportingIntervalPm not correctly applied

Step 3: check measurement counters should appear correct times during reporting interval

    log to console     \nStep 3: check measurement counters should appear correct times during reporting interval
    Get last PM xml File
    OperatingSystem.run    gzip -df /tmp/last_PM_file.gz
    ${occurences}=    evaluate    ${reportingIntervalPm_num}/${miNrX2CB_num}
    Check PM file    /tmp/last_PM_file    expected_type=NX2CB    expected_interval=${miNrX2CB_num}    expected_occurences=${occurences}

Step 4: revert measurement and reporting intervals

    log to console     \nStep 4: revert measurement and reporting intervals
    run keyword if   '${miNrX2CB_old}'!='${miNrX2CB_new}'    Change parameter    ${miNrX2CB_MO}    miNrX2CB    ${miNrX2CB_old}
    run keyword if   '${reportingIntervalPm_old}'!='${reportingIntervalPm_new}'
    ...    Change parameter    ${reportingIntervalPm_MO}    reportingIntervalPm    ${reportingIntervalPm_old}
    [teardown]      coam_admin.Teardown



Wait next PM xml File
    ${current_file}=    Get last PM xml TimeStamp
    Wait Until Keyword Succeeds	   3601    60	PM xml file Changed    ${current_file}
    ${last_file}=    Get last PM xml TimeStamp
    ${diff_sec}=    DateTime.Subtract Date From Date    ${last_file}    ${current_file}    exclude_millis=True
    ${reporting_interval}=    evaluate    ${diff_sec}/60


    [return]    ${reporting_interval}


Compute duration from a start time
    [Arguments]
    ...    ${start_time}
    ...    ${result_format}=compact
    [Documentation]
    ...    Returns the elapsed time from a start time and now.
    ...    The returned time format is the compact one by default (e.g. 1min 15s).

    ${now}=    DateTime.get current date    result_format=epoch
    ${elapsed_time}=    evaluate    ${now} - ${start_time}
    ${duration}=    DateTime.convert time    ${elapsed_time}    ${result_format}    exclude_milles=yes
    [return]    ${duration}

PM xml file Changed
    [Arguments]     ${current_file}

    ${duration}=    Compute duration from a start time     ${start_time}
    log to console    \n....... - elapsed time = ${duration}
    ${last_file}=    Get last PM xml TimeStamp
    should not be equal    ${current_file}    ${last_file}

Get last PM xml TimeStamp
    ${file_name}=   Wait Until Keyword Succeeds    15x    1min    Get last PM xml File Name
    ${timeStamp}=    DateTime.Convert Date     ${file_name}    exclude_millis=True    date_format=%Y%m%d.%H%M%S
    [Return]          ${timeStamp}
    [Teardown]                       ssh.Disconnect    connection=BTS_SSH

Get last PM xml File Name
    #   -rw-r--r-- 1 btssw btssw 59028 Apr 21 12:00 PM.BTS-82.20210421.100000.ANY.xml.gz

    ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=BTS_SSH

    ${cmd}=    set variable    ls -ltr /ram/PM.BTS*xml* |tail -1 |awk '{print $NF}' |cut -f3,4 -d'.'
    ssh.Send Command    command=${cmd}    connection=BTS_SSH
    ${file_name}=   ssh.Read Output    connection=BTS_SSH
    ${file_name}=   strip_string    ${file_name}
    Should Not Be Empty    ${file_name}
    [Return]          ${file_name}

Get last PM xml File
#   -rw-r--r-- 1 btssw btssw 59028 Apr 21 12:00 PM.BTS-82.20210421.100000.ANY.xml.gz

    ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=BTS_SSH

    ${cmd}=    set variable    ls -ltr /ram/PM.BTS*xml* |tail -1 |awk '{print $NF}'

    ssh.Send Command    command=${cmd}    connection=BTS_SSH
    ${file_name}=   ssh.Read Output    connection=BTS_SSH
    ${file_name}=   strip_string    ${file_name}

    #${file_name}=        SSHLibrary.Execute Command    command=${cmd}    return_stdout=True



    #SSHLibrary.get file    source=${file_name}    destination=/tmp/last_PM_file.gz
    ssh.download_file      remote_path=${file_name}    local_path=/tmp/last_PM_file.gz    connection=BTS_SSH
    [Teardown]                       ssh.Disconnect    connection=BTS_SSH


Get MO For Uniq Parameter
    [Arguments]    ${PARAM}

    ${SCF}=    coam_admin.get_scf    export_type=configurationAndRuntimeObjects
    ${xml_root}=    XML.Parse XML           ${SCF}
    ${n_param}=     XML.get element count   ${xml_root}     //p[@name="${PARAM}"]
    should be true    ${n_param}==1
    ${DN}=          Get Element Attribute        ${xml_root}    distName     xpath=(//p[@name="${PARAM}"])[1]/..
    [Return]    ${DN}

Check PM file
	[Arguments]    ${pm_file}    ${expected_type}    ${expected_interval}    ${expected_occurences}
	${occurences}=    set variable    0
        ${xml_root}=    XML.Parse XML   ${pm_file}
        ${n_param}=     XML.get element count   ${xml_root}     //M55110C00002
        FOR    ${index}    IN RANGE    1       ${n_param}+1
               ${measurementType}=     Get Element attribute   ${xml_root}     measurementType    xpath=(//M55110C00002)[${index}]/..
               ${interval}=     Get Element attribute   ${xml_root}     interval    xpath=(//M55110C00002)[${index}]/../../..
 		continue for loop if    '${measurementType}'!='${expected_type}' or '${interval}'!='${expected_interval}'
               ${DN}=                  Get Element Text        ${xml_root}     xpath=(//M55110C00002)[${index}]/../../MO/DN
               ${M55110C00002}=        get element text   ${xml_root}   xpath=(//M55110C00002)[${index}]
		${occurences}=    evaluate    ${occurences}+1
	    END

	should be true    ${expected_occurences}==${occurences}



#-----------------------------------------------------------------------
#[1.0] CB005750_5G_EBAE_003_5GC000165_Configuration_of_measurement_and_reporting_interval_different_than_default
#-----------------------------------------------------------------------




Step 1: change measurement and reporting intervals for 003 case

    log to console      \nStep 1: change measurement and reporting intervals for 003 case

    ${miNrX2CB_MO}=    Get MO For Uniq Parameter    miNrX2CB
    ${miNrX2CB_old}=    get Parameter    ${miNrX2CB_MO}    miNrX2CB
    set test variable     ${miNrX2CB_old}
    set test variable     ${miNrX2CB_MO}


    ${reportingIntervalPm_MO}=    Get MO For Uniq Parameter    reportingIntervalPm
    ${reportingIntervalPm_old}=    Get Parameter    ${reportingIntervalPm_MO}    reportingIntervalPm
    set test variable      ${reportingIntervalPm_old}
    set test variable      ${reportingIntervalPm_MO}


    ${miNrX2CB_new}=    set variable   15min
    ${reportingIntervalPm_new}=    set variable    60min
    set test variable       ${miNrX2CB_new}
    set test variable       ${reportingIntervalPm_new}


    run keyword if   '${miNrX2CB_old}'!='${miNrX2CB_new}'    Change parameter    ${miNrX2CB_MO}    miNrX2CB    ${miNrX2CB_new}
    run keyword if   '${reportingIntervalPm_old}'!='${reportingIntervalPm_new}'
    ...    Change parameter    ${reportingIntervalPm_MO}    reportingIntervalPm    ${reportingIntervalPm_new}

Step 2: Check if PM WebEM presents Collector uploaded files using the first new schedule of reporting interval

    log to console     \nStep 2: Check if PM WebEM presents Collector uploaded files using the first new schedule of reporting interval
    ${miNrX2CB_num}=    Fetch From Left    ${miNrX2CB_new}    min
    ${reportingIntervalPm_num}=    Fetch From Left    ${reportingIntervalPm_new}   min
    set test variable     ${reportingIntervalPm_num}
    set test variable     ${miNrX2CB_num}


    ${start_time}=    DateTime.get current date    result_format=epoch
    set test variable    ${start_time}

    log to console     \n.......wait ${reportingIntervalPm_new}
    Sleep    ${reportingIntervalPm_new}
    log to console     \n.......wait next PM xml File
    ${real_interval}=    Wait next PM xml File
    Should be true    ${real_interval}==${reportingIntervalPm_num}    msgReportingIntervalPm not correctly applied

    log to console     \n........check measurement counters should appear correct times during reporting interval
    Get last PM xml File
    OperatingSystem.run    gzip -df /tmp/last_PM_file.gz
    ${occurences}=    evaluate    ${reportingIntervalPm_num}/${miNrX2CB_num}
    Check PM file    /tmp/last_PM_file    expected_type=NX2CB    expected_interval=${miNrX2CB_num}    expected_occurences=${occurences}


Step 3: Check if PM WebEM presents Collector uploaded files using the second new schedule of reporting interval

    log to console     \nStep 3: Check if PM WebEM presents Collector uploaded files using the second new schedule of reporting interval
    ${miNrX2CB_new}=    set variable    5min
    ${reportingIntervalPm_new}=    set variable    30min
    set test variable       ${miNrX2CB_new}
    set test variable       ${reportingIntervalPm_new}


    ${miNrX2CB_MO}=    Get MO For Uniq Parameter    miNrX2CB
    ${miNrX2CB_old}=    get Parameter    ${miNrX2CB_MO}    miNrX2CB
    set test variable     ${miNrX2CB_old}
    set test variable     ${miNrX2CB_MO}
    run keyword if   '${miNrX2CB_old}'!='${miNrX2CB_new}'    Change parameter    ${miNrX2CB_MO}    miNrX2CB    ${miNrX2CB_new}


    ${reportingIntervalPm_MO}=    Get MO For Uniq Parameter    reportingIntervalPm
    ${reportingIntervalPm_old}=    Get Parameter    ${reportingIntervalPm_MO}    reportingIntervalPm
    #set test variable      ${reportingIntervalPm_old}
    set test variable      ${reportingIntervalPm_MO}
    run keyword if   '${reportingIntervalPm_old}'!='${reportingIntervalPm_new}'
    ...    Change parameter    ${reportingIntervalPm_MO}    reportingIntervalPm    ${reportingIntervalPm_new}


    ${miNrX2CB_num}=    Fetch From Left    ${miNrX2CB_new}    min
    ${reportingIntervalPm_num}=    Fetch From Left    ${reportingIntervalPm_new}   min


    ${start_time}=    DateTime.get current date    result_format=epoch
    set test variable    ${start_time}

    log to console     \n.......wait ${reportingIntervalPm_new}
    Sleep    ${reportingIntervalPm_new}
    ${real_interval}=    Wait next PM xml File
    Should be true    ${real_interval}==${reportingIntervalPm_num}    msgReportingIntervalPm not correctly applied


    log to console     \n........check measurement counters should appear correct times during reporting interval
    Get last PM xml File
    OperatingSystem.run    gzip -df /tmp/last_PM_file.gz
    ${occurences}=    evaluate    ${reportingIntervalPm_num}/${miNrX2CB_num}
    Check PM file    /tmp/last_PM_file    expected_type=NX2CB    expected_interval=${miNrX2CB_num}    expected_occurences=${occurences}








#-----------------------------------------------------------------------
#[1.0] CB005750_5G_EBAN_003_5GC000341_Parameter_modification_reset_needed
#-----------------------------------------------------------------------

STEP_001 - Backup DU SCF via DU WebEM
     log to console     \n STEP_001 - Backup DU SCF via DU WebEM
        coam_admin.connect_to
    ...        bts_host=${DU_GNB_IP}
    ...        username=${DU_WEBEM_USERNAME}
    ...        password=${DU_WEBEM_PASSWORD}
    #...        name=${connection}


     ${cell_list}=    coam_admin.get_cell_list
    FOR     ${cell}    IN    @{cell_list['cells']['nr']}
        ${operational_state}    Convert To Lower Case    ${cell['status']['operationalState']}
        continue for loop if   '${operational_state}' != 'enabled'
        ${cell_DN}=    set variable    ${cell['id']['configuration']}
    END
    should not be equal    ${cell_DN}    unknown     msg=no cell Online found
    log    \n....... NR cells are Online    console=${true}

    ${old_pmax}=    Get Parameter    ${cell_DN}   pMax
    set test variable   ${old_pmax}

    Backup DU SCF via DU WebEM    du_scf_path=${BACKUP_SCF_PATH}
    File Should Exist    ${BACKUP_SCF_PATH}


STEP_002 - Import DU SCF via DU WebEM
    log to console     \n STEP_002 - Import DU SCF via DU WebEM
    Import DU SCF via DU WebEM    du_scf_path=${TARGET_SCF_PATH}


STEP_003 - Wait until gNB cell onAir

    log to console     \n STEP_003 - Wait until gNB cell onAir
    wait until keyword succeeds    10min    1min    ping
    #DU login    ${DU_GNB_IP}
    ${start_time}=    DateTime.get current date    result_format=epoch
    set suite variable    ${start_time}
    wait until keyword succeeds    20min    30s    gNB in onAir state
    WAIT UNTIL KEYWORD SUCCEEDS    15min    15s    All cells are Online
         ${cell_list}=    coam_admin.get_cell_list
    FOR     ${cell}    IN    @{cell_list['cells']['nr']}
        ${operational_state}    Convert To Lower Case    ${cell['status']['operationalState']}
        continue for loop if   '${operational_state}' != 'enabled'
        ${cell_DN}=    set variable    ${cell['id']['configuration']}
    END
    should not be equal    ${cell_DN}    unknown     msg=no cell Online found

    ${new_pmax}=    Get Parameter    ${cell_DN}   pMax
    set test variable   ${new_pmax}

    should not be equal     ${old_pmax}     ${new_pmax}     msg=paramter modify fail through loading scf


    [teardown]    coam_admin.Teardown


STEP_004 - Restore DU SCF via DU WebEM
    log to console     \n STEP_004 - Restore DU SCF via DU WebEM
    File Should Exist    ${BACKUP_SCF_PATH}
    Restore DU SCF via DU WebEM    du_scf_path=${BACKUP_SCF_PATH}
    wait until keyword succeeds    10min    1min    ping


gNB in onAir state
    #[Arguments]
   # ...    ${connection}=DU_connection

    ${gNB_statuses}=    coam_admin.get_bts_statuses
    ${proceduralState}=    get from dictionary    ${gNB_statuses}    key=proceduralState
    log to console    \n....... - gNB_statuses = ${gNB_statuses}

    ${duration}=    Compute duration from a start time     ${start_time}
    log to console    ....... - elapsed time = ${duration}

    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}

All cells are Online

    ${cells_info}   taf.sbts.oam.coam.admin.get_cells_info
    FOR  ${cell_group}  IN   @{cells_info}
         Should contain    ${cell_group['status']['operationalState']}    Enabled    ignore_case=True
         ${status_keys}    Collections.get dictionary keys    ${cell_group['status']}
         ${availability_status}    run keyword and return status    should contain
         ...    ${status_keys}    availabilityStatus    ignore_case=True
         run keyword if    ${availability_status}    Should contain
         ...    ${cell_group['status']['availabilityStatus']}    Online
    END
    LOG TO CONSOLE    ${SPACE*2}All cells are Online.

Ping
    [Arguments]
    ...    ${du_gnb_ip}=${DU_GNB_IP}

    ssh.connect_to    hostname=${TEST_VM_ADDR}
    ...               username=${TEST_VM_USERNAME}
    ...               password=${TEST_VM_PASSWORD}
    ...               alias=VM_connection

    log to console    \n....... ping ${DU_GNB_IP} ...
    ssh.send_command    command=ping ${du_gnb_ip} -c 5 -i 2    connection=VM_connection
    ${output}=    ssh.read_output    connection=VM_connection
    should match regexp    ${output}    ttl=

    [teardown]    ssh.disconnect    connection=VM_connection

