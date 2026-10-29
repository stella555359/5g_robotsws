*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG2    owner-Allen.ge    release-SBTS20A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${SIM_GNB7_CELL_1_NRARFCN_531000}    531040

@{PARAMS_IN_SCF}
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS:actMultBearers=true
...    LNBTS:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS/LNBTS_TDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-3:harqMaxTrVoLteDl=4
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
...    LNCEL-1/LNCEL_TDD-0:maxNumActDrb=10
...    LNCEL-1/LNCEL_TDD-0:maxNumActUE=4
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_TDD-0:maxNumQci1Drb=1
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_TDD-0:measGapPattern=gap0
...    LNCEL-2/LNCEL_TDD-0:measGapPattern=gap0
...    LNCEL-3/LNCEL_TDD-0:measGapPattern=gap0
...    @{relation_error_fixed}

@{relation_error_fixed}
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS/LNBTS_TDD-0:skipPsQciUeReleaseCheck=true
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
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrcEmergency=200
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=100
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addEmergencySessions=1
...    LNBTS/LNBTS_TDD-0:actIMSEmerSessR9=true
...    LNBTS/LNBTS_TDD-0:actHighPrioServices=true
@{qciTab6}
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab6:nrPdcpProfIdx=1001

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
...    LNBTS/LNBTS_TDD-0:actPubSafetyBearers=true
...    LNCEL-1:inactivityTimerPubSafety=1000
...    LNCEL-2:inactivityTimerPubSafety=1000
...    LNCEL-3:inactivityTimerPubSafety=1000

@{actVoLteNoEnDc to QCI65 and QCI66 calls}
...    LNBTS:actVoLteNoEnDc=QCI65 and QCI66 calls

@{Online change maxNumActDrb}
...    LNCEL-1/LNCEL_TDD-0:maxNumActDrb=4
...    LNBTS:actVoLteNoEnDc=QCI65/66 and all QCI1 calls

${ue_eutra_capabilities}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011C0002400004
...    900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA000178000368000
...    7F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000000
...    3A00000001D00000000E800000007400000003A00000001D00000000A080000079D00000000000000000000000000000000000000000000000
...    0000000000001011C421298061CFFFFFFFFFFFFFFFA15000300452E000040000209614010180778000003000000100

${V_1}
...    SEPARATOR=
...    DE1809F0008206102860E2048A163069022489942A58B983268D9D3CB5FA55074F800000001F000000003E000000007C00000000F800000001
...    F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000
...    001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800
...    000001F000000006FEFFFB20020070D9000000005EE800000020254A8389D0100000208000420000860001100002280004600008E000120000
...    2480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B400
...    03F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E80000000504000003CE8000000000000000000000000000000000000000000000
...    00000000000000808E21094C030E7FFFFFFFFFFFFFFD0A8001802297000020000104B1A0000CF0000006000000242000810210
${V_2}
...    SEPARATOR=
...    DE1809F0008206102860E2048A163069022489942A58B983268D9D3CB5FA55074F800000001F000000003E000000007C00000000F800000001
...    F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000
...    001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800
...    000001F000000006FEFFFB20020070D9000000005EE800000020254A8389D0100000208000420000860001100002280004600008E000120000
...    2480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B400
...    03F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E80000000504000003CE8000000000000000000000000000000000000000000000
...    00000000000000808E21094C030E7FFFFFFFFFFFFFFD0A8001802297000020000104B1A0000CF0000006000000242000810210
${V_3}
...    SEPARATOR=
...    DE1809F0008206102860E2048A163069022489942A58B983268D9D3CB5FA55074F800000001F000000003E000000007C00000000F800000001
...    F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000
...    001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800
...    000001F000000006FEFFFB20020070D9000000005EE800000020254A8389D0100000208000420000860001100002280004600008E000120000
...    2480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B400
...    03F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E80000000504000003CE8000000000000000000000000000000000000000000000
...    00000000000000808E21094C030E7FFFFFFFFFFFFFFD0A8001802297000020000104B1A0000CF0000006000000242000810210

