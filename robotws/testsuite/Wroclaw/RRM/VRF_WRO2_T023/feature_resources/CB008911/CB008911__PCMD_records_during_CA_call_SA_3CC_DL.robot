*** Settings ***
Documentation
...  contact: Szymon Startek

Library       SSHLibrary
Library       DateTime
Library       ute_ue
Library       taf.sbts.oam.coam.admin    WITH NAME    admin
Library       taf.sw.dcap.rd
Library       ../../resources/Emil.py
Library       ../../resources/CSV_analyzer.py
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager.DCAPManager  WITH NAME  dcap_manager
Resource      ../../resources/ca_IWK.robot
Variables     testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Rozanka/resources/scenario.py


*** Variables ***
${MAX_DCAP_LOGS_DELAY}          140                      # Max time in seconds needed for change of DCAP logs collecting status to 'Running'
# Default value: 140
${DCAP_LOGS_PATH}                                        # Path to DCAP logs on local VM
${WINDOWS_PATH_TO_EMIL_EXE}     C:/Program Files/Emil/Emil    # Absolute path to EMIL execution file on Windows remote host (no '.exe' needed)
# Default value: C:/Program Files/Emil/Emil
${WINDOWS_TEMP_LOGS_DIR}        C:/Users/sranwro2/Documents/dcap_logs    # Absolute path to directory where logs will be kept for conversion to CSV
${NR_UE_CAPABILITY}                                      # Capability of NR UE used in test
${NR_PCELL_ID}                                           # NR PCell ID
${NR_SCELL_ID1}                                          # NR first SCell ID
${NR_SCELL_ID2}                                          # NR second SCell ID
${PCELL_ATTENUATOR_ALIAS}                                # Name of the attenuator ports mapped to the primary cell in ta_ue_config.yaml file
${SCELL_1_ATTENUATOR_ALIAS}                              # Name of the attenuator ports mapped to the 1st secondary cell in ta_ue_config.yaml file
${SCELL_2_ATTENUATOR_ALIAS}                              # Name of the attenuator ports mapped to the 2nd secondary cell in ta_ue_config.yaml file
${MERGE_CSV}                                             # Path to marged CSV file
${CELL1_NRCI}        '00000000 01011111 01100000 00000011 0000'B    # SCell Id NRCI
${CELL2_NRCI}        '00000000 01011111 01100000 00000010 1100'B    # SCell Id NRCI


*** Keywords ***
TC__CB008911__PCMD_records_during_CA_call_SA_3CC_DL

    Set Tags    CA-RRM    AUTHOR-magdalena.swierbutowicz@nokia.com    OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R1    FEATURE-CB008911
    ...         FEATURE-CB008911  GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Start Collecting Control Plane Logs
    Step 2: Perform NR DL Data Transfer
    Step 3: Stop NR Data Transfer
    Step 4: Stop Collecting Control Plane Logs
    Step 5: Extract EMIL Logs
    Step 6: Parse EMIL Logs
    Step 7: Check PCMD Records Related To SCells Addition
    Step 8: Check PCMD Records Related To INITIAL Timing Advance
    Step 9: Check PCMD Records Related To PERIODIC Timing Advance
    Step 10: Check Value Of tagId In Timing Advance PCMD Records
    Step 11: Check PCMD Records Related To Downlink Carrier Aggregation Scheduling Scenarios
    Step 12: Check PCMD Records Related To Downlink RLC Throughput Measurements
    Step 13: Check PCMD Records Related To SCell Release


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Global Variables
    ${_}  ${parsed_scf_gnb} =  Save And Parse SCF  SCF  alias=gNB
    Check Element In SCF  ${parsed_scf_gnb}  TCE  TCE-1  /p[@name='tceIpAddress']
    ...  <p name="tceIpAddress">${DCAP_HOST['ip']}</p>  dist_name_substring=True
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Log  Start setting attenuation  console=True
    Log  = Preconditions passed =  console=True


Set Global Variables
    Set Test Variable  ${DCAP_STARTED}  False

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Import Variables  ${ABSTRACT_LIB_CONFIG}


