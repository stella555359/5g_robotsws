*** Settings ***
Documentation
...   author: Piotr Brzezicki piotr.brzezicki@nokia.com
...   maintainer: piotr.brzezicki@nokia.com

Library    DateTime                                                     WITH NAME    dt
Library    taf.ue                                                       WITH NAME    ue
Library    ute_fsmaccess
Library    ta5g_pm_counters                                             WITH NAME    pmcount
Library    taf.rfrl.ue.ute_ue_config.UteUeConfig                        WITH NAME    uteueconfig
Library    taf.rfrl.bts.commissioning                                   WITH NAME    commission
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations        WITH NAME    duoperations
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    cells
Library    ../../../../resources/pcap_verification/flow_verifier.py     WITH NAME    flow_verifier
Library    ./suite_specific_keywords.py                                 WITH NAME    sskpy
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common.RfAttenuator  WITH NAME    rf_att
Library    ../../FR_CB008490/resources/bts_logs.py                       WITH NAME    bts_logs

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../../../resources/collect_logs.robot

Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./variables.py
Variables    ./delta.py

*** Variables ***
${DESIRED_CELL_ID}=      1261731860
${skip_commissioning}       ${NONE}
${skip_common_steps}       ${NONE}
${pcap_capture_filter}    'sctp and (port 38412 or port 38472 or port 38462 or port 29211)'
${PCAP_IF}                any

*** Keywords ***
Suite Setup
    [Documentation]    KW for Suite Setup. Performs full commissioning only for 1 BTS and common steps

    Log Action To Console    ==== SUITE SETUP START ====
    sskpy.Remove unused gNB from tl robot variable
    rf_att.Setup All Attenuators
    Run Keyword If    '${skip_common_steps}' != 'true'    Common Suite Setup    check_truck_roll=${True}
    Log Action To Console    ==== SUITE SETUP END ====    new_line_after=True


Suite Teardown
    [Documentation]    KW for Suite Teardown. Performs common steps

    Log Action To Console    ==== SUITE TEARDOWN START ====    new_line_after=True
    Run Keyword If    '${skip_common_steps}' != 'true'    Common Suite Teardown

Test Setup
    [Documentation]    KW for Test Setup. Performs common steps, prepares UE and attenuator

    Log Action To Console    ==== TEST SETUP START ====
    Run Keyword If    '${skip_common_steps}' != 'true'     Common Preconditions    raise_exception_when_setup_ru_console_fail=${False}
    taf.rfrl.utilities.test_config.Set Test Case Log Path
    Download gNB Configuration File    local_dir=${LOG_PATH}    filename=${TEST NAME}_Test_Setup_SCF.xml
    Prepare Ue for L3 Call    alias=QC_MTP_SDX65    capabilities=REAL_UE    reboot_ue=False
    rf_att.Set Attenuation For Ru    radio_type=AEQP     value=10dB
    Run Keyword And Warn On Failure    bts_logs.Start UTF Logs Collection
    Log Action To Console    ==== TEST SETUP END ====    new_line_after=True

Test Teardown
    [Documentation]    KW for Test Teardown. Detaches UE and performs common steps

    Log Action To Console    ==== TEST TEARDOWN START ====   new_line_after=True
    Run Keyword and Ignore Error    ue.Detach Ue    QC_MTP_SDX65
    Run Keyword And Warn On Failure     bts_logs.Stop UTF Logs Collection
    Run Keyword If    '${skip_common_steps}' != 'true'     Common Postconditions    collect_snapshot_from_ru=${False}

Delta Commissioning With OnAir Check
    [Arguments]    ${delta}
    [Documentation]     KW performs delta commissioning and waits for all cells to be onAir
    ...                 :param delta: SCF delta in JSON format

    Log Action To Console    Delta Commissioning And OnAir Check
    Perform Delta Commissioning On GNB     delta=${delta}
    Wait For All Cells To Be OnAir


