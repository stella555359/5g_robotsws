*** Settings ***

Documentation     Keywords related to UTE handling

Library    ./python/ute_handler.py
Resource    ./testline.robot
Resource    ./qualcomm.robot

*** Variables ***
&{ABSTRACT_LIB_CONFIG}    UE_POOLS=&{EMPTY}


*** Keywords ***

Create Configuration for UTE UE
    [Documentation]    :Author: Jing Liang
    ...    Should be used at Suite Setup
    ...    right now only support Qualcomm, Viavi
    ${ue_num}=    Get length    ${tl.ues}
    FOR    ${ue_id}    IN RANGE    ${ue_num}
        ${ue_type}=    testline.Get UE type    ue_id=${ue_id}
        ${ABSTRACT_LIB_CONFIG}=    ute_handler.create_ue_configuration
    ...    config=${ABSTRACT_LIB_CONFIG}    tl=${tl}    ue_id=${ue_id}    ue_type=${ue_type}
    END
    Set Suite Variable    ${ABSTRACT_LIB_CONFIG}
