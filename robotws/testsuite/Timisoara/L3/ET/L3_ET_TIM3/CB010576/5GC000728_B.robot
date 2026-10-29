*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO  VARIANT_SA_FS_ECPRI_MMWV_TDD    CONFIGURED
...           CRT  RAN_5G_FDD    RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Alok Shastri
...              :contact: Alok.Shastri@nokia.com

Resource    ../resources/5G_SW_WRO_Keywords.robot
Library    ta5g_tshark
Library    ta5g_iperf_traffic

Variables    ta5g_global_var

Suite Setup       Run Keywords    Start Default Logging And Reach Onair
...                               lua_cfg_filepath=${CURDIR}/../resources/egate_2c_tdd_sansa_FR2_n257.lua
...                               output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...               AND             Set Counter Collecting Interval To Five Minutes
...               AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Find Scfc and Send Delta Commissioning    scfc_filename=default_drb_srb_timer.json
...               AND             Stop Default Processes And Gather Logs and Compress Logs

*** Test Cases ***
5GC000728_B_18_Verify_Ue_State_Remains_In_Rrc_Connected_When_At_Least_One_Drb_Is_Active_And_SRB_Is_Inactive_Already
    [Documentation]      Verifies UE state remains in RRC CONNECTED when one of the DRB is still active
    ...                  when other DRBs are INACTIVE
    ...     This testcase covers following legacy scenarios:
    ...     5GC000728_B_17
    ...     5GC000728_B_19
    ...     5GC000728_B_21
    ...     Requirement ID:  5G_RAN_USR_6193
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_setup_drb_srb_timer_TC18.json
    [Teardown]    Run Keywords    Detach Ue Without Confirmation    ue_id=1    type=switch_off
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ${DRB_INACTIVITY_TIMER}=    Set Variable    50
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Establish Pdu Session    ue_id=1    pdu_id=2    gw_id=2
    Start Downlink Traffic    pdu_gw_id=1    throughput=1M    duration=80
    Sleep    ${DRB_INACTIVITY_TIMER}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=0
