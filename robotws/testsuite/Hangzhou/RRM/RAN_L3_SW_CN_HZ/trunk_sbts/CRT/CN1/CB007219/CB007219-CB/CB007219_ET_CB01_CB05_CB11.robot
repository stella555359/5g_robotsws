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

@{CA_param_NSA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=8CCDL_4CC UL
...    NRBTS:maxNumScellsDl=7
...    NRBTS:maxNumScellsUl=3
...    NRCELL:actCDrx=true

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

${N257M_I_5}    SEPARATOR=
...    A107C04C160801D0030800004080100904005C0003203083678F2C10050800080202008010C0004010100200404010000100600060002008
...    08020040200400008030003000100404018030100200004010001000080202004008080400020001004040200401002000

${N258M_I_5}    SEPARATOR=
...    A107C04C160801D0130800004080100904045C0003203083678F2C10050800080202008010C0004010100200404010000100600060002008
...    08020040200400008030003000100404018030100200004010001000080202004008080400020001004040200401002000

${N257M_I_and_N257F_D}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D001430000A81D003080021004004100170001501403678F2E01B3C7961FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480

${N258M_I_and_N258F_D}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D011430000A81D013080021004004101170001501403678F2E01B3C7961FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480

${N258A_A_4L_4L_5_and_N257A_A_2L_2L_5}    SEPARATOR=
...    A117E0460B0400E808000000205C160801D0000000210020401004820104045C0005A05100D9E3CB8806CF1E581005080008020200400840
...    0040101004008600020080802004020040000803000300010040401803010020000401000100008020200400808040002000100404020040
...    10020000

${N258A_A_4L_4L_and_N257A_A_2L_2L}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D010000000A81D00000002100400C10082022E0002A02841B3C797083678F2FF68200017A01F001A0018004
...    D0202D04E0A00C06012803000301F00E494000001C928000043000002000000000080000000005BAD6E94010400000000041000010000100
...    55DC8AED40B403E00681400050800A60044004000112000008000000900000400000000020010020040020080105429441618DCE83660090

@{OnlineParam_FAF_off}
...    NRBTS:actMfbiNrCaSupportFr2=none

@{OnlineParam_FAF_on}
...    NRBTS:actMfbiNrCaSupportFr2=NSA

@{OnlineParam_CB05_1}
...    NRCELL-8:freqBandIndicatorNR=258
...    NRCELL-8:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    @{OnlineParam_FAF_on}

@{OnlineParam_CB05_2}
...    NRCELL-8:freqBandIndicatorNR=257
...    NRCELL-8:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

@{N257_8DL_4UL_CA_drx}
...    reported successful RA
...    pcid:51, scellIdx:9] configure_0_1
...    pcid:51, scellIdx:9] configure_1_1
...    pcid:52, scellIdx:10] configure_0_1
...    pcid:52, scellIdx:10] configure_1_1
...    pcid:53, scellIdx:11] configure_0_1
...    pcid:53, scellIdx:11] configure_1_1
...    pcid:54, scellIdx:12
...    pcid:55, scellIdx:13
...    pcid:56, scellIdx:14
...    pcid:57, scellIdx:15
...    frequencyBandList.*\{.*257.*\}\.:::8
...    @{drx}

@{drx}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10

@{N258_8DL_4UL_CA}
...    pcid:51, scellIdx:9] configure_0_1
...    pcid:51, scellIdx:9] configure_1_1
...    pcid:52, scellIdx:10] configure_0_1
...    pcid:52, scellIdx:10] configure_1_1
...    pcid:53, scellIdx:11] configure_0_1
...    pcid:53, scellIdx:11] configure_1_1
...    pcid:54, scellIdx:12
...    pcid:55, scellIdx:13
...    pcid:56, scellIdx:14
...    pcid:57, scellIdx:15
...    frequencyBandList.*\{.*258.*\}\.:::8

@{N258_8DL_4UL_CA_drx}
...    @{N258_8DL_4UL_CA}
...    @{drx}

@{N257_drx}
...    reported successful RA
...    frequencyBandList.*\{.*257.*\}\.:::1
...    @{drx}

@{N258_drx}
...    reported successful RA
...    frequencyBandList.*\{.*258.*\}\.:::1
...    @{drx}

