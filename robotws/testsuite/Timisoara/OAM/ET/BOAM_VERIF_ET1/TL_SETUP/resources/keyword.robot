*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String

Resource    ../../resources/admin.robot
Resource    ../../resources/system.robot


*** Variables ***

${TEST_LOG_DIR}=    /home/ute
${jenkins_url}         http://files.ute.nsn-rdnet.net/builds/enb/base/
*** Keywords ***

Branch or Trunk Jenkins
    ${BRANCH_from_JENKINS}=     Run  command=cat ~/jenkins/branch.txt

    Set Global Variable  ${BRANCH_from_JENKINS}

Precondition and DW software

    Log to Console  Check if SW already active

    Set Suite Variable  ${SKIP}  false
    Run  command=echo ${SKIP} > ~/jenkins/skip.txt

    ${new_build}=    Replace Branch for Trunk
    ${result}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    ${SWR}  ${output1}  Run Keyword And Ignore Error  should contain  ${result}  TargetBD_${new_build}.xml
    Set Global Variable  ${SWR}

#    Log to Console  ${BRANCH_from_JENKINS}
#
    ${last_build}=  Run Keyword If   '${BRANCH_from_JENKINS}' == 'SBTS00'
    ...                      Run  command=cat ~/jenkins/lastSBTS00.txt
    ...  ELSE IF    '${BRANCH_from_JENKINS}'=='SBTS22R3'      Run  command=cat ~/jenkins/lastSBTS22R3.txt
    ...  ELSE IF    '${BRANCH_from_JENKINS}'=='SBTS22R2'      Run  command=cat ~/jenkins/lastSBTS22R2.txt
    ...  ELSE     Fail

    Log to Console  last: ${last_build}

#${last_build}=   Run  command=cat ~/jenkins/lastSBTS00.txt

    Run Keyword If  '${last_build}'=='${CIT_software_Promoted}'
    ...    Run Keywords  log to console  ${CIT_software_Promoted} already tested
    ...  AND  Set Global Variable  ${SKIP}  true
    ...  ELSE IF  '${BRANCH_from_JENKINS}'=='SBTS00'
    ...    Run  command=echo ${CIT_software_Promoted} > ~/jenkins/lastSBTS00.txt
    ...  ELSE IF  '${BRANCH_from_JENKINS}'=='SBTS22R3'
    ...    Run  command=echo ${CIT_software_Promoted} > ~/jenkins/lastSBTS22R3.txt
    ...  ELSE IF  '${BRANCH_from_JENKINS}'=='SBTS22R2'
    ...    Run  command=echo ${CIT_software_Promoted} > ~/jenkins/lastSBTS22R2.txt

    Log to Console  skip: ${SKIP}

    Run keyword If    '${SWR}' == 'PASS' or '${SKIP}' == 'true'
#    ...  log to console  ${SWR} :if PASS download not needed
    ...  Run  command=echo ${SKIP} > ~/jenkins/skip.txt
    ...  ELSE
    ...  Download SW

Download SW

    log to console  Start download ${CIT_software_Promoted}
    ${software_split}=    Split String
    ...                          string=${CIT_software_Promoted}
    ...                          separator=_
    ...                          max_split=4

    ${BRANCH}=   Get from list         ${software_split}    0
    Set Global Variable  ${BRANCH}

    Run Keyword If  '${BRANCH}'=='SBTS00'   Download SW from WFT
    ...   ELSE IF   '${BRANCH}'=='SBTS22R3'   Download SW from WFT
    ...   ELSE IF   '${BRANCH}'=='SBTS22R2'   Download SW from WFT
    ...   ELSE IF   '${BRANCH}'=='SBTS22R1'   Download SW from WFT

Download SW from WFT

    ${download_build}=        Set Variable   ${CIT_software_Promoted}

    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${jenkins_url}${download_build}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}

    Log    Download completed    console=yes

