*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Library    CB008367.py

*** Keywords ***
Pump Traffic By ${x}Mbit For UEs ${start_ue}-${last_ue} With Trfid${trf_id}
    FOR    ${index}    IN RANGE    ${start_ue}-${1}    ${last_ue}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        ${ue_id}=    Evaluate    ${index}+${1}
        Start Data Dl Amount Mbps    ue_id=${ue_id}    pdu_id=${pdu_index}    trf_id1=${trf_id}    amount=${x}
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

NSA Start Downlink Traffic ${amount} ${unit} For UEs ${first_ue}-${last_ue}
    FOR    ${index6}    IN RANGE    ${first_ue}-${1}    ${last_ue}
        ${ue_id}=    Evaluate    ${index6}+${1}
#        ${pdu_index}=    Evaluate    ${index6}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start id=2 ue=${ue_id} dir=dl ${unit}=${amount}
        ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id}
    END

NSA Start ${amount} ${unit} Uplink Traffic For UEs ${first_ue}-${last_ue}
    FOR    ${index}    IN RANGE    ${first_ue}-${1}    ${last_ue}
        ${ue_id}=    Evaluate    ${index}+${1}
#        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start id=2 ue=${ue_id} dir=ul ${unit}=${amount}
        ...    pass_regexp=UE ${ue_id}: UDP UL TRF
    END
