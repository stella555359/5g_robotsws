*** Settings ***
Documentation
...    Author: Andrada Bugiu (andrada.bugiu@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)

Library  SeleniumLibrary
Library  String
Library  DateTime

*** Variables ***
${VCU}                      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gw_vcu}                   10.15.253.192
${gw_err_vcu}               10.15.253.193
${destIpAddr_vcu}           0.0.0.0
${destIpPrefixLength_vcu}   0
${orderNumber_vcu}          6
${orderNumber_err_vcu}      5

${VDU}                      https://10.5.62.82
${gw_vdu}                   10.5.62.74
${gw_err_vdu}               10.5.62.81
${destIpAddr_vdu}           0.0.0.0
${destIpPrefixLength_vdu}   0
${orderNumber_vdu}          6
${orderNumber_err_vdu}      5


*** Keywords ***
Login
#    [Arguments]  ${platform}
#    Open Browser  ${platform}  Chrome
    5GC002279-A.Open Browser for ssh
    Sleep  4
    ${condition}=  run keyword and return status  page should contain  Advanced
    run keyword if   ${condition}==True  run keywords
    ...  click button  details-button  AND  click link  proceed-link

    Input Text  login-username    Nemuadmin
    Input Text  login-password    nemuuser
    Click Button  Login
    Sleep  10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains  Cells Status Summary
    Maximize Browser Window
    Sleep  4

Open Browser for ssh
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VCU}
    Sleep    10 secs

Logout
    Click Element  //*[@id="user-settings"]/button/span[2]
    Sleep  2
    Page Should Contain  Sign out
    Sleep  6
    Click Element  //*[contains(text(),'Sign out')]
    Sleep  3
	Close Browser


Generate fault 61665
    [Arguments]  ${gw_err}  ${destIpAddr}  ${destIpPrefixLength}

    Log to console  Generate fault 61665
    5GC002279-A.Delete DeltaPlan
    Create DeltaPlan
    Search parameter to generate fault  IPRT-2

#    ${routingTableDN}=  Get Text  id:object-distname

    #complete IPRT-2 parameters
    Input Text  ${destIpAddr_value}  ${destIpAddr}
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  5
    Input Text  ${destIpPrefix_value}  ${destIpPrefixLength}
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  5
    Input Text  ${gw_value}  ${gw_err}
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  5
    Input Text  ${preference_value}  1
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  7
    ${date}=  Get Current Date
    Input Text  ${userLabelIPRT_value}  test2279_${date}

    Validate and activate plan
    Verify fault is generated  61665  IPRT


Clear fault 61665
    [Arguments]  ${gw}
    #${platform}

    Log to console  Clear fault 61665
    5GC002279-A.Delete DeltaPlan
    Create DeltaPlan
    Search parameter to clear fault  IPRT-2
    Input Text  ${gw_value}  ${gw}
    Validate and activate plan
    Verify fault is cleared  61665
    5GC002279-A.Delete DeltaPlan
#    Verify route entries  ${platform}


Verify fault is generated
    [Arguments]  ${fault}  ${routingTableDN}
    Sleep  2
    Click Element  ${Alarms_button}
    Wait until page contains  ${fault}  timeout=60
    Sleep  7
    ${table_rows}=  Get WebElements  ${alarms_table}
    FOR  ${row}  IN  @{table_rows}
        Log    ${row.text}
        ${rowmatch}=  Run Keyword And Return Status  Should contain  ${row.text}  ${fault}
        Run Keyword If  ${rowmatch}==True  Should Contain  ${row.text}  ${routingTableDN}
        Exit FOR loop if  ${rowmatch}==True
    END


Verify fault is cleared
    [Arguments]  ${fault}

    Click Element  ${Alarms_button}
    Wait until page does not contain  ${fault}  timeout=60


