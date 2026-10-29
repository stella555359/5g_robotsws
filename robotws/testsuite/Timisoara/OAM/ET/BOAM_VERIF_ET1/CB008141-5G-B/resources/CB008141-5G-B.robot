*** Settings ***
Documentation
...    Author: Elena Sabau
...    Maintainer:elena.sabau@nokia.com
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB008141-5G-B/general.robot
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB008141-5G-B/general_1.robot

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

Resource       ../../resources/pretest_posttest.robot
Resource       ../../resources/system.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/selenium_oru.robot
Resource    ../../resources/orusim.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
#${SCF_path}=       ${CURDIR}/Configuration_ORAN_BfActive_4Beams_CellOnAir_scf.xml
${enb_web_alias}    ENB
${enb_admin_alias}  ADMIN
${OUT_MRBTS_ID}=    10617
${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${O-RU_username}=                oru
${O-RU_password}=                orusim12
${oru1}=                    10.5.55.152
${O-RU_username}=                oru
${O-RU_password}=                orusim12
${oru2}=                    10.5.53.238
${O-RU_addr}=                    10.5.55.152
${O-RU_username}=                oru
${O-RU_password}=                orusim12
${SYSTEM_ALIAS_ORU}=             oru
${USERNAME}     Nemuadmin
${PASSWORD}     nemuuser

${cell_dist_name}=            MRBTS-${OUT_MRBTS_ID}/NRBTS-10617/NRCELL-1

#${command_start_docker}  echo orusim12 | sudo -S docker run --rm --name=orusim
#     ...    --volume=/home/oru/docker_share/orusim:/etc/orusim --detach --privileged
#     ...    --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v2.0.14
${comand_start_FR2}  echo orusim12 | sudo -S docker run --rm --name=orusim
     ...    --volume=/home/oru/docker_share/orusim:/etc/orusim --detach --privileged
     ...    --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/orusim:v2.0.14
${comand_10_beams_on_O-RU}  sed -i 's/aeud-n261-32beams_sectionType3.xml/aeud-n261-32beams_sectionType3_10beams.xml/g'
     ...     orusim-config.xml
${comand_32_beams_on_O-RU}  sed -i 's/xranuser3.xml/aeud-n261-32beams_sectionType3.xml/g' orusim-config.xml
${comand_beams_for_FR1}  sed -i 's/aeud-n261-32beams_sectionType3_10beams.xml/xranuser3.xml/g' orusim-config.xml


#${delta_file_beams_mute}=     ${CURDIR}/Delta_Configuration_2beams_mute.json
${scf_32beams}=     ${CURDIR}/32beamsConfiguration_scf_MRBTS_mapping.xml
${scf_22beamsMuted}=        ${CURDIR}/Configuration_scf_MRBTS-10617_gNB10617-ORAN3-22BeamsMutedcellOnAir.xml
${delta_file_change_DuBeamId}=      ${CURDIR}/Delta_Configuration_DuBeamId_change_to_correct_value.json
${delta_file_unmute_Beam_ID_0}=     ${CURDIR}/Delta_Configuration_scf_MRBTS-10617_gNB10617-ORAN3_unmuted_beam_ID_0.json
${delta_file_mute_Beam_ID_0}=       ${CURDIR}/Delta_Configuration_scf_MRBTS-10617_gNB10617-ORAN3_muted_beam_ID_0.json
${scf_32beams_onair}=       ${CURDIR}/32beamsConfiguration_scf_MRBTS_group_mapping_onair_.xml

${delta_file_locked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_locked.json
${delta_file_unlocked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_unlocked.json

*** Keywords ***

BTS shall successfully setup NR cell with O-RAN flexible beam-group mapping
     Check_the_configuration_32_beams_and_Start_O-RU_FR2
     Log to console  Perform Commissioning with 32 beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_32beams_onair}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  420  25    ADMIN Check BTS onair

Cell setup fails when flexible beam-group mapping is wrong FID 4664
     Check_the_configuration_32_beams_and_Start_O-RU_FR2
     Log to console  Perform Commissioning with 32 beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_32beams}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4664

## *** To clear fault 4664 change the value of parameter dubeamid
## *** Also set dubeamid=0

     ADMIN Perform Delta Recommissioning     ${delta_file_change_DuBeamId}  True
## *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared
    Sleep  10
    ADMIN Perform Delta Recommissioning     ${delta_file_locked_cell}  True
    Sleep  10
    ADMIN Perform Delta Recommissioning     ${delta_file_unlocked_cell}  True
#     ADMIN Lock Cell   ${cell_dist_name}
#     ADMIN Unlock Cell   ${cell_dist_name}
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

The beam mapping table is bigger than the number of beams supported by O-RU_beams muted 5GC002001 enabled_FR2
     Check_the_configuration_10_beams_and_Start_O-RU_FR2
     ADMIN Perform Commissioning
     ...     scf_file=${scf_22beamsMuted}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
#     SSHLibrary.Close Connection

The beam mapping table is bigger than the number of beams supported by O-RU cell setup fails _ FID 4664_FR2
     Check_the_configuration_10_beams_and_Start_O-RU_FR2
     ADMIN Perform Delta Recommissioning     ${delta_file_unmute_Beam_ID_0}  True
     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4664
     ADMIN Perform Delta Recommissioning     ${delta_file_mute_Beam_ID_0}  True
    Sleep  10
    ADMIN Perform Delta Recommissioning     ${delta_file_locked_cell}  True
    Sleep  10
    ADMIN Perform Delta Recommissioning     ${delta_file_unlocked_cell}  True
#     ADMIN Lock Cell   ${cell_dist_name}
#     ADMIN Unlock Cell   ${cell_dist_name}
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
     Check_the_configuration_beams_and_Start_O-RU_FR1
#     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=1868

Check_the_configuration_beams_and_Start_O-RU_FR1
## *** Check if O-RU is started on FR2 configuration
     Log to console  Open SSH Connection To O-RU
     SYSTEM Open SSH Connection To o-ru  ${oru1}
     SSHLibrary.Write    cd docker_share/orusim/
     Log to console  Searching for Keyword
     SSHLibrary.Read Until       orusim]$
     Log to console  Searching for axranuser3.xml
     SSHLibrary.Write    grep -i "xranuser3.xml" orusim-config.xml
     ${reply}=  SSHLibrary.Read Until       orusim]$
     Log to console  ${reply}
     ${contains}=    Run Keyword And Return Status    Should Contain    ${reply}    xranuser3.xml
     Run Keyword If  '${contains}' == 'True'
     ...   Log to console  Configuation xranuser3.xml found !
     ...   ELSE
     ...   Run command to configure O-RU for FR1

