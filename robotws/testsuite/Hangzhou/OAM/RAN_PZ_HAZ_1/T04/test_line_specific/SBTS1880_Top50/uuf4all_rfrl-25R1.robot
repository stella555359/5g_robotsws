*** Settings ***
Documentation   Test suite for basic UUF OAM Tests in loop

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        ../../test_resources/CM/TA_Call_For_Top50_PA.robot
Resource        ../../test_resources/CM/TA_Call_For_Top50_Module.robot
Resource        ../../test_resources/CM/Report_To_Reporting_Portal_With_ConfigID.robot

Force Tags      CA_VRF_HAZ1

*** Variables ***
${Check_Ipsec}                    ${False}
${TEST_ITERATION}=                  1
${UPDATE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}        20
${RU_RESET_TEST_ITERATION}          20
${RU_LOCK_TEST_ITERATION}           1
${BBMOD_TEST_ITERATION}             10
${BBMOD_LOCK_TEST_ITERATION}        1
${CELL_LOCK_TEST_ITERATION}         5
${CELL_BLOCK_TEST_ITERATION}        1
${COMMISSIONING_TEST_ITERATION}     1
${SHOULD_BE_REPORTED}           ${True}
${4G_SOURCE_SW}                 SBTS24R1_ENB_0000_001516_000009
${4G_TARGET_SW}                 SBTS25R1_ENB_0000_000419_000007
${USE_TEST_PACKAGES}            ${True}
${RESTORE_TO_TARGET_SW}         ${False}

@{CUSTOM_ALARMS}                7220  61510  61618  61074  4654  4655  61649  61524
    ...    61652  4298  6322  4681  4592  62003  6134  7509   6202
@{CRITICAL_FAULTS}              1907  1900  1902  1906  1920  4527  10
#${LABEL}                         CLOUD_SRAN_L_1ASIB_3ABIA_1ASIB_1ABIA_3AHEGC_3AHPDA_3AHHB_3AZNA_1880
#${HOSTNAME}                     10_5_5G-1881-4G-1880_MRBTS-1880
${LABEL}                        CLOUD_SRAN_L_1880_2ASIA_4ABIA_3AHEGC_3AHPDA_3AZNA_3AHHB
${HOSTNAME}                     10_5_5G-1881-4G-1880_MRBTS-1880    #10_5_UTESRAN1880
${SCOUT_HOSTNAME}               10_5_5G-1881-4G-1880_MRBTS-1880
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
    ...          qc_project=RAN_VRF
    ...          qc_id=117595
    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
#    ...          case_name=[1.0] SWM_Sofware_Upgrade_Rollback_via_WebEM
#    ...          qc_id=83558
#    ...          build=${4G_TARGET_SW}
#    ...          parameter_1=${4G_SOURCE_SW}
#    ...          testline=${HOSTNAME}
#    ...          status=${LOOP_RESULTS}
#    Top50_TA_Call    SBTS_ID=1880

    [Teardown]   Run Keyword If Test Failed   Set Test Failed

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Tags]   reset
#    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=117594
    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    Top50_TA_Call    SBTS_ID=1880

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
    ...          qc_project=RAN_VRF
    ...          qc_id=117591
    ...          should_be_reported=${SHOULD_BE_REPORTED}


E2E_TL_Capacity_Module_Lock_Unlock
    [Tags]   bbmodlock
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    BBMOD_LOCK_UNLOCK
    ...          test_iteration=${BBMOD_LOCK_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=xxxxx
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
    ...          qc_project=RAN_VRF
    ...          qc_id=117596
    ...          should_be_reported=${SHOULD_BE_REPORTED}


E2E_TL_RU_Lock_Unlock
    [Tags]   rmodlock
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    RMOD_LOCK_UNLOCK
    ...          test_iteration=${RU_LOCK_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=xxxxx
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
    ...          qc_project=RAN_VRF
    ...          qc_id=117597
    ...          should_be_reported=${SHOULD_BE_REPORTED}


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]   cellblock
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_LNCEL_BLOCK
    ...          test_iteration=${CELL_BLOCK_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=xxxxx
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
    ...          qc_project=RAN_VRF
    ...          qc_id=117593
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
    ...          qc_project=RAN_VRF
    ...          qc_id=117592
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
    ...          qc_project=RAN_VRF
    ...          qc_id=117602

E2E_TL_call_with_OAM_KPI
    [Tags]   call
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    Top50_TA_Call    SBTS_ID=1880
    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
    ...          case_name=E2E_TL_L3Call_After_UUF
    ...          qc_id=83565
    ...          build=${4G_TARGET_SW}
    ...          parameter_1=${4G_TARGET_SW}
    ...          testline=${HOSTNAME}
    ...          status=passed

*** Keywords ***
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
