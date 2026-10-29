*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CNI120418_keywords.robot
Library     ../resources/Python/webem_alarms.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_3x20_LO_AP_LO.xml
...                            swconfig_flags_list=@{SWCONFIG_FLAGS}
...            AND             CNI120418 Setup
...            AND             Update SCF And Perform Commissioning    scf_file_name=scf_LO_AP_LO_B1B2.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/setup_180UEs.lua

Suite Teardown    Run Keywords    Print Active Alarms
...               AND             admin.Teardown All Aliases For Admin
...               AND             Stop Default Processes And Gather Logs

*** Variables ***
@{SWCONFIG_FLAGS}    0x580934=1    #rdNbProcedureContextsHigh
...                  0x580933=0    #rdNbProcedureContextsLow

*** Test Cases ***
CNI120418_B1_CPRT_event_throttling_due_to_signaling_overload_in_L2PS
    ${subpool_dict}    Check L2 Pool Assignment    cells_amount=3
    Start Dcap And Syslog Collection
    Execute Egate Command    cmd=set_pdu_param ue=101-280 pdu=1 trf_type=internal
    FOR    ${i}    IN RANGE    111    271
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}
    END
    Attach Ue    ue_id=101
    Attach Ue    ue_id=102
    Attach Ue    ue_id=103
    Attach Ue    ue_id=104
    Attach Ue    ue_id=105
    Attach Ue    ue_id=106
    ${ue_id}    Set Variable    ${101}
    FOR    ${i}    IN RANGE    1    18
        Log To Console           ue_pdu_session_setup ue=${ue_id}-${ue_id+9} pdu=1 nwslice=1 gw=1
        Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id}-${ue_id+9} pdu=1 nwslice=1 gw=1
        ${ue_id}    Evaluate    ${ue_id}+${10}
        Sleep    2s
    END
    Verify Avg Tput For Multiple UEs    last_ue=270    dir=dl    expected_tput=1    first_ue=110
    Run Keyword And Continue On Failure    Execute Egate Command    cmd=ue_register id=271
    #reject expected    M55166C00020	RRC_ESTAB_NEME_FAIL_OVLDU_UP + RRC_NEME_FAIL_SIG_OVLDU_UP
    Run Keyword And Continue On Failure    Execute Egate Command    cmd=ue_register id=272
    #reject expected    M55166C00020	RRC_ESTAB_NEME_FAIL_OVLDU_UP + RRC_NEME_FAIL_SIG_OVLDU_UP
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=273 establishment_cause=emergency
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=274 establishment_cause=emergency
    Execute Egate Command    cmd=ue_register id=273-274 registration_type=EmergencyRegistration
    Execute Egate Command    cmd=ue_pdu_session_setup ue=273-274 pdu=1 nwslice=1 gw=1 request_type=initial-emergency-request
    Execute Egate Command    cmd=trf_data_start ue=273-274 pdu=1 trf_id=1 mbps=1 dir=dl
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=101 gnb=2 cell=1 msg=resume_request_1 cause=mo_Signalling
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=102 gnb=2 cell=1 msg=resume_request_1 cause=mo_Signalling
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=103 gnb=2 cell=1 msg=resume_request_1 cause=emergency
    Execute Egate Command
    ...    cmd=ue_nr_rrc_resume_request_param id=104 gnb=2 cell=1 msg=resume_request_1 cause=highPriorityAccess
    Execute Egate Command
    ...    cmd=ue_nr_rrc_resume_request_param id=105 gnb=2 cell=1 msg=resume_request_1 cause=mps_PriorityAccess
    Execute Egate Command
    ...    cmd=ue_nr_rrc_resume_request_param id=106 gnb=2 cell=1 msg=resume_request_1 cause=mcs_PriorityAccess
    Execute Egate Command    cmd=ue_nr_rrc_resume id=101
    Execute Egate Command    cmd=ue_nr_rrc_resume id=102
    Execute Egate Command    cmd=ue_nr_rrc_resume id=103
    Execute Egate Command    cmd=ue_nr_rrc_resume id=104
    Execute Egate Command    cmd=ue_nr_rrc_resume id=105
    Execute Egate Command    cmd=ue_nr_rrc_resume id=106
    [Teardown]    Run Keywords    Stop Syslog    alias=mandatory_log
    ...           AND             Stop Dcap Logs Collection
