*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_N_1774_ASIB_2ABIO_3AZQS_3AVQL
Library     XML  use_lxml=True

Suite Setup       Run keywords    Check Netboot variable  AND  Map BuildShareTimi01  AND  Map rotta server
Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__BBMOD_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__BBMOD_Power_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__5G_RAT_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Resource    ../../KPI/test_resources/KPI__BTS_autonomous_reset_after_plan_activation.robot
Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
Resource    ../../KPI/test_resources/KPI__Cell_block_unblock.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot

Variables    targets.py


*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1774
${REF_FILE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1774/json/KPI_ref_file.json
${REFERENCE_CONFIGURATION_ID}    CNF_5G_14b



*** Test Cases ***

Download software for SWR test case
    [Timeout]    14400
    Download needed software


[1][1.0]Airscale_Local_Software_Download_and_Activation
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
    ...    AND    Set Test Variable    ${Test Timeout}    60
 	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE} 
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE} 
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
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

[1][1.0]Airscale_OAM KPI_Local_Software_Rollback
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

[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    5000
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    2400
    ...    AND    Set Test Variable    ${onAir Check Number}    800
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    50
    ...    AND    Set Test Variable    ${Test Timeout}    60
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
	...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
	...    Run Keyword  Recover Test Line By Power Reset


[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable  
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}
    
[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_Site Reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}                                        


[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}


[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}


[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}


[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}


[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}

[1][1.0]Airscale_KPI_SBTS Power reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
    ...    AND    Set Test Variable    ${RESET_SMOD_ONLY}    True
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Site_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_power_reset
    TC__KPI__Site_power_reset
    [Teardown]    Run Keywords    KPI__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}                    


[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI_BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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


[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset		

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset		

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI_5G_RAT_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    KPI__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__5G_RAT_Reset_From_WebEM
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}    
	...    Run Keyword  Recover Test Line By Power Reset
 


[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset
	
[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset
	
[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Remote_power_reset
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset	

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset
	
[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset    


[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]BTS_autonomous_reset_after_plan_activation
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
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset            

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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


[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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

[1][1.0]KPI__BBMOD_Power_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1223007798
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


[1][1.0]KPI_Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}    1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI_Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}    1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI_Cell_lock_unlock_for_LTE_or_NR
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNCEL_ID}    ${None}
    ...    AND    Set Test Variable    ${NRCELL_ID}    1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${RAT_LOCK}    NR
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_lock_unlock_for_LTE_or_NR
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]    Run Keywords    KPI__Cell_lock_unlock_for_LTE_or_NR.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI_Cell_lock_unlock_for_LTE_or_NR
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

[1][1.0]KPI_Cell_lock_unlock_for_LTE_or_NR
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


[1][1.0]KPI__Cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-43258/NRCELL_R-1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Cell_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}   

[1][1.0]KPI__Cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-43258/NRCELL_R-1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Cell_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}   

[1][1.0]KPI__Cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-43258/NRCELL_R-1
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    KPI__Cell_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}   

[1][1.0]KPI__Cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-43258/NRCELL_R-1
    ...    AND    KPI__Cell_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}   


[1][1.0]KPI__Cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10771/NRCELL_R-1
    ...    AND    KPI__Cell_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Cell_block_unblock
    TC__KPI__Cell_block_unblock
    [Teardown]    Run Keywords    KPI__Cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}   


[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


[1][1.0]KPI__Radio_module_reset_from_admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__Radio_module_reset_from_admin.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Radio_module_reset_from_admin
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    KPI__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset


[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    DH232011180
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


[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    DH232011180
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

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    DH232011180
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

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    DH232011180
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1221004006
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

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1221004006
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

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1221004006
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

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0]KPI__RMOD_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1221004006
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    600
    ...    AND    Set additional ignored alarms variable
    ...    AND    KPI__RMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    KPI__RMOD_power_reset
    TC__KPI__RMOD_power_reset
    [Teardown]    Run Keywords    KPI__RMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Run Keyword  Recover Test Line By Power Reset

[1][1.0] KPI#16 - Manual cell lock unlock duration
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi16a    kpi16b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi16a
    ...    AND    Report KPI    kpi16b

[1][1.0] KPI#3 Power-on Startup Availability
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi3
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi3

[1][1.0] KPI#1 Site Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi1a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi1a

[1][1.0] [1][1.0]KPI#10a Manual 5G RAT reset downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi10a
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi10a

[1][1.0] [1][1.0]KPI#10b Manual 5G RAT reset downtime RAT Hard Reset
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi10b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi10b   

[1][1.0] KPI#5 Capacity Module Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi5
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi5
	
[1][1.0] [1][1.0]KPI#14 BBMOD_Power_Reset_From_WebEM
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi14
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi14	

[1][1.0] KPI#17a_b Cell Block-Unblock duration
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi17a    kpi17b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi17a
    ...    AND    Report KPI    kpi17b

[1][1.0] KPI#2a(b) Inter-Release SW Activation Downtime - N-1 to N
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_ID}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
	...    AND    Report KPI    ${SW_ACTIVATION_DOWNTIME_KPI_ID}

[1][1.0] KPI#51a_b Radio Unit Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi51a    kpi51b	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi51a
    ...    AND    Report KPI    kpi51b	

[1][1.0] KPI#54a_b Power-on Radio Unit startup availability
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi54a    kpi54b	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi54a
    ...    AND    Report KPI    kpi54b
	
[1][1.0] KPI#4 Complete BTS SW Upgrade
    [Timeout]    300    
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi4	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi4

[1][1.0] KPI#12 - BTS autonomous reset after plan activation	
	[Timeout]    300    
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi12	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi12

[1][1.0] KPI#11 - Manual remote power reset downtime	
	[Timeout]    300    
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_20b 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi11	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi11
	
[1][1.0] KPI#2c(d) Intra-Release SW Activation Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    CNF_5G_14b
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SW_ACTIVATION_DOWNTIME_KPI_ID}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    ${SW_ACTIVATION_DOWNTIME_KPI_ID}	





*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  [['faultId', '4657', 'alarmId', '7100'], ['faultId', '4655', 'alarmId', '7220'],
    ...                                     ['faultId', '61524', 'alarmId', '7220'], ['faultId', '61652', 'alarmId', '7220'],
    ...                                     ['faultId', '4654', 'alarmId', '7220'], ['faultId', '61649', 'alarmId', '7220']]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
    
Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a

