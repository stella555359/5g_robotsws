*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska; Dan Moldovan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py


Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reset Testline
...             AND             Check Radios Availability
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sa.lua
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Add Preferences To Wireshark Config
...             AND             Start Xn And Ng Interfaces
...             AND             Start Server Interface
...             AND             Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

${ueCapabilityEnquiryFilter}=   (nsetapx.traceActivationType == 1 && nsetapx.traceActivationType == 0) && nr-rrc.ueCapabilityEnquiry_element
${ueCapabilityInfoFilter}=    (nsetapx.traceActivationType == 1 && nsetapx.traceActivationType == 0) && nr-rrc.ueCapabilityInformation_element

*** Test Cases ***
CB010938_A_B6_1_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_MBA_Cell_Trace

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             log to console    start trase
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_subscriber_trace_with_cell_trace.json
    ...        AND             Check Radios Availability
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD


    Trigger ICS With Trace Start    ue_id=1
    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_HAS_SPECIAL_ALGO}
    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
    Perform Exit Idle Mode    ue_id=1
    sleep    30

    Set Test Variable     ${tcpdumpfilepath}    ${OUTPUT_DIR}/${TEST_NAME}/eth3_tcp.pcap
    Verify Tcpdump Log    packet_filter=${ueCapabilityEnquiryFilter}    pcap_file_path=${tcpdumpfilepath}
    Verify Tcpdump Log    packet_filter=${ueCapabilityInfoFilter}    pcap_file_path=${tcpdumpfilepath}

    [Teardown]    Run Keywords    Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=1-4
    ...           AND             Stop Tcp Pcap
#    ...           AND             Roll Delta Back
#    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
#    ...                           delta_scf_filename=delta_subscriber_trace_with_cell_trace.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
