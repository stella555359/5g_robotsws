*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for 5GC000705-A

Resource    ../../resources/Common/btslog.robot
Resource    ../../resources/Common/commissioning.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/ute_workarounds.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/reporting.robot
Resource    ../../resources/Common/pmcounters.robot
Resource    ../../resources/Common/snapshot.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/wts_ue.robot
Resource    ../../resources/Common/util.robot

Resource    ../resources/SQD65/sqd65_keywords.robot

Resource    5GC000705-A_Commissioning.robot

Library     taf.config.wts       WITH NAME    wts_conf
Library     taf.transport.ssh    WITH NAME    ssh


*** Variables ***

${TEST_MODE}                auto

${WTS_CFG_FILE_705-A-inter-gNB_B6}      basic_setup_705-A-inter-gNB_B6.cfg
${WTS_CFG_FILE_705-A-intra-gNB_B6}     basic_setup_705-A-intra-gNB_B6.cfg
${WTS_CFG_FILE_705-A-noXn}      basic_setup_705-A-noXn.cfg
${EGATE_CONSOLE_LOG}        /opt/iphy/latest/egate_console.log
${UE_CAPA_B6_TDD}           SEPARATOR=
...                         ue_nr_capabilities=6180000004408480000002680801C4D0000012044000441E000000000000045400000000000005400000400801
${UE_CAPA_TDD}              SEPARATOR=
...                         ue_nr_capabilities=21A00000010900000004D0100389A00000340280221C0C0300F000000000000022A00000000000002A0000020040081114


@{EC1_1_COUNTERS}           M55125C07507  # NG_HO_PREP_FAIL_RRL_SRC
...                         M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC1_2_COUNTERS}           M55125C07508  # NG_HO_PREP_FAIL_BNS_SRC
...                         M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC1_3_COUNTERS}           M55125C07509  # NG_HO_PREP_FAIL_CNA_SRC
...                         M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC1_4_COUNTERS}           M55125C07510  # NG_HO_PREP_FAIL_OTH_SRC
...                         M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC2_COUNTERS}             M55125C07516  # NG_HO_PREP_CNC_SRC
...                         M55125C07517  # NG_HO_PREP_CNC_ACK_SRC
...                         M55125C07511  # NG_HO_PREP_TIME_EXP_SRC

@{EC1_1_PM_COUNTERS}           M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC1_2_PM_COUNTERS}           M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC1_3_PM_COUNTERS}           M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC1_4_PM_COUNTERS}           M55147C00502  # FAIL_HO_PREP_EMERGENCY_RECD
@{EC2_PM_COUNTERS}             @{EMPTY}

@{EC1_1_RD_COUNTERS}           NG_HO_PREP_FAIL_RRL_SRC  # M55125C07507
@{EC1_2_RD_COUNTERS}           NG_HO_PREP_FAIL_BNS_SRC  # M55125C07508
@{EC1_3_RD_COUNTERS}           NG_HO_PREP_FAIL_CNA_SRC  # M55125C07509
@{EC1_4_RD_COUNTERS}           NG_HO_PREP_FAIL_OTH_SRC  # M55125C07510

@{EC2_RD_COUNTERS}             NG_HO_PREP_CNC_SRC       # M55125C07516
...                            NG_HO_PREP_CNC_ACK_SRC   # M55125C07517
...                            NG_HO_PREP_TIME_EXP_SRC  # M55125C07511

${Simulated_gNB_ID}         3
${NGIP_simulated_gNB}       10.0.1.3
${XNIP_simulated_gNB}       10.0.1.4
${PROXY_simulated_gNB}      10.0.2.90


@{IP_LIST_eth3_add}        ${XNIP_simulated_gNB}  ${NGIP_simulated_gNB}

@{IP_LIST_eth4_add}        ${PROXY_simulated_gNB}

@{pdu2_qos_list_EC1}  ${2}
*** Keywords ***

Prepare TL for 5GC000705-A
    [Documentation]   Prepare UTE TL for 5GC000705-A test
    Set Suite Variable  ${suite_setup_status}  Start
    Sqd65 Common Setup
    ${CELL_TECHNOLOGY}=        wts_ue.Get cellTechnology Info

    IF    "${CELL_TECHNOLOGY}" == "TDD+FDD"
    ...        Set Suite Variable     ${CELL_TECHNOLOGY}    TDD
    ...    ELSE
    ...        Set Suite Variable     ${CELL_TECHNOLOGY}

    Get SW branch
    5GC000705-A_Commissioning.Commissioning
    Prepare 5GC000705-A-noXn WTS Config
    ute_workarounds.Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_705-A-noXn}
    Set Suite Variable  ${suite_setup_status}  Finished

