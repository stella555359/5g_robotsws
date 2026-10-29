*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: Test Suite
...   "Test Case coverage in Documentation section for each case respectively"

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
Library     taf.selenium.sbts  WITH NAME   sel
Library     testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Suite Setup		Suite_Setup
Test Setup	        Test Setup
Test Teardown           Run Keywords    Test_Teardown
Suite Teardown		Suite Teardown
Resource                testsuite/Bangalore/ORAN/T02/resources/robot/OperationKeywords.robot


*** Variables ***

${BTS_ADDRESS} =           192.168.255.129
${BTS_path}=               /home/ute/MCG-PC-66/Log
${iteration}=              12
${ippduhostip}=            10.53.252.14
${portnum}=                2
${rmod_distname}=          MRBTS-1212/EQM-1/APEQM-1/RMOD-1
${bbmod_distname}=         MRBTS-1212/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${SYSregexpattern}=        <..........T..:..:..
${var_start_sys}=          availability status: Offline
${var_end_sys}=            Validated to OnAirDone
${KPI3_time}=              300
${KPI51_time}=              240
${KPI13_time}=              420
${KPI11_time}=              420
${KPI7_10_time}=              120
${KPI1_time}=              330
${KPI54_time}=              240
${KPI5_time}=              330
${KPI12_time}=              330
@{list_of_expFaults}=      6327    61649    4655    61524    4654    61652    7220   7107    7115    4592    4297
${mo_id}=                  PLMN-PLMN/MRBTS-1212/MNL-1/MNLENT-1/SYNC-1
${FILTER_BY}=                   MRBTS
${mo_name}=                     PLMN-PLMN/MRBTS-1212
${fm_cm_itsmwas_hostIp}=   	10.43.48.16
${nwi3_hostIp}=            	10.43.48.16
${clsservices_hostIp}=     	10.43.48.21
${clsdb_hostIp}=           	10.43.48.22
${NETACT_NAME}=            	srnclab1042
${WEB_URL}=                	https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${netactUSERNAME}=              test2
${netactPASSWORD}=              Qwer_1234
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${description}=                 NetactPlan_CB010445
${hostip_ru}=                   10.53.252.12
${port_ru}=                     5
${plan_name}=                   NetActPlanforTest_CB010445
${distname_gracefulSH}=         MRBTS-1212/NRBTS-30001
${grSD_valueTrue}=              true
${parameter_grSD}=              actGrflShdn
${grSD_valueFalse}=             false

*** Test Cases ***

TC_kpi3
    [Documentation]    CB010445-C_KPI#3_Power-on startup availability
    [Tags]    TC6

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        PerformPowerResetfromIpPdu     ${ippduhostip}    ${portnum}
        Sleep    300
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFileIteration${i}.zip
        collect_im_snapshot
        ...  ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshotIteration${i}.ims2
        collect_raw_alarm_history_file
        ...        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/alarmSnapshotIteration${i}.json
        collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/scfIteration${i}.xml
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI3_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi51
    [Documentation]    CB010445-C_KPI#51a_Manual RU reset downtime
    [Tags]    TC

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        ResetSingleRadio    ${rmod_distname}
        sleep    4m
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI51_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi13
     [Documentation]    CB010445-C_KPI#13_Manual SW rollback downtime
     [Tags]    TC

     FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        RollbackSWinBTS
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFile.zip
        Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshot.ims2
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI13_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
     END

TC_kpi11
    [Documentation]    CB010445-C_KPI#11_Manual remote power reset downtime
    [Tags]    TC

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        PerformPowerReset
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFile.zip
        Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshot.ims2
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi7_10
    [Documentation]    CB010445-C_KPI#7_KPI#10_Manual LTE RAT reset downtime and Manual 5G RAT reset downtime
    [Tags]    TC

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        PerformNRResetRAT
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END
    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        PerformLTEResetRAT
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi1
    [Documentation]    CB010445-C_KPI#1a_Manual Site Reset downtime
    [Tags]    TC100

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        Reset Site
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFileIteration${i}.zip
        collect_im_snapshot
        ...       ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshotIteration${i}.ims2
        collect_raw_alarm_history_file
        ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/alarmSnapshotIteration${i}.json
        collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/scfIteration${i}.xml
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI1_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi54
    [Documentation]    CB010445-C_KPI#54a_Power-On RU Startup availability
    [Tags]    TC

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        PerformPowerResetfromIpPdu    ${hostip_ru}    ${port_ru}
        sleep    4m
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI54_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi5
    [Documentation]    CB010445-C_KPI#5_Capacity Module reset Downtime
    [Tags]    TC543

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd
    Start BTS logs
    SingleBBmodReset    ${bbmod_distname}
    Sleep    3m
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI5_time}
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    Perform Parameter Recommissioning          ${distname_gracefulSH}       ${parameter_grSD}    ${grSD_valueTrue}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    FOR    ${i}    IN RANGE    1    2
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start BTS logs
        SingleBBmodReset    ${bbmod_distname}
        Sleep    3m
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI5_time}
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END
    Perform Parameter Recommissioning          ${distname_gracefulSH}       ${parameter_grSD}    ${grSD_valueFalse}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State

TC_kpi12
    [Documentation]    CB010445-C_KPI#12_CM activation with site reset service downtime
    [Tags]    TC101

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start BTS logs

    Add URL
    Add_fmwas_node
    Upload Alarms
    Add_cmwas_node
    Run Keyword and Ignore Error    Delete Plan    ${plan_name}
    ${plan_conf}=    netact.Create Plan Configuration    ${plan_name}
    ...                            ${description}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    Get Actual Configuration MO Data   ${mo_id}
    ${managed_object}=    netact.Create Managed Object
    ...                ${plan_conf}    ${meta_class}    ${meta_version}    ${mo_id}    CREATE
    ...                                            alias=${NETACT_NAME}    manualFrameTimingAdjustment=9
    Provision Plan    ${plan_name}
    sleep    5m
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotFile.zip
    collect_im_snapshot
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/imSnapshot.ims2
    collect_raw_alarm_history_file
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alarmSnapshot.json
    collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/scf.xml
    Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI12_time}
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    Delete Plan    ${plan_name}
    Delete Node    cmwas    alias=${NETACT_NAME}
    Delete Node    nwi3    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}
