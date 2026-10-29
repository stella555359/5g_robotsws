*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../TestCases/SM/Cloud_SBTS_SM_Cell_Block_Unblock.robot
Resource    ../../TestCases/SM/Cloud_SBTS_SM_Radio_Modules_Lock_Unlock.robot
Resource    ../../TestCases/STARTUP/Cloud_SBTS_STARTUP_Radio_Modules_Reset.robot

Suite Setup       Sharing Suite Setup
                  ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
Suite Teardown    Sharing Suite Teardown
                  ...  cbts_get_logs=${False}
*** Variables ***
${VDU_SCF_PATH}=             ${CURDIR}/SCF_8714_shared/SCFC_vDU_runtime.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF_8714_shared/SCFC_vCU.xml
${SBTS_SCF_PATH}=            ${CURDIR}/SCF_8714_shared/SCFC_SBTS_runtime.xml

@{ADDITIONAL_COMMON_ALLOWED_ALARMS}=
                               ...  faultId=4689, severity=Minor

@{CBTS_RMOD_SN_LIST}=  ABC75116255
@{SBTS_RMOD_SN_LIST}=  DEF45120901
@{SBTS_CELL_LIST}=  12345  67890
@{CBTS_CELL_LIST}=  2  14  29

*** Test Cases ***
[1][1.0] Automated_Cell_Block_Unblock
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_CM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  cbts_cells_id_list=${CBTS_CELL_LIST}
    ...  sbts_cells_id_list=${SBTS_CELL_LIST}
    ...  get_kpi=${True}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

[1][1.0] Automated_RF_Module_Lock_Unlock
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  cbts_rmod_sn_list=${CBTS_RMOD_SN_LIST}
    ...  sbts_rmod_sn_list=${SBTS_RMOD_SN_LIST}
    ...  sbts_rmod_sn_count=1
    ...  cbts_rmod_sn_count=1
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown

[1][1.0] Automated_RF_Module_Reset
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    ...  cbts_rmod_sn_list=${CBTS_RMOD_SN_LIST}
#    ...  sbts_rmod_sn_list=${SBTS_RMOD_SN_LIST}
    ...  sbts_rmod_sn_count=1
    ...  cbts_rmod_sn_count=1
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