Perform Precondition of Test Case
    Set Test Variable    ${TEST_RESULT}   failed
    IF    '${PREV_TEST_STATUS}'=='FAIL'
        Teardown Egate Connection for Airphone
        Teardown Edaemon Connection for Airphone
        Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_705-A-noXn}
    END

Perform Postconditions of Test Case
    Stop logging
    IF    '${TEST_MODE}'=='auto'   Collect AP Sos Report and Snapshots
    Revert Current Delta Commissioning

Revert Current Delta Commissioning
    ${log_dir}=               Get Testcase Log Directory
    ${scf}=                   Get SCF from gNB  target_dir=${log_dir}
    ${ts_conf_dir}=           Get Test Suite Config Directory
    ${revert_file}=           Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf   ${ts_conf_dir}/${5GC000705-A_SCF}  ${scf}  ${revert_file}
    Config gNB with delta scf                ${revert_file}

Prepare 5GC000705-A-noXn WTS Config
    ${WTS_CFG_FILE_705-A-noXn}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_705-A-noXn}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.insert              set GNB3_NG_ADDR="${NGIP_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set GNB3_PROXY_ADDR="${PROXY_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert
    ...  set_gnb id=${Simulated_gnb_ID} type=simulated plmn=311:489 ng=$GNB3_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...  after  set_gnb id=2
    wts_conf.modify
    ...  set_gnb id=${Simulated_gnb_ID}  gnb_id=0x3:22 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts_conf.insert              set_cell id=1 gnb=${Simulated_gnb_ID} pci=16:0 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=${nrarfcn}:${nrarfcn}
    ...                          after  set_cell id=1 gnb=2
    wts_conf.modify
    ...  set_cell id=1 gnb=${Simulated_gnb_ID}  proxy=$GNB3_PROXY_ADDR:9999|$GNB3_PROXY_ADDR:8888 mandatory_for_activation=off
    wts_conf.insert    ue_param id=1 nr_usage_setting=voice_centric  after  ue_param id=1
    wts_conf.modify    qosflow_set id=1    modification=5qi=5
    wts_conf.modify    set_qosflow id=2    modification=5qi=1
    wts_conf.delete    set_qosflow id=3
    wts_conf.delete    set_qosrule id=1
    wts_conf.delete    set_qosrule id=2
    wts_conf.insert    set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=2
    wts_conf.insert    set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.modify    nwslice_set id=1    modification=qos_flows=1,2 qos_rules=1,2
    wts_conf.modify              ue_param id=1       ${UE_CAPA_${CELL_TECHNOLOGY}}

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_705-A-noXn}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_705-A-noXn}  ${ts_conf_dir}

Prepare 5GC000705-A-inter-gNB_B6 WTS Config
    ${WTS_CFG_FILE_705-A-inter-gNB_B6}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_705-A-inter-gNB_B6}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.insert              set GNB_XN_ADDR="10.0.1.2"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set GNB3_XN_ADDR="${XNIP_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set GNB3_NG_ADDR="${NGIP_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set GNB3_PROXY_ADDR="${PROXY_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.modify              set_gnb id=2              xn=$GNB_XN_ADDR
    wts_conf.insert
    ...  set_gnb id=${Simulated_gnb_ID} type=simulated plmn=311:489 ng=$GNB3_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...  after  set_gnb id=2
    wts_conf.modify
    ...  set_gnb id=${Simulated_gnb_ID}  gnb_id=0x3:22 x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts_conf.insert              set_cell id=1 gnb=${Simulated_gnb_ID} pci=16:0 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=${nrarfcn}:${nrarfcn}
    ...                          after  set_cell id=1 gnb=2
    wts_conf.modify
    ...  set_cell id=1 gnb=${Simulated_gnb_ID}  proxy=$GNB3_PROXY_ADDR:9999|$GNB3_PROXY_ADDR:8888 mandatory_for_activation=off
    wts_conf.insert
    ...  gnb_param id=${Simulated_gnb_ID} xn_listening_socket=1 sib1_period=160ms send_xn_setup=false
    ...  after  set_gnb id=${Simulated_gnb_ID}

    wts_conf.insert    ue_param id=1 nr_usage_setting=voice_centric  after  ue_param id=1
    wts_conf.modify    qosflow_set id=1    modification=5qi=5
    wts_conf.modify    set_qosflow id=2    modification=5qi=1
    wts_conf.delete    set_qosflow id=3
    wts_conf.delete    set_qosrule id=1
    wts_conf.delete    set_qosrule id=2
    wts_conf.insert    set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=2
    wts_conf.insert    set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.modify    nwslice_set id=1    modification=qos_flows=1,2 qos_rules=1,2
    wts_conf.modify              ue_param id=1       ${UE_CAPA_B6_${CELL_TECHNOLOGY}}

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_705-A-inter-gNB_B6}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_705-A-inter-gNB_B6}  ${ts_conf_dir}