Step 1: Start Collecting Control Plane Logs
    Log  \n==== Step 1: Start Collecting Control Plane Logs ====  console=True

    ${nr_cell_list} =  Create List  ${NR_PCELL_ID}  ${NR_SCELL_ID1}  ${NR_SCELL_ID2}

    ${nr_log_profile} =  Create List  Tracer_5g
    ${profiles_dictionary} =  Create Dictionary  gnb_custom_profile=${nr_log_profile}
    ${user} =  Evaluate  $tl.gnbs[0].cu.oam_http_connection_details.username
    ${password} =  Evaluate  $tl.gnbs[0].cu.oam_http_connection_details.password

    Start Dcap Helper  ${nr_cell_list}  ${profiles_dictionary}  ${user}  ${password}

    Log  Waiting for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_DCAP_LOGS_DELAY}  5s  Check If Traces Are Running

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL' and ${DCAP_STARTED}
    ...  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}


Start Dcap Helper
    [Arguments]  ${nr_cell_list}  ${profiles_dictionary}  ${user}  ${password}

    Log  Connecting to DCAP server IP=${DCAP_HOST['ip']} on port=${DCAP_HOST['port']}  console=True
    dcap_manager.Connect To  host=${DCAP_HOST['ip']}  port=${DCAP_HOST['port']}
    ...  user=${DCAP_HOST['login']}  passwd=${DCAP_HOST['password']}


    Log  Using profiles:\n${profiles_dictionary}.\nStarting new trace for IP ${GNB_OAM_IP}...  console=True
    Set Test Variable  ${DCAP_STARTED}  True
    ${trace_id} =  dcap_manager.Start New Trace  mplane=${GNB_OAM_IP}  user=${user}  passwd=${password}
    ...  port=${DCAP_HOST['port']}  nr_cells=${nr_cell_list}  log_profile=${profiles_dictionary}
    Set Test Variable  ${TRACE_ID}  ${trace_id}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  dcap_manager.Stop Trace  trace=${trace_id}
    ...  AND  dcap_manager.Teardown
    ...  AND  Set Test Variable  ${DCAP_STARTED}  False


Check If Traces Are Running
    ${trace_status} =  Get Trace Info By ID  trace_id=${TRACE_ID}  connection=dcap_collector
    Should Be Equal As Strings  ${trace_status['status']}  running
    ...  msg=Trace status is ${trace_status['status']}. Should be: 'running'.
    Log  Trace status ${trace_status['status']}  console=True


Step 2: Perform NR DL Data Transfer
    Log  \n==== Step 2: Perform NR DL Data Transfer ====  console=True

    Log  Preparing UE for DL data transfer...  console=True
    Set Attenuation  ${PCELL_ATTENUATOR_ALIAS}  0dB
    Prepare UE For Data Transfer  NR_UE  ${NR_PCELL_ID}  connection=gNB  lte_cell=False
    Set Attenuation  ${SCELL_1_ATTENUATOR_ALIAS}  0dB
    Set Attenuation  ${SCELL_2_ATTENUATOR_ALIAS}  0dB
    Log  Starting data transfer...  console=True
    Start Data Transfer    NR_DL    NR_UE    dl    throughput=700 Mbits/sec    max_segment_size=1400
    ...  protocol=tcp    duration=180s
    Sleep  80s  reason=Wait for the PCMD records to appear during the data tranfer.
    Log  Increase attenuation of SCell to trigger SCell release  console=True
    Set Attenuation  ${PCELL_ATTENUATOR_ALIAS}  20dB
    Sleep  5s  reason=Wait few seconds for the A1 event to occur.
    Set Attenuation  ${SCELL_1_ATTENUATOR_ALIAS}  80dB
    Set Attenuation  ${SCELL_2_ATTENUATOR_ALIAS}  80dB
    Sleep    30s  reason=Wait for the PCMD SCells release records to appear during the data tranfer.
    Set Attenuation  ${PCELL_ATTENUATOR_ALIAS}  0dB
    Set Attenuation  ${SCELL_1_ATTENUATOR_ALIAS}  0dB
    Set Attenuation  ${SCELL_2_ATTENUATOR_ALIAS}  0dB


Step 3: Stop NR Data Transfer
    Log  \n==== Step 3: Stop NR Data Transfer ====  console=True

    Check Data Transfer Is Alive  NR_DL
    Await Data Transfer Finish    NR_DL
    Detach UE  NR_UE


Step 4: Stop Collecting Control Plane Logs
    Log  \n==== Step 4: Stop Collecting Control Plane Logs ====  console=True

    Stop DCAP Traces And Download Logs  trace_id=${TRACE_ID}


