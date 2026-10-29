*** Settings ***
Documentation  kpi tests.
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_N_1778_2ASIB_6ABIO_18AHEH_10AHCA_8AHFIB

Suite Setup    KPI Suite Setup
Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
Resource    ../../KPI/test_resources/KPI__Cell_block_unblock.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot

Variables    targets.py

*** Variables ***

${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1778
${REFERENCE_CONFIGURATION_ID}    CNF_5G_21
${CALCULATE_RESET_DURATION}    ${TRUE}
${ALLOW_RECOVERY}  ${TRUE}



*** Test Cases ***

Download software for SWR test case
    [Timeout]    14400
	Download needed software


TC__SW_download_and_activation__SBTS_to_SBTS_TARGET
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}     /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
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

KPI#2a(b) Inter-Release SW Activation Downtime - N-1 to N_CRT
    [Tags]    QC_36833
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_ID}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

TC__Site_reset_WITH_SNAPSHOT
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


TC__Site_reset_WITHOUT_SNAPSHOT
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
    [Tags]    QC_36829
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi1a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

TC__Site_power_reset_WITH_SNAPSHOT
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

TC__Site_power_reset_WITHOUT_SNAPSHOT
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
    [Tags]    QC_36834
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
    [Tags]    QC_36830
    [Timeout]    300
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi11a    kpi11b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


Max Duration of Remote Power Reset_CRT
    [Tags]    QC_55517
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpiremotepowerreset
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

TC__Cell_lock_unlock_for_LTE_or_NR_cell_WITH_SNAPSHOT_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}   1
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_lock_unlock_for_LTE_or_NR_cell_WITHOUT_SNAPSHOT_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}   1
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#16 - Manual cell lock unlock duration_CRT
    [Tags]    QC_36839
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi16a    kpi16b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

TC__Cell_block_unblock_WITH_SNAPSHOT_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-10778/NRCELL_R-1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_block_unblock_WITHOUT_SNAPSHOT_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-10778/NRCELL_R-1
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#17a_b Cell Block-Unblock duration_CRT
    [Tags]    QC_36832
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi17a    kpi17b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

TC__Radio_module_reset_from_admin_WITH_SNAPSHOT_1M222033043
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    1M222033043
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
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

TC__Radio_module_reset_from_admin_WITHOUT_SNAPSHOT_1M222033043
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    1M222033043
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Radio_module_reset_from_admin_WITH_SNAPSHOT_BL1919V00LC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL1919V00LC
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
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

TC__Radio_module_reset_from_admin_WITHOUT_SNAPSHOT_BL1919V00LC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL1919V00LC
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
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
    [Tags]    QC_36837
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi51a    kpi51b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


Max Duration of Radio Module Reset_CRT
    [Tags]    QC_55515
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpirmodreset
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


TC__RMOD_power_reset_WITH_SNAPSHOT_1M222033043
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M222033043
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITHOUT_SNAPSHOT_1M222033043
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M222033043
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITH_SNAPSHOT_BL1919V00LC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    BL1919V00LC
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITHOUT_SNAPSHOT_BL1919V00LC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    BL1919V00LC
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#54a_b Power-on Radio Unit startup availability_CRT
    [Tags]    QC_36838
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi54a    kpi54b
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


