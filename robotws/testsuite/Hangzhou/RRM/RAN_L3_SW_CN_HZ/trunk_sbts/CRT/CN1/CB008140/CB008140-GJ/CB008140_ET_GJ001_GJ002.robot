*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-Blues_SGT&A
...    owner-Tingjian.Mao    release-SBTS23R3    CRT
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    ${rdMaxIncomingCaRel}=2
@{PARAMS_IN_SWCONFIG_GNB2}
...    ${rdMaxIncomingCaRel}=2
${rdMaxIncomingCaRel}    0x5901d2

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel_for_NRCELL_11}
...    @{PARAMS_FOR_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_FOR_GNB1}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-11:msg1FrequencyStart=20
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-12:msg1FrequencyStart=20
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL-11:weightForSCellSelection=80

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/NRCELL:actEnhMultipleDedicatedBWPs=true

@{GNB1_CA_rel_for_NRCELL_11}
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:sCellAdditionMethod=blind

@{GNB2_CA}
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-11:gNbId=1
...    NRCELL-14/NRREL-11:gNbIdLength=22
...    NRCELL-14/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-11:lcrId=11
...    NRCELL-14/NRREL-11:removeNotAllowed=false
...    NRCELL-14/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind

@{2CC_success}
...    PhysCellId: 60] SCellIndex 1 activated successfully at airphone

@{3CC_success}
...    PhysCellId: 60] SCellIndex 1 activated successfully at airphone
...    PhysCellId: 61] SCellIndex 2 activated successfully at airphone

@{Add_NRREL_12_on_CELL2_14}
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:gNbIdLength=22
...    NRCELL-14/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=false
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-12:sCellAdditionMethod=blind

${CA_support_list}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa

