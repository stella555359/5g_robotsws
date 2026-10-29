*** Settings ***
Documentation
...   Keywords for testing of feature CB007835
...   authors: Marek Kobosko, Miroslaw Wiacek
...   contact: marek.kobosko@nokia.com, miroslaw.wiacek@nokia.com

Library    ./resources.py  WITH NAME  fetcher
Library      taf.rfrl.utilities.logger.custom_logger  WITH NAME  logger
Resource     taf/rfrl/bts/robot/common/gnb_counter.robot
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

