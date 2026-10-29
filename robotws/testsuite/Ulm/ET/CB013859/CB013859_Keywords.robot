*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: Keywords for CB013859-A and -B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     taf.config.wts        WITH NAME    wts_conf

Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot
Resource    ./CB013859_Commissioning.robot
Resource    ./CB013859_PM.robot


*** Variables ***

@{IP_LIST_eth3_add}         10.0.1.3  10.0.1.4
@{IP_LIST_eth4_add}         10.0.2.90
${EGATE_CONSOLE_LOG}        /opt/iphy/latest/egate_console.log

${SA_UE_CB013859}          SEPARATOR=
...    F5A03C0047D4FFBEFFFFBAF0A40003C170101E0935F3FFFB7C00B004D9E71FF9863CA160106E0601F8E02145F063FE6F28EF215FFFFFF96596884400416CCB6C06FCFBFFFEBFF
...    F7CFB3FFFFE014FFD3FF28BE20FFCDE51DE42BFFFFFF2CB2D10880082D996D80DF9F7FFFD7FFEF9F67FFFFC029FFA7FE517C46FF9BCA210AFFFFFFCB2CB44220020B665B6037F
...    FDFFFF5FFFBE7D9FFFFF00A7FE9FF945F0A3FE6F288600FFFFFFCB2CB640880082D996D80DFFF7FFFD7FFEF9F67FFFFC02DFFFFEDFFFFE517C4CFF9BCA21803FFFFFF2CB2D802
...    2001EB625B80DFFF3FFFD7FFEF9F677FFFC37FFFFB7FFFF81A89C46000E1400060A00C0C0184C00003FCFFFFFFFFFA898180385000182803082061300002FF3FFFFFFFFEA2706
...    00038500018280308207118000013FCFFFFFFFFF80480310106023402880983A8000AC071234081BFCFB71234081BFCFB71204681BFCFB601C0C631FFFFC000460007C0050382
...    80381884E00E000F000C07400E0A00C06000040000601200301F012C9000000AC90000022C90000042C90000062C900000800460A56065654D654D654D01190000012CA48C800
...    0089652464000084B292320000625949190000412CA4802282C55039AA55154AA6A954D0F0021004F24E03C9380F24A03C9280F24A000011004008010100600C0401803010020
...    0404018032008010020200C018080300602004008080300640100200404018030100600C0400801010020042B0620

${SA_UE_ICS}               SEPARATOR=
...    0410F88821CF5A03C0047D4FFBEFFFFBAF0A40003C170101E0935F3FFFB7C00B004D9E71FF9863CA160106E0601F8E02145F063FE6F28EF215FFFFFF96596884400416CCB6C06
...    FCFBFFFEBFFF7CFB3FFFFE014FFD3FF28BE20FFCDE51DE42BFFFFFF2CB2D10880082D996D80DF9F7FFFD7FFEF9F67FFFFC029FFA7FE517C46FF9BCA210AFFFFFFCB2CB4422002
...    0B665B6037FFDFFFF5FFFBE7D9FFFFF00A7FE9FF945F0A3FE6F288600FFFFFFCB2CB640880082D996D80DFFF7FFFD7FFEF9F67FFFFC02DFFFFEDFFFFE517C4CFF9BCA21803FFF
...    FFF2CB2D8022001EB625B80DFFF3FFFD7FFEF9F677FFFC37FFFFB7FFFF81A89C46000E1400060A00C0C0184C00003FCFFFFFFFFFA898180385000182803082061300002FF3FFF
...    FFFFFEA270600038500018280308207118000013FCFFFFFFFFF80480310106023402880983A8000AC071234081BFCFB71234081BFCFB71204681BFCFB601C0C631FFFFC000460
...    007C005038280381884E00E000F000C07400E0A00C06000040000601200301F012C9000000AC90000022C90000042C90000062C900000800460A56065654D654D654D01190000
...    012CA48C8000089652464000084B292320000625949190000412CA4802282C55039AA55154AA6A954D0F0021004F24E03C9380F24A03C9280F24A000011004008010100600C04
...    018030100200404018032008010020200C018080300602004008080300640100200404018030100600C0400801010020042B06200

