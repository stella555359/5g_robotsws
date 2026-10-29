*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CNI120418_keywords.robot
Resource    ../resources/configuration_id.robot
Library     ../resources/Python/webem_alarms.py
Library     ta5g_pm_counters

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_3x20_LO_AP_LO.xml
...                            swconfig_flags_list=@{SWCONFIG_FLAGS}
...            AND             Run    DCAP_Basic_controller start
...            AND             Start Default Logging
...            AND             CNI120418 Setup
...            AND             Update SCF And Perform Commissioning    scf_file_name=full_CNI_120418_B3.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/setup_B3_90Ues.lua

Suite Teardown    Run Keywords    Print Active Alarms
...               AND             admin.Teardown All Aliases For Admin
...               AND             Stop Default Processes And Gather Logs

*** Variables ***
@{RRC_Reject}
...    UE101: RRC Reject was received
...    UE101: Is INACTIVE

@{SWCONFIG_FLAGS}    0x58093B=50    #rdCs1OverloadProtectionEntryDL	default=4 / 0..50 / step=1
...                  0x58093C=50    #rdCs1OverloadProtectionExitDL	default=5 / 0..50 / step=1
...                  0x58093D=50    #rdAvgUesWithDrbOverloadProtectionEntryDL	default=150 / 0..4000 / step=1
...                  0x58093E=40    #rdAvgUesWithDrbOverloadProtectionExitDL	default=100 / 0..4000 / step=1
...                  0x58093F=100    #rdCs1OverloadProtectionFilterCoeffDL	default=0 / 0..1 / step=0.01

*** Test Cases ***
CNI_120418_B3_B5_CPRT_event_throttling_due_to_DL_scheduling_overload_in_L2PS_start_stop
  [Documentation]
    ...    1. This user scenario describes the gNB-DU when 5G DU UPlane (L2-PS) is in Downlink scheduling overload state.
    ...    2. Configuration:
    ...    3 FDD cells are OnAir with CPRI interface on ABIO baseband module, classical SA:
    ...    actOvlProtL2Sched is set to "true"
    ...    0x58093B=50    #rdCs1OverloadProtectionEntryDL
    ...    0x58093C=50    #rdCs1OverloadProtectionExitDL
    ...    0x58093D=50    #rdAvgUesWithDrbOverloadProtectionEntryDL
    ...    0x58093E=40    #rdAvgUesWithDrbOverloadProtectionExitDL
    ...    0x58093F=100    #rdCs1OverloadProtectionFilterCoeffDL
    ...    3. Test Case Steps:
    ...    a. Attach 90 UEs
    ...    b. Establish PDU session for all UEs
    ...    c. Start Data traffic for all UEs  - cell should be on OVL state
    ...    d. Trigger attach new UE with Emergency Registration
    ...    e. Stop Data traffic for 1 UE and wait until all DRBs and SRBs timer expired.
    ...    f. Trigger UE1 RESUME to cell1.
    ...    4. Expect result:
    ...    a. UEs attaches are successful for UEs. MIB/SIBs are successfully decoded turn to RRC_INACTIVE w
    ...    b. PDU sessions are established successfully for UEs.
    ...    c. Data is successfully transmitted in both directions for UEs
    ...    d. UEs attaches (RRC:RRCSetupRequest) with Establishment Cause IE (emergency) are not rejected by gNB-DU and are successfu
    ...    e. UE101 is in RRC_INACTIVE state because DRBs and SRBs timer expired
    ...    f. Trigger UE1 RESUME to cell1 got RRC Reject
    ...    g. exit from OVL state
    ...    h. Attach Successully 10 Ues
    ...    5. CheckPoints:
    ...    a. Check counter PM and RD counters.

    ${subpool_dict}    Check L2 Pool Assignment    cells_amount=3
    Prepare UEs To Emergency Call And RRC Resume
    Start Dcap And Syslog Collection
    Attach 90 Ues
    Establish PDU Session For All UEs
    Start Data Traffic In Both Directions
    Verify Avg Tput For Multiple UEs    last_ue=190    dir=dl    expected_tput=1    first_ue=101
    Stop Data Traffic For 5 UEs And Wait For Inactive State Due to DRB and SRB timer expired
    Attach Emergency Call UE To OVL Cell
    Attach New Ue To OVL Cell With Cause mo-Signalling
    RRC Resume With Reject    ue_id=101    cell_id=1    cause=mt_Access    msg=resume_request_1
    Verify RD PM Counter If Incremented Properly
    Verify PM Counters If Incremented Properly
    Dettach 50 UEs And Verify If Cell Is No Longer In OVL State
    Sleep     100s
    Attach Again 10 UEs To Cell That Has Exited The OVL State
    Verify PM Counters After OVL State Counters Schould Not Incremented
    [Teardown]    Run Keywords    Stop Syslog    alias=mandatory_log
    ...           AND             Stop Dcap Logs Collection
    ...           AND             Send Configuration ID To Scout

