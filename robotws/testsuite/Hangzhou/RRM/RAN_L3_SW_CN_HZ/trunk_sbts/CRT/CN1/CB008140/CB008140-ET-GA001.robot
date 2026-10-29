*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    	CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-jazz    owner-jean.jing    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
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
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:actCDrx=false
...    NRCELL:configuredEpsTac=200
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{PARAMS_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=519000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:ssbFrequency=518670
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=531960
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:ssbFrequency=531870
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:weightForSCellSelection=10
...    NRCELL-3:weightForSCellSelection=30
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=2
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=506010
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-1:ssbFrequency=505950

@{PARAMS_FOR_OTHERS}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60


...    NRBTS:actRanSharing=false
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

${SA_Capa_Support_3CC_TTT_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA170000381DC6C28AAD608C21A00107483401B5B262AC68B5E25AF42D7B16BC628B5E45AF52D7996BCA160F038782F555
...    55553D55555542E00007004961E26000713000000058158B850001C28000E140000010B02B17008003098061300004160563E01000606C0C2
...    60184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C00038581
...    5878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B80400180603036000C0B02B0F06C00
...    38980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C01018060303
...    600110B0201600DC0068099000A026C02817400E909428913639F0E244891365AF1E2448913639F0E344891226C73E1C4891226C73E1C6891
...    2244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E244891363
...    9F0E344891226C73E1C4891226C73E1C68912244D8E7C301B1218C6318C6318C6318C6318C1E82E003C00281C1401C0C02500700060240040
...    603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000700400200000
...    008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7933780B581B58095811583
...    B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000
...    996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D554
...    1E285805E02540A05028140A05028140A05028140A05028140A050011080801002020040088040080101002004040080110080600A0200400
...    8080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018040080110080600A0201802808
...    0100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A02018030080600A101
...    00C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C
...    01804030051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

@{PM_Counters_Check_GA001_PRIM}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0

@{PM_Counters_Check_GA001_EXT}
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1

${GNB_DU_SCELL_2_ADMI_REQ_SA}     M55139C01501
#This counter describes the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It is measured in PCell in SA mode in DU only
${IGNB_CA_ATT_2_SCELL_SA}     M55118C11002
#Counts the number of inter gNB CA attempts for SA to add two S-Cell
${IGNB_CA_SCELL_ADMI_REQ_SA}     M55138C03501
#The number of radio admission requests for Inter gNB S-Cell setup
${IGNB_CA_SCELL_ADMI_SUCC_SA}     M55138C03502
#The number of successful radio admissions for Inter gNB S-Cell additions in SA mode
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
#Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter describes the total number of radio admission requests for SCell
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
#This counter describes the total number of radio admission requests for SCell
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
#The number of successful radio admissions for 2 SCells additions in SA mode in DU
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#The number of successful radio admissions for the SCell in SA mode in DU
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL

*** Test Cases ***
CB008140-ET-GA001_TTT_3CC_2200enable_withoutACSI_Bundling_blindscelladd
    [Documentation]
    ...    [purpose]:
    ...        This user scenario verifies the case that the highest CSI-RS resource set provided by ext-SCell are selected.
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 GA
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n41)(pci:50)
    ...    GNB-2 ext: cell2-TDD(n41)(pci:51) cell3-TDD(n41)(pci:52)
    ...    scell gnb2-cell12 and gnb2-cell13
    ...    5G UE capability:
    ...    - simultaneousCSI-ReportsPerCC=8 for each band;
    ...    - simultaneousCSI-ReportsAllCC=12;
    ...    - Maximum number of CSI-RS supported among all CCs are 12:
    ...    RF-Parameters::BandCombination-v1540::CA-ParametersNR-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb
    ...    {
    ...          maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 12;
    ...          totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllC = 96;
    ...    }
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell1
    ...         b.PDU1 setup, scell added
    ...         c.run dl/ul traffic for UE,
    ...         d.stop traffic
    ...         e.UE context release
    ...         f.Check counters and logs
    ...    [Expected Results]:
    ...         b. 4 csirs and P8 for both Pcell and Scell
    ...         c.Traffic ok
    [Tags]    GA001    QC_252626
    Clear Counter Files for 2GNB
    Ue Register And PDU Session Setup With Blind Scell Addition
    Verify Throuput on Pscell and Scell
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_GA_001${/}a2a.ini    wait_string=UEContextRelease::10
    Check Counters    ${PM_Counters_Check_GA001_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_GA001_EXT}
    Check userstop cause shall be correct

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/3cells_gnb1_1T_gnb2_2T

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_TTT_CA}

Traffic For PDU1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=11    UE ${ue_id}: UDP UL

Scell traffic check
    [Arguments]    ${scell1_tput1}    ${scell1_tput2}    ${scell1_tput1_except}=30    ${scell1_tput2_except}=30
    Should Be True    ${scell1_tput1}/1000>${scell1_tput1_except}
    Should Be True    ${scell1_tput2}/1000>${scell1_tput2_except}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${scell1_tput1_except}=230    ${scell1_tput2_except}=230
    ...    ${dl_throughput_except}=340
    Traffic For PDU1
    sleep    ${sleep_time}
    ${scell1_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${scell1_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Scell traffic check    ${scell1_tput1}    ${scell1_tput2}    ${scell1_tput1_except}    ${scell1_tput2_except}
    ${scell1_tput0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput0}/1000>${dl_throughput_except}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>9

Ue Register And PDU Session Setup With Blind Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${scell1pci}=51    ${scell2pci}=52
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=cellIdx:2
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Rrc Should Contain    sCellToAddModList    physCellId ${scell1pci}    physCellId ${scell2pci}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    pass_regexp=Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 3
    should be equal As Numbers    ${number}    1
