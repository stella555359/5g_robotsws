*** Settings ***
Documentation    Suite description
...    Author:    Wu Amy;Sheng Haoyun-Lyle;Zhou Qiang;Lou Xingxin;Ding Lisa;Wu Nick
...    Maintainer:    Wu Amy;Sheng Haoyun-Lyle;Zhou Qiang;Lou Xingxin;Ding Lisa;Wu Nick

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/bts_common_interface.robot
Variables   ./env.py

*** Variables ***
&{5G_CB007409_UHIE_3_Cell}=        peak_rate_config={"301":[110,20],"302":[110,20],"303":[110,20]}
...   HW_ID=CB007409    site_mode=SA    ONAIR_TIME=15 min    GG=110:97;99:123

${LABEL}                      CLOUD_RF_AIR_B4_CRT2_1064 #testline type
${HOSTNAME}                   1_5_CLOUD064 #testline
${REMOTE_VM_IP}               ${None}
${REMOTE_MPLANE}              ${None}
@{CUSTOM_ALARMS}              @{EMPTY}
${SHOULD_BE_REPORTED}         ${False}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Generic
${QC_PROJECT}=                RAN_ST

#upgrade
${5G_SOURCE_SW}=                SBTS00_ENB_9999_230402_000011
${5G_TARGET_SW}=                SBTS00_ENB_9999_230405_000016
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS00_ENB_9999_230402_000011
${4G_TARGET_SW}=                SBTS00_ENB_9999_230405_000016
${4G_TARGET_SW_PATH}=           ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}

# Delta Commissioning Parameters
${TEST_ITERATION}=              1
@{CRITICAL_FAULTS}=             @{EMPTY}
${USE_REMOTE_NODE}=             ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${QC_DOMAIN}=                   MN_RAN_ST
${TEST_QC_ID}=                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${ONLINE_PARAS}=     {"2493":[{"dist_name":"xxxxx","para_name":"xxxx","para_value":"xxxx"}]}
# network_type: NR; LTE; 3G; 2G
${RAT_RESET_PARAS}=    {"2493":{"network_type":"LTE",
...    "parameter":[{"dist_name":"xxxx","para_name":"xxxx","para_value":"xxxxx"}]}}
${SITE_RESET_PARAS}=    {"2493":[{"dist_name":"xxxx","para_name":"xxxx","para_value":"xxxx"}]}

*** Test Cases ***
Onair_Switch Configuration
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5G_CB007409_UHIE_3_Cell
    Verify All Cells OnAir
    [Teardown]    Testcase Basic Postcondition

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_RMOD_RESET
    ...          test_iteration=20
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=500848
    ...          qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=20
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
    ...          qc_id=192834
    ...          qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_BBMOD_RESET
    ...          test_iteration=20
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
    ...          qc_id=439835
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_NRCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
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


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    OAM_LNCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_LTE_And_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_LNCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${False}
    OAM_NRCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
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

E2E_TL_Delta_Commissioning
    [Setup]   Create Nodes Parameters Init     config_id=xxxx
    ${SHOULD_NOT_BE_REPORTED}    Set Test Variable    ${False}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${online_paras}    Evaluate    ${ONLINE_PARAS}
        ${site_reset_paras}    Evaluate    ${SITE_RESET_PARAS}
        ${rat_reset_para}    Evaluate    ${RAT_RESET_PARAS}
        ${online_delta_plan}    Generate Delta Plan    ${online_paras["${bts_id}"]}
        ${site_reset_delta_plan}    Generate Delta Plan    ${site_reset_paras["${bts_id}"]}
        ${rat_reset_delta_plan}    Generate Delta Plan    ${rat_reset_para["${bts_id}"]["parameter"]}
        ${rat_network_type}    Set Variable    ${rat_reset_para["network_type"]}
        Set Test Variable    ${ONLINE_DELTA_PLAN}    ${online_delta_plan}
        Set Test Variable    ${SITE_RESET_DELTA_PLAN}    ${site_reset_delta_plan}
        Set Test Variable    ${RAT_RESET_DELTA_PLAN}    ${rat_reset_delta_plan}
        Set Test Variable    ${REMOTE_VM_IP}    ${NODE_CFG["${bts_id}"]["host_ip"]}
        ${host_ip}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        Set Test Variable    ${REMOTE_MPLANE}    ${host_ip}
        E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
        E2E_TL_Delta_Commissioning_With_Site_Reset_Required
        Run Keyword If    "${rat_network_type}"=="NR"    E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
        ...    ELSE IF    "${rat_network_type}"=="LTE"   E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
        ...    ELSE IF    "${rat_network_type}"=="3G"    E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
        ...    ELSE IF    "${rat_network_type}"=="2G"    E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    END

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION}
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

*** Keywords ***
E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${ONLINE_DELTA_PLAN}
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

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${SITE_RESET_DELTA_PLAN}
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
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${RAT_RESET_DELTA_PLAN}
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

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_LTE_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${RAT_RESET_DELTA_PLAN}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}

E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_WCDMA_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${RAT_RESET_DELTA_PLAN}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}

E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_GSM_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${RAT_RESET_DELTA_PLAN}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}

