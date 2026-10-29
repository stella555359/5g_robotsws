*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs And Recovery RD parameter
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1ET    owner-jun.15.zhang    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}

@{enableBeamforming}
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:beamSet:basicBeamSet=beamSet_6
...    NRCELL:numberOfRxBeamforming=6Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=120
...    NRCELL:beamSet:upperEdgeAngle=60
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams

@{srsConfig}
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRCELL:actUlSrsBm=true
...    NRCELL:actDlSrsBm=true
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL:srsForBeamMgmt:comb=comb2
...    NRCELL:msg1FrequencyStart=18
...    NRCELL:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL:wbSbSrsSwitch:prbRatioHysteresis=1
...    NRCELL:wbSbSrsSwitch:prbRatioThreshold=2
...    NRCELL:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL:wbSbSrsSwitch:rankThreshold=1
...    NRCELL:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL:wbSbSrsSwitch:seHysteresis=100
...    NRCELL:wbSbSrsSwitch:seThreshold=1
...    NRCELL:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=51
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-2:srsForBeamMgmt:cSRS=63
...    NRCELL-2:srsForBeamMgmt:bSRS=2
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
#1208 Frame Structure
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols

@{CB008322}
...    NRBTS:actCarrierAggregation=false
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true
...    NRDU-1:actInterNumerologyCa=false
...    NRCELLGRP-0:ssBurstSetPeriod=20
...    NRCELLGRP-1:ssBurstSetPeriod=20
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actCDrx=false
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL-1:chBw=80MHz
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:actCsirsMultiplexing=false
...    NRCELL:actDlSrsSubbandBm=true
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL:srsForSubbandBm:srsUePeriodicityInput=slots40
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350

#${rdSrsCodebookAndTas}    0x590103
${rdMinSrsUePeriodicity}    0x5901E6
${rdSubBandSectorNumber}    0x5901DC
${rdSrsAllocMethod}    0x5901B6
${rdMaxSrsResPerSpecialSym1208}    0x5901EC
${rdMaxSrsResPerSpecialSym1070}    0x5901ED
${rdMaxSrsResPerSpecialSym1116}    0x5901EE
${rdMaxSrsResPerSym1208}    0x5900FD
${rdMaxSrsResPerSym1070}    0x590127
${rdMaxSrsResPerSym1116}    0x590128
${rdSubbandBfMethod}    0x5901BD
${rdEnableSrsSwitchScheduler}    0x5805ae
${rdNumSrsCheck}    0x5805b5

@{PARAMS_IN_SWCONFIG}
#...    ${rdSrsCodebookAndTas}=2
...    ${rdMinSrsUePeriodicity}=40
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=10
...    ${rdMaxSrsResPerSpecialSym1116}=10
...    ${rdMaxSrsResPerSpecialSym1070}=10
...    ${rdMaxSrsResPerSym1208}=11
...    ${rdMaxSrsResPerSym1116}=11
...    ${rdMaxSrsResPerSym1070}=11
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496; 3 for SKTMVP

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

#SA UE1/2:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t4r4 maxNumberSRS-Ports-PerResource=n4
${ue_nr_cap_SA_UE}    SEPARATOR=
...    E1A09000575F7A13160003C4A0002C1001018093170019C3D0B004D9061CF9863CA160704C060188E00D51B137582308682041D20F003EB65C558D0E7C471E819F604F8
...    CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0006480007001B280002800003A8D85181AC1184341020E907801F5B2E2AC6873E238F40CFB027C6647
...    1E439F40CFB027D473E618F28581C0E1E2E000BE0038002F8003200003800C3070A0200000718785000184D00008718785000182800010718705007134000018718389A
...    10000038C3C4D000C26800085C00C028809A3200045034089B1CF870A246D8E7C3851226C73E1C29D1B639F0E046D8E7C3851A36C73E181E836001F0014080A00E06012
...    803800301F09C01000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000C00800007004000038020010000000
...    40000400200100C0300400004802000028010008080200200101C0700400005C928010300C2E494000185C928030300C0300C2E49401018060185C928060300C0300C03
...    00C030B9250080601806018061724A01C0C0300C0300C0300C030B825000061724A0000C4E49400818062724A0080C0300C4E094000189C928070300C0300C0300C0300
...    C4E4940181806018062724A0000C0E49403818060180601806018060724A00C0C0300C030382500006060080000D037953595359535819581B5833594B5933580B58095
...    811591B5BA4654D0341000009652504000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010
...    000A96524040002E5949410040C0325949410000C965250314AAAA9545D2A8BA55154162A81C55068AA531549A2A80C55028AA47555DA81A017C09E8140A05028140A05
...    028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000600101C00C20200C018080300610100600C04008030808030060200C018
...    D50300008101820303A1000

