*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009142

Resource    ./Resources/CNI129558_common_keyword.robot
Library     ./Resources/CNI129558_common_keyword.py
Variables   ./Resources/TLConfigration_CNI129558.py


Suite Setup       CNI129558 Suite setup
Suite Teardown    CNI129558 Suite Teardown


*** Test Cases ***
[1]CNI-129558-A_B1_06_Classic_SCell_pre-emptionintra-gNB_CA_FR1_TDD-FDD
    [Tags]  CRT_TRUNK
    [Setup]   CNI129558 Common Case Setup
    Lock UE to Dedicated Cell    lock_info=${A_B1_06_UE_lock_info}
    Modify Parameters with json    input_list=${CELL4_Para}    bts_host=${gNB_ip0}
    Block Two Station Cell    block_cell_id_list0=${gnb0_all_cell[2:3]}    block_cell_id_list1=${gnb1_all_cell}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info1}    value_list=${A_B1_06_PA_value1}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info2}    value_list=${A_B1_06_PA_value2}
    Adjust PA And Check Aasyslog    UE_call_info=${A_B1_06_ue_info3}    PA_value_list=${A_B1_06_PA_value2}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${gnb0_all_cell[2:3]}    unblock_cell_id_list1=${gnb1_all_cell}
     ...    gnb0_para_list=${CELL4_Para_recover}

[1]CNI-129558-A_B2_05_Classic_intra-gNB_CA_downgrade_SCell_pre-emption_intra-gNB_CA_FR1_FDD-TDD
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    Lock UE to Dedicated Cell    lock_info=${A_B2_05_UE_lock_info}
    Modify Parameters with json    input_list=${CELL3_Para}    bts_host=${gNB_ip0}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info1}    value_list=${A_B2_05_PA_value1}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info2}    value_list=${A_B2_05_PA_value2}
    Adjust PA And Check Aasyslog    UE_call_info=${A_B1_06_ue_info3}    PA_value_list=${A_B2_05_PA_value2}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${empty_list}    unblock_cell_id_list1=${empty_list}
    ...    gnb0_para_list=${CELL3_Para_recover}

[1]CNI-129558-A_B3_05_Classic_intra-gNB_SCell_context_pre-emption_during_intra-gNB_handover
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    Lock UE to Dedicated Cell    lock_info=${A_B3_05_UE_lock_info}
    Modify Parameters with json    input_list=${A_B3_05_para}    bts_host=${gNB_ip0}
    Adjust PA And UE Attach    UE_call_info=${A_B3_05_ue_info1}    value_list=${A_B3_05_PA_value1}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info3}    value_list=${A_B3_05_PA_value2}
    Adjust PA And Check Aasyslog    UE_call_info=${empty_ue_info}    PA_value_list=${A_B3_05_PA_value3}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${empty_list}    unblock_cell_id_list1=${empty_list}
    ...    gnb0_para_list=${A_B3_05_para_recover}

[1]CNI-129558-A_B4_02_Classic_intra-gNB_CA_downgrade_SCell_pre-emption_during_inter-gNB_NG_handover
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    Lock UE to Dedicated Cell    lock_info=${A_B4_02_UE_lock_info}
    Block Two Station Cell    block_cell_id_list0=${empty_list}    block_cell_id_list1=${gnb1_all_cell[1:2]}
    Modify Parameters with json    input_list=${A_B4_02_para}    bts_host=${gNB_ip0}
    Modify Parameters with json    input_list=${A_B4_02_para1}    bts_host=${gNB_ip1}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info1}    value_list=${A_B4_02_PA_value1}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info2}    value_list=${A_B4_02_PA_value2}
    Adjust PA And UE Attach    UE_call_info=${A_B1_06_ue_info3}    value_list=${A_B4_02_PA_value3}
    Adjust PA And Check Aasyslog    UE_call_info=${empty_ue_info}    PA_value_list=${A_B4_02_PA_value4}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${empty_list}    unblock_cell_id_list1=${gnb1_all_cell[1:2]}
    ...    gnb0_para_list=${A_B4_02_para_recover}    gnb1_para_list=${A_B4_02_para1_recover}

[1]CNI-129558-B_B2_03_Classic_inter-gNB_CA_downgrade_SCell_context_pre-emption_during_RRC_Connection_Resume
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    Modify Parameters with json    input_list=${CELL1_Para}    bts_host=${gNB_ip0}
    Modify Parameters with json    input_list=${B_B2_03_para1}    bts_host=${gNB_ip1}
    Adjust PA And UE Attach    UE_call_info=${B_B2_03_ue_info1}    value_list=${B_B2_03_PA_value1}    prepare_ue=${True}
    Adjust PA And Check Aasyslog    UE_call_info=${A_B1_06_ue_info3}    PA_value_list=${B_B2_03_PA_value2}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${empty_list}    unblock_cell_id_list1=${empty_list}
    ...    gnb0_para_list=${CELL1_Para_recover}    gnb1_para_list=${B_B2_03_para1_recover}

