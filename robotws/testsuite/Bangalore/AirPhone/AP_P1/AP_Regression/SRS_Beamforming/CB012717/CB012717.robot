*** Settings ***

Documentation     author: Athul Krishna
...               contact: vamsi.gundlur@nokia.com
...               Description: CB012717: 16DL8UL ULMUMIMO with SRS Beamforming

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB012717

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${TC_configs}                    ${CURDIR}/Config_Files
${ul_tput}                       110
@{SA_UE_List}                    1    2    41    42
${EDAEMON_PORT}                  50000
${bsr_file_name}                 BSR_AQQL_6_H3H3_ALN60_ARP60_P00_COVERAGE_00444_00001.zip

*** Test Cases ***
CB012717_TC1_SRS Beamforming with 16DL8UL config
    [Documentation]    SRS Beamforming with 16DL8UL config
    [Tags]    AP_REG    2717_TC1
    [Setup]    Generic Test Setup    feature=CB012717    custom_config=True    custom_config_folder=${TC_configs}
    ...    bsr_update=True    bsr_file_name=${bsr_file_name}    cell_deployment=SA
    UE Register and Start Traffic For SA Non CA Capable UEs    ${SA_UE_List}    ${ul_tput}
    Sleep    30s
    Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=1    profile_id=1    init_quad_pos=0
    ...    init_sub_quad_pos=0    test_type=UL_MIMO    mode=fixed
    Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=2    profile_id=2    init_quad_pos=2
    ...    init_sub_quad_pos=3    test_type=UL_MIMO    mode=fixed
    Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=41    profile_id=3    init_quad_pos=3
    ...    init_sub_quad_pos=3    test_type=UL_MIMO    mode=fixed
    Perform UL mimo SRS Beam profile mode and associate UE to testmode    ue_id=42    profile_id=4    init_quad_pos=1
    ...    init_sub_quad_pos=2    test_type=UL_MIMO    mode=fixed
    Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${ul_tput}
    ...    expected_ul_tput=${ul_tput}    scell=${SA_Scell_Index}
    Associate UE to testmode    id=1    testmode=ul_mimo_srs_beam_pos    profile_id=1    action=deactivate
    Associate UE to testmode    id=2    testmode=ul_mimo_srs_beam_pos    profile_id=2    action=deactivate
    Associate UE to testmode    id=41    testmode=ul_mimo_srs_beam_pos    profile_id=3    action=deactivate
    Associate UE to testmode    id=42    testmode=ul_mimo_srs_beam_pos    profile_id=4    action=deactivate
    Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${ul_tput}
    ...    expected_ul_tput=${ul_tput}    scell=${SA_Scell_Index}
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=3
    [Teardown]    Simple Test Teardown    ${SA_UE_List}
