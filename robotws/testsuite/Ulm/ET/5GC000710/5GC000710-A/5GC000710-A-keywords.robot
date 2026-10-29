*** Settings ***
Documentation   This is a keyword file for 5GC000710-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${wireshark_running}     false


*** Keywords ***

start wireshark trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     5s
    Set suite variable      ${wireshark_running}    true


stop wireshark trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${wireshark_running}'=='false'   RETURN
    sleep     5s
    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Move File    ${resultDir}/dump_testpc/dump_testpc.pcap    ${wireshark_store}
    sleep     2s
    Set suite variable      ${wireshark_running}    false


move wireshark file for UE${id}
    [Documentation]    [PRIVATE]    move wireshark file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark file wireshark.pcap moved to directory ${resultDir}/UE${id}
    Create Directory    ${resultDir}/UE${id}
    sleep     2s
    Move File    ${resultDir}/wireshark.pcap    ${resultDir}/UE${id}


check all radio units online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    wait until keyword succeeds
    ...    10min   20sec
    ...    Verify All Radios are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM http session    node_type=gnb  node_id=${0}


set spid for UE
    [Documentation]    [PRIVATE]    set spid before attach in wts
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:   number of UE
    ...     :param ${spid}:    spid value to be set
    [Arguments]     ${ue_id}     ${spid}
    sleep     2s
    ${cmd}   set variable   ue_enb_param id=${ue_id} spid=${spid}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


trigger gNB addition
    [Documentation]    [PRIVATE]   trigger gNB addition
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:   number of UE
    [Arguments]     ${ue_id}    ${target_cells}=3
    Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    bearer_id=2   target_cells=${target_cells}


set measurement gap on
    [Documentation]    [PRIVATE]    set measurement gap on
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}   set variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Log To Console    execute on wts: ${cmd}
    sleep     2s
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


send A1 measurement report
    [Documentation]    [PRIVATE]   send A1 event
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    [Arguments]     ${ue_id}
    Sleep    2s
    ${cmd}   set variable   ue_measurement_send_nr event=A1 srsrp_nr=50 meas_id=4 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           alias=ap_egate


send A2 measurement report
    [Documentation]    [PRIVATE]   send A2 measurement report
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${srsrq_nr}:  srsrq_nr, default value 30
    [Arguments]     ${ue_id}     ${srsrq_nr}=30
    Sleep    2s
    ${cmd}   set variable   ue_measurement_send_nr event=A2 srsrp_nr=33 srsrq_nr=${srsrq_nr} meas_id=3 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           alias=ap_egate


send A2 measurement report and expect meas_id not found
    [Documentation]    [PRIVATE]   send A2 measurement report
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${srsrq_nr}:  srsrq_nr, default value 30
    [Arguments]     ${ue_id}     ${srsrq_nr}=30
    Sleep    2s
    ${cmd}   set variable   ue_measurement_send_nr event=A2 srsrp_nr=33 srsrq_nr=${srsrq_nr} meas_id=3 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    Log To Console    checking on wts: meas_id=3 not found
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           pass_regexp=meas_id=3 not found
    ...           alias=ap_egate


send A3 measurement report and expect successful RA
    [Documentation]    [PRIVATE]   send A3 measurement report and expect successful RA
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    [Arguments]     ${ue_id}
    Sleep    2s
    ${cmd}   set variable   ue_measurement_send_nr event=A3 srsrp_nr=90 srsrq_nr=35 phycell_id=49 nrsrp_nr=100 nrsrq_nr=40 meas_id=5 id=${ue_id}
    Log To Console
    ...    execute on wts: ${cmd}
    Log To Console    and check for "Proxy (eNB 3 cell 2) reported successful RA"
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           pass_regexp=Proxy .eNB 3 cell 2. reported successful RA
    ...           alias=ap_egate


send A5 measurement report
    [Documentation]    [PRIVATE]   send A5 measurement report
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${nrsrq_nr}:  nrsrq_nr
    [Arguments]     ${ue_id}    ${nrsrq_nr}
    Sleep    2s
    ${cmd}   set variable
    ...   ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=49 nrsrp_nr=100 nrsrq_nr=${nrsrq_nr} meas_id=5 id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           alias=ap_egate


