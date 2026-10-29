*** Settings ***
Documentation     author: Gopi Ram
...               contact: gattu.gopi_ram@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot
Resource        ../../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008983

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/../../Config_Files/13_CB008983/wts
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
${ul_allocated_prb_list}         0,3|5,35|49,3
@{nrcel_profile_id}              1    2
&{delta}                         sCellActivationMethod=blind    sCellDeactivationTimerGNB=infinity
@{logical_cell_list}             1    2


*** Test Cases ***
CB008983_C_WithDSS_Phase3_SANSA_10Mhz_FDD_TDD_n8_N78_100Mhz_CA_Blind_Addition_Buffer_and_RLQ_based_Activation
    [Documentation]    Attach NSA and SA with DSS enable and validate traffic with blind scell addition and buffer RLQ scell activation
    [Tags]    AP_REG    TC1_DSS
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


CB008983_C_WithDSS_Phase3_SANSA_10Mhz_FDD_TDD_n8_N78_100Mhz_CA_Blind_Addition_Blind_Activation
    [Documentation]    Attach NSA and SA with DSS enable and validate traffic with blind scell addition and blind scell activation
    [Tags]    AP_REG    TC2_DSS
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
