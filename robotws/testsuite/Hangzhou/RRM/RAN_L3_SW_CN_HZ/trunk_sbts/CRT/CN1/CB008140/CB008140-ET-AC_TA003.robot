*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_L1B_CPRI_CMWV_FDD
...               release-SBTS23R3    owner-jiangping.cao    team-SG14    
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}

@{CB008140_config_GNB2}
...    NRDU-1:actInterGnbCa=DLOnly
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
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
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=158940
...    NRBTS/NRADJNRCELL-1:physCellId=62
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=158940
...    NRBTS/NRADJNRCELL-2:physCellId=63
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-10:lcrId=11
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-14:actBeamforming=false
...    NRCELL-14/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-10:gNbId=1
...    NRCELL-14/NRREL-10:gNbIdLength=22
...    NRCELL-14/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-10:lcrId=12
...    NRCELL-14/NRREL-10:removeNotAllowed=false
...    NRCELL-14/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL-13:msg1FrequencyStart=15
...    NRCELL-14:msg1FrequencyStart=15
...    NRCELL-13:sCellDeactivationTimerGNB=ms1280


@{CB008140_config_GNB1}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL-11:nrCellType=2DL2UL
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
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
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=13
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=14
...    NRBTS/NRADJNRCELL-2:nrarfcn=153400
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=28
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=13
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-10:lcrId=14
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL

@{CA_basic_config}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:intGnbScellTempBlockTmr=30
...    NRBTS:weightForIgnbCaSelection=1

...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false
...    NRBTS:actIncXn=true
...    NRCELL:actK1Opt=intraAndInter-gNB

@{sCellActivationMethod_blind}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{sCellActivationMethod_bufferBased}
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}    M55139C01002

