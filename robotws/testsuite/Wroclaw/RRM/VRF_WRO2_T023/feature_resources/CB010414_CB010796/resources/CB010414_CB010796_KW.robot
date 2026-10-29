*** Settings ***
Documentation
...   contact: Wojciech Peciak

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/ca_IWK.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/cloud_bts.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB011169/resources/CB011169_resources.robot

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/tti_trace.py
Library    ta5g_commissioning
Library    ta5g_admin_operations
Library    ta5g_iphy
Library    taf.config.scf
Library    ta5g_pm_counters


*** Keywords ***
Prepare vDU Delta Scfs For CB010414 Rf Counters Collection Act And Deact
    [Documentation]
    ...  KW calculates delta JSON files to preform activation of RMOD temperature related counters on vDU
    ...  and to revert the changes back to original SCF.
    ...  Counters are set with interval specified by the ${interval_time} argument
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | interval_time          | No   | Counters collection interval in min value.                            |
    ...  |                        |      | Value has to be allowed in SCF.                                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Prepare vDU Delta Scfs For CB010414 Rf Counters Collection Act And Deact  ${interval_time}=5

    [Arguments]    ${interval_time}=5
    Load SCF  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml

    Modify SCF Element  value=${interval_time}min  dist_name=${PMMNL_DIST_NAME}    p_name=mtSBTSRMODTemperature
    Modify SCF Element  value=${interval_time}min  dist_name=${PMCADM_DIST_NAME}   p_name=reportingIntervalPm
    Modify SCF Element  value=${interval_time}min  dist_name=${NRPMRNL_DIST_NAME}  p_name=miNrCellAvailability

    Save SCF  ${LOG_PATH}/misc_logs/vDU_SCF_modified.xml
    Calculate Delta Between SCFs
    ...  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml
    ...  ${LOG_PATH}/misc_logs/vDU_SCF_modified.xml
    ...  CB010414_Rf_Counters_Collection_Act

Activate CB010414 RF Counters Collection Every ${interval_time}min
    [Documentation]
    ...  KW activates RMOD temperature related  counters on vDU SCF
    ...  and sets its collection in declared cycles in minutes.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | interval_time          | Yes  | Counters collection interval in min value.                            |
    ...  |                        |      | Value has to be allowed in SCF.                                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Activate CB010414 RF Counters Collection Every 5min

    Prepare vDU Delta Scfs For CB010414 Rf Counters Collection Act And Deact  interval_time=${interval_time}
    Log  \n Activate CB010414 RF Counters Collection Every ${interval_time}min...  console=True
    Connect To VDU
    Log  Performing recommissioning on vDU...  console=True
    Set Test Variable  ${PARAMETERS_MODIFIED}  True
    vdu.Perform Delta Recommissioning  delta_file=${LOG_PATH}/misc_logs/CB010414_Rf_Counters_Collection_Act.json
    Log  Update on vDU finished.  console=True
    [Teardown]  Run Keyword And Ignore Error  vdu.Disconnect

Restore CB010414 RF Counters Config
    [Documentation]
    ...  KW restores original (before the test started) values of parameters.
    ...  It requires "Activate CB010414 RF Counters Collection Every ${interval_time}min" KW to be executed beforehand.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Restore CB010414 RF Counters Config

    Log  \n Restore CB010414 RF Counters Config...  console=True
    Connect To VDU
    Log  Performing recommissioning on vDU...  console=True
    vdu.Perform Delta Recommissioning
    ...  delta_file=${LOG_PATH}/misc_logs/CB010414_Rf_Counters_Collection_Act_revert.json
    Log  Update on vDU finished.  console=True
    Set Test Variable  ${PARAMETERS_MODIFIED}  False
    [Teardown]  Run Keyword And Ignore Error  vdu.Disconnect


