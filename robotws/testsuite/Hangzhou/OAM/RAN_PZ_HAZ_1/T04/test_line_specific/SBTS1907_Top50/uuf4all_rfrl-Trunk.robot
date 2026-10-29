*** Settings ***
Documentation   Test suite for basic UUF OAM Tests in loop

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        ../../test_resources/CM/TA_Call_For_Top50_PA.robot
Resource        ../../test_resources/CM/TA_Call_For_Top50_Module.robot
Resource        ../../test_resources/CM/Report_To_Reporting_Portal_With_ConfigID.robot

Force Tags      CA_RAN_PZ_HAZ_1

*** Variables ***
${Check_Ipsec}                    ${True}
${TEST_ITERATION}=                  1
${UPDATE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}        20
${RU_RESET_TEST_ITERATION}          20
${BBMOD_TEST_ITERATION}             10
${CELL_LOCK_TEST_ITERATION}        10
${COMMISSIONING_TEST_ITERATION}    2
${SHOULD_BE_REPORTED}           ${False}
${4G_SOURCE_SW}                 SBTS23R3_ENB_0000_001563_000000
${4G_TARGET_SW}                 SBTS23R4_ENB_0000_000620_000026
${USE_TEST_PACKAGES}            ${True}
${RESTORE_TO_TARGET_SW}         ${True}

@{CUSTOM_ALARMS}                7220  62003  7509  61510  61618  61074  4654  4655  61649  61524
    ...    61652 4298 6322 4681  4592  6134
@{CRITICAL_FAULTS}              1907  1900  1902  1906  1920  4527
#${LABEL}                        CLOUD_SRAN_L_1ASIL_1ABIA_1ABIO_3AKNB_3AHEGHA_3AHPDA_1907
#${HOSTNAME}                     10_5_5G-1906-4G-1907_MRBTS-1907
${LABEL}                        CLOUD_SRAN_L_1907_1ASIL_1ABIO_3AHPDA_3AHEGHA
${HOSTNAME}                     10_5_5G-1906-4G-1907_MRBTS-1907
${SCOUT_HOSTNAME}               10_5_5G-1906-4G-1907_MRBTS-1907
@{CUSTOMERS_LIST}               Optus
${USE_BUILDS_STORAGE}           ${False}
${ONLINE_PARAMETER_DELTA}       delta_files/online_parameter.json
${SITE_RESET_DELTA}             delta_files/site_reset_parameter.json
${LTE_RAT_RESET_DELTA}          delta_files/lte_rat_reset.json
${UPDATE_TEST_FAILED}           ${False}

${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${USE_REMOTE_NODE}=             ${True}
${RP_CA}                        VRF_OAM
${RP_LOCATION}                  VRF_HAZ1
${RP_ORGANIZATION}              VRF_HAZ1_T04

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Tags]   upgrade
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...          use_test_packages=${USE_TEST_PACKAGES}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=684931
    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
#    ...          case_name=[1.0] SWM_Sofware_Upgrade_Rollback_via_WebEM
#    ...          qc_id=684931
#    ...          build=${4G_TARGET_SW}
#    ...          parameter_1=${4G_SOURCE_SW}
#    ...          testline=${HOSTNAME}
#    ...          status=${LOOP_RESULTS}
    Top50_TA_Call    SBTS_ID=1907

    [Teardown]   Run Keyword If Test Failed   Set Test Failed

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Tags]   reset
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=684932
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]   bbmod
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_BBMOD_RESET
    ...          test_iteration=${BBMOD_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=512044
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]   rmod
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_RMOD_RESET
    ...          test_iteration=${RU_RESET_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=511938
    ...          should_be_reported=${SHOULD_BE_REPORTED}


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]   cell
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_LNCEL_LOCK
    ...          test_iteration=${CELL_LOCK_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=511939
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]   online
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=${COMMISSIONING_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          delta_file=${ONLINE_PARAMETER_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=511940
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]   sitereset
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=${COMMISSIONING_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          delta_file=${SITE_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=511941
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]   LTE
    DELTA_COMMISSIONING_WITH_LTE_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${LTE_RAT_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=xxx

E2E_TL_call_with_OAM_KPI
    [Tags]   call
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    Top50_TA_Call    SBTS_ID=1907
    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
    ...          case_name=E2E_TL_L3Call_After_UUF
    ...          qc_id=511942
    ...          build=${4G_TARGET_SW}
    ...          parameter_1=${4G_TARGET_SW}
    ...          testline=${HOSTNAME}
    ...          status=passed

*** Keywords ***
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
