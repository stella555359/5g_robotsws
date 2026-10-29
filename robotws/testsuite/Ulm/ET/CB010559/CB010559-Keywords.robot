*** Settings ***
Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007_GMS <OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com>'
...    Description: Keywords for CB010559
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../CB008574/CB008574_Keywords.robot

Library     taf.config.wts       WITH NAME    wts_conf

*** Variables ***

${TEST_MODE}           manual
${EGATE_CONSOLE_LOG}   /opt/iphy/latest/egate_console.log
${VONR}                ${TRUE}
${UE_ID}               1
&{TRF}                 kbps_DL=1000  kbps_UL=500  size_dl=100  size_ul=100  max_lost=150  variance=10
@{5qi1_list}           ${6}
@{DCAP_PROFILE}        cp_5g  Tracer_5g

${DISABLE_CLUBBING}    TTI=3 NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_COMPRESS_PROXY_PROTO_MSGS=enabled
...                    NR_CLUB_PROXY_PROTO_MSGS=disabled

@{FALLBACK_COUNTERS}
...                    M55124C00043  ==  0  REESTAB_UNPREP_ACC_OTH_FAIL
...                    M55124C00044  ==  1  REESTAB_UNPREP_ATT_OTH_FAIL
...                    M55124C00045  ==  0  REESTAB_UNPREP_ACC_VONR
...                    M55124C00046  ==  1  REESTAB_UNPREP_ACC_FALLBACK
...                    M55124C00047  ==  1  REESTAB_UNPREP_FALLBACK
...                    M55124C00048  ==  0  REESTAB_UNPREP_ACC_HO_FAIL
...                    M55124C00049  ==  0  REESTAB_UNPREP_ATT_HO_FAIL
...                    M55124C00502  ==  1  RRC_REESTAB_FALLBACK
...                    M55124C00505  ==  1  RRC_REESTAB_OTHER_FAILURE
...                    M55124C00504  ==  0  RRC_REESTAB_HO_FAILURE

@{FAILURE_COUNTERS_DU}
...                    M55127C00503  ==  1  RRC_REESTAB_OTHER_FAILURE_DU
...                    M55127C00502  ==  0  RRC_REESTAB_HO_FAILURE_DU

@{RRE_COUNTERS}
...                    M55124C00043  ==  0  REESTAB_UNPREP_ACC_OTH_FAIL
...                    M55124C00044  ==  0  REESTAB_UNPREP_ATT_OTH_FAIL
...                    M55124C00045  ==  1  REESTAB_UNPREP_ACC_VONR
...                    M55124C00046  ==  0  REESTAB_UNPREP_ACC_FALLBACK
...                    M55124C00047  ==  0  REESTAB_UNPREP_FALLBACK
...                    M55124C00048  ==  1  REESTAB_UNPREP_ACC_HO_FAIL
...                    M55124C00049  ==  1  REESTAB_UNPREP_ATT_HO_FAIL
...                    M55124C00502  ==  0  RRC_REESTAB_FALLBACK
...                    M55124C00505  ==  0  RRC_REESTAB_OTHER_FAILURE
...                    M55124C00504  ==  1  RRC_REESTAB_HO_FAILURE

@{RRE_COUNTERS_OTH_FAIL}
...                    M55124C00043  ==  1  REESTAB_UNPREP_ACC_OTH_FAIL
...                    M55124C00044  ==  1  REESTAB_UNPREP_ATT_OTH_FAIL
...                    M55124C00045  ==  1  REESTAB_UNPREP_ACC_VONR
...                    M55124C00046  ==  0  REESTAB_UNPREP_ACC_FALLBACK
...                    M55124C00047  ==  0  REESTAB_UNPREP_FALLBACK
...                    M55124C00048  ==  0  REESTAB_UNPREP_ACC_HO_FAIL
...                    M55124C00049  ==  0  REESTAB_UNPREP_ATT_HO_FAIL
...                    M55124C00502  ==  0  RRC_REESTAB_FALLBACK
...                    M55124C00505  ==  1  RRC_REESTAB_OTHER_FAILURE
...                    M55124C00504  ==  0  RRC_REESTAB_HO_FAILURE

*** Keywords ***

