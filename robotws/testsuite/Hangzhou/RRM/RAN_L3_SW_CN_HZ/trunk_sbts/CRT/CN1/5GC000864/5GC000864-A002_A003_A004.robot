*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env And Get IP
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_TDD  team-SG2  C*T  owner-ji.fan  release-5G21A
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
@{PARAMS_IN_SCF}
...    MRBTS-1/MNL-1/TCEADM-1:tceAdminId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${tl.test_pc.default_ssh_connection_details.addr}
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100
...    MRBTS-1/NRBTS-1/NRCTRLTS-1:nrCtrltsId=1
...    @{Create_NrMTraceCU_With_PCMDReporting_true}

@{Create_NrMTraceCU_With_PCMDReporting_true}
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=10
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrMtraceCuId=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{Create_NrMTraceCU_With_PCMDReporting_false}
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=false
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=10
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrMtraceCuId=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{Create_Invalid_cellMaxActiveUEsTraced}
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=0
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrMtraceCuId=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

${SCTPPCAP_FILE_A004}    CellTrace_864A004
${actCellTraceReport}    MRBTS-1/NRBTS-1:actCellTraceReport=true
${inactCellTraceReport}    MRBTS-1/NRBTS-1:actCellTraceReport=false
${Delete_NRMTRACECU}    delete:MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-.*

${INTERFACE}    any
${listen_port}    49100
${GNB_X2_IP}    10.0.1.2

*** Test Cases ***
5GC000864-ET-A004 Verify Cell Trace Session Deactivation by Session Deletion should be successful
   [Documentation]
   ...    This case is to Verify Cell Trace Session Deactivation by Session Deletion should be successful.
   ...    [Configuration]: 1 classical cmWave gNb, 2 cells
   ...    [Cover Feature]: 5GC000864
   [Tags]    QC_61591
   Enable CellTrace Feature And Get Current Active Faultid
   Start TCPDump in ClassicGNB    ${INTERFACE}    ${SCTPPCAP_FILE_A004}
   Enable CellTrace Feature
   Start Tracer in L3DC in UTE Way One
   Delete NRMTRACECU Object by Delta Commission
   Check Msg StopSession Should Exist in Wireshark Log
   UTE TestCase Teardown and Stop Tracer

5GC000864-ET-A002 Verify Cell Trace Session creation with inconsistent parameters should be failed
   [Documentation]
   ...    [purpose]:This case is to verify Cell Trace Session creation with inconsistent parameters should be failed.
   ...    [Configuration]: 1 classical cmWave gNb , 1 cell
   ...    [Cover Feature]:5GC000864
   [Tags]    QC_61594
   Enable CellTrace Feature And Get Current Active Faultid
   Configure CellTrace Releated Parameters on UTE and Set cellMaxActiveUEsTraced with Invalid Value Should Fail
   UTE TestCase Teardown and Check Alarm

5GC000864-ET-A003 Verify more than one Cell Trace Session creation should be failed
    [Documentation]
    ...    [Purpose]:This case is to verify more than one cell trace session creation should be failed.
    ...    [Configuration]: 1 classical cmWave gNb , 1 cell
    ...    [Cover Feature]:5GC000864
    [Tags]    QC_61593
    Enable CellTrace Feature And Get Current Active Faultid
    Add another NRMTRACECU and failed
    UTE TestCase Teardown and Check Alarm

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Get IP
    Common Suite Setup And Setup Airphone Env
    ${L3DC_ute_ip_address}    Run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Set Suite variable    ${L3DC_ute_ip_address}

Enable CellTrace Feature And Get Current Active Faultid
    delta commission parameters    ${actCellTraceReport}
    delta commission parameters    ${Delete_NRMTRACECU}
    delta commission parameters    ${Create_NrMTraceCU_With_PCMDReporting_true}
    Judge The NRMTRACECU Object Should Exist

Judge The NRMTRACECU Object Should Exist
    ${return_params}    object should exist    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true

Create NRMTRACECU Object with PCMDreporting False
    delta commission parameters    ${Delete_NRMTRACECU}
    ${recovered}    delta commission parameters    ${Create_NrMTraceCU_With_PCMDReporting_false}

Delete NRMTRACECU Object by Delta Commission
    ${recovered}    delta commission parameters    ${Delete_NRMTRACECU}

Enable CellTrace Feature
    delta commission parameters    ${actCellTraceReport}

Disable Celltrace Feature Flag
    ${recovered}    delta commission parameters    ${inactCellTraceReport}

Start Tracer in L3DC in UTE Way One
    ${stdout} =    Run    pwd
    ${stdout} =    Run    sudo iptables -F
    ${stdout} =    Run    ls -al
    Log    ${stdout}
    ${stdout} =    Run    rm temp.txt
    Start NetCat Listening
    ${status}    Run Keyword And Return Status    Check Connection between GNB and L3DC
    Run Keyword Unless    ${status}    Rebuild NRMTRACECU With PCMD False And Check Connection Again

Start NetCat Listening
    start TCE  port=${listen_port}  prompt=Listening

UTE TestCase Teardown and Check Alarm
    Disable Celltrace Feature Flag
    Create NRMTRACECU Object with PCMDreporting False

UTE TestCase Teardown and Stop Tracer
    Stop TCE  port=49100
    UTE TestCase Teardown and Check Alarm

Start TCPDump in ClassicGNB
    [Arguments]    ${INTERFACE}    ${PCAPFILE}
    Run Keyword And Ignore Error
    ...    Execute Cmd On Pc    sudo tcpdump -U -w - -i ${INTERFACE} ${SAVE LOG DIRECTORY}${/}ute_wireshark_${PCAPFILE}.pcap>& tmp_${PCAPFILE}.txt&

Check Msg StopSession Should Exist in Wireshark Log
    check wireshark log    ${CURDIR}${/}a2a_A004${/}a2a.ini

Check Connection between GNB and L3DC
    Run    ps -ef|grep 49100
    Run    cat tmp_${PCAPFILE}.txt |grep -a 10.0.1.2
    Run    sudo iptables -L
    wait until keyword succeeds    60s    2s    trace_connection_should_be_existed
    Run    ps -ef|grep 49100
    Run    cat tmp_${PCAPFILE}.txt |grep -a 10.0.1.2
    Run    sudo iptables -L

Rebuild NRMTRACECU With PCMD False And Check Connection Again
    Delete NRMTRACECU Object by Delta Commission
    Create NRMTRACECU Object with PCMDreporting False
    run keyword and ignore error    Check Connection between GNB and L3DC

trace_connection_should_be_existed
    ${output}    Run    cat tmp_${PCAPFILE}.txt |grep -a 10.0.1.2
    Should contain    ${output}    Connection from ${GNB_X2_IP}

Configure CellTrace Releated Parameters on UTE and Set cellMaxActiveUEsTraced with Invalid Value Should Fail
    delta commission parameters    ${Delete_NRMTRACECU}
    object should not exist    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
    run keyword and ignore error    delta commission parameters    ${Create_Invalid_cellMaxActiveUEsTraced}
    object should not exist    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=0

Add another NRMTRACECU and failed
    run keyword and ignore error    delta commission parameters
    ...    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-2:actCellTraceReportingCU=true
    object should exist    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
    object should not exist    MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-2:actCellTraceReportingCU=true
