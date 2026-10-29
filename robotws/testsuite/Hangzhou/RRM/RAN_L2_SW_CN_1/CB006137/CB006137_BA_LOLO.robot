*** Settings ***
Resource    ./CB006137_resource.robot
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource          ./resources/CB006137_BC_resource.robot
Suite Setup    Common Suite Setup
Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00    CN1_SG09_SM2    RAN_5G    RAN_5G_TDD    CRT

*** Variables ***
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${Egatelog_path}    ${CURDIR}
${LOCAL_IPHY_DIR}    ${CURDIR}/config
${SCF_DIR}    ${CURDIR}/config
#${6137_BOO_SCF}    ${SCF_DIR}/SCF_BOO_5cell-BA.xml
${6137_LO_SCF}    ${SCF_DIR}/SCF_LO_5cell-BA.xml
${6137_LO_10M_N66_60M_N77_SCF_2}    ${SCF_DIR}/SCF_LO_5cell_2.xml
${WTS_CFG_10M_N66_60M_N77}    wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_FS_2T3F.cfg
${WTS_CFG_10M_N66_60M_N77_B06}    basic_setup_BA_06.cfg
#${IPHY_10M_N66_60M_N77_2}    iphy_10M_N66_60M_N77_2.xml
${IPHY_10M_N66_60M_N77_2_LOLO}    iphy_10M_N66_60M_N77_2_LOLO.xml
#${IPHY_4CC}    iphy_10M_N66_60M_N77.xml
${IPHY_4CC}    iphy_10M_N66_60M_N77_LOLO.xml
${gnb_swconfig}    /home/ute/testline_init_results/configs/sm_swconfig.txt
${WTS_CFG_10M_N66_60M_N77_B40}    wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_N71N66N77N41.cfg
${WTS_CFG_10M_N66_N77_N41_B51}    wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_B51.cfg
${WTS_CFG_4CC}         wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_4CC.cfg
${WTS_CFG_3CC_B5}      wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_3CC_B5.cfg
${WTS_CFG_BA021}       wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_BA021.cfg
${WTS_CFG_BA027}       wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_BA027.cfg
${WTS_CFG_BA034}       wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_BA034.cfg
${WTS_CFG_MUE_B43}    wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_BA043.cfg
${WTS_CFG_10M_N66_N77_N41_BA57}    wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_N66N77N41BA57.cfg
${4CC_SCELLS}         ('1', '50', '71'), ('2', '60', '77'), ('3', '61', '41')
${4CC_SCELLS_2}       ('1', '51', '25'), ('2', '60', '77'), ('3', '61', '41')
${3CC_SCELLS_2F}      ('1', '50', '71'), ('2', '51', '25')
${3CC_SCELLS_2T}      ('3', '60', '77'), ('4', '61', '41')
${F+2T_SCELLS}        ('1', '60', '77'), ('2', '61', '41')
${F+T_SCELLS}         ('1', '61', '41')
${3F_SCELLS}          ('3', '50', '71'), ('4', '51', '25')
${4CC_SCELLS1}        ('1', '51', '25'), ('2', '60', '77'), ('3', '61', '41')
${2CC_SCELLS}         ('1', '61', '41')
${3CC_SCELLS1}        ('1', '51', '25'), ('2', '60', '77')
${DST_FOR_PCELL}    MRBTS-1/NRBTS-1/NRCELL-3
${STEP_PARA}    ueSplitPowerAdjStep 
${RATIO_PARA}    weightRatioOfUePwrScellVsPcell
${6137_BA_COMMON_RD}    0x58057F=16;0x58057a=3;0x10041=1;0x4B000F=1;0x58012d=4
#0x58057F rdFeatureFlagBitmap4; bitmap;0 - RIM.COMMON, 1- RIM.RI, 2- RIM.RI_SELECTOR, 3- RIM.RS, 4- UL.INTERBAND_CA.POWER_SPLIT
#0x58057a rdFeatureFlagBitmapLevel; enum;0 - VIP, 1 - ERROR, 2 - WARNING, 3 - INFO, 4 - DEBUG, 5 - INVALID
#0x10041 Output mode which devices prints are forwarded (0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid)
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
#CB006137-ET-BA003_Single_UE_UL_CA_Call_with_dynamic_UL_power_sharing_PCELL_and_SCELL_over_power_with_refinebeam
#    [Tags]    caseBA003    YueRong    Owner_Susie
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_60M_N77}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA003.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture Ttitrace For BA003
#    SA 5G Detach    ue_id=${UE_ID}
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/0/
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/0/
#    Check Initial Buffer And Power Split Info    ${TEST_LOG_DIRECTORY}/ttitrace/0/
#    Check Power Split Info After Scell Resume
#
#CB006137-ET-BA005_Single_UE_UL_CA_Call_with_dynamic_UL_power_sharing_PCELL_and_SCELL_over_power_state_change_with_refinebeam_and_2200
#    [Tags]    caseBA005    Owner_Juning
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_60M_N77}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA005.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture Log For BA005
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/00/
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/00/
#    Check Initial Buffer And Power Split Info    ${TEST_LOG_DIRECTORY}/initial/
#    Check Slot Not Scheduled    2    ${TEST_LOG_DIRECTORY}/03_01/
#    Check Slot Not Scheduled    7    ${TEST_LOG_DIRECTORY}/03_01/
#
#CB006137-ET-BA006_Single_UE_UL_CA_Call_with_dynamic_UL_power_sharing_buffer_stop_and_start
#    [Tags]    caseBA006    Owner_WangXin
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_10M_N66_60M_N77_SCF_2}    ${IPHY_10M_N66_60M_N77_2_LOLO}    ${WTS_CFG_10M_N66_60M_N77_B06}
#     ...    timerforreinit=5000
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77_B06}
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    SA 5G Attach    ue_id=3
#    SA Set Traffic Type To Internal    ue_id=3    pdu_id=3
#    SA 5G PDU Session Setup For A1 ScellAdd And ScellAct    ue_id=3
#    sleep    15s
#    Check UL On Target    3    0    1    170
#    Trigger PHR To GNB    profile_id=2    phr_start=20    ue_id=3    cell_id=1
#    sleep    5s
#    Start Ttitrace With Streaming Mode
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=3 pdu\=3 dir\=ul trf_id\=3
#    sleep    2s
#    Start SA Internal Traffic    ue_id=3    pdu_id=3    dir=ul    mbps=175    trf_id=3    seconds=6000
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/6
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/6
#    Check DynamicPowerSplit Stop By Gnb_syslog
#    Check Tti For Power    ${TEST_LOG_DIRECTORY}/ttitrace/6/

#CB006137-ET-BA021_SCell_selection_with_UL_CA_with_F1_F3_F4_F5_for_DL_4CC_CA_based_on_dlToUlContributionRatio_50
#    [Tags]    caseBA021    YueRong    Owner_YueRong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_BA021}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA021.xml
#    Delta Commission With SCF File    ${json_file}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_BA021}
#    L3 Call And Scell Change And Check For BA021
#    Log To Console    \nCheck counter...\n
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For BA021
#    SA 5G Detach    ue_id=${UE_ID}
#    Log To Console    \nCB006137_ET_BA021,the end.\n

