*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Library     ute_ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB013438/CB013438_REAL_UE/resources/keywords_13438.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attach_verification.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py


*** Variables ***
${serving_cell}                             410
@{ue_list}                                  UE_1   UE_3   UE_4
&{ues_schedulweight}                        UE_1=${20}   UE_3=${10}   UE_4=${0}
&{ues_fiveqi}                               UE_1=7    UE_3=9    UE_4=6
@{tput_directions}                          DL  UL


*** Keywords ***
Require UEs
    FOR    ${ue}    IN    @{ue_list}
        Require Ue    ${ue}   capabilities=${ue}
    END


Attach UEs To Preferred Cell
    [Arguments]   @{ue_list}
    FOR    ${ue}    IN    @{ue_list}
        Attach Ue     ${ue}
        Verify 5G SA Attach   ${ue}
        Log to console   ${SPACE} schedulweight set to: ${ues_schedulweight}[${ue}] for 5QI: ${ues_fiveqi}[${ue}]
    END


Detach UEs and stop data transfer
    Stop data transfers for all ues
    FOR    ${ue}    IN    @{ue_list}
        Detach Ue   ${ue}
    END


Verify Average Tput in Next Few Seconds
    [Arguments]     @{ue_list}   ${period_to_analyse}=${30}  ${stabilisation_period}=10s
    Show Text on Console   [Wait for tput verification from last ${period_to_analyse} seconds]
    BuiltIn.Sleep   ${stabilisation_period}      wait traffic stabilized on all UEs before validation
    BuiltIn.Sleep   ${period_to_analyse}
    &{ues_avg_tputs}   Create Dictionary
    Set Test Variable   ${ues_avg_tputs}
    ${total_dl_tput}   ${total_ul_tput}    Calculate Total Tput   @{ue_list}  period_to_analyse=${period_to_analyse}
    ${ues_DL}     calculate_tput      ${ues_schedulweight}     ${total_dl_tput}
    ${ues_UL}     calculate_tput      ${ues_schedulweight}     ${total_ul_tput}
    FOR   ${ue}   IN   @{ue_list}
        Log Tput on Console   DL  ${ue}  ${ues_DL}
        Log Tput on Console   UL  ${ue}  ${ues_UL}
    END


Calculate Total Tput
    [Arguments]  @{ue_list}  ${period_to_analyse}
    FOR   ${dir}   IN   @{tput_directions}
        Set Test Variable   ${${dir}_tput}   0
        ${sum_tput}   Set Variable   0
        FOR   ${ue}   IN   @{ue_list}
            ${avg_tput}   Get Average Throughput   dt_name=DT_${dir}_${ue}  from_last=${period_to_analyse}
            ${avg_tput}   Evaluate   ${avg_tput} / 1000
            ${avg_tput}   Evaluate   "%.1f" % ${avg_tput}
            Set To Dictionary   ${ues_avg_tputs}   ${dir}_${ue}=${avg_tput}
            ${sum_tput}   Evaluate   ${sum_tput} + ${avg_tput}
        END
        Set Test Variable   ${${dir}_tput}   ${sum_tput}
    END
    [Return]   ${dl_tput}   ${ul_tput}


Log Tput on Console
    [Arguments]     ${direction}  ${ue}  ${expected_values}
    ${tput_deviation}   Set Variable If   ${ues_avg_tputs}[${direction}_${ue}] > 150   10  20
    ${diff}   Evaluate   abs((${expected_values}[${ue}] - ${ues_avg_tputs}[${direction}_${ue}]) / ${expected_values}[${ue}] * 100)
    ${diff}   Evaluate   "%.1f" % ${diff}
    ${notification}   Set Variable If  ${diff} < ${tput_deviation}  OK  NOK
    Log To Console   ${ue} ${direction} TPUT measurements: \n Expected: ${expected_values}[${ue}] Mbits/sec,
    Log To Console   ${SPACE}Measured: ${ues_avg_tputs}[${direction}_${ue}] Mbits/sec,
    Log To Console   ${SPACE}Difference ${notification}: ${diff}% \n
    Run Keyword And Continue On Failure
    ...   Should Be True   ${diff} < ${tput_deviation}   For ${ue} ${direction} tput difference ${diff}% is bigger than accepted ${tput_deviation}%


Update Schedulweight for UEs
    [Arguments]   &{params_to_update}
    Set To Dictionary  ${ues_schedulweight}   &{params_to_update}
    Set Test Variable   ${ues_schedulweight}
