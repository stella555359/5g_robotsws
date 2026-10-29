*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    release-SBTS21A
...               team-CN3ET    owner-wendy.yu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS:actMultBearers=true
...    LNBTS:actMultiSCGSplit=true
...    LNBTS:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL:harqMaxTrVoLteDl=4
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL:tac=33
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    LNBTS:actVoLteNoEnDc=disabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/SIB-0:pMaxOwnCell=-10
...    @{NRDCPR}
...    @{LNADJGNB}
...    @{LNRELGNBCELL}
...    @{qciTab6}
...    @{pdcpProfileId}
...    @{Emergency QCI}
...    @{QCI65and66}
...    @{NRDCDPR}
...    @{qciTab7}
...    @{qciTab8}
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actVoLteNoEnDcDrop=true
...    LNBTS:act8EpsBearers=true
...    @{FixRelationErrors}
@{NRDCDPR}
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=531232
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
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=531232
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
@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNRELGNBCELL}
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
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
...    LNCEL:inactivityTimerPubSafety=1000
@{FixRelationErrors}
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS/LNBTS_FDD-0:skipPsQciUeReleaseCheck=true


${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
${ue_eutra_capabilities_1&2}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C6800033C00000180000009000820840

${ue_eutra_capabilities_3}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E8000000074
...    00000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000
...    07400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC800801C36400000001
...    7BA000000080952A0E2740400000820001080002180004400008A00011800023800048000092000128000258000
...    4C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F000
...    06D0000FE003A7400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400
...    000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0
...    0000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007
...    400000003A0000000141000000F3A00000000000000000000000000000000000000000000000000000000000202
...    388425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080

${gnb7_cell1}
...    {id: 1, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531198',eci: '0x0000404',
...    earfcn: '1400:19400', shared_plmn: '262:03'}

@{actVoLteNoEnDc to non-emergency QCI1 calls}
...    LNBTS:actVoLteNoEnDc=non-emergency QCI1 calls

@{actVoLteNoEnDcDrop_ENABLE}
...    LNBTS:actVoLteNoEnDcDrop=true

@{actVoLteNoEnDcDrop_DISABLE}
...    LNBTS:actVoLteNoEnDcDrop=false

@{parames_case2}
...    LNBTS:actVoLteNoEnDc=QCI65/66 and emergency QCI1
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS:actVoLteNoEnDcDrop=true

@{parames_case4}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actVoLteNoEnDc=non-emergency QCI1 calls
...    LNBTS:actVoLteNoEnDcDrop=true
...    LNBTS:actHoWoSnChg=intraEnbHoEnabled

${SGNB_REL_INIT_MENB_VOLTE}    M8080C75
${SCG_REL_INIT_MENB_VOLTE}    M8080C76
${SGNB_MOD_SUCC_IA_HO}    M8080C22
${SGNB_RECONFIG_IA_HO}    M8080C25

@{PM_COUNTERS_KEEP_ZERO_FOR_CNI58993}
...    LNCEL-1:${SGNB_REL_INIT_MENB_VOLTE}=0
...    LNCEL-1:${SCG_REL_INIT_MENB_VOLTE}=0

@{PM_COUNTERS_ADD_ONE}
...    LNCEL-1:${SGNB_REL_INIT_MENB_VOLTE}=1
...    LNCEL-1:${SCG_REL_INIT_MENB_VOLTE}=1

@{PM_COUNTER_FOR_CASE02}
...    LNCEL-1:${SGNB_REL_INIT_MENB_VOLTE}=0
...    LNCEL-1:${SCG_REL_INIT_MENB_VOLTE}=0

@{PM_COUNTER_FOR_CASE04}
...    LNCEL-1:${SGNB_MOD_SUCC_IA_HO}=1
...    LNCEL-1:${SGNB_RECONFIG_IA_HO}=0

${PM_COUNTER_INTERVAL}    1min

*** Test Cases ***
CNI-58993-A-a_ET_01_01_Normal_QCI1_Not_Trigger_Takeback_Of_Established_EN-DC_When_CNI_Enable
    [Documentation]    This test case is to verify when set LTE5388 enable and tmpActFeat1 bit28 to true or set actVoLteNoEnDcDrop to true,
    ...    then Normal QCI will not trigger take back of established EN-DC when UE is in EN-DC mode.
    [Tags]
    Online Change Parameters ActVoLteNoEnDc To Non-emergency QCI1 Calls
    Normal QCI1 Should Not Trigger Takeback Of Established EN-DC When CNI58993 Enable
    Normal QCI1 Should Trigger Takeback Of Established EN-DC When CNI58993 Disable
    Normal QCI1 Should Not Trigger Takeback Of Established EN-DC When CNI58993 Enable Again
    UE Release QCI1 Bearer And Detach

CNI-58993-A-a_ET_02_01_QCI65_QCI66_EmergQCI1_Not_Trig_Takeback_Of_Established_EN-DC_If_CNI_Enable
    [Documentation]    This test case is to verify when set LTE5388 enable and tmpActFeat1 bit28 to true or set actVoLteNoEnDcDrop to true,
    ...    then QC65 and QCI66 and emergency QCI1 will not trigger take back of established EN-DC when UE is in EN-DC mode
    [Tags]
    Start RTPM Counter
    Online Change Parameters For Case02
    CUS UE Attach eNB1 Cell1 Bearer Change From MCG To SCG
    CUS UE Setup QCI 66 65 And Emergency QCI1
    Check Rtpm Counters    ${PM_COUNTER_FOR_CASE02}
    UE Detach And Check SgNB Release

CNI-58993-A-a_ET_04_01_SCG_Should_Keep_After_IntraHO_When_CNI_Enable
    [Documentation]    This test case is to verify inter-work with LTE4281, when set LTE5388 enable and tmpActFeat1 bit28 to 1
    ...    or set actVoLteNoEnDcDrop to true and set actHoWoSnChg to 1(intraEnbHoEnabled), then SCG should be kept after handover.
    [Tags]
    Start RTPM Counter
    Online Change Parameters For Case04
    CUS UE Attach To eNB1 And B1MR Trigger SgNB Addition Produce    ue_id=6
    CUS UE Setup Emergency QCI1 And Trigger Intra ENB HandOver
    Check Rtpm Counters    ${PM_COUNTER_FOR_CASE04}
    UE Detach

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO    ue_count=11
    Config Alias
    Set UE parameters before ENDC setup

Config Alias
    Create UE Alias for mulipule UEs
    Create Enb alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Create UE Alias for mulipule UEs
    FOR    ${ue_id}    IN RANGE    1    7
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set UE parameters before ENDC setup
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Config UE1 to UE6
    Config gnb7

Config UE1 to UE6
    FOR    ${ue_id}    IN RANGE    1    7
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
    END

Config gnb7
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    Execute Egate Command    enb_param id=2 endc_capable_qci=6
    Execute Egate Command    enb_x2_link_up enb=2 target=7    is up
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Set UE parameters for ENDC capability
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=7
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=77
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=78
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=79
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'ulm_pgw3.net'
    ...    devtype: 'tun'
    ...    devname: 'tunPGW3'
    ...    emergency: 'on'
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...      - ${gnb7_cell1}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '3:0', earfcn: '1450:19400', bw: 20, status: 'enabled'}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...      - {qci: 6, default: on, pdn: 1, trf_type: internal}
    ...      - {qci: 7, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {qci: 66, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
     ...     - {qci: 6, default: on, pdn: 2}
    ...      - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, pdn: 2}
    ...      - {qci: 5, default: on, pdn: 3, priority: 1}
    ...      - {qci: 1, pdn: 3, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31,
    ...         preemption: 1, vulnerability: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    FOR    ${ue_id}     IN RANGE    1    6
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_3
        Update Yaml    UEs/UE_sets/${ue_id}    capability: ${ue_eutra_capabilities_1&2}
    END
    Update Yaml    UEs/UE_sets/6    capability: ${ue_eutra_capabilities_3}
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_3

Online Change parameters actVoLteNoEnDc to non-emergency QCI1 calls
    Delta Commission Parameters    ${actVoLteNoEnDc to non-emergency QCI1 calls}

Online Change Parameter actVoLteNoEnDcDrop to ENABLE
    Delta Commission Parameters    ${actVoLteNoEnDcDrop_ENABLE}

Online Change Parameter actVoLteNoEnDcDrop to DISABLE
    Delta Commission Parameters    ${actVoLteNoEnDcDrop_DISABLE}

Online Change Parameters For Case02
    Delta Commission Parameters    ${parames_case2}

Online Change Parameters For Case04
    Delta Commission Parameters    ${parames_case4}

Normal QCI1 Should Not Trigger Takeback Of Established EN-DC When CNI58993 Enable
    Start Rtpm Counter
    CUS UE Attach To eNB1 And B1MR Trigger SgNB Addition Produce    ue_id=1
    Check SgNBRelease Flow Should not be triggered during UE setup QCI1 bearer    ue_id=1
    Check Rtpm Counters    ${PM_COUNTERS_KEEP_ZERO_FOR_CNI58993}

Normal QCI1 Should Trigger Takeback Of Established EN-DC When CNI58993 Disable
    Start Rtpm Counter
    Online Change Parameter actVoLteNoEnDcDrop to DISABLE
    CUS UE Attach To eNB1 And B1MR Trigger SgNB Addition Produce    ue_id=2
    Check SgNBRelease Flow Should be triggered during UE setup QCI1 bearer    ue_id=2
    Check Rtpm Counters    ${PM_COUNTERS_ADD_ONE}

Normal QCI1 Should Not Trigger Takeback Of Established EN-DC When CNI58993 Enable Again
    Online Change Parameter actVoLteNoEnDcDrop to ENABLE
    Start Rtpm Counter
    CUS UE Attach To eNB1 And B1MR Trigger SgNB Addition Produce    ue_id=3
    Check SgNBRelease Flow Should not be triggered during UE setup QCI1 bearer    ue_id=3
    Check Rtpm Counters    ${PM_COUNTERS_KEEP_ZERO_FOR_CNI58993}

UE Release QCI1 Bearer And Detach
    Release Normal QCI1 Bearer    ue_id=1
    Release Normal QCI1 Bearer    ue_id=2
    Release Normal QCI1 Bearer    ue_id=3
    Release Emergency QCI1 Bearer    ue_id=1
    Release Emergency QCI1 Bearer    ue_id=2
    Release Emergency QCI1 Bearer    ue_id=3
    Release All UEs


CUS UE Attach eNB1 Cell1 Bearer Change From MCG To SCG
   [Arguments]    ${ue_id}=4    ${cell_id}=1
    Set UE parameters for ENDC capability     ue_id=${ue_id}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=attach_ENDC_flow    overall_timeout=20
    ${V_2}    catenate    ue_attach id=${ue_id} cell=${cell_id} ue_eutra_capabilities=${ue_eutra_capabilities_1&2}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${V_2}
    Flow Occurred As Expected    alias=attach_ENDC_flow

CUS UE Attach To eNB1 And B1MR Trigger SgNB Addition Produce
    [Arguments]    ${ue_id}=1
    ${UE_ATTACH}    catenate    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_1&2}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Uex Command    ${UE_ATTACH}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=B1_ENDC_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=1 nrsrp=50 nrsrq=66
    Flow Occurred As Expected    alias=B1_ENDC_flow

Check SgNBRelease Flow Should not be triggered during UE setup QCI1 bearer
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    alias=noSgNBRelease    overall_timeout=20
    Add Normal QCI1 Bearer    ue_id=${ue_id}
    Add Emergency QCI1 Bearer    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=noSgNBRelease

Check SgNBRelease Flow Should be triggered during UE setup QCI1 bearer
    [Arguments]    ${ue_id}=2
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    alias=SgNBRelease    overall_timeout=20
    Add Normal QCI1 Bearer    ue_id=${ue_id}    eRAB=7
    Add Emergency QCI1 Bearer    ue_id=${ue_id}    eRAB=9
    Flow Occurred As Expected    alias=noSgNBRelease

Add Emergency QCI1 Bearer
    [Arguments]    ${ue_id}=1    ${eRAB}=9
    ${emer_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 1 and priorityLevel eq 'highest')
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${emer_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    alias=emer_qci1    overall_timeout=20
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=ulm_pgw3.net request_type=emergency
    Flow Occurred as expected    alias=emer_qci1

Add Normal QCI1 Bearer
    [Arguments]    ${ue_id}=1    ${eRAB}=7
    ${normal_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 1 and priorityLevel eq 'no-priority')
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${normal_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    alias=normal_qci1     overall_timeout=20
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=nokia_2.net
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 apn=nokia_2.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=normal_qci1

Release Normal QCI1 Bearer
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 7 and cause contains (nas eq 'normal-release')))
    ...    MME_1:S1AP_E-RABReleaseResponse (e-RAB-ID eq 7)
    ...    alias=nor_rel    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=1 apn=nokia_2.net
    Flow Occurred as expected    alias=nor_rel

Release Emergency QCI1 Bearer
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 9 and cause contains (nas eq 'normal-release')))
    ...    MME_1:S1AP_E-RABReleaseResponse (e-RAB-ID eq 9)
    ...    alias=eme_rel    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=1 apn=ulm_pgw3.net
    Flow Occurred as expected    alias=eme_rel

