*** Settings ***
Documentation
...  | taf.rfrl.csv4all library  | CSV_ULM's implementation for UUF test cases on customer-specific site configurations.  |
...  | Links | https://nokia.sharepoint.com/sites/uuf4all/SitePages/UUF-test-strategy.aspx  |
...  |        | https://wrgitlab.ext.net.nokia.com/RAN/resource-packages/taf.rfrl.csv4all/-/blob/main/taf/rfrl/csv4all/csv_example.robot  |
...  | Team:         |  CSV Ulm                                     |
...  | Contact:      |  I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com    |


Library    Collections
Library    OperatingSystem
Library    String

Library    taf.ue
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Library    taf/rfrl/csv4all/CSV4AllTestCases.py

Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/reporting.robot
Resource    ../../../SyVe/resources/syve_testline.robot
Resource    ../../../SyVe/resources/sqd64/Attach_and_Data_Transfer.robot
Resource    ../../../SyVe/resources/scf_info.robot
Resource    ../../../SyVe/resources/UEs_handler.robot
Resource    ../resources/commonKeywords.robot
Variables   qc_mapping.yaml

Suite Setup       CSV4ALL with RFRL Suite Setup
Suite Teardown    CSV4ALL with RFRL Suite Teardown
Test Setup        CSV4ALL with RFRL Tests Setup
Test Teardown     CSV4ALL with RFRL Tests Teardown


*** Variables ***
${RP_CA}                    VRF_RRM
${RP_LOCATION}              VRF_ULM
${RP_ORGANIZATION}          VRF_ULM_T03
${qc_domain}                MN_RAN
${EMAIL_RECIPIENTS}         None
${LABEL}=                   ULM02_E2E_ASIB_ABIA_ABIO_ABIO_3xAHEGHA_3xAEQQ_3xAHPMDB    # ULM02_E2E_ASIB_ABIO_ASIA_3xABIA_2xFXED_2xFRHC_FRMC_2xARGA
${RDC_CONFIG}=              ${CURDIR}/mumin_config_file.yaml    # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
@{CRITICAL_FAULTS}          7509    #EN DSS Setup Failure - Max EN DSS Counter Value reached
${ONLINE_PARAMETER_DELTA}   ${CURDIR}/DELTA_SCF.json
${SITE_RESET_DELTA}         ${None}
${DT_DL}                    DT_DL
${DT_UL}                    DT_UL
${DL_RATE}                  20
${UL_RATE}                  10
${TCP_DL_RATE}              550
${TCP_UL_RATE}              155
${SOURCE_SW_VERSION}        ${EMPTY}
${TARGET_SW_VERSION}        ${EMPTY}
${RESTORE_TO_TARGET_SW}     ${False}
${SOURCE_ORU_FW_VERSION}=   ${EMPTY}   # e.g. value '0204'
${SOURCE_ORU_FW_PACKAGE}=   FJ-RU-ET1---------${SOURCE_ORU_FW_VERSION}.FGF.zip     # e.g. value 'FJ-RU-ET1---------0204.FGF.zip'
${TARGET_ORU_FW_VERSION}=   ${EMPTY}   # e.g. value '0401'
${TARGET_ORU_FW_PACKAGE}=   FJ-RU-ET1---------${TARGET_ORU_FW_VERSION}.FGF.zip     # e.g. value 'FJ-RU-ET1---------0401.FGF.zip'
${PATH_TO_ORU_FIRMWARE}=    /mnt/etfiles/images/RF_SW/OFEGSA

&{OAM_KPI_TARGETS}    kpi2a=500
...                   kpi2b=600
...                   kpi2c=415
...                   kpi2d=425

# Test iteration count used in keyword call
${TEST_ITERATIONS}          1
${SHOULD_BE_REPORTED}       ${True}


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Documentation]     E2E_TL_SW_UPGRADE_ROLLBACK_WITH_OAM_KPI using taf.rfrl.csv4all: SW upgrade and rollback WITH L3 call
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_UPGRADE_L3_Call    QCD_MN_RAN     CSV_ULM_UUF
    Log To Console    ${\n}Upgrade Update Fallback Test using CSV4ALL RFRL and L3 Call (TCP Data Transfer).
    Should Not Be Empty    ${TARGET_SW_VERSION}
    Log To Console    ${\n}The SW Version to Upgrade to is ${TARGET_SW_VERSION}.
    ${Data_Transfer_KW}=    Set Variable    5G L3 Data Transfer
    ${qc_project}    ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          kpi_targets=${OAM_KPI_TARGETS}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          use_external_storage=${False}
    ...          download_path=${None}                  # default value, to be replaced with variable if needed
    ...          use_testpackage=${False}
    ...          restore_to_target_sw=${True}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...          artifactory_location=espoo2            # default value, to be replaced with variable if needed
    ...          package_suffix=A54                     # default value, to be replaced with variable if needed
    ...          l3_call_method=${Data_Transfer_KW}
    ...          synchronize_software_on_passive=False  # default value, to be replaced with variable if needed
    ...          yaft_path=/home/ute                    # default value, to be replaced with variable if needed
    ...          virtualenv_dir=${None}                 # default value, to be replaced with variable if needed


