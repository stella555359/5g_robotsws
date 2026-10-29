*** Settings ***
Documentation    This file contains common config management admin keywords

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Resource    ./Common_Delta_Keywords.robot

*** Keywords ***
Get DL Forwarding Parameters From gNB
    ${dl_forwarding_params_list}    Create List    actDlDataForwardingX2    tDCoverall
    ${scf_path}    admin_helper.download current scf file
    ${dl_forwarding_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${dl_forwarding_params_list}    ${NRBTS_DISTNAME}
    [Return]    ${dl_forwarding_dict}

Recommission with Updated Parameters
    [Arguments]    ${delta_json}    ${should_activate}=${True}
    admin_helper.Recommission With Delta From Admin    delta_json=${delta_json}    should_activate=${should_activate}

Update Original DL Forwarding params in gNB
    [Arguments]    ${dl_forwarding_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update DL Forwarding Parameters    nrbts_distname=${NRBTS_DISTNAME}    &{dl_forwarding_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}