#only_CA_2CC_N28A_N3
${SA_Capa_Support_2CC_FF_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B00B582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FF8000007FE00000044000702A8D899AC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0A8360DEB04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2858
...    1C0E1E13FFE00000FFF80000088000E0073C3C4C000E010000010B0102A07130200038581587836001C02000006160561E140007008000008
...    581587898001C1B000002160561E26000713000003058158B898001C02000E140000040B02B17130003836001C1B000004160562E14000700
...    80038360000082C0AC5C28000E01000700800001058158B898001C02000E0D8000020B02B170A0003836001C1B000004160562E26000706C0
...    038500000102C0AC3C1B000E0D8000030B0200E00DC028809900083505683A14489B1CF870226C73E1C28913639F0E14489B1CF870A244D8E
...    7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E042810363
...    9F0000A870C6318C6318C6318C6F413003C00281C1401C0C02500700060240040603E09002000000010008000000200000001000002008000
...    02004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B0040020
...    48120080000C0339535953582958215833582B594B5933580B581B58095811583B40D04000025949410000196526040000659490100003965
...    2404000125949010000596526040001A594901000079652404000225949010000996524040002A5949010000B965250400032594901000031
...    65240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028140A0502
...    8140A000E10100C018040080108080100402018030804008010100C018040300608080600C02018030804008010100C018040080110080600
...    C02018030080600C10100200804008020008020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E82830
...    5A


#only_CA_3CC_N28A_N3(2A)
${SA_Capa_Support_3CC_FFF_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FFC000003FF000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E007BC3C4C000E010000010B0102A07130200038581587836001C02000006160561E14000700800000
...    8581587898001C1B000002160562E0D80070080038040000142C0AC3C4C000E260000060B02B17130003804001C28000008160562E2600070
...    6C0038360000082C0AC5C28000E01000706C00001058158B850001C02000E010000020B02B17130003804001C1B000004160562E14000706C
...    0038360000082C0AC5C4C000E0D80070A0000020581587836001C1B000006160401C01B8051013200107A05C83E14489B1CF870226C73E1C2
...    8913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810
...    206C73E044810206C73E044810206C73E0428103639F000B878C6318C6318C6318C630F413003C00281C1401C0C02500700060240040603E0
...    900200000001000800000020000000100000200800002004000018020000100100000A008004010040100000C008000070040020000000800
...    0080040000480200000C010000140080000B004002048120080000C0339535953582958215833582B594B5933580B581B58095811583B40D0
...    40000259494100001965260400006594901000039652404000125949010000596526040001A59490100007965240400022594901000099652
...    4040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E284
...    80BC04A8140A05028140A05028140A05028140A05028140A000E10100C018040080108080100402018030804008010100C018040300608080
...    600C02018030804008010100C018040080110080600C02018030080600C10100200804008020008020043543E00020406080C0E1416181A20
...    22242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008140-ET-GJ001_interGnb_CA_SA_Call_scell_addition_failure_with_NRREL_not_enough
    [Documentation]
    ...    1. This user scenario porpuse is add some exploring test case about modification the value of optional parameter
    ...    2. Configuration
    ...       GNB3 is composed of CELL3.1 CELL3.2 CELL3.13 CELL3.14
    ...       GNB2 is composed of CELL2.11 CELL2.12
    ...       Cell2_11 is candidate SCell of all other cells
    ...       RdMaxIncomingCaRel: 0x5901d2=2 in cell2_11
    ...       SCell addition method is blind
    ...    3. Test Case Steps:
    ...         a.UE1 intergnb ca setup successfully for cell3_14+cell2_11; UE2 intergnb ca setup successfully for cell3_1+cell2_11
    ...         b.UE3 setup in cell3_2, trigger intergnb ca setup to scell cell2_11 failed due to rdMaxIncomingCaRel exceed
    ...         c.UE4 setup in cell3_2, trigger intergnb ca setup to scell cell2_11 failed due to rdMaxIncomingCaRel exceed
    ...         d.UE5 setup in cell2_12, trigger intragnb ca setup to scell cell2_11 failed due to rdMaxIncomingCaRel exceed
    ...         e.UEs deregister should be successfully
    [Tags]    GJ001    QC_280796    CA_LABEL-FF(15Mhz_FDD_n28+20Mhz_FDD_n3)    CA_LABEL-TF(100Mhz_TDD_n77+20Mhz_FDD_n3)
    Sa Ue Attach and 2CC success      ue_id=1    enb_id=3    cell_id=14
    Sa Ue Attach and 2CC success    ue_id=2    enb_id=3    cell_id=1
    Sa Ue Attach and 2CC unsuccess    ue_id=3    enb_id=3    cell_id=2
    Sa Ue Attach and 2CC unsuccess    ue_id=4    enb_id=3    cell_id=2
    Sa Ue Attach and 2CC unsuccess    ue_id=5    enb_id=2    cell_id=1
    UE Deregister From GNB

CB008140-ET-GJ002_interGnb_CA_SA_scell_addition_partial_success
    [Documentation]
    ...    1. This user scenario porpuse is add some exploring test case about modification the value of optional parameter
    ...    2. Configuration
    ...       GNB3 is composed of CELL3.1 CELL3.2 CELL3.13 CELL3.14
    ...       GNB2 is composed of CELL2.11 CELL2.12
    ...       Cell2_11 is candidate SCell of all other cells
    ...       cell3_14 is candidate SCell of cell2_12
    ...       RdMaxIncomingCaRel: 0x5901d2=2 in cell2_11
    ...       SCell addition method is blind
    ...    3. Test Case Steps:
    ...         a.UE3 setup in cell3_14, trigger intergnb ca setup to scell cell2_11+cell2_12 successfully
    ...           UE1 intergnb ca setup successfully for cell3_1+cell2_11; UE2 intergnb ca setup successfully for cell3_2+cell2_11
    ...         b.UE3 setup in cell3_14, trigger intergnb ca setup to scell cell2_11+cell2_12, failed to cell2_11 due to
    ...           rdMaxIncomingCaRel exceed, successful to add cell2_12
    ...         c.UE4( BC support cell3_14+cell2_11) setup in cell3_14, trigger intergnb ca setup to scell cell2_11,
    ...           failed due to rdMaxIncomingCaRel exceed
    ...         d.UE5 setup in cell2_12, trigger intragnb ca setup to scell cell2_11,failed due to rdMaxIncomingCaRel exceed
    ...         e.UEs deregister should be successfully
    [Tags]    GJ002    QC_280797    CA_LABEL-FFF(15Mhz_FDD_n28+20Mhz_FDD_n3)    CA_LABEL-TF(100Mhz_TDD_n77+20Mhz_FDD_n3)
    OnlineParamChange_gNB2    ${Add_NRREL_12_on_CELL2_14}
    Update UE capa
    Sa Ue Attach and 3CC success    ue_id=3    enb_id=3    cell_id=14
    UE Deregister From GNB    ue_id=3
    Sa Ue Attach and 2CC success    ue_id=1    enb_id=3    cell_id=1
    Sa Ue Attach and 2CC success    ue_id=2    enb_id=3    cell_id=2
    Sa Ue Attach and only one Scell add    ue_id=3    enb_id=3    cell_id=14
    Sa Ue Attach and 2CC unsuccess    ue_id=4    enb_id=3    cell_id=14
    Sa Ue Attach and 2CC unsuccess    ue_id=5    enb_id=2    cell_id=12
    UE Deregister From GNB

*** Keywords ***
Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}
    Update Cfg    ue_param id=2-5 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Update UE capa
    ${cmd}    catenate    ue_param id=3 ue_nr_capabilities=${SA_Capa_Support_3CC_FFF_CA}
    Execute Egate Command    ${cmd}
    ${cmd1}    catenate    ue_param id=4 ue_nr_capabilities=${SA_Capa_Support_2CC_FF_CA}
    Execute Egate Command    ${cmd1}
    ${cmd2}    catenate    ue_param id=1 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Execute Egate Command    ${cmd2}

OnlineParamChange_gNB2
  [Arguments]    ${Online_Param}
  Delta Commission Parameters Gnb2    ${Online_Param}
  Cells Should Be OnAir

UE Attach To Target Cell
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Sa Ue Attach and 2CC success
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11
    UE Attach To Target Cell    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=${2CC_success}    timeout=5s

Sa Ue Attach and 3CC success
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11
    UE Attach To Target Cell    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=${3CC_success}    timeout=5s

Sa Ue Attach and 2CC unsuccess
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11
    UE Attach To Target Cell    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=Initial Context Setup Successful
    ...    fail_regexp=SCellIndex 1 activated successfully at airphone    timeout=5s

Sa Ue Attach and only one Scell add
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11
    UE Attach To Target Cell    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=PhysCellId: 61] SCellIndex 2 activated successfully at airphone
    ...    fail_regexp=SCellIndex 1 activated successfully at airphone    timeout=5s

UE Deregister From GNB
    [Arguments]    ${ue_id}=all
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached
