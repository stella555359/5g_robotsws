*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String

Resource    ../../resources/admin.robot


*** Variables ***

${TEST_LOG_DIR}=    /home/ute
${jenkins_url}         http://files.ute.nsn-rdnet.net/builds/enb/base/
*** Keywords ***
SCF FILE
    ${SCF_FILE}    Set Variable If    '${BRANCH_from_JENKINS}' == 'master_vDU'    master_vDU.xml
        ...                           '${BRANCH_from_JENKINS}' == 'vDUCNF22R3'    vDU22R3.xml
        ...                           '${BRANCH_from_JENKINS}' == 'vDUCNF22R4'    vDU22R4.xml
    Set Global Variable  ${SCF_FILE}

Branch or Trunk Jenkins
    ${BRANCH_from_JENKINS}=     Run  command=cat ~/jenkins/branch.txt

    Set Global Variable  ${BRANCH_from_JENKINS}

#Precondition and DW software
#
#    Log to Console  Check if SW already active
#
#    Set Suite Variable  ${SKIP}  false
#    Run  command=echo ${SKIP} > ~/jenkins/skip.txt
#
#    ${new_build}=    Replace Branch for Trunk
#    ${result}=  SYSTEM Execute Command On gNB
#    ...    command=ls /ffs/run/
#    ${SWR}  ${output1}  Run Keyword And Ignore Error  should contain  ${result}  TargetBD_${new_build}.xml
#    Set Global Variable  ${SWR}
#
#    ${last_build}  Run Keyword If  '${BRANCH_from_JENKINS}'=='SBTS00'
#    ...    Run  command=cat ~/jenkins/lastSBTS00.txt
#    ...  ELSE IF ${BRANCH_from_JENKINS}'=='SBTS22R2'
#    ...    Run  command=cat ~/jenkins/lastSBTS22R2.txt
#
#    Run Keyword If  '${last_build}'=='${CIT_software_Promoted}'
#    ...    log to console  ${CIT_software_Promoted} already tested
#    ...  AND  Set Global Variable  ${SKIP} true
#    ...  ELSE IF '${BRANCH_from_JENKINS}'=='SBTS00'
#    ...    Run  command=ls ${CIT_software_Promoted} > ~/jenkins/lastSBTS00.txt
#    ...  ELSE IF '${BRANCH_from_JENKINS}'=='SBTS22R2'
#    ...    Run  command=ls ${CIT_software_Promoted} > ~/jenkins/lastSBTS22R2.txt
#
#
#    Run keyword If    '${SWR}'=='PASS'  or  ${SKIP}= 'true'
#    ...  log to console  ${SWR} :if PASS download not needed
#    ...  AND  Run  command=ls ${SKIP} > ~/jenkins/skip.txt
#    ...  ELSE
#    ...  Download SW
#
#Download SW
#
#    log to console  Start download ${CIT_software_Promoted}
#    ${software_split}=    Split String
#    ...                          string=${CIT_software_Promoted}
#    ...                          separator=_
#    ...                          max_split=4
#
#    ${BRANCH}=   Get from list         ${software_split}    0
#    Set Global Variable  ${BRANCH}
#
#    Run Keyword If  '${BRANCH}'=='SBTS00'   Download SW from WFT
#    ...   ELSE IF   '${BRANCH}'=='SBTS22R2'   Download SW from WFT
#    ...   ELSE IF   '${BRANCH}'=='SBTS22R1'   Download SW from WFT
#
#Download SW from WFT
#
#    ${download_build}=        Set Variable   ${CIT_software_Promoted}
#
#    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
#    Log    \nDownload SW packages    console=yes
#    Run    wget ${jenkins_url}${download_build}/${main_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
#
#    Log    Download completed    console=yes
#
#Replace Branch for Trunk
#    ${split_build}=    Split string       ${CIT_software_Promoted}    separator=\_
#    ${branch_flag}=   Get from list       ${split_build}     0
#
#    ${replaced_build}=    Run keyword if    '${branch_flag}'=='SBTS00'    Replace String    ${CIT_software_Promoted}    ${branch_flag}    SBTS22R3
#    ...   ELSE IF   '${branch_flag}'=='SBTS22R2'    Set Variable   ${CIT_software_Promoted}
#    ...   ELSE IF   '${branch_flag}'=='SBTS22R1'    Set Variable   ${CIT_software_Promoted}
#    [return]  ${replaced_build}
#
#Verify SW Version
#    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
#    ${active_software_split}=    Split String
#    ...                          string=${active_software}
#    ...                          separator=_
#    ...                          max_split=4
#    ${BRANCH}=   Get from list         ${active_software_split}    2
#    ${version}=  Run Keyword If  '${BRANCH}'=='9999'  ADMIN Check If Alarm Is Active   fault_id=1936
#	...                    ELSE IF   '${BRANCH}'=='0010'  ADMIN Check If Alarm Is Not Active   fault_id=1936
#
#Wait No Ping
#    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.129
#    ${ping_command}  taf_ssh.read output
#    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
#    taf_ssh.disconnect    connection=SC
#
#Update Software With Activation
#    log to console  SWR on going
#    ADMIN Update Software With Activation
#    ...    sw_package=${SW_DESTINATION}${CIT_software_Promoted}_release_BTSSM_downloadable.zip
#    ...    timeout=3600
#
#    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
#    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
#
##    log to console  check BTS Is OnAir
##    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
#
#    ${active_build}=    Replace SW Version
#
#    ${output}=  SYSTEM Execute Command On gNB
#    ...    command=ls /ffs/run/
#    should contain  ${output}  	TargetBD_${active_build}.xml
#
#Replace SW Version
#    ${split_build}=    Split string       ${CIT_software_Promoted}    separator=\_
#    ${version_flag}=   Get from list       ${split_build}     0
#
#    ${active_build}=    Run keyword if    '${BRANCH}'=='SBTS00'    Replace String    ${CIT_software_Promoted}    ${version_flag}    SBTS22R3
#    ...   ELSE IF   '${BRANCH}'=='SBTS22R2'    Set Variable   ${CIT_software_Promoted}
#    ...   ELSE IF   '${BRANCH}'=='SBTS22R1'    Set Variable   ${CIT_software_Promoted}
#    [return]  ${active_build}
