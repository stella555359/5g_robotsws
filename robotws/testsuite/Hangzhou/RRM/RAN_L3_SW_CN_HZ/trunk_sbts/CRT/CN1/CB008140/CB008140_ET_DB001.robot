*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    owner-jun.15.zhang    release-SBTS23R4    CRT    team-L3CN1_SG14
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3:ipAddress=10.0.1.126
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3:remoteNeType=GNB
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-4:ipAddress=10.0.1.128
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-4:remoteNeType=GNB
@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/XNLINK-3:cPlaneIpAddr=10.0.1.126
...    NRBTS/XNLINK-4:cPlaneIpAddr=10.0.1.128
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-4:administrativeState=Unlocked
...    NRBTS/NRADJGNB-4:gNbIdLength=22
...    NRBTS/NRADJGNB-4:gNodeBId=36
...    NRBTS/NRADJGNB-4:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-4:xnLinkRef=3
...    NRBTS/NRADJGNB-4:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-4:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-5:administrativeState=Unlocked
...    NRBTS/NRADJGNB-5:gNbIdLength=22
...    NRBTS/NRADJGNB-5:gNodeBId=37
...    NRBTS/NRADJGNB-5:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-5:xnLinkRef=4
...    NRBTS/NRADJGNB-5:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-5:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-5:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=12
...    NRBTS/NRADJNRCELL-1:nrarfcn=153400
...    NRBTS/NRADJNRCELL-1:physCellId=61
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-2:gNbId=35
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=1
...    NRBTS/NRADJNRCELL-2:nrarfcn=157400
...    NRBTS/NRADJNRCELL-2:physCellId=62
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-3:gNbId=36
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=1
...    NRBTS/NRADJNRCELL-3:nrarfcn=368400
...    NRBTS/NRADJNRCELL-3:physCellId=63
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-4:gNbId=37
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=1
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=54
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=35
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=36
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=1
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=37
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=1
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
@{PARAMS_ADJ_REL_FOR_GNB2}
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
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

#UE_Capa with 2CC with band combination for n77+n3, n77+n28, n77+78
${SA_Capa_Support_2CC_n77_n3_n28_n78_CA}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623809DC6C06C0D608C21A0810748046D6C98AB1A1CF88
...    E3D033EC09F1891C790E7D473E618F28581C0E1E0BFFFFF800E000BE000280381506C02D608C21A081078804656C98AB121CFB027C471E312
...    38F21CFA8E7CC31E50B0381C3C27F6000001FD8000000500702A8D899AC1184341020E9008C2D931544439F11C788E3D033EC09F18E7CC31E
...    50B0381C3C17003FF001C00FFC000500702A0D837AC1184341020F1008CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF
...    800003FFE000000A00E0551B1375823086800001001185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553D55555540A
...    00E0092C3C4C000E268000000B02B17130003898001C4C000002160562E0100061300C26000082C0AC7C02000E03000701800389A00000C2C
...    0AC5C02000C010181B0002058158F804001C06000E0D800713400002858158B80400181B0309800060B02B0F00800309800070B02B0F00800
...    300400080B02B0F06C00303600090B02B0F00800300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160561E0D80071300000
...    6858158B89800184C03004000E0B02B1F130003098060080C0D8003C2C0AC5C4C000C010181B0008058158F89A001C1B000E0300070180000
...    88581009006E003404C80050134157484A14489B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891226C73E1
...    C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14489B1CF871224489B1CF871A2448
...    913639F0E2448913639F0E344891226C73E180D890C6318C6318C6318C6318C60F40B00F000A070300E0600A80E000C0480080C07C1200400
...    000002001000000040000180200000401000004008000030040000200200001401000802008020000180100000E0080040000001000010008
...    00009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296F266F016B036B012B022B07681A0800004
...    B29282000032CA4C080000CB29202000072CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA4808000
...    54B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C501178095
...    028140A05028140A05028140A05028140A050281400442020040080801002201002004040080101002004402018028080100202004008C040
...    30050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020040084040300
...    501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C02018028404030060100200
...    4402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C0146A
...    87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${IGNB_CA_ATT_1_SCELL_SA}           M55118C11001
${IGNB_CA_ATT_1_SCELL_SA_SUCC}      M55118C11004
${GNB_DU_SCELL_1_ADMI_REQ_SA}       M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}      M55139C01004
${IGNB_CA_ADD_REQ_SA_NRADJ}         M55175C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}        M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}       M55138C03502
${GNB_DU_SCELL_ADMI_REQ_SA}         M55139C01001
${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}    M55139C01002
@{PM_Counters_Check_GNB1}
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1

