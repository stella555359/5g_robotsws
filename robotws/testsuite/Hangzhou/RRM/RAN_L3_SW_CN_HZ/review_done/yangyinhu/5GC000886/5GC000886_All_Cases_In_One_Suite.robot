*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env And Get IP
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    owner-zhu.baijie
...               release-5G21A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1cell_ecpri

@{PARAMS_IN_SCF}
...    MRBTS-1/MNL-1/TCEADM-1:tceAdminId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceId=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${tl.test_pc.default_ssh_connection_details.addr}
...    MRBTS-1/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49151
...    MRBTS-1/NRBTS-1/NRCTRLTS-1:nrCtrltsId=1
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    @{Create_NrMTraceCU_With_PCMDReporting_true}
...    @{NRADJNRCELL}
...    @{intra_freq_inter_gnb}
...    @{enabled_a3_HO_rsrp}

@{5GC000886_D001}
...    MRBTS-1/NRBTS-1:actSecDataUsageRep=true
...    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=60

@{5GC000886_D003_D004}
...    MRBTS-1/NRBTS-1:actSecDataUsageRep=false
...    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=60

@{5GC000886_D004}
...    MRBTS-1/NRBTS-1:actSecDataUsageRep=true
...    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=10

@{5GC000886_D005_D006}
...    MRBTS-1/NRBTS-1:actSecDataUsageRep=true
...    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=60

@{5GC000886_D007_D008}
...    MRBTS-1/NRBTS-1:actSecDataUsageRep=true
...    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=60
...    MRBTS-1/NRBTS-1:actMultiDrbNSA=true

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

${DefaultPeriodicalDataUsageReportTime}    60s
${NSA_UE_1}    31
${NSA_UE_2}    32

# Number of EN-DC X2 Secondary RAT Data Usage Report sent to eNB
${ENDC_X2_SEC_RAT_DATA_USAGE_REP}    M55110C02001
${counters_D003}    PLMN-PLMN/MRBTS-1/NRBTS-1:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}=0
${counters_D005}    PLMN-PLMN/MRBTS-1/NRBTS-1:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}>=5
${counters_D006}    PLMN-PLMN/MRBTS-1/NRBTS-1:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}>=5
${counters_D008}    PLMN-PLMN/MRBTS-1/NRBTS-1:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}>=4

*** Test Cases ***
5GC000886-ET-D001-Verify_Secondary_RAT_Data_Usage_Report_generation_and_delivery_triggered_with_SN_initiated_by_Radio_link_failure
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to check: DataUsageReport triggered by RLF
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886
    [Tags]    QC_xxxxx
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D001}
    Trigger RLF After UE Attached
    Check Messages of RLF Procedure And Data Usage Report in Wireshark Log    Check_RLF

5GC000886-ET-D003-Verify_Secondary_RAT_Data_Usage_Report_with_feature_disable
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to verify Secondary RAT Data Usage Report generation failed
    ...    when feature is set to disable.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886
    [Tags]    QC_xxxxx
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D003_D004}
    Attach UE And Start To Collect Tcpdump On ASIK
    sleep    ${DefaultPeriodicalDataUsageReportTime}
    Recover DataUsageReport Parameter
    Check Data Usage Report And PM Counter

5GC000886-ET-D004-Verify_Secondary_RAT_Data_Usage_Report_with_feature_disable_To_enable_after_UE_attach
    [Documentation]    [Purpose]: The purpose of this test case is to verify Secondary RAT Data Usage Report generation failed
    ...    when feature is set to disable.
    ...    [Test Step]: attach UE then enable feature, there is no secondary RAT date usage report generation.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886
    [Tags]    QC_xxxxx
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D003_D004}
    Attach UE And Start To Collect Tcpdump On ASIK
    Modify actSecDataUsageRep with true
    Recover DataUsageReport Parameter
    Check Data Usage Report And PM Counter

5GC000886-ET-D005-Verify_Secondary_RAT_Data_Usage_Report_with_feature_enable_To_disable_after_UE_attach
    [Documentation]
    ...    [Purpose]: This case is to verify Secondary RAT Data Usage Report generation
    ...    and delivery triggered or not if feature status change from enable to disable after UE attached.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886
    [Tags]    5GC000886_D005
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D005_D006}
    Start To Capture Wireshark Log    D005_Check_DataUsageReport
    Start To Collect Tcpdump And Modify Parameters After UE attached
    Analysis SecondaryRATDataUsageReport Messages And Check PM Counter D005

5GC000886-ET-D006-Verify_Secondary_RAT_Data_Usage_Report_with_Modifing_Periodical_Value
    [Documentation]
    ...    [Purpose]: This case is to verify Secondary RAT Data Usage Report generation and delivery can be triggered normally
    ...    if timer value changed.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886
    [Tags]    QC_xxxxx
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D005_D006}
    Start To Collect Tcpdump And Modify periodicalDataUsageReportTimer Parameters After UE attached
    Analysis SecondaryRATDataUsageReport Messages And Check PM Counter D006

