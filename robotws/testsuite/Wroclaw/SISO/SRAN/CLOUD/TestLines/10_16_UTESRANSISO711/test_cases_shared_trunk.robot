*** Settings ***
Documentation
...  Author: marek.oleksiewicz@nokia.com
...  Maintainer: marek.oleksiewicz@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../TestCases/SM/Cloud_SBTS_SM_Cell_Block_Unblock.robot
Resource    ../../TestCases/SM/Cloud_SBTS_SM_Radio_Modules_Lock_Unlock.robot
Resource    ../../TestCases/STARTUP/Cloud_SBTS_STARTUP_Radio_Modules_Reset.robot
Resource    ../../TestCases/STARTUP/Cloud_SBTS_STARTUP_Radio_Modules_Power_Reset.robot
Resource    ../../TestCases/STARTUP/Cloud_SBTS_STARTUP_CBTS_vDU_SBTS_Site_Reset.robot

Suite Setup       Sharing Suite Setup
                  ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
Suite Teardown    Sharing Suite Teardown
                  ...  cbts_get_logs=${False}
*** Variables ***
${VDU_SCF_PATH}=             ${CURDIR}/SCF/vDU/TRUNK/vDU_TRUNK.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF/vCU/TRUNK/vCU_TRUNK.xml
${SBTS_SCF_PATH}=            ${CURDIR}/SCF/Classical/TRUNK/scf_TRUNK_runtime.xml

@{ADDITIONAL_COMMON_ALLOWED_ALARMS}=
                               ...  faultId=4689, severity=Minor
                               ...  faultId=4675, severity=major

@{ADDITIONAL_COMMON_HISTORICAL_ALLOWED_ALARMS}=
                               ...  faultId=4689, severity=Minor
                               ...  faultId=4675, severity=major
@{ADDITIONAL_COMMON_VDU_ALLOWED_ALARMS}=
                               ...  faultId=4675, severity=major

@{CBTS_RMOD_SN_LIST}=  DH243126323  L1242806533  L1242806531  L1242806539  DH243126322  DH243126335  1M201202406  L1223508299  L1223508298
@{RMOD_SN_LIST}=  DH244316335

*** Test Cases ***
[1][1.0] Automated_Cell_Block_Unblock
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_CM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    [Teardown]  Sharing Test Teardown

[1][1.0] Automated_RF_Module_Lock_Unlock
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    [Teardown]  Sharing Test Teardown

[1][1.0] Automated_RF_Module_Reset
    [Setup]  Sharing Test Setup
    TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
    [Teardown]  Sharing Test Teardown