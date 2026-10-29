*** Settings ***
Documentation   Test suite for basic UUF OAM Tests in loop

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        ../../test_resources/CM/TA_Call_For_Top50_Module.robot
#Resource        ../../test_resources/CM/TA_Call_For_Top50_PA.robot
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
${5G_SOURCE_SW}                 SBTS24R1_ENB_0000_001516_000009
${5G_TARGET_SW}                 SBTS00_ENB_9999_241119_000005
${USE_TEST_PACKAGES}            ${True}
${RESTORE_TO_TARGET_SW}         ${False}

@{CUSTOM_ALARMS}                7220  62003  7509  61510  61618  61074  4654  4655  61649  61524  61652  7313  7305
@{CRITICAL_FAULTS}              1907  1900  1902  1906  1920  4527  6450
#${LABEL}                        CLOUD_SRAN_N_1ASIL_2ABIO_3AEQN_3AHEGC_3AZNA_3AHPDA_1881
#${HOSTNAME}                     10_5_5G-1881-4G-1880_MRBTS-1881
${LABEL}                        CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
${HOSTNAME}                     10_5_5G-1881-4G-1880_MRBTS-1881
${SCOUT_HOSTNAME}               10_5_5G-1881-4G-1880_MRBTS-1881
@{CUSTOMERS_LIST}               Optus
${USE_BUILDS_STORAGE}           ${False}
${ONLINE_PARAMETER_DELTA}       delta_files/online_parameter.json
${SITE_RESET_DELTA}             delta_files/site_reset_parameter.json
${NR_RAT_RESET_DELTA}           delta_files/nr_rat_reset.json
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
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...          use_test_packages=${USE_TEST_PACKAGES}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=33080
    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
#    ...          case_name=[1.0] SWM_Sofware_Upgrade_Rollback_via_WebEM
#    ...          qc_id=33080
#    ...          build=${5G_TARGET_SW}
#    ...          parameter_1=${5G_SOURCE_SW}
#    ...          testline=${HOSTNAME}
#    ...          status=${LOOP_RESULTS}
#    Top50_TA_Call    SBTS_ID=1881    UE_UI_Version=MATE40PROUI1.0
    Top50_TA_Call    SBTS_ID=1881

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
    ...          qc_project=RAN_VRF
    ...          qc_id=33081
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    Top50_TA_Call    SBTS_ID=1881

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
    ...          qc_id=33077
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
    ...          qc_id=33078
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

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]   cell
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_NRCEL_LOCK
    ...          test_iteration=${CELL_LOCK_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=33076
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]   cellblock
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_NRCEL_BLOCK
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
    ...          qc_id=33075
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
    ...          qc_id=33079
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]   NR
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
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
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_VRF
    ...          qc_id=33082

E2E_TL_call_with_OAM_KPI
    [Tags]   call
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    Top50_TA_Call    SBTS_ID=1881
    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
    ...          case_name=E2E_TL_L3Call_After_UUF
    ...          qc_id=33074
    ...          build=${5G_TARGET_SW}
    ...          parameter_1=${5G_TARGET_SW}
    ...          testline=${HOSTNAME}
    ...          status=passed

*** Keywords ***
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
