*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource          Resources/1347_common_keyword.robot
Variables         Resources/2537_variables.py
Library    taf.analyzer.pcap        WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/gnb_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot

*** Variables ***
${mcs_ip}    ${tl.mcses.ip_addr}
${mcs_model}    ${tl.mcses.model}
@{2537disable_horizontal}    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35    -35
@{2537disable_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
@{beam_set_2_horizontal}    -19    -19    19    19    -19    -19    19    19    -19    -19    19    19    -19    -19    19    19
@{beam_set_5_1_horizontal}    -33    -33    -16    -16    0    0    0    0    16    16    33    33    -33    -33    -16    -16
@{beam_set_6_horizontal}    -35    -35    -20    -20    -7    -7    7    7    20    20    35    35    -35    -35    -20    -20
@{Beamset3_1_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
@{Beamset3_1_refinebeam_horizontal}    -39    -39    -31    -31    -17    -17    -10    -10    10    10    17    17    31    31    39    39
@{Beamset8_horizontal}    -37    -37    -26    -26    -15     -15    -5    -5    5    5    15    15    26    26    37    37
@{beam_set_2_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
@{beam_set_5_1_vertical}    96    96    96    96    96    96    96    96    96    96    102    102    96    96    96    96
@{beam_set_6_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
@{Beamset3_1_vertical}    96    96    96    96    96    96    102    102    96    96    96    96    96    96    102    102
@{Beamset3_1_refinebeam_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
@{Beamset8_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
${luashark_path_21A}    /home/ute/Downloads/Lua/generated_luashark_21A/luashark.lua
${luashark_path_TRUNK}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R2/luashark.lua
${scf_path}       /home/ute/Downloads/SCF
${scf_100M_common}    ${scf_path}/common.xml
${scf_FDM_disable}    ${scf_path}/common_100m_679_disable.xml
${scf_80m}    ${scf_path}/common_80m.xml
${scf_80m_b5_1}    ${scf_path}/common_80m_b5_1.xml
${scf_20m}    ${scf_path}/common_20M.xml
${scf_20m_al2}    ${scf_path}/common_20M_AL2.xml
${scf_40m}    ${scf_path}/common_40M.xml
${scf_60m}    ${scf_path}/common_60m_beamset_2.xml
${scf_60m_refine}    ${scf_path}/common_60m_beamset_3_1_refine.xml
${scf_100m_beamset8}    ${scf_path}/common_100m_beamset8.xml
${scf_100m_beamset8_refine}    ${scf_path}/common_100m_beamset8_refine.xml
${scf_enable_2200}    ${scf_path}/common_enable_2200.xml
${scf_2056_2x2}    ${scf_path}/CB002056_2x2.xml
${tshark_path}    /usr/bin/tshark
${expression_cmas_ul}    \"uldata_puschreceivereq\"
${command_template_ul_21A}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_21A} -Y ${expression_cmas_ul} -T pdml
${command_template_ul_TRUNK}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_TRUNK} -Y ${expression_cmas_ul} -T pdml
${expression_cmas_dl}    \"dldata_pdschsendreq\"
${command_template_dl_21A}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_21A} -Y ${expression_cmas_dl} -T pdml
${command_template_dl_TRUNK}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_TRUNK} -Y ${expression_cmas_dl} -T pdml
${pdsch_sfn_filed_name}    DlData_PdschSendReq.PdschSendReq.sfn
${pdsch_slot_filed_name}    DlData_PdschSendReq.PdschSendReq.slot
${pdsch_rnti_filed_name_21A}    DlData_PdschSendReq.grants_item_15.rnti
${pdsch_rnti_filed_name_TRUNK}    DlData_PdschSendReq.grants_item_0.rnti
${pdsch_pid_filed_name}    DlData_PdschSendReq.patternId.patternId_item_0
${pusch_sfn_filed_name_xpath}    UlData_PuschReceiveReq.PuschReceiveReq.sfn
${pusch_slot_filed_name_xpath}    UlData_PuschReceiveReq.PuschReceiveReq.slot
${pusch_rnti_filed_name_xpath_21A}    .//UlData_PuschReceiveReq.grants_item_15.rnti
${pusch_rnti_filed_name_xpath_TRUNK}    .//UlData_PuschReceiveReq.grants_item_0.rnti
${pusch_pid_filed_name_xpath}    .//UlData_PuschReceiveReq.patternId.patternId_item_0
${sfn_d}    DlData_PdschSendReq.PdschSendReq.sfn
${slot_d}    DlData_PdschSendReq.PdschSendReq.slot
${rnti_d}    DlData_PdschSendReq.grants_item_0.rnti
${prb_d}    DlData_PdschSendReq.grants_item_0.numOfPrb
${antport_d}    DlData_PdschSendReq.grants_item_0.antPort
${scramb_d}    DlData_PdschSendReq.grants_item_0.dmrsScramblingSequenceInt

*** Test Cases ***
[1][1.0] 5GC002537-F2_DL_and_UL_scheduling_of_8_UEs_in_a_single_slot_with_FD_BF_when_refined_beam_enable
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=@{2537disable_horizontal}    vertical_set=@{2537disable_vertical}
    Set Test Variable    ${ue_num}    ${4}
    Reload Case SCF and Commission    scf_file=${scf_FDM_disable}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
    Check Value for disable 2537
    [Teardown]    Case Teardown

[2][1.0] 5GC002537-F2_DL_and_UL_scheduling_of_4_UEs_in_a_single_slot_with_FD_BF_when_refined_beam_enable
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_100M_common}
    COAM Save snapshot via rest api
    #${output}    Get log from gnb
    #should contain    ${output}    item=actFdmEnhancedScheduling=1
    #should contain    ${output}    item=actFdmScheduling=1
    #should contain    ${output}    item=dlEcpriFdBeamforming=1
    #should contain    ${output}    item=ulEcpriFdBeamforming=1
    #${ExternalAntenna}    Get_parameter_value    abbr=actExternalAntennaBF    filter_param=Activate external antenna beamforming
    #${actbf}    Get_parameter_value    abbr=actBeamforming    filter_param=Activate Beamforming
    #Run Keyword If    '${ExternalAntenna}'=='true'    should be true    '${actbf}'=='false' or '${actbf}'=='true'
    #...    ELSE IF    '${ExternalAntenna}'=='false'    should be true    '${actbf}'=='true'
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=150    num=${ue_num}
    Check Value for 2537-F
    [Teardown]    Case Teardown

[1][1.0] 5GC002537-A1_Feature_activation_when_actFdmScheduling_is_true_and_EcpriFdBeamforming_is_false
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}    vertical_set=${beam_set_5_1_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_80m_b5_1}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=120    num=${ue_num}
    Check Value for 2537-E
    [Teardown]    Case Teardown

