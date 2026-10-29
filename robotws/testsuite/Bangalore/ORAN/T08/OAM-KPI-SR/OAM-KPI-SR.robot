*** Settings ***

Documentation
...   author: Rubina Nath, Sreekumar Kumaran
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
Suite Setup		Suite Setup
Test Setup	        Test Setup
Test Teardown           Run Keywords    Test_Teardown
Suite Teardown		Suite Teardown
Resource      ${CURDIR}/resources/OAM_KPI_Keywords.robot
Library		testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py

*** Variables ***

${BTS_ADDRESS} =           192.168.255.129
${BTS_path}=               /home/ute/OAM-KPI-SR/Log
${ippduhostip}=            10.58.242.47
${portnum}=                5
${nr_cell_distname}=        MRBTS-1025/NRBTS-1025/NRCELL-
@{nr_cell_ids}=             2   3   5   6   9   10
${lte_cell_distname}=        MRBTS-1025/LNBTS-1025/LNCEL-
@{lte_cell_ids}=             0   1
${rmod_distname}=          MRBTS-1025/EQM-1/APEQM-1/RMOD-1
${bbmod_distname}=         MRBTS-1025/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${SYSregexpattern}=        <..........T..:..:..
${var_start_sys}=          availability status: Offline
${var_end_sys}=            Validated to OnAirDone
${power_on_time}=
${KPI3_time}=               300
${KPI51_time}=              240
${KPI13_time}=              420
${KPI11_time}=              548
${KPI7_10_time}=              120
${KPI1_time}=              348
${KPI54_time}=              240
${KPI5_time}=              365
${KPI12_time}=
@{list_of_expFaults}=      6327    61649    4655    61524    4654    61652    7220   7107    7115    4592    4297    4647
${mo_id}=                  PLMN-PLMN/MRBTS-1025/MNL-1/MNLENT-1/SYNC-1
${FILTER_BY}=                   MRBTS
${mo_name}=                     PLMN-PLMN/MRBTS-1025
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
${hostip_ru1}=                   10.58.242.49
${hostip_ru2}=                   10.58.242.57
${hostip_ru3}=                   10.58.242.57
${port_ru1}=                     3
${port_ru2}=                     2
${port_ru3}=                     3
${plan_name}=                   NetActPlanforTest_CB012145
${distname_gracefulSH}=         MRBTS-1025/NRBTS-1025
${grSD_valueTrue}=              true
${parameter_grSD}=              actGrflShdn
${grSD_valueFalse}=             false
${iteration}=                   2
@{lock_unlock}=                 kpi16a_b_LTE    kpi16a_b_NR     kpi17a_b_LTE    kpi17a_b_NR
${trunk}= 						SBTS26R3
${branch_N-1}=					SBTS26R2

*** Test Cases ***

TC_kpi13
     [Documentation]    CB010445-C_KPI#13_Manual SW rollback downtime
     [Tags]    TC2

     FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        RollbackSWinBTS
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFile.zip
        Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshot.ims2
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI13_time}
        ...        kpi13
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
     END


TC_kpi3
    [Documentation]    CB010445-C_KPI#3_Power-on startup availability
    [Tags]    TC6

    log to console      \n--starting test case  KPI#3_Power-on startup availability --\n
    FOR    ${i}    IN RANGE    1    ${iteration}
        log      power off the bts first
        log to console    \n---iteration number ${i} started--\n
        Sleep    60
        PerformPowerOfffromIpPdu     ${ippduhostip}    ${portnum}
        log to console      \n---step -PerformPowerOfffromIpPdu - is completed --\n
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        PerformBTSPowerOnfromIpPdu     ${ippduhostip}    ${portnum}
        Sleep    100
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFileIteration${i}.zip
        collect_im_snapshot
        ...  ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshotIteration${i}.ims2
        collect_raw_alarm_history_file
        ...        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/alarmSnapshotIteration${i}.json
        collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/scfIteration${i}.xml
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI3_time}
        ...        kpi3
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
        log to console    \n---iteration number ${i} is completed--\n
    END


TC_kpi54
    [Documentation]    CB010445-C_KPI#54a_Power-On RU Startup availability
    [Tags]    TC7

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        PerformPowerOfffromIpPdu     ${hostip_ru1}    ${port_ru1}
        #PerformPowerResetfromIpPdu    ${hostip_ru1}    ${port_ru1}
        #PerformPowerResetfromIpPdu    ${hostip_ru2}    ${port_ru2}
        #PerformPowerResetfromIpPdu    ${hostip_ru3}    ${port_ru3}
        sleep    30s
        PerformRUPowerOnfromIpPdu    ${hostip_ru1}    ${port_ru1}
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI54_time}
	 ...		kpi54
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END


TC_kpi11
    [Documentation]    CB010445-C_KPI#11_Manual remote power reset downtime
    [Tags]    TC3

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        PerformPowerReset
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFile.zip
        Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshot.ims2
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
        ...        kpi11
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END


