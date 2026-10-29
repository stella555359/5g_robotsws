*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-Delun.Li
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{A4_Config}
...    @{IRAT_config}

@{IRAT_config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actInterRatHoFromEutraToSA=true
...    NRBTS-1:nonContentRachAcFullConfigHo=true
...    NRBTS-1:tNgRelocExecDeltL=5000
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:actCDrx=true
...    NRCELL-11:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-11:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-11:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-11:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=18
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:physCellId=11
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3

@{A4_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=6
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=9
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=633216
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-11/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-11/NRHOIF-2:cellDepType=SA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=126750
...    NRCELL-11/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRCELL-11/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-11/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-11/NRREL-1:lcrId=2
...    NRBTS-1/NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRBTS-1/NRCELL-11/NRREL-2:gNbId=1
...    NRBTS-1/NRCELL-11/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-11/NRREL-2:lcrId=12
...    NRBTS-1/NRCELL-11/NRREL-2:removeNotAllowed=false
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:cellIndividualOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:eNodeBId=18
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:eutranCellExcluded=false
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:removeNotAllowed=false
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:ecgiPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-11/NRRELE-1:ecgiPlmn:mncLength=3

${SA_Capa_Combination_Support_CA_not_Support}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E0540B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A3F7F204BEF128000C00
...    13C3C4D000E208000010B010210740000003804808D00A2026C04182001E803202851226C73E1C081B0C38000E043183D04C00F000F07050
...    0703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000
...    C00800007004002000000080000800400004802000030010000140080000B004002048120080000C0339535953582958195833582B594B59
...    33580B581B580958115CAD0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E
...    594901000089652404000265949010000A96524040002E5949410000C965240400030594900CD2AABA55554AA2E95455058AA0B1541A2A94
...    C55268AA031540A2A935559628480BC04A8140A05028140A05028140A05028140A05028140A000E10100C018040080108080100402018030
...    804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C101002008040080200080F01C
...    3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${ue_id}    81
${cell_id}    11
${pdu_id}    1

*** Test Cases ***
CB007517-ET-C058_IRAT_HO_to_LTE_then_IRAT_HO_back_to_gNB_and_A4_configured
    [Documentation]
    ...    1. This user scenario porpuse is to check the gNB behaviour for a UE on a SA call
    ...    For Inter-RAT handover from LTE, the 'a4RetryTimer' shall start at the completion of the incoming handover.
    ...    2. Configuration
    ...       configuration on BTS
    ...           CA was not enabled
    ...       configuration on cell 11
    ...           NRHOIF have cell 2 and cell 12
    ...           NO CA releations , and CA was not enabled
    ...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11. A2 should be configured
    ...         b. waiting for fisrt a4RetryTimer expire, and A4 allocated to UE.
    ...         c. Trigger A2 MR in cell11 during a4SupervisionTimer is running.
    ...         d. Trigger A1 MR in cell11 during a4SupervisionTimer is running.
    ...         e. Trigger A2 MR in cell11 during a4SupervisionTimer is running.
    ...         f. Trigger UE NR IRAT HO to LTE , when B2 was already configured and no A4 allocated to UE .
    ...         h. Make UE IRAT HO from LTE to NR, then A4 configuration and deconfiguration will be started.
    ...         i. UE deregister should be successfully.
    [Tags]    QC_194585    owner-Delun.Li    C058
    UE_Register_With_pdu
    Check_A4_Cconfigured
    Trigger_A2_MR_After_First_A4_Configured    ue_id=81    carrierfreq=424090    event_type=A2
    Trigger_A1_MR_To_Trigger_A4_Configured    ue_id=81    carrierfreq=424090    event_type=A1
    Trigger_A2_MR_After_First_A4_Configured    ue_id=81    carrierfreq=424090    event_type=A2
    Trigger_B2_MR_to_HO_to_LTE    ue_id=81    carrierfreq=424090    event_type=B2
    Trigger_HO_back_from_LTE
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C058${/}a2a.ini    wait_string=UEContextRelease::1

*** Keywords ***
Modify Cfg
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.15 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
#    Debug Enter Into Egate

UE_Register_With_pdu
    Start To Capture Wireshark Log
    Update UE capa    ${SA_Capa_Combination_Support_CA_not_Support}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created

Check_A4_Cconfigured
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=eventA4
    sleep    2s    reason=wait timer

Trigger_A2_MR_After_First_A4_Configured
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    ...    fail_regexp=eventA4
    sleep    25s    reason=sleep timer must bigger than a4PeriodicMeasControlSA a4RetryTimer to wait a4RetryTimer expire

Trigger_A1_MR_To_Trigger_A4_Configured
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    sleep    25s    reason=wait timer
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    rrcReconfigurationComplete


Trigger_B2_MR_to_HO_to_LTE
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=1    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=UeContextReleaseComplete
    sleep    20s    reason=wait timer

Trigger_HO_back_from_LTE
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=11 plmn=311:489
    ...    pass_regexp=ENB-5.1 to EXT_ENB-2.11
    sleep    100s    reason=wait timer

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    sleep    30s    reason=wait timer
    stop capture wireshark log

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
