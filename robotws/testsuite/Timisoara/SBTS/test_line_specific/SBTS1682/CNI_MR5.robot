*** Settings ***
Documentation  Test suite contain KPI TCs
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  ${ENB_BRANCH}  SRAN
...         CLOUD_SRAN_NLWG_1ASIB_1ABIO_2ABIA_1ASIA_3ABIA_2FXDB_1FRGU_1FRME_2FXED_4FXDA_1AHFIC    STATE_SKIP_AGENT
Library           XML  use_lxml=True
Suite Setup       Run keywords  Check Netboot variable  AND  Map BuildShareTimi01  AND  Map rotta server
Suite Teardown    Save kpi results


Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Variables    targets.py

*** Variables ***
${HW_LOCATION_CODE}    Timisoara
${TESTLINE_NAME}    10_18_UTESRANCLOUD1682
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1682
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR5b
${TIM_DIRECTORY_PATH_ON_ROTTA}   SBTS1Vrf/OAM_KPI/CRT
${MOVE_LOGS_ON_ROTTA}   ${FALSE}


*** Test Cases ***




TC__Site_power_reset_WITH_SNAPSHOT
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__Site_power_reset_WITHOUT_SNAPSHOT
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#3 Power-on Startup Availability_CRT
    [Tags]    QC_223212
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi3
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown




TC__Remote_power_reset_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Remote_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Remote_power_reset
    TC__KPI__Remote_power_reset
    [Teardown]    Run Keywords    KPI__Remote_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__Remote_power_reset_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Remote_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Remote_power_reset
    TC__KPI__Remote_power_reset
    [Teardown]    Run Keywords    KPI__Remote_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#11 - Manual remote power reset downtime
    [Tags]    QC_223217
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi11
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown








*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  [['faultId', '6505', 'alarmId', '7115'], ['faultId', '4655', 'alarmId', '7220'],
    ...                         ['faultId', '61524', 'alarmId', '7220'], ['faultId', '61652', 'alarmId', '7220'],
    ...                         ['faultId', '4654', 'alarmId', '7220'], ['faultId', '61649', 'alarmId', '7220']]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    Run  sudo mkdir -p /media/share2-mnt
    Run  sudo mkdir -p /media/logs2-mnt
    ${first_sh_command}   Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
        ...                             cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${first_sh_command}
    ${second_sh_command}  Catenate  sudo sh -c "echo //10.5.16.72/share2 /media/share2-mnt/
    ...                             cifs _netdev,noperm,username=nokiatm,nosuid,noexec,password=Aikonrotimi2@ 0 0 >>/etc/fstab"
    Run  ${second_sh_command}
    ${third_sh_command}   Catenate  sudo sh -c "echo //10.5.16.76/logs2 /media/logs2-mnt/
        ...                             cifs _netdev,noperm,username=nokiatm,nosuid,noexec,password=Aikonrotimi8* 0 0 >>/etc/fstab"
    Run  ${third_sh_command}
    Run  sudo mount -a