5GC000886-ET-D008-Verify_Secondary_RAT_Data_Usage_Report_Periodical_with_MultiUE_MultiDRB
    [Documentation]
    ...    [Purpose]: This case is to verify Secondary RAT Data Usage Report generation and delivery can be triggered normally
    ...    with Multi-DRBs and Multi-UEs.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell, 2 UEs 2 DRBs
    ...    [Cover Feature]: 5GC000886
    [Tags]    QC_xxxxx
    Clear Counter Files
    Delta Commission Parameters    ${5GC000886_D007_D008}
    Start To Collect Tcpdump After Two UEs And Two Bearers Addition Successfully
    Check X2AP E1AP Usage Report Periodical And PM Counter D008

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

Attach UE And Start To Collect Tcpdump On ASIK
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ${NSA_UE_1}
    Start To Capture Wireshark Log    Check_DataUsageReport

Trigger RLF After UE Attached
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ${NSA_UE_1}
    Start To Capture Wireshark Log    Check_RLF
    Trigger RLF In Egate
    sleep    ${DefaultPeriodicalDataUsageReportTime}

Recover DataUsageReport Parameter
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=0
    Cells Should Be onair

Modify actSecDataUsageRep with true
    Delta commission parameters    ${5GC000886_D004}
    Cells Should Be onair
    sleep    10s    # make parameters take effect

Check Data Usage Report And PM Counter
    [Arguments]    ${wireshark_name}=Check_DataUsageReport
    Check Wireshark Log    ${CURDIR}${/}a2a_D003_D004${/}Check_DataUsageReport_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31
    Check Counters    ${counters_D003}

Trigger RLF In Egate
    [Arguments]    ${ue_id}=31
    ${cmd}    Catenate    ue_dc_rlf    ue\=${ue_id}    failure_type\=rlc_max_num_retx    at\=gnb
    Execute Egate Command    ${cmd}    pass_regexp=ScgFailureInformationNR_r15

Check Messages of RLF Procedure And Data Usage Report in Wireshark Log
    [Arguments]    ${wireshark_name}=Check_RLF
    Check Wireshark Log    ${CURDIR}${/}a2a_D001${/}Check_RLF_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity    timeout=20s

Start To Collect Tcpdump And Modify Parameters After UE attached
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ${NSA_UE_1}
    sleep    ${DefaultPeriodicalDataUsageReportTime}
    Delta commission parameters    MRBTS-1/NRBTS-1:actSecDataUsageRep=false
    Cells Should Be onair
    sleep    ${DefaultPeriodicalDataUsageReportTime}
    Delta commission parameters    MRBTS-1/NRBTS-1:actSecDataUsageRep=false
    Cells Should Be onair
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=0
    Cells Should Be onair
    sleep    ${DefaultPeriodicalDataUsageReportTime}

Analysis SecondaryRATDataUsageReport Messages And Check PM Counter D005
    Analysis SecondaryRATDataUsageReport messages in the wireshark log D005
    Check Counters    ${counters_D005}

Analysis SecondaryRATDataUsageReport Messages And Check PM Counter D006
    Analysis SecondaryRATDataUsageReport messages in the wireshark log D006
    Check Counters    ${counters_D006}

Analysis SecondaryRATDataUsageReport messages in the wireshark log D005
    [Arguments]    ${wireshark_name}=D005_Check_DataUsageReport
    Check Wireshark Log    ${CURDIR}${/}a2a_D005${/}D005_Check_DataUsageReport_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31

Analysis SecondaryRATDataUsageReport messages in the wireshark log D006
    [Arguments]    ${wireshark_name}=D006_Check_DataUsageReport
    Check Wireshark Log    ${CURDIR}${/}a2a_D006${/}D006_Check_DataUsageReport_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31

Start To Collect Tcpdump And Modify periodicalDataUsageReportTimer Parameters After UE attached
    Start To Capture Wireshark Log    D006_Check_DataUsageReport
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ${NSA_UE_1}
    sleep    ${DefaultPeriodicalDataUsageReportTime}
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=180
    Cells Should Be onair
    ${time2sleep}    evaluate    180+60
    sleep    ${time2sleep}
    change periodicalDataUsageReportTimer step1
    change periodicalDataUsageReportTimer step2

change periodicalDataUsageReportTimer step1
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=10
    Cells Should Be onair
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=0
    Cells Should Be onair
    ${time2sleep}    evaluate    0+80
    sleep    ${time2sleep}

change periodicalDataUsageReportTimer step2
    Delta commission parameters    MRBTS-1/NRBTS-1:periodicalDataUsageReportTimer=20
    Cells Should Be onair
    ${time2sleep}    evaluate    20+10
    sleep    ${time2sleep}
	

Start To Collect Tcpdump After Two UEs And Two Bearers Addition Successfully
    Start To Capture Wireshark Log    D008_Check_DataUsageReport
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${NSA_UE_1}    bearer_id=2,3
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${NSA_UE_2}    bearer_id=2,3
    sleep    ${DefaultPeriodicalDataUsageReportTime}
    Recover DataUsageReport Parameter
    sleep    ${DefaultPeriodicalDataUsageReportTime}

Check X2AP E1AP Usage Report Periodical And PM Counter D008
    [Arguments]    ${wireshark_name}=D008_Check_DataUsageReport
    Check Wireshark Log    ${CURDIR}${/}a2a_D008${/}D008_Check_DataUsageReport_a2a.ini
    ...    name=${wireshark_name}    wait_string=UEContextReleaseComplete::2
    Release Ues    ue_type=nsa    ue_id=31
    Check Counters    ${counters_D008}
