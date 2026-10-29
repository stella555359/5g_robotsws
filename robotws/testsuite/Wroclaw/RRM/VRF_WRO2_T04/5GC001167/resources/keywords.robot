*** Settings ***
Documentation
...   feature keywords

Library       ute_admin
Library       ute_ue
Library       SSHLibrary
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library       ../../../resources/etws_cmas/counters.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      ./delta_keywords.py
Library      ./pcap_verifiers.py
Library      ./dss_params.py
Library       ta5g_cell_operations
Library      ./keywords_1167.py    WITH NAME    python_1167
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables    ./ca_variables.py

*** Variables ***
${CONNECTION ALIAS}
&{COUNTERS_H}
&{COUNTERS_L}
${MAX_UL_TPUT}=     40Mbits/sec
${CA_UE}=     UE_1
${NON_CA_UE}=     UE_2
${PCELL_106}    106
${SCELL_100}    100
${SCELL_101}    101

*** Keywords ***
Attach UE To Pcell And Scell
    [Arguments]    ${ue}    ${num_of_scells}=1    ${alias}=attach    ${vonr}=${FALSE}    ${scells_id}=${EMPTY}
    Tcpdump.Start Tcpdump On Smod    filename=attach_${alias}.pcap
    Require Ue If Not Reserved    ${ue}
    ute_ue.Attach UE    ${ue}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  ute_ue.Log UE Info  ${ue}  IP
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    Check Cell And Signal Strength For Ue    ${ue}
    Ue Attached To Pcell And Scells    ${pcap_file}    ${num_of_scells}    ${scells_id}    vonr=${vonr}
    [Return]    ${pcap_file}
    [Teardown]    Run Keywords    Tcpdump.teardown_tcpdump_on_smod    AND
    ...    Set Test Variable    ${${ue}_reserved}    ${True}

Preconditions To Counter Test
    [Arguments]    ${dict_name}    ${num_of_scells}=1
    Set Initial Attenuation For Test
    Return From Keyword If    &{${dict_name}}
    Run Keyword If    not '${num_of_scells}' == '2'    Remove Scell Addition Method    106    101

Postconditions To Counter Test
    ${reserved}    Is Ue Reserved    ${CA_UE}

Attach Ue and Collect Counters
    [Arguments]    ${counter_list}=${C_H}    ${dict_name}=COUNTERS_H    ${num_of_scells}=1
    ...    ${tput_duration}=60s    ${scells_id}=${EMPTY}
    Preconditions To Counter Test    ${dict_name}    ${num_of_scells}
    Return From Keyword If    &{${dict_name}}
    counters.Wait For Pm Counters Interval
    Attach UE To Pcell And Scell    ${CA_UE}    ${num_of_scells}    alias=attach_${dict_name}_scells_${num_of_scells}
    ...    scells_id=${scells_id}
    tcpdump.Start Tcpdump On Smod    filename=traffic_start_${dict_name}_scells_${num_of_scells}.pcap
    Start DL Traffic For Ue    ${CA_UE}    800Mbits/sec    duration=${tput_duration}
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    &{counters_values}=     Get Scell Add Counter Values    ${counter_list}
    Set Suite Variable   &{${dict_name}}    &{counters_values}
    [Return]    &{${dict_name}}

Set Initial Attenuation 2 cells
    Attenuate All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_1']['attenuation']}  ${ATTENUATOR['NRCELL_1']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_2']['attenuation']}  ${ATTENUATOR['NRCELL_2']['ports']}  confirm=${TRUE}

Set Initial Attenuation 3 cells
    Attenuate All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_1']['attenuation']}  ${ATTENUATOR['NRCELL_1']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_2']['attenuation']}  ${ATTENUATOR['NRCELL_2']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_3']['attenuation']}  ${ATTENUATOR['NRCELL_3']['ports']}  confirm=${TRUE}

Attenuate All Cells
    [Arguments]    ${att_id}=${NONE}
    attenuator_keywords.Initialise Attenuator
    attenuator_keywords.Set Attenuation  90dB  confirm=${TRUE}    attenuator_id=${att_id}

Set Attenuation For Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=90dB    ${att_id}=${NONE}
    attenuator_keywords.Initialise Attenuator
    attenuator_keywords.Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}
    ...    attenuator_id=${att_id}

