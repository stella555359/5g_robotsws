*** Settings ***
Documentation
...   author: Sara Nowak, Andrzej Pencak
...   contact: sara.nowak@nokia.com, andrzej.pencak@nokia.com
...   maintainer: sara.nowak@nokia.com, andrzej.pencak@nokia.com


Library      DateTime                                                                    WITH NAME    dt
Library      taf.ue                                                                      WITH NAME    ue
Library      ta5g_pm_counters
Library      ute_fsmaccess
Library      ute_tshark
Library      taf.sbts.oam.coam.admin                                                     WITH NAME    admin
Library      taf.collectors.tcpdump                                                      WITH NAME    tcpdump

Library      taf.rfrl.utilities.logger.custom_logger                                     WITH NAME    logger
Library      taf.rfrl.ue.ute_ue_config.UteUeConfig
Library      taf.rfrl.utilities.test_config
Library      taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog                   WITH NAME    gnb_log
Library      taf.rfrl.utilities.parsers.pcap_checker                                     WITH NAME    pcap_checker

Library      ./smart_attenuator.py                                                       WITH NAME    attenuator
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.ue
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.pcap.collecting
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.commissioning
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.setups.Setups          WITH NAME    st
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.teardowns.Teardowns    WITH NAME    td

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.variables.common


*** Variables ***

${NR_CELL_4_ID}=    1263157248
${NR_CELL_12_ID}=   1263157254
${4SK10_CELL_30_ID}=   ${T09SK030_RU_DATA}[AHPE][nrCellIdentity]
${4SK10_CELL_40_ID}=   ${T09SK030_RU_DATA}[AHEH][nrCellIdentity]
${SCF_PREFIX}=      CB014359_regression

*** Keywords ***

Suite Setup
    [Documentation]    Suite setup with contains common suite setup.
    logger.Log Info To Console     Suite Setup
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Set Suite Variable    $ue_pc     ${abstract_lib_config.UE_PC}
    Common Suite Setup With OnAir Test Line Preparation
    ...    prefix_tag=${SCF_PREFIX}
    ...    should_5G_neighbour_be_changed=${True}
    ...    list_of_additional_allowed_alarms=@{ALLOWED_ALARMS}

Test Setup
    [Documentation]    Test setup with contains common test preconditions.
    ue.Require Ue         SDX_75     capabilities=REAL_UE
    Setup Attenuator
    Attenuate all ports
    Common Preconditions    verify_mandatory_scf_params=False
    Lock Radio Unit on gNB    0   3

Test Setup 4SK010
    st.run_common_preconditions
    ue.Require UE      ${MY_UE_ALIAS_UE1}    capabilities=REAL_UE
    Setup 4SK010 Attenuator
    Set MRBTS ID
    Set attenuation to AHPE area 1

Test Teardown
    [Documentation]    Test teardown with common postconditions.
    Run Keyword And Ignore Error    ue.Detach UE    SDX_75
    Run Keyword And Ignore Error    Unlock Radio Unit on gNB    0   3
    Run Keyword If    '${skip_common_steps}' != 'true'    Common Postconditions
    ...   collect_snapshot_from_ru=${False}

Test Teardown 4SK010
    [Documentation]    Test teardown with common postconditions.
    Run Keyword And Ignore Error    ue.Detach UE    ${MY_UE_ALIAS_UE1}
    Run Keyword And Ignore Error    Turn on NRDC to disable mobility
    Run Keyword And Ignore Error    gnb_log.Stop Tcpdump On SMOD    bts_id=0
    td.run_common_postconditions


Setup Attenuator
    [Documentation]    Initializes attenuator.
    logger.Log Info to Console    Setup Attenuator
    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=RADIO_RACK
    Set Suite Variable    @{GNB_2_CELL_4_RF_PORTS}    ${52}    ${120}
    Set Suite Variable    @{GNB_2_CELL_12_RF_PORTS}    ${154}    ${222}

Attenuate all ports
    [Documentation]    Initializes attenuator and turn on attenuation for all cells.
    ${ports}=    Evaluate    list(range(1, 257))
    ${values}=    Evaluate    ["64dB"] * 256
    attenuator.Set Ports Attenuation    RADIO_RACK    ${ports}    ${values}