Replace Branch for Trunk
    ${split_build}=    Split string       ${CIT_software_Promoted}    separator=\_
    ${branch_flag}=   Get from list       ${split_build}     0

    ${replaced_build}=    Run keyword if    '${branch_flag}'=='SBTS00'    Replace String    ${CIT_software_Promoted}    ${branch_flag}    SBTS22R4
    ...   ELSE IF   '${branch_flag}'=='SBTS22R3'    Set Variable   ${CIT_software_Promoted}
    ...   ELSE IF   '${branch_flag}'=='SBTS22R2'    Set Variable   ${CIT_software_Promoted}
    ...   ELSE IF   '${branch_flag}'=='SBTS22R1'    Set Variable   ${CIT_software_Promoted}
    [return]  ${replaced_build}

Verify SW Version
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='9999'  ADMIN Check If Alarm Is Active   fault_id=1936
	...                    ELSE IF   '${BRANCH}'=='0010'  ADMIN Check If Alarm Is Not Active   fault_id=1936

Wait No Ping
    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.129
    ${ping_command}  taf_ssh.read output
    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
    taf_ssh.disconnect    connection=SC

Update Software With Activation
    log to console  SWR on going
    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}${CIT_software_Promoted}_release_BTSSM_downloadable.zip
    ...    timeout=3600

#    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period

#    log to console  check BTS Is OnAir
#    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

    log to console  Check BBMOD and SMOD
    Wait until keyword succeeds  900  30   Check if BBMOD is in availabilityStatus Online
    Wait until keyword succeeds  900  30   Check if SMOD is in availabilityStatus Online
#    sleep  300
#    ${active_build}=    Replace SW Version
#
#    ${output}=  SYSTEM Execute Command On gNB
#    ...    command=ls /ffs/run/
#    should contain  ${output}  	TargetBD_${active_build}.xml

Replace SW Version
    ${split_build}=    Split string       ${CIT_software_Promoted}    separator=\_
    ${version_flag}=   Get from list       ${split_build}     0

    ${active_build}=    Run keyword if    '${BRANCH}'=='SBTS00'    Replace String    ${CIT_software_Promoted}    ${version_flag}    SBTS22R4
    ...   ELSE IF   '${BRANCH}'=='SBTS22R3'    Set Variable   ${CIT_software_Promoted}
    ...   ELSE IF   '${BRANCH}'=='SBTS22R2'    Set Variable   ${CIT_software_Promoted}
    ...   ELSE IF   '${BRANCH}'=='SBTS22R1'    Set Variable   ${CIT_software_Promoted}
    [return]  ${active_build}

Configuration Reset
    log to console  Perform Config Reset
    ADMIN Configuration Reset
    sleep  600
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Wait Until Keyword Succeeds  300  30    ADMIN Check BTS Not Commisioned

SWR and commisioning in Branch
    log to console  SWR in Branch
    Update Software With Activation
    Wait until keyword succeeds  900  60   ADMIN Check BTS Not Commisioned
##    wait until keyword succeeds  240s  10s    Check if RMOD is in availabilityStatus Online
#    ### Site reset !
#    ####  BBMOD operational state enabled
#    sleep  900

#    log to console  Check BBMOD and SMOD
#    Wait until keyword succeeds  900  30   Check if BBMOD is in availabilityStatus Online
#    Wait until keyword succeeds  900  30   Check if SMOD is in availabilityStatus Online

    log to console  Perform commissioning with default scf: {Scf_Default_${Actual_Branch}}
    PREPOST Setup Admin
    ADMIN Perform Commissioning  ${Scf_Default_${Actual_Branch}}  True

SWR and commisioning in Trunk
    log to console  SWR in Trunk
    Update Software With Activation

##    wait until keyword succeeds  240s  10s    Check if RMOD is in availabilityStatus Online
#    ### Site reset !
#    log to console  Check BBMOD and SMOD
#    Wait until keyword succeeds  900  30   Check if BBMOD is in availabilityStatus Online
#    Wait until keyword succeeds  900  30   Check if SMOD is in availabilityStatus Online
#    sleep  900

    log to console  Perform commissioning with default scf: ${Scf_Default_Trunk}
    ADMIN Perform Commissioning  ${Scf_Default_Trunk}  True

Check if BBMOD is in availabilityStatus Online
    [Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=none

Check if SMOD is in availabilityStatus Online
#    [Arguments]      ${timeout}=30s
#    ${status}  Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
#    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/SMOD_R-1
#    ...      value=Online
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...      value=none
