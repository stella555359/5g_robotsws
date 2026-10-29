*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library        taf.sw.reporting_portal
Resource       ../../feature_resources/CB008370/CB008370-A_B1-Activation_of_the_feature_for_single_UE_in_good_radio_conditions.robot
Resource       ../../feature_resources/CB013206/CB013206_CR_C_RAB_REL_NRM_SGNB_INSES_PMQAP_M55162C00012_counter_check.robot
Resource       ${CB011169_TEST_PATH}
Resource       ${CB007065_TEST_PATH}
Resource       ../../feature_resources/CB007065/CB007065_B_CB010471_Interworking_with_5GC000431.robot
Resource       ${CB007065_A_CB010442_TEST_PATH}
Resource       ${CB0010414_TEST_PATH}
Resource       ../../feature_resources/CB010369_CB008225/CB010369_CB008225_RRC_inactive_RFSP_based.robot
Resource       ../../resources/attenuator.robot

Suite Setup  Cloud Test Suite Setup
Suite Teardown  Cloud Test Suite Teardown


*** Variables ***
${ABSTRACT_LIB_CONFIG}          /home/ute/testline_configuration/7_16_UTE5GCLOUDU077/ta_ue_config.yaml
${TA_ATTENUATOR_CONFIG}         /home/ute/testline_configuration/7_16_UTE5GCLOUDU077/ta_ue_config.yaml
${CU_OAM_VERSION_VCU}           cuoam_26r1
${CU_OAM_VERSION_VDU}           cuoam_26r2
${WTS_CFG_FILE_PATH}            /opt/wts/latest/ran_sharing_basic_setup.cfg

${SHOULD_BE_REPORTED}           True
${HOSTNAME}                     1_16_VRF_vRAN_AP_ET_ST
${LABEL}                        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_RRH_SWFH
${QC_DOMAIN}                    MN_RAN
${QC_PROJECT}                   RAN_VRF
${LOG_LINK}                     \\\\nescrotta.nesc.nokia.net\\rotta\\MN_RAN\\RAN_VRF\\Trunk\\VRF_WRO2\\VRF_WRO2_T02\&03

${CB011169_TEST_PATH}           SEPARATOR=
...                             ../../feature_resources/CB011169/
...                             CB011169_CB008954-C_SA_Robustness_with_three_dedicated_BWP_counters_check_and_cell_lock_and_unlock.robot
${CB007065_TEST_PATH}           SEPARATOR=
...                             ../../feature_resources/CB007065/
...                             CB007065_B_CB008133_Power_reduction_via_load_based_massive_MIMO_power_saving_with_32TRX_path_switch_off.robot
${CB007065_A_CB010442_TEST_PATH}           SEPARATOR=
...                             ../../feature_resources/CB007065/
...                             CB007065_A_CB010442_B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated.robot
${CB0010414_TEST_PATH}          SEPARATOR=
...                             testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB010414_CB010796/
...                             CB010414_CB010796_Stop_slot_blanking_triggered_by_RFU_for_the_temperature_is_cooling_down_and_counters_check.robot

