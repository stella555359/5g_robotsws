*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG2    owner-Shelly.Song    release-SBTS20A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    0x10041 = 5    #ERadCcs_AaSysLogOutputMode - 0=none,1=all,2=udp,3=sic,4=stdout, 5=local, 6=remote
...    0x10040 = 1    #ERadCcs_AaSysLogOutputLevel - Severity: 1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
...    0x1003f = 1    #ERadCcs_AaSysLogInputLevel - Severity: 1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
...    0x340001 = 1    #enable BStat core flag
...    0x340002 = 1    #BSTAT PM debug prints
...    0x340006 = 8080    #BSTAT enable measurement reporting prints
...    0x0010001A=0x7F5    #TCommonRadShbRecordEnabled

${SIM_GNB7_CELL_1_NRARFCN_531000}    531040

@{PARAMS_IN_SCF}
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS:actMultBearers=true
...    LNBTS:actMultiSCGSplit=true
...    LNBTS:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-3:harqMaxTrVoLteDl=4
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    LNBTS:actVoLteNoEnDc=disabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/SIB-0:pMaxOwnCell=-10
...    @{NRDCPR}
...    @{X2_Link_LNADJGNB}
...    @{LNRELGNBCELL}
...    @{qciTab6}
...    @{pdcpProfileId}
...    @{Emergency QCI}
...    @{QCI65and66}
...    @{NRDCDPR}
...    @{qciTab7}
...    @{qciTab8}
...    @{relation_error_fixed}

@{relation_error_fixed}
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS/LNBTS_FDD-0:skipPsQciUeReleaseCheck=true
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled

@{NRDCDPR}
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${SIM_GNB7_CELL_1_NRARFCN_531000}    # 531040 ${NRARFCN531198}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=100
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-87
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=6
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=7
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4

@{NRDCPR}
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=100
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${SIM_GNB7_CELL_1_NRARFCN_531000}    # 531040 ${NRARFCN531198}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCPR-0:enDCpMaxEUTRApowerOffset=4
...    LNBTS/NRDCPR-0:enDCpMaxNRpowerOffset=5
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrq=-87

