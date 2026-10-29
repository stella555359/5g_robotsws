*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CONFIGURED
...           RAN_5G_TDD    RAN_5G_FDD    RAN_5G    AP_P1    CRT    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamila Bialczyk
...              :contact: kamila.bialczyk@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Library      ta5g_setups_and_teardowns
Library      ta5g_ue_mobility
Library      ta5g_commissioning


Suite Setup     Run Keywords
...             Start Default Logging And Reach OnAir    lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...             AND     Find Scfc And Send Delta Commissioning    scfc_filename=delta_drbInactivity30s.json

Suite Teardown    Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=delta_srbInactivityDefault.json
...             AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${drbInactivityTimer} =   30
${NGAP_UE_CONTEXT_RELEASE_REQUEST_CAUSE} =    (ngap.radioNetwork == 20) && ${NGAP_UE_CONTEXT_RELEASE_REQUEST}


*** Test Cases ***
5GC000752-J_4_DRB_and_SRB_timer_expiration_after_PDU_session
    [Documentation]   Correct handling of DRB and SRB timers expiration after successful PDU session establishment
    ...               This testcase covers following legacy scenarios:
    ...               5GC000728_B_15_Verify_Successful_UE_State_Transition_From_Rrc_Connected_To_Rrc_Idle_When_Srb_Inactivity_Detected
    ...               5GC000728_B_16_Verify_Successful_UE_State_Transition_From_Rrc_Connected_To_Rrc_Idle_When_Srb_Is_Inactive
    ...               Requirement ID:   5G_RAN_USR_6193
    ...               5GC000723_D_4_Check_SrbInactivityTimerSA_Expiration
    ...               Requirement ID:   5G_RAN_USR_4523

    Attach Ue    ue_id=1
    Establish PDU Session
    Sleep    ${drbInactivityTimer}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_INACTIVITY_NOTIFICATION}
    Sleep    30    Wait for srbinactivity timer
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST_CAUSE}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
