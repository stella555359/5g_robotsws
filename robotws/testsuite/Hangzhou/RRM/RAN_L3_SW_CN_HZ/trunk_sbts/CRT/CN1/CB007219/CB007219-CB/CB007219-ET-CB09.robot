*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-ha.zheng    team-CN1ET    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_param_NSA}
...    @{MFBI}
...    @{gscn_Arfcn}

@{CA_param_NSA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=8CCDL_4CC UL
...    NRBTS:maxNumScellsDl=7
...    NRBTS:maxNumScellsUl=3

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=2062503
...    NRCELL-1:gscnOrSsPbchArfcn=22415

# CB09
# F1, F2, F3 are contiguous but non-contiguous with other sets, same with CB07 NRCELL-6/7/8
...    NRCELL-2:nrarfcn=2070833
...    NRCELL-2:gscnOrSsPbchArfcn=22444
...    NRCELL-3:nrarfcn=2072499
...    NRCELL-3:gscnOrSsPbchArfcn=22449
...    NRCELL-4:nrarfcn=2074165
...    NRCELL-4:gscnOrSsPbchArfcn=22455
...    NRCELL-4:type0CoresetConfigurationIndex=0

@{MFBI}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:actMfbiNrCaSupportFr2=NSA

...    NRCELL:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=258
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=261
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=257

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=257
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=257
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=258
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=258

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

# CB09
...    NRCELL-1:freqBandIndicatorNR=258
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-2:freqBandIndicatorNR=261
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:freqBandIndicatorNR=261
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-4:freqBandIndicatorNR=261
...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-5:freqBandIndicatorNR=258
...    NRCELL-5:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-6:freqBandIndicatorNR=258
...    NRCELL-6:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
# NRCELL-7/8, only support native n258
...    NRCELL-7:freqBandIndicatorNR=258
...    delete:NRCELL-7:nrConnectModeProfileDN
...    NRCELL-8:freqBandIndicatorNR=258
...    delete:NRCELL-8:nrConnectModeProfileDN


${N257M_I_5}    SEPARATOR=
...    A107C04C160801D0030800004080100904005C0003203083678F2C10050800080202008010C0004010100200404010000100600060002008
...    08020040200400008030003000100404018030100200004010001000080202004008080400020001004040200401002000
${N257M_I_and_N257F_D}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D001430000A81D003080021004004100170001501403678F2E01B3C7961FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480

${N258M_I_5_and_N261H_G_5}    SEPARATOR=
...    A107C08C160801D01308000040B82C1003A0838C0042004080200904020808B8000A40A106CF1E5C20D9E3CB200A10001004040100208000
...    80202004008C0004010100400804008000100600060002008080300602004000080200020001004040080101008000400020080804008020
...    040000
${N258M_I_and_N261H_G}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D041C60000A81D01308002100400C10082022E0002A02806CF1E5C03678F2C3F68200017A01F00120018004
...    D0202D0480A00C06012803000301F00649401000000001C92807004010040100401004010C016E95BA500410040000000004100C01004010
...    040000401576A2BB502D00F801A050001420029801100100004480000200000024000010000000000800400801000802004150A510586373
...    A0D98024

# CB09
${N257A_A_N257G_and_N257A_A_N257H}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401083D00000C800C0001507A000019001C00840100304020808B8000A80A106CF1E5C20D9E3CBFDA080005E807C0
...    04800600134080B4120280301804A00C000C07C03925000000724A01C010040100401004010043000002000000000080000000005BA56E94
...    01040000000004100C01004010040000401576A2BB502D00F801A05000142002980110010000448000020000002400001000000000084040
...    0801010060002020040080804000150A510586373A0D980240
${N257A_A_N257G_5_and_N257A_A_N257H_5}    SEPARATOR=
...    A107C08C260801D00000C800C00008170982007400003200380108010200802410082022E0002D028806CF1E5C403678F2C0802880004010
...    1002004040180010000802020040080804000300010040401002010020000401800180008020200C01808010000200800080004010100200
...    40402000100008020201002008010000
@{N257_4DL_1UL_CA_CB09}
...    reported successful RA
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:51, scellIdx:9] configure_1_1
...    pcid:52, scellIdx:10] configure_1_1
...    pcid:53, scellIdx:11] configure_1_1
...    frequencyBandList.*\{.*257.*\}\.:::4

@{PM_Counters_Check_CB09}
...    NRCELL-1:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-2:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-3:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-4:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-5:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-6:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-7:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-8:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_3_SCELL_DL_ATT}=1

...    NRCELL-1:RACDU:${SGNB_DU_SCELL_3_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_3_ADMISSION_SUCC}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_3_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_3_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_3_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_DL}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_DL}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_DL}>0


${SCELL_CONF_ALT_BAND_NSA}    M55118C01006    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #The number of admitted NSA users when radio admission is done on the alternative band.
#Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #The number of radio admission requests with MFBI for NSA user. Updated to the PS-Cell in the DU
#whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #The number of radio admitted NSA users with alternative band. Updated to the PS-Cell in the DU
#whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #This counter indicates the total number of CA UEs in the current cell configured as an S-Cell,
#which have 1 configured S-Cell in DL in NSA 3x mode.
${RRC_RECONF_7_SCELL_DL_ATT}    M55118C02012
${RRC_RECONF_3_SCELL_UL_ATT}    M55118C02005
${RRC_RECONF_4_SCELL_DL_ATT}    M55118C02006

