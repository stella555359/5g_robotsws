*** Settings ***
Documentation
...    Author: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library  SeleniumLibrary
Library   SSHLibrary
Library   String
Library  Collections

*** Variables ***

${VDU}        https://10.5.62.114
${VDUSSH}     10.5.26.221
${SSHPASS}    Yt_xk39b@123

*** Keywords ***

Login vDU
    Open Browser   ${VDU}   Chrome
    Sleep   4
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Input Text      login-username    Nemuadmin
    Input Text      login-password    nemuuser
    Click Button    Login
    Sleep  3

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Maximize Browser Window
    Sleep  4
    Wait Until Page Contains    Radio Modules Status Summary
    Wait Until Page Contains    Cells Status Summary

Logout vDU
    Click Element    user-settings
    Sleep     2
    Page Should Contain       Sign out
    sleep   6
    Click Element  //*[contains(text(),'Sign out')]
    Sleep     4
    Close Browser

Check active alarms
    Click Element   ${AlarmTab}
    ${Cond1}=  Run Keyword And Return Status    Page Should Contain     7108
    ${Cond2}=  Run Keyword And Return Status    Page Should Contain     4298
    ${Cond3}=  Run Keyword And Return Status    Page Should Contain     ToP reference missing
    Run Keyword If   ${Cond1}==False and ${Cond2}==False and ${Cond3}==False            Generate Alarm
    ...              ELSE                            Log To Console       Info:Alarm widget is present

Generate Alarm
   Open connection     ${VDUSSH}
   Login               core   ${SSHPASS}
   Write               oc get pods -n cran1
   ${GETPOD1}=         Read      delay=1s
   ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oamext
   ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
   ${NAMESPACE1}=      Fetch FROM Left                ${OAMPODNAME}    -oam
   ${NAMESPACE}=       Fetch FROM Right               ${NAMESPACE1}    -
   log to console   oampod name=${OAMPODNAME}
   Write               oc -it exec ${OAMPODNAME} -c ctr-${NAMESPACE}-oamagent /bin/bash -n cran1
   Sleep               15
   Write               ${SPACE}
   ${cmd1}=  set variable   curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults${SPACE}
   ${cmd2}=  set variable   --header 'content-type: application/json' --data "{\\"faultId\\":4298,\\"state\\":
   ${cmd3}=  set variable   ,\\"severity\\":1,\\"source\\":\\"MRBTS-2003\\",\\"sourceType\\":1,\\"extraInfo\\":\\"57360\\"
   ${cmd4}=  set variable   ,${SPACE}\\"recoveryOverride\\":1}"
   ${cmd}=   set variable    ${cmd1}${cmd2}1${cmd3}${cmd4}
   Log                       ${cmd}
   Write                     ${cmd}
   CLose connection

   Click Element   ${AlarmTab}
   Sleep           3
   Wait Until Page Contains     7108   timeout=60s
   Wait Until Page Contains     4298
   Wait Until Page Contains     ToP reference missing
   Sleep           1
   Open connection     ${VDUSSH}
   Login               core   ${SSHPASS}
   Write               oc -it exec ${OAMPODNAME} -c ctr-${NAMESPACE}-oam /bin/bash -n cran1
   Sleep               20
   Write               ${SPACE}
   ${cmdClearAlarm}=   set variable    ${cmd1}${cmd2}0${cmd3}${cmd4}
   Log                       ${cmdClearAlarm}
   Write                     ${cmdClearAlarm}
   Close connection
