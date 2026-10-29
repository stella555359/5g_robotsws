*** Settings ***
Documentation
...    Author: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library  SeleniumLibrary
Library   SSHLibrary
Library   String

*** Variables ***
${VDU}        https://10.5.62.58
${VDUSSH}     10.5.26.222
${SSHPASS}    Yt_xk39b@123

*** Keywords ***
Check initial OAM container status
    log to console  ${\n}Check initial OAM container status....
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}
    Write               oc get pod -n cran1
    ${GETPOD1}=         Read      delay=1s
    ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oamconfig
    ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
    Log                 ${OAMPODNAME}
    ${NAMESPACE1}=      Fetch FROM Left                ${OAMPODNAME}    -oamconfig
    ${NAMESPACE}=       Fetch FROM Right               ${NAMESPACE1}    -

    Write               oc describe pod ${OAMPODNAME} -n cran1
    ${CTR1}=            Read      delay=1s
    ${CTR2}=            Fetch From Right              ${CTR1}       ctr-${NAMESPACE}-oamconfig:
    ${CTR3}=            Fetch From Left               ${CTR2}       Liveness
    Should contain      ${CTR3}                       Running
    ${STARTEDTIMECTRinit}=  Get Lines Containing String   ${CTR3}       Started:
    Set Global Variable      ${STARTEDTIMECTRinit}
    Log                 ${STARTEDTIMECTRinit}


Check if OAM container was restarted
    log to console  ${\n}Check if OAM container was restarted...
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}
    FOR  ${index}   IN RANGE   999
         Write               oc get pod -n cran1
         ${GETPODSTATUS1}=         Read      delay=1s
         ${FOR}=  Run Keyword And Return Status    Should contain      ${GETPODSTATUS1}         Terminating
         Exit FOR loop if  ${FOR}==True
    END
    Write               oc get pod -n cran1
    ${GETPOD1}=         Read      delay=1s
    ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oamconfig
    ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
    Log                 ${OAMPODNAME}
    ${NAMESPACE1}=      Fetch FROM Left                ${OAMPODNAME}    -oamconfig
    ${NAMESPACE}=       Fetch FROM Right               ${NAMESPACE1}    -
    FOR  ${i}   IN RANGE   100
         Write               oc describe pod ${OAMPODNAME} -n cran1
         ${CTR1}=            Read      delay=1s
         ${CTR2}=            Fetch From Right              ${CTR1}       ctr-${NAMESPACE}-oamconfig:
         ${CTR3}=            Fetch From Left               ${CTR2}       Liveness
         ${FOR}=  Run Keyword And Return Status    Should contain      ${CTR3}               Running
         Exit FOR loop if  ${FOR}==True
    END

    ${STARTEDTIMECTRfinal}=  Get Lines Containing String   ${CTR3}       Started:
    Should not be equal      ${STARTEDTIMECTRinit}    ${STARTEDTIMECTRfinal}
    Log  Initial Status=${STARTEDTIMECTRinit} Final status=${STARTEDTIMECTRfinal}
    Close Connection

