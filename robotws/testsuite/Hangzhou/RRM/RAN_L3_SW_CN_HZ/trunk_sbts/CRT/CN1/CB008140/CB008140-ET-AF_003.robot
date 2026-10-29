*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-Delun.Li
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008140-AF    release-5G23R3
...    STATE_CONFIGURED    RAN_5G
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
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB


@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS:actNgcFlexSaMode=true
...    NRPMRNL-1:miNrRelReportCu=disabled

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
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
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
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
...    NRCELL-14:maxNumOfSCellAlloc=0
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false


@{OnlineParam_AF003_gNB2}
...    NRCELL-14:maxNumOfSCellAlloc=1

@{OnlineParam_AF003_recover_gNB2}
...    NRCELL-14:maxNumOfSCellAlloc=250

@{PM_Counters_Check_PRIM}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-11:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=2
...    NRCELL-11:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_SA_REJ}=1

@{PM_Counters_Check_EXT}
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:${IGNB_CA_ADD_REQ_SA_NRADJ}=2
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_UNSUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=1

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#This counter measures the number of A4 triggered handover execution attempts related to inter-frequency Intra-gNB Intra-DU handover for SA.
${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
#This counter is counts the number of inter gNB CA attempts for SA to add one S-Cell.
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004
#This counter is Counts the number of inter gNB CA addition attempts successful for adding one S-Cell for SA.
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
#This counter is Counts the Admission request of S-Cell setup in ext-gNB.
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
#This counter is Counts the successful Admission of S-Cell setup in ext-gNB.
${IGNB_CA_SCELL_ADMI_UNSUCC_SA}    M55138C03503
#This counter is Counts the failed Admission control for S-Cell setup in the ext-gNB CU.
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
#This counter is Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA
${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55175C00002
#Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA rejected in ext-gNB
${IGNB_CA_ATT_SA_REJ}    M55118C11007
#Counts the number of inter gNB CA addition attempts rejected for SA.

${SA_Capa_Support_FR2_CA}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B00B582308682041E207032B64C55890E7D813E2
...    38F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA36266B04610D04083A40E0616C98AA221CF88E3C471E819F604F
...    8C73E618F28581C0E1E0B801FF800E007FE00078001C0A8360DEB04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50
...    B0381C3C27FFC00001FFF000000F0003801EF0F1300038040000042C040A81C4C08000E160561E0D8007008000018581587850001C020000
...    02160561E26000706C00000858158B836001C02000E010000050B02B0F1300038980000182C0AC5C4C000E0100070A000002058158B89800
...    1C1B000E0D8000020B02B170A0003804001C1B000004160562E1400070080038040000082C0AC5C4C000E01000706C00001058158B850001
...    C1B000E0D8000020B02B17130003836001C28000008160561E0D800706C000018581007006E014404C80041685C83E14489B1CF870226C73
...    E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E0
...    44810206C73E044810206C73E044810206C73E0428103639F000B878C6318C6318C6318C630F413003C00281C1401C0C0250070006024004
...    0603E0900200000001000800000020000000100000200800002004000018020000100100000A008004010040100000C00800007004002000
...    00008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811
...    583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A59490100007965240400022594901
...    0000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA
...    4D5541E28480BC04A8140A05028140A05028140A05028140A05028140A000E10100C018040080108080100402018030804008010100C0180
...    40300608080600C02018030804008010100C018040080110080600C02018030080600C10100200804008020008020043543E00020406080C
...    0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${ue_id}    1
${cell_id}    11
${pdu_id}    1

*** Test Cases ***
CB008140_AF003_Inter-gNB_FF_CA_bufferBased_Scell_addition_Failure_cause_ran_out_of_candidate_Scell_allocation_in_ext_gNB
    [Documentation]
    ...    1. This user scenario porpuse is to check the gNB behaviour for a UE on a SA call
    ...    When maxNumOfSCellAlloc in ext-gNB is set to 0, inter-gNB CA SCell addition for a SA UE context having one
    ...    candidate SCell only in an ext-gNB will fail due to no Radio resources in target ext-gNB-CU.
    ...    2. Configuration
    ...       configuration on BTS
    ...           CA was enabled
    ...       configuration on cell 11
    ...           CA releations between prime-cell is cell11 and ext-cell is cell14, and CA was enabled
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully.
    ...         b. Make traffic, CA will trigger fail with No-Radio-Resources-Available.
    ...         c. stop traffic, and then deregister UE success.
    ...         d. Modify maxNumOfScellAlloc from 0 to 1 success.
    ...         e. UE registers successfully and PDU session is setup successfully.
    ...         f. Make traffic, CA will trigger success.
    ...         h. UE deregister should be successfully.
    [Tags]    QC_217448    owner-Delun.Li    AF003
    Clear Counter Files Of AF003
    UE Attach To Target Cell Then Send And Verify Throughput    ${cell_id}
    UE Deregister From gNB First Time    ue_id=${ue_id}
    OnlineParamChange_gNB2    ${OnlineParam_AF003_gNB2}
    UE Attach To Target Cell Then Send And Verify Throughput Again    ${cell_id}
    UE Deregister From gNB    ue_id=${ue_id}
    Check Counters AF003
    Check Wireshark Log    ${CURDIR}${/}A2A_AF_003${/}a2a_prime.ini    wait_string=UEContextRelease::20
    Check Wireshark Log GNB2    ${CURDIR}${/}A2A_AF_003${/}a2a_ext.ini    wait_string=UEContextRelease::4
    [Teardown]    AF03 Recover Env And Test Teardown with recover

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F
#    Debug Enter Into Egate

Clear Counter Files Of AF003
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE Attach To Target Cell Then Send And Verify Throughput
  [Arguments]    ${cell_id}
  Update UE capa    ${SA_Capa_Support_FR2_CA}
  Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
  Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
  Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
  Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    QoS Routing Table
  Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150
  Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
  Verify Throughput

Verify Throughput
    [Arguments]    ${Tput_dl}=80    ${Tput_ul}=9.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE Attach To Target Cell Then Send And Verify Throughput Again
  [Arguments]    ${cell_id}
  Update UE capa    ${SA_Capa_Support_FR2_CA}
  Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
  Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
  Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
  Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    QoS Routing Table
  Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150
  Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
  Verify Throuput on Pscell and Scell    ${ue_id}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pcell_dl}=72    ${scell_dl}=64    ${Tput_ul}=9
    sleep    15s     #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > ${scell_dl}

OnlineParamChange_gNB2
  [Arguments]    ${Online_Param}
  Delta Commission Parameters Gnb2    ${Online_Param}
  wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

AF03 Recover Env And Test Teardown with recover
    Delta Commission Parameters Gnb2    ${OnlineParam_AF003_recover_gNB2}
    Update UE capa    ${SA_Capa_perUE_Full}
    Common Test Teardown And Stop Capture Logs

UE Deregister From gNB First Time
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    sleep    30s    reason=wait timer

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    sleep    30s    reason=wait timer
    stop capture wireshark log

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Check Counters AF003
    Check Counters    ${PM_Counters_Check_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_EXT}
