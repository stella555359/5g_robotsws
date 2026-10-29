*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env And Get IP
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    owner-zhu.baijie
...               release-5G21A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    MRBTS-1/MNL-1/TCEADM-1:tceAdminId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${tl.test_pc.default_ssh_connection_details.addr}
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49151
...    MRBTS-1/NRBTS-1/NRCTRLTS-1:nrCtrltsId=1
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
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

@{PARAMS_TO_MODIFY_864_2cell}
...    MRBTS-1/NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    MRBTS-1/NRBTS-1:srb3SupportEnabled=true
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=2

...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n64
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1

...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-2:absThreshSsbRsrqConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-2:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-2:cbraPreamblesPerSsb=n64
...    MRBTS-1/NRBTS-1/NRCELL-2:sMeasConfigSsbRsrp=1

${actCellTraceReport}    MRBTS-1/NRBTS-1:actCellTraceReport=true
${listen_port}    49151

*** Test Cases ***
5GSW_CP_EDA_5GC000864_PR569249_Verify X2AP messages trace with intra-DU PSCellChanges
    [Documentation]
    ...    [Purpose]:For EDA PR569249. The purpose of this test case is to verify the scenario acccording to the PR569249.
    ...    Cell trace still reports the NR RRC reconfiguration Complete message with old crnti in interMeNB HO with PSCellchange scenario.
    ...    1.Trace the sucessful intra-DU PSCellChanges.
    ...    2.Check that the old C_RNTI value in ueContextSetupResponse is different with
    ...    the new one in the ueContextModificationResponse after intra-DU PSCellchange.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 2 Cell, NSA
    ...    [Cover Feature]: 5GC000864
    [Tags]    QC_xxxxx
    Enable CellTrace Feature
    Start Tcpdump For Trace
    Start Tracer in L3DC in UTE Way One
    Set Params For Intra-DU HO
    UE Intra HO By A3
    Check C_RNTI Should Changed
    Analysis Wireshark Log For HO

*** Keywords ***
Modify Cfg
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated s1u=10.0.1.124 plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24
    ...    daemon=10.0.2.1:22222 x2=10.0.1.126:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${GNB3_CFG}

    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${CELL_381}

Common Suite Setup And Setup Airphone Env And Get IP
    Common Suite Setup And Setup Airphone Env
    ${L3DC_ute_ip_address}    Run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Set Suite variable    ${L3DC_ute_ip_address}

Enable CellTrace Feature
    Delta commission parameters    ${actCellTraceReport}
    Cells Should Be onair    check_sib=False

Start Tcpdump For Trace
    Start To Capture Wireshark Log    Check_X2AP_trace

Set Params For Intra-DU HO
    Delta commission parameters    ${PARAMS_TO_MODIFY_864_2cell}
    Cells Should Be onair

Start Tracer in L3DC in UTE Way One
    ${stdout} =    Run    pwd
    ${stdout} =    Run    sudo iptables -F
    ${stdout} =    Run    ls -al
    Log    ${stdout}
    start TCE    port=${listen_port}    prompt=Listening

UE Intra HO By A3
    NSA UE Attach To Sim Enb1 Cell1 And Start ENDC With Real GNB2 Cell1    ue_id=31
    Start traffic
    Perform UE X2 Intra Handover From Sim Enb1 Cell1 To Real GNB2 Cell2    evt=A3    ue=31
    Wait Until Keyword Succeeds    3min    10s    Check Traffic Stream
    Release Ues    ue_type=nsa    ue_id=31

Start Traffic
    Start DL Traffic Stream
    Start UL Traffic Stream
    Wait Until Keyword Succeeds    5min    10s    Check Traffic Stream

Start DL Traffic Stream
    Start Traffic Stream    Direction=dl    Data_Rate=5    Default_UE_ID=31

Start UL Traffic Stream
    Start Traffic Stream    Direction=ul    Data_Rate=2    Default_UE_ID=31

