*** Settings ***
Library    ../../outsides/resources_570/webUI_operations.py
Library    ta5g_admin_operations
Library    ta5g_commissioning
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    ./keywords_1118.py
Library    ./mcs/mcs_parsing.py
Library    robot.libraries.DateTime
Library    taf.ue  WITH NAME  ue
Resource   ../../outsides/resources_1118/attach_verification.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Variables  ./att_port_mapping.py


*** Variables ***
&{ue_rnti_dict}
${TPUT_DL}  100 Mbits/sec
${TPUT_UL}  60 Mbits/sec
${GN_OAM_ADDR}            ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${server_port_ul_1}       ${tl.ues[0].iperf_details.ports[0]}
${server_port_ul_2}       ${tl.ues[0].iperf_details.ports[1]}

*** Keywords ***
1118 Test Teardown
    Set Servedamf State  Unlocked
    ue.Stop Data Transfers For All UEs
    Clear Attenuation If Initialised
    Run keyword and ignore error    keywords_1118.Detach UEs

Attach UEs
    [Arguments]  ${nr_only}=${FALSE}

    FOR  ${ue}  IN  @{UE_NAMES}
        ue.Require UE  ${ue}  ${ue}

        Run Keyword If  ${nr_only}
        ...        ue.Change Network Mode   ${ue}   NR_only
        ...  ELSE  ue.Change Network Mode   ${ue}   NR  LTE

        ue.Attach UE  ${ue}
    END

Attach NSA UE
    [Arguments]  ${UE_id}
    run keyword and ignore error    Do Attach UE   ${UE_id}

Attach SA UE
    [Arguments]  ${UE_id}
    ue.Change Network Mode   ${UE_id}   NR_only
    ue.Attach UE  ${UE_id}

_Attach NSA UE Succeed
    [Arguments]  ${UE_id}
    ${check}   Run Keyword And Continue On Failure   Verify 5G NSA Attach   ${UE_id}
    Should contain   ${check}[1]   CONNECTED


Do Attach UE
    [Arguments]  ${ue_id}
    ue.Attach UE  ${ue_id}
    sleep  30s
    ${status}=    Run Keyword And Return Status
    ...    _UE Attached Successfully  ${ue_id}
    #Run Keyword Unless   ${status}      ue.Detach Ue   ${ue_id}
    Should Be Equal   ${status}   ${True}  ${ue_id} not attached

Samsung UE Attach
    [Arguments]  ${UE_id}  ${nr_only}=${FALSE}
    ue.Require UE  ${UE_id}  ${UE_id}
    Run Keyword If  ${nr_only}
    ...        Attach SA UE   ${UE_id}
    ...  ELSE  Attach NSA UE   ${UE_id}

UE Attach And Verification
    [Arguments]   ${ue_alias}
    Attach Ue   ${ue_alias}
    Sleep   5s  wait for cell setup
    ${CELL_INFO}   Get UE Info   ${ue_alias}  CELL_INFO
    Should Be Equal   ${CELL_INFO}[isCellRegistered]  ${True}  ${ue_alias} not attached to any cell
    Log To Console   ${ue_alias} attached successfully after reboot in ${kw_runs+1}. attempt
    [Teardown]   Run Keywords
    ...    Detach Ue   ${ue_alias}    AND
    ...    Set Test Variable   ${kw_runs}   ${kw_runs+1}

_UE Attached Successfully
    [Arguments]  ${UE_id}
    ${status}=    Run Keyword And Return Status
    ...    _Attach NSA UE Succeed   ${UE_id}
    run keyword if  not ${status}   Verify 4G Attach   ${UE_id}

UE Rebooting
    [Arguments]   @{ue_aliases_list}
    FOR  ${ue_alias}  IN  @{ue_aliases_list}
        Reboot Ue   ${ue_alias}  180
        Log To Console   ${ue_alias} rebooted successfully
        Set Test Variable   ${kw_runs}   ${0}
        Wait Until Keyword Succeeds  3x  10s
        ...   UE Attach And Verification  ${ue_alias}
    END

Detach UEs
    FOR  ${ue}  IN  @{UE_NAMES}
        ue.Detach Ue  ${ue}
    END

Assert MCS Is In Range
    [Arguments]  ${lower_bound}  ${upper_bound}  ${frames}

    ${mcs_average}=    mcs_parsing.Get Mcs Average    ${frames}
    Should Be True   ${lower_bound} <= ${mcs_average} <= ${upper_bound}

Assert MCS Table Is
    [Arguments]  ${mcs_table_expected}  ${frames}

    ${mcs_table}=    mcs_parsing.Get Mcs Table    ${frames}
    Should Be Equal  ${mcs_table}  ${mcs_table_expected}