@{X2_Link_LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11

@{LNRELGNBCELL}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{pdcpProfileId}
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms

@{Emergency QCI}
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:hpsSessConfig:hpsSessArpMax=4
...    LNBTS:hpsSessConfig:hpsSessArpMin=1
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false
...    LNBTS:imsEmerPlmnConfig:emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessMnc=3
...    LNBTS:imsEmerPlmnConfig:emerSessMncLen=2
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=200
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=100
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addEmergencySessions=1
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS/LNBTS_FDD-0:actHighPrioServices=true

@{qciTab6}
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab6:nrPdcpProfIdx=1001

@{qciTab7}
...    LNBTS:qciTab7:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab7:nrPdcpProfIdx=1001

@{qciTab8}
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab8:nrPdcpProfIdx=1001

@{QCI65and66}
...    LNBTS:actOperatorQCI=true
...    LNBTS:qciTab65:lcgid=1
...    LNBTS:qciTab65:maxGbrDl=31
...    LNBTS:qciTab65:maxGbrUl=31
...    LNBTS:qciTab65:pdcpProfIdx=101
...    LNBTS:qciTab65:qci=65
...    LNBTS:qciTab65:qciSupp=ENABLE
...    LNBTS:qciTab65:rlcProfIdx=101
...    LNBTS:qciTab65:schedulPrio=5
...    LNBTS:qciTab66:lcgid=1
...    LNBTS:qciTab66:maxGbrDl=31
...    LNBTS:qciTab66:maxGbrUl=31
...    LNBTS:qciTab66:pdcpProfIdx=101
...    LNBTS:qciTab66:qci=66
...    LNBTS:qciTab66:qciSupp=ENABLE
...    LNBTS:qciTab66:rlcProfIdx=101
...    LNBTS:qciTab66:schedulPrio=5
...    LNBTS/LNBTS_FDD-0:actPubSafetyBearers=true
...    LNCEL-1:inactivityTimerPubSafety=1000
...    LNCEL-2:inactivityTimerPubSafety=1000
...    LNCEL-3:inactivityTimerPubSafety=1000

@{Ream-Enb1_LNADJGNB-1_To_Sim-Gnb_7}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS/LNADJGNB-1:x2ToGnbLinkStatus=available

@{Ream-Enb1_LNADJ-255_To_Sim-Enb_2}
...    LNBTS/LNADJ-255:adjEnbId=2
...    LNBTS/LNADJ-255:cPlaneIpAddr=10.0.1.3
...    LNBTS/LNADJ-255:x2LinkStatus=available

@{actDynTrigLteNrDualConnectivity}
...    LNBTS:actDynTrigLteNrDualConnectivity=false

@{actVoLteNoEnDc to QCI65 and QCI66 calls}
...    LNBTS:actVoLteNoEnDc=QCI65 and QCI66 calls

@{actVoLteNoEnDc to QCI6566 and emergency QCI1 calls}
...    LNBTS:actVoLteNoEnDc=QCI65/66 and emergency QCI1

@{actVoLteNoEnDc to non-emergency QCI1 calls}
...    LNBTS:actVoLteNoEnDc=non-emergency QCI1 calls

@{actVoLteNoEnDc to disable}
...    LNBTS:actVoLteNoEnDc=disabled

${SGNB_REL_INIT_MENB_VOLTE}    M8080C75
${SCG_REL_INIT_MENB_VOLTE}    M8080C76

@{PM_COUNTER_FOR_LTE5388-A-c_ET_01_01}
...    LNCEL-1:${SGNB_REL_INIT_MENB_VOLTE}=1
...    LNCEL-1:${SCG_REL_INIT_MENB_VOLTE}=3

@{PM_COUNTER_FOR_CASE05}
...    LNCEL-1:${SGNB_REL_INIT_MENB_VOLTE}=1
...    LNCEL-1:${SCG_REL_INIT_MENB_VOLTE}=1

${PM_COUNTER_INTERVAL}    1min

${ue_eutra_capabilities}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C6800033C00000180000009000820840

${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004

*** Test Cases ***
LTE5388-A-a_ET_01_01_Feature activation and deactivation with actVoLteNoEnDc is set disable QCI65andQCI66 and non-emergency QCI1 calls
    [Tags]
    UE attach eNB1 cell1 with QCI65 QCI66 and QCI6 then B1 was activated cause feature disable    ue_id=1
    Detach UE1 and online change actVoLteNoEnDc to QCI65 and QCI66 calls
    UE attach eNB1 cell1 with QCI65 QCI66 and QCI6 with no B1    ue_id=1
    UE attach eNB1 cell1 with QCI1 and QCI6 with B1    ue_id=2
    Online Change parameters actVoLteNoEnDc to QCI6566 and emergency QCI1 calls
    UE setup with emergency QCI1 With PDN3    ue_id=2
    Online Change parameters actVoLteNoEnDc to disable
    UE1 Release QCI65 and UE2 Release emergency QCI1
    UE1 Release QCI66 and UE2 Release normal QCI1

LTE5388-A-c_ET_01_01_Normal QCI1 trigger take back of established EN-DC
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Start RTPM Counter
    Online Change parameters actVoLteNoEnDc to non-emergency QCI1 calls
    Check X2 Availble Between Real-ENB_1 and Sim-GNB_7
    UE attach eNB1 cell1 with QCI6 QCI7 and QCI8 then B1 was activated    ue_id=3
    B1 trigger SgNB addition produce Successful with QCI6 QCI7 QCI8    ue_id=3
    UE setup normal QCI1 With PDN1 and setup emergency QCI5 QCI1 With PDN3    ue_id=3
    UE release normal QCI1 bearer and release emergency QCI1 bearer    ue_id=3
    Detach UE    ue_id=3
    sleep    360
    Check RTPM Counters    ${PM_COUNTER_FOR_LTE5388-A-c_ET_01_01}

LTE5388-A-c_ET_05_01_QCI65 QCI66 and emergencyQCI1 trigger take back of established EN-DC
    [Tags]
    Start RTPM Counter
    Online Change parameters actVoLteNoEnDc to QCI6566 and emergency QCI1 calls
    Online Change parameters actDynTrigLteNrDualConnectivity to disable
    Check X2 Availble Between Real-ENB_1 and Sim-GNB_7
    Check ANR Setup X2 Availble Between Real-ENB_1 and Sim-ENB_2
    UE attach eNB1 cell1 bearer change from MCG to SCG    ue_id=4
    UE setup QCI66 QCI65 With PDN1 and setup emergency QCI1 With PDN3    ue_id=4
    UE release emergency QCI1 and release normal QCI66 QCI65    ue_id=4
    Detach UE    ue_id=4
    Check RTPM Counters    ${PM_COUNTER_FOR_CASE05}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Set UE parameters before ENDC setup
    Create Alias

Set UE parameters before ENDC setup
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Config UE1 to UE4
    Config gnb7

Config UE1 to UE4
    FOR    ${ue_id}    IN RANGE    1    5
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=7
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=77
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=78
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=79
        Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
    END

Config gnb7
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    Execute Egate Command    enb_param id=7 endc_capable_qci=6,7,8
    Execute Egate Command    enb_x2_link_up enb=7 target=1    X2 link with eNB-1 is activated already
    Execute Egate Command    enb_x2_link_up enb=2 target=1    X2 link with eNB-1 is activated already
    Execute Egate Command    enb_x2_link_up enb=2 target=7    is up
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}    #531040
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '179500:188500'}    #188512
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2: 10.0.1.12
    ...      x2_peers: 1
    ...      cells:
    ...        ${GNB8_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '3:0', earfcn: '1450:19400', bw: 20, status: 'enabled'}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 6, default: on, pdn: 1}
    ...      - {qci: 7, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    ...      - {qci: 66, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 2, precedence: 2, priority: 2}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...      - {qci: 6, default: on, pdn: 1}
    ...      - {qci: 8, default: on, pdn: 2}
    ...      - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 1, precedence: 1, priority: 1, pdn: 1}
    ...      - {qci: 65, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {qci: 66, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {pdn: 3, qci: 5, default: on}
    ...      - {pdn: 3, qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_3
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...      - {pdn: 1, qci: 6, default: on, preprovisioned: off, priority: 1}
    ...      - {pdn: 1, qci: 7, default: off, preprovisioned: on, priority: 2, filter: 2, precedence: 2}
    ...      - {pdn: 1, qci: 8, default: off, preprovisioned: on, priority: 3, filter: 3, precedence: 3}
    ...      - {pdn: 1, qci: 1, default: off, preprovisioned: off, priority: 4, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 1, qci: 65, default: off, preprovisioned: off, priority: 5, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 1, qci: 66, default: off, preprovisioned: off, priority: 6, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 3, qci: 5, default: on, preprovisioned: off, priority: 1}
    ...      - {pdn: 3, qci: 1, default: off, preprovisioned: on, priority: 2, filter: 2, precedence: 2,
    ...         mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    Update Yaml    UEs/UE_sets/3     bearer: bearer_set_4
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...      - {pdn: 1, qci: 6, default: on, preprovisioned: off, priority: 1}
    ...      - {pdn: 1, qci: 7, default: off, preprovisioned: off, priority: 2}
    ...      - {pdn: 1, qci: 8, default: off, preprovisioned: off, priority: 3}
    ...      - {pdn: 1, qci: 1, default: off, preprovisioned: off, priority: 4, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 1, qci: 65, default: off, preprovisioned: off, priority: 5, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 1, qci: 66, default: off, preprovisioned: off, priority: 6, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 3, qci: 5, default: on, preprovisioned: off, priority: 1}
    ...      - {pdn: 3, qci: 1, default: off, preprovisioned: on, priority: 2, filter: 2, precedence: 2,
    ...         mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    Update Yaml    UEs/UE_sets/4     bearer: bearer_set_5

Online Change parameters actVoLteNoEnDc to non-emergency QCI1 calls
    Delta Commission Parameters    @{actVoLteNoEnDc to non-emergency QCI1 calls}
    Cells Should Be OnAir

Online Change parameters actVoLteNoEnDc to QCI6566 and emergency QCI1 calls
    Delta Commission Parameters    @{actVoLteNoEnDc to QCI6566 and emergency QCI1 calls}
    Cells Should Be OnAir

Online Change parameters actDynTrigLteNrDualConnectivity to disable
    Delta Commission Parameters    @{actDynTrigLteNrDualConnectivity}
    Cells Should Be OnAir

Online Change actVoLteNoEnDc to QCI65 and QCI66 calls
    Delta Commission Parameters    @{actVoLteNoEnDc to QCI65 and QCI66 calls}
    Cells Should Be OnAir

Online Change parameters actVoLteNoEnDc to disable
    Delta Commission Parameters    @{actVoLteNoEnDc to disable}
    Cells Should Be OnAir

UE attach eNB1 cell1 with QCI65 QCI66 and QCI6 then B1 was activated cause feature disable
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${QCI6_QCI65_QCI66}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 65,
    ...    e-RAB-ID eq 7 and qCI eq 66)
    ${B1NRActivation}    catenate
    ...    measObjectToAddModList contains (carrierFreq eq 1400, carrierFreq-r15 eq 531040) and
    ...    reportConfigInterRAT contains (b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 100)) and
    ...    reportOnLeave-r15 eq "TRUE" and
    ...    measIdToAddModList contains (measId eq 17) and
    ...    gapOffset contains (gp0 eq 16)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI6_QCI65_QCI66} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${B1NRActivation} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities} 
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach

UE attach eNB1 cell1 with QCI65 QCI66 and QCI6 with no B1
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qci_id_1}=65    ${qci_id_2}=66
    ${QCI6_QCI65_QCI66}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 65,
    ...    e-RAB-ID eq 7 and qCI eq 66)
    ${B1NRActivation}    catenate
    ...    b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 100)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI6_QCI65_QCI66} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measObjectToAddModList contains (carrierFreq eq 1400))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${B1NRActivation})
    ...    alias=UE_${ue_id}_attach_no_B1    overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities} 
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach
    Flow Not Occurred For Message    alias=UE_${ue_id}_attach_no_B1

