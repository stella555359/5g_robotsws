*** Settings ***
Documentation    Suite description
...    Author:    Lin Weicheng
...    Maintainer:    Lin Weicheng

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot

Force Tags      CA_RAN_PZ_HAZ_1

*** Variables ***
&{5G_BTS10380}=        HW_ID=CB007605        site_mode=SA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1],"50":[1,1],"51":[1,1],"52":[1,1]}

#${LABEL}                      CLOUD_5G_CLASSICAL_SA_ASIL_ABIO_3AEQP_3AKQJ
${HOSTNAME}                   1_5_UTE5G136
${DISABLE_SYSLOG_CHECK}       ${False}
@{USER_SUSPICIOUS_PRINTS}     @{EMPTY}
${USE_REMOTE_NODE}            ${False}
@{CUSTOM_ALARMS}              4654    4655    61524    61652    61649    7312    7313    61030    61074
...     7107     7304     7305    7318     61666
@{CRITICAL_FAULTS}            10    1806    4341    4352    4383
${SHOULD_BE_REPORTED}         ${True}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Optus
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_ST

#upgrade
${5G_SOURCE_SW}=                SBTS23R3_ENB_0000_000724_000000
${5G_TARGET_SW}=                SBTS23R3_ENB_0000_000724_000000
${5G_TARGET_SW_PATH}=
...    /home/ute/Downloads/cloud/SBTS23R3_ENB_0000_000724_000000_release_BTSSM_downloadable_A54.zip
${REMOTE_NODE_UPDATE}=          ${False}
${USE_REMOTE_NODE}=             ${False}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}

${ONLINE_PARAMETER_DELTA}       ${CURDIR}${/}online_parameter.json
${SITE_RESET_DELTA}             ${CURDIR}${/}site_reset_parameter.json

*** Test Cases ***
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SW_UPGRADE_TEST
#    ...          test_iteration=3
#    ...          custom_alarms=${CUSTOM_ALARMS}
##    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          5g_source_sw=${5G_SOURCE_SW}
#    ...          5g_target_sw=${5G_TARGET_SW}
#    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
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
#    ...          qc_id=559182
#    ...          qc_project=${QC_PROJECT}
#
#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=20
#    ...          custom_alarms=${CUSTOM_ALARMS}
##    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=559183
#    ...          qc_project=${QC_PROJECT}
#
#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    OAM_RMOD_RESET
#    ...          test_iteration=20
#    ...          custom_alarms=${CUSTOM_ALARMS}
##    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=559184
#    ...          qc_project=${QC_PROJECT}
#
#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    OAM_BBMOD_RESET
#    ...          test_iteration=10
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=559185
#    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_NRCEL_LOCK
    ...          test_iteration=3
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=627246
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=1
    ...          delta_file=${ONLINE_PARAMETER_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=627245
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=1
    ...          delta_file=${SITE_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=627245
    ...          qc_project=${QC_PROJECT}
