*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.config.scf    WITH NAME    scf
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
Download Scf And Make New
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${scf_file}  COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${scf_file_name}    Fetch from right    ${scf_file}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${time}  get time  epoch
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    ${time}.xml
    ${scf_file_update_path}    set variable    ${SAVE LOG DIRECTORY}/${scf_name_for_update}
    [Return]  ${scf_file}  ${scf_file_update_path}

Modify Parameters In SCF From Webem And Commission
    [Arguments]  ${modify_params}    ${gnb_index}=0    ${connection}=GNB_OAM
    ${scf_file}    ${scf_file_update_path}    Download Scf And Make New    gnb_index=${gnb_index}    connection=${connection}
    scf.Load scf    ${scf_file}
    FOR  ${item}  IN  @{modify_params}
        ${list_name}    set variable
        ${status}   ${output}   run keyword and ignore error  get from dictionary    ${item}    list_name
        ${list_name}    set variable if    '${status}'=='FAIL'    ${None}    ${output}
        scf.modify_scf_element  dist_name=${item}[dist_name]    list_name=${list_name}
        ...    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    COAM Commission with scf file    scf_file_path=${scf_file_update_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    ...    connection=${connection}

Modify beamSet Parameters via SCF
    [Arguments]  ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${tiltOffset}
    log to console  Modify beamSet Parameters via SCF
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    p_name=actBeamforming  value=${actBeamforming}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    p_name=numberOfTransmittedSsBlocks  value=${numberOfTransmittedSsBlocks}
    append to list  ${modify_params}  ${item}
    ${scf_file}    ${scf_file_update_path}    Download Scf And Make New
    scf.Load scf    ${scf_file}
    FOR  ${item}  IN  @{modify_params}
        ${list_name}    set variable
        ${status}   ${output}   run keyword and ignore error  get from dictionary    ${item}    list_name
        ${list_name}    set variable if    '${status}'=='FAIL'    ${None}    ${output}
        scf.modify_scf_element  dist_name=${item}[dist_name]    list_name=${list_name}
        ...    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.remove_list_from_scf  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1    list_name=beamSet
    ${beamSet_Dic}    Create Dictionary    basicBeamSet=${basicBeamSet}    tiltOffset=${tiltOffset}    leftEdgeAngle=${60}
    ...    nrBtsBeamRefinementP2=false    rightEdgeAngle=${60}
    scf.add list to scf  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1   list_name=beamSet
    scf.add item to list  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1    list_name=beamSet    elements=${beamSet_Dic}
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}
