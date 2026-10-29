*** Settings ***
Documentation
...   Test suite for regression testing for feature CB008972
...   author: Jakub Bialon
...   contact: jakub.bialon@nokia.com
...   group: MN_RAN_RD_VRF_KRK_7

Library   BuiltIn
Library   ute_ue
Library   tools.py
Library   taf.sbts.oam.coam.admin   WITH NAME   SbtsAdmin
Library   taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations   WITH NAME   gnbcell
Library   taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnbasir


*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}   ${False}
${UE_DEFAULT_ALIAS_NAME}   UE
${DATA_TRANSFER_DEFAULT_DURATION}   120s
${DEFAULT_PACKET_SIZE}   1380
${DEFAULT_PROTOCOL}   tcp
${DEFAULT_DEVIATION}   20%


*** Keywords ***
Check SBTS Active Alarms
    [Arguments]   ${allowed_alarms_list}
    ${sbts_alarms_list}=   SbtsAdmin.Get Active Alarms
    tools.Check Active Alarms   allowed_alarms_list=${allowed_alarms_list}
    ...                         sbts_alarms_list=${sbts_alarms_list}

Verify Sbts And Asir Satus
    [Arguments]   ${allowed_sbts_fault_list}   ${allowed_asir_fault_list}   ${cell_blocked}
    Run Keyword If   ${cell_blocked} == ${False}   Run Keywords
    ...                                            Verify Status Of All Bts Cells Is Operational
    ...                                            cell_type=nr
    ...                                            expected_cell_amount=${8}
    ...                                            usage_state=active   AND
    ...                                            Verify Status Of All Bts Cells Is Operational
    ...                                            cell_type=lte
    ...                                            expected_cell_amount=${3}
    ...                                            usage_state=idle   AND
    ...                                            gnbasir.Verify Status Of All Asir Cells Is Operational
    Run Keyword If   ${cell_blocked} == ${True}   Run Keywords
    ...                                           Verify Status Of All Bts Cells Is Not Operational
    ...                                           cell_type=nr
    ...                                           expected_cell_amount=${8}   AND
    ...                                           Verify Status Of All Bts Cells Is Not Operational
    ...                                           cell_type=lte
    ...                                           expected_cell_amount=${3}   AND
    ...                                           gnbasir.Verify Status Of Asir Cells
    ...                                           expected_asir_cell_status=failed
    Check SBTS Active Alarms   allowed_alarms_list=${allowed_sbts_fault_list}
    gnbasir.Verify Only Allowed Alarms Are Active   allowed_alarms=${allowed_asir_fault_list}

Verify L3 Call Traffic On Particular Cell With Quectel
    [Arguments]   ${cell_id}   ${duration}   ${tput_dl}   ${tput_ul}   ${protocol}
    gnbcell.Block All Cells
    gnbcell.Unblock Cell   cell_id=${10}   timeout=300
    gnbcell.Unblock Cell   cell_id=${cell_id}   timeout=300
    gnbcell.Wait For Cell To Be Onair   cell_id=${cell_id}   timeout=300
    Check data transfer with Quectel   throughput_DL=${tput_dl}
    ...                                throughput_UL=${tput_ul}
    ...                                duration=${duration}
    ...                                protocol=${protocol}
    gnbcell.Block Cell   cell_id=${cell_id}
    gnbcell.Block Cell   cell_id=${10}
    gnbcell.Unblock All Cells
    Verify Status Of All Bts Cells Is Operational   cell_type=nr   expected_cell_amount=${8}   usage_state=active
    Verify Status Of All Bts Cells Is Operational   cell_type=lte   expected_cell_amount=${3}   usage_state=idle
    gnbasir.Verify Status Of All Asir Cells Is Operational

Check data transfer with Quectel
    [Arguments]   ${throughput_DL}
    ...           ${throughput_UL}
    ...           ${parallel_streams_DL}=1
    ...           ${parallel_streams_UL}=1
    ...           ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...           ${ue_capabilities}=QUECTEL_UE
    ...           ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...           ${packet}=${DEFAULT_PACKET_SIZE}
    ...           ${protocol}=${DEFAULT_PROTOCOL}
    ...           ${deviation}=${DEFAULT_DEVIATION}

    Log    ${ue_capabilities}
    ute_ue.Attach UE   ${ue_alias}
    Sleep   10sec
    # DL
    ute_ue.Start Data Transfer   dt_name=DT_DL
    ...                          ue_alias=${ue_alias}
    ...                          direction=dl
    ...                          duration=${duration}
    ...                          packet=${packet}
    ...                          throughput=${throughput_DL}
    ...                          protocol=${protocol}
    ...                          parallel_streams=${parallel_streams_DL}
    ...                          linux_congestion=reno
    ute_ue.Get UE Info   ${ue_alias}
    ute_ue.Await Data Transfer Finish   dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${throughput_DL}   deviation=${deviation}
    # UL
    ute_ue.Start Data Transfer   dt_name=DT_UL
    ...                          ue_alias=${ue_alias}
    ...                          direction=ul
    ...                          duration=${duration}
    ...                          packet=${packet}
    ...                          throughput=${throughput_UL}
    ...                          protocol=${protocol}
    ...                          parallel_streams=${parallel_streams_UL}
    ...                          linux_congestion=reno
    ute_ue.Await Data Transfer Finish   dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${throughput_UL}   deviation=${deviation}
    [Teardown]   ute_ue.Detach UE    ${ue_alias}

Verify Status Of All Bts Cells Is Operational
    [Arguments]   ${cell_type}   ${expected_cell_amount}   ${usage_state}
    Wait until keyword succeeds   300 sec   6 min   gnbcell.Verify All Cells Statuses   cell_type=${cell_type}
    ...                                                                                availability_status=online
    ...                                                                                operational_state=enabled
    ...                                                                                administrative_state=unlocked
    ...                                                                                blocking_state=unblocked
    ...                                                                                procedural_status=configured
    ...                                                                                usage_state=${usage_state}
    ...                                                                                barring_status=unbarred
    ...                                                                                expected_cell_amount=${expected_cell_amount}

Verify Status Of All Bts Cells Is Not Operational
    [Arguments]   ${cell_type}   ${expected_cell_amount}
    Wait until keyword succeeds   300 sec   6 min   gnbcell.Verify All Cells Statuses   cell_type=${cell_type}
    ...                                                                                availability_status=offline
    ...                                                                                operational_state=disabled
    ...                                                                                administrative_state=unlocked
    ...                                                                                blocking_state=blocked
    ...                                                                                procedural_status=configured
    ...                                                                                usage_state=idle
    ...                                                                                barring_status=unbarred
    ...                                                                                expected_cell_amount=${expected_cell_amount}
