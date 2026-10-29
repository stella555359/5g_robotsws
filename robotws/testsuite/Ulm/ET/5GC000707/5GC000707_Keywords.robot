*** Settings ***
Documentation   This is a Robot Test Suite for feature 5GC000707 'InterRat HO LTE' testing
...             Link to Test Strategy: https://nokia.sharepoint.com/:w:/r/sites/MN5GSCProductization/Shared%20Documents/General/
...                                    5G%26SC%20Collaborator/5GC000600%E2%80%935GC000799/5GC000707/5GC000707_Feature_Test_Strategy.docx
...                                    ?d=w5d3c577623544040aa955e7c98eeb3b4&csf=1&web=1&e=Et8mkt
...             Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...             Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot
Resource    5GC000707_Commissioning.robot
Resource    5GC000707_Counters.robot

Library     taf.config.wts      WITH NAME    wts_conf
Library     taf.analyzer.pdml   WITH NAME    pdml_analyzer

*** Variables ***

${TEST_MODE}                  auto
${WTS_ALIAS}                  ap_egate           # from wts_ue.robot
${WTS_CFG_FILE}               basic_setup_707.cfg
${EGATE_CONSOLE_LOGFILE}      egate_console.log
@{UE_ID_LIST}                 1
@{5QI1_LIST}                  3

&{equiv_plmn1}=               mcc=111    mnc=111    mncLength=3
&{equiv_plmn2}=               mcc=222    mnc=222    mncLength=3

${B2_MEAS_VALUES}             nrsrp_nr=19 nrsrq_nr=17
${CELLINDIVIDUALOFFSET}       -24

${UE_CAPA_TDD}                SEPARATOR=
...                           ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF0A40003C170101E0935F3FFFB7C00B00101E76E0601F8E01945C003FE2F08EF2F82087FD50880
...                           0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F4517002FF8BC23BCBE0821FF54220033F653748F1893EB1893EAE3127D4624FA883
...                           C893E1228CB7CFD145C137FE2F08EF2F82087FD508800CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F251704EFF8BC23BCBE0821F
...                           F54220033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A3A000034030236C93E07FFFC000460007C0050
...                           38280381884C00E000F07C013200000019000000401E14DE54D0041000009659504000065965401D0AABA55543C006C007CDF80E03803CDF80E0380
...                           0000003002006008010D58300010205898D93BB80000001114

${UE_CAPA_FDD}                SEPARATOR=
...                           ue_nr_capabilities=E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F88DAC31B47498A823F
...                           96524CA01105B260901831E31FF9863CA160703878099D87619D876008006000000000E230000000020020237B0500603818078300500783E01C820
...                           0000148200000548200000949280000D300B81B791B5BA40141000009652404000065949010000296524040000E594941000049652424000154B292
...                           009A071748E2E8544D2A88AEC40107801A0100800000000002004008C4018000810180

*** Keywords ***

Prepare TL for 5GC000707
    [Documentation]   Prepare UTE TL for CB008146-F test
    ...    backup TL configurations, configure GNB with mobility profile, prepare WTS config file for
    Set Suite Variable  ${SUITE_SETUP_STATUS}  Start
    Sqd65 Common Setup
    ${CELL_TECHNOLOGY}=        wts_ue.Get cellTechnology Info
    Set Suite Variable        ${CELL_TECHNOLOGY}
    ${SW_BRANCH}=             testline.Get gNB SW Branch
    Set Suite Variable        ${SW_BRANCH}
    Commissioning
    Prepare WTS Config
    Bring Airphone TL to on Air
    Set Suite Variable        ${SUITE_SETUP_STATUS}  Finished

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'
    ...               Perform Preconditions of Test Scenario in Case of Previous TC failed
    Start Logging
    Set Suite Variable                     ${egate_console_log}    ${tl.core.dir_path}/${EGATE_CONSOLE_LOGFILE}

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air

Perform Postconditions of Test Scenario
    Collect Snapshots
    ${log_dir}=       Get Testcase Log Directory
    Get SCF from gNB  target_dir=${log_dir}
    Disconnect UE
    Stop Logging

Bring Airphone TL to on Air
    ute_workarounds.Bring Airphone TL to on Air status   force_cu_type=SA  cfg_file=${WTS_CFG_FILE}

