*** Settings ***
Documentation    Keywords for 5GC001912_MA 5GC001912_MB CNI-50897 test
...              author: Lukasz Skoczylas
...              contact: lukasz.skoczylas@nokia.com

Library    OperatingSystem
Library    ./precondition_with_ue.py
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.flow_verifier
Library    taf.rfrl.procedures.resources.python.sleeping_cell_detector    WITH NAME    scd
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/ue/robot/REAL_UE.robot
Resource   ./collect_logs.robot

*** Keywords ***
Suite Precondition
    Log To Console    \n--Suite Precondition--\n
    Perform Commissioning on gNB to onAir state
    scd.Enable Sleeping Cell Detection Feature
    Require Ue for L3 Call
    Run Keyword And Ignore Error  ue.Detach UE     UE
    Get primary cell parameters
    Get secondary cells parameters

Watch Alarms
    Start watching alarms    allowed_alarms=${allowed_alarms}
    scd.Enable Sleeping Cell Detection       log_dir=${LOG_PATH}/SleepingCell
    Watch Active Alarms and Collect Logs on Unexpected Alarm

Clean up
    Log To Console    \n--Clean up--\n
    scd.Verify Sleeping Cell Detection
    Stop watching alarms
    Remove Directory	${LOG_PATH}/ALARMS    recursive=${TRUE}
    Run Keyword And Ignore Error  ue.Detach UE     UE
    Unlock Cells on CU
    Wait for all cells to be onAir

Get primary cell parameters
    [Documentation]     Get primary cell parameters from gBN DU. Assuming first cell configured as PSCell
    ...                 Put primary_cell dict to suite variable
    Log To Console    \n--Get primary cell parameters--\n
    ${gnb_cell1_parameters}=  Get Cell Parameters
    Set Suite Variable    ${primary_cell}      ${gnb_cell1_parameters}

Get secondary cells parameters
    [Documentation]     Get secondary cells parameters from gBN DU. Assuming cell 2 to 8 configured as SCell
    ...                 Put secondary_cells list of dicts to suite variable
    Log To Console    \n--Get secondary cells parameters--\n
    @{secondary_cells}=    Create List
    # Fill two first with null to have list index equal to cell id
    Append To List    ${secondary_cells}    ${Null}
    Append To List    ${secondary_cells}    ${Null}
    FOR    ${cell_id}    IN RANGE   2   9
        ${gnb_cell_parameters}=  Get Cell Parameters   cell_id=${cell_id}
        Append To List    ${secondary_cells}      ${gnb_cell_parameters}
    END
    Set Suite Variable    ${secondary_cells}

Configure maxNumScellsDl on CU
    [Arguments]    ${value}
    [Documentation]     Configure maxNumScellsDl parameter on CU via delta plan
    ...     :param value: Value to set (1..7)
    Log To Console    \n--Configure maxNumScellsDl: ${value} on CU--\n
    Delete Delta Plan From CU
    Update Parameter Of Delta Plan      maxNumScellsDl    ${value}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Validate And Activate Delta Plan    skip_if_no_changes=${True}

Configure caConfigurationSupport on CU
    [Arguments]    ${value}
    [Documentation]     Configure caConfigurationSupport parameter on CU via delta plan
    ...     :param value: Value to set (2CCDL_2CCUL, 4CCDL_2CCUL or 8CCDL_4CC UL)
    Log To Console    \n--Configure caConfigurationSupport: ${value} on CU--\n
    Delete Delta Plan From CU
    Update Parameter Of Delta Plan      caConfigurationSupport    ${value}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Validate And Activate Delta Plan    skip_if_no_changes=${True}

Configure sCellActivationMethod on DU
    [Arguments]    ${value}
    [Documentation]     Configure sCellActivationMethod parameter on DU
    ...     :param value: Value to set (blind, bufferBased or bufferAndRLQualityBased)
    Log To Console    \n--Configure sCellActivationMethod: ${value} on DU--\n
    Perform Configuration Parameter Recommissioning On gNB  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    sCellActivationMethod    ${value}

Start Data Transfer DL&UL
    [Arguments]    ${DL_tput}  ${UL_tput}
    [Documentation]     Start UDP Data Transfer DL&UL on UE
    ...     :param DL_tput: DL tput
    ...     :param UL_tput: UL tput
    Log To Console    \n--Start Data Transfer DL&UL--\n
    Start Data Transfer on Real UE    dt_name=DT_DL  ue_alias=UE  direction=dl    duration=600s   tput=${DL_tput}
    ...                               protocol=udp  parallel_streams=1  size_packet=1400B
    Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=UE  direction=ul    duration=600s   tput=${UL_tput}
    ...                               protocol=udp  parallel_streams=1  size_packet=1400B

