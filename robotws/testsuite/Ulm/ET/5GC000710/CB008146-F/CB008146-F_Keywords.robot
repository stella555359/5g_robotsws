*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008146-F

Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    CB008146-F_Commissioning.robot
Resource    B2A1_RRC_MEAS.robot
Resource    A2_RRC_MEAS.robot

Library     taf.config.wts    WITH NAME     wts_conf

*** Variables ***

${WTS_CFG_FILE_8146-F}      basic_setup_8146-F.cfg
${WTS_CFG_FILE_8146-F-B7-B8}   basic_setup_8146-F-B7-B8.cfg
${EGATE_CONSOLE_LOG}        /opt/iphy/latest/egate_console.log
${Simulated_gNB_ID}         50
${XNIP_simulated_gNB}       10.0.1.3
${NGIP_simulated_gNB}       10.0.1.4
${PROXY_simulated_gNB}      10.0.2.100
${BAD_UE_CAPA_TDD}          SEPARATOR=
...                         ue_nr_capabilities=E1A00000074E5A031E0003822007824C1900010F07006201A0130080C0700CA8D851AC10143404B2CA260A07AD8202
...                         020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D012CB2898281EB608080838778E1C830E0008193C7D5C0013C0070004
...                         F000A8D89BAC10143404B2CA260A07AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898281EB6080808
...                         38778E1C830E0008193C7D54000014000000420E2680000000101342400E010113D84C00C000A070500703009801C001A0F80000000000003
...                         95340004000025965400D2AAA0E00E0016000000080100210
${UE_CAPA_TDD}              SEPARATOR=
...                         ue_nr_capabilities=E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD820202
...                         0E1DE38720C38002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C0
...                         02A3626EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E1D
...                         E38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000001CA9A00
...                         02000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40
${UE_CAPA_FDD}              SEPARATOR=
...                         ue_nr_capabilities=E1201000014F5E0302C002044009041B38987C283809B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D
...                         262A08FE594932814105B260901831E31FF9863CA160703878089C027000402000004010000020020237B0900180E0A00F06012003C1F00E4
...                         1000000A41000002A41000004A494000069807C0DBCA9BC0CADD200A0800004B29202000032CA480800014B29202000072CA4A0800024B292
...                         120000AA5949005D038BA551740E269544D2A88AEC40700F0034020100000031006000204060
${BAD_UE_CAPA_FDD}          SEPARATOR=
...                         ue_nr_capabilities=E1201000014F5E0302C002024024106CE261F0A0609B0083FF30C7942C0E0980406228040531800507C46D618DA3A4
...                         C5411FCB2926500882D930480C18F18FFCC31E50B0381C3C044E01380020100000200800001001011BD8380180E0601E0C01401E0F8072080
...                         0000520800001520800002524A000034C03E06DE54DE0656E900504000025949010000196524040000A594901000039652504000125949090
...                         000552CA4802E81C5D2A8BA07134AA26954457620181E00680402000000620040008

@{MOP2_COUNTER}             M55157C00034  # NRMOP_SA_PROFILE_SELECTED_02
@{MOP3_COUNTER}             M55157C00035  # NRMOP_SA_PROFILE_SELECTED_03
@{B7_RRC_COUNTER}           M55113C00501  # Number of DL RRC Message Transfer sent
@{B7_COUNTERS}              M55124C02001  # Number of Inter-Rat B2 measurement received
...                         M55125C00501  # Number of UE CONTEXT RELEASE COMMAND received
...                         M55125C00502  # Number of UE CONTEXT RELEASE COMPLETE sent
...                         M55125C02001  # Number of inter-Rat HO preparation attempted (NNGCC)
...                         M55125C02002  # Number of successful inter-Rat HO preparation
...                         M55125C02006  # Number of successful inter RAT handover executions
@{B7_NREMO_COUNTERS}        M55144C00001  # Number of inter-Rat HO preparation attempted
...                         M55144C00002  # Number of successful inter-Rat HO preparation
...                         M55144C00006  # Number of successful inter RAT handover executions
${NREMO_COUNTERS_DN}        MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/ECI-4610/PLMN-PLMN/MCC-311/MNC-489
@{B8_COUNTERS}              M55144C00501  # Number of Inter-RAT Handover attempts for IMS Emergency Call
...                         M55144C00502  # Number of Successful inter-RAT handover for IMS Emergency Call
...                         M55144C00503  # Number of Successful Preparation of inter-RAT Handover for Emergency call

