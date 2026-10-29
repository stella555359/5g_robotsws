*** Settings ***
Documentation
...    Author: Oana Ciuculesc/Adrian Cretu  (oana.ciuculesc@nokia.com/adrian.1.cretu@nokia.com)
...    Maintainer: Oana Ciuculesc/Adrian Cretu  (oana.ciuculesc@nokia.com/adrian.1.cretu@nokia.com)
...    Test designed for D-RAN test setup. C-RAN may not work due to PID search method

Library     SeleniumLibrary
Library     SSHLibrary
Library     String
Library     Collections
Resource    xPath_CB008524A.robot

*** Variables ***
${VDUHISTORY}        https://10.5.62.98/alarm/historical
${VDUSSH}     10.5.26.218
${SSHPASS}    Yt_xk39b@123

${ALARMS}     //*[contains(concat(' ', @class, ' '), ' side-bar-icon mdi-16px mdi mdi-bell ng-star-inserted ')]
&{PROCESS}     NTS=NTS  CPCONFIG=cpconfig  TAS=TAS  TRSCONFIG=trsconfig  ASM=asm  eAxC=EAXC  AGENT=agent  FM=fm  CM=cm
...            FMMED=med   CTP=CTP   CMcrit=CCSMCUDaemonExe   IMS=IMS
&{PROCESSPATH}  NTS=/bin/bash /opt/nokia/SS_OAM/NTS/run.sh
...             CPCONFIG=/opt/nokia/SS_OAM/CPCONFIG/CPCONFIG /opt/nokia/SS_OAM/CPCONFIG/cpconfigvdu.json
...             TAS=/bin/bash /opt/nokia/SS_OAM/TAS/run.sh
...             TRSCONFIG=/opt/nokia/SS_OAM/TRSCONFIG/TRSCONFIG /opt/nokia/SS_OAM/TRSCONFIG/trsconfig.json
...             ASM=/opt/nokia/SS_OAM/ASM/asm /opt/nokia/SS_OAM/ASM/asmvdu.json
...             eAxC=/opt/nokia/SS_OAM/EAXC/EAXC /opt/nokia/SS_OAM/EAXC/eaxcfhvdu.json
...             AGENT=/opt/nokia/SS_OAM/OAMAGENT/OAMAGENT /opt/nokia/SS_OAM/OAMAGENT/agent_oam.json
...             FM=/opt/nokia/SS_OAM/FM/FM /opt/nokia/SS_OAM/FM/fmvdu.json
...             CM=/opt/nokia/SS_OAM/OAMCM/oamcm /opt/nokia/SS_OAM/OAMCM/oamcm.json
...             FMMED=/opt/nokia/SS_OAM/MED/MED /opt/nokia/SS_OAM/MED/medvdu.json
...             CTP=/opt/nokia/SS_OAM/CTP/CTP /opt/nokia/SS_OAM/CTP/ctpvdu.json
...             CMcrit=startup=nid=0xE045
...             IMS=/bin/bash /opt/nokia/SS_OAM/IMSNAPSHOT/runvdu.sh
&{SUPERVISIONINT}  ASM=105  TRSCONFIG=990  FM=15  CM=105  TAS=990  CTP=15  AGENT=105  eAxC=15
&{POD}  OAMCONFIG=oamconfig  ASM=oamasm  eAxC=oamfh  TRSCONFIG=oamconfig  CM=oamcm
*** Keywords ***

Find PID
   [Arguments]   ${PROCESS}   ${PROCESSPATH}
   Start Command       ps aux | grep --label=${PROCESS} -H '${PROCESSPATH}'
   ${PIDLines}=        Read Command Output
   ${PIDLine}=         Get Line             ${PIDLines}     0
   ${PIDsplit}=        Split String         ${PIDLine}
   ${PIDslice}=        Get Slice From List   ${PIDsplit}   1  2
   ${PIDstring}=       Convert to string     ${PIDslice}
   ${PID}=             Strip String  ${PIDstring}  characters=[]'
   Log                 ${PID}
   [Return]  ${PID}

