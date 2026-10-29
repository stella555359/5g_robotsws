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
...     Setup egate  egate_port=20000  alias=default

*** Variables ***
${lua_cfg}=      SA_TDD_2c_1gNBSim_3amf_TC4.lua

*** Test Cases ***
example
    [Tags]    A1
    Observe AMFConfigurationUpdate for indefinite time
    Observe NGSetupResponse for indefinite time
    Register callback
    ...     NGSetupResponse
    ...     save_guamis_and_types
    Register callback
    ...     AMFConfigurationUpdate
    ...     save_guamis_and_types
#    Lock NGAP links
    EXPECT FLOW: AMF1 NGAP nGSetup
    EXPECT FLOW: AMF2 NGAP nGSetup
    EXPECT FLOW: AMF3 NGAP nGSetup
#    Unlock NGAP links
    Execute egate command  cmd=link_drop link=ng by=amf:1 to=gnb:2
    Execute egate command  cmd=link_drop link=ng by=amf:2 to=gnb:2
    Execute egate command  cmd=link_drop link=ng by=amf:3 to=gnb:2

    PASS FLOW: AMF1 NGAP nGSetup
    PASS FLOW: AMF2 NGAP nGSetup
    PASS FLOW: AMF3 NGAP nGSetup
    wait for number of updates          3
    run keyword and continue on failure
    ...  AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped
    run keyword and continue on failure
    ...  AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped
    run keyword and continue on failure
    ...  AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:mapped
    ...  guami:1-2-3,guami_type:native
    ...  guami:1-2-4,guami_type:native
