*** Settings ***

#Resource            ./resources/CB008682.robot
Resource            ./resources/general.robot

Suite Setup       Run Keywords  Suite Preconditions
...               AND           Platform preparation N-2

*** Variables ***

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
Software_Upgrade_from_N-2_to_N
    [Tags]    CRT
    Download and activate testpackage N

Software_Rollback_from_N_to_N-2
    [Tags]    CRT
    Rollback and activate from N to N-x

Software_Fallback_to_N-2
    [Tags]    CRT
    Fallback 4082