[1]CNI-129558-B_B3_05_Classic_inter-gNB_SCell_context_pre-emption_during_intra-gNB_handover
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    @{gnb0_expect}    Create List     ${0}     ${0}    ${1}
    @{gnb1_expect}    Create List     ${1}     ${1}    ${0}
    ${Before_gnb1_value}    ${before_gnb1_last_time}    get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...    counter_name_list=@{counter_object_name}    NRCELL_ID=NRCELL-2    MRBTS_ID=${TL1_BTS_ID}    NRBTS_ID=${TL1_NRBTS_ID}
    ...    if_before=${True}
    ${Before_gnb0_value}    ${before_gnb0_last_time}    get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...    counter_name_list=${counter_object_name}    NRCELL_ID=NRCELL-1    bts_host=${gNB_ip0}    MRBTS_ID=${TL0_BTS_ID}
    ...    NRBTS_ID=${TL0_NRBTS_ID}
    ...    if_before=${True}
    Lock UE to Dedicated Cell    lock_info=${B_B3_05_UE_lock_info}
    Block Two Station Cell    block_cell_id_list0=${gnb1_all_cell[-1:-2]}    block_cell_id_list1=${gnb1_all_cell[1:]}
    Block or UnBlock Mulite Cell    cell_id_list=${gnb0_all_cell[0:1]}    BTS_ID=${TL0_ENB_ID}    NRBTS_ID=${TL0_LNBTS_ID}
    ...    bts_host=${gnb_ip0}
    ...    cell_type=lte
    Modify Parameters with json    input_list=${B_B3_05_para}    bts_host=${gNB_ip0}
    Modify Parameters with json    input_list=${B_B2_03_para1}    bts_host=${gNB_ip1}
    Adjust PA And UE Attach    UE_call_info=${B_B2_03_ue_info1}    value_list=${B_B2_03_PA_value1}    prepare_ue=${True}
    Adjust PA And UE Attach    UE_call_info=${B_B3_05_ue_info2}    value_list=${B_B3_05_PA_value2}
    Adjust PA And Check Aasyslog    UE_call_info=${empty_ue_info}    PA_value_list=${B_B3_05_PA_value3}
    log to console    sleep 6 mins
    Sleep    6min
    ${After_gnb1_value}     get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...     counter_name_list=${counter_object_name}    NRCELL_ID=NRCELL-2    MRBTS_ID=${TL1_BTS_ID}    NRBTS_ID=${TL1_NRBTS_ID}
    ...     if_before=${False}    before_timestamp_list=${before_gnb1_last_time}
    ${After_gnb0_value}     get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...     counter_name_list=${counter_object_name}    NRCELL_ID=NRCELL-1    bts_host=${gNB_ip0}
    ...     MRBTS_ID=${TL0_BTS_ID}    NRBTS_ID=${TL0_NRBTS_ID}
    ...     if_before=${False}    before_timestamp_list=${before_gnb0_last_time}
    check counter value    before_value=${Before_gnb1_value}    after_value=${After_gnb1_value[0]}    expected_value=${gnb1_expect}
    check counter value    before_value=${Before_gnb0_value}    after_value=${After_gnb0_value[0]}    expected_value=${gnb0_expect}
    Block or UnBlock Mulite Cell    cell_id_list=${gnb0_all_cell[0:1]}    BTS_ID=${TL0_ENB_ID}    NRBTS_ID=${TL0_LNBTS_ID}
    ...    bts_host=${gnb_ip0}
    ...    cell_type=lte    block_flag=${False}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${gnb1_all_cell[-1:-2]}    unblock_cell_id_list1=${gnb1_all_cell[1:]}
    ...    gnb0_para_list=${B_B3_05_para_recover}    gnb1_para_list=${B_B2_03_para1_recover}

