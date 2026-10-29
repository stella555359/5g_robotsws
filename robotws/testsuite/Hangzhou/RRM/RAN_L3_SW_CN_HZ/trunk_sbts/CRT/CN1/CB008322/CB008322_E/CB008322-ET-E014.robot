*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1ET    owner-jun.15.zhang    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{PARAMS_FOR_Drx}
...    @{PARAMS_FOR_CSI}
...    NRCELL:nrofHARQProcessesForPDSCH=16

@{enableBeamforming}
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:beamSet:basicBeamSet=beamSet_6
...    NRCELL:beamSet:tiltOffset=0
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
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
...    NRCELL:actUlSrsBm=false
...    NRCELL:actDlSrsBm=true
...    NRCELL:msg1FrequencyStart=18
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL:srsForBeamMgmt:comb=comb2
...    NRCELL:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL:srsForBeamMgmt:cSRS=49
...    NRCELL:srsForBeamMgmt:bSRS=2
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL:wbSbSrsSwitch:prbRatioHysteresis=15
...    NRCELL:wbSbSrsSwitch:prbRatioThreshold=20
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
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:actDlSrsSubbandBm=true
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL:srsForSubbandBm:srsUePeriodicityInput=slots40
...    NRCELL:chBw=80MHz

@{PARAMS_FOR_Drx}
...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actCDrx=true
...    NRDRX-4:drxInactivityTimer=40ms
...    NRDRX-4:drxLongCycle=40ms
...    NRDRX-4:drxOnDurationTimer=30ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    NRCELL:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRCELL:actUlClosedLoopPwrCtrl=puschSrs
...    NRCELL:nrUlClpcProfileDN=NRULCLPC_PROFILE-1
...    NRCELL:srPeriodicity=slots40
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160

@{PARAMS_FOR_CSI}
...    NRCELL:actCsirsMultiplexing=false
...    NRCELL:actUeCsirsCoexistCellCsirs=true
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL:periodicCsiAcquisition:csirsPower=3
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=2

${rdSrsCodebookAndTas}    0x590103
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
${rdNumberOfUeCsirsSymbol}    0x580265
${rdCsiRsReconfigCellToUE}    0x590179

@{PARAMS_IN_SWCONFIG}
...    ${rdSrsCodebookAndTas}=1
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=4
...    ${rdMaxSrsResPerSpecialSym1116}=4
...    ${rdMaxSrsResPerSpecialSym1070}=4
...    ${rdMaxSrsResPerSym1208}=5
...    ${rdMaxSrsResPerSym1116}=5
...    ${rdMaxSrsResPerSym1070}=5
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
...    ${rdNumberOfUeCsirsSymbol}=4
...    ${rdCsiRsReconfigCellToUE}=1
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496; 3 for SKTMVP

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

@{PARAMS_IN_IPHY_XML}    vcell:dlFeatures=pmiBeams

#SA UE1:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t4r4 maxNumberSRS-Ports-PerResource=n4
${ue_nr_cap_SA_UE1}    SEPARATOR=
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

#SA UE2/3:
#BAND78: BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE2}    SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E26800001190000580804C0230F01A000A07050060200900180780000000
...    00000D1528A1452827004100000012020400004048040302A42A8029027004002004008004008020

#SA UE4/5:
#BAND78: BAND78: t1r2 maxNumberSRS-Ports-PerResource=n1 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE4}    SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E268000011D0000160201300803C088000A0705006020090018078000000
...    000000D1528A1452827004100000012020400004048000302A42A802902700400200400800400802

