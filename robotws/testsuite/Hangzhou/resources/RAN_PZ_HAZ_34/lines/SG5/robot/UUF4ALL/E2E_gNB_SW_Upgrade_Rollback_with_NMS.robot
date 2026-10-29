*** Settings ***
Documentation
...  author: Annie Hu
...  contact: annie.hu@nokia-sbell.com


Suite Setup     SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Test Timeout    90 minutes


Resource    ./Resource/Common_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Library          taf.sbts.oam.coam.admin       WITH NAME    coam


Force Tags      E2E_22R1      SG_05

*** Variables ***

*** Test Cases ***
[1]01_SWM download and activate via NOM
   [Tags]   AUTHOR_annie.hu@nokia-sbell.com
   [Setup]   Case Setup
     ${sw_version}   Check Suitable SW Package
     ${sw_version}   Run Keyword If   '${sw_version}'=='None' and '${sw_version.find("SBTS")}'=='0'
      ...   Import Software Package To NOM
      ...   ELSE   Set Variable   ${sw_version}
     Log To Console   Software Package: ${sw_version}
     Check gNB Should Be Normal
     @{gnb_list}   Create List   ${MO_NAME}
     ${operation_id}   NOM Download Software And Return Operation ID   gnb_list=${gnb_list}   sw_version=${sw_version}
     Sleep   1m
     Wait Until Keyword Succeeds   60m   1m   NOM Check Operation Status   operation_id=${operation_id}
     #${down_status}     Provision SW via connect_to_nom    DN_NAME=${DN_NAME}     ne_sw_version=${GNB_upgrade_SW}
     #...    download=True    activate=False    timeout=1800
     #Check gNB Should Be Normal
     Check the planned version
     #${active_status}     Provision SW via connect_to_nom    DN_NAME=${DN_NAME}     ne_sw_version=${GNB_upgrade_SW}
     #...    download=False    activate=True    timeout=1800
     ${operation_id}   NOM Activate Software And Return Operation ID  gnb_list=${gnb_list}   sw_version=${sw_version}
     Sleep   1m
     Wait Until Keyword Succeeds   30m   1m   NOM Check Operation Status   operation_id=${operation_id}

     Check gNB Should Be Normal
     Check the active version
     #${return_fault}   Upload alarm via connect_to_nom and check Fault     DN_NAME=${DN_NAME}
     ${status}   Run Keyword And Return Status   NOM Login
     run keyword if  not ${status}   Run Keywords
     ...   Run Keyword And Ignore Error   NOM Logout   AND
     ...   NOM Login
     ${return_fault}=  NOM Get Active Alarms Via Rest    MRBTS-${MRBTS_ID}
     #${alarms_info}=  nom.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
     log to console    ${return_fault}
     ${fault_id_list}      Get Alarm Info from WebUI      timeout=10s
     should be equal    ${fault_id_list}    ${return_fault}

    [Teardown]   Case Teardown


[1]02_SWM_rollback_via_NOM
     [Tags]   AUTHOR_annie.hu@nokia-sbell.com
     [Setup]   Case Setup
     ${return_active_version}   ${return_passive_version}     Get gNB SW version string
     ${status}     Rollback SW via connect_to_nom     DN_NAME=${MO_NAME}     timeout=1200
     Check gNB Should Be Normal
     ${version}     Get Version
     Should be equal     ${version}      ${return_passive_version}
     Upload Configuration via nom    DN_NAME=${MO_NAME}
     sleep    30s
     ${active5GRATSWVersion}     ${passiveSWReleaseVersion}   Get Sw_version via NOM
     ${rollback_active_version}   ${rollback_passivone_version}     Get gNB SW version string
     Should be equal    ${active5GRATSWVersion}     ${rollback_active_version}
     Should be equal    ${passiveSWReleaseVersion}     ${rollback_passivone_version}
     ${status}   Run Keyword And Return Status   NOM Login
     run keyword if  not ${status}   Run Keywords
     ...   Run Keyword And Ignore Error   NOM Logout   AND
     ...   NOM Login
     ${return_fault}=  NOM Get Active Alarms Via Rest    MRBTS-${MRBTS_ID}
     #${alarms_info}=  nom.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
     log to console    ${return_fault}
     ${fault_id_list}      Get Alarm Info from WebUI      timeout=10s
     should be equal    ${fault_id_list}    ${return_fault}
     [Teardown]    Case Teardown


*** Keyword ***
Case Setup
    Common Setup
    ${active_sw_version}   ${passive_sw_version}   ${planned_sw_version}   COAM Get SW Version
    @{list}   Split String   ${ACTIVE_SW_VERSION}   _
    ${Release}   Set Variable If
    ...   '${list[2]}'=='0000'   ${list[0]}
    ...   '${list[2]}'=='9999'   SBTS00
    Set Suite Variable   ${ACTIVE_SW_VERSION}
    Set Suite Variable   ${RELEASE}
    #Set Suite Variable   ${PACKAGE_VERSION}   ${ACTIVE_SW_VERSION.replace("${ACTIVE_SW_VERSION.split('_')[0]}","${RELEASE}")}
     Set Suite Variable   ${PACKAGE_VERSION}     ${target_version}
    Log To Console   RELEASE: ${RELEASE}
    Log To Console   ACTIVE_SW_VERSION: ${ACTIVE_SW_VERSION}
    Log To Console   PACKAGE_VERSION: ${PACKAGE_VERSION}


Case Teardown
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM Check All Cells Onair
    Common Teardown