*** Keywords ***
Verify PM Counters After OVL State Counters Schould Not Incremented
    Sleep    10
    ${pm_counter_file}=    Get Next Unpacked Raw Pm Counters File
    Verify Any Counters In File
    ...  M55166C00020  0  RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...  M55166C00021  0  RRC_RESUME1_NEME_FAIL_OVLDU_UP
    ...  M55124C00023  0  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55166C00019  0  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  M55124C04501  0  SA_RRC_ESTAB_NEME_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

Verify PM Counters If Incremented Properly
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File
    Verify Any Counters In File
    ...  M55166C00020  1  RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...  M55166C00021  1  RRC_RESUME1_NEME_FAIL_OVLDU_UP
    ...  M55124C00023  0  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55166C00019  0  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  M55124C04501  0  SA_RRC_ESTAB_NEME_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

Verify RD PM Counter If Incremented Properly
    ${rd_counter_file}=    Get Next Unpacked Raw RD Counters File
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=RRC_NEME_FAIL_SCH_OVLDU_UP
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}

Attach Again 10 UEs To Cell That Has Exited The OVL State
    FOR    ${i}    IN RANGE    110    116
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}
    END

Dettach 50 UEs And Verify If Cell Is No Longer In OVL State
    Execute Egate Command    cmd=ue_deregister id=110-180 ue_deregister_type=switch_off

Prepare UEs To Emergency Call And RRC Resume
    Execute Egate Command    cmd=smf_param id=1 reset
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=101 establishment_cause=mo-Signalling
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=193 establishment_cause=mo-Signalling
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=192 establishment_cause=emergency
    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command     cmd=${cmd_ics_param}

Attach 90 Ues
    Execute Egate Command    cmd=set_pdu_param ue=101-191 pdu=1 trf_type=internal
    FOR    ${i}    IN RANGE    101    191
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}
    END

Attach Emergency Call UE To OVL Cell
     Execute egate command   cmd=ue_register id=192 registration_type=EmergencyRegistration
     ...    pass_regexp=UE192: UE performed Registration type EMERGENCY_REGISTRATION
     ...    timeout=10
     Execute egate command   cmd=ue_pdu_session_setup ue=192 pdu=1 nwslice=1 gw=1
     ...    timeout=10

Attach New Ue To OVL Cell With Cause mo-Signalling
     Execute egate command   cmd=ue_register id=193
     ...    pass_regexp=UE193: RRC Reject was received
     ...    timeout=10
     Execute egate command   cmd=ue_pdu_session_setup ue=193 pdu=1 nwslice=1 gw=1
     ...    timeout=10

Establish PDU Session For All UEs
    ${ue_id}    Set Variable    ${101}
    FOR    ${i}    IN RANGE    10
        Run Keyword If    ${ue_id} > 190    Exit For Loop
        Log To Console           ue_pdu_session_setup ue=${ue_id}-${ue_id+9} pdu=1 nwslice=1 gw=1
        Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id}-${ue_id+9} pdu=1 nwslice=1 gw=1
        ${ue_id}    Evaluate    ${ue_id}+${10}
        Sleep    2s
    END

Start Data Traffic In Both Directions
    Run Keyword And Continue On Failure
    ...    Execute Egate Command
    ...    cmd=trf_data_start ue=101-191 pdu=1 trf_id=1 mbps=7 dir=dl
    ...    timeout=30s
    Sleep    60s    reason=Wait for throughput stabilization

Stop Data Traffic For 5 UEs And Wait For Inactive State Due to DRB and SRB timer expired
    Run Keyword And Continue On Failure
    ...    Execute Egate Command
    ...    cmd=trf_data_stop ue=101-106 pdu=1 trf_id=1
    ...    timeout=30s
    Sleep    200s    reason=Wait for DRB and SRB timer expired

RRC Resume With Reject
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${msg}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} msg=${msg}
    Execute Egate Command    cmd=ue_nr_rrc_resume id=101
    ...    pass_regexp=UE101: RRC Reject was received
    ...    timeout=10
