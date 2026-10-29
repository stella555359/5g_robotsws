*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CRT    team-SG2
...               CLOUD_R4LAPO_CUS    release-xL18    owner-junli.chang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1/LNBTS_TDD-0:actConvVoice=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS-1:actHoFromUtran=true
...    LNBTS-1:actRedirect=enabled
...    LNBTS-1:actServBasedMobThr=true
...    LNBTS-1:pwrFallbackCa=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
...    LNCEL-2/LNCEL_TDD-0:earfcn=40940
...    LNCEL-3/LNCEL_TDD-0:earfcn=41138
...    LNCEL:a2RedirectQci1=enabled
...    LNCEL:ulsMinTbs=104
...    LNCEL:ulsMinRbPerUe=3
...    LNCEL:actUePowerBasedMobThr=true
...    LNCEL:rsrqRedirectParams:threshold4Rsrq=-38
...    LNCEL:cellTechnology=TDD
...    LNCEL-1:actUePowerBasedMobThr=true
...    LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-1:rsrqMobilityParams:threshold2aRsrq=34
...    LNBTS-1/LNBTS_TDD-0:preventPsHOtoWcdma=None
...    LNBTS-1:actDLCAggr=false
...    LNCEL-1:inactivityTimer=180
...    LNBTS-1/LNADJ-254:rlfBasedRCRsupported=true
...    LNBTS-1/LNADJ-254:adjEnbId=74566
...    LNBTS-1/LNADJ-254:cPlaneIpAddr=10.0.1.3
...    LNBTS-1/LNADJ-255:rlfBasedRCRsupported=true
...    LNBTS-1/LNADJ-255:adjEnbId=74567
...    LNBTS-1/LNADJ-255:cPlaneIpAddr=10.0.1.4
...    @{LTE_IF_Neighbor_Param}
@{LTE_IF_Neighbor_Param}
...    LNCEL-1/LNREL-1:ecgiLcrId=103
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:handoverAllowed=onlyS1
...    LNCEL-1/LNHOIF-1:interPresAntP=false
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40940
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1/MODPR-0:freqLayListLte=40940,3000,2100
@{PRAMS_FOR_HIGH_PRIORITY}
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1/LNBTS_TDD-0:actIMSEmerSessR9=true
...    LNBTS-1/LNBTS_TDD-0:actHighPrioServices=true
...    LNBTS-1:hpsSessConfig:hpsSessArpMax=4
...    LNBTS-1:hpsSessConfig:hpsSessArpMin=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrcEmergency=80
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=25
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addEmergencySessions=30
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumEmergencySessions=8
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumRrcNoDrb=5
...    LNCEL-1/LNCEL_TDD-0:maxNumQci1Drb=20
...    LNCEL-1/LNCEL_TDD-0:maxNumActDrb=100
...    LNCEL-1/LNCEL_TDD-0:maxNumActUE=20
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUeDc=1
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=1
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=20
...    LNCEL-1/LNCEL_TDD-0:addNumDrbRadioReasHo=0
...    LNCEL-1/LNCEL_TDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_TDD-0:addNumQci1DrbTimeCriticalHo=1
...    LNCEL-1/LNCEL_TDD-0:addNumQci1DrbRadioReasHo=1
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=false
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addAUeRrHo=30
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addAUeTcHo=45
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPreemCap=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPreemVul=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS-1:imsEmerPlmnConfig:emerSessLimServ=false
...    LNBTS-1:imsEmerPlmnConfig:emerSessMcc=262
...    LNBTS-1:imsEmerPlmnConfig:emerSessMnc=3
...    LNBTS-1:imsEmerPlmnConfig:emerSessMncLen=2
@{PARAMS_FOR_RRNA}
...    LNCEL-1:gbrCongHandling=l2andl3
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNCEL-1:addGbrTrafficRrHo=5
...    LNCEL-1:addGbrTrafficTcHo=10
...    LNBTS-1:actPdcpRohc=true
...    LNBTS-1:congWeightAlg=arpPrioPerVul
...    LNCEL-1:maxGbrTrafficLimit=30
...    LNCEL-1/LNCEL_TDD-0:tddFrameConf=1
...    LNCEL-1/LNCEL_TDD-0:tddSpecSubfConf=7
...    LNBTS-1:actEmerCallRedir=Disabled
...    LNCEL-1:actModulationSchemeUL=16QAMHighMCS
...    LNCEL-1:actModulationSchemeDl=64QAM
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nCqiRb=3
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:cqiPerNp=40ms
...    LNCEL-1:iniMcsUl=20
...    LNCEL-1:iniMcsDl=28
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=72
...    LNBTS-1:qciTab1:maxGbrDl=512
...    LNBTS-1:qciTab1:maxGbrUl=512
...    LNBTS-1:qciTab3:maxGbrDl=12000
...    LNBTS-1:qciTab3:maxGbrUl=512
@{PARAMS_FOR_01_04}
...    LNBTS-1:actHOtoWcdma=false
...    LNBTS-1:actHoFromUtran=false
...    LNCEL-2/LNCEL_TDD-0:earfcn=38000
...    LNCEL-3/LNCEL_TDD-0:earfcn=38000
...    LNBTS-1/LNBTS_TDD-0:actInterFreqServiceBasedHo=false
...    LNCEL-1:a3Offset=2
...    LNCEL-1:threshold3=65
...    LNCEL-1:threshold3a=66
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1:enableCovHo=true
...    LNCEL-1:threshold2a=65
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:threshold2aQci1=64
...    LNCEL-1:threshold2InterFreqQci1=59
...    LNCEL-1:threshold2aHpue=55
...    LNCEL-1:threshold2InterFreqHpue=50
...    LNCEL-1:threshold2Wcdma=45
...    LNCEL-1:threshold2GERAN=40
...    LNCEL-1:threshold4=19
...    LNCEL-1:blacklistHoL:blacklistTopo=onlyX2
...    LNCEL-1:blacklistHoL:freqEutra=40940
...    LNCEL-1:blacklistHoL:phyCellIdRange=n4
...    LNCEL-1:blacklistHoL:phyCellIdStart=8
...    LNCEL-1:inactivityTimer=1000
@{PARAMS_FOR_01_04_recovery}
...    LNCEL-1:blacklistHoL:blacklistTopo=allEqual
...    LNCEL-1:blacklistHoL:freqEutra=65535
...    LNCEL-1:blacklistHoL:phyCellIdRange=n4
...    LNCEL-1:blacklistHoL:phyCellIdStart=499
@{PARAMS_FOR_01_19}
...    LNCEL-1:actUePowerBasedMobThr=true
...    LNCEL-1:inactivityTimer=60000
@{PARAMS_FOR_01_24}
...    LNBTS-1/MODPR-0:freqLayListLte=1
...    LNCEL-1:inactivityTimer=60000
@{PARAMS_FOR_01_27}
...    @{PRAMS_FOR_HIGH_PRIORITY}
...    @{PARAMS_FOR_RRNA}
...    LNCEL-1:actUePowerBasedMobThr=true
...    LNCEL-1:inactivityTimer=60000
...    LNCEL/CDFIM-1:rttBdClList:idleLBRttCelResPrio=2
${HPUE_eutra_capabilities}
...    SEPARATOR=
...    D59FF41034410381FFFFFFFFFE000040100000004C5003514201D0000181D0000103D00000340001E800001A0040F400004D000D5F20000144
...    0084800154000808807740
${NomalUE_eutra_capabilities}    C59FF42032E80002BC1A3101902004408020A5407000
${ERAB_INI_SETUP_ATT_HIGH_PWR_UE}    M8006C326
${ERAB_INI_SETUP_SUCC_H_PWR_UE}    M8006C327
${ERAB_REL_ALL_ABNORMAL_H_PWR_UE}    M8006C328
${ERAB_REL_NORMAL_HIGH_PWR_UE}    M8006C329
${ERAB_REL_RRNA_HIGH_PWR_UE}    M8006C330
${ERAB_REL_DOUBLE_S1_H_PWR_UE}    M8006C331
${MAX_ACTIVE_HIGH_PWR_UE}    M8051C140
@{PM_Counters_01_04}
...    LNCEL-1:${ERAB_INI_SETUP_ATT_HIGH_PWR_UE}=3
...    LNCEL-1:${ERAB_INI_SETUP_SUCC_H_PWR_UE}=3
...    LNCEL-1:${ERAB_REL_ALL_ABNORMAL_H_PWR_UE}=1
...    LNCEL-1:${ERAB_REL_NORMAL_HIGH_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_RRNA_HIGH_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_DOUBLE_S1_H_PWR_UE}=0
...    LNCEL-1:${MAX_ACTIVE_HIGH_PWR_UE}=1
@{PM_Counters_01_19}
...    LNCEL-1:${ERAB_INI_SETUP_ATT_HIGH_PWR_UE}=1
...    LNCEL-1:${ERAB_INI_SETUP_SUCC_H_PWR_UE}=1
...    LNCEL-1:${ERAB_REL_ALL_ABNORMAL_H_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_NORMAL_HIGH_PWR_UE}=1
...    LNCEL-1:${ERAB_REL_RRNA_HIGH_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_DOUBLE_S1_H_PWR_UE}=0
...    LNCEL-1:${MAX_ACTIVE_HIGH_PWR_UE}=1
@{PM_Counters_01_24}
...    LNCEL-1:${ERAB_INI_SETUP_ATT_HIGH_PWR_UE}=1
...    LNCEL-1:${ERAB_INI_SETUP_SUCC_H_PWR_UE}=1
...    LNCEL-1:${ERAB_REL_ALL_ABNORMAL_H_PWR_UE}=1
...    LNCEL-1:${ERAB_REL_NORMAL_HIGH_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_RRNA_HIGH_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_DOUBLE_S1_H_PWR_UE}=1
...    LNCEL-1:${MAX_ACTIVE_HIGH_PWR_UE}=1
@{PM_Counters_01_27}
...    LNCEL-1:${ERAB_INI_SETUP_ATT_HIGH_PWR_UE}=4
...    LNCEL-1:${ERAB_INI_SETUP_SUCC_H_PWR_UE}=4
...    LNCEL-1:${ERAB_REL_ALL_ABNORMAL_H_PWR_UE}=2
...    LNCEL-1:${ERAB_REL_NORMAL_HIGH_PWR_UE}=0
...    LNCEL-1:${ERAB_REL_RRNA_HIGH_PWR_UE}=2
...    LNCEL-1:${ERAB_REL_DOUBLE_S1_H_PWR_UE}=0
...    LNCEL-1:${MAX_ACTIVE_HIGH_PWR_UE}=2
@{PARAMS_IN_SWCONFIG}
...    0x10041 = 5
...    0x10040 = 1
...    0x1003F = 1
...    0x340003 = 1
...    0x340005 = 1
...    0x34000E = 8006
...    0x10023=1
...    0x1002 =1
...    0x1002A=1
...    0x1002B=0x3735
...    0x1002C=0x3736
...    0x1002D=0x3734
...    0x1002E=0x3738
@{PARAMS_IN_EMIL}
...    0x2382
...    0x2381
${Timer_wait_channel_quality_change}    5