UE attach eNB1 cell1 with QCI1 and QCI6 with B1
    [Arguments]    ${ue_id}=2    ${cell_id}=1
    ${QCI1_QCI6}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 1)
    ${B1NRActivation}    catenate
    ...    b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 100)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI1_QCI6} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1NRActivation})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities} 
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach

UE attach eNB1 cell1 with QCI6 QCI7 and QCI8 then B1 was activated
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    ${QCI6_QCI7_QCI8}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 7,
    ...    e-RAB-ID eq 7 and qCI eq 8)
    ${B1NRActivation}    catenate
    ...    measObjectToAddModList contains (carrierFreq eq 1400, carrierFreq-r15 eq 531040) and
    ...    reportConfigInterRAT contains (b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 100)) and
    ...    reportOnLeave-r15 eq "TRUE" and
    ...    measIdToAddModList contains (measId eq 17) and
    ...    gapOffset contains (gp0 eq 16)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI6_QCI7_QCI8} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${B1NRActivation} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities} 
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach

UE attach eNB1 cell1 bearer change from MCG to SCG
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    ${V_3}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_3}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach

B1 trigger SgNB addition produce Successful with QCI6 QCI7 QCI8
    [Arguments]    ${ue_id}=1    ${phycell_id}=1    ${blacklist_measureid}=1,2,4,7
    ${QCI6_QCI7_QCI8_ReqList}    catenate
    ...    E-RABs-ToBeAdded-SgNBAddReqList contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 7,
    ...    e-RAB-ID eq 7 and qCI eq 8)
    ${QCI6_QCI7_QCI8_AckList}    catenate
    ...    E-RABs-Admitted-ToBeAdded-SgNBAddReqAckList contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 7,
    ...    e-RAB-ID eq 7 and qCI eq 8)	
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (${QCI6_QCI7_QCI8_ReqList})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge (${QCI6_QCI7_QCI8_AckList})
    ...    GNB_7:X2AP_SgNBReconfigurationComplete
    ...    GNB_7:X2AP_SNStatusTransfer
    ...    alias=ENDC_for_UE_${ue_id}    overall_timeout=30
    ${endc_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${phycell_id} nrsrp=50 meas_id_blacklist=${blacklist_measureid}
    Flow Occurred As Expected    alias=ENDC_for_UE_${ue_id}

UE setup with emergency QCI1 With PDN3
    [Arguments]    ${ue_id}=1    ${qci_id}=1    ${eRAB}=8    ${apn_name}=emergency.nsn.com
    ${normal_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 1 and priorityLevel eq 'highest')
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_E-RABSetupRequest (${normal_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    alias=UE_${ue_id}_bearer_add_qci_${qci_id}     overall_timeout=30
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=${apn_name} request_type=emergency
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_add_qci_${qci_id}

UE setup with emergency QCI5 QCI1 With PDN3
    [Arguments]    ${ue_id}=3    ${qci_id}=1    ${eRAB_QCI5}=9    ${eRAB_QCI1}=10    ${apn_name}=emergency.nsn.com
    ${QCI_5}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB_QCI5} and qCI eq 5 and priorityLevel eq 'highest')
    ${QCI_1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB_QCI1} and qCI eq 1 and priorityLevel eq 2)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_E-RABSetupRequest (${QCI_5})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB_QCI5}))
    ...    MME_1:S1AP_E-RABSetupRequest (${QCI_1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB_QCI1}))
    ...    alias=UE_${ue_id}_bearer_add_qci_${qci_id}     overall_timeout=30
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=${apn_name} request_type=emergency
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_add_qci_${qci_id}

