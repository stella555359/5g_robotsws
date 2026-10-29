*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/ue_operations.robot

Suite Setup       Common Suite Setup    feature_folder=5GC000534

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       10
${ul_tput}                       10
@{Non_CA_SA_UE_List}             1    2    3    4    5    6    7    8
@{switch_profile_list}           5    6    7    8    1    2    3    4
@{recovery_profile_list}         8    7    6    5    4    3    2    1

*** Test Cases ***
5GC000534_TC1_Verify_Beam_Attach of 8 SA UEs to 8 beams followed by Beam Switch and then Beam Recovery to different beams
    [Documentation]    Verify successful Beam Attach of 8 SA UEs to 8 different beams followed by Beam Switch to different beams
    ...    and then Beam Recovery to different beams with beamset_8 configured
    [Tags]    AP_REG    0534_TC1
    [Setup]    Generic Test Setup    feature=5GC000534
    Perform Beam control profile mode and associate UE to testmode    ue_id=1    profile_id=1    ssbeam_bestbeam=0
    ...    ueBeamIndexInitial=0,1,2,3,4,5,6,7    ssbeam_rsrp_best=-44    ssbeam_rsrp_avg=-50
    Perform Beam control profile mode and associate UE to testmode    ue_id=2    profile_id=2    ssbeam_bestbeam=1
    ...    ueBeamIndexInitial=1,0,2,3,4,5,6,7    ssbeam_rsrp_best=-45    ssbeam_rsrp_avg=-120
    Perform Beam control profile mode and associate UE to testmode    ue_id=3    profile_id=3    ssbeam_bestbeam=2
    ...    ueBeamIndexInitial=2,0,1,3,4,5,6,7    ssbeam_rsrp_best=-50    ssbeam_rsrp_avg=-125
    Perform Beam control profile mode and associate UE to testmode    ue_id=4    profile_id=4    ssbeam_bestbeam=3
    ...    ueBeamIndexInitial=3,0,1,2,4,5,6,7    ssbeam_rsrp_best=-55    ssbeam_rsrp_avg=-120
    Perform Beam control profile mode and associate UE to testmode    ue_id=5    profile_id=5    ssbeam_bestbeam=4
    ...    ueBeamIndexInitial=4,0,1,2,3,5,6,7    ssbeam_rsrp_best=-60    ssbeam_rsrp_avg=-139
    Perform Beam control profile mode and associate UE to testmode    ue_id=6    profile_id=6    ssbeam_bestbeam=5
    ...    ueBeamIndexInitial=5,0,1,2,3,4,6,7    ssbeam_rsrp_best=-65    ssbeam_rsrp_avg=-70
    Perform Beam control profile mode and associate UE to testmode    ue_id=7    profile_id=7    ssbeam_bestbeam=6
    ...    ueBeamIndexInitial=6,0,1,2,3,4,5,7    ssbeam_rsrp_best=-46    ssbeam_rsrp_avg=-100
    Perform Beam control profile mode and associate UE to testmode    ue_id=8    profile_id=8    ssbeam_bestbeam=7
    ...    ueBeamIndexInitial=7,0,1,2,3,4,5,6    ssbeam_rsrp_best=-48    ssbeam_rsrp_avg=-100
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${Non_CA_SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Perform Beam action switch    ue_list=${Non_CA_SA_UE_List}    switch_profile_list=${switch_profile_list}
    Perform Beam action recovery    ue_list=${Non_CA_SA_UE_List}    recovery_profile_list=${recovery_profile_list}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${Non_CA_SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${Non_CA_SA_UE_List}
    [Teardown]    Simple Test Teardown    ${Non_CA_SA_UE_List}