CB002537_100M_6UE_COUNTER
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_100M_common}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Run keyword and ignore error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
    sleep    15min
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C20001
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C20002
    ${counter3}    Check BTS Counters via webUI    counter_id=M55308C21001
    ${counter4}    Check BTS Counters via webUI    counter_id=M55308C21002
    ${counter5}    Check BTS Counters via webUI    counter_id=M55308C21003
    ${counter6}    Check BTS Counters via webUI    counter_id=M55308C21004
    ${counter7}    Check BTS Counters via webUI    counter_id=M55308C17002
    ${counter8}    Check BTS Counters via webUI    counter_id=M55308C18002
    Should Contain    ${counter1}    273
    Should Contain    ${counter2}    273
    should be true    ${counter3}[-1]>=${1000000} or ${counter3}[-2]>=${1000000}
    should be true    ${counter4}[-1]>=${4} or ${counter4}[-2]>=${4}
    should be true    ${counter5}[-1]>=${100000} or ${counter5}[-2]>=${100000}
    should be true    ${counter6}[-1]>=${2} or ${counter6}[-2]>=${2}
    should be true    ${counter7}[-1]>=${4} or ${counter7}[-2]>=${4}
    should be true    ${counter8}[-1]>=${4} or ${counter8}[-2]>=${4}
    [Teardown]    Case Teardown

CB002537_20M_6UE_Beamset6
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_20m}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=30    num=${ue_num}
    [Teardown]    Case Teardown

CB002537_20M_6UE_Beamset6_AL2
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_20m_al2}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=30    num=${ue_num}
    Check Value for 2537-E
    [Teardown]    Case Teardown

CB002537_40M_6UE_Beamset6
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_40m}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=50    num=${ue_num}
    Check Value for 2537-E
    [Teardown]    Case Teardown

CB002537_1SUBCELL_100M_6UE _beamset6_enable2200
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_enable_2200}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=150    num=${ue_num}
    [Teardown]    Case Teardown

CB002537_60M_6UE_Beamset2
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_2_horizontal}    vertical_set=${beam_set_2_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_60m}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
    [Teardown]    Case Teardown

CB002537_60M_6UE_Beamset3_1_refinebeam
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${Beamset3_1_refinebeam_horizontal}    vertical_set=${Beamset3_1_refinebeam_vertical}
    Set Test Variable    ${ue_num}    ${6}
    Reload Case SCF and Commission    scf_file=${scf_60m_refine}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
    [Teardown]    Case Teardown

