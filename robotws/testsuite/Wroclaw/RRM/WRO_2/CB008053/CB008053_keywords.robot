*** Settings ***

Documentation    Keywords for CB008053.

*** Keywords ***

Verify CA Configuration
    [Arguments]    ${CA_Veryfication_Message}
    Verify Tcpdump Log    ${CA_Veryfication_Message}

Verify PCell Switch Veryfication
    [Arguments]    ${PCell_Switch_Veryfication_Message}
    Verify Tcpdump Log    ${PCell_Switch_Veryfication_Message}

Register UE To gNB
    [Arguments]    ${UE_Id}
    Attach Ue    ue_id=${UE_Id}
    Wait For UE Register    3s
    Execute Egate Command    cmd=set_pdu_param ue=${UE_Id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${UE_Id} pdu=1 nwslice=1 gw=1

Wait For UE Register
    [Arguments]    ${Inactive Timer}
    sleep    ${Inactive Timer}

Trigger CA With A1 Measurement
    [Arguments]    ${UE_Id}    ${Meas_Id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${UE_Id} meas_id=${Meas_Id} event=A1 srsrp_nr=90
    Wait For Trigger CA    10s

Perform Pcell Switch
    [Arguments]    ${UE_Id}    ${Meas_Id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${UE_Id} meas_id=${Meas_Id} event=A1 scell=1 scell_rsrp=90
    ...   scell=2 scell_rsrp=34 scell=3 scell_rsrp=34
    Wait For Trigger CA    10s

Wait For Trigger CA
    [Arguments]    ${Inactive Timer}
    sleep    ${Inactive Timer}
