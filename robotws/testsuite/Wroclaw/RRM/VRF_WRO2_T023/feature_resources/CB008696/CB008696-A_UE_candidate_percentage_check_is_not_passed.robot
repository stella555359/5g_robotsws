*** Settings ***
Documentation    Keywords for the CB008696

Library      ta5g_pm_counters
Library      ta5g_tshark
Variables    ta5g_global_var

*** Variables ***
${RRC Release}=    nr-rrc.rrcRelease_element
${RRC Release Reselection Priority}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.carrierFreq == 300)&&
...    (nr-rrc.carrierFreq == 147500)&&
...    (nr-rrc.carrierFreq == 636576)&&
...    (nr-rrc.cellReselectionPriority == 7)&&
...    (nr-rrc.t320 == 2)

*** Keywords ***
TC__CB008696-A_UE_candidate_percentage_check_is_not_passed
    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Register UE To gNB
    Wait For The UE To Be Inactive    ${12}
    Verify RRC Release Message Occured    ${RRC Release}
    Verify Reselection Priority    ${RRC Release Reselection Priority}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55124C00001    +1    NRRCC_RRC_RELEASE_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

Set Internal Traffic Type To UE
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Register UE To gNB
    Attach Ue    ue_id=1
    Wait For UE Register    3s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1

Wait For UE Register
    [Arguments]    ${Inactive Timer}
    Sleep    ${Inactive Timer}

Wait For The UE To Be Inactive
    [Arguments]    ${Inactive Timer}
    Sleep    ${Inactive Timer}

Verify RRC Release Message Occured
    [Arguments]    ${RRC Release}
    Verify Tcpdump Log    packet_filter=${RRC Release}    continue_on_failure=${True}

Verify Reselection Priority
    [Arguments]    ${RRC Release Reselection Priority}
    Verify Tcpdump Log    packet_filter=${RRC Release Reselection Priority}    continue_on_failure=${True}