@{PM_Counters_Check_GNB2}
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=1




*** Test Cases ***
CB008140-ET-DB001_Verify_Blind_inter-gNB_CA_SCell_addition_with_candidate_ext-SCells_hosted_by_different_gNBs_5_gnbs
    [Documentation]
    ...    The successful blind inter-gNB CA SCell addition for SA UE context having several candidate SCells hosted by different gNBs.
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2  gnb=2 pci=17:0 tac=200 tdd_cell=on  band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3  gnb=3 pci=17:1 tac=200 tdd_cell=on  band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50
    ...    Cell id=4  gnb=3 pci=17:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz  SCellWeight=50
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=50
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz  SCellWeight=50 Cellid=0x800C/32780
    ...    Cell id=1 gnb=4 pci=20:2 tac=200 tdd_cell=off band=n28 nr_arfcn=147400:157400 gscn=1963 chBw=15MHz  SCellWeight=25 Cellid=0x8C001/573441
    ...    Cell id=1 gnb=5 pci=21:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=50 Cellid=0x90001/589825
    ...    Cell id=1 gnb=6 pci=18:0 tac=200 tdd_cell=on  band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=100MHz SCellWeight=50 Cellid=0x94001/606209
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On Cell1_1
    ...         b. UE1 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful, Blind Add Cell2_12 as Scell
    ...         Step B: UE1 Traffic And Throughput is OK
    [Tags]    QC_250689    DB001
    Clear Counter Files for 2GNB
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param
    UE Register And PDU Session Setup With Blind Scell Addition    ue_id=1    scell1pci=61
    Run Traffic And Verify Throughput
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=4 pci=20:2 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=147400:157400
    ...    gscn=1963 nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell1_sim_configuration}
    ${gNB5_sim_configuration}    catenate
    ...    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.127 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.126 nssai=0x1:0xd143a5 amf=1 xp=10.0.1.126:32742 xpu=10.0.1.126:32742 xp_management=on
    Update Cfg    ${gNB5_sim_configuration}
    ${gNB5_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=5 pci=21:0 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=349400:368400
    ...    gscn=4605 nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB5_Cell1_sim_configuration}
    ${gNB6_sim_configuration}    catenate
    ...    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.129 gnb_id=0x25:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.128 nssai=0x1:0xd143a5 amf=1 xp=10.0.1.128:32742 xpu=10.0.1.128:32742 xp_management=on
    Update Cfg    ${gNB6_sim_configuration}
    ${gNB6_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=6 pci=18:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=648000:648000
    ...    gscn=8000 nr_scs=30kHz bs_channel_bandwidth=100MHz mandatory_for_activation=off
    Update Cfg    ${gNB6_Cell1_sim_configuration}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_2CC_n77_n3_n28_n78_CA}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4,5,6 protocol=xp,xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4,5,6

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Set Sim gNB ignb CA Addition Param
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes
    ...    location_bw_ul=1:2 location_bw_dl=3:4 Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=1 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=25
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2
    ${gNB5_param}    catenate
    ...    gnb_param id=5 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes
    ...    location_bw_ul=1:2 location_bw_dl=3:4 Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB5_param}
    Execute Egate Command    gnb_cell_param gnb=5 id=1 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=5 target=2    pass_regexp=Sent to GNB-2
    ${gNB6_param}    catenate
    ...    gnb_param id=6 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes
    ...    location_bw_ul=1:2 location_bw_dl=3:4 Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB6_param}
    Execute Egate Command    gnb_cell_param gnb=6 id=1 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=6 target=2    pass_regexp=Sent to GNB-2

UE Register And PDU Session Setup With Blind Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${scell1pci}=53
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Sleep    5s    #wait all Scell info print

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    630    45
    [Teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}   qfi=${qfi}   direction=dl   rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}   qfi=${qfi}   direction=ul   rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