#CB006137-ET-BA027_SCell_selection_considering_admission_control_dlToUlContributionRatio_50
#    [Tags]    caseBA027    YueRong    Owner_YueRong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_BA027}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA027.xml
#    Delta Commission With SCF File    ${json_file}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_BA027}
#    L3 Call And Scell Change And Check For BA027
#    Log To Console    \nCheck counter...\n
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For BA027
#    SA 5G Detach    ue_id=${UE_ID}
#    Log To Console    \nCB006137_ET_BA027,the end.\n

#CB006137-ET-BA034_SCell_selection_considering_admission_control_and_cell_load_dlToUlContributionRatio_20_4cc
#    [Tags]    caseBA034    Owner_lilidong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_BA034}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA034.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_BA034}
#    Multi UE Attach And Do UL DL Traffic    1    4    50    100
#    A1 Scell Addition And Check    ue_id=1    meas_id=1    srsrp_nr=115    scells_info=${4CC_SCELLS_2}
#    A1 Scell Addition And Check    ue_id=2    meas_id=1    srsrp_nr=115    scells_info=${4CC_SCELLS_2}
#    A1 Scell Addition And Check    ue_id=3    meas_id=1    srsrp_nr=115    scells_info=${4CC_SCELLS_2}
#    A1 Scell Addition And Check    ue_id=4    meas_id=1    srsrp_nr=115    scells_info=${4CC_SCELLS_2}
#    Sleep     10s
#    Check DL On Target For MultiUEBA034    1-4    0-3    350
#    Check UL On Target    1    0    2    20
#    Check UL On Target    2    0    3    20
#    Check UL On Target    3    0    2    20
#    Check UL On Target    4    0    3    20
#    #Check Counters
#    SA 5G Detach    ue_id=1-4

#CB006137-ET-BA035_A1_based_SCell_change_from_FDD_to_TDD
#    [Tags]    caseBA035    Owner_lilidong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_3CC_B5}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_3CC_B5}
#    Basic L3 Call and Traffic
#    A1 Scell Addition And Check    ue_id=${UE_ID}    meas_id=1    srsrp_nr=100    scells_info=${3CC_SCELLS_2F}
#    Sleep     5s
#    Check DL On Target    ${UE_ID}    0    1-2    175
#    Check UL On Target    ${UE_ID}    0    0    20
#    A1 Scell Addition And Check    ue_id=${UE_ID}    meas_id=4    srsrp_nr=120    scells_info=${3CC_SCELLS_2T}
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for ttitrace
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/035/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/035
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/035/
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/035/
#    Sleep     5s
#    Check DL On Target    ${UE_ID}    0    3-4    175
#    Check UL On Target    ${UE_ID}    0    3-4    50
#    #Check Counters
#    SA 5G Detach    ue_id=${UE_ID}

#CB006137-ET-BA036_A1_based_SCell_change_from_TDD_to_FDD
#    [Tags]    caseBA036    YueRong    Owner_YueRong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_3CC_B5}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA036.xml
#    Delta Commission With SCF File    ${json_file}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_3CC_B5}
#    L3 Call And Scell Change And Check For BA036
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For BA036
#    SA 5G Detach    ue_id=${UE_ID}

#CB006137-ET-BA039_A2_based_SCell_stepwise_release_4cc_Release_scell4
#    [Tags]    caseBA039    Owner_lilidong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_4CC}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA039.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_4CC}
#    Basic L3 Call and Traffic
#    A1 Scell Addition And Check    ue_id=${UE_ID}    meas_id=1    srsrp_nr=120    scells_info=${4CC_SCELLS}
#    Sleep     5s
#    Check DL On Target    ${UE_ID}    0    1-3    175
#    Check UL On Target    ${UE_ID}    0    1-2    50
#    A2 Scell Release And Check
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for ttitrace
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/039/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/039
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/039/
#    #Check Counters
#    SA 5G Detach    ue_id=${UE_ID}

#CB006137-ET-BA040_A2_based_SCell_stepwise_release_4cc_Release_scell5
#    [Tags]    caseBA040    Owner_WangXin
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_60M_N77_B40}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA040.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77_B40}
#    Basic L3 Call and Traffic
#    A1 Scell Addition And Check    ue_id=${UE_ID}    meas_id=1    srsrp_nr=120    scells_info=${4CC_SCELLS}
#    Sleep    5s
#    Check DL On Target    ${UE_ID}    0    1-3    175
#    Check UL On Target    ${UE_ID}    0    1-2    50
#    Trigger A2 Scell Release For TDD    ue_id=${UE_ID}    meas_id=4    scell_index=3    scell_rsrp=70
#    Check Scell Release Infos    scell_index=3
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for ttitrace
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/040/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/040
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/040/
#    SA 5G Detach    ue_id=${UE_ID}

#CB006137-ET-BA043_Multiple_UEs_call_setup_with_inter-band_FDD_FR1_TDD_with_reafinebeam
#    [Tags]    caseBA043    Owner_WangXin
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_MUE_B43}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA043.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_MUE_B43}
#    Multi UE Attach And Do UL DL Traffic    1    15    15    50
#    Check Target Tput For MUE    1    5    dl    0    1-31    100
#    Check Target Tput For MUE    1    5    ul    0    1-31    30
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for ttitrace
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/043
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/043
#    Check PCSI For MultiUE    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/043/
#    Check BeamReport For Pcell    ${TEST_LOG_DIRECTORY}/ttitrace/043/
#    #check counters

#CB006137-ET-BA046_Multiple_UEs_Call_with_dynamic_UL_power_sharing_without_beamforming
#    [Tags]    caseBA046    Owner_lilidong
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_60M_N77}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA046.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture Ttitrace For BA046    1    5    120    60    300    90
#    Check PCSI For MultiUE    count_rnti=5    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2/
#    SA 5G Detach    ue_id=1-5

#CB006137-ET-BA051_BWP_use_optimized_interworking_with_UL_CA_CELL4_DL_FULL_BWP_not_supported
#    [Tags]    caseBA051    Owner_AbbyWang
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_N77_N41_B51}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA051.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_N77_N41_B51}
#    Basic L3 Call and Traffic
#    A1 Scell Addition And Check    ue_id=${UE_ID}    meas_id=1    srsrp_nr=120    scells_info=${F+T_SCELLS}
#    Sleep     5s
#    Check DL On Target    ${UE_ID}    0    1    175
#    Check UL On Target    ${UE_ID}    0    0    20
#    Check LocationAndBandwidth From Egate Log
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For Large BWP Used in BA051
#    SA 5G Detach    ue_id=${UE_ID}

#CB006137-ET-BA057_BWP_use_optimized_interworking_with_UL_CA_CELL4_DL_large_BWP_and_UL_small_bwp_supported
#    [Tags]    caseBA057    Owner_Junying
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_N77_N41_BA57}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA057.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_N77_N41_BA57}
#    L3 Call and Capture Log For BA057
#    Check LocationAndBandwidth From Egate Log    12977
#    Check LocationAndBandwidth From Egate Log    36300
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/00/
    