${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502

${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004

@{PM_Counters_Check_UE1_GNB2}
...    NRCELL-13:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-13:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-13:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...    NRCELL-13:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

@{PM_Counters_Check_UE1}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=1
...    NRBTS-2:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1

@{PM_Counters_Check_UE2_GNB2}
...    NRCELL-13:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-13:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1

@{PM_Counters_Check_UE2}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

#@{RD_COUNTER_CHECK_UE1_GNB2}
#...    NRCELL-13:IGNB_CA_ATT_1_SCELL_SA=1
#...    NRCELL-13:IGNB_CA_ATT_1_SCELL_SA_SUCC=1

#@{RD_COUNTER_CHECK_UE1}
#...    NRCELL-11:IGNB_CA_SCELL_ADMI_REQ_SA=1
#...    NRCELL-11:IGNB_CA_SCELL_ADMI_SUCC_SA=1
#...    NRBTS-2:IGNB_CA_ADD_REQ_SA_NRADJ=1

#@{RD_COUNTER_CHECK_UE2_GNB2}
#...    NRCELL-13:IGNB_CA_SCELL_ADMI_REQ_SA=1
#...    NRCELL-13:IGNB_CA_SCELL_ADMI_SUCC_SA=1
#...    NRBTS-1:IGNB_CA_ADD_REQ_SA_NRADJ=1

#@{RD_COUNTER_CHECK_UE2}
#...    NRCELL-11:IGNB_CA_ATT_1_SCELL_SA=1
#...    NRCELL-11:IGNB_CA_ATT_1_SCELL_SA_SUCC=1

${SA_Capa_Support_CA}    SEPARATOR=
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

*** Test Cases ***
CB008140-ET-AA005_AB001_AC001_AE001_AE004_AD001_scell_addition_activation_contextrelease_withOrWithout_multiGBR_for_ignb_ca_FF
    [Documentation]
    ...    [purpose]:
    ...        [CB008140-ET-AA005][CB008140-ET-AB001]The purpose is to verify Xn igNB-CA and Xp ignb-CA setup successfully setup successfully
    ...        [CB008140-ET-AC001]this case is to test successful FDD+FDD 2CC inter-GNB blind scell addition for SA UE while only 1 scell
    ...         candidate which located in 1 external GNB.
    ...        [CB008140-ET-AE001]this is to test blind scell activation after inter-GNB FDD+FDD DL 2CC scell addition succeed.
    ...        [CB008140-ET-AE004]this case is to test the successful external SCell addition for a SA UE context having one
    ...         cell only in an external gNB as candidate SCell for CA and more than one non-GBR DRB established.
    ...        [CB008140-ET-AD001]this case is to test the AMF initiated UE context release inter GNB after 2CC scell addition succeed.
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140
    ...    [Precondition]:
    ...    GNB-1:cell1-TDD(n77)(pci:50)    cell2-TDD(n77)(pci:51)    cell11-FDD(n3)(pci:60)    cell12-FDD(n28)(PCI61)
    ...    GNB-13:cell13-FDD(n28)(pci:62)    cell14-FDD(n28)(pci:63)
    ...    [Test Case Steps]
    ...         a.Check logs after gnb startup
    ...         b.UE1 attach on gnb1-cell11
    ...         c.run dl/ul traffic for UE1
    ...         d.AMF initiated ue context release
    ...         e.UE2 attach on gnb2-cell13 with 2 non GBRs
    ...    [Expected Results]:
    ...         a.after timer(iGnbCaXnSetupReqTmr) timeout, gNB1 sends out XNAP: IGNB CA SETUP REQUEST to gNB2
    ...         gNB2 response with an XnAP: IGNB CA SETUP RESPONSE message
    ...         b.ue-1 attached to GNB-1 CELL-11 successfully, and PDU session is setup successfully,ue1 add GNB-2 CELL-13 for 2CC CA
    ...           The messages are exchanged between the respective network entities.
    ...           The PM counters indicated are correctly pegged.(Comments:before 23R3, rd counter will be checked instead of PM counter)
    ...         c.traffic run normally, scell will be activated.
    ...         d.ue1 context release successfully
    ...         e.ue2 attached to GNB-2 CELL-13, and PDU session is setup successfully,add GNB2 CELL-11 for 2CC CA,contains transport addresses
    ...         for each non-GBR DRB and iGNB CA setup for all two QoS Flows.The messages are exchanged between the respective network entities.
    [Tags]    QC_217918    jiancao
    Clear Counter Files for 2GNB
    Ue register and pdu session setup with blind scell addition on GNB1
    Run traffic to activate scell
    AMF initiated UE context release
    #Check Counters    ${PM_Counters_Check_UE1}    rd_counters_expression=${RD_COUNTER_CHECK_UE1}
    Check Counters    ${PM_Counters_Check_UE1}
    Check Counters GNB2    ${PM_Counters_Check_UE1_GNB2}
    OnlineParamChange_gNB2    ${sCellActivationMethod_blind}
    Clear Counter Files for 2GNB
    Ue register and pdu session setup for blind scell addition on GNB1 with multi nonGBR
    Run traffic for pcell and scell
    Check Counters    ${PM_Counters_Check_UE2} 
    #Check Counters GNB2    ${PM_Counters_Check_UE2_GNB2}    rd_counters_expression=${RD_COUNTER_CHECK_UE2_GNB2}
    Check Counters GNB2    ${PM_Counters_Check_UE2_GNB2}
    [Teardown]    Recover Env And Test Teardown with recover

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_gnb1_2F_gnb2_2T2F

Perform Steps After Onair
    Check WireShark Log    ${CURDIR}${/}A2A_AC_TA_001${/}a2a_xnxp_setup.ini    wait_string=ENDCX2SetupResponse
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AC_TA_001${/}a2a_xnxp_setup_gnb2.ini    wait_string=IgNBCAXpSetupResponse

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Ue register and pdu session setup with blind scell addition on GNB1
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=3    ${cell_id}=13    ${scell_id}=11    ${case_id}=003
    ...    ${cmd_regexp}=UE now in NG RM Registere    ${cmd_pdu_regexp}=sCellIndex 1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Start To Capture Wireshark Log    SA_UE${ue_id}_cell${scell_id}_attach
    Start To Capture Wireshark Log GNB2    SA_UE${ue_id}_cell${cell_id}_attach_GNB2
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}
    Check WireShark Log    ${CURDIR}${/}A2A_AC_TA_${case_id}${/}a2a_attach_UE${ue_id}.ini    name=SA_UE${ue_id}_cell${scell_id}_attach
    ...    wait_string=IgNBCAModificationRequestAcknowledge
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AC_TA_${case_id}${/}a2a_attach_UE${ue_id}_gnb2.ini
    ...    name=SA_UE${ue_id}_cell${cell_id}_attach_GNB2    wait_string=IgNBCAModificationRequestAcknowledge

Run traffic to activate scell
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    Start RRC Log    SA_UE${ue_id}_activation
    ${cmd}    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue:
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue:    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ${ue_id}
    Get RRC Log
    ${rrc_content}    Run    cat ${SAVE LOG DIRECTORY}/rrc_SA_UE${ue_id}_activation.log
    Should Match Regexp    ${rrc_content}    SCellIndex .* activated successfully at airphone.

Run traffic for pcell and scell
    [Arguments]    ${ue_id}=2    ${sleep_time}=15s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue:
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue:    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

AMF initiated UE context release
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11    ${scell_id}=13    ${case_id}=003
    Start To Capture Wireshark Log    SA_UE${ue_id}_cell${cell_id}_release
    Start To Capture Wireshark Log GNB2    SA_UE${ue_id}_cell${scell_id}_release_GNB2
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    Received UE Context Release Complete from GNB
    Check WireShark Log    ${CURDIR}${/}A2A_AC_TA_${case_id}${/}a2a_release_UE${ue_id}.ini    name=SA_UE${ue_id}_cell${cell_id}_release
    ...    wait_string=IgNBCAReleaseRequestAcknowledge
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AC_TA_${case_id}${/}a2a_release_UE${ue_id}_gnb2.ini
    ...    name=SA_UE${ue_id}_cell${scell_id}_release_GNB2    wait_string=IgNBCAReleaseRequestAcknowledge

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters Gnb2    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

Ue register and pdu session setup for blind scell addition on GNB1 with multi nonGBR
    [Arguments]    ${ue_id}=2    ${gateway}=11    ${enb_id}=2    ${cell_id}=11    ${scell_id}=13    ${case_id}=003
    ...    ${cmd_regexp}=UE now in NG RM Registere    ${cmd_pdu_regexp}=sCellIndex 1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Start To Capture Wireshark Log    SA_UE${ue_id}_cell${cell_id}_attach
    Start To Capture Wireshark Log GNB2    SA_UE${ue_id}_cell${scell_id}_attach_GNB2
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AC_TA_${case_id}${/}a2a_attach_UE${ue_id}_gnb2.ini    name=SA_UE${ue_id}_cell${scell_id}_attach_GNB2
    ...    wait_string=IgNBCAModificationRequestAcknowledge
    Check WireShark Log    ${CURDIR}${/}A2A_AC_TA_${case_id}${/}a2a_attach_UE${ue_id}.ini
    ...    name=SA_UE${ue_id}_cell${cell_id}_attach    wait_string=IgNBCAModificationRequestAcknowledge

Recover Env And Test Teardown with recover
    Delta Commission Parameters Gnb2    ${sCellActivationMethod_bufferBased}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=1
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_CA}
    Update Cfg    set_qosflow id=2 5qi=9
