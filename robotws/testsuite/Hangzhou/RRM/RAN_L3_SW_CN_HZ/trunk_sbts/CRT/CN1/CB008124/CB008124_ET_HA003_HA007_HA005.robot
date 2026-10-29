*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    team-CN1ET    owner-jing.ye
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008124    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fdd_sansa_cmwv/2cells/

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    @{common_drx_and_VoNR_drx}
...    @{732_enabled}
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    delete:NRBTS-1/NRDRB-15:nrPdschHRLaDN
...    NRCELL:actDrxRetransTimerSupport=true
...    NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabledr
@{732_enabled}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{common_drx_and_VoNR_drx}
...    NRBTS:actAdditionalSliceSupport=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actVoNR=true
...    NRCELL:cellDepType=SA
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL-1:drxProfile1:drxInactivityTimer=500ms
...    NRCELL-1:drxProfile1:drxLongCycle=320ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
#...    NRCELL-1:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile2:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerUl=16slot
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actCDrxVoNR=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:actVoNR=true
...    NRCELL-2:cellDepType=SA
...    NRCELL:drxProfile2:drxInactivityTimer=4ms
...    NRCELL:drxProfile2:drxLongCycle=40ms
...    NRCELL:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-2:configuredEpsTac=${EMPTY}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-10:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=32
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL:drxProfile1:drxHarqRttTimerUl=28symbols
...    NRCELL:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL:actDrxRetransTimerSupport=true

@{5qi80_related_modification}
...    NRBTS/NRDRB-16:actDddsReduction=false
...    NRBTS/NRDRB-16:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-16:actLostPduFastRetx=false
...    NRBTS/NRDRB-16:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-16:discardTimer=infinity
...    NRBTS/NRDRB-16:discardTimerUl=infinity
...    NRBTS/NRDRB-16:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:drbInactivityTimerSA=10
...    NRBTS/NRDRB-16:dscp=0
...    NRBTS/NRDRB-16:dtxDelaySinceLastScheduling=0
...    NRBTS/NRDRB-16:dtxMaxRetentionDelay=10
...    NRBTS/NRDRB-16:durationThresDiscardDl=40
...    NRBTS/NRDRB-16:durationThresDiscardUl=20
...    NRBTS/NRDRB-16:endMarkerTimer=2000
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=35
...    NRBTS/NRDRB-16:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-16:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2
...    NRBTS/NRDRB-16:numSduDiscard=1
...    NRBTS/NRDRB-16:pdcpStatRepWaitTimer=20
...    NRBTS/NRDRB-16:pdcpStatRepWaitTimerOffset=50
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-16:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-16:resType=nonGBR
...    NRBTS/NRDRB-16:rlcMode=RLC_AM
...    NRBTS/NRDRB-16:rlcPduDelayThCa=30
...    NRBTS/NRDRB-16:schedulWeight=1
...    NRBTS/NRDRB-16:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-16:volThresDiscardDl=8000
...    NRBTS/NRDRB-16:volThresDiscardUl=800
...    NRBTS/NRDRB-16:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-16:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-16:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-16:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-16:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-16:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-16:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-16:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-16:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-16:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-16:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-16:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-16:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-16:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-16:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-80:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms80

@{PARAMS_for_HA007}
...    @{CG_DRX_profile_for_HA007}
...    @{CGconfig_for_HA007}

@{CG_DRX_profile_for_HA007}
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=160ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:drxProfile2:drxInactivityTimer=50ms
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerUl=24slot
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=24
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:drxProfile2:drxInactivityTimer=40ms
...    NRCELL-2:drxProfile2:drxLongCycle=40ms
...    NRCELL-2:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-2:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-2:drxProfile2:drxRetransTimerUl=16slot
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=24
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=20

...    NRCELL:drxProfile1:drxHarqRttTimerUl=28symbols
...    NRCELL-1:drxProfile1:drxRetransTimerUl=1slot
...    NRCELL-2:drxProfile1:drxRetransTimerUl=0slot

