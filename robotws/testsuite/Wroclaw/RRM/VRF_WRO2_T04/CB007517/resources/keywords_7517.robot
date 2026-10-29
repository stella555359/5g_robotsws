*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Library      ./specific_keywords_7517.py    WITH NAME   python_7517
Library      ../../../resources/cell_utility/cell_utility_backend.py
Library      ../../../VRF_WRO2_T07/resources/admin_api/admin_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      ute_ue
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py


*** Variables ***
${tput_deviation}             20%
@{tput_direction_list}        DL  UL
${tput_duration}              900
${WHITE}                      "\\033[7m"
${RED}                        "\\033[41m"
${num_cells}                  2

*** Keywords ***
Log Info On Console
    [Arguments]   ${info}   ${colour}=${WHITE}
    ${message}   Evaluate  ${colour} "\\n${info}\\033[0m\\n"
    Log To Console   ${message}


Choose Traffic Direction Randomly And Set Value Of Expected Tput
    [Documentation]   Set expected value of tput based on: http://5gtables.eecloud.dynamic.nsn-net.net/?tool=SCFImport
    ${direction}   Evaluate   random.choice(${tput_direction_list})  random
    Set Test Variable   ${direction}
    ${tput}  Set Variable If  '${direction}' == 'DL'  1200Mbits/sec  128Mbits/sec
    Set Test Variable   ${tput}
    ${log_text}  Set Variable If  '${direction}' == 'DL'   Downlink  Uplink
    Log Info On Console   [${log_text} TCP traffic will be checked during test, ${tput}]


Configure A4 Measurement Parameters
    ${a4MeasMaxNumber}  ${a4RetryTimer}  ${log_collecting_time}   Set Random Parameters In WebUI
    Set Test Variable   ${a4MeasMaxNumber}
    Set Test Variable   ${a4RetryTimer}
    Set Test Variable   ${log_collecting_time}


Attach UE And Verify A4 Measurements After Attach
    [Arguments]   ${ue_alias}
    Initialise Attenuator
    Set Attenuation  0dB  confirm=${TRUE}
    Set Attenuation  90dB  ${ATTENUATOR['LNCELL_11']['ports']}  confirm=${TRUE}     # lte serving cell hardcoded - att port crashed
    Require Ue    ${ue_alias}  capabilities=${ue_alias}
    # UE Rebooting  ${ue_alias}
    Log Info On Console   [UE attaching and verifying A4 Measurements after attach in progress...]
    Set Test Variable  ${log_index}  _check_pci
    Start Tracing On SMOD   smod slave=False
    Attach Ue     ${ue_alias}
    Wait For All A4Measurements Messages
    ${log_path}   Stop Tracing And Download Logs From SMOD
    ${cells}   Verify 5G NSA Attach   ue_alias=${ue_alias}  pcap_file=${log_path}
    Set Test Variable   ${current_lte_pci}   ${lte_pci}
    Run Keyword And Continue On Failure   Verify A4 Measurements   pcap_file=${log_path}
    Run Keyword And Continue On Failure   Verify A4 Meas Max Number
    ...   pcap_file=${log_path}  no_cells=${num_cells}  a4_meas_max_number=${a4MeasMaxNumber}


Wait For All A4Measurements Messages
    BuiltIn.Sleep   ${log_collecting_time}s   Calculated time: a4MeasMaxNumber x a4RetryTimer + offset (2x a4RetryTimer)


Start Traffic In Chosen Direction
    [Arguments]   ${ue_alias}
    ${tput_start_time}   Get Time  epoch
    Set Test Variable   ${tput_start_time}
    Start Data Transfer  dt_name=DT_DATA  ue_alias=${ue_alias}  direction=${direction}  duration=${tput_duration}s
    ...                  protocol=tcp  buffer=32M  max_segment_size=1450  parallel=2
    Log Info On Console   [${direction.upper()} TCP traffic started]
    BuiltIn.Sleep   10s  wait traffic started
    Check Data Transfer Is Alive   DT_DATA


Check New LTE Cell
    ${cells}   Verify 5G NSA Attach   ue_alias=${ue_alias}  show_on_console=False
    Set Test Variable   ${new_lte_pci}   ${lte_pci}
    Should Not Be Equal   ${current_lte_pci}  ${new_lte_pci}    There was not MeNB HO precedure
    Log To Console   \n LTE HO done successfully, new LTE PCI=${new_lte_pci}


Attenuate Active LTE Cell
    [Arguments]   ${pci}
    Set Attenuation  0dB  confirm=${TRUE}
    Set Attenuation  90dB  ${ATTENUATOR['LNCELL_${pci}']['ports']}  confirm=${TRUE}
    BuiltIn.Sleep   5s   wait for new LTE cell HO


Clear Attenuation For LTE Cells
    Set Attenuation  0dB  ${ATTENUATOR['LNCELL_11']['ports']}  confirm=${TRUE}
    Set Attenuation  0dB  ${ATTENUATOR['LNCELL_12']['ports']}  confirm=${TRUE}


Verify Average Tput in Given Period
    [Arguments]   ${expected_tput}
    Log Info On Console   [Tput verifying in progress...]
    Check Data Transfer Is Alive   DT_DATA
    ${tput_time_point}   Get Time  epoch
    ${omit}   Evaluate   ${tput_time_point} - ${tput_start_time}
    BuiltIn.Sleep   60s  run traffic few second before verification
    Run Keyword And Continue On Failure
    ...    Verify Average Throughput With Deviation   DT_DATA  ${expected_tput}  ${tput_deviation}  omit=${omit}

    ${avg_tput}   Get Average Throughput   dt_name=DT_DATA   omit=${omit}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    Log To Console   \n Tput measurements: \n\ Expected: ${expected_tput}, \n\ Measured: ${avg_tput}Mbits/sec
