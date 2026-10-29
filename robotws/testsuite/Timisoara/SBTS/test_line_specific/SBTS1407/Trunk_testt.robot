*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_2FXCB_1FRGU
Library           XML  use_lxml=True

Suite Setup       Run keywords  Set Library Search Order  ca_KPI_general  ca_CIT_general  AND  Check Netboot variable  AND  Map BuildShareTimi01
Suite Teardown    Save kpi results



Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot

Variables    targets.py

*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}   10_18_UTESRANCLOUD1407
${REF_FILE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1407/json/KPI_ref_file.json
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR3

*** Test Cases ***

	
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