Start Data Transfer UL
    [Arguments]    ${UL_tput}
    [Documentation]     Start UDP Data Transfer UL on UE
    ...     :param UL_tput: UL tput
    Log To Console    \n--Start Data Transfer UL--\n
    Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=UE  direction=ul    duration=600s   tput=${UL_tput}
    ...                               protocol=udp  parallel_streams=1  size_packet=1400B

Stop Data Transfer
    ue.Stop Data Transfer     dt_name=DT_DL
    ue.Stop Data Transfer     dt_name=DT_UL

Lock PSCell
    [Documentation]     Lock cell on CU. Assuming first cell configured as PSCell
    Log To Console    \n--Lock PSCell--\n
    @{cells}  Create List  1
    Lock Cells on CU    ${cells}

Lock SCells
    [Arguments]    ${list_cell_ids}
    [Documentation]     Lock given cells on CU
    ...     :param list_cell_ids: list of cell ids to lock
    Log To Console    \n--Lock SCells  cell_ids: ${list_cell_ids}--\n
    Lock Cells on CU    ${list_cell_ids}

Wait for Cell to be Offline
    [Arguments]    ${cell_id}
    [Documentation]     Wait for cell be offline on DU
    ...     :param cell_id: id of observed cell
    Wait Until Keyword Succeeds  30 sec   1 sec  Verify Cell Statuses  cell_id=${cell_id}
    ...                                                                operational_state=Disabled
    ...                                                                availability_status=Offline
    ...                                                                procedural_status=configured
    ...                                                                administrative_state=unlocked

Wait for all cells to be onAir
    [Documentation]     Wait until all cell be onAir. Assuming 8 cell configured
    FOR    ${cell_id}    IN RANGE   1   9
        Wait for cell to be OnAir   cell_id=${cell_id}  timeout=300
    END

Attach UE and Verify EN-DC
    [Documentation]     Attach UE and verify 5G  EN-DC connection
    Log To Console    \n--Attach UE and Verify EN-DC--\n
    Start tcpdump on CU   filename=attach_nsa.pcap
    ue.Attach Ue     UE
    Stop tcpdump on CU and download logs   filename=attach_nsa.pcap
    Verify Attach EN-DC   attach_nsa.pcap

Verify Attach EN-DC
    [Arguments]    ${pcap_filename}
    [Documentation]     This keyword verifies if attach EN-DC is successful
    ...     :param pcap_filename: name of the pcap file created during the test, used for
    ...                           verification of attach
    Log To Console    \n--Verify Attach EN-DC--\n
    ${attach_expected_messages} =    Create List
    ...    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge(contains(physCellId=${primary_cell["physCellId"]}))
    ...    SgNBReconfigurationComplete    SNStatusTransfer
    Expect Messages In Flow    awaited_messages=${attach_expected_messages}
    ...    pcap_file=${OUTPUT DIR}/${pcap_filename}
    ${scg_failure_info} =    Check If Message Is In Flow
    ...    awaited_message=SgNBModificationRequest(contains(scgFailureInfo))
    ...    pcap_file=${OUTPUT DIR}/${pcap_filename}
    Run Keyword If    ${scg_failure_info} == ${True}    Fail   msg=RACH procedure failed.

Verify UEContextRelease
    [Arguments]    ${pcap_filename}
    [Documentation]     This keyword verifies if UEContextRelease in pcap
    ...     :param pcap_filename: name of the pcap file created during the test
    Log To Console    \n--Verify UEContextRelease--\n
    ${expected_messages} =    Create List
    ...     UEContextRelease
    Expect Messages In Flow    awaited_messages=${expected_messages}
    ...    pcap_file=${OUTPUT DIR}/${pcap_filename}


Verify ENDCPartialReset and UEContextRelease
    [Arguments]    ${pcap_filename}
    [Documentation]     This keyword verifies if ENDCPartialReset and UEContextRelease in pcap
    ...     :param pcap_filename: name of the pcap file created during the test
    Log To Console    \n--Verify UEContextRelease--\n
    ${expected_messages} =    Create List
    ...     ENDCPartialResetRequired(contains(radioNetwork=cell-not-available*))
    ...     SgNBReleaseRequest   UEContextRelease
    Expect Messages In Flow    awaited_messages=${expected_messages}
    ...    pcap_file=${OUTPUT DIR}/${pcap_filename}

