*** Settings ***
Documentation    This suite contains 5GC000475 ConfigManagement Admin test cases

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Resource    ../Resources/Common_ConfigManagement_Admin_Keywords.robot
Resource    ../Resources/Common_Delta_Keywords.robot


*** Keywords ***
Enable DL Forwarding Feature in gNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${dl_forwarding_params_dict}    Create Dictionary    actDlDataForwardingX2=true    tDCoverall=15000
    Update DL Forwarding Parameters    nrbts_distname=${NRBTS_DISTNAME}    &{dl_forwarding_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Update tDCoverall param in gNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${td_params_dict}    Create Dictionary    tDCoverall=5000
    Update DL Forwarding Parameters    nrbts_distname=${NRBTS_DISTNAME}    &{td_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get tDCoverall Param From gNB
    ${tDCoverall_params_list}    Create List    tDCoverall
    ${scf_path}    admin_helper.download current scf file
    ${tDCoverall_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${tDCoverall_params_list}    ${NRBTS_DISTNAME}
    [Return]    ${tDCoverall_dict}

Update Original tDCoverall param in gNB
    [Arguments]    ${td_params_dict}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update DL Forwarding Parameters    nrbts_distname=${NRBTS_DISTNAME}    &{td_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