Check OAMAgent is restarted after killing process on VDU
    log to console  ${\n}Check OAMAgent is restarted after killing process on VDU...
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}
    sleep   5
    Write               ps wwaux | grep AGENT
    ${AGENTinit}    Read    delay=2s
    Should Contain         ${AGENTinit}      agent_oam.json
    ${PID1}=            Get Lines Containing String    ${AGENTinit}    agent_oam.json
    ${pidinitfetch}=       Fetch From Right        ${PID1}     9999${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    Log                    ${pidinitfetch}
    ${PIDinit}=                Fetch From Left        ${pidinitfetch}     ${SPACE}
    Log to console   kill -SIGSTOP agent_oam.json....
    Write                  sudo kill -SIGSTOP ${PIDinit}
    Sleep                  105
    Log to console   kill -SIGCONT agent_oam.json....
    Write                  sudo kill -SIGCONT ${PIDinit}
    sleep                  10
    Write               ps wwaux | grep AGENT
    ${AGENTfin}    Read    delay=2s
    Should Contain         ${AGENTfin}      agent_oam.json
    ${PID2}=            Get Lines Containing String    ${AGENTfin}    agent_oam.json
    ${pidfinfetch}=       Fetch From Right        ${PID2}     9999${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    Log                    ${pidfinfetch}
    ${PIDfin}=                Fetch From Left        ${pidfinfetch}     ${SPACE}
    Log                    PIDinit=${PIDinit} PIDfin=${PIDfin}
    Should Not Be Equal    ${PIDinit}    ${PIDfin}
    Close Connection

Check TRSConfig is restarted after killing process on VDU
    log to console  ${\n}Check TRSConfig is restarted after killing process on VDU...
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}
    Write               ps wwaux | grep TRSCONFIG
    ${TRSinit}    Read    delay=10s
    Should Contain         ${TRSinit}      trsconfig.json
    ${PID1}=            Get Lines Containing String    ${TRSinit}    trsconfig.json
    ${pidinitfetch}=    Fetch From Right        ${PID1}     9999${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    Log                    ${pidinitfetch}
    ${PIDinitTRS}=                Fetch From Left        ${pidinitfetch}     ${SPACE}
    log to console  ${PIDinitTRS}
    Log to console   kill -SIGSTOP  trsconfig.json....
    Write                  sudo kill -SIGSTOP ${PIDinitTRS}
    Sleep                  110
    Log to console   kill -SIGCONT  trsconfig.json....
    Write                  sudo kill -SIGCONT ${PIDinitTRS}
    Sleep  50
    Check initial OAM container status

    Write               ps wwaux | grep TRSCONFIG
    ${TRSfin}    Read    delay=2s
    Should Contain         ${TRSfin}      trsconfig.json
    ${PID2}=            Get Lines Containing String    ${TRSfin}    trsconfig.json
    ${pidfinfetch}=       Fetch From Right        ${PID2}     9999${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    Log                    ${pidfinfetch}
    ${PIDfinTRS}=                Fetch From Left        ${pidfinfetch}     ${SPACE}
    Log                    PIDinit=${PIDinitTRS} PIDfin=${PIDfinTRS}
    Should Not Be Equal    ${PIDinitTRS}    ${PIDfinTRS}
    Close Connection

Check CPConfig is restarted after killing process on VDU
    log to console  ${\n}Check CPConfig is restarted after killing process on VDU...
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}
    Sleep               1
    Write               ps wwaux | grep CPCONFIG
    ${CPinit}    Read    delay=2s
    Should Contain         ${CPinit}      cpconfigvdu.json
    ${PID1}=            Get Lines Containing String    ${CPinit}    cpconfigvdu.json
    ${pidinitfetch}=       Fetch From Right        ${PID1}     9999${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    Log                    ${pidinitfetch}
    ${PIDinitCP}=                Fetch From Left        ${pidinitfetch}     ${SPACE}
    Log to console   PIDinitCP=${PIDinitCP}
    Log to console   kill -SIGSTOP cpconfigvdu.json....
    Write                  sudo kill -SIGSTOP ${PIDinitCP}
    Sleep                  170
    Log to console   kill -SIGSCONT cpconfigvdu.json....
    Write                  sudo kill -SIGCONT ${PIDinitCP}
    sleep   10
    Write               ps wwaux | grep CPCONFIG
    ${CPfin}    Read
    Should Not Contain         ${CPfin}      cpconfigvdu.json
    FOR  ${i}   IN RANGE   999
         write    ps wwaux | grep CPCONFIG
         #${f1_status}=  read command output
         ${CPCONFIG_status}    Read    delay=1s
         log   ${CPCONFIG_status}
         ${FOR}=  Run Keyword And Return Status    should contain  ${CPCONFIG_status}  cpconfigvdu.json
         Exit FOR loop if  ${FOR}==True
    END
    ${PID2}=            Get Lines Containing String    ${CPCONFIG_status}    cpconfigvdu.json
    ${pidfinfetch}=       Fetch From Right        ${PID2}     9999${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    ${PIDfinCP}=                Fetch From Left        ${pidfinfetch}     ${SPACE}
    Log to console                    PIDinit=${PIDinitCP} PIDfin=${PIDfinCP}
    Should Not Be Equal    ${PIDinitCP}    ${PIDfinCP}
    Close Connection