Prepare WTS Config
    ${WTS_CFG_FILE}=             Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    Remove ENB from WTS config
    Remove NSA UEs from WTS config
    Add GNB-1 to WTS config
    wts_conf.Modify              set_amf_region id=1    tac_list=7627107,100,788,200,0,${EPS_TAC}
    FOR  ${id}  IN RANGE  1  10
        wts_conf.Modify          ue_param id=${id}      ${UE_CAPA_TDD} dual_conn=eutra_nr
    END
    wts_conf.Modify              ue_param id=51         ${UE_CAPA_FDD} dual_conn=eutra_nr
    wts_conf.Modify              ue_param id=52         ${UE_CAPA_FDD} dual_conn=eutra_nr
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE}  ${ts_conf_dir}

Collect Snapshots
    IF    '${TEST_MODE}' != 'snapshot'
            IF    '${TEST_STATUS}' == 'PASS' or '${TEST_MODE}' == 'manual'   RETURN
    END
    Collect AP Sos Report and Snapshots

Register UE
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${cell_id}=1
    Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ...                                    pass_regexp=(location updated to eNB-2 cell ${cell_id})|(already there)
    UE Register                            ue_id=${ue_id}
    Set Traffic Type                       ue_id=${ue_id}  pdu_id=${pdu_id}   trf_type=internal
    UE PDU Session Setup                   ue_id=${ue_id}  pdu=${pdu_id}
    Start Data Traffic In Egate            ue_id=${ue_id}  direction=dl   protocol=udp   trf_id=1   pdu=${pdu_id}  qfi=1   mbps=1

Disconnect UE
    [Arguments]
    FOR  ${ue_id}  IN   @{UE_ID_LIST}
       Send Egate Command and verify output   cmd=ue_kill id=${ue_id}
       ...                                    pass_regexp=(silently killed|UE may be OFF or killed)
    END

Send Measurement Report
    [Arguments]    ${event}  ${meas_values}=${EMPTY}   ${ue_id}=1  ${pass_regexp}=EGATE>  ${fail_regexp}=None  ${timeout}=10s
    ${meas_id}=    Get Measurement id      event=${event}  ue_id=${ue_id}
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ute_wtssim.execute egate command       cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} ${meas_values}
    ...                                    pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}  timeout=${timeout}  alias=${WTS_ALIAS}
    Sleep   1
    Run Keyword And Ignore Error           Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   set_log flush

Verify Measurement is configured
    [Arguments]  ${event}  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event}

Verify Measurement is absent
    [Arguments]  ${event}  ${ue_id}=1
    ${meas_info}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    ${status}=  Run Keyword and Return Status
    ...  Should Match Regexp  ${meas_info}  ${event}
    IF   ${status}  Fail  Unexpected ${event} measurement found

Collect PMCounters
    [Arguments]    ${target_dir}=None
    ${log_dir}=    IF    '${target_dir}'=='None'  testline.Get Testcase Log Directory
    ...            ELSE                           Set Variable   ${target_dir}
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}
    RETURN  ${pm_files}

Activate DRX
    Update SCF param   param=actCDrx  value=true   dist_name=NRBTS-1/NRCELL-1

DeActivate DRX
    Update SCF param   param=actCDrx  value=false  dist_name=NRBTS-1/NRCELL-1

Update SCF param
    [Arguments]   ${dist_name}  ${value}  ${param}
    connect.Setup OAM HTTP Session
    Update SCF parameter   dist_name=${dist_name}     parameter=${param}   value=${value}

Verify PM Counters
    [Arguments]       ${tc}  ${dn_suffix}=1  ${target_cell}=${LTE_LCI_1}  ${target_mcc}=${sa_plmn['mcc']}  ${target_mnc}=${sa_plmn['mnc']}
    ${pm_files}=      Collect PMCounters
    ${counter_var}=   Get Variable Value   ${${tc}_COUNTERs}
    Verify PM Counter Reference Table  reference_table=${counter_var}  pm_dir=${pm_files}   distname_suffix=${dn_suffix}

    ${counter_var}=   Get Variable Value   ${${tc}_NREMO_COUNTERs}
    IF    "${counter_var}" != "None"
          ${nremo_dn}=  Get NREMO Counters DN   target_cell=${target_cell}  target_mcc=${target_mcc}  target_mnc=${target_mnc}  dn_suffix=${dn_suffix}
          Verify PM Counter Reference Table  reference_table=${counter_var}  pm_dir=${pm_files}   distname_suffix=${nremo_dn}
    END

