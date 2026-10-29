*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R3    owner-jolin.fan    team-CN1ET
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}
...    @{PARAMS_ADJ_REL_FOR_GNB2_to_simGNB4}

@{CB008140_config_GNB1}
...    NRDU-1:actInterGnbCa=disabled
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=153400
...    NRBTS/NRADJNRCELL-2:physCellId=61
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL


@{CB008140_config_GNB2}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=40
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL

@{PARAMS_ADJ_REL_FOR_GNB2_to_simGNB4}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/NRADJGNB-4:administrativeState=Unlocked
...    NRBTS/NRADJGNB-4:gNbIdLength=22
...    NRBTS/NRADJGNB-4:gNodeBId=35
...    NRBTS/NRADJGNB-4:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-4:xnLinkRef=2
...    NRBTS/NRADJGNB-4:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-4:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-44:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-44:fiveGsTac=200
...    NRBTS/NRADJNRCELL-44:gNbId=35
...    NRBTS/NRADJNRCELL-44:gNbIdLength=22
...    NRBTS/NRADJNRCELL-44:lcrId=5
...    NRBTS/NRADJNRCELL-44:nrarfcn=648000
...    NRBTS/NRADJNRCELL-44:physCellId=54
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-44:freqBandIndicatorNR=77

@{CA_basic_config}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRBTS:intGnbScellTempBlockTmr=60
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{L022_Precondition_GNB2}
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=2
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12:weightForSCellSelection=10

@{Deac_InterGnbCa}
...    NRDU-1:actInterGnbCa=disabled

@{Act_InterGnbCa}
...    NRDU-1:actInterGnbCa=DLOnly

@{L026_Precondition_GNB1}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{L026_Precondition_GNB2}
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB

@{ADD_CELL11_NRREL_Cell1-1}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

@{Modify_CELL11_NRREL_to_Cell1-2}
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:lcrId=2

@{Modify_CELL11_NRREL1_to_Sim4-5}
...    NRCELL-11/NRREL-1:gNbId=35
...    NRCELL-11/NRREL-1:lcrId=5

@{Delete_CELL11_NRREL_Cell1-2}
...    delete:NRCELL-11/NRREL-1

@{ADD_CELL11_NRREL_Cell1-2}
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{GNB1_iGnbCaXnCfUpBackOffTmr}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=310
@{GNB2_iGnbCaXnCfUpBackOffTmr}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=305

@{LOCK_CELL1_2}
...    NRCELL-2:administrativeState=Locked

@{UNLOCK_CELL1_2}
...    NRCELL-2:administrativeState=Unlocked

@{ADD_CELL12_NRREL_Cell1-2}
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

@{recover_env_gnb1}
...    delete:NRCELL-.*/NRREL-.*
...    NRDU-1:actInterGnbCa=DLOnly

@{recover_env_gnb2}
...    delete:NRCELL-.*/NRREL-.*
...    NRDU-1:actInterGnbCa=DLOnly

${SA_Capa_notSupport_N3_N28_CC}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000
...    170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64
...    C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50
...    B0381C3C17AAAAAAA9EAAAAAAA1700003801AB0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B0F00800309800070B02B0F00800
...    300400080B02B0F06C00303600090B02B0F00800300C000A0B02B0F018003036000B0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606
...    C001E160562E2600060080C0D800402C0AC7C4D000C01018060303600110B0201200DC0068099000A0268BA005283614489B1CF871224489B1CF871224489B1CF870A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8600A868C6318C6318C6318C0F
...    417001E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200000C0100000800800005004002008020080000600400003
...    8020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA4
...    A080000CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA48
...    0800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A050280088404008010
...    10020044020040080801002020040088040300501002004040080118080600A020180280801002020040088040400501010014040580B18080600C02018028080600C020040
...    08804030050100C014040080108080600A02004008404030050100C014202018030080600C10100C018040300508080600A02018028804030050100C018040300508080600C
...    020040088040080101002004040300518080100202004008080600A02018028804008010100C018040300618080100202018028080600C02018028D50F80008101820303850
...    58606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