${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040164A01C06000000000400020101002004

${V_5}
...    SEPARATOR=
...    DE1809F0008206102860E2048A163069022489942A58B983268D9D3CB5FA55074F800000001F000000003E000000007C00000000F800000001
...    F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000
...    001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800000001F000000003E000000007C00000000F800
...    000001F000000006FEFFFB20020070D9000000005EE800000020254A8389D0100000208000420000860001100002280004600008E000120000
...    2480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B400
...    03F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E80000000504000003CE8000000000000000000000000000000000000000000000
...    00000000000000808E21094C030E7FFFFFFFFFFFFFFD0A8001802297000020000104B1A0000CF0000006000000242000810210

*** Test Cases ***
LTE5388-A-b_ET_01_01_Initial_Context_Setup_with_EN-DC_eligible_bearer_and_QCi65_QCI66_with_actVoLteNoEnDc_is_set_QCI65_and_QCI66_calls
    [Documentation]
    ...    UE1 attach Real-eNB1 cell1 with QCI65 and EN-DC eligible bearer(QCI6)
    ...    UE3 attach Real-eNB1 cell1 with QCI66 and EN-DC eligible bearer(QCI6)
    ...    UE5 attach Real-eNB1 cell1 with QCI65 and QCI66 and EN-DC eligible bearer(QCI6)
    ...    UE1 ERAB release QCI65
    ...    send iphy command to UE1 and make B1 trigger ENDC
    ...    UE3 RCR to eNB1 cell1 when ERAB setup QCI65
    ...    UE3 ERAB release QCI66
    ...    send iphy command to UE2 make B1 trigger ENDC
    ...    UE5 ERAB release QCI65
    ...    UE5 ERAB release QCI66
    ...    send iphy command to UE3 and make B1 trigger ENDC
    [Tags]
    Online Change actVoLteNoEnDc to QCI65 and QCI66 calls
    Three UE1 UE3 UE5 attach to Real-eNB1 cell1
    UE1 released QCI65 then trigger ENDC
    UE3 RCR to eNB1 cell1 during QCI65 setup then release QCI66 then trigger ENDC
    UE5 release QCI65 QCI66 then trigger ENDC

LTE5388-A-b_ET_06_01_intra_eNB_HO_with_all_EN-DC_restricted_VoLTE_bearer
    [Documentation]    UE9 attach to Real-eNB1 cell2 with QCI65 , QCI66 ,normal QCI1 and QCI6( EN-DC eligible bearer)
    ...    UE9 ERAB setup emergency QCI1
    ...    UE9 X2HO to ENB1 cell1
    ...    UE9 ERAB release Normal QCI1 release QCI65 QCI66 and emergency QCI1 simultaneously by preemption
    ...    send iphy command make B1 trigger ENDC
    [Tags]
    Online Change actVoLteNoEnDc to QCI65 QCI66 and all QCI1 calls
    UE9 attach to Real-eNB1 cell2 with QCI1 QCI6 QCI65 QCI66 with no B1 related measId17
    UE9 Intra eNB handover to Real-eNB1 Cell1
    UE9 Release QCI1 QCI65 QCI66
    B1 trigger SgNB addition produce    ue_id=9

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Set UE parameters before ENDC setup
    Create Alias

Set UE parameters before ENDC setup
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Config UE1 to UE10
    Config gnb7

Config UE1 to UE10
    FOR    ${ue_id}    IN RANGE    1    10
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
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_9    ue_id=9    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
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
    ...      - {qci: 6, default: on, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    ...      - {qci: 66, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: off, priority: 1}
    FOR    ${ue_id}    IN RANGE    1    3
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...      - {qci: 6, default: on, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: off, priority: 1}
    ...      - {qci: 66, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    FOR    ${ue_id}    IN RANGE    3    5
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_3
    END	
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...      - {qci: 6, default: on, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    ...      - {qci: 66, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 2, precedence: 2, priority: 2}
    FOR    ${ue_id}    IN RANGE    5    7
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_4
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...      - {pdn: 1, qci: 6, default: on}
    ...      - {pdn: 1, qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 3, precedence: 3, priority: 3}
    ...      - {pdn: 1, qci: 65, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    ...      - {pdn: 1, qci: 66, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 2, precedence: 2, priority: 2}
    FOR    ${ue_id}    IN RANGE    7    10
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_5
    END		

Online Change actVoLteNoEnDc to QCI65 and QCI66 calls
    Delta Commission Parameters    @{actVoLteNoEnDc to QCI65 and QCI66 calls}
    Cells Should Be OnAir

UE1 attach Real-eNB1 cell1 with QCI6 QCI65 and no B1 was activated
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${ue_eutra_capabilities}=${V_3}
    ${B1NRActivation}    catenate
    ...    reportConfigToAddModList contains (b1-ThresholdNR-r15 is present)
    ${QCI6_QCI65}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 65)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( measObjectToAddModList contains (carrierFreq eq 38000) )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI6_QCI65})
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1NRActivation})
    ...    alias=UE_${ue_id}_attach_with_no_B1     overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach
    Flow Not Occurred For Message    alias=UE_${ue_id}_attach_with_no_B1

