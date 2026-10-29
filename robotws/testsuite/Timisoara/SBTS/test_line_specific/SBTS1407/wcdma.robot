*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_2FXCB_1FRGU
Library           XML  use_lxml=True


Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot


*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}   10_18_UTESRANCLOUD1407

*** Test Cases ***
Download software for SWR test case
    [Timeout]    14400
	Download needed software

*** Test Cases ***
[1][1.0]Airscale_Local_Software_Download_and_Activation
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${SBTS_DESIRED_SW_BUILD}_release_BTSSM_downloadable
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
	
*** Keywords ***

Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  [['faultId', '4657', 'alarmId', '7100'], ['faultId', '4655', 'alarmId', '7220'], 
    ...                                     ['faultId', '61524', 'alarmId', '7220'], ['faultId', '61652', 'alarmId', '7220'], 
    ...                                     ['faultId', '4654', 'alarmId', '7220'], ['faultId', '61649', 'alarmId', '7220']]                     
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}