*** Test Cases ***
LTE4211_ET_01_04_E-RABs abnormal releases for HPUEs due to partial handover through S1
    [Tags]
    OnlineParamChange    ${PARAMS_FOR_01_04}
    Start Rtpm Counter
    HPUE Attach To eNB1 with 3 e-rab    ue_id=1    ue_eutra_capabilities=${HPUE_eutra_capabilities}
    UE send A2RSRP mobility event measurement report with RSRP equal to minus 102 to Enb    ue_id=1    srsrp=38    srsrq=34
    release QCI1 with cause RN_radio_resources_not_available
    S1 Handover from eNB1 cell1 to sim-eNB2    ue_id=1
    check rtpm counters    ${PM_Counters_01_04}
    [Teardown]    Local Test Teardown And Recover Env    ${PARAMS_FOR_01_04_recovery}

LTE4211_ET_01_19_E-RABs normal releases for HPUEs due to MME initiated E-RAB release with normal release per call
    [Tags]
    OnlineParamChange    ${PARAMS_FOR_01_19}
    Start Rtpm Counter
    HPUE Attach To eNB1    ue_id=2    ue_eutra_capabilities=${HPUE_eutra_capabilities}
    Normal UE Attach To eNB1    ue_id=3    ue_eutra_capabilities=${NomalUE_eutra_capabilities}
    UE Add QCI1 radio Bearer    ue_id=2
    UE Add QCI1 radio Bearer    ue_id=3
    UE Release Bearer    ue_id=2
    UE Release Bearer    ue_id=3
    check rtpm counters    ${PM_Counters_01_19}

