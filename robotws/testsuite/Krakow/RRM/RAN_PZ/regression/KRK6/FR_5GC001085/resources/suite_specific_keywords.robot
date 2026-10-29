*** Settings ***
Documentation
...  author:  Andrzej Pencak, Olga Urbanska
...  contact: andrzej.pencak@nokia.com, olga.urbanska@nokia.com

Library  DateTime                                                                                WITH NAME    dt
Library  OperatingSystem                                                                         WITH NAME    os
Library  String                                                                                  WITH NAME    str
Library  taf.ue                                                                                  WITH NAME    ue
Library  testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_5GC001085/resources/smart_attenuator.py  WITH NAME    attenuator
Library  testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py                WITH NAME    fv
Library   taf.rfrl.ue.logs.qxdm_logs.QxdmLogsCollector                                           WITH NAME    QxdmLC
Library   taf.rfrl.utilities.test_config.DefaultFileLocation                                     WITH NAME    dfl
Library   taf.rfrl.ue.logs.qxdm_logs.LicenseKeeperKeywords                                       WITH NAME    LkKeywords
Library  taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                               WITH NAME    gnbcell
Library  taf/rfrl/procedures/resources/python/sleeping_cell_detector.py                          WITH NAME    scd
Library  testsuite.Krakow.RRM.RAN_PZ.resources.pm_counter_du.PmCounterDu
Library  taf.rfrl.bts.commissioning
Library  testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_5GC001085/resources/suite_specific_keywords.py

Resource  taf/rfrl/bts/robot/gnb.robot
Resource  taf/rfrl/common_resources/common_step/interface.robot
Resource  testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource  testsuite/Krakow/RRM/RAN_PZ/resources/resources.robot
Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}    7311
#7311 - No Xn link available
*** Keywords ***

Suite Setup
    [documentation]    Initializes the test suite by preparing the testline, setting cell IDs, and defining suite-level
    ...                variables for RF port assignments and attenuation values.
    Common Suite Setup With OnAir Test Line Preparation
    ...                 prefix_tag=5GC001085_C02
    ...                 should_5G_neighbour_be_changed=${True}
    ...                 list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    Set cells IDs
    Set Suite Variable    @{GNB_1_CELL_1_RF_PORTS}         ${1}    ${2}
    Set Suite Variable    @{GNB_1_CELL_2_RF_PORTS}         ${3}    ${4}
    Set Suite Variable    ${attenuation_for_serving}       5dB
    Set Suite Variable    ${attenuation_for_neighbors}     15dB
    Set Suite Variable    ${fading_step}                   1dB
    Set Suite Variable    ${attenuation_interval}          1s

Test Setup
    [documentation]    This keyword prepares environment befor each test case.
    Log Action To Console    Start test
    Perform Full Commissioning on Classical gNB
    ...    prefix_tag=5GC001085_C02
    Run Keyword And Ignore Error    scd.Enable Sleeping Cell Detection Feature
    scd.Start Sleeping Cell Detection Watchdog For All Bts       log_dir=${LOG_PATH}/SleepingCell
    Wait Until Keyword Succeeds    600      20    gnbcell.block_cell    bts_id=0      cell_id=1    du_id=0
    Wait Until Keyword Succeeds    600      20    gnbcell.block_cell    bts_id=1      cell_id=1    du_id=0
    Download gNB Configuration File
    ...    local_dir=${OUTPUT DIR}
    ...    filename=scfc_gnb0_before_test.xml
    ...    gnb_id=0
    ...    du_id=0
    Upload QxdmLogCatch Script
    ue.Require Ue    UE_1  capabilities=REAL_ANDROID_UE
    Connect to license keeper client    lkc_path='C:/auto/QPM_LK3.1.2'
    Get qxdm and qcat licence
    Kill all Qxdm processes
    Clear Log Directory
    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=RADIO_RACK_01

Test Teardown
    [arguments]    ${clear_gnb0}=${False}
    [documentation]    This keyword clears environment after each test case.
    ...                :param clear_gnb0:    the flag causes the cleaning of gNB0
    Log Action To Console    End test
    Run keyword if     ${clear_gnb0}  Download gNB Configuration File
    ...    local_dir=${OUTPUT DIR}
    ...    filename=scfc_gnb0_after_test.xml
    ...    gnb_id=0
    ...    du_id=0
    Run Keyword And Ignore Error    ue.Detach Ue    UE_1
    Release qxdm and qcat licence
    scd.Verify Sleeping Cell Detection
    gnbcell.unblock_cell    bts_id=0      cell_id=1    du_id=0
    gnbcell.unblock_cell    bts_id=1      cell_id=1    du_id=0
    Wait for Cell To Be Onair    bts_id=0      cell_id=1    du_id=0
    Wait for Cell To Be Onair    bts_id=1      cell_id=1    du_id=0
    ${ports}=     Combine Lists   ${GNB_1_CELL_1_RF_PORTS}   ${GNB_1_CELL_2_RF_PORTS}
    ${values}=    Create List     110dB    110dB    110dB    110dB
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${ports}    ${values}
    Common Postconditions

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Detach UE
    [documentation]    Detaches the specified User Equipment (UE).
    Log Action To Console    Detach UE
    ue.Detach Ue    UE_1