RRC Reestablishment Request
    [Arguments]    ${ue}=${UE_ID}  ${target_gnb}=${TGT_GNB['apId']}  ${target_cell}=${TGT_GNB['cellId']}  ${cause}=otherFailure
    ...            ${pass_regexp}=PATH SWITCH REQUEST ACK  ${fail_regexp}=${None}
    Send Egate Command And Verify Output   cmd=ue_rrc_reestablish id=${ue} gnb=${target_gnb} cell=${target_cell} cause=${cause}
    ...                                    pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}

Config Sim GNB
    Send Egate Command And Verify Output   gnb_param id=${SIM_GNB['apId']} integrityprotection_algorithm=nia2 ciphering_algorithm=nea2
    Send Egate Command And Verify Output   gnb_param id=${SIM_GNB['apId']} srb1_rlc_sn_field_size=size_12

Config VoNR
    [arguments]    ${ue_id}=${UE_ID}
    Send Egate Command And Verify Output   ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-VoiceCall
    ${exist}=    Get Variable Value    ${SA_CAPA_VONR}
    IF  '${exist}' != 'None'
       Send Egate Command And Verify Output   ue_param id=${ue_id} ue_nr_capabilities=${SA_CAPA_VONR}
    END

Setup VoNR
    [arguments]    ${ue_id}=${UE_ID}    ${pdu}=1
    UE PDU Session Modify         ue_id=${ue_id}   pdu=${pdu}     qos_flow_list=@{5qi1_list}  by=amf
    Start Data Traffic In Egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=${pdu}   qfi=2   kbps=${TRF['kbps_DL']}   size=100
    Start Data Traffic In Egate   ue_id=${ue_id}   direction=ul   protocol=udp   trf_id=1   pdu=${pdu}   qfi=2   kbps=${TRF['kbps_UL']}   size=100

UE Attach And Start Traffic
    [arguments]   ${ue}=${UE_ID}  ${pdu}=1
    UE Change Location            id=${ue}  enb=${SRC_GNB['apId']}  cell=${SRC_GNB['cellId']}
    IF  '${SRC_GNB['apId']}' == '${SIM_GNB['apId']}'  Config Sim GNB
    IF  ${VONR}                   Config VoNR   ue_id=${ue}
    ${register}                   Run Keyword And Return Status   UE Register                   ue_id=${ue}
    IF  not ${register}           UE Register                   ue_id=${ue}
    Set Traffic Type              ue_id=${ue}   pdu_id=${pdu}   trf_type=internal
    UE PDU Session Setup          ue_id=${ue}   pdu=${pdu}      pass_regexp=(Pdu Session.*successfully)|(Initial Context Setup Successful)
    Start Data Traffic In Egate   ue_id=${ue}   direction=dl    protocol=udp   trf_id=1   pdu=${pdu}   qfi=1   kbps=${TRF['kbps_DL']}   size=200
    Start Data Traffic In Egate   ue_id=${ue}   direction=ul    protocol=udp   trf_id=1   pdu=${pdu}   qfi=1   kbps=${TRF['kbps_UL']}   size=200
    IF  ${VONR}                   Setup VoNR    ue_id=${ue}
    Verify Bearer Stats

Verify Bearer Stats
    [arguments]    ${ue_id}=${UE_ID}    ${pdu}=1
    Sleep                       20s
    ${bearer_stats}             Get Bearer Stats From Egate   ue_id=${ue_id}  trf_id=1  mode=all  pdu=${pdu} qfi=1
    Verify Average Data Rate    ${bearer_stats}
    IF  ${VONR}
       ${bearer_stats}             Get Bearer Stats From Egate   ue_id=${ue_id}  trf_id=1  mode=all  pdu=${pdu} qfi=2
       Verify Average Data Rate    ${bearer_stats}  qfi=2
    END

Clear Stats
    [arguments]    ${ue_id}=${UE_ID}    ${pdu}=1
    Send Egate Command And Verify Output   bearer_stats_clear ue=${ue_id} pdu=1 qfi=1 dir=bi
    IF  ${VONR}   Send Egate Command And Verify Output   bearer_stats_clear ue=${ue_id} pdu=${pdu} qfi=2 dir=bi

