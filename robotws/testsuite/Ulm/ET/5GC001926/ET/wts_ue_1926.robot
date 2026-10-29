*** Settings ***
Documentation
...    author: Jing Liang, Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for 5GC001926 WTS handling

Library     Collections
Resource    ../../../resources/Common/wts_ue.robot

*** Variables ***
${DEFAULT_BEARER}    ${9}
${AP_DL_RATE_TDD}    ${5}
${AP_DL_RATE_FDD}    ${2}
${AP_UL_RATE}        ${3}
# @{UE_LIST}         to be defined in test suite
&{AP_BEARER_DICT}    ue_1=@{EMPTY}    ue_2=@{EMPTY}
...                  ue_101=@{EMPTY}    ue_102=@{EMPTY}
&{DATA_DICT}         ue_1=@{EMPTY}    ue_2=@{EMPTY}
...                  ue_101=@{EMPTY}    ue_102=@{EMPTY}

*** Keywords ***
# UE & Core handling
Detach all NSA UEs
    FOR    ${ue_id}    IN    @{UE_LIST}
         Detach UE from LTE    ${ue_id}
    END

Attach UE on LTE with default Bearer
    [Documentation]
    ...    TODO:find out how to detect default bearer, right now hard coded
    ...    :param ue_id:    ue_id configured in WTS configuration
    [Arguments]    ${ue_id}
    Send Egate Command and verify output    cmd=ue_attach id=${ue_id}
    ...    pass_regexp=UE IS ACTIVE
    Append To List    ${AP_BEARER_DICT.ue_${ue_id}}    ${DEFAULT_BEARER}

Add Bearer on eNB for UE
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    [Arguments]    ${ue_id}    ${bearer_id}
    Send Egate Command and verify output    cmd=bearer_add ue=${ue_id} id=${bearer_id} filter=0 precedence=${bearer_id}
    ...    pass_regexp=Bearer-${bearer_id} .* created
    ${bearer_id}=    Convert to Integer    ${bearer_id}
    Append To List    ${AP_BEARER_DICT.ue_${ue_id}}    ${bearer_id}

Trigger SgNBAddition
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    [Arguments]    ${ue_id}
    ${bearers}=    evaluate    ','.join(str(i) for i in ${AP_BEARER_DICT.ue_${ue_id}})
    Send Egate Command and verify output    cmd=enb_ue_dc_start ue=${ue_id} bearer=${bearers} target_gnb=2 target_cells=1 type=split_scg
    ...    pass_regexp=reported successful RA
    Sleep    1s

Send DL data
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param bearers:  (default all) attached bearer id configured in WTS configuration
    [Arguments]    ${ue_id}    ${bearers}=all
    ${bearer_id}=    Run Keyword If
    ...    '${bearers}'=='all'    evaluate    ','.join(str(i) for i in ${AP_BEARER_DICT.ue_${ue_id}})
    ...    ELSE    Set Variable    ${bearers}
    Send Egate Command and verify output    cmd=trf_data_start ue=${ue_id} id=${bearer_id} dir=dl trf_id=2 mbps=${AP_DL_RATE_${FDD_TDD}}
    Sleep    1s

Send UL data
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param bearers:  (default all) attached bearer id configured in WTS configuration
    [Arguments]    ${ue_id}    ${bearers}=all
    ${bearer_id}=    Run Keyword If
    ...    '${bearers}'=='all'    evaluate    ','.join(str(i) for i in ${AP_BEARER_DICT.ue_${ue_id}})
    ...    ELSE    Set Variable    ${bearers}
    Send Egate Command and verify output    cmd=trf_data_start ue=${ue_id} id=${bearer_id} dir=ul trf_id=2 mbps=${AP_UL_RATE}
    Sleep    1s

Trigger SgNBModification to Add Bearer
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    [Arguments]    ${ue_id}    ${bearer_id}
    Add Bearer on eNB for UE    ue_id=${ue_id}    bearer_id=${bearer_id}
    Send Egate Command and verify output
    ...    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=SgNBReconfigurationComplete

Trigger SgNBModification to Delete Bearer
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    [Arguments]    ${ue_id}    ${bearer_id}
    Send Egate Command and verify output    cmd=trf_data_stop ue=${ue_id} id=${bearer_id}    pass_regexp=Traffic was stopped
    Sleep    10s    reason=to have stable execution
    Delete Bearer for UE    ue_id=${ue_id}    bearer_id=${bearer_id}

Delete Bearer for UE
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    [Arguments]    ${ue_id}    ${bearer_id}
    Send Egate Command and verify output
    ...    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_release=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified
    ...    pass_regexp=SgNBReconfigurationComplete
    ${bearer_id}=    Convert to Integer    ${bearer_id}
    Remove Values From List    ${AP_BEARER_DICT.ue_${ue_id}}    ${bearer_id}
    Sleep    3s

