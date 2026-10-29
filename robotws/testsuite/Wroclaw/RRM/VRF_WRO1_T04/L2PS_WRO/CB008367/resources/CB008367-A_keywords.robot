*** Settings ***
Documentation
...    copyright: Nokia

Library    ../CB008367.py
Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/traffic_management.py

*** Keywords ***
Pump Traffic By ${x}Mbit For UEs ${start_ue}-${last_ue} With Trfid${trf_id}
    FOR    ${index}    IN RANGE    ${start_ue}-${1}    ${last_ue}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        ${ue_id}=    Evaluate    ${index}+${1}
        start_data_dl_mbps    ue_id=${ue_id}    pdu_id=${pdu_index}    trf_id1=${trf_id}    amount=${x}
    END

Display Actual Traffic For UEs ${start_ue}-${last_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${last_ue}+${1}
        Verify Tput On Scell    ue_id=${ue_id}    cc=0     tput_expected=True
    END

Attach And Pdu Session For Ues
    [Arguments]    ${ues}    ${pass_regex}
    FOR    ${index1}    IN RANGE    0    ${ues}
        ${pdu_index}=    Evaluate    ${index1}%${15}+${1}
        ${ue_id}=    Evaluate    ${index1}+${1}
        Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_index} trf_type=internal
        Attach Ue    ue_id=${ue_id}
        Execute Egate Command And Wait For Data
        ...    cmd=ue_pdu_session_setup pdu=${pdu_index} ue=${ue_id} nwslice=1 gw=${ue_id}
        ...    pass_regexp=${pass_regex}
    END


Check Allocation To Bwp For UEs
    [Arguments]    ${ue_start}    ${ue_stop}    ${bwp_type}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_stop}+1
        ${CRNTI_UE}=    Get Ue Crnti    ue_id=${ue_id}
        ${bwp_size}=    Set Variable If
        ...    "${bwp_type}" == "Large"    245
        ...    "${bwp_type}" == "Small"    217
        ${FILTER_UE}=    Catenate    f1ap.C_RNTI ==    ${CRNTI_UE}    && nr-rrc.carrierBandwidth ==${bwp_size}
        Run Keyword If    "${bwp_type}" == "Large"
        ...  Verify Tcpdump Log  packet_filter=${FILTER_UE}  number_of_messages=1
        Run Keyword If    "${bwp_type}" == "Small"
        ...  Verify Tcpdump Log  packet_filter=${FILTER_UE}  number_of_messages=2
    END

Run 9Mbps DL Traffic For Small BWP UEs
    FOR    ${index3}    IN RANGE    1    7
        Pump Traffic By 2Mbit For UEs 1-24 With Trfid${index3}
    END

Run 64Mbps DL Traffic For Large BWP UEs
    FOR    ${index2}    IN RANGE    1    7
        Pump Traffic By 13Mbit For UEs 25-32 With Trfid${index2}
        Sleep    1s
    END

Deregister ${ues} UEs
    FOR    ${dereg}    IN RANGE    1    ${ues}+1
        Execute Egate Command And Wait For Data    cmd=ue_deregister id=${dereg} ue_deregister_type=switch_off
    END

Start Downlink Traffic ${amount} ${unit} For UEs ${first_ue}-${last_ue}
    FOR    ${index6}    IN RANGE    ${first_ue}-${1}    ${last_ue}
        ${ue_id}=    Evaluate    ${index6}+${1}
        ${pdu_index}=    Evaluate    ${index6}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} dir=dl ${unit}=${amount} trf_id=1
        ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu_index} Qfi:1 TrfId:1
    END

Start Uplink Traffic With Period For UEs ${first_ue}-${last_ue}
    FOR    ${index}    IN RANGE    ${first_ue}-${1}    ${last_ue}
        ${ue_id}=    Evaluate    ${index}+${1}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} dir=ul period_ms=4 burst=3 size=200
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu_index} Qfi:1 TrfId:1
    END

Start ${amount} ${unit} Uplink Traffic For UEs ${first_ue}-${last_ue}
    FOR    ${index}    IN RANGE    ${first_ue}-${1}    ${last_ue}
        ${ue_id}=    Evaluate    ${index}+${1}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} dir=ul ${unit}=${amount}
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu_index} Qfi:1 TrfId:1
    END