@{PM_Counters_Check_CB01}
...    NRCELL-1:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-2:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-3:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-4:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-5:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-6:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-7:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-8:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_REQ}=3
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_SUCC}=3
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=3
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=3
...    NRCELL-1:NCAC:${RRC_RECONF_7_SCELL_DL_ATT}=4
...    NRCELL-1:NCAC:${RRC_RECONF_3_SCELL_UL_ATT}=4
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_7_ADMISSION_REQ}=4
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_7_ADMISSION_SUCC}=4
...    NRCELL-1:RACCU:${SGNB_SCELL_7_ADMISSION_REQ}=4
...    NRCELL-1:RACCU:${SGNB_SCELL_7_ADMISSION_SUCC}=4
...    NRCELL-1:NCAC:${UE_PSCELL_3_CONF_SCELL_UL}>0
...    NRCELL-1:NCAC:${UE_PSCELL_7_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL}>0
...    NRCELL-2:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-3:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-4:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-5:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-6:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-7:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-8:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0

@{PM_Counters_Check_CB05}
...    NRCELL-1:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-2:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-3:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-4:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-5:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-6:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-7:NCAC:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-8:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_7_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_3_SCELL_UL_ATT}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_7_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_7_ADMISSION_SUCC}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_7_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_7_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_3_CONF_SCELL_UL}>0
...    NRCELL-1:NCAC:${UE_PSCELL_7_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL}>0
...    NRCELL-2:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-3:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-4:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-5:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-6:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-7:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0
...    NRCELL-8:NCAC:${UE_SCELL_7_CONF_SCELL_DL}>0

@{PM_Counters_Check_CB12}
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1

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
${RRC_RECONF_7_SCELL_DL_ATT}    M55118C02012
${RRC_RECONF_3_SCELL_UL_ATT}    M55118C02005
${SGNB_DU_SCELL_7_ADMISSION_REQ}    M55115C00014
${SGNB_DU_SCELL_7_ADMISSION_SUCC}    M55115C00021
${SGNB_SCELL_7_ADMISSION_REQ}    M55114C00027
${SGNB_SCELL_7_ADMISSION_SUCC}    M55114C00034
${UE_PSCELL_3_CONF_SCELL_UL}    M55118C04005
${UE_PSCELL_7_CONF_SCELL_DL}    M55118C04012
${UE_SCELL_7_CONF_SCELL_DL}    M55118C05012
${UE_SCELL_3_CONF_SCELL_UL}    M55118C05005

