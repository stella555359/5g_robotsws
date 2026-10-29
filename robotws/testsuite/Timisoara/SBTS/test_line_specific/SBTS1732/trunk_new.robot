*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLG_1732_1ASIB_1ASIA_1ABIO_3ABIA_1ARDB_1FRGT_2FXEB_3AZNA_3AEQW
Library     XML  use_lxml=True

Suite Setup    KPI Suite Setup

Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Energy_Consumption_Measurements.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Documentation  kpi tests.
Variables    targets.py

*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1732
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR19
${CALCULATE_RESET_DURATION}      ${TRUE}
${ALLOW_RECOVERY}  ${FALSE}
${COPY_LOGS_ON_KPI_SHARE1}  ${TRUE}






*** Test Cases ***

Download software for SWR test case
    [Timeout]    28800
	Download needed software


TC__SW_download_and_activation__SBTS_to_SBTS_TARGET
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}     /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    7500
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    [['faultId', '7300', 'alarmId', '7107']]
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


TC__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}
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
    ...    AND    Set Test Variable    ${SW Update Timeout}    7500
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    [['faultId', '7300', 'alarmId', '7107']]
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset



KPI#2a(b) Inter-Release SW Activation Downtime - N-1 to N_CRT
    [Tags]    QC_192973
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_ID}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


KPI#4 Complete BTS SW Upgrade_CRT
    [Tags]    QC_
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi4
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


TC__Site_reset_WITH_SNAPSHOT_KPI1
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
     ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Site_reset_WITHOUT_SNAPSHOT_KPI1
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


KPI#1 Site Reset Downtime_CRT
    [Tags]    QC_192972
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi1a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown




TC__Site_power_reset_WITH_SNAPSHOT_KPI3
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
     ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__Site_power_reset_WITHOUT_SNAPSHOT_KPI3
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
     ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


KPI#3 Power-on Startup Availability_CRT
    [Tags]    QC_192980
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi3
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown




TC__Remote_power_reset_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Remote_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Remote_power_reset
    TC__KPI__Remote_power_reset
    [Teardown]    Run Keywords    KPI__Remote_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Remote_power_reset_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    KPI__Remote_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Remote_power_reset
    TC__KPI__Remote_power_reset
    [Teardown]    Run Keywords    KPI__Remote_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


KPI#11 - Manual remote power reset downtime_CRT
    [Tags]    QC_192986
    [Timeout]    300
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi11a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown



TC__Radio_module_reset_from_admin_WITH_SNAPSHOT_L1194707343
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1194707343
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__Radio_module_reset_from_admin_WITHOUT_SNAPSHOT_L1194707343
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1194707343
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


TC__Radio_module_reset_from_admin_WITH_SNAPSHOT_RW201700120
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    RW201700120
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__Radio_module_reset_from_admin_WITHOUT_SNAPSHOT_RW201700120
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    RW201700120
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


TC__Radio_module_reset_from_admin_WITH_SNAPSHOT_1M222318962
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    1M222318962
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__Radio_module_reset_from_admin_WITHOUT_SNAPSHOT_1M222318962
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    1M222318962
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


KPI#51a_b Radio Unit Reset Downtime_CRT
    [Tags]    QC_192967
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi51a    kpi51b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__RMOD_power_reset_WITH_SNAPSHOT_L1194707343
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1194707343
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITHOUT_SNAPSHOT_L1194707343
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1194707343
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITH_SNAPSHOT_RW201700120
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    RW201700120
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITHOUT_SNAPSHOT_RW201700120
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    RW201700120
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


TC__RMOD_power_reset_WITH_SNAPSHOT_1M222318962
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M222318962
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITHOUT_SNAPSHOT_1M222318962
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M222318962
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


KPI#54a_b Power-on Radio Unit startup availability_CRT
    [Tags]    QC_192971
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi54a    kpi54b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown



*** Keywords ***


Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a