Wait For All Cells To Be OnAir
    [Documentation]     KW waits until All BTS cells achieve onAir state

    Log Action To Console    Wait For All Cells To Be OnAir
    cells.Wait For All Cells Statuses    availability_status=online
    ...                                  operational_state=enabled
    ...                                  administrative_state=Unlocked
    ...                                  blocking_state=Unblocked
    ...                                  procedural_status=configured
    ...                                  usage_state=Active
    ...                                  barring_status=unbarred
    ...                                  timeout=600

Reconfigure NRBTS/identifiedFwaUeList = <UE RFSP Index>
    Log Action To Console    Reconfigure NRBTS/identifiedFwaUeList = <UE RFSP Index>
    Perform Delta Commissioning On gNB     delta=${ue_is_has_fwa_rfsp}

Attach UE with cell verification
    [Arguments]     ${pcap_gathering_time}=15s
    [Documentation]    The keyword performs registration to SA cell with NR-DC call establishment
    ...    and checks if attach was performed to desired cell of 5G BTS.
    ...    :param pcap_gathering_time:        Time of pcap gathering after UE attach

    ${date}=    Get Current Date   result_format=%Y%m%d-%H%M%S
    ${pcap_file}=  Set variable    UE_attach_${date}.pcap
    Start tcpdump on CU     filename=${pcap_file}    interface=${PCAP_IF}    protocol=${pcap_capture_filter}
    ue.Attach UE   QC_MTP_SDX65
    ${CELL_ID}=    ue.Get Ue Info    QC_MTP_SDX65   CELL_ID
    Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}
    Sleep    ${pcap_gathering_time}
    Stop tcpdump on CU and Download Logs    filename=${pcap_file}
    ${hex_5g_nrci}=    sskpy.get nr cell id in hex   nr_cell_id=${CELL_ID}       hex_len=18
    sskpy.verify_ngap_initial_context_setup    pcap_file=${LOG_PATH}/${pcap_file}    nrcell_id=${hex_5g_nrci}
    [RETURN]    ${pcap_file}


Attach UE with NRDC establishment verification
    [Documentation]    The keyword performs registration to SA cell with NR-DC call establishment
    ...    and checks if attach was performed to desired cell of 5G BTS.

    Log Action To Console    Attach UE with NRDC establishment verification
    ${pcap_file}=    Attach UE with cell verification
    sskpy.verify nrdc call setup    pcap_file=${LOG_PATH}/${pcap_file}

Attach UE and verify that inter-freq and inter-RAT measurements were configured
    Log Action To Console    Attach UE and verify that inter-freq and inter-RAT measurements were configured
    ${pcap_file}=    Attach UE with cell verification
    ue.Detach Ue    QC_MTP_SDX65
    sskpy.check_that_interfreq_and_interrat_measurements_were_configured_for_ue    pcap_file=${LOG_PATH}/${pcap_file}

Attach UE and verify that inter-freq and inter-RAT measurements were NOT configured
    Log Action To Console    Attach UE and verify that inter-freq and inter-RAT measurements were NOT configured
    ${pcap_file}=    Attach UE with cell verification
    ue.Detach Ue    QC_MTP_SDX65
    sskpy.check_that_interfreq_and_interrat_measurements_were_not_configured_for_ue    pcap_file=${LOG_PATH}/${pcap_file}

Attach UE and A4 NRDC is configured and RRC Release contains frequencies for reselection
    Log Action To Console    Attach UE and A4 NRDC is configured and RRC Release contains frequencies for reselection
    ${pcap_file}=    Attach UE with cell verification    pcap_gathering_time=30s
    ue.Detach Ue    QC_MTP_SDX65
    sskpy.check_that_a4_nrdc_is_configured_and_rrc_release_contains_frequencies_for_reselection   pcap_file=${LOG_PATH}/${pcap_file}

