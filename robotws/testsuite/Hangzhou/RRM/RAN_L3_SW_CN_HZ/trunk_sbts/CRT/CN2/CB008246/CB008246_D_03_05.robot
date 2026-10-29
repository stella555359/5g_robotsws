*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB008246    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8246_related_modification}
...    @{8246_D_related_modification}

@{8246_related_modification}
...    NRCELL-1:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMaxHR=15
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMinHR=-30
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=2
...    NRCELL-1:puschHrLaConfig:ullaSinrOffsetHR=2
...    NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS-1/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10
...    NRBTS-1/NRPDSCHHRLA-2:dllaBlerTargetHR=10
...    NRBTS-1/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS-1/NRPUSCHHRLA-2:ullaBlerTargetHR=10
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-1:actCceSplit=false

@{8246_D_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRDU-1:carrierAggregationSupportList=none

@{online_modify_dllaIniDeltaCqiHR}
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=150

@{online_modify_dllaDeltaCqiMaxHR}
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=0

@{online_modify_dllaDeltaCqiStepdownHR}
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=100

@{online_modify_dllaBlerTargetHR}
...    NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=1

@{online_modify_dlHRBlerOutageMcsThresh64qamLowSE}
...    NRBTS-1/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=0

@{online_modify_dlHRBlerOutagePercentage}
...    NRBTS-1/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=90

@{online_modify_dlHRBlerOutagePeriod}
...    NRBTS-1/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=50

${UE_Capa_Support_HRLA}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B24C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0
...    0038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B
...    02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B0
...    2B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E060128
...    03800301200203014000000000120040081F0480100000000800001004000000020000040100000400800003004000020020000140100080
...    2008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B06
...    6B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034
...    B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55
...    058AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100
...    2008040300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C0182020040100801
...    0043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008246_D_03_FR1_SA_TDD_DL_Switch_Between_BR_And_HR_Online_Change_NIDD_Param_For_pdschHrLaConfig_With_Static
    [Documentation]
    ...    1. Feature activation flag is enable for NRCELL1
    ...    2. NIDD NRPDSCHHRLA instance is configured
    ...    3. NIDD NRBTS/BWP_PROFILE/PDCCH/alSelection is set as 'static'
    [Tags]    QC_282322    owner-chunlan.yang
    stop capture wireshark log
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    Update UE capa    ue_id=82    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    UE Attach To Target Cell    ue_id=81    cell_id=1    pdu=1    gw=1
    UE in Idle    ue_id=82    cell_id=1    pdu=2    gw=2
    Online modify dllaIniDeltaCqiHR
    Online modify dllaDeltaCqiMaxHR
    Online modify dllaDeltaCqiStepdownHR

CB008246_D_05_FR1_SA_TDD_DL_Switch_Between_BR_And_HR_PDCCH_Online_Change_NIDD_Param_NRPDSCHHRLA_With_Static
    [Documentation]
    ...    1. Feature activation flag is enable for NRCELL1
    ...    2. NIDD NRPDSCHHRLA instance is configured
    ...    3. NIDD NRBTS/BWP_PROFILE/PDCCH/alSelection is set as 'static'
    [Tags]    QC_282321    owner-chunlan.yang
    stop capture wireshark log
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    Update UE capa    ue_id=82    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    Update UE capa    ue_id=83    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    Update UE capa    ue_id=84    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    Update UE capa    ue_id=85    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    UE Attach To Target Cell    ue_id=81    cell_id=1    pdu=1    gw=1
    UE in Idle    ue_id=82    cell_id=1    pdu=2    gw=2
    UE in Idle    ue_id=83    cell_id=1    pdu=3    gw=3
    UE in Idle    ue_id=84    cell_id=1    pdu=4    gw=4
    UE in Idle    ue_id=85    cell_id=1    pdu=5    gw=5
    Online modify dllaBlerTargetHR
    Online modify dlHRBlerOutageMcsThresh64qamLowSE
    Online modify dlHRBlerOutagePercentage
    Online modify dlHRBlerOutagePeriod

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu}    ${gw}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${gw} nwslice=1    QoS Routing Table

UE in Idle
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu}    ${gw}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_param empty_pdu_session_list=on id=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${gw} nwslice=1    QoS Routing Table
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    UE Context Release Complete

Exit idle
    [Arguments]    ${ue_id}    ${pdu}
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    Initial Context Setup Successful
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal

Online modify dllaIniDeltaCqiHR
    Start To Capture Wireshark Log    D_03_01
    OnlineParamChange    @{online_modify_dllaIniDeltaCqiHR}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_03${/}a2a.ini    name=D_03_01    wait_string=itf_l2_ps_cell_cellreconfigurationresp::3

Online modify dllaDeltaCqiMaxHR
    Start To Capture Wireshark Log    D_03_02
    OnlineParamChange    ${online_modify_dllaDeltaCqiMaxHR}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_03${/}a2a_D_03_02.ini    name=D_03_02    wait_string=itf_l2_ps_cell_cellreconfigurationresp::3

Online modify dllaDeltaCqiStepdownHR
    Start To Capture Wireshark Log    D_03_03
    OnlineParamChange    ${online_modify_dllaDeltaCqiStepdownHR}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_03${/}a2a_D_03_03.ini    name=D_03_03    wait_string=itf_l2_ps_cell_cellreconfigurationresp::3

Online modify dllaBlerTargetHR
    Start to Capture Wireshark Log    D_05_01
    OnlineParamChange    ${online_modify_dllaBlerTargetHR}
    Exit idle    ue_id=82    pdu=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_05${/}a2a.ini    name=D_05_01    wait_string=dllaBlerTargetHR::1

Online modify dlHRBlerOutageMcsThresh64qamLowSE
    Start to Capture Wireshark Log    D_05_02
    OnlineParamChange    ${online_modify_dlHRBlerOutageMcsThresh64qamLowSE}
    Exit idle    ue_id=83    pdu=3
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_05${/}a2a_D_05_02.ini    name=D_05_02    wait_string=dlHRBlerOutageMcsThresh64qamLowSE::1

Online modify dlHRBlerOutagePercentage
    Start to Capture Wireshark Log    D_05_03
    OnlineParamChange    ${online_modify_dlHRBlerOutagePercentage}
    Exit idle    ue_id=84    pdu=4
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_05${/}a2a_D_05_03.ini    name=D_05_03    wait_string=dlHRBlerOutagePercentage::1

Online modify dlHRBlerOutagePeriod
    Start to Capture Wireshark Log    D_05_04
    OnlineParamChange    ${online_modify_dlHRBlerOutagePeriod}
    Exit idle    ue_id=85    pdu=5
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_D_05${/}a2a_D_05_04.ini    name=D_05_04    wait_string=dlHRBlerOutagePeriod::1