Gradually Increase Attenuation For Scell
    [Arguments]    ${cell_id}    ${init_value}=0    ${max_value}=90
    Initialise Attenuator
    Gradually Increase Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=6    interval=1
    ...    init_value=${init_value}
    ...    max_value=${max_value}

Gradually Decrease Attenuation For Scell
    [Arguments]    ${cell_id}    ${init_value}=90    ${min_value}=0
    Initialise Attenuator
    Gradually Decrease Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=6    interval=1
    ...    init_value=${init_value}
    ...    min_value=${min_value}

Clear Attenuation
    Set Attenuation  0dB  confirm=${TRUE}

Restore Ues To First Cell
    Perform HO Procedure    2
    Perform HO Procedure    3
    BuiltIn.Sleep    20    Wait For Ho


Configure Scell Activation Method To
    [Documentation]    Possible methods:
    ...    blind
    ...    bufferBased
    ...	   bufferAndRLQualityBased
    [Arguments]    ${method}
    Update Parameter     param=sCellActivationMethod    value=${method}

Restore Default Scell Activation Method
    Update Parameter     param=sCellActivationMethod    value=blind

Start DL Traffic For Ue
    [Arguments]    ${ue}=UE_1    ${dl_tput}=44Mbits/sec    ${duration}=60s    ${protocol}=udp    ${dt}=default    ${wait}=${TRUE}
    Start Data Transfer  DT_${ue}_${dt}  ${ue}  dl  duration=${duration}  packet_size=1300  throughput=${dl_tput}
    ...    protocol=${protocol}
    Set Test Variable   ${expected_dl_tput_${ue}}    ${dl_tput}
    Run Keyword If    ${wait}    BuiltIn.Sleep    15    ${\n}Wait for DL tput start
    Log To Console    ${\n}Tput started: DT_${ue}_${dt}  ${dl_tput}  duration: ${duration}${\n}

Start UL Traffic For Ue
    [Arguments]    ${ue}=UE_1    ${ul_tput}=${MAX_UL_TPUT}    ${duration}=60s    ${protocol}=udp    ${dt}=defaultul    ${wait}=${TRUE}
    Start Data Transfer  DT_${ue}_${dt}  ${ue}  ul  duration=${duration}  packet_size=1300  throughput=${ul_tput}
    ...    protocol=${protocol}
    Set Test Variable   ${expected_ul_tput_${ue}}    ${ul_tput}
    Run Keyword If    ${wait}    BuiltIn.Sleep    15    ${\n}Wait for UL tput start
    Log To Console    ${\n}Tput started: DT_${ue}_${dt}  ${ul_tput}  duration: ${duration}${\n}

Verify DL Tput For Ue
    [Arguments]    ${ue}=UE_1    ${expected_tput}=${None}    ${threshold}=10%    ${dt}=default      ${src}=control_app
    Log To Console    ${\n}Checking DL tput for UE: ${ue}...
    ${tput}=    Set Variable If    '${expected_tput}' is '${None}'
    ...    ${expected_dl_tput_${ue}}
    ...    ${expected_tput}
    Run Keyword And Continue On Failure    Await Data Transfer Finish  DT_${ue}_${dt}
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation  DT_${ue}_${dt}  ${tput}  ${threshold}
    ...     tput_collection_src=${src}

Verify UL Tput For Ue
    [Arguments]    ${ue}=UE_1    ${expected_tput}=${None}    ${threshold}=10%    ${dt}=defaultul      ${src}=control_app
    Log To Console    ${\n}Checking UL tput for UE: ${ue}...
    ${tput}=    Set Variable If    '${expected_tput}' is '${None}'
    ...    ${expected_ul_tput_${ue}}
    ...    ${expected_tput}
    Run Keyword And Continue On Failure    Await Data Transfer Finish  DT_${ue}_${dt}
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation  DT_${ue}_${dt}  ${tput}  ${threshold}
    ...     tput_collection_src=${src}


Set Initial Number Scells To Activate
    [Arguments]    ${pcell_id}    ${num_of_scells}
    Update Parameter     param=iniNumSCellsToActivate    value=${num_of_scells}
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${pcell_id}