UE setup with normal QCI1 With PDN1 and Check SgNBRelease and M8080C75 add 1
    [Arguments]    ${ue_id}=1    ${qci_id}=1    ${apn_name}=nokia_1.net
    ${QCI_1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 8 and qCI eq 1 and priorityLevel eq 4)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_E-RABSetupRequest (${QCI_1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 8))
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    alias=UE_${ue_id}_bearer_add_qci_${qci_id}     overall_timeout=30
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci_id} apn=${apn_name} mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_add_qci_${qci_id}

UE ERAB setup with QCI65
    [Arguments]    ${ue_id}=1    ${eRAB}=7    ${qci_id}=65    ${apn_name}=nokia_1.net
    ${qci65}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 65 and priorityLevel eq 5)
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci65})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    alias=UE_${ue_id}_bearer_add_qci_${qci_id}     overall_timeout=30
    Execute Uex Command    bearer_add ue=${ue_id} qci=65 apn=${apn_name} mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_add_qci_${qci_id}

UE ERAB setup with QCI66 successfully Than eNB trigger the SgNB take back procedure
    [Arguments]    ${ue_id}=4    ${eRAB}=6    ${qci_id}=66    ${apn_name}=nokia_1.net
    ${qci66}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 66 and priorityLevel eq 6)
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci66})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    alias=UE_${ue_id}_bearer_add_qci_${qci_id}    overall_timeout=30
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci_id} apn=${apn_name} mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_add_qci_${qci_id}

