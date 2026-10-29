*** Settings ***
Documentation  kpi tests.

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_N_1778_2ASIB_6ABIO_18AHEH_10AHCA_8AHFIB
Library     XML  use_lxml=True

Suite Setup    KPI Suite Setup
Suite Teardown    Save kpi results


Resource    ../../KPI/test_resources/KPI__Independent_RU_SW_Upgrade.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot

Variables    targets.py

*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1778
${REFERENCE_CONFIGURATION_ID}    CNF_5G_21
${CALCULATE_RESET_DURATION}      ${TRUE}
${ALLOW_RECOVERY}  ${TRUE}



*** Test Cases ***

Download software for SWR test case
    [Timeout]    14400
	Download needed software


TC__SBTS_Independent_RU_SW_Upgrade
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}     /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
 	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Independent_RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Independent_RU_SW_Upgrade
    TC__KPI__Independent_RU_SW_Upgrade
    [Teardown]    Run Keywords    KPI__Independent_RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


TC__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    50
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${TRUE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    TC__KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__SW_download_and_activation__SBTS_to_SBTS_INTERMEDIATE
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_INTERMEDIATE_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    False
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


KPI#55_CRT
    [Tags]    QC_165323
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi55a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


KPI#57_CRT
    [Tags]    QC_
	[Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_57}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

KPI#55_C&P
    [Tags]    QC_320933
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi55a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


KPI#57a(b)_C&P
    [Tags]    QC_320918
	[Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_57}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

KPI#57c(d)_C&P
    [Tags]    QC_320976
	[Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_57}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown



*** Keywords ***


Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a