Set cells IDs
    [documentation]    Retrieves and sets suite variables for the physical and NR cell IDs of gNB1's cell 1 and cell 2,
    ...                failing if fewer than two cells are present.
    Log Action To Console    Set cells IDs
    ${number_of_cells}=    gnbcell.Get Number Of Cells    bts_id=0    du_id=0
    Run Keyword If    ${number_of_cells} < 2    Fail    "Insufficient number of cells in gNB 1"
    ${gnb1_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${0}    du_id=0
    ${gnb1_cell2_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${2}    du_id=0
    Set Suite Variable    ${gnb1_cell1_id}      ${gnb1_cell1_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell1_nrid}    ${gnb1_cell1_parameters['nrCellIdentity']}
    Set Suite Variable    ${gnb1_cell2_id}      ${gnb1_cell2_parameters['physCellId']}

Attach 5G UE to gNB1 cell1 and collect logs
    [documentation]    Configures attenuators, starts network traffic capture (Tcpdump), collects Qxdm logs,
    ...                attaches the UE to gNB1 cell1, and verifies the attachment.
    Log Action To Console    Attach 5G UE to gNB1 cell1
    ${ports}=     Combine Lists   ${GNB_1_CELL_1_RF_PORTS}    ${GNB_1_CELL_2_RF_PORTS}
    ${values}=    Create List     ${attenuation_for_serving}   ${attenuation_for_serving}     110dB    110dB
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${ports}    ${values}
    Sleep    5s
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    UE_attach_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    Collect Qxdm Hdf Log    duration=120
    Sleep    20s
    ue.Attach Ue    UE_1
    Sleep    3s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Verify Attach Cell Id    pcap_filename=${pcap_name}    expected_nr_cell_id=${gnb1_cell1_nrid}

Set consecRecheckForNrNbRemoval to 2 parameter on gNB1
    [documentation]    Configures the consecRecheckForNrNbRemoval parameter to 2 on gNB1.
    Log Action To Console    Set consecRecheckForNrNbRemoval to 2 parameter on gNB1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRANRPR-1
    ...    param_name=consecRecheckForNrNbRemoval    param_value=2
    ...    skip_parameter_relation_errors=false    timeout=120

Set idleTimeForNrNbRemoval to 2 parameter on gNB1
    [documentation]    Configures the idleTimeForNrNbRemoval parameter to 2 on gNB1.
    Log Action To Console    Set idleTimeForNrNbRemoval to 2 parameter on gNB1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRANRPR-1
    ...    param_name=idleTimeForNrNbRemoval    param_value=2
    ...    skip_parameter_relation_errors=false    timeout=120

Set reportAmountSA to r1 parameter on gNB1 cell1
    [documentation]    Configures the reportAmountSA parameter to r1 for gNB1 cell1.
    Log Action To Console    Set reportAmountSA to r1 parameter on gNB1 cell1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-0
    ...    param_name=reportAmountSA    param_value=r1
    ...    skip_parameter_relation_errors=false    timeout=120

Set reportAmountSA to r4 parameter on gNB1 cell1
    [documentation]    Configures the reportAmountSA parameter to r4 for gNB1 cell1.
    Log Action To Console    Set reportAmountSA to r4 parameter on gNB1 cell1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-0
    ...    param_name=reportAmountSA    param_value=r4
    ...    skip_parameter_relation_errors=false    timeout=120

Set actAutoNrNbRemoval to false on gNB1
    [documentation]    Configures a parameter, actAutoNrNbRemoval,
    ...                to false on gNB1 by performing a recommissioning action.
    Log Action to Console    Set actAutoNrNbRemoval to false on gNB1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRANR-1
    ...    param_name=actAutoNrNbRemoval    param_value=false
    ...    skip_parameter_relation_errors=false    timeout=120

Trigger Handover from gNB1 cell1 to gNB1 cell2
    [documentation]    Performs an intra-gNB handover from gNB1 cell1 to gNB1 cell2 by manipulating RF attenuation
    ...                and verifying the handover through QXDM logs.
    Log Action To Console    Perform handover from gNB1 cell1 to gNB1 cell2
    attenuator.execute_fading_scenario    RADIO_RACK_01
    ...                                   source_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                                   target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                                   fading_step=${fading_step}
    ...                                   fading_interval=${attenuation_interval}
    ...                                   fading_min=${attenuation_for_serving}
    ...                                   fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt
    Sleep    5s
    Download Qxdm Logs
    Check Ue Handover    ${gnb1_cell2_id}

Trigger Handover from gNB1 cell2 to gNB1 cell1
    [documentation]    Triggers a handover from gNB1 cell2 to gNB1 cell1 by manipulating attenuation,
    ...                collects Qxdm logs, and verifies the UE's handover.
    Log Action To Console    Perform handover from gNB1 cell2 to gNB1 cell1
    Kill all Qxdm processes
    Clear Log Directory
    Collect Qxdm Hdf Log    duration=50
    attenuator.execute_fading_scenario    RADIO_RACK_01
    ...                                   source_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                                   target_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                                   fading_step=${fading_step}
    ...                                   fading_interval=${attenuation_interval}
    ...                                   fading_min=${attenuation_for_serving}
    ...                                   fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt
    Sleep    5s
    Download Qxdm Logs
    Check Ue Handover    ${gnb1_cell1_id}

Check if relations appered under both cells
    [documentation]    Waits for a specified duration and then verifies the existence of `NRREL` objects for both local
    ...                cell ID 2 and local cell ID 0 under the gNB.
    Log Action To Console    Wait for Relations to appear in WebEM
    Sleep    30s
    Check If any Object Contains Specified Parameters    object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=2
    Sleep    40s
    Check If any Object Contains Specified Parameters    object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=0

Change parameter maxNumOfRrc to 0 on gNB1 cell2
    [documentation]    Sets the `maxNumOfRrcSA` parameter on gNB1 cell 2 to 0 via configuration recommissioning.
    Log Action To Console    Change parameter maxNumOfRrc to 0 on gNB1 cell2
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-2
    ...    param_name=maxNumOfRrcSA    param_value=0
    ...    skip_parameter_relation_errors=true    timeout=300

Perform few consecutive unsuccessful Handovers from gNB1 cell1 to gNB1 cell2 and check that NRREL was removed
    [documentation]    Executes four consecutive unsuccessful handovers from gNB1 cell1 to gNB1 cell2,
    ...                then verifies that only one NRREL exists and that the relation under cell2 was not removed.
    Repeat Keyword    4 times    Perform unsuccessful handover from gNB1 cell1 to gNB1 cell2
    Sleep  120s  reason=wait for relation to be removed
    Check Only One Relation Existence
    Check if relation under cell2 wasn't removed

Perform unsuccessful handover from gNB1 cell1 to gNB1 cell2
    [documentation]    Simulates an unsuccessful handover by executing fading scenarios between two cells
    ...                using an attenuator, checks UE measurements, and reattaches the UE.
    Log Action To Console    Perform unsuccessful handover from gNB1 cell1 to gNB1 cell2
    attenuator.execute_fading_scenario    RADIO_RACK_01
    ...                                   source_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                                   target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                                   fading_step=${fading_step}
    ...                                   fading_interval=${attenuation_interval}
    ...                                   fading_min=${attenuation_for_serving}
    ...                                   fading_max=${attenuation_for_neighbors}
    attenuator.execute_fading_scenario    RADIO_RACK_01
    ...                                   source_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                                   target_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                                   fading_step=${fading_step}
    ...                                   fading_interval=${attenuation_interval}
    ...                                   fading_min=${attenuation_for_serving}
    ...                                   fading_max=${attenuation_for_neighbors}
    Run Keyword and Ignore Error    Check Ue Measurements    cell_id=${gnb1_cell2_id}
    Reattach UE to gNB1 cell1

Change parameter on gNB1 cell2 maxNumOfRrc back to 250
    [documentation]    Changes the `maxNumOfRrcSA` parameter on gNB1 cell 2 back to 250 via recommissioning
    ...                and verifies UE attachment to the expected cell.
    Log Action To Console    Change maxNumOfRrc on gNB1 Cell2 back to 250
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-2
    ...    param_name=maxNumOfRrcSA    param_value=250
    ...    skip_parameter_relation_errors=true    timeout=300

Try to trigger successful Handover from gNB1 cell1 to gNB1 cell2
    [documentation]    Initiates a successful handover from gNB1 cell1 to gNB1 cell2 by adjusting attenuation,
    ...                collects Qxdm logs, and verifies the UE's handover.
    Log Action To Console    Trigger successful handover from gNB1 cell1 to gNB1 cell2 after NRREL delition
        attenuator.execute_fading_scenario    RADIO_RACK_01
    ...                                       source_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                                       target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                                       fading_step=${fading_step}
    ...                                       fading_interval=${attenuation_interval}
    ...                                       fading_min=${attenuation_for_serving}
    ...                                       fading_max=${attenuation_for_neighbors}
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt
    Sleep    5s
    Download Qxdm Logs
    Check Ue Handover    ${gnb1_cell2_id}

Fail And Log Error
    [Arguments]    ${msg}
    [documentation]   :param msg: message logged
    Log     message=${msg}   level=ERROR
    Fail    msg=${msg}

Check Ue Handover
    [arguments]    ${cell_id}
    [documentation]    This keyword checks if handover procedure has been successful.
    ...                :param cell_id:    target cell ID during handover procedure
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M_%S
    Verify Handover Succeeded in RRC Messages    file_path=${OUTPUT_DIR}/qxdm.txt    target_cell_pci=${cell_id}

Check Ue Measurements
    [arguments]    ${cell_id}
    [documentation]    This keyword checks if measurement messages have been sent.
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M_%S
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt
    Sleep    5s
    Download Qxdm Logs
    Verify PCI in Measurement Reports    file_path=${OUTPUT_DIR}/qxdm.txt    expected_pci=${cell_id}


Check Ue Measurements And ANR DRX Profile Reconfiguration During Handover
    [arguments]    ${cell_id}
    [documentation]    This keyword checks if measurement messages have been sent and whether handover procedure
    ...                has been successful. Additionally during handover it checks if Drx Release and Drx
    ...                Profile Configuration occured in RRC messages.
    ...                :param cell_id:    target cell ID during handover procedure
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M_%S
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt
    Sleep    5s
    Download Qxdm Logs
    Verify CGI Request with Drx Release and ANR Drx Profile Configuration Occured in RRC Messages
    ...    file_path=${OUTPUT_DIR}/qxdm.txt
    ...    target_cell_pci=${cell_id}
    Verify CGI Info and Handover Succeeded in RRC Messages
    ...    file_path=${OUTPUT_DIR}/qxdm.txt
    ...    target_cell_pci=${cell_id}

Verify Attach Cell Id
    [arguments]    ${pcap_filename}    ${expected_nr_cell_id}
    [documentation]    This keyword checks ID of attached cell.
    ...                :param pcap_filename:    filename of pcap with caught messages
    ...                :param expected_nr_cell_id:    expected cell's nrcellid
    ${hex_expected_nr_cell_id}=    Get Nr Cell Id In Hex    ${expected_nr_cell_id}
    ${message_found}=    fv.Check If Message Is In Flow
    ...    awaited_message=UplinkNASTransport(contains(*nRCellIdentity=${hex_expected_nr_cell_id}))
    ...    pcap_file=${OUTPUT_DIR}/${pcap_filename}
    Run Keyword If    ${message_found} == ${False}    Fail    msg=Ue did not attach to expected cell.

Check Only One Relation Existence
    [documentation]    Verifies that exactly one `NRREL` object exists in the gNB configuration.
    ${number_of_nrrels_1}=     Get Number Of Objects In Scf    object_type=NRREL
    Should Be Equal As Integers    ${number_of_nrrels_1}     1

Check if relation under cell2 wasn't removed
    [documentation]    Confirms that an `NRREL` object with specific gNB ID and local cell ID (0) still exists.
    Check If any Object Contains Specified Parameters    object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=0

Check if relation to gNB1 cell2 appeared
    [documentation]    Waits for a specified duration and then verifies the existence of an `NRREL` object
    ...                with specific gNB ID and local cell ID (2).
    Log Action to Console    Wait for Relations to appear in WebEM
    Sleep    90s
    Check If any Object Contains Specified Parameters    object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=2

Reattach UE to gNB1 cell1
    [documentation]    Detaches the UE, clears logs, kills Qxdm processes, and then re-attaches the UE to gNB1 cell1.
    ue.Detach Ue    UE_1
    Sleep  3s
    Kill all Qxdm processes
    Clear Log Directory
    Attach 5G UE to gNB1 cell1 and collect logs

Perform handover from gNB1 cell1 to gNB1 cell2 With DRX Profile Reconfiguration
    Log Action to Console    Perform handover from gNB1 cell1 to gNB1 cell2 With DRX Profile Reconfiguration
    Check If There Are No Objects In Scf    object_type=NRREL
    attenuator.execute_fading_scenario    RADIO_RACK_01
    ...                                   source_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                                   target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                                   fading_step=${fading_step}
    ...                                   fading_interval=${attenuation_interval}
    ...                                   fading_min=${attenuation_for_serving}
    ...                                   fading_max=${attenuation_for_neighbors}
    Sleep    5s
    Check Ue Measurements And ANR DRX Profile Reconfiguration During Handover    cell_id=${gnb1_cell2_id}
    Sleep    60s
    Check If any Object Contains Specified Parameters    object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=2