Assert Avg Tput 6 Percent Higher For 256QAM
    [Arguments]  ${dt_1}  ${dt_2}  ${dt_1_time}  ${dt_2_time}
    ue.Await Data Transfer Finish  DT_UL_2
    ue.Stop Data Transfers For All UEs

    ${tput_time_diff}=  Subtract Date From Date  ${dt_2_time}  ${dt_1_time}
    ${tput_time_diff_trunk}    Evaluate     ${tput_time_diff}-${50}
    ${tput_time_diff}    Set Variable If   '${release_sbts}'=='SBTS22R3'    ${tput_time_diff}      ${tput_time_diff_trunk}

    ${tput_64}  ue.Get Average Throughput  dt_name=DT_UL_1  omit=${tput_time_diff}
    ${tput_256}  ue.Get Average Throughput  dt_name=DT_UL_2
    Log to console  Tput for UE1: ${tput_64}
    Log to console  Tput for UE2: ${tput_256}
    Should Be True  ${tput_256} > 1.06 * ${tput_64}

Assert Tput Equal For actUlDftSOfdm
    [Arguments]  ${dt_1}  ${dt_2}
    ue.Await Data Transfer Finish  DT_UL_1
    ${tput_1}  ue.Get Average Throughput  dt_name=DT_UL_1
    ue.Await Data Transfer Finish  DT_UL_2
    ${tput_2}  ue.Get Average Throughput  dt_name=DT_UL_2
    Log to console  Tput for UE1: ${tput_1}
    Log to console  Tput for UE2: ${tput_2}
    Should Be True  ${tput_1}==${tput_2}

Start Traffic
    [Arguments]  ${dt_label}  ${ue_label}  ${direction}  ${protocol}  ${duration}  ${port}=${server_port_ul_1}

    ${tput}=  Set Variable If
    ...  '${direction}'=='ul'
    ...  ${TPUT_UL}
    ...  ${TPUT_DL}
    ${tput_udp_kwargs_dict}  Create Dictionary  throughput=${tput}Mbits/sec  packet_size=1400  buffer=35M
    ${tput_tcp_kwargs_dict}  Create Dictionary  buffer=5M  max_segment_size=1400  packet_size=10k
    ${dt_kwargs}  Set Variable If  '${protocol.lower()}' == 'udp'
    ...  ${tput_udp_kwargs_dict}
    ...  ${tput_tcp_kwargs_dict}

    Should Be True  ${duration} > 15
    ue.Start Data Transfer  ${dt_label}  ${ue_label}  ${direction}
    ...  duration=${duration}s  protocol=${protocol}  &{dt_kwargs}  port=${port}
    Sleep  15  reason=Wait for tput stabilization

256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put
    [Arguments]  ${nr_only}=${FALSE}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts_tmp}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Set Suite Variable      ${release_sbts}          ${release_sbts_tmp}
    Run keyword If  '${release_sbts}'=='SBTS22R3'   256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put for 22R3  nr_only=${nr_only}
    ...    ELSE       256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put for Trunk    nr_only=${nr_only}


256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put for Trunk
    [Arguments]  ${nr_only}=${FALSE}
    [Documentation]  Attaches the UE_1 and UE_2 in 64QAM. Starts data transfer for UE_1.
    ...              Then, changes modulation to 256QAM. Waits for UE_2 to get to Idle state.
    ...              Then, Starts data transfer for UE_2.
    ...              Modulation used for UE_1 should remain 64QAM in the whole process.
    ...              Modulation used for UE_2 should be 256QAM.
    ...              Moreover, the tput should be about 6% higher in 256QAM.
    ...              Tput gain is calculated using time window with both UE's throughput active.

    keywords_1118.Start Traffic  DT_UL_1  UE_1  ul  tcp  310  ${server_port_ul_1}
    ${tput_1_time}=  Get Current Date
    #Start gnbMirroring  capturing_time_seconds=3    bb_slots=5
    Start to collect bip log new    nr_phy_cell_ids=208,207
    Sleep  3  reason=Wait for log collection
    #${ue_1}=  Stop gnbMirroring And Gather L1L2 Logs  filename=${TEST_NAME}_ue_1.pcap
    CreateDirectory       /home/ute/tmp
    Stop to collect bip log new     target_dir=/home/ute/tmp
    ${bip_files1}     Get BIP File List    log_path=/home/ute/tmp/l1l2bip

    Set Ul 256QAM Activation State For All Cells  true
    Samsung UE Attach  UE_2  nr_only=${nr_only}
    Sleep  30  reason=Wait for UE2 to get to Idle state

    # Duration of this transfer must be same as for DT_UL_1 for correct tput calculation
    #keywords_1118.Start Traffic  DT_UL_2  UE_2  ul  tcp  100  ${server_port_ul_2}
    keywords_1118.Start Traffic  DT_UL_2  UE_2  ul  tcp  200  ${server_port_ul_2}
    ${tput_2_time}=  Get Current Date
    #Start gnbMirroring  capturing_time_seconds=3    bb_slots=5
    Start to collect bip log new    nr_phy_cell_ids=208,207
    Sleep  3  reason=Wait for log collection
    #${both_ues}=  Stop gnbMirroring And Gather L1L2 Logs  filename=${TEST_NAME}_both_ues.pcap
    CreateDirectory       /home/ute/tmp2
    Stop to collect bip log new     target_dir=/home/ute/tmp2

    Assert Avg Tput 6 Percent Higher For 256QAM  DT_UL_1  DT_UL_2  ${tput_1_time}  ${tput_2_time}
    ${bip_files2}     Get BIP File List    log_path=/home/ute/tmp2/l1l2bip     mergecap_wait=30s
    #Verify BIP Logs For Activation Test  ${ue_1}  ${both_ues}
    Verify BIP Logs For Activation Test  ${bip_files1}  ${bip_files2}


