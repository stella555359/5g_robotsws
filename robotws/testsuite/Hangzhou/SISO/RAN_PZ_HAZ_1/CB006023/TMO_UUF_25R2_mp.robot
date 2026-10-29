*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     OperatingSystem
Variables   ./env.py
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Force Tags  CA_VRF_HAZ1  SBTS00  RAN_5G


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{TMO_B}=
...   peak_rate_config={"86":[190,10],"87":[190,10],"88":[190,10]}
...   HW_ID=Conf#12 Megafone:     site_mode=SA    ONAIR_TIME=40min

#${GLO_SCOUT_TESTLINE_NAME}=    1_5_UTE5G163
#
#${INIT_SW_VERSION}    {'10424': 'SBTS24R2_ENB_0000_000092_000000'}
#${TARGET_SW_VERSION}    {'10424': 'SBTS00_ENB_9999_231207_000009'}
#${RB_TO_TARGET}    YES
#${YAFT}    YES
#${force_recommission}    True
#
#${RU}    3*AEHC
#${SA_OR_NSA}
#${TDD_OR_FDD}    TDD
#${HW_ID}    ASIB+ABIO+3*AEHC+6*AHFIB
#${CHECK_CLIMATECONTROLPROFILING_DEFAULT}    ${False}
#
#${GGMAP}   {'L1202707603': {'1':'3.6.6','2':'3.6.8','3':'3.7.6','4':'3.3.6'},
#...    'L1213010417': {'1':'3.6.1','7':'3.6.3'},'L1213010383': {'1':'3.7.1','7':'3.3.1'}}
#
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Unstable eCPRI Link Detected
#
#${IS_SUPPORTED_CALL}      ${False}
#
#${LABEL}                      CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_ASIBR_ABIOB1_3xAEHC_FULLRACK
#${HOSTNAME}                   1_5_UTE5G163
#${DISABLE_SYSLOG_CHECK}       ${False}
#@{USER_SUSPICIOUS_PRINTS}     @{EMPTY}
#${REMOTE_VM_IP}               ${None}
#${REMOTE_MPLANE}              ${None}
#${USE_REMOTE_NODE}            ${False}
#@{CUSTOM_ALARMS}              @{EMPTY}
#@{CRITICAL_FAULTS}            @{EMPTY}
##${SHOULD_BE_REPORTED}         ${False}
#${REPORT_COMMENT}=            ${None}
#@{CUSTOMERS_LIST}             TMO US
#${QC_DOMAIN}=                 MN_RAN
#${QC_PROJECT}=                RAN_VRF
#
#${TEST_ITERATION}=              1
#${SHOULD_BE_REPORT}=          ${True}
#
##upgrade
#${5G_SOURCE_SW}=                SBTS00_ENB_9999_240826_000002
#${5G_TARGET_SW}=                SBTS00_ENB_9999_240826_000009
#${5G_TARGET_SW_PATH}=           ${None}
#${4G_SOURCE_SW}=                SBTS00_ENB_9999_240826_000002
#${4G_TARGET_SW}=                SBTS00_ENB_9999_240826_000009
#${4G_TARGET_SW_PATH}=           ${None}
#${USE_BUILDS_STORAGE}=          ${False}
#${RESTORE_TARGET_SW}=           ${True}
#${PERFORM_UBOOT_DOWNGRADE}=     ${True}
#
#${REMOTE_NODE_UPDATE}=      @{EMPTY}
#${DOWNLOAD_PATH}=     /home/ute/Downloads
#
#${RP_CA}                      VRF_SiSo
#${RP_LOCATION}                VRF_HAZ1
#${RP_ORGANIZATION}            VRF_HAZ1_T04
#
${UPGRADE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}         20
${RU_RESET_TEST_ITERATION}           20
${BBMOD_TEST_ITERATION}              20
${CELL_LOCK_TEST_ITERATION}          3
${COMMISSIONING_TEST_ITERATION}      1
${USE_TEST_PACKAGES}            True
${RESTORE_TO_TARGET_SW}         True

${REPORT}                     ${True}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             TMO US
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ1
${RP_ORGANIZATION}            VRF_HAZ1_T04
${INITIAL_SW}                 SBTS00_ENB_9999_250530_000010
${TARGET_SW}                  SBTS00_ENB_9999_250531_000015

&{NODE1}                      testline_object=${tl.gnbs[0]}
...                           source_sw=${INITIAL_SW}
...                           target_sw=${TARGET_SW}
@{NODES}                      ${NODE1}
${TEST_ITERATION}=              1
@{CUSTOM_ALLOWED_ALARMS}         4654    4655    61524    61652    61649    61030    61074
@{TEMPORARY_ALLOWED_FAULTS}      4589

*** Test Cases ***
#Switch configuration
#    [Tags]    QC_    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=TMO_B
#    Verify All Cells OnAir
#    [Teardown]    Testcase Basic Postcondition

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    [Tags]    QC_59145    QCD_MN_RAN   QCP_RAN_VRF
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=1
#    ...          custom_alarms=${tl_config.DEFAULT_ADDITIONAL_ALLOWED_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORT}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=59145
#    ...          qc_project=${QC_PROJECT}
#
#
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    [Timeout]   24h
#    [Tags]    QC_33157    QCD_MN_RAN   QCP_RAN_VRF
#    UUF4ALL_SW_UPGRADE_TEST
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${tl_config.ADDITIONAL_ALLOWED_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORT}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          5g_source_sw=${5G_SOURCE_SW}
#    ...          5g_target_sw=${5G_TARGET_SW}
#    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
#    ...          4g_source_sw=${4G_SOURCE_SW}
#    ...          4g_target_sw=${4G_TARGET_SW}
#    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
#    ...          use_builds_storage=${USE_BUILDS_STORAGE}
#    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
#    ...          remote_node_update=${REMOTE_NODE_UPDATE}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          use_test_packages=${False}
#    ...          download_path=${DOWNLOAD_PATH}
#    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=33157
#    ...          qc_project=${QC_PROJECT}


#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    [Tags]    QC_59145   QCD_MN_RAN   QCP_RAN_ST
#    OperatingSystem.remove file      /home/ute/.netrc
#    E2E TL ACTIVATION RESET TEST   ${NODES}  ${NODE1}   ${TEST_ITERATION}    customers_list=${customers_list}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=59145
#    ...          qc_project=${QC_PROJECT}


E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_188663   QCD_MN_RAN   QCP_RAN_ST
    OperatingSystem.remove file      /home/ute/.netrc
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=188663
    ...          use_testpackage=${USE_TEST_PACKAGES}
    ...          restore_to_target_sw=${RESTORE_TO_TARGET_SW}


