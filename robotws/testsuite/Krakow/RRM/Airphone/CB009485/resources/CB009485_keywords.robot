*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>

Resource    ../../../resources/Robot/common_settings.robot
Library     taf.ul.ue.sim.env_setup
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     ./ta_pcmd_verify.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${log_directory}=      /home/ute/logs/

*** Keywords ***
Test setup
    Start tshark collecting
    Start TCE interface monitoring via Wireshark
    Sleep    5s

Test cleanup
    Teardown PCMD
    Execute egate command   cmd=deregister_ue id=1 by=amf
    Execute egate command   cmd=deregister_ue id=2 by=amf
    Execute egate command   cmd=kill_ue id=1-2
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

Run Setup
    [Arguments]
    Log To Console    Setup started
    Setup emss    node_id=1
    ${run_update}    get variable value      ${configure}    "True"    # do not ever change that line!

    Run Keyword if   ${run_update} != ${False}
    ...    Prepare TL with config files

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Enable internal mirroring for alias  gNB2

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCFC}
     Add 5gc  config=${LUA_CFG}  edaemon_ports=10000
     Configure environment       rmod_detection_timeout=420s    validate_gnb=False
     Configure  ${setup_yaml}
     Log To Console    After Configure ENV

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Configure that UE1 will send capabilites in parts and UE2 in single message
    Execute egate command  cmd=ue_param id=1 ueCapInfomsg_Segment_Threshold=20
    Execute egate command  cmd=ue_param id=2 ueCapInfomsg_Segment_Threshold=70

Expect UE1 to sent UE Capabilities Information in segments
    Expect Message Flow
    ...     UE_1:NR-RRC_ULDedicatedMessageSegment-r16
    ...     UE_1:NR-RRC_ULDedicatedMessageSegment-r16
    ...     UE_1:NR-RRC_ULDedicatedMessageSegment-r16
    ...     UE_1:NR-RRC_ULDedicatedMessageSegment-r16
    ...     alias=UE1_segmented_capabilities
    ...     overall_timeout=30

    Expect message will not occur
    ...     UE_1:NR-RRC_UECapabilityInformation
    ...     alias=UE1_ue_capability_message
    ...     overall_timeout=10

Expect UE2 to sent UE Capabilities Information in single message
    Expect Message Flow
    ...     UE_2:NR-RRC_UECapabilityInformation
    ...     alias=UE2_ue_capability_message
    ...     overall_timeout=30

    Expect message will not occur
    ...     UE_2:NR-RRC_ULDedicatedMessageSegment-r16
    ...     alias=UE2_segmented_capabilities
    ...     overall_timeout=10

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=True    load_plugin=False
    Sleep  2

Start TCE interface monitoring via Wireshark
    Setup PCMD

Start tshark collecting
    Start tshark
    ...   log_filename=eth3.pcap
    ...   eth_interface=eth3
    ...   alias=nsetapx_alias

Stop capturing UE${ue_id:\d+} trace in Wireshark
    Verify tshark    pdml_capture_ue${ue_id}.pdml

Stop tshark collecting
    Stop tshark   alias=nsetapx_alias

Teardown PCMD
    Stop collecting PCMD reports
    Sleep  2
    Deconfigure PCMD
    Sleep  2

UE${ue_id:\d+} attach to gNB2
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=30

    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

    Flow occurred as expected   alias=UE${ue_id}_RRC_attach
    Flow occurred as expected   alias=UE${ue_id}_NGAP_attach

Verify tshark
    [Arguments]   ${file_name}=pdml_capture.pdml
    Sleep  5s
    Stop capturing  alias=nsetapx_alias
    convert tshark to pdml
    ...   alias=nsetapx_alias
    ...   packet_filter=nsetapx
    ...   output_filepath=${log_directory}${file_name}
    Stop tshark collecting

Verify that reassembled UE Capability Information is present in active TRS of UE1 call
    verify_reassembled_capabilities_message_in_cell_trace    ueCapabilityInformation    ${log_directory}pdml_capture_ue1.pdml    0
    verify_ue_capabilities_in_cell_trace    ueCapabilityInformation    ${log_directory}pdml_capture_ue1.pdml    1

Verify that UE1 Capabilities were sent with several ULDedicatedMessageSegment messages
    Flow occurred as expected   alias=UE1_segmented_capabilities
    Flow Not Occurred For Message    alias=UE1_ue_capability_message

Verify that UE2 Capabilities were sent in UECapabilityInformation message
    Flow occurred as expected   alias=UE2_ue_capability_message
    Flow Not Occurred For Message    alias=UE2_segmented_capabilities

Verify that UL Dedicated Message Segments were contained in active TRS of UE1 call
    verify_capability_segment_message_in_cell_trace   ulDedicatedMessageSegment-r16    ${log_directory}pdml_capture_ue1.pdml    4

Verify that UL UECapabilityInformation message was contained in active TRS of UE2 call
    verify_capability_segment_message_in_cell_trace    ulDedicatedMessageSegment-r16    ${log_directory}pdml_capture_ue2.pdml    0
    verify_reassembled_capabilities_message_in_cell_trace    ueCapabilityInformation    ${log_directory}pdml_capture_ue2.pdml    0
    verify_ue_capabilities_in_cell_trace   ueCapabilityInformation    ${log_directory}pdml_capture_ue2.pdml    1
