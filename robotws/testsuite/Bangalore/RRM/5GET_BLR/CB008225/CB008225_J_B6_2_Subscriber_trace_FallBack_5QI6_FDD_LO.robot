*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R4    CONFIGURED

Documentation
...
...				author       : B,Padmashree <padmashree.b@nokia.com>
...             maintainer   : B,Padmashree <padmashree.b@nokia.com>
...             Introduction : This testcase validates the PCMD, Cell trace records and MDT measurements
...	    					   during RNA update
...             Test Set Name: [1]CB008225_J_B06_1 Verify Subscriber and Equipment Trace during
...							   Resume procedure_Inactivity based_DL User data arrival_5QI6_FDD_LO
...             Testing Split: CB008225 Split J testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008225 CFAM
...             RequirementID: 5G_RAN_USR_RRM_19071

Library    taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab

Resource         resources/CB008225_resource.robot


Suite Setup         Run keywords   Update_tce_ip_in_delta_file     ${scf_file_path}/SBTS24R3/${scffile_name}
...                 AND    Update_tce_ip_in_delta_file     ${scf_file_path}/SBTS25R2/${scffile_name}
...                 AND    Prepare TL with all config files
...                 AND     ute_utf_lab.Update Utf Lab
...                 AND     Initiate Dcap
...                 AND    Add routes
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib
...                 AND     DCAP Connect To gNB


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     DCAP Disconnect To gNB


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/j_b6_2_basic_setup.cfg
${scffile_name}     CB008225_J_B6_2_SCF.xml
${scf_file_path}    ${CURDIR}/config/
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        51
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TEST_NAME}        test_case
${SCFC}=                   ${CURDIR}/config/SBTS25R2/CB008225_J_B6_2_SCF.xml
${AP_XML}=                 ${CURDIR}/config/wts/CB008225_J_B6_2_IPHY.xml

${start_ue_id}      ${51}
${end_ue_id}      ${51}
${delta}       10
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps
${inactivity_timer}     120
${duration}          60
${trf_id}          ${1}


*** Test Cases ***
[1] CB008225_J_B06_2 Verify Subscriber and Equipment Trace during Fallback to RRC Setup procedure_5QI6_FDD_LO
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof1}                ${52}=${QOS_Prof1}             ${53}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}       ${52}=${QOS_Prof1_speed_ul}    ${53}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}       ${52}=${QOS_Prof1_speed_dl}    ${53}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}           ${52}=${QOS_Prof1_unit}        ${53}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${51}=on                     ${52}=on                       ${53}=on
    ${state}                  Create Dictionary          ${51}=inactive               ${52}=inactive                  ${3}=inactive
    ${trigger}             Create Dictionary             ${51}=dldata_ranpaging		${52}=dldata_ranpaging	${53}=dldata_ranpaging
	${state1}			Create Dictionary          ${51}=active               ${52}=active                  ${53}=active


    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    Start_Dcap_Ipcapture
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
	...			subscriber_trace=True
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
	Set_action_rrc_resume_request		${start_ue_id}		cause=rna_Update		action=invalid_short_mac_i
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}
    ...        state=${state}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    Trigger_ue_nr_rrc_resume		${start_ue_id}
    sleep   60s
    Stop Subscriber Trace
    Start Subscriber Trace  trace_session_id=2

    Stop_and_Collect_Dcap_IpCapture         ${LOG_PATH}
    verify_subscribertraces_on_tce    pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_subscribertrace.pdml
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