#NSA UE11:
#BAND78: t2r4 maxNumberSRS-Ports-PerResource=n2 BAND41: t1r1 maxNumberSRS-Ports-PerResource=n1
${ue11_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000000
...    2C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C04180
...    9A320005C83C49D2226C73E1C49D1226C73E1C49D1226C73E1C49D1226C73E1C49D1224C73E8D3A2448931CFA24E8922639F060144000100808
...    010060201803080002010100200804030061800040202018030080600C020180308000201010020080400802080004020201803040002010100C018

${ue_nr_full_cap_n2}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C7
...    90E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB00000
...    0FEC000000C80000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702B8F88DAC1184341
...    020F941E00556C98AB0A1CF88E3C600000000000000000000000013FFE00000FFF800000C80000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C4600
...    0E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B
...    1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C460000041
...    60562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B010465001760F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1
...    C4891226C73E1C28103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF8002E1E318
...    C6318C6318C6318C3D06C003C00281C1401C0C02500700060240040603E0900200000001000002008000000040000080200000801000006008000040040000280200100
...    4010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D60
...    25604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A9
...    6524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1A00BC04A8140A05028140A05028140A
...    05028140A05028140A000C10100C018040080108080100402018030804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030
...    080600C10100200804008021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

@{UE_PDU_expect}
...    nrofPorts p4
...    Initial Context Setup Successful
@{UE_ENDC_expect}
...    nrofPorts p4
...    successful RA

*** Test Cases ***
CB008322-ET-E014_Verify_2200_IWK_Cell_Spec_CSIRS_Reconfig_To_UE_Spec_When_UE_Reconfig_To_WB_SRS_And_Back_To_Cell_Spec_CSIRS_When_UE_Reconfig_To_ASRS
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will Verify UE with subband SRS And Cell Spec CSIRS reconfig to UE wideband SRS and UE specific CSISRS successfully, and when 
    ...    reconfig to subband SRS, cell specific CSIRS resouce reconfigured due to only aperiodic srs allocated for UE when 2200 is enabled.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=80MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=80MHz
    ...    2.Test Case Steps:
    ...         a. PreUE SA UE2, NSA UE11, SA UE4 and UE5 attach to Cell2 one by one.
    ...         b. SA UE1 attach to Cell2 and setup PDU
    ...         c. SA UE4 release.
    ...         d. UE1 send full DL traffic.
    ...         e. SA UE3 attach to Cell2 and setup PDU
    ...         f. UE1 stop DL traffic.
    ...    3. Expected Results:
    ...         Step a: UEs are attached and configured with UE specific CSIRS resource (Check rrcReconfiguration.csi_MeasConfig IE: nrofPorts=p4).
    ...         Step b: UE1 is configured with subband 4 1 port tas srs on or close to common drx duration slot.
    ...         The fisrt tas srs resource is reusing codebook srs resource.
    ...         Cell specific CSIRS resource is configured for UE1 due to rdNumberOfUeCsirsSymbol is not enough(Check nrofPorts=p8).
    ...         Step c: UE4 releases successfully.
    ...         Step d: UE1 is configured with 4 1 port wideband tas srs resource regardless of drx.
    ...         UE specific CSIRS resource is configured.
    ...         Step e: UE3 is configured 2 2 port tas srs resource on or close to common drx duration slot.
    ...         Cell specific CSIRS resource allocated for the UE.
    ...         Step f: UE1 is allocated with 1 1 port aperiodic codebook srs resource.
    ...         Cell specific CSIRS resource is configured for UE1 due to no periodic srs resource allocated(Check nrofPorts=p8).
    [Tags]    QC_320657    E014
    PRE UE Attach To Cell2
    SA UE Attach    ue_id=1
    SA UE Deattach    ue_id=4
    SA UE1 Send And Verify Throughput
    SA UE Attach    ue_id=3
    UE1 Stop Traffic
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_E014${/}a2a.ini    wait_string=UEContextReleaseComplete::22

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_AQQL    ue_count=5

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir /home/ute/bsr_package/
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git /home/ute/bsr_package/
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=60

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE2}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_cap_SA_UE2}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${ue_nr_cap_SA_UE4}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${ue_nr_cap_SA_UE4}
    Update Cfg    ue_param id=11 ue_nr_capabilities=${ue_nr_full_cap_n2} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}

PRE UE Attach To Cell2
    SA UE Attach And Verify UE Specific CSIRS    ue_id=2
    NSA UE Attach And Verify UE Specific CSIRS    ue_id=11
    SA UE Attach And Verify UE Specific CSIRS    ue_id=4
    SA UE Attach And Verify UE Specific CSIRS    ue_id=5

SA UE Attach And Verify UE Specific CSIRS
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    qosflow_modify qos_flow=1 default=on ue=${ue_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=${UE_PDU_expect}    timeout=20s

SA UE Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    qosflow_modify qos_flow=1 default=on ue=${ue_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

NSA UE Attach And Verify UE Specific CSIRS
    [Arguments]    ${ue_id}=11    ${target_cells}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=${UE_ENDC_expect}    timeout=20s

SA UE1 Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Send Traffic SA    ue_id=${ue_id}
    Verify Throuput SA    ue_id=${ue_id}

Send Traffic SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=1    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=4    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=5    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=6    pass_regexp=Started Downlink Internal traffic

Verify Throuput SA
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s    ${Tput_dl}=810
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${Tput_dl}

UE1 Stop Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Sleep    2s    #Wait trf stop and send rrcReconfiguration

SA UE Deattach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s