Activate InterRAT HO Failure
    [Arguments]  ${action_cause}
    ute_wtssim.execute egate command   cmd=amf_ue_ng_handover_param id=1 ue=1 ${action_cause}  timeout=1s  alias=${WTS_ALIAS}
    ute_wtssim.execute egate command   cmd=amf_ue_ng_handover_param id=1 ue=1                  timeout=1s  alias=${WTS_ALIAS}

Set NG HO Preparation Timer
    [Arguments]  ${value}=2000
    Update SCF param   param=tNgRelocPrep  value=${value}  dist_name=NRBTS-1

Set NG Overall HO Procedure Timer
    [Arguments]  ${value}=2000
    Update SCF param   param=tNgRelocOverall  value=${value}  dist_name=NRBTS-1

InterRAT HO
    [Arguments]  ${ue_id}=1  ${phy_cell_id}=${LTE_PCI_1}  ${timeout}=10s
    ...          ${pass_regexp}=IRAT Handover from NR to EUTRA completed  ${fail_regexp}=None
    Serving becomes worse than threshold  ue_id=${ue_id}
    Sleep  1
    PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    ...   ue_id=${ue_id}
    ...   b2_meas_values=phycell_id=${phy_cell_id} ${B2_MEAS_VALUES}   pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}  timeout=${timeout}

InterRAT HO with unknown PCI
    Serving becomes worse than threshold
    Sleep  1
    PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    ...   b2_meas_values=phycell_id=21 ${B2_MEAS_VALUES}    pass_regexp=None   fail_regexp=rrcReconfigurationComplete
    Verify Measurement is configured   event=B2
    Verify Measurement is configured   event=A1

InterRAT HO with low RSRP
    Serving becomes worse than threshold
    Sleep  1
    PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    ...   b2_meas_values=phycell_id=${LTE_PCI_1} ${B2_MEAS_VALUES}    pass_regexp=${None}  fail_regexp=rrcReconfigurationComplete
    ...   timeout=3s
    Verify Measurement is configured   event=B2
    Verify Measurement is configured   event=A1

InterRAT HO Preparation
    Activate InterRAT HO Failure   action=no_response
    InterRAT HO                    pass_regexp=HandoverRequest for UE with AMF UE ID \\d+ and RAN UE ID \\d+ will not be sent

InterRAT HO Cancelled by A1
    ${meas_id}=  Get Measurement id        event=A1
    Send Egate Command and verify output   cmd=ue_measurement_send_nr meas_id=${meas_id} event=A1 id=1
    ...                                    pass_regexp=Received Handover Cancel from GNB-2 with Cause: RAN handover cancelled
    Sleep   1
    Verify Measurement is configured       event=A2
    Verify Measurement is absent           event=A1
    Verify Measurement is absent           event=B2

InterRAT HO Preparation Failure
    [Arguments]   ${cause}
    Activate InterRAT HO Failure   action=ho_preparation_failure cause=${cause}
    InterRAT HO                    pass_regexp=Forced Handover Preparation Failure
    Sleep  1

Serving becomes worse than threshold
    [Arguments]    ${ue_id}=1
    Verify Measurement is configured       event=A2    ue_id=${ue_id}
    Send Measurement Report                event=A2    ue_id=${ue_id}
    Verify Measurement is configured       event=B2    ue_id=${ue_id}
    Verify Measurement is configured       event=A1    ue_id=${ue_id}
    Verify Measurement is absent           event=A2    ue_id=${ue_id}

Serving becomes better than threshold
    [Arguments]    ${ue_id}=1
    Send Measurement Report                event=A1    ue_id=${ue_id}
    Verify Measurement is configured       event=A2    ue_id=${ue_id}
    Verify Measurement is absent           event=A1    ue_id=${ue_id}
    Verify Measurement is absent           event=B2    ue_id=${ue_id}

PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    [Arguments]   ${ue_id}=1  ${b2_meas_values}=phycell_id=${LTE_PCI_1} ${B2_MEAS_VALUES}  ${timeout}=10s
    ...           ${pass_regexp}=IRAT Handover from NR to EUTRA completed  ${fail_regexp}=None
    Send Measurement Report    event=B2   ue_id=${ue_id}    meas_values=${b2_meas_values}
    ...                        pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}  timeout=${timeout}