Set cell attenuation
    [Documentation]    Set attenuation from Cell.
    [Arguments]     ${att_value}=0dB   ${RF_ports}=${GNB_2_CELL_4_RF_PORTS}
    logger.Log Info to Console    ======= Set cell attenuation to ${att_value} ========\n
    ${values}=    Create List     ${att_value}    ${att_value}
    attenuator.Set Ports Attenuation    RADIO_RACK    ${RF_ports}    ${values}

Set cell area attenuation
    [Documentation]    Set attenuation from Cell area.
    [Arguments]     ${att_value}=0dB  ${area_number}=1   ${RF_ports}=${GNB_2_CELL_4_RF_PORTS}

    logger.Log Info to Console    ======= Set cell area ${area_number} attenuation to ${att_value} ======\n
    IF    ${area_number} == 1
        ${values}=    Create List     ${att_value}    64dB
    ELSE
        ${values}=    Create List     64dB      ${att_value}
    END
    attenuator.Set Ports Attenuation    RADIO_RACK    ${RF_ports}    ${values}

Set cell attenuation to 0dB
    [Documentation]    Turn off attenuation from Cell.
    [Arguments]     ${RF_ports}=${GNB_2_CELL_4_RF_PORTS}
    Set cell attenuation    att_value=0dB    RF_ports=${RF_ports}

Set cell attenuation to 10dB
    [Documentation]    Turn off attenuation from Cell.
    [Arguments]     ${RF_ports}=${GNB_2_CELL_4_RF_PORTS}
    Set cell attenuation    att_value=10dB    RF_ports=${RF_ports}

Set cell attenuation to 20dB
    [Documentation]    Turn off attenuation from Cell.
    [Arguments]     ${RF_ports}=${GNB_2_CELL_4_RF_PORTS}
    Set cell attenuation    att_value=20dB    RF_ports=${RF_ports}

Set cell attenuation to 40dB
    [Documentation]    Turn off attenuation from Cell.
    [Arguments]     ${RF_ports}=${GNB_2_CELL_4_RF_PORTS}
    Set cell attenuation    att_value=40dB    RF_ports=${RF_ports}

Set cell area ${area_number} attenuation to 0dB
    [Documentation]    Turn off attenuation from Cell area.
    Set cell area attenuation    att_value=0dB    area_number=${area_number}    RF_ports=${GNB_2_CELL_12_RF_PORTS}

Set cell area ${area_number} attenuation to 20dB
    [Documentation]    Turn off attenuation from Cell area.
    Set cell area attenuation    att_value=20dB    area_number=${area_number}    RF_ports=${GNB_2_CELL_12_RF_PORTS}

Set cell area ${area_number} attenuation to 40dB
    [Documentation]    Turn off attenuation from Cell area.
    Set cell area attenuation    att_value=40dB    area_number=${area_number}    RF_ports=${GNB_2_CELL_12_RF_PORTS}

Attach SDX UE
    [Documentation]    The keyword perform attach
    [Arguments]    ${expected_nr_cell_id}
    ${date}=  dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_file}=  Set variable   Attach_${date}.pcap
    Start Tcpdump on gNB    ${pcap_file}
    Sleep    5s
    ue.Attach UE   SDX_75
    Sleep  5s
    Stop Tcpdump on gNB    ${pcap_file}
    Verify Attach Cell Id    pcap_filename=${pcap_file}    expected_nr_cell_id=${expected_nr_cell_id}
    logger.Log Info To Console   Verify Attach    log_hierarchy=3

Verify Attach Success Rate
    [Documentation]    The keyword perform attach in loop
    [Arguments]    ${iterations}=10    ${nr_cell_id}=${nr_cell_4_id}
    FOR    ${Index}     IN RANGE        ${iterations}
        logger.Log Info To Console    Attach UE - Iteration ${Index}    log_hierarchy=2
        Attach SDX UE    expected_nr_cell_id=${nr_cell_id}
        logger.Log Info To Console    UE attached successfully    log_hierarchy=3
        Detach SDX UE
    END

Verify Attach Cell Id
    [Arguments]    ${pcap_filename}    ${expected_nr_cell_id}
    [Documentation]    Checks ID of attached cell.
    ...                :param pcap_filename:    filename of pcap with caught messages
    ...                :param expected_nr_cell_id:    expected cell's nrcellid
    ${expected_nr_cell_id_in_hex}=    Evaluate    "{0:#0{1}x}".format(int(${expected_nr_cell_id}), 18)
    ${awaited_message}=    Catenate   SEPARATOR=
    ...                                      InitialUEMessage {
    ...                                      findBy { has(ngap.InitialUEMessage_element) }
    ...                                      verifyBy { has(ngap.NRCellIdentity:=${expected_nr_cell_id_in_hex}) }
    ...                                      }
    pcap_checker.Expect Flow    pcap_file=${LOG_PATH}/${pcap_filename}
    ...                                              display_filter=ngap
    ...                                              awaited_messages=${awaited_message}