@{IP_LIST_eth3_add}        ${XNIP_simulated_gNB}  ${NGIP_simulated_gNB}
                           ...  10.0.1.122  10.0.1.123  10.0.1.124  10.0.1.125
                           ...  10.0.1.102  10.0.1.103  10.0.1.104  10.0.1.105  10.0.1.106
                           ...  10.0.1.12

@{IP_LIST_eth4_add}        ${PROXY_simulated_gNB}
                           ...  10.0.2.90  10.0.2.91  10.0.2.92

@{pdu2_qos_list_B8}  ${2}

*** Keywords ***

Prepare TL for CB008146-F
    [Documentation]   Prepare UTE TL for CB008146-F test
    ...    backup TL configurations, configure GNB with mobility profile, prepare WTS config file for
    Set Suite Variable  ${suite_setup_status}  Start
    Sqd65 Common Setup
    ${CELL_TECHNOLOGY}=        wts_ue.Get cellTechnology Info
    Set Suite Variable        ${CELL_TECHNOLOGY}
    ${SW_BRANCH}=             testline.Get gNB SW Branch
    Set Suite Variable        ${SW_BRANCH}
    Commissioning
    Prepare CB008146-F WTS Config
    ute_workarounds.Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_8146-F}
    Get SCF from gNB  scf_name=${CB008146-F_SCF}
    Set Suite Variable  ${suite_setup_status}  Finished

Reload backuped config files
    [Documentation]    Bring back TL to original condition
    ${suite_log_dir}=  Get Test Suite Log Directory
    Run Keyword and Ignore Error    Check TL connectivity and PDU status
    IF  "${suite_setup_status}" != "Finished" and '${TEST_MODE}' == 'auto'
      Run Keyword and Warn on Failure  wts_ue.Collect sos report logs  target_dir=${suite_log_dir}
    END
    IF   '${TEST_MODE}' != 'auto'
       Run    cp ${P_ORIG_SCF} /tmp/gnb_tmp.xml
       Execute full commissioning    gnb_id=0    scf_path=/tmp/gnb_tmp.xml
    END
    Kill WTS Services

Perform Precondition of Test Scenario
    IF    '${PREV_TEST_STATUS}'=='FAIL'
        Teardown Egate Connection for Airphone
        Teardown Edaemon Connection for Airphone
        Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_8146-F}
    END
    Start Logging

Perform Postconditions of Test Scenario
    Stop logging
    Revert Delta Commissioning

Revert Delta Commissioning
    ${log_dir}=               Get Testcase Log Directory
    ${scf}=                   Get SCF from gNB  target_dir=${log_dir}
    ${ts_conf_dir}=           Get Test Suite Config Directory
    ${revert_file}=           Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf   ${ts_conf_dir}/${CB008146-F_SCF}  ${scf}  ${revert_file}
    Config gNB with delta scf                ${revert_file}

Collect PMCounters
    [Arguments]    ${target_dir}=None
    ${log_dir}=    IF    '${target_dir}'=='None'  testline.Get Testcase Log Directory
    ...                        ELSE  Set Variable   ${target_dir}
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}
    RETURN  ${pm_files}

Counter Verification
   [Arguments]   ${counter_files}  ${counter_names}  ${counter_value}=1  ${dn}=MRBTS-1/NRBTS-1/NRCELL-1
    ${counters}=         Get Counter Value      ${counter_files}  ${dn}   ${counter_names}
    FOR  ${counter}  IN  @{counter_names}
       Should be True    "${counters["${counter}"]}" == "${counter_value}"
    END

Send Measurement Report
    [Arguments]    ${measurement}   ${ue_id}=1  ${pass_regexp}=EGATE>
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   cmd=ue_measurement_send_nr ${measurement} id=${ue_id}
    ...                                    pass_regexp=${pass_regexp}
    Sleep   1
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   set_log flush

Verify Measurement is configured
    [Arguments]  ${event_type}  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}

