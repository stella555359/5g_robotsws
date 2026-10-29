*** Settings ***
Documentation
...    Author: velu.p@nokia.com
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -C is related to O-RAN V5.0 improvements with the use of 3rd party RU.
...    Confluence link: link
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: 
...    AC/REQ: 


Resource     ./resources/CB008205-G.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot


Test Setup        ORAN Preconditions
Test Teardown     Test Postconditions Without WTSSIM S1
Force Tags        CRT  FL00    QCD_MN_RAN   QCP_RAN_ST


*** Variables ***

&{O-RU M-Plane version check when supported M-Plane version value is lower than O-DU minimum supported version in LTE FDD}    QC_ID_FL00=QC_507476

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***

	
TC_03_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_lower_than_O-DU_minimum_supported_version_in_LTE_FDD
    [Tags]    TC_3    QCD_MN_RAN    QCP_RAN_ST
    TC_03_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_lower_than_O-DU_minimum_supported_version_in_LTE_FDD
    [Teardown]    run keywords
    ...      reportingportal_Keywords.Set QC_Tag    
    ...      Test Postconditions Without WTSSIM S1
    RP Settings
