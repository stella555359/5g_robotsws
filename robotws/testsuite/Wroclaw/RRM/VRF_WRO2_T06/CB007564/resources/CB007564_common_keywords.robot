*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Maciej Madej <maciej.madej@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>

Library     ta_emss
Library     ta_messaging
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_egate
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     ta5g_ue_mobility
Library     ta5g_cell_operations
Library     ta5g_tshark
Library     ta5g_commissioning
Library     CB007564_common.py
Resource    ../../../sim_resources/Krk_regression/devKrk_resources/yaml_config_paths.robot
Library     taf.ul.ue.sim.env_setup


*** Keywords ***
Add secondary PDU Session to UE${ue_id:\d+} with one QoS Flow
    Sleep  5s
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse
    ...     alias=UE${ue_id}_PDU_session_setup
    ...     overall_timeout=10

    Execute egate command   cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 gw=6 nwslice=1
    Flow occurred as expected  alias=UE${ue_id}_PDU_session_setup

Add secondary QoS flow to UE${ue_id:\d+} initial PDU Session
    Sleep  2s
    Execute egate command
    ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6
    ...   pass_regexp=UPF-1: Added QosFlow with QFI:

Add secondary QoS flow to UE${ue_id:[1-9]} second PDU Session
    Sleep  2s
    Execute egate command
    ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6
    ...   pass_regexp=UPF-1: Added QosFlow with QFI:

Attach UE${ue_id:\d+} and setup initial PDU Session with one QoS Flow
    Expect RRC messages flow for UE${ue_id} during UE Attach prcedure
    Expect NGAP messages flow for UE${ue_id} during UE Attach prcedure

    Sleep  2s
    Execute egate command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session
    Sleep  2s

Collect PM counters file
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Set suite variable  ${PM_COUNTERS}  ${PM_COUNTERS}

Deregister UE${ue_id:\d+}
    Execute egate command   cmd=deregister_ue id=${ue_id} by=amf
    Execute egate command   cmd=kill_ue id=${ue_id}

Expect NGAP messages flow for UE${ue_id:[1-9]} during UE Attach prcedure
    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as ICS_Req
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=30

Expect RRC messages flow for UE${ue_id:[1-9]} during UE Attach prcedure
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=30

Expect RRC reconfiguration flow for UE${ue_id:[1-9]}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=30

Expect RRC release flow for UE${ue_id:[1-9]}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_RRC_release
    ...     overall_timeout=30

Run delta setup
    Send delta commissioning    input_filepath=${delta_configuration}
    Check Radios Availability
    Reach OnAir    lua_cfg=${LUA_CFG}

Run Setup
    Log To Console    Setup started
    Check radios availability
    Sleep  1
    Reach Onair    lua_cfg=${LUA_CFG}
    Setup devices aliases

Prepare TL with config files
    ${scfc_filepath}       Get Variable Value    ${SCFC}
    ${ap_xml_filepath}     Get Variable Value    ${AP_XML}
    ${lua_filepath}        Get Variable Value    ${LUA_CFG}

    Run keyword if    '${scfc_filepath}'!='None'
    ...                Add gNB configuration    scfc=${scfc_filepath}
    Run keyword if    '${ap_xml_filepath}'!='None'
    ...                Add simulator    sim_type=airphone    config=${ap_xml_filepath}
    Run keyword if    '${lua_filepath}'!='None'
    ...                Add 5GC    config=${lua_filepath}    edaemon_ports=10000
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default     save_egate=${True}


Run Setup with config files
    Log To Console    Setup started
    Prepare TL with config files
    Setup devices aliases

Run yaml setup
    Log To Console    Setup started
    Teardown emss   bts_id=1
    Setup emss      bts_id=1

    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} == "True"
    ...    Reach onAir state
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default
    Setup devices aliases

Reach onAir state
    Configure   ${yaml_paths_to_configure}
    Log To Console    Before Reach OnAir
    Reach Onair    lua_cfg=${LUA_CFG}
    Log To Console    After Reach OnAir

Run Setup alternative
    Log To Console    Setup started
    Reliable emss setup         bts_id=1
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state alternative
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default
    Setup devices aliases

Reach onAir state alternative
    Wait for gnb to reach configured state
    discover bts
    Configure   ${yaml_paths_to_configure}
    Log To Console    Before Reach OnAir
    reach onair with retries    lua_cfg=${LUA_CFG}
    Log To Console    After Reach OnAir

Set Counter Collecting Interval To Five Minutes
    Send Delta Commissioning  input_filepath=${pm_counters_five_minutes_interval}

Set UE${ue_id:[1-9]} to ignore RRC Reconfiguration messages
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop

Set UE${ue_id:[1-9]} to stop ignoring RRC Reconfiguration messages
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} reset

Setup devices aliases
    Create ues alias
    ...   alias=UE
    ...   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Try to setup Qos Flow for 5QI-1 for UE_${ue_id:[1-9]}
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest as PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_modify
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=30

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf

Verify that ${counter_id} ${counter_name} counter is equal ${value} in NRCELL-${cell_id} cell in gNB2
    Verify Last Counters In File
    ...    ${counter_id}
    ...    ${value}
    ...    ${counter_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS}

Verify that UE${ue_id:[1-9]} context was released with cause: "radioNetwork: slice-not-supported"
    Flow occurred as expected  alias=UE${ue_id}_UE_Context_Release

Verify that UE${ue_id:[1-9]} context was released with cause: "radioNetwork: radio-connection-with-ue-lost"
    Flow occurred as expected  alias=UE${ue_id}_UE_Context_Release

Verify that UE${ue_id:[1-9]} was attached to gNB2
    Flow occurred as expected   alias=UE${ue_id}_RRC_attach
    Flow occurred as expected   alias=UE${ue_id}_NGAP_attach

Verify that UE${ue_id:[1-9]} was released
    Flow occurred as expected   alias=UE${ue_id}_RRC_release
