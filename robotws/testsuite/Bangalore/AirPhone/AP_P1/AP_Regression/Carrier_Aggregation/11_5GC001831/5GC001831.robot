*** Settings ***
Documentation     author: Bhanu Vamsi Krishna
...               contact: vamsi.gundlur@nokia.com
...               Description:

Resource    ./5GC001831_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC001831

*** Variables ***
@{dl_tput_list}                  150    150    150    150
@{dl_Htput_list}                 175    175    175    175    100
@{multi_dl_tput}                 100    80
${CA_UL_tput}                    150
${multi_CA_UL_tput}              35
@{Single_CA_NSA_UE_List}         11
@{Multi_CA_NSA_UE_List}          11    12    13    14
@{logical_cell_list}             1    2    3    4
@{NRREL_list}                    1    2    3    4
@{UL_Scell_index}                8    9
${4cc_mue_configs}               ${CURDIR}/../Config_Files/15_5GC001831/TC9
${4cc_sue_configs}               ${CURDIR}/../Config_Files/15_5GC001831/TC15

*** Test Cases ***
5GC001831_TC9_MUE FR2 Intra band[Bn257] Contigious DL_4CC_UL_2CC symmetric CA with beam Forming enabled with beamset 32_A
    [Tags]    AP_REG    5GC001831_TC9
    [Setup]    Test Setup for 1831    dl_tput_list=${multi_dl_tput}    custom_config_folder=${4cc_mue_configs}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Multi_CA_NSA_UE_List}    target_cells=1
    ...    uplink_tput=${multi_CA_UL_tput}
    Sleep    90
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${multi_CA_UL_tput}    UE_List=${Multi_CA_NSA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Multi_CA_NSA_UE_List}
    [Teardown]    Test Teardown    nsa_ue_list=${Multi_CA_NSA_UE_List}

5GC001831_TC15_Verify Peak data rate for FR2 Intra band[Bn260] Contigious DL_4CC Asymetric CA CA beam Forming enabled with beamset 32_A
    [Tags]    AP_REG    5GC001831_TC15
    [Setup]    Test Setup for 1831    dl_tput_list=${dl_Htput_list}    custom_config_folder=${4cc_sue_configs}
    FOR    ${index}    IN RANGE    2
        Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}    target_cells=1
        ...    uplink_tput=${CA_UL_tput}
        Sleep    90
        Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
        ...    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}
        ...    DL_Scell_Id=${4CC_NSA_cell_Index}
        Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
        sleep    20
    END
    [Teardown]    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}