Trigger RU Temperature Update Msg
    [Documentation]
    ...  KW will trigger msg to OAM with RU temperature rating to affect Slot/Symbol Muting/Blanking on Hot RU
    ...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1463341040#
    ...  CB005788:HightemperaturehandlingofRFunitsinRF7.1TDDFR1-OamTerm/AaShellcommand
    ...
    ...  Within the KW dictionary with temperature rating change levels for AP radio unit is created.
    ...  It consists of AP OAM command to change the level and expected response to confirm change was done.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | temperature_rating     | No   | Temperature rating to be triggered on RU.                             |
    ...  |                        |      | One of defined values in &{RU_TEMP_CMD_SET} dictionary.               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Trigger RU Temperature Update Msg  temperature_rating=NORMAL

    [Arguments]  ${temperature_rating}=NORMAL

    &{ru_temp_high} =  Create Dictionary
                            ...  tempRatingCMD=--db ${rmod_ap_id} set_temp_rating HIGH
                            ...  ExpRes=set_temp_rating HIGH successfully proceed
    &{ru_temp_increased} =  Create Dictionary
                            ...  tempRatingCMD=--db ${rmod_ap_id} set_temp_rating INCREASED
                            ...  ExpRes=set_temp_rating INCREASED successfully proceed
    &{ru_temp_normal} =  Create Dictionary
                            ...  tempRatingCMD=--db ${rmod_ap_id} set_temp_rating NORMAL
                            ...  ExpRes=set_temp_rating NORMAL successfully proceed
    &{ru_temp_cmd_set} =  Create Dictionary  HIGH=&{ru_temp_high}  INCREASED=&{ru_temp_increased}  NORMAL=&{ru_temp_normal}

    Run And Verify RU OAM Command
    ...  ${ru_temp_cmd_set}[${temperature_rating}][tempRatingCMD]
    ...  ${ru_temp_cmd_set}[${temperature_rating}][ExpRes]

    Log  Setting temperature ratio on RU to ${temperature_rating}  console=True

Run And Verify RU OAM Command
    [Documentation]
    ...  KW will create AirPhone RU OAM session, run command there and validate its result against expected result value.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | OAM_command            | Yes  | RU OAM command to be executed.                                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | expected_result        | Yes  | Text of expected result from command output                           |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Run And Verify RU OAM Command  --db 1 set_temp_rating INCREASED  set_temp_rating INCREASED successfully proceed

    [Arguments]  ${OAM_command}  ${expected_result}
    ${command_result} =  Execute Wts Command  /opt/UE_APP_OAM/service/OamTerm/oamTerm.py ${OAM_command}

    Should Contain  ${command_result}   ${expected_result}
    ...  RU OAM command verification failed. Expected: ${expected_result} | Actual: ${command_result}

R&D Counters Collection From vDU
    [Documentation]
    ...  KW will wait for end of current counters collection cycle on vDU and
    ...  retrieve R&D counters file returning its local path.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | output_dirpath         | No   | Path to output directory where vDU counters file will be placed.      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     R&D Counters Collection From vDU  ${OUTPUT_DIR}/counters_vDU

    [Arguments]  ${output_dirpath}=${LOG_PATH}/counters_vdu_1
    Wait For New Counter Period  additional_waiting_time=60
    ${rd_counter_file} =  Get Latest Unpacked Full Rd Counters File Aic  output_dirpath=${output_dirpath}  vdu=1
    [Return]  ${rd_counter_file}

Collect TTI Trace With UTF
    [Documentation]
    ...  KW starts TTI Trace logs collection via UTF for specified cell.
    ...  After fixed time it will stop the session and download logs marking it with currently used UE id.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | nr_cell_id             | Yes  | Id of cell from which TTI Trace should be collected.                  |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | ue_id                  | Yes  | ID of currently used UE                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect TTI Trace With UTF  1  1

    [Arguments]  ${nr_cell_id}  ${ue_id}
    Start Collecting Logs With UTF  ${nr_cell_id}
    Sleep  3s  reason=Wait for TTI to be collected.
    [Teardown]  Stop UTF Traces and Download Logs  ${TRACE_ID}  ue_id=${ue_id}

