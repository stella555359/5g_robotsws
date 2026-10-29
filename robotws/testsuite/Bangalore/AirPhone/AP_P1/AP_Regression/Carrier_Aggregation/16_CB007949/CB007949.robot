*** Settings ***
Documentation     author: Bhanu Vamsi
...               contact: vamsi.gundlur@nokia.com
...               Description:

Resource    ./CB007949_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB007949

*** Variables ***
${NUMBER_OF_CELLS}               3
@{dl_tput_list}                  150    150    150    150    150    150
@{multi_dl_tput}                 90
${ul_tput}                       100
${tc2_ul_tput}                   50
${multi_ul_tput}                 10
@{Single_CA_SA_UE_List}          1
@{Multi_CA_SA_UE_List}           1    2    3    4    5    6    7    8    9    10
${3cc_TC1}                       ${CURDIR}/../Config_Files/16_CB007949/TC1
${3cc_TC2}                       ${CURDIR}/../Config_Files/16_CB007949/TC2
${3cc_TC3}                       ${CURDIR}/../Config_Files/16_CB007949/TC3
${WTS_FILE}                      basic_setup.lua

*** Test Cases ***
CB007949-A_8DL4UL_Verify with SUE high traffic pcell scell traffic distribution with blind scell addition and blind scell activation
    [Tags]    AP_REG    CB007949_TC1
    [Setup]    Test Setup for 7949    dl_tput_list=${dl_tput_list}    custom_config_folder=${3cc_TC1}    edaemon_port=50000
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}
    ...    scell_index_list=${3CC_scell_index}    uplink_tput=${ul_tput}
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_index_list=${3CC_scell_index}
    Sleep    90
    Validate uplink and downlink cell throughput from UE stats and bearer stats for dl CA    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_SA_UE_List}    UL_Scell_Id=${ul_scell_id}    DL_Scell_Id=${3CC_cell_index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB007949-ET-B03_8DL4UL_Different frame structure TDD 3CCs CA conigured Pcell 1208 and scell with 1116 and 1070
    [Tags]    AP_REG    CB007949_TC2
    [Setup]    Test Setup for 7949    dl_tput_list=${dl_tput_list}    custom_config_folder=${3cc_TC2}    ul_tput=${tc2_ul_tput}
    ...    edaemon_port=50000
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation for 3CC    ${Single_CA_SA_UE_List}
    Start parallel traffic for all SA UEs    ${Single_CA_SA_UE_List}    ${dl_tput_list}    ${ul_tput}
    Wait Until Keyword Succeeds    1 min    30sec
    ...    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_index_list=${3CC_scell_index}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for dl CA    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_SA_UE_List}    UL_Scell_Id=${ul_scell_id}    DL_Scell_Id=${3CC_cell_index}
    Stop traffic for UEs    ca_sa_ue_list=${Single_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_list=${3CC_scell_index}
    Detach SA UEs    ${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB007949-A_4DL4UL_Verify_with_MUE_10UEs_per_Cell_10Mbps_DL_10Mbps_UL_per_UE_with_blind_scell_addition_and_blind_scell_activation
    [Tags]    AP_REG    CB007949_TC3
    [Setup]    Test Setup for 7949    dl_tput_list=${multi_dl_tput}    custom_config_folder=${3cc_TC3}    ul_tput=${multi_ul_tput}
    ...    edaemon_port=50000
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation for 3CC    ${Multi_CA_SA_UE_List}
    Verify scell activated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}    scell_index_list=${3CC_scell_index}
    Start parallel traffic for all SA UEs    ${Multi_CA_SA_UE_List}    ${dl_tput_list}    ${ul_tput}
    Wait Until Keyword Succeeds    5 min    30sec
    ...    Validate uplink and downlink cell throughput from UE stats and bearer stats for dl CA    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Multi_CA_SA_UE_List}    UL_Scell_Id=${ul_scell_id}    DL_Scell_Id=${3CC_cell_index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Multi_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${Multi_CA_SA_UE_List}