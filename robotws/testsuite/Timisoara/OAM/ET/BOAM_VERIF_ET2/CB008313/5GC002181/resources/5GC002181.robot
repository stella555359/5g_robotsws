*** Settings ***
Documentation
...    Author: Dan Novacescu (dan.novacescu@nokia.com)
...    Maintainer: Dan Novacescu (dan.novacescu@nokia.com)
...    Group in charge: RAN_BOAM_VERIF_SG02
...    References: doors
...    Feature Description:5GC002181
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BTS_VERIF_ET2/CB008313/5GC002181/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn

Resource    ../../../resources/admin.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${asoe_addr}                     192.168.255.1
${asoe_username}                 toor4nsn
${asoe_password}                 oZPS0POrRieRtu


${scf_path}             /tmp/
${scf_name}             scf_file.xml

*** Keywords ***

Check maxTransmissionDistance
    ${TransmissionDistance}    ADMIN Get Parameter
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1
        ...    parameter=maxTransmissionDistance
    ${SFP}    Get Object Distname From Class Name if List
    ...    class_name=SFP_PARAMS_L
    ${SFP1}=   get from list   ${SFP}   0
    Should Contain  ${SFP1}    maxTransmissionDistance

Get Object Distname From Class Name if List
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    @{parameters_list}   create list
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${parameters}    Get From Dictionary    ${element}    parameters
        append to list   ${parameters_list}   ${parameters}
    END
    [Return]    ${parameters_list}


