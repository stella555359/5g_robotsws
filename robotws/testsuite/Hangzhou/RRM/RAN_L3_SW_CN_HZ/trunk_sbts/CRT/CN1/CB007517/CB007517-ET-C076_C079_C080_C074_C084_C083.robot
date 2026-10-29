*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-jing.ye
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7882
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{HO_Config}
...    @{A4_Config}
...    @{RRE_Config}
...    @{NRHOIF_Config}
...    @{NRREL_Config}
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-2:actCDrx=true


@{RRE_Config}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms

@{HO_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS-1/NRCELL-2:measGapSelectionSA=balancedChoice

@{A4_Config}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=5000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=20
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=9000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=1000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=25
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4MeasMaxNumber=1
...    NRCELL-1:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4MeasMaxNumber=1
...    NRCELL-2:a4PeriodicMeasControlNSA:a4RetryTimer=10

@{NRHOIF_Config}
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=636768
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=99
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRCELL-2/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-1:a4PriorityForHigherPrioFreqHo=100

@{NRREL_Config}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:lcrId=1
...    delete:NRBTS-1/NRCELL-2/NRREL-1

@{OnlineParam_for_C083}
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-1:actCDrx=false

@{OnlineParam_for_C083_Recover}
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:actCDrx=true

@{OnlineParam_for_C079}
...    NRBTS-1/NRCELL-1:actCDrx=false
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=1000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=1000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10

@{OnlineParam_for_C079_Recover}
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=5000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=20

@{OnlineParam_for_C074_C084}
...    NRBTS-1/NRCELL-2:actCDrx=false
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrpAndRsrq
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64

@{OnlineParam_for_C074_C084_Recover}
...    NRBTS-1/NRCELL-2:actCDrx=true
...    NRBTS-1/NRCELL-1:a3MeasEnabled=none

@{OnlineParam_for_C083}
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-1:actCDrx=false

@{OnlineParam_for_C083_Recover}
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:actCDrx=true

${SA_Capa_support_full_gappattern}    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E0015
...    1B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C2403D6C10101070EF1C39061C00103278FAB8002780
...    0E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C00103278FAA8000028000000841C4D000000002026878003804044FFFFFFF84C00C000A07050070300
...    9801C001A0F8000000000000395340004000025965400D2AAA12007000B000000040080118B130001020304050607080B101112131921252627284A

${ue_id}    1
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${pdu_id1}    2
${pdu_id2}    1
${gw_id1}    2
${cell_id}    1
${RRC_cause}    reconfigurationFailure


*** Test Cases ***
CB007517-ET-C076_Inter_freq_A4_deconfigure_been_queued_when_PDU_release_ongoing
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    CPUE concurrency: inter-freq A4 deconfigure been queued when PDU release(not the last PDU) ongoing.
    ...    2. Configuration
    ...         a.configuration on cell 1
    ...           UE capability support independent MG
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           NRHOIF and NRREL for cell 1, present for cell 2,a4PriorityForHigherPrioFreqHo is 99
    ...           Measurement: A4
    ...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and 2 PDU sessions are setup successfully on cell 1.
    ...         b. start traffic and check.
    ...         c. Trigger PDU session release after A4 configured, and hold RRC reconfiguration complete for PDU release for 5s.
    ...         d. check throughput.
    ...         e. A4 can be configured and deconfigured successfully.
    ...         f. Release the last PDU session , A4 should not be configured anymore.
    ...         g. UE deregister should be successfully.
    ...     4. Expect result:
    ...         a. PDU sessions are setup successfully, DRX setup, and start retry timer.
    ...         b. no traffic lost.
    ...         c. Trigger PDU session release after A4 configured, A4 deconfig should be handled after PDU release.
    ...         d. no traffic lost.
    ...         e. A4 can be configured and deconfigured successfully.
    ...         f. no traffic lost.
    ...         g. UE deregister should be successfully.
    [Tags]    QC_192630    owner-jing.ye    C076
    UE Attach To Target Cell With 2 PDU Sessions    cell_id=1
    Send And Verify Throughput
    A4 Deconfig Should Be Queued When PDUSessionResourceRelease Ongoing    ue_id=${ue_id}    pdu_id1=${pdu_id1}
    Verify Throughput
    A4 Can Be Config And Deconfig Normally
    A4 Config Should Be stopped after the last PDU released    ue_id=${ue_id}    pdu_id2=${pdu_id2}
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C076${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB007517-ET-C079_Ongoing_A4_Configuration_should_be_abort_when_AMF_triggered_UEContextReleaseCommand_incoming
    [Documentation]
    ...    1. TThe purpose of this test case is to check following scenarios:
    ...    CPUE concurrency: inter-freq A4 configuration is aborted when AMF_triggered_UEContextReleaseCommand incoming
    ...    2. Configuration
    ...           configuration on cell 1
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           Measurement: A4
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger RRC delay 5s on egate before a4RetryTimer expire.
    ...         c. Trigger UEContextRelease within 5s.
    ...         d. UE deregister
    ...     4. Expect result:
    ...          a. PDU session is setup successfully
    ...          b. egate command executed successfully.
    ...          c. A4 configuration procedure should be aborted and UE is released.
    ...          d. UE deregister is successfully.
    [Tags]    QC_192631    owner-jia.pan    C079
    OnlineParamChange    ${OnlineParam_for_C079}
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger hold RRC reconfiguration complete
    Trigger UEContextRelease    cell_id=${cell_id}
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C079${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C079_Teardown

CB007517-ET-C080_PDUSessionResource_SetupRequest_incoming_when_A4_configuration_ongoing_Queue
    [Documentation]
    ...    1. TThe purpose of this test case is to check following scenarios:
    ...    PDUSessionResource_SetupRequest queued when A4 configuration_ongoing.
    ...    2. Configuration
    ...           configuration on cell 1
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           Measurement: A4
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger 2nd PDU setup after A4RetryTimer expired.
    ...         c. After PDU setup setup success ,A4 deconfiguration success , check PCAP.
    ...         d. UE deregister.
    ...     4. Expect result:
    ...          a. 1st PDU session is setup successfully
    ...          b. A4 configuration success,than 2nd PDU setup success .
    ...          c. A4 deconfiguration success.
    ...          d. UE deregister is successfully.
    [Tags]    QC_192632    owner-xiaowen.xu    C080
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Send And Verify Throughput
    UE Attach To Target Cell With 2nd PDU while A4 configuration ongoing
    A4 Can Be Config And Deconfig Normally
    Verify Throughput    sleep_time=10s
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C080${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB007517-ET-C074_Inter_freq_A4_configure_been_ignored_when_RRE_ongoing
   [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    CPUE concurrency: inter-freq A4 deconfigure been ignored when RRE to original cell ongoing
    ...    CPUE concurrency: inter-freq A4 configure been ignored when RRE to other cell ongoing
    ...    2. Configuration
    ...         a.configuration on cell 1/cell 2
    ...           RRE is enabled
    ...           UE capability support independent MG
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           NRHOIF and NRREL for cell 1, present for cell 2,a4PriorityForHigherPrioFreqHo is 99
    ...           NRHOIF and NRREL for cell 12, present for cell 1,a4PriorityForHigherPrioFreqHo is 100
    ...           Measurement: A4
    ...           DRX: enabled on cell 1, disabled on cell 2
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1, then start traffic.
    ...         b. Trigger RRC delay command on egate before a4SupervisionTimer expiry.
    ...         c. Trigger RRE to cell 1 before a4SupervisionTimer expiry,
    ...            but RRC reconfiguration complete will be delayed for 5s according to stepb.
    ...         d. After supervisionTimer expiry, A4 deconfiguration procedure should be ignored and RRE succeed, then check throughput.
    ...         e. Reset RRC delay on egate.
    ...         f. A4 configured after a4retryTimer expiry.
    ...         g. A4 deconfigured after a4SupervisionTimer expiry.
    ...         h. Trigger RRC delay command on egate before a4retryTimer expiry.
    ...         i. Trigger RRE to cell 2 within 5s, but RRC reconfiguration complete will be delayed for 5s according to steph.
    ...         j. After retryTimer expiry, A4 configuration procedure should be ignored and RRE succeed.
    ...         k. A4 configured after a4retryTimer expiry.
    ...         l. check throughput
    ...         m. UE deregister should be successfully.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, DRX setup, and start retry timer, no traffic loss. After retryTimer expiry, A4 configured.
    ...          b. egate command executed successfully.
    ...          c. RRC reconfiguration complete in RRE procedure has been delayed.
    ...          d. RRE succeed, no A4 deconfigured after supervisionTimer expiry, DRX recoveried, no traffic loss.
    ...          e. egate command executed successfully.
    ...          f. correct A4 configured after a4retryTimer expire, perFR1 MG setup, DRX release.
    ...          g. A4 deconfigured after a4SupervisionTimer expiry, MG release, DRX setup.
    ...          h. egate command executed successfully.
    ...          i. RRC reconfiguration complete in RRE procedure has been delayed.
    ...          j. RRE succeed, no A4 configured during RRE, no MG, no DRX setup.
    ...          k. A4 configuration after a4retryTimer expiry, MG setup.
    ...          l. no throughput loss.
    ...          m. UE deregister is successfully.
    [Tags]    QC_192629    owner-lena.zhuo    C074
    OnlineParamChange    ${OnlineParam_for_C074_C084}
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Send And Verify Throughput
    Reestablishment when A4 deconfig ongoing    sleep2_time=0s
    Reestablishment when A4 config ongoing    cell_id=2
    UE Deregister Longtime From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C074${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C074_84_Teardown

CB007517-ET-C084_RRE_incoming_when_A4_deconfiguration_ongoing_abort_and_process
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    CPUE concurrency: inter-freq A4 configure been aborted when RRE to original cell incoming, then process RRE
    ...    CPUE concurrency: inter-freq A4 deconfigure been aborted when RRE to original cell incoming, then process RRE
    ...    CPUE concurrency: inter-freq A4 deconfigure been aborted when RRE to other cell incoming, then process RRE
    ...    2. Configuration
    ...         a.configuration on cell 1/cell 2
    ...           RRE is enabled
    ...           UE capability support independent MG
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           NRHOIF and NRREL for cell 1, present for cell 2,a4PriorityForHigherPrioFreqHo is 99
    ...           NRHOIF and NRREL for cell 12, present for cell 1,a4PriorityForHigherPrioFreqHo is 100
    ...           Measurement: A4
    ...           DRX: enabled on cell 1, disabled on cell 2
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1, then start traffic.
    ...         b. Trigger RRC delay command on egate before a4RetryTimer expire.
    ...         c. A4 configured to UE side, but RRC reconfiguration complete will be delayed for 5s according to stepb.
    ...         d. Trigger RRE to cell 1 within 5s.
    ...         e. A4 configuration procedure should be ignored and RRE succeed, then check throughput.
    ...         f. Reset RRC delay on egate.
    ...         g. A4 configured after a4retryTimer expire.
    ...         h. Trigger RRC delay command on egate before a4SupervisionTimer expire.
    ...         i. A4 deconfiguration to UE side, but RRC reconfiguration complete will be delayed for 5s according to steph.
    ...         j. Trigger RRE to cell 1 within 5s.
    ...         k. A4 deconfiguration procedure should be ignored and RRE succeed.
    ...         l. check throughput
    ...         m. Reset RRC delay on egate.
    ...         o. A4 configured after a4retryTimer expire.
    ...         p. Trigger RRC delay command on egate before a4SupervisionTimer expire.
    ...         q. A4 deconfiguration to UE side, but RRC reconfiguration complete will be delayed for 5s according to stepp.
    ...         r. Trigger RRE to cell 2 within 5s.
    ...         s. A4 deconfiguration procedure should be ignored and RRE succeed.
    ...         t. check throughput
    ...         u. UE deregister should be successfully.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, DRX setup, and start retry timer, no traffic loss.
    ...          b. egate command executed successfully.
    ...          c. RRC reconfiguration complete in A4 configuration procedure has been delayed.
    ...          d. RRE been triggered successfully, and RRC reconfiguration complete in RRE procedure has been delayed.
    ...          e. A4 configuration procedure should be ignored and RRE succeed, DRX recoveried, no traffic loss.
    ...          f. egate command executed successfully.
    ...          g. correct A4 configured after a4retryTimer expire, perFR1 MG setup.
    ...          h. egate command executed successfully.
    ...          i. RRC reconfiguration complete in A4 deconfiguration procedure has been delayed.
    ...          j. RRE been triggered successfully, and RRC reconfiguration complete in RRE procedure has been delayed.
    ...          k. A4 deconfiguration procedure should be ignored and RRE succeed, no A4 configured after RRE, no MG, DRX setup.
    ...          l. no throughput loss.
    ...          n. egate command executed successfully.
    ...          o. correct A4 configured after a4retryTimer expire, perFR1 MG setup.
    ...          p. egate command executed successfully.
    ...          q. RRC reconfiguration complete in A4 deconfiguration procedure has been delayed.
    ...          r. RRE been triggered successfully, and RRC reconfiguration complete in RRE procedure has been delayed.
    ...          s. A4 deconfiguration procedure should be ignored and RRE succeed, no A4 configured after RRE, no MG, no DRX setup.
    ...          t. no throughput loss.
    ...          u. UE deregister is successfully.
    [Tags]    QC_192634   owner-lena.zhuo    C084
    OnlineParamChange    ${OnlineParam_for_C074_C084}
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Send And Verify Throughput
    Reestablishment when A4 first config
    Reestablishment when A4 deconfig ongoing
    Reestablishment when A4 deconfig ongoing    cell_id=2
    UE Deregister Longtime From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C084${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C074_84_Teardown

CB007517-ET-C083_UE_Radio_Capability_Check_incoming_when_A4_configuration_process_in_parallel
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    CPUE concurrency: UE Radio Capability Check incoming when A4 configuration ongoing
    ...    2. Configuration
    ...         a.configuration on cell 1
    ...           UE capability support independent MG
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           NRHOIF and NRREL for cell 1, present for cell 2,a4PriorityForHigherPrioFreqHo is 99
    ...           Measurement: A4
    ...           DRX: disable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. start traffic and check.
    ...         c. A4 can be config and deconfig successfully.
    ...         d. check throughput.
    ...         e. Hold RRC reconfigration complete for 5s.
    ...         f. Before 2nd A4 config complete, trigger UE Radio Capability immediately.
    ...         g. check throughput.
    ...         h. A4 can be config and deconfig successfully with 3th time. No more config happen.
    ...         i. check throughput.
    ...         j. UE deregister should be successfully.
    ...     4. Expect result:
    ...         a. PDU session is setup successfully, and start retry timer.
    ...         b. no traffic lost.
    ...         c. A4 can be config and deconfig successfully.
    ...         d. no traffic lost.
    ...         e. egate command executed successfully.
    ...         f. UE Radio Capability Check been handled after A4 configuration complete, A4 configuration continued after delay finished,
    ...            both succeed. A4 can be deconfig successfully when supervision timer expired.
    ...         g. no traffic lost.
    ...         h. A4 can be config and deconfig successfully with 3th time. No more A4 config happen.
    ...         i. no traffic lost.
    ...         j. UE deregister should be successfully.
    [Tags]    QC_192633    owner-jing.ye    C083
    OnlineParamChange    ${OnlineParam_for_C083}
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Send And Verify Throughput
    A4 Can Be Config And Deconfig Normally
    Verify Throughput
    Trigger hold RRC reconfiguration complete
    UE Radio Capability Check when A4 configuration Ongoing Should Be Handled in Parallel
    A4 Can Be Config And Deconfig Successfully And No More A4 Config
    Verify Throughput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C083${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C083 TestTeardown

*** Keywords ***
C079_Teardown
    OnlineParamChange    ${OnlineParam_for_C079_Recover}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    ${C_1}    catenate
    ...     set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=636666:636666
    ...     gscn=7882 mandatory_for_activation=off
    Update Cfg     ${C_1}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

UE Attach To Cell1
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Update UE capa    ${SA_Capa_support_full_gappattern}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table

UE Attach To Target Cell With 2 PDU Sessions
    [Arguments]    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id1} gw=${gw_id1} nwslice=${nwslice}    QoS Routing Table

UE Attach To Target Cell With 2nd PDU while A4 configuration ongoing
    ${cmd_rrc_delay}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    ${pass_regexp}    Catenate    UE${ue_id}: Hit on error cases presence=any action=delay
    Execute Egate Command     ${cmd_rrc_delay}     pass_regexp=${pass_regexp}    timeout=20s
    ${cmd_2ndPDU}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id1} gw=${gw_id1} nwslice=${nwslice}
    Execute Egate Command    ${cmd_2ndPDU}    UPLINK NAS TRANSPORT

A4 Deconfig Should Be Queued When PDUSessionResourceRelease Ongoing
    [Arguments]    ${ue_id}    ${pdu_id1}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=eventA4    timeout=20s
    Trigger hold RRC reconfiguration complete
    ${ret1}=    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id1} by=ue
    ...    Hit on error cases presence=any action=delay    timeout=6s
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=7s
    Trigger Reset RRC reconfiguration complete

A4 Config Should Be stopped after the last PDU released
    [Arguments]    ${ue_id}=1    ${pdu_id2}=1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToAddModList    timeout=20s
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id2} by=ue
    ...    Successfully released PDU Session with ID ${pdu_id2}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=6s
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    fail_regexp=measIdToAddModList    timeout=30s

A4 Can Be Config And Deconfig Normally
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToAddModList    timeout=20s
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=6s

A4 Can Be Config And Deconfig Successfully And No More A4 Config
    A4 Can Be Config And Deconfig Normally
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    fail_regexp=measIdToAddModList    timeout=20s

Trigger hold RRC reconfiguration complete
    ${ret1}=     Execute Egate Command    ue_param id=${ue_id} reestablishing_state_timeout=9s
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000

Trigger Reset RRC reconfiguration complete
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=0

Verify Throughput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throughput
    [Arguments]    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throughput    sleep_time=${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Deregister Longtime From gNB
    [Arguments]    ${ue_id}    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for A4 config and deconfig
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger UEContextRelease
    [Arguments]    ${cell_id}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    Hit on error    timeout=10s
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=MISC_unspecified    IS IDLE

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Trigger RRC reestablishment with delay
    [Arguments]    ${RRC_cause}=reconfigurationFailure    ${cell_id}=1    ${sleep_time}=5s
    ${ret1}=     Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${RRC_cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=3s
    sleep    ${sleep_time}    sleep for RRE complete

Trigger hold RRC reconfiguration complete before RRE
    [Arguments]    ${sleep_time}=0s
    sleep    ${sleep_time}    sleep for A4 configuration
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    ...    Hit on error cases presence=any action=delay    timeout=20s

Trigger hold RRC reconfiguration complete in RRE
    [Arguments]    ${sleep1_time}=0s    ${sleep2_time}=0s
    sleep    ${sleep1_time}    sleep for A4 configuration
    ${ret1}=     Execute Egate Command    ue_param id=${ue_id} reestablishing_state_timeout=9s
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    sleep    ${sleep2_time}    sleep for A4 deconfiguration

Check MeasConfig Add on UE
    [Arguments]    ${time_out}=20s    ${sleep_time}=1s
    Execute Egate Command     ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToAddModList    timeout=${time_out}
    sleep    ${sleep_time}    sleep for A4 configuration

Check MeasConfig Del on UE
    [Arguments]    ${time_out}=20s    ${sleep_time}=1s
    Execute Egate Command     ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=${time_out}
    sleep    ${sleep_time}    sleep for A4 deconfiguration

UE Radio Capability Check when A4 configuration Ongoing Should Be Handled in Parallel
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=Hit on error cases presence=any action=delay    timeout=20s
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=${ue_id} gnb=2    rrcReconfigurationComplete    timeout=5s
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=6s
    Verify Throughput

C083 TestTeardown
    OnlineParamChange    ${OnlineParam_for_C083_Recover}
    Common Test Teardown And Stop Capture Logs

Reestablishment when A4 deconfig ongoing
    [Arguments]    ${cell_id}=1    ${sleep_time}=10s    ${sleep2_time}=3s
    Check MeasConfig Add on UE
    Trigger hold RRC reconfiguration complete in RRE    sleep2_time=${sleep2_time}
    Trigger RRC reestablishment with delay    cell_id=${cell_id}
    Trigger Reset RRC reconfiguration complete
    Verify Throughput    sleep_time=${sleep_time}

Reestablishment when A4 config ongoing
    [Arguments]    ${cell_id}=1    ${sleep1_time}=40s    ${sleep_time}=10s
    Check MeasConfig Del on UE
    Trigger hold RRC reconfiguration complete in RRE    sleep1_time=${sleep1_time}
    Trigger RRC reestablishment with delay    cell_id=${cell_id}
    Verify Throughput    sleep_time=${sleep_time}

Reestablishment when A4 first config
    [Arguments]    ${cell_id}=1    ${sleep_time}=10s
    Trigger hold RRC reconfiguration complete before RRE
    Trigger RRC reestablishment with delay    cell_id=${cell_id}
    Trigger Reset RRC reconfiguration complete
    Verify Throughput    sleep_time=${sleep_time}

C074_84_Teardown
    OnlineParamChange    ${OnlineParam_for_C074_C084_Recover}
    Common Test Teardown And Stop Capture Logs



