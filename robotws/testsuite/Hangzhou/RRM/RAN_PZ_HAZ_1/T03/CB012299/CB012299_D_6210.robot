*** Settings ***
Documentation
...   author: GAO ZHUO
...   contact: zhuo.1.gao@nokia-sbell.com
...   this is a robot case about CB012299_D

Resource          ../Resources/common_resource.robot
Force Tags        CRT    RAN_5G    STATE_SKIP_AGENT
...               SBTS00   CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG07_ST_RRM    TA_LEVEL_22
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Variables ***
${DEBUG_MODE}            ${TRUE}
# @{mo_list}               MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
# ...                      MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
# ${TTI_cell}              NRCELL_R-31
# &{fault_4655}            faultId=${4655}
# &{fault_4654}            faultId=${4654}
# &{fault_61524}           faultId=${61524}
# &{fault_61652}           faultId=${61652}
# &{fault_2002}            faultId=${2002}
# &{fault_7300}            faultId=${7300}
# &{fault_61649}           faultId=${61649}
# &{fault_4592}            faultId=${4592}
# @{Ohter_Allow_Alarms}    &{fault_4655}    &{fault_4654}    &{fault_2002}    &{fault_61524}    &{fault_61652}
# &{dcap_info}    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
# ${tti_path}      /home/ute/test_results/

*** Test Cases ***
# CB012299_D_01_Scell addition scenario in nominal bandwidth mode
# CB012299_D_02_Scell in nominal PCell has activated CB012299 Semi-dynamic bandwidth size switching feature and PCell is in nominal
# CB012299_D_05_Scell in nominal bandwidth mode_SA Carrier Aggregation SCell selection Scell configured with small BWP
# CB012299_D_07_Scell in transition from nominal bandwidth to limited bandwidth mode
# CB012299_D_08_Scell in transition from nominal to limited mode_PCell has activated CB012299 Semi-dynamic bandwidth size switching feature
# CB012299_D_10_Scell addition scenario in limited bandwidth mode
# CB012299_D_11_Scell in limited mode_PCell has activated CB012299 Semi-dynamic size switching feature and PCell is in limited mode
# CB012299_D_14_Scell in limited bandwidth mode_SA Carrier Aggregation SCell selection Scell configured with small BWP
# CB012299_D_16_Scell addition scenario in transition from limited bandwidth to nominal bandwidth mode
# CB012299_D_17_Scell from limited to nominal PCell activated CB012299 Semi-dynamic size switching feature and PCell is from limited to nominal
# CB012299_D_19_Scell addition scenario when set semiDynamicBwSize= limitedBandwidth with feature turn off
# CB012299_D_20_Scell addition scenario in nominal mode when feature turn off and online change semiDynamicBwSize from nominal to limited mode
# CB012299_D_21_Scell addition scenario in nominal bandwidth mode_PCell has activated CB012299 and PCell is in limited bandwidth mode
# CB012299_D_22_Scell addition scenario in limited bandwidth mode_PCell has activated CB012299 and PCell is in nominal bandwidth mode
# CB012299_D_23_Scell addition scenario in limited bandwidth mode_PCell has deactivated CB012299 and enable RAT1

CB012299_D_01_Scell addition scenario in nominal bandwidth mode
    [Documentation]
    ...    n3(AHEGB) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s
    block_other_gnb_cells_1078_4001
    block_other_enb_cells_88_3
    set_testline_cell-33_status_onair
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    # Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    # ...                  counter_rule=${CURDIR}/counter_rule12299_D.txt
    detach_QC8450
    sleep    3s
    attach_QC8450
    Change AKNB to nominalBandwidth
    sleep    3s
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    sleep    3s
    8450_DLstart
    sleep    300s
    8450_DLstop
    sleep    3s
    # Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    # sleep      3s
    unblock_all_6210_cells
    Change AKNB to nominalBandwidth

