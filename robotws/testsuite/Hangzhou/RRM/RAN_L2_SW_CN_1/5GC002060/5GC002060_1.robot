*** Settings ***
Documentation    ...
#Resource       ./5GC002060_Common_Keyword.robot
#Resource       ../CUDU_L2/common_setup_teardown.robot
#
#Force Tags        RAN_5G_TDD    FR1
#...               Owner_lading    5GC002060    RAN_5G    SBTS00    SBTS23R1    SBTS22R4    CRT
#...               CN1_SQ    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#
#Suite Setup    Common Suite Setup 2
#Suite Teardown    Common Suite Teardown 2
#*** Variables ***
#${DELTA_FILE_A_01}    Delta_conf_5GC002060_ET_case1.json
#${DELTA_FILE_A03}    Delta_conf_5GC002060_ET_A03.json
#${DELTA_FILE_A06}    Delta_conf_5GC002060_ET_A06.json
#${DELTA_FILE_A012}    Delta_conf_5GC002060_ET_A012.json
#${WTS_CFG_CASE_A_01}    wts_cfg_NSA_TDD_FR1_2UE_DRX.cfg
#${WTS_CFG_CASE_A_06}    wts_cfg_NSA_TDD_FR1_2UE_DRX_SRB3.cfg
#${Drx_period}          8
#${Drx_period_A03}    64
#${Drx_period_A06}    32
#${Drx_period_A012}    64
#${DELTA_FILE_B07}    Delta_conf_5GC002060_ET_B07.json
#${SWCONFIG_PARAM_B07}    0x5801c1=5;0x580003=5000;
#
#*** Test Cases ***
#5GC002060-ET-A001_FR1_DRX_LongCycle_160_ms_for_FR1NSA_L3_call_via_LTE_SRB1_in_NSA_mode
#    [Tags]     Owner_lading    case_A_01
#    [Setup]    Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#    ...        AND    Setup TL For Each Case    ${DELTA_FILE_A_01}    ${WTS_CFG_CASE_A_01}
#    [Timeout]    60min
#    Start X2 Pcap Log
#    NSA L3 UE attach    11    2    2    2
#    Stop X2 Pcap Log    ${output_dir}
#    NSA Start DL Traffic    11    2    100
#    NSA Start UL Traffic    11    2    60
#    Start Ttitrace With Streaming Mode
#    NSA Stop Traffic    11    2    ul     1
#    NSA Stop Traffic    11    2    dl     1
#    Stop Ttitrace And Convert To CSV
#    Check DRX on time and sleep time is right    0.14
#    Verify DRX period from ttitrace    ${Drx_period}
#    #[Teardown]    Recover TL
#
#5GC002060-ET-A003_FR1_DRX_LongCycle_640_ms_for_FR1NSA_L3_call_via_LTE_SRB1_in_NSA_mode
#    [Tags]     Owner_dguan    case_A_03
#    [Setup]    Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#    ...        AND    Setup TL For Each Case    ${DELTA_FILE_A03}    ${WTS_CFG_CASE_A_01}
#    [Timeout]    60min
#    Start X2 Pcap Log
#    NSA L3 UE attach    11    2    2    2
#    Stop X2 Pcap Log    ${output_dir}
#    NSA Start DL Traffic    11    2    30
#    NSA Start UL Traffic    11    2    30
#    Start Ttitrace With Streaming Mode
#    NSA Stop Traffic    11    2    ul     1
#    NSA Stop Traffic    11    2    dl     1
#    sleep    5s
#    Stop Ttitrace And Convert To CSV
#    Check DRX on time and sleep time is right    0.14
#    Verify DRX period    ${Drx_period_A03}
#    #[Teardown]    Recover TL
#
#5GC002060-ET-A006_FR1_DRX_LongCycle_320_ms_for_L3_call_via_LTE_SRB3_in_NSA_mode
#    [Tags]     Owner_suqian    case_A_06
#    [Setup]    Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#    ...        AND    Setup TL For Each Case    ${DELTA_FILE_A06}    ${WTS_CFG_CASE_A_06}
#    [Timeout]    60min
#    Start X2 Pcap Log
#    NSA L3 UE attach    11    2    2    2
#    Stop X2 Pcap Log    ${output_dir}
#    NSA Start DL Traffic    11    2    100
#    NSA Start UL Traffic    11    2    60
#    Start Ttitrace With Streaming Mode
#    NSA Stop Traffic    11    2    ul     1
#    NSA Stop Traffic    11    2    dl     1
#    Stop Ttitrace And Convert To CSV
#    Periodic Read PM Counter    M55308C11001
#    Periodic Read PM Counter    M55308C11002
#    Verify DRX period    ${Drx_period_A06}
#    #[Teardown]    Recover TL
#
#5GC002060-ET-A012_FR1_SA_L3_call_with_DRXLongCycle 640 ms
#    [Tags]     Owner_haiyliu    case_A_012
#    [Setup]    Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#    ...        AND    Setup TL For Each Case    ${DELTA_FILE_A012}    TDD_basic_setup.cfg
#    [Timeout]    60min
#    SA 5G Attach    1
#    SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G PDU Session Setup    1
#    SA Start Traffic Internal    ue_id=1    pdu_id=1    mbps=175
#    Start Ttitrace With Streaming Mode
#    sleep    10s
#    SA Stop Data Traffic Internal    1    1
#    sleep    5s
#    Stop Ttitrace And Convert To CSV
#    Periodic Read PM Counter    M55308C11001
#    Periodic Read PM Counter    M55308C11002
#    Verify DRX period from ttitrace    ${Drx_period_A012}
#    #[Teardown]    Recover TL
#
#5GC002060-ET-B007_UE_will_perform_beam_change_when_beam_age_exceed_for_4_beam_in_SA_mode
#    [Tags]     Owner_yalsun    case_B_07
#    [Setup]    Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#    ...        AND    Setup TL For Each Case    ${DELTA_FILE_B07}    TDD_basic_setup.cfg    ${SWCONFIG_PARAM_B07}
#    [Timeout]    60min
#    UE Beamforming Profile And Association
#    SA 5G Attach    1
#    SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G PDU Session Setup    1
#    SA Start Traffic Internal    ue_id=1    pdu_id=1    mbps=175
#    Check PatternID From Wirshark    1
#    UE Beamforming Switch    2    0
#    Check PatternID From Wirshark    2