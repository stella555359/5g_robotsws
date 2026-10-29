*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Resource    ./1086_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC001086
Suite Teardown    Suite Teardown

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       10
${ul_tput}                       10
@{Non_CA_SA_UE_List}             1
@{Non_CA_NSA_UE_List}            11
@{NSA_UE_ID}                     11
${bsr_file_name}                 BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip


*** Test Cases ***
5GC001086_TC1_Enable_BeamSet6_SANSA_with SRSPort2_FIXED_location_1208_Frameformat
    [Documentation]    Enable BeamSet6 SANSA with SRSPort2 FIXED location 1208 Frameformat
    [Tags]    1086_TC1    P3_REG
    [Setup]    Test Setup    bsr_file_name=${bsr_file_name}
    Perform set SRS Beam profile mode and position    ue_list=${Non_CA_SA_UE_List}    init_pos=0
    ...    srsMode=fixed
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}
    Perform set SRS Beam profile mode and position    ue_list=${Non_CA_NSA_UE_List}    scell_index=8
    ...    init_pos=0   srsMode=fixed
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}    pdu=3
    Stop Traffic and Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List}
    [Teardown]    Simple Test Teardown    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List}

5GC001086_TC2_Enable_BeamSet6_SANSA_with SRSPort2_Oscillating_mode_1070_Frameformat
    [Documentation]    Enable BeamSet6 SANSA with SRSPort2 Oscillating_mode_1070 Frameformat
    [Tags]    AP_REG    1086_TC2
    [Setup]    Test Setup    bsr_file_name=${bsr_file_name}
    Perform set SRS Beam profile mode and position    ue_list=${Non_CA_SA_UE_List}    init_pos=2
    ...    step_count=50    srsMode=oscillating
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}
    Perform set SRS Beam profile mode and position    ue_list=${Non_CA_NSA_UE_List}    scell_index=8
    ...    init_pos=2    step_count=50    srsMode=oscillating
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}    pdu=3
    Stop Traffic and Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List}
    [Teardown]    Simple Test Teardown    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List}