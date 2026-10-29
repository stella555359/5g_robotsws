*** Settings ***
Documentation     author: Sudha V
...               contact: sudha.v@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot
Resource        ../../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008983

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/../../Config_Files/14_CB008983/wts
@{dl_tput_list}                  100
${ul_tput}                       10
@{SA_UE_List}                    1    31    51
@{NSA_UE_List}                   11   41    61
@{NSA_UE1}                       11
@{NSA_UE2}                       41
@{NSA_UE3}                       61
@{SA_Scell_list}                 0    1
@{NSA_Scell_list}                8    9
@{SA_Scell_Index}                1
@{NSA_Scell_Index}               9
@{SA_Scell_list_1}               0
@{NSA_Scell_list_1}              8
${EDAEMON_PORT}                  22222
@{noofcells}                     1    2    3
@{target_cell}                   1    2    3
${NUMBER_OF_CELLS}               2
${assigned_dl_minimum_share_to_nr}    75
${min_lte_nr_dss_ratio}          75
@{ul_allocated_prb_list}         0,3|5,35|49,3    0,3|5,52|76,3    0,3|5,70|103,3
@{nrcel_profile_id}              1    2
&{delta}                         sCellActivationMethod=blind    sCellDeactivationTimerGNB=infinity
${antenna_ports_num}             1
@{logical_cell_list}             1    2    3    4
${super_all_status}              on
${dl_norsubframes}               1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
${prb_allocat_1}                 SEPARATOR=    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,
...    52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,
...    52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,
...    52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,
...    52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52
${prb_allocat_2}                 SEPARATOR=    0:0,79+1:0,79+2:0,79+3:0,79+4:0,79+5:0,79+6:0,79+7:0,79+8:0,79+9:0,79+10:0,79+11:0,79+12:0,79+13:0,
...    79+14:0,79+15:0,79+16:0,79+17:0,79+18:0,79+19:0,79+20:0,79+21:0,79+22:0,79+23:0,79+24:0,79+25:0,79+26:0,79+27:0,79+28:0,79+29:0,79+30:0,
...    79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,79+36:0,79+37:0,79+38:0,79+39:0,79+40:0,79+41:0,79+42:0,79+43:0,79+44:0,79+45:0,79+46:0,79+47:0,
...    79+48:0,79+49:0,79+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,79+56:0,79+57:0,79+58:0,79+59:0,79+60:0,79+61:0,79+62:0,79+63:0,79+64:0,
...    79+65:0,79+66:0,79+67:0,79+68:0,79+69:0,79+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,79+76:0,79+77:0,79+78:0,79+79:0,79
${prb_allocat_3}                 SEPARATOR=    0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,
...    106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,
...    106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,
...    106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,
...    106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,
...    106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106
@{prb_allocat}                   ${prb_allocat_1}    ${prb_allocat_2}    ${prb_allocat_3}

*** Test Cases ***
CB008983_C_WithDSS_Phase3_SANSA_FDD_DSS_N1_10M_15M_N8_20M_TDD_N78_100M_NONDSS_CA_Blind_Addition_Buffer_RLQ_Activation
    [Documentation]    DSS
    [Tags]    AP_REG    TC5_DSS
    [Setup]    Test setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=CB008983    prb_list=True    prb_allocat=${prb_allocat}
    ...    ul_allocated_prb_list=${ul_allocated_prb_list}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation    ${NSA_UE1}    ${NSA_Scell_Index}
    ...    target_cells=1    uplink_tput=${ul_tput}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation    ${NSA_UE2}    ${NSA_Scell_Index}
    ...    target_cells=2    uplink_tput=${ul_tput}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation    ${NSA_UE3}    ${NSA_Scell_Index}
    ...    target_cells=3    uplink_tput=${ul_tput}
    Perform SA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation    ${SA_UE_List}    ${SA_Scell_Index}
    ...    uplink_tput=${ul_tput}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}[0]
    ...    expected_ul_tput=${ul_tput}    UE_List=${NSA_UE_List}    UL_Scell_Id=${NSA_Scell_list_1}    DL_Scell_Id=${NSA_Scell_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}[0]
    ...    expected_ul_tput=${ul_tput}    UE_List=${SA_UE_List}    UL_Scell_Id=${SA_Scell_list_1}    UL_Scell_Id_2=${SA_Scell_list_1}
    ...    DL_Scell_Id=${SA_Scell_list}
    Activate testmode and verify scell deactivation    ${NSA_UE_List}    scell=${NSA_Scell_Index}[0]    profile_id=2    scell_list=${NSA_Scell_Index}
    Activate testmode and verify scell deactivation    ${SA_UE_List}    scell=${SA_Scell_Index}[0]    profile_id=2    scell_list=${SA_Scell_Index}
    Stop Traffic and Detach SA UEs    ${SA_UE_List}
    Stop Traffic and Detach NSA UEs    ${NSA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${SA_UE_List}    nsa_ue_list=${NSA_UE_List}