E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Documentation]     E2E_TL_SW_UPGRADE_ROLLBACK_WITH_OAM_KPI using taf.rfrl.csv4all: SW upgrade and rollback WITHOUT L3 call
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_UPGRADE    QCD_MN_RAN    CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}Upgrade Update Fallback Test using CSV4ALL RFRL.
    Should Not Be Empty    ${TARGET_SW_VERSION}
    Log To Console    ${\n}The gNB SW Version to Upgrade to is ${TARGET_SW_VERSION}.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          use_external_storage=${False}
    ...          download_path=${None}                  # default value, to be replaced with variable if needed
    ...          use_testpackage=${True}
    ...          restore_to_target_sw=${{${RESTORE_TO_TARGET_SW}}}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...          artifactory_location=espoo2            # default value, to be replaced with variable if needed
    ...          package_suffix=A54                     # default value, to be replaced with variable if needed
    ...          l3_call_method=${None}                 # default value, to be replaced with variable if needed
    ...          synchronize_software_on_passive=False  # default value, to be replaced with variable if needed
    ...          yaft_path=/home/ute                    # default value, to be replaced with variable if needed
    ...          virtualenv_dir=${None}                 # default value, to be replaced with variable if needed


E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_TL_ACTIVATION_RESET    QCD_MN_RAN     CSV_ULM_UUF
    [Timeout]    24h
    [Documentation]   Performs SW upgrades from SW candidate load to its Test Package version (T1) in loops,
    ...     including SW activation as well as the full set of upgrade and migration procedures.
    Log To Console    ${\n}E2E_TL_ACTIVATION_RESET_TEST
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${tl_name_only}=    String.Fetch From Right    ${OUTPUT_DIR}    /
    Log To Console    ${\n}Test executed under: ${tl_name_only}

    CSV4AllTestCases.E2E_TL_ACTIVATION_RESET_TEST
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...


E2E_TL_Site_Reset_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_SITE_RESET   QCD_MN_RAN     CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}Site Reset Test using CSV4ALL RFRL
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${tl_name_only}=    String.Fetch From Right    ${OUTPUT_DIR}    /
    Log To Console    ${\n}Test executed under: ${tl_name_only}

    CSV4AllTestCases.E2E TL SITE RESET WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...


E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_SITE_RESET_WITHOUT_HWF    QCD_MN_RAN     CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}Site Reset Test using CSV4ALL RFRL without HWF (obsolete/replaced since June 2025)
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    ${tl_name_only}=    String.Fetch From Right    ${OUTPUT_DIR}    /
    Log To Console    ${\n}Test executed under: ${tl_name_only}

    CSV4AllTestCases.E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...


E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_RMOD_RESET_TEST    QCD_MN_RAN     CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}RU Reset Test using CSV4ALL RFRL.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL RU RESET WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...


E2E_TL_RU_Lock_Unlock_with_OAM_KPI
    [Documentation]
    ...  |  E2E_TL_RU_Lock_Unlock using taf.rfrl.csv4all: RU Lock and Unlock  |
    [Tags]  CA_VRF_ULM    CSV4ALL_RU_Lock_Unlock    QCD_MN_RAN     CSV_ULM_UUF
    [Timeout]   24h
    Log To Console    ${\n}RU Lock and Unlock Test using CSV4ALL RFRL.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL RU Lock Unlock
    ...    ${NODES}
    ...    ${SRAN_NODE}
    ...    ${TEST_ITERATIONS}
    ...    report=${SHOULD_BE_REPORTED}
    ...    calculate_kpi=${True}
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${TARGET_SW_VERSION}
    ...    topology=${LABEL}
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_BBMOD_RESET_TEST    QCD_MN_RAN     CSV_ULM_UUF

    Log To Console    ${\n}Capacity Module Reset Test using CSV4ALL RFRL.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_LNCEL_BLOCK_TEST    QCD_MN_RAN     CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}LTE Cell Block and Unblock Test using CSV4ALL RFRL.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_NRCEL_BLOCK_TEST    QCD_MN_RAN      CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}NR Cell Block and Unblock Test using CSV4ALL RFRL.
    Set Test Variable    ${Data_Transfer_KW}    5G L3 Data Transfer
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...          l3_call_method=${Data_Transfer_KW}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_NRCEL_LOCK_TEST    QCD_MN_RAN      CSV_ULM_UUF
    [Timeout]    24h
    Log To Console    ${\n}Cell Lock Unlock NR Test using CSV4ALL RFRL.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    #...          l3_call_method=Check L3 Call Attach   #ToDo: use in future once UEs are available...
    #...          l3_call_method=5G_L3_Data_Transfer


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Documentation]    The E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    ...    Test is only valid for RAT-sharing configurations.
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_LNCEL_LOCK_TEST    QCD_MN_RAN       CSV_ULM_UUF
    Log To Console    ${\n}LTE Cells Lock and Unlock Test using CSV4ALL RFRL.
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    CSV4AllTestCases.E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...          l3_call_method=${None}                 # default value, to be replaced with variable if needed