Intra-frequency Intra-DU Intra-gNB Handover
    [Documentation]  with 4 cells configuration, FDD is from cell 4 (phycell 53) to cell 3 (phycell 52)
    ...    TDD is from cell 2 (phycell 51) to cell 1 (phycell 50)
    [Arguments]   ${ue_id}=2    ${phycell_id}=52
    Send Measurement Report    event=A3  ue_id=${ue_id}   meas_values=phycell_id=${phycell_id}
    ...                        pass_regexp=Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB-2.3 performed   fail_regexp=None

Get Measurement id
    [Arguments]  ${event}  ${ue_id}=1
    ${measurements}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  Event${event}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    RETURN  ${words}[0]

Remove NSA UEs from WTS config
    ${NSA_UE_IDs}=
    ...  Run   bash -c "grep dual_conn=eutra_nr ${tl.core.dir_path}/${tl.core.cfg_filename} | sed -e 's/^.* id=\\\\([0-9]*\\\\) .*$/\\\\1/'"
    @{NSA_UE_ID_LIST}=  Split to lines  ${NSA_UE_IDs}
    FOR  ${nsa_ue_id}  IN   @{NSA_UE_ID_LIST}
        ${present}=  wts_conf.get  set_ue simulated id=${nsa_ue_id}
        IF   '${present}' != 'None'
            wts_conf.delete    set_ue simulated id=${nsa_ue_id}
            wts_conf.delete    ue_param id=${nsa_ue_id}
            wts_conf.delete    set_pdu_gateway id=${nsa_ue_id}
            wts_conf.delete    set_bearer id=2 ue=${nsa_ue_id}
        END
    END

Remove ENB from WTS config
    wts_conf.delete              set_enb id=1
    wts_conf.delete              enb_param id=1
    wts_conf.delete              set_cell id=1 enb=1
    wts_conf.delete              enb_endc_param id=1
    wts_conf.delete              mme_pool_area id=1
    wts_conf.delete              set_mme id=1
    wts_conf.delete              set_sgw id=1
    wts_conf.delete              set_pgw id=1

Add GNB-1 to WTS config
    ${gnb-1}=             Catenate
    ...                   type=simulated plmn=${sa_plmn['mcc']}:${sa_plmn['mnc']}
    ...                   ng=$ENB1_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${gnb-1_cell-1}=      Catenate
    ...                   gnb=1 pci=3:2 tac=${EPS_TAC} nrci=0x01 tdd_cell=on earfcn=1:18001
    ...                   proxy=$SERVER_IP:12219 bw=20MHz technology=lte mandatory_for_activation=off
    ${gnb-1_cell-2}=      Catenate
    ...                   gnb=1 pci=7:1 tac=${EPS_TAC} nrci=0x02 tdd_cell=on earfcn=1:18001
    ...                   proxy=$SERVER_IP:12220 bw=20MHz technology=lte mandatory_for_activation=off

    wts_conf.insert       set_gnb id=1 ${gnb-1}                   before  set_uec id=1
    wts_conf.insert       set_cell id=2 ${gnb-1_cell-2}           after   set_gnb id=1
    wts_conf.insert       set_cell id=1 ${gnb-1_cell-1}           after   set_gnb id=1
    wts_conf.insert       gnb_param id=1 xn_listening_socket=off  after   set_gnb id=1

Verify DRX Values
    ${drxOnDurationTimer}   Remove String  ${nrDrx['drxOnDurationTimer']}  ms
    ${drxInactivityTimer}   Remove String  ${nrDrx['drxInactivityTimer']}  ms
    ${drxLongCycle}         Remove String  ${nrDrx['drxLongCycle']}        ms
    ${drxRetransTimerDl}    Remove String  ${nrDrx['drxRetransTimerDl']}   slot
    ${drxRetransTimerUl}    Remove String  ${nrDrx['drxRetransTimerUl']}   slot
    @{drx_cfg_seq}=   Create List
    ...               rrcReconfiguration
    ...               mac-CellGroupConfig
    ...               drx-Config setup
    ...               drx-onDurationTimer milliSeconds : ms${drxOnDurationTimer}
    ...               drx-InactivityTimer ms${drxInactivityTimer}
    ...               drx-RetransmissionTimerDL sl${drxRetransTimerDl}
    ...               drx-RetransmissionTimerUL sl${drxRetransTimerUl}
    ...               drx-LongCycleStartOffset ms${drxLongCycle} : \\d+
    ...               rrcReconfigurationComplete
    ...               gapUE  YES
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${egate_console_log}  @{drx_cfg_seq}

