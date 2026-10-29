*** Settings ***
Documentation
...    Author: Dan Moldovan
...    Maintainer:dan.moldovan@nokia.com
...    Group in charge: MN
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB008141-5G-A/general.robot
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB008141-5G-A/general_1.robot

Library         String
Library         Telnet
Library         OperatingSystem
Library         Process
Library         SeleniumLibrary
Library         SSHLibrary
Library         OperatingSystem
Library         DateTime

Resource       ../../resources/admin.robot
Resource       ../../resources/pretest_posttest.robot
Resource       ../../resources/fault_trigger.robot
Resource    ../../resources/selenium_oru.robot
Resource    ../../resources/orusim.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${SCF_path}=       ${CURDIR}/Configuration_ORAN_BfActive_4Beams_CellOnAir_scf.xml
${enb_web_alias}    ENB
${enb_admin_alias}  ADMIN
${OUT_MRBTS_ID}=    10616
${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
#${O-RU_addr}=                    10.5.55.152
#${O-RU_username}=                user
#${O-RU_password}=                Init_4321
${SYSTEM_ALIAS_ORU}=             oru
${USERNAME}     Nemuadmin
${PASSWORD}     nemuuser

${cell_dist_name}=            MRBTS-${OUT_MRBTS_ID}/NRBTS-1/NRCELL-9
${delta_file_locked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_locked.json
${delta_file_unlocked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_unlocked.json

#${command_start_docker}  echo Init_4321 | sudo -S docker run --rm --name=orusim
#     ...    --volume=/home/user/docker_share/orusim:/etc/orusim --detach --privileged
#     ...    --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v1.20.20


${scf_6beams}=                ${CURDIR}/6beamsConfiguration_scf_MRBTS.xml
${scf_4beams}=                ${CURDIR}/4beamsConfiguration_scf_MRBTS.xml
${delta_file}=                ${CURDIR}/Delta_Configuration_beam4_5_delete.json
${delta_file_beams_mute}=     ${CURDIR}/Delta_Configuration_2beams_mute.json

${O-RU_username}=                oru
${O-RU_password}=                orusim12
${oru1}=                    10.5.53.235
${alias}=  ${ADMIN_ALIAS}

*** Keywords ***

Bigger_Configured_beams_in_beam_mapping_table
     Log to console  Check  O-RU is started
     Check_and_Start_O-RU  ${oru1}
     Log to console  Perform Commissioning with 6 beams
     ADMIN Perform Commissioning
     ...     scf_file=${Scf_6beams}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4664

## *** To remain with 4 Beams -> Delete Beam4 and Beam5
## *** Also set basicBeamSet=beamSet_4 and numberOfTransmittedSsBlocks=4 beams

     ADMIN Perform Delta Recommissioning     ${delta_file}  True
## *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared
     Sleep  10
     ADMIN Perform Delta Recommissioning     ${delta_file_locked_cell}  True
     Sleep  10
     ADMIN Perform Delta Recommissioning     ${delta_file_unlocked_cell}  True
#     ADMIN Lock Cell   ${cell_dist_name}
#     ADMIN Unlock Cell   ${cell_dist_name}
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

Number of configured beams in the pre-defined beam-set matches the number of beams supported by O-RU
     Log to console  Check  O-RU is started
     Check_and_Start_O-RU  ${oru1}
     ADMIN Perform Commissioning
     ...     scf_file=${Scf_4beams}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  600  30    ADMIN Check BTS On Air

Mute_beams_if_number_bigger_than_supported
     Log to console  Check  O-RU is started
     Check_and_Start_O-RU  ${oru1}
    ADMIN Perform Commissioning
     ...     scf_file=${Scf_6beams}
     ...     skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
    ADMIN Perform Delta Recommissioning     ${delta_file_beams_mute}  True
## *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared
    Sleep  10
    ADMIN Perform Delta Recommissioning     ${delta_file_locked_cell}  True
    Sleep  10
    ADMIN Perform Delta Recommissioning     ${delta_file_unlocked_cell}  True
#     ADMIN Lock Cell   ${cell_dist_name}
#     ADMIN Unlock Cell   ${cell_dist_name}
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

#Check_and_Start_O-RU
#
### *** Check if O-RU is started
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    command=echo Init_4321 | sudo -S docker ps -a     #sudo docker ps -a
#     Log to console  ${reply}
#
### *** If O-RU is not started ... START O-RU !
#     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
#     Log to console  O-RU status check is :${status}
#
#     Run Keyword If  '${status}' == 'True'
#     ...   Log to console  O-RU already started !
#     ...   ELSE IF   '${status}' == 'False'
#     ...   SYSTEM Start Command On o-ru  command=${command_start_docker}
#     ...   ELSE
#     ...   Log to console  Wrong status !
#l
#        Sleep  20
### *** If O-RU is not started => fail !
#        ${reply}=  SYSTEM Start Command On o-ru
#        ...    command=echo Init_4321 | sudo -S docker ps -a     #sudo docker ps -a
#        Log to console  ${reply}
#        Should contain  ${reply}  airphone-docker
#
#     Log to console  O-RU started successfully!


#Connect_to_O-RU
#    [Documentation]
#    ...    ****************
#    ...    - [TEST PURPOSE] -The Purpose of this case is to connect to O-RU.
#    ...     -TC verifies that command sudo docker ps -a works on O-RU
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 17.06.2021 - - Created
#    ...    *******************
#    ...    elena.sabau@nokia.com
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    command=${command_start_docker}  #Start docker
#     Log to console  ${reply}
#     Sleep  20
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    command=echo Init_4321 | sudo -S docker ps -a     #sudo docker ps -a
#     Log to console  ${reply}
#     Should contain  ${reply}  airphone-docker
#     Sleep  20
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    command=echo Init_4321 | sudo -S docker stop orusim    #sudo docker kill orusim
#    Log to console  ${reply}
#    SeleniumLibrary.Close Browser


#SYSTEM Start Command On o-ru
#    [Arguments]    ${command}
#    ...            ${hostname}=${O-RU_addr}
#    ...            ${username}=${O-RU_username}
#    ...            ${password}=${O-RU_password}
#    ...            ${alias}=${SYSTEM_ALIAS_ORU}
#    taf.transport.ssh.connect_to
#    ...    hostname=${hostname}
#    ...    username=${username}
#    ...    password=${password}
#    ...    alias=${alias}
#     ${reply}=  taf.transport.ssh.execute
#    ...    command=${command}
#    ...    connection=${alias}
#    [Return]    ${reply}

