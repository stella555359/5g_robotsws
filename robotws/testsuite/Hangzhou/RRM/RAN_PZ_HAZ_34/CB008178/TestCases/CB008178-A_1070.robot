*** Settings ***
Library    DateTime
Resource    ./../Resources/CB008178-A_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008985/Resources/CB008178_keywords.robot

Documentation    Suite description
...    author: Jiang Xian
...    contact: xian.jiang@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB008178

Suite Setup  8178 Suite preparation multiGNB   frame_bw=100M_1070    NSA_SA=${NSA_SA}
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         1200M
${UL_TPUT}         300M

*** Test Cases ***
CB008178-A-TC202-PMO-RX_PREAMBLE_PWR_PRACH_LEVEL_12...22-eCPRI_TDD-MultiUE-SA_NSA
    [Tags]  CIT_TRUNK
    [Documentation]     Author: Jiang Xian
    ...    UE attach 5 times, check  AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL_** update correctly
    [Setup]     CB008178 Case setup   scf_template_path=${None}
    ${ssb_id_list}    create list    0    1
    UE attach several times then check AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL counters
    ...    cell_id=1    subcell_id=0    ssb_beam_needed=${True}   ssb_id_list=${ssb_id_list}    attach_times=${5}
    ...    target_file_name=step1_bip_log_attach_5_times
    [Teardown]    run keyword and ignore error     8178 case teardown    detach_ue=${True}