@{CGconfig_for_HA007}
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRDRB-11:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-14:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-11:rlcMode=RLC_UM
...    NRBTS/NRDRB-14:rlcMode=RLC_UM
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms80

@{CG_DRX_profile_for_HA005}
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=24
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=160ms
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL-2:drxProfile2:drxInactivityTimer=40ms
...    NRCELL-2:drxProfile2:drxLongCycle=40ms
...    NRCELL-2:drxProfile2:drxOnDurationTimer=10ms
...    NRCELL-2:drxProfile2:drxRetransTimerDl=16slot
...    NRCELL-2:drxProfile2:drxRetransTimerUl=0slot

...    NRCELL-1:drxProfile1:drxHarqRttTimerUl=14symbols
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-2:drxProfile1:drxHarqRttTimerUl=28symbols    ####HA005
...    NRCELL-2:drxProfile1:drxRetransTimerUl=8slot
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms10

#The following flag is used to enable debug log for troubleshooting
@{PARAMS_IN_SWCONFIG}
...    @{bitmap_level}
...    @{ULCG_TYPE2}
...    @{ULCG_TYPE2_LA}
...    @{L2_HARQ_DCI_BSR_ACSI}
...    @{L2_DL_DCI}

@{bitmap_level}
...    0x58057A=3
@{ULCG_TYPE2}
...    0x58057E=0x200
@{ULCG_TYPE2_LA}
...    0x58057F=0x80
@{L2_HARQ_DCI_BSR_ACSI}
...    0x58057D=0x3300
@{L2_DL_DCI}
...    0x58057C=0x80000
...    0x580180 = 0x1

@{DRX_config}
...    Setup QosFlow with QFI:1 5QI:80
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl0

@{CGconfig_HA07_5QI5_drxsetup_check}
...    Setup QosFlow with QFI:1 5QI:5
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-RetransmissionTimerUL sl1
...    drx-HARQ-RTT-TimerUL 28

@{CGconfig_HA07_5QI1_drxsetup_check}
...    QosFlow with QFI:2 5QI:1
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-RetransmissionTimerUL sl24
...    drx-HARQ-RTT-TimerUL 0

@{CGconfig_HA07_5QI6_drxsetup_and_CG_check}
...    QosFlow with QFI:1 5QI:6
...    rrcReconfigurationComplete

@{CGconfig_HA07_5QI1_5QI5_DRX_and_CG_check}
...    Successfully released PDU Session with ID 1
...    drx-Config release
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-InactivityTimer ms40
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl1
...    configuredGrantConfig setup

@{CGconfig_HA07_after_RRE_DRX_and_CG_check}
...    RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-InactivityTimer ms40
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl1
...    configuredGrantConfig setup

@{DRX_config_HA05}
...    Setup QosFlow with QFI:1 fiveQI:80
...    configuredGrantConfig setup
...    drx-Config setup
...    drx-InactivityTimer ms40
...    drx-HARQ-RTT-TimerUL 14
...    drx-RetransmissionTimerUL sl16

@{HA05_after_RRE_DRX_and_CG_check}
...    RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete:::4
...    drx-Config setup
...    drx-InactivityTimer ms40
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl8
...    configuredGrantConfig setup

@{HA05_after_RRE_to_cell1}
...    RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete:::4
...    drx-Config setup
...    drx-InactivityTimer ms40
...    drx-HARQ-RTT-TimerUL 14
...    drx-RetransmissionTimerUL sl16
...    configuredGrantConfig setup

${UL_CG_ACT_ATT_SUCC}    M55308C00021    #This counters provides the number of successful activation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_1.
${CG_RE_TX_PUSCH_SUCC}    M55308C00029     #The counter provides the sum of CG retransmissions on the PUSCH
#successfully received on the gNB during the measurement period.
${CG_RE_TX_PUSCH_UNSUCC}    M55308C00030    #The counter provides the sum of CG retransmissions on the PUSCH
#unsuccessfully received on the gNB during the measurement period.

