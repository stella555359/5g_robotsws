*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R4    CONFIGURED

Documentation
...
...				author       : Kavya Kavya (Nokia) <kavya.kavya@nokia.com>
...             maintainer   : Kavya Kavya (Nokia) <kavya.kavya@nokia.com>
...             Introduction : This testcase describes the Sherpa traces verification for 0x3A BearerModifyReq 
...	    					   and 0x38 HiUserCu_DlDataInd messages.  
...             Test Set Name: CB008225_J_1 Verify Sherpa Traces - HiUserCu_BearerModifyReq during 
...							   Suspend and Resume, HiUserCu_DlDataInd during Resume_TDD_LN 
...             Testing Split: CB008225 Split J testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008225 CFAM
...             RequirementID: 5G_RAN_USR_RRM_19071

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Config_sherpa_HiUserCu_NonRANsha_InactBased-Uelevel_gLN-apLO_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gLN-apLO_tdd_ref.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TEST_NAME}        test_case
${Sherpa_message_ID_to_filter}          BearerModifyReq(0x3a)

${start_ue_id}    ${1}
${end_ue_id}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 9
@{QOS_Prof2_speed_dl}      1       1
@{QOS_Prof2_speed_ul}      1       1
@{QOS_Prof2_unit}          mbps     mbps

@{QOS_Prof3}               1        6            #5QI 4
@{QOS_Prof3_speed_dl}      1        30
@{QOS_Prof3_speed_ul}      1        30
@{QOS_Prof3_unit}          mbps     mbps

@{QOS_Prof4}               1      2       3                            #5QI 1
@{QOS_Prof4_speed_dl}      1      32      amr_wb_18_25
@{QOS_Prof4_speed_ul}      1      32      amr_wb_18_25
@{QOS_Prof4_unit}          mbps   kbps    rtp_codec

${delta}       30
*** Test Cases ***

[1]CB008225_J_1_Verify_Sherpa_Traces_HiUserCu_BearerModifyReq_during_Suspend_and_Resume_HiUserCu_DlDataInd_during_Resume_TDD_LN

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof1}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof1_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof1_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof1_unit}        ${3}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                   ${3}=inactive

    Start Log      btslog     cprt      sherpa
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable       200
    ${trf_id}      Set Variable    ${1}
    Trigger DL Traffic for SA    ue_id=1    Traffic_rate=kbps     dl_rate=15       pdu_id=1      trf_id=1      qfi_id=1
    sleep   10
    ${tp_read}=     Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1       #${skipp}=1
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}     
    ...     ${qos_profile}         state=${state}
    ${inactivity_timer}      Set Variable    32
    Log to Console          Wait ${inactivity_timer}s for UE to move inactive state
    sleep   ${inactivity_timer}s
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    Trigger DL Traffic for SA    ue_id=1    Traffic_rate=Mbps     dl_rate=15       pdu_id=1      trf_id=1      qfi_id=1        
    ${scen1}     Stop Log      btslog     cprt      sherpa
    Decode Sherpa pcap      
    Filterring of Message ID BearerModifyReq in Sherpa csv      BearerModifyReq(0x3a)|cause:6
    Filterring of Message ID BearerModifyReq in Sherpa csv      BearerModifyReq(0x3a)|cause:7
    Filterring of Message ID BearerModifyReq in Sherpa csv      DlDataInd(0x40)|HiUserCU