Pcap To Pdml
    [Arguments]  ${packet_filter}=ngap
    ${log_dir}=              testline.Get Testcase Log Directory
    ${sctp_pcap}=            tcpdump.Stop Tcpdump on TestPc    target_dir=${log_dir}
    Convert PCAP to PDML     source=${sctp_pcap}  target=${log_dir}/${packet_filter}.pdml  filter=${packet_filter}
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 -U sctp
    RETURN  ${log_dir}/${packet_filter}.pdml

Verify UE Context Release Cause
    ${ngap_pdml_file}=       Pcap To Pdml
    @{pattern_list}=         Create List
    ...                      ngap.UEContextReleaseRequest_element
    ...                      radioNetwork: tngrelocoverall-expiry
    ...                      ngap.UEContextReleaseCommand_element
    ...                      radioNetwork: tngrelocoverall-expiry
    Verify Sequence in File  ${ngap_pdml_file}  @{pattern_list}

Set Target Cell as blacklisted
    Update SCF param   param=eutranCellExcluded  value=true  dist_name=NRBTS-1/NRCELL-1/NRRELE-1

UnSet Target Cell as blacklisted
    Update SCF param   param=eutranCellExcluded  value=false  dist_name=NRBTS-1/NRCELL-1/NRRELE-1

Set Mobility Restriction
    [Arguments]  ${mobility_restriction}  ${ue_id}=1
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=${mobility_restriction}
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_mobility_restriction_list_param id=${ue_id}
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_ue_ics_param id=${ue_id} mobility_restriction_list_id=1
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_ue_ics_param id=${ue_id}

UnSet Mobility Restriction
    [Arguments]  ${ue_id}=1
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_ue_ics_param id=${ue_id} reset
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_ue_ics_param id=${ue_id}

Verify Black Cell Config
    @{black_cell_cfg_seq}=   Create List
    ...               rrcReconfiguration
    ...               measConfig
    ...               measObjectToAddModList
    ...               measObject measObjectEUTRA
    ...               excludedCellsToAddModListEUTRAN
    ...               cellIndexEUTRA
    ...               physCellIdRange
    ...               start ${LTE_PCI_1}
    ...               rrcReconfigurationComplete
    ...               Black cells for object \\d
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${egate_console_log}  @{black_cell_cfg_seq}

Verify Config Values
    # only gap values random sample selected (values taken from:5G_RAN_CP_35298, regarding UE Capa)
    @{cfg_vals}=   Create List
    ...            gapUE\\s+YES\\s+20\\s+3 ms\\s+80 ms\\s+0 ms
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${egate_console_log}  @{cfg_vals}

Get NREMO Counters DN
    [Arguments]  ${target_cell}=${LTE_LCI_1}  ${target_mcc}=${sa_plmn['mcc']}  ${target_mnc}=${sa_plmn['mnc']}  ${dn_suffix}=1
    ${enb_id_hex}=            Convert To Hex       ${ENB_ID}        length=2
    ${enb_lci_hex}=           Convert To Hex       ${target_cell}   length=2
    ${eci}=                   Convert To Integer   0x${enb_id_hex}${enb_lci_hex}
    ${nremo_counters_dn}      Catenate    SEPARATOR=
    ...                       MRBTS-1/NRBTS-1/NRCELL-${dn_suffix}/PLMN-PLMN/MCC-${sa_plmn['mcc']}/MNC-${sa_plmn['mnc']}/
    ...                       PLMN-PLMN/ECI-${eci}/PLMN-PLMN/MCC-${target_mcc}/MNC-${target_mnc}
    RETURN  ${nremo_counters_dn}

Enable UE Capa in ICS
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_ue_ics_param id=1 include_ue_capabilities=on
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=amf_ue_ics_param id=1

Verify widebandRSRQ-Meas
    @{cfg_vals}=   Create List
    ...            rrcReconfiguration
    ...            measConfig
    ...            measObjectToAddModList
    ...            measObject measObjectEUTRA
    ...            widebandRSRQ-Meas TRUE
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${egate_console_log}  @{cfg_vals}