Stop DCAP Traces And Download Logs
    [Arguments]  ${trace_id}

    Log  Stopping DCAP traces...  console=True
    dcap_manager.Stop Trace  trace=${trace_id}
    Set Test Variable  ${DCAP_STARTED}  False
    Log  Downloading logs...  console=True
    ${dcap_logs_path} =  dcap_manager.Download Logs  trace=${trace_id}  target_dir=${LOG_PATH}/dcap_logs
    Log  Logs downloaded to ${dcap_logs_path}.  console=True
    Set Test Variable  ${DCAP_LOGS_PATH}  ${dcap_logs_path}
    dcap_manager.Teardown


Step 5: Extract EMIL Logs
    Log  \n==== Step 5: Extract EMIL Logs ====  console=True

    Extract Logs  ${DCAP_LOGS_PATH}  extract_dir=${LOG_PATH}/dcap_logs/dcap_unzipped


Step 6: Parse EMIL Logs
    Log  \n==== Step 6: Parse EMIL Logs ====  console=True

    Convert Files To CSV On Remote Windows Host
    ${files} =  OperatingSystem.List Files In Directory  ${LOG_PATH}/dcap_logs/CSV
    ${file_paths} =  Create List
    FOR  ${file}  IN  @{files}
        ${file_path} =  OperatingSystem.Join Path  ${LOG_PATH}/dcap_logs/CSV/  ${file}
        Log  Created file path: ${file_path}  console=True
        Append To List  ${file_paths}  ${file_path}
    END

    ${merge_csv}  Combine Multi Csv Files  ${LOG_PATH}/dcap_logs/CSV
    Log  \nCreated combine csv file: ${merge_csv}  console=True
    Set Test Variable  ${MERGE_CSV}  ${merge_csv}