*** Test Cases ***
CB013206_CR_C_RAB_REL_NRM_SGNB_INSES_PMQAP_M55162C00012_counter_check
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB013206_CR_C_RAB_REL_NRM_SGNB_INSES_PMQAP_M55162C00012_counter_check
    ...  vDU  vCU  ta5g_ue_mobility
    ...  AND  Set Test Variable  ${NR_CELL_ID}  1
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${UE_ID}  101
    ...  AND  TC Setup
    TC__CB013206_CR_C_RAB_REL_NRM_SGNB_INSES_PMQAP_M55162C00012_counter_check
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB007065_B_CB010471_Interworking_with_5GC000431
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB007065_B_CB010471_Interworking_with_5GC000431
    ...  vDU  vCU  ta5g_ue_mobility
    ...  AND  Set Test Variable  ${NR_CELL_ID1}  1
    ...  AND  Set Test Variable  ${NR_CELL_ID2}  2
    ...  AND  Set Test Variable  ${TX_POWER_GROUP_ID}  1
    ...  AND  Set Test Variable  ${CELL_POWER_GROUP_ID}  2
    ...  AND  Set Test Variable  ${UE_ID1}  101
    ...  AND  Set Test Variable  ${UE_ID2}  121
    ...  AND  Set Test Variable  ${SWITCH_ON_TIMEOUT}  300
    ...  AND  Set Test Variable  ${SWITCH_OFF_TIMEOUT}  120
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  TC Setup
    TC__CB007065_B_CB010471_Interworking_with_5GC000431
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB007065_A_CB010442_B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB007065_A_CB010442_B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
    ...  vDU  vCU
    ...  AND  Set Test Variable  ${NR_CELL_ID}  2
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${NR_CELL_IDENTIFIER}    00:87:a0:00:20
    ...  AND  TC Setup
    TC__CB007065_A_CB010442_B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB010414_CB010796_Stop_slot_blanking_triggered_by_RFU_for_the_temperature_is_cooling_down_and_counters_check
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB010414_CB010796_Stop_slot_blanking_triggered_by_RFU_for_the_temperature_is_cooling_down_and_counters_check
    ...  CB010414_CB010796_KW  tti_trace  cloud_bts_ta5g_pm_counters  ta5g_ue_mobility  vDU  vCU
    ...  AND  Set Test Variable  ${NR_CELL_ID}  1
    ...  AND  Set Test Variable  ${UE_ID}  1
    ...  AND  Set Test Variable  ${RMOD_MO_ID}  2
    ...  AND  Set Test Variable  ${RMOD_AP_ID}  1
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${MAX_UTF_LOGS_DELAY}  300s
    ...  AND  TC Setup
    TC__CB010414_CB010796_Stop_slot_blanking_triggered_by_RFU_for_the_temperature_is_cooling_down_and_counters_check
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB010369-B_Successful_transition_of_UE_from_RRC_Connected_to_RRC_Inactive_state_due_to_expiration_of_RFSP_based_Inactivity_timer_IWK_with_CB008225
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB010369_CB008225_RRC_inactive_RFSP_based  CB010369_CB008225_resources
    ...  vDU  vCU  ta5g_ue_mobility
    ...  AND  Set Test Variable  ${NR_CELL_ID_ORIGIN}  1
    ...  AND  Set Test Variable  ${NR_CELL_ID_TARGET}  2
    ...  AND  Set Test Variable  ${UE_ID}  1
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${GNB_VCU_TCPDUMP_ALIAS}  default_F1_E1_RRC
    ...  AND  Set Test Variable  ${RANAC_TARGET_CELL}  2
    ...  AND  Set Test Variable  ${PLMN_ID}  1
    ...  AND  Set Test Variable  ${TAC}  200
    ...  AND  TC Setup
    TC__CB010369-B_Successful_transition_of_UE_from_RRC_Connected_to_RRC_Inactive_state_due_to_expiration_of_RFSP_Inactivity_timer_IWK_with_CB008225
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB008370-A_B1-Activation_of_the_feature_for_single_UE_in_good_radio_conditions
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB008370-A_B1-Activation_of_the_feature_for_single_UE_in_good_radio_conditions  ute_ue  vDU  vCU
    ...  AND  Set Test Variable  ${NR_CELL_ID}  15
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NOKIA_UE
    ...  AND  Set Test Variable  ${NR_EXPECTED_DL_TPUT}  500
    ...  AND  Set Test Variable  ${CELL_ALIAS}  NR_CELL_15
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  TC Setup
    TC__CB008370-A_B1-Activation_of_the_feature_for_single_UE_in_good_radio_conditions
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB007065_B_CB008133_Power_reduction_via_load_based_massive_MIMO_power_saving_with_32TRX_path_switch_off
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB007065_B_CB008133_Power_reduction_via_load_based_massive_MIMO_power_saving_with_32TRX_path_switch_off
    ...  ute_ue  vDU  vCU
    ...  AND  Set Test Variable  ${NR_CELL_ID}  15
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NOKIA_UE
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  4
    ...  AND  Set Test Variable  ${CELL_ALIAS}  NR_CELL_15
    ...  AND  Set Test Variable  ${ATTENUATION_VALUE}  ${0}
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  TC Setup
    TC__CB007065_B_CB008133_Power_reduction_via_load_based_massive_MIMO_power_saving_with_32TRX_path_switch_off
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


CB011169_CB008954-C_SA_Robustness_with_three_dedicated_BWP_counters_check_and_cell_lock_and_unlock
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Set Library Search Order  CB011169_CB008954-C_SA_Robustness_with_three_dedicated_BWP_counters_check_and_cell_lock_and_unlock
    ...  CB011169_resources  AnalyzePRBs  ute_ue  vDU  vCU
    ...  AND  Set Test Variable  ${NR_CELL_ID}  15
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NOKIA_UE
    ...  AND  Set Test Variable  ${CELL_ALIAS}  NR_CELL_15
    ...  AND  Set Test Variable  ${ATTENUATION_VALUE}  ${30}
    ...  AND  Set Test Variable  ${BWP_PROFILE_DN_INITIAL}  MRBTS-XXX/NRBTS-8680/BWP_PROFILE-5
    ...  AND  Set Test Variable  ${BWP_PROFILE_DN_100MHZ}  MRBTS-XXX/NRBTS-8680/BWP_PROFILE-36
    ...  AND  Set Test Variable  ${BWP_PROFILE_DN_80MHZ}  MRBTS-XXX/NRBTS-8680/BWP_PROFILE-37
    ...  AND  Set Test Variable  ${BWP_PROFILE_DN_40MHZ}  MRBTS-XXX/NRBTS-8680/BWP_PROFILE-38
    ...  AND  Set Test Variable  ${MSG1_FREQ_START}  38
    ...  AND  Set Test Variable  ${NAMESPACE}  cran8680
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${PHONE_NUMBER}  0105
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro/rmnet_data
    ...  AND  Set Test Variable  ${MAX_UTF_LOGS_DELAY}  300s
    ...  AND  Set Test Variable  ${COLLECT_UE_LOGS}  False
    ...  AND  Create Ignored Alarms
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  TC Setup
    TC__CB011169_CB008954-C_SA_Robustness_with_three_dedicated_BWP_counters_check_and_cell_lock_and_unlock
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case


