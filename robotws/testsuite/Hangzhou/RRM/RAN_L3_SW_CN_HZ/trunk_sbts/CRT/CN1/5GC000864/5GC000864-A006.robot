*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env And Get IP
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-SG2    CRT    owner-ji.fan    release-5G21A
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
@{PARAMS_IN_SCF}
...    MRBTS-1/MNL-1/TCEADM-1:tceAdminId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIpAddress=10.0.1.1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100
...    MRBTS-1/NRBTS-1/NRCTRLTS-1:nrCtrltsId=1
...    @{Create_NrMTraceCU_With_PCMDReporting_true}
...    @{miNr_Settings}

@{miNr_Settings}
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrRelReportCu=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled

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

${actCellTraceReport}    MRBTS-1/NRBTS-1:actCellTraceReport=true

${listen_port}    49100
@{fault_8000}    fault_id=8000    fault_name=Failure in connection between BTS and 3rd party tool

*** Test Cases ***
5GC000864-ET-A006 Verify TCP link should be handled correctly
    [Documentation]    [Purpose]:This case is to verify more than one cell trace session creation should be failed.
    ...    [Configuration]: 1 classical cmWave gNb , 1 cell
    ...    [Cover Feature]:5GC000864
    [Tags]    QC_61589
    Create NRMTRACECU Object With PCMDreporting False
    Stop Trace And Check TCP Should lost
    Start Trace And Check TCE Session Should Alive

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Get IP
    Common Suite Setup And Setup Airphone Env
    ${L3DC_ute_ip_address}    Run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Set Suite variable    ${L3DC_ute_ip_address}

Stop Trace And Check TCP Should lost
    Start To Capture Wireshark Log    Check_Have_RST
    Fm Fault Should Be Cleared    ${fault_8000}
    Enable CellTrace Feature
    Start Tracer in L3DC in UTE Way One
    sleep    60s    # trace record to tce_49100.txt
    Reboot L3DC VM to make TCE unreachable in UTE
    Fm Fault Should Be Raised    ${fault_8000}
    Check TCP link lost and Msg RST in Wireshark

Start Trace And Check TCE Session Should Alive
    Start To Capture Wireshark Log    Check_Have_IsAlive
    Fm Fault Should Be Raised    ${fault_8000}
    Start Tracer in L3DC in UTE Way One
    Check FID_8000 Should Be Cleared
    Check TCE Session Msg IsAlive in Wireshark


Check TCE Session Msg IsAlive in Wireshark
    Check Wireshark Log    ${CURDIR}${/}a2a_A006${/}Check_Have_IsAlive_a2a.ini
    ...    name=Check_Have_IsAlive    wait_string=UEContextReleaseComplete::2

Reboot L3DC VM to make TCE unreachable in UTE
    Stop Tracer in UTE

Stop Tracer in UTE
    ${nc_id}    run    ps -ef | grep "nc -lvp 49100" | grep -v grep | awk '{print $2}'
    run    kill -9 ${nc_id.strip()}
    ${output}    run    ps -ef | grep "nc -lvp 49100" | grep -v grep | awk '{print $2}'
    Should be true    "${output.strip()}"==""

Check TCP link lost and Msg RST in Wireshark
    Check Wireshark Log    ${CURDIR}${/}a2a_A006${/}Check_Have_RST_a2a.ini
    ...    name=Check_Have_RST    wait_string=UEContextReleaseComplete::2

Create NRMTRACECU Object With PCMDreporting False
    ${recovered}    Delta commission parameters    ${Create_NrMTraceCU_With_PCMDReporting_false}

Enable CellTrace Feature
    Delta commission parameters    ${actCellTraceReport}

Start Tracer in L3DC in UTE Way One
    Stop All Firewall Rules
    Start TCE    port=${listen_port}    prompt=Listening

Stop All Firewall Rules
    ${stdout} =    Run    pwd
    ${stdout} =    Run    sudo iptables -F
    ${stdout} =    Run    ls -al
    Log    ${stdout}

Check FID_8000 Should Be Cleared
    wait until keyword succeeds    2min    2s    Fm Fault Should Be Cleared    ${fault_8000}     timeout=2
