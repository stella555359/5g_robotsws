*** Settings ***
Documentation    This file contains 5GC001301 config management admin keywords

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Resource    ../../../Resources/Variables/Common_Variables.robot
Resource    ../Resources/Common_Keywords.robot
Resource    ./5GC001301_Delta_Keywords.robot
Resource          ./5GC001301_Keywords.robot
Resource          ../../../Resources/robot/log.robot

*** Variables ***
&{tddframe_list_params}        frameStructureType=semiStatic    ulDlDataSlotRatio=1/4    guardPeriodLength=2Symbols
                               ...    tdLteUlDlConfig=tdLteConfig2
&{tddframe1070_list_params}    frameStructureType=semiStatic    ulDlDataSlotRatio=3/7    guardPeriodLength=2Symbols
                               ...    tdLteUlDlConfig=tdLteConfig2
${tddframe_list_name}          tddFrameStructure
&{prach_params}    prachPreambleFormat=13    prachStartSymbol=2    ssBurstSetPeriod=20
                               ...    dlBandwidth=273    ulBandwidth=273

*** Keywords ***
Get List of Prach Parameters From gNB
    ${prach_list}    create List    prachConfigurationIndex
    ${tddframe_list_params}    create List    frameStructureType    ulDlDataSlotRatio    guardPeriodLength    tdLteUlDlConfig
    ${chBw_list}    create List    chBw
    ${burstperiod_list}    create list     ssBurstSetPeriod
    ${scf_path}    admin_helper.download current scf file
    ${prach_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${prach_list}    ${NRCELL_DISTNAME}
    ${tddframe_list_params}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${tddframe_list_params}   ${NRCELL_DISTNAME}
    ...    ${tddframe_list_name}
    ${channel_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${chBw_list}    ${NRCELL_DISTNAME}
    ${ssburst_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${burstperiod_list}    ${NRBTS_DISTNAME}/NRCELLGRP-0
    set suite variable    ${prach_dict}
    set suite variable    ${tddframe_list_params}
    set suite variable    ${channel_dict}
    set suite variable    ${ssburst_dict}

Enable Frame1208 Format
    Initialise Delta Store    name=default
    ${prach_dict}    Create Dictionary    chBw=100MHz    prachConfigurationIndex=196
    Update gnb parameter    nrbts_distname=${NRCELL_DISTNAME}    &{prach_dict}
    Update frame parameters    nrbts_distname=${NRCELL_DISTNAME}    listname=${tddframe_list_name}    &{tddframe_list_params}
    ${BurstPeriod_dict}    Create Dictionary    ssBurstSetPeriod=20
    Update gnb parameter    nrbts_distname=${NRBTS_DISTNAME}/NRCELLGRP-0    &{BurstPeriod_dict}
    ${delta_store}    Collect Delta Store
    Recommission Prach Parameters    delta_json=${delta_store}    should_activate=${True}

Enable Frame1070 Format
    Initialise Delta Store    name=default
    ${prach_dict}    Create Dictionary    chBw=100MHz    prachConfigurationIndex=196
    Update gnb parameter    nrbts_distname=${NRCELL_DISTNAME}    &{prach_dict}
    Update frame parameters    nrbts_distname=${NRCELL_DISTNAME}    listname=${tddframe_list_name}    &{tddframe1070_list_params}
    ${BurstPeriod_dict}    Create Dictionary    ssBurstSetPeriod=20
    Update gnb parameter    nrbts_distname=${NRBTS_DISTNAME}/NRCELLGRP-0    &{BurstPeriod_dict}
    ${delta_store}    Collect Delta Store
    Recommission Prach Parameters    delta_json=${delta_store}    should_activate=${True}

Revert FrameFormat in GNB to original Value
    Initialise Delta Store    name=default
    Update gnb parameter    nrbts_distname=${NRCELL_DISTNAME}    &{prach_dict}
    Update gnb parameter    nrbts_distname=${NRCELL_DISTNAME}    &{channel_dict}
    Update frame parameters    nrbts_distname=${NRCELL_DISTNAME}    listname=${tddframe_list_name}    &{tddframe_list_params}
    Update gnb parameter    nrbts_distname=${NRBTS_DISTNAME}/NRCELLGRP-0    &{ssburst_dict}
    ${delta_store}    Collect Delta Store
    Recommission Prach Parameters    delta_json=${delta_store}    should_activate=${True}

Recommission Prach Parameters
    [Arguments]    ${delta_json}    ${should_activate}=${True}
    admin_helper.Recommission With Delta From Admin    delta_json=${delta_json}    should_activate=${should_activate}

Set Configuration for 1208 Framestructure
    Enable Frame1208 Format
    Reboot GNB
    Check GNB Status before WTS Start
    Generate AP swconfig file for desired AP Framerate    apframe=7
    Reboot Airphone For Recovery
    Prepare Environment Based On Run Type
    Update PRACH params in WTS xml    &{prach_params}
    Start pcap collection in gNB and WTS

Set Configuration for 1070 Framestructure
    Enable Frame1070 Format
    Reboot GNB
    Check GNB Status before WTS Start
    Generate AP swconfig file for desired AP Framerate    apframe=9
    Reboot Airphone For Recovery
    Prepare Environment Based On Run Type
    Update PRACH params in WTS xml    &{prach_params}
    Start pcap collection in gNB and WTS