Collect Tput Logs from Syslog
    [Arguments]     ${duration}   ${dir}
    [Documentation]     Collect BTSlog from gNB DU and extract L2 Tput logs.
    ...                 Put Tput logs to suite variable ${tput_log}
    ...     :param duration: duration time of log collecting, eg. 30 seconds
    ...     :param dir: name of direcotry for log
    Start Collecting gNB Btslog
    Sleep  ${duration}
    Stop Collecting gNB Btslog    log_dir=${OUTPUT DIR}/${dir}
    ${tput_log}=    Get Tput Logs from Syslog    ${OUTPUT DIR}/${dir}
    Set Suite Variable    ${tput_log}

Get Tput Logs from Syslog
    [Arguments]    ${log_dir}
    [Documentation]     Extract L2 Tput statistics from syslog
    ...     :param log_dir: directory where are syslog logs
    ...     :return tput_logs: string with L2 tput stats
    Run   rm ${log_dir}/SYSLOG_*
    Run   tar xzvf ${log_dir}/btslog_*/syslog_files.tgz -C ${log_dir}
    ${tput_log}=    Run   grep -e "-L2_LO_UL_0" -e "-L2_LO_TB_BUI0" -e "L-RLC numOfBearers" ${log_dir}/SYSLOG_*
    [Return]    ${tput_log}

Dl Data transfer is scheduled via PSCell only
    Log To Console    \n--Verify Dl Data transfer is scheduled via PSCell only--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${dl_ids}=    Set Variable    ${acctive_cells}[1]
    Length Should Be  ${dl_ids}  1
    Should Contain   ${dl_ids}   ${primary_cell}[nrCellIdentity]

Ul Data transfer is scheduled via PSCell only
    Log To Console    \n--Verify Ul Data transfer is scheduled via PSCell only--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${ul_ids}=    Set Variable    ${acctive_cells}[0]
    Length Should Be  ${ul_ids}  1
    Should Contain   ${ul_ids}   ${primary_cell}[nrCellIdentity]

Dl Data transfer is scheduled via PSCell and SCells
    [Arguments]   ${numScells}
    [Documentation]     Verify DL Data transfer is scheduled via PSCell and given number of SCells
    ...     :param numScells: expected number of active SCell
    Log To Console    \n--Verify DL Data transfer is scheduled via PSCell and ${numScells} SCells--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${dl_ids}=    Set Variable    ${acctive_cells}[1]
    ${expected_num_of_cell}=   Evaluate   ${numScells} + 1
    Length Should Be  ${dl_ids}  ${expected_num_of_cell}
    Should Contain   ${dl_ids}   ${primary_cell}[nrCellIdentity]

Ul Data transfer is scheduled via PSCell and SCells
    [Arguments]   ${numScells}
    [Documentation]     Verify UL Data transfer is scheduled via PSCell and given number of SCells
    ...     :param numScells: expected number of active SCell
    Log To Console    \n--Verify UL Data transfer is scheduled via PSCell and ${numScells} SCells--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${ul_ids}=    Set Variable   ${acctive_cells}[0]
    ${expected_num_of_cell}=   Evaluate   ${numScells} + 1
    Length Should Be  ${ul_ids}    ${expected_num_of_cell}
    Should Contain   ${ul_ids}   ${primary_cell}[nrCellIdentity]

Dl Data transfer is scheduled via PSCell and SCells except cells
    [Arguments]   ${numScells}   ${except_cells}
    [Documentation]     Verify Dl Data transfer is scheduled via PSCell and given number of SCells
    ...                 and no transfer on given except cells
    ...     :param numScells: expected number of active SCell
    ...     :param except_cells: list of cell ids where tput is not expected
    Log To Console    \n--Verify Dl Data transfer is scheduled via PSCell and ${numScells} SCells--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${dl_ids}=    Set Variable    ${acctive_cells}[1]
    ${expected_num_of_cell}=   Evaluate   ${numScells} + 1
    Length Should Be  ${dl_ids}  ${expected_num_of_cell}
    Should Contain   ${dl_ids}   ${primary_cell}[nrCellIdentity]
    FOR  ${except_cell}  IN  @{except_cells}
        Should Not Contain    ${dl_ids}    ${secondary_cells}[${except_cell}][nrCellIdentity]}
    END

No DL/UL Data transfer scheduled
    Log To Console    \n--Verify No DL/UL Data transfer scheduled--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${ul_ids}=    Set Variable   ${acctive_cells[0]}
    ${dl_ids}=    Set Variable    ${acctive_cells[1]}
    Length Should Be  ${dl_ids}   0
    Length Should Be  ${ul_ids}   0

No DL Data transfer scheduled
    Log To Console    \n--Verify No DL Data transfer scheduled--\n
    ${acctive_cells}=    get_active_cell_ids   ${tput_log}
    ${dl_ids}=    Set Variable    ${acctive_cells[1]}
    Length Should Be  ${dl_ids}   0