E2E_TL_Delta_Commissioning_Online_Change
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_Online_SCF_Mod    QCD_MN_RAN
    [Timeout]    24h
    Log To Console    ${\n}Delta Commissioning Online Change Test using CSV4ALL RFRL.
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      TL is ${bts_distName}

    CSV4AllTestCases.E2E TL Delta Commissioning With Online Parameter Modification
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...          l3_call_method=${None}                 # default value, to be replaced with variable if needed


E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  CA_VRF_ULM    UUF4ALL_RFRL_SCF_Mod_w_SITE_RESET    QCD_MN_RAN
    [Timeout]    24h
    Log To Console    ${\n}Delta Commissioning With Site Reset Test using CSV4ALL RFRL.
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      TL is ${bts_distName}

    CSV4AllTestCases.E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...          ${NODES}
    ...          ${SRAN_NODE}
    ...          ${TEST_ITERATIONS}
    ...          delta=${SITE_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${None}                 # default value, to be replaced with variable if needed
    ...          sw_build=${TARGET_SW_VERSION}
    ...          topology=${LABEL}
    ...          stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...          l3_call_method=${None}                 # default value, to be replaced with variable if needed


E2E_TL_SBTS_Block_Unblock
    [Tags]  CA_VRF_ULM    Block_Unblock_SITE    QCD_MN_RAN      CSV_ULM_UUF
    Log To Console    ${\n}Running testcase for Block Site and Unblock Site (Note: The procedure includes a site reset) ...

    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        Log To Console    ${\n}Block Site associated to node ${node_type.upper()}-${node_id} ...
        ${oam_alias}    connect.Setup OAM http session    node_id=${node_id}    node_type=${node_type}
        admin.block    detailed_output=True    connection=${oam_alias}    timeout=120

        Log To Console    ${\n}Wait 30 Sec.
        Sleep    30sec

        Log To Console    ${\n}UnBlock Site associated to node ${node_type.upper()}-${node_id} (Note: A site reset will be triggered) ...
        admin.unblock    wait_for_reconnection=True    detailed_output=True    connection=${oam_alias}    timeout=240

        Log To Console    ${\n}Wait 60 Sec.
        Sleep    60sec

        gnb.Wait Until Node To Be Onair State    node_id=${node_id}    node_type=${node_type}
    END

    [Teardown]    commonKeywords.CSV Online Reporting To ReP


E2E_TL_Block_Unblock_All_Cells
    [Tags]  CA_VRF_ULM    Block_Unblock_All_Cells    QCD_MN_RAN
    Log To Console    ${\n}Test for Block All Cells and Unblock Site...

    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
    ...    customer_name=${CUSTOMERS_LIST}[0]
    ...    release_name=${TARGET_SW_BRANCH}

    Log To Console    ${\n}Setup OAM http session to the SBTS (5G, LTE, GSM)...
    ${oam_alias}    connect.Setup OAM http session    node_id=0    node_type=gNB

    Log To Console    ${\n}Block all LTE Cells.
    admin.block_all_cells    rat=LTE    detailed_output=True    connection=${oam_alias}

    Log To Console    ${\n}Block all GSM Cells.
    admin.block_all_cells    rat=GSM    detailed_output=True    connection=${oam_alias}    timeout=120

    Log To Console    ${\n}Block all NR Cells.
    admin.block_all_cells    rat=NR    detailed_output=True    connection=${oam_alias}

    Log To Console    ${\n}Wait 60 Sec.
    Sleep    60sec

    Log To Console    ${\n}UnBlock all LTE Cells.
    admin.unblock_all_cells    rat=LTE    detailed_output=True    connection=${oam_alias}

    Log To Console    ${\n}UnBlock all GSM Cells.
    admin.unblock_all_cells    rat=GSM    detailed_output=True    connection=${oam_alias}

    Log To Console    ${\n}UnBlock all NR Cells.
    admin.unblock_all_cells    rat=NR    detailed_output=True    connection=${oam_alias}

    [Teardown]    commonKeywords.CSV Online Reporting To ReP


*** Keywords ***
CSV4ALL with RFRL Suite Setup
    Log To Console    Running Test Suite Setup keyword 'CSV4ALL with RFRL Suite Setup' ...
    testline.Set Console Output
    Log Variables
    Log To Console    Creating the log folders
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    git_handling.Save Current Workspace Info
    builtin.Log To Console   The logs of this test run will be available at: ${P_resultSuiteBaseDir}
    commonKeywords.Get CURRENT_SW_BRANCH And Set It As Suite Variable

    commonKeywords.Identify The list Of Unique SMODs And Associated Primary SBTS Nodes Of The Testline   log_to_console=${True}

    Define SRAN_NODE And NODES Variables And Set Them As Suite Variables
    commonKeywords.Get CSV TL customer mapping from TL name and set it as Suite Variable CUSTOMERS_LIST

    # use a different than the default qc_mapping.yaml file in case of FSMF hardware, namely: qc_mapping_fsm3.yaml
    IF   'FSMF' in ${{ [ value['hardware_type'] for key, value in $PRIMARY_TL_NODES_DICT.items() ] }}
    ...   builtin.Import Variables   ${CURDIR}/../CSV4ALL/qc_mapping_fsm3.yaml
    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        commonKeywords.Get The SW Version Of SBTS Node And Set It To Suite Variable P_GNBSWVERSION   node_type=${node_type}    node_id=${node_id}
    END

    Log Variables

    IF   'tcpdump' in ${ENABLED_LOGS}
       commonKeywords.Start tcpdump trace via eth3 interface connected to the monitoring port of testline switch
    END
    ${gnb_sw_version}=    testline.Get gNB SW version    gnb_id=${0}
    Log to console    ${\n}INFO: GNB SW Version is: ${gnb_sw_version}
    ${current_oru_fw_version}=    commonKeywords.Get Running ORAN RU FW version if applicable
    Log To Console    ${\n}Running Test Suite Setup keyword 'CSV4ALL with RFRL Suite Setup' completed!


CSV4ALL with RFRL Suite Teardown
    Log To Console    Running Test Suite Teardown keyword 'CSV4ALL with RFRL Suite Teardown' ...
    # [TODO]: Check if re-checking (and re-setting to global variable) of the current SW version of all primary SBS nodes is really needed here
    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        Get the SW version of SBTS node and set it to Suite Variable P_GNBSWVERSION   node_type=${node_type}   node_id=${node_id}
        ...   sw_version_tag=final
    END

    IF   'tcpdump' in ${ENABLED_LOGS}
       commonKeywords.Stop and collect tcpdump trace via eth3 interface connected to the monitoring port of testline switch
       ...   target_dir=${P_resultSuiteBaseDir}
    END

    # [TODO]: Check if "Save current loads" KW call is really needed, as this seems to be only for reporting purposes which is handled by CSV4ALL
    Wait Until Keyword Succeeds  3x  30sec    syve_testline.Save current loads
    Log To Console    ${\n}Running Test Suite Setup keyword 'CSV4ALL with RFRL Suite Teardown' completed!


CSV4ALL with RFRL Tests Setup
    Log To Console   ${EMPTY}
    Log Variables
    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        gnb.Get Current Alarms From Node    node_type=${node_type}   node_id=${node_id}
    END


CSV4ALL with RFRL Tests Teardown
    Log    ${\n}...The End.    console=${P_console}


Check L3 Call Attach
    Log To Console    ${\n}Test the L3 Call.
    ${_cell_phy_cell_id}    gnb.Get gNB Physical Cell ID
    Log To Console    ${\n}The gNB have the following Cell ID: ${_cell_phy_cell_id}

    Attach_and_Data_Transfer.Stop IPSL and set Scenario Preconditions
    ...   path_to_ipsl_files=${CURDIR}/../../../SyVe/resources/IPSL_with_ONE_QCI_for_2IMSI/

    Attach_and_Data_Transfer.Attach UE to eNB
    Attach_and_Data_Transfer.Perform SgNBAddition

    Attach_and_Data_Transfer.Attach UE to eNB
    Attach_and_Data_Transfer.Perform SgNBAddition    ru_id=1

    Attach_and_Data_Transfer.Attach UE to eNB
    Attach_and_Data_Transfer.Perform SgNBAddition    ru_id=2

    RETURN    ${KEYWORD STATUS}

    [Teardown]    Run Keywords    Log To Console    ${\n}The status is: ${KEYWORD STATUS} ${\n}Message: ${KEYWORD MESSAGE}
    ...           AND    Attach_and_Data_Transfer.Detach and Attenuate all cells


5G L3 Data Transfer
    [Arguments]    ${cell_used_in_test}    ${remote}=${None}
    [Documentation]
    ...  | TCP Data Transfer Testing on a NR cell, which preferebly will be a NR TDD (if available on the TL), or a NR FDD cell otherwise. |
    ...  | This test case is aimed at verifying TCP Tput at a NR cell, where the used NR duplexing cell type (TDD/FDD) is selected by TL name. |
    ...  | if no cells shall be blocked, @{LNCEL_to_block_list} must be defined as empty list |
    ...  | counters check shall be added            |
    Log To Console    ${\n}cell_used_in_test is ${cell_used_in_test}
    Log To Console    ${\n}remote is ${remote}

    ${tl_name}=     testline.Get Testline Name
    ${technology_in_use}=   Set Variable If   '${tl_name}' in ['7_15_UTESRANTL232', '7_15_UTESRANTL283']   FDD   TDD

    Log To Console    ${\n}Data Transfer Testing on NR ${technology_in_use} cell
    commonKeywords.Setup Test Scenario For Data Transfer Testing

#    IF  "${technology_in_use}" == "TDD"
#        @{LNCEL_to_block_list} =    Create List
#        Set Suite Variable     @{LNCEL_to_block_list}    # Interference cells: if no cells shall be blocked, @{LNCEL_TO_BLOCK_LIST} is an empty list
#    ELSE
#        BTS_Cells_Handler.Select LTE Cells To Block
#    END

    commonKeywords.E2E Data Transfer   technology_in_use=${technology_in_use}

    Log To Console    ${\n}Stop Data Transfers For All UEs.
    taf.ue.Stop Data Transfers For All UEs

    RETURN    ${KEYWORD STATUS}

    [Teardown]    commonKeywords.Test Scenario Teardown


Define SRAN_NODE And NODES Variables And Set Them As Suite Variables
    [Documentation]    This keyword is used to defined the SRAN_NODE and the NODES variables that are needed for the execution of the test cases
    ...    from CSV4ALL library. The variables are made available as Suite Variables.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |

    @{CUSTOM_ALARMS}=    Get TL specific list of custom allowed alarms
    ${tl_name}=     testline.Get Testline Name

    IF    ${tl.gnbs != None}
            ${SRAN_NODE}   Create Dictionary
            ...      testline_object=${tl.gnbs[0]}
            ...      source_sw=${SOURCE_SW_VERSION}
            ...      target_sw=${TARGET_SW_VERSION}
            ...      custom_allowed_alarms=@{CUSTOM_ALARMS}
            ...      critical_alarms=@{CRITICAL_FAULTS}
            ...      check_mplane=${False}
            ...      testline_scout_name=${tl_name}
    ELSE
            ${SRAN_NODE}   Create Dictionary
            ...      testline_object=${tl.enbs[0]}
            ...      source_sw=${SOURCE_SW_VERSION}
            ...      target_sw=${TARGET_SW_VERSION}
            ...      custom_allowed_alarms=@{CUSTOM_ALARMS}
            ...      critical_alarms=@{CRITICAL_FAULTS}
            ...      check_mplane=${False}
            ...      testline_scout_name=${tl_name}
    END

    ${PRIMARY_TL_NODE}=   builtin.Set Variable   ${PRIMARY_TL_NODES_LIST}[0]
    IF  'OFEGSA' in '${{','.join($PRIMARY_TL_NODES_DICT['${PRIMARY_TL_NODE}']['radio_types']) }}'
        &{OFEGSA_FILEPATHS}=    Create Dictionary
        ...   upgrade=${PATH_TO_ORU_FIRMWARE}/${TARGET_ORU_FW_PACKAGE}
        ...   rollback=${PATH_TO_ORU_FIRMWARE}/${SOURCE_ORU_FW_PACKAGE}

        Set To Dictionary    ${SRAN_NODE}    oran_files=${OFEGSA_FILEPATHS}
    END

    ${NODES}=    Create List    ${SRAN_NODE}
    Set Suite Variable    ${SRAN_NODE}
    Set Suite Variable    ${NODES}

    RETURN    ${SRAN_NODE}    ${NODES}
