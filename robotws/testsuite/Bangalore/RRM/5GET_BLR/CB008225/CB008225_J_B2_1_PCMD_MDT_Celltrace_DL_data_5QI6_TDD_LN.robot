*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R4    CONFIGURED

Documentation
...
...				author       : B,Padmashree <padmashree.b@nokia.com>
...             maintainer   : B,Padmashree <padmashree.b@nokia.com>
...             Introduction : This testcase validates the PCMD, Cell trace records and MDT measurements
...	    					    reported by gNB-CU-CP when UE
...                            moves from RRC_Inactive to RRC_Connected state.
...             Test Set Name: CB008225_J_B02_1 Verify PCMD, Cell Trace Records and MDT measurements during
...                            Resume procedure_Inactivity based_DL User data arrival _5QI6_TDD_LN
...             Testing Split: CB008225 Split J testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008225 CFAM
...             RequirementID: 5G_RAN_USR_RRM_18000

Library    taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     ute_utf_lab.Update Utf Lab
...                 AND     Initiate Dcap
...					AND     Update_tce_ip_in_delta_file     ${scf_file_path}/SBTS24R3/${scffile_name}
...					AND     Update_tce_ip_in_delta_file     ${scf_file_path}/SBTS25R2/${scffile_name}
...                 AND     Perform SCF Delta Commissioning with Delta_config_Inact_based_PCMD_MDT_CELLTRACE_gLN_apLO_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces       ${wts_cfg_file}
...                 AND     DCAP Connect To gNB

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     DCAP Disconnect To gNB

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gLN-apLO_tdd_ref.cfg
${scffile_name}     Delta_config_Inact_based_PCMD_MDT_CELLTRACE_gLN_apLO_TDD.json
${scf_file_path}    ${CURDIR}/config/
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TEST_NAME}        test_case

${start_ue_id}      ${1}
${end_ue_id}      ${1}
${delta}       30
${inactivity_timer}      120
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
[1][1.0] CB008225_J_B02_1 Verify PCMD, CellTraceRecords and MDTmeasurements during Resumeprocedure_Inactivity based_DL Userdata arrival _5QI6_TDD_LN
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof1}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof1_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof1_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof1_unit}        ${3}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                  ${3}=inactive
	${trigger}             Create Dictionary             ${1}=dldata_ranpaging      ${2}=dldata_ranpaging       ${3}=dldata_ranpaging


    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...


    Start_Dcap_Ipcapture
	${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
	Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}
    ...        state=${state}
	Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
	Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}       ${state}        ${trigger}
	Stop_and_Collect_Dcap_IpCapture			${LOG_PATH}
    Link SCOUT SCF to Configuration ID for Reporting
	verify_celltraces_on_tce     pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_celltrace.pdml
	verify_pcmd_traces_on_tce     pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_pcmd.pdml
	verify_mdt_on_tce	 pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_mdt.pdml
#    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
