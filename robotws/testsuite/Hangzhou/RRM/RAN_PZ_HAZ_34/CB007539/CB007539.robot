# # @Time    : 2022/6/1 14:13
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB007539.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB007539_5G_B_CB007723_B_C
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Force Tags    CRT_TRUNK    CRT_22R4    PY36
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup     Run keywords     robot_common_operations.Common Suite Setup   AND    CI_interface.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       Run keywords     robot_common_operations.Common Case Setup   AND    Connect to gnb coam via ssl
# Test Teardown    Run Keyword And Ignore Error    Run keywords    robot_common_operations.Common Case Teardown
# ...             AND     COAM Teardown gnb connections
# 
# 
# 
# *** Variables ***
# ${if_commissioning}            True
# ${GLOBAL_CELL_ID}    10
# @{CASE105_LOCK_CELLS}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-14
# ...                     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-15
# ...                     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-16
# ...                     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-17
# &{PRACH_121_THOUGHPUT_INFO}     prach_configuration_index=121
# ...                             6Symbols_ul_tp_threshold=97
# ...                             6Symbols_dl_tp_threshold=456
# ...                             2Symbols_ul_tp_threshold=96
# ...                             2Symbols_dl_tp_threshold=511
# &{PRACH_135_THOUGHPUT_INFO}     prach_configuration_index=135
# ...                             6Symbols_ul_tp_threshold=61
# ...                             6Symbols_dl_tp_threshold=454
# ...                             2Symbols_ul_tp_threshold=62
# ...                             2Symbols_dl_tp_threshold=508
# @{CASE105_PRACH_THOUGHPUT_INFO}    &{PRACH_121_THOUGHPUT_INFO}    &{PRACH_135_THOUGHPUT_INFO}
# &{PRACH_114_THOUGHPUT_INFO}    prach_configuration_index=114    ul_tp_threshold=116    dl_tp_threshold=408
# &{PRACH_128_THOUGHPUT_INFO}    prach_configuration_index=128    ul_tp_threshold=89    dl_tp_threshold=408
# @{CASE108_PRACH_THOUGHPUT_INFO}    &{PRACH_114_THOUGHPUT_INFO}    &{PRACH_128_THOUGHPUT_INFO}
# &{DEFAULT_TDD_FRAME_STRUCTURE}      frameStructureType=semiStatic
# ...                                 guardPeriodLength=6Symbols
# ...                                 tdLteUlDlConfig=tdLteConfig2
# ...                                 ulDlDataSlotRatio=1/4
# @{TDD_FRAME_STRUCTURE_VALUE}    &{DEFAULT_TDD_FRAME_STRUCTURE}
# &{PARAMETERS1_DICT}      parameterName=tddFrameStructure
# ...                     value=@{TDD_FRAME_STRUCTURE_VALUE}
# ...                     operation=update
# &{PARAMETERS2_DICT}      parameterName=prachConfigurationIndex
# ...                     value=114
# ...                     operation=update
# &{PARAMETERS3_DICT}      parameterName=rangeExtension
# ...                     value=0-6.9km
# ...                     operation=update
# &{PARAMETERS4_DICT}      parameterName=totalNumberOfRAPreambles
# ...                     value=32
# ...                     operation=update
# &{PARAMETERS5_DICT}      parameterName=cbraPreamblesPerSsb
# ...                     value=n32
# ...                     operation=update
# &{PARAMETERS6_DICT}      parameterName=zeroCorrelationZoneConfig
# ...                     value=0
# ...                     operation=update
# @{CASE105_PARAMETERS_LIST}  ${PARAMETERS1_DICT}    ${PARAMETERS2_DICT}
# @{CASE108_PARAMETERS_LIST}  ${PARAMETERS1_DICT}    ${PARAMETERS2_DICT}    ${PARAMETERS3_DICT}    ${PARAMETERS4_DICT}
# ...                         ${PARAMETERS5_DICT}    ${PARAMETERS6_DICT}
# &{CASE105_DELTA_JSON}   distName=${EMPTY}
# ...                     operation=update
# ...                     parameters=${CASE105_PARAMETERS_LIST}
# &{CASE108_DELTA_JSON}   distName=${EMPTY}
# ...                     operation=update
# ...                     parameters=${CASE108_PARAMETERS_LIST}
# ${SSB_POSITION_IN_BRUST_FOR_6_SYMBOLS}    ff0000ffff0000ff
# ${SSB_POSITION_IN_BRUST_FOR_2_SYMBOLS}    0f0f0f0f0f0f0f0f
# @{CSI_RS_TRANCKING_SLOT_OFFSET_FOR_6_SYMBOLS}    87    97    107    117    127    137    147    157
# @{CSI_RS_TRANCKING_SLOT_OFFSET_FOR_2_SYMBOLS}    88    98    108    118    128    138    148    158
# 
# *** Test Cases ***
# CB007539-5G-B_108_CB007723-C-0103-8CC-Cells_configurations_with_extended_range_and_10GP_symbols
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    case108
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#     ...    parameter=caConfigurationSupport    value=none
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#     ...    parameter=actCarrierAggregation    value=false
#     FOR    ${info}    IN    @{CASE108_PRACH_THOUGHPUT_INFO}
#         All cells configurations as extend range    prach_configuration_index=${info['prach_configuration_index']}
#         ...    case_delta_json=${CASE108_DELTA_JSON}    guardPeriodLength=10Symbols
#         UE attach NSA cell and check UE log    ul_tp_threshold=${info['ul_tp_threshold']}
#         ...    dl_tp_threshold=${info['dl_tp_threshold']}
#         ...    ssbPositionInBurst=${SSB_POSITION_IN_BRUST_FOR_6_SYMBOLS}
#         ...    csiRsTranckingSlotOffset=${CSI_RS_TRANCKING_SLOT_OFFSET_FOR_6_SYMBOLS}
#         coam.lock    dist_name=${EMPTY}    technology=NR    connection=GNB_OAM    timeout=60
#         Wait Until Keyword Succeeds    2min    10s    Verify BTS 5G Cells Status Is Cell Lock State
#         coam.unlock    dist_name=${EMPTY}    technology=NR    connection=GNB_OAM    timeout=60
#         Wait Until Keyword Succeeds    5min    10s    Verify BTS Status Is "OnAir"
#         UE attach NSA cell and check UE log        ul_tp_threshold=${info['ul_tp_threshold']}
#         ...    dl_tp_threshold=${info['dl_tp_threshold']}
#         ...    ssbPositionInBurst=${SSB_POSITION_IN_BRUST_FOR_6_SYMBOLS}
#         ...    csiRsTranckingSlotOffset=${CSI_RS_TRANCKING_SLOT_OFFSET_FOR_6_SYMBOLS}
#     END
#     [Teardown]    COAM Teardown gnb connections
# 
# CB007539-5G-B_105_CB007723-B-0106-PRACH_format_B4_4cc_changeGP_From6To2
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    case105
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#     ...    parameter=caConfigurationSupport    value=none
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#     ...    parameter=actCarrierAggregation    value=false
#     coam.lock    dist_name=${CASE105_LOCK_CELLS}    connection=GNB_OAM    timeout=60
#     FOR    ${info}    IN    @{CASE105_PRACH_THOUGHPUT_INFO}
#         All cells configurations as extend range    prach_configuration_index=${info['prach_configuration_index']}
#         ...    case_delta_json=${CASE105_DELTA_JSON}    guardPeriodLength=6Symbols
#         UE attach NSA cell and check UE log    ul_tp_threshold=${info['6Symbols_ul_tp_threshold']}
#         ...    dl_tp_threshold=${info['6Symbols_dl_tp_threshold']}
#         ...    ssbPositionInBurst=${SSB_POSITION_IN_BRUST_FOR_6_SYMBOLS}
#         ...    csiRsTranckingSlotOffset=${CSI_RS_TRANCKING_SLOT_OFFSET_FOR_6_SYMBOLS}
#         All cells configurations as extend range    prach_configuration_index=${info['prach_configuration_index']}
#         ...    case_delta_json=${CASE105_DELTA_JSON}    guardPeriodLength=2Symbols
#         UE attach NSA cell and check UE log    ul_tp_threshold=${info['2Symbols_ul_tp_threshold']}
#         ...    dl_tp_threshold=${info['2Symbols_dl_tp_threshold']}
#         ...    ssbPositionInBurst=${SSB_POSITION_IN_BRUST_FOR_2_SYMBOLS}
#         ...    csiRsTranckingSlotOffset=${CSI_RS_TRANCKING_SLOT_OFFSET_FOR_2_SYMBOLS}
#     END
#     [Teardown]    COAM Teardown gnb connections
# 
# *** Keywords ***
# All cells configurations as extend range
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${prach_configuration_index}    ${case_delta_json}    ${guardPeriodLength}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl
#     ${cells_info}    coam.get_cells_info    connection=${connection}
#     ${delta_json}    Create List
#     :FOR    ${cell}    IN     @{cells_info}
#     \    ${delta_dict}    Set Variable    ${case_delta_json}
#     \    Set To Dictionary    ${delta_dict}    distName=${cell['id']['configuration']}
#     \    Set To Dictionary    ${delta_dict['parameters'][0]['value'][0]}    guardPeriodLength=${guardPeriodLength}
#     \    Set To Dictionary    ${delta_dict['parameters'][1]}    value=${prach_configuration_index}
#     \    ${copy_delta_dict}    Copy Dictionary    ${delta_dict}
#     \    Append To List    ${delta_json}    ${copy_delta_dict}
#     ${delta_file}    Convert To String    ${delta_json}
#     ${delta_file}    Replace String    ${delta_file}    '    "
#     coam.perform_delta_recommissioning    delta_file=${delta_file}
#     ...    skip_parameter_relation_errors=True    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    10s    Verify BTS Status Is "OnAir"
# 
# UE attach NSA cell and check UE log
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${ul_tp_threshold}    ${dl_tp_threshold}    ${ssbPositionInBurst}    ${csiRsTranckingSlotOffset}
#     ...    ${ul_tp}=200M    ${dl_tp}=600M
#     Start To Capture Wireshark Log From ENB
#     ${local_pcap_path}    Set Variable    ${TS_CASE_LOG_PATH}/case108.pcap
#     Connect to gnb coam via ssl
#     UE Attach And Check Throughput With Detach    global_cell_id=${GLOBAL_CELL_ID}
#     ...    ul_tp=${ul_tp}   ul_tp_threshold=${ul_tp_threshold}
#     ...    dl_tp=${dl_tp}   dl_tp_threshold=${dl_tp_threshold}    attach_mode=NSA
#     Stop To Capture Wireshark Log From ENB    local_pcap_path=${local_pcap_path}
#     cap.load_pcap_file    pcap_file=${local_pcap_path}    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
#     ...    tshark_path=${TSHARK_PATH}    alias=asdasd
#     ${ssb-PositionsInBursts}    cap.get_field_value_by_xpath    pcap_parser=asdasd
#     ...    xpath=.//nr-rrc.ssb_PositionsInBurst/nr-rrc.longBitmap    attribute_name=value
#     Should Contain    ${ssb-PositionsInBursts}    ${ssbPositionInBurst}
#     ${csi-MeasConfig}    cap.get_field_value_by_xpath    pcap_parser=asdasd
#     ...    xpath=.//nr-rrc.slots640    attribute_name=show
#     :FOR    ${i}     IN    @{csiRsTranckingSlotOffset}
#     \    Should Contain    ${csi-MeasConfig}    ${i}
