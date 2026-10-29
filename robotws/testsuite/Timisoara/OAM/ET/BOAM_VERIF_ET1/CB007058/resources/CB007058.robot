*** Settings ***
Documentation
...    Author: Elena Sabau (elena.sabau@nokia.com)
...    Maintainer:
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general.robot
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general_1.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library        taf.gnb.oam.coam.admin       WITH NAME       taf_admin
#Library        ./check_errors.py
Library         taf.selenium.sbts
Library         taf.transport.ssh   WITH NAME   csn
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
${enb_web_alias}    ENB
${enb_admin_alias}  ADMIN
${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${command}
${O-RU_addr}=                    10.5.53.235
#${O-RU_username}=                o-ru_simulation
#${O-RU_password}=                Init_4321
${result}
${SYSTEM_ALIAS_ORU}=             oru
${host_ip_address}=              10.5.53.235
${reply}
${USERNAME}     Nemuadmin
${PASSWORD}     nemuuser
${element_param}    actBeamforming
#${command_start_docker}  echo orusim12 | sudo -S docker run --rm --name=orusim
#     ...    --volume=/home/oru/docker_share/orusim:/etc/orusim --detach --privileged
#     ...    --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/orusim:v2.0.10
${text_error}  Whenever NRBTS-1 having NRBTS-1.actOranCUPlanePhase1 (value: true)
     ...    equal to true, NRCELL-9 having NRCELL-9.actBeamforming (value: false) equal to false,
     ...    it is required that NRCELL-9.actORuBeamforming (value: true) equal to false
#${SCF_path}=       ${CURDIR}/Configuration_ORAN_BfActive_4Beams_CellOnAir_scf.xml
${scf_actBeamforming_false}=  ${CURDIR}/Configuration_scf_actBeamforming_false.xml
${scf_onair}=  ${CURDIR}/Configuration_scf__onair_CB007058.xml
${scf_actOruBeamforming_false}=  ${CURDIR}/Configuration_scf_actOruBeamforming_false.xml
${scf_beamset_4}=                ${CURDIR}/Configuration_scf_beamset_4.xml
${scf_beamSequenceDirection_right_to_left}=                ${CURDIR}/scf_beamSequenceDirection_righttoleft_and_bottomtotop.xml
${cell_dist_name}=            MRBTS-${OUT_MRBTS_ID}/NRBTS-1/NRCELL-9
${OUT_MRBTS_ID}=    10616
${delta_file_beamset_2_2}                ${CURDIR}/Delta_Configuration_param_beamset_2_2.json
${delta_file_locked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_locked.json
${delta_file_unlocked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_unlocked.json
${delta_file_beamsequence_change}                ${CURDIR}/Delta_Configuration_beamSequenceDirection_lefttoright_and_toptobottom.json
${delta_file_actOruBeamforming_true_change}                ${CURDIR}/Delta_Configuration_scf_actOruBeamforming_true.json

${O-RU_username}=                oru
${O-RU_password}=                orusim12
${oru1}=                    10.5.53.235
${alias}=  ${ADMIN_ALIAS}

*** Keywords ***

Connect_to_O-RU
## *** Check if O-RU is started
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo orusim12 | sudo -S docker ps -a     #sudo docker ps -a
     Log to console  ${reply}

## *** If O-RU is not started ... START O-RU !
     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
     Log to console  O-RU status check is :${status}

     Run Keyword If  '${status}' == 'True'
     ...   Log to console  O-RU already started !
     ...   ELSE IF   '${status}' == 'False'
     ...   SYSTEM Start Command On o-ru  command=${command_start_docker}
     ...   ELSE
     ...   Log to console  Wrong status !
l
        Sleep  20
## *** If O-RU is not started => fail !
        ${reply}=  SYSTEM Start Command On o-ru
        ...    command=echo orusim12 | sudo -S docker ps -a     #sudo docker ps -a
        Log to console  ${reply}
        Should contain  ${reply}  airphone-docker

     Log to console  O-RU started successfully!

16_NIDD_relationship_between_actORuBeamforming_actBeamforming_and_actNcYgMPlane
     Log to console  Check  O-RU is started
     Connect_to_O-RU
     Log to console  Perform Commissioning with beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_actBeamforming_false}
     ...     should_activate=False
     ...     skip_parameter_relation_errors=True
     Sleep  60
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair


4_To_setup_BF_cell_with_BF_supported_O-RU_ORUBeamFormingSupport_is_true_success_US2
     Log to console  Check  O-RU is started
     Connect_to_O-RU
     Log to console  Perform Commissioning with beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_onair}
     ...     skip_parameter_relation_errors=True
     Sleep  60
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair


13_O-RU_BF=false_cell_BF_configured_O-RU_supporting_BF_Beam_Set!=1_configured

     Log to console  Check  O-RU is started
     Connect_to_O-RU
     Log to console  Perform Commissioning with beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_actOruBeamforming_false}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=1868

## *** Also set basicBeamSet=beamSet_2_2

     ADMIN Perform Delta Recommissioning     ${delta_file_actOruBeamforming_true_change}  True
## *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared

     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

10_Predefined_beam_set_mapping_Case4
     Log to console  Check  O-RU is started
     Connect_to_O-RU
     Log to console  Perform Commissioning with beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_beamSequenceDirection_right_to_left}
     ...     skip_parameter_relation_errors=True
     Sleep  100
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
## *** Change beamSequenceDirection LefttoRight and ToptoBottom

     ADMIN Perform Delta Recommissioning     ${delta_file_beamsequence_change}  True
## *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared

     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

6_BF_cell_config_not_matching_O-RU_BF_config_FID_4664
     Log to console  Check  O-RU is started
     Connect_to_O-RU
     Log to console  Perform Commissioning with beams
     ADMIN Perform Commissioning
     ...     scf_file=${scf_beamset_4}
     ...     skip_parameter_relation_errors=True
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4664

## *** Also set basicBeamSet=beamSet_2_2

     ADMIN Perform Delta Recommissioning     ${delta_file_beamset_2_2}  True
     Sleep  10
# *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared
     ADMIN Perform Delta Recommissioning     ${delta_file_locked_cell}  True
     Sleep  10
     ADMIN Perform Delta Recommissioning     ${delta_file_unlocked_cell}  True
#     ADMIN Lock Cell   ${cell_dist_name}
#     ADMIN Unlock Cell   ${cell_dist_name}
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

Logout And Close Browser
    Run Keyword And Ignore Error    selenium_coam.Logout  coam=${enb_web_alias}
    Run Keyword And Ignore Error    selenium_coam.close_browser  coam=${enb_web_alias}

SYSTEM Execute Command On O-RU
    [Arguments]    ${command}
    ...            ${hostname}=${O-RU_addr}
    ...            ${username}=${O-RU_username}
    ...            ${password}=${O-RU_password}
    ...            ${alias}=${SYSTEM_ALIAS_ORU}
    csn.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
    ${reply}    Run Keyword And Return    csn.execute
    ...    command=${command}
    ...    connection=${alias}
    [Return]    ${reply}

SYSTEM Check If Host Is Reachable With Ping
    [Arguments]    ${host_ip_address}
    ${rc}    Run And Return Rc     ping -c 1 ${host_ip_address}
    Should Be Equal As Integers     ${rc}    0

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

Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
#    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129
#Login Credentials SBTS
#    [Arguments]    ${webem_username}=${USERNAME}
#    ...            ${webem_password}=${PASSWORD}
#    Input Text        id=login-username    ${webem_username}
#    Input Password    id=login-password    ${webem_password}
#    Click Button      locator=//button[@class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"]