TC_kpi51
    [Documentation]    CB010445-C_KPI#51a_Manual RU reset downtime
    [Tags]    TC1

    FOR    ${i}    IN RANGE    1    ${iteration}
        log to console      iternation=${i}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ResetSingleRadio    ${rmod_distname}
        sleep    4m
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFileIteration${i}.zip
        collect_im_snapshot
        ...  ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshotIteration${i}.ims2
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI51_time}
        ...        kpi51a
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END






TC_kpi7_10
    [Documentation]    CB010445-C_KPI#7_KPI#10_Manual LTE RAT reset downtime and Manual 5G RAT reset downtime
    [Tags]    TC4

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        PerformNRResetRAT
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
        ...        kpi11
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END
    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        PerformLTEResetRAT
        sleep    2m
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}

        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI7_10_time}
        ...        kpi7
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi16a_16b_17a_17b
    [Documentation]    CB010445-C_KPI#16a_KPI#16b_KPI#17a_KPI#17b_Manual lock cell duration
    ...         Manual unlock cell duration_Manual block cell duration_Manual unblock cell duration
    [Tags]    TC3
    Log     Lock cell kpi#16a
    FOR    ${type}     IN     @{lock_unlock}
       IF      ${type} == kpi16a_b_LTE
          FOR    ${i}    IN RANGE    1    ${iteration}
               os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               AllLteCellLockUnlock
               Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
               Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SnapshotFile.zip
               Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/imSnapshot.ims2
               ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SYSlogs/btslog
               ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
               log    ${tmp}
               Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
               ...        ${path}    ${SYSregexpattern}
               ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
               ...        kpi16a
           END
        ELSE IF     ${type} == kpi16a_b_NR
           FOR    ${i}    IN RANGE    1    ${iteration}
               os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               AllNRcelllockUnlock
               Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
               Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SnapshotFile.zip
               Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/imSnapshot.ims2
               ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SYSlogs/btslog
               ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
               log    ${tmp}
               Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
               ...        ${path}    ${SYSregexpattern}
               ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
               ...        kpi16a
           END
        ELSE IF      ${type} == kpi17a_b_LTE
           FOR    ${i}    IN RANGE    1    ${iteration}
               os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               AllLTEcellBlockUnblock
               Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
               Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SnapshotFile.zip
               Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/imSnapshot.ims2
               ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SYSlogs/btslog
               ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
               log    ${tmp}
               Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
               ...        ${path}    ${SYSregexpattern}
               ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
               ...        kpi16a
           END
        ELSE IF     ${type} == kpi17a_b_NR
           FOR    ${i}    IN RANGE    1    ${iteration}
               os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               AllNRcelllockUnlock
               Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
               Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}
               Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SnapshotFile.zip
               Collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/imSnapshot.ims2
               ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${type}/Iteration${i}/SYSlogs/btslog
               ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
               log    ${tmp}
               Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
               ...        ${path}    ${SYSregexpattern}
               ...        ${var_start_sys}     ${var_end_sys}    ${KPI11_time}
               ...        kpi16a
           END
		END


        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END





TC_kpi1
    [Documentation]    CB010445-C_KPI#1a_Manual Site Reset downtime
    [Tags]    TC100

    FOR    ${i}    IN RANGE    1    ${iteration}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Reset Site
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SnapshotFileIteration${i}.zip
        collect_im_snapshot
        ...       ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/imSnapshotIteration${i}.ims2
        collect_raw_alarm_history_file
        ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/alarmSnapshotIteration${i}.json
        collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/scfIteration${i}.xml
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI1_time}
		...		kpi1
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END

TC_kpi5
    [Documentation]    CB010445-C_KPI#5_Capacity Module reset Downtime
    [Tags]    TC543

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd
    Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd
    SingleBBmodReset    ${bbmod_distname}
    Sleep    3m
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wo_gsd/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI5_time}
	...		   kpi5
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    Perform Parameter Recommissioning          ${distname_gracefulSH}       ${parameter_grSD}    ${grSD_valueTrue}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    FOR    ${i}    IN RANGE    1    4
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        SingleBBmodReset    ${bbmod_distname}
        Sleep    3m
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}
        ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/SYSlogs/btslog
        ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
        log    ${tmp}
        Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
        ...        ${path}    ${SYSregexpattern}
        ...        ${var_start_sys}     ${var_end_sys}    ${KPI5_time}
		...        kpi5
        Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    END
    Perform Parameter Recommissioning          ${distname_gracefulSH}       ${parameter_grSD}    ${grSD_valueFalse}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State


TC_kpi12
    [Documentation]    CB010445-C_KPI#12_CM activation with site reset service downtime
    [Tags]    TC101

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}

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
    Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI12_time}
	...        kpi12
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}
    Delete Plan    ${plan_name}
    Delete Node    cmwas    alias=${NETACT_NAME}
    Delete Node    nwi3    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}


