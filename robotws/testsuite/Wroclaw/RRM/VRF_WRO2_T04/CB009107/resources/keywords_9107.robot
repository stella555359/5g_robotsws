*** Settings ***
Documentation
...   feature keywords

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py

*** Keywords ***
Attach UE To Cell
    [Arguments]    ${ue}    ${cell}
    ${random_filename_suffix}    	Generate Random String    8
    ${pcap_file}=   Start Listening Tcpdump From Smod    filepath=attach_${random_filename_suffix}.pcap
    Require Ue If Not Reserved    ${ue}
    ute_ue.Attach UE    ${ue}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  ute_ue.Log UE Info  ${ue}  IP
    Stop Listening Tcpdump From Smod
    Check Cell And Signal Strength For Ue    ${ue}
    Verify Cell Id    ${ue}    expected_cell_id=${cell}
    [Return]    ${pcap_file}
    [Teardown]    Run Keywords    Set Test Variable    ${${ue}_reserved}    ${True}    AND
    ...    Stop Pcap Collection


Attenuate All Cells Except Supercell NR Sector 1
    keywords.Attenuate All Cells    ${1}
    keywords.Attenuate All Cells    ${2}
    attenuator_keywords.Set Attenuation  0  ${ATTENUATOR['NRCELL_2']['ports']['S1']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_2']['att_id']}

Attenuate All Cells Except Supercell NR Sector 2
    keywords.Attenuate All Cells    ${1}
    keywords.Attenuate All Cells    ${2}
    attenuator_keywords.Set Attenuation  0  ${ATTENUATOR['NRCELL_2']['ports']['S2']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_2']['att_id']}

Attenuate All Cells Except Supercell LTE Sector 1
    keywords.Attenuate All Cells    ${1}
    keywords.Attenuate All Cells    ${2}
    attenuator_keywords.Set Attenuation  0  ${ATTENUATOR['NRCELL_15']['ports']['S1']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_15']['att_id']}

Attenuate All Cells Except Supercell LTE Sector 2
    keywords.Attenuate All Cells    ${1}
    keywords.Attenuate All Cells    ${2}
    attenuator_keywords.Set Attenuation  0  ${ATTENUATOR['NRCELL_15']['ports']['S2']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_15']['att_id']}

Verify Cell Id
    [Arguments]    ${ue_alias}    ${expected_cell_id}
    ${CELL_INFO}   Get UE Info   ${ue_alias}  CELL_INFO
    Log To Console    ${CELL_INFO}
    Should be true   ${CELL_INFO}[pci] == ${expected_cell_id}

Switch Ue Mode To LTE
    [Arguments]    ${ue}
    Log To Console    Switching UE: ${ue} network mode to LTE
    Attach Ue   ${ue}    validation=${FALSE}
    Change Network Mode    ${ue}    LTE
    Detach Ue    ${ue}

Switch Ue Mode To NR
    [Arguments]    ${ue}
    Log To Console    Switching UE: ${ue} network mode to NR
    Attach Ue   ${ue}    validation=${FALSE}
    Change Network Mode    ${ue}    NR only
    Detach Ue    ${ue}

Switch Ue Mode To NR LTE
    [Arguments]    ${ue}
    Log To Console    Switching UE: ${ue} network mode to NR/LTE
    Attach Ue   ${ue}    validation=${FALSE}
    Change Network Mode    ${ue}    NR/LTE
    Detach Ue    ${ue}

Start Verification Supercell
    [Arguments]    ${ue}    ${cell}    ${sector}    ${dst_sector}
    Attach UE To Cell    ${ue}    ${cell}
    Tcpdump.Start Tcpdump On Smod    filename=pcap_${cell}_${sector}_${dst_sector}.pcap
#    Start Voice Call    vc_alias=call_1    ue_alias=${ue}    to=0105    duration=250s
    Start DL Traffic For Ue    ${ue}    dl_tput=30Mbits/sec    duration=100s
    Start UL Traffic For Ue    ${ue}    ul_tput=10Mbits/sec    duration=100s

    Trigger Ue Transfer Between Sectors   cell=${cell}    src_sector=${sector}    dst_sector=${dst_sector}    att_value=0
    ...    att_id=${ATTENUATOR['NRCELL_2']['att_id']}
    BuiltIn.Sleep    20
    Verify DL Tput For Ue    ${ue}
    Verify UL Tput For Ue    ${ue}
#    Await voice Call Finish    call_1
    BuiltIn.Sleep    10
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
#    Run Keyword If   ${cell} == 5   Assert Vonr Call Started With Qos 1    ${pcap_file}    occurrence=1
    [Teardown]    Run Keywords    Detach Ue    ${ue}    AND
    ...    Stop Pcap Collection



