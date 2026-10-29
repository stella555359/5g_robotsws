*** Settings ***
Documentation   Keywords for UUF4ALL

Library        ../../regression/python_functions.py
Library        ./python_l3_call.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library        taf.ue
Library        ute_ue
Library        DateTime
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/utilities.py    WITH NAME  utilities
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/variables.py
Resource       ../../regression/regression_keywords.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/variables.py

*** Variables ***
${tput_deviation}         20%
${tput_duration}          30s
${ue_alias}               UE_1
${call_type}              SA
${exp_tput}               10Mbits/sec
${L3_CALL}         ${VARIABLE['L3_CALL']}
${L3_CALL_CELLS}    ${VARIABLE['L3_CALL_CELLS']}
${TPUT_SRC}    ${VARIABLE['L3_CALL_TPUT_SRC']}

*** Keywords ***
Prepare Testline to onAir if Needed
    [Arguments]    ${custom_swconfig_flags}=${None}
    ${tl_state}    check_tl_reservation_state
    Run Keyword If   '${tl_state}' == 'sw_uploaded'
    ...    Prepare Testline To OnAir State    scf_tag=SCF_DEFAULT    custom_swconfig_flags=${custom_swconfig_flags}
    Run Keyword If   '${tl_state}' == 'on_air'
    ...    Run Keyword And Ignore Error   Start and Initialize Attenuator


Set Airplane Mode for All UEs
    ${ue_number}   get_ue_number
    Set UTE Library For UE If Needed
    FOR  ${ue}  IN RANGE  ${ue_number}
        Run Keyword And Continue On Failure   Run Keywords
        ...    Require Ue If Not Reserved    UE_${ue+1}   scope=suite    AND
        ...    Detach Ue   UE_${ue+1}
    END

Set L3 Call To Execution
    [Documentation]   Set 'attach_test_keyword' variable depending on TL readiness to make a call
    ${reserved}    Is Ue Reserved    ${ue_alias}
    Run Keyword If   ${L3_CALL}   Run Keywords
    ...    Log To Console   \n\nL3 CALL will be done in each loop for randomly choosen affected cell\n    AND
    ...    Set Test Variable   ${L3_call_keyword}   L3 Call                                               AND
    ...    Initialise Attenuator                                                                          AND
    ...    Set UTE Library For UE If Needed                                                               AND
    ...    Require Ue If Not Reserved    ${ue_alias}    scope=suite


L3 Call
    [Arguments]   ${dependent_cells}
    ${time}   Get Current Date   result_format=%H:%M:%S
    ${pci}   Get Affected Cells And Choose Randomly One   ${dependent_cells}    ${L3_CALL_CELLS}
    Require Ue If Not Reserved    ${ue_alias}    scope=suite
    Return From Keyword If  ${pci} == ${None}    ${None}
    Log To Console   \n***** L3 CALL STARTED *****\n
    Log To Console   [ INFO ] ${time} - pci=${pci} will be used in L3 Call\n
    Attenuate All Cells Except One   ${pci}
    Attach UE To Given Cell   call_type=${call_type}
    Start Traffic And Verify It
    Log To Console   ***** L3 CALL FINISHED *****\n
    [Teardown]   Run Keywords
    ...     Detach Ue    ue_alias=${ue_alias}     AND
    ...     Set Attenuation  0dB  confirm=${TRUE}


Attenuate All Cells Except One
    [Arguments]   ${pci}
    Set Attenuation  90dB  confirm=${TRUE}
    Set Attenuation  0dB  ${ATTENUATOR['NRCELL_${pci}']['ports']}  confirm=${TRUE}


Attach UE To Given Cell
    [Arguments]   ${call_type}
    #Start Tracing On SMOD
    Attach Ue     ${ue_alias}
    #${logs path}   Stop Tracing And Download Logs From SMOD
    Run Keyword If   '${call_type}' == 'SA'
    ...     Verify 5G SA Attach
    Run Keyword If   '${call_type}' == 'NSA'
    ...     Verify 5G NSA Attach   #pcap_file=${logs path}


Start Traffic And Verify It
    [Arguments]   ${expected_tput}=${exp_tput}
    Start Data Transfer  dt_name=DT_DATA  ue_alias=${ue_alias}  direction=DL  duration=${tput_duration}
    ...                  protocol=udp  throughput=${exp_tput}  packet_size=1300
    ${time}   Get Current Date   result_format=%H:%M:%S
    Log To Console   [ INFO ] ${time} - DL UDP traffic started, duration: ${tput_duration}
    BuiltIn.Sleep   10s  wait traffic started
    Check Data Transfer Is Alive   DT_DATA
    Await Data Transfer Finish    DT_DATA
    ${avg_tput}   Get Average Throughput   dt_name=DT_DATA  tput_collection_src=${TPUT_SRC}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    ${time}   Get Current Date   result_format=%H:%M:%S
    Log To Console   \n[ INFO ] ${time} - AVERAGE DL TPUT: ${avg_tput} Mbit/s \n
    Run Keyword And Continue On Failure
    ...    Verify Average Throughput With Deviation   DT_DATA  ${expected_tput}  ${tput_deviation}  tput_collection_src=${TPUT_SRC}