Activate VoNR
    Update Parameter     param=actEnhancedVoNR    value=true

Activate DSS
    [Arguments]    ${min_nr_dss_ratio}=65    ${max_nr_dss_ratio}=70    ${lte_bandwith}=${None}
    Activate DSS On LTE Side    min_dss_ratio=${min_nr_dss_ratio}    max_dss_ratio=${max_nr_dss_ratio}    lte_bandwith=${lte_bandwith}
    Activate DSS On 5G Side    min_dss_ratio=${min_nr_dss_ratio}    max_dss_ratio=${max_nr_dss_ratio}
    Wait For All Cells On Air State    timeout=160
    BuiltIn.Sleep    100    Wait For RMODs to be fully operational
    Log To Console    DSS activated!

Deactivate DSS
    [Arguments]    ${min_nr_dss_ratio}=65    ${max_nr_dss_ratio}=70
    Deactivate DSS On 5G Side    ${min_nr_dss_ratio}    ${max_nr_dss_ratio}
    Deactivate DSS On LTE Side    ${min_nr_dss_ratio}    ${max_nr_dss_ratio}
    Wait for all cells on air state
    Log To Console    DSS deactivated!

Perform HO Procedure
    [Arguments]  ${pcell_id}
    Gradually Increase Attenuation For Scell    cell_id=${pcell_id}
    ...    init_value=${ATTENUATOR['NRCELL_${pcell_id}']['attenuation']}    max_value=90
    BuiltIn.Sleep    15    Wait for HO

Format Attenuation Value
    [Arguments]  ${value}
    @{words}=  Split String  ${value}  d
    [Return]  ${words[-1]}

Set Max Number Of Scell Alloc For Cell
    [Arguments]    ${cell_id}    ${max_num}
    Update Parameter    param=maxNumOfSCellAlloc    value=${max_num}    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Restore Default Max Number Of Scell Alloc
    [Arguments]    ${cell_id}
    Update Parameter    param=maxNumOfSCellAlloc    value=250    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Set Max Number Of Rrc For Cell
    [Arguments]    ${cell_id}    ${max_num}
    Update Parameter    param=maxNumOfRrcSA    value=${max_num}    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Restore Default Max Number Of Rrc
    [Arguments]    ${cell_id}
    Update Parameter    param=maxNumOfRrcSA    value=275    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Configure Scell Deactivation Timer To
    [Arguments]    ${value}
    Update Parameter    param=sCellDeactivationTimerGNB    value=${value}
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${PCELL_ID}
    Update Parameter    param=sCellDeactivationTimerGNB    value=${value}
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${SCELL_ID}
    Update Parameter    param=sCellDeactivationTimerGNB    value=${value}
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${SECOND_SCELL_ID}

Restore Scell Deactivation Timer To Infinity
    Configure Scell Deactivation Timer To   infinity

Activate Graceful Shutdown
    Update Parameter     param=actGrflShdn    value=true

Deactivate Graceful Shutdown
    Update Parameter     param=actGrflShdn    value=false

Lock Cell With Id
    [Arguments]    ${cell_id}
    Lock Single Cell    cell_id=${cell_id}
    Check Cell Is Locked    cell_id=${cell_id}

Unlock Cell With Id
    [Arguments]    ${cell_id}
    Unlock Single Cell    cell_id=${cell_id}
    Check Cell Is Not Locked    cell_id=${cell_id}

Detach Ue If Needed
    [Arguments]    ${ue}=${CA_UE}
    ${reserved}    Is Ue Reserved    ${ue}
    Run Keyword If    ${reserved}    Detach Ue     ${ue}

Activate A1 Pcell Switch
    [Arguments]    ${src_cell}    ${nrhoif_id}
    Update Parameter    param=a1BasedPCellSwitchEnabled    value=true
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${src_cell}/NRHOIF-${nrhoif_id}

Deactivate A1 Pcell Switch
    [Arguments]    ${src_cell}    ${nrhoif_id}
    Update Parameter    param=a1BasedPCellSwitchEnabled    value=false
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${src_cell}/NRHOIF-${nrhoif_id}