LTE4211_ET_01_24_E-RABs releases due to double S1 detected for High Power Ues
    [Tags]
    OnlineParamChange    ${PARAMS_FOR_01_24}
    Start Rtpm Counter
    HPUE Attach To eNB1    ue_id=4    ue_eutra_capabilities=${HPUE_eutra_capabilities}
    E-RABs releases due to double S1 detected    ue_id=4    enb_id=2    cell_id=21
    check rtpm counters    ${PM_Counters_01_24}

LTE4211_ET_01_27_E-RABs Releases for HPUEs due to E-RAB release with cause radio resources not available
    [Tags]
    OnlineParamChange    ${PARAMS_FOR_01_27}
    Start Rtpm Counter
    HPUE Attach To eNB1 with special QCI    ue_id=5    ue_eutra_capabilities=${HPUE_eutra_capabilities}    qci=1
    HPUE Attach To eNB1 with special QCI    ue_id=6    ue_eutra_capabilities=${HPUE_eutra_capabilities}    qci=3
    UE start data transfer with special QCI    ue_id=5    bearer_id=6    throughput=512
    UE start data transfer with special QCI    ue_id=6    bearer_id=6    throughput=12000
    trigger congestion with make UE channel quality worse     ue_id=6
    Stop data transfer    ue_1st_id=5    ue_2nd_id=6
    check rtpm counters    ${PM_Counters_01_27}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Local Test Teardown And Recover Env
    [Arguments]    ${param}=${EMPTY}
    Delta Commission Parameters    ${param}
    Reset simenb HO config
    clear counter files
    Common Test Teardown And Stop Capture Logs

