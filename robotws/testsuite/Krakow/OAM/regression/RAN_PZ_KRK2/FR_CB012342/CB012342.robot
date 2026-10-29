*** Settings ***
Documentation    Test suite for UUF ASiR
...              Author: Barbara Wozniak
...              Contact: barbara.wozniak@nokia.com

Library            Collections
Library            String
Library            taf.rfrl.csv4all.CSV4AllTestCases
Library            taf.rfrl.csv4all.resources.utilities.wft.CSV4ALLWft      WITH NAME    Wft
Library            taf.rfrl.utilities.test_config.DefaultFileLocation    WITH NAME    FileLocation
Library            taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    GnbDuOp
Library            taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate    WITH NAME   GnbSwUp
Library            taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME   GnbCommissioning
Library            taf.sbts.oam.coam.admin.interface.admin    WITH NAME    CoamAdmin
Resource           taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables          taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library            ./resources/qc_ids.py

Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    Common Suite Teardown
Test Teardown     Custom Test Teardown

*** Variables ***
${RP_CA}                                        VRF_OAM
${RP_LOCATION}                                  VRF_KRK
${RP_ORGANIZATION}                              VRF_KRK_T02
@{CUSTOMERS_LIST}                               Generic
${EMAIL_RECIPIENTS}                             ${None}
${SOURCE_SW_1}                                  ${None}
${SOURCE_SW_2}                                  ${None}
${TARGET_SW}                                    ${None}
${ITERATIONS_1}                                 10
${ITERATIONS_2}                                 10
${SCF_PREFIX_1}                                 ${None}
${SCF_PREFIX_2}                                 ${None}
&{NODE1}                                        testline_object=${tl.gnbs[0]}
...                                             source_sw=${None}
...                                             target_sw=${TARGET_SW}
...                                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
@{NODES}                                        ${NODE1}
@{UPGRADE_NODES}                                ${NODE1}
@{CUSTOM_ALLOWED_ALARMS}                        @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${ADD_ALARMS}                                   ${None}
${DOWNLOAD_PATH}                                /home/ute/UUF_SW
${IS_TL_NOT_PREPARED}                           ${True}
${SWCONFIG_PATH}                                swconfig/default_swconfig.txt
${REPORT}                                       ${True}
${SCF_PREFIX}                                   Unknown

*** Test Cases ***
1_E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    72h
    [Setup]      Custom Test Setup    ${SOURCE_SW_1}    ${SCF_PREFIX_1}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${UPGRADE_NODES}  ${ITERATIONS_1}
    ...                                        report=${REPORT}
    ...                                        qc_domain=MN_RAN
    ...                                        qc_id=${QC_ID}
    ...                                        qc_project=RAN_VRF
    ...                                        customers_list=@{CUSTOMERS_LIST}
    ...                                        restore_to_target_sw=${False}

2_E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    72h
    [Setup]      Custom Test Setup    ${SOURCE_SW_2}    ${SCF_PREFIX_2}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${UPGRADE_NODES}  ${ITERATIONS_2}
    ...                                        report=${REPORT}
    ...                                        qc_domain=MN_RAN
    ...                                        qc_id=${QC_ID}
    ...                                        qc_project=RAN_VRF
    ...                                        customers_list=@{CUSTOMERS_LIST}
    ...                                        restore_to_target_sw=${False}

*** Keywords ***
Custom Setup
    [Arguments]    ${source_sw}
    ...            ${scf_prefix}
    GnbSwUp.Wait Sw Update Possible    readiness_timeout=${300}
    ${is_not_commissioned}    Run Keyword And Return Status    GnbDuOp.Verify Bts Is Not Commissioned
    ${current_sw}    GnbDuOp.Get Bts Sw Version
    ${INITIAL_RELEASE}    Wft.Get Sw Release    ${source_sw}
    ${initial_sw}    Replace String    ${source_sw}    SBTS00    ${INITIAL_RELEASE}
    Send    Current SW - ${current_sw}, planned source SW - ${initial_sw}
    ${is_config_reset_needed}    Evaluate    '${current_sw}' > '${initial_sw}'
    ${is_sw_upgrade_needed}    Evaluate    '${current_sw}' != '${initial_sw}'
    ${TESTLINE_NAME}    taf.rfrl.utilities.tl_config.Get Testline Name
    Set Global Variable    ${INITIAL_RELEASE}
    Set Global Variable    ${TESTLINE_NAME}
    Run Keyword If    not ${is_not_commissioned} and ${is_config_reset_needed}
    ...               Reset Config
    Run Keyword If    ${is_sw_upgrade_needed}
    ...               Upgrade To Initial Sw    ${source_sw}
    Run Keyword If    ${IS_TL_NOT_PREPARED}    Prepare Testline    ${scf_prefix}
    ...      ELSE     GnbDuOp.Wait For Site To Be Onair    timeout=${1200}
    ${is_commissioning_needed}    Evaluate    '${SCF_PREFIX}' != '${scf_prefix}'
    Run Keyword If    ${is_commissioning_needed}    Perform Commissioning    ${scf_prefix}