Verify Measurement is absent
    [Arguments]  ${event_type}  ${ue_id}=1
    ${meas_info}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    ${status}=  Run Keyword and Return Status
    ...  Should Match Regexp  ${meas_info}  ${event_type}
    IF  ${status}  Fail  Unexpected ${event_type} measurement found

Get Measurement id
    [Arguments]  ${event_type}  ${ue_id}=1
    ${measurements}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    RETURN  ${words}[0]

Update SCF Param
    [Arguments]  ${value}  ${parameter}  ${dist_name}
    connect.Setup OAM HTTP Session
    Update SCF parameter   value=${value}  parameter=${parameter}   dist_name=${dist_name}

Apply Config for B4
    ${meas_cfg_b4}=          Copy Dictionary     ${MEAS_CFG_2}
    Set to Dictionary        ${meas_cfg_b4}      a2MeashoEnabledSA=rsrpAndRsrq

    ${a2_meas_cfg_b4}=       Copy Dictionary     ${A2_MEAS_CFG}
    Set to Dictionary        ${a2_meas_cfg_b4}   a2HysteresishoSsbRsrpSA=10
    Set to Dictionary        ${a2_meas_cfg_b4}   a2ThresholdhoSsbRsrpSA=0
    Set to Dictionary        ${a2_meas_cfg_b4}   a2ThresholdhoSsbRsrqSA=127
    Set to Dictionary        ${a2_meas_cfg_b4}   a2TimeToTriggerhoSsbRsrqSA=ms512

    ${scf_file}=             Load current SCF

    Add NRREL to Cell         cell_id=1
    Add NRREL to Cell         cell_id=2

    ${items}                 Get Dictionary Items   ${a2_meas_cfg_b4}
    FOR    ${key}    ${value}    IN    @{items}
        ${rsrp}=  Evaluate  "Rsrp" in "${key}"
        IF  '${rsrp}' == 'True'
        ...             scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-1  p_name=${key}  list_name=a2MeashoSsbRsrpSA  value=${value}
        ...   ELSE
        ...             scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-1  p_name=${key}  list_name=a2MeashoSsbRsrqSA  value=${value}
    END

    scf.modify_scf_element   dist_name=NRBTS-1/NRMOPR_SA-2  p_name=a2MeashoEnabledSA    value=${meas_cfg_b4.a2MeashoEnabledSA}

    scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-1     p_name=a3MeasEnabled        value=rsrp
    scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-1     p_name=a5MeasEnabled        value=none

    scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-2     p_name=a5MeasEnabled        value=rsrqCombined
    scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-2     p_name=a5HysteresisSsbRsrp  list_name=a5MeasSsbRsrp  value=0
    scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-2     p_name=a5Threshold1SsbRsrp  list_name=a5MeasSsbRsrp  value=1
    scf.modify_scf_element   dist_name=NRBTS-1/NRCELL-2     p_name=a5Threshold2SsbRsrp  list_name=a5MeasSsbRsrp  value=0

    #B42
    scf.modify_scf_element   dist_name=NRBTS-1/NRMOPR_SA-3  p_name=a2MeashoEnabledSA    value=rsrpAndRsrq
    scf.modify_scf_element   dist_name=NRBTS-1              p_name=actRfspIndex         value=true

    ${physCellId2}=          scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-2  p_name=physCellId
    Set Suite Variable       ${physCellId2}

    Apply Delta SCF          ${scf_file}  scf_B4

    RETURN  ${meas_cfg_b4}  ${a2_meas_cfg_b4}

IntraDuHO  #5G_CP_ARC_ALG_3587
    [Arguments]   ${ue_id}  ${target_cell}
    ${meas_id}=                  Get Measurement id    EventA5   ue_id=${ue_id}
    ${meas_cmd}=                 catenate
    ...                          meas_id=${meas_id} event=A5 srsrp_nr=0 srsrq_nr=0 ssinr_nr=0 srs_result=0:0:0:0
    ...                          phycell_id=${target_cell} nrsrp_nr=1 nrsrq_nr=1 nsinr_nr=1 rs_type=ssb
    ...                          index=0 nrs_result=1:1:1
    Send Measurement Report      ue_id=${ue_id}   measurement=${meas_cmd}  pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed

InterRatHO  #5G_CP_ARC_ALG_1717
    ${meas_id}=                  Get Measurement id    EventA2
    Send Measurement Report      meas_id=${meas_id} event=A2
    ${meas_id}=                  Get Measurement id    EventB2
    Send Measurement Report      meas_id=${meas_id} event=B2 srsrp_nr=1 srsrq_nr=2 phycell_id=${ENB_PHY_CELL_ID} nrsrp_nr=3 nrsrq_nr=21
    ...                          pass_regexp=Completed handling UeContextReleaseComplete for Handover Type:1

Prepare CB008146-F WTS Config
    [Documentation]    use taf.config.wts to modify basic_setup.cfg for feature testing
    ...   The UE with ID 5 is used for B1.2 with no Inter-RAT capabilities
    ${WTS_CFG_FILE_8146-F}=      Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_8146-F}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    FOR   ${egate_command}  ${id}   IN
    ...    set_ue           id=4
    ...    set_ue           id=5
    ...    set_ue           id=6
    ...    ue_param         id=4
    ...    ue_param         id=5
    ...    ue_param         id=6
        wts_conf.delete     ${egate_command} ${id}
    END
    wts_conf.Modify              ue_param id=1      ${UE_CAPA_${CELL_TECHNOLOGY}}
    wts_conf.Modify              ue_param id=2      ${UE_CAPA_${CELL_TECHNOLOGY}}
    wts_conf.clone_and_modify    set_ue simulated id=1    id=5 suci=0:311:489:0000:0:0:021645404
    wts_conf.clone_and_modify    ue_param id=1            id=5 ${BAD_UE_CAPA_${CELL_TECHNOLOGY}}
    wts_conf.modify              set_nwslice id=1   ue=all
    ${slice2}=                   wts_conf.get  set_nwslice id=2
    IF               '${slice2}' != 'None'
    ...                          wts_conf.modify      set_nwslice id=2   ue=all
    ...         ELSE
    ...                          wts_conf.insert      set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1  after  set_nwslice id=1
    # Config for B6
    wts_conf.insert              set GNB_XN_ADDR="10.0.1.2"   after    set GNB_NG_ADDR="10.0.1.2"
    wts_conf.insert              set GNB3_XN_ADDR="${XNIP_simulated_gNB}"   after    set GNB_NG_ADDR="10.0.1.2"
    wts_conf.insert              set GNB3_NG_ADDR="${NGIP_simulated_gNB}"   after    set GNB_NG_ADDR="10.0.1.2"
    wts_conf.insert              set GNB3_PROXY_ADDR="${PROXY_simulated_gNB}"   after    set GNB_NG_ADDR="10.0.1.2"
    wts_conf.modify              set_gnb id=2              xn=$GNB_XN_ADDR
    wts_conf.insert
    ...  set_gnb id=${Simulated_gnb_ID} type=simulated plmn=311:489 ng=$GNB3_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...  after  set_gnb id=2
    wts_conf.modify
    ...  set_gnb id=${Simulated_gnb_ID}  gnb_id=0x26:22 x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts_conf.insert              set_cell id=1 gnb=${Simulated_gnb_ID} pci=16:0 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=${nrarfcn}:${nrarfcn}
    ...                          after  set_cell id=1 gnb=2
    wts_conf.modify
    ...  set_cell id=1 gnb=${Simulated_gnb_ID}  proxy=$GNB3_PROXY_ADDR:9999|$GNB3_PROXY_ADDR:8890 mandatory_for_activation=off gscn=7880
    wts_conf.insert
    ...  gnb_param id=${Simulated_gnb_ID} xn_listening_socket=1 send_xn_setup=false
    ...  after  set_gnb id=${Simulated_gnb_ID}
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_8146-F}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_8146-F}  ${ts_conf_dir}