Apply Config for 5GC000707-H
    ${actMFBIEutra}=            Create Dictionary  parameter=actMFBIEutra            value=true   dist_name=NRBTS-1
    ${earfcnValue_nradjcell}=   Create Dictionary  parameter=earfcnValue             value=2000   dist_name=NRBTS-1/NRADJECELL-1
    ${eUtraMBIL_elements}=      Create List        1
    ${eUtraMultibandInfoList}=  Create Dictionary  parameter=eUtraMultibandInfoList  value=${eUtraMBIL_elements}      dist_name=NRBTS-1/NRADJECELL-1
    ${earfcnValue_nrhoir}=      Create Dictionary  parameter=earfcnValue             value=2000   dist_name=NRBTS-1/NRHOIR-1
    ${para_list}=               Create List
    ...                         ${actMFBIEutra}  ${earfcnValue_nradjcell}  ${earfcnValue_nrhoir}
    ...                         ${actMFBIEutra}  ${earfcnValue_nradjcell}  ${eUtraMultibandInfoList}  ${earfcnValue_nrhoir}

    Update SCF Parameters     ${para_list}

Verify Eutra Measurement Object
    @{cfg_vals}=   Create List
    ...            rrcReconfiguration
    ...            measConfig
    ...            measObjectToAddModList
    ...            measObject measObjectEUTRA
    ...            carrierFreq 50                  # 5G_CP_IF_RRC_1650
    ...            allowedMeasBandwidth ${nrhoir1['allowedMeasBandwidth']}
    ...            widebandRSRQ-Meas ${nrhoir1['widebandRsrqMeas']}
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${egate_console_log}  @{cfg_vals}

Apply Config for CB006966-E-B1
    ${cellIndividualOffset}=    Create Dictionary  parameter=cellIndividualOffset      value=${CELLINDIVIDUALOFFSET}dB
    ...                         dist_name=NRBTS-1/NRCELL-1/NRRELE-1
    ${eutraFreqQOffsetRange}=   Create Dictionary  parameter=eutraFreqQOffsetRange     value=${nrhoir1['eutraFreqQOffsetRange']}dB
    ...                         dist_name=NRBTS-1/NRHOIR-1
    ${para_list}=               Create List
    ...                         ${cellIndividualOffset}  ${eutraFreqQOffsetRange}

    Update SCF Parameters     ${para_list}

Verify Eutra Measurement Object E-B1
    @{cfg_vals}=   Create List
    ...            rrcReconfiguration
    ...            measConfig
    ...            measObjectToAddModList
    ...            measObject measObjectEUTRA
    ...            carrierFreq ${EARFCN}
    ...            allowedMeasBandwidth ${nrhoir1['allowedMeasBandwidth']}
    ...            cellsToAddModListEUTRAN
    ...            cellIndexEUTRA \\d
    ...            physCellId ${LTE_PCI_1}
    ...            cellIndividualOffset dB${CELLINDIVIDUALOFFSET}
    ...            eutra-Q-OffsetRange dB${nrhoir1['eutraFreqQOffsetRange']}
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${egate_console_log}  @{cfg_vals}

A1 Measurement Report with wrong servCellId
    [Arguments]  ${ue_id}=1
    # A1 Measurement Report with wrong servCellId (servCellId=5 instead of 0)
    ${serv_cell_id}=  Set Variable  5
    ${meas_id}=       Get Measurement id   event=A1  ue_id=${ue_id}
    ${meas_id}=       Evaluate  ${meas_id} - 1
    ute_wtssim.execute egate command    cmd=ue_ul_dcch_send id=${ue_id} type=MeasurementReport hex=000${measid}00${serv_cell_id}432D94288180000
    ...                                 timeout=5s  alias=${WTS_ALIAS}   fail_regexp=rrcReconfigurationComplete