Custom Suite Setup
    ${source_sw}    Set Variable If    "${SOURCE_SW_1}" == "${None}"    ${SOURCE_SW_2}    ${SOURCE_SW_1}
    ${scf_prefix}    Set Variable If    "${SOURCE_SW_1}" == "${None}"    ${SCF_PREFIX_2}    ${SCF_PREFIX_1}
    Custom Setup    ${source_sw}    ${scf_prefix}
    ${TARGET_RELEASE}    Wft.Get Sw Release    ${TARGET_SW}
    Set Global Variable    ${TARGET_RELEASE}

Custom Test Setup
    [Arguments]    ${source_sw}
    ...            ${scf_prefix}
    Skip If    "${source_sw}" == "${None}"
    Custom Setup    ${source_sw}    ${scf_prefix}
    Set To Dictionary    ${NODE1}    source_sw=${source_sw}
    Set Qc Id
    Common Preconditions    collect_syslog=${False}

Custom Test Teardown
    CoamAdmin.Teardown All Aliases For Admin
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

Send
    [Arguments]    ${message}
    ${timestamp}    Get Time    result_format=%d-%m-%Y %H:%M:%S
    Log To Console    [${timestamp}] ${message}

Reset Config
    Send    Reset Configuration started
    Set Global Variable    ${IS_TL_NOT_PREPARED}    ${True}
    GnbSwUp.Reset configuration

Set Qc Id
    Skip If    "${REPORT}" == "${False}"
    ${QC_ID}    qc_ids.Get Qc Id    ${TESTLINE_NAME}    ${INITIAL_RELEASE}    ${TARGET_RELEASE}
    Set Global Variable    ${QC_ID}
    Run Keyword If  "${QC_ID}" != "${None}"    Set Tags    QC_${QC_ID}

Upgrade To Initial Sw
    [Arguments]    ${source_sw}
    ${initial_sw_path}    GnbSwUp.Download Sw Package    sw_version=${source_sw}
    ...                                                  target_dir=${DOWNLOAD_PATH}
    GnbSwUp.Wait Sw Update Possible    readiness_timeout=${300}
    Send    SW upgrade to ${source_sw} started
    GnbSwUp.Update Software    ${initial_sw_path}
    ...                        timeout=3600
    Sleep    300 sec    reason=Time for SW activation
    Send    SW upgrade finished

Prepare Testline
    [Arguments]    ${scf_prefix}
    CoamAdmin.Teardown All Aliases For Admin
    Common Suite Setup With OnAir Test Line Preparation
    ...    swconfig_from_path=commissionings/Krakow/${SWCONFIG_PATH}
    ...    increase_timeout_for_update_sw=900
    ...    increase_time_for_checking_radios=900
    ...    incompatible_error_timer=900
    ...    prefix_tag=${scf_prefix}
    ...    scfs_path=commissionings/Krakow/${TESTLINE_NAME}/${INITIAL_RELEASE}
    Set Global Variable    ${IS_TL_NOT_PREPARED}    ${False}
    Set Global Variable    ${SCF_PREFIX}    ${scf_prefix}

Perform Commissioning
    [Arguments]    ${scf_prefix}
    ${scf_name}    FileLocation.Get Default Scf Name    prefix_tag=${scf_prefix}
    GnbCommissioning.Perform Bts Full Commissioning    scf_file=commissionings/Krakow/${TESTLINE_NAME}/${INITIAL_RELEASE}/${scf_name}
    GnbDuOp.Wait For Site To Be Onair
    Set Global Variable    ${SCF_PREFIX}    ${scf_prefix}