${GNB3_CFG}                SEPARATOR=
...    set_gnb id=3 type=simulated plmn=310:260 ng=$GNB3_NG_ADDR xn=$GNB3_XN_ADDR gnb_id=0x3:22 daemon=$SERVER_IP:$DAEMON_PORT x2_peers=
...    none nssai=0x01:1 amf=1 plmnList=310:260

${GNB3_Cell-1_CFG}         SEPARATOR=
...    set_cell id=1 gnb=3 pci=16:0 tac=1 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER1_IP:9999 nr_arfcn=528000:528000 gscn=
...    6501 mandatory_for_activation=off

*** Keywords ***

Prepare TL For CB013859
    sqd65_keywords.Sqd65 Common Setup
    Fetch Nidd Version From SCF File
    Prepare WTS Config
    CB013859_Commissioning.Common Commissioning For All Sub-Features
    ute_workarounds.Bring Airphone TL To On Air Status     cfg_file=basic_setup_CB013859.cfg
    ${SW_BRANCH}=       testline.Get gNB SW Branch
    Set Suite Variable  ${SW_BRANCH}


Perform Preconditions Of Test Scenario
    testline.Create Testcase Log Directory
    IF      '${PREV_TEST_STATUS}'=='FAIL'
    ...                 Perform Preconditions Of Test Scenario In Case of Previous TC Failed
    ${log_dir}=         testline.Get Testcase Log Directory
    ${SCF_TC_Setup}=    gnb.Get SCF from gNB  target_dir=${log_dir}  scf_name=scf_before_tc_execution.xml
    sqd65_keywords.Start Logging       pmcounter_enabled=${FALSE}
    Set Suite Variable  ${SCF_TC_Setup}


Perform Preconditions Of Test Scenario In Case Of Previous TC Failed
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone
    ute_workarounds.Bring Airphone TL To On Air Status     cfg_file=basic_setup_CB013859.cfg


Perform Postconditions Of Test Case
    Run Keyword And Warn On Failure    sqd65_keywords.Stop logging
    IF  '${TEST_MODE}' == 'auto' and '${TEST_STATUS}' == 'FAIL'
        sqd65_keywords.Collect AP Sos Report And Snapshots
    END
    Revert Delta Commissioning


Revert Delta Commissioning
    ${log_dir}=                 testline.Get Testcase Log Directory
    ${curr_scf}=                gnb.Get SCF From GNB   target_dir=${log_dir}  scf_name=scf_after_tc_execution.xml
    ${revert_file}=             Set Variable   ${log_dir}/revert.json
    scf.Calculate Delta SCF     ${SCF_TC_Setup}  ${curr_scf}  ${revert_file}
    sqd65_keywords.Config GNB With Delta SCF   ${revert_file}


Fetch Nidd Version From SCF File
    [Documentation]    Author: MN RAN RD VRF ULM T01 01
    ...    This keyword fetches the NIDD version of NRBTS from current SCF file and create a suite variable with this NIDD version
    [Arguments]
    ${scf_file}=         Get File    ${P_ORIG_SCF}
    ${nrbts_nidd_ver}=	 Get Lines Containing String       ${scf_file}	    com.nokia.srbts.nrbts:NRBTS
    ${nrbts_nidd_list}   Split String      ${nrbts_nidd_ver}     "
    ${NIDD_VERSION}=     Evaluate    "${nrbts_nidd_list}[5]".replace("'", "")
    Set Suite Variable   ${NIDD_VERSION}


