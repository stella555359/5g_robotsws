*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description: Testing CB009514J_CB008305 with SRS Beam

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB009514J_CB008305

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       150
${ul_tput}                       10
@{Non_CA_SA_UE_List}             1    2
@{logical_cell_list}             1
${EDAEMON_PORT}                  50000
${NUMBER_OF_CELLS}               1
${REPETITIONS}                   2

*** Test Cases ***
CB009514J_CB008305_Verify Lock Unlock for SRS beam scenario in 7.2e
    [Documentation]    Verify Cell Lock and Unlock with SRS beam
    [Tags]    AP_REG    CB008305_TC1
    [Setup]    Generic Test Setup    feature=CB009514J_CB008305    cell_deployment=SA    syslog_err_count=41
    FOR    ${index}    IN RANGE    2
        Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=1    profile_id=1    init_quad_pos=0
        ...    init_sub_quad_pos=0    test_type=UL_MIMO    mode=fixed
        Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=2    profile_id=2    init_quad_pos=1
        ...    init_sub_quad_pos=1    test_type=UL_MIMO    mode=fixed
        Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${dl_tput}
        Sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${Non_CA_SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
        Run Keyword If    '${index}' == '0'    Perform NR Cell Lock and Unlock
    END
    [Teardown]    Simple Test Teardown    ${Non_CA_SA_UE_List}

CB009514J_CB008305_Verify Cell delete and setup for SRS beam scenario in 7.2e via dlMimoMode
    [Documentation]    Verify Cell delete and setup with SRS beam via dlMimoMode
    [Tags]    AP_REG    CB008305_TC2    P3_REG
    [Setup]    Generic Test Setup    feature=CB009514J_CB008305    cell_deployment=SA    syslog_err_count=119
    FOR    ${index}    IN RANGE    ${REPETITIONS}
        Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=1    profile_id=1    init_quad_pos=0
        ...    init_sub_quad_pos=0    test_type=UL_MIMO    mode=fixed
        Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=2    profile_id=2    init_quad_pos=1
        ...    init_sub_quad_pos=1    test_type=UL_MIMO    mode=fixed
        Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${dl_tput}
        Sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${Non_CA_SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
        Run Keyword If    int(${index}) <= int(${REPETITIONS} - 2)    Perform Cell delete and setup via dlMimoMode    ${NUMBER_OF_CELLS}    ${index}
    END
    [Teardown]    Simple Test Teardown    ${Non_CA_SA_UE_List}