*** Test Cases ***
CB008140_L022_primeGNB_actInterGnbCa_disabled_ue_noscelladded_then_modifyto_Dlonly_then_triggerA1MR_scell_added_depend_weightForSCellSelection
    [Documentation]
    ...    [purpose]:
    ...        This user scenario verifies gNB's behavior to support the online modification of actInterGnbCa from 'disabled' to 'DLOnly'.
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:52) cell4-TDD(n77)(pci:53) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(pci:61)
    ...    [Test Case Steps]:
    ...         a. UE1 register to gnb2-cell11, and PDU Session Setup, A1 meas for scell addition is configured,scell candidate cell2-12.
    ...         b. UE5 register to gnb2-cell11, and PDU Session Setup, A1 meas for scell addition is not configured because actInterGnbCa is
    ...            set to 'disabled'and UE5 not support n3-n28 CC.
    ...         c. online modify for Prime GNB2 to set 'actInterGnbCa=disabled' and then set 'actInterGnbCa=Dlonly' for both GNBs,
    ...            Prime GNB2 send 'IgNBCASetupRequest' and 'IgNBCAConfigurationUpdateIndication' to GNB1.
    ...         d. UE1 send A1 MR to trigger scell addition, scell cell1-1 add successfully.
    ...         e. Check logs.
    [Tags]    QC_285043    L022    CA_LABLE-FT(10MHz_TDD_n3+100MHz_TDD_n77)
    [Setup]    Preconfiguration GNB2 for case    ${L022_Precondition_GNB2}
    Ue Register And PDU Session Setup    ue_id=1    gateway=1    enb_id=3    cell_id=11
    Check UE configured with A1    ue_id=1    cellfreq=368430
    Ue Register And PDU Session Setup    ue_id=5    gateway=1    enb_id=3    cell_id=11
    Check UE not configured with A1    ue_id=5    cellfreq=368430
    OnlineParamChange for ext GNB2    ${Deac_InterGnbCa}
    OnlineParamChange for both GNBs    ${Act_InterGnbCa}    ${Act_InterGnbCa}
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=1    cellfreq=368430
    ...    pass_reg_ca=PhysCellId: 50] SCellIndex 1 activated successfully    T_dl=400    T_ul=20
    Check Wireshark Log    ${CURDIR}${/}A2A_L_022${/}a2a.ini    wait_string=UEContextRelease::0
    Release UEs    ue_type=all
    [Teardown]    case recover

CB008140-ET-L026_Online_modification_Add_ext_caRel_firstextscellofextgnb_existpre_IGNBxnxp_inPrimeGNB
    [Documentation]
    ...    [purpose]:
    ...        This user scenario verifies gNB's behavior to support the online modification of actInterGnbCa from 'DLOnly' to 'disabled' and nrrel.
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:52) cell4-TDD(n77)(pci:53) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(pci:61)
    ...    [Test Case Steps]:
    ...         a.UE1 register to gnb1-cell1, and PDU Session Setup, blind scell cell2-3 additon is successful.
    ...         b.run and check dl/ul traffic for UE1
    ...         c.online modify for GNB2 to add the first new NRREL cell1-1 for cell2-11.
    ...         d.UE2 register to gnb2-cell11, and PDU Session Setup, blind scell cell1-1 additon is successful.
    ...         e.run and check dl/ul traffic for UE2
    ...         f.online modify for GNB2 to change NRREL from cell1-1 to cell1-2 for cell2-11. UE2 will be bulk released due to cell2-11 reset,
    ...           GNB2 send 'IgNBCAConfigurationUpdateIndication' with cellsToRemove:cell1-1 and then triggers inter-gNB CA Xn and Xp setup with
    ...           gNB1 again for nrrel cell1-2 added.
    ...         g.UE3 register to gnb2-cell11, and PDU Session Setup, blind scell cell1-2 additon is successful.
    ...         h.online modify for GNB2 to change NRREL from cell1-2 to simGNB4 cell4-5 for cell2-11.UE3 will be bulk released due to cell2-11
    ...           reset,GNB2 send 'IgNBCAConfigurationUpdateIndication' with cellsToRemove:cell1-2 and then triggers inter-gNB CA Xn and Xp setup
    ...           with gNB4 for nrrel cell4-5 added.
    ...         i.release all UEs
    ...         j.online modify for GNB1 'iGnbCaXnCfUpBackOffTmr=310' and online modify for GNB2 'iGnbCaXnCfUpBackOffTmr=305', ensure that all
    ...            steps k~n can be executed before iGnbCaXnCfUpBackOffTmr timeout.
    ...         k.online modify for GNB2 to change NRREL from cell4-5 to cell1-2 for cell2-11, Msg XnAP:IGNB CA CONFIGURATION UPDATE INDICATION
    ...           triggerd and iGnbCaXnCfUpBackOffTmr timer start counts.
    ...         l.online modify for GNB1 to Online Modify to Lock and Unlock CELL1-2. Msg XnAP:IGNB CA CONFIGURATION UPDATE INDICATION will not
    ...           triggerd because these two change will be combined within iGnbCaXnCfUpBackOffTmr.
    ...         m.online modify for GNB2 to delete NRREL cell1-2 and add again for cell2-11. Once the only one scell NRREL cell1-2 is added again
    ...            GNB2 send 'IgNBCASetupRequest' to GNB1 and timer iGnbCaXnCfUpBackOffTmr is canceled at the same time. GNB1 send Msg XnAP:
    ...           'IGNB CA CONFIGURATION UPDATE INDICATION' with 'Inter-gNB-CA-Allowed: allowed' and 'ReportedCellList:cell1-2'
    ...         n.online modify for GNB2 to add NRREL cell1-2 for cell2-12. Msg XnAP:IGNB CA CONFIGURATION UPDATE INDICATION will not triggerd
    ...           because this ext scell cell1_2 is already known.
    ...         o.UE4 register to gnb2-cell12, and PDU Session Setup, blind scell cell1-2 additon is successful.
    ...         p.Check logs
    [Tags]    QC_285044    L026    CA_LABLE-TT(100MHz_TDD_n77+100MHz_TDD_n77)    CA_LABLE-FT(10MHz_TDD_n3+40MHz_TDD_n77)
    [Setup]    Preconfiguration GNBs for case    ${L026_Precondition_GNB1}    ${L026_Precondition_GNB2}
    Make call for UE1 to cell1-1 with blind scell and start traffic
    OnlineParamChange for ext GNB2    ${ADD_CELL11_NRREL_Cell1-1}
    Make call for UE2 to cell2-11 with blind scell and start traffic
    OnlineParamChange for ext GNB2    ${Modify_CELL11_NRREL_to_Cell1-2}
    Make call for UE3 to cell2-11 with blind scell and start traffic
    Online Modify to Change GNB2 CELL11 NRREL from CELL1-2 to sim GNB cell4-5
    Release UEs    ue_type=all
    Online Modify to set iGnbCaXnCfUpBackOffTmr and trigger timer
    Online Modify to Lock and Unlock CELL1-2
    Online Modify Delete CELL2-11 NRREL CELL1-2 and ADD again
    OnlineParamChange for ext GNB2    ${ADD_CELL12_NRREL_Cell1-2}
    Make call for UE4 to cell2-12 with blind scell and start traffic
    Check Logs
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Preconfiguration GNB2 for case
    [Arguments]    ${Online_Param}
    Delta Commission Parameters GNB2    ${Online_Param}
    Common Test Setup And Start To Capture Logs

