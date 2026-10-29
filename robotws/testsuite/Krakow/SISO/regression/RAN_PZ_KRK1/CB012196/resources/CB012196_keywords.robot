*** Settings ***
Documentation
...   Resources for regression testing of feature CB012196
...   author: Marek Szłapa
...   contact: marek.szlapa@nokia.com

Library      taf.rfrl.utilities.logger.custom_logger                            WITH NAME    logger
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME    asir
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations          WITH NAME    gnbcell
Library      taf.rfrl.bts.devices.du.commissioning.EnbCommissioning             WITH NAME    enbscf
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Variables    ./cells_info.py


*** Keywords ***
Change defaultLnRelGnbCellId on eNB
    [Arguments]    ${defaultLnRelGnbCellId_value}
    enbscf.perform_configuration_parameter_recommissioning    dist_name=MRBTS-{}/LNBTS-{}/LNCEL-1
    ...                                                       parameter=defaultLnRelGnbCellId
    ...                                                       operation=update
    ...                                                       value=${defaultLnRelGnbCellId_value}

Perform NSA L3 Call on all cells
    [Arguments]    ${deviation}=40%
    FOR    ${cell}    IN    @{cells_info}
        logger.log_info_to_console  Changing lnrelgnbcell value to ${cell}[lnrelgnbcell_id]
        Change defaultLnRelGnbCellId on eNB     defaultLnRelGnbCellId_value=${cell}[lnrelgnbcell_id]
        logger.log_info_to_console  Starting call on NRCELL-${cell}[nrcell_id]
        Run Keyword And Continue On Failure     CB012196 Verify L3 Call Data Transfer DL&UL
        ...                                     protocol=tcp
        ...                                     duration=120s
        ...                                     tput_dl=${cell}[tput_dl]
        ...                                     tput_ul=${cell}[tput_ul]
        ...                                     deviation=${deviation}
        ...                                     parallel_streams_ul=${cell}[parallel_streams_ul]
        ...                                     parallel_streams_dl=${cell}[parallel_streams_dl]
    END

Reset all pRRHs via ASIRWebEM
    ${all_ants_ids}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available pRRH IDs: ${all_ants_ids}
    FOR  ${ant_id}  IN  @{all_ants_ids}
        logger.log_info_to_console      Resetting ANT ${ant_id}
        asir.reset_antenna             ant_id=${ant_id}
    END
    Wait Until Keyword Succeeds     60 sec     10 sec   gnbcell.verify_all_cells_are_onair

Block Unblock all pRRHs via ASIRWebEM
    ${all_ants_ids}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available pRRH IDs: ${all_ants_ids}
    FOR  ${ant_id}  IN  @{all_ants_ids}
        logger.log_info_to_console      Blocking ANT ${ant_id}
        asir.block_antenna              ant_id=${ant_id}
    END
    Wait for alarms
    logger.log_info_to_console  Verify statuses and alarms after blocking all antennas
    asir.verify_antennas_are_blocked    ant_ids=${all_ants_ids}
    asir.verify_alarm_is_active         fault_id=4348
    gnbalarm.verify_alarm_is_active     fault_name=Failure detected on assigned antennas    fault_id=4479
    FOR  ${ant_id}  IN  @{all_ants_ids}
        logger.log_info_to_console  Unblocking ANT ${ant_id}
        asir.unblock_antenna        ant_id=${ant_id}
    END
    Wait for alarms
    logger.log_info_to_console  Verify statuses and alarms after unblocking all antennas
    asir.verify_antennas_are_enabled       ant_ids=${all_ants_ids}
    asir.verify_alarm_is_not_active        fault_id=4348
    gnbalarm.verify_alarm_is_not_active    fault_name=Failure detected on assigned antennas    fault_id=4479
    gnbcell.verify_all_cells_are_onair

CB012196 Verify L3 Call Data Transfer DL&UL
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}    ${deviation}
    ...            ${parallel_streams_dl}    ${parallel_streams_ul}      ${alias}=UE
    [Documentation]    Attach, Data Transfer DL and UL, Verification Average Troughput and Detach
    ...     :param duration:               Duration of transmision, exaple: 600s
    ...     :param tput_dl:                Expected tput for DL, example 100 Mbits/sec
    ...     :param tput_ul:                Expected tput for UL, example 100 Mbits/sec
    ...     :param protocol:               udp or TCP
    ...     :param deviation:              Percentage of deviation in tput, example: 25%
    ...     :param paralel_streams_dl:     Number of parallel streams for DL
    ...     :param paralel_streams_ul:     Number of parallel streams for UL
    Attach with mobile data switch    ${alias}
    Start Data Transfer DL&UL and Verify Troughput    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...                                               protocol=${protocol}    deviation=${deviation}
    ...                                               parallel_streams_dl=${parallel_streams_dl}
    ...                                               parallel_streams_ul=${parallel_streams_ul}
    [Teardown]    ue.Detach UE   ${alias}

Attach with mobile data switch
    [Arguments]    ${alias}=UE
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    ue.Reboot UE    ${alias}
    ue.turn_mobile_data_off    alias=${alias}
    ue.turn_mobile_data_on    alias=${alias}

Wait for alarms
    [Arguments]    ${sleep_time}=30s
    logger.log_info_to_console  Waiting ${sleep_time} for alarms to appear
    sleep    ${sleep_time}
