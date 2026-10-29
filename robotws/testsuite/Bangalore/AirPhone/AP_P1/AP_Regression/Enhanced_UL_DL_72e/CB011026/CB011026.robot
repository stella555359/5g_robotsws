*** Settings ***
Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB011026

*** Variables ***
${WTS_FILE}                      basic_setup.cfg
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       100
${ul_tput}                       10
@{Non_CA_SA_UE_List}             1    2    3    4    5    6    7    8    9    10
${bsr_file_name}                 BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
&{delta}                         actDlSrsBm=false    actUlSrsBm=false
@{logical_cell_list}             1

*** Test Cases ***
CB011026_TC1_Validate_FH_Cplane_message_fragmentation_aggregation_DL_UL_periodic_SRS__multi_UEs
    [Documentation]    Validate the FH C-plane message fragmentation and aggregation for DL, UL and periodic SRS in multiple
    ...    cells/carriers with multiple UEs/Resources
    [Tags]    AP_REG    11026_TC1
    [Setup]    Generic Test Setup    feature=CB011026    bsr_update=True    bsr_file_name=${bsr_file_name}    cell_deployment=SA
    ...        syslog_err_count=100
    Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${Non_CA_SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${Non_CA_SA_UE_List}
    [Teardown]    Run keywords    Delete BSR File    bsr_file_name=${bsr_file_name}    AND    Simple Test Teardown    ${Non_CA_SA_UE_List}

CB011026_TC2_Validate_FH_Cplane_message_fragmentation_aggregation_DL_UL_aperiodic_SRS_multi_UEs
    [Documentation]    Validate the FH C-plane message fragmentation and aggregation for DL, UL and aperiodic SRS in multiple
    ...    cells/carriers with multiple UEs/Resources
    [Tags]    AP_REG    11026_TC2
    [Setup]    Generic Test Setup    feature=CB011026    bsr_update=True    bsr_file_name=${bsr_file_name}    cell_deployment=SA
    ...    scf_update=True    delta=${delta}    logical_cell_list=@{logical_cell_list}    syslog_err_count=97
    Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${Non_CA_SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${Non_CA_SA_UE_List}
    [Teardown]    Run keywords    Delete BSR File    bsr_file_name=${bsr_file_name}    AND    Simple Test Teardown    ${Non_CA_SA_UE_List}

*** Keywords ***
Get Delta for CB011026
    [Arguments]    &{kwargs}
    Get bts distname
    ${actDlSrsBm}    Pop From Dictionary    ${kwargs}    actDlSrsBm
    ${actUlSrsBm}    Pop From Dictionary    ${kwargs}    actUlSrsBm
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}
    ...    actDlSrsBm=${actDlSrsBm}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}
    ...    actUlSrsBm=${actUlSrsBm}