Apply Config according CNI
    [Arguments]   ${ue_id}=51    ${dist_name}=NRBTS-1/NRCELL-3
    ${cni_ue_nr_capa}=  Catenate  SEPARATOR=
    ...  E9A01000074F5A1302000201404824C5800260D40C13601873E618F28581C130080C4700AA05899AC1184341020F94022CB64C550D0E7C471E819F604F8C73E618F2858
    ...  1C0E1E1380024000E000900003801C0A81E0DEB04610D04083E500892D931541439F11C78C73E618F28581C0E1E04F80000003E00000000E00702A07805AC1184341020
    ...  F940224B64C55050E7C471E31CF9863CA16070387813F8000000FE00000003801C00200383600000000E26000001003006E0260281701409DB1CF870276C73E19E81601
    ...  C00140E060180C01501C00180300C0281F00C01000000008000010040000100200000C03654D6025606D60CD00C1000009652404000065949010000296524040000E594
    ...  900352A88A031140E2283440107801D0381C0E0000040020080100040080118A11000102030406070A0B0C101112131B25282940

    ${scf_file}=            Load current SCF
    scf.modify_scf_element  dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     list_name=coresetDedicated  p_name=size     value=48
    Set Element             dist_name=${dist_name}                               p_name=reqMinNumPuschPrb    value=46
    Set Element             dist_name=${dist_name}                               p_name=freqBandIndicatorNR  value=28
    Set Element             dist_name=${dist_name}/NRCELL_FDD-1                  p_name=chBwDl               value=10MHz
    Set Element             dist_name=${dist_name}/NRCELL_FDD-1                  p_name=chBwUl               value=10MHz
    Set Element             dist_name=NRBTS-1/NRSYSINFO_PROFILE-2/NRIRFIM-1      p_name=freqBandIndicatorNR  value=28
    Apply Delta SCF         ${scf_file}  scf_CNI-76790

    Bring Airphone TL to on Air
    Start F1AP capturing

    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=ue_param id=${ue_id} ue_nr_capabilities=${cni_ue_nr_capa}
    ute_wtssim.execute egate command   timeout=1s  alias=${WTS_ALIAS}   cmd=ue_param id=${ue_id}

Apply Config for CB006966-E-B3
    ${cellIndividualOffset}=    Create Dictionary  parameter=cellIndividualOffset    value=-3dB           dist_name=NRBTS-1/NRCELL-1/NRRELE-1
    ${b2MeashoEnabled}=         Create Dictionary  parameter=b2MeashoEnabled         value=rsrqCombined   dist_name=NRBTS-1/NRHOIR-1
    ${eutraFreqQOffsetRange}=   Create Dictionary  parameter=eutraFreqQOffsetRange   value=4dB            dist_name=NRBTS-1/NRHOIR-1
    ${para_list}=               Create List
    ...                         ${cellIndividualOffset}  ${b2MeashoEnabled}  ${eutraFreqQOffsetRange}

    Update SCF Parameters     ${para_list}

Apply Config for 5GC000707-D-B31
    ${sa_plmn_list}=          Create List  ${sa_plmn}
    ${equiv_plmn1_list}=      Create List  ${equiv_plmn1}
    ${equiv_plmn2_list}=      Create List  ${equiv_plmn2}
    ${nrrele1_ecgiPlmn}=      Create Dictionary  parameter=ecgiPlmn   value=${equiv_plmn1_list}  dist_name=NRBTS-1/NRCELL-1/NRRELE-1
    ${nrrele2_ecgiPlmn}=      Create Dictionary  parameter=ecgiPlmn   value=${equiv_plmn2_list}  dist_name=NRBTS-1/NRCELL-1/NRRELE-2
    ${nradjecell1_ecgiPlmn}=  Create Dictionary  parameter=ecgiPlmn   value=${equiv_plmn1_list}  dist_name=NRBTS-1/NRADJECELL-1
    ${nradjecell1_enbPlmn}=   Create Dictionary  parameter=enbPlmn    value=${sa_plmn_list}      dist_name=NRBTS-1/NRADJECELL-1
    ${nradjecell2_ecgiPlmn}=  Create Dictionary  parameter=ecgiPlmn   value=${equiv_plmn2_list}  dist_name=NRBTS-1/NRADJECELL-2
    ${nradjecell2_enbPlmn}=   Create Dictionary  parameter=enbPlmn    value=${sa_plmn_list}      dist_name=NRBTS-1/NRADJECELL-2
    ${para_list}=             Create List
    ...                       ${nrrele1_ecgiPlmn}      ${nrrele2_ecgiPlmn}
    ...                       ${nradjecell1_ecgiPlmn}  ${nradjecell1_enbPlmn}
    ...                       ${nradjecell2_ecgiPlmn}  ${nradjecell2_enbPlmn}

    Update SCF Parameters     ${para_list}

