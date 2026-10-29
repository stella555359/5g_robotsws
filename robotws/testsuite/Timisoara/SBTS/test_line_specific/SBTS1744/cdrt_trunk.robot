*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_NLWG_10744_ASIB_ABIA_ABIN_ABIO_FXDB_AHEGA_AHFIA  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Resource    ../../WebEM/test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Startup_view_show_resources.robot
Resource    ../../WebEM/test_resources/WebEM__UAM_Update_alias_and_password_for_local_users.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1744
${COLLECT_SNAPSHOT_FLAG}    always

*** Test Cases ***
[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_753245
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DISABLED_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${MODULE_RECOVERY_TIMEOUT_AFTER_UNLOCK}    1200
    
    ...    AND    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    TC__WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Teardown]    Run Keywords    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__BTS_Startup_view_show_resources
    [Tags]  QC_788462
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_NR_LTE_NA}    SCF_NR_LTE_NA.xml
    ...    AND    Set Test Variable    ${SCF_WCDMA_GSM_NA}    SCF_WCDMA_GSM_NA.xml
    
    ...    AND    WebEM__BTS_Startup_view_show_resources.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BTS_Startup_view_show_resources
    TC__WebEM__BTS_Startup_view_show_resources
    [Teardown]    Run Keywords    WebEM__BTS_Startup_view_show_resources.TC Teardown
    ...    AND    Restore Resource Search Order
  
  
[1]WebEM__UAM_Update_alias_and_password_for_local_users
    [Tags]  QC_812819
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__UAM_Update_alias_and_password_for_local_users.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__UAM_Update_alias_and_password_for_local_users
    TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Teardown]    Run Keywords    WebEM__UAM_Update_alias_and_password_for_local_users.TC Teardown
    ...    AND    Restore Resource Search Order