CB006137-ET-BA069_DL_CA_features_up_to_DL_4CC_UL_2CC_SCell_activation_and_deactivation_UL_and_DL_with_F1_F3_F4_F5
    [Tags]    caseBA069    Owner_Juning
    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_4CC}
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_BA069.xml
    Delta Commission With SCF File    ${json_file}
    Reboot TL And Check Configured
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Reboot TL And Check Configured
    Start UTE WTS And Check Cell Setup    ${WTS_CFG_4CC}
    L3 Call And Capture Log For BA069
    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/00/
    Check PCSI For Each 3Cell    ${TEST_LOG_DIRECTORY}/01/
    #Check Scelldeactive Via Macce From Gnb_syslog    3

#CB006137-ET-BA075_Online_modification_of_ueSplitPowerAdjStep_and_weightRatioOfUePwrScellVsPcell
#    [Tags]    caseBA075    Susie    Owner_Susie
#    [Setup]    Setup TL For BA Each Case    ${6137_LO_SCF}    ${IPHY_4CC}    ${WTS_CFG_10M_N66_60M_N77}
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture Log For BA075
#    SA 5G Detach    ue_id=${UE_ID}
#    Check Adjustment Step    syslog0    5.011872
#    Check Adjustment Step    syslog2    10
#    Check Adjustment Step    syslog3    5.011872

*** Keywords ***
Common Suite Setup
    Suite Setup Update GNB    log=${False}
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Configure UTE ETH For GNB3
    #Send Swconfig for GNB    ${gnb_swconfig}

Setup TL For BA Each Case
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${onlyscellul}=false    ${timerforreinit}=100
    #Reboot TL And Check Configured
    Create Test Directory
    Set Test Variable    ${6137_BA_RD}    ${6137_BA_COMMON_RD};0x58063d=${timerforreinit}
    Add RD Parameters To GNB Swconfig File    ${6137_BA_RD}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    Full Commission With SCF File    ${scf_file}
    Sleep    120S    wait gnb and airphone all reboot avaliable.
    Reboot TL And Check Configured
    Set WTS Files Name For Each Cases    ${wts_cfg_name}

L3 Call And Capture Ttitrace For BA003
    [Arguments]    ${UE_ID}=1    ${dl_tp}=70    ${ul_tp1}=60    ${ul_tp_threshold}=50
    ...    ${duration}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    Start Ttitrace With Streaming Mode
    SA 5G PDU Session Setup For Blind ScellAdd And ScellAct    ue_id=${UE_ID}
    ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp1}    trf_id=1    seconds=3000
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0/
    Collect from savepoint  savepoint=${savepoint0}  destination_file=${TEST_LOG_DIRECTORY}/syslog0  alias=${GNB_SYSLOG.alias}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0/
    Sleep    60s    reason=Wait for traffic
    Check UL On Target    ${UE_ID}    0    1     ${ul_tp_threshold}  
    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Trigger PHR To GNB    profile_id=1    phr_start=0    cell_id=0
    Trigger PHR To GNB    profile_id=2    phr_start=0    cell_id=1
    Wait for message in syslog file  regexp=scellSuspend  timeout=60  alias=${GNB_SYSLOG.alias}
    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
    Sleep    30s    reason=Wait for process
    Check Scell UL TP Decreased    1    1    0
    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Recover Default PH Of Pcell And Scell
    Wait for message in syslog file  regexp=scellResume  timeout=60  alias=${GNB_SYSLOG.alias}
    Collect from savepoint  savepoint=${savepoint2}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
    Sleep    60s    reason=Wait for traffic
    Check UL On Target    ${UE_ID}    0    1    ${ul_tp_threshold}
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=ul trf_id\=1
    ute_wtssim.Execute Egate Command    cmd=sim_log_set flush    timeout=2s

Check Power Split Info After Scell Resume
    [Arguments]    ${log_name}=syslog2
    ${initial_power}    Set Variable    initial power local cell: 50.000000
    ${rst}    Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i "${initial_power}"|wc -l
    Should Be True    ${rst} == 1

L3 Call And Capture Log For BA005
    [Documentation]    L3 call procedure
    ...    00 Initial powersplit with traffic dl&ul,Initial split power case: 1
    ...    01 Pcellsuspend with changing phr,case 4
    ...    02 Pcellresume with decreasing ul traffic to 1M,Initial split power case: 2
    ...    03 Pcellsuspend again with increase ul traffic,case 4
    ...    04 Pcellresume again with changing phr.
    ...    the end!
    [Arguments]    ${UE_ID}=1    ${dl_tp}=70    ${ul_tp1}=1    ${ul_tp2}=80    ${dl_tp_threshold}=50    ${ul_tp_threshold}=50
    ...    ${duration}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    SA 5G PDU Session Setup For Blind ScellAdd And ScellAct    ue_id=${UE_ID}
    Teardown All Connections
    Start Ttitrace With Streaming Mode
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=3    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp1}    trf_id=1    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp2}    trf_id=2    seconds=3000
    ute_syslog.Wait For Message In Syslog File    regexp=Initial split power case    timeout=60    alias=${GNB_SYSLOG.alias}
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/initial/
    Sleep    5s    reason=Wait for traffic
    Check TP On Target    ${UE_ID}    0    1    ${dl_tp_threshold}    ${ul_tp_threshold}
    Sleep    ${duration}    reason=Wait for process
    Check TP On Target    ${UE_ID}    0    1    ${dl_tp_threshold}    ${ul_tp_threshold}
    Collect from savepoint  savepoint=${savepoint0}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
    Teardown All Connections
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=Wait for ttitrace
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/00/
    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Teardown All Connections
    Start Gnb BIP Log
    Trigger PHR To GNB    profile_id=1    phr_start=10
    Trigger PHR To GNB    profile_id=2    phr_start=25    cell_id=1
    ute_syslog.Wait For Message In Syslog File    regexp=pcellSuspend    timeout=20    alias=${GNB_SYSLOG.alias}
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/01/
    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
    sleep    30s    reason=seperater
    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Teardown All Connections
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=ul trf_id\=2    #decrease UL data
    ute_syslog.Wait For Message In Syslog File    regexp=pcellResume    timeout=60    alias=${GNB_SYSLOG.alias}
    Collect from savepoint  savepoint=${savepoint2}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
    sleep    30s    reason=seperater
    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Move File    ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz    ${TEST_LOG_DIRECTORY}/02/
    OperatingSystem.Move File    ${TEST_LOG_DIRECTORY}/AP_syslog.tar.gz    ${TEST_LOG_DIRECTORY}/02/
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    ${savepoint3} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Teardown All Connections
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp2}    trf_id=2    seconds=3000
    ute_syslog.Wait For Message In Syslog File    regexp=pcellSuspend    timeout=20    alias=${GNB_SYSLOG.alias}
    Start Ttitrace With Streaming Mode
    sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/03_01/
    Collect from savepoint  savepoint=${savepoint3}  destination_file=${TEST_LOG_DIRECTORY}/syslog3  alias=${GNB_SYSLOG.alias}
    sleep    30s    reason=seperater
    ${savepoint4} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Teardown All Connections
    Trigger PHR To GNB    profile_id=2    phr_start=30    cell_id=1
    ute_syslog.Wait For Message In Syslog File    regexp=pcellResume    timeout=60    alias=${GNB_SYSLOG.alias}
    Collect from savepoint  savepoint=${savepoint4}  destination_file=${TEST_LOG_DIRECTORY}/syslog4  alias=${GNB_SYSLOG.alias}
    sleep    30s    reason=seperater
    Teardown All Connections
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=ul trf_id\=1
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=ul trf_id\=2
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=dl trf_id\=3
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=detached
    ute_wtssim.Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    Run Keyword And Ignore Error    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/initial
    Run Keyword And Ignore Error    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/00
    Run Keyword And Ignore Error    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/03_01/

