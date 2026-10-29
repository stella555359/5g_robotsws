*** Settings ***
Documentation  Test Cases implementation for CB008152

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008152/resources/keywords.robot

*** Variables ***
${tput_duration}  30s

*** Keywords ***
[1]CB008152-B.B1_05_SA_2UEs_FDD_35MHz_PeakTput_UL_DL
    Detach UEs from cell    ${ues}
    attach ues to cell  ${ues}

    Start ULDL for UEs  ${ues}  duration=1m
    ${tputs}  Await datatransfers finish

    ${dl_avg}  set variable  ${tputs[0]}
    ${ul_avg}  set variable  ${tputs[1]}

    should be true  ${dl_avg} >= 350000
    should be true  ${ul_avg} >= 250000


[1]CB008152-B.B1.B4_14_SA_FDD_35MHz_64QAM_L3call_UL_DL_tput
    Set 64QAM DL/UL
    Detach UEs from cell    ${ues}
    attach ues to cell  ${ues}

    Start ULDL for UEs  ${ues}  duration=1m
    ${tputs}  Await datatransfers finish