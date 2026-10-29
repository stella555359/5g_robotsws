*** Settings ***

Documentation
...
...             author:            vuyyuri.satyanarayana_raju@nokia.com
...             maintainer:        vuyyuri.satyanarayana_raju@nokia.com
...
...             INTRODUCTION:     This testcase describes the gNB behavior for UE(5QI-6) in RRC_INACTIVE state
...                               that is successfully transitioned from RRC_INACTIVE to RRC_CONNECTED state and
...                               resume of SRBs and DRBs. Successful Resume procedure
...             TEST SET NAME:    Use case of the Test case is to verify gNB behavior for UE(5QI-6) in RRC_INACTIVE state
...                               that is successfully transitioned from RRC_INACTIVE to RRC_CONNECTED state and
...                               resume of SRBs and DRBs. Successful Resume procedure
...             TESTING SPLIT:    See CB008225 testplan split D
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008225, CB010413 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18085;5G_RAN_OP_2558 


Resource         ../CB008225/resources/CB008225_resource.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_operations.robot


Suite Setup         Run keywords  Test Suite Setup
...                 AND           AIC Software Build Info
...                 AND           Fetch Taf Library used in TL
...                 AND           Log to console    vDU delta commissioning
...                 AND           Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                 AND           sleep    300s
...                 AND           Log to console    vCU delta commissioning
...                 AND           Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND           sleep    700s
...                 AND           Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep   120s

Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner


*** Variables ***
${delta_vdu}        ${CURDIR}/config/SBTS24R2/vDU_CB008225_TDD_2Cell_Delta_scf.xml
${delta_cu}         ${CURDIR}/config/SBTS24R2/vCU_CB008225_TDD_2Cell_Delta_scf.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_TDD_AiC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TEST_NAME}        test_case
${split}        resume
${start_ue_id}      ${1}
${end_ue_id}      ${1}
${delta}       30
${tp_duration}      40
${inactivity_timer}      90
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       5
@{QOS_Prof2_speed_ul}      1       5
@{QOS_Prof2_unit}          mbps     mbps

${duration}      60
${trf_id}      ${1}

*** Test Cases ***

[1]CB008225_D_B1_5 Successful RESUME procedure for UE in RRC Inactive State - Inactivity based - DL AMF signaling arrival_5QI6_FDD_LO

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}
    ${cnai}          Create Dictionary         ${1}=on   
    ${state}         Create Dictionary         ${1}=inactive 
    ${trigger}       Create Dictionary         ${1}=dldata_ranpaging
    ${qos}           Create Dictionary         ${1}=ngbr

    [Setup]     Run keywords         Log to console     \n-----> Test Setup <-----
    ...         AND                  Testcase Setup
    Start CPRT F1 Monitoring
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}

    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Reset Bearer Stats     ${start_ue_id}     ${end_ue_id}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}     ${qos}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${tp_read1}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${duration}   both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Stop and Collect CPRT F1 Monitoring
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}




