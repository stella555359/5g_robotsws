*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_[LO][LO]_AP_[LOO]

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       ../../resources/airphone/wro_2/keywords/logging.robot
Resource       ../resources/Error_finder.robot
Resource       ../resources/keywords.robot
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_ue_mobility
Library        ute_fsmaccess
Library        ta5g_ue_measurements
Library        ta5g_throughput
Library        ../../resources/scout_report.py
Library        ../resources/multignb_variables.py
Library        ../resources/syslog_collector.py
Resource         CB014648_keywords.robot

Suite Setup        Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Start Vm Ethernet Interfaces
...    AND         Log To Console    message=${REMOTE_HOSTS}
...    AND         Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST_PCMD}
...    AND         Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST_PCMD}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_2}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_1}
...    AND         Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}
...    AND         Start Ncat Listener On Port    49140
...    AND         Start Ncat Listener On Port    49141

Suite Teardown    Compress Test Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    remote_host=${REMOTE_HOST_1_IP}

*** Variables ***
${IPHY}=                         ${CURDIR}/config/iphy_MN_AHFII_AHLOA_AHFIB_SN_AHFII_AHLOA_AHFIB.xml
${cfg}=                          ${CURDIR}/config/cfg_40UEs_5CC_6CC.cfg
${SCFC_GNB_1}=                   scfc_CD_gnb1_n25_3A_n66_2A_n71A.xml
${SCFC_GNB_2}=                   scfc_CD_gnb2_n25_2A_n66_2A_n71B.xml
${delta_3CC}=                    Delta_3CC_FDD.json
${delta_5CC}=                    Delta_5CC_FDD.json
${delta_6CC}=                    Delta_6CC_FDD.json
${delta_max_num_of_CA_users}=    delta_maxNumOfCaUsersNRCell_40.json
@{FAULT_IDS_LIST}=               6450    4383    2087    7101
@{REMOTE_HOSTS}=                 None

*** Test Cases ***
USCB014648_TC17_B_B1_Robustness_Automation_MBA_trace_session
    Start Tshark Nsetapx    alias=nsetapx_initial
    Start Collecting Syslog From Gnbs
    Set Internal Traffic Type For Ue    ue=6-15    pdu=1
    Attach Multiple Ues    first_ue_id=6   last_ue_id=15   enb=2    cell=1
    Setup PDU Session for UE#6-UE#15
    Perform PDU Session Modification By Adding 5QI Mobility Robustness    first_UE=6    last_UE=15    5QI=5
    Perform PDU Session Modification By Adding 5QI Mobility Robustness    first_UE=6    last_UE=15    5QI=1
    Perform PDU Session Modification By Adding 5QI Mobility Robustness    first_UE=6    last_UE=15    5QI=2
    UE#6-UE#15 sends A1 measurement With MeasId-2 For SCell Addition To PhyCellId 51
    Stop Tshark   alias=nsetapx_initial
    Validate Lack of 5QI Specific Metrics    pcap_filename=nsetapx_initial

    Start Tshark Nsetapx    alias=nsetapx_5QI1_5QI2_throughput_start
    Start DL and UL Data Traffic for UE#6-UE#15 on 5QI1 and 5QI2
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Stop Tshark     alias=nsetapx_5QI1_5QI2_throughput_start
    Verify StartRecordingSession Count    count=10    pcap_filename=nsetapx_5QI1_5QI2_throughput_start
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_5QI1_5QI2_throughput_start

    Start Tshark Nsetapx    alias=nsetapx_1st_PCell_Switch
    UE#6-UE#15 sends A2 measurement For PCell Switch To Cell-4
    UE#6-UE#15 sends A1 measurement With MeasId-9 For SCell Addition To PhyCellId 54
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Stop Tshark     alias=nsetapx_1st_PCell_Switch
    Validate 5QI Specific Metrics In Moderate Radio Conditions    pcap_filename=nsetapx_1st_PCell_Switch
    Verify StartRecordingSession Count    count=10    pcap_filename=nsetapx_1st_PCell_Switch
    Verify StopRecordingSession Count    count=10    pcap_filename=nsetapx_1st_PCell_Switch

    Start Tshark Nsetapx    alias=nsetapx_2nd_PCell_Switch
    UE#6-UE#15 sends A2 measurement For PCell Switch to Cell-1
    UE#6-UE#15 sends A1 measurement With MeasId-18 For SCell Addition To PhyCellId 51
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Stop Tshark     alias=nsetapx_2nd_PCell_Switch
    Validate 5QI Specific Metrics In Moderate Radio Conditions    pcap_filename=nsetapx_2nd_PCell_Switch
    Verify StartRecordingSession Count    count=10    pcap_filename=nsetapx_2nd_PCell_Switch
    Verify StopRecordingSession Count    count=10    pcap_filename=nsetapx_2nd_PCell_Switch

    Start Tshark Nsetapx    alias=nsetapx_1st_intergNB_HO_gNB1
    Start Tshark Nsetapx    alias=nsetapx_1st_intergNB_HO_gNB2   port=49141
    UE#6-UE#15 sends A2 measurement with measId-17 below threshold for inter-frequency HO
    Wait For Data    10
    UE#6-UE#15 sends A3 measurement with measId-26 for inter-frequency inter-gNB HO to psycell_id-60
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Stop Tshark     alias=nsetapx_1st_intergNB_HO_gNB1
    Stop Tshark     alias=nsetapx_1st_intergNB_HO_gNB2
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_1st_intergNB_HO_gNB1
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_1st_intergNB_HO_gNB2
    Verify StartRecordingSession Count   count=10    pcap_filename=nsetapx_1st_intergNB_HO_gNB2
    Verify StopRecordingSession Count    count=10    pcap_filename=nsetapx_1st_intergNB_HO_gNB1

    Start Tshark Nsetapx    alias=nsetapx_2nd_intergNB_HO_gNB1
    Start Tshark Nsetapx    alias=nsetapx_2nd_intergNB_HO_gNB2    port=49141
    UE#6-UE#15 sends A2 measurement with measId-28 below threshold for inter-frequency HO
    Wait For Data    10
    UE#6-UE#15 sends A3 measurement with measId-30 for inter-frequency inter-gNB HO to psycell_id-51
    Wait For Data    10
    UE#6-UE#15 sends A1 measurement With MeasId-32 For SCell Addition To PhyCellId 51
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Stop Tshark     alias=nsetapx_2nd_intergNB_HO_gNB1
    Stop Tshark     alias=nsetapx_2nd_intergNB_HO_gNB2
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_2nd_intergNB_HO_gNB1
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_2nd_intergNB_HO_gNB2
    Verify StartRecordingSession Count   count=10    pcap_filename=nsetapx_2nd_intergNB_HO_gNB1
    Verify StopRecordingSession Count    count=10    pcap_filename=nsetapx_2nd_intergNB_HO_gNB2

    Start Tshark Nsetapx    alias=nsetapx_RRCReestablishment
    Perform UE RRC Reestablishment for UE#6-UE#15 to Cell#3 on gNB#2
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Perform UE RRC Reestablishment for UE#6-UE#15 to Cell#1 on gNB#2
    Wait For Data    10
    Verify DL and UL throughput For UE#6-UE#15
    Stop Tshark     alias=nsetapx_RRCReestablishment
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_RRCReestablishment
    Validate 5QI Specific Metrics In Moderate Radio Conditions   pcap_filename=nsetapx_RRCReestablishment
    Verify StartRecordingSession Count   count=20    pcap_filename=nsetapx_RRCReestablishment
    Verify StopRecordingSession Count    count=20    pcap_filename=nsetapx_RRCReestablishment

    [Teardown]     Run Keywords    Deregister UE    ue_id=1-40
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Stop Collecting Syslog And Download Files
    ...            AND    Find Errors    remote_host=True
    ...            AND    Add Scout Scf Id To Test Data
    ...            AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND    Collect Selected Debug Files
    ...                   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                   omit_collectors=sos_report
    ...            AND    Get BTS Snapshot
    ...                   output_filepath=${OUTPUT_DIR}/${TEST_NAME}/remote_host_bts_snapshot.zip
    ...                   remote_host=${REMOTE_HOST_1_IP}

