*** Settings ***
Documentation  This suite contains KPI__Independent_RU_SW_Upgrade test cases

Library  XML  use_lxml=True

Resource  ../../KPI/test_resources/KPI__Independent_RU_SW_Upgrade.robot
Resource  ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource  ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot


*** Variables ***
${COLLECT_SNAPSHOT_FLAG}  never
${SBTS_DESIRED_SW_BUILD}  SBTS00_ENB_9999_241127_000005
${SBTS_INTERMEDIATE_SW_BUILD}  SBTS00_ENB_9999_241126_000006


*** Test Cases ***
TC_SBTS_Independent_RU_SW_Upgrade_1
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TARGET_SW_NAME}         ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}          /media/BuildShareTimi01/SBTS/Trunk
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}      1200
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}      500
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    1200
    ...    AND    KPI__Independent_RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Independent_RU_SW_Upgrade
    TC__KPI__Independent_RU_SW_Upgrade
    [Teardown]    Run Keywords    KPI__Independent_RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order


TC_SBTS_SOAM_rollback_to_SBTS_SOAM_1
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    50
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${TRUE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    TC__KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order


TC_SW_download_and_activation__SBTS_to_SBTS_INTERMEDIATE
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TARGET_SW_NAME}    ${SBTS_INTERMEDIATE_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /media/BuildShareTimi01/SBTS/Trunk
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    500
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ON_AIR_CHECK_NUMBER}    200
    ...    AND    Set Test Variable    ${FIRST_CELL_ON_AIR_TIMEOUT}    50
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    ${FALSE}
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


TC_SBTS_SOAM_rollback_to_SBTS_SOAM_2
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    50
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${TRUE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    TC__KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order


TC_SBTS_Independent_RU_SW_Upgrade_2
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TARGET_SW_NAME}         ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}          /media/BuildShareTimi01/SBTS/Trunk
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}      1200
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}      500
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    1200
    ...    AND    KPI__Independent_RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Independent_RU_SW_Upgrade
    TC__KPI__Independent_RU_SW_Upgrade
    [Teardown]    Run Keywords    KPI__Independent_RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order