Prepare WTS Config
    [Documentation]    Basic setup cfg file will be updated based on CB013859 needs using this keyword.
    wts_conf.load_wts_cfg   file_path=${P_ORIG_WTS_CONFIG}
    wts_conf.insert         set GNB3_NG_ADDR="10.0.1.3"  after  set PDN_IP11="4.7.254.211"
    wts_conf.insert         set GNB3_XN_ADDR="10.0.1.4"  after  set GNB3_NG_ADDR="10.0.1.3"
    wts_conf.insert         set PROXY_SERVER1_IP="10.0.2.90"  after  set GNB3_XN_ADDR="10.0.1.4"
    wts_conf.insert         set SA_UE_CB013859=${SA_UE_CB013859}  before  set_amf_region id=1
    wts_conf.insert         set SA_UE_ICS=${SA_UE_ICS}  after  set SA_UE_CB013859=${SA_UE_CB013859}
    wts_conf.modify         set_amf_region id=1  modification=tac_list=200,100,788,200,0,1,2,7,10
    wts_conf.modify         set_cell id=1  modification=tac=1
    wts_conf.modify         set_cell id=2  modification=tac=2
    wts_conf.modify         set_cell id=4  modification=tac=2
    wts_conf.modify         set_cell id=7  modification=tac=7
    wts_conf.modify         set_cell id=10  modification=tac=10
    wts_conf.insert         ${GNB3_CFG}  after  set_cell id=12 gnb=2
    wts_conf.insert         gnb_param id=3 xn_listening_socket=1 sa_ho=ng_based sib1_period=80 sib2_period=80 sib5_period=80 measEvent=A3
    ...                     after  set_gnb id=3
    wts_conf.insert         ${GNB3_Cell-1_CFG}  after  gnb_param id=3
    wts_conf.modify         ue_param id=1  modification=ue_nr_capabilities=$SA_UE_CB013859
    wts_conf.modify         ue_param id=2  modification=ue_nr_capabilities=$SA_UE_CB013859
    wts_conf.insert         amf_ue_ics_param id=1 ue=all include_ue_capabilities=on ue_capabilities=$SA_UE_ICS
    ...                     after  set_pdu_gateway id=100
    wts_conf.modify         set_nwslice id=1  modification=snssai=0x01:1 ue=all
    FOR   ${id}   IN RANGE   2   21
        wts_conf.delete         set_nwslice id=${id}
    END
    wts_conf.insert         set_nwslice id=2 snssai=0x81:0 ue=all amf=1 qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7  after  set_nwslice id=1
    wts_conf.insert         set_nwslice id=3 snssai=0x81:1 ue=all amf=1 qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7  after  set_nwslice id=2
    wts_conf.insert         set_nwslice id=4 snssai=0x01:3000 ue=all amf=1 qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7  after  set_nwslice id=3
    wts_conf.insert         set_nwslice id=5 snssai=0x01:4000 ue=all amf=1 qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7  after  set_nwslice id=4
    wts_conf.insert         sim_debug_log level=4 enb=3  after  sim_debug_log level=4 sgw=1
    wts_conf.save_wts_cfg   file_path=${tl.core.dir_path}/basic_setup_CB013859.cfg
    ${ts_conf_dir}=         testline.Get Test Suite Config Directory
    Copy File               ${tl.core.dir_path}/basic_setup_CB013859.cfg  ${ts_conf_dir}


Register And Establish PDU Session
    [Documentation]    Register and establish PDU Session
    [Arguments]   ${ue_id}   ${pdu_id}   ${nwslice}   ${pass_regexp}=Initial Context Setup Successful
    wts_ue.UE Register   ue_id=${ue_id}   nwslice=${nwslice}
    wts_ue.Set Traffic Type   ue_id=${ue_id}   pdu_id=${pdu_id}   trf_type=internal
    wts_ue.UE PDU Session Setup   ue_id=${ue_id}   pdu=${pdu_id}   gw=${pdu_id}   nwslice=${nwslice}   pass_regexp=${pass_regexp}
    Sleep  5s