@{PM_Counters_Check_HA007}
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}=2
...    NRCELL-1:${CG_RE_TX_PUSCH_SUCC}>0
...    NRCELL-1:${CG_RE_TX_PUSCH_UNSUCC}>0

@{PM_Counters_Check_HA005}
...    NRCELL-2:${UL_CG_ACT_ATT_SUCC}=5

*** Test Cases ***
CB008124-ET-HA003_non-GBR_DRX1_wo_CG_capa
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behaviour needed to configure DRX for UE capable to setup UL Grant Type 2
    ...       for activated cell.
    ...    2. Configuration
    ...       a.SA,FDD
    ...       b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...       c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...       d.UE not support CG2.
    ...    3.Test Case Steps:
    ...      a.UE attach to cell-1 with 5QI-80 as default DRB. CG is not configured.
    ...      b.start UL traffic, no traffic lost.
    ...      c.UE release successfully.
    [Tags]    QC_280328    owner-jing.ye    HA03
    UE Attach To Target Cell With 5QI_80    ${DRX_config}    ue_id=2    cell_id=1
    Start UL traffic    ue_id=2    pdu=1    qfi=1    mbps=5
    Wait Until Keyword Succeeds    30s    5s    Verify Traffic Should Not Be Lost
    UE Deregister From gNB    ue_id=2

CB008124_ET_HA007_DRX1 and DRX2 reconfiguration
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request procedure.
    ...    2. Configuration
    ...    a.SA,FDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach to cell-1 with 5QI-5 as default DRB
    ...    Expected result:
    ...       1. UE attach successfully.
    ...       2. 5QI-5 DRB setup successfully with no CG configured to UE side.
    ...       3. DRX1 setup on UE side successfully with correct parameter in DRX profile1.
    ...       (cgDrxHarqRttTimerUl and cgDrxRetransTimerUl as configured)
    ...    b.modify PDU with 5QI-1 DRB added 5QI-1 DRB setup successfully
    ...    Expected result:
    ...       1.5QI-1 DRB setup successfully.
    ...       2.DRX1 released with cgDrxHarqRttTimerUl and cgDrxRetransTimerUl.
    ...       3.DRX2 setup.
    ...    c.add PDU2 with 5QI-6 DRB, then start burst UL traffic on this DRB3
    ...    Expected result:
    ...       1.5QI-6 DRB setup successfully with CG configured to UE side
    ...       2.DRX1 and DRX2 all no impact.
    ...       3.no traffic loss
    ...    d.release 2 DRBs in PDU1 simultaneously
    ...    Expected result:
    ...       1.DRX2 released.
    ...       2.DRX1 setup with cgDrxHarqRttTimerUl and cgDrxRetransTimerUl.
    ...       3.no traffic loss.
    ...    e.RRE to cell-1
    ...    Expected result:
    ...       1.UE RRE to cell-1 successfully.
    ...       2.PDU2 with 5QI-6 DRB reestablish successfully.
    ...       3.DRX2 for target cell setup on UE side successfully with correct parameter.
    ...         (cgDrxHarqRttTimerUl and cgDrxRetransTimerUl)
    ...       4.CG activated successfully.
    ...    f.enter APH test mode, trigger CG PUSCH CRC NOK within DRX onduration and outside of DRX on duration period.
    ...    Expected result:
    ...       1.data retransmission succeed within DRX onduration period, RTTTimerUl and RetransTimerUl starts.
    ...       2.data retransmission succeed outside DRX onduration period, RTTTimerUl and RetransTimerUl starts.
    ...       3.DRXInactivityTimer not starts after PDCCH for reTx
    ...       Notes: these checkpoint will only check in MT
    ...    g.UE detach.
    [Tags]    QC_280324    owner-liupei.fang    HA07
    Clear Counter Files
    Online modify parameter and update UE capa
    UE attach 5QI5 and start burst UL traffic
    Add PDU with DRB and check traffic
    Setup with new PDU with 5QI6 and start burst UL traffic
    Trigger PDU release and check traffic
    Trigger RRE on cell-1 and check traffic    ${CGconfig_HA07_after_RRE_DRX_and_CG_check}
    Trigger CG PUSCH CRC NOK and check traffic
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_HA007}

