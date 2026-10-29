*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Miłosz Komarczewski
...             :contact: milosz.komarczewski@nokia.com

*** Keywords ***
Verify 5QI 1&5 Establishment
    Verify Tcpdump Log      packet_filter=${F1AP_5QI_1&5_ESTABLISHMENT}

Verify A1 Measurement For SCell Change Setup
    [Arguments]    ${message_to_check}    ${packet_filter}
    Verify Tshark For Given Number Of Messages
   ...    alias=${message_to_check}
   ...    packet_filter=${packet_filter}
   ...    number_of_messages=1

Verify A2 Measurement For SCell Release Setup
    [Arguments]    ${message_to_check}    ${packet_filter}
    Verify Tshark For Given Number Of Messages
   ...    alias=${message_to_check}
   ...    packet_filter=${packet_filter}
   ...    number_of_messages=1

Send A2 Measurement With Capture
    [Arguments]     ${ue_id}    ${a2_meas_id}    ${scell_id}
    Run Keyword And Return    With Message Capture    eth4   Send A2 Measurement    ue_id=${ue_id}
    ...  a2_meas_id=${a2_meas_id}    scell=${scell_id}

Verify Successful 4CC SCell Release
   [Arguments]    ${message_to_check}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${SCELL_TO_BE_RELEASED}

Attach UE With PDU Session Setup And Verify DRX Is Configured
    [Arguments]   ${ue_id}    ${gw_id}=1    ${pdu_id}=1
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_CONFIG} && ${UE}==${ue_id}
    ...    action=Attach UE With PDU Session Setup   ue_id=${ue_id}    gw_id=${gw_id}    pdu_id=${pdu_id}
    ...    packet_number=1

Send A1 Measurement With Capture
    [Arguments]   ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Run Keyword And Return    With Message Capture    eth4   Send A1 Measurement    ue_id=${ue_id}
    ...  a1_meas_id=${a1_meas_id}    a1_rsrp=${a1_rsrp}

Verify DRX is not Reconfigured
    [Arguments]    ${message_to_check}
    Verify Tshark For Given Number Of Messages
   ...    alias=${message_to_check}
   ...    packet_filter=${DRX_CONFIG}
   ...    number_of_messages=0

Verify DRX Is Configured
    Verify Tshark For Single Message
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_CONFIG}

Verify DRX Is Reconfigured
    Verify Tshark For Single Message
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_PROFILE2_CONFIG}

Send A1 Measurement
    [Arguments]    ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} srsrp_nr\=${a1_rsrp} event\=A1

Send A2 Measurement
    [Arguments]    ${ue_id}    ${a2_meas_id}   ${scell}    ${a2_rsrp}=5
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${a2_meas_id} scell=${scell} srsrp_nr=${a2_rsrp} event=A2

Attach UE With PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Start Data DL and UL Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${mbps_dl}=100   ${mbps_ul}=100
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} mbps=${mbps_dl} dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} mbps=${mbps_ul} dir=ul
    Wait For Traffic To Stabilize

Start Vonr DL and UL Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl  rtp_codec=amr_12_2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul  rtp_codec=amr_12_2
    Wait For Traffic To Stabilize

Verify Data DL and UL Traffic on Cells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul format=long
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl format=long

Verify Successful 4CC SCell Addition
    [Arguments]    ${message_to_check}    ${packet_filter}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${packet_filter}

Lock Cell And Check
    [Arguments]    ${cell_id}=3
    Lock Single Cell             cell_id=${cell_id}
    Wait For Cell To Be Locked   cell_id=${cell_id}
    Check Cell Is Locked         cell_id=${cell_id}


Verify 5QI-5 Establishment
    Verify Tcpdump Log      packet_filter=${F1AP_5QI_5_ESTABLISHMENT}

Verify 5QI-1 Establishment
    Verify Tcpdump Log      packet_filter=${F1AP_5QI_1_ESTABLISHMENT}

Perform GBR Qosflow Establishment
    [Arguments]     ${ue_id}=1     ${qosflows}=2
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qosflows} by=amf