Convert Files To CSV On Remote Windows Host
    ${ip}  ${login}  ${password}=  Set Variable
    ...  ${REMOTE_PC['ssh_ip']}  ${REMOTE_PC['ssh_username']}  ${REMOTE_PC['ssh_password']}

    SSHLibrary.Open Connection  ${ip}
    SSHLibrary.Login  ${login}  ${password}
    ${stdout}  ${rc} =  SSHLibrary.Execute Command
    ...  mkdir ${WINDOWS_TEMP_LOGS_DIR}  return_rc=True
    Log  stdout=${stdout}  console=True
    Should Be Equal As Integers  ${rc}  0  msg=SSH command execution ended with error.

    Rename Files   ${LOG_PATH}/dcap_logs/dcap_unzipped
    ${win_file_paths} =  Copy LCBIN Files To Windows  ${LOG_PATH}/dcap_logs/dcap_unzipped
    ...                                             ${WINDOWS_TEMP_LOGS_DIR}
    ...                                             ${ip}  ${login}  ${password}
    Log  File paths on Windows:\n${win_file_paths}  console=True

    FOR  ${file_path}  IN  @{win_file_paths}
        Log  \nFile path=${file_path}  console=True
        ${stdout}  ${rc} =  SSHLibrary.Execute Command
        ...  "${WINDOWS_PATH_TO_EMIL_EXE}" ${file_path} -ToCSV PerTrace -AutoClose
        ...  return_rc=True  timeout=600s
        Log  stdout=${stdout}  console=True
        Should Be Equal As Integers  ${rc}  0  msg=SSH command execution ended with error.
    END

    SSHLibrary.Get File  ${WINDOWS_TEMP_LOGS_DIR}/*.csv  ${LOG_PATH}/dcap_logs/CSV/

    ${stdout}  ${rc} =  SSHLibrary.Execute Command
    ...  rm -rf ${WINDOWS_TEMP_LOGS_DIR}  return_rc=True
    Log  stdout=${stdout}  console=True
    Should Be Equal As Integers  ${rc}  0  msg=SSH command execution ended with error.
    [Teardown]  SSHLibrary.Close All Connections


Step 7: Check PCMD Records Related To SCells Addition
    Log  \n==== Step 7: Check PCMD Records Related To SCells Addition ====  console=True

    ${filter1}=  Catenate    SEPARATOR=
    ...  CuVendorExtensionRecordDataType.*.setupSCells.*.scellIndex.*.cellId\\snrcgi.*.plmn-Identity.*.cellIdentity
    ...  .*.nrArfcnDl.*.sCellDirectionConfig
    ...  .*.scellIndex.*.cellId\\snrcgi.*.plmn-Identity.*.cellIdentity.*.nrArfcnDl.*.sCellDirectionConfig.*
    Check PCMD Records  CuCaConfigurationTraceRecord  ${filter1}

    ${filter2}=  Catenate    SEPARATOR=
    ...  DuVendorExtensionRecordDataType.*.setupSCells.*.scellIndex.*.cellId\\snrcgi.*.plmn-Identity.*.cellIdentity
    ...  .*.nrArfcnDl.*.sCellDirectionConfig
    ...  .*.scellIndex.*.cellId\\snrcgi.*.plmn-Identity.*.cellIdentity.*.nrArfcnDl.*.sCellDirectionConfig.*
    Check PCMD Records  DuCaConfigurationTraceRecord  ${filter2}


Step 8: Check PCMD Records Related To INITIAL Timing Advance
    Log  \n==== Step 8: Check PCMD Records Related To INITIAL Timing Advance ====  console=True

    ${filter}=  Set Variable  DuVendorExtensionRecordDataType.*.taData\\sinitial.*.tagId.*
    Check PCMD Records  TimingAdvanceTraceRecord  ${filter}


Step 9: Check PCMD Records Related To PERIODIC Timing Advance
    Log  \n==== Step 9: Check PCMD Records Related To PERIODIC Timing Advance ====  console=True

    ${filter}=  Set Variable    DuVendorExtensionRecordDataType.*.taData\\speriodic.*.tagId.*
    Check PCMD Records  TimingAdvanceTraceRecord  ${filter}

    Log  Check periodicity of the Periodic Timing Advance Records. It should be around 4 sek.  console=True
    ${periodicity}  Check Timing Advance Records Periodicity  ${MERGE_CSV}  TimingAdvanceTraceRecord
    Should Be True  ${periodicity}  msg=Periodicity of TimingAdvanceTraceRecord is not between 4 and 5 sec.


Step 10: Check Value Of tagId In Timing Advance PCMD Records
    Log  \n==== Step 10: Check Value Of tagId In Timing Advance PCMD Records ====  console=True

    Check tagId Value


Step 11: Check PCMD Records Related To Downlink Carrier Aggregation Scheduling Scenarios
    Log  \n==== Step 11: Check PCMD Records Related To Downlink Carrier Aggregation Scheduling Scenarios ====  console=True

    ${filter}=  Catenate    SEPARATOR=
    ...  DuVendorExtensionRecordDataType.*.dlCaSCellSchedulingRecord.*.endMarker.*.cellId\\snrci
    ...  .*.recordCollectionDuration\\s([1-9]\\d+).*.timeOfUeSched\\s([1-9]\\d+).*.numOf1stMacPduTx\\s([1-9]\\d+)
    ...  .*.numOfBad1stMacPduTx.*.numOfPdschTxWithRank1.*.numOfPdschTxWithRank2.*.numOfPdschTxWithRank3
    ...  .*.numOfPdschTxWithRank4.*.avgTb0WbCqi.*.sumOfWbCqi.*.numOfWbCqiSamples.*
    Check PCMD Records  DuDlCaSCellSchedulingTraceRecord  ${filter}

    Log  Check periodicity of the DuDlCaSCellSchedulingTraceRecord. It should be around 4 sek.  console=True
    ${periodicity}  Check Records Periodicity  ${MERGE_CSV}
    ...  DuDlCaSCellSchedulingTraceRecord  ${CELL1_NRCI}  ${CELL2_NRCI}
    Should Be True  ${periodicity}  msg=Periodicity of DuDlCaSCellSchedulingTraceRecord is not between 4 and 5s.


Step 12: Check PCMD Records Related To Downlink RLC Throughput Measurements
    Log  \n==== Step 12: Check PCMD Records Related To Downlink RLC Throughput Measurements ====  console=True

    ${filter}=  Catenate    SEPARATOR=
    ...  DuVendorExtensionRecordDataType.*.caSCellDlRbRlcMeasRecord.*.rbData.*.endMarker.*.drb-Id.*.cellId\\snrci
    ...  .*.dataCollectionDuration\\s([1-9]\\d+).*.timeOfUePduTx\\s([1-9]\\d+).*.sumOfRlcPduTxBytes\\s([1-9]\\d+)
    ...  .*.avgIpLatency.*.sumOfDelays\\s(\\d+).*.numOfRlcSdus\\s(\\d+).*
    Check PCMD Records  DuDlCaSCellRadioBearerRlcMeasTraceRecord  ${filter}

    Log  Check periodicity of the DuDlCaSCellRadioBearerRlcMeasTraceRecord. It should be around 4 sek.  console=True
    ${periodicity}  Check Records Periodicity  ${MERGE_CSV}
    ...  DuDlCaSCellRadioBearerRlcMeasTraceRecord  ${CELL1_NRCI}  ${CELL2_NRCI}
    Should Be True  ${periodicity}  msg=Periodicity of DuDlCaSCellRadioBearerRlcMeasTraceRecord is not between 4 and 5s.


Step 13: Check PCMD Records Related To SCell Release
    Log  \n==== Step 13: Check PCMD Records Related To SCell Release ====  console=True

    ${filter1}=  Set Variable
    ...  CuVendorExtensionRecordDataType.*.releasedSCells.*.cellId\\snrcgi.*.plmn-Identity.*.cellIdentity
    Check PCMD Records  CuCaConfigurationTraceRecord  ${filter1}

    ${filter2}=  Set Variable
    ...  DuVendorExtensionRecordDataType.*.releasedSCells.*.cellId\\snrcgi.*.plmn-Identity.*.cellIdentity
    Check PCMD Records  DuCaConfigurationTraceRecord  ${filter2}


Check PCMD Records
    [Arguments]  ${record_name}  ${filter}
    ${record_exist}  Check Whether The Keyword Exists In Csv  ${MERGE_CSV}  ${record_name}
    Log  \n ${record_name} exist: ${record_exist}  console=True
    Should Be True  ${record_exist}  msg=${record_name} does not exist
    @{record_data}  Read Pcmd Record  ${MERGE_CSV}  ${record_name}
    Should Not Be Empty  ${record_data}
    ...    msg=There are no parameters in the given record. Check the column numer of the record in CSV file.

    ${list_pcmd_fields}  Create List
    FOR  ${row}  IN  @{record_data}
        ${flat_row}=  Remove String  ${row}  \n
        ${pcmd_fields} =  Get Regexp Matches  ${flat_row}  ${filter}
        Run Keyword If  ${pcmd_fields}!=[]  Append To List  ${list_pcmd_fields}  ${pcmd_fields}
    END

    Should Not Be Empty  ${list_pcmd_fields}  msg=The record does not have the required parameters.
    Log  \n${record_name} contains all required fields  console=True


Check tagId Value
    [Arguments]  ${value}=0
    ${record_exist}  Check Whether The Keyword Exists In Csv  ${MERGE_CSV}  TimingAdvanceTraceRecord
    Log  \n TimingAdvanceTraceRecord exist: ${record_exist}  console=True
    Should Be True  ${record_exist}  msg=TimingAdvanceTraceRecord does not exist
    @{record_data}  Read Pcmd Record  ${MERGE_CSV}  TimingAdvanceTraceRecord
    Should Not Be Empty  ${record_data}
    ...    msg=There are no parameters in the given record. Check the column numer of the record in CSV file.

    ${total_number_of_records} =  Get Length  ${record_data}

    ${list_pcmd_fields}  Create List
    FOR  ${row}  IN  @{record_data}
        ${flat_row}=  Remove String  ${row}  \n
        ${pcmd_fields} =  Get Regexp Matches  ${flat_row}  tagId\\s${value}
        Run Keyword If  ${pcmd_fields}!=[]  Append To List  ${list_pcmd_fields}  ${pcmd_fields}
    END

    ${total_number_of_matching_records} =  Get Length  ${list_pcmd_fields}

    Should Be Equal As Integers  ${total_number_of_records}  ${total_number_of_matching_records}
    ...  msg=At least one TimingAdvanceTraceRecord does not have tagId equal to ${value}.
    Log  Success, all TimingAdvanceTraceRecord have tagId equal to ${value}.  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False
    Create Directory  ${LOG_PATH}/dcap_logs


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Set Attenuation For All Cells  100%
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE

    Run Keyword If  ${DCAP_STARTED}  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}

    IWK Test Teardown  stop_wireshark=True  delta_exists=False  local_enb_connection=False
