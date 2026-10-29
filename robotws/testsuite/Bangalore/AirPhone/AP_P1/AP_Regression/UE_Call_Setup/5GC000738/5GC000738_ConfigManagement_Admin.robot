*** Settings ***
Documentation    This file contains 5GC000738 config management admin keywords

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Resource    ../../../Resources/Variables/Common_Variables.robot
Resource    ../Resources/Common_Keywords.robot
Resource    ./5GC000738_Delta_Keywords.robot
Resource    ./5GC000738_Keywords.robot
Resource    ../../../Resources/robot/log.robot

*** Variables ***
${MCC}             555
${MNC1}            10
${MNC2}            20
${MNC_Length}      2

*** Keywords ***
Get List of Parameters From gNB
    ${Ransharing_list}    create List    actRanSharing
    ${scf_path}    admin_helper.download current scf file
    ${Ransharing_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${Ransharing_list}    ${NRBTS_DISTNAME}
    set suite variable    ${Ransharing_dict}

Enable PLMN Parameters for Sngb Addition and Modification
    Initialise Delta Store    name=default
    ${mnp_dict}    Create Dictionary    mcc=${MCC}    mnc=${MNC1}    mncLength=${MNC_Length}
    Update mo and parameter to delta    nrbts_distname=${NRBTS_DISTNAME}/NRPLMN-1    &{mnp_dict}
    ${mnp_dict2}    Create Dictionary    mcc=${MCC}    mnc=${MNC2}    mncLength=${MNC_Length}
    Update mo and parameter to delta    nrbts_distname=${NRBTS_DISTNAME}/NRPLMN-2    &{mnp_dict2}
    @{plmn_listvalues}    Create List    ${NRBTS_DISTNAME}/NRPLMN-1    ${NRBTS_DISTNAME}/NRPLMN-2
    Update mo and parameter to delta    nrbts_distname=${NRCELL_DISTNAME}/NRPLMNSET_NSA-1    configuredEpsTac=0
    delta_store.add_legacy_list_parameters_to_delta    ${NRCELL_DISTNAME}/NRPLMNSET_NSA-1    nrPlmnDNList    @{plmn_listvalues}
    ${plmn_params_dict}    Create Dictionary    actRanSharing=true
    Update DL Forwarding Parameters    nrbts_distname=${NRBTS_DISTNAME}    &{plmn_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Delete PLMN Parameters
    Initialise Delta Store    name=default
    Delete managed object to delta    nrbts_distname=${NRCELL_DISTNAME}/NRPLMNSET_NSA-1
    Delete managed object to delta    nrbts_distname=${NRBTS_DISTNAME}/NRPLMN-1
    Delete managed object to delta    nrbts_distname=${NRBTS_DISTNAME}/NRPLMN-2
    Update gnb parameter    nrbts_distname=${NRBTS_DISTNAME}    &{Ransharing_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Revert PLMN parameters in GNB to original Value
    Delete PLMN Parameters