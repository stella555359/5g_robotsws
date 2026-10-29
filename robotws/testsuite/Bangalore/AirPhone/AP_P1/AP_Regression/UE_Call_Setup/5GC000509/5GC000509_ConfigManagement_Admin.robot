*** Settings ***
Documentation    This file contains 5GC000509 ConfigManagement Admin keywords

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Resource    ../Resources/Common_ConfigManagement_Admin_Keywords.robot
Resource    ../Resources/Common_Delta_Keywords.robot
Resource    ./5GC000509_Delta_Keywords.robot


*** Keywords ***
Disable DL Forwarding Feature in gNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${dl_forwarding_params_dict}    Create Dictionary    actDlDataForwardingX2=false
    Update DL Forwarding Parameters    nrbts_distname=${NRBTS_DISTNAME}    &{dl_forwarding_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get Cipher Parameters From gNB
    ${cipher_params_list}    Create List    nea0    nea1_128    nea2_128    nea3_128
    ${scf_path}    admin_helper.download current scf file
    ${cipher_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${cipher_params_list}
    ...    ${NRBTS_DISTNAME}    cipherPrefL
    [Return]    ${cipher_dict}

Get NullFallback Parameter From gNB
    ${null_fallback_list}    Create List    nullFallback
    ${scf_path}    admin_helper.download current scf file
    ${null_fallback_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${null_fallback_list}
    ...    ${NRBTS_DISTNAME}
    [Return]    ${null_fallback_dict}

Update Original Cipher Params in gNB
    [Arguments]    ${cipher_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Cipher Parameters    nrbts_distname=${NRBTS_DISTNAME}    listname=cipherPrefL    &{cipher_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Update Original nullfallback Param in gNB
    [Arguments]    ${nullfallback_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update NullFallback Parameter    nrbts_distname=${NRBTS_DISTNAME}    &{nullfallback_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Set Cipher Algorithm Parameters
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${cipher_params_dict}    Create Dictionary    nea0=0    nea1_128=6   nea2_128=0   nea3_128=0
    Update Cipher Parameters    nrbts_distname=${NRBTS_DISTNAME}    listname=cipherPrefL    &{cipher_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Set NullFallback Parameter
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${nullfallback_dict}    Create Dictionary    nullFallback=false
    Update NullFallback Parameter    nrbts_distname=${NRBTS_DISTNAME}    &{nullfallback_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get CBRA Preamble Parameter From gNB
    ${cbra_preamble_list}    Create List    cbraPreamblesPerSsb
    ${scf_path}    admin_helper.download current scf file
    ${cbra_preamble_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${cbra_preamble_list}
    ...    ${NRCELL_DISTNAME}
    [Return]    ${cbra_preamble_dict}

Set CFRA Dedicated Preambles
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${preamble_dict}    Create Dictionary    cbraPreamblesPerSsb=n60
    Update CBRA Preamble Parameter    nrcell_distname=${NRCELL_DISTNAME}    &{preamble_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Update Original CBRA Preamble Param in gNB
    [Arguments]    ${preamble_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update CBRA Preamble Parameter    nrcell_distname=${NRCELL_DISTNAME}    &{preamble_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}
