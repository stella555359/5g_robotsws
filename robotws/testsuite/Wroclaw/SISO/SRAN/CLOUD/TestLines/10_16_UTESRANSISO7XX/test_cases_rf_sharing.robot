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
${VDU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vDU.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vCU.xml
${SBTS_SCF_PATH}=            ${CURDIR}/SCF/SCFC_SBTS.xml

@{ADDITIONAL_COMMON_ALLOWED_ALARMS}=
                               ...  faultId=4689, severity=Minor

@{ADDITIONAL_COMMON_HISTORICAL_ALLOWED_ALARMS}=
                               ...  faultId=4689, severity=Minor

@{CBTS_RMOD_SN_LIST}=  ABC75116255
@{SBTS_RMOD_SN_LIST}=  DEF45120901
@{SBTS_CELL_LIST}=  12345  67890
@{CBTS_CELL_LIST}=  2  14  29

*** Test Cases ***
# All cells from SCF file
[1][1.0] Automated_Cell_Block_Unblock_Example_1
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_CM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${True}

# SBTS and CBTS radio modules listed in ${CBTS_CELL_LIST} and  ${SBTS_CELL_LIST}
[1][1.0] Automated_Cell_Block_Unblock_Example_2
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_CM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  cbts_cells_id_list=${CBTS_CELL_LIST}
    ...  sbts_cells_id_list=${SBTS_CELL_LIST}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

# All SBTS and CBTS radio modules from SCF file
[1][1.0] Automated_RF_Module_Lock_Unlock_Example_1
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

# SBTS and CBTS radio modules listed in ${CBTS_RMOD_SN_LIST} and  ${SBTS_RMOD_SN_LIST}
[1][1.0] Automated_RF_Module_Lock_Unlock_Example_2
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  cbts_rmod_sn_list=${CBTS_RMOD_SN_LIST}
    ...  sbts_rmod_sn_list=${SBTS_RMOD_SN_LIST}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

# Random radio modules from SCF file
[1][1.0] Automated_RF_Module_Lock_Unlock_Example_3
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  sbts_rmod_sn_count=3
    ...  cbts_rmod_sn_count=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

# All SBTS and CBTS radio modules from SCF file
[1][1.0] Automated_RF_Module_Reset_Example_1
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

# SBTS and CBTS radio modules listed in ${CBTS_RMOD_SN_LIST} and  ${SBTS_RMOD_SN_LIST}
[1][1.0] Automated_RF_Module_Reset_Example_2
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  cbts_rmod_sn_list=${CBTS_RMOD_SN_LIST}
    ...  sbts_rmod_sn_list=${SBTS_RMOD_SN_LIST}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}

# Random radio modules from SCF file
[1][1.0] Automated_RF_Module_Reset_Example_3
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    ...  sbts_rmod_sn_count=3
    ...  cbts_rmod_sn_count=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
    [Teardown]  Sharing Test Teardown
    ...  cbts_get_logs=${False}