Check PCSI For MultiUE
    [Arguments]    ${log_dir}    ${count_rnti}=15
    ${value}    Read Csv Columns    ${log_dir}/output_ul.csv    rnti    filter=csiSrReportData.reportType=PERIODIC_CSI
    ${list}     Evaluate      list(set(${value}))
    ${new}    Create List
    :FOR   ${value}    IN     @{list}
    \     Run Keyword If     '${value}'!='0' and '${value}'!='65535'   Append To List    ${new}   ${value}
    Log     ${new}
    ${len}    Get Length    ${new}
    Should Be True  ${len}==${count_rnti}

Check BeamReport For Pcell
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_43_a.ini    output_dl.csv    ${csv_file_path}

L3 Call And Scell Change And Check For BA021
    Basic L3 Call and Traffic
    Sleep    5s    reason=Wait for traffic
    Log To Console    \nAdd 2 scells(F),1F+2T...\n
    Trigger A1 Scell Addition    ${UE_ID}    1    100
    Log To Console    \nCheck UE is configured 3CC,3F\n
    Save Egate Log    log_path=${Egatelog_path}
    Get And Check Scell Infos    ${3CC_SCELLS_2F}
    Sleep    5s    reason=Wait for traffic
    Check DL On Target    ${UE_ID}    0    1-2    100
    Check UL On Target    ${UE_ID}    0    0    20
    SA 5G Detach    ue_id=${UE_ID}
    Sleep    5s
    Basic L3 Call and Traffic
    Sleep    5s    reason=Wait for traffic
    Log To Console    \nCheck UE is configured 1F+2T \n
    Trigger A1 Scell Addition    ${UE_ID}    1    120
    Log To Console    \nCheck scell change activated successfully,Ue is configured 4cc...\n
    Save Egate Log    log_path=${Egatelog_path}
    Get And Check Scell Infos    ${4CC_SCELLS1}
    Sleep    5s    reason=Wait for traffic
    Check DL On Target    ${UE_ID}    0    1-23   100
    Check UL On Target    ${UE_ID}    0    0    20

L3 Call And Scell Change And Check For BA027
    Basic L3 Call and Traffic    ue_id=1    ul_tp=50    dl_tp=100
    Sleep    5s    reason=Wait for traffic
    Log To Console    \nAdd 2 scells(F),1F+2T...\n
    Trigger A1 Scell Addition    ${UE_ID}    1    120
    Log To Console    \nCheck UE is configured 2CC,\n
    Save Egate Log    log_path=${Egatelog_path}
    Get And Check Scell Infos    ${2CC_SCELLS}
    Sleep    5s    reason=Wait for traffic
    Check DL On Target    ${UE_ID}    0    1    100
    Check UL On Target    ${UE_ID}    0    1    20
    Sleep    5s
    Basic L3 Call and Traffic    ue_id=2    ul_tp=50    dl_tp=100
    Sleep    5s    reason=Wait for traffic
    Log To Console    \nCheck UE is configured 1F+2T \n
    Trigger A1 Scell Addition    2    1    120
    Log To Console    \nCheck scell change activated successfully,Ue is configured 4cc...\n
    Save Egate Log    log_path=${Egatelog_path}
    Get And Check Scell Infos    ${3CC_SCELLS1}
    Sleep    5s    reason=Wait for traffic
    Check DL On Target    2    0    1-23   100
    Check UL On Target    2    0    0    20

L3 Call And Scell Change And Check For BA036
    [Arguments]    ${ueId}=1
    Basic L3 Call and Traffic
    Sleep    5s    reason=Wait for traffic

    Log To Console    \nAdd 2 scells(F),1F+2T...\n
    Trigger A1 Scell Addition    ${UE_ID}    1    100
    Get And Check Scell Infos    ${F+2T_SCELLS}
    Sleep    5s    reason=Wait for traffic
    Check DL On Target    ${UE_ID}    0    1-2    175
    Check UL On Target    ${UE_ID}    0    1-2    50

    Log To Console    \nScell change form 1F+2T to 3F\n
    Trigger A1 Scell Addition    ${UE_ID}    4    120
    Get And Check Scell Infos    ${3F_SCELLS}
    Sleep    5s    reason=Wait for traffic
    Check DL On Target    ${UE_ID}    0    3-4    175
    Check UL On Target    ${UE_ID}    0    3-4    20

L3 Call And Capture Ttitrace For BA046
    [Arguments]    ${start_ue_num}    ${end_ue_num}    ${dl_tp}    ${ul_tp}    ${dl_tp_threshold}    ${ul_tp_threshold}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    SA 5G Attach    ue_id=${UE_ID}
    Sleep    2s
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Sleep    2s    Reason=wait for PDU session completed
    END
    Log To Console    Initial Power Split...
    ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Start SA Internal Traffic    ue_id=${start_ue_num}-${end_ue_num}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1    seconds=3000
    Start SA Internal Traffic    ue_id=${start_ue_num}-${end_ue_num}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=1    seconds=3000
    Collect from savepoint  savepoint=${savepoint0}  destination_file=${TEST_LOG_DIRECTORY}/syslog0  alias=${GNB_SYSLOG.alias}
    Sleep    60s    reason=Wait for traffic
    Check Target Tput For MUE    1    5    dl    0    1-31    ${dl_tp_threshold}
    Check Target Tput For MUE    1    5    ul    0    1-31    ${ul_tp_threshold}
    Log To Console    Change PHR Until Pcell Suspend...

    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    Trigger PHR To GNB    profile_id=1    phr_start=0    ue_id=${UE_ID}    cell_id=0
    Trigger PHR To GNB    profile_id=2    phr_start=15    ue_id=${UE_ID}    cell_id=1
    Sleep    5s
    END
    Wait for message in syslog file  regexp=pcellSuspend  timeout=60  alias=${GNB_SYSLOG.alias}
    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
    Sleep    30s    reason=Wait for process
    Check Target Tput For MUE    1    5    dl    0    1-31    ${dl_tp_threshold}
    ${ul_tp_threshold_2}    evaluate    ${ul_tp_threshold}-5
    Check Target Tput For MUE    1    5    ul    0    1-31    ${ul_tp_threshold_2}

    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    Recover Default PH Of Pcell And Scell    ue_id=${UE_ID}
    Sleep    5s
    END
    Wait for message in syslog file  regexp=pcellResume  timeout=60  alias=${GNB_SYSLOG.alias}
    Collect from savepoint  savepoint=${savepoint2}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
    Sleep    30s    reason=Wait for process
    Check Target Tput For MUE    1    5    dl    0    1-31    ${dl_tp_threshold}
    Check Target Tput For MUE    1    5    ul    0    1-31    ${ul_tp_threshold}

    Start Ttitrace With Streaming Mode
    Sleep    1s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2/
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2/
    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/

