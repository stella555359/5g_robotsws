** Settings ***
Documentation   This is a keyword file for 5GC000480-D-J, part general keywords
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Email: 'Sylvia.Schneider@nokia.com'
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${wireshark_running}     false


*** Keywords ***

get version from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update in wts and commissioning
    ...       :Autor: Sylvia Schneider
    ${parsed_SCF}    parse XML    ${P_ORIG_SCF}
    ${version_SCF}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    set suite variable   ${version_SCF}
    Log To Console    set suite variable version_SCF to value: ${version_SCF}


Suite Teardown for 5GC000480-D-J Testing
    [Documentation]    [PRIVATE]    teardown for 480-D-J
    ...       :Autor: Sylvia Schneider
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config


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


Perform Preconditions of Test Scenario
    Create a Test Scenario Folder


start wireshark trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Set suite variable      ${wireshark_running}    true


stop wireshark trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${part}
    IF    '${wireshark_running}'=='false'   RETURN
    Sleep    2s    finish message recording
    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Create Directory    ${resultDir}/part${part}
    Move File    ${resultDir}/dump_testpc/dump_testpc.pcap    ${resultDir}/part${part}/wireshark.pcap
    Set suite variable      ${wireshark_running}    false


Attach on gNB
    [Arguments]    ${gnb_id}   ${ue_id}   ${target_cells}
    Log to Console    \nAttach UE ${ue_id} on gnb ${gnb_id}
    Attach UE to LTE    ue_id=${ue_id}
    Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    bearer_id=2    target_gnb=${gnb_id}   target_cells=${target_cells}
    Sleep    5s


unsuccessful Attach on gNB
    [Arguments]    ${gnb_id}   ${ue_id}   ${target_cells}
    Log to Console    \nAttach UE ${ue_id} on gnb ${gnb_id}
    Attach UE to LTE    ue_id=${ue_id}
    Sleep    2s
    Run Keyword And Ignore Error
    ...   Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    bearer_id=2    target_gnb=${gnb_id}   target_cells=${target_cells}
    Sleep    5s
    Detach UE from LTE                     ue_id=${ue_id}
    Sleep    5s


handover with A3 measurement to gNB3
    [Arguments]    ${ue_id}=151     ${meas_id}=1
    ${cmd}   set variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=48 nrsrp_nr=70 meas_id=${meas_id} id=${ue_id}
    ${pass}  set variable   Proxy .eNB 3 cell 1. reported successful RA
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${pass}"
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${pass}
    ...    alias=ap_egate
    Sleep    5s


handover with A3 measurement to gNB2
    [Arguments]    ${ue_id}
    ${cmd}   set variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=52 nrsrp_nr=70 meas_id=1 id=${ue_id}
    ${pass}  set variable   Inter Sgnb Handover is successful
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${pass}"
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${pass}
    ...    alias=ap_egate
    Sleep    5s


unsuccessful handover with A3 measurement to gNB2
    [Arguments]    ${ue_id}
    ${cmd}   set variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=52 nrsrp_nr=70 meas_id=1 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    alias=ap_egate
    Sleep    5s


Attach on gNB with additional bearers
    [Arguments]    ${gnb_id}   ${ue_id}   ${target_cells}
    ute_wtssim.execute egate command     cmd=enb_param id=1 drb_id_begin=3 endc_capable_qci=all    alias=ap_egate
    Log to Console    \nAttach UE ${ue_id} with additional bearers 3 and 4 on gnb ${gnb_id}
    Attach UE to LTE    ue_id=${ue_id}
    Sleep    2s
    Send Egate Command and verify output    cmd=bearer_add ue=${ue_id} id=3 filter=0 precedence=0
    ...    pass_regexp=Bearer-3 .* created
    Sleep    2s
    Send Egate Command and verify output    cmd=bearer_add ue=${ue_id} id=4 filter=0 precedence=1
    ...    pass_regexp=Bearer-4 .* created
    Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    bearer_id=2,3,4    target_gnb=${gnb_id}   target_cells=${target_cells}


execute several handover between gNB3 and gNB2
    [Arguments]    ${ue_id}
    handover with A3 measurement to gNB3   ue_id=${ue_id}
    handover with A3 measurement to gNB2   ue_id=${ue_id}
    FOR   ${run}    IN RANGE   4
          handover with A3 measurement to gNB3    ue_id=${ue_id}     meas_id=5
          handover with A3 measurement to gNB2    ue_id=${ue_id}
    END