UE3 attach Real-eNB1 cell1 with QCI6 QCI66 and no B1 was activated
    [Arguments]    ${ue_id}=3    ${cell_id}=1    ${ue_eutra_capabilities}=${V_1}
    ${B1NRActivation}    catenate
    ...    reportConfigToAddModList contains (b1-ThresholdNR-r15 is present)
    ${QCI6_QCI66}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 66)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( measObjectToAddModList contains (carrierFreq eq 38000) )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI6_QCI66})
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1NRActivation})
    ...    alias=UE_${ue_id}_attach_with_no_B1     overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach
    Flow Not Occurred For Message    alias=UE_${ue_id}_attach_with_no_B1

UE5 attach Real-eNB1 cell1 with QCI6 QCI65 QCI66 and no B1 was activated
    [Arguments]    ${ue_id}=5    ${cell_id}=1    ${ue_eutra_capabilities}=${V_2}
    ${B1NRActivation}    catenate
    ...    reportConfigToAddModList contains (b1-ThresholdNR-r15 is present)
    ${QCI6_QCI65_QCI66}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 65,
    ...    e-RAB-ID eq 7 and qCI eq 66)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( measObjectToAddModList contains (carrierFreq eq 38000) )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI6_QCI65_QCI66})
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1NRActivation})
    ...    alias=UE_${ue_id}_attach_with_no_B1     overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach
    Flow Not Occurred For Message    alias=UE_${ue_id}_attach_with_no_B1

UE release QCI then RRC contains measId_17_B1
    [Arguments]    ${ue_id}=1    ${qci_id}=1
    Expect message flow
    ...    MME_1:S1AP_E-RABReleaseCommand
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (17))
    ...    alias=UE_${ue_id}_bearer_del_qci_${qci_id}    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id}
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_del_qci_${qci_id}

UE release QCI then RRC not contains measId_17_B1
    [Arguments]    ${ue_id}=5    ${qci_id}=65
    Expect message flow
    ...    MME_1:S1AP_E-RABReleaseCommand
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToReleaseList contains (5))
    ...    alias=UE_${ue_id}_bearer_del_qci_${qci_id}    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id}
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_del_qci_${qci_id}

B1 trigger SgNB addition produce
    [Arguments]    ${ue_id}=1    ${phycell_id}=1    ${blacklist_measureid}=18
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge (E-RABs-Admitted-ToBeAdded-SgNBAddReqAckList contains (e-RAB-ID eq 5))
    ...    alias=ENDC_for_UE_${ue_id}    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${phycell_id} nrsrp=50 meas_id_blacklist=${blacklist_measureid}
    Flow Occurred As Expected    alias=ENDC_for_UE_${ue_id}