Establish PDU Session
    [Documentation]    Establish PDU Session
    [Arguments]   ${ue_id}   ${pdu_id}   ${nwslice}   ${pass_regexp}=Initial Context Setup Successful
    wts_ue.Set Traffic Type   ue_id=${ue_id}   pdu_id=${pdu_id}   trf_type=internal
    wts_ue.UE PDU Session Setup   ue_id=${ue_id}   pdu=${pdu_id}   gw=${pdu_id}   nwslice=${nwslice}   pass_regexp=${pass_regexp}
    Sleep  5s


Establish PDU Session For B_IWK7
    [Documentation]    Establish PDU Session for CB013859-B#IWK7 without sleep in the end due to supervision timer of 10s for A4 MRs arrival
    [Arguments]   ${ue_id}   ${pdu_id}   ${nwslice}   ${pass_regexp}=Initial Context Setup Successful
    wts_ue.Set Traffic Type   ue_id=${ue_id}   pdu_id=${pdu_id}   trf_type=internal
    wts_ue.UE PDU Session Setup   ue_id=${ue_id}   pdu=${pdu_id}   gw=${pdu_id}   nwslice=${nwslice}   pass_regexp=${pass_regexp}


Delay PDU Session Setup Message Till Next PDU Session Setup Is Triggered
    [Documentation]    Action that queues the pdu session setup message till next pdu session setup is triggered
    [Arguments]    ${amf_id}=1
    wts_ue.Send Egate Command And Verify Output   cmd=amf_ue_pdu_setup_param id=${amf_id} action=delay_till_next_pdu_setup


Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    [Documentation]    Check whether UE is configured with A1 measurement, then send A1 MR and verify SCells configured
    [Arguments]    ${ue_id}   ${carrier_freq}   ${srsrp_nr}   ${ca_msg_verify}   ${CA_cell_configuration}   ${PCell_info}=${EMPTY}
    ${log_dir}=                 Get Testcase Log Directory
    sqd65_keywords.Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    ${egate_log}   CB013859_Keywords.Send NR Measurement Report
    ...    event=A1
    ...    meas_values=srsrp_nr=${srsrp_nr}
    ...    ue_id=${ue_id}
    ...    carrier_freq=${carrier_freq}
    ${Rrc_after_A1_based_scell_addition}    Set variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}${PCell_info}.log
    Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
    Set Suite Variable    @{CA_MSG_SEQ}   @{ca_msg_verify}
    Verify SCELL Addition For UE In RRC Reconfiguration
    ...    Rrc_file_path=${Rrc_after_A1_based_scell_addition}
    ...    CA_cell_configuration=${CA_cell_configuration}


Send NR Measurement Report
    [Arguments]    ${event}  ${meas_values}=${EMPTY}   ${ue_id}=1  ${timeout}=10s  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ...            ${pass_regexp}=rrcReconfigurationComplete  ${fail_regexp}=${None}
    ${meas_ids}                                   Get NR Measurement IDs     ${event}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    ${egate_log}  wts_ue.Send Egate Command And Verify Output
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids}[0] event=${event} ${meas_values}
    ...    pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}  timeout=${timeout}
    Sleep   1
    Run Keyword And Ignore Error                  wts_ue.Send Egate Command And Verify Output
    ...                                           cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    wts_ue.Send Egate Command And Verify Output   set_log flush
    RETURN   ${egate_log}


Verify SCELL Addition For UE In RRC Reconfiguration
    [Documentation]
    ...   To verify if SCells Additions are configured by gNB for the UE during RRC Reconfiguration. List @{CA_MSG_SEQ} must be
    ...   defined in subfeature suite variable.
    [Arguments]    ${Rrc_file_path}   ${CA_cell_configuration}
    util.Verify Sequence In File  ${Rrc_file_path}  @{CA_MSG_SEQ}
    Log    The gNB configures the UE with ${CA_cell_configuration}.
    ...        console=${P_console}


Verify A1 Measurement Event Configured On TDD-SCell For The PCell Change
    [Documentation]    Check whether UE is configured with A1 measurement on TDD-SCell for the PCell change
    [Arguments]    ${ue_id}   ${carrier_freq}
    sqd65_keywords.Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}