UE release emergency QCI1
    [Arguments]    ${ue_id}=1    ${qci_id}=1    ${apn_name}=emergency.nsn.com
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=UE_${ue_id}_bearer_del_qci_${qci_id}    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id} apn=${apn_name}
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_del_qci_${qci_id}

UE release normal QCI1
    [Arguments]    ${ue_id}=1    ${qci_id}=1    ${apn_name}=nokia_1.net
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id} apn=${apn_name}

UE1 Release QCI65 and UE2 Release emergency QCI1
    UE release QCI    ue_id=1    qci_id=65    apn_name=nokia_1.net
    UE release emergency QCI1    ue_id=2    qci_id=1    apn_name=emergency.nsn.com

UE1 Release QCI66 and UE2 Release normal QCI1
    UE release QCI    ue_id=1    qci_id=66    apn_name=nokia_1.net
    UE release QCI    ue_id=2    qci_id=1    apn_name=nokia_1.net

UE release QCI65 bearer change from MCG to SCG
    [Arguments]    ${ue_id}=1    ${qci_id}=65
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=ENDC_for_UE_${ue_id}    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id}
    Flow Occurred As Expected    alias=ENDC_for_UE_${ue_id}

UE release QCI
    [Arguments]    ${ue_id}=1    ${qci_id}=65    ${apn_name}=nokia_1.net
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=UE_${ue_id}_bearer_del_qci_${qci_id}    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id} apn=${apn_name}
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_del_qci_${qci_id}

Detach UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Detach UE1 and online change actVoLteNoEnDc to QCI65 and QCI66 calls
    Detach UE
    Online Change actVoLteNoEnDc to QCI65 and QCI66 calls

UE setup normal QCI1 With PDN1 and setup emergency QCI5 QCI1 With PDN3
    [Arguments]    ${ue_id}=3
    UE setup with normal QCI1 With PDN1 and Check SgNBRelease and M8080C75 add 1    ue_id=${ue_id}    qci_id=1
    UE setup with emergency QCI5 QCI1 With PDN3    ue_id=${ue_id}    eRAB_QCI5=9    eRAB_QCI1=10

UE release normal QCI1 bearer and release emergency QCI1 bearer
    [Arguments]    ${ue_id}=3
    UE release normal QCI1    ue_id=${ue_id}    qci_id=1
    UE release emergency QCI1    ue_id=${ue_id}    qci_id=1

UE setup QCI66 QCI65 With PDN1 and setup emergency QCI1 With PDN3
    [Arguments]    ${ue_id}=4
    UE ERAB setup with QCI66 successfully Than eNB trigger the SgNB take back procedure    ue_id=${ue_id}
    UE ERAB setup with QCI65    ue_id=${ue_id}
    UE setup with emergency QCI5 QCI1 With PDN3    ue_id=4    eRAB_QCI5=8    eRAB_QCI1=9

UE release emergency QCI1 and release normal QCI66 QCI65
    [Arguments]    ${ue_id}=4
    UE release emergency QCI1    ue_id=${ue_id}    qci_id=1
    UE release QCI    ue_id=${ue_id}    qci_id=66
    UE release QCI65 bearer change from MCG to SCG    ue_id=${ue_id}    qci_id=65

Check X2 Availble Between Real-ENB_1 and Sim-GNB_7
    Object Should Exist    ${Ream-Enb1_LNADJGNB-1_To_Sim-Gnb_7}

Check ANR Setup X2 Availble Between Real-ENB_1 and Sim-ENB_2
    Object Should Exist    ${Ream-Enb1_LNADJ-255_To_Sim-Enb_2}