Attach UE to each cell
    Log Action To Console    Attach UE to each cell
    ue.Attach UE   QC_MTP_SDX65
    ${CELL_ID}=    ue.Get Ue Info    QC_MTP_SDX65   CELL_ID
    Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}
    ue.Detach Ue    QC_MTP_SDX65
    rf_att.Set Attenuation For Ru    radio_type=AZQO     value=110dB
    rf_att.Set Attenuation For Ru    radio_type=AHPE     value=0dB
    ue.Attach UE   QC_MTP_SDX65
    ${DESIRED_CELL_ID}=   Set variable    1261731870
    ${CELL_ID}=    ue.Get Ue Info    QC_MTP_SDX65   CELL_ID
    Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}
    ue.Detach Ue    QC_MTP_SDX65
    rf_att.Set Attenuation For Ru        radio_type=AHPE     value=110dB

Attach UE and trigger reestablishment to other cell during A4 supervision timer running
    [Documentation]    The keyword performs registration to SA cell with rrc reestablishment afterwards
    ...    and checks related RRC messages

    Log Action To Console    Attach UE and trigger reestablishment to other cell during A4 supervision timer running
    rf_att.Set Attenuation For Ru    radio_type=AHPE     value=0dB
    ${date}=    Get Current Date   result_format=%Y%m%d-%H%M%S
    ${pcap_file}=  Set variable    UE_attach_${date}.pcap
    Start tcpdump on CU     filename=${pcap_file}    interface=${PCAP_IF}    protocol=${pcap_capture_filter}
    ${DESIRED_CELL_ID}=   Set variable    1261731870
    ue.Attach UE   QC_MTP_SDX65
    ${CELL_ID}=    ue.Get Ue Info    QC_MTP_SDX65   CELL_ID
    Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}
    Sleep    10s
    sskpy.trigger reestablishment to other cell    src_radio_type=AHPE    tgt_radio_type=AZQO
    Sleep    10s
    Stop tcpdump on CU and Download Logs    filename=${pcap_file}
    ue.Detach Ue    QC_MTP_SDX65
    sskpy.check reestablishment    pcap_file=${LOG_PATH}/${pcap_file}

Detach UE with NRDC release verification
    [Documentation]    The keyword performs UE detach.

    Log Action To Console    Detach UE with NRDC release verification
    ${date}=    Get Current Date   result_format=%Y%m%d-%H%M%S
    ${pcap_file}=  Set variable    UE_detach_${date}.pcap
    Start tcpdump on CU     filename=${pcap_file}    interface=${PCAP_IF}   protocol=${pcap_capture_filter}
    ue.Detach Ue    QC_MTP_SDX65
    Sleep  5s
    Stop tcpdump on CU and Download Logs    filename=${pcap_file}
    ${pcap_path}=    Set variable    ${LOG_PATH}/${pcap_file}
    sskpy.Verify F1ap Ue Context Release    ${pcap_path}
    sskpy.Verify E1ap Bearer Context Release    ${pcap_path}
    sskpy.Verify Ngap Ue Context Release    ${pcap_path}

Verify Messages in flow
    [Arguments]    ${awaited_message}    ${number_of_messages}    ${pcap_file}
    [Documentation]    The keyword gets all messages in flow and verifies if length of table of messages have propper
    ...                value
    ...                :param awaited_message:        A message that need to be checked
    ...                :param number_of_messages:        Number of awaited messages to check length of messages table
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify ${awaited_message} messages in flow
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=${awaited_message}
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${expected_length}=    Check Messages Length    ${message}    ${number_of_messages}
    Run Keyword If    ${expected_length} != ${True}    Fail And Log Error
    ...    msg= No ${awaited_message} messages in flow

Verify UEContextReleaseCommand Message
    [Arguments]    ${pcap_file}
    [Documentation]    Verifies UEContextReleaseCommand has a propper value in it
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify UEContextReleaseCommand message
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=UEContextReleaseCommand
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${are_items_in_message}=    Find Cause and its Value    Cause: radioNetwork (0)    normal-release    ${message[1]}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= No normal-release in message

Verify BearerContextReleaseCommand Message
    [Arguments]    ${pcap_file}
    [Documentation]    Verifies BearerContextReleaseCommand has a propper value in it
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify BearerContextReleaseCommand message
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=BearerContextReleaseCommand
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${are_items_in_message}=    Find Cause and its Value    Cause: radioNetwork (0)    normal-release    ${message[0]}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= No normal-release in message

