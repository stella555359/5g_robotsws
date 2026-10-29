*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh
Library         taf.gnb.oam.megazone_client                 WITH NAME   mz

Resource        ${CURDIR}/../../gnbStatus.robot
Resource        ${CURDIR}/../../coam_selenium.robot
Resource        ${CURDIR}/ABF_resources.robot
Resource        ${CURDIR}/Abf_CPRT_Logs_Check.robot

*** Keywords ***
Abf_Cell_Setup_C_OAM
    [Documentation]     The purpose of this test case is to check Analog
    ...             Beamforming activation at cOAM level only
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    Alarm initial status

    #Get beamSet infos
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=;


    ${params_distname_dict}    Create Dictionary
    ${params_values_dict}      Create Dictionary
    ${filters_params_dict}     Create Dictionary


    ${cmd}      catenate
    ...         grep "\\"com.nokia.srbts.nrbts:NRCELL\\"" ${scf_path}/save_initial_scf.xml
    ...         | awk -F "distName=" '{print $2}'| awk -F "\\"" '{print $2}'
    ${distname}=    Run    ${cmd}

    Set To Dictionary    ${params_distname_dict}    actBeamforming    ${distname}
    Set To Dictionary    ${params_distname_dict}    basicBeamSet    ${distname}
    Set To Dictionary    ${params_distname_dict}    leftEdgeAngle    ${distname}
    Set To Dictionary    ${params_distname_dict}    rightEdgeAngle    ${distname}
    Set To Dictionary    ${params_distname_dict}    upperEdgeAngle    ${distname}
    Set To Dictionary    ${params_distname_dict}    lowerEdgeAngle    ${distname}
    #Set To Dictionary    ${params_distname_dict}    tiltOffset    ${distname}

    ${cmd}      catenate
    ...         grep "\\"com.nokia.srbts.nrbts:NRCELLGRP\\"" ${scf_path}/save_initial_scf.xml
    ...         | awk -F "distName=" '{print $2}'| awk -F "\\"" '{print $2}'
    ${distname}=    Run    ${cmd}

    Set To Dictionary    ${params_distname_dict}    numberOfTransmittedSsBlocks    ${distname}
    Set To Dictionary    ${params_distname_dict}    ssBurstSetPeriod    ${distname}


    Set To Dictionary    ${params_values_dict}    actBeamforming    true
    Set To Dictionary    ${params_values_dict}    basicBeamSet    @{bs}[1]
    Set To Dictionary    ${params_values_dict}    numberOfTransmittedSsBlocks    32 beams
    Set To Dictionary    ${params_values_dict}    ssBurstSetPeriod    20
    Set To Dictionary    ${params_values_dict}    leftEdgeAngle    @{bs}[3]
    Set To Dictionary    ${params_values_dict}    rightEdgeAngle    @{bs}[4]
    Set To Dictionary    ${params_values_dict}    upperEdgeAngle    @{bs}[5]
    Set To Dictionary    ${params_values_dict}    lowerEdgeAngle    @{bs}[6]
    #Set To Dictionary    ${params_values_dict}    tiltOffset    ${EMPTY}



    Set To Dictionary    ${filters_params_dict}    actBeamforming    Activate Beamforming
    Set To Dictionary    ${filters_params_dict}    basicBeamSet    Basic Beam Set
    Set To Dictionary    ${filters_params_dict}    leftEdgeAngle    Left Cell Edge Angle
    Set To Dictionary    ${filters_params_dict}    rightEdgeAngle    Right Cell Edge Angle
    Set To Dictionary    ${filters_params_dict}    upperEdgeAngle    Upper Cell Edge Angle
    Set To Dictionary    ${filters_params_dict}    lowerEdgeAngle    Lower Cell Edge Angle
    #Set To Dictionary    ${filters_params_dict}     tiltOffset    Tilt Offset
    Set To Dictionary    ${filters_params_dict}    numberOfTransmittedSsBlocks    Number of transmitted Synchronization Signal Blocks
    Set To Dictionary    ${filters_params_dict}    ssBurstSetPeriod    SS Burst Set Period

    log    ${params_distname_dict}
    log    ${params_values_dict}
    log    ${filters_params_dict}

    Set Multiples Parameters Values    params_distname_dict=${params_distname_dict}    params_values_dict=${params_values_dict}
    ...                                filters_params_dict=${filters_params_dict}    timeout=300

    Abf_CPRT_Logs_Check    ${beamset}

    Alarm final status
