*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R3    owner-jean.jing    team-Jazz    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_11}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB

...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRDU-1:actConnectedModeMobilityCA=false
...    NRDU-1:actInterNumerologyCa=true


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
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly


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
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_for_NRCELL_11}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11:actVoNR=false
...    NRCELL-11:nrCellType=2DL2UL
...    NRCELL:sCellDeactivationTimerGNB=infinity


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

${SA_Capa_Support_nonCA}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF8
...    8E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D805AC1184341020F1018656C98AB121CFB027C471E3
...    1238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B133582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC
...    31E50B0381C3C17003FF001C00FFC000B000E0541B06F582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA160703878
...    4FFF800003FFE0000016001C00C50389810001C2C0AC3C1B000E010000030B02B0F0A00038040000042C0AC3C4C000E0D8000010B02B1706C
...    003804001C0200000A160561E26000713000003058158B898001C1B000E0D8000020B02B170A0003804001C1B000004160562E14000700800
...    38040000082C0AC5C28000E0D800706C00001058158B898001C1B000E140000040B02B0F06C00383600000C2C0803803700A2026400207495
...    064089B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204
...    081B1CF811204081B1CF810A040D8E7C000130C18C6318C6318C631E8260078005038280381803A01C0018090010180F82400800000004002
...    000000080000000400000802000008010000060080000400400002802001004010040000300200001C0100080000002000020010000120080
...    00030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000
...    065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000265949010000A96524040
...    002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A0A0BC04A8140A0502
...    8140A05028140A05028140A05028140A000E10100C018040080108080100402018030804008010100C018040300608080600C020180308040
...    08010100C018040080110080600C02018030080600C10100200804008020008020043543E00020406080C0E1416181A202224262830323638
...    3A3E424A4C4E5052545A5E828305A

@{PM_Counters_Check_AF009_PRIM}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

#@{RD_Counters_Check_AF009_PRIM}
#...    NRCELL-1:IGNB_CA_ATT_1_SCELL_SA=1
#...    NRCELL-1:IGNB_CA_ATT_1_SCELL_SA_SUCC=1

@{PM_Counters_Check_AF009_EXT}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1

#@{RD_Counters_Check_AF009_EXT}
#...    IGNB_CA_SCELL_ADMI_REQ_SA=1
#...    IGNB_CA_SCELL_ADMI_SUCC_SA=1
#...    IGNB_CA_ADD_REQ_SA_NRADJ=1


${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502

${GNB_DU_SCELL_1_ADMI_REQ_SA}     M55139C01003
#This counter describes the number of radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It is measured in PCell in SA mode in DU only
${GNB_DU_SCELL_ADMI_REQ_SA}     M55139C01001
#Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA.
${GNB_DU_SCELL_1_ADMI_SUCC_SA}     M55139C01004
#This counter describes the number of successful radio admission requests for exactly 1 SCell before the CA configuration
#on RRC. It is measured in PCell in SA mode in DU only.
${UE_PCELL_1_CONF_SCELL_DL_SA}     M55118C05507
#Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.

*** Test Cases ***
CB008140-ET-AF008_Inter-gNB_FT_CA_Blind_Scell_addition_triggered_Failure_cause_no_sufficient_UE_capability
    [Documentation]
    ...    [purpose]: The purpose of this case is to verify UE capability enquiry procedure when the cell where the UE
    ...    attached has been configured with inter-gNB CA, the bands of candidate SCells in external gNB are included in
    ...    the band list in UECapabilityEnquiry message.
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140-AF
    ...    [Test Case Steps]:
    ...         a.make a normal SA CA_FT ue
    ...         b.make a normal SA CA_FT ue, but scell add failed
    ...    [Expected Results]:
    ...         a.CA_FT UE work normally
    ...         b.CA_FT UE, but no scell add as no_sufficient_UE_capability
    [Tags]    QC_218671    AF008
    Make Normal CA SA UE
    Make CA UE call but scell add fail
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AF_008${/}a2a_gnb2.ini    wait_string=UEContextRelease::20

CB008140-ET-AF009-Inter-gNB_TF_CA_Blind_Scell_addition_Failure_cause_RRC_RECONFIGURATION_COMPLETE_timeout
    [Documentation]
    ...    [purpose]: The purpose of this case is to verify When timerRRCGuard expires and gNB does not receive
    ...    RRC: RECONFIGURATION COMPLETE message from UE, inter-gNB CA SCell addition for a SA UE context having one
    ...    candidate SCell only in an ext-gNB will fail and UE will be released.
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140-AF
    ...    [Test Case Steps]:
    ...         a.make a normal SA CA_TF ue
    ...         b. Trigger RRC delay for Scell addition
    ...    [Expected Results]:
    ...         a.CA_TF UE pdu setup successfully
    ...         b.Scell add failed due to GNB receive UE RRC complete msg timeout
    [Tags]    QC_218672    AF009
    Clear Counter Files    ${False}
    clear counter files gnb2
    Sa Ue Attach For RRC Timeout    1    1    2    1    ${SA_Capa_Support_CA}
    Check Counters    ${PM_Counters_Check_AF009_PRIM}    wait=${True}
    #Check Counters GNB2    ${PM_Counters_Check_AF009_EXT}    ${RD_Counters_Check_AF009_EXT}    wait=${True}
    Check Counters GNB2    ${PM_Counters_Check_AF009_EXT}    wait=${True}
    Check WireShark Log    ${CURDIR}${/}A2A_AF_009${/}a2a.ini    wait_string=UEContextRelease::13

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Make Normal CA SA UE
    Sa Ue Attach    1    1    3    11    ${SA_Capa_Support_CA}
    Setup pdu session with scell add blind
    Send And Verify Throuput    1    20
    UE Deregister From gNB    1

Make CA UE call but scell add fail
    Sa Ue Attach    1    1    3    11    ${SA_Capa_Support_nonCA}
    Setup pdu session with no scelladd
    Send And Verify Throuput for no scell UE    1    20
    UE Deregister From gNB    1

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${UE_Capa}=${SA_Capa_Support_CA}
    Update UE capa    ${ue_id}    ${UE_Capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Sa Ue Attach For RRC Timeout
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${UE_Capa}=${SA_Capa_Support_CA}    ${sleep_time}=30s
    Update UE capa    ${ue_id}    ${UE_Capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=scell_to_add_mod delay=5000 action=drop
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table
    sleep    ${sleep_time}

Setup pdu session with scell add blind
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    sCellIndex 1

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell    sleep_time=30s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>220
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>280
    Should Be True    ${ul_throughput}/1000>8

Send And Verify Throuput for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell for no scell UE    sleep_time=30s

Verify Throuput on Pscell for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>60
    Should Be True    ${ul_throughput}/1000>8

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Modify Cfg
    ${command_cell2} =    catenate    SEPARATOR=
    ...           set_cell id=2
    ...    \ gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    \ nr_arfcn=666666:666666 mandatory_for_activation=off gscn=8193
    Update Cfg    ${command_cell2}
    ${command_cell4} =    catenate    SEPARATOR=
    ...           set_cell id=4
    ...    \ gnb=3 pci=17:2 tac=200 nrci=0x04 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    \ nr_arfcn=660000:660000 mandatory_for_activation=off gscn=8124
    Update Cfg    ${command_cell4}
    Update Cfg    set_qosflow id=1 5qi=5 default=on

Update UE capa
    [Arguments]    ${ue_id}=1    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
