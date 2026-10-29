*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CIT   CDRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS22R4    SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot
Library   	     taf.sw.scout 	WITH NAME	scout

Suite Setup         Run keywords     Suite setup from scratch
...            AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_MultiUE_with_8379_20MHz.json
...            AND     sleep    400
...            AND     Reboot gNB System Module from Console and check Airscale is ready
...            AND     sleep    400
...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Navin Ray, navin.kumar_ray@nokia.com
...             maintainer:        Navin Ray, navin.kumar_ray@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for VinrGBR 5QI-2 and VonrGBR 5QI-1
...             TEST SET NAME:    CB008379-5G-C_13_Scheduling_Priority_for_UE_with_5QI1_and_5QI2_GBR_bearers_FDD
...                               Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for 30 minutes with VinrGBR 5QI-2 on Classical gNB
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_14716,5G_RAN_USR_RRM_14807

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_fdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${5}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3


@{QOS_Prof2}                1
@{QOS_Prof2_speed_ul}       10
@{QOS_Prof2_speed_dl}       30
@{QOS_Prof2_unit}           mbps


@{QOS_Prof7}               1       2           3                4
@{QOS_Prof7_speed_ul}      10       32         amr_wb_18_25     30
@{QOS_Prof7_speed_dl}      10       32         amr_wb_18_25     30
@{QOS_Prof7_unit}          mbps    kbps        rtp_codec        mbps


*** Test Cases ***
[1]CB008379-5G-C_13_Scheduling_Priority_for_UE_with_5QI1_and_5QI2_GBR_bearers_and_Multiple_UEs_with_a_non-GBR_bearer_FDD

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof7}              ${2}=${QOS_Prof2}
    ...     ${3}=${QOS_Prof2}                ${4}=${QOS_Prof2}      ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof7_speed_ul}     ${2}=${QOS_Prof2_speed_ul}
    ...     ${3}=${QOS_Prof2_speed_ul}     ${4}=${QOS_Prof2_speed_ul}     ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof7_speed_dl}     ${2}=${QOS_Prof2_speed_dl}
    ...     ${3}=${QOS_Prof2_speed_dl}     ${4}=${QOS_Prof2_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof7_unit}         ${2}=${QOS_Prof2_unit}
    ...     ${3}=${QOS_Prof2_unit}            ${4}=${QOS_Prof2_unit}       ${5}=${QOS_Prof2_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...    ${en_ue_id}    pdu_id=1    nw_id=1
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
# Make sure that Non GBR call is fully occupying the network bandwidth then only  utility.compare_tp will work
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
#    Start and Stop TTI TRACE
    sleep   ${duration}s
#    Collect TTI Trace   tti_trace

    ${nongbr_tp_read}=     Run Keyword And Ignore Error
    ...     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id}     ${duration}
	...     both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1


#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

    [Teardown]  Run Keywords    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***


Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}