Preconfiguration GNBs for case
    [Arguments]    ${Online_Paramq_gnb1}    ${Online_Paramq_gnb2}
    Delta Commission Parameters    ${Online_Paramq_gnb1}
    Delta Commission Parameters GNB2    ${Online_Paramq_gnb2}
    Common Test Setup And Start To Capture Logs

Modify Cfg
    Update Cfg    ue_param id=5 ue_nr_capabilities=${SA_Capa_notSupport_N3_N28_CC}
    ${gNB3_configuration}    catenate
    ...    set_gnb id=3 type=external plmn=311:489 s1u=$GNB2_S1U_ADDR x2=$GNB2_X2_ADDR:36422 ng=$GNB2_NG_ADDR xn=$GNB2_XN_ADDR gnb_id=0x02:22
    ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5 xp=10.0.1.3:32742 xpu=10.0.1.3:32742
    ...    xp_management=on
    Update Cfg    ${gNB3_configuration}
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell5_sim_configuration}    catenate    set_cell id=5 gnb=4 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=10.0.2.92:9999
    ...    nr_arfcn=648000:648000 gscn=8000 nr_scs=30kHz bs_channel_bandwidth=40MHz
    Update Cfg    ${gNB4_Cell5_sim_configuration}

Ue Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table

Check UE configured with A1
    [Arguments]    ${ue_id}    ${cellfreq}
    ${result}=    Run Keyword And Return Status    get_nr_meas_id_for_specific_type_and_frequency
    ...    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be True    '${result}' == 'True'

Check UE not configured with A1
    [Arguments]    ${ue_id}    ${cellfreq}
    ${result}=    Run Keyword And Return Status    get_nr_meas_id_for_specific_type_and_frequency
    ...    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be True    '${result}' == 'False'

UE Send A1 Trigger Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}    ${T_dl}    ${T_ul}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 srsrq_nr=82
    ...    pass_regexp=${pass_reg_ca}
    Run Traffic And Verify Throughput    ue_id=${ue_id}    tput_dl=${T_dl}    tput_ul=${T_ul}

Make call for UE1 to cell1-1 with blind scell and start traffic
    Ue Register And PDU Session Setup with blind scell addition    ue_id=1    gateway=1    enb_id=2    cell_id=1
    ...    regexp=PhysCellId: 52] SCellIndex 1 activated successfully
    Run Traffic And Verify Throughput    ue_id=1    tput_dl=400    tput_ul=20

Make call for UE2 to cell2-11 with blind scell and start traffic
    Ue Register And PDU Session Setup with blind scell addition    ue_id=2    gateway=2    enb_id=3    cell_id=11
    ...    regexp=PhysCellId: 50] SCellIndex 1 activated successfully
    Run Traffic And Verify Throughput    ue_id=2    tput_dl=400    tput_ul=20

