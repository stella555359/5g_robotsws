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

@{enabled_a3_rsrp}
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:rsrpThresholdSSB=11
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:filterCoeffSsbRsrp=fc4
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1


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

${actCellTraceReport}    MRBTS-1/NRBTS-1:actCellTraceReport=true

${listen_port}    49100

*** Test Cases ***
5GC000864-ET-A010 Verify X2AP messages trace with inter-GNB PSCellChange procedure
    [Documentation]
    ...    [purpose]:This case is to Verify X2AP messages trace with intra-DU PSCellChange.
    ...    [Configuration]: 1 classical cmWave gNb, 1 cell, 1 Qualcomm
    ...    [Cover Feature]:5GC000864
    [Tags]    QC_61586
    Create NRMTRACECU Object With PCMDreporting False
    Enable CellTrace Feature
    Start Tracer in L3DC in UTE Way One
    Set A3 event measurement configuration
    Set Para actIntraFreqInterGnbMobilityNSA3x to Enable Inter-GNB HO
    Setup X2 Link From Sim Enb1 to Sim Gnb3
    NSA UE Attach To Sim Enb1 And Start ENDC With Real GNB2    ue_id=31
    X2 HO Should Succeed from Real Gnb2 to Sim Gnb3
    UE Change Succeed from gNB Sim to gNB Real
    Check Msg SgNBChangeRequired and Confirm in Wireshark Log    Check_SgNBChangeRequired

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

Create NRMTRACECU Object With PCMDreporting False
    ${recovered}    Delta commission parameters    ${Create_NrMTraceCU_With_PCMDReporting_false}

Enable CellTrace Feature
    Delta commission parameters    ${actCellTraceReport}
    Cells Should Be onair    check_sib=False
    Start To Capture Wireshark Log    Check_SgNBChangeRequired

Start Tracer in L3DC in UTE Way One
    ${stdout} =    Run    pwd
    ${stdout} =    Run    sudo iptables -F
    ${stdout} =    Run    ls -al
    Log    ${stdout}
    start TCE    port=${listen_port}    prompt=Listening

Set A3 event measurement configuration
    Delta commission parameters    ${enabled_a3_rsrp}
    Cells Should Be onair    check_sib=False

Set Para actIntraFreqInterGnbMobilityNSA3x to Enable Inter-GNB HO
    Delta commission parameters    MRBTS-1/NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true
    Cells Should Be onair    check_sib=False

Setup X2 Link From Sim Enb1 to Sim Gnb3
    ${cmd}    Catenate    enb_x2_link_up    enb\=1 target\=3
    Execute Egate Command    ${cmd}    pass_regexp=is up
    Check Sim Enb1 To Real Gnb2 X2 Should Available

Check Sim Enb1 To Real Gnb2 X2 Should Available
    object should exist    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=available

NSA UE Attach To Sim Enb1 And Start ENDC With Real GNB2
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity    timeout=20s

X2 HO Should Succeed from Real Gnb2 to Sim Gnb3
    [Arguments]    ${ue_id}=31
    ${cmd}    Catenate    ue_measurement_send_nr    id\=${ue_id}    meas_id\=1    event\=A3    srsrp_nr\=11 srsrq_nr\=11
    ...    phycell_id\=381 nrsrp_nr\=22 nrsrq_nr\=22
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    Execute Egate Command    ${cmd}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    sleep    2    # make sure HO successful

UE Change Succeed from gNB Sim to gNB Real
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_disp
    ${cmd}    Catenate    dc_gnb_ue_change    ue\=${ue_id} gnb\=2 target_sgnb_cells\=1 cause\=RN_sCG_Mobility
    Execute Egate Command    ${cmd}    pass_regexp=Inter Sgnb Handover is successful

Check Msg SgNBChangeRequired and Confirm in Wireshark Log
    [Arguments]    ${wireshark_name}=Check_SgNBChangeRequired
    Check Wireshark Log    ${CURDIR}${/}a2a_A010${/}Check_SgNBChangeRequired_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31
