*** Settings ***
Documentation   This is a Robot Test Suite for Feature 5GC001927_Q 'Concurrency Handling'
...             Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...             Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    ../../resources/SQD65/sqd65_commissioning.robot
Library     taf.analyzer.pdml
Library     taf.config.wts      WITH NAME    wts_conf
Library     5GC001927-Q.py

*** Variables ***

${EGATE_5G_ATTACH}            reported successful RA
${EGATE_TRF_STOPPED}          Traffic was stopped
${X2_LOG_DIR}                 /tmp
${X2_LOG_FILE}                x2_trace.pcap
${DEFAULT_DATA_RATE}          500	# kbps
${MAX_PACKET_LOST}            100
${VARIANCE}                   10
${TRAFFIC_DURATION}           25s
${WTS_CFG_TMP_FILE}           wts_tmp.cfg
${TEST_MODE}                  auto
${UE_ID}                      151
${SUITE_STATE}                NOK
${WTS_CFG_FILE}               basic_setup_1927-Q.cfg


*** Keywords ***


Common Suite Setup
    ute_workarounds.Log TL Info as Metadata for UTE AP TL
    Create Test Suite Log Folders
    Check UeType
    Check TL Infos
    UTE Cloud Workaround
    Prepare WTS config
    Set Syslog Level in gNB swconfig
    Bring Airphone TL to on Air status   cfg_file=${WTS_CFG_FILE}
    Activate 5GC001927 Feature
    ute_tshark.Setup Tshark              interface=any   alias=tshark
    Set Suite Variable  ${SUITE_STATE}   OK


Common Suite Teardown
    IF  '${SUITE_STATE}'=='NOK'   Snapshot  level=TEST_SUITE


Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    Start EGATE Logs
    Start X2 Trace
    Attach UE to LTE and Start Traffic
    Add Bearer and Start Traffic             bearer=3


Perform Postconditions of Test Scenario
    Stop Traffic
    Detach UE from LTE    ue_id=${UE_ID}
    Collect EGATE Logs
    Stop X2 Trace
    Run Keyword If Test Failed    Snapshot
    Run Keyword and Warn on Failure    Set SCOUT TC ID for Reporting


Prepare WTS config
    ${WTS_CFG_FILE}=             Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.Modify              enb_param id=1      endc_capable_qci=all
    wts_conf.insert              enb_timer T_DC_Overall=5000ms            after  enb_param id=1
    wts_conf.insert              enb_timer T_DC_Prep=5000ms               after  enb_param id=1
    wts_conf.insert              set_bearer id=5 ue=${UE_ID} qci=8 pdn=1  after  set_bearer id=2 ue=${UE_ID}
    wts_conf.insert              set_bearer id=4 ue=${UE_ID} qci=7 pdn=1  after  set_bearer id=2 ue=${UE_ID}
    wts_conf.insert              set_bearer id=3 ue=${UE_ID} qci=6 pdn=1  after  set_bearer id=2 ue=${UE_ID}
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE}  ${ts_conf_dir}

Snapshot
    [Arguments]  ${level}=TEST_CASE
    ${log_dir}=        IF  '${level}'=='TEST_SUITE'  Get Testsuite Log Directory
    ...                ELSE                                      Get Testcase Log Directory
    Run Keyword And Ignore Error    wts_ue.Collect sos report logs   target_dir=${log_dir}
    Run Keyword And Ignore Error    collect snapshot from gnb        target_dir=${log_dir}


Verify Message Sequence for SgNBModification Before Cases
    ${message_sequence}=                     Catenate
    ...                                      SgNBModificationRequest
    ...                                      SgNBModificationRequest
    ...                                      SgNBModificationRequestAcknowledge
    ...                                      SgNBReconfigurationComplete
    Verify Message Sequence In X2 Trace      messages=${message_sequence}
    Verify Message Sequence Not In X2 Trace  messages=SgNBModificationReject
    Verify Message Sequence Not In X2 Trace  messages=ErrorIndication


Verify Message Sequence for SgNBModification After Cases
    ${message_sequence}=                     Catenate
    ...                                      SgNBModificationRequest
    ...                                      SgNBModificationRequestAcknowledge
    ...                                      SgNBModificationRequest
    ...                                      SgNBReconfigurationComplete
    ...                                      SgNBModificationRequestAcknowledge
    ...                                      SgNBReconfigurationComplete
    Verify Message Sequence In X2 Trace      messages=${message_sequence}
    Verify Message Sequence Not In X2 Trace  messages=SgNBModificationReject
    Verify Message Sequence Not In X2 Trace  messages=ErrorIndication


