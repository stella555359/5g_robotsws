*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS24R1    SBTS23R2    CONFIGURED

Documentation
...
...				author       : B,Padmashree <padmashree.b@nokia.com>
...             maintainer   : B,Padmashree <padmashree.b@nokia.com>
...             Introduction : This testcase describes the gNB behavior for UE in RRC_INACTIVE state that is
...								successfully transitioned from RRC_INACTIVE to RRC_CONNECTED state and resume of
...								SRBs and DRBs. Successful Resume procedure
...             Test Set Name: CB008225_D_B1_7 Successful RESUME procedure for UE in RRC Inactive State_UAI based for UE
...									 with preferredRRC-State-r16 is set to outofConnected_DL user data_5QI6_TDD_LN
...             Testing Split: CB008225 Split D testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008225 CFAM
...             RequirementID: 5G_RAN_USR_RRM_19071

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Config_Ransharing_LO_AP_LO_GMC.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces       ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...					AND		kill_ue
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gLO_tdd_gmc.cfg
${scffile_name}     Delta_config_Inact_based_PCMD_MDT_CELLTRACE_gLN_apLO_TDD.json
${scf_file_path}    ${CURDIR}/config/SBTS23R4/
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TEST_NAME}        test_case
@{cause_list}       2   2
${start_ue_id}      ${1}
${end_ue_id}      ${1}
${delta}       30
${inactivity_timer}      100
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

${duration}          60
${trf_id}          ${1}

*** Test Cases ***
[1]CB008225_D_B1_7 Successful RESUME procedure for UE in Inactive State_UAI preferredRRC-State-r16 is outofConnected_DL user data_5QI6_TDD_LN
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof1}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof1_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof1_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof1_unit}        ${3}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                  ${3}=inactive
    ${trigger}             Create Dictionary             ${1}=dldata_ranpaging                  ${2}=dldata_ranpaging       ${3}=dldata_ranpaging
	set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
	Start Log      btslog     cprt
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    ${full_rnti_list}   Set UE Assistance info and Verify UE state      ${start_ue_id}    ${end_ue_id}      uai_state=outOfConnected 
    Verify_resume_and_ue_status   ${start_ue_id}     ${end_ue_id} 
    ${scen1}     Stop Log      btslog     cprt
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap        ${start_ue_id}      ${end_ue_id}     ${qos_profile}
    ...       ${full_rnti_list}     cause_list=${cause_list}        state=${state}     activityNotify=uE   split=resume     uai_set=true
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
	
*** Keywords ***
kill_ue
	wtsrunner.ue_kill	id=1

Verify_resume_and_ue_status
    [Arguments]     ${start_ue_id}      ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1    
    ${output}   Read WTS Output For Pattern And Print matching Lines     .*UE${ue_idx}: UE performed resume procedure*.      timeout=10
    ${output}   Read WTS Output For Pattern And Print matching Lines     .*UE${ue_idx}: Started Downlink Internal traffic*.      timeout=10
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=PDN    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ACTIVE    partial_match=${TRUE}
    Log to Console    ${output}
    Log to Console    UE: ${ue_idx} in active state
    END