CUS UE Setup QCI 66 65 And Emergency QCI1
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    alias=noSgNBRelease    overall_timeout=30
    Add QCI66 Bearer    ue_id=4
    Add QCI65 Bearer    ue_id=4
    Add Emergency QCI1 Bearer    ue_id=4
    Flow Not Occurred For Message    alias=noSgNBRelease

Add QCI66 Bearer
    [Arguments]    ${ue_id}=1    ${eRAB}=6
    ${qci66}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 66 and priorityLevel eq 'no-priority')
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci66})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    alias=qci_66     overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=66 apn=nokia_1.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=qci_66

Add QCI65 Bearer
    [Arguments]    ${ue_id}=1    ${eRAB}=7
    ${qci65}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq 65 and priorityLevel eq 'no-priority')
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci65})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq ${eRAB}))
    ...    alias=qci_65     overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=65 apn=nokia_1.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=qci_65

UE Detach And Check SgNB Release
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    alias=SgNBRelease    overall_timeout=20
    Release All UEs
    Flow Occurred As Expected    alias=noSgNBRelease

CUS UE Setup Emergency QCI1 And Trigger Intra ENB HandOver
    [Arguments]    ${ue_id}=6    ${qci}=2
    Add Emergency QCI1 Bearer    ue_id=${ue_id}    eRAB=7
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBModificationRequest(radioNetwork eq 'mCG-Mobility')
    ...    ENB_1:X2AP_SgNBModificationRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(mobilityControlInfo contains (targetPhysCellId eq ${qci}))
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    alias=intraHO    overall_timeout=20
    Execute Uex Command      ue_ho id=${ue_id} enb=1 cell=2
    Flow Occurred As Expected    alias=intraHO

UE Detach
    [Arguments]    ${ue_id}=6
    Execute Uex Command    ue_detach id=${ue_id}