CB008124-ET-HA005_non-GBR DRX1 with CG activation failure interworking with RRE
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behaviour needed to configure DRX for UE capable to setup UL Grant Type 2
    ...       for activated cell.
    ...    2. Configuration
    ...    a.SA,FDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    f.Common DRX feature is enabled,RRE feature is enabled
    ...    3. Test Case Steps:
    ...    a.UE attach to cell-1 with 5QI-80 as default DRB.
    ...    b.enter APH test mode to trigger missing reception of the UE 'Configured Grant Confirmation' MAC CE acknowledging the activation
    ...    request sent in DCI0_1 with CS-RNTI allocated to the UE.
    ...    c.start UL traffic.
    ...    d.exit test mode,RRE to cell-2
    ...    e.enter APH test mode to trigger missing reception of the UE 'Configured Grant Confirmation' MAC CE acknowledging the activation
    ...    request sent in DCI0_1 with CS-RNTI allocated to the UE.then RRE back to cell-1
    ...    f.repeat 5 times for step 4~5
    ...    g.release UE
    ...    4. Expect result:
    ...    a. check btslog CGINIT and CGCONFIGURED
    ...    c. check btslog CGWAITFORACTIVATION->CGWAITFORACTIVATIONCONFIRMATION->CGWAITFORDEACTIVATIONORDER->CGWAITFORDEACTIVATIONCONFIRMSCHEDULING
    ...    ->CGWAITFORDEACTIVATIONCONFIRM->CGWAITFORDEACTIVATIONORDER->CGWAITFORDEACTIVATIONCONFIRMSCHEDULING->CGWAITFORDEACTIVATIONCONFIRM->CGERROR
    ...    d. check btslog CGINIT->CGCONFIGURED->CGWAITFORACTIVATION->CGWAITFORACTIVATIONCONFIRMATION->CGACTIVATED
    ...    e. check btslog CGINIT->CGCONFIGURED->CGWAITFORACTIVATION->CGWAITFORACTIVATIONCONFIRMATION->CGWAITFORACTIVATION->
    ...    CGWAITFORACTIVATIONCONFIRMATION->CGERROR
    ...    note:btslog is not check in TA,the above description is for reference only.

    [Tags]    QC_280326    Christine.chen    HA05
    Clear Counter Files
    Online Param Change    ${CG_DRX_profile_for_HA005}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    repeat keyword    5    HA05 steps
    Check Counters    ${PM_Counters_Check_HA005}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells/    ue_count=15
    
Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5 default=on
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=udp qos_flow=4
    Update Cfg    set_qosrule id=5 proto=udp qos_flow=5
    Update Cfg    set_qosrule id=6 proto=udp qos_flow=6
    Update Cfg    set_qosrule id=7 proto=udp qos_flow=9
    Update Cfg    nwslice_set id=1 qos_flows=1,2,3,4,5,6,9 qos_rules=1,2,3,4,5,6,7 snssai=0x01:0xD143A5 default=on ue=all amf=1
    
    
Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach To Target Cell With 5QI_80
    [Arguments]    ${expect}    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=9 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${expect}

start UL traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=5    ${mbps}=5
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 mbps=${mbps} dir=ul
   
Verify Traffic Should Not Be Lost
    [Arguments]    ${ue_id}=2    ${ul}=4.5
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