Prepare CB008146-F-B7-B8 WTS Config
    ${NSA_UE_IDs}=
    ...  Run   bash -c "grep dual_conn=eutra_nr ${tl.core.dir_path}/${tl.core.cfg_filename} | sed -e 's/^.* id=\\\\([0-9]*\\\\) .*$/\\\\1/'"
    @{NSA_UE_ID_LIST}=  Split to lines  ${NSA_UE_IDs}
    ${WTS_CFG_FILE_8146-F-B7-B8}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_8146-F-B7-B8}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.modify              ue_param id=1      ${UE_CAPA_${CELL_TECHNOLOGY}}
    ${gnb1}=                     catenate
    ...                          set_gnb id=1 type=simulated plmn=${plmn['mcc']}:${plmn['mnc']} ng=$ENB1_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...                          gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none
    ${gnb1_cell1}                catenate
    ...                          set_cell id=1 gnb=1 pci=3:2 earfcn=${MEAS_CFG_2['earfcnValue']}:20000 tac=${EPS_TAC}
    ...                          proxy=$SERVER_IP:12219 nrci=0x1 tdd_cell=on

    wts_conf.delete              set_enb id=1
    wts_conf.delete              enb_param id=1
    wts_conf.delete              set_cell id=1 enb=1
    wts_conf.delete              enb_endc_param id=1
    wts_conf.delete              mme_pool_area id=1
    wts_conf.delete              set_mme id=1
    wts_conf.delete              set_sgw id=1
    wts_conf.delete              set_pgw id=1
    wts_conf.insert              set ENB1_S1U_ADDR="10.0.1.136"           before  set_amf_region id=1
    wts_conf.modify              set_amf_region id=1    tac_list=7627107,100,788,200,0,${EPS_TAC}
    wts_conf.insert              ${gnb1}                                  before  set_uec id=1
    wts_conf.insert              ${gnb1_cell1}                            after  set_gnb id=1
    wts_conf.modify              set_cell id=1 gnb=1    modification=bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert              gnb_param id=1 xn_listening_socket=off   after  set_cell id=1 gnb=1
    wts_conf.insert              ue_param id=1 dual_conn=eutra_nr         after  ue_param id=1
    wts_conf.insert              ue_param id=1 nr_usage_setting=voice_centric  after  ue_param id=1
    wts_conf.modify              qosflow_set id=1    modification=5qi=5
    wts_conf.delete              set_qosflow id=2          # VoNR by AP cof
    wts_conf.delete              set_qosflow id=3          # VoNR by AP cfg
    wts_conf.delete              set_qosrule id=1          # VoNR by AP cof
    wts_conf.delete              set_qosrule id=2          # VoNR by AP cof
    wts_conf.insert              set_qosflow id=2 5qi=1 default=off  after  set_qosflow id=1
    wts_conf.delete              nwslice_set id=1          # VoNR by AP cfg
    wts_conf.insert              set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all  after  set_qosflow id=2
    wts_conf.insert              set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=1
    FOR  ${nsa_ue_id}  IN   @{NSA_UE_ID_LIST}
        ${present}=  wts_conf.get  set_ue simulated id=${nsa_ue_id}
        IF           '${present}' != 'None'
               wts_conf.delete    set_ue simulated id=${nsa_ue_id}
               wts_conf.delete    ue_param id=${nsa_ue_id}
               wts_conf.delete    set_pdu_gateway id=${nsa_ue_id}
               wts_conf.delete    set_bearer id=2 ue=${nsa_ue_id}
        END
    END
    IF               '${CELL_TECHNOLOGY}' == 'FDD'
    ...                          wts_conf.modify         ue_param id=1   ${UE_CAPA_FDD}

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_8146-F-B7-B8}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_8146-F-B7-B8}  ${ts_conf_dir}

Setup for 5GC000710_F_B7_B8
    Prepare CB008146-F-B7-B8 WTS Config
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_8146-F-B7-B8}  force_cu_type=SA
    Start Logging

Apply Config for B6
    ${scf_file}=              Load current SCF

    Add NRADJGNB to SCF
    Add NRADJNRCELL to SCF
    Add NRREL to SCF

    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-1  list_name=a3MeasSsbRsrp
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-1   list_name=a3MeasSsbRsrp
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-1    list_name=a3MeasSsbRsrp
    ${a3MeasSsbRsrp_dict}     Create dictionary
    ...                       a3HysteresisSsbRsrp  0
    ...                       a3OffsetSsbRsrp  6
    ...                       a3TimeToTriggerSsbRsrp  ms480
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-1   list_name=a3MeasSsbRsrp    elements=${a3MeasSsbRsrp_dict}

    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-1  list_name=a5MeasSsbRsrp
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-1   list_name=a5MeasSsbRsrp
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-1    list_name=a5MeasSsbRsrp
    ${a5MeasSsbRsrp_dict}     Create dictionary
    ...                       a5HysteresisSsbRsrp  0
    ...                       a5Threshold1SsbRsrp  52
    ...                       a5Threshold2SsbRsrp  54
    ...                       a5TimeToTriggerSsbRsrp  ms100
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-1   list_name=a5MeasSsbRsrp    elements=${a5MeasSsbRsrp_dict}

    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1    p_name=a3MeasEnabled  value=rsrp
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1    p_name=a5MeasEnabled  value=rsrp

    Apply Delta SCF           ${scf_file}  scf_B6