*** Test Cases ***
CB007219-ET-CB01_verify_PSCell_and_SCells_both_can_in_alternative_or_native_band_when_FR2_FAF_enabled
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when CB007219 FR2 feature activation flag is enabled or disabled.
    ...    When CB007219 FR2 FAF is enabled, gNB will be able to support carrier aggregation with PSCell and/or SCells
    ...    in alternative and native band.
    ...    Cell 1 to Cell 8 are configured with contiguous frequencies in ascending order (F0 <F1 <...<F7) with frequency range between
    ...    26500-27500 MHz. On the SgNB, a Cellgroup with 8 FR2 TDD Cells, Cell 0 to Cell 7 are configured with the below configuration
    ...                        Cell1 to Cell4 Cell5 to Cell 8
    ...    frequency           F0 F1 to F7
    ...    Bandwidth (MHz)     100 100
    ...    Native band         257 257
    ...    Alternative band    258 258
    ...    DL MIMO layers      4L 4L
    ...    UL MIMO layers      2L 2L
    ...    UE1 supports the following band configuration
    ...    o    CA_n258M in DL
    ...    o    CA_n258I in UL
    ...    UE2 supports the following band configuration
    ...    o    CA_n257M in DL
    ...    o    CA_n257I in UL
    ...    2.Test Case Steps:
    ...        a. NSA UE1 and UE2 attach to PScell and start traffic
    ...        b. online modify Feature flag actMfbiNrCaSupportFr2 = 2 (NSA)
    ...        c. Detach UE1 and UE2 and attach UEs again to PScell
    ...        d. online modify Feature flag actMfbiNrCaSupportFr2 = 0 (none)
    ...        e. Detach UE1 and UE2 and attach UEs again to PScell
    ...        f. Check counters
    ...    3. Expected Results:
    ...        Step a: UE1 attach to cell1 as PScell with band n258, no SCells added.
    ...                UE2 attach to cell2 with 7 SCells in DL and 3 SCells in UL with selected band combination
    ...                CA_257M and CA_257I for DL and UL respectively.
    ...        Step b: online modify successfully.
    ...        Step c: UE1 detach successful and attach to cell1 with 7 SCells in DL and 3 SCells in UL with selected
    ...                band combination CA_258M and CA_258I for DL and UL respectively.
    ...                UE2 detach successful and attach to cell2 with 7 SCells in DL and 3 SCells in UL with selected
    ...                band combination CA_257M and CA_257I for DL and UL respectively.
    ...        Step d: online modify successfully.
    ...        Step e: UE1 detach successful and attach to cell1 as PScell with band n258, no SCells added.
    ...                UE2 detach successful and attach to cell2 with 7 SCells in DL and 3 SCells in UL with selected
    ...                band combination CA_257M and CA_257I for DL and UL respectively.
    [Tags]    CB01    LABEL-8T(8*100MHz_TDD_n257)    QC_363467
    Clear Counter Files
    online change then attach UE1 UE2    OnlineParam=${OnlineParam_FAF_off}    pass_CA_1=${N257_8DL_4UL_CA_drx}    fail_CA=${N258_8DL_4UL_CA}
    ...    dl_cell_num=1    ul_cell_num=1
    online change then attach UE1 UE2    OnlineParam=${OnlineParam_FAF_on}    pass_CA_1=${N257_8DL_4UL_CA_drx}    pass_CA_2=${N258_8DL_4UL_CA_drx}
    online change then attach UE1 UE2    OnlineParam=${OnlineParam_FAF_off}    pass_CA_1=${N257_8DL_4UL_CA_drx}    fail_CA=${N258_8DL_4UL_CA}
    ...    dl_cell_num=1    ul_cell_num=1
    Check Counters    ${PM_Counters_Check_CB01}

CB007219-ET-CB05_verify_PSCell_in_alternative_band_and_one_Scell_in_native_band_when_FR2_FAF_enabled
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when CB007219 FR2 feature activation flag is enabled, gNB
    ...       will be able to support carrier aggregation with PSCell in alternative band and Scell in native band.
    ...    Cell 1 to Cell 8 are configured with contiguous frequencies in ascending order (F0 <F1 <...<F7) with frequency range between
    ...    26500-27500 MHz. On the SgNB, Cell 1 is configured with the below configuration
    ...    o    Native band: n257, alternative band: n258
    ...    o    BW: 100 MHz
    ...    UE supports the following band configuration
    ...    BC#1: n258A    N258
    ...    FSEI#1 DL:    DL MIMO layers 4L
    ...    DL ChBw (MHz)    100
    ...    FSEI#1 UL:    UL MIMO Layers 4L
    ...    UL ChBw (MHz)    100
    ...    BC#2: n257A    N257
    ...    FSEI#2 DL:    DL MIMO layers 2L
    ...    DL ChBw (MHz)    100
    ...    FSEI#2 UL:    DL MIMO l
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...        b. Check counters
    ...    3. Expected Results:
    ...        Step a: UE attach to cell1 with 7 SCells in DL and 3 SCells in UL with selected band combination CA_258M
    ...                and CA_258I for DL and UL respectively.
    [Tags]    CB05    LABEL-8T(8*100MHz_TDD_n257)    QC_363465
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_CB05_1}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N258M_I_and_N258F_D}    ue_eutra_nr_cap=${N258M_I_5}
    ...    pass_CA=${N258_8DL_4UL_CA_drx}
    Send Throughput    ue_id=11
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=11    dl_cell_num=8    ul_cell_num=4
    Check Counters    ${PM_Counters_Check_CB05}
    [Teardown]    CB05_Teardown