Verify Message Sequence In X2 Trace
    [Arguments]  ${messages}=none
    ${pdml_file}=                          Convert X2 Trace
    Verify Message Sequence In PDML File   pdml_file=${pdml_file}   messages=${messages}


Verify Message Sequence Not In X2 Trace
    [Arguments]  ${messages}=none
    ${pdml_file}=                              Convert X2 Trace
    Verify Message Sequence Not In PDML File   pdml_file=${pdml_file}   messages=${messages}


Verify Traffic On 4G only
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=2
    Send Egate Command and verify output    cmd=bearer_disp ue=${ue} at=enb
    ${bearer_start}   ${bearer_stop}        Bearer List   ${bearer}
    FOR  ${b}   IN RANGE   ${bearer_start}   ${bearer_stop}+1
        Verify Bearer Stats                bearer=${b}  direction=dl  dc_cell_group=mcg
        Run Keyword And Ignore Error       Verify Bearer Stats        bearer=${b}  direction=ul  dc_cell_group=mcg
    END

Bearer List
    [Arguments]  ${bearer_list}=2
    ${rc}=               Evaluate   "-" in "${bearer_list}"
    ${start}  ${stop}=   IF     ${rc}==True  Split String   ${bearer_list}   -
    ${bearer_start}=     Set Variable if    ${start}!=None   ${start}
    ...                                     ${start}==None   ${bearer_list}
    ${bearer_stop}=      Set Variable if    ${stop}!=None    ${stop}
    ...                                     ${stop}==None    ${bearer_list}
    RETURN  ${bearer_start}  ${bearer_stop}


Verify Traffic On 5G only
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=2
    Send Egate Command and verify output    cmd=bearer_disp ue=${ue} at=enb
    ${bearer_start}   ${bearer_stop}=       Bearer List   ${bearer}
    FOR  ${b}   IN RANGE   ${bearer_start}   ${bearer_stop}+1
        Verify Bearer Stats                bearer=${b}  direction=dl  dc_cell_group=scg
        Run Keyword And Ignore Error       Verify Bearer Stats        bearer=${b}  direction=ul  dc_cell_group=mcg
    END

Verify Bearer Stats
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=2  ${direction}=dl  ${dc_cell_group}=mcg  ${kbps}=${DEFAULT_DATA_RATE}
    ${bearer_stats}=          Send Egate Command and verify output
    ...                       cmd=bearer_stats ue=${ue} id=${bearer} dir=${direction} dc_cell_group=${dc_cell_group}
    ...                       pass_regexp=EGATE>
    ${_}   ${dataRate}=       Should Match Regexp   ${bearer_stats}   Average data rate +(\\d+) .+\\r
    ${data_rate_limit}=       Evaluate   ${kbps}*1000-${kbps}*1000/100*${VARIANCE}
    Should Be True            ${dataRate} >= ${data_rate_limit}
    ${_}  ${packet_lost}=     Should Match Regexp       ${bearer_stats}   Total packets lost +(\\d+) +\\r
    Should Be True            ${packet_lost} < ${MAX_PACKET_LOST}


Check UeType
    ${ue_type}       Get UE type
    Should Be Equal  ${ue_type}  airphone


Activate 5GC001927 Feature
    ${scf_file}=              Load current SCF
    Set Element               dist_name=NRBTS-1     p_name=actMultiDrbNSA    value=true
    Apply Delta SCF           ${scf_file}  scf_5GC001927

Start X2 Trace
    ${X2_LOG_DIR}=            Get Testcase Log Directory
    Set Test Variable         ${X2_LOG_FILE}   ${X2_LOG_DIR}/${X2_LOG_FILE}
    ute_tshark.start capturing    capture_filter=sctp   log_dir=${X2_LOG_DIR}   log_name=${X2_LOG_FILE}   alias=tshark


Convert X2 Trace
    Stop X2 Trace
    Set Test Variable        ${pdml_file}   ${X2_LOG_FILE}.pdml
    ${result}  ${_}=         Run Keyword And Ignore Error    File Should Not Exist   ${pdml_file}
    IF           '${result}'=='PASS'
    ...                      ute_tshark.read pcap and save to file
    ...                      pcap_file_path=${X2_LOG_FILE}  filename=${PDML_FILE}  output_type=pdml  packet_filter=x2ap  alias=tshark
    RETURN  ${pdml_file}


