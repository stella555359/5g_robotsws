*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: OM operations related Keywords

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.nms.netact    WITH NAME    netact
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.hw.pdu    WITH NAME    pdu
Resource     ./testsuite/Bangalore/ORAN/resources/robot/SetupReadinessWithIntelligentSoftwareUpdate.robot

*** Variables ***

${BTS_ADDRESS}=    192.168.255.129
${value_true}=     true
${connection}=     default

*** Keywords ***

Test Setup
    Log to console  \n--Start test--\n
    Run Keywords     Login To Admin
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}

Test Teardown
    Log to console  --End test--\n
    Get ActiveAlarms
    Collect Snapshot    snaptarget_file_name=${BTS_path}/${SUITE NAME}/${Date}/PostTestLogs/Snapshot.zip
    admin.collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/PostTestLogs/imSnapshot.ims2
    Stop BTS logs
    admin.teardown_all_aliases_for_admin
    SSHLibrary.Close All Connections

Suite Setup
    log    "Test Started"
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}/SoftwareUpdateLogs
    Set global variable    ${Date}    ${CurrentDate}
    Run Keywords     Login To Admin
    ${sourcePath}    Set Variable    toor4nsn@192.168.255.129:/ffs/run/swconfig.txt
    Log To Console    ----\nStart of Intelligent SW Update----
    Set global variable    ${sourcePath}
    ${output}=    os.Run    df -k .
    Log to console    Disk Space Before Test Execution is ${output}
    os.run    scp ${sourcePath} ${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/swconfig.txt
    Start BTS logs
    Run keyword and continue on failure    Trigger_Setup_Readiness_With_Intelligent_SoftwareUpdate
    Run Keyword and Ignore Error     Check ActiveFaultandAlarmID    @{faultslist}
    Collect Snapshot    snaptarget_file_name=${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/Snapshot.zip
    CleanupBuilds
    Log to console    ----\nEnd of Intelligent SW Update----
    ${output}=    os.Run    df -k .
    Log to console    Disk Space After Test Execution is ${output}
    Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs
    admin.teardown_all_aliases_for_admin

Suite Teardown
	log    "Test END"

Start BTS logs
    [Documentation]     Starts BTS logs
    Run     killall btslog
    btslog.create_btslog_collector    name=btslog
    core.setup_collectors    names=btslog
    core.set_suite_alias    btslog
    core.start_collectors    names=btslog

Stop BTS logs
    [Arguments]    ${btslog_target_dir}=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    [Documentation]     Stops BTS logs
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog     target_dir=${btslog_target_dir}
    core.teardown_collectors    names=btslog

Login To Admin
    admin.setup_admin    bts_host=${BTS_ADDRESS}

SingleBlockCell
   [Arguments]    ${name}
   admin.block_cell    dist_name=${name}
   ...                 timeout=60
   ...                 detailed_output=False
   ...                 connection=${connection}

SingleUnblockCell
   [Arguments]    ${name}
   admin.unblock_cell    dist_name=${name}
   ...                   timeout=60
   ...                   detailed_output=False
   ...                   connection=${connection}

AllLTEcellBlockUnblock
    ${listlncel}=    admin.get_ids_for_all    LNCEL
    log    ${listlncel}
    ${len}=    Get length    ${listlncel}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.block_cell    dist_name=${listlncel}[${i}]
        ...                 timeout=30
        ...                 detailed_output=False
        ...                 connection=${connection}
        Sleep    10s
        admin.unblock_cell    dist_name=${listlncel}[${i}]
        ...                   timeout=30
        ...                   detailed_output=False
        ...                   connection=${connection}
    END

AllNRcellBlockUnblock
    ${listnrcell}=    admin.get_ids_for_all    NRCEL
    log    ${listnrcell}
    ${len}=    Get length    ${listnrcell}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.lock     dist_name=${listnrcell}[${i}]
        ...            timeout=120s
        Sleep    10s
        admin.unlock     dist_name=${listnrcell}[${i}]
        ...              timeout=120s
    END

AllLteCellLockUnlock
    ${listlncel}=    admin.get_ids_for_all    LNCEL
    log    ${listlncel}
    ${len}=    Get length    ${listlncel}
    log    ${len}
        FOR    ${i}    IN RANGE   ${len}
        admin.lock     dist_name=${listlncel}[${i}]
        ...            timeout=120s
        Sleep    10s
        admin.unlock     dist_name=${listlncel}[${i}]
        ...              timeout=120s
    END

AllBBLockUnlock
    ${listBBMOD}=    admin.get_ids_for_all    BBMOD
    log    ${listBBMOD}
    ${len}=    Get length    ${listBBMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.lock     dist_name=${listBBMOD}[${i}]
        ...            timeout=120s
        Sleep    10s
        admin.unlock     dist_name=${listBBMOD}[${i}]
        ...              timeout=120s
    END

AllRadioLockUnlock
    ${listRMOD}=    admin.get_ids_for_all    RMOD
    log    ${listRMOD}
    ${len}=    Get length    ${listRMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.lock     dist_name=${listRMOD}[${i}]
        ...            timeout=120s
        Sleep    10s
        admin.unlock     dist_name=${listRMOD}[${i}]
        ...              timeout=120s
    END

SingleBBmodReset
    [Arguments]    ${name}
    admin.reset_unit       dist_name=${name}
    ...                    reset_type=warm
    ...                    timeout=360

Collect Snapshot
    [Arguments]     ${snaptarget_file_name}=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
	admin.collect_snapshot    target_file_name=${snaptarget_file_name}

Reset Site
    admin.reset_site
    ...    wait_for_reconnection=${value_true}
    ...    connection=${connection}
    ...    timeout=600

Check_BTS_State
    ${bts_state}=    admin.get_mrbts_state
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

SingleResetRadio
    [Arguments]    ${name}
    radio_reset_at_layer_1    dist_name=${name}
    ...                       reset_type=Soft
    ...                       timeout=400
    ...                       connection=${connection}
    ...                       detailed_output=False

ResetAllRadio
    ${listRMOD}=    admin.get_ids_for_all    RMOD
    log    ${listRMOD}
    ${len}=    Get length    ${listRMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.reset_unit        dist_name=${listRMOD}[${i}]
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=${connection}
        ...                     detailed_output=False
    END

ResetSingleRadio
        [Arguments]     ${RMOD}
        admin.reset_unit        dist_name=${RMOD}
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=${connection}
        ...                     detailed_output=False

ResetAllBBmod
    ${listBBMOD}=    admin.get_ids_for_all    BBMOD
    log    ${listBBMOD}
    ${len}=    Get length    ${listBBMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.reset_unit        dist_name=${listBBMOD}[${i}]
        ...                     reset_type=warm
        ...                     timeout=400
        ...                     connection=${connection}
        ...                     detailed_output=False
    END

PerformPowerReset
    admin.power_reset    reset_with_snapshot=false    wait_for_reconnection=true    timeout=600
    ...            detailed_output=False     connection=default
    ...            cold_reset_secondary_core_via_backplane=false    graceful_cell_shutdown=false

ORU Upgrade Wo Reset
    update_software    sw_package=${sw2}
    ...                should_activate=True
    ...                timeout=1000
    ...                connection=default
    ...                should_reset_radios=False

ORU Upgrade Reset
    update_software    sw_package=${sw1}
    ...                should_activate=True
    ...                timeout=1000
    ...                connection=${connection}
    ...                should_reset_radios=True

Get ActiveAlarms
    ${alr}=     admin.get_active_alarms
    log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number
    Log    ${alr_num}

Check ActiveFaultandAlarmID
    [Arguments]    @{fault_list}
    ${alr}=     admin.get_active_alarms
    log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        ${affectedobj}=    Convert To String    ${alr}[${i}][configObjectName]
        run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        Run Keyword If    "${fltstring}" == "10"
        ...    Log to console    \nFID 10 is reported on ${affectedobj}, Please collect radio logs.
    END

Print Radio Version
    ${SWparameters}=    get_parameters_for_all    class_name=RMOD
    ...                                           timeout=10
    ...                                           connection=${connection}
    log    ${SWparameters}

PerformPowerResetfromIpPdu
    [Arguments]    ${pdu_host_ip}    ${portnum}
    setup_pdu     model=RRB    host=${pdu_host_ip}    alias=RRB_ippdu
    pdu.reset_ports    ports=${portnum}    time_interval=20    pdu_device=RRB_ippdu
    pdu.teardown_pdu    pdu_device=RRB_ippdu

BLOCKallCELLS
    admin.block_all_cells    rat=NR,LTE
    ...                      timeout=300
    ...                      detailed_output=False
    ...                      connection=${connection}

UnBLOCKallCELLS
    admin.unblock_all_cells    rat=NR,LTE
    ...                        timeout=300
    ...                        detailed_output=False
    ...                        connection=${connection}

RollbackSWinBTS
     ${SWversion}=    admin.get_software_info    timeout=10    connection=default
     log    ${SWversion}
     rollback_software    timeout=300    detailed_output=False    connection=default
     sleep    200s
     Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
     ${SWversion}=    admin.get_software_info    timeout=10    connection=default
     log    ${SWversion}

Perform Parameter Recommissioning
    [Arguments]    ${parameter_dist_name}    ${parameter_name}     ${value}
    admin.perform_parameter_recommissioning
    ...    dist_name=${parameter_dist_name}
    ...    parameter=${parameter_name}
    ...    operation=update
    ...    value=${value}
    ...    skip_parameter_relation_errors=${value_true}
    ...    should_activate=${value_true}
    ...    timeout=300
    Sleep    60s

Lock_NgLink
	[Arguments]    ${name}
	admin.lock_ng_link    dist_name=${name}
	...                   timeout=60
	...                   connection=${connection}

UnLock_NgLink
	[Arguments]    ${name}
	admin.unlock_ng_link    dist_name=${name}
	...                     timeout=60
	...                     connection=${connection}

SingleLockBaseband
	[Arguments]    ${name}
	admin.lock_baseband    dist_name=${name}
	...                     timeout=60
	...                     connection=${connection}

SingleUnlockBaseband
	[Arguments]    ${name}
	admin.unlock_baseband    dist_name=${name}
	...                      timeout=60
	...                      connection=${connection}

BlockRat
	[Arguments]    ${name}
	admin.block_rat    rat=${name}
	...                timeout=60
	...                connection=${connection}

UnblockRat
	[Arguments]    ${name}
	admin.unblock_rat    rat=${name}
	...                  timeout=60
	...                  connection=${connection}

ResetCell
    [Arguments]    ${name}
    admin.reset_cell    cell_id=${name}
    ...                       graceful_cell_shutdown=None
    ...                       timeout=400
    ...                       connection=${connection}
    ...                       detailed_output=False

ResetAllCells
    [Arguments]    ${technology}
    admin.reset_all_cells    technology=${technology}
    ...                       timeout=400
    ...                       connection=${connection}
    ...                       detailed_output=False

SingleLockOperation
    [Arguments]    ${distname}
    admin.lock     ${distname}
    ...            timeout=120s

SingleUnLockOperation
    [Arguments]    ${distname}
    admin.unlock     ${distname}
    ...              timeout=120s

untar_syslogsFile
    snapshotFileIdentifier.unzip
    ...    /home/ute/MCG-PC-75/Log/RobustnessTestScript/08_03_2024_1110/BBmodResetTest/Iteration1/SYSlogs/btslog/syslog_files.tgz


unzip_Snapshot_adminLogFile
    snapshotFileIdentifier.unzip
    ...    /home/ute/MCG-PC-75/Log/OMops/22_02_2024_1512/ORU_Reset_Test/Iteration1/SnapshotFileIteration1.zip

GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    [Arguments]    ${File}    ${regexpattern}    ${var_start_sys}     ${var_end_sys}    ${inputtime}

    ${tmp}=    Convert To Number    ${inputtime}
    ${offlineindication}=       Run       grep \"${var_start_sys}\" ${File}/*.LOG
    log    ${offlineindication}
    ${offlineindicationregex}=  Get Regexp Matches  ${offlineindication}  ${regexpattern}
    ${onAirindication}=       Run       grep \"${var_end_sys}\" ${File}/*.LOG
    log    ${onAirindication}
    ${onAirindicationregex}=  Get Regexp Matches  ${onAirindication}    ${regexpattern}
    log    ${offlineindicationregex}
    log    ${onAirindicationregex}
    ${var_x}=    convert to string      ${offlineindicationregex}
    ${var_y}=    Remove String     ${var_x}    [    ]    '    <
    ${offlineindicationstatus}=   Replace String     ${var_y}    ${SPACE}        ${EMPTY}
    ${offlineindicationstatus}=   Replace String     ${var_y}    T    ${SPACE}
    log    ${offlineindicationstatus}
    @{offlineIndic_words}=    Split String    ${offlineindicationstatus}    ,
    ${Length1}=    Get length    ${offlineIndic_words}
    ${var_n}=    convert to string      ${onAirindicationregex}
    ${var_m}=    Remove String     ${var_n}    [    ]    '    <
    ${onAirindicationstatus}=   Replace String     ${var_m}    ${SPACE}        ${EMPTY}
    ${onAirindicationstatus}=   Replace String     ${var_m}    T    ${SPACE}
    log    ${onAirindicationstatus}
    @{onairIndic_words}=    Split String    ${onAirindicationstatus}    ,
    ${Length2}=    Get length    ${onairIndic_words}
    ${len}=      Evaluate    ${Length2} - 1
    ${time}=	Subtract Date From Date     ${onairIndic_words}[${len}]    ${offlineIndic_words}[0]
    Run Keyword and Continue on Failure    Run Keyword If    ${time} >= ${tmp}
    ...    Fail    The value ${time} is more than expected time

GrepTimeStampsfromAdminLogFileandCalculateTimeDifference
    [Arguments]    ${adminFile}    ${regexpattern}    ${var_start_admin}     ${var_end_admin}    ${inputtime}

    ${tmp}=    Convert To Number    ${inputtime}
    ${Startindication}=    os.grep file    ${adminFile}     ${var_start_admin}
    log    ${Startindication}
    ${SuccessIndication}=    os.grep file    ${adminFile}     ${var_end_admin}
    log    ${SuccessIndication}
    ${matchStart}=    Get Regexp Matches     ${Startindication}    ${regexpattern}
    ${matchEnd}=    Get Regexp Matches    ${SuccessIndication}    ${regexpattern}
    log    ${matchStart}
    log    ${matchEnd}

    ${var1}=    convert to string      ${matchStart}
    ${var_y}=    Remove String     ${var1}    [    ]    '
    ${matchStartfinal}=   Replace String     ${var_y}    ${SPACE}        ${EMPTY}
    ${matchStartfinal}=   Replace String     ${var_y}    T    ${SPACE}
    log    ${matchStartfinal}

    @{matchStartfinalString}=    Split String    ${matchStartfinal}    ,
    ${Length1}=    Get length    ${matchStartfinalString}

    ${var2}=    convert to string      ${matchEnd}
    ${var_x}=    Remove String     ${var2}    [    ]    '
    ${matchEndfinal}=   Replace String     ${var_x}    ${SPACE}        ${EMPTY}
    ${matchEndfinal}=   Replace String     ${var_x}    T    ${SPACE}
    log    ${matchEndfinal}

    @{matchEndfinalString}=    Split String    ${matchEndfinal}    ,
    ${Length2}=    Get length    ${matchEndfinalString}

    Should be equal   ${Length2}    ${Length1}

    FOR    ${i}    IN RANGE    0    ${Length1}
        ${time}=	Subtract Date From Date     ${matchEndfinalString}[${i}]    ${matchStartfinalString}[${i}]
        Run Keyword and Continue on Failure    Run Keyword If    ${time} >= ${tmp}
        ...    Fail    The time calculated value is more than allowed range.
    END

PerformNRResetRAT
    admin.rat_reset    rat_type=NR    timeout=180    connection=default

PerformLTEResetRAT
    admin.rat_reset    rat_type=LTE    timeout=180    connection=default


Add URL
    netact.add_web_url    web_url=${WEB_URL}
    ...                   username=${netactUSERNAME}
    ...                   password=${netactPASSWORD}
    ...                   alias=${NETACT_NAME}

Upload Alarms
    ${alarms}=    netact.upload_alarms    dist_name=${mo_name}
    ...                                   alias=${NETACT_NAME}
    Log    ${alarms}    console=${TRUE}
    ${alarms}=    netact.Get Alarms    ${mo_name}    alias=${NETACT_NAME}
    Log   ${alarms}    console=${TRUE}

Add_fmwas_node
    netact.Add Node    fmwas   ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=${NETACT_NAME}

Add_cmwas_node
    netact.Add Node    cmwas    ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=${NETACT_NAME}

Provision Plan
    [Arguments]    ${plan_name}
    netact.provision_plan    ${plan_name}    ${mo_name}    backup_plan_name=counter_ups
    ...               create_backup_plan=${TRUE}    provisioning_operation=activate    alias=${NETACT_NAME}

Delete Plan
   [Arguments]    ${plan_name}
   netact.delete_plan    plan_name=${plan_name}    alias=${NETACT_NAME}

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    ${actual_conf}=    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${managed_object}=    netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=${NETACT_NAME}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}

Counter_Value_Check
    [Arguments]    ${path}    @{ListofCountervalues}
    ${counter_List}=    admin.get_pm_counters_by_dist_name    timeout=300
    log    ${counter_List}
    log    ${counter_List['${path}']}
    FOR   ${count1}	IN	@{ListofCountervalues}
    	Run Keyword and Continue On Failure    Should Not Be Empty    ${counter_List['${path}']}[${count1}]}    0
        log    ${counter_List['${path}']}[${count1}]}
    END
    Sleep   60

Configure Netconf Credentials
    [Arguments]    @{list}
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}
