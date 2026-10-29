*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               CLOUD_R4P    owner-chenghong.li    team-RT1    release-legacy
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${Debug}    ${False}
${SOS_REPORT_FLAG}    pass:False,fail:False
${WIRESHARK_FLAG}    ${False}
${UTE_WIRESHARK_FLAG}    ${False}

@{PARAMS_IN_SCF}
...  @{Related_Feature_Switch}
@{Related_Feature_Switch}
...  LNCEL-1:threshold2InterFreq=20
...  LNCEL-1:threshold2a=85
...  LNCEL-1:threshold2aQci1=70
...  LNBTS:actIfHo=enabled
...  LNBTS:actLTES1Ho=true
...  LNCEL:actInterFreqLB=false
...  LNBTS/LNBTS_TDD-0:actConvVoice=true
...  LNBTS:actMultBearers=true
...  LNCEL-1:inactivityTimer=2000
...  LNCEL/LNCEL_TDD-0:earfcn=38000
...  LNBTS:actServBasedMobThr=true
...  LNCEL:actIntraFreqLoadBal=false
...  LNCEL-1:iFServiceBasedHoRetryTimer=60
@{delta_para_02}
...  LNBTS_TDD-0:actInterFreqServiceBasedHo=true
...  LNBTS:actSelMobPrf=true
...  LNCEL-1:moPrMappingList:moPrId=1
...  LNCEL-1:moPrMappingList:spid=1
...  LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=50
#fix error...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=0
...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=1
#fix error...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=0
...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=1
#fix error...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=0
...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
#fix error...  LNCEL-1:loadSettings:targetLoadGbrDl=0
...  LNCEL-1:loadSettings:targetLoadGbrDl=1
#fix error...  LNCEL-1:loadSettings:targetLoadNonGbrDl=0
...  LNCEL-1:loadSettings:targetLoadNonGbrDl=1
#fix error...  LNCEL-1:loadSettings:targetLoadPdcch=0
...  LNCEL-1:loadSettings:targetLoadPdcch=1
...  MODPR-0:autoAdapt=false
...  MODPR-0:freqLayListServiceBasedHo=38050,38015
...  MOPR-1:freqLayListServiceBasedHo=38050,38025
...  delete:MODPR-0:freqLayListLte
...  delete:MOPR-1:freqLayListLte
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=38050
...  LNCEL-1/LNHOIF-1:thresholdRsrpIFSBFilter=-100
...  LNCEL-1/LNHOIF-2:eutraCarrierInfo=38015
...  LNCEL-1/LNHOIF-3:eutraCarrierInfo=38025
...  LNBTS/LNBTS_TDD-0:actDedVoLteInterFreqHo=false
...  delete:LNCEL-1/LNHOIF-1:thresholdRsrqIFSBFilter
...  LNCEL-1:blacklistHoL:blacklistTopo=onlyX2
...  LNCEL-1:blacklistHoL:freqEutra=38050
...  LNCEL-1:blacklistHoL:phyCellIdStart=0
...  LNCEL-1:blacklistHoL:phyCellIdRange=n504
#${lua_ue_simenb_2}    {True}
#${simenb_2_earfcn}    38050:38050
${HO_SB_ATT}      M8021C7    # Number of service based handover attempts
${HO_SB_SUCC}     M8021C8    # Number of successful service based handover completions
${HO_PREP_IN_ATT}    M8021C25    # Incoming handover preparation attempts
${HO_PREP_IN_SUCC}    M8021C30    # Successful incoming handover preparations
@{PM_Counters}
...  LNCEL-1:${HO_SB_ATT}=1
...  LNCEL-1:${HO_SB_SUCC}=1
...  LNCEL-1:${HO_PREP_IN_ATT}>=1
...  LNCEL-1:${HO_PREP_IN_SUCC}>=1

${ue1_capa}    919FF43A33E6CB0007FFFFFFFC00

${QCI1andIFSB}
...    measConfig contains (
...      measObjectToAddModList contains (
...        measObjectEUTRA contains (carrierFreq eq 38050)
...        ,
...        measObjectEUTRA contains (carrierFreq eq 38015)
...      )and
...      measIdToAddModList contains (measId eq 31)
...      and
...      s-Measure eq 0
...    )

${AddMeasID30and31}
...    measIdToAddModList contains (
...      measId eq 31,
...      measId eq 30
...    )

${DelMeasID30and31}
...    measIdToRemoveList contains (
...      31,
...      30
...    )

*** Test Case ***
LTE1127-A_01_02_SB Measurement Setup after QCI1 E-RAB setup in source cell and S1HO
    [Tags]
    Online parameter change
    UE attach without QCI1 bearer and IFSB is not activated
    QCI5_Bearer_Setup
    QCI1_Bearer_Setup and IFSB activated
    A4 IFSB S1HO
    eNB42 Ho To eNB-Cell1
    QCI1BearerRelease
    UE detach_02
    Check Counters    ${PM_Counters}


*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on

Modify Yaml
 # add bear
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 5, pdn: 1}

    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2

    ${ENB2_CELL1}    catenate    - {id: 21, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:0',
    ...    earfcn: '38050:38050', bw: 20}
 # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      cells:
    ...        ${ENB2_CELL1}



Online parameter change
    Delta Commission Parameters    ${delta_para_02}
    Cells Should Be OnAir

UE attach without QCI1 bearer and IFSB is not activated
    [Arguments]    ${ue_id}=1    ${ue_capa}=${ue1_capa}
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1andIFSB})
    ...    alias=attach_no_QCI1_IFSB_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=1 cell=${ue_id} ue_eutra_capabilities=${ue_capa}
    Flow Not Occurred For Message    alias=attach_no_QCI1_IFSB_flow

QCI5_Bearer_Setup
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
    ...    alias=UE_Add_QCI5    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1andIFSB})
    ...    alias=attach_no_QCI1_IFSB_flow    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=5
    Flow Occurred As Expected    alias=UE_Add_QCI5
    Flow Not Occurred For Message    alias=attach_no_QCI1_IFSB_flow

QCI1_Bearer_Setup and IFSB activated
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1andIFSB})
    ...    alias=UE_Add_QCI1    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 apn=nokia_1.net gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Flow Occurred As Expected    alias=UE_Add_QCI1

A4 IFSB S1HO
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${AddMeasID30and31})
    ...    alias=trfdata    overall_timeout=140
    Execute Uex Command    trf_data_start ue=1 dir=ul protocol=udp Mbps=1 stats=true
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=1 stats=true
    Flow Occurred As Expected    alias=trfdata
    Expect Message Flow
    ...    UE_${ue_id}:RRC_MeasurementReport (measId eq 31)
    ...    MME_1:S1AP_HandoverRequest (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    alias=IFSBHO    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A4 phycell_id=9 nrsrp=60 nrsrq=33 srsrp=50 srsrq=32
    Flow Occurred As Expected    alias=IFSBHO

eNB42 Ho To eNB-Cell1
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "handover-desirable-for-radio-reasons"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1andIFSB})
    ...    alias=UE_HO_CELL2    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_HO_CELL2


Qci1BearerRelease
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${DelMeasID30and31})
    ...    alias=QCI1Del    overall_timeout=20
    Execute Uex Command   bearer_del ue=${ue_id} qci=1
    Flow Occurred As Expected    alias=QCI1Del

UE detach_02
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease
    ...    alias=Detach_UE_Flow    overall_timeout=5
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=Detach_UE_Flow