Start Traffic Stream
    [Arguments]    ${Direction}=dl    ${Data_Rate}=2    ${Default_UE_ID}=31    ${Actual_Bearer_ID}=2    ${Bearer_ID}=2
    ${part}    set variable
    ...    trf_data_start ue\=${Default_UE_ID} id\=${Actual_Bearer_ID} dir\=${Direction} trf_id\=${Bearer_ID} mbps\=${Data_Rate}
    ${result}    Run    (sleep 1;echo "${part}";sleep 5)|telnet 0 20000

NSA UE Attach To Sim Enb1 Cell1 And Start ENDC With Real GNB2 Cell1
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity    timeout=20s

Perform UE X2 Intra Handover From Sim Enb1 Cell1 To Real GNB2 Cell2
    [Arguments]    ${evt}=A3    ${ue}=31    ${phyid}=51    ${meas}=1
    ${part}    set variable
    ...    ue_measurement_send_nr id\=${ue} meas_id\=${meas} event\=${evt} srsrp_nr\=11 srsrq_nr\=11 phycell_id\=${phyid} nrsrp_nr\=30 nrsrq_nr\=30
    ${result}    Run    (sleep 1;echo "${part}";sleep 5)|telnet 0 20000
    Should contain    ${result}    reported successful RA

Analysis Wireshark Log For HO
    [Arguments]    ${wireshark_name}=Check_X2AP_trace
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000864${/}Check_X2AP_trace_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2

Check Traffic Stream
    [Arguments]    ${Direction}=dl    ${Default_UE_ID}=31    ${Actual_Bearer_ID}=2
    ${part}    set variable    bearer_stats ue\=${Default_UE_ID} id\=${Actual_Bearer_ID} dir\=${Direction} dc_cell_group\=scg
    ${result}    Run
    ...    (sleep 1;echo "${part}";sleep 5)|telnet 0 20000 | tee test.txt
    ${data_rate}    Run    cat test.txt | grep -a "Average data rate" | awk '{print $4}'
    ${data_rate_num}    Convert To Integer    ${data_rate}
    ${data_rate_num}    Evaluate    ${data_rate_num}/1000000.0
    ${status}    Evaluate    4.5 < ${data_rate_num} <= 5.0
    Should be true    ${status}
    Set suite variable    ${RESTART_FLAG1}    False
    ${part}    set variable    bearer_stats ue\=${Default_UE_ID} id\=${Actual_Bearer_ID} dir\=ul dc_cell_group\=all
    ${result}    Run
    ...    (sleep 1;echo "${part}";sleep 5)|telnet 0 20000 | tee test.txt
    ${data_rate}    Run    cat test.txt | grep -a "Average data rate" | awk '{print $4}'
    ${data_rate_num}    Convert To Integer    ${data_rate}
    ${data_rate_num}    Evaluate    ${data_rate_num}/1000000.0
    ${status}    Evaluate    1.8 < ${data_rate_num} <= 2.0
    Should be true    ${status}
    Set suite variable    ${RESTART_FLAG1}    False

Check C_RNTI Should Changed
    Get newUE_Identity Value
    should not be equal as strings    ${newUE_Identity}    ${newUE_Identity_After_HO}

Get newUE_Identity Value
    ${out}    Execute Cmd On Pc    grep newUE-Identity ${WTS_DIR}/egate_console.log
    Log To Console    out is ${out}
    Set Suite Variable    ${newUE_Identity}    ${out.splitlines()[0].split("newUE-Identity ")[-1].replace(",", "")}
    Log To Console    newUE_Identity is ${newUE_Identity}
    Set Suite Variable    ${newUE_Identity_After_HO}    ${out.splitlines()[1].split("newUE-Identity ")[-1].replace(",", "")}
    Log To Console    newUE_Identity_After_HO is ${newUE_Identity_After_HO}
