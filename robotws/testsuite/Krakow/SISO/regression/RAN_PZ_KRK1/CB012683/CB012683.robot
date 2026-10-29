*** Settings ***
Documentation
...   Regression test procedures for the feature CB012683
...   author: Julia Luszcz
...   contact: julia.luszcz@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource    ./procedures/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ./procedures/Manual_SiSo_CM_Recommissioning.robot
Resource    ./procedures/General_SiSo_RAT_Block_Unblock.robot
Resource    ./procedures/General_SiSo_Online_Cell_Addition_Deletion.robot
Resource    ./resources/keywords.robot
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py
Variables   taf/rfrl/bts/alarms/classical_alarms_definition.py

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     Custom Test Teardown

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}        False
${ENABLE_RACH_OBSERVER}                     ${False}
${logs_path}                                ${LOG_PATH}

@{GNB_RU_RESET_ALLOWED_ALARMS}              No X2 link available for a specific LTEENB
...                                         No X2 link available
${ITERATIONS_SiteReset}                 3
${BTS_startup_time}                     ${600}

${capabilities}                         REAL_UE
${reboot_ue}                            False
${timeout_reboot_ue}                    100
${rat_startup_time}                     600

#cell addition deletion
${default_scf_filename}         default_scf.xml
${deleted_cell_scf_filename}    deleted_cell_scf.xml
${add_cell_delta_filename}      add_cell_delta.json

${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}
${CUSTOMERS_LIST}                               ${None}     # Customer list separated by comma
@{CUSTOM_ALARMS}                                @{EMPTY}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}    ${CLASSICAL_FAULT_4123}    ${CLASSICAL_FAULT_4125}
...                                               ${CLASSICAL_FAULT_4153}    ${CLASSICAL_FAULT_4405}
${SYSLOG_IGNORED_PRINTS}                        ${None}     # String separated by |
${SWCONFIG_PATH}                                commissionings/Krakow/swconfig/default_swconfig.txt

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            10

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    221556

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T01
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
[1][1.0] CB012683_3d_E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF
    [Setup]    Custom Test Setup

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

    [Teardown]    Custom Test Teardown

[1][1.0] CB012172_3d_General_SiSo_Cell_block_and_unblock
    General SiSo Cell block and unblock
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_Manual_SiSo_SM_BTS_Site_Reset
    gnb_alarm.Allow Alarm                     ${GNB_RU_RESET_ALLOWED_ALARMS}
    Repeat Keyword                  ${ITERATIONS_SiteReset}
    ...                             General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_General_SiSo_RU_module_reset_from_GUI
    General SiSo Auto RF module reset from WebUI   runs=1
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_Manual_SiSo_SM_RF_Module_lock_unlock
    General SiSo Auto RF Lock Unlock
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_Manual_SiSo_CM_Recommissioning
    gnb_alarm.Allow Alarm                         ${GNB_RU_RESET_ALLOWED_ALARMS}
    Manual_SiSo_CM_Recommissioning      parameters_to_change=${parameters_to_change}
    ...                                 incorrect_parameters=${incorrect_parameters}
    gnb_alarm.Disallow Alarm                      ${GNB_RU_RESET_ALLOWED_ALARMS}
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_General_SiSo_RAT_Block_Unblock_with_L3Call
    gnb_alarm.Allow Alarm                         RAT blocked
    General_SiSo_RAT_Block_Unblock   ${rat_startup_time}
    gnb_alarm.Disallow Alarm                      RAT blocked
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_Manual_SiSo_SM_NR_RAT_reset
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Manual_SiSo_SM_NR_RAT_reset     is_actRatResetEnhancement_frozen=True   rat_startup_time=${BTS_startup_time}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] CB012172_3d_General_SiSo_Online_Cell_Addition_Deletion
    Prepare Ue for L3 Call          capabilities=${capabilities}
    ...                             reboot_ue=${reboot_ue}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
    General_SiSo_Online_Cell_Addition_Deletion
    Verify L3 call                  sectors_parameters=${sectors_to_call_config}
    ...                             timeout_reboot_ue=${timeout_reboot_ue}
