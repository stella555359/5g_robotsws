*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Documentation  DryRun suite with TC FM_RMOD_crash_FID4590

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${454}
${LTEVlan}            ${451}
${Switch_IP}          10.255.10.118
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1327


*** Test Cases ***
[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_8
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_9
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_10
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_11
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_12
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_13
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_14
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590_15
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order