Modify Yaml
    ${QCI1}    catenate     - {qci: 1, preprovisioned: on, filter: 2, precedence: 2, gbr_ul: 512, gbr_dl: 512, mbr_ul: 512, mbr_dl: 512,
    ...     priority: 4, preemption: on, vulnerability: on, pdn: 1}
    ${QCI3}    catenate     - {qci: 3, preprovisioned: on, filter: 4, precedence: 4, gbr_ul: 512, gbr_dl: 12000, mbr_ul: 512, mbr_dl: 12000,
    ...    priority: 3, preemption: on, vulnerability: on, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, preprovisioned: on, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, filter: 1, precedence: 1, pdn: 1}
    ...     - {qci: 2, preprovisioned: on, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, filter: 2, precedence: 2, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 5, default: on, priority: 1, preemption: on, vulnerability: off, pdn: 1}
    ...     ${QCI1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 5, default: on, priority: 1, preemption: off, vulnerability: on, pdn: 1}
    ...     ${QCI3}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_4
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.31
    ...    x2: 10.0.1.31
    ...    cells:
    ...       - {id: 21, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:0', eci: '0x0000215', earfcn: '40940:40940', bw: 20}
    ...       - {id: 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:1', eci: '0x0000216', earfcn: '40940:40940', bw: 20}
    ...       - {id: 23, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:2', eci: '0x0000217', earfcn: '40940:40940', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.32
    ...    x2: 10.0.1.32
    ...    cells:
    ...       - {id: 31, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:0', eci: '0x000031F', earfcn: '41138:41138', bw: 20}
    ...       - {id: 32, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:1', eci: '0x0000320', earfcn: '41138:41138', bw: 20}
    ...       - {id: 33, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:2', eci: '0x0000321', earfcn: '41138:41138', bw: 20}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Reset simenb HO config
    Execute Egate Command    enb_param id=2 s1_ho_qci_to_reject=none
    Execute Egate Command    mme_param ue_ctx_release_cause=off

HPUE Attach To eNB1 with 3 e-rab
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}     ${cell_id}=1
    ${UE_capab_info}    catenate
    ...    UE-EUTRA-Capability contains (supportedBandListEUTRA-v1320 contains (ue-PowerClass-N-r13 eq "class2"))
    ${e-rab_req_info}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    ((e-RAB-ID eq 5) and (qCI eq 8)),
    ...    ((e-RAB-ID eq 6) and (qCI eq 1)),
    ...    ((e-RAB-ID eq 7) and (qCI eq 2))
    ...    )
    ${e-rab_Resp_info}    catenate
    ...    E-RABSetupListCtxtSURes contains (
    ...    (e-RAB-ID eq 5),
    ...    (e-RAB-ID eq 6),
    ...    (e-RAB-ID eq 7)
    ...    )
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${e-rab_req_info})
    ...    MME_1:S1AP_InitialContextSetupResponse (${e-rab_Resp_info})
    ...    MME_1:S1AP_UECapabilityInfoIndication (${UE_capab_info})
    ...    alias=ue_attach_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=ue_attach_flow

UE send A2RSRP mobility event measurement report with RSRP equal to minus 102 to Enb
    [Arguments]    ${ue_id}=1    ${srsrp}=65    ${srsrq}=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=${srsrp} srsrq=${srsrq}

release QCI1 with cause RN_radio_resources_not_available
    Execute Egate Command    enb_param id=2 s1_ho_qci_to_reject=1 s1_ho_cause_for_rejected_bearer=RN_radio_resources_not_available

S1 Handover from eNB1 cell1 to sim-eNB2
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    alias=ue_attach_flow    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} enb=2 cell=21
    Flow Occurred As Expected    alias=ue_attach_flow

HPUE Attach To eNB1
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}     ${cell_id}=1
    ${UE_capab_info}    catenate
    ...    UE-EUTRA-Capability contains (supportedBandListEUTRA-v1320 contains (ue-PowerClass-N-r13 eq "class2"))
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    MME_1:S1AP_UECapabilityInfoIndication (${UE_capab_info})
    ...    alias=HPUE_attach_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=HPUE_attach_flow

Normal UE Attach To eNB1
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}     ${cell_id}=1
    ${UE_capab_info}    catenate
    ...    UE-EUTRA-Capability contains (supportedBandListEUTRA-v1320 contains (ue-PowerClass-N-r13 eq "class2"))
    Expect Message Will Not Occur
    ...    MME_1:S1AP_UECapabilityInfoIndication (${UE_capab_info})
    ...    alias=normal_UE_attach_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Not Occurred For Message    alias=normal_UE_attach_flow

