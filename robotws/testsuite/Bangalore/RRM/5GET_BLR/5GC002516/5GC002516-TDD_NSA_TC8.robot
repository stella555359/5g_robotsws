*** Settings ***
Documentation
...	author/contact: maria.vetrova@nokia.com
...
...	Test case to verify Frame Structure with enabled 5GC002516.
...     for 1 UE on 1CC. DL MCS lowered to 5 to keep full buffer.
...     UE supports simultaneous HARQ ACK + CSI.
...	It uses some common setup/teardown keywords


Resource          5GC002516_keyword.robot
Resource          resources/common/common_setup_teardown.robot
Resource          resources/common/common_log_capture.robot
Resource          resources/common/common_file_operation.robot
Resource          resources/common/common_deal_config_file.robot


Force Tags        CRT    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
...               SBTS00    SBTS22R1     SBTS22R2     CONFIGURED
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD


Suite Setup       Run Keywords    common_setup_teardown.Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE_TC8}
...               AND    common_setup_teardown.Suite Setup Copy WTS Config Files From QT
...               AND    run keyword if    '${AP_FCT_BOARD_TYPE}' == 'ASIL'     common_deal_config_file.Send Swconfig for GNB
...                      ${SWCONFIG_PATH_FILE}
...               AND    run keyword if    '${AP_FCT_BOARD_TYPE}' == 'ASIL'     common_setup_teardown.Reboot TL And Check Configured 
...               AND    common_file_operation.Modify UE Capabilities In CFG    ${WTS_DIR}/${WTS_CFG}    ${UE_NR_PATT}    ${UE_NR_VAL}
...               AND    common_setup_teardown.Suite Setup Start WTS And Check OnAir


Suite Teardown    common_setup_teardown.Common Suite Teardown


Test Setup        common_setup_teardown.Common Test Setup

Test Teardown     Run Keywords    common_setup_teardown.Common Test Teardown
...               AND    common_deal_config_file.Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}
...               AND    5GC002516_keyword.Verify 5GC002516 SYSLOG    ${slot_type_TC8}

*** Test Cases ***
[1][2.0] TC8_5GC002516_B-b_VerifyMutingSlot_Scenario13
    [Documentation]    This test case is to verify Frame Structure and TPut with enabled 5GC002516;
    ...    Source Frame Structure: tdLte 3ms, 6-4-4;
    ...    Interfering  Frame Structure: Semi 14, 10-2-2.
    [Tags]    test8
    5GC002516_keyword.5GC002516_Coordination_of_TDD_Deployment    ${expected_dl_TC8}    ${expected_ul_TC8}

