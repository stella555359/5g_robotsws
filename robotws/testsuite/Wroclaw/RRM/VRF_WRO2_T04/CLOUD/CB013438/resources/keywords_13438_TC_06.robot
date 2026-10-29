*** Settings ***
Documentation
...   author: Mateusz Bury
...   contact: mateusz.bury@nokia.com

Library     ute_ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB013438/resources/keywords_13438_TC_06.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attach_verification.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB013438/resources/variables_13438_TC_06.py

*** Variables ***
${tput_deviation}                           30%
${tput_duration}                            3600
@{ue_list}                                  UE_1    UE_2    UE_3

*** Keywords ***
Require UEs
    FOR    ${ue}    IN    @{ue_list}
        Require Ue    ${ue}   capabilities=${ue}
    END

Attach UEs To Preferred Cell
    [Arguments]   @{ue_list}
    FOR    ${ue}    IN    @{ue_list}
        Attach Ue     ${ue}
    END

Detach UEs and stop data transfer
    Stop data transfers for all ues
    FOR    ${ue}    IN    @{ue_list}
        Detach Ue   ${ue}
    END

Start Data Transfer In Both Directions
    [Arguments]   @{ue_list}
    FOR    ${ue}    IN    @{ue_list}
        Start Data Transfer  max_segment_size=1360  dt_name=DT_DL_${ue}    ue_alias=${ue}    direction=dl
            ...                  duration=${tput_duration}s  protocol=tcp
        Start Data Transfer  max_segment_size=1360  dt_name=DT_UL_${ue}    ue_alias=${ue}    direction=ul
            ...                  duration=${tput_duration}s  protocol=tcp
    END
    ${num_of_ues}=  Get Length    ${ue_list}
    BuiltIn.Sleep   10s  wait traffic started and stabilized
    FOR    ${ue}    IN    @{ue_list}
        Check Data Transfer Is Alive   DT_DL_${ue}
        Check Data Transfer Is Alive   DT_UL_${ue}
    END
    Show Text on Console   [TCP traffic in both directions for ${num_of_ues} UEs started]


Verify Average Tput in Next Few Seconds
    [Arguments]     @{ue_list}   ${period_to_analyse}=${30}  ${stabilisation_period}=60s
    Show Text on Console   [Wait for tput verification from last ${period_to_analyse} seconds]
    BuiltIn.Sleep   ${stabilisation_period}     wait traffic stabilized on all UEs before validation
    BuiltIn.Sleep   ${period_to_analyse}
    ${total_dl_tput}   Calculate Total Tput   @{ue_list}  direction=DL  period_to_analyse=${period_to_analyse}
    ${total_ul_tput}   Calculate Total Tput   @{ue_list}  direction=UL  period_to_analyse=${period_to_analyse}
    ${ues_DL}     calculate_tput      ${ues_schedulweight}     ${total_dl_tput}
    ${ues_UL}     calculate_tput      ${ues_schedulweight}     ${total_ul_tput}
    FOR    ${ue}    IN    @{ue_list}
        Run Keyword And Continue On Failure
        ...    Verify Average Throughput With Deviation   DT_DL_${ue}  ${ues_DL}[${ue}]Mbits/sec  ${tput_deviation}  from_last=${period_to_analyse}
        Run Keyword And Continue On Failure
        ...    Verify Average Throughput With Deviation   DT_UL_${ue}  ${ues_UL}[${ue}]Mbits/sec  ${tput_deviation}  from_last=${period_to_analyse}
        Log Tput on Console   DL  ${ue}  ${ues_DL}  ${period_to_analyse}
        Log Tput on Console   UL  ${ue}  ${ues_UL}  ${period_to_analyse}
    END

Update Schedulweight for UEs
    [Arguments]   &{params_to_update}
    Set To Dictionary  ${ues_schedulweight}   &{params_to_update}
    Set Test Variable   ${ues_schedulweight}

Log Tput on Console
    [Arguments]     ${direction}  ${ue}  ${expected_values}   ${period_to_analyse}
    ${avg_tput}   Get Average Throughput   dt_name=DT_${direction}_${ue}  from_last=${period_to_analyse}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    ${diff}   Evaluate   abs((${expected_values}[${ue}] - ${avg_tput}) / ${expected_values}[${ue}] * 100)
    ${diff}   Evaluate   "%.2f" % ${diff}
    Log To Console   ${ue} ${direction} TPUT measurements: \n\ Expected: ${expected_values}[${ue}] Mbits/sec, \n\ Measured: ${avg_tput} Mbits/sec
    Log To Console   ${SPACE}Difference: ${diff}% \n

Calculate Total Tput
    [Arguments]  @{ue_list}  ${direction}  ${period_to_analyse}
    ${total_tput}   Set Variable   0
    FOR    ${ue}    IN    @{ue_list}
        ${avg_tput}   Get Average Throughput   dt_name=DT_${direction}_${ue}  from_last=${period_to_analyse}
        ${total_tput}   Evaluate   ${total_tput} + ${avg_tput}
    END
    [Return]   ${total_tput}

Set Default Values On Attenuator For 13438
    Log To Console     ${ATTENUATOR}
    Set Attenuation    127   ${ATTENUATOR['NRCELL_10']['ports']}
    Set Attenuation    127  ${ATTENUATOR['NRCELL_20']['ports']}
    Set Attenuation    127  ${ATTENUATOR['NRCELL_22']['ports']}
    Set Attenuation    127  ${ATTENUATOR['NRCELL_30']['ports']}
    Set Attenuation    10  ${ATTENUATOR['NRCELL_41']['ports']}
