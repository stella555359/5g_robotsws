*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...                 CLOUD_R4P    team-CN3ET    owner-junmei.shao    release-SBTS21A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enable_CB007266}
...    @{CB007266_b1NrRedirectTimer}
...    LNBTS/PMRNL-1:mtUEQuantity=15min
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=31
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false|emerSessArpPrioLev=1
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNCEL-1:inactivityTimer=10
...    @{add_MODRED}
...    @{add_REDRT}
...    @{LTE4088}
...    @{LTE4193}
...    @{pdcp_discard_timer}
...    @{NRDCDPR_for_band7_and_band8}
...    @{LNADJGNB_7}
...    @{LNRELGNBCELL_1}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{Config_Mobility_Profile_03}
...    @{LTE5003}
...    @{FIX_RELATION_ERROR}
@{FIX_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{add_REDRT}
...    LNCEL-1/REDRT-0:redirRat=nr
...    LNCEL-1/REDRT-0:redirectPrio=8
...    delete:LNCEL-1/REDRT-0:csFallBPrio
...    delete:LNCEL-1/REDRT-0:emerCallPrio
...    LNCEL-1/REDRT-0:redirNrCarFrq:carrierFreqNrCell=285440|ssbSubcarrierSpacing=15kHz
...    LNCEL-2/REDRT-0:redirRat=nr
...    LNCEL-2/REDRT-0:redirectPrio=1
...    delete:LNCEL-2/REDRT-0:csFallBPrio
...    delete:LNCEL-2/REDRT-0:emerCallPrio
...    LNCEL-2/REDRT-0:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
...    LNCEL-3/REDRT-0:redirRat=nr
...    LNCEL-3/REDRT-0:redirectPrio=1
...    delete:LNCEL-3/REDRT-0:csFallBPrio
...    delete:LNCEL-3/REDRT-0:emerCallPrio
...    LNCEL-3/REDRT-0:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
@{add_MODRED}
...    LNBTS/MODPR-0/MODRED-0:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-0:redirectPrio=4
...    delete:LNBTS/MODPR-0/MODRED-0:csFallBPrio
...    delete:LNBTS/MODPR-0/MODRED-0:emerCallPrio
...    LNBTS/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
...    LNBTS/MODPR-0/MODRED-1:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-1:redirectPrio=2
...    delete:LNBTS/MODPR-0/MODRED-1:csFallBPrio
...    delete:LNBTS/MODPR-0/MODRED-1:emerCallPrio
...    LNBTS/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
@{pdcp_discard_timer}
...    LNBTS:pdcpProf1001:tDiscard=infinity
@{Config_Mobility_Profile_03}
...    LNCEL:actReturnTo5GSA=at end of non-emerg RRC or non-emerg voice
...    LNBTS:actSelMobPrf=true
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS:moProfileSelect=combined
...    LNBTS/MODPR-0/MODRED-1:redirectPrio=1
...    LNBTS/MODPR-0/MODRED-0:redirectPrio=8
...    LNBTS/MODPR-0/MODRED-0:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-0:redirNrCarFrq:carrierFreqNrCell=531040|ssbOffset=0
...    LNBTS/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|ssbOffset=0
...    LNBTS/MODPR-0/MODRED-1:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-1:redirNrCarFrq:carrierFreqNrCell=185200|ssbOffset=0
...    LNBTS/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=15kHz|ssbOffset=0
@{LNADJGNB_7}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNRELGNBCELL_1}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{NRDCDPR_for_band7_and_band8}
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=531040
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=185200
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
@{LTE5003}
...    LNCEL:actFlowCtrlEnh=true
...    @{LTE4549}
...    @{CA}
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL-1:actScellConfigForHiDemand=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1:maxNumScells=3
...    LNCEL-2:maxNumScells=3
...    LNCEL-3:maxNumScells=3
...    LNCEL-1:actCaArchEnhImp=off
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL-1:dlScellConfigLevel=20
...    LNCEL-1/CAPR-1:earfcnDL=1500
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS:actFlexCaMgmt=true
...    LNCEL-1:scellFastSchedulingSelect=normal
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-1:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:dlCaMinPcellCqi=0
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
${ue_nr_capabilities}    00000000010100200000600000380802C080380C000000
${ue_eutra_nr_capabilities}    01080803604008081010701800000006C08010102020E038000000006000100800040200010080801002
${endc_and_redirect_capability}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011C0002400004
...    900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA000178000368000
...    7F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000000
...    3A00000001D00000000E800000007400000003A00000001D00000000A080000079D00000000000000000000000000000000000000000000000
...    0000000000001011C421298061CFFFFFFFFFFFFFFFA15000300452E00004000020963401018077800000300000012000042001806000180300
...    E0
@{set_actReturnTo5GSA_as_5}
...    LNCEL:actReturnTo5GSA=at end of non-emerg RRC connection
@{disable_CB007266_and_enable_LTE5003_with_actReturnTo5GSA_5}
...    LNCEL:actB1ReturnTo5GSA=false
...    LNBTS/NRMEASDPR-0:mrWaitTimer=2000
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    @{enable_LTE5003_with_actReturnTo5GSA_5}
@{enable_LTE5003_with_actReturnTo5GSA_5}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    @{set_actReturnTo5GSA_as_5}
@{enable_CB007266}
...    LNCEL:actB1ReturnTo5GSA=true
@{CB007266_b1NrRedirectTimer}
...    LNBTS:b1NrRedirectTimer=2000
${release_redirect}
...    releaseCause eq "other" and redirectedCarrierInfo contains
...    (nr-r15 contains (
...    carrierFreq-r15 eq 185200 and subcarrierSpacingSSB-r15 eq 'kHz15'))
${b1_event}
...    eventB1-NR-r15 contains (b1-ThresholdNR-r15
...    contains (nr-RSRP-r15 eq 90)
...    and reportOnLeave-r15 eq "TRUE") and
...    measIdToAddModList contains (
...    measId eq 17, measId eq 18)
*** Test Cases ***
CB007266-SR-A-b_ET_01_01_Redirection_To_5G_Succeed_When_enable_actB1ReturnTo5GSA_and_with_valid_B1
    [Tags]
    OnlineParamChange    ${disable_CB007266_and_enable_LTE5003_with_actReturnTo5GSA_5}
    LTE inactivityTimer expired trigger RRC Connection Release with redirect when disable CB007266
    OnlineParamChange    ${enable_CB007266}
    LTE inactivityTimer expired not trigger redirection for no valid B1
    LTE inactivityTimer expired trigger redirection with high redirection priority B1
    [Teardown]    Test Teardown For Recover LTE5003

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    create alias
    execute egate command    trace_sim on mme=1 protocol=s1
    Set ue parameters before attach

create alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '524100:524100',
    ...    earfcn: '1400:19400', shared_plmn: '262:03'}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '179500:188500',
    ...    earfcn: '1400:19400', shared_plmn: '262:03'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...    ${GNB7_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...    gnb_id: '0x00008'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...    ${GNB8_CELL1}
    Update Yaml    UEs/UE_sets/1    eea: 'null'    eia: 'null'    capability: ${endc_and_redirect_capability}    capability_nr: ${ue_nr_capabilities}

Test Teardown For Recover LTE5003
    Delta Commission Parameters    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
    Common Test Teardown And Stop Capture Logs

Set ue parameters before attach
    FOR    ${ue_id}    IN RANGE    1    5
        execute uex command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        execute uex command    ue_param id=${ue_id} supported_bands_nr=7,8
        execute uex command    ue_cqi_param id=${ue_id} set=1 scell=0-3 rank=4 ignore_codebook_subset_restriction=true
        execute uex command    ue_cqi_param id=${ue_id} set=2 scell=0-3 rank=4 ignore_codebook_subset_restriction=true
        execute egate command    ue_mme_param id=1 spid=213
    END
    execute egate command
    ...    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command
    ...    gnb_endc_param id=8 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

LTE inactivityTimer expired trigger RRC Connection Release with redirect when disable CB007266
    [Documentation]
    ...    wait inactivityTimer=10s expired to check rrc connection release with redirect
    Attach UE For CB007266
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq 'user-inactivity')
    ...    UE_1:RRC_RRCConnectionRelease (${release_redirect})
    ...    alias=inactivity_release_redirect    overall_timeout=20
    flow occurred as expected    alias=inactivity_release_redirect

LTE inactivityTimer expired and Check RRC Connection Release without redirect
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq 'user-inactivity')
    ...    UE_1:RRC_RRCConnectionRelease (releaseCause eq 'other')
    ...    alias=relase_no_redirect    overall_timeout=20
    expect message will not occur
    ...    UE_1:RRC_RRCConnectionRelease (redirectedCarrierInfo contains ('nr-r15'))
    ...    alias=no_redirect    overall_timeout=20
    flow occurred as expected    alias=relase_no_redirect
    flow not occurred for message    alias=no_redirect

Attach UE For CB007266
    [Arguments]    ${ue_id}=1    ${ue_capability}=${endc_and_redirect_capability}
    ${V_1}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_capability} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} cell=1
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfiguration (${b1_event})
    ...    alias=attach_ok    overall_timeout=20
    execute uex command    ${V_1}
    flow occurred as expected    alias=attach_ok


resume UE to ACTIVE status
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfiguration (${b1_event})
    ...    alias=resume_active    overall_timeout=20
    execute uex command    trf_data_start ue=${ue_id} dir=dl protocol=udp kbps=10 duration=1
    flow occurred as expected    alias=resume_active

LTE inactivityTimer expired trigger redirection with high redirection priority B1
    resume UE to ACTIVE status
    expect message flow
    ...    UE_1:RRC_MeasurementReport (measId eq 18 and pci-r15 eq 2)
    ...    UE_1:RRC_MeasurementReport (measId eq 17 and pci-r15 eq 1)
    ...    UE_1:RRC_RRCConnectionRelease (${release_redirect})
    ...    alias=b1_redirect    overall_timeout=20
    execute uex command    ue_measurement_send id=1 event=B1_NR phycell_id=2 nrsrp=120
    execute uex command    ue_measurement_send id=1 event=B1_NR phycell_id=1 nrsrp=120
    flow occurred as expected    alias=b1_redirect

LTE inactivityTimer expired not trigger redirection for no valid B1
    resume UE to ACTIVE status
    LTE inactivityTimer expired and Check RRC Connection Release without redirect