256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put for 22R3
    [Arguments]  ${nr_only}=${FALSE}
    [Documentation]  Attaches the UE_1 and UE_2 in 64QAM. Starts data transfer for UE_1.
    ...              Then, changes modulation to 256QAM. Waits for UE_2 to get to Idle state.
    ...              Then, Starts data transfer for UE_2.
    ...              Modulation used for UE_1 should remain 64QAM in the whole process.
    ...              Modulation used for UE_2 should be 256QAM.
    ...              Moreover, the tput should be about 6% higher in 256QAM.
    ...              Tput gain is calculated using time window with both UE's throughput active.

    keywords_1118.Start Traffic  DT_UL_1  UE_1  ul  tcp  300  ${server_port_ul_1}
    ${tput_1_time}=  Get Current Date
    Start gnbMirroring  capturing_time_seconds=3    bb_slots=5
    Sleep  3  reason=Wait for log collection
    ${ue_1}=  Stop gnbMirroring And Gather L1L2 Logs  filename=${TEST_NAME}_ue_1.pcap

    Set Ul 256QAM Activation State For All Cells  true
    Samsung UE Attach  UE_2  nr_only=${nr_only}
    Sleep  30  reason=Wait for UE2 to get to Idle state

    # Duration of this transfer must be same as for DT_UL_1 for correct tput calculation
    keywords_1118.Start Traffic  DT_UL_2  UE_2  ul  tcp  100  ${server_port_ul_2}
    ${tput_2_time}=  Get Current Date
    Start gnbMirroring  capturing_time_seconds=3    bb_slots=5
    Sleep  3  reason=Wait for log collection
    ${both_ues}=  Stop gnbMirroring And Gather L1L2 Logs  filename=${TEST_NAME}_both_ues.pcap

    Assert Avg Tput 6 Percent Higher For 256QAM  DT_UL_1  DT_UL_2  ${tput_1_time}  ${tput_2_time}
    Verify BIP Logs For Activation Test  ${ue_1}  ${both_ues}

256_QAM_for_PUSCH_Feature_Deactivation_20MHz
    keywords_1118.Start Traffic  DT_UL_1  UE_1  ul  tcp  100
    Start gnbMirroring  capturing_time_seconds=3
    Sleep  5s  reason=Wait for log collection
    ${bip_256}=  Stop gnbMirroring And Gather L1L2 Logs  filename=${TEST_NAME}_bip_256.pcap
    ue.Await Data Transfer Finish  DT_UL_1

    Sleep  30s  reason=Wait for UE to get to idle state
    Set Ul 256QAM Activation State For All Cells  false
    keywords_1118.Start Traffic  DT_UL_2  UE_1  ul  tcp  100
    Start gnbMirroring  capturing_time_seconds=3
    Sleep  5s  reason=Wait for log collection
    ${bip_64}=  Stop gnbMirroring And Gather L1L2 Logs  filename=${TEST_NAME}_bip_64.pcap
    ue.Await Data Transfer Finish  DT_UL_2

    ${frames_256}=  Get Frames From Pcap  ${bip_256}
    ${frames_64}=  Get Frames From Pcap  ${bip_64}

    Assert MCS Table Is  256QAM   ${frames_256}
    Assert MCS Table Is  64QAM    ${frames_64}
    Assert MCS Is In Range  lower_bound=${256_mod_ord_8_mcs_min}
    ...                     upper_bound=${256_mcs_max}
    ...                     frames=${frames_256}
    Assert MCS Is In Range  lower_bound=${64_mod_ord_6_mcs_min}
    ...                     upper_bound=${64_mcs_max}
    ...                     frames=${frames_64}

Get the SW
    sleep   30    reason=Wait for socket release
    coam.Connect to         bts_host=${GN_OAM_ADDR}
    ${SW_Version}=          coam.get_sw_version
    set suite variable      ${SW_Version}

GNB Configuration Setup
    [Documentation]                    Download the SCF on gNB
    [Arguments]                        ${SCF}
    ${SCFPath}=                        catenate            ${CURDIR}/SCF_Directory
    coam.connect_to                    bts_host=${GN_OAM_ADDR}    name=coam_admin
    coam.perform_commissioning         scf_file=${SCFPath}/${SCF}          skip_parameter_relation_errors=True    connection=coam_admin   timeout=600
    Verify if all cells are onair
    [Teardown]                         coam.teardown              connection=coam_admin
