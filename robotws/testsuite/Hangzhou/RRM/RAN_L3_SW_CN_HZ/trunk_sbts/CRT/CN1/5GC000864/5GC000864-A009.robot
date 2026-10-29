*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env And Get IP
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-SG2    CRT    owner-ji.fan
...               release-5G21A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
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

${actCellTraceReport}    MRBTS-1/NRBTS-1:actCellTraceReport=true

${listen_port}    49100

*** Test Cases ***
5GC000864-ET-A009 Verify X2AP messages trace with X2APSgNBAdditionRequestReject
    [Documentation]
    ...    [purpose]:This case is to verify Verify X2AP messages trace with X2APSgNBAdditionRequestReject.
    ...    [Configuration]: 1 classical cmWave gNb, 1 cell, 1 Qualcomm
    ...    [Cover Feature]:5GC000864
    [Tags]    QC_61588
    Create NRMTRACECU Object With PCMDreporting False
    Enable CellTrace Feature
    Start To Capture Wireshark Log    Check_X2APSgNBAdditionRequestReject
    Start Tracer in L3DC in UTE Way One
    Set Para MaxNumOfUsers to Make SgNBAddition be rejected
    NSA UE Attach To GNB And SgNBAdditionRequestReject    ue_id=31
    Check Msg SgNBAdditionRequestReject in Wireshark Log    Check_X2APSgNBAdditionRequestReject

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Get IP
    Common Suite Setup And Setup Airphone Env
    ${L3DC_ute_ip_address}    Run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Set Suite variable    ${L3DC_ute_ip_address}

Create NRMTRACECU Object With PCMDreporting False
    ${recovered}    Delta commission parameters    ${Create_NrMTraceCU_With_PCMDReporting_false}

Set Para MaxNumOfUsers to Make SgNBAddition be rejected
    Delta commission parameters    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfUsers=0
    Cells Should Be onair

Check Msg SgNBAdditionRequestReject in Wireshark Log
    [Arguments]    ${wireshark_name}=Check_X2APSgNBAdditionRequestReject
    Check Wireshark Log    ${CURDIR}${/}a2a_A009${/}Check_X2APSgNBAdditionRequestReject_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31

NSA UE Attach To GNB And SgNBAdditionRequestReject
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=SgNBAdditionRequestReject    timeout=20s

Enable CellTrace Feature
    Delta commission parameters    ${actCellTraceReport}

Start Tracer in L3DC in UTE Way One
    ${stdout} =    Run    pwd
    ${stdout} =    Run    sudo iptables -F
    ${stdout} =    Run    ls -al
    Log    ${stdout}
    start TCE    port=${listen_port}    prompt=Listening