send A5 measurement report and expect successful RA
    [Documentation]    [PRIVATE]   send A5 measurement report and expect successful RA for eNB 3 cell 2
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${nrsrq_nr}:  nrsrq_nr
    [Arguments]     ${ue_id}    ${nrsrq_nr}
    Sleep    2s
    ${cmd}   set variable
    ...   ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=49 nrsrp_nr=100 nrsrq_nr=${nrsrq_nr} meas_id=5 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check for "Proxy (eNB 3 cell 2) reported successful RA"
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           pass_regexp=Proxy .eNB 3 cell 2. reported successful RA
    ...           alias=ap_egate


Attach and detach UE
    Log to Console    \nAttach UE ${UE}
    [Arguments]   ${UE}=151
    Attach UE to LTE    ue_id=${UE}
    Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${UE}    bearer_id=2   target_cells=3
    sleep    3s
    Log to Console    \nDetach UE ${UE}
    ute_wtssim.execute egate command and wait for data    cmd=ue_detach id=${UE}    alias=ap_egate
    sleep    3s


set spid and attach
    [Documentation]    [PRIVATE]   set spid and attach
    ...     :Autor: Sylvia Schneider
    [Arguments]   ${UE}=151     ${spid_attach}=111
    Log To Console    \n****Test: set spid, attach
    start wireshark trace
    sleep     2s
    set spid for UE   ue_id=${UE}     spid=${spid_attach}
    sleep     2s
    Attach and detach UE
    sleep     2s
    stop wireshark trace
    sleep     2s
    Log To Console    wireshark file wireshark.pcap moved to directory ${resultDir}/part_attach
    sleep     2s
    Create Directory    ${resultDir}/part_attach
    sleep     2s
    Move File     ${resultDir}/wireshark.pcap    ${resultDir}/part_attach


attach and modify spid
    [Documentation]    [PRIVATE]   attach and modify spid
    ...     :Autor: Sylvia Schneider
    [Arguments]   ${test_run}   ${UE}=151     ${spid_modify}=222
    Log To Console    \n****Test: attach and modify spid
    start wireshark trace
    sleep     2s
    Log to Console    Attach UE ${UE}
    Attach UE to LTE    ue_id=${UE}
    Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${UE}    bearer_id=2   target_cells=3
    sleep    3s
    modify spid      ue_id=${UE}    spid_modify=${spid_modify}
    sleep    3s
    Log to Console    Detach UE ${UE}
    ute_wtssim.execute egate command and wait for data    cmd=ue_detach id=${UE}    alias=ap_egate
    sleep     2s
    stop wireshark trace
    sleep     2s
    Log To Console    wireshark file wireshark.pcap moved to directory ${resultDir}/part_modify${test_run}
    sleep     2s
    Create Directory    ${resultDir}/part_modify${test_run}
    sleep     2s
    Move File     ${resultDir}/wireshark.pcap    ${resultDir}/part_modify${test_run}
    sleep     2s


unassign spid and attach
    [Documentation]    [PRIVATE]   attach and modify spid
    ...     :Autor: Sylvia Schneider
    [Arguments]   ${UE}=151
    Log To Console    \n****Test: unassign spid, attach
    start wireshark trace
    sleep     2s
    unassign spid    ue_id=${UE}
    sleep     2s
    Attach and detach UE
    sleep     2s
    stop wireshark trace
    sleep     2s
    Log To Console    wireshark file wireshark.pcap moved to directory ${resultDir}/part_unassign
    sleep     2s
    Create Directory    ${resultDir}/part_unassign
    sleep     2s
    Move File     ${resultDir}/wireshark.pcap    ${resultDir}/part_unassign
    sleep     2s


modify spid
    [Documentation]    [PRIVATE]   modify spid for UE while attached
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:   number of UE
    ...     :param ${spid_modify}: spid value to be set
    [Arguments]    ${ue_id}   ${spid_modify}
    ${cmd}   set variable     enb_ue_dc_modify ue=${ue_id} by=enb cause=MISC_CauseMisc_unspecified spid=${spid_modify}
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check for "SgNBModificationRequestAcknowledge"
    ${output_modify_spid}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=SgNBModificationRequestAcknowledge
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_modify_spid.txt    ${output_modify_spid}
    Sleep    2s


unassign spid
    [Documentation]    [PRIVATE]   delete spid for AP UE while not attached
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:   number of UE
    [Arguments]    ${ue_id}
    ${cmd}   set variable   ue_enb_param id=${ue_id} spid=not_assigned
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate
    Sleep    3s