start ul traffic and verify
    [Arguments]    ${ue_id}=3    ${pdu}=1    ${qfi}=1    ${mbps}=20    ${ul}=15
    start UL traffic    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    mbps=${mbps}
    Wait Until Keyword Succeeds    30s    2s    Verify Traffic Should Not Be Lost    ue_id=${ue_id}    ul=${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${CGconfig_HA07_5QI5_drxsetup_check}      

start burst UL traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=5    ${trf_id}=1    ${period_ms}=4 
    Execute Egate Command    
   ...    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul burst=1 period_ms=${period_ms} kbps=112


Add PDU with DRB and check traffic
    [Arguments]    ${ue_id}=1    ${PDU}=1    ${qos}=1   
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${PDU} qosflows_to_add=${qos} by=amf    ${CGconfig_HA07_5QI1_drxsetup_check}
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=1    ul=100
    
Setup new PDU with 5QI6
    [Arguments]    ${ue_id}=1    ${PDU}=2    ${qos}=6   
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${PDU} trf_type=internal    
    Execute Egate Command    qosflow_modify qos_flow=${qos} default=on
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${PDU} nwslice=1 gw=2    ${CGconfig_HA07_5QI6_drxsetup_and_CG_check}
    
Trigger RRE on cell-1 and check traffic
   [Arguments]    ${expect}    ${ue_id}=1    ${ul}=100
    Execute Egate Command    
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=reconfigurationFailure    pass_regexp=${expect}
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=${ue_id}    ul=${ul}

Trigger RRE on cell-2 and check traffic
   [Arguments]    ${expect}    ${ue_id}=1    ${ul}=100
    Execute Egate Command
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=2 cause=reconfigurationFailure    pass_regexp=${expect}
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=${ue_id}    ul=${ul}

Trigger PDU session release
    [Arguments]    ${ue_id}    ${pdu_id}    ${pass_regexp}
    ${output}=    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf
    ...    pass_regexp=${pass_regexp}


Trigger CG PUSCH CRC NOK and check traffic
    [Arguments]    ${CgBler}=200
    Execute Egate Command    cg_testmode_nr profile_id=1 CgBler=${CgBler}
    Execute Egate Command    ue_testmode_set_nr id=1 scell=1 testmode=configured_grant profile_id=1 action=activate
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=1    ul=100   

Setup with new PDU with 5QI6 and start burst UL traffic
    Setup new PDU with 5QI6
    start burst UL traffic    ue_id=1    pdu=2    qfi=1    trf_id=2 
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=1    ul=200

    
UE attach 5QI5 and start burst UL traffic  
    Execute Egate Command    qosflow_modify qos_flow=5 default=on
    UE Attach To Target Cell    ue_id=1    cell_id=1    
    start burst UL traffic    ue_id=1    pdu=1    qfi=1
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=1    ul=100
    
Online modify parameter and update UE capa        
    Online Param Change    Online_Param=${PARAMS_for_HA007}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    
Verify current Traffic Should Not Be Lost 
    [Arguments]    ${ue_id}=1    ${ul}=5 
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=current
    Should Be True    ${ul_throughput}>${ul}

Trigger PDU release and check traffic
    Trigger PDU session release    ue_id=1    pdu_id=1    pass_regexp=${CGconfig_HA07_5QI1_5QI5_DRX_and_CG_check}
    Wait Until Keyword Succeeds    30s    5s    Verify current Traffic Should Not Be Lost    ue_id=1    ul=100

Trigger ON missing reception
    [Arguments]    ${ue_id}=3
    Execute Egate Command    cg_testmode_nr profile_id=${ue_id} SkipCgActivationDci=5
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=1 testmode=configured_grant profile_id=${ue_id} action=activate

Trigger OFF missing reception
    [Arguments]    ${ue_id}=3
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=1 testmode=configured_grant profile_id=${ue_id} action=deactivate

HA05 steps
    UE Attach To Target Cell With 5QI_80    ${DRX_config_HA05}    ue_id=3    cell_id=1
    Trigger ON missing reception    ue_id=3
    start ul traffic and verify
    Trigger OFF missing reception    ue_id=3
    Trigger RRE on cell-2 and check traffic    ${HA05_after_RRE_DRX_and_CG_check}    ue_id=3    ul=15
    Trigger ON missing reception    ue_id=3
    Trigger RRE on cell-1 and check traffic    ${HA05_after_RRE_to_cell1}    ue_id=3    ul=15
    Trigger OFF missing reception    ue_id=3
    UE Deregister From gNB    ue_id=3

