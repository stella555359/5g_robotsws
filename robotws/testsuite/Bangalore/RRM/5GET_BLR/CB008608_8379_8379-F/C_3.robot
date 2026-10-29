*** Settings ***
Force Tags      CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource            ./CB008608_resource.robot
Resource            ../resources/robot/common_log_collection.robot

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
...                     AND                 Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                     AND                 Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
#...                     AND                 Trigger Delta Plan For CU  ${delta_cu}
#...                     AND                 Update and Activate Delta Plan Parameter   delta   ${delta_vdu}
...                     AND    BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND    sleep   300s
...                     AND    BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status      ${800}
...                     AND    Clear WTS     ${WTS_DIR}
...                     AND    Add WTS Ipaddr At VM
...                     AND    log to console   loading cfg.................
...                     AND    Start WTS Using WTS_Runner     ${wts_cfg_file}
...                     AND    sleep   120s

Suite Teardown          Run keywords        Kill WTS processes Using WTS_Runner

Test Teardown    Run Keywords   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
#${gnb_index}        0
#${vdu_index}        0
#${wts_cfg_file}     /opt/iphy/latest/basic_fullstack_sa_call_tdd_cmwv_Working.cfg
#${wts_cfg_file}     ${CURDIR}/config/basic_fullstack_sa_call_tdd_cmwv_Working.cfg
${delta_vdu}        ${CURDIR}/config/SBTS24R1/Delta_configuration_scf_vDU.xml
${delta_cu}         ${CURDIR}/config/SBTS24R1/Delta_configuration_scf_vCU.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode_updated_with_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
#${UE_ID}     3
${VDU_SCF_PATH}     ${CURDIR}/config/working_8379_vdu.xml
${VCU SCF PATH}     ${CURDIR}/config/working_8379_vcu.xml
${VDU_SCF_PATH_1}   /home/ute/TL7_All_files/8608/2cell_Final_Bakup/Backup_17thMay/Actual_configuration_scf_MRBTS-3804_3804_20220516-1046.xml
${VCU SCF PATH_1}   /home/ute/TL7_All_files/8608/2cell_Final_Bakup/Backup_17thMay/Actual_configuration_scf_MRBTS-3804_vCU1_BLR_20220516-1046.xml
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      ${1}
${en_ue_id}      ${5}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3

@{QOS_Prof2}                1           23
@{QOS_Prof2_speed_ul}       3           5
@{QOS_Prof2_speed_dl}       3           80
@{QOS_Prof2_unit}           mbps        mbps

@{QOS_Prof7}               1       2          3                10
@{QOS_Prof7_speed_ul}      10      32         amr_wb_18_25     30
@{QOS_Prof7_speed_dl}      10      32         amr_wb_18_25     30
@{QOS_Prof7_unit}          mbps    kbps       rtp_codec        mbps

*** Test Cases ***
[1]CB008379-5G-C_3_Single_GBR_UE_with_5QI_128_Multiple_UE_with_non_GBR_5QI_129_FDD

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof7}              ${2}=${QOS_Prof7}
    ...     ${3}=${QOS_Prof2}                ${4}=${QOS_Prof2}      ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof7_speed_ul}     ${2}=${QOS_Prof7_speed_ul}
    ...     ${3}=${QOS_Prof2_speed_ul}     ${4}=${QOS_Prof2_speed_ul}     ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof7_speed_dl}     ${2}=${QOS_Prof7_speed_dl}
    ...     ${3}=${QOS_Prof2_speed_dl}     ${4}=${QOS_Prof2_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof7_unit}         ${2}=${QOS_Prof7_unit}
    ...     ${3}=${QOS_Prof2_unit}            ${4}=${QOS_Prof2_unit}       ${5}=${QOS_Prof2_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with 5QI128 and 129

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}    ${en_ue_id}
    ...    pdu_id=1    nw_id=1
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    120
    ${trf_id}      Set Variable    ${1}
# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
# Make sure that Non GBR call is fully occupying the network bandwidth then only  utility.compare_tp will work
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    log to console   collect bearer stats...
    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}    skipp=1
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
