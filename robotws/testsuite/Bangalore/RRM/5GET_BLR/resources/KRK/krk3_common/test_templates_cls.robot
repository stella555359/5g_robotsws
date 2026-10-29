*** Settings ***
Documentation
...            KRK3 Test templates for Classical deployment
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Resource    main_cls.robot

Suite Setup       Run Keywords
...               Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_out=${WTS_HO}
...    AND        Delete Existing Xn Link If Exists
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_HO}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${DEFAULT_LOGS}    radio_res=yes
Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
# Config files
@{IP_ADDR_SIM_GNB}    eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_HO}           ${CURDIR}/configs/Delta_HO_Xn_NG_A3_A5.json
${DELTA_PCMD}         ${CURDIR}/configs/Delta_PCMD_DCAP.json
@{DELTAS}             ${DELTA_HO}    ${DELTA_PCMD}
&{SUITE_CONFIG}       delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_WTS_A3_Xn}    ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_A5_NG}    ${CURDIR}/configs/wts_sim_gnb_A5_NGHO.cfg
${WTS_HO}             ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg
# Logging options
&{SHERPA_STREAM}        nr_phy_cell_ids=50,51    up_sw=L2Ps    trace_type=Sherpa
&{TTI_TRACE_STREAM}     nr_phy_cell_ids=50,51    up_sw=L2Ps    trace_type=Component
@{L2_STREAM_CONFIGS}    ${SHERPA_STREAM}    ${TTI_TRACE_STREAM}
&{LOGS_WITH_SHERPA}     syslog_gnb=yes    tcpdump_gnb=yes    sherpa=${L2_STREAM_CONFIGS}
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}

*** Test Cases ***
01_Classical_with_AP_SA_L3_Call_Sherpa
    [Documentation]    Example test with L3 Call of SA UEs with traffic verification and Sherpa trace collection.
    ...                Using default WTS config and expecting two SA UEs.
    ...                UE-1 is using default throughput (10mbps DL/UL) and UE-2 is using parametrized throughput.
    ...                Collected PCAP is decoded into Sherpa L1L2Trace and TTI Trace.
    [Setup]    Run Keywords
    ...           DCAP Basic Control    action=stop
    ...    AND    Test Case Setup    logs=${LOGS_WITH_SHERPA}    radio_res=yes
    Start Sherpa Trace Collection
    Start SA L3 Call    ue_id=1
    Start SA L3 Call    ue_id=2    dl_tput=500kbps    ul_tput=OFF
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=2    dl_tput=500kbps    ul_tput=OFF
    Get UE Stats From Egate    ue_id=1    scell=0-6    type=pdsch    size_unit=auto
    Get UE Stats From Egate    ue_id=2    scell=0-6    type=pdsch    size_unit=kbps
    Stop SA L3 Call    ue_id=1
    Stop SA L3 Call    ue_id=2
    ${sherpa_pcap}    Stop and Collect Sherpa Trace    log_dir=${TEST_log_dir}/Wireshark/
    Convert Sherpa Trace PCAP to CSV    pcap_filepath=${sherpa_pcap}    csv_dirpath=${TEST_log_dir}/Sherpa/
    Decode TTI Traces from PCAP or BIN    input_filepath=${sherpa_pcap}    output_dir=${TEST_log_dir}/TTITrace/
    ...    format=excelCsv    conversion_filter=dlFdSchedData

02_Classical_with_AP_NSA_L3_Call_DCAP_PCMD_CellTrace
    [Documentation]    Example test with L3 Call of NSA UEs with traffic verification and DCAP trace collection.
    ...                Using default WTS config and expecting two NSA UEs.
    ...                UE-11 is using default throughput (10mbps DL/UL) and UE-12 is using parametrized throughput.
    ...                ipCapture PCAP collected with DCAP is used to get PCMD records and Cell Traces which are
    ...                are verified.
    ...                PCMD Records verification example:
    ...                - Values for ``x2ap_Id`` are taken from SgNBAdditionRequestAcknowledge messages from PCAP
    ...                - Different ``seconds`` fields are found according to parent node name
    ...                - Expected values for ``seconds`` fields use regexp patterns
    ...                - Expected order of records is: sgnbAdditionRecord (UE-11) -> sgnbAdditionRecord (UE-12)
    [Tags]    DCAP
    [Setup]    Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    Start NSA L3 Call    ue_id=101    target_gnb_cell=1
    Start NSA L3 Call    ue_id=102    target_gnb_cell=2    dl_tput=500kbps    ul_tput=OFF
    Verify NSA UE Traffic Using Bearer Stats    ue_id=101     wait=10s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=102    dl_tput=500kbps    ul_tput=OFF
    Stop NSA L3 Call    ue_id=101
    Stop NSA L3 Call    ue_id=102
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    #--------- PCMD ------------------------------------------------------------------------------------------------
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    ${UE11_X2_ID}    ${UE12_X2_ID}    Get Message Field Values from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    field_name=x2ap.SgNB_UE_X2AP_ID
    ...    filter=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1) && !nsetapx
    ${Add_UE11}    Create Dictionary
    ...    record_name=sgnbAdditionRecord
    ...    sgnb_ue_x2ap_Id=${UE11_X2_ID}
    ...    sgnbAdditionReqAckSndTime.*seconds=\\d{10}
    ...    sgnbReconfCmplRcvTime.*seconds=\\d{10}
    ${Add_UE12}    Create Dictionary
    ...    record_name=sgnbAdditionRecord
    ...    sgnb_ue_x2ap_Id=${UE12_X2_ID}
    ...    sgnbAdditionReqAckSndTime.*seconds=\\d{10}
    ...    sgnbReconfCmplRcvTime.*seconds=\\d{10}
    ${PCMD_Seq}    Create List    ${Add_UE11}    ${Add_UE12}
    Verify PCMD Records Sequence in Collection    ${records}    ${PCMD_Seq}
    #--------- Cell Traces -----------------------------------------------------------------------------------------
    ${traces}    Get Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/CellTraces.json
    Verify Cell Trace in Collection    ${traces}    x2ap    SgNBAdditionRequest=.*    UE_X2AP_ID=\\d+