Check_the_configuration_10_beams_and_Start_O-RU_FR2
## *** Check if O-RU is started on FR2 configuration
     Log to console  Open SSH Connection To O-RU
#     SYSTEM Open SSH Connection To O-RU
     SYSTEM Open SSH Connection To o-ru  ${oru1}
     SSHLibrary.Write    cd docker_share/orusim/
     Log to console  Searching for Keyword
     SSHLibrary.Read Until       orusim]$
     Log to console  Searching for aeud-n261-32beams_sectionType3_10beams.xml
     SSHLibrary.Write    grep -i "aeud-n261-32beams_sectionType3_10beams.xml" orusim-config.xml
     ${reply}=  SSHLibrary.Read Until       orusim]$
     Log to console  ${reply}
     ${contains}=    Run Keyword And Return Status    Should Contain    ${reply}    aeud-n261-32beams_sectionType3_10beams.xml
     Run Keyword If  '${contains}' == 'True'
     ...   Log to console  Configuation aeud-n261-32beams_sectionType3_10beams.xml found !
     ...   ELSE
     ...   Run command to configure O-RU with 10 beams

Check_the_configuration_32_beams_and_Start_O-RU_FR2
## *** Check if O-RU is started on FR2 configuration
     Log to console  Open SSH Connection To O-RU
     SYSTEM Open SSH Connection To o-ru  ${oru1}
