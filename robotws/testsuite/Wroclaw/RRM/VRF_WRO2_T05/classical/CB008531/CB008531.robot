*** Settings ***

Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008531/resources/kw_CB008531.robot


# Test Setup      Run keyword
# ...    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA

# Test Teardown   Run Keyword
# ...    Detach Ue     UE_2

*** Variables ***
${resource_path_8531}            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008531/resources
${tput_DL_bandwith_CB008531}     980 Mbits/sec
${tput_UL_bandwith_CB008531}     50 MBits/sec
${tput_deviation}       10%
${tput_duration_CB008531}        200s
${Packet_Size}          1200
@{lines_gNB_159_off}       13   14   15   16   17   18
@{lines_gNB_159_on}        19   20
@{lines_gNB_154_off}       1   2   3   4   5   6   7   8   9   10   11   12
@{lines_gNB_154_on}        9   10   11   12

*** Keywords ***
[1]CB008531-5G-D_03_InterFrequencyInterGnb_PCell-HO_different_target_gNB_neighbors
#    Load scf for second NR  ${resource_path_8531}    SCFs  scf_MRBTS-51005-handover_154.xml  10.42.181.25
    Setup attenuators
    Set attenuators for CB008531
    Setup attenuator for 154 TL
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_off}   value=90
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=0
    Start syslog collection
    sleep  10s
    Attach UE SA For test
    ${Before_ho}=    ute_ue.Get Ue Info    UE_2   PCI
    Log to console   ${Before_ho}
    Start Tshark for CB008531
    sleep  5s
    Start ULDL UDP SA  ${tput_DL_bandwith_CB008531}   ${tput_UL_bandwith_CB008531}
    Perform handover
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Log to console   Scell should be activated
    ${After_ho}=    ute_ue.Get Ue Info    UE_2   PCI
    Log to console   ${After_ho}
    Stop Tshark and download logs after handover
    Stop syslog collection
    Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_CB008531}   ${tput_UL_bandwith_CB008531}
    Verify FDD SCell activation 8531
    Should Not Be Equal As Strings  ${Before_ho}   ${After_ho}
    Verify Inter-gNB handover procedure
    Verify UE Capability Enquiry procedure
    [Teardown]  Run Keywords
    ...   Run Keyword and Ignore Error   Stop syslog collection   AND
    ...   Setup initial attenuation for 154 TL   lines=${lines_gNB_154_off}   value=90