Verify Message in flow
    [Arguments]    ${awaited_message}    ${pcap_file}
    [Documentation]    The keyword verifies if messages appears in flow
    ...                value
    ...                :param awaited_message:        A message that need to be checked
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify ${awaited_message} message in flow
    ${message_found}=    flow_verifier.Check If Message Is In Flow
    ...    awaited_message=${awaited_message}
    ...    pcap_file=${LOG_PATH}/${pcap_file}
    Run Keyword If    ${message_found} == ${False}    Fail And Log Error
    ...                                               msg=Message ${awaited_message} not found in flow.

Verify RRCReconfigurationComplete Message in flow
    [Arguments]    ${pcap_file}
    [Documentation]    Verifies RRCReconfigurationComplete is in flow
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify RRCReconfigurationComplete message in flow
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=ULRRCMessageTransfer
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${are_items_in_message}=    Find Item in Message    RRCReconfigurationComplete    ${message}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= Cells does not appear in message

Verify RRCRelease Message in flow
    [Arguments]    ${pcap_file}
    [Documentation]    Verifies RRCRelease is in flow
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify RRCRelease message in flow
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=UEContextReleaseCommand
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${are_items_in_message}=    Find Item in Message    rrcRelease    ${message}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= RRCRelease is not in flow

Verify if Cells Appear in UEContextSetupRequest Message
    [Arguments]    ${expected_scells}    ${awaited_message}    ${pcap_file}
    [Documentation]    The keyword checks if given cells are configured
    ...                :param expected_cells: list of cells ids to check

    ${expected_scells_number}=    Get Length   ${expected_scells}
    Log Action To Console    Verify if ${expected_scells_number}CC is Configured in UEContextSetupRequest
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=${awaited_message}
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${scells_find_messages_info}=    Find All Scells in Message    ${expected_scells}    ${message[1]}
    Run Keyword If    ${scells_find_messages_info} != ${True}    Fail And Log Error
    ...    msg= Cells does not appear in message

Verify UEContextSetupResponse Message
    [Arguments]    ${expected_items}    ${awaited_message}    ${pcap_file}
    [Documentation]    The keyword gets UEContextSetupResponse message and checks if expected items are in it and
    ...                are arranged in the appropriate trees
    ...                :param expected_items:        Expected items to be checked in message
    ...                :param awaited_message:        A message that need to be checked
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify UEContextSetupResponse message
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=${awaited_message}
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    ${are_items_in_message}=    Find Items in Message    ${expected_items}    ${message[1]}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= Expected items does not appear in message
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[2]}
    ...                                                                       ${expected_items[0:2]}
    ...                                                                       ${message[1]}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[4]}
    ...                                                                       ${expected_items[3:4]}
    ...                                                                       ${message[1]}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[8]}
    ...                                                                       ${expected_items[5:8]}
    ...                                                                       ${message[1]}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${does_item_have_propper_value}=    Check if Item has Proper Value    ${expected_items[3]}
    ...                                                                   7 items    ${message[1]}
    Run Keyword If    ${does_item_have_propper_value} != ${True}    Fail And Log Error
    ...    msg= An item have not a proper value

