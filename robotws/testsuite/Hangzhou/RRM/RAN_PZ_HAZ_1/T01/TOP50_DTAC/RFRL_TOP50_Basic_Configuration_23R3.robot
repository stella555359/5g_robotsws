*** Settings ***
Documentation   Test suite for basic UUF OAM Tests in loop

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot


Force Tags      CA_RAN_PZ_HAZ_1

*** Variables ***
${UPDATE_TEST_ITERATION}            1
${SITE_RESET_TEST_ITERATION}        20
${RU_RESET_TEST_ITERATION}          20
${BBMOD_TEST_ITERATION}             10
${CELL_LOCK_TEST_ITERATION}         3
${COMMISSIONING_TEST_ITERATION}     1
${SHOULD_BE_REPORTED}           ${True}
${5G_SOURCE_SW}                 SBTS22R1_ENB_0000_002003_000000
${5G_TARGET_SW}                 SBTS00_ENB_9999_230425_000018
${USE_TEST_PACKAGES}            ${False}
${RESTORE_TO_TARGET_SW}         ${False}


@{CUSTOM_ALARMS}                4309  4406  1811  7220  62003  7509  61510  61618  61074  4654  4655  61649  61524
    ...    61652  6450  7313    7115    6134    6129    6263    6351
@{CRITICAL_FAULTS}              1907  1900  1902  1906  1920  4527
${LABEL}                        CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_ABILB2_AHPDA_RFS
${HOSTNAME}                     10_5_UTESRAN001T5082
@{CUSTOMERS_LIST}               Telenor DTAC Thailand
${USE_BUILDS_STORAGE}           ${False}
${ONLINE_PARAMETER_DELTA}       ${CURDIR}${/}delta_files${/}online_parameter.json
${SITE_RESET_DELTA}             ${CURDIR}${/}delta_files${/}site_reset_parameter.json
${UPDATE_TEST_FAILED}            ${False}

*** Test Cases ***
E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    QC_558089       QCD_MN_RAN      QCP_RAN_ST
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_NRCEL_LOCK
    ...          test_iteration=${CELL_LOCK_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          use_remote_node=False
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=431541


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    QC_558095       QCD_MN_RAN      QCP_RAN_ST
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_BBMOD_RESET
    ...          test_iteration=${BBMOD_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          use_remote_node=False
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=266861

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    QC_558098       QCD_MN_RAN      QCP_RAN_ST
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    OAM_RMOD_RESET
    ...          test_iteration=${RU_RESET_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          use_remote_node=False
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=266858

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
      [Tags]    QC_558096       QCD_MN_RAN      QCP_RAN_ST
    Run Keyword If  ${UPDATE_TEST_FAILED}  Fail
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          use_remote_node=False
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=266860

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
    ...          use_remote_node=False
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=266866
    ...          should_be_reported=False


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
    ...          use_remote_node=False
    ...          qc_domain=MN_RAN
    ...          qc_project=RAN_ST
    ...          qc_id=266866
    ...          should_be_reported=False


