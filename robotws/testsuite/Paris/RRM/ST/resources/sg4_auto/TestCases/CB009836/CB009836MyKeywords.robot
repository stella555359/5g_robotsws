*** Settings ***
Documentation
...     TODO

*** Keywords ***
Actions Suite Setup
    ${date}             DateTime.get current date    result_format=%Y%m%d_%H_%M
#    ${date}         Set Variable        20240828_11_38
    ${directory}        replace string      ${SUITE NAME}_${date}    ${SPACE}    _
    ${suiteLogPath}     set variable        ${logPath}/${directory}

    create directory    ${suiteLogPath}
    set suite variable  ${suiteLogPath}    ${suiteLogPath}
    set suite variable  ${resultFile}    ${suiteLogPath}/result.txt
    set suite variable  ${csiRsFile}    ${suiteLogPath}/resultCsiRs.txt
    coam.connect to     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}       name=coam_admin        trim_logs=True
    coam.get_current_scf_file       local_dir_path=${suiteLogPath}    file_name=scf_orig.xml   connection=coam_admin  timeout=30s
    Get TTI trace Decoder CB007113
    ${collectors}    Create Dictionary
    Set Suite Variable    ${SUITE_TAF_collectors}    ${collectors}


Actions Suite Teardown

    Run Keyword If        ${restoreSCF}
    ...            coam.perform_commissioning	bts_id=0	scf_file=${suiteLogPath}/scf_orig.xml
    ...     skip_parameter_relation_errors=True	    should_activate=True    	timeout=300      connection=coam_admin

    coam.teardown    connection=coam_admin
    myData           ${resultFile}    ${myDataSet}
    Start Process       sleep ${timerTeardown} && cp ${OUTPUT_FILE} ${suiteLogPath}           shell=True
    Start Process       sleep ${timerTeardown} && cp ${LOG_FILE} ${suiteLogPath}              shell=True
    Start Process       sleep ${timerTeardown} && cp ${REPORT_FILE} ${suiteLogPath}           shell=True
    Start Process       sleep 30 && rm ${OUTPUT_DIR}/*ims2           shell=True


Actions Test Setup
    ${date}             DateTime.get current date    result_format=%Y%m%d_%H_%M
#    ${date}         Set Variable        20240828_11_38
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${testLogPath}      joinpath        ${suiteLogPath}     ${directory}
    create directory    ${testLogPath}
    set test variable   ${testLogPath}     ${testLogPath}/
    OperatingSystem.Run  command=rm ${OUTPUT_DIR}/ue_proxy*
    OperatingSystem.Run  command=rm ${OUTPUT_DIR}/ue.UE*
    #coam.connect to     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}       name=coam_admin
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_orig.xml   connection=coam_admin
    ${softVersion}        coam.Get SW version   connection=coam_admin
    ${softVersion2}       testline.Get gNB SW version
    coam.get_sw_release_name      connection=coam_admin
    Append To File   ${resultFile}   ------------------------------------------------------\n
    Append To File   ${resultFile}   ${TEST NAME}\n
    Append To File   ${resultFile}   Software: ${softVersion}\n
    #Append To File   ${resultFile}   Software: ${softVersion2}\n
    Append To File   ${resultFile}   ------------------------------------------------------\n
    Append To File   ${csiRsFile}   ------------------------------------------------------\n
    Append To File   ${csiRsFile}   ${TEST NAME}\n
    Append To File   ${csiRsFile}   ------------------------------------------------------\n


Actions Test Setup with UEs
    ${date}             DateTime.get current date    result_format=%Y%m%d_%H_%M
#    ${date}         Set Variable        20240828_11_38
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${testLogPath}      joinpath        ${suiteLogPath}     ${directory}
    create directory    ${testLogPath}
    set test variable   ${testLogPath}     ${testLogPath}/
    OperatingSystem.Run  command=rm ${OUTPUT_DIR}/ue_proxy*
    OperatingSystem.Run  command=rm ${OUTPUT_DIR}/ue.UE*
    #coam.connect to     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}       name=coam_admin
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_orig.xml   connection=coam_admin
    ${softVersion}        coam.Get SW version   connection=coam_admin
    ${softVersion2}       testline.Get gNB SW version
    coam.get_sw_release_name      connection=coam_admin
    Append To File   ${resultFile}   ------------------------------------------------------\n
    Append To File   ${resultFile}   ${TEST NAME}\n
    Append To File   ${resultFile}   Software: ${softVersion}\n
    #Append To File   ${resultFile}   Software: ${softVersion2}\n
    Append To File   ${resultFile}   ------------------------------------------------------\n
    Append To File   ${csiRsFile}   ------------------------------------------------------\n
    Append To File   ${csiRsFile}   ${TEST NAME}\n
    Append To File   ${csiRsFile}   ------------------------------------------------------\n

    Require UEs      1   2   3
    Reboot UEs      1   2   3
    Sleep     60s
    Detach UEs      1       2       3

Actions Test Teardown
    Run Keyword if     ${SnapshotOnTeardown}
    ...     Run Keyword And Continue On Failure   Collect snapshot coam ext01             resultBaseDir=${testLogPath}
    FOR   ${ue}   IN   @{ueList}
        Run keyword and ignore error    ue.Stop Data Transfer  dt_name=dt_UE_${ue}_dl
        Run keyword and ignore error    ue.detach_ue    ue_alias=${alias_${ue}}
#        Run keyword and ignore error    ue.reboot ue    ${alias_${ue}}    timeout=120
        #Kill Python On PC UE   ${ue}
    END
    #coam.teardown    connection=coam_admin
    Append To File   ${resultFile}   \nFINAL RESULT: ${TEST_STATUS}\n
    Append To File   ${resultFile}   \n********************************************************************
    Append To File   ${resultFile}   \n********************************************************************\n\n
    Append To File   ${csiRsFile}   \n********************************************************************
    Append To File   ${csiRsFile}   \n********************************************************************\n\n
    OperatingSystem.Run  command=cp ${OUTPUT_DIR}/ute_ue* ${testLogPath}
    OperatingSystem.Run  command=cp ${OUTPUT_DIR}/ue_proxy* ${testLogPath}
    OperatingSystem.Run  command=cp ${OUTPUT_DIR}/ue.UE* ${testLogPath}
    OperatingSystem.Run  command=for file in `ls ${testLogPath}/*csv`; do gzip $file; done
    OperatingSystem.Run  command=for file in `ls ${testLogPath}/*pcap`; do gzip $file; done


myKw Main test 1
    myKw Log config in result file
    myKw Activate config
    myKw Check TRS CSI-RS allocation
    myKw Check cell specific CSI-RS allocation
    MyKw Launch UE part

myKw Main test 2

    myKw Main test 3-sub1
    MyKw Launch UE part One UE PC
    ${stats}  myTTI v1      suffixe=${EMPTY}       duration=${5}
    run keyword if     ${checkPRB}  myKw PRB check

myKw Main test 3
#    #Idem myKw Main test 1 + cell setup si le SYSLOG n est pas complet (2x)
    myKw Main test 3-sub1
    MyKw Launch UE part
    sleep     10s
    ${stats}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=${EMPTY}       duration=${5}

    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv

    run keyword if     ${checkPRB}  myKw PRB check

myKw Main test 3bis
#    #Idem myKw Main test 1 + cell setup si le SYSLOG n est pas complet (2x)
    Log To Console    \nStep 1: CNI OFF
    set test variable   ${nbCheck}  0
    set test variable  ${lockRequired}   No
    SetFlagOnSwConfig        0x5809C1        0
    myKw Log config in result file
    ${cellsNumber}       Get Cells Number OAM
    ${nrCells}          Evaluate    list(range(${cellsNumber}))
    ${nrCellIx}          Evaluate    list(range(${cellsNumber}))
#    Lock Cells        ${cellsToLock}
#    ${nrCellIx}    Evaluate    [d for d in ${nrCellIx} if d not in ${cellsToLock}]
    ${nrCellId_all}            Get Cells List OAM
    ${nrCellId}    Create List
    FOR   ${cell}    IN    @{nrCellIx}
        Append To List    ${nrCellId}    ${nrCellId_all[${cell}]}
    END
    Set Test Variable         ${nrCellId}
    Set Test Variable         ${nrCellIx}
    myKw Activate config
    myKw Check TRS CSI-RS allocation v2
    myKw Check cell specific CSI-RS allocation v2
    myKw Check errors in Syslog


    Run Keyword If    ${skipFileCreation}       OperatingSystem.Run  command=cp /tmp/check_cell_setup.json ${testLogPath}/check_cell_setup.json

    Run Keyword If      ${CheckPRB} and not ${skipFileCreation}      myKw Create File for PRB Checks
    log  ${lockRequired}
    run keyword if  '${lockRequired}' == 'Yes'  run keywords
    ...  myKw Trigger Cell Setup
    ...  AND  Append To File  ${resultFile}     \nNew attempt. Perform lock/unlock\n
    ...  AND  myKw Trigger Cell Setup
    ...  AND  myKw Check TRS CSI-RS allocation v2
    ...  AND  myKw Check cell specific CSI-RS allocation v2
    log  ${lockRequired}
    run keyword if  '${lockRequired}' == 'Yes'  run keywords
    ...  myKw Trigger Cell Setup
    ...  AND  Append To File  ${resultFile}     \nNew attempt. Perform lock/unlock\n
    ...  AND  myKw Trigger Cell Setup
    ...  AND  myKw Check TRS CSI-RS allocation v2
    ...  AND  myKw Check cell specific CSI-RS allocation v2
    run keyword if  '${lockRequired}' == 'Yes'   run keywords
    ...  Append To File  ${resultFile}     \nMISSING Info in SYSLOG\n
    ...  AND  Run Keyword And Continue On Failure   Fail   MISSING Info in SYSLOG
    MyKw Launch UE part
    sleep     10s
    ${stats_ref}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_CNI_OFF       duration=${5}
    Run Keyword If        ${collectSnap}        coam.collect snapshot      target_file_name=${testLogPath}/snapshot_CNI_OFF    connection=coam_admin
    Log To Console    \n...Snapshot Taken for CNI OFF
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_CNI_OFF.LOG
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${ReqPeriodicity}    1
    append to file  ${resultFile}        Stats CNI OFF:\n
    FOR   ${key}  IN  @{stats_ref.keys()}
        log  ${stats_ref["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats_ref["${key}"]}[0] Mbps Bler: ${stats_ref["${key}"]}[1]% MCS: ${stats_ref["${key}"]}[2]\n
    END
    run keyword if     ${checkPRB}  myKw PRB check        suffixe=_CNI_OFF

    Stop Data Transfers For All Ues
    Log To Console    \n...Traffic Stopped CNI OFF
    ${stats_ref}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_NO_TRAFFIC_CNI_OFF       duration=${5}
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_NO_TRAFFIC_CNI_OFF.LOG
    # Activate CNI
    Log To Console    \nStep 2: CNI ON
    SetFlagOnSwConfig        0x5809C1        1

    wait until keyword succeeds     300s        10s        Reset Site and check Cells Are On Air
    # Launch traffic
    FOR   ${ue}   IN   @{ueList}
                run keyword and continue on failure    ue.attach_ue       ue_alias=${alias_${ue}}
                run keyword and continue on failure   set airplane mode Off and enable data   ${ue}
                run keyword and continue on failure
                ...        MyKw Launch UE part sub 2  ${ue}  dl=${dl}  ul=${ul}  ngbr=${ngbr}  gbr=${gbr}
    END
    ${stats_after}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_CNI_ON       duration=${5}
    Run Keyword If        ${collectSnap}        coam.collect snapshot        target_file_name=${testLogPath}/snapshot_CNI_ON   connection=coam_admin
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_CNI_ON.LOG
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${ReqPeriodicity}    5
    append to file  ${resultFile}        Stats CNI ON:\n
    FOR   ${key}  IN  @{stats_after.keys()}
        log  ${stats_after["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats_after["${key}"]}[0] Mbps Bler: ${stats_after["${key}"]}[1]% MCS: ${stats_after["${key}"]}[2]\n
        ${status}   evaluate   ${stats_after["${key}"]}[0] > ${stats_ref["${key}"]}[0]*0.9
        run keyword if   not(${status})    set test variable  ${checkTput}  tputNotOK
    END
    run keyword if  '${checkTput}' == 'tputNotOK'  Run Keyword And Continue On Failure  fail   \nTput degraded with CNI
    Log To Console    \n...Snapshot Taken for CNI ON
    Stop Data Transfers For All Ues
    Log To Console    \n...Traffic Stopped CNI ON
    ${stats_ref}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_NO_TRAFFIC_CNI_ON       duration=${5}
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_NO_TRAFFIC_CNI_ON.LOG

myKw Main test 3-sub1
    set test variable   ${nbCheck}  0
    set test variable  ${lockRequired}   No
    myKw Log config in result file
    ${cellsNumber}       Get Cells Number OAM
    ${nrCells}          Evaluate    list(range(${cellsNumber}))
    ${nrCellIx}          Evaluate    list(range(${cellsNumber}))
#    Lock Cells        ${cellsToLock}
#    ${nrCellIx}    Evaluate    [d for d in ${nrCellIx} if d not in ${cellsToLock}]
    ${nrCellId_all}            Get Cells List OAM
    ${nrCellId}    Create List
    FOR   ${cell}    IN    @{nrCellIx}
        Append To List    ${nrCellId}    ${nrCellId_all[${cell}]}
    END
    Set Test Variable         ${nrCellId}
    Set Test Variable         ${nrCellIx}
    myKw Activate config
    myKw Check TRS CSI-RS allocation v2
    myKw Check cell specific CSI-RS allocation v2
    myKw Check errors in Syslog

#    Lock Cells        ${cellsToLock}
#    ${nrCellId}    Evaluate    [d for d in ${nrCellId} if d not in ${cellsToLock}]
    Run Keyword If      ${CheckPRB}     myKw Create File for PRB Checks
    log  ${lockRequired}
    run keyword if  '${lockRequired}' == 'Yes'  run keywords
    ...  myKw Trigger Cell Setup
    ...  AND  Append To File  ${resultFile}     \nNew attempt. Perform lock/unlock\n
    ...  AND  myKw Trigger Cell Setup
    ...  AND  myKw Check TRS CSI-RS allocation v2
    ...  AND  myKw Check cell specific CSI-RS allocation v2
    log  ${lockRequired}
    run keyword if  '${lockRequired}' == 'Yes'  run keywords
    ...  myKw Trigger Cell Setup
    ...  AND  Append To File  ${resultFile}     \nNew attempt. Perform lock/unlock\n
    ...  AND  myKw Trigger Cell Setup
    ...  AND  myKw Check TRS CSI-RS allocation v2
    ...  AND  myKw Check cell specific CSI-RS allocation v2
    run keyword if  '${lockRequired}' == 'Yes'   run keywords
    ...  Append To File  ${resultFile}     \nMISSING Info in SYSLOG\n
    ...  AND  Run Keyword And Continue On Failure   Fail   MISSING Info in SYSLOG

myKw Main test 4
    set test variable   ${nbCheck}  0
    set test variable  ${lockRequired}   No
    myKw Log config in result file CB12605
    wait until keyword succeeds             120s        1s         gnb_log.Start Collecting GNB Btslog
    wait until keyword succeeds     300s        10s        Reset Site and check Cells Are On Air
    ${cellsNumber}       Get Cells Number OAM
    ${nrCellIx}          Evaluate    list(range(${cellsNumber}))
    Lock Cells        ${cellsToLock}
    ${nrCellIx}    Evaluate    [d for d in ${nrCellIx} if d not in ${cellsToLock}]
    ${nrCellId_all}            Get Cells List OAM
    ${nrCellId}    Create List
    FOR   ${cell}    IN    @{nrCellIx}
        Append To List    ${nrCellId}    ${nrCellId_all[${cell}]}
    END
    Set Test Variable         ${nrCellId}
    Set Test Variable         ${nrCellIx}
    Sleep        10s
    OperatingSystem.Run  command=cp ${syslog_folder}/${syslog} ${testLogPath}/${syslog}
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=${testLogPath}

    Run Keyword If    ${skipFileCreation}
    ...    OperatingSystem.Run  command=cp /tmp/check_cell_setup.json ${testLogPath}/check_cell_setup.json

    Run Keyword If      ${CheckPRB} and not ${skipFileCreation}      myKw Create File for PRB Checks
    ${l1Sp_assign}        Get From Pool Checks File        l1SpCells        ${testLogPath}/check_cell_setup.json

    MyKw Launch UE part One UE PC

    ${stats}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=${EMPTY}       duration=${5}
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv

    run keyword if     ${checkPRB}  myKw PRB check

myKw Main test 4bis
    Log To Console    \nStep 1: CNI OFF
    set test variable   ${nbCheck}  0
    set test variable  ${lockRequired}   No
    SetFlagOnSwConfig        0x5809C1        0
    myKw Log config in result file CB12605
    wait until keyword succeeds             120s        1s         gnb_log.Start Collecting GNB Btslog
    wait until keyword succeeds     300s        10s        Reset Site and check Cells Are On Air
    ${cellsNumber}       Get Cells Number OAM
    ${nrCellIx}          Evaluate    list(range(${cellsNumber}))
    Lock Cells        ${cellsToLock}
    ${nrCellIx}    Evaluate    [d for d in ${nrCellIx} if d not in ${cellsToLock}]
    ${nrCellId_all}            Get Cells List OAM
    ${nrCellId}    Create List
    FOR   ${cell}    IN    @{nrCellIx}
        Append To List    ${nrCellId}    ${nrCellId_all[${cell}]}
    END
    Set Test Variable         ${nrCellId}
    Set Test Variable         ${nrCellIx}
    Sleep        10s
    OperatingSystem.Run  command=cp ${syslog_folder}/${syslog} ${testLogPath}/SYSLOG_CELLSETUP_CNI_OFF.LOG
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=${testLogPath}
    myKw Check errors in Syslog

    Run Keyword If    ${skipFileCreation}
    ...        OperatingSystem.Run  command=cp /tmp/check_cell_setup.json ${testLogPath}/check_cell_setup.json

    Run Keyword If      ${CheckPRB} and not ${skipFileCreation}      myKw Create File for PRB Checks
    ${l1Sp_assign}        Get From Pool Checks File        l1SpCells        ${testLogPath}/check_cell_setup.json

    MyKw Launch UE part One UE PC

    ${stats_ref}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_CNI_OFF       duration=${5}  snapshot=${collectSnap}
    Log To Console    \n...Traces Taken for CNI OFF
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_CNI_OFF.LOG
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${ReqPeriodicity}    1
    append to file  ${resultFile}        Stats CNI OFF:\n
    FOR   ${key}  IN  @{stats_ref.keys()}
        log  ${stats_ref["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats_ref["${key}"]}[0] Mbps Bler: ${stats_ref["${key}"]}[1]% MCS: ${stats_ref["${key}"]}[2]\n
    END
    run keyword if     ${checkPRB}  myKw PRB check        suffixe=_CNI_OFF
    ${throughput_ref}    Create List
    FOR   ${ue}   IN   @{ueList}
        ${thp_i}        Get Throughput        ${ue}
        Append To List    ${throughput_ref}    ${thp_i}
    END
    Stop Data Transfers For All Ues

    Log To Console    \n...Traffic Stopped, CNI OFF
    Log To Console    \n...Average Throughput CNI OFF: ${throughput_ref}

    ${stats_ref_off}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_NO_TRAFFIC_CNI_OFF       duration=${5}
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_NO_TRAFFIC_CNI_OFF.LOG
    # Activate CNI-127661
    SetFlagOnSwConfig        0x5809C1        1

    wait until keyword succeeds             120s        1s         gnb_log.Start Collecting GNB Btslog

    wait until keyword succeeds     300s        10s        Reset Site and check Cells Are On Air
    Lock Cells        ${cellsToLock}
    Sleep        10s
    OperatingSystem.Run  command=cp ${syslog_folder}/${syslog} ${testLogPath}/SYSLOG_CELLSETUP_CNI_ON.LOG
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=${testLogPath}

    # Launch traffic
    FOR   ${ue}   IN   @{ueList}
                run keyword and continue on failure    ue.attach_ue       ue_alias=${alias_${ue}}
                run keyword and continue on failure   set airplane mode Off and enable data   ${ue}
                run keyword and continue on failure
                ...        MyKw Launch UE part sub 2  ${ue}  dl=${dl}  ul=${ul}  ngbr=${ngbr}  gbr=${gbr}
    END
    ${stats_after}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_CNI_ON       duration=${5}  snapshot=${collectSnap}
    Log To Console    \n...Traces Taken for CNI ON
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_CNI_ON.LOG
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${ReqPeriodicity}    5
    append to file  ${resultFile}        Stats CNI ON:\n
    FOR   ${key}  IN  @{stats_after.keys()}
        log  ${stats_after["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats_after["${key}"]}[0] Mbps Bler: ${stats_after["${key}"]}[1]% MCS: ${stats_after["${key}"]}[2]\n
        ${status}   evaluate   ${stats_after["${key}"]}[0] > ${stats_ref["${key}"]}[0]*0.9
        run keyword if   not(${status})    set test variable  ${checkTput}  tputNotOK
    END
    run keyword if  '${checkTput}' == 'tputNotOK'  Run Keyword And Continue On Failure  fail   \nTput degraded with CNI
    ${throughput_after}    Create List
    FOR   ${ue}   IN   @{ueList}
        ${thp_i}        Get Throughput        ${ue}
        Append To List    ${throughput_after}    ${thp_i}
    END
    Stop Data Transfers For All Ues


    Log To Console    \n...Traffic Stopped, CNI ON
    Log To Console    \n...Average Throughput CNI ON: ${throughput_after}
    ${stats_after_off}  run keyword if     ${checkPRB}     myTTI w Syslog      suffixe=_NO_TRAFFIC_CNI_ON       duration=${5}
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${ReqPeriodicity}        Get resourceReq periodicity        ${testLogPath}        SYSLOG_CALL_NO_TRAFFIC_CNI_ON.LOG

myKw Launch and convert TTI
    [Arguments]   ${suffixe}               ${duration}
    Collect TTI Traces in Streaming mode CB007113       tti_trace_path=${testLogPath}
    ...     tti_trace_filename=traceTTI${suffixe}
    ...     tti_trace_duration=${duration}     trace_ip=${tl.test_pc.default_ssh_connection_details.addr}
    Convert TTI trace from pcap to excelCsv CB007113    traceTTI${suffixe}.pcap        ${testLogPath}


Get TTI trace Decoder
    ${SOFTWARE_INFO}        coam.Get SW version   connection=coam_admin
    Set suite variable      ${SOFTWARE_INFO}
    _Download And Install Ttitrace Decode Tool From File Server

myKw Activate config
    ${param_list}    Create List

    #Mandatory feature activation checks
    ${xml_root} =   XML.parse xml   ${testLogPath}/scf_orig.xml
    set test variable  ${testCheck}  testOK
    FOR  ${cellID}  IN   @{nrCellId}
        Compare value with current configuration  ${xml_root}   ${cellID}  actDlMuMimoEnh  ${actDlMuMimoEnh}
        Compare value with current configuration  ${xml_root}   ${cellID}   actUlMuMimo  ${actUlMuMimo}
        Compare value with current configuration  ${xml_root}   ${cellID}   actSuperCell  ${actSuperCell}
    END
    run keyword if  '${testCheck}' == 'testNotOK'   fail   \nWrong Mandatory Config (UL or DL MIMO)
    Append To File   ${resultFile}   \n\nCheck Mandatory Config--> PASSED\n(UL/DL MIMO, no superCell)\n

    #Prepare the configuration from preconditions
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actBbPoolTddFr1$=${actBbPoolTddFr1}
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actBbPoolExtensionTddFr1=${actBbPoolExtensionTddFr1}
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actBbPoolTddFr1AlgEnh=${actBbPoolTddFr1AlgEnh}
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actSlowPrbPooling$=${actSlowPrbPooling}
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actSpatialStreamPooling=${actSpatialStreamPooling}
    Append To List  ${param_list}  modify:${mrbts}/${nrbts}:actExplicitCsirsPoolSolution=${actExplicitCsirsPoolSolution}
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actFdmEnhancedScheduling=${actFdmEnhancedScheduling}
    Append To List    ${param_list}    modify:${mrbts}/${nrbts}:actBbPoolTddFr1Enh=${actBbPoolTddFr1Enh}
    #Append To List       ${param_list}    modify:${mrbts}/${nrbts}:actTddCsirsOpt=${actTddCsirsOpt}

    ${param_list}  myKw Create ChannelGroup  ${param_list}

    FOR     ${cellID}  IN   @{nrCellId}
        ${i}        get index from list        ${nrCellId}        ${CellId}
        ${param_list}    myKw Set Frame Structure   ${cellID}   ${param_list}
		run keyword if   '${actInfTddFrameMuting}' == 'true'
		...        myKw Set Interfering Frame Structure   ${cellID}   ${param_list}
		${scf_modifs}    create list
            ...  modify:${cellID}:cellBwpList:bwpDN=${bwp0}[${i}]|cellBwpId=0
            ...  modify:${cellID}:cellBwpList:bwpDN=${bwp1}[${i}]|cellBwpId=1
            ...  modify:${cellID}:chBw=${chBw}[${i}]
            #...  modify:${cellID}:srsForBeamMgmt:cSRS=${cSRS}[${i}]
            ...  modify:${cellID}:srsForBeamMgmt:cSRS=${cSRS['${chBw}[${i}]']}
            ...  modify:${cellID}:reqMinNumPuschPrb=${reqMinNumPuschPrb['${chBw}[${i}]']}
            ...  modify:${cellID}:prachConfigurationIndex=${prach}[${i}]
            ...  modify:${cellID}:basicBeamSet=${beamset}[${i}]
            ...  modify:${cellID}:actDlSrsBm=${actDlSrsBm}
            ...  modify:${cellID}:actBeamforming=${actBeamforming}
            ...  modify:${cellID}:actCsirsMultiplexing=${actCsirsMultiplexing}
            ...  modify:${cellID}:actCellCsirsTddOnSsbBf=${actCellCsirsTddOnSsbBf}
            ...  modify:${cellID}:actCellCsiRsImTddNonBf=${actCellCsiRsImTddNonBf}
            ...  modify:${cellID}:actAdaptiveReTxResMcs$=${actAdaptiveReTxResMcs}
            #...  modify:${cellID}:actNonVoNRGBRService=${actNonVoNRGBRService}
            ...  modify:${cellID}:nrCellType=${nrCellType}[${i}]
            ...  modify:${cellID}:csirsForTracking:rbAllocation=${rbAllocation}
            ...  modify:${cellID}:actBlankDlSymbBorderCoord=${actBlankDlSymbBorderCoord}
            ...  modify:${cellID}:csirsNumberWithinReportPeriod_Set1=${csirsNbWithinReportPeriod_Set1}[${i}]
            ...  modify:${cellID}:msg1FrequencyStart=${msg1FrequencyStart}[${i}]
            ...  modify:${cellID}:periodicCsiAcquisition:maxCsirsNumber=${maxCsirsNumber}[${i}]
            ...  modify:${cellID}:periodicCsiAcquisition:csiReportPeriodicity=${csiReportPeriodicity}[${i}]
            ...  modify:NRCELLGRP-${nrCellGrplId}[${i}]:numberOfTransmittedSsBlocks=${beams}[${i}]
            ...  modify:${cellID}:csirsTrackingPeriod=${csirsTrackingPeriod}
            ...  modify:${cellID}:dlMimoMode=${dlMimoMode}[${i}]
            ...  modify:${cellID}:actInfTddFrameMuting=${actInfTddFrameMuting}
            ...  modify:${cellID}:actUeCsirsCoexistCellCsirs=${actUeCsirsCoexistCellCsirs}
            ...  modify:${cellID}:actCsirsBeamPowerBalance=${actCsirsBeamPowerBalance}
            ...  modify:${cellID}:actNonVoNRGbrService=${actNonVoNRGbrService}[${i}]
            ...  modify:${cellID}:actGBRAdmissionControl=${actGBRAdmissionControl}[${i}]
            ...  modify:${cellID}:actPerCsiReportBundlingTddFr1=${actPerCsiReportBundlingTddFr1}
            ...  modify:${cellID}:pagingOffset=${pagingOffset}[${i}]
            ...  modify:${cellID}:fPdcchMonOccsnPo=${fPdcchMonOccsnPo}[${i}],
           #... modify:${cellID}:csirsPower=4
        Append To List       ${param_list}     @{scf_modifs}

        ${bwp2_exists}  Run Keyword And Return Status  Variable Should Exist  ${bwp2}

        Run Keyword If      ${bwp2_exists}      Append To List       ${param_list}
        ...                 modify:${cellID}:cellBwpList:bwpDN=${bwp2}[${i}]|cellBwpId=2
        ...                 modify:${cellID}:actPowerSavingBWP=${actPowerSavingBWP}
        ...                 modify:${cellID}:bwpChBwPowerSaving=${bwpChBwPowerSaving}[${i}]

    END

    myKw Update actTddCsirsAllocOptimization

    log   ${param_list}
    #Apply modifications / Reset
    scf.load_scf                    ${testLogPath}/scf_orig.xml
    scf.perform_scf_modification    modification_strings=${param_list}
    scf.save_scf                    file_path=${testLogPath}/scf_modif.xml
    scf.calculate_delta_scf         target_scf_path=${testLogPath}/scf_modif.xml
    ...        actual_scf_path=${testLogPath}/scf_orig.xml  delta_scf_path=${testLogPath}/scf_delta.xml
    ${all_modifs}                   Get File       ${testLogPath}/scf_delta.xml

    #on refait un commissioning pour prendre en compte le vendor file
    ${status}  run keyword and return status
    ...     coam.perform_commissioning	bts_id=0	scf_file=${testLogPath}/scf_modif.xml
    ...     skip_parameter_relation_errors=False	should_activate=True	timeout=600  connection=coam_admin
    run keyword if   not(${status})  run keywords
    ...  Append To File   ${resultFile}    \nCommissioning FAILED\n
    ...  AND     Fail   Commissioning FAILED

    wait until keyword succeeds             120s        30s         gnb_log.Start Collecting GNB Btslog
    ${nbCells}   evaluate  len(@{nrCellId})
    ${status}  run keyword and return status   wait until keyword succeeds             600s       60s
    ...    Verify that cells are onair with COAM CB007113      coam_admin    ${nbCells}
    run keyword if   not(${status})  run keywords
    ...  Append To File   ${resultFile}    \nActivation FAILED. Cells are NOT on air\n
    ...  AND     Fail   Activation  FAILED. Cells are NOT on air
    Sleep        10s
    OperatingSystem.Run  command=cp ${syslog_folder}/${syslog} ${testLogPath}/${syslog}
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=${testLogPath}
    #Run Keyword And Continue On Failure   Collect snapshot coam ext01             resultBaseDir=${testLogPath}

    Run Keyword And Continue On Failure
    ...        myKw Check actTddCsirsAllocOptimization activation    ${actTddCsirsAllocOptimization}


Compare value with current configuration
    [Arguments]  ${xml_root}  ${dist_name}  ${param_name}  ${param_value}
    ${xpath}=  set variable  //managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ${value}=  XML.Get Element Text  ${xml_root}  ${xpath}
    ${status}=  run keyword and return status  should be equal    ${param_value}   ${value}
    run keyword if   not(${status})  run keywords
    ...  Append To File   result.txt    ${dist_name}/${param_name} must be set to ${param_value}\n
    ...  AND  set test variable  ${testCheck}  testNotOK


myKw Set Frame Structure
    [Arguments]   ${nrCellId}    ${param_list}
    ${tddFrameParam}     convert to String      ${${frameStructure}_fs}
    ${tddFrameParam}     Replace String         ${tddFrameParam}           '    "
    ${tddFrameStructure}      Set Variable      ${nrCellId}:tddFrameStructure
    Append To List       ${param_list}   delete:${tddFrameStructure}
    Append To List       ${param_list}   add:${tddFrameStructure}
    Append To List       ${param_list}   add:${tddFrameStructure}:${tddFrameParam}
    RETURN  ${param_list}


myKw Set Interfering Frame Structure
    [Arguments]   ${nrCellId}    ${param_list}
    ${5GC001116_0_fs}      create dictionary
    ...     infFrameStructureType      tdLte
    ...     infGuardPeriodLength       4Symbols
    ...     infLteToNrFrameShift       0ms
    ...     infTdLteUlDlConfig         tdLteConfig2
    ...     infUlDlDataSlotRatio       1/4
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true

    ${5GC001116_3_fs}      create dictionary
    ...     infFrameStructureType      tdLte
    ...     infGuardPeriodLength       4Symbols
    ...     infLteToNrFrameShift       3ms
    ...     infTdLteUlDlConfig         tdLteConfig2
    ...     infUlDlDataSlotRatio       1/4
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true

    ${5GC001208_fs}      create dictionary
    ...     infFrameStructureType      semiStatic
    ...     infGuardPeriodLength       2Symbols
    ...     infUlDlDataSlotRatio       1/4
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true


    ${5GC001070_fs}      create dictionary
    ...     infFrameStructureType      semiStatic
    ...     infGuardPeriodLength       2Symbols
    ...     infUlDlDataSlotRatio       3/7
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true

    ${infTddFrameParam}     convert to String      ${${infTddFrameStructure}_fs}
    ${infTddFrameParam}     Replace String         ${infTddFrameParam}           '    "
    ${infTddFrameStructure}      Set Variable      ${nrCellId}:infTddFrameStructure
    Append To List       ${param_list}   delete:${infTddFrameStructure}
    Append To List       ${param_list}   add:${infTddFrameStructure}
    Append To List       ${param_list}   add:${infTddFrameStructure}:${infTddFrameParam}
    log to console       \ninfTddFrameStructure : ${infTddFrameStructure}
    log to console       \ninfTddFrameParam: ${infTddFrameParam}


myKw Create ChannelGroup
#On delete pour chaque cell, les infos CHANNELGROUP et on les ajoute.
    [Documentation]
    ...  On delete, pour chaque cell, les infos CHANNELGROUP avant de les creer avec la config target.
    ...  Il n'y a aucun check sur la configuration courante. On delete sans verifier la target.
    ...  Limitation: 4DL4UL / 8DL8UL
    [Arguments]   ${param_list}
    scf.load_scf                    ${testLogPath}/scf_orig.xml
    ${nrbts_version}        scf.get_mo_attribute        ${mrbts}/MNL-1       version
    FOR     ${cellID}   IN  @{nrCellId}
        ${param_list}  myKw Delete Current Cell ChannelGroup  ${param_list}  ${cellID}
        ${ix}    get Index from list   ${nrCellId}        ${cellID}
        ${i}    evaluate    "${cellID}".split('-')[-1]
        ${chanResourceDN}   scf.get_value_from_scf
        ...  dist_name=${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${i}/CHANNELGROUP-1/CHANNEL-1      p_name=resourceDN
        myKw Create Channels in ChannelGroup   ${param_list}  ${cellID}  1  ${chanResourceDN}  ${nrbts_version}
        run keyword if     '${nrCellType}[${ix}]' == '8DL8UL'
        ...  myKw Create Channels in ChannelGroup   ${param_list}  ${cellID}  2  ${chanResourceDN}  ${nrbts_version}
    END
    RETURN  ${param_list}


myKw Delete Current Cell ChannelGroup
    [Arguments]   ${param_list}  ${cellId}
    ${result}   scf.get_all_dist_names_by_pattern   ${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellId}/CHANNELGROUP
    FOR   ${dName}   IN   @{result}
        Append To List       ${param_list}   delete:${dName}
    END
    RETURN  ${param_list}


myKw Create Channels in ChannelGroup
    [Arguments]   ${param_list}   ${cellId}  ${chanGrp}   ${chanResourceDN}  ${nrbts_version}

    ${cmd}    CATENATE    SEPARATOR=
    ...    add:[com.nokia.srbts.mnl:CHANNELGROUP, ${mrbts}/
    ...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellId}/CHANNELGROUP-${chanGrp}, ${nrbts_version}, create]

    Append To List
    ...    ${param_list}
    ...    ${cmd}

    FOR  ${j}  IN RANGE  4
            ${channelId}    evaluate   ${j} + 1
            ${channel_txt}      Set Variable    ${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellId}/CHANNELGROUP-${chanGrp}/CHANNEL-${channelId}
            Append To List      ${param_list}   add:[com.nokia.srbts.mnl:CHANNEL, ${channel_txt}, ${nrbts_version}, create]
            Append To List      ${param_list}   add:${channel_txt}:direction=TX
            Append To List      ${param_list}   add:${channel_txt}:resourceDN=${chanResourceDN}
            ${channelId}    evaluate   ${j} + 5
            ${channel_txt}      Set Variable    ${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellId}/CHANNELGROUP-${chanGrp}/CHANNEL-${channelId}
            Append To List      ${param_list}   add:[com.nokia.srbts.mnl:CHANNEL, ${channel_txt}, ${nrbts_version}, create]
            Append To List      ${param_list}   add:${channel_txt}:direction=RX
            Append To List      ${param_list}   add:${channel_txt}:resourceDN=${chanResourceDN}
    END
    RETURN  ${param_list}


myKw Log config in result file
    Append To File   ${resultFile}   \nactBbPoolTddFr1 (CB008940): ${actBbPoolTddFr1}
    Append To File   ${resultFile}   \nactBbPoolExtensionTddFr1 (CB010513): ${actBbPoolExtensionTddFr1}
    Append To File   ${resultFile}   \nactBbPoolTddFr1AlgEnh: ${actBbPoolTddFr1AlgEnh}
    Append To File   ${resultFile}   \nactExplicitCsirsPoolSolution: ${actExplicitCsirsPoolSolution}
    Append To File   ${resultFile}   \nactBbPoolTddFr1Enh (CB011028): ${actBbPoolTddFr1Enh}
    Append To File   ${resultFile}   \nactTddCsirsAllocOptimization (CB009836): ${actTddCsirsAllocOptimization}
    Append To File   ${resultFile}   \nactTddCsirsOpt (CB012265): ${actTddCsirsOpt}
    Append To File   ${resultFile}   \nFrame structure: ${frameStructure}
    Append To File   ${resultFile}   \nBeamset: @{beamSet}
    Append To File   ${resultFile}   \ncsiReportPeriodicity: @{csiReportPeriodicity}
    Append To File   ${resultFile}   \ndlMimoMode @{dlMimoMode}
    Append To File   ${resultFile}   \nnrCellType @{nrCellType}
    Append To File   ${resultFile}   \nchBw @{chBw}
    #Append To File   ${resultFile}   \ncSRS @{cSRS}
    Append To File   ${resultFile}   \nactUeCsirsCoexistCellCsirs ${actUeCsirsCoexistCellCsirs}
    Append To File   ${resultFile}   \nactCsirsBeamPowerBalance ${actCsirsBeamPowerBalance}
    Append To File   ${resultFile}   \ncsirsNbWithinReportPeriod_Set1 @{csirsNbWithinReportPeriod_Set1}
    Append To File   ${resultFile}   \nmaxCsirsNumber @{maxCsirsNumber}

myKw Log config in result file CB12605
    [Arguments]   ${scf}=${testLogPath}/scf_orig.xml
    scf.Load Scf    ${scf}
    ${actBbPoolTddFr1}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+        p_name=actBbPoolTddFr1
    Append To File   ${resultFile}   \nactBbPoolTddFr1 (CB008940): ${actBbPoolTddFr1}
    ${actBbPoolExtensionTddFr1}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+        p_name=actBbPoolExtensionTddFr1
    Append To File   ${resultFile}   \nactBbPoolExtensionTddFr1 (CB010513): ${actBbPoolExtensionTddFr1}
    ${actBbPoolTddFr1AlgEnh}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+        p_name=actBbPoolTddFr1AlgEnh
    Append To File   ${resultFile}   \nactBbPoolTddFr1AlgEnh: ${actBbPoolTddFr1AlgEnh}
    ${actExplicitCsirsPoolSolution}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+    p_name=actExplicitCsirsPoolSolution
    Append To File   ${resultFile}   \nactExplicitCsirsPoolSolution: ${actExplicitCsirsPoolSolution}
    ${actBbPoolTddFr1Enh}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+        p_name=actBbPoolTddFr1Enh
    Append To File   ${resultFile}   \nactBbPoolTddFr1Enh (CB011028): ${actBbPoolTddFr1Enh}
    ${actTddCsirsAllocOptimization}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+    p_name=actTddCsirsAllocOptimization
    Append To File   ${resultFile}   \nactTddCsirsAllocOptimization (CB009836): ${actTddCsirsAllocOptimization}
    ${actTddCsirsOpt}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRBTS-\\d+        p_name=actTddCsirsOpt
    Append To File   ${resultFile}   \nactTddCsirsOpt (CB012265): ${actTddCsirsOpt}
    ${frameStructure}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        list_name=frameStructure
    Append To File   ${resultFile}   \nFrame structure: ${frameStructure}
    ${beamSet}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=beamSet
    Append To File   ${resultFile}   \nBeamset: @{beamSet}
    ${csiReportPeriodicity}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=csiReportPeriodicity
    Append To File   ${resultFile}   \ncsiReportPeriodicity: @{csiReportPeriodicity}
    ${dlMimoMode}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=dlMimoMode
    Append To File   ${resultFile}   \ndlMimoMode @{dlMimoMode}
    ${nrCellType}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=nrCellType
    Append To File   ${resultFile}   \nnrCellType @{nrCellType}
    ${chBw}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=chBw
    Append To File   ${resultFile}   \nchBw @{chBw}
    #Append To File   ${resultFile}   \ncSRS @{cSRS}
    ${actUeCsirsCoexistCellCsirs}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=actUeCsirsCoexistCellCsirs
    Append To File   ${resultFile}   \nactUeCsirsCoexistCellCsirs ${actUeCsirsCoexistCellCsirs}
    ${actCsirsBeamPowerBalance}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=actCsirsBeamPowerBalance
    Append To File   ${resultFile}   \nactCsirsBeamPowerBalance ${actCsirsBeamPowerBalance}
    ${csirsNbWithinReportPeriod_Set1}    scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+     p_name=csirsNbWithinReportPeriod_Set1
    Append To File   ${resultFile}   \ncsirsNbWithinReportPeriod_Set1 @{csirsNbWithinReportPeriod_Set1}
    ${maxCsirsNumber}        scf.get_all_values_from_scf_by_pattern    dist_name=.*NRCELL-\\d+        p_name=maxCsirsNumber
    Append To File   ${resultFile}   \nmaxCsirsNumber @{maxCsirsNumber}

myKw Check TRS CSI-RS allocation
    ${output}       Get filtered message from syslog  ${testLogPath}/${syslog}
    ...        -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'
    ${csirsGroups}  extract csirsPoolingGroupId from syslog     ${output}
    log   ${csirsGroups}
    ${nrCellGroups}     extract nrCellGrpId from syslog     ${output}
    log   ${nrCellGroups}
    ${output}       Get filtered message from syslog   ${testLogPath}/${syslog}
    ...        -e l2::ps::cell::CellGroupSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellGroupSetupReq:'
    ${trscsirs}     extract trscsirs from syslog     ${output}      ${csirsGroups}      ${nrCellGroups}
    Log    ${trscsirs}
    ${expectedtrsCsiRs}   createTrsCsiRs  ${frameStructure}  ${beams}[0]   ${actBbPoolTddFr1}  ${actExplicitCsirsPoolSolution}
    Log    ${expectedtrsCsiRs}

    ${status1}  evaluate
    ...    len(${trscsirs}) == len(${expectedtrsCsiRs}) and len(set([a['csirsPoolingGroupId'] for a in ${csirsGroups}])) == len(${expectedtrsCsiRs})
    ${status2}  run keyword and return status  Lists Should Be Equal     ${trscsirs}        ${expectedtrsCsiRs}
    run keyword if    not(${status1})   run keywords
    ...  Append To File  ${resultFile}     \nTRS CSI-RS allocation: MISSING Info in SYSLOG\n
    ...  AND  Run Keyword And Continue On Failure   Fail   TRS CSI-RS allocation: MISSING Info in SYSLOG
    ...  ELSE   run keyword if   not(${status2})  run keywords
    ...  Append To File  ${resultFile}     \nWRONG TRS CSI-RS allocation\n
    ...  AND  Run Keyword And Continue On Failure   Fail   WRONG TRS CSI-RS allocation
    ...  ELSE   Append To File   ${resultFile}    \nCheck TRS CSI-RS assignment --> PASSED\n


myKw Check TRS CSI-RS allocation v2
    #Update pour myKw Main test 3 + si le SYSLOG n est pas complet on met a jour ${lockRequired} pour trigger cell setup
    ${output}   Get filtered message from syslog  ${testLogPath}/${syslog}
    ...   -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'
    ${csirsGroups}     extract csirsPoolingGroupId from syslog     ${output}
    log   ${csirsGroups}
    ${nrCellGroups}    extract_nrCellGrpId_from_syslog     ${output}
    log   ${nrCellGroups}
    ${output}       Get filtered message from syslog   ${testLogPath}/${syslog}
    ...  -e l2::ps::cell::CellGroupSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellGroupSetupReq:'
    ${trscsirs}     extract_trscsirs_from_syslog     ${output}      ${csirsGroups}      ${nrCellGroups}
    Log    ${trscsirs}
    ${expectedtrsCsiRs}   createTrsCsiRs     ${frameStructure}  ${beams}[0]  ${actBbPoolTddFr1}   ${actExplicitCsirsPoolSolution}
    ...  actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    Log    ${expectedtrsCsiRs}

    ${status1}  evaluate
    ...  len(${trscsirs}) == len(${expectedtrsCsiRs}) and len(set([a['csirsPoolingGroupId'] for a in ${csirsGroups}])) == len(${expectedtrsCsiRs})
    ${status2}  run keyword and return status  Lists Should Be Equal     ${trscsirs}        ${expectedtrsCsiRs}
    run keyword if    not(${status1})   run keywords
    ...  Append To File  ${resultFile}     \nTRS CSI-RS allocation: MISSING Info in SYSLOG\n
    ...  AND  set test variable   ${lockRequired}   Yes
    ...  ELSE   run keyword if   not(${status2})  run keywords
    ...  Append To File  ${resultFile}     \nWRONG TRS CSI-RS allocation\n
    ...  AND  Run Keyword And Continue On Failure   Fail   WRONG TRS CSI-RS allocation
    ...  ELSE   run keywords   Append To File   ${resultFile}    \nCheck TRS CSI-RS assignment --> PASSED\n
    ...  AND   writeCsiRsConfigTrs   ${csiRsFile}      ${expectedtrsCsiRs}

myKw Trigger Cell Setup
    ${nbCheck}   evaluate   ${nbCheck} + 1
    set test variable  ${nbCheck}
    set test variable   ${lockRequired}   No
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/${syslog}_sav${nbCheck}
    FOR  ${cellID}  IN   @{nrCellId}
            coam.lock   ${cellID}   timeout=60  connection=coam_admin
    END
    sleep   30s
    gnb_log.Start Collecting GNB Btslog
    FOR  ${cellID}  IN   @{nrCellId}
            coam.unlock   ${cellID}   timeout=60  connection=coam_admin
    END
    ${nbCells}   evaluate  len(@{nrCellId})
    ${status}  run keyword and return status   wait until keyword succeeds    600s       60s
    ...  Verify that cells are onair with COAM CB007113      coam_admin    ${nbCells}
    OperatingSystem.Run  command=cp ${syslog_folder}/${syslog} ${testLogPath}/${syslog}
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=${testLogPath}


myKw Check cell specific CSI-RS allocation
    ${output}   Get filtered message from syslog  ${testLogPath}/${syslog}
    ...   -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'
    ${csirsGroups}     extract_csirsPoolingGroupId_from_syslog_v2     ${output}
    log   ${csirsGroups}
    ${output}   Get filtered message from syslog  ${testLogPath}/${syslog}
    ...   -e l2::ps::cell::CellSetupResp_t: -e 'Received from L2PS itf::l2::ps::cell::CellSetupResp:'
    ${cellcsirs}     extract_cellcsirs_from_syslog_cell     ${output}       ${csirsGroups}
    Log    ${cellcsirs}

    ${res1}  evaluate  len(set([a['csirsPoolingGroupId'] for a in ${csirsGroups}])) == ${nbCellCsiRsGrp}
    ${res2}  evaluate   len(${cellcsirs}) == len(${nrCellId})
    ${status}   evaluate
    ...  len(set([a['csirsPoolingGroupId'] for a in ${csirsGroups}])) == ${nbCellCsiRsGrp} and len(${cellcsirs}) == len(${nrCellId})
    run keyword if  not(${status})  run keywords
    ...  Append To File  ${resultFile}     \nCell CSI-RS allocation: MISSING Info in SYSLOG\n
    ...  AND  set test variable   ${lockRequired}   Yes
    ...  ELSE   myKw Check cell specific CSI-RS allocation sub 1    ${csirsGroups}  ${cellcsirs}

myKw Check cell specific CSI-RS allocation v2
    #Update pour myKw Main test 3 + si le SYSLOG n est pas complet on met a jour ${lockRequired} pour trigger cell setup
    ${output}   Get filtered message from syslog  ${testLogPath}/${syslog}
    ...  -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'
    ${csirsGroups}     extract_csirsPoolingGroupId_from_syslog_v2     ${output}
    log   ${csirsGroups}
    ${output}   Get filtered message from syslog  ${testLogPath}/${syslog}
    ...  -e l2::ps::cell::CellSetupResp_t: -e 'Received from L2PS itf::l2::ps::cell::CellSetupResp:'
    ${cellcsirs}     extract_cellcsirs_from_syslog_cell     ${output}       ${csirsGroups}
    Log    ${cellcsirs}

    ${res1}  evaluate  len(set([a['csirsPoolingGroupId'] for a in ${csirsGroups}])) == ${nbCellCsiRsGrp}
    ${res2}  evaluate   len(${cellcsirs}) == len(${nrCellId})
    ${status}   evaluate
    ...  len(set([a['csirsPoolingGroupId'] for a in ${csirsGroups}])) == ${nbCellCsiRsGrp} and len(${cellcsirs}) == len(${nrCellId})
    run keyword if  not(${status})  run keywords
    ...  Append To File  ${resultFile}     \nCell CSI-RS allocation: MISSING Info in SYSLOG\n
    ...  AND  set test variable   ${lockRequired}   Yes
    ...  ELSE   myKw Check cell specific CSI-RS allocation sub 1    ${csirsGroups}  ${cellcsirs}

myKw Check errors in Syslog
    ${cmd}    CATENATE    SEPARATOR=
    ...  command=cat ${testLogPath}/${syslog} |
    ...  grep -i -e ERR/L2-PS/ -e ERR/.uplane/L2-PS/ -e WRN/L2-PS/ -e ERR/l1_application_rt/ -e ERR/.uplane/l1_application_rt/
    ...  -e WRN/l1_application_rt/ -e ERR/l1_application_nrt/ -e ERR/.uplane/l1_application_nrt/ -e WRN/l1_application_nrt/

    ${output}   OperatingSystem.Run        ${cmd}
    ${ErrorsCount}        Get Count        ${output}        ERR/
    ${warningsCount}    Get Count        ${output}        WRN/
    Append To File  ${resultFile}     \nErrors in syslog: ${ErrorsCount}\n
    Append To File  ${resultFile}     \nWarnings in syslog: ${warningsCount}\n
    RETURN      ${output}

myKw Check cell specific CSI-RS allocation sub 1
    [Arguments]  ${csirsGroups}  ${cellcsirs}
    Append To File   ${csiRsFile}    \n\n***********************\nCell Specific Config\n***********************\n
    ${expectedCellCsiRs}   createCellCsiRs_v3   ${csiRsFile}  ${frameStructure}   ${actCsirsMultiplexing}
    ...   ${actExplicitCsirsPoolSolution}   ${csiReportPeriodicity}
    ...   ${csirsNbWithinReportPeriod_Set1}    ${maxCsiRsNumber}   ${csirsGroups}   ${nrCellId}
    ...   ${actTddCsirsAllocOptimization}  ${actInfTddFrameMuting}
    Log    ${expectedCellCsiRs}
    ${status}  run keyword and return status   Lists Should Be Equal     ${cellcsirs}        ${expectedCellCsiRs}
    run keyword if   not(${status})  run keywords
    ...  Append To File   ${resultFile}    \nWRONG Cell Specific CSI-RS allocation\n
    ...  AND  Run Keyword And Continue On Failure   Fail   WRONG Cell Specific CSI-RS allocation
    ...  ELSE   run keywords    Append To File   ${resultFile}   \nCheck cell specific CSI-RS assignment --> PASSED\n
    ...  AND   writeCsiRsConfigCellSpe   ${csiRsFile}      ${expectedCellCsiRs}   ${csirsGroups}

MyKw Launch UE part
    #Reserve UE + Attach UE
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 1  ${ue}
    END
    #Start transfert
    FOR   ${ue}   IN   @{ueList}
        ${status}        run keyword and return status   MyKw Launch UE part sub 2  ${ue}  dl=${dl}  ul=${ul}  ngbr=${ngbr}  gbr=${gbr}
        Run Keyword If    ${status}    Log To Console    \nTraffic launched on UE ${ue}
    END

MyKw Launch UE part One UE PC

    run keyword and continue on failure   MyKw Launch Start Proxy and ADB    ${ueList}[0]

    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE call  ${ue}
        Set Airplane Mode Off And Enable Data     ${ueList}[0]
    END
    FOR   ${ue}   IN   @{ueList}
                run keyword and continue on failure   MyKw Launch UE part sub 2  ${ue}  dl=${dl}  ul=${ul}  ngbr=${ngbr}  gbr=${gbr}
    END

MyKw Launch UE part for counters
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 1  ${ue}
    END
    wait for next measurement interval   additional-waiting-time=1s   is_reduce_waiting-time=false
    ${start_time}       Get Time        epoch
    ${MeasPeriodToCheck}        Evaluate    (${start_time}//300)*300
    ${MeasPeriodToCheck}    convert to string   ${MeasPeriodToCheck}
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 2  ${ue}
    END
    sleep   10s
    myTTI v1
    wait for next measurement interval  additional-waiting-time=30s   is_reduce_waiting-time=false
    ${countersData}  coam.get_counters_info  connection=coam_admin  timeout=3min   dist_name=BTS/${mrbts}/${nrbts}
    ${countersExtract}   myFnGetNrCellCounter  ${countersData}  ${mrbts}  ${nrbts}  ${nrCellId}  NCELA  ${counterstocheck}  ${MeasPeriodToCheck}
    FOR  ${counters}  IN  @{countersDesc}
         Append To File   ${resultFile}   \n${counters}
    END
    Append To File   ${resultFile}   \n
    FOR  ${cellId}  IN  @{nrCellId}
        append to file   ${resultFile}   \n${cellId}\n
        myKw Counter check negative values   ${cellID}    ${countersExtract}
        myKw Counter check zero values   ${cellId}    ${countersExtract}
        myKw Counter validation  ${cellId}    ${countersExtract}
    END

MyKw Launch UE part sub 1
    [Arguments]  ${ue}
#    Kill Python On PC UE   ${ue}
#    sleep       4s
    Start ue proxy socketIO    ${ue}
    sleep       10s
    Set ADB ROOT in UE  ${ue}
    sleep       2s

    Run Keyword And Continue On Failure      ue.require_ue      ue_alias=${alias_${ue}}      capabilities=${capabilities_${ue}}
    sleep       2s
    Set Airplane Mode Off And Enable Data     ${ue}
    sleep       3s
#    Run keyword and ignore error  ue.detach_ue    ue_alias=${alias_${ue}}
    Wait until keyword succeeds  120s  30s  ue.attach_ue      ue_alias=${alias_${ue}}

MyKw Launch Start Proxy and ADB
    [Arguments]  ${ue}
    Kill ue_proxy On PC UE   ${ue}
    sleep       4s
    Start ue proxy socketIO    ${ue}
    sleep       5s
    Set ADB ROOT in UE  ${ue}
    sleep       4s


MyKw Launch UE call
    [Arguments]  ${ue}
    Wait until keyword succeeds  120s  30s  ue.require_ue      ue_alias=${alias_${ue}}      capabilities=${capabilities_${ue}}
    sleep       2s
    Wait until keyword succeeds  120s  30s   ue.attach_ue       ue_alias=${alias_${ue}}


MyKw Launch UE call loop
    FOR   ${ue}   IN   @{ueList}
        Run keyword and ignore error  ue.detach_ue    ue_alias=${alias_${ue}}
        Wait until keyword succeeds  120s  30s  ue.attach_ue      ue_alias=${alias_${ue}}
        Wait until keyword succeeds  120s  30s
        ...    ue.Start Data Transfer  dt_name=dt_UE_${ue}_dl   ue_alias=${alias_${ue}}   direction=dl   duration=${duration}
        ...    throughput=${dlTput['${ue}']} Mbits/sec   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    qci=${qci_dl}
    END

MyKw Stop UE call loop
    FOR   ${ue}   IN   @{ueList}
        Run keyword and ignore error    ue.Stop Data Transfer  dt_name=dt_UE_${ue}_dl
        Run keyword and ignore error    ue.detach_ue    ue_alias=${alias_${ue}}
    END

MyKw Get Tput loop
    FOR   ${ue}   IN   @{ueList}
        ${Thp_UE1}      ue.Get Average Throughput       dt_UE_${ue}_dl       omit=8
    END

Get Throughput
    [Arguments]  ${ue}
    ${thp_dl_ngbr}        Run keyword if  ${dl} and ${ngbr}    ue.Get Average Throughput   dt_UE_${ue}_dl       omit=8
    ${thp_dl_gbr}        Run keyword if  ${dl} and ${gbr}    ue.Get Average Throughput   dt_UE_${ue}_dl_gbr       omit=8
    ${thp_ul_ngbr}        Run keyword if  ${ul} and ${ngbr}    ue.Get Average Throughput   dt_UE_${ue}_ul       omit=8
    ${thp_ul_gbr}        Run keyword if  ${ul} and ${gbr}    ue.Get Average Throughput   dt_UE_${ue}_ul_gbr       omit=8
    ${thpt}    create dictionary    dl_ngbr=${thp_dl_ngbr}    dl_gbr=${thp_dl_gbr}    ul_ngbr=${thp_ul_ngbr}    ul_gbr=${thp_ul_gbr}
    RETURN  ${thpt}

MyKw Launch UE part sub 2
    [Arguments]  ${ue}      ${dl}=${TRUE}        ${ul}=${FALSE}        ${ngbr}=${TRUE}     ${gbr}=${FALSE}
#    Clear Naa Storage  ${alias_${ue}}
    Run keyword if  ${dl} and ${ngbr}
    ...     Wait until keyword succeeds  120s  5s
        ...    ue.Start Data Transfer  dt_name=dt_UE_${ue}_dl   ue_alias=${alias_${ue}}   direction=dl   duration=${duration}
        ...    throughput=${dlTput['${ue}']} Mbits/sec   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    qci=${qci_dl}
    Run keyword if  ${dl} and ${gbr}
    ...     Wait until keyword succeeds  120s  5s
        ...   ue.Start Data Transfer  dt_name=dt_UE_${ue}_dl_gbr   ue_alias=${alias_${ue}}   direction=dl   duration=${duration}
        ...    throughput=${dlTput['${ue}']} Mbits/sec   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    qci=3        port=${gbr_port}
    Run keyword if  ${ul} and ${ngbr}
    ...     Wait until keyword succeeds  120s  5s
        ...    ue.Start Data Transfer  dt_name=dt_UE_${ue}_ul   ue_alias=${alias_${ue}}   direction=ul   duration=${duration}
        ...    throughput=${ulTput['${ue}']} Mbits/sec   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    qci=9
    Run keyword if  ${ul} and ${gbr}
    ...     Wait until keyword succeeds  120s  5s          Launch UL GBR traffic        ue=${ue}        duration=${duration}
        ...    throughput=${ulTput['${ue}']}M   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    port=${ul_gbr_port}


myTTI
    myKw Launch and convert TTI    suffixe=${EMPTY}       duration=5
    ${ttiLog}   set variable   ${testLogPath}traceTTI.dlAndUl.csv
    ${file_exists}=  Run Keyword and Return Status    File Should Exist  ${ttiLog}
    ${ttiLog}  set variable if   not(${file_exists})    ${testLogPath}traceTTI_0.dlAndUl.csv
    ...   ${testLogPath}traceTTI.dlAndUl.csv
    set test variable  ${checkTput}  tputOK
    ${stats}       Run Keyword And Continue On Failure        parse_dl   ${ttiLog}
    append to file  ${resultFile}   \nTput:\n
    FOR   ${key}  IN  @{stats.keys()}
        log  ${stats["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats["${key}"]}[0] Mbps Bler: ${stats["${key}"]}[1]% MCS: ${stats["${key}"]}[2]\n
        ${status}   evaluate   ${stats["${key}"]}[0] > 200
        run keyword if   not(${status})  run keywords
        ...  Append To File   ${resultFile}    Tput too low\n
        ...  AND  set test variable  ${checkTput}  tputNotOK
    END
    run keyword if  '${checkTput}' == 'tputNotOK'  Run Keyword And Continue On Failure  fail   \nTput too low

myTTI v1
    #Ajoute variabl ${suffixe} pour gestion du nom du fichier
    #Ajout variable ${expectedDlTput} pour mini Tput par cell
    #Renvoi stats
    [Arguments]   ${suffixe}=${EMPTY}       ${duration}=${5}
    myKw Launch and convert TTI     ${suffixe}      ${duration}
    ${ttiLog}   set variable   ${testLogPath}traceTTI${suffixe}.dlAndUl.csv
    ${file_exists}=  Run Keyword and Return Status    File Should Exist  ${ttiLog}
    ${ttiLog}  set variable if   not(${file_exists})    ${testLogPath}traceTTI${suffixe}_0.dlAndUl.csv
    ...   ${testLogPath}traceTTI${suffixe}.dlAndUl.csv
    set test variable   ${ttiLog}   ${ttiLog}   #pour avoir depuis d autre kw
    set test variable  ${checkTput}  tputOK

    ${stats}       Run Keyword And Continue On Failure        parse_dl   ${ttiLog}
    append to file  ${resultFile}   \nTput:\n
    FOR   ${key}  IN  @{stats.keys()}
        log  ${stats["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats["${key}"]}[0] Mbps Bler: ${stats["${key}"]}[1]% MCS: ${stats["${key}"]}[2]\n
        ${status}   evaluate   ${stats["${key}"]}[0] > ${expectedDlTput['${ueMapping["${key}"]}']}
        run keyword if   not(${status})  run keywords
        ...  Append To File   ${resultFile}    Tput too low\n
        ...  AND  set test variable  ${checkTput}  tputNotOK
    END
    ${status}  evaluate  len(${stats}) == len(@{nrCellId})
    run keyword if  not(${status})  Run Keyword And Continue On Failure  fail   \nMissing cell data in TTI trace

    run keyword if  '${actUeCsirsCoexistCellCsirs}' == 'false'  Run Keyword And Continue On Failure  MyKw CheckMaxRs
    run keyword if  '${checkTput}' == 'tputNotOK'  Run Keyword And Continue On Failure  fail   \nTput too low
    RETURN  ${stats}



myTTI w Syslog
    [Arguments]   ${suffixe}=${EMPTY}       ${duration}=${2}        ${snapshot}=${False}

    gnb_log.Start Collecting GNB Btslog

    myKw Launch and convert TTI     ${suffixe}      ${duration}
    OperatingSystem.Run  command=cp ${syslog_folder}/${syslog} ${testLogPath}/SYSLOG_CALL${suffixe}.LOG
    Run Keyword If      ${snapshot}      coam.collect snapshot      target_file_name=${testLogPath}/snapshot${suffixe}.zip    connection=coam_admin
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=${testLogPath}
    ${ttiLog}   set variable   ${testLogPath}traceTTI${suffixe}.dlAndUl.csv
    ${file_exists}=  Run Keyword and Return Status    File Should Exist  ${ttiLog}
    ${ttiLog}  set variable if   not(${file_exists})    ${testLogPath}traceTTI${suffixe}_0.dlAndUl.csv
    ...   ${testLogPath}traceTTI${suffixe}.dlAndUl.csv
    set test variable   ${ttiLog}   ${ttiLog}   #pour avoir depuis d autre kw
    set test variable  ${checkTput}  tputOK

    ${stats}       Run Keyword And Continue On Failure        parse_dl   ${ttiLog}
    append to file  ${resultFile}   \nTput:\n
    FOR   ${key}  IN  @{stats.keys()}
        log  ${stats["${key}"]}[0]
        append to file  ${resultFile}
        ...   PCI ${key}: ${stats["${key}"]}[0] Mbps Bler: ${stats["${key}"]}[1]% MCS: ${stats["${key}"]}[2]\n
        ${status}   evaluate   ${stats["${key}"]}[0] > ${expectedDlTput['${ueMapping["${key}"]}']}
        run keyword if   not(${status})  run keywords
        ...  Append To File   ${resultFile}    Tput too low\n
        ...  AND  set test variable  ${checkTput}  tputNotOK
    END
    ${status}  evaluate  len(${stats}) == len(@{nrCellId})
    run keyword if  not(${status})  Run Keyword And Continue On Failure  fail   \nMissing cell data in TTI trace

#    run keyword if  '${actUeCsirsCoexistCellCsirs}' == 'false'  Run Keyword And Continue On Failure  MyKw CheckMaxRs
    run keyword if  '${checkTput}' == 'tputNotOK'  Run Keyword And Continue On Failure  fail   \nTput too low
#    ${stats_ul}       Run Keyword And Continue On Failure        parse_ul   ${ttiLog}
    RETURN  ${stats}

myKw PRB check
    #Create an excel file with PRB statistics and check if the PRB usage matches algorithm
    [Arguments]   ${suffixe}=${EMPTY}       ${syslog_folder}=${testLogPath}       ${syslogFile}=${syslog}
    ${file_exists}=  Run Keyword and Return Status    File Should Exist  ${testLogPath}traceTTI${suffixe}.dlAndUl.csv
    ${ttiLog}  set variable if   not(${file_exists})    ${testLogPath}traceTTI${suffixe}_0.dlAndUl.csv
    ...   ${testLogPath}traceTTI${suffixe}.dlAndUl.csv
    ${ExcelFile}        ${DlErrors}     ${UlErrors}        ${ZabErrors}
    ...     Create_Excel_Charts_from_TTI       tti_csv=${ttiLog}        tl=${tl}
    ...     dl=True     ul=True     syslog=${syslog_folder}/${syslogFile}     scf_file=${syslog_folder}/scf_modif.xml
    ...    cb012605=${cb012605}
    ${CheckAlgo}        Evaluate    ${DlErrors} > 0 or ${UlErrors} > 0
    ${CheckZab}        Evaluate    ${ZabErrors} > 0
    Run Keyword If      ${CheckAlgo}        Append To File   ${resultFile}    \nCheck PRB assignment --> FAILED\n
        ...  ELSE   Append To File   ${resultFile}    \nCheck PRB assignment --> PASSED\n
    Run Keyword If      ${CheckZab}        Append To File   ${resultFile}    \nCheck ZAB assignment --> FAILED\n
        ...  ELSE   Append To File   ${resultFile}    \nCheck ZAB assignment --> PASSED\n
    Run Keyword If      ${CheckAlgo}        Run Keyword And Continue On Failure     fail
    ...    \nPRB assignment does not match algorithm: ${DlErrors} DL errors, ${UlErrors} UL errors
    Run Keyword If      ${CheckZab}        Run Keyword And Continue On Failure     fail
    ...    \nZAB assignment does not match algorithm: ${ZabErrors} errors
#    Check PRB Assignment CB008940
#    ...       ${TTI_Convert}        ${dll1spcells}      ${dlstreams}        ${MaxSpPRBdl}
#    Check PRB Assignment CB007113
#    ...      ${TTI_Convert}        ${ull1spcells}      ${ulstreams}        ${MaxSpPRBul}



myKw Counter check negative values
    [Arguments]   ${nrcell}     ${countersExtract}
    append to file   ${resultFile}   \n\tCounter check: negative values\n
    FOR   ${counter}   IN    @{counterstocheck}
        ${status}   evaluate    ${countersExtract}[${nrcell}][${counter}] >= 0
        run keyword if   ${status}   append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) OK\n
        ...  ELSE  run keywords   Run Keyword And Continue On Failure  fail   \nCounter check failed: Negative value for ${counter}  AND
        ...  append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) not OK\n
    END

myKw Counter check zero values
    [Arguments]   ${nrcell}     ${countersExtract}
    append to file   ${resultFile}      \n\tCounter check: zero values\n
    FOR   ${counter}   IN    @{counterstocheck}
        ${status}   evaluate    ${countersExtract}[${nrcell}][${counter}] == 0
        run keyword if   not(${status})   append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) OK\n
        ...  ELSE  run keywords   Run Keyword And Continue On Failure  fail   \nCounter check failed: Zero value for ${counter}  AND
        ...  append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) not OK\n
    END

myKw Counter validation
    [Arguments]   ${nrcell}     ${countersExtract}
    append to file   ${resultFile}      \n\tCounter check: M55308C10005 <= M55308C10003
    ${status}   evaluate    ${countersExtract}[${nrcell}][M55308C10005] <= ${countersExtract}[${nrcell}][M55308C10003]
    run keyword if   ${status}   append to file   ${resultFile}
    ...   \tOK\n\t\tM55308C10005: ${countersExtract}[${nrcell}][M55308C10005], M55308C10003: ${countersExtract}[${nrcell}][M55308C10003]\n
        ...  ELSE  run keywords   Run Keyword And Continue On Failure  fail   \nCounter check failed: M55308C10005 <= M55308C10003  AND
        ...  append to file   ${resultFile}
        ...  \tnot OK\n\t\tM55308C10005: ${countersExtract}[${nrcell}][M55308C10005]\n\t\tM55308C10003: ${countersExtract}[${nrcell}][M55308C10003]\n

myKw Check actTddCsirsAllocOptimization activation
    [Arguments]   ${flag}
    ${output}=  OperatingSystem.Run
    ...    command=cat ${testLogPath}/${syslog} | grep -E 'actTddCsirsAllocOptimization\"?\:${flag}'
    ${len}    Get length  ${output}
    run keyword if    ${len} == 0   run keywords
    ...   log to console   \nactTddCsirsAllocOptimization not correctly set in cell setup message\n
    ...   AND  Fail   actTddCsirsAllocOptimization not correctly set in cell setup message\

myKw Activate cb012605 in vendor file
    [Arguments]   ${argumentsList}=${EMPTY}        ${scf}=${testLogPath}/scf_orig.xml
    ${vendor}     coam.download_vendor_file       target_file_name=${testLogPath}/vendor.xml    connection=coam_admin
    ${vendor_file_parsed}       Parse xml       ${testLogPath}/vendor.xml
    ${xpath}    set variable   .//managedObject[@class='NRBTS']//p[@name='actBbPoolingTddFr1Ecpri72e']
    ${vendor_file_parsed}       Set Element Text       source=${vendor_file_parsed}   text=true     xpath=${xpath}
    ${xpath}    set variable   .//managedObject[@class='NRBTS']//p[@name='actEcpri72e']
    ${vendor_file_parsed}       Set Element Text       source=${vendor_file_parsed}   text=disabled     xpath=${xpath}
    FOR     ${item}     IN  @{argumentsList}
            ${vendor_file_parsed}       Add Items To Vendor File        ${vendor_file_parsed}       ${item}
    END
    Save Xml        source=${vendor_file_parsed}         path=${testLogPath}/vendor_modif.xml
    coam.set_vendor_file    vendor_file=${testLogPath}/vendor_modif.xml   connection=coam_admin
    ${status}  run keyword and return status  coam.perform_commissioning	 bts_id=0	 scf_file=${scf}
    ...     skip_parameter_relation_errors=True     should_activate=True 	timeout=600   connection=coam_admin


myKw Update actTddCsirsAllocOptimization
    ${vendor}     coam.download_vendor_file       target_file_name=/tmp/vendor.xml    connection=coam_admin
    ${vendor_file_parsed}       Parse xml       /tmp/vendor.xml
    ${xpath}    set variable   .//managedObject[@class='NRBTS']//p[@name='actTddCsirsAllocOptimization']
    ${vendor_file_parsed}       Set Element Text       source=${vendor_file_parsed}   text=${actTddCsirsAllocOptimization}     xpath=${xpath}
    Save Xml        source=${vendor_file_parsed}         path=/tmp/vendor_modif.xml
    coam.set_vendor_file    vendor_file=/tmp/vendor_modif.xml   connection=coam_admin

myKw Upgrade gNB
    ${softVersion}        coam.Get SW version   connection=coam_admin
    #${softVersion}        testline.Get gNB SW version
    Append To File   ${resultFile}   Current Software: ${softVersion}\n
    Append To File   ${resultFile}   Target Software: ${targetVersion}\n

    ${str1}   remove string using regexp    ${targetVersion}   .*_ENB
    ${str2}   remove string using regexp    ${softVersion}   .*_ENB
    ${status}  run keyword and return status    should be equal   ${str1}  ${str2}
    #${status}  run keyword and return status    should be equal   ${softVersion}  ${targetVersion}
    run keyword if   ${status}  run keywords
    ...  Append To File   ${resultFile}    \nSoftware already installed\n
    ...  AND   Pass execution  Software already installed

    ${sw_package_path}=  Set Variable  /5gswload/SBTS00_TRUNK/${targetVersion}_release_BTSSM_downloadable_A54.zip
    ${file_not_exist}  Run keyword and return status  File Should Not Exist  ${sw_package_path}
    ${sw_package_path}  Run Keyword If  ${file_not_exist}  Download SW Package  sw_version=${targetVersion}
    ...                                                                         target_dir=/5gswload/SBTS00_TRUNK/
    ...                 ELSE                               Set Variable  ${sw_package_path}
    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=2700
    sleep  180s
    wait until keyword succeeds  600s   60s    Verify that cells are onair with COAM CB007113      coam_admin      3
#    ${softVersion3}        testline.Get gNB SW version
    ${softVersion}        coam.Get SW version   connection=coam_admin
    ${str2}   remove string using regexp    ${softVersion}   .*_ENB
    ${status}  run keyword and return status    should be equal   ${str1}  ${str2}
#    ${status}  run keyword and return status    should be equal   ${softVersion3}  ${targetVersion}
    run keyword if   not(${status})  run keywords
    ...  Append To File   ${resultFile}    \nUpgrade not performed\n
    ...  AND   Fail   Upgrade not performed
    ...  ELSE   Append To File   ${resultFile}   \nUpgrade successfull: New Software: ${targetVersion}\n

MyKw Set Airplane Mode Off And Enable Data 3 UEs
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ${ue_ids}       Create List      8a9973ff        c84aef54        dab1ced1
    FOR    ${ueid}    IN    @{ue_ids}
        ssh.Send Command    adb -s ${ueid} shell cmd connectivity airplane-mode disable    connection=${testpc_alias}
        ssh.Send Command    adb -s ${ueid} shell cmd phone data enable    connection=${testpc_alias}
    END
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

MyKw CheckMaxRs
    ${status}   checkRefSignal   ${ttiLog}   ${csiRsFile}   ${maxCsiRsNumber}
    run keyword if     '${status}' == 'False'  run keywords
    ...  Append To File   ${resultFile}    \nWRONG Max Resource Set Configured for calls\n
    ...  AND  Run Keyword And Continue On Failure   Fail   WRONG Max Resource Set Configured for calls
    ...  ELSE   Append To File   ${resultFile}   \nCheck Max Resource Set Configured for calls --> PASSED\n

MyKw Create File for PRB Checks
    [Arguments]   ${suffixe}=${EMPTY}       ${syslog_folder}=${testLogPath}       ${syslogFile}=${syslog}


    #bypass robocop
    ${suffixe}=    Set Variable    ${suffixe}
    ${dll1spcells}       Check Dll1Subpool Assignment       ${syslog_folder}        ${syslogFile}
    ${ull1spcells}       Check Ull1Subpool Assignment       ${syslog_folder}        ${syslogFile}
    ${numMinPrbAllocDl}           ${numMinPrbAllocUl}       Get numMinPrbAlloc      ${syslog_folder}        ${syslogFile}
    ${numMinLayerPrbAllocDl}           ${numMinLayerPrbAllocUl}       Get numMinLayerPrbAlloc      ${syslog_folder}        ${syslogFile}
    ${maxCellPrb}     Get MaxCellPRB          ${syslog_folder}/scf_modif.xml      ${syslog_folder}        ${syslogFile}
    ${longPucchNumPuschPrb}        Get longPucchNumPuschPrb       ${syslogFolder}      ${syslogFile}

    #Run Keyword And Continue On Failure
    #...     Create Pool Checks File      ${dll1spcells}     ${ull1spcells}     ${numMinPrbAllocDl}    ${numMinPrbAllocUl}
    #...     ${numMinLayerPrbAllocDl}    ${numMinLayerPrbAllocUl}    ${maxCellPrb}       ${longPucchNumPuschPrb}
    #...     ${syslog_folder}      ${syslogFile}     ${nrCellIx}        ${cellsToLock}      scf=${syslog_folder}/scf_modif.xml