Verify RRCReconfiguration Message
    [Arguments]    ${expected_items}    ${pcap_file}
    [Documentation]    The keyword gets RRCReconfiguration message and checks if expected items are in it and
    ...                are arranged in the appropriate trees
    ...                :param expected_items:        Expected items to be checked in message
    ...                :param pcap_file:        A file to look in for message

    Log Action To Console    Verify RRCReconfiguration message
    ${message}=    flow_verifier.Get Messages From The Flow    awaited_message=DLRRCMessageTransfer
    ...                                                        pcap_file=${LOG_PATH}/${pcap_file}
    Set Test Variable     ${rrc_msg}    ${message[-1]}
    ${are_items_in_message}=    Find Item in Message    RRCReconfiguration    ${rrc_msg}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= No RRCReconfiguration message

    ${are_items_in_message}=    Find Items in Message    ${expected_items}    ${rrc_msg}
    Run Keyword If    ${are_items_in_message} != ${True}    Fail And Log Error
    ...    msg= Expected items does not appear in message
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[3]}
    ...                                                                       ${expected_items[0:3]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[5]}
    ...                                                                       ${expected_items[4:5]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item

    ${is_propper_count}=    Count Appearances in Message    ${expected_items[7]}    8    ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Item does not apper propper count of times

    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[8]}
    ...                                                                       ${expected_items[9:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[9]}
    ...                                                                       ${expected_items[10:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[10]}
    ...                                                                       ${expected_items[11:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[11]}
    ...                                                                       ${expected_items[12:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[12]}
    ...                                                                       ${expected_items[13:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[13]}
    ...                                                                       ${expected_items[14:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[14]}
    ...                                                                       ${expected_items[15:16]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item

    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[15]}
    ...                                                                       ${expected_items[16:21]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[16]}
    ...                                                                       ${expected_items[17:21]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[17]}
    ...                                                                       ${expected_items[18:21]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[18]}
    ...                                                                       ${expected_items[19:21]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item
    ${is_one_item_within_other}=    Check if One Item is Within Other Item    ${expected_items[19]}
    ...                                                                       ${expected_items[20:21]}
    ...                                                                       ${rrc_msg}
    Run Keyword If    ${is_one_item_within_other} != ${True}    Fail And Log Error
    ...    msg= Child item is not in parent item

    ${does_item_have_propper_value}=    Check if Item has Proper Value    ${expected_items[4]}
    ...                                                                   8 items    ${rrc_msg}
    Run Keyword If    ${does_item_have_propper_value} != ${True}    Fail And Log Error
    ...    msg= An item have not a proper value

    ${is_propper_count}=    Count Appearances in Message    ${expected_items[20]}    8    ${rrc_msg}
    Run Keyword If    ${is_propper_count} != ${True}    Fail And Log Error
    ...    msg= Item does not apper propper count of times

Fail And Log Error
    [Arguments]   ${msg}
    [Documentation]    The keyword performs failure and logs error message.
    ...                :param msg:     message logged

    Log    message=${msg}    level=ERROR
    Fail   msg=${msg}

Start UDP DL and UL data transmission for specified time
    [Arguments]    ${dl_throughput}    ${ul_throughput}     ${data_transfer_time}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL    ${parallel_streams}=1
    [Documentation]    Keyword starts UDP DL and UL traffic transmission for specified time.
    ...                Traffic is performed in downlink and uplink directions.
    ...                :dl_throughput:    throughput in downlink direction of single stream
    ...                :ul_throughput:    throughput in uplink direction
    ...                :param data_transfer_time:    data transmission's time
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL
    ...                :parallel_streams: number of UDP streams

    Log Action To Console     Start UDP DL and UL data transmission for ${data_transfer_time}
    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=QC_MTP_SDX65
    ...                       direction=dl    duration=${data_transfer_time}    protocol=udp
    ...                       parallel_streams=${parallel_streams}    enhanced_reports=true
    ...                       throughput=${dl_throughput}    iperf_len=1320B    packet=1320B    buffer_server=16M
    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=QC_MTP_SDX65
    ...                       direction=ul    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${ul_throughput}    packet_size=1320    buffer_client=4M

Execute and Verify Large UDP DL and UL data transfer for short time
    Log Action To Console    Execute and Verify Large UDP DL and UL data transfer for short time
    Execute and Verify UDP DL and UL data transfer for specified time    dl_throughput=1000 Mbits/sec
    ...                                                                  ul_throughput=130 Mbits/sec
    ...                                                                  data_transfer_time=30s
    ...                                                                  dl_throughput_for_verify=3000 Mbits/sec
    ...                                                                  ul_throughput_for_verify=130 Mbits/sec
    ...                                                                  dl_deviation=10%
    ...                                                                  ul_deviation=20%
    ...                                                                  parallel_streams=3

Await DL and UL data transmission finish
    [Arguments]    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword awaits DL and UL data transmission.
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Await DL and UL data transmission finish
    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Await Data Transfer Finish    ${ul_dt_name}

Stop DL and UL data transmission
    [Arguments]    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword stops DL and UL data transmission.
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}

Verify UDP DL and UL data transmission
    [Arguments]    ${dl_throughput_for_verify}    ${ul_throughput_for_verify}    ${dl_deviation}    ${ul_deviation}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword checks if UDP throughput datagram loss is below max_allowed_datagram_loss.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param dl_throughput_for_verify:    tput in downlink direction for verify
    ...                :param ul_throughput_for_verify:    tput in uplink direction for verify
    ...                :param dl_deviation:   deviation of tput in downlink direction in percentage
    ...                :param ul_deviation:   deviation of tput in uplink direction in percentage
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Verify UDP DL and UL data transmission
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_throughput_for_verify}
    ...                                            deviation=${dl_deviation}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_throughput_for_verify}
    ...                                            deviation=${ul_deviation}

Execute and verify UDP DL and UL data transfer for specified time
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${data_transfer_time}    ${dl_throughput_for_verify}
    ...            ${ul_throughput_for_verify}    ${dl_deviation}    ${ul_deviation}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL    ${parallel_streams}=1
    [Documentation]    The keyword executes UDP DL and UL data transmission for a specific time and checks if throughput
    ...                datagram loss is below max_allowed_datagram_loss.
    ...                Traffic is performed in downlink and uplink directions.
    ...                :param dl_throughput:    throughput in downlink direction
    ...                :param ul_throughput:    throughput in uplink direction
    ...                :param data_transfer_time:    data transmission's time
    ...                :param dl_throughput_for_verify:    tput in downlink direction for verify
    ...                :param ul_throughput_for_verify:    tput in uplink direction for verify
    ...                :param dl_deviation:   deviation of tput in downlink direction in percentage
    ...                :param ul_deviation:   deviation of tput in uplink direction in percentage
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Start UDP DL and UL data transmission for specified time    dl_throughput=${dl_throughput}
    ...                                                         ul_throughput=${ul_throughput}
    ...                                                         data_transfer_time=${data_transfer_time}
    ...                                                         dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    ...                                                         parallel_streams=${parallel_streams}
    Await DL and UL data transmission finish                    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    Stop DL and UL data transmission                            dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    Verify UDP DL and UL data transmission                      dl_throughput_for_verify=${dl_throughput_for_verify}
    ...                                                         ul_throughput_for_verify=${ul_throughput_for_verify}
    ...                                                         dl_deviation=${dl_deviation}
    ...                                                         ul_deviation=${ul_deviation}
    ...                                                         dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log

    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Verify that legacy PM Counters were not incremented
    Log Action To Console    Verify that legacy PM Counters were not incremented
    pmcount.Wait For Next Full Pm Interval
    ${absolute_log_file}=    pmcount.Get Latest Unpacked Full Pm Counters File    output_dirpath=${LOG_PATH}/counters
    ${COUNTER_LOCALMOID}=     Set variable
    ...                  PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRDU-1
    @{42_list}=    sskpy.Get Pm Counters List    M55311C42
    pmcount.Verify If Latest Pm Counters In Counter Id List Have Exact Value   ${42_list}   0    ${counter_localmoid}    ${absolute_log_file}
    @{43_list}=    sskpy.Get Pm Counters List    M55311C43
    pmcount.Verify If Latest Pm Counters In Counter Id List Have Exact Value   ${43_list}   0    ${counter_localmoid}    ${absolute_log_file}
    @{44_list}=    sskpy.Get Pm Counters List    M55311C44
    pmcount.Verify If Latest Pm Counters In Counter Id List Have Exact Value   ${44_list}   0    ${counter_localmoid}    ${absolute_log_file}
    @{45_list}=    sskpy.Get Pm Counters List    M55311C45
    pmcount.Verify If Latest Pm Counters In Counter Id List Have Exact Value   ${45_list}   0    ${counter_localmoid}    ${absolute_log_file}