Reset Ue Info for Common Keyword
    [Documentation]    testcase teardown
    ...    or should have keyword create new UE info at setup
    FOR    ${ue_id}    IN    @{UE_LIST}
         Clean Up Bearer info on UE    ue_id=${ue_id}
         Clean Up Traffic info on UE    ue_id=${ue_id}
    END

Clean Up Traffic info on UE
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    [Arguments]    ${ue_id}
    FOR    ${data}    IN    @{DATA_DICT.ue_${ue_id}}
         Remove Values From List    ${DATA_DICT.ue_${ue_id}}    ${data}
    END

Clean Up Bearer info on UE
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    [Arguments]    ${ue_id}
    FOR    ${bearer_id}    IN    @{AP_BEARER_DICT.ue_${ue_id}}
         Remove Values From List    ${AP_BEARER_DICT.ue_${ue_id}}    ${bearer_id}
    END

Get Average Throughput for all Bearers
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param dir:      (ul / dl) traffic direction
    [Arguments]    ${ue_id}    ${dir}
    FOR    ${bearer_id}    IN    @{AP_BEARER_DICT.ue_${ue_id}}
         ${data_rate}=    Get Average Data Rate via Egate    ue_id=${ue_id}    id=${bearer_id}    trf_id=2    dir=${dir}
         Append to List    ${DATA_DICT.ue_${ue_id}}    ${data_rate}
    END

#SA
Detach all SA UEs
    FOR    ${ue_id}    IN    @{UE_LIST}
         UE Deregister    ${ue_id}
    END

Attach UE1 with two PDU sessions
    [Documentation]
    [Arguments]    ${ue_id}=1    ${nwslice}=1,2,3,5
    UE Register   ue_id=${ue_id}  nwslice=${nwslice}
    Set traffic type   ue_id=${ue_id}   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=${ue_id}   pdu_id=2   trf_type=internal
    UE PDU Session Setup    ue_id=${ue_id}  pdu=1  nwslice=1  gw=1
    UE PDU Session Setup    ue_id=${ue_id}  pdu=2  nwslice=2  gw=2  pass_regexp=Pdu Session.*successfully
    Append To List    ${AP_BEARER_DICT.ue_${ue_id}}    1
    Append To List    ${AP_BEARER_DICT.ue_${ue_id}}    2

Attach UE2 with two PDU sessions
    [Documentation]
    [Arguments]    ${ue_id}=2    ${nwslice}=1,2
    UE Register   ue_id=${ue_id}  nwslice=${nwslice}
    Set traffic type   ue_id=${ue_id}   pdu_id=3   trf_type=internal
    Set traffic type   ue_id=${ue_id}   pdu_id=4   trf_type=internal
    UE PDU Session Setup    ue_id=${ue_id}  pdu=3  nwslice=${nwslice.split(',')[0]}  gw=3
    UE PDU Session Setup    ue_id=${ue_id}  pdu=4  nwslice=${nwslice.split(',')[1]}  gw=4  pass_regexp=Pdu Session.*successfully
    Append To List    ${AP_BEARER_DICT.ue_${ue_id}}    3
    Append To List    ${AP_BEARER_DICT.ue_${ue_id}}    4

Send DL data for both UEs for all PDU sessions
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=${AP_DL_RATE_${FDD_TDD}}
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=2   qfi=1   mbps=${AP_DL_RATE_${FDD_TDD}}
    Start data traffic in egate   ue_id=2   direction=dl   protocol=udp   trf_id=1   pdu=3   qfi=1   mbps=${AP_DL_RATE_${FDD_TDD}}
    Start data traffic in egate   ue_id=2   direction=dl   protocol=udp   trf_id=1   pdu=4   qfi=1   mbps=${AP_DL_RATE_${FDD_TDD}}
    Sleep    5s


Send UL data for both UEs for all PDU sessions
    Start data traffic in egate   ue_id=1   direction=ul   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=${AP_UL_RATE}
    Start data traffic in egate   ue_id=1   direction=ul   protocol=udp   trf_id=1   pdu=2   qfi=1   mbps=${AP_UL_RATE}
    Start data traffic in egate   ue_id=2   direction=ul   protocol=udp   trf_id=1   pdu=3   qfi=1   mbps=${AP_UL_RATE}
    Start data traffic in egate   ue_id=2   direction=ul   protocol=udp   trf_id=1   pdu=4   qfi=1   mbps=${AP_UL_RATE}
    Sleep    5s

Get Average Throughput for all PDUs
    [Documentation]
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param dir:      (ul / dl) traffic direction
    [Arguments]    ${ue_id}    ${dir}
    FOR    ${pdu_id}    IN    @{AP_BEARER_DICT.ue_${ue_id}}
         ${data_rate}=    Get Average Data Rate via Egate    ue_id=${ue_id}    pdu=${pdu_id}    trf_id=1    qfi=1    dir=${dir}
         Append to List    ${DATA_DICT.ue_${ue_id}}    ${data_rate}
    END
    RETURN    ${DATA_DICT.ue_${ue_id}}
