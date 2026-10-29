*** Settings ***
Documentation
...   Keywords for testing of feature CB007835
...   authors: Marek Kobosko, Miroslaw Wiacek
...   contact: marek.kobosko@nokia.com, miroslaw.wiacek@nokia.com

Library    ./resources.py  WITH NAME  fetcher
Library      taf.rfrl.utilities.logger.custom_logger  WITH NAME  logger
Resource     taf/rfrl/bts/robot/common/gnb_counter.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Variables    ./variables.py

*** Keywords ***
Full counter verification GNB
    [Arguments]    ${min_endc_tput_dl_5G}    ${min_endc_tput_ul_5G}
    logger.log_info_to_console   Gather gNB counter data Uplink
    ${ul_counter_value}    fetcher.Gather Counters Gnb    ${sum_counters_ul}    ${divide_counter_ul}
    logger.log_info_to_console   Gather gNB counter data Downlink
    ${dl_counter_value}    fetcher.Gather Counters Gnb    ${sum_counters_dl}    ${divide_counter_dl}
    logger.log_info_to_console   Verify gNB counter data Uplink
    logger.log_info_to_console    ul_counter_value
    logger.log_info_to_console    ${ul_counter_value}
    Should Be True    ${ul_counter_value} >= ${min_endc_tput_ul_5G}
    logger.log_info_to_console   Verify gNB counter data Downlink
    logger.log_info_to_console    dl_counter_value
    logger.log_info_to_console    ${dl_counter_value}
    Should Be True    ${dl_counter_value} >= ${min_endc_tput_dl_5G}

Full counter verification eNB
    [Arguments]     ${divisor}    ${min_endc_tput_dl_4G}    ${min_endc_tput_ul_4G}
    logger.log_info_to_console   Gather eNB counter data Uplink
    ${ul_counter_value}    fetcher.Gather Counters Enb    ${counter_ul_enb_numerator}    ${divisor}
    logger.log_info_to_console   Gather eNB counter data Downlink
    ${dl_counter_value}    fetcher.Gather Counters Enb    ${counter_dl_enb_numerator}    ${divisor}
    logger.log_info_to_console    Verify eNB counter data Uplink
    logger.log_info_to_console    ul_counter_value
    logger.log_info_to_console    ${ul_counter_value}
    logger.log_info_to_console   Verify eNB counter data Downlink
    logger.log_info_to_console    dl_counter_value
    logger.log_info_to_console    ${dl_counter_value}
    Should Be True    ${ul_counter_value} >= ${min_endc_tput_ul_4G}
    Should Be True    ${dl_counter_value} >= ${min_endc_tput_dl_4G}

BiDir TCP throughput verification
    [Arguments]     ${tput_duration}    ${dl_tput}    ${ul_tput}    ${tput_protocol}
    REAL_UE.Prepare Ue for L3 Call      capabilities=REAL_UE
    ${CELLS_TO_LOCK}    bck.get_cell_ids_in_specific_cell_group     cell_group_id=${1}
    FOR    ${cell_id}   IN    @{CELLS_TO_LOCK}
        gnbcell.lock cell                   cell_id=${cell_id}     administrative_state=${True}
        sleep                               5
        gnbcell.verify cell is locked       cell_id=${cell_id}
    END
    sleep    60
    Wait Until Keyword Succeeds    3 times    10 minutes    REAL_UE.Verify L3 Call Data Transfer DL&UL
    ...                            duration=${tput_duration}
    ...                            tput_dl=${dl_tput}
    ...                            tput_ul=${ul_tput}
    ...                            protocol=${tput_protocol}
    ...                            linux_congestion_dl=bbr
    ...                            parallel_streams_dl=8
    ...                            parallel_streams_ul=2
    ...                            size_packet_ul=1400B
    FOR    ${cell_id}   IN    @{CELLS_TO_LOCK}
        gnbcell.unlock cell                   cell_id=${cell_id}     administrative_state=${True}
        gnbcell.verify cell is unlocked       cell_id=${cell_id}
    END