Send A1 MR And Verify PCell Switch And SCells Release Happened
    [Arguments]    ${ue_id}   ${carrier_freq}   ${scell}   ${scell_rsrp}
    sqd65_keywords.Send NR Measurement Report
    ...    event=A1
    ...    meas_values=scell=${scell} scell_rsrp=${scell_rsrp}
    ...    ue_id=${ue_id}
    ...    carrier_freq=${carrier_freq}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${NRCELL-7.lcrId} to EXT_ENB-2.${NRCELL-1.lcrId} performed
    Sleep   2
    sqd65_keywords.Verify Sequence In Egate File  ${EGATE_CONSOLE_LOG}  @{CA_MSG_SEQ_RELEASE}


Verify A4 Measurement Event Configured And Send A4 MR For All Candidate SCells
    FOR   ${carrier_freq}                   ${phycell_id}      IN
    ...   ${NRCELL-2.arfcnSsbPbch}          52
    ...   ${NRCELL-7.arfcnSsbPbch}          57
    ...   ${NRCELL-10.arfcnSsbPbch}         60
        Verify A4 Measurement Event Configured And Send A4 MR
        ...    ue_id=1
        ...    carrier_freq=${carrier_freq}
        ...    phycell_id=${phycell_id}
        ...    nrsrp_nr=80
        ...    nrsrq_nr=40
    END


Verify A4 Measurement Event Configured And Send A4 MR
    [Documentation]    Check whether UE is configured with A4 measurement, then send A4 MR
    [Arguments]    ${ue_id}   ${carrier_freq}   ${phycell_id}   ${nrsrp_nr}   ${nrsrq_nr}
    sqd65_keywords.Verify Measurement ID Is Configured  event_type=A4  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    sqd65_keywords.Send NR Measurement Report
    ...    event=A4
    ...    meas_values=phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ...    ue_id=${ue_id}
    ...    carrier_freq=${carrier_freq}
    ...    pass_regexp=${None}


Start DL UL Data Traffic On 2 PDU Sessions
    [Arguments]      ${ue_id}
    FOR   ${trf_id_range_min}      ${trf_id_range_max}      ${direction}      ${mbps}      ${pdu}      IN
    ...   1                        3                        dl                175          1
    ...   4                        6                        ul                50           1
    ...   1                        3                        dl                175          2
    ...   4                        6                        ul                50           2
        Start SA Data Traffic In Egate On Multiple Traffic IDs
        ...    ue_id=${ue_id}
        ...    trf_id_range_min=${trf_id_range_min}
        ...    trf_id_range_max=${trf_id_range_max}
        ...    direction=${direction}
        ...    mbps=${mbps}
        ...    pdu=${pdu}
    END
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids


Start DL UL Data Traffic On Single PDU Session
    [Arguments]      ${ue_id}   ${pdu}=1
    FOR   ${trf_id_range_min}      ${trf_id_range_max}      ${direction}      ${mbps}      IN
    ...   1                        3                        dl                175
    ...   4                        6                        ul                50
    Start SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=${ue_id}
    ...    trf_id_range_min=${trf_id_range_min}
    ...    trf_id_range_max=${trf_id_range_max}
    ...    direction=${direction}
    ...    mbps=${mbps}
    ...    pdu=${pdu}
    END
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids


Start SA Data Traffic In Egate On Multiple Traffic IDs
    [Documentation]   Starting SA Data Traffic in Egate on multiple traffic IDs
    [Arguments]      ${ue_id}   ${trf_id_range_min}   ${trf_id_range_max}   ${direction}   ${mbps}=50   ${qfi}=1   ${pdu}=1
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
           wts_ue.Start Data Traffic In Egate   ue_id=${ue_id}  direction=${direction}  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}
    END