CB002537_2SUBCELL_100M_Beamset8_8ue
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${Beamset8_horizontal}    vertical_set=${Beamset8_vertical}
    Set Test Variable    ${ue_num}    ${8}
    Reload Case SCF and Commission    scf_file=${scf_100m_beamset8}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
    Check Value for 2537-H
    [Teardown]    Case Teardown

CB002537_100M_Beamset8_8ue_refinebeam
    [Tags]    5GC002537
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${Beamset8_horizontal}    vertical_set=${Beamset8_vertical}
    Set Test Variable    ${ue_num}    ${8}
    Reload Case SCF and Commission    scf_file=${scf_100m_beamset8_refine}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
    [Teardown]    Case Teardown

CB002056-524_ABIO_MU_MIMO_2x2
    [Tags]    5GC002056
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${Beamset8_horizontal}   vertical_set=${Beamset8_vertical}
    Reload Case SCF and Commission    scf_file=${scf_2056_2x2}
    Common UE Attach    ue_index=0    attach_mode=5G_NSA
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=0    send_traffic=50MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=0    send_traffic=500MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Common UE Attach    ue_index=1    attach_mode=5G_NSA
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=1    send_traffic=50MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=1    send_traffic=500MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Common UE Attach    ue_index=2    attach_mode=5G_NSA
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=2    send_traffic=50MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=2    send_traffic=500MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Common UE Attach    ue_index=3    attach_mode=5G_NSA
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=3    send_traffic=50MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=3    send_traffic=500MKbits/sec
    ...    send_duration=1800    ue_mode=NSA
    sleep    5s
    Check DL UL Throughput On Site
    Common Capture BIP log and download
    Check Value for 2056 2x2
    Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=0    ue_mode=NSA
    Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=0    ue_mode=NSA
    Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=3    ue_mode=NSA
    Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=3    ue_mode=NSA
    [Teardown]    Case Teardown

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_ul}    ${command_template_ul_TRUNK}
    ...    ELSE    set test variable    ${command_template_ul}    ${command_template_ul_21A}
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_dl}    ${command_template_dl_TRUNK}
    ...    ELSE    set test variable    ${command_template_dl}    ${command_template_dl_21A}
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${pdsch_rnti_filed_name}    ${pdsch_rnti_filed_name_TRUNK}
    ...    ELSE    set test variable    ${pdsch_rnti_filed_name}    ${pdsch_rnti_filed_name_21A}
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${pusch_rnti_filed_name_xpath}    ${pusch_rnti_filed_name_xpath_TRUNK}
    ...    ELSE    set test variable    ${pusch_rnti_filed_name_xpath}    ${pusch_rnti_filed_name_xpath_21A}
    robot_common_operations.Common Suite Setup

Case Teardown
    Run keyword and ignore error    Multi UE Detach And Stop Traffic
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Multi UE Detach And Stop Traffic
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}    ue_mode=NSA
        Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}    ue_mode=NSA
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}
    END

Multi UE Attach And Send DL Traffic
    [Arguments]    ${send_traffic_dl}=200MKbits/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Common UE Attach    ue_index=${ue_no}    attach_mode=5G_NSA
        sleep    3s
        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
        ...    send_duration=${send_duration}    ue_mode=NSA
    END

Multi UE Attach And Send Traffic
    [Arguments]    ${send_traffic_ul}=50MKbits/sec    ${send_traffic_dl}=300MKbits/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Common UE Attach    ue_index=${ue_no}    attach_mode=5G_NSA
        sleep    3s
        Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
        ...    send_duration=${send_duration}    ue_mode=NSA
        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
        ...    send_duration=${send_duration}    ue_mode=NSA
    END

Check DL UL Throughput On Site
    [Arguments]
    run keyword and ignore error    power_ue.Check throughput    ue_type=huawei    direction=ul    throughput=0
    run keyword and ignore error    power_ue.Check throughput    ue_type=huawei    direction=dl    throughput=0

Multi UE Check DL Tput
    [Arguments]    ${check_traffic_dl}=100    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Run Keyword And Continue On Failure    Common UE Check DL Tput    ue_index=${ue_no}
        ...    check_traffic=${check_traffic_dl}    ue_mode=NSA
    END

Multi UE Check Tput
    [Arguments]    ${check_traffic_ul}=5    ${check_traffic_dl}=50    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Run Keyword And Continue On Failure    Common UE Check UL And DL Tput    ue_index=${ue_no}
        ...    check_traffic_ul=${check_traffic_ul}    check_traffic_dl=${check_traffic_dl}
    END

evaluate value
    [Arguments]    ${count}
    ${count}    evaluate    ${count}+${1}
    Set Test Variable    ${count}

