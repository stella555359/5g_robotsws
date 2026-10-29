# *** Settings ***
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Force Tags        CLOUD_5GC_dRNIC_1vDU_O_AP_LO    AP    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${DU_SCF}             scfc_VDU_7922_case10.xml
# ${CU_SCF}             scfc_VCU_7922_case10.xml
# ${AIRPHONE_NAME}      iphy_7922_case10.xml
# ${WTS_CFG}           basic_setup_7922_case10.cfg
# ${UE_ID}        11
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    sosreport    tshark    egatelog
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# ${B_S}          beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3 csirs_bestbeam\=2 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# ${BS_MODE}      ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=1
# ${BS_MODE1}     ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=2
# 
# *** Test Cases ***
# CB007922_case10_A_4c_intraL2RT_interBand_Single_UE_A1_Scell_addition_and_RLQ_deactivation_A2_Scell_release_refineBF_NSA
#     Step1:Prepare onAir
#     Step2:Attach NSAUE and Send A1 measurement
#     Step3:Send DL/UL data and check UE use refine beam
#     Step4:Override Scell CQI trigger bad threshold
#     Step5:Override Scell CQI trigger good threshold and scell resume
#     Step6:Override scell CQI to reach bad scell RLQ threshold for more than 100s trigger scell deactivate
#     Step7:Override Scell CQI trigger good threshold and scell not resume
#     Step8:Send A2 measurement and check scell released
#     Step9:Send A1 measurement and check scell added
#     Step10:Detach ue
# 
# *** Keywords ***
# Step1:Prepare onAir
#     Start Collect GNB and AP Syslog in 'before_onair' File
#     Modify TL VM And AP SCTP Configuration
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'before_onair' File
# Step2:Attach NSAUE and Send A1 measurement
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=1
#     Set UE_${UE_ID} Refine Beam
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# Step3:Send DL/UL data and check UE use refine beam
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=7    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=8    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    UL    25M    trf_id=9    duration=${3600}
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}step3_send_data/ttiTrace
# 
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step3_send_data
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_refineBeam.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 400000
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 400000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# Step4:Override Scell CQI trigger bad threshold
# 	Start Collect GNB and AP Syslog in 'step4_rlq_bad' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=2 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=activate
# 	Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_rlq_bad' File
# Step5:Override Scell CQI trigger good threshold and scell resume
#     Start Collect GNB and AP Syslog in 'Step5_RLQ_good' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=deactivate
# 	Wait Throughput Timer    20
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step5_RLQ_good/ttiTrace
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_RLQ_good' File
# Step6:Override scell CQI to reach bad scell RLQ threshold for more than 100s trigger scell deactivate
# 	Start Collect GNB and AP Syslog in 'Step6_RLQ_bad_scell_deactive' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=2 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=activate
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
# 
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step6_RLQ_bad_scell_deactive/ttiTrace
# 
#     Wait Throughput Timer    60
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_RLQ_bad_scell_deactive' File
# 
# Step7:Override Scell CQI trigger good threshold and scell not resume
#     Start Collect GNB and AP Syslog in 'Step7_RLQ_good_scell_not_resume' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=deactivate
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
#     run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0	
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step7_RLQ_good_scell_not_resume/ttiTrace
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_RLQ_good_scell_not_resume' File
# 
# Step8:Send A2 measurement and check scell released
#     Start Collect GNB and AP Syslog in 'Step8_trigger_a2' File
# 	airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A2 scell=2 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
#     ${id}    VDU Start TTiTrace Log
#     Wait '2s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step8_trigger_a2/ttiTrace
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_trigger_a2' File
# 
# Step9:Send A1 measurement and check scell added
#     Start Collect GNB and AP Syslog in 'step9_send_A1' File
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_send_A1' File
# 
# Step10:Detach ue
#     Airphone NSA Detach    ${UE_ID}
# 
# Set UE_${UE_ID} Refine Beam
#     airphone_execute_egate_command    ${B_S}
#     airphone_execute_egate_command    ${BS_MODE}
#     airphone_execute_egate_command    ${BS_MODE1}    
# 
# 
# wait ${time} to check log
#     sleep    ${time}
# 
# Capture tti for ${ttiduring} in ${ttipath}
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}${ttipath}/ttiTrace
# 
# Check ${ttipath} ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_refineBeam.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${ttipath}