Search parameter to generate fault
    [Arguments]  ${parameter}

    Input Text  filter-input-field-plans-tree  ${parameter}
    Sleep  2
    ${add_param_name}=  Fetch From Left  ${parameter}  -  # takes parameter name without number (e.g. IPRT or RTPOL)

    # if ${parameter} doesn`t exist, create it
    ${condition}=  run keyword and return status  page should contain  ${parameter}
    run keyword if   ${condition}==False  Run keywords
    ...  Input Text  filter-input-field-plans-tree  IPNO-1  AND
    ...  Sleep  2  AND
    ...  Click Element  //*[contains(text(),'IPNO-1')]  AND
    ...  Click Element  webem-parameter-editor-add-object-overlay-button  AND
    ...  Click Element  //*[@id="webem-pe-add-object-classname-dropdown"]/div/span  AND
    ...  Click Element  //*[contains(text(),'${add_param_name}')]  AND
    ...  Click Element  //*[@id="webem-pe-add-object-load-default-values-dropdown"]/div/div[2]  AND
    ...  Click Element  //*[contains(text(),'OK')]  AND
    ...  Wait until page contains  Add object operation finished  AND
    ...  Sleep  5  AND
    ...  Input Text  filter-input-field-plans-tree  ${parameter}

    Sleep  2
    Click Element  //*[contains(text(),'${parameter}')]
    Sleep  5
    ${condition}=  run keyword and return status  page should contain  Structure 1
    run keyword if   ${condition}==False  Click Element  //*[@id="configuration-add-structure"]/button/span[1]


Search parameter to clear fault
    [Arguments]  ${parameter}

    Input Text  filter-input-field-plans-tree  ${parameter}
    Sleep  2
    Click Element  //*[contains(text(),'${parameter}')]
    Sleep  5
    ${condition}=  run keyword and return status  page should contain  Structure 1
    run keyword if   ${condition}==False  Click Element  //*[@id="configuration-add-structure"]/button/span[1]


Validate and activate plan
    Sleep  5
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  8
    Click Element  //*[contains(text(),'Validate Plan')]  # if first Validate button is not active, click it again
    Wait until page contains  Validate plan operation finished  timeout=60
    Sleep  2
    Click Element  //*[contains(text(),'Activate Plan')]
    Click Element   //*[contains(text(),'Execute')]
    Wait until page contains  Activate plan operation finished  timeout=60
    Click Element  //*[contains(text(),'Done')]
    Sleep  2


Verify route entries
    [Arguments]  ${platform}

    Click element  ${Diagnostic_button}
    Click Element  //*[contains(text(),'IP Connectivity')]
    Sleep  2
    Click Element  ${SourceAddr_list}
    Sleep  2
    ${srcipAddr}=  Fetch From Right  ${platform}  https://
    Mouse Down    xpath=//li[contains(.,'${srcipAddr}')]
    Click Element  xpath=//li[contains(.,'${srcipAddr}')]
    Sleep  2
    Click Element  ${Scope_list}
    Sleep  2
    Mouse Down    xpath=//li[contains(.,'User defined address')]
    Click Element  xpath=//li[contains(.,'User defined address')]
    Sleep  2
    Input Text  IpAddress  0.0.0.0
    Sleep  2
    Click Element  //*[contains(text(),'Start')]
    Sleep  2

    # verify Successful message (different xpaths for VCU and VDU)
    ${condition}=  run keyword and return status  page should contain element
    ...  xpath=/html/body/webem-root/${success_message}
    run keyword if   ${condition}==False  Wait Until Element Contains
    ...  xpath=/html/body/vdu-webem-root/${success_message}  Successful  timeout=60
    ...  ELSE  Wait Until Element Contains   xpath=/html/body/webem-root/${success_message}  Successful  timeout=60
    Sleep  2


