*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

Resource       ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource       ../resources/collectors.robot
Resource       feature_keywords.robot
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_file_system
Library        ta5g_cell_operations
Library        ../../resources/scout_report.py
Library        feature_resources.py

Suite Setup        Run Keywords
    ...            Enable C-Plane Debug Logs       with_reboot=${false}
    ...    AND     Set VM Ethernet Interfaces for Simulated Core Network

Test Teardown      Run Keywords
    ...            Teardown Egate And Collect Logs
    ...     AND    Find Scfc And Fix And Send Full Commissioning
    ...            scfc_filename=${DEFAULT_SCFC}
    ...     AND    Check For Unexpected Active Alarms
    ...     AND    Find Errors    remote_host=True
    ...     AND    Add Scout Scf Id To Test Data
    ...     AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...     AND    Collect Selected Debug Files
    ...            output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            omit_collectors=sos_report
    ...     AND    Get BTS Snapshot
    ...            output_filepath=${OUTPUT_DIR}/${TEST_NAME}/remote_host_bts_snapshot.zip

Suite Teardown    Compress Test Logs

*** Variables ***
${CFG}                                ${CURDIR}/config/basic_setup.cfg
${SCFC}                               scfc_D_B7.xml
${DEFAULT_SCFC}                       scfc.xml
${DELTA_D_B7}                         Delta_D_B7.json
${DELTA_AL8}                          delta_FB2.json
${DELTA_AL4}                          Delta_AL4.json
@{CELLS_LIST}                         1
@{ENERGYSAVING}                       energySaving       energySaving
@{NOTENERGYSAVING}                    notEnergySaving    notEnergySaving
${PAGING_UPDATE}                      ngap.PagingDRX == 0
${DRXDEFAULTCYCLE}                    nr-rrc.defaultPagingCycle == 0 && f1ap.nRPCI == 51
@{BIP_COLUMNS}                        DlData_DciInfoL1sw.aggregationLevel

*** Test Cases ***
CB014330_TC29_D_B7_Paging_parameter_drxDefaultPaging_online_modification_for_the_cell_in_energySaving_state_Classical_FR1_TDD_FDD_SA_Cells
    [Setup]        Run Keywords    Find Scfc And Fix And Send Full Commissioning
    ...                   scfc_filename=${SCFC}
    ...            AND    Reach Onair Without Confirmation    lua_cfg=${CFG}
    ...            AND    Enable Tshark Verification

    Check If Cell Is In EnergySaving Mode
    Find Scfc and Send Delta Commissioning   scfc_filename=${DELTA_D_B7}
    Check If Cell Is Not In EnergySaving Mode For A While After Online Modification
    Verify Successfull Update Of Serving Cell

CB014330_TC32_F_B2_Main_PDCCH_parameter_dciPagingAggregationLevel_online_modification
    [Setup]        Run Keywords     Reset Wts
    ...            AND    Wait 300s For Reset
    ...            AND    Find Scfc and Send Delta Commissioning
    ...                   scfc_filename=${DELTA_AL8}
    ...            AND    Reach Onair Without Confirmation    lua_cfg=${CFG}
    ...            AND    Enable Tshark Verification

    Setup Traffic To Internal For UE#1-UE#4
    Attach Multiple Ues    first_ue_id=1    last_ue_id=4   enb=2
    Setup PDU Session For UE#1-UE#4
    Wait 110s For Reaching Idle Mode
    Start Paging And Check That Aggregation Level For Paging Is AL8
    Start Traffic For UE#1-UE#4
    Verify That 140Mbps average Throughput For dl Is Reached On 0 Cell/s For UE#1-UE#4
    Find Scfc and Send Delta Commissioning   scfc_filename=${DELTA_AL4}
    Verify That 140Mbps average Throughput For dl Is Reached On 0 Cell/s For UE#1-UE#4
    Stop Traffic For UE#1-UE#4
    Check For Unexpected Active Alarms
    Wait 110s For Reaching Idle Mode
    Start Paging And Check That Aggregation Level For Paging Is AL4

*** Keywords ***
Check If Cell Is In EnergySaving Mode
    Wait 600s For EnergySaving
    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{ENERGYSAVING}

Check If Cell Is Not In EnergySaving Mode For A While After Online Modification
    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{NOTENERGYSAVING}
    Wait 600s For EnergySaving
    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{ENERGYSAVING}

Verify Successfull Update Of Serving Cell
    [Arguments]    ${number_of_messages}=1
    tshark_verifying.Verify Tcpdump Log
    ...    packet_filter=${PAGING_UPDATE}
    ...    continue_on_failure=False
    ...    number_of_messages=${number_of_messages}
    tshark_verifying.Verify Tcpdump Log
    ...    packet_filter=${DRXDEFAULTCYCLE}
    ...    continue_on_failure=False
    ...    number_of_messages=${number_of_messages}

Start Paging And Check That Aggregation Level For Paging Is AL${AL}
    Start Collecting BIP Logs
    Execute Egate Cmd    cmd=amf_fake_paging_start amf=1 gnbs=2 paging_limit=50
    Wait 5s For Paging
    Stop Collecting BIP Logs    pcap_filename=tcpdump_AL${AL}.pcap
    Convert BIP Logs Pcap To Csv
    ...       pcap_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_LOGS/L1L2_BIP_Logs/tcpdump_AL${AL}.pcap
    ...       filter=DlData_DciInfoL1sw.aggregationLevel == ${AL} && 3gpp.rnti == 65534
    ...       dir_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_LOGS/
    ...       csv_log_name=BIP_logs_AL${AL}.csv
    ...       columns=@{BIP_COLUMNS}
    Check That Aggregation Level For Paging Is AL${AL}

Check That Aggregation Level For Paging Is AL${AL}
    ${result}=    feature_resources.Verify Prnti Aggregation Level    file_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_LOGS/BIP_logs_AL${AL}.csv
    ...    aggregation_level=${AL}
    Should Be True    ${result}
