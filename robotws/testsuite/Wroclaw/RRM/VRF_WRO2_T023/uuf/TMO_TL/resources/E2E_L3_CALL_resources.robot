*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library     OperatingSystem
Library     Collections
Library     DateTime
Library     String
Library     SSHLibrary
Library     ute_admin_infomodel
Library     ute_ue
Library     taf.sbts.oam.coam.admin   WITH NAME   admin
Library     ta_attenuator
Library     ute_tshark


*** Variables ***
${WS_INTERFACE}    ens3f1
${CAPTURE_FILTER}    host 10.44.207.230


*** Keywords ***
E2E_L3_CALL_WRO23
    [Arguments]    ${dum1}=None    ${dum2}=None
    Log  dum1=${dum1}, dum2=${dum2}
    Log To Console    ${\n}
    Set All qrxlevmin As Precondition    -22
    FOR    ${cell_att_pipes}    IN    @{CALL_MATRIX.keys()}
        Cell Loop Segment    ${cell_att_pipes}
    END

Cell Loop Segment
    [Arguments]    ${cell_att_pipes}
    FOR    ${cell}    IN    @{CALL_MATRIX['${cell_att_pipes}']}
        Log To Console    Checking ${cell}
        Unlock qrxlevmin To Cell ${cell} On ${cell_att_pipes} And Perform Attach
    END

Unlock qrxlevmin To Cell ${cell} On ${cell_att_pipes} And Perform Attach
    [Teardown]    Iteration Teardown    ${cell}
    Iteration Setup    ${cell}
    Log To Console    Setting attenuation on ${cell} to 0%
    Set Attenuation    ${cell_att_pipes}    0%
    Set Attenuation    ${cell_att_pipes}    0%
    Log To Console    UE Attach
    ${output_attach}    Run Keyword And Return Status    Attach UE    UE_FOR_TA    timeout=30
    Sleep    5
    Run Keyword If    ${output_attach}    Verifcation Part    UE_FOR_TA    ${cell}
    Wait Until Keyword Succeeds    3x    5s    Start Data Transfer  NR_DL  UE_FOR_TA  dl  throughput=10000 Mbits/sec
    ...    packet_size=1400  duration=180s  buffer=32M
    Log To Console    Data Transfer Started
    Sleep    185
    Stop Data Transfer    NR_DL
    Log To Console    Data Transfer Stopped
    ${avg_tpt}    ute_ue.Get Average Throughput    NR_DL    tput_collection_src=control_app
    Reset Data Transfer Statistics    NR_DL
    Log To Console    Avg tpt on cell ${cell} is ${avg_tpt}Kbits/sec
    Log To Console    Setting attenuation on ${cell} to 100%
    Set Attenuation    ${cell_att_pipes}    100%
    Set Attenuation    ${cell_att_pipes}    100%

Iteration Setup
    [Arguments]    ${cell}
    Set qrxlevmin Level    ${cell}    -65
    admin.Setup Admin    bts_host=10.44.207.168    alias=admin_connection

Iteration Teardown
    [Arguments]    ${cell}
    run keyword and ignore error    Detach Ue    UE_FOR_TA
    Set qrxlevmin Level    ${cell}    -22
    admin.Teardown Admin    connection=admin_connection

Get Current nrCellIdentity
    [Arguments]    ${cell}
    [Teardown]    admin.Teardown Admin    connection=single_qrx
    admin.Setup Admin    alias=single_qrx
    ${nrCellIdentity}    admin.Get Parameters
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-20003/${cell.replace('-','_R-')}
    ...    nrCellIdentity    connection=single_qrx
    [Return]    ${nrCellIdentity['nrCellIdentity']}

Verifcation Part
    [Arguments]    ${ue}    ${cell}
    ${IP}    Get Ue Info    ${ue}    IP
    ${CELL_ID}    Get Ue Info    ${ue}    CELL_ID
    ${nrCellIdentity}    Get Current nrCellIdentity    ${cell}
    Should Be Equal As Strings    ${nrCellIdentity}    ${CELL_ID}

Setup E2E
    Set Library Search Order    E2E_L3_CALL_resources
    Log To Console    Reserving Attenuator for test..
    Load Attenuation Config    ${TA_ATTENUATOR_CONFIG}
    Require Attenuator Setup Of    ${CELLS_LST}
    Log To Console    Setting attenuation on all cells to 100%
    Set Attenuation For All Cells    100%
    Log To Console    Reserving UE for test..
    Require Ue    UE_FOR_TA    capabilities=NR_L3_CALL

Teardown E2E
    Run Keyword And Ignore Error    Detach UE    UE_FOR_TA
    Set All qrxlevmin As Precondition    -65
    admin.Teardown All Aliases For Admin
    Set Attenuation For All Cells    100%
    FOR    ${i}    IN    @{CELLS_LST}
        Release Attenuator Cell    ${i}
    END

Set All qrxlevmin As Precondition
    [Arguments]    ${value}
    [Teardown]    admin.Teardown Admin    connection=all_qrx_set
    Log To Console    Setting qrxlevmin for all cells at level ${value}db
    admin.Create Delta    delta_id=d
    FOR    ${cell}    IN    @{CELL_LIST}
        admin.Append Parameter Update To Delta    MRBTS-2004/NRBTS-20003/${cell}    qRxLevMin    ${value}    delta_id=d
    END
    ${delta}    admin.Get Delta    delta_id=d
    admin.Setup Admin    alias=all_qrx_set
    admin.Perform Delta Recommissioning    ${delta}    skip_parameter_relation_errors=True
    ...    alias=all_qrx_set

Set qrxlevmin Level
    [Arguments]    ${cell_to_lock}    ${value}
    [Teardown]    admin.Teardown Admin    connection=qrx_change
    Log To Console    Setting qrxlevmin on ${cell_to_lock} at ${value}dB
    admin.Setup Admin    alias=qrx_change
    admin.Perform Parameter Recommissioning    MRBTS-2004/NRBTS-20003/${cell_to_lock}    qRxLevMin   update
    ...    ${value}    connection=qrx_change