UE Add QCI1 radio Bearer
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains ((e-RAB-ID eq 6) and (qCI eq 1)))
    ...    alias=ADD_qci1_flow    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=ADD_qci1_flow

UE Release Bearer
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (cause contains (nas eq "normal-release"))
    ...    alias=release_qci1_flow    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=1
    Flow Occurred As Expected    alias=release_qci1_flow

HPUE Attach To eNB1 with special QCI
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}    ${cell_id}=1    ${qci}=1    ${bearer_id}=2
    ${UE_capab_info}    catenate
    ...    UE-EUTRA-Capability contains (supportedBandListEUTRA-v1320 contains (ue-PowerClass-N-r13 eq "class2"))
    ${e-rab_req_info}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    ((e-RAB-ID eq 5) and (qCI eq 5)),
    ...    ((e-RAB-ID eq 6) and (qCI eq ${qci}))
    ...    )
    ${e-rab_Resp_info}    catenate
    ...    E-RABSetupListCtxtSURes contains (
    ...    (e-RAB-ID eq 5),
    ...    (e-RAB-ID eq 6)
    ...    )
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${e-rab_req_info})
    ...    MME_1:S1AP_InitialContextSetupResponse (${e-rab_Resp_info})
    ...    MME_1:S1AP_UECapabilityInfoIndication (${UE_capab_info})
    ...    alias=Attach_spec_qci_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=Attach_spec_qci_flow

E-RABs releases due to double S1 detected
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=21
    Expect Message Flow
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "radio-connection-with-ue-lost"))
    ...    alias=release_qci1_flow    overall_timeout=20
    Execute Uex Command    ue_rrc_reconf_param id=${ue_id} if_contains=mobility_control_info action=drop
    execute uex command and expect error    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}    sErrMeasConfigEventNotFound
    Execute Egate Command    ue_s1_ctx_release id=${ue_id} cause_rnl=radio_connection_with_ue_lost    UE state at MME is IDLE
    Flow Occurred As Expected    alias=release_qci1_flow

UE start data transfer with special QCI
    [Arguments]    ${ue_id}    ${bearer_id}    ${throughput}
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=${bearer_id} dir=dl kbps=${throughput} protocol=udp

trigger congestion with make UE channel quality worse
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=8:8:1    #no return string
    Sleep    ${Timer_wait_channel_quality_change}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=2:2:1

Stop data transfer
    [Arguments]    ${ue_1st_id}    ${ue_2nd_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseIndication (cause contains (radioNetwork eq "radio-resources-not-available"))
    ...    MME_1:S1AP_E-RABReleaseIndication (cause contains (radioNetwork eq "radio-resources-not-available"))
    ...    alias=release_bearer_flow    overall_timeout=20
    Execute Uex Command    trf_data_stop ue=${ue_1st_id} bearer=6
    Execute Uex Command    trf_data_stop ue=${ue_2nd_id} bearer=6
    Flow Occurred As Expected    alias=release_bearer_flow