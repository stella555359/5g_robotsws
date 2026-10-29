*** Settings ***
Resource    ../resources/CB008083_common_keywords.robot

Library     ../../../resources/Python/live_guami_view.py
Resource    ta_messaging/single_message_observer.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...    Run keywords
...     Create AMF device with alias 'AMF1' identified by ip=10.0.1.11     AND
...     Create AMF device with alias 'AMF2' identified by ip=10.0.1.12     AND
...     Create AMF device with alias 'AMF3' identified by ip=10.0.1.13

*** Variables ***


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

    EXPECT FLOW: AMF1 NGAP nGSetup
    EXPECT FLOW: AMF2 NGAP nGSetup
    EXPECT FLOW: AMF3 NGAP nGSetup

    #requests
    run command
    ...   send_hex
    ...   hex=00150025000003001B00080061626300AAAAA80066000D000061626300616263000003080015400100
    ...   source=amf:1
    ...   target=gnb:2
    run command
    ...   send_hex
    ...   hex=00150025000003001B00080061626300AAAAA80066000D000061626300616263000003080015400100
    ...   source=amf:2
    ...   target=gnb:2
    run command
    ...   send_hex
    ...   hex=00150025000003001B00080061626300AAAAA80066000D000061626300616263000003080015400100
    ...   source=amf:3
    ...   target=gnb:2


    # responses
    run command
    ...   send_hex
    ...   hex=20150031000004000100060180414D46580060000F0020616263010041000000B04001000056400100005000080061626300000308
    ...   source=amf:1
    ...   target=gnb:2
    run command
    ...   send_hex
    ...   hex=20150031000004000100060180414D46580060000F0020616263010042000000B04001400056400100005000080061626300000308
    ...   source=amf:2
    ...   target=gnb:2
    run command
    ...   send_hex
    ...   hex=20150031000004000100060180414D46580060000F0020616263010043000000B04001000056400100005000080061626300000308
    ...   source=amf:3
    ...   target=gnb:2
    PASS FLOW: AMF1 NGAP nGSetup
    PASS FLOW: AMF2 NGAP nGSetup
    PASS FLOW: AMF3 NGAP nGSetup
    wait for number of updates          3
    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-1-1,guami_type:native
    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-1-2,guami_type:mapped
    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-1-3,guami_type:native
