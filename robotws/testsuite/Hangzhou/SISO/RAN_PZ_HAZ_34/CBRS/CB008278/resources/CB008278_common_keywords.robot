*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB008184

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Variables    ../TestData/CB008278_variables.py

*** Variables ***
@{PA_Ports}    13    14    15    16
@{nr_cell_1}    ${1}
*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_10MHz+10MHz
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep  30
    log to console    SET PA
    #Set PA Value For Pointed Port    PA_Port_List=${PA_Ports}    value=${5}
    data_transfer_common    tput_self_define=${tput}    tput_from=self_define    cell_id=${nr_cell_1}    loop_times=${1}
    [Teardown]    Set PA Value For Pointed Port    PA_Port_List=${PA_Ports}    value=${20}
