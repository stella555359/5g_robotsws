*** Settings ***
Documentation
...   maintainer:  arunkumar.a
...   contact: arunkumar.a@nokia.com
...   Test suite for CSV4ALL Tests for RJIO
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         taf.sbts.oam.coam.admin    WITH NAME    admin_api
Resource        ../resources/robot/UE_keywords.resource
Resource        ../resources/robot/Common_keywords.resource
Resource        ../resources/robot/Basic_Vm_Operation.resource
Variables       ../resources/robot/variables/ANR_test_case_variables.py

*** Variables ***
${UUF_TEST_ITERATION}=                       3
${SITE_RESET_TEST_ITERATION}=                20
${RU_RESET_TEST_ITERATION}=                  10
${NR_LOCK_TEST_ITERATION}=                   10
${DELTA_COMMISSION_TEST_ITERATION}=          1
${L3_Call_TEST_ITERATION}=                   1
@{CUSTOM_ALARMS}=               4655  61524  61652  4654  61649  4569
${RP_CA}=                       VRF_RRM
${RP_LOCATION}=                 VRF_BLR1
${RP_ORGANIZATION}=             VRF_BLR1_T02
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              Reliance India
${DOWNLOAD_PATH}=               /home/ute/swbuilddownloadpath
${DOWNLOAD_PATH_local_path}=    /home/ute/swbuilddownloadpath
${testline_name}=               7_2_RJIO1061
${GIT_LAB_LOCATION}=            /home/ute/robotws/testsuite/Bangalore/RRM/T02/resources/JSON/${testline_name}/
${ONLINE_PARAMETER_DELTA}=      ${GIT_LAB_LOCATION}EIRP_Delta_Configuration_RDI_17954.json
${SITE_RESET_DELTA}=            ${GIT_LAB_LOCATION}Full_Comission_With_site_reset.json
${NR_RAT_RESET_DELTA}=          ${GIT_LAB_LOCATION}NR_Rat_reset.json
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID}=                  ${None}
${QC_PROJECT}=                  RAN_VRF
#    EXAMPLE PDU Variable
#    &{RU1}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{3, }  version=8221-1
#    &{RU2}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{4, }  version=8221-1
#    &{RU3}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{5, }  version=8221-1
#    @{PDU_LIST}=               &{RU1}  &{RU2}  &{RU3}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
${EMAIL_RECIPIENTS}=            arunkumar.a@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}
${VIRTUALENV_DIR}=              ${None}
${SERIAL_CONSOLE}=              ${False}
${l3_methodology}=          Attach_voice_data_transfer_L3Call
${BACKUP_SCF_DIR}=          ${None}
${MRBTS_ID}=                1061
${MP_build}=                ${None}
${scf_file_path}            testsuite/Bangalore/RRM/T02/CSV_RJIO_Testing/SCF/${testline_name}
${INITIAL_SW}               ${None}
${TARGET_SW}                ${None}
${ITERATIONS}               1
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
@{NODES}                    ${NODE1}
${5G_SOURCE_SW}             ${INITIAL_SW}
${5G_TARGET_SW}             ${TARGET_SW}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3   Test_Code
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=450  # Inter-release SW activation downtime without firmware update
    ...                                       kpi2b=685  # Inter-release SW activation downtime with firmware update
    ...                                       kpi2c=400  # Intra-release SW activation downtime without firmware update
    ...                                       kpi2d=450  # Intra-release SW activation downtime with firmware updates
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    Log To Console    [ Debug ]: 5G Source build:${INITIAL_SW}
    Log To Console    [ Debug ]: 5G Target build:${5G_TARGET_SW}
    Common_keywords.do_source_sw_as_active_sw    5G_SOURCE_SW=${5G_SOURCE_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    FOR  ${item}   IN   @{COMMON_SW_DOWNLOAD_PATH}
        Basic_Vm_Operation.Remove Folder File In VM    folder_name=${item}
        Basic_Vm_Operation.Create Folder In VM    folder_name=${item}

    END
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${UUF_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_dcap=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3    RE_RUN
    [Timeout]   24h
    [Setup]    Run Keyword    UE_keywords.Require UE
    Common_keywords.do_source_sw_as_active_sw    5G_SOURCE_SW=${5G_SOURCE_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Run Keyword And Continue On Failure    Common_keywords.taf_attenuator_objects
    ...    attenuation_ports=@{NR_CELL_0_Port_1}    set_value=${value_in_dB}[0]
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=450
    ...                                       kpi2b=685
    ...                                       kpi2c=400
    ...                                       kpi2d=450
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_dcap=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}
    ...          l3_call_method=${l3_methodology}

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=235  # Manual RU reset downtime
    ...                                       kpi51b=235  # Manual RU reset downtime
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL RU RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${RU_RESET_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}
    ...          customers_list=${CUSTOMERS_LIST}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=41   # Manual lock cell duration
    ...                                       kpi16b=290   # Manual unlock cell duration
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${NR_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

TC47 Performing parameter changes which require BTS restart in RJio configuration
    [Tags]   CRT_SBTS00  CRT_SBTS25R2   CRT_SBTS25R3
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          delta=${SITE_RESET_DELTA}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Documentation]    CSV4ALL not implemented on RAT Reset Scenario. Planned to deploy 10th FEB.
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          delta=${NR_RAT_RESET_DELTA}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

TC43 Performing Online Parameter Changes to enable sleeping cell feature in RJio configuration
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_BTS_Block_Unblock
    [Tags]   Exploratory
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=41   # Manual lock cell duration
    ...                                       kpi16b=290   # Manual unlock cell duration
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL BTS BLOCK UNBLOCK
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${NR_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Lock_Unlock
    [Tags]   Exploratory
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=41   # Manual lock cell duration
    ...                                       kpi16b=290   # Manual unlock cell duration
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL RU LOCK UNLOCK
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${NR_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

# E2E_TL_RU_Power_Reset
#     [Tags]   Exploratory
#     [Timeout]   24h
#     Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
#     Common_keywords.SCF Commission BTS Status Check
#     IF    "${testline_name}" == "7_2_RJIO1063"
#         Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
#     ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
#         Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
#     ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
#         Configure_QC_ID_for_Reportng_portal_MP_TestCase
#     ELSE IF    '${testline_name}' == '7_2_RJIO1061'
#         Common_keywords.Configure_QC_ID_for_Reportng_portal
#     ELSE
#         BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
#     END
#     Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=41   # Manual lock cell duration
#     ...                                       kpi16b=290   # Manual unlock cell duration
#     Set Test Variable  ${ALARM_TIMEOUT}  180
#     Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
#     Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
#     E2E TL RU POWER RESET
#     ...          nodes_details=${NODES}
#     ...          test_nodes_details=${NODE1}
#     ...          iterations_per_node=${NR_LOCK_TEST_ITERATION}
#     ...          customers_list=${CUSTOMERS_LIST}
#     ...          report=${SHOULD_BE_REPORTED}
#     ...          qc_domain=${QC_DOMAIN}
#     ...          qc_id=${TEST_QC_ID}
#     ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]   Exploratory
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=41   # Manual lock cell duration
    ...                                       kpi16b=290   # Manual unlock cell duration
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${NR_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_with_OAM_KPI
    [Tags]   CRT_SBTS00  CRT_SBTS25R2    CRT_SBTS25R3
    [Timeout]   24h
    # Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=330  # Manual site reset downtime
    ...                                       kpi1b=210  # Manual site reset downtime
    ...                                       kpi1c=280  # Manual site reset downtime
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]   CRT_SBTS00_Next    CRT_SBTS25R2    CRT_SBTS25R3_Next
    [Timeout]   24h
    Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    Common_keywords.SCF Commission BTS Status Check
    IF    "${testline_name}" == "7_2_RJIO1063"
        Common_keywords.Configure_QC_ID_for_Reportng_portal_BTS_1063
    ELSE IF    ('${MP_build}' != '${None}' and "${testline_name}" == "7_2_RJIO1063")
        Common_keywords.Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    ELSE IF    ('${testline_name}' == '7_2_RJIO1061' and '${MP_build}' != '${None}')
        Configure_QC_ID_for_Reportng_portal_MP_TestCase
    ELSE IF    '${testline_name}' == '7_2_RJIO1061'
        Common_keywords.Configure_QC_ID_for_Reportng_portal
    ELSE
        BuiltIn.Log To Console    [ERROR]: QC Marking will not happen due to TL condition not meet.
    END
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=330  # Manual site reset downtime
    ...                                       kpi1b=210  # Manual site reset downtime
    ...                                       kpi1c=280  # Manual site reset downtime
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}
