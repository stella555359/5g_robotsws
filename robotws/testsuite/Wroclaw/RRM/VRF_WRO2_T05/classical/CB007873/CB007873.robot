*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007873/resources/kw_cb007873.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
# Resource        testsuite/RRM/Wroclaw/FGCR-10143/resources/kw_fgcr10143.robot

# Test Setup      Run keyword
# ...    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA


# Test Teardown   Run Keyword
# ...    Run Keyword and Ignore Error    Detach Ue     UE_2

*** Variables ***
${tput_DL_bandwith_1390L}     920 Mbits/sec
${tput_UL_bandwith_1390L}     50 MBits/sec
${tput_deviation}       10%
${tput_duration_1390L}        300s
${Packet_Size}          1200

*** Keywords ***
[1]CB007873_5G_I_02_Inter-band_FDD_-_FR1_TDD_DL_CA_for_NSA_UE
    [Documentation]  This scenario describes the successful UE configuration of the Inter-band DL CA FDD ? FR1-TDD
    ...              feature for single UE with 2 aggregated carriers in NSA 3x mode. PSCell is FDD carrier and single
    ...              SCell is FR1-TDD carrier. It is assumed that FDD cell and FR1-TDD cell have overlaid coverage
    ...              with FDD cell having bigger coverage compared to TDD cell. FDD cell and FR1-TDD cell are served
    ...              by two different BB cards. In addition, DRX setup for UE with data DRB after SCell
    ...              configuration is verified.
    # &{bts_key} =    Create Dictionary    host=10.44.90.162  port=443  username=Nemuadmin  password=nemuuser
    # Create dcap session    host=10.42.54.68    port=8100   secure=True
    # Get dcap bts id by IP   host=10.44.90.162
    # Dcap get 5g profiles
    # Dcap create bts    host=10.44.90.162
    # Dcap start trace   bts=&{bts_key}   gnb_trace_profile=NR_488
    # Run Change Mode Script   ue_mode=NSA
    Set connection To LTE
    Change cellBarred    value=barred
    Change cellBarred    value=barred    cell_id=104
    Setup attenuators
    Set attenuator for 7873 step 1
    Start syslog collection
    sleep  10s
    Start tcpdump logs on LTE
    sleep  10s
    # Change Network Mode    UE_2    NR_LTE
    Attach UE SA For test
    sleep  5s
    ${QUALCOMM_CELL_ID}=    ute_ue.Get Ue Info    UE_2   PCI
    Log to console  ${QUALCOMM_CELL_ID}
    Start ULDL UDP SA  ${tput_DL_bandwith_1390L}   ${tput_UL_bandwith_1390L}   ${tput_duration_1390L}
    Set attenuator for 7873 step 2
    sleep  25s
    Set attenuator for 7873 step 3
    sleep  25s
    Stop tcpdump logs on LTE and download logs
    Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_1390L}   ${tput_UL_bandwith_1390L}
    # Dcap stop trace
    Change cellBarred    value=notBarred
    sleep  10s
    Stop syslog collection
    Detach Ue     UE_2
    sleep  50s
    # Verify SCell configuration
    Verify SCell activation
    Verify call release
    Verify PM Counters 7873
    [Teardown]   Run keywords
    ...   Change cellBarred    value=notBarred    AND
    ...   Change cellBarred    value=notBarred    cell_id=104
    # ...   Run Change Mode Script   ue_mode=SA

# [1]CB007873_5G_I_13_Inter-band_FDD-DSS_-_FR1_TDD_DL_CA_for_SA_UE
#     [Documentation]  This scenario describes the successful UE configuration of the Inter-band DL CA FDD ? FR1-TDD
#     ...              feature for single UE with 2 aggregated carriers in SA mode. PCell is FDD carrier with DSS Phase 2
#     ...              feature activate and single SCell is FR1-TDD carrier. It is assumed that FDD-DSS cell and FR1-TDD
#     ...              cell have overlaid coverage with FDD-DSS cell having bigger coverage compared to TDD cell.
#     ...              FDD-DSS cell and FR1-TDD cell are served by two different BB cards.
#     ...              In addition, DRX setup for UE with data DRB after SCell configuration is verified.
#     # &{bts_key} =    Create Dictionary    host=10.44.90.162  port=443  username=Nemuadmin  password=nemuuser
#     # Create dcap session    host=10.42.54.68    port=8100   secure=True
#     # Get dcap bts id by IP   host=10.44.90.162
#     # Dcap get 5g profiles
#     # Dcap create bts    host=10.44.90.162
#     # Dcap start trace   bts=&{bts_key}   gnb_trace_profile=NR_488
#     Setup attenuators
#     Set attenuator for 7873 step 1
#     Start syslog collection
#     sleep  10s
#     sleep  10s
#     Attach UE SA For test
#     Change Network Mode    UE_2    NR_only
#     sleep  5s
#     ${QUALCOMM_CELL_ID}=    ute_ue.Get Ue Info    UE_2   PCI
#     Log to console  ${QUALCOMM_CELL_ID}
#     Start ULDL UDP SA  ${tput_DL_bandwith_1390L}   ${tput_UL_bandwith_1390L}   ${tput_duration_1390L}
#     Set attenuator for 7873 step 35db for 104
#     sleep  3s
#     # Stop tcpdump logs on LTE and download logs
#     Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_1390L}   ${tput_UL_bandwith_1390L}
#     Detach Ue     UE_2
#     sleep  10s
#     Stop syslog collection
#     Verify SCell configuration SA
#     Verify SCell activation
#     Verify call release
#     Verify PM Counters 7873 SA
#     # [Teardown]   Run keyword
#     # ...   Dcap stop trace
