*** Settings ***
Resource    ../resources/CB008083_common_keywords.robot

Resource    ta_messaging/single_message_observer.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...    Run keywords
...     Create AMF device with alias 'AMF1' identified by ip=10.0.1.11     AND
...     Create AMF device with alias 'AMF2' identified by ip=10.0.1.12     AND
...     Create AMF device with alias 'AMF3' identified by ip=10.0.1.13      AND
...     create ues alias    alias=UE   id_type=wts_5g           AND
...     Setup egate  egate_port=20000  alias=default

*** Variables ***
${lua_cfg}=      SA_TDD_2c_1gNBSim_3amf_TC4.lua

*** Test Cases ***

example
    [Teardown]     Detach and kill UE1
    [Tags]    A1
    Observe AMFConfigurationUpdate for indefinite time
    Observe NGSetupResponse for indefinite time
    Register callback
    ...     NGSetupResponse
    ...     save_guamis_and_types
    Register callback
    ...     AMFConfigurationUpdate
    ...     save_guamis_and_types
    run keyword and ignore error
    ...  Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    run keyword and ignore error
    ...  Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-2,guami_type:native
    run keyword and ignore error
    ...  Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-2-3,guami_type:native
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE1 sends amf-Identifier:1-2-1,guami-Type:native and AMF1 is selected
    Expect Keyword To Pass With Ratio
    ...      2
    ...      2
    ...      UE2 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    Expect Keyword To Pass With Ratio
    ...      2
    ...      2
    ...      UE2 sends amf-Identifier:1-2-3,guami-Type:native and AMF3 is selected