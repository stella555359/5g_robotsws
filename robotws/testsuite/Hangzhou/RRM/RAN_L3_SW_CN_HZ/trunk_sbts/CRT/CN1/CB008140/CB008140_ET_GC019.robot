*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    team-jazz    owner-jolin.fan    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

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
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:actFdmEnhancedScheduling=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL:nrCellType=2DL2UL
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_FOR_GNB1}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actSaUeBasedAnrNr=true
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:nrarfcn=663400
...    NRCELL-2:gscnOrSsPbchArfcn=8159
...    NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS/NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS/NRBTS/NRANR-1:actAutoNrNbRemoval=false
...    MRBTS/NRBTS/NRANR-1:consecHoFailThres=0
...    MRBTS/NRBTS/NRANR-1:consecHoFailThresEutra=3
...    MRBTS/NRBTS/NRANR-1:consecXnResolveFailThres=3
...    MRBTS/NRBTS/NRANRPR-1:anrThresRsrpNbCell=-90
...    MRBTS/NRBTS/NRANRPR-1:anrThresRsrqNbCell=-12
...    MRBTS/NRBTS/NRANRPR-1:anrThresholdSelector=RSRP
...    MRBTS/NRBTS/NRANRPR-1:cellDepMode=SA+NSA
...    MRBTS/NRBTS/NRANRPR-1:consecRecheckForNrNbRemoval=5
...    MRBTS/NRBTS/NRANRPR-1:idleTimeForNrNbRemoval=72
...    MRBTS/NRBTS/NRANRPR-1:maxNumAnrNrrelAllowed=50

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
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
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=2
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:nrarfcn=653400
...    NRCELL-3:gscnOrSsPbchArfcn=8055

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
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
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=663400
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRCELL-3:a2MeasSCellRelEnabled=rsrp

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{PM_Counters_Check_GC019_priGNB}
...    NRBTS-1:${ATT_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:${SUCC_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:${HO_PDU_SESS_RES_SENT_SLICE}=2
...    NRCELL-1:${SUCC_NGBR_DRB_INTRAGHO_SA_PLMN}=1
...    NRCELL-2:${SUCC_NGBR_DRB_INTRAGHO_SA_PLMN}=1
...    NRCELL-1:${SUCC_SETUP_USER_SA_PLMN}=3
...    NRCELL-2:${SUCC_SETUP_USER_SA_PLMN}=1
...    NRCELL-1:${ATT_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:${ATT_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:${SUCC_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:${SUCC_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}>1
...    NRCELL-2:${UE_PCELL_1_CONF_SCELL_DL_SA}>1
...    NRCELL-1:${UE_PCELL_2_CONF_SCELL_DL_SA}>1
...    NRCELL-1:${F1_UE_CTXT_MOD_REQ_SENT}>1
...    NRCELL-2:${F1_UE_CTXT_MOD_REQ_SENT}>1
...    NRCELL-1:${F1_UE_CTXT_MOD_RESP_RECEIVED}>1
...    NRCELL-2:${F1_UE_CTXT_MOD_RESP_RECEIVED}>1
...    NRBTS-1:${F1_UE_CTXT_MOD_REQ_RECEIVED}>1
...    NRBTS-1:${F1_UE_CTXT_MOD_RESP_SENT}>1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=3
...    NRCELL-2:NCAC:${IGNB_CA_ATT_SA_REL}=1


${IGNB_CA_ATT_SA_REL}    M55118C11008

${ATT_GNB_INTRA_DU_HO_SLICE}    M55149C00004
#Attempted Intra-Frequency Intra-gNB Intra-DU HO per PLMN, per slice.
${SUCC_GNB_INTRA_DU_HO_SLICE}    M55149C00005
#Successful Intra-Frequency Intra-gNB Intra-DU HO, per PLMN, per slice.
${HO_PDU_SESS_RES_SENT_SLICE}    M55149C02002
#The number of intra-gNB intra DU PDU sessions requested per PLMN.
${SUCC_NGBR_DRB_INTRAGHO_SA_PLMN}    M55145C00221
#The nbr of successfully established non-GBR DRBs, upon Intra-gNB HO for SA user per PLMN-ID.
${SUCC_SETUP_USER_SA_PLMN}    M55145C00223
#The number of UEs successfully established for SA user per PLMN-ID When UE is established upon successful PDU session establishment or
#incoming Intra- or Inter-gNB HO. Updated to the target cell.
${ATT_INTRA_DU_HO_SA_PLMN}    M55145C00301
#The number of intra-frequency intra-DU HO execution attempts for SA per PLMN-ID When RRC Reconfiguration message is sent by the gNB to UE
#for Intra-gNB Intra-DU HO, which indicates a Handover Command to the UE. Updated to the source cell.
${SUCC_INTRA_DU_HO_SA_PLMN}    M55145C00302
#The number of successful intra-frequency intra-DU HOs for SA per PLMN-ID.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL.
${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
#Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU. Incremented when F1AP UE Context Modification ReqUEst is sent by gNB-CU.
${F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002
#Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU.
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001
#Number of incoming UE CONTEXT MODIFICATION REQUEST received from gNB-CU.
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002
#Number of outgoing UE CONTEXT MODIFICATION RESPONSE sent to gNB-CU.

${SA_Capa_Support_3CC_n77_3A_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05FFFFFC007FFC5F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000
...    170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64
...    C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50
...    B0381C3C17AAAAAAA9EAAAAAAA17000038028B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260000C2C
...    0AC5C02000C010181B0002058158F8040018060303606134000A161758B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B
...    02B0F00800300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160561E0D800713000006858158B89800184C03004000E0B02B1F130003098060080C0D8003C
...    2C0AC5C4C000C010181B0008058158F89A0018020300C0606C0022160561E26800700810009058158F80400181B0309A0613400261617009006E003404C800501345D004040
...    C290A244D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F
...    0E14489B1CF871224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E14489B1CF871A2448913639F0C074506318C6318C6318C
...    6318C6318C7A0B800F800A070500703009401C0018090010180F824008000000040020000000800003004000008020000080100000600800004004000028020010040100400
...    00300200001C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE0CDE02D606D6025604560ED03
...    41000009652504000065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000265949010000A96524040002E59494
...    10000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A050281400
...    4C2020040080801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404
...    0300601002004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C02018
...    0284040300601002004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C0142020040080
...    81200A30100C01404030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D
#enable nr-CGI-Reporting

*** Test Cases ***
CB008140_ET_GC019_intra-DU_intra-freq_Handover_outgoing_in_IgNB-CA_mode_TTT_to_inter-gNB_CA_blind_TF_rsrp_and_back_with_ANR
    [Documentation]
    ...    this case is to test intra-gNB intra-DU handover of a UE context in IgNB-CA mode.
    ...    [Configuration]:
    ...    PCell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    PCell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz
    ...    SCell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8055 chBw=40MHz
    ...    SCell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz
    ...    SCell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    SCell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    2.Test Case Steps:
    ...     a. UE1 Register And PDU Session Setup On Cell1_1
    ...     b. UE1 Start Traffic And Verify Throughput
    ...     c. UE1 Send A1 to trigger ignb ca scell addition (Cell2_3 + Cell2_4)And Verify Throughput
    ...     d. UE2 Register and repeat stepa,b,c
    ...     e. UE1 A3 intraFreq HO to Cell1_2 And Verify Throughput, with blind scell addition (Cell2_11)
    ...     f. UE2 A2 scell release scell-1 Cell2_3 And Verify Throughput
    ...     g. UE1 A3 intraFreq HO back to Cell1_1 And Verify Throughput
    ...     h. repeat step c
    ...     i. wireshark logs and counters check

    [Tags]    QC_253776    GC019
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=1
    UE Send A1 Trigger 3CC Scell Activation And Verify Throughput    ue_id=1
    UE2 Register and to same status as UE1
    Send A3 MR to trigger intraGNB intraFreqHo with blind Scell Addition    ue_id=1    cellfreq=663360    target_pci=51
    Send A2 MR to Release scell1 for UE2    ue_id=2    cellfreq=653376
    Send A3 MR to trigger intraFreqHo back    ue_id=1    cellfreq=663360    target_pci=50
    UE Send A1 Trigger 3CC Scell Activation And Verify Throughput    ue_id=1
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_GC019_priGNB}
    Check WireShark Log    ${CURDIR}${/}A2A_GC_019${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::4
    Check userstop cause shall be correct


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_3A_CA}
    ${set_cell2_gscn}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=663400:663400
    ...    mandatory_for_activation=off gscn=8159
    Update Cfg    ${set_cell2_gscn}
    ${set_cell3_gscn}    catenate
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=653400:653400
    ...    mandatory_for_activation=off gscn=8055
    Update Cfg    ${set_cell3_gscn}

UE2 Register and to same status as UE1
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=2
    UE Send A1 Trigger 3CC Scell Activation And Verify Throughput    ue_id=2

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Sleep    5s    #wait all sysinfo

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=25 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}    Tput_dl=490    Tput_ul=20

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=45    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Run Traffic And Verify Throughput For 3CC
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=25 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput For 3CC    ue_id=${ue_id}    Tput_dl=490    Tput_ul=20

Verify Throughput For 3CC
    [Arguments]    ${ue_id}=1    ${Tput_dl}=490    ${Tput_ul}=25
    sleep    15s    sleep for Tput stable
    ${dl_throughput_total}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput_total}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Verify DL Throughput For 3CC    ${ue_id}    ${Tput_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify DL Throughput For 3CC
    [Arguments]    ${ue_id}=1    ${total_tput}=490
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_tput}

Send A2 MR to Release scell1 for UE2
    [Arguments]    ${ue_id}=2    ${cellfreq}=653376
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ${ret3}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret3}    sCellToReleaseList
    Verify Throughput    ue_id=${ue_id}    Tput_dl=490    Tput_ul=20

UE Send A1 Trigger 3CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell1pci}=52    ${scell2pci}=53
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone	
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
    Sleep    5s    #wait all sysinfo
    Run Traffic And Verify Throughput For 3CC    ue_id=${ue_id}

Send A3 MR to trigger intraGNB intraFreqHo with blind Scell Addition
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${target_pci}=51
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A3
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${target_pci} nrsrp_nr=100 nrsrq_nr=80
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Verify Throughput    ue_id=${ue_id}    Tput_dl=270    Tput_ul=20

Send A3 MR to trigger intraFreqHo back
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${target_pci}=50
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A3
    ${ret2}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${target_pci} nrsrp_nr=100 nrsrq_nr=80
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Should Contain    ${ret2}    rrcReconfigurationComplete
    Verify Throughput    ue_id=${ue_id}    Tput_dl=270    Tput_ul=20

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 3
    should be equal As Numbers    ${number}    4
    ${number}=
    ...    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserSuspendSchedulingReq_t.ueSuspendCause == 4
    should be equal As Numbers    ${number}    2