L3 Call and Capture Log For BA057
    [Arguments]    ${ue_id}=${UE_ID}    ${ul_tp}=100    ${dl_tp}=175
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${ue_id}
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=1    seconds=3000
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=2    seconds=3000
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1    seconds=3000
    A1 Scell Addition And Check    ue_id=${UE_ID}    meas_id=1    srsrp_nr=120    scells_info=${F+2T_SCELLS}
    Sleep    10s    reason=Wait for A1 scelladdition
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=Wait for capture ttitrace
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/00/
    Check DL On Target    ${UE_ID}    0    1    165
    Check UL On Target    ${UE_ID}    0    1    20
    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For Small BWP Used in BA057
    SA 5G Detach    ue_id=${UE_ID}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/00/

L3 Call And Capture Log For BA069
    [Arguments]    ${UE_ID}=1
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Trigger A1 Scell Addition    1    1    120
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=ul    mbps=50    trf_id=1    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=50    trf_id=1    seconds=3000
    Sleep    10s    reason=Wait for traffic
    Check UL On Target    1    0    3    30
    Check DL On Target    1    0    3    40
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=Wait for ttitrace to check pcsi
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/00/

    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=175    trf_id=1    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=175    trf_id=2    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=175    trf_id=3    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=175    trf_id=4    seconds=3000
    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=175    trf_id=5    seconds=3000
    Sleep    10s    reason=Wait for traffic
    Wait Until Keyword Succeeds    5min    1min    Check DL 3 Scells On Target
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=Wait for ttitrace to check pcsi
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/01/

    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=ul trf_id\=1
    Sleep    40s    reason=Wait for traffic
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${UE_ID}    ul    pcell    0
    ${scell_ulTP}    Get CA Cell Average Throughput    ${UE_ID}    ul    scell    3
    Sleep    10s
    Should Be True    ${scell_ulTP}==0
    Log To Console    \n Check there is no scell deactitivated\n    console=True
    Wait Until Keyword Succeeds    5min    1min    Check DL 3 Scells On Target
    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}/syslogpart1/
    OperatingSystem.Run    mv /opt/iphy/latest/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-before.log
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=dl trf_id\=5
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=dl trf_id\=4
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu\=1 dir\=dl mbps\=151 trf_id\=3
    ${trf_id3mbps} =   Set Variable    141
    FOR    ${id}    IN RANGE    1    16
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu\=1 dir\=dl mbps\=${trf_id3mbps} trf_id\=3
        ${trf_id3mbps} =    Evaluate    ${trf_id3mbps} - 10
        Sleep    2s
    END
    ${trf_id2mbps} =   Set Variable    171
    FOR    ${id}    IN RANGE    1    19
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu\=1 dir\=dl mbps\=${trf_id2mbps} trf_id\=2
        ${trf_id2mbps} =    Evaluate    ${trf_id2mbps} - 10
        Sleep    2s
    END
    ${trf_id1mbps} =   Set Variable    171
    FOR    ${id}    IN RANGE    1    19
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu\=1 dir\=dl mbps\=${trf_id1mbps} trf_id\=1
        ${trf_id1mbps} =    Evaluate    ${trf_id1mbps} - 10
        Sleep    2s
    END
    Verfiy Scells Are Deactivation    4
    Teardown All Connections
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    BuiltIn.Log    \n Decode ttitrace \n    console=yes
    Run Keyword And Ignore Error    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/00
    Run Keyword And Ignore Error    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/01

Verfiy Scells Are Deactivation
    [Arguments]    ${scell_nums}
    Log To Console    \nverify Scell Deactivation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${scell_deactivation}    Set Variable    SCellIndex ${id} deactivated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log.001|grep -i "${scell_deactivation}"|wc -l
    Should Be True    ${check_rst}==1
    END

Clear PM Counter Reports
    ${cmd}    Set Variable    rm /tmp/PM.BTS*
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'
    Sleep    5s    reason=wait for handling

Check PM Counter For BA021
    [Documentation]    check counter
    ...    M55118C10005 is updated with P-Cell UEs with configured S-Cell in UL;
    ...    M55118C10006 is updated with S-Cell UEs with configured S-Cell in UL.
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10005
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10006
    Should Be True    ${rd_counter_value}==0

Check PM Counter For BA027
    [Documentation]    check counter
    ...    M55118C10005 is updated with P-Cell UEs with configured S-Cell in UL;
    ...    M55118C10006 is updated with S-Cell UEs with configured S-Cell in UL.
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10005
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10006
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10001
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10002
    Should Be True    ${rd_counter_value}>0

Check PM Counter For BA036
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C06506
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C06507
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10005
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C10006
    Should Be True    ${rd_counter_value}==0

Check PM Counter For Large BWP Used in BA051
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    1    NCADC    M55167C00001
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCADC    M55167C00003
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C04002
    Should Be True    ${rd_counter_value}>0

Check PM Counter For Small BWP Used in BA057
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    1    NCADC    M55167C00001
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCADC    M55167C00002
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C04001
    Should Be True    ${rd_counter_value}>0

Connect To GNB DU
    SSH.Connect To    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}    password=${GNB_ASIK.password}    alias=GNB-DU

Get PM File
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}/PMFile/CA
    Check PM File
    Get PM File To Local    ${log_path}

Check PM File
    Connect To GNB DU
    ${output}    SSH.Execute    ls -lrt /tmp/PM.BTS*|wc -l    connection=GNB-DU
    ${num}    Replace String   ${output}   \r\n   ${EMPTY}
    Should Be True    ${num}>=1
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU

Get PM File To Local
    [Arguments]    ${log_path}
    OperatingSystem.Run And Return Rc And Output    rm -rf ${log_path}/*
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/PM.BTS* ${log_path}
    OperatingSystem.Run And Return Rc And Output    gunzip ${log_path}/PM.BTS*.gz
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/RD.BTS* ${log_path}
    OperatingSystem.Run And Return Rc And Output    gunzip ${log_path}/RD.BTS*.gz

Get PM Counter Value From Xml
    [Arguments]    ${mode}    ${meas_type}    ${counter}    ${flag}=CA
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/${flag}/PM.BTS*.xml|grep ${counter}
    ${pcell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-3<\/DN><\/MO><NE-WBTS_1.0 measurementType="${meas_type}">
    ${count_var}    Set Variable    <${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${count_var2}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex} =    Run Keyword If    '${mode}' == '1'
    ...    Catenate    SEPARATOR=    ${pcell_var}    ${count_var}
    ...    ELSE    Catenate    SEPARATOR=    ${pcell_var}    ${count_var2}
    Log To Console    ${regex}
    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
    BuiltIn.Log    ${list}
    ${len}    Get Length    ${list}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${list}    ${id}
        LOG    ${counter_value}
        Exit Loop Based On Flag    ${counter_value}    ${flag}
    END
    Run Keyword And Ignore Error  SSH.Disconnect
    [Return]    ${counter_value}

Get PM Counter Value From Xml_RD
    [Arguments]    ${mode}    ${meas_type}    ${counter}    ${flag}=CA
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/CA/RD.BTS*.xml|grep ${counter}
    ${pcell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-3<\/DN><\/MO><NE-WBTS_1.0 measurementType="${meas_type}">
    ${count_var}    Set Variable    <${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${count_var2}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex} =    Run Keyword If    '${mode}' == '1'
    ...    Catenate    SEPARATOR=    ${pcell_var}    ${count_var}
    ...    ELSE    Catenate    SEPARATOR=    ${pcell_var}    ${count_var2}
    Log To Console    ${regex}
    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
    BuiltIn.Log    ${list}
    ${len}    Get Length    ${list}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${list}    ${id}
        LOG    ${counter_value}
        Exit Loop Based On Flag    ${counter_value}    ${flag}
    END
    Run Keyword And Ignore Error  SSH.Disconnect
    [Return]    ${counter_value}

Exit Loop Based On Flag
    [Arguments]    ${counter_value}    ${flag}=CA
    Run Keyword If    '${flag}' == 'CA'
    ...    Exit For Loop If    '${counter_value}'>'0'
    ...    ELSE    Exit For Loop If    '${counter_value}'=='0'

Check DynamicPowerSplit Stop By Gnb_syslog
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${TEST_LOG_DIRECTORY};tar -xzvf ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    Log    ${output}
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${count}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "DynamicPowerSplit stop power split timer for ue"|wc -l
    Should Be True    ${count}!=0

Trigger PHR To GNB
    [Arguments]    ${profile_id}    ${phr_start}    ${phr_min}=0    ${phr_max}=30    ${phr_step_size}=5
    ...    ${phr_period}=10    ${pc_max}=23    ${phr_mode}=Fixed    ${ue_id}=1    ${cell_id}=0
    Log To Console    start send Power Headroom Report to gnb...
    ${cmd1}    Catenate    phr_override_testmode_nr profile_id=${profile_id} phr_mode=${phr_mode} phr_start=${phr_start} 
    ...    phr_min=${phr_min} phr_max=${phr_max} phr_step_size=${phr_step_size} phr_period=${phr_period} pc_max=${pc_max}
    ute_wtssim.Execute Egate Command    ${cmd1}
    ${cmd2}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate
    ...     profile_id=${profile_id} scell=${cell_id}
    ute_wtssim.Execute Egate Command    ${cmd2}

Recover Default PH Of Pcell And Scell
    [Arguments]    ${ue_id}=1
    Trigger PHR To GNB    profile_id=1    phr_start=38    ue_id=${ue_id}    cell_id=0
    Trigger PHR To GNB    profile_id=2    phr_start=38    ue_id=${ue_id}    cell_id=1

Check Status By Gnb_syslog
    [Arguments]    ${status_info}
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${TEST_LOG_DIRECTORY};tar -xzvf ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    Log    ${output}
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${count}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i powerStateInfo|wc -l
    Should Be True    ${count}!=0
    ${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i powerStateInfo
    ${regexp}    Set Variable    powerStateInfo:(?P<powerStateInfo>\\S+)
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    powerStateInfo
    ${ret_str}=    Convert To String    ${ret}
    ${ret}=    String.Replace String Using Regexp    ${ret_str}    u    ${EMPTY}
    Log    ${ret}
    Should Contain    ${ret}    ${status_info}    

Check TP On Target
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}   ${target_ulsum_tp}
    Check UL On Target    ${ueId}    ${pcell_index}    ${scell_index}    ${target_ulsum_tp}
    Check DL On Target    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}

Check UL On Target
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_ulsum_tp}
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    Log To Console    Pcell's UL Troughput is ${pcell_ulTP}    console=True
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Log To Console    Scell's UL Troughput is ${scell_ulTP}    console=True
    ${ulsum_tp}    evaluate    ${pcell_ulTP}+${scell_ulTP}
    Log To Console    UL Troughput is ${ulsum_tp}    console=True
    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}

Check Tti For Power
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_6_a.ini    output_ul.csv    ${csv_file_path}

Check DL On Target
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
    Log To Console    Pcell's DL Troughput is ${pcell_dlTP}    console=True
    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    Log To Console    Scell's DL Troughput is ${scell_dlTP}    console=True
    ${dlsum_tp}    evaluate    ${pcell_dlTP}+${scell_dlTP}
    Log To Console    DL Troughput is ${dlsum_tp}    console=True
    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}

Check DL On Target For MultiUEBA034
    [Arguments]    ${ueId}    ${cell_index}    ${target_dlsum_tp}
    ${dlTP_UE1}    Get CA Cell Average Throughput    1    dl    All    ${cell_index}
    ${dlTP_UE2}    Get CA Cell Average Throughput    2    dl    All    ${cell_index}
    ${dlTP_UE3}    Get CA Cell Average Throughput    3    dl    All    ${cell_index}
    ${dlTP_UE4}    Get CA Cell Average Throughput    4    dl    All    ${cell_index}
    #Log To Console    cell's DL Troughput is ${pcell_dlTP}    console=True
    #${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    #Log To Console    Scell's DL Troughput is ${scell_dlTP}    console=True
    ${dlsum_tp}    evaluate    ${dlTP_UE1}+${dlTP_UE2}+${dlTP_UE3}+${dlTP_UE4}
    Log To Console    DL Troughput is ${dlsum_tp}    console=True
    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}

Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${cell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${cell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell_M}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTputM>\\d+.?\\d*)\\sMbps
#    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
#    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list_M}    String.Get Regexp Matches    ${output}    ${regexp_cell_M}    AvgTputM
    ${cell_tp_M}=    Evaluate    sum(map(float,${avg_tp_list_M}))
    ${regexp_cell_K}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTputK>\\d+.?\\d*)\\sKbps
    ${avg_tp_list_K}    String.Get Regexp Matches    ${output}    ${regexp_cell_K}    AvgTputK
    ${cell_tp_K}=    Evaluate    sum(map(float,${avg_tp_list_K}))
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp_K}/1000)
    ${cell_tp}    evaluate    ${cell_tp_M}+${Kbps_to_Mbps}
    ${cell_tput_Mbps}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    #${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    #${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    #Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    #${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    #${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    #${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    #...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    #...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Check Target Tput For MUE
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${dir}    ${pcell_index}    ${scell_index}    ${target_sum_tp}
    ${pcell_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    ${dir}    ${pcell_index}
    Log To Console    Pcell's ${dir} Troughput is ${pcell_TP}    console=True
    ${scell_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    ${dir}    ${scell_index}
    Log To Console    Scell's ${dir} Troughput is ${scell_TP}    console=True
    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    ${dir} Troughput is ${sum_tp}    console=True
    Should Be True    ${sum_tp}>=${target_sum_tp}

Check Scell UL TP Decreased
    [Arguments]    ${ueId}    ${scell_index}    ${target_ul_tp}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Log To Console    Scell's UL Troughput is ${scell_ulTP}    console=True
    Should Be True    ${scell_ulTP}<=${target_ul_tp}

SA 5G PDU Session Setup For Blind ScellAdd And ScellAct
    [Arguments]    ${ue_id}
    Log To Console    start 5G PDU Session Setup CA...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=SCellIndex 1 activated successfully    timeout=3minutes
    Log To Console    ${output}

SA 5G PDU Session Setup For A1 ScellAdd And ScellAct
    [Arguments]    ${ue_id}    ${ul_tp1}=5    ${ul_tp2}=175
    Log To Console    start 5G PDU Session Setup CA...
    ${command}    Set Variable    ue_pdu_session_setup pdu=3 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Context Setup Successful for UE    timeout=3minutes
    #${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
    ${command}    Set Variable    ue_measurement_send_nr id=3 meas_id=1 event=A1 srsrp_nr=100
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=3    dir=ul    mbps=${ul_tp1}    trf_id=1    seconds=6000
    ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=3 qfi=1 trf_id=3 mbps=${ul_tp2} dir=ul seconds=6000
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=SCellIndex 1 activated successfully at airphone    timeout=3minutes

Check PCSI For Each Cell
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcsi.ini    output_ul.csv    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcsi_dtx.ini    output_ul.csv    ${csv_file_path}

Check Initial Buffer And Power Split Info
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_initialPowerSplit.ini    output_ul.csv    ${csv_file_path}

Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=3
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}   

Configure UTE ETH For GNB3
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4

SA 5G PDU Session Setup For Blind ScellAdd And Bufferbased ScellAct
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Log To Console    start 5G PDU Session Setup CA...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    Log To Console    ${output}

SA Start UL Traffic Internal And Check Scell Activation
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1    ${seconds}=60
    Log To Console    start UL traffic...
    ${pattern}    Set Variable    SCellIndex 1 activated successfully
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
    ...    pass_regexp=${pattern}    timeout=5min

SA Stop Data Traffic Internal And Check Scell Deactivation
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Log To Console    start stop traffic...    
    ${pattern}    Set Variable    SCellIndex 1 deactivated successfully
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=bi
    ...    pass_regexp=${pattern}    timeout=5min

Check Scell Activation From BIP
    [Arguments]    ${id}=1    ${cell_nums}=2
    Log To Console  verify Scell activation from bip...
    ${filter}=    Catenate    mac-nr.dlsch.lcid == 0x3A
    @{csv_title_list}=    Create List    mac-nr.control.scell-act-deact.cell1    mac-nr.control.scell-act-deact.cell2
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${id}/5GBipL2L1_filtering_off.pcap0
    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scellactive.csv    ${filter}    ${csv_title_list}
    FOR    ${index}    IN RANGE    1    ${cell_nums}
    ${active_number}   Get Total Active Number   ${index}
    Should Be True    ${active_number}>=1
    END
    
Get Total Active Number
    [Arguments]    ${id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scellactive.csv   mac-nr.control.scell-act-deact.cell${id}   ["1"]   include   no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check Scells Deactivation From BIP
    [Arguments]    ${id}=2    ${cell_nums}=2
    Log To Console    verify Scells Deactivation from bip...
    ${filter}=    Catenate    mac-nr.dlsch.lcid == 0x3A
    @{csv_title_list}=    Create List    mac-nr.control.scell-act-deact.cell1    mac-nr.control.scell-act-deact.cell2
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${id}/5GBipL2L1_filtering_off.pcap0
    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scelldeactive.csv    ${filter}    ${csv_title_list}
    FOR    ${id}    IN RANGE    1    ${cell_nums}
    ${deactive_number}    Get Total DeActive Number    ${id}
    Should Be True    ${deactive_number}>=1
    END

Get Total DeActive Number
    [Arguments]    ${id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scelldeactive.csv    mac-nr.control.scell-act-deact.cell${id}    ["0"]    include   no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check UL Bler For Each Cell
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_ul_bler.ini    output_ul.csv    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_ul_no_bler.ini    output_ul.csv    ${csv_file_path}

Trigger A1 Scell Addition
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete

Trigger A2 Scell Release For TDD
    [Arguments]    ${ue_id}    ${meas_id}    ${scell_index}    ${scell_rsrp}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=${scell_rsrp}
    ...    pass_regexp=rrcReconfigurationComplete

Start SA Internal Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}=1    ${seconds}=60
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    Log To Console    start Internal traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir\=${dir} mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
    Sleep    2s    reason=wait traffic is stable

Capture BIP And Ttitrace Together
    [Arguments]    ${log_id}=1    ${duration}=3
    Capture And Decode TTitrace    ${log_id}    ${duration}
    Start Gnb BIP Log
    Sleep    ${duration}s    reason=Wait for bip logs
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/${log_id}
    Sleep    ${duration}s    reason=Wait for bip logs

Check UL Only On Scell
    [Arguments]    ${ul_tp_threshold}    ${list_tp_all}
    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
        Should Be True    ${dic_tp_ue.scell_ul}>${ul_tp_threshold}
    END
    
Check UL On Pcell And Scell
    [Arguments]    ${ul_tp_threshold}    ${list_tp_all}
    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
        ${ulsum_tp}    evaluate    ${dic_tp_ue.pcell_ul}+${dic_tp_ue.scell_ul}
        Log To Console    UL Troughput is ${ulsum_tp}    console=True
        Should Be True    ${ulsum_tp}>${ul_tp_threshold}
    END

Check DL On Pcell And Scell
    [Arguments]    ${dl_tp_threshold}    ${list_tp_all}
    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
        ${dlsum_tp}    evaluate    ${dic_tp_ue.pcell_dl}+${dic_tp_ue.scell_dl}
        Log To Console    DL Troughput is ${dlsum_tp}    console=True
        Should Be True    ${dlsum_tp}>${dl_tp_threshold}
    END

Check TP For Released Scells
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Set Variable    CellIndex-${scell_index}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?\\s+){3}(?P<AvgTput>\\d+.?\\d*)
    ${arg_tput_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    Should Be Empty    ${arg_tput_list}

Basic L3 Call and Traffic
    [Arguments]    ${ue_id}=${UE_ID}    ${ul_tp}=100    ${dl_tp}=175
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${ue_id}
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=1    seconds=3000
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=2    seconds=3000
    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1    seconds=3000

A1 Scell Addition And Check
    [Arguments]    ${ue_id}    ${srsrp_nr}    ${scells_info}    ${meas_id}
    Trigger A1 Scell Addition    ${ue_id}    ${meas_id}    ${srsrp_nr}
    Get And Check Scell Infos    ${scells_info}

A2 Scell Release And Check
    Trigger A2 Scell Release For TDD    ue_id=${UE_ID}    meas_id=3    scell_index=2    scell_rsrp=70
    Check Scell Release Infos
    Sleep    2s
    Check TP For Released Scells    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=2
    Check TP For Released Scells    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2

Check Scell Release Infos
    [Arguments]    ${scell_index}=2
    ${releaseidregex}=    Set Variable    sCellToReleaseList[\\s\\S]*?{([\\s\\S]*?)}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${release_id_list}=    String.Get Regexp Matches    ${content}    ${releaseidregex}    1
    ${release_id}=    String.Get Regexp Matches    @{release_id_list}[0]    \\d+
    List Should Contain Value    ${release_id}    ${scell_index}

Check Slot Not Scheduled
    [Arguments]    ${slotnumber}    ${csv_file_path}
    @{data_list}=    TTITRACEANALYZER.Filter 2Source Column Return other    ${csv_file_path}/output_ul.csv
    ...    physCellId    slot    52    include    ${slotnumber}    include    ulFdSchedData.numOfPrb    no
    ${count}    Get Length    ${data_list}
    ${count1}    Count Values In List    ${data_list}    ${EMPTY}
    Should Be True    ${count}==${count1}
    [Return]    ${count}

Check LocationAndBandwidth From Egate Log
    [Arguments]    ${locationAndBandwidth}=31624
    Log To Console    Start check locationAndBandwidth info from egate log.
    ${check_rst}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "locationAndBandwidth"
    Should Contain    ${check_rst}     locationAndBandwidth ${locationAndBandwidth}

L3 Call And Capture Log For BA075
    [Arguments]    ${UE_ID}=1    ${dl_tp}=70    ${ul_tp1}=60    ${ul_tp_threshold}=50
    ...    ${duration}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    Log To Console    start 5G PDU Session Setup CA...
    ${cmd1}    Set Variable    ue_pdu_session_setup pdu=1 ue=1 nwslice=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${cmd1}    pass_regexp=Context Setup Successful for UE    timeout=3minutes
    Log To Console    ${output}
    ${cmd2}    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=126 phycell_id=52
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${cmd2}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    ${cmd3}    Set Variable    trf_data_start ue=${ue_id} pdu=1 trf_id=1 mbps=${ul_tp1} dir=ul
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${cmd3}    pass_regexp=SCellIndex 1 activated successfully at airphone    timeout=3minutes
    Sleep    60s    reason=Wait for traffic
    Check UL On Target    ${UE_ID}    0    1     ${ul_tp_threshold}
    ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Trigger PHR To GNB    profile_id=2    phr_start=20    cell_id=1
    Sleep    5s    reason=Wait for logs
    Collect from savepoint  savepoint=${savepoint0}  destination_file=${TEST_LOG_DIRECTORY}/syslog0  alias=${GNB_SYSLOG.alias}
    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Recover Default PH Of Pcell And Scell
    Set The PowerAdjStep Online
    Wait for message in syslog file    regexp=ueSplitPowerAdjStep    timeout=60    alias=${GNB_SYSLOG.alias}
    Collect from savepoint    savepoint=${savepoint1}    destination_file=${TEST_LOG_DIRECTORY}/syslog1    alias=${GNB_SYSLOG.alias}
    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Trigger PHR To GNB    profile_id=1    phr_start=3    cell_id=0
    Trigger PHR To GNB    profile_id=2    phr_start=15    cell_id=1
    Sleep    10s    reason=Wait for logs
    Collect from savepoint    savepoint=${savepoint2}    destination_file=${TEST_LOG_DIRECTORY}/syslog2    alias=${GNB_SYSLOG.alias}
    ${savepoint3} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Set The PowerAdjStep Online    step_value=170
    Wait for message in syslog file    regexp=ueSplitPowerAdjStep    timeout=60    alias=${GNB_SYSLOG.alias}
    Sleep    10s    reason=Wait for logs
    Collect from savepoint    savepoint=${savepoint3}    destination_file=${TEST_LOG_DIRECTORY}/syslog3    alias=${GNB_SYSLOG.alias}
    ${savepoint4} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Set The WeightRatioOfUePwrScellVsPecll Online
    Wait for message in syslog file    regexp=ueSplitPowerAdjStep    timeout=60    alias=${GNB_SYSLOG.alias}
    Sleep    5s    reason=Wait for logs
    Collect from savepoint    savepoint=${savepoint4}    destination_file=${TEST_LOG_DIRECTORY}/syslog4    alias=${GNB_SYSLOG.alias}

Set The PowerAdjStep Online
    [Arguments]    ${step_value}=200
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.Perform Parameter Recommissioning
    ...    dist_name=${DST_FOR_PCELL}    parameter=${STEP_PARA}    operation=update    value=${step_value}    skip_parameter_relation_errors=True
    [Teardown]    COAM.Teardown

Set The WeightRatioOfUePwrScellVsPecll Online
    [Arguments]    ${ratio_value}=WeightRatio 100
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.Perform Parameter Recommissioning
    ...    dist_name=${DST_FOR_PCELL}    parameter=${RATIO_PARA}    operation=update    value=${ratio_value}    skip_parameter_relation_errors=True
    [Teardown]    COAM.Teardown

Check Adjustment Step
    [Arguments]    ${log_name}=syslog0    ${expected_step}=5.011872
    ${count}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i powerAdjStep:${expected_step}|wc -l
    Should Be True    ${count}!=0

Check DL 3 Scells On Target
    [Arguments]    ${target_ulsum_tp}=300
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${UE_ID}    dl    pcell    0
    ${scell1_dlTP}    Get CA Cell Average Throughput    ${UE_ID}    dl    scell    1
    ${scell2_dlTP}    Get CA Cell Average Throughput    ${UE_ID}    dl    scell    2
    ${scell3_dlTP}    Get CA Cell Average Throughput    ${UE_ID}    dl    scell    3
    ${dlsum_tp}    evaluate    ${pcell_dlTP}+${scell1_dlTP}+${scell2_dlTP}+${scell3_dlTP}
    Log To Console    \n DL Troughput is ${dlsum_tp}    console=True
    Should Be True    ${pcell_dlTP}
    Should Be True    ${scell1_dlTP}
    Should Be True    ${scell2_dlTP}
    Should Be True    ${scell3_dlTP}
    Should Be True    ${dlsum_tp}>=${target_ulsum_tp}

Check PCSI For Each 3Cell
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcsi3scells.ini    output_ul.csv    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcsi_dtx3scells.ini    output_ul.csv    ${csv_file_path}

Check Scelldeactive Via Macce From Gnb_syslog
    [Arguments]    ${sCellnum}
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${TEST_LOG_DIRECTORY};tar -xzvf ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    Log    ${output}
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    #${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "sendMacCe for UE:"
    ${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "sendMacCe deactivation"
    ${regexp}    Set Variable    sCellMask:0x(?P<sCellMask>[0-9a-f])
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellMask
    ${len}    Get Length    ${ret}
    Should Be True    ${len} == ${sCellnum}
    Log    ${ret}
    [Return]    ${ret}

