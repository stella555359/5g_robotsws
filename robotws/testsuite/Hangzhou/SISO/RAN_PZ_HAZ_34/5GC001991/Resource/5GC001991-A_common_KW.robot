*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

Resource          ../../5GC002118/Resource/5GC002118_common_KW.robot

*** Variables ***
${exp_actBeamforming}           true
${exp_basicBeamSet}             beamSet_4_2
${exp_leftEdgeAngle}            60
${exp_rightEdgeAngle}           60
${exp_tiltOffset}               0
${exp_nrBtsBeamRefinementP2}    false
${exp_numberOfTransmittedSsBlocks}    6 beams

*** Keywords ***
"${Step}" Change Parameters via webUI
    log to console    \n"${Step}": Change Parameter via webUI
#    parameters to be modified:
#    /MRBTS/NRBTS/NRCELL/actBeamforming=true
#    /MRBTS/NRBTS/NRCELL/beamSet/basicBeamSet=beamSet_4_2
#    /MRBTS/NRBTS/NRCELL/beamSet/leftEdgeAngle=60
#    /MRBTS/NRBTS/NRCELL/beamSet/rightEdgeAngle=60
#    /MRBTS/NRBTS/NRCELL/beamSet/tiltOffset=0
#    /MRBTS/NRBTS/NRCELL/beamSet/nrBtsBeamRefinementP2=false  #(default value)
#    /MRBTS/NRBTS/NRCELLGRP/numberOfTransmittedSsBlocks=6 beams
    ${Orig_actBeamforming}    Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Activate Beamforming
    ...                              p_name=actBeamforming
    Run Keyword If    '${Orig_actBeamforming}'!='${exp_actBeamforming}'    selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Activate Beamforming
    ...                              new_value=${exp_actBeamforming}
    ...                              abbr=actBeamforming
    ...                              timeout=${120}
    ${Orig_basicBeamSet}      Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Basic Beam Set
    ...                              p_name=basicBeamSet
    Run Keyword If    '${Orig_basicBeamSet}'!='${exp_basicBeamSet}'    selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Basic Beam Set
    ...                              new_value=${exp_basicBeamSet}
    ...                              abbr=basicBeamSet
    ...                              timeout=${120}
    ${Orig_leftEdgeAngle}     Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Left Cell Edge Angle
    ...                              p_name=leftEdgeAngle
    Run Keyword If   '${Orig_leftEdgeAngle}'!='${exp_leftEdgeAngle}'    selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Left Cell Edge Angle
    ...                              new_value=${exp_leftEdgeAngle}
    ...                              abbr=leftEdgeAngle
    ...                              timeout=${120}
    ${Orig_rightEdgeAngle}     Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Right Cell Edge Angle
    ...                              p_name=rightEdgeAngle
    Run Keyword If   '${Orig_rightEdgeAngle}'!='${exp_rightEdgeAngle}'    selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Right Cell Edge Angle
    ...                              new_value=${exp_rightEdgeAngle}
    ...                              abbr=rightEdgeAngle
    ...                              timeout=${120}
    ${Orig_tiltOffset}        Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Tilt Offset
    ...                              p_name=tiltOffset
    Run Keyword If   '${Orig_tiltOffset}'!='${exp_tiltOffset}'    selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=Tilt Offset
    ...                              new_value=${exp_tiltOffset}
    ...                              abbr=tiltOffset
    ...                              timeout=${120}
    ${Orig_nrBtsBeamRefinementP2}    Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=BTS Beam Refinement P2
    ...                              p_name=nrBtsBeamRefinementP2
    Run Keyword If   '${Orig_nrBtsBeamRefinementP2}'!='${exp_nrBtsBeamRefinementP2}'    selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                              filter_param=BTS Beam Refinement P2
    ...                              new_value=${exp_nrBtsBeamRefinementP2}
    ...                              abbr=nrBtsBeamRefinementP2
    ...                              timeout=${120}
    ${Orig_numberOfTransmittedSsBlocks}     Get Parameter via webUI
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-0
    ...                              filter_param=Number of transmitted Synchronization Signal Blocks
    ...                              p_name=numberOfTransmittedSsBlocks
    Run Keyword If   '${Orig_numberOfTransmittedSsBlocks}'!='${exp_numberOfTransmittedSsBlocks}'   selenium_coam.set_parameter_value
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-0
    ...                              filter_param=Number of transmitted Synchronization Signal Blocks
    ...                              new_value=${exp_numberOfTransmittedSsBlocks}
    ...                              abbr=numberOfTransmittedSsBlocks
    ...                              timeout=${120}
    selenium_coam.validate_plan
    ${defination_errors}   ${relation_errors}   ${hardware_errors}     Get Validate error
    Should be empty    ${defination_errors}
    Should be empty    ${relation_errors}
    Should be empty    ${hardware_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    Wait Until Keyword Succeeds    10min    30s     Check Cell is UP
    ${scfFile_modify}    backup commission file via WebUI    scfSaved_dir=${SAVE LOG DIRECTORY}/aftermoodify


"${Step}" Get tiltOffset values via webUI
    log to console    \n"${Step}": Get tiltOffset values via webUI

    ${maxOffset_General}    ${minOffset_General}    get tiltOffset general range
    log to console    tiltOffset general range: max=${maxOffset_General}; min=${minOffset_General}; step=${tiltStep}
    ${maxTiltOffset}    ${minTiltOffset}    get tiltOffset boundary range
    log to console    tiltOffset boundary range: max=${maxTiltOffset}; min=${minTiltOffset}; step=${tiltStep}

    # clean SOAP logs before modify tiltOffset
    Wait Until Keyword Succeeds    20min    1min    check ru ip allocation
    run keyword and ignore error   should be equal as strings    ${ru_ip}   ${ru_addr}
    ...    msg=Waring: please double check your ru addr in init.py
    Connect to gnb coam via ssl
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    #Connect to RU With Allocated IP
    #...     ru_alias=ru
    #...     asik_alias=asik
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asik
    Connect to RU With Allocated IP
    ...     ru_alias=ru
    ...     asik_alias=asik
    ...     container_id=${FHNETcontainer_id}
    run keyword and ignore error    COAM Teardown gnb connections
    sleep   1s
    set test variable    ${cmd_rm}    rm -f /ram/UnitOAM_SOAP_Log*.gz;ls /ram/UnitOAM_SOAP_Log*.xml
    ${output_cmd_SOAP}    csn.execute    command=${cmd_rm}    connection=ru    timeout=60s
    should not be empty    ${output_cmd_SOAP}
    ${SAOP_FilePath}    Fetch from left   string=${output_cmd_SOAP}    marker=${SPACE}
    ${SAOP_FilePath}    Strip string    ${SAOP_FilePath}
    set test variable    ${SAOP_FilePath}
    run keyword and ignore error    csn.disconnect    connection=ru
    run keyword and ignore error    csn.disconnect    connection=asik

"${Step}" Modify tiltOffset to trigger fault 4598
    log to console           \n"${Step}" Modify tiltOffset to trigger fault 4598
#    ${exp_tiltOffset} =    Evaluate    ${minTiltOffset} - ${tiltStep}
    ${exp_tiltOffset} =    Evaluate    ${maxTiltOffset} + ${tiltStep}
    set test variable    ${exp_tiltOffset}
    should be true    ${minOffset_General}<=${exp_tiltOffset}<=${maxOffset_General}
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    ${cells}=       coam.Get parameters for all    class_name=NRCEL   connection=GNB_OAM
    ${cells_id}=    Create List
    FOR    ${cell}    IN    @{cells}
         ${cell_id}=          Get From Dictionary    ${cell}        configurationId
         Append To List       ${cells_id}       ${cell_id}
    END
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=GNB_OAM
    ${cell_group_list}    get dictionary keys    ${cell_info}
    coam.teardown    connection=GNB_OAM
    FOR    ${cellIndex}    IN    @{cells_id}
        ${Orig_tiltOffset}        Get Parameter via webUI
        ...                                      dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...                                      filter_param=Tilt Offset
        ...                                      p_name=tiltOffset
        set test variable    ${Orig_tiltOffset}
        Sleep   2s
        Run Keyword If   '${Orig_tiltOffset}'!='${exp_tiltOffset}'
        ...    selenium_coam.set_parameter_value     dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...                                      filter_param=Tilt Offset
        ...                                      new_value=${exp_tiltOffset}
        ...                                      abbr=tiltOffset
        ...                                      timeout=${120}
        ${Orig_basicBeamSet}      Get Parameter via webUI
        ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...                              filter_param=Basic Beam Set
        ...                              p_name=basicBeamSet
        Run Keyword If    '${Orig_basicBeamSet}'!='${exp_basicBeamSet}'    selenium_coam.set_parameter_value
        ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...                              filter_param=Basic Beam Set
        ...                              new_value=${exp_basicBeamSet}
        ...                              abbr=basicBeamSet
        ...                              timeout=${120}
    END

    #${cell_group_list} = [u'NRCELLGRP-0', u'NRCELLGRP-1']
    FOR    ${cell_group}    IN    @{cell_group_list}
        ${Orig_numberOfTransmittedSsBlocks}     Get Parameter via webUI
        ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/${cell_group}
        ...                              filter_param=Number of transmitted Synchronization Signal Blocks
        ...                              p_name=numberOfTransmittedSsBlocks
        Run Keyword If   '${Orig_numberOfTransmittedSsBlocks}'!='${exp_numberOfTransmittedSsBlocks}'   selenium_coam.set_parameter_value
        ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/${cell_group}
        ...                              filter_param=Number of transmitted Synchronization Signal Blocks
        ...                              new_value=${exp_numberOfTransmittedSsBlocks}
        ...                              abbr=numberOfTransmittedSsBlocks
        ...                              timeout=${120}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

"${Step}" Check Fault 4598 via WebEM
    log to console    \n"${Step}": Check Fault 4598 via WebEM
    wait until keyword succeeds    8min    1min    WEBUI Login
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}

    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    ${cells}=       coam.Get parameters for all    class_name=NRCEL   connection=GNB_OAM
    ${cells_id}=    Create List
    FOR    ${cell}    IN    @{cells}
         ${cell_id}=          Get From Dictionary    ${cell}        configurationId
         Append To List       ${cells_id}       ${cell_id}
    END
    coam.teardown    connection=GNB_OAM
    FOR    ${cellIndex}    IN    @{cells_id}
        ${cell_name}    wait until keyword succeeds    2min    30s
        ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...    filter_param=Cell name
        set test variable     ${cell_name}
        run keyword if   '${cell_name}' == '${EMPTY}'
        ...    set test variable   ${alarming_OB}    [${BTS_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...    ELSE
        ...    set test variable   ${alarming_OB}    [${BTS_Name}][${cell_name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        wait until keyword succeeds     10min    1min    Check active fault on WebUI
        ...    alarm_filter=${alarming_OB}
        ...    Severity_expect=minor
        ...    AlarmID_expect=7115
        ...    AlarmName_expect=BASE STATION INFORMATION
        ...    FaultID_expect=4598
        ...    FaultName_expect=Tilt Offset is out of steering range
        ...    AlarmOB_expect=${alarming_OB}
#        ...    alarm_filter=Tilt Offset is out of steering range
    END

"${Step}" Check tiltOffset in SOAP logs
    log to console    \n"${Step}": Check tiltOffset in SOAP logs
    #csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    #sleep   1s
    #csn.connect to    hostname=${ru_ip}    username=${ru_username}    password=${ru_password}   alias=ru   proxy=asik
    #sleep   1s
    Connect to gnb coam via ssl
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asik
    Connect to RU With Allocated IP
    ...     ru_alias=ru
    ...     asik_alias=asik
    ...     container_id=${FHNETcontainer_id}
    set test variable    ${cmd_grep}    <parameterName>tiltOffset</parameterName><newValue>${exp_tiltOffset}</newValue>
    set test variable    ${cmd_cat}    cat ${SAOP_FilePath} | grep '${cmd_grep}'
    ${output_cmd_catSOAP}    csn.execute    command=${cmd_cat}    connection=ru    timeout=60s
    run keyword and ignore error   Should Not Be Empty    ${output_cmd_catSOAP}
    ...    msg=Waring: please double check tiltOffset in SOAP Logs
    run keyword and ignore error    csn.disconnect    connection=ru
    run keyword and ignore error    csn.disconnect    connection=asik
    run keyword and ignore error    COAM Teardown gnb connections

get tiltOffset general range
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    ${cells}=       coam.Get parameters for all    class_name=NRCEL   connection=GNB_OAM
    ${cells_id}=    Create List
    FOR    ${cell}    IN    @{cells}
         ${cell_id}=          Get From Dictionary    ${cell}        configurationId
         Append To List       ${cells_id}       ${cell_id}
    END
    coam.teardown    connection=GNB_OAM
    FOR    ${cellIndex}    IN    @{cells_id}
        ${tiltOffsetDetails}    selenium_coam.get_parameter_details
        ...                     dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...                     filter_param=Tilt Offset
        ...                     abbr=tiltOffset
        ${exist}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    dictionary=${tiltOffsetDetails}    key=Actual value    msg=parameter 'tiltOffset' is not configured.
        run keyword if  not ${exist}   selenium_coam.set_parameter_value
        ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellIndex}
        ...                              filter_param=Tilt Offset
        ...                              new_value=${0}  #set default value
        ...                              abbr=tiltOffset
        ...                              timeout=${120}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${tiltOffsetDetails}    selenium_coam.get_parameter_details
    ...                                       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                       filter_param=Tilt Offset
    ...                                       abbr=tiltOffset
    ...                                       timeout=${120}
    set test variable    ${tiltActu}    ${tiltOffsetDetails}[Actual value]
    set test variable    ${tiltStep}    ${tiltOffsetDetails}[Step]
    set test variable    ${tiltRange}    ${tiltOffsetDetails}[Range]    # -13..13
    @{result_tmp}    string.split string    ${tiltRange}    separator=...
    set test variable    ${minOffset_General}    ${result_tmp}[0]
    set test variable    ${maxOffset_General}    ${result_tmp}[-1]
    [Return]  ${maxOffset_General}  ${minOffset_General}

get tiltOffset boundary range
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    @{MOs_RMOD_L}    coam.get_managed_objects    class_name=RMOD_L   connection=GNB_OAM
    set test variable    ${distName_RMOD_L}    ${MOs_RMOD_L[0]['distName']}
    &{Dict_RMOD_BP}    coam.get_parameters    dist_name=${distName_RMOD_L}/RMOD_BP_L-1      connection=GNB_OAM
#    &{Dict_RMOD_BP}   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RMOD_BP_L-1    connection=GNB_OAM
    set test variable    ${supportedBfBeamSet}   ${Dict_RMOD_BP.supportedBfBeamSet}
    #{'beamSet': 'beamSet_4_2', 'maxTiltOffset': 5, 'minTiltOffset': -7}
    set test variable    ${maxTiltOffset}   ${Dict_RMOD_BP.supportedBfBeamSet[-3].maxTiltOffset}
    set test variable    ${minTiltOffset}   ${Dict_RMOD_BP.supportedBfBeamSet[-3].minTiltOffset}
    coam.teardown    connection=GNB_OAM
    [Return]  ${maxTiltOffset}  ${minTiltOffset}