Verify Average Data Rate
    [arguments]    ${bearer_stats}  ${qfi}=1
    Verify Average Data Rate By Direction   bearer_stats=${bearer_stats}  qfi=${qfi}  dir=DL
    Verify Average Data Rate By Direction   bearer_stats=${bearer_stats}  qfi=${qfi}  dir=UL

    ${tot_pkts_drop_dl}         Convert To Integer  ${bearer_stats["UE_1"]["DL"]["Total packets lost"]}
    IF  ${tot_pkts_drop_dl} > ${TRF['max_lost']}           Log    DL: qfi:${qfi} Total packets lost:${tot_pkts_drop_dl}           level=WARN
    ${tot_pkts_drop_ul}         Convert To Integer  ${bearer_stats["UE_1"]["UL"]["Total packets lost"]}
    IF  ${tot_pkts_drop_ul} > ${TRF['max_lost']}           Log     message=UL: qfi:${qfi} Total packets lost:${tot_pkts_drop_ul}  level=WARN

Verify Average Data Rate By Direction
    [arguments]    ${bearer_stats}  ${qfi}=1  ${dir}=DL
    ${av_data_rate}          Convert To Integer  ${bearer_stats['UE_${UE_ID}']['${dir}']['Average data rate']}
    ${data_rate_min}         Evaluate   ${TRF['kbps_${dir}']}*1000-${TRF['kbps_${dir}']}*1000/100*${TRF['variance']}
    IF  ${av_data_rate} < ${data_rate_min}
    ...   Log    ${dir} qfi:${qfi} Average data rate:${av_data_rate} expected: ${TRF['kbps_${dir}']}     level=WARN