Stop DL UL Data Traffic On 2 PDU Sessions And Deregister UE
    [Arguments]      ${ue_id}
    FOR   ${trf_id_range_min}      ${trf_id_range_max}      ${direction}      ${pdu}      IN
    ...   1                        3                        dl                1
    ...   4                        6                        ul                1
    ...   1                        3                        dl                2
    ...   4                        6                        ul                2
        Stop SA Data Traffic In Egate On Multiple Traffic IDs
        ...    ue_id=${ue_id}
        ...    trf_id_range_min=${trf_id_range_min}
        ...    trf_id_range_max=${trf_id_range_max}
        ...    direction=${direction}
        ...    pdu=${pdu}
    END
    wts_ue.UE Deregister  ue_id=${ue_id}


Stop DL UL Data Traffic On 3 PDU Sessions And Deregister UE
    [Arguments]      ${ue_id}
    FOR   ${trf_id_range_min}      ${trf_id_range_max}      ${direction}      ${pdu}      IN
    ...   1                        3                        dl                1
    ...   4                        6                        ul                1
    ...   1                        3                        dl                2
    ...   4                        6                        ul                2
    ...   1                        3                        dl                3
    ...   4                        6                        ul                3
        Stop SA Data Traffic In Egate On Multiple Traffic IDs
        ...    ue_id=${ue_id}
        ...    trf_id_range_min=${trf_id_range_min}
        ...    trf_id_range_max=${trf_id_range_max}
        ...    direction=${direction}
        ...    pdu=${pdu}
    END
    wts_ue.UE Deregister  ue_id=${ue_id}


Stop SA Data Traffic In Egate On Multiple Traffic IDs
    [Documentation]   Stoping SA Data Traffic in Egate on multiple traffic IDs
    [Arguments]      ${ue_id}   ${trf_id_range_min}   ${trf_id_range_max}   ${direction}   ${pdu}=1
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
           wts_ue.Stop Data Traffic In Egate   ue_id=${ue_id}  direction=${direction}  trf_id=${trf_id}  pdu=${pdu}
    END


Collect And Verify PM Counters For SA
    [Arguments]   ${test_instance}  ${pm_collector_alias}=gnb_pm_counters  ${dual_delta_commissioning}=${EMPTY}  ${pcell}=NRCELL-1
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${dual_delta_commissioning}
    PM Counter Verification  PM_dir=${pm_files}  pcell_list=${${test_instance}_PM_PCELL${dual_delta_commissioning}}  pcell=${pcell}


Collect PM Counters
    [Arguments]    ${collector_alias}
    ${log_dir}=    testline.Get Testcase Log Directory
    pmcounters.Wait Until The Current Measurement Period Stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}    collector_alias=${collector_alias}
    RETURN  ${pm_files}


PM Counter Verification
    [Documentation]    Verifying PM counters values
    [Arguments]    ${PM_dir}   ${pcell_list}   ${pcell}
    pmcounters.Verify PM Counter Reference Table  reference_table=${pcell_list}   pm_dir=${PM_dir}   distname_suffix=${pcell}


Setup For CB013859-B_IWK1
    [Documentation]    Perform TC Setup and change location of UE1 to camp on Cell-7
    Perform Preconditions Of Test Scenario
    Relocate UE To Different Cell   ue_id=1   enb_id=2   cell_id=7


Teardown For CB013859-B_IWK1
    [Documentation]    Perform TC Teardown and change location of UE1 to camp back on Cell-1 as part of TC Teardown if TC fails in between the test
    wts_ue.UE Deregister  ue_id=1
    Perform Postconditions Of Test Case
    Relocate UE To Different Cell   ue_id=1   enb_id=2   cell_id=1


Relocate UE To Different Cell
    [Documentation]    Change location of UE to camp on a different cell
    [Arguments]   ${ue_id}=1   ${enb_id}=2   ${cell_id}=1
    wts_ue.Send Egate Command And Verify Output   cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...                                    pass_regexp=(location updated to eNB-${enb_id} cell ${cell_id})|(already there)
