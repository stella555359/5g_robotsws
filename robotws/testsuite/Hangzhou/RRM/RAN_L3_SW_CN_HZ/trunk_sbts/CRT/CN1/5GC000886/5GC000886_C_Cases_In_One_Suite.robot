*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env And Get IP
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    C*T    owner-zhu.baijie
...               release-5G21A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
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
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    @{Create_NrMTraceCU_With_PCMDReporting_true}
...    @{NRADJNRCELL}
...    @{intra_freq_inter_gnb}
...    @{enabled_a3_HO_rsrp}

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

@{enabled_a3_HO_rsrp}
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387

...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=24
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3

@{intra_freq_inter_gnb}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

${periodicalDataUsageReportTimer}    60
${DefaultPeriodicalDataUsageReportTime}    60s
${NSA_UE_1}    31
${NSA_UE_2}    32

@{5GC000886_D007_D008}
...    MRBTS-1/NRBTS-1:actSecDataUsageRep=true
...    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=60
...    MRBTS-1/NRBTS-1:actMultiDrbNSA=true

# Number of EN-DC X2 Secondary RAT Data Usage Report sent to eNB
${ENDC_X2_SEC_RAT_DATA_USAGE_REP}    M55110C02001
${counters_C004}    PLMN-PLMN/MRBTS-1/NRBTS-1:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}=6

${Stop_Time_Sync}    ddal -s ddal_sfn_monitor_sync DDAL_SFN_SYNC_OSUTC_TO_BTSRTC DDAL_SFN_STOP

*** Test Cases ***
5GC000886-ET-C004-Verify_End-month_partial_Data_Usage_Report_generation_and_delivery_by_next_event_multiDRB_multiUE
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to check: EndMonth report should be reported
    ...    in DataUsageReport triggered by Event MultiDRB And MultiUE.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886
    [Tags]    QC_86744
    Switch SyncMonitor OFF and Modify System Time
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D007_D008}
    Start To Collect Tcpdump After Two UEs And Two Bearers Addition Successfully
    Release sgNB UE And Stop Tcpdump
    Check Data Usage Report And PM Counter With Event Trigger C004

*** Keywords ***
Modify Cfg
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated s1u=10.0.1.124 plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24
    ...    daemon=10.0.2.1:22222 x2=10.0.1.126:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${GNB3_CFG}

    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${CELL_381}
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.231 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2

    Update Cfg    set_bearer id=2 ue=32 qci=9 pdn=1 ip=4.7.254.232 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=3 ue=32 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all

Common Suite Setup And Setup Airphone Env And Get IP
    Common Suite Setup And Setup Airphone Env
    ${L3DC_ute_ip_address}    Run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Set Suite variable    ${L3DC_ute_ip_address}

Switch SyncMonitor OFF and Modify System Time
    ${current_end_of_date}    Get Current The End Of Date
    Change gNB local time    Time_setting="${current_end_of_date} 23:58:50"

Get Current The End Of Date
    ${current_month_day}    execute cmd on gnb    date +%Y-%m-%d
    ${current_strotime}    execute cmd on gnb    date -d"$(date -d'${current_month_day} 1 month' +'%Y-%m-01') -1 days" +"%F"
    [Return]    ${current_strotime}

Change gNB local time
    [Arguments]    ${Time_setting}
    ${current_month_day}    execute cmd on gnb    date +%Y-%m-%d
    execute cmd on gnb    ${Stop_Time_Sync}
    execute cmd on gnb    date -s ${Time_setting}

Start To Collect Tcpdump After Two UEs And Two Bearers Addition Successfully
    Start To Capture Wireshark Log    C004_Check_DataUsageReport
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${NSA_UE_1}    bearer_id=2,3
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${NSA_UE_2}    bearer_id=2,3
    sleep    ${DefaultPeriodicalDataUsageReportTime}
    Recover DataUsageReport Parameter
    sleep    ${DefaultPeriodicalDataUsageReportTime}

Release sgNB UE And Stop Tcpdump
    ${time2sleep}    evaluate    ${periodicalDataUsageReportTimer}
    sleep    ${time2sleep}
    Release Ues    ue_type=nsa    ue_id=${NSA_UE_1}
    Release Ues    ue_type=nsa    ue_id=${NSA_UE_2}

Recover DataUsageReport Parameter
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=0
    Cells Should Be onair

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity    timeout=20s

Check Data Usage Report And PM Counter With Event Trigger C004
    [Arguments]    ${wireshark_name}=C004_Check_DataUsageReport
    Check Wireshark Log    ${CURDIR}${/}a2a_C004${/}C004_Check_DataUsageReport_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::4
    Check Counters    ${counters_C004}
