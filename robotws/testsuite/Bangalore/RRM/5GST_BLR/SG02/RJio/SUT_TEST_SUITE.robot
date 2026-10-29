*** Settings ***
Documentation
...   maintainer:  arunkumar.a
...   contact: arunkumar.a@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot
Resource        ./Resources_Rjio/robot/UE_keywords.robot
Resource        ./Resources_Rjio/robot/Common_keywords.robot

Force Tags     CA_VRF_BLR1  PY39

*** Variables ***
${UUF_TEST_ITERATION}=                        3
${SITE_RESET_TEST_ITERATION}=                 20
${RU_RESET_TEST_ITERATION}=                   10
${NR_LOCK_TEST_ITERATION}=                    10
${DELTA_COMMISSION_TEST_ITERATION}=           1
${L3_Call_TEST_ITERATION}=                    1
@{CUSTOM_ALARMS}=               4298  4694  6150  6351  7509  7513  8150  
...    61631  4527  7307  62003  7312  4592  7313   
${REMOTE_VM_IP}=                ${None}  
${REMOTE_MPLANE}=               ${None}  
${LABEL}=                       ${None}  
${HOSTNAME}=                    ${None}  
@{CRITICAL_FAULTS}=             10   4383  6450   
${SHOULD_BE_REPORTED}=          ${True}  
@{CUSTOMERS_LIST}=              Reliance India 
${5G_SOURCE_SW}=                ${None}  
${5G_TARGET_SW}=                ${None}  
${5G_TARGET_SW_PATH}=           ${None}  
${4G_SOURCE_SW}=                ${None}  
${4G_TARGET_SW}=                ${None}  
${4G_TARGET_SW_PATH}=           ${None}  
${REMOTE_NODE_UPDATE}=          ${False}  
${USE_REMOTE_NODE}=             ${False}  
${DOWNLOAD_PATH}=               /home/ute/swbuilddownloadpath
${USE_BUILDS_STORAGE}=          ${False}  
${RESTORE_TARGET_SW}=           ${True}  
${PERFORM_UBOOT_DOWNGRADE}=     ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}  
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}  
${REPORT_COMMENT}=              ${None}  
${testline_name}=               ${None}
${GIT_LAB_LOCATION}=            ../RJio/JSON_folder/${testline_name}/
${ONLINE_PARAMETER_DELTA}=      ${GIT_LAB_LOCATION}Online_Paramter_delta.json 
${SITE_RESET_DELTA}=            ${GIT_LAB_LOCATION}Full_Comission_With_site_reset.json   
${NR_RAT_RESET_DELTA}=          ${GIT_LAB_LOCATION}NR_Rat_reset.json  
${LTE_RAT_RESET_DELTA}=         ${None}  
${WCDMA_RAT_RESET_DELTA}=       ${None}
${GSM_RAT_RESET_DELTA}=         ${None}
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID}=                  ${None}  
${QC_PROJECT}=                  RAN_ST
#    EXAMPLE PDU Variable
#    &{RU1}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{3, }  version=8221-1
#    &{RU2}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{4, }  version=8221-1
#    &{RU3}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{5, }  version=8221-1
#    @{PDU_LIST}=               &{RU1}  &{RU2}  &{RU3}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF  
${EMAIL_RECIPIENTS}=            arunkumar.a@nokia.com  
${MUMIN_CONFIG_FILE}=           ${None}   
${VIRTUALENV_DIR}=              ${None}   
${SERIAL_CONSOLE}=              ${False}  
${local_node_attach_test_keyword}=    Attach_voice_data_transfer_L3Call

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00   
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=450  # Inter-release SW activation downtime without firmware update
    ...                                       kpi2b=685  # Inter-release SW activation downtime with firmware update
    ...                                       kpi2c=400  # Intra-release SW activation downtime without firmware update
    ...                                       kpi2d=450  # Intra-release SW activation downtime with firmware updates
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    Common_keywords.RollBack if passive sw is source build and check onair state
    Common_keywords.Configure_QC_ID_for_Reportng_portal           
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UUF_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${False}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          use_test_packages=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00  
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=450
    ...                                       kpi2b=685
    ...                                       kpi2c=400
    ...                                       kpi2d=450
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${L3_Call_TEST_ITERATION}
    ...          local_node_attach_test_keyword=${local_node_attach_test_keyword}
    ...          remote_node_attach_test_keyword=${None}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          use_test_packages=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00 
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=235  # Manual RU reset downtime
    ...                                       kpi51b=235  # Manual RU reset downtime
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    OAM_RMOD_RESET
    ...          test_iteration=${RU_RESET_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00    RERUN_1
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=41   # Manual lock cell duration
    ...                                       kpi16b=290   # Manual unlock cell duration
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    OAM_NRCEL_LOCK
    ...          test_iteration=${NR_LOCK_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

TC47 Performing parameter changes which require BTS restart in RJio configuration
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00  
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=${DELTA_COMMISSION_TEST_ITERATION}
    ...          delta_file=${SITE_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00   
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=${DELTA_COMMISSION_TEST_ITERATION}
    ...          delta_file=${NR_RAT_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00 
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=330  # Manual site reset downtime
    ...                                       kpi1b=210  # Manual site reset downtime
    ...                                       kpi1c=280  # Manual site reset downtime
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

TC43 Performing Online Parameter Changes to enable sleeping cell feature in RJio configuration
    [Timeout]   24h
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00  
    Common_keywords.Configure_QC_ID_for_Reportng_portal 
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=${DELTA_COMMISSION_TEST_ITERATION}
    ...          delta_file=${ONLINE_PARAMETER_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

Rjio_E2E_63_Mobility_UE_based_ANR
    [Tags]   Test_suite   
    Pass Execution  message=Empty test case
Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
    [Tags]   CDRT_SBTS24R2  CDRT_SBTS24R1  CDRT_SBTS00 
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
[CB007511]Deepsleep mode for energy efficiency based on CB007511
    [Tags]   24R2  24R1  
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
Robustness Deepsleep mode for energy efficiency based on CB007511
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
Regression Scenario for Sleeping Cell Detection when GPS signal is recovered after longer interruption
    [Tags]   24R2  24R1
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
RJIO_KPI & counter verification for VoNR traffic
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
RJIO_KPI & counter verification with multiple slices
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
RJIO_RACH success rate verification on multiple slices
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
RJIO_Throughput verification on slicing configuration
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case


    

    