#     SYSTEM Open SSH Connection To O-RU
     SSHLibrary.Write    cd docker_share/orusim/
     Log to console  Searching for Keyword
     SSHLibrary.Read Until       orusim]$
     Log to console  Searching for aeud-n261-32beams_sectionType3.xml
     SSHLibrary.Write    grep -i "aeud-n261-32beams_sectionType3.xml" orusim-config.xml
     ${reply}=  SSHLibrary.Read Until       orusim]$
     Log to console  ${reply}
     ${contains}=    Run Keyword And Return Status    Should Contain    ${reply}    aeud-n261-32beams_sectionType3.xml
     Run Keyword If  '${contains}' == 'True'
     ...   Log to console  Configuation aeud-n261-32beams_sectionType3.xml found !
     ...   ELSE
     ...   Run command to configure O-RU with 32 beams

Run command to configure O-RU for FR1
     SYSTEM Open SSH Connection To O-RU  ${oru1}
     SSHLibrary.Write    cd docker_share/orusim/
     Log to console  Searching for Keyword
     SSHLibrary.Read Until       orusim]$
## *** set on o-ru the configuration FR1
     SSHLibrary.Write    ${comand_beams_for_FR1}
     SSHLibrary.Read Until       orusim]$
## *** O-RU is stop and create a new container with configuration proper
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo orusim12 | sudo -S docker stop orusim     #sudo docker ps -a
     Log to console  ${reply}
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=${comand_start_FR2}     #sudo docker ps -a

Run command to configure O-RU with 10 beams
     SYSTEM Open SSH Connection To O-RU  ${oru1}
     SSHLibrary.Write    cd docker_share/orusim/
     Log to console  Searching for Keyword
     SSHLibrary.Read Until       orusim]$
## *** set on o-ru the configuration with 10 beams
     SSHLibrary.Write    ${comand_10_beams_on_O-RU}
     SSHLibrary.Read Until       orusim]$
## *** O-RU is stop and create a new container with configuration proper
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo orusim12 | sudo -S docker stop orusim     #sudo docker ps -a
     Log to console  ${reply}
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=${comand_start_FR2}     #sudo docker ps -a

Run command to configure O-RU with 32 beams
     SYSTEM Open SSH Connection To O-RU  ${oru1}
     SSHLibrary.Write    cd docker_share/orusim/
     Log to console  Searching for Keyword
     SSHLibrary.Read Until       orusim]$
## *** set on o-ru the configuration with 32 beams
     SSHLibrary.Write    ${comand_32_beams_on_O-RU}
     SSHLibrary.Read Until       orusim]$
## *** O-RU is stop and create a new container with configuration proper
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo orusim12 | sudo -S docker stop orusim     #sudo docker ps -a
     Log to console  ${reply}
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=${comand_start_FR2}     #sudo docker ps -a

Default_oru_image_FR1
     Log to console  Start O-RU_container and O-RU1
     Check_and_Stop_O-RU_container  ${oru1}
     Check_and_Start_O-RU_container  ${oru1}
     Check_and_Start_O-RU  ${oru1}

#SYSTEM Open SSH Connection To O-RU
### *** open ssh connection O-RU
#    SYSTEM Open SSH Connection    host=${O-RU_addr}
#    ...                           port=22
#    ...                           username=${O-RU_username}
#    ...                           password=${O-RU_password}
#    ...                           alias=oru
#
#SYSTEM Open SSH Connection
#    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
#    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=20    alias=${alias}
#    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

#Check_and_Start_O-RU
#
### *** Check if O-RU is started
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    command=echo orusim12 | sudo -S docker ps -a     #sudo docker ps -a
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
#
#        Sleep  20
### *** If O-RU is not started => fail !
#        ${reply}=  SYSTEM Start Command On o-ru
#        ...    command=echo orusim12 | sudo -S docker ps -a     #sudo docker ps -a
#        Log to console  ${reply}
#        Should contain  ${reply}  airphone-docker
#
#     Log to console  O-RU started successfully!

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

