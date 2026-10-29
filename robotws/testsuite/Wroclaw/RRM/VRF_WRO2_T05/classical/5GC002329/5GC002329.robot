*** Settings ***

Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002329/resources/kw_2329.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot


# Test Setup      Run keyword
# ...    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA

# Test Teardown   Run Keyword
# ...    Detach Ue     UE_2

*** Variables ***
${tput_DL_bandwith_2329L}     1380 Mbits/sec
${tput_UL_bandwith_2329L}     50 MBits/sec
${tput_deviation}       10%
${tput_duration_2329L}        100s
${Packet_Size}          1200

*** Keywords ***
[1]5GC002329_AD_UE_configured_with_both_TDD-FDD_FR1_CA_and_DRX_in_SA_mode_with_VoNR
    Setup attenuators
    Set attenuators for 2329
    Start syslog collection
    sleep  10s
    ute_ue.Attach Ue  UE_2
    sleep  5s
    Start Tshark for 2329
    sleep  2s
    Start ULDL UDP SA  ${tput_DL_bandwith_2329L}   ${tput_UL_bandwith_2329L}   ${tput_duration_2329L}
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    sleep  10s
    Start Voice Call    VC_1    UE_2    0105   duration=20s    dialing_timeout=70s
    sleep  2s
    Stop Tshark and download logs after VoNR start
    sleep  5s
    Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_2329L}   ${tput_UL_bandwith_2329L}
    Start Tshark for 2329
    Await Voice Call Finish    VC_1
    Sleep   5s
    Stop Voice Call    VC_1
    Stop Tshark and download logs after VoNR stop
    Stop syslog collection
    Verify FDD SCell configuration
    Verify FDD SCell activation 2329
    Verify VoNR call success
    Verify VoNR call release

[1]5GC002329_AE_Single_UE_full_mobility_support_for_UE_which_has_TDD_FR1_and_FDD_CA_configured_for_SA_call_incoming_UE
    # TC name change without brackets -> brackets can not be in syslog name (name is created based on TC name)
    Set test variable  ${test_name}  5GC002329_AE
    Setup attenuators
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Start syslog collection
    sleep  5s
    ute_ue.Attach Ue  UE_2
    ${IP}  ute_ue.Get Ue Info    UE_2   IP
    Log to console    ${IP}
    ${PCI_befor_ho}  ute_ue.Get Ue Info    UE_2   PCI
    Log to console   ${PCI_befor_ho}
    sleep  10s
    Set attenuation_2 and check  lines=${lines_gNB_410_AEHC_6_TDD}   value=0
    sleep  15s
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=45
    sleep  15s
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=90
    sleep  15s
    Log to console   After Handover PCI
    ${PCI_after_ho}  ute_ue.Get Ue Info    UE_2   PCI
    Log to console   ${PCI_after_ho}
    Start ULDL UDP SA  ${tput_DL_bandwith_2329L}   ${tput_UL_bandwith_2329L}   ${tput_duration_2329L}
    sleep  15s
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    sleep  15s
    Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_2329L}   ${tput_UL_bandwith_2329L}
    sleep  15s
    Stop syslog collection
    Verify FDD SCell configuration
    Verify FDD SCell activation 2329