Get Total Packets Dropped From Egate Output
    [Arguments]   ${output}
    ${output}   String.Get Lines Containing String   ${output}   Total packets dropped
    ${output}   String.Replace String   ${output}   Total packets dropped   ${EMPTY}
    @{words}    String.Split String     ${output}    (
    ${data_rate}   String.Strip String   ${words[0]}
    RETURN   ${total_packets_dropped}

Disable Xn Ho In Src GNB
    [arguments]    ${nrrel}=1
    ${current_scf}=           Load Current SCF   gnb_id=${SRC_GNB['node']}
    Set Element               dist_name=NRBTS-${SRC_NODE+1}/NRCELL-${SRC_CELL}/NRREL-${nrrel}    p_name=handoverAllowedSA    value=forbidden
    Apply Delta SCF           ${current_scf}  disable_xn_ho    gnb_id=${SRC_GNB['node']}

Enable Xn Ho In Src GNB
    [arguments]    ${nrrel}=1
    ${current_scf}=           Load Current SCF   gnb_id=${SRC_GNB['node']}
    Set Element               dist_name=NRBTS-${SRC_NODE+1}/NRCELL-${SRC_CELL}/NRREL-${nrrel}    p_name=handoverAllowedSA    value=allowed
    Apply Delta SCF           ${current_scf}  disable_xn_ho    gnb_id=${SRC_GNB['node']}

Reset WTS
    Send Egate Command And Verify Output         reset
    Sleep                                        60s
    Send Egate Command And Verify Output         cfg file=basic_setup.cfg
    Wait Until All GNBs To Be Onair State
    Run Keyword And Warn On Failure              UE Register
    Sleep                                        10s
    Run Keyword And Ignore Error                 Deregister UE
    Get Resources Taken Before Test

Setup XN Link
    Send Egate Command And Verify Output    cmd=xn_link_gnb_up gnb=${SIM_GNB['apId']} target=${TGT_GNB['apId']}
    Send Egate Command And Verify Output    cmd=xn_link_gnb_up gnb=${SIM_GNB['apId']} target=${SRC_GNB['apId']}

Disable 3rd GNB
    [arguments]   ${nrAdjNrCellId}=10
    IF  '${TGT_GNB['apId']}' == '${SIM_GNB['apId']}'   RETURN
    ${current_scf}=           Load Current SCF   gnb_id=${TGT_GNB['node']}
    Set Element               dist_name=NRBTS-${TGT_GNB['nrBtsId']}/NRADJNRCELL-${nrAdjNrCellId}    p_name=physCellId    value=0
    Apply Delta SCF           ${current_scf}  disable_3rd_gnb    gnb_id=${TGT_GNB['node']}

Enable 3rd GNB
    [arguments]   ${nrAdjNrCellId}=10
    IF  '${TGT_GNB['apId']}' == '${SIM_GNB['apId']}'   RETURN
    ${current_scf}=           Load Current SCF   gnb_id=${TGT_GNB['node']}
    Set Element               dist_name=NRBTS-${TGT_GNB['nrBtsId']}/NRADJNRCELL-${nrAdjNrCellId}    p_name=physCellId    value=${SRC_GNB['pci']}
    Apply Delta SCF           ${current_scf}  enable_3rd_gnb    gnb_id=${TGT_GNB['node']}

Setup SimGnb To Trigger RetrieveUeContextReq
    ${egate_cmd}      Set Variable   gnb_ue_rrc_reestablish_param ue=${UE_ID} gnb_id=${TGT_GNB['apId']}
    ${egate_param}    Set Variable   action=trigger_xnap_retrieve_ue_context_req
    Send Egate Command And Verify Output         ${egate_cmd} ${egate_param}

Verify RRE Counters
    [Arguments]   ${ref_table}=${RRE_COUNTERS}
    IF  '${TGT_GNB['apId']}' == '${SIM_GNB['apId']}'
       Log    No Counters from Sim gNB           level=WARN
       RETURN
    END
    ${pm_files_tgt}                              Collect PM Counters From Target GNB
    Verify PM Counter Reference Table            reference_table=${ref_table}  pm_dir=${pm_files_tgt}  distname_suffix=NRCELL-${TGT_GNB['cellId']}

Delay Path Switch
    Send Egate Command And Verify Output         cmd=amf_ue_path_switch_param id=1 action=delay_path_switch_req_ack time_to_wait=100ms
    Send Egate Command And Verify Output         cmd=amf_ue_path_switch_param id=1

Setup PDU Forwarding Tunnel
    Send Egate Command And Verify Output   gnb_xnu_address_indication_param id=${TGT_GNB['apId']} forwarding_tunnel_type=pdu
    Send Egate Command And Verify Output   gnb_xnu_address_indication_param id=${TGT_GNB['apId']}

Verify Msgs In Egate Console Log
    [Arguments]   ${msg_list}
    Send Egate Command And Verify Output     set_log flush
    Verify Sequence In File                  ${EGATE_CONSOLE_LOG}  @{msg_list}

CB010559-2realGnb Setup
    Setup Global Vars 2realGnb
    Sqd65 Common Setup                                   skip_precheck=${True}
    Setup WTS Cfg 2realGnb
    Bring Airphone TL To F1 Up Status
    Commissioning
    Bring Airphone TL To On Air Status Without Reboot    remove_logs=${True}
    ${SW_BRANCH}=                                        testline.Get GNB SW Branch
    Set Suite Variable                                   ${SW_BRANCH}

Setup Global Vars 2realGnb
    Set Suite Variable  ${GNB3_XN_IP}        10.0.1.8
    Set Suite Variable  @{IP_LIST_eth3_add}  10.0.1.4  10.0.1.6  ${GNB3_XN_IP}  10.0.1.115

    &{GNB1}=            Create Dictionary    node=0   nrBtsId=1  apId=2  cellId=1  pci=50  nrci=1   nrarfcn=156000  ssbfreq=155790  freqband=28
    Set Suite Variable  ${GNB1}  &{GNB1}
    &{GNB2}=            Create Dictionary    node=1   nrBtsId=2  apId=3  cellId=5  pci=54  nrci=5   nrarfcn=156000  ssbfreq=156030  freqband=28
    Set Suite Variable  ${GNB2}  &{GNB2}
    &{GNB3}=            Create Dictionary    node=-1  nrBtsId=4  apId=4  cellId=10  pci=54  nrci=10  nrarfcn=156000  ssbfreq=155790  freqband=28
    Set Suite Variable  ${GNB3}  &{GNB3}
    &{GNB3_2}=          Create Dictionary    node=-1  nrBtsId=4  apId=4  cellId=11  pci=54  nrci=11  nrarfcn=126900  ssbfreq=126750  freqband=71
    Set Suite Variable  ${GNB3_2}  &{GNB3_2}

    Set Suite Variable  ${SRC_GNB}          &{GNB1}
    Set Suite Variable  ${TGT_GNB}          &{GNB2}             # RRE TGT
    Set Suite Variable  ${OTH_GNB}          &{GNB3}             # HO TGT
    Set Suite Variable  ${OTH2_GNB}         &{GNB3_2}           # HO TGT
    Set Suite Variable  ${SIM_GNB}          &{GNB3}
    Set Suite Variable  ${SIM2_GNB}         &{GNB3_2}

Setup WTS Cfg 2realGnb
    ${ts_conf_dir}=         Get Test Suite Config Directory
    Copy File               ${tl.core.dir_path}/${tl.core.cfg_filename}   ${ts_conf_dir}/${tl.core.cfg_filename}.orig
    Copy File               ${tl.core.dir_path}/${tl.core.cfg_filename}   ${tl.core.dir_path}/${tl.core.cfg_filename}.orig

    wts_conf.Load Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.Insert         set GNB${SIM_GNB['apId']}_NG_ADDR="10.0.1.4"          after    set GNB2_NG_ADDR="10.0.1.3"
    wts_conf.Insert         set GNB${SIM_GNB['apId']}_S1U_ADDR="10.0.1.115"       after    set GNB2_S1U_ADDR="10.0.1.113"
    wts_conf.Insert         set GNB${SIM_GNB['apId']}_X2_ADDR="10.0.1.6"          after    set GNB2_X2_ADDR="10.0.1.3"
    wts_conf.Insert         set GNB${SIM_GNB['apId']}_XN_ADDR="${GNB3_XN_IP}"     after    set GNB${SIM_GNB['apId']}_X2_ADDR="10.0.1.6"

    wts_conf.Modify         command=set_gnb id=${GNB1['apId']}            modification=xn=$GNB1_X2_ADDR
    wts_conf.Modify         command=set_gnb id=${GNB2['apId']}            modification=xn=$GNB2_X2_ADDR

    wts_conf.Modify         command=set_cell id=2 gnb=${GNB1['apId']}     modification=nrci=0x02
    wts_conf.Modify         command=set_cell id=3 gnb=${GNB1['apId']}     modification=nrci=0x03
    wts_conf.Modify         command=set_cell id=4 gnb=${GNB1['apId']}     modification=nrci=0x04
    wts_conf.Modify         command=set_cell id=5 gnb=${GNB2['apId']}     modification=nrci=0x05
    wts_conf.Modify         command=set_cell id=6 gnb=${GNB2['apId']}     modification=nrci=0x06
    wts_conf.Modify         command=set_cell id=7 gnb=${GNB2['apId']}     modification=nrci=0x07
    wts_conf.Modify         command=set_cell id=8 gnb=${GNB2['apId']}     modification=nrci=0x08

    wts_conf.Insert         set_gnb id=${SIM_GNB['apId']} ${SIM_GNB_SET}        before   set_uec id=1
    wts_conf.Insert         gnb_param id=${SIM_GNB['apId']} ${SIM_GNB_PARAM}    after    set_gnb id=${SIM_GNB['apId']}
    wts_conf.Insert         set_cell id=${SIM_GNB['nrci']} ${SIM_CELL1_SET}     after    gnb_param id=${SIM_GNB['apId']}
    wts_conf.Insert         set_cell id=${SIM2_GNB['nrci']} ${SIM_CELL2_SET}    after    set_cell id=${SIM_GNB['nrci']}

    wts_conf.Modify         set_ue simulated id=${UE_ID}                  modification=nia=null+zuc+aes+snow3g
    wts_conf.Modify         set_ue simulated id=${UE_ID}                  modification=nea=null+zuc+aes+snow3g

    wts_conf.Modify         set_qosflow id=1                              modification=5qi=5
    wts_conf.Modify         set_qosflow id=2                              modification=5qi=6

    wts_conf.Insert         sim_param_set ${DISABLE_CLUBBING}                  after    uec_param id=1
    wts_conf.Insert         sim_debug_log level=4 enb=${SIM_GNB['apId']}       before   link_ctrl_param
    wts_conf.Insert         sim_trace enb=${SIM_GNB['apId']} protocol=xn on    before   cfg_end

    wts_conf.Save Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.Save Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}.new
    wts_conf.Save Wts Cfg   ${ts_conf_dir}/${tl.core.cfg_filename}

Perform Postconditions Of Test Scenario
    IF    '${TEST_STATUS}'=='FAIL'         sqd65_keywords.Collect AP SOS Report And Snapshots
    CB008574_Keywords.Deregister UE
    resources.Configure Default Excluding Resource Paths   add=//cooling
    CB008574_Keywords.Get Resources Taken After Test
    CB008574_Keywords.Verify Resource Usage
    sqd65_keywords.Stop Logging