*** Keywords ***
Cloud Test Suite Setup
    Set Environment Variable  TAF_VDU_CLIENT_DISABLE_LOGGING  True
    Set Environment Variable  TAF_VCU_CLIENT_DISABLE_LOGGING  True
    Setup Ssh Credentials To Ocp Server
    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${suite_log_path} =  OperatingSystem.Join Path  ${OUTPUT DIR}  ${timestamp}_AP
    Create Directory  ${suite_log_path}
    Set Suite Variable  ${SUITE_LOG_PATH}  ${suite_log_path}
    Create Ignored Alarms
    Create Simulated Cells List
    Enable Cloud
    Setup Airphone


Setup Ssh Credentials To Ocp Server
    OperatingSystem.Run  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "10.44.249.132"
    OperatingSystem.Run  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "10.42.38.55"


Setup Airphone
    Call Ap Console Reboot
    Log  Waiting for Airphone to go on air after reboot...  console=True
    Sleep  120s  reason=Wait for state of HW to change after triggering reboot.
    Check Radios Availability Aic  timeout=500
    Wait For F1 Links To Be Available Aic
    cloud_bts_egate.Reach Onair Aic  check_edaemon_port=${True}  lua_cfg=${wts_cfg_file_path}  timeout=360
    ...  sim_cell_ids=${sim_cell_ids}  x2_setup_pass_regexp=ENB-.: X2AP Link with GNB-.*is up
    ...  wait_for_mib_and_sib=${False}  version_check_toggle=on
    Wait For Ng Link To Be Active Aic  timeout=300


Cloud Test Suite Teardown
    Stop Default Processes And Gather Logs Aic  output_dirpath=${SUITE_LOG_PATH}


Create Ignored Alarms
    ${ignored_alarms} =  Create List
    Set Suite Variable  ${IGNORED_ALARMS_VCU}  ${ignored_alarms}

    ${ignored_alarms} =  Create List
    Set Suite Variable  ${IGNORED_ALARMS_VDU}  ${ignored_alarms}


Create Simulated Cells List
    ${sim_cell_ids} =  Create List  1  2
    Set Suite Variable  ${SIM_CELL_IDS}  ${sim_cell_ids}


Report Test Case
    [Arguments]  ${name}=${TEST_NAME}  ${ca}=VRF_WRO2  ${testline}=${HOSTNAME}  ${build}=${VDU_SW_VERSION}
    ...  ${cu_build}=${VCU_SW_VERSION}  ${cu_caas_build}=${VCU_OCP_VERSION}  ${du_caas_build}=${VDU_OCP_VERSION}
    ...  ${label}=${LABEL}  ${tool}=WebEM  ${links}=${LOG_LINK}  ${qc_domain}=${QC_DOMAIN}  ${qc_project}=${QC_PROJECT}
    ...  ${qc_testlab_path}=Root\\Test_Sets\\Trunk\\VRF_WRO2\\VRF_WRO2_T02&T03\\CRT  ${qc_test_set_name}=CRT__WRO__CloudBTS
    ...  ${ap_build}=${AP_SW_VERSION}

    ${result} =  Set Variable If  '${TEST_STATUS}' == 'PASS'  passed  failed
    Report To RP  name=${name}  result=${result}  ca=${ca}  testline=${testline}  build=${build}
    ...  cu_build=${cu_build}  cu_caas_build=${cu_caas_build}  du_caas_build=${du_caas_build}
    ...  label=${label}  tool=${tool}  links=${links}  qc_domain=${qc_domain}  qc_project=${qc_project}
    ...  qc_testlab_path=${qc_testlab_path}  qc_test_set_name=${qc_test_set_name}  qc_test_instance_name=${TEST_NAME}
    ...  ap_build=${ap_build}  fhgw_build=${FHGW_SW_VERSION}
