*** Settings ***
Documentation
...    Author: Radu Catlan (radu-vasile.catlan@nokia.com)/Cristina Nicolae (cristina.nicolae@nokia.com)
...    Maintainer: Radu Catlan (radu-vasile.catlan@nokia.com)/Cristina Nicolae (cristina.nicolae@nokia.com)

Library   SeleniumLibrary
Library   SSHLibrary  timeout=10s
Library   String
Library   Process

*** Variables ***

${VDU}          https://10.5.62.58  #vDU4
${VDUSSH}       10.5.26.222
${VDUFHGW}      10.15.217.209
${FHGWPASS}     root
${RU}           root@169.254.1.2
${RU-PROXY}     ruproxy-1-0

*** Keywords ***

Connection RU
    log to console  ....Connecting to RU...
    open connection  ${VDUFHGW}
    login  _nokfhgwoperator   ${FHGWPASS}
    write  root
    write  kubectl exec -it ${RU-PROXY} bash    #for vdu6
    sleep  2
    Write  ssh ${RU}
    sleep  15
    ${readRSA}    Read     delay=5s
    log to console     ${readRSA}
   ${condition}=  run keyword and return status  should contain  ${readRSA}  Are you sure you want to continue connecting
        run keyword if   ${condition}==True  write  yes
        ...              ELSE     log to console  Info:RSA already present
    sleep  3

Trigger 1937&1936
    log to console  ....Triggering 1936&1937...
    Connection RU
    write  frmonShellClient localhost 2000
    set client configuration  timeout=60 seconds

    ${create}=  set variable  / action create ConfigAccess /CI/ConfigAccess_Module /module
    Write  ${create}
    sleep  1
    write  ${\n}
    ${readoutput1}  read  delay=2s
    ${condition}=  run keyword and return status  should contain  ${readoutput1}  done ok
        run keyword if   ${condition}==True  log to console  ConfigAccess done ok
        ...              ELSE                log to console  ConfigAccess already created

    ${download}=  set variable  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/run/tempest_inst1.json"
    Write Bare  ${download}
    sleep  1
    write  ${\n}
    ${readoutput2}  read  delay=2s
    ${condition}=  run keyword and return status  should contain  ${readoutput2}  done ok
        run keyword if   ${condition}==True  log to console  download file done ok
        ...              ELSE                log to console  download file already done

    # return into RF shell
    ${crtl_c}  evaluate  chr(int(3))
    write bare  ${crtl_c}
    ${readoutput3}  read  delay=2s
    Write  ssh ${RU}
    ${ru_output}  read  delay=2s
    ${condition}=  run keyword and return status  should contain   ${ru_output}  Do you want to continue connecting?
        run keyword if   ${condition}==True  write  y
        ...              ELSE                log to console  connection to RU already done
    write  cat /run/tempest_inst1.json | grep tempOffset
    ${tempOffset_values}  Read  delay=5s
    @{lines}=  Split to lines   ${tempOffset_values}  0  -1
    FOR  ${line}  IN  @{lines}
        ${new_line}  fetch from right   ${line}  :${SPACE}
        ${newer_line}  fetch from left  ${new_line}  ,
#        ${value_float}   Convert To Number  ${newer_line}
#        ${value_integer}   Convert To Integer   ${value_float}
#        ${value}  evaluate  abs(${value_integer})
#        ${substraction}  evaluate  80 - ${value}
#        ${new_tempOffset}  evaluate  ${substraction} + ${value}
        ${sed1}=  set variable  sed -i 's/"tempOffset": ${newer_line},
        ${sed2}=  set variable  /"tempOffset": 80,/g' /run/
        ${sed3}=  set variable  tempest_inst1.json
        ${sed}=   set variable  ${sed1}${sed2}${sed3}
        Write   ${sed}
        write   ${\n}
       ${output_sed}  read  delay=2s
    END
    Write  ssh ${RU}
    ${ru_output}  read  delay=2s
    ${condition}=  run keyword and return status  should contain   ${ru_output}  Do you want to continue connecting?
        run keyword if   ${condition}==True  write  y
        ...              ELSE                log to console  connection to RU already done
    write  cat /run/tempest_inst1.json | grep tempOffset
    ${tempOffset_values}  Read  delay=5s
    log to console  ${tempOffset_values}
    Save and Update File
#    ${sed1}=  set variable  sed -i 's/"tempOffset": 0,/"tempOffset": 80,/g' /run/
#    ${sed2}=  set variable  tempest_inst1.json
#    ${sed}=  set variable  ${sed1}${sed2}
#    Write  ${sed}
#    sleep  5
#    write  ${\n}
#    ${readoutput}  read  delay=2s
#
#


