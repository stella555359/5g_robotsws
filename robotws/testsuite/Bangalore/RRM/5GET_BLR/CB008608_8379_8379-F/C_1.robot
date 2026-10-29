*** Settings ***
Force Tags      CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource            ./CB008608_resource.robot
Resource            ../resources/robot/common_log_collection.robot

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
#...                     AND                 Trigger Delta Plan For CU  ${delta_cu}
#...                     AND                 Update and Activate Delta Plan Parameter   delta   ${delta_vdu}
...                     AND                 Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                     AND                 Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
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
${delta_vdu}        ${CURDIR}/config/SBTS24R1/Delta_configuration_scf_vDU.xml
${delta_cu}         ${CURDIR}/config/SBTS24R1/Delta_configuration_scf_vCU.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode_updated_with_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}         ${1}                   # Total UE ngbr+gbr
${en_ue_id}         ${5}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      10
@{QOS_Prof1_speed_dl}      50
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1         5
@{QOS_Prof2_speed_ul}      1        20
@{QOS_Prof2_speed_dl}      1        20
@{QOS_Prof2_unit}          mbps     mbps

*** Test Cases ***
[1]CB008379-5G-C_1_Single_GBR_UE_with_5QI_3_Multiple_non_GBR-Ues_FDD

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}            Create Dictionary   ${1}=${QOS_Prof1}   ${2}=${QOS_Prof1}   ${3}=${QOS_Prof1}
    ...      ${4}=${QOS_Prof1}   ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}    ${2}=${QOS_Prof1_speed_ul}
    ...     ${3}=${QOS_Prof1_speed_ul}     ${4}=${QOS_Prof1_speed_ul}   ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}    ${2}=${QOS_Prof1_speed_dl}
    ...     ${3}=${QOS_Prof1_speed_dl}     ${4}=${QOS_Prof1_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}       Create Dictionary   ${1}=${QOS_Prof1_unit}    ${2}=${QOS_Prof1_unit}
    ...     ${3}=${QOS_Prof1_unit}     ${4}=${QOS_Prof1_unit}   ${5}=${QOS_Prof2_unit}
    ${total_ue}=   Get Dictionary Keys   ${qos_profile}
    ${ngbr_ue}=   Get Slice From List   ${total_ue}      0        -1      #Change as per GBR UE count

#Step 1. Attach NGBR+GBR UEs, with PDU session 5QI-6 nonGBR qosflow which is default QOS
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...     ${en_ue_id}    pdu_id=1    nw_id=1

#Step 2. Attach GBR UEs, with PDU session 5QI-3 GBR qosflow
    Create Modify PDU session   ${st_ue_id}    ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...     ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    60
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${ngbr_ue}[0]     ${ngbr_ue}[-1]     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

    sleep    ${duration}s

    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${ngbr_ue}[0]     ${ngbr_ue}[-1]
    ...     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1

    log to console     NGBR Throughput ${nongbr_tp_read}

#
#    ${trf_id}      Set Variable    ${2}
#    Reset Bearer Stats     ${st_ue_id}    ${en_ue_id}
#
##Step 3. Running traffic on NGBR+GBR UE for verification
#    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
#    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
#
#    sleep   ${durati
#
#    ${gbr_nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id}
#    ...     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}     ${qos_profile_speed_dl}
#    ...     ${qos_profile}       gbr_chk=1
#
#    log to console    GBR_NGBR Throughput ${gbr_nongbr_tp_read}


#
#    utility.compare_tp  ${wts_cfg_file}     ${st_ue_id}     ${nongbr_tp_read}    ${gbr_nongbr_tp_read}    ${qos_profile}
#    ...    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${vonr_codec_rate}    ${qos_profile_unit}    dirct=both

    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
