*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS23R4  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_2FXCB_1FRGU
Library           XML  use_lxml=True

Suite Setup       Run keywords    Check Netboot variable  AND  Map BuildShareTimi01  AND  Map rotta server
Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__GSM_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../KPI/test_resources/KPI__Energy_Consumption_Measurements.robot
Resource    ../../KPI/test_resources/KPI__BTS_autonomous_reset_after_plan_activation.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot

Variables    targets.py

*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}   10_18_UTESRANCLOUD1407
${REF_FILE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR3
${TIM_DIRECTORY_PATH_ON_ROTTA}   SBTS1Vrf/OAM_KPI/CRT
${MOVE_LOGS_ON_ROTTA}   ${TRUE}         

*** Test Cases ***

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset                                         

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset

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
    ...    Run Keyword  CIT Recover Test Line By Power Reset                                                                                    

[1][1.0]KPI#51a_b Radio Unit Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi51a    kpi51b	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi51a
    ...    AND    Report KPI    kpi51b	
	

[1][1.0]KPI#54a_b Power-on Radio Unit startup availability
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi54a    kpi54b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi54a
    ...    AND    Report KPI    kpi54b	
	
	
[1][1.0]KPI#16 - Manual cell lock unlock duration
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi16a    kpi16b
    ...    AND    KPI__Compare_KPI.TC Setup  
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi16a
    ...    AND    Report KPI    kpi16b	
	
	
[1][1.0]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi8
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi8
		

[1][1.0]KPI#3 Power Reset_BTS starts-First cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi3	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi3	


[1][1.0]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}   3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi7
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi7	

[1]KPI#1a Site Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi1a	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi1a	

[1]KPI#9 GSM RAT Reset Downtime
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}   kpi9	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi9

[1][1.0]KPI#12 - BTS autonomous reset after plan activation	
	[Timeout]    300    
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi12	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi12

[1][1.0]KPI#11 - Manual remote power reset downtime	
	[Timeout]    300    
	[Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Ref_Configuration}    3 
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi11	
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
    ...    AND    Report KPI    kpi11  


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a

Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  [['faultId', '4657', 'alarmId', '7100'], ['faultId', '4655', 'alarmId', '7220'],
    ...                                     ['faultId', '61524', 'alarmId', '7220'], ['faultId', '61652', 'alarmId', '7220'],
    ...                                     ['faultId', '4654', 'alarmId', '7220'], ['faultId', '61649', 'alarmId', '7220']]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
	