[1]CNI-129558-B_B4_03_Classic_inter-gNB_CA_downgrade_SCell_pre-emption_during_inter-gNB_NG_handover
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    Modify Parameters with json    input_list=${B_B4_03_para}    bts_host=${gNB_ip0}
    Modify Parameters with json    input_list=${B_B4_03_para1}    bts_host=${gNB_ip1}
    Adjust PA And UE Attach    UE_call_info=${B_B2_03_ue_info1}    value_list=${B_B2_03_PA_value1}    prepare_ue=${True}
    Adjust PA And UE Attach    UE_call_info=${B_B3_05_ue_info2}    value_list=${B_B3_05_PA_value2}
    Adjust PA And Check Aasyslog    UE_call_info=${empty_ue_info}    PA_value_list=${B_B3_05_PA_value3}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${empty_list}   unblock_cell_id_list1=${empty_list}
    ...    gnb0_para_list=${B_B4_03_para_recover}    gnb1_para_list=${B_B4_03_para1_recover}


[1]CNI-129558-B_IWK1_03_B3_Classic_inter-gNB_SCell_context_pre-emption_release_counter_resources_incoming_handover
    [Tags]  CRT_TRUNK
    [Setup]  CNI129558 Common Case Setup
    @{gnb0_expect}    Create List     ${0}     ${0}    ${1}
    @{gnb1_expect}    Create List     ${1}     ${1}    ${0}
    ${Before_gnb1_value}    ${before_gnb1_last_time}    get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...    counter_name_list=@{counter_object_name}    NRCELL_ID=NRCELL-2    MRBTS_ID=${TL1_BTS_ID}    NRBTS_ID=${TL1_NRBTS_ID}
    ...    if_before=${True}
    ${Before_gnb0_value}    ${before_gnb0_last_time}    get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...    counter_name_list=${counter_object_name}    NRCELL_ID=NRCELL-1    bts_host=${gNB_ip0}    MRBTS_ID=${TL0_BTS_ID}
    ...    NRBTS_ID=${TL0_NRBTS_ID}
    ...    if_before=${True}
    Lock UE to Dedicated Cell    lock_info=${B_IWK1_03_UE_lock_info}
    Block Two Station Cell    block_cell_id_list0=${gnb1_all_cell[-1:-2]}    block_cell_id_list1=${gnb1_all_cell[1:]}
    Block or UnBlock Mulite Cell    cell_id_list=${gnb0_all_cell[0:1]}    BTS_ID=${TL0_ENB_ID}    NRBTS_ID=${TL0_LNBTS_ID}
    ...    bts_host=${gnb_ip0}
    ...    cell_type=lte
    Modify Parameters with json    input_list=${B_IKW1_03_para}    bts_host=${gNB_ip0}
    Modify Parameters with json    input_list=${B_B2_03_para1}    bts_host=${gNB_ip1}
    Adjust PA And UE Attach    UE_call_info=${B_B2_03_ue_info1}    value_list=${B_B2_03_PA_value1}    prepare_ue=${True}
    Adjust PA And UE Attach    UE_call_info=${B_B3_05_ue_info2}    value_list=${B_B3_05_PA_value2}
    Adjust PA And Check Aasyslog    UE_call_info=${empty_ue_info}    PA_value_list=${B_B3_05_PA_value3}
    log to console    sleep 6 mins
    Sleep    6min
    ${After_gnb1_value}     get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...     counter_name_list=${counter_object_name}    NRCELL_ID=NRCELL-2    MRBTS_ID=${TL1_BTS_ID}    NRBTS_ID=${TL1_NRBTS_ID}
    ...     if_before=${False}    before_timestamp_list=${before_gnb1_last_time}
    ${After_gnb0_value}     get_bts_counters    counter_ids=M55118C00106,M55118C00107,M55167C00190
    ...     counter_name_list=${counter_object_name}    NRCELL_ID=NRCELL-1    bts_host=${gNB_ip0}
    ...     MRBTS_ID=${TL0_BTS_ID}    NRBTS_ID=${TL0_NRBTS_ID}
    ...     if_before=${False}    before_timestamp_list=${before_gnb0_last_time}
    check counter value    before_value=${Before_gnb1_value}    after_value=${After_gnb1_value[0]}    expected_value=${gnb1_expect}
    check counter value    before_value=${Before_gnb0_value}    after_value=${After_gnb0_value[0]}    expected_value=${gnb0_expect}
    Block or UnBlock Mulite Cell    cell_id_list=${gnb0_all_cell[0:1]}    BTS_ID=${TL0_ENB_ID}    NRBTS_ID=${TL0_LNBTS_ID}
    ...    bts_host=${gnb_ip0}
    ...    cell_type=lte    block_flag=${False}
    [Teardown]    CNI129558 Common Case Teardown    unblock_cell_id_list0=${empty_list}    unblock_cell_id_list1=${gnb1_all_cell[1:]}
    ...    gnb0_para_list=${B_IKW1_03_para_recover}    gnb1_para_list=${B_B2_03_para1_recover}