Kill process for pasive supervision
   [Arguments]   ${PROCESS}   ${PROCESSPATH}
   Open connection     ${VDUSSH}
   Login               core   ${SSHPASS}
   ${PID1}=   Find PID  ${PROCESS}   ${PROCESSPATH}
   Sleep               1s
   Write               sudo kill -9 ${PID1}
   Sleep               3s
   ${PID2}=   Find PID  ${PROCESS}   ${PROCESSPATH}
   Should Not Be Equal    ${PID1}    ${PID2}
   Close connection

Kill process for active supervision
   [Arguments]   ${PROCESS}   ${PROCESSPATH}  ${SUPERVISIONINT}
   Open connection     ${VDUSSH}
   Login               core   ${SSHPASS}
   ${PID1}=   Find PID  ${PROCESS}   ${PROCESSPATH}
   Sleep               1s
   Write               sudo kill -SIGSTOP ${PID1}
   Sleep               ${SUPERVISIONINT}s
   Write               sudo kill -SIGCONT ${PID1}
   Sleep               10s
   ${PID2}=   Find PID  ${PROCESS}   ${PROCESSPATH}
   Should Not Be Equal    ${PID1}    ${PID2}
   Close connection

Check if all pods are up and running
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}

    Log  Verify if all pods are running
    FOR  ${index1}   IN RANGE   999
         Write               oc get pods -n cran1
         ${GETPODSTATUS1}=         Read      delay=5s
         ${RunningStatus}=  Get Count     ${GETPODSTATUS1}    Running
         ${PodNumber}=      Get Count     ${GETPODSTATUS1}    po-
         Sleep              5
         Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=2
    END
#    Check if continer was restarted  ${POD.ASM}
    Close Connection

Open Browser for ssh
    [Arguments]    ${VDU}
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VDU}
    Sleep    10 secs

Login vDU
    Open Browser for ssh   ${VDUHISTORY}
    Sleep    5
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link
    Input Text    login-username    Nemuadmin
    Input Text    login-password    nemuuser
    Click Button   Login
    sleep  10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]
    Maximize Browser Window
    Sleep   10

Logout vDU
    Click element  //*[@id="user-settings"]/button/span[2]
    Sleep  3
    Page Should Contain       Sign out
    sleep   6
    Click Element  //*[contains(text(),'Sign out')]
    Sleep     3
	Close Browser

Check if continer was restarted
    [Arguments]   ${POD}
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}
    Write       oc get pods -n cran1
    ${PODline}=  Read  delay=5s
    Should Contain         ${PODline}  Running
    ${PODline1}=            Get Lines Containing String  ${PODline}  ${POD}
    ${podlinestring}=  Split String  ${PODline1}
    ${RESTARTNUMBER}=  Get Slice From List  ${podlinestring}  3  4
    ${RESTARTNUMBERstring}=  Convert to string  ${RESTARTNUMBER}
    ${RESTARTNUMBERstr}=  Strip String  ${RESTARTNUMBERstring}  characters=[]'
    Log  ${RESTARTNUMBERstr}
    Should Not Be Equal  ${RESTARTNUMBERstr}  0

Check TRSConfig is restarted after killing process on VDU
    Kill process for active supervision  ${PROCESS.TRSCONFIG}   ${PROCESSPATH.TRSCONFIG}  ${SUPERVISIONINT.TRSCONFIG}
    Check if all pods are up and running


Trigger a critical process failure
    Kill process for pasive supervision  ${PROCESS.eAxC}   ${PROCESSPATH.eAxC}
    Check if all pods are up and running