Prepare 5GC000705-A-intra-gNB_B6 WTS Config
    ${WTS_CFG_FILE_705-A-intra-gNB_B6}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_705-A-intra-gNB_B6}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.modify              ue_param id=1       ${UE_CAPA_B6_${CELL_TECHNOLOGY}}
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_705-A-intra-gNB_B6}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_705-A-intra-gNB_B6}  ${ts_conf_dir}

Setup for 5GC000705-A-B2
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_705-A-noXn}  force_cu_type=SA

Setup for 5GC000705-A-intra-gNB_B6
    Prepare 5GC000705-A-intra-gNB_B6 WTS Config
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_705-A-intra-gNB_B6}  force_cu_type=SA

Setup for 5GC000705-A-inter-gNB_B6
    Prepare 5GC000705-A-inter-gNB_B6 WTS Config
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_705-A-inter-gNB_B6}  force_cu_type=SA

Setup for 5GC000705-A-B7
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_705-A-noXn}  force_cu_type=SA

Apply Config for 5GC000705-A_B1
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    5GC000705-A_Commissioning.Add NRREL to SCF
    5GC000705-A_Commissioning.Add NRADJNRCELL to SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF NoXn
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    Apply Delta SCF           ${scf_file}  scf_B1

Apply Config for 5GC000705-A_B2
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=targetOnly
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    5GC000705-A_Commissioning.Add NRREL to SCF

    5GC000705-A_Commissioning.Add NRADJNRCELL to SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF NoXn
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    Apply Delta SCF           ${scf_file}  scf_B2

Apply Config for 5GC000705-A_EC1
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    5GC000705-A_Commissioning.Add NRREL to SCF

    5GC000705-A_Commissioning.Add NRADJNRCELL to SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF NoXn

    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-1     list_name=emergencyCallRestrictions
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-1   list_name=emergencyCallRestrictions
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-1    list_name=emergencyCallRestrictions
    ${emergency_call_dict}    Create dictionary  emergencyCallMrListIgnore  true  emergencyCallPlmnHoAllowed  true
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-1   list_name=emergencyCallRestrictions   elements=${emergency_call_dict}

    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrMobilityReportCu    value=5min
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrNGCC    value=5min

    5GC000705-A_Commissioning.Modify NRDRB15 in SCF
    5GC000705-A_Commissioning.Modify NRDRB5QI6 in SCF
    5GC000705-A_Commissioning.Modify NRDRBRMAC3 in SCF
    5GC000705-A_Commissioning.Add NRDRBPDCP3 to SCF
    5GC000705-A_Commissioning.Modify NRDRBRLCUM1 in SCF
    Apply Delta SCF           ${scf_file}  scf_EC1

Apply Config for 5GC000705-A_EC2
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    5GC000705-A_Commissioning.Add NRREL to SCF
    5GC000705-A_Commissioning.Add NRADJNRCELL to SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF NoXn

    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrNGCC    value=5min

    Apply Delta SCF           ${scf_file}  scf_EC2

Apply Config for 5GC000705-A_EC1_robust
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1    p_name=blockHoTimer    value=0

    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    5GC000705-A_Commissioning.Add NRREL to SCF

    5GC000705-A_Commissioning.Add NRADJNRCELL to SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF NoXn

    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-1     list_name=emergencyCallRestrictions
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-1   list_name=emergencyCallRestrictions
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-1    list_name=emergencyCallRestrictions
    ${emergency_call_dict}    Create dictionary  emergencyCallMrListIgnore  true  emergencyCallPlmnHoAllowed  true
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-1   list_name=emergencyCallRestrictions   elements=${emergency_call_dict}

    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrMobilityReportCu    value=5min
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrNGCC    value=5min

    5GC000705-A_Commissioning.Modify NRDRB15 in SCF
    5GC000705-A_Commissioning.Modify NRDRB5QI6 in SCF
    5GC000705-A_Commissioning.Modify NRDRBRMAC3 in SCF
    5GC000705-A_Commissioning.Add NRDRBPDCP3 to SCF
    5GC000705-A_Commissioning.Modify NRDRBRLCUM1 in SCF
    Apply Delta SCF           ${scf_file}  scf_EC1_robust