CB012299_D_16_Scell addition scenario in transition from limited bandwidth to nominal bandwidth mode
    [Documentation]
    ...    n3(AHEGB) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s
    block_other_gnb_cells_1078_4001
    block_other_enb_cells_88_3
    set_testline_cell-33_status_onair
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    # Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    # ...                  counter_rule=${CURDIR}/counter_rule12299_D.txt
    detach_QC8450
    sleep    3s
    attach_QC8450
    Change AKNB to limitedBandwidth
    sleep    3s
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    sleep    3s
    8450_DLstart
    sleep    120s
    Change AKNB to nominalBandwidth
    sleep    180s
    8450_DLstop
    sleep    3s
    # Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    # sleep      3s
    unblock_all_6210_cells
    Change AKNB to nominalBandwidth

*** Keywords ***
Counter Operation
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${counter_rule}=${EMPTY}
    ...    ${interval}=5
    ...    ${timeout}=${None}
    ...    &{kwargs}
    [Documentation]     this keyword contain the classical BTS normal operation
    ...   Author: winnie he
    ...   Contact: winnie.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | yes | operation can support "start_collect_counter",
    ...                        "collect_counter", "collect_counter_and_check_rule", "compare"]  |
    ...   | product_type | yes | product type can support enb, gnb, vcu, vdu |
    ...   | bts_index | No | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |
    ...   | cudu_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |
    ...   | counter_rule | No | counter rule string list or text file path  |
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |
    ...   | kwargs | No | other parameters you want to pass to the kw |
    ${product_type}    Convert To Lower Case    ${product_type}
    ${value}    Run Keyword If    '${product_type}' in ["enb", "gnb", "vcu", "vdu"]
    ...    _counter_operation.interface    operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    counter_rule=${counter_rule}
    ...    interval=${interval}
    ...    timeout=${timeout}
    ...    &{kwargs}
    ...    ELSE
    ...    Fail    msg=Your product_type ${product_type} no support yet. Please contact the model owner.
    [Return]    ${value}
detach_QC8450
   AT Operation    detach    ue_index=0

attach_QC8450
   AT Operation    attach    ue_index=0

8450_DLstart
    AT Operation    start_traffic    ue_index=0    ueip=172.252.50.184    IperfOptions=-u -t 3600 -l 1400B -i 1 -b 200M -p 5504    direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
8450_DLstop
    AT Operation    stop_traffic  direction=dl
set_testline_cell-33_status_onair
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR    distname_id=NRCELL-33

Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

Change AKNB to nominalBandwidth
    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-6210/NRBTS-6210/NRCELL-1001
    @{value_list}     Create List    nominalBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Change AKNB to limitedBandwidth
    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-6210/NRBTS-6210/NRCELL-1001
    @{value_list}     Create List    limitedBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Start TTI trace for specific cell
    [Tags]    tti
    Log To Console    start to capture tti with DCAP
    ${dcap_argument}   Create Dictionary   nrCells=${TTI_cell}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop TTI trace for specific cell
    Log To Console    stopping tti with DCAP
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    Set Test Variable    ${tti_path}     ${local_file_path}
    Log To Console    \nTTI log: ${local_file_path}

Change CB009849_C_actDlForceRankDowng_to_dlVoNRCtrlOnly
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${19}  maxMcsForDlVoNRCtrl=${19}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVoNRCtrlOnly
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-21    MRBTS-37421/NRBTS-37421/NRCELL-21
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}


Analyze TTI log
    [Tags]    tti
    Log To Console    \nStart Log Analysis for ${tti_path}
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict}
    Log To Console    \nAnalyze TTI log: ${result}
    ${status}    check_rules     ${tti_path}    ${mcs_setting[0]}    ${mcs_setting[1]}    ${mcs_setting[2]}
    Log To Console    \nCheck rule log: ${status}
    should be true    ${status}

block_other_gnb_cells_1078_4001
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1078     need_verify=True
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-4001     need_verify=True
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1002     need_verify=True

block_other_enb_cells_88_3
    BTS Operation    operation=cell_block           product_type=enb    bts_index=0    distname_id=LNCELL-88     need_verify=True
    BTS Operation    operation=cell_block           product_type=enb    bts_index=0    distname_id=LNCELL-3     need_verify=True

unblock_all_6210_cells
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1078     need_verify=True
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-4001     need_verify=True
    BTS Operation    operation=cell_unblock           product_type=enb    bts_index=0    distname_id=LNCELL-88     need_verify=True
    BTS Operation    operation=cell_unblock           product_type=enb    bts_index=0    distname_id=LNCELL-3     need_verify=True
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1002     need_verify=True