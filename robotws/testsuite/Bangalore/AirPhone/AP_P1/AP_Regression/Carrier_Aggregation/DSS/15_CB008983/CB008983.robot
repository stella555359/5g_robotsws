*** Settings ***
Documentation     author: kusuma S
...               contact: kusuma.s@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot
Resource        ../../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008983

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/../../Config_Files/15_CB008983/wts
@{dl_tput_list}                  150    150    150    150
${total_DL_tput}                 600
${ul_tput}                       50
@{SA_UE_List}                    1
${SA_UE_HO}                      1
@{FDD_UE_List}                   61
${FDD_UE_HO}                     61
@{SA_Scell_list}                 0    1    2    3
@{SA_Scell_list_1}               0
${EDAEMON_PORT}                  22222
@{noofcells}                     3    4
@{target_cell}                   3    4
${NUMBER_OF_CELLS}               2
${pdu_id}                        3
${phycell_id}                    50
${phycell_id_fdd}                53
${fdd_primary_cell}              4
${sim_cell_fdd}                  1
${A2_carrier_freq}               518430
${A3_carrier_freq}               127250
${A2_carrier_freq_fdd}           156010
${assigned_dl_minimum_share_to_nr}    75
${min_lte_nr_dss_ratio}          75
@{ul_allocated_prb_list}         0,3|5,35|49,3    0,3|5,70|103,3
${antenna_ports_num}             1
${super_all_status}              on
${dl_norsubframes}               1011111001-1111111111-1011111001-1111111111-1011111001-1111111111-1011111001-1111111111
${prb_allocat_1}                 SEPARATOR=    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,
...    52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,
...    52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,
...    52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,
...    52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52
${prb_allocat_2}                 SEPARATOR=    0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,
...    106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,
...    106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,
...    106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,
...    106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,
...    106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106
@{prb_allocat}                   ${prb_allocat_1}    ${prb_allocat_2}

*** Test Cases ***
CB008983_TC_1_WithDSS_Phase3_SANSA_IntragNB_InterFreq_Handover_TDD_FDD_TDD_with_CA_Regression
    [Documentation]    DSS
    [Tags]    AP_REG    TC5_DSS
    [Setup]    Test setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=CB008983    prb_list=True    prb_allocat=${prb_allocat}
    ...    ul_allocated_prb_list=${ul_allocated_prb_list}    HO=True
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${SA_UE_List}    4CC=True
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${SA_UE_List}    UL_Scell_Id=${SA_Scell_list_1}    DL_Scell_Id=@{SA_Scell_list}
    ...    UL_Scell_Id_2=${SA_Scell_list_1}
    Trigger Interfreq XN Based SA Forward handover for 4CC    ue_id=${SA_UE_HO}    scell_index=${SA_Scell_list}    A2_carrier_freq=${A2_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_freq}
    Get Average Throughput from Bearer Stats For SA    ue_id=${SA_UE_HO}    dir=dl    pdu_id=${pdu_id}
    Get Average Throughput from Bearer Stats For SA    ue_id=${SA_UE_HO}    dir=ul    pdu_id=${pdu_id}
    Trigger Interfreq XN Based SA Reverse handover for 4CC    ue_id=${SA_UE_HO}    scell_index=${SA_Scell_list}    A2_carrier_freq=${A3_carrier_freq}
    ...    A3_carrier_freq=${A2_carrier_freq}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${SA_UE_List}    UL_Scell_Id=${SA_Scell_list_1}    DL_Scell_Id=@{SA_Scell_list}
    ...    UL_Scell_Id_2=${SA_Scell_list_1}
    Stop Traffic and Detach SA UEs    ${SA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${SA_UE_List}

CB008983_TC_2_WithDSS_Phase3_SANSA_IntragNB_InterFreq_Handover_FDD_TDD_FDD_with_CA_Regression
    [Documentation]    DSS
    [Tags]    AP_REG    TC6_DSS
    [Setup]    Test setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=CB008983    prb_list=True    prb_allocat=${prb_allocat}
    ...    ul_allocated_prb_list=${ul_allocated_prb_list}    HO=True
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${FDD_UE_List}    4CC=True
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${FDD_UE_List}    UL_Scell_Id=${SA_Scell_list_1}    DL_Scell_Id=@{SA_Scell_list}
    ...    UL_Scell_Id_2=${SA_Scell_list_1}
    Trigger Interfreq XN Based SA Forward handover for 4CC    ue_id=${FDD_UE_HO}    scell_index=${SA_Scell_list}
	...    A2_carrier_freq=${A2_carrier_freq_fdd}    A3_carrier_freq=${A2_carrier_freq}    phycell_id=${phycell_id}
	...    primary_cell=${fdd_primary_cell}    sim_cell=${sim_cell_fdd}
    Get Average Throughput from Bearer Stats For SA    ue_id=${FDD_UE_HO}    dir=dl    pdu_id=${pdu_id}
    Get Average Throughput from Bearer Stats For SA    ue_id=${FDD_UE_HO}    dir=ul    pdu_id=${pdu_id}
    Trigger Interfreq XN Based SA Reverse handover for 4CC    ue_id=${FDD_UE_HO}    scell_index=${SA_Scell_list}    A2_carrier_freq=${A2_carrier_freq}
    ...    A3_carrier_freq=${A2_carrier_freq_fdd}    phycell_id=${phycell_id_fdd}    primary_cell=${fdd_primary_cell}
	...    sim_cell=${sim_cell_fdd}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${FDD_UE_List}    UL_Scell_Id=${SA_Scell_list_1}    DL_Scell_Id=@{SA_Scell_list}
    ...    UL_Scell_Id_2=${SA_Scell_list_1}
    Stop Traffic and Detach SA UEs    ${FDD_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${FDD_UE_List}