Verify Target Cell ID
    [Arguments]  ${target_cell_id}
    ${ngap_pdml_file}=  Pcap To Pdml      packet_filter=ngap
    ${target_cells}=    Get Pdml Entries  file_name=${ngap_pdml_file}  field_name=s1ap.CellIdentity  attrib_name=show  attrib_value=${target_cell_id}
    ${cnt}=             Get length  ${target_cells}
    IF      ${cnt} == 0   Fail  InterRatHO: Target Cell ID not found


Update SCF Parameters
    [Arguments]  ${para_list}
    connect.Setup OAM HTTP Session
    Update List of SCF parameters   ${para_list}  timeout=300

Delay AMF initiated NGAP UE Context Release Command
    [Arguments]  ${delay}=1s
    Send Egate Command and verify output   amf_timer T_Local=${delay}
    Send Egate Command and verify output   amf_timer

Setup VoNR Call
    [Arguments]  ${ue_id}=3
    Update SCF param                          param=actVoNR  value=true   dist_name=NRBTS-1/NRCELL-1  #  Activate VoNR
    Send Egate Command and verify output      ue_param id=${ue_id} nr_usage_setting=voice_centric
    Send Egate Command and verify output      qosflow_modify qos_flow=2 ue=${ue_id} default=on
    Send Egate Command and verify output      ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-VoiceCall
    Register UE                               ue_id=${ue_id}
    UE PDU Session Modify                     ue_id=${ue_id}  qos_flow_list=@{5QI1_LIST}  by=amf
    Start data traffic in egate               ue_id=${ue_id}  direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=2   mbps=1   size=100
    Start data traffic in egate               ue_id=${ue_id}  direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=3   mbps=1   size=100

Set Reporting Interval
    [Arguments]  ${interval}=15
    ${reportingInterval}=       Create Dictionary  parameter=reportingIntervalPm    value=${interval}min    dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
    ${miNrNGCC}=                Create Dictionary  parameter=miNrNGCC               value=${interval}min    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ${para_list}=               Create List        ${reportingInterval}  ${miNrNGCC}
    ${miNRs}=                   Create List        miNrBeamforming  miNrCaCu  miNrCaDu  miNrCellUtilization  miNrDlHarq  miNrDlSignalQuality
    ...                         miNrE1InterfaceBts  miNrE1InterfaceCuCpNsa  miNrE1InterfaceCuCpSa  miNrE1InterfaceCuUp  miNrE1InterfaceCuUpNsa
    ...                         miNrE1InterfaceCuUpSa  miNrEcpriUpFCp  miNrEirp  miNrEnDssPerCell  miNrF1CC  miNrF1CD  miNrF1UCInterface
    ...                         miNrF1UDInterface  miNrF1UU  miNrGnss  miNrHighRlcReport  miNrIfPsCellChange  miNrHoInterruptCuUp  miNrLowRlcReport
    ...                         miNrLteMgPerCell  miNrLteMobilityReport  miNrMacPduTput  miNrMacSduReport  miNrMgPerCell  miNrMobilityReport
    ...                         miNrMobilityReportCu  miNrMobilityReportDu  miNrNAECL  miNrNeighborNrNrCuSa  miNrNgInterface  miNrNgUReport
    ...                         miNrNREMO  miNrPaging  miNrPDCP1Report  miNrPDCP2Report  miNrPDCP2Report  miNrPdcpC  miNrPsCellChange  miNrRacCu
    ...                         miNrRacDu  miNrRachUsage  miNrRadBearer  miNrRANS  miNrRelReportCu  miNrRlfPerCell  miNrRRCC
    ...                         miNrRRCD  miNrRSACU  miNrRSADU  miNrRSANB  miNrRSUP  miNrS1UInterface
    ...                         miNrSlicingCuCp  miNrSlicingCuUp  miNrSrb3C  miNrSrb3D  miNrSrvcAvaStats  miNrTimingAdvance  miNrUeState  miNrUlHarq
    ...                         miNrUlSignalQuality  miNrX2CB  miNrX2CC  miNrX2UInterface  miNrXnCCInterface  miNrXnInterface
    ...                         miNrNTRAF  miNrCellAvailability
    FOR  ${miNr}  IN  @{miNRs}
        ${miNrDict}=            Create Dictionary  parameter=${miNr}        value=disabled          dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
        Append To List          ${para_list}  ${miNrDict}
    END

    Update SCF Parameters     ${para_list}
    Set Suite Variable        &{P_MEAS_PERIOD}        &{EMPTY}
    Wait until the next Measurement Period starts