Get log from gnb
    Connect to Common Unit Master
    ${output}  csn.Execute  command=bsh 1:1 lxc-attach -n 0x1740 'zcat /tmp/ASP-1740_startup.zip | grep -i actfdm'
    ...    connection=ASIK Master
    Csn.Disconnect	connection=ASIK Master
    [Return]    ${output}

check numOfLayers
    [Arguments]    ${length}    ${mcs}    ${nol}    ${nop}
    FOR    ${len}    IN RANGE    ${length}
        Run Keyword If    ${mcs}[${len}]==0x00000000 and ${nol}[${len}]==0x00000001    should be true    ${nop}[${len}]<=0x0000005D
        ...    ELSE IF    ${mcs}[${len}]==0x00000000 and ${nol}[${len}]==0x00000002    should be true    ${nop}[${len}]<=0x0000002E
        ...    ELSE    log    "not fit"
    END

Check Value for disable 2537
    [Arguments]    ${num}=4
    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_template_ul}
    FOR    ${i}    IN RANGE    ${num}
        ${mcs}    Get value from Bip Log    field_name=UlData_PuschReceiveReq.grants_item_${i}.mcs
        ${nol}    Get value from Bip Log    field_name=UlData_PuschReceiveReq.grants_item_${i}.numOfLayers
        ${nop}    Get value from Bip Log    field_name=UlData_PuschReceiveReq.grants_item_${i}.numOfPrb
        ${length}    Get Length    ${mcs}
        should be true    ${length}>=${10}
        check numOfLayers    length=${length}    mcs=@{mcs}    nol=@{nol}   nop=@{nop}
    END
    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_template_dl}
    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_filed_name}    field_name_slot=${pdsch_slot_filed_name}
    ...    item_name=${pdsch_rnti_filed_name}    target_item_num=${4}
    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_filed_name}    field_name_slot=${pdsch_slot_filed_name}
    ...    item_name=${pdsch_pid_filed_name}    target_item_num=${1}    target_succ_rate=${0.99}

Check Value for 2537-E
    [Arguments]    ${pcap_file}=${bip_log_path}
    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${command_template_dl}
    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_filed_name}    field_name_slot=${pdsch_slot_filed_name}
    ...    item_name=${pdsch_rnti_filed_name}    target_item_num=${4}
    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_filed_name}    field_name_slot=${pdsch_slot_filed_name}
    ...    item_name=${pdsch_pid_filed_name}    target_item_num=${4}

Check Value for 2537-F
    [Arguments]    ${pcap_file}=${bip_log_path}
    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${command_template_ul}
    Check Item Num Per Slot   field_name_sfn=${pusch_sfn_filed_name_xpath}   field_name_slot=${pusch_slot_filed_name_xpath}
    ...    item_name=${pusch_rnti_filed_name_xpath}    target_item_num=${4}
    Check Item Num Per Slot   field_name_sfn=${pusch_sfn_filed_name_xpath}   field_name_slot=${pusch_slot_filed_name_xpath}
    ...    item_name=${pusch_pid_filed_name_xpath}    target_item_num=${4}

Check Value for 2537-H
    [Arguments]    ${pcap_file}=${bip_log_path}
    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${command_template_dl}
    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_filed_name}    field_name_slot=${pdsch_slot_filed_name}
    ...    item_name=${pdsch_rnti_filed_name}    target_item_num=${8}

Check Value for 2056 2x2
    [Arguments]    ${pcap_file}=${bip_log_path}
    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${command_template_dl}
    @{sfn}     Get value from Bip Log    field_name=${sfn_d}
    @{slot}    Get value from Bip Log    field_name=${slot_d}
    @{rnti}    Get value from Bip Log    field_name=${rnti_d}
    @{prb}     Get value from Bip Log    field_name=${prb_d}
    @{antport}    Get value from Bip Log    field_name=${antport_d}
    ${rnti_l}    get length    ${rnti}
    @{rnti_c}    Remove Duplicates    ${rnti}
    ${count_r}    get length    ${rnti_c}
    should be true    ${count_r}>=2
    Set Test Variable    ${count}    ${0}
    FOR    ${len}    IN RANGE    ${200}
        ${len1}    evaluate    ${len}+1
        ${result1}    Evaluate    ${sfn}[${len}]==${sfn}[${len1}]
        ${result2}    Evaluate    ${slot}[${len}]==${slot}[${len1}]
        ${result3}    Evaluate    ${rnti}[${len}]!=${rnti}[${len1}]
        ${result4}    Evaluate    ${prb}[${len}]==${prb}[${len1}]
        ${result5}    Evaluate    ${antport}[${len}]!=${antport}[${len1}]
        Run Keyword if    ${result1} and ${result2} and ${result3} and ${result4} and ${result5}    Set Test Variable    ${count}    ${${count}+1}
    END
	should be true    ${count}>=10