Apply Config for 5GC000705-A_B6_intra_gNB
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actSaUeBasedAnrNr    value=true
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=drbInactivityTimerSA    value=6000
    Activate connected DRX and Fix Relation Error by adding suppCnPartialAdNgHo to default value
    5GC000705-A_Commissioning.Add NRANR to SCF
    5GC000705-A_Commissioning.Add NRANRPR to SCF
    Apply Delta SCF           ${scf_file}  scf_B6_intra_gNB

Apply Config for 5GC000705-A_B6_inter_gNB
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraFreqHoSA    value=true
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu    value=5min
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1    p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=NRBTS-1   p_name=timerXnDataFwdGuard   value=250

    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actSaUeBasedAnrNr    value=true
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=drbInactivityTimerSA    value=6000
    Activate connected DRX and Fix Relation Error by adding suppCnPartialAdNgHo to default value
    5GC000705-A_Commissioning.Add NRANR to SCF
    5GC000705-A_Commissioning.Add NRANRPR to SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF
    5GC000705-A_Commissioning.Add NRADJNRCELL to SCF
    Apply Delta SCF           ${scf_file}  scf_B6_inter_gNB

Trigger A3 Handover B1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}   pass_regexp=Received HandoverNotify

Trigger A3 Handover B2
    [Arguments]    ${meas_id}=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    fail_regexp=Received Handover Required    timeout=10    alias=ap_egate

Trigger A3 Handover Radio Resources not available
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   amf_ue_ng_handover_param id=1 ue=1 action=ho_preparation_failure cause=RN_radio_resources_not_available
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Forced Handover Preparation Failure for UE
    Sleep   1s
    # triggering 2nd UE measurement report within blockHoTimer, Handover Required should not be triggered from source gNB
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    fail_regexp=Received Handover Required    timeout=10    alias=ap_egate

Trigger A3 Handover 5QI not supported
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   amf_ue_ng_handover_param id=1 ue=1 action=ho_preparation_failure cause=RN_slice_not_supported
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Forced Handover Preparation Failure for UE
    Sleep   1s
    # triggering 2nd UE measurement report within blockHoTimer, Handover Required should not be triggered from source gNB
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    fail_regexp=Received Handover Required    timeout=10    alias=ap_egate

Trigger A3 Handover HO Target not allowed
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   amf_ue_ng_handover_param id=1 ue=1 action=ho_preparation_failure cause=RN_ho_target_not_allowed
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Forced Handover Preparation Failure for UE
    Sleep   1s
    # triggering 2nd UE measurement report within blockHoTimer, Handover Required should not be triggered from source gNB
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    fail_regexp=Received Handover Required    timeout=10    alias=ap_egate

Trigger A3 Handover Radio Network unspecified
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   amf_ue_ng_handover_param id=1 ue=1 action=ho_preparation_failure cause=RN_CauseRadioNetwork_unspecified
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Forced Handover Preparation Failure for UE
    Sleep   1s
    # triggering 2nd UE measurement report within blockHoTimer, Handover Required should not be triggered from source gNB
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    fail_regexp=Received Handover Required    timeout=10    alias=ap_egate

Trigger A3 Handover Amf no response
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   amf_ue_ng_handover_param id=1 ue=1 action=no_response
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Sending Handover Cancel Acknowledge
    Sleep   1s
    # triggering 2nd UE measurement report within blockHoTimer, Handover Required should not be triggered from source gNB
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    fail_regexp=Received Handover Required    timeout=10    alias=ap_egate

Trigger A3 Handover unknown PCI intra gNB
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 phycell_id=51 nrsrp_nr=100
    ...       phycell_id=60 nrsrp_nr=45
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Sleep   200s    # time required for creation of NRREL object needed for verification

Trigger A3 Handover unknown PCI inter gNB
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd}    Catenate   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 phycell_id=48 nrsrp_nr=100
    ...       phycell_id=60 nrsrp_nr=45
    Send Egate Command and verify output   cmd=${cmd}
    ...       pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Sleep   200s    # time required for creation of NRREL object needed for verification

Verify NRREL Object Creation
    [Arguments]    ${save_scf_post_verification}
    Load current SCF
    ${dist_name}=   Set Variable    NRBTS-1/NRCELL-1/NRREL-256
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    ${hoallowed}=   IF   ${mo_exist}==True
    ...             scf.get_value_from_scf   dist_name=NRBTS-1/NRCELL-1/NRREL-256   p_name=handoverAllowedSA
    ...    ELSE     Set Variable    failed
    ${tc_conf_dir}=   Get Testcase Log Directory
    scf.save_scf    ${tc_conf_dir}/${save_scf_post_verification}
    IF    ${mo_exist}!=True or '${hoallowed}'!='allowed'    FAIL    missing MOC or wrong parameter value


