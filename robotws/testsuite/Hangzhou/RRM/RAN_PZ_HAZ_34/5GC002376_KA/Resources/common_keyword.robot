*** Settings ***
Documentation    author: Deng xueqin
...              Group: 5G_PZ_MMW_HZ_2_SG
...              contact: xueqin.deng@nokia-sbell.com

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***


*** Keywords ***
Test Suite Setup
    CI_interface.Common Suite Setup
    ${scf_path}=    Backup DU SCF
    set global variable    ${scf_path}
    Du login page via webUI
    Du Check cell on air via WebUI without login

Test Suite Teardown
    Restore DU SCF    ${scf_path}
    Wait until keyword succeeds    10 min    30 sec
	...    Du login page via webUI
    #Close DU start up window
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    Close DU start up window
	DU COAM selenium logout
    run    rm ${scf_path}

Get parameters for Beamforming
    [Documentation]  Author: Deng xueqin
    ...              Description: get beamforming parameters value
    [Arguments]    ${cell_id}
    ${actBeamforming}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=actBeamforming
    ...    filter_param=Activate Beamforming
    ${numberOfTransmittedSsBlocks}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    abbr=numberOfTransmittedSsBlocks
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ${ssBurstSetPeriod}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    abbr=ssBurstSetPeriod
    ...    filter_param=SS Burst Set Period
    ${basicBeamSet}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=basicBeamSet
    ...    filter_param=Basic Beam Set
    ${leftEdgeAngle}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=leftEdgeAngle
    ...    filter_param=Left Cell Edge Angle
    ${rightEdgeAngle}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=rightEdgeAngle
    ...    filter_param=Right Cell Edge Angle
    ${lowerEdgeAngle}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=lowerEdgeAngle
    ...    filter_param=Lower Cell Edge Angle
    ${upperEdgeAngle}    selenium_coam.get_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=upperEdgeAngle
    ...    filter_param=Upper Cell Edge Angle
    &{beamforming_values}=    Create Dictionary
    ...    actBeamforming=${actBeamforming}
    ...    numberOfTransmittedSsBlocks=${numberOfTransmittedSsBlocks}
    ...    ssBurstSetPeriod=${ssBurstSetPeriod}
    ...    basicBeamSet=${basicBeamSet}
    ...    leftEdgeAngle=${leftEdgeAngle}
    ...    rightEdgeAngle=${rightEdgeAngle}
    ...    lowerEdgeAngle=${lowerEdgeAngle}
    ...    upperEdgeAngle=${upperEdgeAngle}
    [Return]    ${beamforming_values}

Set parameters for specific beamset
    [Documentation]  Author: Deng xueqin
    ...              Description: set beamforming parameters value for specific beamset
    [Arguments]    ${cell_id}    ${set_beamforming_value}
    ${cur_beamforming_value}    Get parameters for Beamforming    cell_id=${cell_id}
    Run Keyword If    '${set_beamforming_value}[actBeamforming]' != '${cur_beamforming_value}[actBeamforming]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=actBeamforming
    ...    new_value=${set_beamforming_value}[actBeamforming]
    ...    filter_param=Activate Beamforming
    Run Keyword If
    ...    '${set_beamforming_value}[numberOfTransmittedSsBlocks]' != '${cur_beamforming_value}[numberOfTransmittedSsBlocks]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    abbr=numberOfTransmittedSsBlocks
    ...    new_value=${set_beamforming_value}[numberOfTransmittedSsBlocks]
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    Run Keyword If    '${set_beamforming_value}[ssBurstSetPeriod]' != '${cur_beamforming_value}[ssBurstSetPeriod]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    abbr=ssBurstSetPeriod
    ...    new_value=${set_beamforming_value}[ssBurstSetPeriod]
    ...    filter_param=SS Burst Set Period
    Run Keyword If    '${set_beamforming_value}[basicBeamSet]' != '${cur_beamforming_value}[basicBeamSet]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=basicBeamSet
    ...    new_value=${set_beamforming_value}[basicBeamSet]
    ...    filter_param=Basic Beam Set
    Run Keyword If    '${set_beamforming_value}[leftEdgeAngle]' != '${cur_beamforming_value}[leftEdgeAngle]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=leftEdgeAngle
    ...    new_value=${set_beamforming_value}[leftEdgeAngle]
    ...    filter_param=Left Cell Edge Angle
    Run Keyword If    '${set_beamforming_value}[rightEdgeAngle]' != '${cur_beamforming_value}[rightEdgeAngle]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=rightEdgeAngle
    ...    new_value=${set_beamforming_value}[rightEdgeAngle]
    ...    filter_param=Right Cell Edge Angle
    Run Keyword If    '${set_beamforming_value}[lowerEdgeAngle]' != '${cur_beamforming_value}[lowerEdgeAngle]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=lowerEdgeAngle
    ...    new_value=${set_beamforming_value}[lowerEdgeAngle]
    ...    filter_param=Lower Cell Edge Angle
    Run Keyword If    '${set_beamforming_value}[upperEdgeAngle]' != '${cur_beamforming_value}[upperEdgeAngle]'
    ...    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=upperEdgeAngle
    ...    new_value=${set_beamforming_value}[upperEdgeAngle]
    ...    filter_param=Upper Cell Edge Angle

Get Cell List
    scf.load_scf    file_path=${scf_path}
    ${cell_list}=    scf.get_all_values_from_scf    list_name=nrCellList
    [Return]    ${cell_list}

Config beamset for all cells
    [Arguments]    ${set_beamforming_value}
    ${cell_list}    Get Cell List
    FOR    ${cell_id}    IN    @{cell_list}
        Set parameters for specific beamset    cell_id=${cell_id}    set_beamforming_value=${set_beamforming_value}
    END
    sleep    1s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
