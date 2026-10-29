*** Settings ***
Documentation    Suite description
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-10143/resources/kw_10143.py
Library     taf.transport.ssh    WITH NAME    ssh
Library           BuiltIn
Library           SSHLibrary

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot

*** Variables ***

${labpcname}=                                            wro5grrm
${labpcip}=                                              10.42.22.230
${labpcpass}=                                            5gpass!1
${Emil_keywords}=                                        ${CURDIR}/Emil_processing_keywords.py
${tes_emil}=                                             ${CURDIR}/test_emil.robot


*** Keywords ***
Waiting for RRC idle
     LOG TO CONSOLE    -Waiting for UE idle
     sleep   30

Verify TDD Cell RRC_realese triggered by user inactivity
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    InactivityDetectionScenario     InactivityDetectionScenario started for ueIdCuUp
    check if exist in syslog    BearerContextInactivityNotificatio
    ...                         CP-NRT send BearerContextInactivityNotification to CP-IF

Verify RRC_realese contains freqPriorityListNR
    Log to console   Getting freqPriorityListNR drom DCAP to do

Verify TDD SCell configuration
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    AddedServingCellsList     Store addedSCellList:AddedServingCellsList
    check if exist in syslog    ScellAddition
    ...                         ScellAddition procedure Completed with No ScellAddition Error for ueIdCu

Verify TDD SCell activation
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    handleActivateMacCe     handleActivateMacCe done for UE


Read counters value 10143
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55124C00001
    FOR    ${counter}    IN      @{counters}
       ${value}    Get Last Counter Values     ${counter}
       Append To List      ${counters_values}      ${value
    END
    [Return]        ${counters_values}

Verify PM Counters for 10143
    log to console              Verify PM counters values
    ${counters}                 Read Counters Value 10143
    ${NRRCC_RRC_RELEASE_SENT}   get counter value   ${counters}  101      M55124C00001
    Should Be True      1<=${NRRCC_RRC_RELEASE_SENT}

#Get dcap bts id by IP
#    [Arguments]    ${host}
#    ${dcap_bts_info}   Dcap get all bts info
#    ${bts_id}      get dcap bts id   ${dcap_bts_info}   ${host}
#    Run keyword if   ${bts_id} is not None    Dcap delete bts   ${bts_id}
#    [Return]   ${bts_id}

###  DCAP
#Mkdir for EMil script
#    SSHLibrary.Open Connection   host=${labpcip}
#    SSHLibrary.Login  username=${labpcname}    password=${labpcpass}
#    SSHLibrary.execute_command  command=rm -r -v c:/robot_script
#    sleep  3s
#    SSHLibrary.execute_command  command=mkdir c:/robot_script
#    [Teardown]  SSHLibrary.Close Connection

# Send Emil script
#     [Arguments]    ${dcap_filepath}
#     Run   sshpass -p '${labpcpass}' scp ${dcap_filepath} ${labpcname}@${labpcip}:C:/robot_script
#     Run   sshpass -p '${labpcpass}' scp ${Emil_keywords} ${labpcname}@${labpcip}:C:/robot_script
#     Run   sshpass -p '${labpcpass}' scp ${tes_emil} ${labpcname}@${labpcip}:C:/robot_script

# Check emil log
#     [Arguments]  ${end_file}
#     ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
#     set test variable  ${emil_out}  ${FALSE}
#     ssh.execute   unzip C:/robot_script/*.zip -d C:/robot_script/           connection=LabPC
#     ${5gm_file_path}=  ssh.execute   find C:/robot_script/ |grep 5gm| tr -d '\n'          connection=LabPC
#     ssh.execute   mv ${5gm_file_path} C:/robot_script          connection=LabPC
#     ${execute}=  ssh.execute    robot -L trace -v end_file:*.${end_file} C:/robot_script/test_emil.robot             connection=LabPC
#     ${emil_out}=  Run keyword and return status  Should Contain  ${execute}   PASS
#     run keyword if   ${emil_out}
#     ...   Log to console   RRC_realese contains “freqPriorityListNR”
#     ...   ELSE
#     ...   Log to console  RRC_realese NOT contains “freqPriorityListNR”
#     set suite variable   ${emil_out}
#     [Teardown]  ssh.Disconnect    connection=LabPC

Set attenuators for 10143
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation_2 and check  lines=${lines_gNB_190_AHLOA_3_TDD}   value=28
