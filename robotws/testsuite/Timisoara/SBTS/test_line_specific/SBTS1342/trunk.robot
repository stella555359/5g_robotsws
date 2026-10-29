*** Settings ***
Force Tags      QCD_MN_RAN  QCP_RAN_ST  ${ENB_BRANCH}  SRAN  CLOUD_SRAN_LWG_1342_1ASIA__2ABIA_1AHEGB_1AHFIC
Library         XML  use_lxml=True

Suite Setup       Map rotta server
Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__LTE_RAT_reset_from_ADMIN.robot
#Resource    ../../KPI/test_resources/KPI__GSM_RAT_reset_from_ADMIN.robot
#Resource    ../../KPI/test_resources/KPI__Site_reset.robot
#Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
#Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
#Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
#Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
#Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
#Resource    ../../KPI/test_resources/KPI__5G_RAT_Reset_From_WebEM.robot
#Resource    ../../KPI/test_resources/KPI__BBMOD_Reset_From_WebEM.robot
#Resource    ../../KPI/test_resources/KPI__Cell_block_unblock.robot
#Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
#Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
#Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot

*** Variables ***
${SCF_ID}           01
${REF_FILE_PATH}    /home/ute/btsauto/robotws/testsuite/SBTS/test_line_specific/Timisoara/SBTS1342/json/KPI_ref_file.json
${TIM_DIRECTORY_PATH_ON_ROTTA}    SBTS1Vrf/OAM_KPI/CRT
${REFERENCE_CONFIGURATION_ID}     CNF_SRAN_10342

*** Test Cases ***
Download software for SWR test case
    [Timeout]    14400
    Download needed software

[1][1.0] Airscale_Local_Software_Download_and_Activation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}                 ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}                  /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}              1200
    ...    AND    Set Test Variable    ${Ping loss timeout}              500
    ...    AND    Set Test Variable    ${Ping regain timeout}            1200
    ...    AND    Set Test Variable    ${onAir Check Number}             200
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}      50
    ...    AND    Set Test Variable    ${Test Timeout}                   60
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}          always
    ...    AND    Set Test Variable    ${MOVE_LOGS_ON_ROTTA}             ${TRUE}

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1][1.0] Airscale_OAM KPI_Local_Software_Rollback
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1][1.0] Airscale_Local_Software_Download_and_Activation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_INTERMEDIATE_SW_BUILD}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}     /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
    ...    AND    Set Test Variable    ${onAir Check Number}    200
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1][1.0]KPI#2a SWR_SW -First cell down to last cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}    5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_ID}
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0]KPI#4 SWR_SW download begins-First cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}    5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi4
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] KPI_Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE

    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  Recover Test Line By Power Reset

[1]KPI#16 Cell lock unlock
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi16a    kpi16b
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Airscale_KPI_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#1a Site Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi1a
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Airscale_KPI_Cell block unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__Cell_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#17 Cell block unblock
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi17a    kpi17b
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] GSM RAT reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__GSM_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__GSM_RAT_reset_from_ADMIN
    TC__KPI__GSM_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__GSM_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#9 GSM RAT reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi9
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] LTE RAT reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#7 LTE RAT reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi7
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Radio module reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#51 RU reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi51a  kpi51b
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Radio module power reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#54 RU power reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi54a  kpi54b
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Site power reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40

    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#3 Site power reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi3
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] WCDMA RAT reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset

[1]KPI#8 WCDMA RAT reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}       5
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}       kpi8
    ...    AND    KPI__Compare_KPI.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Compare_KPI
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Restore Resource Search Order
