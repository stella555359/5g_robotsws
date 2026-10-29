*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R2  SRAN  CLOUD_SRAN_NLWG_1ASIB_1ABIO_2ABIA_1ASIA_3ABIA_2FXDB_1FRGU_1FRME_2FXED_4FXDA_1AHFIC

Suite Setup    Run keywords    Check Netboot variable  AND  Map BuildShareTimi01  AND  Map rotta server
...            AND   Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
Suite Teardown    Save kpi results


Resource    ../../KPI/test_resources/KPI__BBMOD_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__BBMOD_Power_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__GSM_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
Resource    ../../KPI/test_resources/KPI__Cell_block_unblock.robot
Resource    ../../KPI/test_resources/KPI__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__5G_RAT_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../KPI/test_resources/KPI__Energy_Consumption_Measurements.robot
Resource    ../../KPI/test_resources/KPI__BTS_autonomous_reset_after_plan_activation.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Documentation  kpi tests.
Variables    targets.py

*** Variables ***
${HW_LOCATION_CODE}    Timisoara
${TESTLINE_NAME}    10_18_UTESRANCLOUD1682
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1682
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR5b
${ALLOW_RECOVERY}  ${TRUE}
${COPY_LOGS_ON_KPI_SHARE1}  ${TRUE}

*** Test Cases ***
Download software for SWR test case
    [Timeout]    14400
        Download needed software

TC__SW_download_and_activation__SBTS_to_SBTS_TARGET
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    2400
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    200
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${Make Additional Checks}    ${FALSE}
    ...    AND    Set Test Variable    ${Additional Checks Number}    5
    ...    AND    Set Test Variable    ${Sleep interval}    1 min
    ...    AND    Set Test Variable    ${Pass If SW exists}    ${False}
    ...    AND    Set Test Variable    ${Log KPIs}    ${TRUE}
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS}    OnAir
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS_AFTER_SWDL}    OnAir
    ...    AND    Set Test Variable    ${HARDWARE_CHECK_AFTER_UPDATE}    10
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    50
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${TRUE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    TC__KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__SW_download_and_activation__SBTS_to_SBTS_INTERMEDIATE
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_INTERMEDIATE_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    2400
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    200
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${Make Additional Checks}    ${FALSE}
    ...    AND    Set Test Variable    ${Additional Checks Number}    5
    ...    AND    Set Test Variable    ${Sleep interval}    1 min
    ...    AND    Set Test Variable    ${Pass If SW exists}    ${False}
    ...    AND    Set Test Variable    ${Log KPIs}    ${TRUE}
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS}    OnAir
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS_AFTER_SWDL}    OnAir
    ...    AND    Set Test Variable    ${HARDWARE_CHECK_AFTER_UPDATE}    10
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#2a(b) Inter-Release SW Activation Downtime - N-1 to N
    [Tags]  QC_151328
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_ID}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


KPI#4 Complete BTS SW Upgrade
    [Tags]  QC_151327
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi4
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


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

KPI#3 Power-on Startup Availability
    [Tags]  QC_151324
    [Timeout]    300

    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi3
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__Site_reset_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__Site_reset_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#1 Site Reset Downtime
    [Tags]  QC_151326
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi1a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__LTE_RAT_reset_from_ADMIN_Soft_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__LTE_RAT_reset_from_ADMIN_Soft_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset


TC__LTE_RAT_reset_from_ADMIN_Hard_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__LTE_RAT_reset_from_ADMIN_Hard_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#7a Manual LTE RAT reset downtime Soft
    [Tags]  QC_151323
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi7a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

KPI#7b Manual LTE RAT reset downtime Hard
    [Tags]  QC_151317
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi7b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


TC__KPI__WCDMA_RAT_reset_from_ADMIN_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__KPI__WCDMA_RAT_reset_from_ADMIN_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#8 WCDMA RAT Reset Downtime
    [Tags]  QC_151316
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi8
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


TC__KPI__GSM_RAT_reset_from_ADMIN_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__GSM_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__GSM_RAT_reset_from_ADMIN
    TC__KPI__GSM_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__GSM_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__KPI__GSM_RAT_reset_from_ADMIN_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__GSM_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__GSM_RAT_reset_from_ADMIN
    TC__KPI__GSM_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__GSM_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#9 GSM RAT Reset Downtime
    [Tags]  QC_151315
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi9
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__5G_RAT_Reset_From_WebEM_Soft_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__5G_RAT_Reset_From_WebEM_Soft_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset


TC__5G_RAT_Reset_From_WebEM_Hard_WITH_SNAPSHOT

    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset


TC__5G_RAT_Reset_From_WebEM_Hard_WITHOUT_SNAPSHOT

    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#10a Manual 5G RAT reset downtime
    [Tags]   QC_151318
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi10a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


KPI#10b Manual 5G RAT reset downtime RAT Hard Reset
    [Tags]  QC_151319
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi10b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


TC__BBMOD_Reset_From_WebEM_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1210302492
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESET_TYPE}    Warm
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__BBMOD_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BBMOD_Reset_From_WebEM
    TC__KPI__BBMOD_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__BBMOD_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__BBMOD_Reset_From_WebEM_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1210302492
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESET_TYPE}    Warm
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__BBMOD_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BBMOD_Reset_From_WebEM
    TC__KPI__BBMOD_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__BBMOD_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#5 Capacity Module Reset Downtime
    [Tags]    QC_151325
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi5
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

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
    [Tags]    QC_151329
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi11
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__BTS_autonomous_reset_after_plan_activation_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__BTS_autonomous_reset_after_plan_activation.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BTS_autonomous_reset_after_plan_activation
    TC__KPI__BTS_autonomous_reset_after_plan_activation
    [Teardown]    Run Keywords    KPI__BTS_autonomous_reset_after_plan_activation.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

TC__BTS_autonomous_reset_after_plan_activation_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__BTS_autonomous_reset_after_plan_activation.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BTS_autonomous_reset_after_plan_activation
    TC__KPI__BTS_autonomous_reset_after_plan_activation
    [Teardown]    Run Keywords    KPI__BTS_autonomous_reset_after_plan_activation.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

KPI#12 - BTS autonomous reset after plan activation
    [Tags]    QC_151322
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi12
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown


TC__BBMOD_Power_Reset_From_WebEM_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1210302492
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESET_TYPE}    Warm
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__BBMOD_Power_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BBMOD_Power_Reset_From_WebEM
    TC__KPI__BBMOD_Power_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__BBMOD_Power_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__BBMOD_Power_Reset_From_WebEM_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1210302492
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESET_TYPE}    Warm
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__BBMOD_Power_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BBMOD_Power_Reset_From_WebEM
    TC__KPI__BBMOD_Power_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__BBMOD_Power_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#14 BBMOD_Power_Reset
    [Tags]    QC_151330
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi14
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__Cell_block_unblock_WITH_SNAPSHOT_GSM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_block_unblock_WITHOUT_SNAPSHOT_GSM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_block_unblock_WITH_SNAPSHOT_WCDMA
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-36820
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_block_unblock_WITHOUT_SNAPSHOT_WCDMA
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-36820
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


TC__Cell_block_unblock_WITH_SNAPSHOT_LTE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10682/LNCEL_R-46820
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_block_unblock_WITHOUT_SNAPSHOT_LTE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10682/LNCEL_R-46820
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


TC__Cell_block_unblock_WITH_SNAPSHOT_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-43223/NRCELL_R-1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_block_unblock_WITHOUT_SNAPSHOT_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-43223/NRCELL_R-1
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    ...    AND    KPI__Cell_block_unblock.TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


KPI#17a_b Cell Block-Unblock duration
    [Tags]    QC_151320
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi17a    kpi17b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__Cell_lock_unlock_for_LTE_or_NR_cell_WITH_SNAPSHOT_LTE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    46820
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_lock_unlock_for_LTE_or_NR_cell_WITHOUT_SNAPSHOT_LTE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    46820
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


TC__Cell_lock_unlock_for_LTE_or_NR_cell_WITH_SNAPSHOT_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}    1
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Cell_lock_unlock_for_LTE_or_NR_cell_WITHOUT_SNAPSHOT_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}    1
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#16 - Manual cell lock unlock duration
    [Tags]    QC_151321
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi16a    kpi16b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown

TC__Radio_module_reset_from_admin_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170942942
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__Radio_module_reset_from_admin_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170942942
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#51a_b Radio Unit Reset Downtime
    [Tags]    QC_151314
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi51a    kpi51b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown

TC__RMOD_power_reset_WITH_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9193037133
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

TC__RMOD_power_reset_WITHOUT_SNAPSHOT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9193037133
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

KPI#54a_b Power-on Radio Unit startup availability
    [Tags]    QC_151313
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi54a    kpi54b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown




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

