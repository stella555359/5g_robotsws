*** Settings ***
Documentation
...   feature keywords


Library     ute_ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005934/resources/specific_keywords_5934.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot


*** Variables ***
@{COUNTERS}   M55138C03001  M55138C03002  M55139C03001  M55139C03002  M55118C09503  M55118C09502  M55118C09501  M55118C10504  M55118C10501
...           M55118C10502


*** Keywords ***
Perform SCell Swap
    [Arguments]   ${from_scell}  ${to_scell}
    logs.Start Tracing On SMOD   filename=scell_swap  smod slave=False
    Set Attenuation  20dB  ${ATTENUATOR['AHFIG_1']['ports']}  confirm=${TRUE}
    ...     attenuator_id=${ATTENUATOR['AHFIG_1']['att_id']}
    Set Attenuation  0dB  ${ATTENUATOR['AHFIG_2']['ports']}  confirm=${TRUE}
    ...     attenuator_id=${ATTENUATOR['AHFIG_2']['att_id']}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=scell_swap  offset=10s
    veify_scell_swap   pcap_file=${logs_path}  from_scell=${from_scell}  to_scell=${to_scell}


Verify test counters
    &{counters_values}=     Get Scell Add Counter Values    ${COUNTERS}
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C10501    cell_id=${pcell}    counter_dict=counters_values    operator=>=
        Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C10502    cell_id=${pcell}    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55138C03001    cell_id=${pcell}    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55138C03002    cell_id=${pcell}    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C03001    cell_id=${pcell}    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C03002    cell_id=${pcell}    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C09503    cell_id=${pcell}    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C09502    cell_id=${pcell}    counter_dict=counters_values    operator=>=