Collect and Verify PM Counters
    [Arguments]   ${tc_instance}
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    ${rd_files}=   Collect RD Counters
    PM Counter Verification    ${pm_files}    ${${tc_instance}_COUNTERS}

Collect PM counters
    ${log_dir}=    testline.Get Testcase Log Directory
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}
    RETURN  ${pm_files}

PM Counter Verification
    [Arguments]   ${counter_files}  ${counter_names}  ${counter_value}=1  ${cell_id}=1
    FOR  ${counter}  IN  @{counter_names}
	   Check PM counter value equal   ${counter_value}   ${counter_files}   ${counter}   NRBTS-1/NRCELL-${cell_id}
    END

RD Counter Verification
    [Arguments]   ${counter_files}  ${counter_names}  ${counter_value}=1  ${cell_id}=1
    FOR  ${counter}  IN  @{counter_names}
	   Check RD counter value equal   ${counter_value}   ${counter_files}   ${counter}   NRBTS-1/NRCELL-${cell_id}
    END

Collect RD Counters
    ${gnb_conn}=   connect.Connect to Node Common Unit
    ${RD_counter_dir}=   Extract gz file    file_pattern=/tmp/RD.BTS-1*.gz    connection=${gnb_conn}
    RETURN    ${RD_counter_dir}

Extract gz file
    [Documentation]    :Author: Jing Liang
    ...
    [Arguments]    ${file_pattern}    ${connection}
    ${target_dir}=    testline.Get Testcase Log Directory
    ${target_dir_rd_counters}=    Set variable    ${target_dir}/gnb_rd_counters
    Set Suite Variable    ${target_dir_rd_counters}
    Create directory    ${target_dir_rd_counters}

    ${file_path}=    Get File Path on Target    file_pattern=${file_pattern}    connection=${connection}
    ${folder}    ${filename}=    Split String From Right    ${file_path}    separator=/    max_split=1
    Set Test Variable    ${source_file}    /tmp/${filename}
    ssh.execute    gunzip -c ${source_file} > /tmp/RD.BTS_counters.xml    connection=${connection}
    ssh.Download File   /tmp/RD.BTS_counters.xml   ${target_dir_rd_counters}/RD.BTS_counters.xml    connection=${connection}
    RETURN    ${target_dir_rd_counters}

Get RD counter value
    [Documentation]   adapted from Get PM counter value:Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=RD.BTS*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Contain  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    Log    ${pi_id} value: ${pi_value}   console=${P_console}
    RETURN    ${pi_value}

Check RD counter value equal
    [Documentation]   adapted from Check PM counter value equal:Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}     PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}

Verify EC2 pmcounters
    [Arguments]    ${pm_files_location}
    ${expected_pm_counter_list}=    Create List
    ...   M55125C07516  ==  1       NGAP: HO Cancel msg sent during prep phase for NG based HO on the source cell
    ...   M55125C07517  ==  1       NGAP: HO Cancel Acknowledge msg received during prep phase for NG based HO on the source cell
    ...   M55125C07511  ==  1       failed NG based HO prep att on the source cell due TNGRELOCprep guard timer expiry

    Verify PM Counter Reference Table     pm_dir=${pm_files_location}    reference_table=${expected_pm_counter_list}

Set Emergency Call Priority
    [Arguments]   ${priority}=1  ${ue_id}=1
    Send Egate Command and verify output    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Send Egate Command and verify output    qosflow_modify qos_flow=1 priority=${priority}
    Send Egate Command and verify output    qosflow_modify qos_flow=2 priority=${priority}

Start data traffic on 2 PDU sessions
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=2   qfi=1   mbps=1
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=2   pdu=2   qfi=2   mbps=1

Stop data traffic on 2 PDU sessions
    Get Average Data Rate via Egate    ue_id=1    dir=dl    trf_id=1    pdu=1    qfi=1
    Get Average Data Rate via Egate    ue_id=1    dir=dl    trf_id=1    pdu=2    qfi=1
    Get Average Data Rate via Egate    ue_id=1    dir=dl    trf_id=2    pdu=2    qfi=2
    Stop data traffic in egate   ue_id=1   direction=dl   trf_id=1   pdu=1   qfi=1
    Stop data traffic in egate   ue_id=1   direction=dl   trf_id=1   pdu=2   qfi=1
    Stop data traffic in egate   ue_id=1   direction=dl   trf_id=2   pdu=2   qfi=2

Get SW Branch
    ${SW_BRANCH}=    testline.Get gNB SW Branch
    Set Suite Variable  ${SW_BRANCH}
