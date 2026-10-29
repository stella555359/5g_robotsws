*** Settings ***
Documentation  This is crt_trunk suite
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLW_10710_2ASOG_1AHEGB_2FXDB  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup    Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShare
Resource    ../../WebEM/test_resources/WebEM__WiFi_management.robot
Resource    ../../WebEM/test_resources/WebEM__Remote_Tool_WiFi_management.robot



*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1710
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1] WebEM__WiFi_management
	[Tags]  QC_242536
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_WLAN_NA}     BTS_CLOUD_SRAN_NLW_10710_2ASOG_1AHEGB_2FXDB_NO_WLAN.xml
    ...    AND    WebEM__WiFi_management.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__WiFi_management
    TC__WebEM__WiFi_management
    [Teardown]  WebEM__WiFi_management.TC Teardown


[1] WebEM__Remote_Tool_WiFi_management
	[Tags]  QC_242537
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
	...    AND    Set Test Variable    ${FILE_WITH_USERS}   SSDWifiConfiguration.xml
    ...    AND    WebEM__Remote_Tool_WiFi_management.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Remote_Tool_WiFi_management
    TC__WebEM__Remote_Tool_WiFi_management
    [Teardown]  WebEM__Remote_Tool_WiFi_management.TC Teardown