*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__SWM__SW_Fallback.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
@{rezultate_fallback}


*** Test Cases ***
[1]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}  2
    ...    AND    Set Test Variable    ${BTS2_reset_number}  0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M120-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M120-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.19
    ...    AND    Set Test Variable    ${BTS2_EIF_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Get Status  ${rezultate_fallback}
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}  2
    ...    AND    Set Test Variable    ${BTS2_reset_number}  0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M120-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M120-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.19
    ...    AND    Set Test Variable    ${BTS2_EIF_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Get Status  ${rezultate_fallback}
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[3]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}  2
    ...    AND    Set Test Variable    ${BTS2_reset_number}  0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M120-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M120-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.19
    ...    AND    Set Test Variable    ${BTS2_EIF_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Get Status  ${rezultate_fallback}
    ...    AND    Restore Resource Search Order


[3]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[4]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}  2
    ...    AND    Set Test Variable    ${BTS2_reset_number}  0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M120-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M120-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.19
    ...    AND    Set Test Variable    ${BTS2_EIF_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Get Status  ${rezultate_fallback}
    ...    AND    Restore Resource Search Order


[4]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[5]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}  2
    ...    AND    Set Test Variable    ${BTS2_reset_number}  0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M120-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M120-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m120
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.19
    ...    AND    Set Test Variable    ${BTS2_EIF_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Get Status  ${rezultate_fallback}
    ...    AND    Restore Resource Search Order


[1.0] Robustness_Reg
    Evaluare Status    ${rezultate_fallback}


*** Keywords ***
Get Status
    [Arguments]    ${lista_rezultate}
    Append To List    ${lista_rezultate}  ${TEST_STATUS}

Evaluare status
    [Arguments]    ${lista_rezultate}
    Set Test Variable    ${test_passed}    0
    Set Test Variable    ${test_total}    0
    FOR    ${status}    IN    @{lista_rezultate}
        ${test_total}=    Evaluate    ${test_total} + 1
        IF    '${status}'=='PASS'
            ${test_passed}=    Evaluate    ${test_passed} + 1
        END
    END
    IF    ${test_total} != ${test_passed}
        Log    Rezultat FAIL, au trecut doar ${test_passed} din ${test_total} teste.    console=True
        FAIL
    ELSE
    	Log    Rezultat PASS, au trecut toate ${test_passed} din ${test_total} teste.    console=True
    END