Generate fault 61664
    [Arguments]  ${orderNumber_err}  ${platform}

    Log to console  Generate fault 61664
    5GC002279-A.Delete DeltaPlan
    Create DeltaPlan
    Search parameter to generate fault  RTPOL-1

    #complete RTPOL-1 parameters
    ${routingTableDN}=  Get Text  id:object-distname
    ${routingTableDN_path}=  Fetch From Left  ${routingTableDN}  /RTPOL-1
    ${srcipAddr}=  Fetch From Right  ${platform}  https://

    Input Text  ${ordernumber_value}  ${orderNumber_err}
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  6
    Input Text  ${routingTableDN_value}   ${routingTableDN_path}/IPRT-1
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  6
    Input Text  ${srcipAddr_value}  ${srcipAddr}
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  6
    Input Text  ${prefix_value}  32
    Click Element  //*[contains(text(),'userLabel')]
    Sleep  6
    ${date}=  Get Current Date
    Input Text  ${userLabelRTPOL_value}  test2279_${date}

    Validate and activate plan
    Verify fault is generated  61664  RTPOL


Clear fault 61664
    [Arguments]  ${orderNumber}
    #${platform}

    Log to console  Clear fault 61664
    5GC002279-A.Delete DeltaPlan
    Create DeltaPlan
    Search parameter to clear fault  RTPOL-1
    Input Text  ${ordernumber_value}  ${orderNumber}
    Validate and activate plan
    Verify fault is cleared  61664
    5GC002279-A.Delete DeltaPlan
#    Verify route entries  ${platform}


Create DeltaPlan
    Click Element  ${ConfigPlans_list}
    Sleep  2
    ${condition}=  run keyword and return status  page should contain  DELTA-PLAN-1
    run keyword if   ${condition}==True  Run keywords
    ...  Mouse Down    xpath=//li[contains(.,'DELTA-PLAN-1')]  AND
    ...  Click Element  xpath=//li[contains(.,'DELTA-PLAN-1')]
    ...  ELSE  Run keywords
    ...  Click Element  //*[contains(text(),'Create Delta Plan')]  AND
#    ...  Click Element  //*[contains(text(),'OK')]  AND
    ...  Click Element  //*[@id="edit-plan-create-button"]/button/span  AND
    ...  Wait until page contains  Create plan operation finished  timeout=20
    Sleep  5


Delete DeltaPlan
    # verify if we are in Configuration page
    ${condition}=  run keyword and return status  page should contain  Create Plan
    run keyword if   ${condition}==False  Run keywords
    ...  Click Element  ${Configuration_button}  AND
    ...  Sleep  5

    Click Element  ${ConfigPlans_list}
    Sleep  10
    ${condition}=  run keyword and return status  page should contain  DELTA-PLAN-1
    run keyword if   ${condition}==True  Run keywords
    ...  Mouse Down    xpath=//li[contains(.,'DELTA-PLAN-1')]  AND
    ...  Click Element  xpath=//li[contains(.,'DELTA-PLAN-1')]  AND
    ...  Click Element  //*[contains(text(),'Delete Plan')]  AND
    ...  Sleep  2  AND
    ...  Click Element  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]  AND
    ...  Wait until page contains  Delete plan operation finished  timeout=60
    Sleep  5

Delete IPRT parameters list
    Log to console  Delete IPRT-2 parameters list
    5GC002279-A.Delete DeltaPlan
    Create DeltaPlan
    Search parameter to clear fault  IPRT-2
    Click Element  ${remove_IPRT_parameters}
    Wait until page contains  Remove structure operation finished
    Validate and activate plan
    5GC002279-A.Delete DeltaPlan

Delete RTPOL parameters list
    Log to console  Delete RTPOL-1 parameters list
    5GC002279-A.Delete DeltaPlan
    Create DeltaPlan
    Search parameter to clear fault  RTPOL-1
    Click Element  ${remove_RTPOl_parameters}
    Wait until page contains  Remove structure operation finished
    Validate and activate plan
    5GC002279-A.Delete DeltaPlan