Save and Update File
    write  frmonShellClient localhost 2000
    set client configuration  timeout=60 seconds

    ${save1}=  set variable  /CI/ConfigAccess_Module action store TEMPORARY DECODED "tempest_inst1
    ${save2}=  set variable  .bin" "/run/tempest_inst1.json"
    ${save}=  set variable  ${save1}${save2}
    Write Bare  ${save}
    sleep  5
    write  ${\n}
    ${readoutput4}  read until  done ok
    log to console  ${readoutput4}
    ${condition}=  run keyword and return status  should contain  ${readoutput4}  done ok
        run keyword if   ${condition}==True  log to console  save file done ok
        ...              ELSE                log to console  save file already done

    ${update}=  set variable  /CI/ConfigAccess_Module action update
    Write Bare  ${update}
    sleep  5
    write  ${\n}
    ${readoutput5}  read until  done ok
    log to console  ${readoutput5}
    ${condition}=  run keyword and return status  should contain  ${readoutput5}  done ok
        run keyword if   ${condition}==True  log to console  update file done ok
        ...              ELSE                log to console  update file already done

    # return into RF shell
    ${crtl_c}  evaluate  chr(int(3))
    write bare  ${crtl_c}
    ${readoutput6}  read  delay=2s
#    ${nahka}=  run keyword and return status  should contain  ${readoutput6}  root@nahka-Node0:~#
#    run keyword if   ${nahka}==True  write  reboot
    log to console  Waiting for alarm 200s..
    sleep  200


Check active 1937&1936 in fault history log
     log to console  ....Checking active 1937&1936 in fault history log...
     Connection RU
     write  cd /run/
     sleep  3

     write  cat fault_history_log.txt
     sleep  3
     ${readoutput_1936_fault_history_log}  read  delay=2s
     ${fault1936_fault_history_log}  get lines containing string   ${readoutput_1936_fault_history_log}  EFaultId_TemperatureHigh (1167)
     log to console  ${fault1936_fault_history_log}
     should contain  ${fault1936_fault_history_log}  active
     should contain  ${fault1936_fault_history_log}  minor

     write  cat fault_history_log.txt
     sleep  3
     ${readoutput_1937_fault_history_log}  read  delay=2s
     ${fault1937_fault_history_log}  get lines containing string   ${readoutput_1937_fault_history_log}  EFaultId_DangerousHigh (1168)
     log to console  ${fault1937_fault_history_log}
     should contain  ${fault1937_fault_history_log}  active
     should contain  ${fault1937_fault_history_log}  critical


Login vDU
    Open Browser for ssh
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

Open Browser for ssh
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VDU}
    Sleep    10 secs


Check fault 1937 is raised in WebEM
	sleep  10
	click element  ${alarm_active}
	sleep  10
    page should contain    1937


Deactivate 1937&1936
    log to console  ....Deactivating 1937&1936...
#    Connection RU
#    ${sed1}=  set variable  sed -i 's/"tempOffset": 80,/"tempOffset": 0,/g' /run/
#    ${sed2}=  set variable  tempest_inst1.json
#    ${sed}=  set variable  ${sed1}${sed2}
#    Write  ${sed}
#    sleep  5
#    write  ${\n}
#    ${readoutput}  read  delay=2s
#
#    Save and Update File
    Connection RU
    ${readoutput}  Read  delay=2s
    ${nahka}=  run keyword and return status  should contain  ${readoutput}  root@nahka-Node0:~#
    run keyword if   ${nahka}==True  write  reboot

Check cleared 1937&1936 in fault history log
     log to console  ....Checking cleared 1937&1936 in fault history log...
     Connection RU
     write  cd /run/
     sleep  3

     write  cat fault_history_log.txt
     sleep  3
     ${readoutput_1936_fault_history_log}  read  delay=2s
     ${fault1936_fault_history_log}  get lines containing string   ${readoutput_1936_fault_history_log}  EFaultId_TemperatureHigh (1167)
     log to console  ${fault1936_fault_history_log}
     should contain  ${fault1936_fault_history_log}  cleared
     should contain  ${fault1936_fault_history_log}  minor

     write  cat fault_history_log.txt
     sleep  3
     ${readoutput_1937_fault_history_log}  read  delay=2s
     ${fault1937_fault_history_log}  get lines containing string   ${readoutput_1937_fault_history_log}  EFaultId_DangerousHigh (1168)
     log to console  ${fault1937_fault_history_log}
     should contain  ${fault1937_fault_history_log}  cleared
     should contain  ${fault1937_fault_history_log}  critical


Check fault 1937 is cleared in WebEM
    sleep  10
	click element   ${alarm_active}
	sleep  10
    wait until page does not contain    1937  timeout=400s


Logout vDU
     close connection
     sleep  5
     page should contain  Nemuadmin
     click element  user-settings
     Page Should Contain       Sign out
     sleep   6
     Click Element  //*[contains(text(),'Sign out')]
     sleep  4
     close browser
     close connection