Detach SDX UE
    [Documentation]    This keyword perform detach
    logger.Log Info to Console    Detach UE
    ue.Detach Ue    SDX_75
    Sleep  3s

Start DL and UL data transmission for specified time
    [Arguments]    ${tput_dl_min}    ${tput_ul_min}
    [Documentation]    This keyword starts UDP traffic transmision in both directions for specified time.
    ...                :param tput_ul_min:    level of minimum required throughput in uplink direction
    ...                :param tput_dl_min:    level of minimum required throughput in downlink direction
    Attach SDX UE    expected_nr_cell_id=${NR_CELL_12_ID}
    logger.Log Info to Console    Start TCP DL and UL data transmission for 60s seconds
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=SDX_75
    ...                       direction=ul       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    2s
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=SDX_75
    ...                       direction=dl       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    60s
    logger.Log Info to Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL
    logger.Log Info to Console    Verify DL and UL avg tput
    ue.Verify Average Throughput      DT_1_UL     tput_min=${tput_ul_min}    tput_max=800 Mbits/sec
    ue.Verify Average Throughput      DT_1_DL     tput_min=${tput_dl_min}    tput_max=7000 Mbits/sec
    Detach SDX UE

Wait until all cells are onair
    [Arguments]    ${waiting_time}=10min    ${checking_interval}=10s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    logger.Log Info to Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    gnbcell.Verify All Cells Are On Air    bts_id=1


Reset BBMOD and perform L3 call
    gnbbbu.Reset BBMOD    bts_id=1    bbmod_id=1
    Wait until all cells are onair
    Verify Default Allowed Alarms on GNB
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=100 Mbits/sec
    ...    tput_ul_min=30 Mbits/sec

Start Tcpdump on gNB
    [Arguments]     ${pcap_file}
    gnb_log.Start Tcpdump On SMOD   bts_id=1
    ...                             interface=any
    ...                             capture_file=${pcap_file}
    ...                             background=${True}

Stop Tcpdump on gNB
    [Arguments]     ${pcap_file}
    gnb_log.Stop Tcpdump On SMOD    bts_id=1
    ${directory}=   gnb_log.Download Tcpdump From BTS       bts_id=1
    ...                                     interface=FCT
    ...                                     log_file_name=${pcap_file}

Modify NRDC feature flag
    [Arguments]    ${value}=disabled
    ${object_dict}=    Create Dictionary    parameterName=actNrDualConnectivity
    Set To Dictionary    ${object_dict}    operation=update
    Set To Dictionary    ${object_dict}    value=${value}
    @{object_list}=    Create List    ${object_dict}
    Perform Object Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-30
    ...    parameter=@{object_list}
    ...    operation=update
    ...    timeout=300
    Perform Object Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-40
    ...    parameter=@{object_list}
    ...    operation=update
    ...    timeout=300


Turn off NRDC to enable mobility
    Modify NRDC feature flag     value=disabled

Turn on NRDC to disable mobility
    Modify NRDC feature flag     value=inter-gNB_FR1-FR2

