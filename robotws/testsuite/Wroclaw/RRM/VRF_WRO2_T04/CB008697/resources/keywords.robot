*** Settings ***
Documentation
...   feature keywords

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008697/resources/keywords.py
Library    testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library    ute_ue
Resource   testsuite/Wroclaw/RRM/resources/connections.robot
Resource   testsuite/Wroclaw/RRM/resources/preconditions.robot

*** Keywords ***
Verify CA status
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap
    Verify CA      ${log_path}   2

Verify Overheating Assistance in F1AP messages when ON
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap
    ...            ${OAI}=UEAssistanceInformation
    ...            ${expected_CCsDL}=0
    ...            ${expected_CCsUL}=1
    verify OAI in nrrrc messages    ${log_path}    ${OAI}    ${expected_CCsDL}    ${expected_CCsUL}

Verify Overheating Assistance in F1AP messages when OFF
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap
    ...            ${OAI}=overheatingAssistance
    verify OAI in nrrrc messages    ${log_path}    ${OAI}

Prepare TL for Overheating Assistance
    [Arguments]     ${cell_250_value}=10  ${cell_251_value}=15  ${cell_252_value}=29    ${cell_255_value}=15
    Initialise Attenuator
    Set Attenuation   ${cell_250_value}   confirm=${TRUE}  port=${ATTENUATOR['NRCELL_1_2']['ports']}
    ...               attenuator_id=${ATTENUATOR['NRCELL_1_2']['att_id']}
    Set Attenuation   ${cell_251_value}   confirm=${TRUE}  port=${ATTENUATOR['NRCELL_1_1']['ports']}
    ...               attenuator_id=${ATTENUATOR['NRCELL_1_1']['att_id']}
    Set Attenuation   ${cell_252_value}    confirm=${TRUE}  port=${ATTENUATOR['NRCELL_1_3']['ports']}
    ...               attenuator_id=${ATTENUATOR['NRCELL_1_3']['att_id']}
    Set Attenuation   ${cell_255_value}    confirm=${TRUE}  port=${ATTENUATOR['NRCELL_1_6']['ports']}
    ...               attenuator_id=${ATTENUATOR['NRCELL_1_6']['att_id']}

trigger Overheating Assistance command from UE
    [Documentation]   AT+EGMC=1,"NR_OVERHEATING",1,1,2,,,,,1,1,,,
    [Arguments]
    ...    ${on_off}=${1}    ${DL}=${0}
    Overheating    alias=MediaTekUe
    ...    oh_op=${on_off}
    ...    cc_dl=${DL}
    ...    cc_ul=${1}
    ...    bw_fr1_dl=${None}
    ...    bw_fr1_ul=${None}
    ...    bw_fr2_dl=${None}
    ...    bw_fr2_ul=${None}
    ...    mimo_fr1_dl=${1}
    ...    mimo_fr2_dl=${1}
    ...    mimo_fr1_ul=${None}
    ...    mimo_fr2_ul=${None}

Start CA full Buffer DL Traffic
    [Arguments]     ${dt_name}=DL_3CC    ${tput}=900Mbits/sec   ${UE_NAME}=MediaTekUe
    Run Keyword And Continue On Failure    ute_ue.Start Data Transfer
    ...    ${dt_name}    ${UE_NAME}    direction=dl    duration=60s    throughput=${tput}    protocol=udp
    BuiltIn.Sleep    10     time to run traffic
    Check Data Transfer Is Alive       ${dt_name}
    Await Data Transfer Finish         ${dt_name}
    ${avg_tput}=    ute_ue.Get Average Throughput    ${dt_name}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.0f" % ${avg_tput}
    Log To Console   \n AVERAGE DL TPUT: ${avg_tput} Mbit/s \n
    [Return]    ${avg_tput}

Compare with expected traffic
    [Arguments]   ${avg_tput}    ${expected_tput}    ${deviation}=20%
    Run Keyword And Continue On Failure    verify if average throughput with deviation reached
    ...    ${deviation}    ${expected_tput}    ${avg_tput}