${SGNB_DU_SCELL_7_ADMISSION_REQ}    M55115C00014
${SGNB_DU_SCELL_7_ADMISSION_SUCC}    M55115C00021
${SGNB_SCELL_7_ADMISSION_REQ}    M55114C00027
${SGNB_SCELL_7_ADMISSION_SUCC}    M55114C00034

${SGNB_DU_SCELL_4_ADMISSION_REQ}    M55115C00011
${SGNB_DU_SCELL_4_ADMISSION_SUCC}    M55115C00018
${SGNB_SCELL_4_ADMISSION_REQ}    M55114C00024
${SGNB_SCELL_4_ADMISSION_SUCC}    M55114C00031

${UE_PSCELL_3_CONF_SCELL_UL}    M55118C04005
${UE_PSCELL_7_CONF_SCELL_DL}    M55118C04012
${UE_SCELL_7_CONF_SCELL_DL}    M55118C05012
${UE_SCELL_3_CONF_SCELL_UL}    M55118C05005

${UE_PSCELL_4_CONF_SCELL_DL}    M55118C04006
${UE_SCELL_4_CONF_SCELL_DL}    M55118C05006

${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504

${RRC_RECONF_3_SCELL_DL_ATT}    M55118C02004
${SGNB_DU_SCELL_3_ADMISSION_REQ}    M55115C00010
${SGNB_DU_SCELL_3_ADMISSION_SUCC}    M55115C00017
${SGNB_SCELL_3_ADMISSION_REQ}    M55114C00023
${SGNB_SCELL_3_ADMISSION_SUCC}    M55114C00030
${UE_PSCELL_3_CONF_SCELL_DL}    M55118C04004
${UE_SCELL_3_CONF_SCELL_DL}    M55118C05004


*** Test Cases ***
CB007219-ET-CB09_verify_PSCell_in_alternative_band_and_best_band_combination_selected_ue_supported
    [Documentation]
    ...    Preconditions
    ...    FR2 CA feature is activated (NRBTS/actCarrierAggregation is set to “true”).
    ...    NRBTS/caConfigurationSupport is set to 3 (8CCDL_4CCUL).
    ...    Configure gNB with NRBTS.gNbCuType set to ‘NSA’, with 1 CELLGROUP contains 8 FR2 NSA Cells (NRBTS/NRCELL.cellDepType set to ‘NSA’).
    ...    NRBTS/maxNumScellsDl is set to 7 and NRBTS/maxNumScellsUl is set to 3
    ...    On the SgNB, a Cellgroup with 8 FR2 TDD Cells, Cell 0 to Cell 7 are configured with the below configuration
    ...                           Cell1	Cell2 to Cell4	Cell5 to Cell6
    ...    frequency               F0    F1 to F3       F4 to F5
    ...    Bandwidth (MHz)         100   100            100
    ...    Native band             258   261            258
    ...    Alternative band	       257   257            257
    ...    DL MIMO layers          2L    2L             2L
    ...    UL MIMO layers          2L    2L             2L

    ...    Step 1: NSA UE1 attach to PScell and start traffic
    ...    ue_attach id=1
    ...    ue_dc_enb_start ue=1 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    Expected result:
    ...    UE attach to cell1 with 3 SCells in DL with selected band combination CA_n257A_n257H and CA_257A for DL and UL respectively.
    ...    Check below messages:
    ...    gNB-CU sends to gNB-DU the F1AP: UE Context Setup Request message containing:
    ...    -	Cell1 identity in SpCell ID IE,
    ...    -	Cell2, Cell3 and Cell4 identities in SCell-ToBeSetup-List IE,
    ...    -	BC#1 in CUtoDURRCInformation CG-ConfigInfo allowedBC-ListMRDC BandCombinationInfo IE.
    ...    gNB-DU replies to gNB-CU with the F1AP: UE Context Setup Response message containing:
    ...    -	The configuration for Cell1 as PSCell and Cell2, Cell3 and Cell4 as SCells with frequency band (n257) for each SCell in
    ...    DUtoCURRCInformationcellGroupConfig IE,
    ...    -	The selected band combination BC#1 in DUtoCURRCInformationselectedBandCombinationIndex IE
    ...    gNB-CU sends to MeNB the X2AP: SgNB Addition Request Acknowledge filled with:
    ...    -	CG-Configscg-CellGroupConfig containing Cell1, Cell2, Cell3 and Cell4 configuration.
    ...    -	CG-ConfigselectedBandCombination containing BC#2.
    ...    Step 2:  check counters
    ...    Expected result:
    ...    M55118C01006 SCELL_CONF_ALT_BAND_NSA
    ...    M55114C00501 SGNB_NSA_ADMISSION_MFBI_REQ
    ...    M55114C00502 SGNB_NSA_ADMISSION_MFBI_SUCC
    ...    M55115C01501 SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...    M55115C01502 SGNB_DU_NSA_ADMISS_MFBI_SUCC

    [Tags]    CB09    QC_363557
    Clear Counter Files
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N257A_A_N257G_and_N257A_A_N257H}
    ...    ue_eutra_nr_cap=${N257A_A_N257G_5_and_N257A_A_N257H_5}
    ...    pass_CA=${N257_4DL_1UL_CA_CB09}
    Check Counters    ${PM_Counters_Check_CB09}


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_nsa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=11    ${cell_id}=1    ${pdu_id}=1    ${ue_nr_cap}=none    ${ue_eutra_nr_cap}=none
    ...    ${pass_CA}=reported successful RA    ${fail_CA}=none    ${bc_list_mrdc}=1:1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    #Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2
    ...    target_cells=${cell_id} bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}    timeout=20s

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_tput_except_dl}=510    ${pcell_tput_except_ul}=130    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${pcell_tput_except_ul}