Check if FMMED service is resilient for its fault data
    Login vDU
    ${ALARMSINIT}=  Get Text  ${alarmtablehistory}
    Log  ${ALARMSINIT}
    Logout vDU
    Kill process for pasive supervision  ${PROCESS.FMMED}   ${PROCESSPATH.FMMED}
    Check if all pods are up and running
    Login vDU
    ${ALARMFIN}=  Get Text  ${alarmtablehistory}
    Logout vDU
    ${Result}=  run keyword and return status  Should Be Equal  ${ALARMSINIT}   ${ALARMFIN}
    Log  ${Result}

Trigger a non-critical process failure more than 5 times
     FOR  ${index1}   IN RANGE   6
       Kill process for pasive supervision  ${PROCESS.ASM}   ${PROCESSPATH.ASM}
       Check if all pods are up and running
     END
       Check if continer was restarted  ${POD.ASM}

Multiple process hang situation for OAM container
    Kill process for active supervision  ${PROCESS.ASM}   ${PROCESSPATH.ASM}  ${SUPERVISIONINT.ASM}
    Kill process for active supervision  ${PROCESS.eAxC}   ${PROCESSPATH.eAxC}  ${SUPERVISIONINT.eAxC}
    Kill process for active supervision  ${PROCESS.CM}   ${PROCESSPATH.CM}  ${SUPERVISIONINT.CM}
    Kill process for active supervision  ${PROCESS.AGENT}   ${PROCESSPATH.AGENT}  ${SUPERVISIONINT.AGENT}
    Check if all pods are up and running

Check WebEM 4649 fault with 7101
    Login vDU
    Click Element    ${alarmbutton}
    Sleep            10s
    Wait Until Element Contains   ${alarmtableactive}  4649
    Element Should Contain    ${alarmtableactive}  7101
    Element Should Contain    ${alarmtableactive}  BTS site autonomous reset as recovery action
    Close Browser

Check WebEM 4649 fault with 7116
    Login vDU
    Click Element    ${alarmbutton}
    Sleep            60s
    Wait Until Element Contains    ${alarmtableactive}  4649  timeout=300s
    Element Should Contain    ${alarmtableactive}  7116
    Element Should Contain    ${alarmtableactive}  4001
    Element Should Contain    ${alarmtableactive}  OAM Non-critical SW Component Failure CPCONFIG
    Close Browser

Multiple process crashed during configuration to trigger 4649
    FOR    ${i}    IN RANGE    6
        Kill process for pasive supervision  ${PROCESS.NTS}   ${PROCESSPATH.NTS}
    END
    Check WebEM 4649 fault with 7101
    Sleep               300s
    FOR    ${i}    IN RANGE    6
        Kill process for pasive supervision  ${PROCESS.TAS}   ${PROCESSPATH.TAS}
    END
    Check WebEM 4649 fault with 7101
    Sleep               300s
    FOR    ${i}    IN RANGE    6
        Kill process for pasive supervision  ${PROCESS.TRSCONFIG}   ${PROCESSPATH.TRSCONFIG}
    END
    Check WebEM 4649 fault with 7101
    Sleep               300s
    Kill process for pasive supervision  ${PROCESS.CPCONFIG}   ${PROCESSPATH.CPCONFIG}
    Check WebEM 4649 fault with 7116

OAMCM critical process failure
    Kill process for pasive supervision  ${PROCESS.CMcrit}   ${PROCESSPATH.CMcrit}
    Check if all pods are up and running

gNB-vDU OAM supports passive supervision for CTP process
    Kill process for pasive supervision   ${PROCESS.CTP}   ${PROCESSPATH.CTP}

Resume communication between vDU OAM process running on OAMExt and OAMConfig pods
    Kill process for pasive supervision   ${PROCESS.AGENT}   ${PROCESSPATH.AGENT}
    Kill process for pasive supervision   ${PROCESS.CPCONFIG}   ${PROCESSPATH.CPCONFIG}

OAMConfig critical IMS service failure
    Kill process for pasive supervision   ${PROCESS.IMS}   ${PROCESSPATH.IMS}