RCR to eNB1 cell1 during ERAB setup
    [Arguments]    ${ue_id}=3    ${eRAB}=7    ${qci_id}=65    ${apn_name}=nokia_1.net
    ${qci65}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq ${eRAB} and qCI eq ${qci_id} and priorityLevel eq 'highest')
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci65})
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest (physCellId eq 1 and reestablishmentCause eq "otherFailure")
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains (e-RAB-ID eq ${eRAB}))	
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishment (radioResourceConfigDedicated contains (ttiBundling eq 'FALSE'))
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 4))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_bearer_add_qci_${qci_id}    overall_timeout=30
    Execute Uex Command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=drb-Identity with_value=6 action=reestablish cause=otherFailure cell=1 nth=1
    Execute Uex Command And Expect Error    bearer_add ue=${ue_id} qci=${qci_id} apn=${apn_name} mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    ...    sErrBearerAcquireUiBearerAllocationReject
    Flow Occurred As Expected    alias=UE_${ue_id}_bearer_add_qci_${qci_id}

Three UE1 UE3 UE5 attach to Real-eNB1 cell1
    UE1 attach Real-eNB1 cell1 with QCI6 QCI65 and no B1 was activated
    UE3 attach Real-eNB1 cell1 with QCI6 QCI66 and no B1 was activated
    UE5 attach Real-eNB1 cell1 with QCI6 QCI65 QCI66 and no B1 was activated

UE1 released QCI65 then trigger ENDC
    UE release QCI then RRC contains measId_17_B1    ue_id=1    qci_id=65
    B1 trigger SgNB addition produce    ue_id=1

UE3 RCR to eNB1 cell1 during QCI65 setup then release QCI66 then trigger ENDC
    RCR to eNB1 cell1 during ERAB setup    ue_id=3
    UE release QCI then RRC contains measId_17_B1    ue_id=3    qci_id=66
    B1 trigger SgNB addition produce    ue_id=3

UE5 release QCI65 QCI66 then trigger ENDC
    UE release QCI then RRC not contains measId_17_B1    ue_id=5    qci_id=65
    UE release QCI then RRC contains measId_17_B1    ue_id=5    qci_id=66
    B1 trigger SgNB addition produce    ue_id=5

Online Change actVoLteNoEnDc to QCI65 QCI66 and all QCI1 calls
    Delta Commission Parameters    ${Online change maxNumActDrb}
    Cells Should Be OnAir

UE9 attach to Real-eNB1 cell2 with QCI1 QCI6 QCI65 QCI66 with no B1 related measId17
    [Arguments]    ${ue_id}=9    ${cell_id}=2
    ${QCI1_QCI6_QCI65_QCI66_ReqList}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 1,
    ...    e-RAB-ID eq 7 and qCI eq 65,
    ...    e-RAB-ID eq 8 and qCI eq 66)
    ${QCI1_QCI6_QCI65_QCI66_AckList}    catenate
    ...    E-RABs-Admitted-ToBeAdded-SgNBAddReqAckList contains (
    ...    e-RAB-ID eq 5 and qCI eq 6, 
    ...    e-RAB-ID eq 6 and qCI eq 1,
    ...    e-RAB-ID eq 7 and qCI eq 65,
    ...    e-RAB-ID eq 8 and qCI eq 66)	
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 38000))
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI1_QCI6_QCI65_QCI66_ReqList} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${V_5} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach

UE9 Intra eNB handover to Real-eNB1 Cell1
    [Arguments]    ${ue_id}=9
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_inter_eNB_HO    overall_timeout=30
    ${no_A4_A5_flow}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains
    ...    (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))) or
    ...    (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))))
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${no_A4_A5_flow})
    ...    alias=no_A4_A5_flow    overall_timeout=30
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_${ue_id}_inter_eNB_HO
    Flow Not Occurred For Message    alias=no_A4_A5_flow

UE9 Release QCI1 QCI65 QCI66
    [Arguments]    ${ue_id}=9
    Execute Uex Command    bearer_del ue=${ue_id} qci=1
    Execute Uex Command    bearer_del ue=${ue_id} qci=65
    Execute Uex Command    bearer_del ue=${ue_id} qci=66