*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Variables   ./env.py
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot

Force Tags  CA_VRF_HAZ1  SBTS00  RAN_5G


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{TMO_B}=
...   peak_rate_config={"86":[190,10],"87":[190,10],"88":[190,10]}
...   HW_ID=Conf#12 Megafone:     site_mode=SA    ONAIR_TIME=40min

${GLO_SCOUT_TESTLINE_NAME}=    1_5_UTE5G163

${INIT_SW_VERSION}    {'10424': 'SBTS24R2_ENB_0000_000092_000000'}
${TARGET_SW_VERSION}    {'10424': 'SBTS00_ENB_9999_231207_000009'}
${RB_TO_TARGET}    YES
${YAFT}    YES
${force_recommission}    True

${RU}    3*AEHC
${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${HW_ID}    ASIB+ABIO+3*AEHC+6*AHFIB
${CHECK_CLIMATECONTROLPROFILING_DEFAULT}    ${False}

${GGMAP}   {'L1202707603': {'1':'3.6.6','2':'3.6.8','3':'3.7.6','4':'3.3.6'},
...    'L1213010417': {'1':'3.6.1','7':'3.6.3'},'L1213010383': {'1':'3.7.1','7':'3.3.1'}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Unstable eCPRI Link Detected

${IS_SUPPORTED_CALL}      ${False}

${LABEL}                      CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_ASIBR_ABIOB1_3xAEHC_FULLRACK
${HOSTNAME}                   1_5_UTE5G163
${DISABLE_SYSLOG_CHECK}       ${False}
@{USER_SUSPICIOUS_PRINTS}     @{EMPTY}
${REMOTE_VM_IP}               ${None}
${REMOTE_MPLANE}              ${None}
${USE_REMOTE_NODE}            ${False}
@{CUSTOM_ALARMS}              @{EMPTY}
@{CRITICAL_FAULTS}            @{EMPTY}
#${SHOULD_BE_REPORTED}         ${False}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             TMO US
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF

${TEST_ITERATION}=              1
${SHOULD_BE_REPORT}=          ${True}

#upgrade
${5G_SOURCE_SW}=                SBTS25R2_ENB_0000_000503_000000
${5G_TARGET_SW}=                SBTS25R2_ENB_0000_000504_000000
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS25R2_ENB_0000_000503_000000
${4G_TARGET_SW}=                SBTS25R2_ENB_0000_000504_000000
${4G_TARGET_SW_PATH}=           ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}

${REMOTE_NODE_UPDATE}=      @{EMPTY}
${DOWNLOAD_PATH}=     /home/ute/Downloads

${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ1
${RP_ORGANIZATION}            VRF_HAZ1_T04


*** Test Cases ***
Switch configuration
    [Tags]    QC_    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=TMO_B
    Verify All Cells OnAir
    [Teardown]    Testcase Basic Postcondition

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_146106    QCD_MN_RAN   QCP_RAN_VRF
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=1
    ...          custom_alarms=${tl_config.DEFAULT_ADDITIONAL_ALLOWED_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=146106
    ...          qc_project=${QC_PROJECT}


E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_146103    QCD_MN_RAN   QCP_RAN_VRF
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${tl_config.ADDITIONAL_ALLOWED_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORT}
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
    ...          qc_id=146103
    ...          qc_project=${QC_PROJECT}