Extract TTI Trace Data From ZIP To Filtered CSV
    [Documentation]
    ...  Transforms TTI Trace ZIP file from UTF to filtered CSV
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Order of actions:
    ...  1. Given ZIP file extraction to TMP directory and returning TTI Trace PCAP file path
    ...  2. PCAP file decoding via EventDecoder and filtering with data from "Included_TTI_Events_List.txt"
    ...  3. Verification if result file exists and returning its path.
    ...     If it does not exist, events from "Included_TTI_Events_List.txt" did not occur in PCAP file.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | utf_logs_path          | Yes  | Path to ZIP file with TTI Trace.                                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | destination_logs_path  | Yes  | Path to store the KW processing results.                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | filtering_file         | No   | Path to file with TTI events to be filtered.                          |
    ...  |                        |      | Default value: ${CURDIR}${/}Included_TTI_Events_List.txt.             |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${csv_tti_path}=  Extract TTI Trace Data From ZIP To Filtered CSV  ${UTF_LOGS_PATH}  ${LOG_PATH}

    [Arguments]  ${utf_logs_path}
    ...          ${destination_logs_path}
    ...          ${filtering_file}=${CURDIR}${/}Included_TTI_Events_List.txt

    ${timestamp}=  Get Time  epoch
    ${tti_file_path}=  Unzip TTI  ${utf_logs_path}
    ...  destination_path=${destination_logs_path}
    ...  file_search_str=5G_L2
    ...  unzipped_path=/tmp/utf_unzipped_timestamped_${timestamp}
    Convert 5G TTI With Eventdecoder Options
    ...  ${tti_file_path}
    ...  output_file_path=${destination_logs_path}
    ...  eventdecoder_options=--split 200000 --include ${filtering_file}
    ${path_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${destination_logs_path}/NR_TTI_dl.csv
    ${path_2_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${destination_logs_path}/NR_TTI_dl.0.csv

    ${csv_tti_path}=  Set Variable If
    ...                 ${path_exist}   ${destination_logs_path}/NR_TTI_dl.csv
    ...                 ${path2_exist}  ${destination_logs_path}/NR_TTI_dl.0.csv
    ...                 ${None}
    Log  TTI Trace processed  console=True
    [Return]  ${csv_tti_path}

Verify SlotBlanking And Muting Ratio
    [Documentation]
    ...  Verification if SlotBlanking is occurring with given Muting Ratio
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  In case of expected 0% Muting Ratio meaning SlotBlanking is deactivated,
    ...  decoded csv_tti_path file does not exist since no dlSlotBlankingInfo
    ...  events were filtered out in captured TTI Trace.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | csv_tti_path           | Yes  | Path to CSV file with TTI Trace.                                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | blanking_ratio         | Yes  | Percentage slot blanking ratio value. One from set: 0%, 17%, 35%, 50%.|
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify SlotBlanking And Muting Ratio  /home/ute/TTI_Trace.csv  17

    [Arguments]  ${csv_tti_path}  ${blanking_ratio}

    IF  '${blanking_ratio}'=='0' and '${csv_tti_path}' == '${None}'
        ${verdict} =  Set Variable  ${True}
    ELSE
        ${verdict} =  Verify Slotblanking With Desired Ratio  ${csv_tti_path}  ${blanking_ratio}
    END

    Should Be True  ${verdict}  msg=Verification if SlotBlanking is occurring with ${blanking_ratio}% Muting Ratio failed.

Deregister UE And Stop Data Transfer
    [Documentation]
    ...  KW tears down UE data transfer and deregisters it from the network.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ue_id                  | No   | ID of currently used UE                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Deregister UE And Stop Data Transfer  1

    [Arguments]  ${ue_id}=1
    Stop Data Traffic  ues=${ue_id}  direction=both
    Release Pdu Session  ue_id=${ue_id}  pdu_id=1
    Deregister Ue  ue_id=${ue_id}
