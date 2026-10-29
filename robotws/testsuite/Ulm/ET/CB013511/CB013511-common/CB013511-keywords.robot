*** Settings ***
Documentation   This is a keyword file for CB013511
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library   Collections
Library   OperatingSystem
Library   DateTime
Library   String
Library   XML

Library    taf.ul.hanging_resources   WITH NAME   resources

Resource        ../../../resources/Common/connect.robot
Resource        ../../../resources/Common/gnb.robot
Resource        ../../../resources/Common/reporting.robot
Resource        ../../../resources/Common/testline.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../../resources/Common/snapshot.robot
Resource        ../../../resources/Common/ute_workarounds.robot

Resource        ../../resources/SQD60/keywords-tracing.robot

Resource        CB013511-keywords-wireshark.robot

*** Keywords ***

Perform Preconditions of Test Scenario CB013511
    [Documentation]    [PRIVATE]    preconditions for CB013511
    ...       :Author: Sylvia Schneider
    Create a Test Scenario Folder


Perform Postconditions of Test Scenario CB013511
    [Documentation]    [PRIVATE]    postconditions for CB013511
    ...       :Author: Sylvia Schneider
    reporting.Set SCOUT TC ID For Reporting
    CB013511-keywords-wireshark.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    keywords-tracing.Dcap Tracing Stop
    keywords-tracing.End Dcap Tracing And Collect Traces
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    Collect Snapshot And Sos Report Data     ${resultDir}


Suite Teardown CB013511
    [Documentation]    [PRIVATE]    Suite Teardown CB013511
    ...       :Author: Sylvia Schneider
    CB013511-keywords-wireshark.Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${LOGS_COLLECTED}'=='False'    Collect Snapshot And Sos Report Data   ${resultBaseDir}
    wts_ue.Reload Stored WTS Config


Collect Snapshot And Sos Report Data
    [Documentation]    [PRIVATE]    Collect Snapshot And Sos Report Data
    ...       :Author: Sylvia Schneider
    [Arguments]    ${store_dir}
    Run Keyword And Ignore Error     ute_workarounds.Check TL connectivity and PDU status
    Log To Console    \ncollecting snapshot data and storing in directory ${store_dir}/snapshot
    Create Directory    ${store_dir}/snapshot
    snapshot.Collect Snapshot From GNB    target_dir=${store_dir}/snapshot
    Log To Console    \ncollecting sos report data and storing in directory ${store_dir}/sosreport
    Create Directory    ${store_dir}/sosreport
    wts_ue.Collect Sos Report Logs      target_dir=${store_dir}/sosreport
    Set Suite Variable     ${LOGS_COLLECTED}       True


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Author: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    gnb.Verify All Radios Are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]      connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}


Create Test Suite Folders
    [Documentation]    [PRIVATE]   Create Test Suite Folders
    ...     :Author: Sylvia Schneider
    ${timeStamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    Set Suite Variable    ${resultBaseDir}    ${OUTPUT_DIR}/${SUITE_NAME}/0000/${timeStamp}
    OperatingSystem.Create Directory    ${resultBaseDir}
    testline.Set Console Output


Create a Test Scenario Folder
    [Documentation]    [PRIVATE]   Create a Test Scenario Folder
    ...     :Author: Sylvia Schneider
    ${tc_name}    String.Fetch From Right   ${TEST NAME}     ${SPACE}
    Set Test Variable      ${resultDir}    ${resultBaseDir}/${tc_name}
    OperatingSystem.Create Directory    ${resultDir}
    Set Test Variable      ${traceDir}    ${resultDir}/traces
    OperatingSystem.Create Directory    ${traceDir}


Get Version Mcc Mnc From GNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Author: Sylvia Schneider
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    XML.Parse XML    ${current_SCF_gnb}

    ${bts_distName}    XML.Get Element Attribute    ${parsed_SCF}    distName    xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Set Suite Variable   ${bts_distName}
    Log To Console    \nbts_distName: "${bts_distName}"

    ${version}    XML.Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Collections.Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${mcc}    XML.Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Collections.Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    XML.Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Collections.Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}


Get Resources
    [Documentation]    [PRIVATE]    get resources
    ...       :Author: Sylvia Schneider
    [Arguments]    ${run}
    Log To Console    \nget used resources and save in var "resources_usage_${run}"
    ${resources_usage_tmp}    resources.Get Resources Usage   node_id=0   node_type=gnb
    Set Test Variable    ${resources_usage_${run}}   ${resources_usage_tmp}


No Check Of Resource nbOfFreeCRNTI
    [Documentation]    [PRIVATE]    exclude nbOfFreeCRNTI from the resource comparison
    ...       :Author: Sylvia Schneider
    resources.Configure Default Excluding Resource Paths   add=//nbOfFreeCRNTI


No Check Of Resource postTimerWheel
    [Documentation]    [PRIVATE]    exclude postTimerWheel from the resource comparison
    ...       :Author: Sylvia Schneider
    resources.Configure Default Excluding Resource Paths   add=//postTimerWheel


No Check Of Resource cooling
    [Documentation]    [PRIVATE]    exclude cooling from the resource comparison
    ...       :Author: Sylvia Schneider
    resources.Configure Default Excluding Resource Paths   add=//cooling


Verify Resource Usage
    [Documentation]    [PRIVATE]    compare resources before test and after test
    ...       :Author: Sylvia Schneider
    Log To Console    \nverify used resources
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}