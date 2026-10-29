*** Settings ***
Force Tags    CONFIGURED   CRT   SBTS00    CLOUD_5G_O_E_AP_LOOO    VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1

Documentation   :copyright: Nokia
...             :authors: Joanna Kutrowska-Girzycka, Edyta Rudnik
...             :contact: joanna.kutrowska-girzycka@nokia.com, edyta.rundik@nokia.com

Resource         ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource         ../../resources/airphone/wro_2/keywords/logging.robot
Resource         ../resources/Error_finder.robot
Resource         CB014648_keywords.robot

Library          ute_wtssim  # must be imported before ta5g_iphy to avoid error
Library          ute_fsmaccess
Library          OperatingSystem
Library          BuiltIn

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST_PCMD}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Trigger site reset
...    AND         Wait for testline ICMP Echo replies and SSH services
...    AND         Sleep  60
...    AND         Check Radios Availability
...    AND         Update BSR Package
...    AND         Start Vm Ethernet Interfaces
...    AND         Copy Wireshark preferences
#...    AND         Find Scfc And Send Delta Commissioning    scfc_filename=delta_delete_TCE_MTRACE.json
...    AND         Reach Onair    lua_cfg=${cfg_A_B1}


Suite Teardown     Run Keywords
...                Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}
...    AND         Compress Test Logs

*** Variables ***
${cfg_A_B1}=              ${CURDIR}/config/basic_setup.cfg

*** Test Cases ***
USCB014648_TC3_A_B101_A_B102-ALT1_Monitoring_of_PCMD_content_related_to_5QI-1_metrics_in_MBA_Trace_Session_while_difficult_radio_conditions-UL_and_DL
    [Documentation]    The aim of this User Scenario is to verify PCMD content related to Downlink and Uplink 5QI
    ...                specific metrics in MBA Trace Session when both 5QI-1 and 5QI-2 are in use in difficult radio conditions (NACK/CRC Fail).

    [Setup]    Run keywords    Find Scfc And Send Delta Commissioning    scfc_filename=delta_MBA.json
    ...    AND                 Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                 Start Ncat Listener On Port    49140
    ...    AND                 Start Tshark Nsetapx    alias=nsetapx_all

    Set Internal Traffic Type For Ue    ue=1-20    pdu=1
    Attach Multiple Ues And Establish PDU Session with 5QI7 for UE#1-UE#20
    Modify PDU Session For UE#1-UE#20 by Adding 5QI5 5QI1 and 5QI2
    Start DL and UL Data Traffic for UE#1-UE#20 on 5QI1 and 5QI2
    Verify DL and UL throughput For UE#1-UE#20
    Simulate DTX For UE#1-UE#20
    Wait For Data    10
    Start Tshark Nsetapx    alias=nsetapx_2
    Wait For Data    20
    Stop Tshark     alias=nsetapx_2
    Validate 5QI Specific Metrics In Bad Radio Conditions   pcap_filename=nsetapx_2
    Stop simulate DTX for UE#1-UE#20
    Deregister UE    ue_id=1-20
    Sleep    60s
    Stop Tshark     alias=nsetapx_all
    Verify StartRecordingSession Count    count=20    pcap_filename=nsetapx_all
    Verify StopRecordingSession Count    count=20    pcap_filename=nsetapx_all


    [Teardown]   Run keywords
    ...                           Run Keyword And Ignore Error    Deregister UE    ue_id=1-20
    ...    AND                    Run Keyword And Ignore Error   Stop Tshark     alias=nsetapx_all
    ...    AND                    Prepare Test Teardown For CB014648 Feature
    ...    AND                    Find Scfc And Send Delta Commissioning    scfc_filename=delta_back_MBA.json

USCB014648_TC9_A_B2_Monitoring_of_PCMD_content_related_to_5QI_specific_metrics_in_SBA_Trace_Session_when_both_5QI-1_and_5QI-2_are_in_use
    [Documentation]    The aim of this User Scenario is to verify PCMD content related to Downlink and Uplink 5QI specific metrics
     ...               in SBA Trace Session when both 5QI-1 and 5QI-2 are in use

    [Setup]    Run keywords    Find Scfc And Send Delta Commissioning    scfc_filename=delta_SBA.json
    ...    AND                 Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                 Start Ncat Listener On Port    49140
    ...    AND                 Start Tshark Nsetapx    alias=nsetapx_all

    Set Internal Traffic Type For Ue    ue=1-20    pdu=1
    Attach Multiple Ues And Establish PDU Session with 5QI7 for UE#1-UE#20
    Start subscriber trace session for UE#1-UE#20
    Modify PDU Session For UE#1-UE#20 by Adding 5QI5 5QI1 and 5QI2
    Start DL and UL Data Traffic for UE#1-UE#20 on 5QI1 and 5QI2
    Verify DL and UL throughput For UE#1-UE#20
    Wait For Data    5
    Start Tshark Nsetapx    alias=nsetapx_2
    Wait For Data    20
    Stop Tshark     alias=nsetapx_2
    Validate 5QI Specific Metrics In Good Radio Conditions    pcap_filename=nsetapx_2
    Deregister UE    ue_id=1-20
    Sleep    60s
    Stop Tshark     alias=nsetapx_all
    Verify StartRecordingSession Count    count=20    pcap_filename=nsetapx_all
    Verify StopRecordingSession Count    count=20    pcap_filename=nsetapx_all

    [Teardown]    Run Keywords
    ...                Run Keyword And Ignore Error    Deregister UE    ue_id=1-20
    ...    AND         Run Keyword And Ignore Error   Stop Tshark     alias=nsetapx_all
    ...    AND         Prepare Test Teardown For CB014648 Feature
    ...    AND         Find Scfc And Send Delta Commissioning    scfc_filename=delta_back_SBA.json