CB007219-ET-CB11_successfuf_EN-DC_setup_in_native_band_where_it_supports_both_the_native_and_alternative_bands_of_the_PSCell
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup for a UE in FR2 where it supports both the native
    ...       and alternative bands of the PSCell, if CB007219 for FR2 is enabled, then gNB will configure native band for PSCell always.
    ...    Cell 1 to Cell 8 are configured with contiguous frequencies in ascending order (F0 <F1 <...<F7) with frequency range between
    ...    26500-27500 MHz. On the SgNB, a Cellgroup with 8 FR2 TDD Cells, Cell 0 to Cell 7 are configured with the below configuration
    ...                        Cell1 to Cell4 Cell5 to Cell 8
    ...    frequency           F0 F1 to F7
    ...    Bandwidth (MHz)     100 100
    ...    Native band         257 257
    ...    Alternative band    258 258
    ...    DL MIMO layers      4L 4L
    ...    UL MIMO layers      2L 2L
    ...    UE supports the following band configuration
    ...    BC#1: n261A    N261
    ...    FSEI#1 DL:    DL MIMO layers 4L
    ...    DL ChBw (MHz)    100
    ...    FSEI#1 UL:    UL MIMO Layers 4L
    ...    UL ChBw (MHz)    100
    ...    BC#2: n257A    N257
    ...    FSEI#2 DL:    DL MIMO layers 2L
    ...    DL ChBw (MHz)    100
    ...    FSEI#2 UL:    DL MIMO layers 2L
    ...    DL ChBw (MHz)    100
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...        b. Check counters
    ...    3. Expected Results:
    ...        Step a: UE1 attach to cell1 as PScell with band n257.
    [Tags]    CB11    LABEL-8T(8*100MHz_TDD_n257)    QC_363466
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_FAF_on}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N258A_A_4L_4L_and_N257A_A_2L_2L}
    ...    ue_eutra_nr_cap=${N258A_A_4L_4L_5_and_N257A_A_2L_2L_5}
    ...    pass_CA=${N257_drx}
    Send Throughput    ue_id=11
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=11    dl_cell_num=1    ul_cell_num=1
    Release Ues    ue_type=all
    OnlineParamChange    ${OnlineParam_FAF_off}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N258A_A_4L_4L_and_N257A_A_2L_2L}
    ...    ue_eutra_nr_cap=${N258A_A_4L_4L_5_and_N257A_A_2L_2L_5}
    ...    pass_CA=${N258_drx}
    Send Throughput    ue_id=11
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=11    dl_cell_num=1    ul_cell_num=1
    Check Counters    ${PM_Counters_Check_CB12}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_nsa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

CB05_Teardown
    OnlineParamChange    ${OnlineParam_CB05_2}
    Common Test Teardown And Stop Capture Logs

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=11    ${cell_id}=1    ${pdu_id}=1    ${ue_nr_cap}=${N257M_I_and_N257F_D}    ${ue_eutra_nr_cap}=${N257M_I_5}
    ...    ${pass_CA}=reported successful RA    ${fail_CA}=none    ${bc_list_mrdc}=1:1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2
    ...    target_cells=${cell_id} bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}    timeout=20s

Send Throughput
    [Arguments]    ${ue_id}=11    ${times}=4    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic
    [Arguments]     ${ue_id}=11    ${dl_cell_num}=8    ${ul_cell_num}=4    ${dl}=540    ${ul}=100
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-15 type=pdsch    Throughput
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    ${total_ul_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${dl_cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    FOR    ${index}    IN RANGE    8    ${ul_cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pusch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_ul_tput}    Evaluate    ${scell_tput}+${total_ul_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${total_ul_tput}/1000 > ${ul}

online change then attach UE1 UE2
    [Arguments]    ${OnlineParam}=none    ${pass_CA_1}=none    ${pass_CA_2}=none    ${fail_CA}=none    ${dl_cell_num}=8    ${ul_cell_num}=4
    ...    ${dl}=540    ${ul}=100
    OnlineParamChange    Online_Param=${OnlineParam}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N257M_I_and_N257F_D}    ue_eutra_nr_cap=${N257M_I_5}
    ...    pass_CA=${pass_CA_1}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=12    ue_nr_cap=${N258M_I_and_N258F_D}    ue_eutra_nr_cap=${N258M_I_5}
    ...    pass_CA=${pass_CA_2}    fail_CA=${fail_CA}
    Release Ues    ue_type=all