#SA UE3/4/5:
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE_t1r4}    SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E26800001190000580804C0210F01A000A07050060200900180780000000
...    00000D1528A1452827004100000012020400004048000302A42A8029027004002004008004008020

*** Test Cases ***
CB008322-ET-B011_Verify ue with SB TAS SRS and dedicate CB SRS reconfig to WB TAS and keep original CB SRS
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify the wide band TAS SRS configuration algorithm of gNB. gNB will select UEs with channel condition better than some
    ...    threshold, buffer larger than some threshold as candidate subband BF UEs and wide band TAS SRS will be configured to these UEs if there
    ...    is available SRS resource.
    ...    [Configuration]:
    ...    Frame structure 1208, srsForBeamMgmt.srsUePeriodicity = 40slots, srsForBeamMgmt.minSrsUePeriodicity = 40slots
    ...    / is availableWidebandSrsBmResourcesTable, | is availableSubbandSrsBmResourcesTable
    ...    |Comb  |cyclicShift| symbol 0 | symbol 1 | symbol 2 | symbol 3 | symbol 4 | symbol 5 | symbol 6 | symbol 7 |
    ...    |     Slot id      |     3    |     8    |    13    |    18    |    23    |    28    |    33    |    38    |
    ...    |  0   |     0     |  UE1(CB) |    UE1   |    UE1   |    UE1   |    UE1   |          |          |          |
    ...    |  0   |     4     |          |          |          |          |          |          |          |          |
    ...    |  0   |     2     |          |          |          |          |          |          |          |          |
    ...    |  0   |     6     |          |          |          |          |          |          |          |          |
    ...    |  1   |     0     |          |          /          /          /    UE1   /    UE1   /    UE1   /    UE1   |
    ...    |  1   |     4     |          |          /          /          /          /          /          /          |
    ...    |  1   |     2     |          |          /          /          /          /          /          /          |
    ...    |  1   |     6     |          |          /          /          /          /          /          /          |
    ...    2.Test Case Steps:
    ...         a. UE1 register and PDU session setup On Cell1
    ...         b. UE1 start Traffic
    ...         c. UE1 stop Traffic
    ...    3. Expected Results:
    ...         Step a: UE1 register and PDU Session setup successfully, only 1 dedicate codebook srs (1 port) and 4 subband tas srs is allocated
    ...         Step b: RRC reconfiguration wide band SRS with periodicity indicated srsUePeriodicitySubbandBm
    ...         Step c: RRC reconfiguration subband srs and keep origin codebook to UE1. The wideband tas srs resource shall be released.
    [Tags]    B011    B018    QC_320601
    Set radPdcchApplyToSeparateStream for AP
    SA UE attach    ue_id=1    cell_id=1
    Send And Verify Throuput
    UE Stop Traffic And Verify No Codebook Reconfig
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B011${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008322-ET-B025_Verify mutiple wide band ues last symbol allocation follow load base rule
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify the mutiple wide band ues last symbol allocation follow load base rule.
    ...    [Configuration]:
    ...    Frame structure 1208, srsForBeamMgmt.srsUePeriodicity = 20slots, srsForBeamMgmt.minSrsUePeriodicity = 40slots
    ...    | is availableWidebandSrsBmResourcesTable, / is availableSubbandSrsBmResourcesTable1, \ is availableSubbandSrsBmResourcesTable2
    ...    |Comb  |cyclicShift| symbol 0 | symbol 1 | symbol 2 | symbol 3 | symbol 4 | symbol 5 | symbol 6 | symbol 7 |
    ...    |     Slot id      |     3    |     8    |    13    |    18    |    23    |    28    |    33    |    38    |
    ...    |  0   |     1     |    UE3   |    UE3   |    UE3   |    UE3   |    UE2   |    UE2   |    UE2   |    UE2   |
    ...    |  0   |     5     |          |          |    UE5   |    UE4   |    UE4   |    UE4   |    UE4   |          |
    ...    |  0   |     3     |          |          |          |    UE5   |    UE5   |    UE5   |          |          |
    ...    |  0   |     7     |          |          |          |          |          |          |          |          |
    ...    |  1   |     1     /    UEs   /    UEs   /    UEs   /    UEs   \          \          \          \          |
    ...    |  1   |     5     /          /          /          /          \          \          \          \          |
    ...    |  1   |     3     /          /          /          /          \          \          \          \          |
    ...    |  1   |     7     /          /          /          /          \          \          \          \          |
    ...    2.Test Case Steps:
    ...         a. UE2 register and PDU session setup On Cell2
    ...         b. UE2 start Traffic
    ...         a. UE3 register and PDU session setup On Cell2
    ...         b. UE3 start Traffic
    ...         a. UE4 register and PDU session setup On Cell2
    ...         b. UE4 start Traffic
    ...         a. UE5 register and PDU session setup On Cell2
    ...         b. UE5 start Traffic
    ...    3. Expected Results:
    ...         Step a: UE2 register and PDU Session setup successfully, four subband tas srs resource is configured and codebook resource is reused
    ...         Step b: RRC reconfiguration wide band SRS with periodicity indicated srsUePeriodicitySubbandBm for UE2
    ...                 Resourcce position See Configuration table, check last symnbol (last item in resource list) shall be slot 38
    ...         Step c: UE3 register and PDU Session setup successfully, four subband tas srs resource is configured and codebook resource is reused
    ...         Step d: RRC reconfiguration wide band SRS with periodicity indicated srsUePeriodicitySubbandBm for UE3
    ...                 Resourcce position See Configuration table, check last symnbol (last item in resource list) shall be slot 18
    ...         Step e: UE4 register and PDU Session setup successfully, four subband tas srs resource is configured and codebook resource is reused
    ...         Step f: RRC reconfiguration wide band SRS with periodicity indicated srsUePeriodicitySubbandBm for UE4
    ...                 Resourcce position See Configuration table, check last symnbol (last item in resource list) shall be slot 33
    ...         Step g: UE5 register and PDU Session setup successfully, four subband tas srs resource is configured and codebook resource is reused
    ...         Step h: RRC reconfiguration wide band SRS with periodicity indicated srsUePeriodicitySubbandBm for UE5
    ...                 Resourcce position See Configuration table, check last symnbol (last item in resource list) shall be slot 28
    [Tags]    B025    QC_320623
    Set radPdcchApplyToSeparateStream for AP
    SA UE attach    ue_id=2    cell_id=2
    Send And Verify Throuput    ue_id=2
    SA UE attach    ue_id=3    cell_id=2
    Send And Verify Throuput    ue_id=3
    SA UE attach    ue_id=4    cell_id=2
    Send And Verify Throuput    ue_id=4
    SA UE attach    ue_id=5    cell_id=2
    Send And Verify Throuput    ue_id=5
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B025${/}a2a.ini    wait_string=UEContextReleaseComplete::16

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_AQQL    ue_count=5
	
Common Test Teardown And Stop Capture Logs And Recovery RD parameter
    Common Test Teardown And Stop Capture Logs
	Recovery radPdcchApplyToSeparateStream for AP

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir /home/ute/bsr_package/
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git /home/ute/bsr_package/
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=60

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_cap_SA_UE_t1r4}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${ue_nr_cap_SA_UE_t1r4}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${ue_nr_cap_SA_UE_t1r4}

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Send Traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}

Send Traffic
    [Arguments]    ${ue_id}=1
    Run Keyword And Ignore Error    Execute Egate Command    
    ...    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Run Keyword And Ignore Error    Execute Egate Command    
    ...    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Run Keyword And Ignore Error     Execute Egate Command    
    ...    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s    ${Tput_dl}=250
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}

UE Stop Traffic And Verify No Codebook Reconfig
    Execute Egate Command    trf_data_stop ue=1 pdu=1    pass_regexp=Traffic was stopped    fail_regexp=srs-ResourceId 0    timeout=20s

Set radPdcchApplyToSeparateStream for AP
    ${Command_1}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP 
    ...    --value 1 --change-type persistent --timeout 5
	${Command_3}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog 
    ...    --value 15 --change-type persistent --timeout 5
    Execute Command On Wts    ${Command_1}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_3}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5

Recovery radPdcchApplyToSeparateStream for AP
    ${Command_1}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP 
    ...    --value 0 --change-type persistent --timeout 5
	${Command_3}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog 
    ...    --value 65535 --change-type persistent --timeout 5
    Execute Command On Wts    ${Command_1}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 55
	Execute Command On Wts    ${Command_3}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5