Make call for UE3 to cell2-11 with blind scell and start traffic
    Ue Register And PDU Session Setup with blind scell addition    ue_id=3    gateway=3    enb_id=3    cell_id=11
    ...    regexp=PhysCellId: 51] SCellIndex 1 activated successfully
    Run Traffic And Verify Throughput    ue_id=3    tput_dl=250    tput_ul=20

Make call for UE4 to cell2-12 with blind scell and start traffic
    Ue Register And PDU Session Setup with blind scell addition    ue_id=4    gateway=4    enb_id=3    cell_id=12
    ...    regexp=PhysCellId: 51] SCellIndex 1 activated successfully
    Run Traffic And Verify Throughput    ue_id=4    tput_dl=280    tput_ul=20

Online Modify to set iGnbCaXnCfUpBackOffTmr and trigger timer
    OnlineParamChange for both GNBs    ${GNB1_iGnbCaXnCfUpBackOffTmr}    ${GNB2_iGnbCaXnCfUpBackOffTmr}
    OnlineParamChange for ext GNB2    ${Modify_CELL11_NRREL_to_Cell1-2}

Online Modify Delete CELL2-11 NRREL CELL1-2 and ADD again
    OnlineParamChange for ext GNB2    ${Delete_CELL11_NRREL_Cell1-2}
    OnlineParamChange for ext GNB2    ${ADD_CELL11_NRREL_Cell1-2}

Online Modify to Lock and Unlock CELL1-2
    Delta Commission Parameters    ${LOCK_CELL1_2}
    Object Should Exist    NRCELL-2:administrativeState=Locked
    Delta Commission Parameters    ${UNLOCK_CELL1_2}
    Object Should Exist    NRCELL-2:administrativeState=Unlocked
    Cells Should Be Onair    check_sib=${True}

OnlineParamChange for ext GNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters GNB2    ${Online_Param}
    Cells Should Be Onair GNB2    check_sib=${True}

OnlineParamChange for both GNBs
    [Arguments]    ${GNB1_Param}    ${GNB2_Param}
    Delta Commission Parameters    ${GNB1_Param}
    Delta Commission Parameters GNB2    ${GNB2_Param}
    Cells Should Be Onair    check_sib=${True}
    Cells Should Be Onair GNB2    check_sib=${True}

Ue Register And PDU Session Setup with blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${regexp}=SCellIndex 1 activated
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${regexp}
    Sleep    5s    #wait all sysinfo

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s    ${tput_dl}=200    ${tput_ul}=20
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=25 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${tput_dl}    Tput_ul=${tput_ul}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=20    ${sleep_time}=15s
    Execute Egate Command    ue_disp
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Online Modify to Change GNB2 CELL11 NRREL from CELL1-2 to sim GNB cell4-5
    Get correct xp xgu version
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param    IgNBCAXpProtocolVersion=${C_XpVersion}    IgNBCAXgUProtocolVersion=${C_XgUVersion}
    Check alarm of Xp Xg version with simGNB mismatch is not raised    xpfaultid=7108    xgfaultid=7109
    OnlineParamChange for ext GNB2    ${Modify_CELL11_NRREL1_to_Sim4-5}

Get correct xp xgu version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    set test variable    ${C_XpVersion}    ${IgNBCAXpProtocol_Version}
    set test variable    ${C_XgUVersion}    ${IgNBCAXgUProtocol_Version}

Check alarm of Xp Xg version with simGNB mismatch is not raised
    [Arguments]    ${xpfaultid}=7108    ${xgfaultid}=7109
    FM Fault Should Be Cleared    fault_id=${xpfaultid}
    FM Fault Should Be Cleared    fault_id=${xgfaultid}

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    Execute Egate Command    enb_xp_param xp_peers=3 id=4 xp_setup_max_retries=3    pass_regexp=is up    timeout=220s

Set Sim gNB ignb CA Addition Param
    [Arguments]    ${IgNBCAXpProtocolVersion}=12    ${IgNBCAXgUProtocolVersion}=1
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpProtocolVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUProtocolVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=5 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50

case recover
    Delta Commission Parameters    ${recover_env_gnb1}
    Delta Commission Parameters GNB2    ${recover_env_gnb2}
    Common Test Teardown And Stop Capture Logs

Check Logs
    Check Wireshark Log    ${CURDIR}${/}A2A_L_026${/}a2a.ini    wait_string=IgNBCAConfigurationUpdateIndication::10
    Check Wireshark Log GNB2    ${CURDIR}${/}A2A_L_026${/}a2a_gnb2.ini    wait_string=IgNBCAConfigurationUpdateIndication::11
