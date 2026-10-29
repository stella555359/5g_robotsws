*** Settings ***
Documentation     author: Bhanu Vamsi
...               contact: vamsi.gundlur@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC002640

*** Variables ***
@{dl_tput_list}                  175    175    175    175    175    175
@{tc2_dl_tput}                   150    150    150
@{tc3_dl_tput}                   150    150    150    150
${ul_tput}                       50
${tc3_ul_tput}                   10
@{cell_list}                     1    2
@{dsscells}                      3    4
@{TC3_cell_list}                 1
@{TC3_dsscells}                  3
@{Single_CA_SA_UE_List}          1
@{SA_Scell_Index}                1    2
@{cell_index}                    0    1    2
${csi_scell_index}               0,1,2
@{UL_Scell_Index}                0
@{logical_cell_list}             1    2    3    4
@{Counter_List}                  M55138C03001    M55138C03002    M55139C03001    M55139C03002    M55118C09502    M55118C09503    M55118C09501
${TC1_configs}                   ${CURDIR}/../../Config_Files/29_5GC002640/TC1
${TC2_configs}                   ${CURDIR}/../../Config_Files/29_5GC002640/TC2
${TC3_configs}                   ${CURDIR}/../../Config_Files/29_5GC002640/TC3
${TC3_dl_norsubframes}           0011101000-0111101110-0011101000-0111101110-0011101000-0111101110-0011101000-0111101110
${TC3_ul_allocated_prb_list}     11,35
${TC3_reservefix_subframes}      1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001

*** Test Cases ***
5GC002640_F_26_B1_3_F_T_T_Single_UE_call_3CC_CA_interworking with DSSp3
    [Documentation]    Carrier aggregation up to 3CC interworking with DSS phase 3 having fdd as primary cell and TDD as two secondary cells
    [Tags]    AP_REG    2640_TC1
    [Setup]    Test setup for DSS    ${cell_list}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=5GC002640    superfast=True    ip_del=True
    ...    target_cell=${dsscells}    custom_config_folder=${TC1_configs}    custom_config=True
    Common Test steps for 5GC002640
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

5GC002640_F_26_B1_3_F_F_T_Single_UE_call_3CC_CA_interworking_with_DSSp3
    [Documentation]    Carrier aggregation up to 3CC interworking with DSS phase 3 having fdd as primary cell and a FDD,TDD as two secondary cells
    [Tags]    AP_REG    2640_TC2
    [Setup]    Test setup for DSS    ${cell_list}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=5GC002640    ip_del=True    custom_config=True
    ...    target_cell=${dsscells}    custom_config_folder=${TC2_configs}    dl_tput_list=${tc2_dl_tput}
    Common Test steps for 5GC002640
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

5GC002640_TC_03_Buffer_based_Scell_Activ_DSS_PRB_blank_low_edge_UL_DL_6PRB_FDD_PCell
    [Documentation]    Carrier aggregation up to 3CC interworking with DSS phase 3 having fdd as primary cell and TDD as two secondary cells with
    ...    Blind scell addition and Buffer based scell activation, interworking DSS with PRB blank low edge UL DL 6PRB
    [Tags]    2640_TC3
    [Setup]    Test setup for DSS    ${TC3_cell_list}    ${WTS_FILE}    ${EDAEMON_PORT}    feature=5GC002640    ip_del=True    custom_config=True
    ...    target_cell=${TC3_dsscells}    custom_config_folder=${TC3_configs}    prb=False    superfast=True    dl_tput_list=${tc3_dl_tput}
    ...    dl_norsubframes=${TC3_dl_norsubframes}    ul_allocated_prb_list=${TC3_ul_allocated_prb_list}    Single_CA_SA_UE_List=${TC3_dsscells}
    ...    reservedfixed_norsubframes=${TC3_reservefix_subframes}    ul_tput=${tc3_ul_tput}
    Common Test steps for 5GC002640
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

*** Keywords ***
Common Test steps for 5GC002640
    [Documentation]    Common test steps for above test cases
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_SA_UE_List}
    ...    scell_index_list=${SA_Scell_Index}    csi_scell_index=${csi_scell_index}    4CC=True
    Start parallel traffic for all SA UEs    ${Single_CA_SA_UE_List}
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_index_list=${SA_Scell_Index}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    dl_scell=${cell_index}    ul_scell=${UL_Scell_Index}
    Stop traffic for UEs    ca_sa_ue_list=${Single_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_list=${SA_Scell_Index}
    Detach SA UEs    ${Single_CA_SA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${Single_CA_SA_UE_List}