Apply Config for B7_Inter_RAT_HO_B2_Meas
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1/NRMEASCFG_IR-2    p_name=b2MeashoEnabled     value=rsrpCombined
    scf.modify_scf_element    dist_name=NRBTS-1/NRHOIR-2          p_name=b2Threshold2hoRsrq  list_name=eutraB2MeashoRsrq  value=10
    scf.modify_scf_element    dist_name=NRBTS-1/NRHOIR-2          p_name=b2HysteresishoRsrq  list_name=eutraB2MeashoRsrq  value=5
    Apply Delta SCF           ${scf_file}  scf_B7

Apply Config for CB008146-F_B8
    ${scf_file}=              Load current SCF

    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1    p_name=actEmergencyCall    value=true    # B8 param modified to objectLocking
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1    p_name=actVoNR    value=true    # B8 param dependency

    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-1     list_name=emergencyCallRestrictions
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-1   list_name=emergencyCallRestrictions
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-1    list_name=emergencyCallRestrictions
    ${emergency_call_dict}    Create dictionary  emergencyCallMrListIgnore  true  emergencyCallPlmnHoAllowed  true
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-1   list_name=emergencyCallRestrictions   elements=${emergency_call_dict}

    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1/NRPMRNL-1         p_name=miNrNREMO
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1/NRPMRNL-1         p_name=miNrNREMO   value=5min

    scf.modify_scf_element    dist_name=NRBTS-1/NRMEASCFG_IR-2    p_name=b2MeashoEnabled     value=rsrpCombined
    scf.modify_scf_element    dist_name=NRBTS-1/NRHOIR-2          p_name=b2Threshold2hoRsrq  list_name=eutraB2MeashoRsrq  value=10
    scf.modify_scf_element    dist_name=NRBTS-1/NRHOIR-2          p_name=b2HysteresishoRsrq  list_name=eutraB2MeashoRsrq  value=5
    Apply Delta SCF           ${scf_file}  scf_B8
    Stop F1AP capturing
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_8146-F-B7-B8}  force_cu_type=SA
    Start F1AP capturing
    Wait until the next Measurement Period starts

Config AMF MRL With Restriction For UE
    [Arguments]    ${ue_id}=1    ${sa_plmn}=311:489    ${fa_plmn}=311:489    ${forbidden_tacs}=222
    ...    ${restricted_plmn}=311:489    ${restricted_rat}=eutra
    ${cmd}    Catenate    amf_mobility_restriction_list_param id=1 sa_plmn=${sa_plmn} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    ...   restricted_plmn=${restricted_plmn} restricted_rat=${restricted_rat}
    Send Egate Command and verify output   ${cmd}
    Send Egate Command and verify output    amf_mobility_restriction_list_param id=1
    Send Egate Command and verify output    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1

Set Emergency Call Priority
    [Arguments]   ${priority}=1  ${ue_id}=1
    Send Egate Command and verify output    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Send Egate Command and verify output    qosflow_modify qos_flow=1 priority=${priority}
    Send Egate Command and verify output    qosflow_modify qos_flow=2 priority=${priority}

Verify InterRatHo
    @{interRatHo_seq}=  Create List
    ...               ue_measurement_send_nr meas_id=\\d event=B2
    ...               HANDOVER REQUIRED: gNB=2
    ...               Received Handover Required from GNB-2 with Handover Type FIVEGS-TO-EPS and cause RAN time critical handover for UE
    ...               Received Handover Request Acknowledge Message
    ...               message c1 : mobilityFromNRCommand
    ...               message c1 : rrcConnectionReconfiguration
    ...               message c1 : rrcConnectionReconfigurationComplete
    ...               UE1: Successful handover from EXT_ENB-2.1 to ENB-1.1
    ...               Received UE Context Release Complete from GNB-2
    ...               Completed handling UeContextReleaseComplete for Handover Type:1
    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{interRatHo_seq}

