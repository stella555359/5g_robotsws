*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  CB009854-X_05_Measurement_gaps_and_inter_freq_HO_for_5CC_UE test automation

Library    ute_ue
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009854/resources/keywords.robot

*** Keywords ***
CB009854_X_05_Measurement_gaps_and_inter_freq_HO_for_5CC_UE
    Set Test Variable   ${ue}   UE_5
    Set Test Variable   ${pcell}   211
    set_preferred_cell   cell_id=${pcell}
    counters.Wait For Pm Counters Interval
    ute_ue.Require Ue    ${ue}    ${ue}
    ute_ue.Attach Ue   UE_5
    Start DL Traffic For Ue    ${ue}    1200Mbits/sec    duration=100s
    Start UL Traffic For Ue    ${ue}    80Mbits/sec     duration=100s
    5CC Counters Loop
    Verify DL Tput For Ue    ${ue}
    Verify UL Tput For Ue    ${ue}
    [Teardown]    Run Keywords
    ...         Detach Ue   ${ue}
    ...   AND   unset_preferred_cell