03_Classical_with_AP_SA_Xn_HO_To_Sim_A3
    [Documentation]    Example test of Inter-GNB Xn Handover of SA UE from External to Simulated GNB and back
    ...                with traffic verification.
    ...                Handover is triggered by A3 Measurement. Simulated GNB is setup with cell PCI 52.

    Check Xn Link is Up    sim_gnb_id=3    ext_gnb_id=2
    Setup SA UE and Expect Measurement Event Config    ue_id=1    event=A3

    Start Internal SA Bidirectional Traffic    ue_id=1
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s

    Perform Xn Inter-GNB Handover to Sim GNB with UE-1 using A3 Event
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=20s

    Perform Xn Inter-GNB Handover to Ext GNB with UE-1 using A3 Event
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=20s
    Stop SA L3 Call    ue_id=1

04_Classical_with_AP_SA_NG_HO_To_Ext_A5
    [Documentation]    Example test of Inter-GNB NG Handover of SA UE from Simulated to External GNB and back
    ...                with traffic verification.
    ...                Handover is triggered by A5 Measurement. Simulated GNB is setup with cell PCI 52.
    ...                New NIDD parameters should be changed/loaded BEFORE Test Case Setup.
    ...                Changed NIDD parameters should be reversed AFTER Test Case Teardown.
    ...                Both recommendations are to avoid unnecessarily long log collection time during test.
    [Setup]    Run Keywords
    ...           Switch HO Type to NG in Ext GNB
    ...    AND    Set Sim GNB To NG HO and A5 Event
    ...    AND    Test Case Setup    logs=${DEFAULT_LOGS}    radio_res=yes

    Change UE-1 Location To Sim GNB
    Setup SA UE and Expect Measurement Event Config    ue_id=1    event=A5

    Start Internal SA Bidirectional Traffic    ue_id=1
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s

    Perform NG Inter-GNB Handover to Ext GNB with UE-1 using A5 Event
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=20s

    Perform NG Inter-GNB Handover to Sim GNB with UE-1 using A5 Event
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=20s
    Stop SA L3 Call    ue_id=1

    [Teardown]    Run Keywords
    ...           Test Case Teardown    check_radio_res=yes    oam_logs=yes
    ...    AND    Switch HO Type to Xn in Ext GNB

*** Keywords ***
Set Sim GNB To ${type} HO and ${event} Event
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                Dictionary is used as a map between embeded parameters (more readable)
    ...                to internal parameters (less readable).
    ...                KW assumes that Sim GNB has ID 3.
    &{ho}    Create Dictionary    Xn=xn_based    NG=ng_based
    Update Sim GNB Parameters    id=3    measEvent=${event}    sa_ho=${ho}[${type}]

Change UE-${ue_id} Location To Sim GNB
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Sim GNB has ID 3 and has only one cell with ID 1.
    Change UE Location    ue_id=${ue_id}    node_id=3    cell_id=1

Perform ${ho_type} Inter-GNB Handover to ${node_type} GNB with UE-${ue_id} using ${event} Event
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Simulated GNB Cell has PCI 52 and External GNB Cell has PCI 50.
    &{pci}    Create Dictionary    Sim=52    Ext=50
    Run Keyword    Perform Inter-GNB ${ho_type} Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${pci}[${node_type}]    event=${event}

Switch HO Type to ${type} in Ext GNB
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Relation 1 in Cell 1 defines HO neighbour to Simulated GNB.
    ...                External GNB performs Xn HO by default unless it is not allowed, then switches to NG.
    &{values}    Create Dictionary    Xn=allowed    NG=XnHoNotAllowed
    Change NIDD Parameter Online
    ...    dist=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    param=handoverAllowedSA    value=${values}[${type}]

Delete Existing Xn Link If Exists
    ${local_skip}    Get Variable Value    ${skip}
    ${skip_config}    Set Variable If    'config' in '${local_skip}'    ${True}    ${False}
    Run Keyword If    ${skip_config}    Return From Keyword
    Log to Console    Removing existing Xn Link if exists
    ${connection}    coam_admin.setup_admin
    ${status}    ${msg}    Run Keyword And Ignore Error    coam_admin.perform_object_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/XNLINK-1    parameter=@{Empty}    operation=delete    connection=${connection}
    coam_admin.teardown_admin    connection=${connection}
    ${not_exist}    Run Keyword And Return Status    Should Contain    ${msg}    object not exist
    Run Keyword Unless    ${not_exist} or '${status}' == 'PASS'    Fail    ${msg}
