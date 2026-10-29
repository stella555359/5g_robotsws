*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CRT    RAN_5G_TDD    FR1    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PRI-High    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    Owner_w13li
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/config
#${DELTA_FILE}       Delta_Conf_5GC001304_B_8ssb_148_162.json
#${UE_ID}            1
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          1
#${BEARER_ID}        2
#${CELL_PATH}        /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
#${CELL_NAME}        MRBTS-1/NRBTS-1/NRCELL-1
#${WTS_LOCAL}      ${CURDIR}/config/wts
#${WTS_CFG}        basic_setup.cfg
#
#*** Test Cases ***
#5GC001304_B_02_Activation_And_Deactivation_Of_Random_Access_Procedure_PrachConfIndex_148_162_8ssb
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    ${output}    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    Verify Prach Config Index    ${output}    index=148
#    Lock Cell    ${CELL_NAME}
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    prachConfigurationIndex    162
#    Unlock Cell    ${CELL_NAME}
#    Verify BTS Status    onair    ${MAX_WAITTIME_CONFIGURED}
#    NSA LTE Detach    ${UE_ID}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    ${output}    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    Verify Prach Config Index    ${output}    index=162
#
#*** Keywords ***
#Verify Prach Config Index
#    [Arguments]    ${content}    ${index}
#    Should Contain    ${content}    prach-ConfigurationIndex ${index}
#
#Lock UnLock Cell
#    [Arguments]    ${oper_type}
#    COAM.Setup Admin
#    Run Keyword If    "${oper_type}"=="Lock"    COAM.Lock    ${CELL_PATH}
#    ...    ELSE IF    "${oper_type}"=="unLock"    COAM.unLock    ${CELL_PATH}
#    [Teardown]    COAM.Teardown
#
#Lock Cell
#    [Arguments]    ${cell_name}
#    Setup Admin
#    Block Cell    dist_name=${cell_name}
#    Teardown Admin
#
#Unlock Cell
#    [Arguments]    ${cell_name}
#    Setup Admin
#    UnBlock Cell    dist_name=${cell_name}
#    Teardown Admin
#
#Verify BTS Status
#    [Arguments]    ${bts_status}    ${verify_duration}
#    run keyword if    '${bts_status}'=='onair'    Wait Until Keyword Succeeds    ${verify_duration}    30s    Verify BTS Is OnAir
#    run keyword if    '${bts_status}'=='configured'   Wait Until Keyword Succeeds     ${verify_duration}    30s    Verify BTS Is Configured
#
#