Stop X2 Trace
    ute_tshark.stop capturing      alias=tshark


Activate Failure Scenario
    [Arguments]  ${ue}=${UE_ID}  ${enb}=1  ${rrc_delay}=0  ${menb_failure_scenario}=no_menb_failure_scenario  ${menb_forced_scenario}=none
    ...          ${abnormal_scenario}=disable
    Send Egate Command and verify output   cmd=enb_param id=${enb} x2_sctp_nodelay=on                                        timeout=1s
    Send Egate Command and verify output   cmd=enb_param id=${enb}                                                           timeout=1s
    Send Egate Command and verify output   cmd=enb_endc_param id=${enb} drb_change=on                                        timeout=1s
    Send Egate Command and verify output   cmd=enb_endc_param id=${enb} menb_failure_scenario=${menb_failure_scenario}       timeout=1s
    Send Egate Command and verify output   cmd=enb_endc_param id=${enb}                                                      timeout=1s
    Send Egate Command and verify output   cmd=ue_sgnb_mod_param id=${ue} menb_forced_scenario=${menb_forced_scenario}       timeout=1s
    Send Egate Command and verify output   cmd=ue_sgnb_mod_param id=${ue} abnormal_scenario=${abnormal_scenario}             timeout=1s
    Send Egate Command and verify output   cmd=ue_sgnb_mod_param id=${ue}                                                    timeout=1s
    Send Egate Command and verify output   cmd=ue_rrc_reconf_param id=${ue} if_contains=any action=none delay=${rrc_delay}   timeout=1s
    Send Egate Command and verify output   cmd=ue_rrc_reconf_param id=${ue}                                                  timeout=1s


Attach UE to LTE and Start Traffic
    [Arguments]  ${ue_id}=${UE_ID}
    Attach UE to LTE   ue_id=${ue_id}
    Start Traffic on   bearer=2


Add Bearer and Start Traffic
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=3
    Add bearer         ue_id=${ue}  bearer_id=${bearer}
    Start Traffic on   bearer=${bearer}


SgNBAddition
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=2  ${target_gnb}=2  ${target_cells}=3
    Send Egate Command and verify output
    ...         cmd=ue_dc_enb_start ue=${ue} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer} type=split_scg
    ...         pass_regexp=${EGATE_5G_ATTACH}
    Sleep  ${TRAFFIC_DURATION}


Bearer Stats from
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=2
    Send Egate Command and verify output    cmd=bearer_disp ue=${ue} at=enb
    Send Egate Command and verify output    cmd=bearer_stats ue=${ue} id=${bearer} dir=dl dc_cell_group=mcg
    Send Egate Command and verify output    cmd=bearer_stats ue=${ue} id=${bearer} dir=ul dc_cell_group=mcg
    Send Egate Command and verify output    cmd=bearer_stats ue=${ue} id=${bearer} dir=dl dc_cell_group=scg
    Send Egate Command and verify output    cmd=bearer_stats ue=${ue} id=${bearer} dir=ul dc_cell_group=scg


Start Traffic on
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=2  ${kbps}=${DEFAULT_DATA_RATE}
    Send Egate Command and verify output    cmd=trf_data_start ue=${ue} id=${bearer} dir=dl kbps=${kbps}
    Send Egate Command and verify output    cmd=trf_data_start ue=${ue} id=${bearer} dir=ul kbps=${kbps}
    Sleep  10s


Stop Traffic
    [Arguments]  ${ue}=${UE_ID}
    Send Egate Command and verify output    cmd=trf_data_stop ue=${ue}  pass_regexp=${EGATE_TRF_STOPPED}
    Sleep  1s


SgNBModification
    [Arguments]  ${ue}=${UE_ID}  ${bearer}=3  ${modification}=bearer_to_add
    Send Egate Command and verify output
    ...         cmd=enb_ue_dc_modify ue=${ue} ${modification}=${bearer} by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    Sleep  ${TRAFFIC_DURATION}


Collect EGATE Logs
    ${log_dir}=                              Get Testcase Log Directory
    Send Egate Command and verify output     cmd=sim_log_set flush  timeout=1s
    Run Keyword And Ignore Error             Copy File       ${tl.core.dir_path}/egate_console.log   ${log_dir}
