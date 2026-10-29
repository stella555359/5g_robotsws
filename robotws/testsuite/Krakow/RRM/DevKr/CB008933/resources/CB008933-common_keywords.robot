*** Settings ***
Documentation

Resource    ../../../resources/Robot/common_settings.robot

Library     ta5g_cell_operations
Library     ../../resources/python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.ul.ue.sim.env_setup

*** Variables ***
${ADMIN_CONNECTION}=  admin_connection

*** Keywords ***
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


Run Setup
    Prepare TL with config files
    Reliable emss setup         bts_id=1
    Setup connection to admin  ${ADMIN_CONNECTION}
    Run Keyword if  ${rtpm} != ${False}
    ...     Activate RTPM counters
    Setup devices aliases


Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Activate RTPM counters
    RTPM activate
    Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '[55601 NR Cell Availability]'}]

Run Suite Teardown
    Teardown connection to admin

Wait for ${time}s ${rest_of_kw_name}
    sleep  ${time}

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UEs[${ue_ids}] PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue}   IN   @{ue_list}
        Run ${traffic_rate}Mbps ${direction} traffic on UE${ue} PDU${pdu_id} QFI${qfi_id} and wait 0 seconds
    END
    Sleep  ${seconds}

Stop ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UEs[${ue_ids}] PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue}   IN   @{ue_list}
        Stop ${traffic_rate}Mbps ${direction} traffic on UE${ue} PDU${pdu_id} QFI${qfi_id}
    END