Set MRBTS ID
    [Documentation]    This keywords reads MRBTS ID and stores it in variable
    admin.Setup admin
    ${out_mrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
    admin.Teardown admin

Setup 4SK010 Attenuator
    [Documentation]    Initializes attenuator.
    logger.Log Info to Console    Setup Attenuator
    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=RADIO_RACK
    Set Suite Variable    @{AHPE_RF_PORTS}    ${17}    ${18}
    Set Suite Variable    @{AHEH_RF_PORTS}    ${19}    ${20}

Attenuate all 4SK10 ports
    [Documentation]    Initializes attenuator and turn on attenuation for all cells.
    ${ports}=    Evaluate    list(range(1, 33))
    ${values}=    Evaluate    ["110dB"] * 32
    attenuator.Set Ports Attenuation    RADIO_RACK    ${ports}    ${values}

Set attenuation to AHPE area 1
    [Documentation]    Turn off attenuation from Cell area.
    Set cell area attenuation    att_value=0dB    area_number=1    RF_ports=@{AHPE_RF_PORTS}

Set attenuation to AHPE area 2
    [Documentation]    Turn off attenuation from Cell area.
    Set cell area attenuation    att_value=0dB    area_number=2   RF_ports=@{AHPE_RF_PORTS}

Attach 4SK010 UE
    [Documentation]    The keyword perform attach
    [Arguments]    ${expected_nr_cell_id}=${4SK10_CELL_30_ID}
    ${date}=  dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_file}=  Set variable   Attach_${date}.pcap
    Start Tcpdump on 4SK010 gNB    ${pcap_file}
    ue.Attach UE   ${MY_UE_ALIAS_UE1}
    Sleep  5s
    Stop Tcpdump on 4SK010 gNB    ${pcap_file}
    Verify UE Cell Id    ue_alias=${MY_UE_ALIAS_UE1}    expected_nrcellid=${expected_nr_cell_id}

    logger.Log Info To Console   Verify Attach    log_hierarchy=3

Trigger inter-freq HO
    [Documentation]    Trigger inter-freq HO
    [Arguments]    ${area}
    ${date}=  dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_file}=  Set variable   HO_${date}.pcap
    Start Tcpdump on 4SK010 gNB    ${pcap_file}
    Sleep    3s
    Set cell area attenuation    att_value=10dB    area_number=${area}    RF_ports=@{AHPE_RF_PORTS}
    Set cell area attenuation    att_value=0dB    area_number=${area}    RF_ports=@{AHEH_RF_PORTS}
    Stop Tcpdump on 4SK010 gNB    ${pcap_file}
    Sleep    2s
    Verify UE Cell Id    ue_alias=${MY_UE_ALIAS_UE1}    expected_nrcellid=${4SK10_CELL_40_ID}

Start Tcpdump on 4SK010 gNB
    [Arguments]     ${pcap_file}
    ${additional_options}=  Set variable  'sctp and (port 38412 or port 38472 or port 38462 or port 38422 or port 29211)'
    gnb_log.Start Tcpdump On SMOD   bts_id=0
    ...                             interface=any
    ...                             capture_file=${pcap_file}
    ...                             background=${True}
    ...                             additional_options=${additional_options}

Stop Tcpdump on 4SK010 gNB
    [Arguments]     ${pcap_file}
    gnb_log.Stop Tcpdump On SMOD    bts_id=0
    ${directory}=   gnb_log.Download Tcpdump From BTS       bts_id=0
    ...                                     interface=FCT
    ...                                     log_file_name=${pcap_file}

Verify inter-freq HO
    [Documentation]    Verify inter-freq HO counters
    ${pm_counter_file}=    	Get Next Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55147C00024   1-2    TOT_INTER_FREQ_HO_DECISION_A3
    ...    local_moid=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-30
    ...    file_path=${pm_counter_file}
    Verify Last Counters In File
    ...    M55306C09014   1-2    RA_CFRA_MSG2_SENT
    ...    local_moid=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-40
    ...    file_path=${pm_counter_file}

Start DL and UL data transmission
    [Documentation]    This keyword starts UDP traffic transmision in both directions for specified time.
    logger.Log Info to Console    Start TCP DL and UL data transmission
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=${MY_UE_ALIAS_UE1}
    ...                       direction=ul       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    2s
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=${MY_UE_ALIAS_UE1}
    ...                       direction=dl       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B

Verify DL and UL data transmission
    [Arguments]    ${tput_dl_min}=30 Mbits/sec    ${tput_ul_min}=20 Mbits/sec
    [Documentation]    This keyword verifies traffic transmision in both directions.
    ...                :param tput_ul_min:    level of minimum required throughput in uplink direction
    ...                :param tput_dl_min:    level of minimum required throughput in downlink direction
    Sleep    30s
    logger.Log Info to Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL
    logger.Log Info to Console    Verify DL and UL avg tput
    ue.Verify Average Throughput      DT_1_UL     tput_min=${tput_ul_min}    tput_max=800 Mbits/sec
    ue.Verify Average Throughput      DT_1_DL     tput_min=${tput_dl_min}    tput_max=7000 Mbits/sec
    ue.Detach UE    ${MY_UE_ALIAS_UE1}

Setup second area for attach
    Attenuate all 4SK10 ports
    Set attenuation to AHPE area 2