*** Keywords ***
UE#${fist_UE}-UE#${last_UE} sends A2 measurement For PCell Switch To Cell-4
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=8 event=A2 srsrp_nr=11 srsrq_nr=11 scell=3 scell_rsrp=12 scell_rsrq=12
    ...     pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.4 performed
    Log To Console    PCell Switch from Cell 1 to Cell 4 executed for UE ${UE}
    Wait For Data
    END

UE#${fist_UE}-UE#${last_UE} sends A2 measurement For PCell Switch To Cell-1
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=16 event=A2 srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=12 scell_rsrq=12
    ...     pass_regexp=Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB-2.1 performed
    Log To Console    PCell Switch from Cell 4 to Cell 1 executed for UE ${UE}
    Wait For Data
    END

UE#${fist_UE}-UE#${last_UE} sends A2 measurement with measId-${meas_id} below threshold for inter-frequency HO
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=${meas_id} event=A2 srsrp_nr=1 srsrq_nr=1
    Log To Console     UE-${UE} sent A2 measurement for HO purposes
    Wait For Data
    END

UE#${first_UE}-UE#${last_UE} sends A3 measurement with measId-${meas_id} for inter-frequency inter-gNB HO to psycell_id-60
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=${meas_id} event=A3 srsrp_nr=1 phycell_id=60 nrsrp_nr=120
    ...     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.10 performed
    Log To Console    Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.10 performed for UE#${UE}
    END

UE#${first_UE}-UE#${last_UE} sends A3 measurement with measId-${meas_id} for inter-frequency inter-gNB HO to psycell_id-51
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=${meas_id} event=A3 srsrp_nr=1 phycell_id=51 nrsrp_nr=120
    ...     pass_regexp=Inter-eNB handover from EXT_ENB-3.10 to EXT_ENB-2.1 performed
    Log To Console    Inter-eNB handover from EXT_ENB-3.10 to EXT_ENB-2.1 performed for UE#${UE}
    END

UE#${first_UE}-UE#${last_UE} perform inter-cell HO
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
        Execute Egate Command
    ...     cmd=ue_reauth id=${UE} nr_sec_cap=zuc|zuc
    ...     pass_regexp=Reauthentication procedure is complete
    Log To Console   Intra-Cell Handover executed for UE#${UE}
    END

UE#${first_UE}-UE#${last_UE} sends A1 measurement With MeasId-${meas_id} For SCell Addition To PhyCellId ${phycell_id}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Send Ue Measurement Nr    ue_id=${UE}    meas_id=${meas_id}    phycell_id=${phycell_id}   srsrp_nr=80    event=A1
    ...    pass_regexp=sCellToAddModList
    Wait For Data
    END
