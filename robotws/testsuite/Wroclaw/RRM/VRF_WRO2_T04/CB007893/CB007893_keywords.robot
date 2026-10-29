*** Settings ***
Documentation
...  author: Pawel Zabawczuk
...  contact: pawel.k.zabawczuk@nokia.com

Library         ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library         ./CB007893_python_functions.py
Resource        ../resources/attach_verification.robot
Resource        ../../resources/preconditions.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py

*** Variables ***
${threshold_th2a_for_rsrp_cell_51}     -83
@{cell_list}   51  12

*** Keywords ***
Check Signal Strength For 4G Cells Used In Test
    [Arguments]   ${ue}=UE_1
    Set Test Variable   ${ue}  UE_1
    Initialise Attenuator
    Set Attenuation  0  confirm=${TRUE}
    Require Ue   ${ue}   capabilities=${ue}
    Attach Ue    ${ue}
    Change Network Mode   ${ue}  LTE
    FOR  ${cell}  IN  @{cell_list}
        Check Signal Strength For 4G Cell   attenuator_cell=${cell}   pci=${cell}
    END
    Log To Console   \n Signal strength for 4G cells: \n ${SPACE} pci=51, rsrp: ${rsrp_lte_cell_51} \n ${SPACE} pci=12, rsrp: ${rsrp_lte_cell_12}
    [Teardown]   Run Keywords
    ...    Change Network Mode   ${ue}  NR/LTE      AND
    ...    Detach Ue   ue_alias=${ue}               AND
    ...    Set Attenuation  90  confirm=${TRUE}


Check Signal Strength For 4G Cell
    [Arguments]   ${attenuator_cell}   ${pci}
    Set Attenuation  90  confirm=${TRUE}
    Set Attenuation  0  ${ATTENUATOR['LNCELL_${attenuator_cell}']['ports']}  confirm=${TRUE}
    Wait Until Keyword Succeeds   120s   10   Check 4G cell   ${pci}


Check 4G cell
    [Arguments]   ${pci}
    ${cell_info}   Get UE Info   ${ue}  CELL_INFO
    Should Be Equal As Strings   ${pci}    ${cell_info}[pci]
    Set Test Variable   ${rsrp_lte_cell_${pci}}   ${cell_info}[rsrp]


Clear Attenuation For Cell 4G Pci ${pci}
    Set Attenuation  0  ${ATTENUATOR['LNCELL_${pci}']['ports']}  confirm=${TRUE}


Clear Attenuation For Cell 5G Pci ${pci}
    Set Attenuation  0  ${ATTENUATOR['NRCELL_${pci}']['ports']}  confirm=${TRUE}


Set Attenuation For 4G Cell Pci 51 Below Threshold Tha2 For RSRP
    [Arguments]   ${required_rsrp_cell_51}=-90
    Set Test Variable   ${required_rsrp_cell_51}
    ${att_cell_51}   Evaluate   ${rsrp_lte_cell_51} - ${required_rsrp_cell_51}
    Set Attenuation  ${att_cell_51}  ${ATTENUATOR['LNCELL_51']['ports']}  confirm=${TRUE}


Set Attenuation For 4G Cell Pci 12 Witn RSRP Lower Than Cell Pci 51
    ${att_cell_12}   Evaluate   ${rsrp_lte_cell_12} - ${required_rsrp_cell_51} + 10
    Set Attenuation  ${att_cell_12}  ${ATTENUATOR['LNCELL_12']['ports']}  confirm=${TRUE}


Perform Data Transfer
    [Arguments]   ${tput}  ${protocol}=udp  ${duration}=300
    ${tput_udp_kwargs_dict}  Create Dictionary  throughput=${tput}Mbits/sec  packet_size=1400
    ${tput_tcp_kwargs_dict}  Create Dictionary  packet_size=10k  max_segment_size=1400
    ${dt_kwargs}  Set Variable If  '${protocol.lower()}' == 'udp'  ${tput_udp_kwargs_dict}  ${tput_tcp_kwargs_dict}

    Start Data Transfer  dt_name=DT_DL  ue_alias=${ue}  direction=DL
    ...                  duration=${duration}s  buffer=8M  protocol=${protocol}  &{dt_kwargs}

    Log To Console       \n DL ${protocol.upper()} traffic ${tput}Mbit/s for ${ue} started, duration ${duration} seconds
    BuiltIn.Sleep   10s   Time to run traffic
    Check Data Transfer Is Alive   DT_DL


Check If Traffic Is Still Running
    BuiltIn.Sleep   60s   Run traffic some seconds before verification
    Check Data Transfer Is Alive   DT_DL


Check Average Tput
    [Arguments]   ${start_time}=0   ${stop_time}=0
    ${omit}   Evaluate   ${stop_time} - ${start_time}
    ${avg_tput}   Get Average Throughput   dt_name=DT_DL   omit=${omit}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    Log To Console   \n AVERAGE DL TPUT: ${avg_tput} Mbit/s \n
