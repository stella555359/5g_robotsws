*** Settings ***
Documentation     author: Gopi Ram
...               contact: gattu.gopi_ram@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot
Resource        ../../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008983

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/../../Config_Files/15_CB008983/wts
@{dl_tput_list}                  100
${ul_tput}                       10
@{SA_UE_List}                    1
@{NSA_UE_List}                   11
@{SA_Scell_list}                 0    1
@{NSA_Scell_list}                8    9
@{SA_Scell_Index}                1
@{NSA_Scell_Index}               9
@{SA_Scell_list_1}               0
@{NSA_Scell_list_1}              8
${EDAEMON_PORT}                  22222
@{noofcells}                     1
${NUMBER_OF_CELLS}               2
${assigned_dl_minimum_share_to_nr}    75
${min_lte_nr_dss_ratio}          75
${ul_allocated_prb_list}         0,3|5,70|103,3
@{nrcel_profile_id}              1    2
&{delta}                         sCellActivationMethod=blind    sCellDeactivationTimerGNB=infinity
@{logical_cell_list}             1    2
${prb_allocat}                   SEPARATOR=    0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,
...    106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,
...    106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,
...    106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,
...    106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,
...    106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106


*** Test Cases ***
CB008983_C_WithDSS_Phase3_SANSA_20Mhz_FDD_TDD_n8_N78_80Mhz_CA_Blind_Addition_Buffer_and_RLQ_based_Activation
    [Documentation]    Attach NSA and SA with DSS enable and validate traffic with blind scell addition and buffer RLQ scell activation
    [Tags]    AP_REG    DSS_TC1
    [Setup]    Test setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=CB008983
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation    ${NSA_UE_List}    ${NSA_Scell_Index}
    ...    target_cells=1    uplink_tput=${ul_tput}
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


CB008983_C_WithDSS_Phase3_SANSA_20Mhz_FDD_TDD_n8_N78_80Mhz_CA_Blind_Addition_Blind_Activation
    [Documentation]    Attach NSA and SA with DSS enable and validate traffic with blind scell addition and blind scell activation
    [Tags]    AP_REG    DSS_TC2
    [Setup]    Test Setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=CB008983    scf_update=True    cell_deployment=SANSA
    ...    delta=${delta}    logical_cell_list=@{nrcel_profile_id}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${NSA_UE_List}    target_cells=1
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${SA_UE_List}
    sleep    10s    reason=for traffic to be stable
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}[0]
    ...    expected_ul_tput=${ul_tput}    UE_List=${NSA_UE_List}    UL_Scell_Id=${NSA_Scell_list_1}    DL_Scell_Id=${NSA_Scell_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}[0]
    ...    expected_ul_tput=${ul_tput}    UE_List=${SA_UE_List}    UL_Scell_Id=${SA_Scell_list_1}    UL_Scell_Id_2=${SA_Scell_list_1}
    ...    DL_Scell_Id=${SA_Scell_list}
    Stop Traffic and Detach SA UEs    ${SA_UE_List}
    Stop Traffic and Detach NSA UEs    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    CB008983    sa_ue_list=${SA_UE_List}    nsa_ue_list=${NSA_UE_List}


*** Keywords ***
Get Delta for CB008983
    [Arguments]    &{kwargs}
    Get bts distname
    ${sCellActivationMethod}    Pop From Dictionary    ${kwargs}    sCellActivationMethod
    ${sCellDeactivationTimerGNB}    Pop From Dictionary    ${kwargs}    sCellDeactivationTimerGNB
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}
    ...    sCellActivationMethod=${sCellActivationMethod}
    FOR    ${cell_id}    IN    @{NRCELL_distname_list}
        delta_store.update managed object and parameter to delta    dist_name=${cell_id}
        ...    sCellDeactivationTimerGNB=${sCellDeactivationTimerGNB}
    END
