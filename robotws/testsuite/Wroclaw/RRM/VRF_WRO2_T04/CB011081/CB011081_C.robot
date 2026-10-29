*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  [1]TC3_CB011081_C_IWK4_FDD+TDD_FR1_DL_6CC_CA_and_F+F_UL_2CC_CA test automation

Library    ute_ue
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/regression_keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011081/resources/keywords.robot


*** Keywords ***
CB011081_C_IWK4_FDD_TDD_FR1_DL_6CC_CA_and_F_F_UL_2CC_CA
    Set Attenuation  0dB  ${ATTENUATOR['AHFIG_2']['ports']}  confirm=${TRUE}
    ...     attenuator_id=${ATTENUATOR['AHFIG_2']['att_id']}
    Set Test Variable   ${ue}   UE_5
    Set Test Variable   ${pcell}   211
    set_preferred_cell   cell_id=${pcell}
    add_scell_addition_method   from_cell=${pcell}   to_cell=202   add_method=covBasedA1
    counters.Wait For Pm Counters Interval
    ute_ue.Require Ue    ${ue}    ${ue}
    ute_ue.Attach Ue   ${ue}
    Start DL Traffic For Ue    ${ue}    1200Mbits/sec    duration=100s
    Start UL Traffic For Ue    ${ue}    80Mbits/sec     duration=100s
    6CC Counters Loop
    Verify DL Tput For Ue    ${ue}
    Verify UL Tput For Ue    ${ue}
    [Teardown]    Run Keywords
    ...         Set Attenuation  90dB  ${ATTENUATOR['AHFIG_2']['ports']}  confirm=${TRUE}
    ...             attenuator_id=${ATTENUATOR['AHFIG_2']['att_id']}
    ...   AND   Detach Ue   ${ue}
    ...   AND   remove_scell_addition_method   from_cell=${pcell}   to_cells=202
    ...   AND   unset_preferred_cell