TC_kpi2a_2b
    [Documentation]    CB010445-C_KPI#2a_2b_Inter-release SW activation downtime without firmware update and with Firmware update
    [Tags]    TC101
    log    Download N-1 build
	${SBTS_type}=    Get_SBTS_build_type_from_BTS
	${current_trunk_prefix}    Set variable     ${trunk}
	${branch_N-1_prefix}    Set Variable    ${branch_N-1}
	IF   '${SBTS_type}'== '${current_trunk_prefix}'
		${SBTS_type}    Set Variable    SBTS00
		log     BTS is on trunk build. Need to download ${branch_N-1_prefix} build and trunk build for inter release upgrade.
		log     Download trunk starts...
		${sw_path_trunk}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
		log    ${sw_path_trunk}
		${SBTS_type}    Set Variable    ${branch_N-1_prefix}
		log     Download branch starts...
		${sw_path_branch}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
		log    ${sw_path_branch}
		log    Need to downgrade BTS to branch.
		admin.update_software   sw_package=${sw_path_branch}    should_activate=True   timeout=600
		...		should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
		Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
	ELSE IF    '${SBTS_type}'== '${branch_N-1_prefix}'
		log     Already on ${branch_N-1_prefix} build. Need to download only trunk build.
		${SBTS_type}    Set Variable    SBTS00
		log     Download trunk starts...
		${sw_path_trunk}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
		log    ${sw_path_trunk}
	END

	log    Main test case body starts here.

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
	log   starting inter release SW upgrade from ${branch_N-1_prefix} to ${current_trunk_prefix}
	admin.update_software   sw_package=${sw_path_trunk}    should_activate=True   timeout=600
		...		should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotFile.zip
    collect_im_snapshot
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/imSnapshot.ims2
    collect_raw_alarm_history_file
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alarmSnapshot.json
    collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/scf.xml
    Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI12_time}
	...        kpi2
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}

TC_kpi2c_2d
    [Documentation]    CB010445-C_KPI#2c_2d_Intra-Release SW Activation Without Firmware Update  and with firmware update
    [Tags]    TC101
	${SBTS_type}=    Get_SBTS_build_type_from_BTS
	${current_trunk_prefix}    Set variable     ${trunk}
	${branch_N-1_prefix}    Set Variable    ${branch_N-1}
	IF   '${SBTS_type}'== '${current_trunk_prefix}'
		${SBTS_type}    Set Variable    SBTS00
		log     BTS is on trunk build.
		log     Download trunk starts.
		${sw_path_trunk}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
		log    ${sw_path_trunk}
	END

	log    Main test case body starts here.

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
	log   starting intra release SW upgrade.
	admin.update_software   sw_package=${sw_path_trunk}    should_activate=True   timeout=600
		...		should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotFile.zip
    collect_im_snapshot
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/imSnapshot.ims2
    collect_raw_alarm_history_file
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alarmSnapshot.json
    collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/scf.xml
    Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI12_time}
	...        kpi2
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}


TC_kpi4
    [Documentation]    CB010445-C_KPI#4 Complete BTS SW upgrade
    [Tags]    TC101
	${SBTS_type}=    Get_SBTS_build_type_from_BTS
	${current_trunk_prefix}    Set variable     ${trunk}
	${branch_N-1_prefix}    Set Variable    ${branch_N-1}
	IF   '${SBTS_type}'== '${current_trunk_prefix}'
		${SBTS_type}    Set Variable    SBTS00
		log     BTS is on trunk build.
		log     Download trunk starts.
		${sw_path_trunk}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
		log    ${sw_path_trunk}
	END

	log    Main test case body starts here.
	log    start point for kpi measurement is sw download begins.

    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start Btslogs from Local machine         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
	log   starting SW upgrade.
    ${SW_download_time}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S
    ${SW_download_time}=    Convert to String     ${SW_download_time}
	Set Suite Variable  ${SW_download_begin_time}  ${SW_download_time}
    log      SW download begin time is ${SW_download_begin_time}
	admin.update_software   sw_package=${sw_path_trunk}    should_activate=True   timeout=600
		...		should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotFile.zip
    collect_im_snapshot
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/imSnapshot.ims2
    collect_raw_alarm_history_file
    ...     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alarmSnapshot.json
    collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/scf.xml
    Stops Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ${path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SYSlogs/btslog
    ${tmp}=    os.run    tar -zxvf ${path}/syslog_files.tgz -C ${path}
    log    ${tmp}
    Run Keyword and Continue On Failure    GrepTimeStampsfromSYSLOGSandCalculateTimeDifference
    ...        ${path}    ${SYSregexpattern}
    ...        ${var_start_sys}     ${var_end_sys}    ${KPI12_time}
	...        kpi4
    Run Keyword and Continue On Failure    Get ActiveAlarms    @{list_of_expFaults}