Apply Config for B2.1_Conf_of_B2_Meas
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1       p_name=a2HysteresishoSsbRsrqSA      list_name=a2MeashoSsbRsrqSA  value=10
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1       p_name=a2ThresholdhoSsbRsrqSA       list_name=a2MeashoSsbRsrqSA  value=100
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1       p_name=a2TimeToTriggerhoSsbRsrqSA   list_name=a2MeashoSsbRsrqSA  value=ms480
    scf.modify_scf_element    dist_name=NRBTS-1/NRMOPR_SA-2    p_name=a2MeashoEnabledSA            value=rsrpCombined
    Apply Delta SCF           ${scf_file}  scf_B2_1_Conf_of_B2_Meas

Change EARFCN Value
    Update SCF Param             value=1001  parameter=earfcnValue   dist_name=MRBTS-1/NRBTS-1/NRMEASCFG_IR-1    # avoid validation errors
    Update SCF Param             value=${MEAS_CFG_1.earfcnValue}  parameter=earfcnValue   dist_name=MRBTS-1/NRBTS-1/NRMEASCFG_IR-2
    ${meas_cfg_b2.2}=            Copy Dictionary    ${MEAS_CFG_2}
    Set to Dictionary            ${meas_cfg_b2.2}   earfcnValue=${MEAS_CFG_1.earfcnValue}
    RETURN  ${meas_cfg_b2.2}

Delete MOP2
    ${scf_file}=              Load current SCF
    scf.remove_mo_with_descendant_mos     dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-2
    scf.remove_mo_with_descendant_mos     dist_name=MRBTS-1/NRBTS-1/NRMOPRMA_SA-2
    Apply Delta SCF           ${scf_file}  scf_B2_3_Conf_of_B2_Meas

Setup B2 Measurement
    Send Measurement Report       meas_id=1 event=A2 srsrq_nr=89 srsrp_nr=50    #5G_CP_ARC_ALG_1697

Verify B2 Measurement Config
    [Arguments]  ${meas_cfg}=${MEAS_CFG_2}  ${nrhoir}=${NRHOIR_2}
    @{B2A1_RRC_MEAS_REGEX_LIST}=  B2A1_RRC_MEAS_REGEX  ${meas_cfg}  ${nrhoir}
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{B2A1_RRC_MEAS_REGEX_LIST}

Set RFSPIndex
   [Arguments]   ${rfsp_index}  ${ue_id}=1
    Send Egate Command and verify output   cmd=ue_ctx_ng_mod id=${ue_id} indexToRFSP=${rfsp_index}
    ...                                    pass_regexp=Received UE Context Modification Response from GNB

AP WA IntraDUHO To Source
   [Arguments]   ${target_cell}  ${ue_id}=1  ${event}=A3
   ${meas_id}=               Get Measurement id   event_type=Event${event}  ue_id=${ue_id}
   Send Measurement Report   ue_id=${ue_id}   measurement=meas_id=${meas_id} event=${event} phycell_id=${target_cell}
   ...                       pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

B4 Teardown
   [Arguments]   ${ue_id}=1
   AP WA IntraDUHO To Source              ue_id=${ue_id}  event=A3  target_cell=${physCellId2}
   UE Deregister                          ue_id=${ue_id}
   Perform Postconditions of Test Scenario

MoPCounter Verification B4.2
    ${pm_files}=                           Collect PMCounters
    ${mop2_3_counter}=                     Combine Lists              ${MOP2_COUNTER}  ${MOP3_COUNTER}
    Counter Verification                   counter_files=${pm_files}  counter_names=${MOP3_COUNTER}
    Counter Verification                   counter_files=${pm_files}  counter_names=${mop2_3_counter}  dn=MRBTS-1/NRBTS-1/NRCELL-2

Enable HO back to real gNB
    Send Egate Command and verify output
    ...    ue_history_information_list_add_ngran id=1 gnb_id=${Simulated_gNB_ID} cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Send Egate Command and verify output   ue_history_information_list id=1 action=commit
    Send Egate Command and verify output   ue_enb_param id=1 ue_history_list=1
