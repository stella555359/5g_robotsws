*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS22R3  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_2FXCB_1FRGU
Library           XML  use_lxml=True
Suite Setup  Download Needed Software

Resource    ../../KPI/test_resources/KPI__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__GSM_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot


*** Variables ***
${SCF_ID}    01
${SBTS_SW_1}  SBTS22R3_ENB_0000_001258_000000
${SBTS_SW_2}  SBTS22R2_ENB_0000_002113_000000

*** Test Cases ***
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_SW_2}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}   ${SBTS_SW_1}_release_BTSSM_downloadable
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    500
    ...    AND    Set Test Variable    ${Ping regain timeout}    1200
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
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${INFOMODEL_TIMEOUT}    20
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_Site Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    40
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order	
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_STATE_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  CIT Recover Test Line By Power Reset
		
[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_GSM_RAT
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
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__WCDMA_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__WCDMA_RAT_reset_from_ADMIN
    TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
		
[1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    44072
    ...    AND    Set Test Variable    ${NRCELL_ID}    ${None}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${RAT_LOCK}    LTE	
    ...    AND    Set additional ignored alarms variable
    
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset
	
[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    ...    AND    Set additional ignored alarms variable

    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  CIT Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order 

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order 

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order 

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order 

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    K9170614714
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    True

    
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order 

[1][1.0]KPI#51a_b Radio Unit Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TEST_TO_COMPARE}    [1][1.0]KPI__Radio_module_reset_from_admin
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   51a_first_cell_down__to__last_cell_up   51b_last_cell_down__to__first_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1][1.0]KPI#54a_b Power-on Radio Unit startup availability
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]KPI__RMOD_power_reset
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   54a_power_on__to__last_cell_up   54b_power_on__to__last_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1][1.0]KPI#16 - Manual cell lock unlock duration
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]KPI__Cell_lock_unlock_for_LTE_or_NR
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   lock_request_to_cell_down    unlock_request_to_cell_up
    ...    AND    KPI__Compare_KPI.TC Setup  
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	
	
[1][1.0]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]Airscale_Partial_Restart_of_WCDMA_RAT
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   first_cell_down_to_last_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
	
[1][1.0]KPI#2a SWR_First cell down-Last cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]Airscale_Local_Software_Download_and_Activation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   first_cell_down_to_last_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1][1.0]KPI#3 Power Reset_BTS starts-First cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]Airscale_STATE_SBTS Power reset
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   power_on_to_first_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1][1.0]KPI#4 SWR_SW download begins-First cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]Airscale_Local_Software_Download_and_Activation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   sw_update_ind_to_first_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1][1.0]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TEST_TO_COMPARE}    [1][1.0]Airscale_Partial_Restart_of_LTE_RAT
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}   3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   first_cell_down_to_last_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1]KPI#1a Site Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TEST_TO_COMPARE}    [1][1.0]Airscale_STATE_Site Reset
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   first_cell_down_to_last_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	

[1]KPI#9 GSM RAT Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Test_to_compare}    [1][1.0]Airscale_Partial_Restart_of_GSM_RAT
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    ${REF_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   first_cell_down_to_last_cell_up	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown	
	
*** Keywords ***

Download Needed Software
    Set Library Search Order  ca_KPI_general  ca_CIT_general
    Run  mkdir /home/ute/btsauto/TARGET_SW
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${SBTS_SW_1}/${SBTS_SW_1}_release_BTSSM_downloadable.zip -P /home/ute/btsauto/TARGET_SW
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${SBTS_SW_2}/${SBTS_SW_2}_release_BTSSM_downloadable.zip -P /home/ute/btsauto/TARGET_SW
    Run  mkdir /home/ute/btsauto
    Run  cp /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json /home/ute/btsauto/KPI_ref_file.json

Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  [['faultId', '4657', 'alarmId', '7100'], ['faultId', '4655', 'alarmId', '7220'],
    ...                                     ['faultId', '61524', 'alarmId', '7220'], ['faultId', '61652', 'alarmId', '7220'],
    ...                                     ['faultId', '4654', 'alarmId', '7220'], ['faultId', '61649', 'alarmId', '7220']]                        
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}