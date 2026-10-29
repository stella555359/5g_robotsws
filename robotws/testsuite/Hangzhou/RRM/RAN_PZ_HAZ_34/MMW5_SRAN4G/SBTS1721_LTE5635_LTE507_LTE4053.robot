# # # @Time    : 2022/5/31 10:00
# # # @Author  : Zheng Yihua
# # # @Email   : yihua.h.zheng@nokia-sbell.com
# # # @File    : SBTS1721_LTE5635_LTE507_LTE4053.robot
# # # @Software: PyCharm
# # # @Doc     : Some Description
# # *** Settings ***
# # Documentation
# # ...    author: Zheng Yihua
# # ...    contact: yihua.h.zheng@nokia-sbell.com, xudong.1.li@nokia-sbell.com
# # ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# # ...    Feature SBTS1721 LTE5635 LTE507 LTE4053
# # 
# # 
# # Resource    LTE_common_keywords.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# # 
# # Suite Setup          robot_common_operations.Common Suite Setup
# # Suite Teardown       robot_common_operations.Common Suite Teardown
# # Test Setup           Run Keywords    robot_common_operations.Common Case Setup 
# # ...    AND     Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${ENB_HOST}
# # Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# # ...    AND     Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM
# # 
# # 
# # 
# # Force Tags        CRT_TRUNK    CRT_22R3    CRT_22R4
# # 
# # *** Variables ***
# # ${scf_dir}         ${CURDIR}/scf
# # ${scf_name}         LTE5077_LTE5625_LTE4053.xml
# # ${MRBTS_ID}    ${tl.enbs[0].instance_id}
# # ${LNBTS_ID}    ${tl.enbs[0].global_bts_id}
# # ${ENB_HOST}=    ${tl.enbs[0].oam_ip.v4}
# # ${couter_path262}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/CMCC-262_CMNC-03/LTE_RAN_Sharing
# # ${couter_path460}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/CMCC-460_CMNC-02/LTE_RAN_Sharing
# # ${couter_path_M8011C276}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Resource
# # ${syslog_LTE4053_TC01}          syslog_LTE4053_TC01.log
# # ${local_LTE4053_TC01_syslog_path}      /home/ute/log/syslog_LTE4053_TC01.log
# # ${match_syslog_Lte4053}    sCellIdSelectedForUlCa: 440578
# # 
# # 
# # *** Test Cases ***
# # [2.0] LTE5625_TC01_nonGBR_related counters_for_2CC
# #     [Tags]    LTE5625_TC01
# #     [Documentation]    LTE5625_TC01_nonGBR_related_counters_for_2CC
# # #    qualcomm_common_keywords.Reserve ue for tests
# # #    qualcomm_common_keywords.Ue attach
# # #    Modify Attenuation
# #     Scf Uploading And Commissioning For Enb    Log_directory=${scf_dir}    SCF_Filename=${scf_name}
# #     Step1: Ue Attached UE2
# #     Step2: Start DL UDP-traffic UE2
# #     Step3: LTE5635 TC01 Check PM counter
# # 
# # [2.0] LTE5625_TC07_nonGBR_related counters_for_without CA
# #     [Tags]    LTE5625_TC02
# #     [Documentation]    [1]LTE5625_TC07_nonGBR_related counters_for_without CA
# #     Step1: Ue Attached UE3
# #     Step2: Start DL UDP-traffic UE3
# #     Step3: LTE5635 TC07 Check PM counter
# #     Check LTE5635 TC07 Counter
# # 
# # [2.0] LTE5077-B_TC12_IP_Throughput_Counter_for_ QCI9 per PLMN-ID
# #     [Tags]    LTE5077-B
# #     [Documentation]    [1]LTE5077-B_TC12_IP_Throughput_Counter_for_ QCI9 per PLMN-ID
# #     Step1: Ue Attached UE1 and UE2
# #     Log    Start UDP-traffic   console=yes
# #     UE Start DL Traffic   throughput=400M    ue_index=0    dl_time=120    dl_port=45001
# #     UE Start DL Traffic   throughput=400M    ue_index=1    dl_time=120    dl_port=45001
# #     Sleep    120s
# #     Step2: LTE5077 TC12 Check PM counter
# # 
# # [2.0] LTE4053_TC01 PCell uplink pathloss check prior to adding DL+UL SCell for One-step&Step-wise Scell Addition&Upgrade
# #     [Tags]    LTE4053_TC01   CDRT_TRUNK
# #     [Documentation]
# #     ...  [1][1.0] LTE4053_TC01 PCell uplink pathloss check prior
# #     ...  to adding DL+UL SCell for One-step&Step-wise Scell Addition&Upgrade
# #     ...  [1][1.0] LTE4053_TC02 PCell uplink pathloss check prior
# #     ...  to adding DL+UL SCell during CA Steering Handover&Reestablishment
# #     Change prameter Lte4053 TC01
# #     sleep    30
# # 	Set PA Recover
# #     #Step1: Ue Attached UE3
# #     Reset UE    ue_index=2
# #     Log    \nStart UL Traffic and change attenuator\n    console=yes
# #     UE Start UL Traffic   throughput=50M    ue_index=2    ul_time=120    ul_port=45001
# #     sleep    10
# #     Set PA LTE4053
# #     sleep    120
# #     Step2: LTE4053 TC02 Check PM counter
# #     Recover the test ENV LTE4053
# # 
# # [2.0] LTE4053_TC02 PCell uplink pathloss check prior to adding DL+UL SCell during CA Steering Handover&Reestablishment
# #     [Tags]    LTE4053_TC02    CDRT_TRUNK
# #     [Documentation]
# #     ...  [1][1.0] LTE4053_TC01 PCell uplink pathloss check prior
# #     ...  to adding DL+UL SCell for One-step&Step-wise Scell Addition&Upgrade
# #     ...  [1][1.0] LTE4053_TC02 PCell uplink pathloss check prior
# #     ...  to adding DL+UL SCell during CA Steering Handover&Reestablishment
# #     Change prameter Lte4053 TC01
# #     sleep    30
# # 	Set PA Recover
# #     #Step1: Ue Attached UE3
# #     Reset UE    ue_index=2
# #     Log    \nStart UL Traffic and change attenuator\n    console=yes
# #     UE Start UL Traffic   throughput=50M    ue_index=2    ul_time=120    ul_port=45001
# #     sleep    10
# #     Set PA LTE4053
# #     sleep    120
# #     Step2: LTE4053 TC02 Check PM counter
# #     Recover the test ENV LTE4053
# # 
# # *** Keywords ***
# # get PM counter latest value
# #     [Documentation]    get PM counter latest value
# #     [Arguments]    ${counter_id}    ${couter_path}    ${connection}
# #     BuiltIn.Log    \n get PM counter latest value \n    console=yes
# #     ${pm_list}    get_pm_counter_values    counter_id=${counter_id}
# #     ...    dic_path=${couter_path}
# #     ...    connection=${connection}
# #     BuiltIn.Log    \n pm_list is ${pm_list} \n    console=yes
# #     ${countervalue}    Set Variable    ${pm_list[0]}
# # #    BuiltIn.set_test_variable    ${countervalue}
# #     BuiltIn.Log    \n pm_value is ${countervalue} \n    console=yes
# #     [Return]    ${countervalue}
# # 
# # mod attenuation with attenuator
# #     [Documentation]    use __init__.py setup an attenuator then modify PA
# #     [Arguments]    ${channels_to_modify}
# #     BuiltIn.Log    \n mod attenuation with attenuator \n    console=yes
# #     attenuator.setup_attenuator
# #     ...    ip_addr=${tl.attenuator.ip_addr}
# #     ...    port=${tl.attenuator.port}
# #     ...    attenuation_port_numbers=${tl.attenuator.attenuation_port_numbers}
# #     ...    vendor=${tl.attenuator.vendor}
# #     gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}
# # 
# # Reset UE
# #     [Arguments]     ${ue_index}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #     ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #     Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
# #     csn.send_command     command=adb -s ${serial_number} reboot     connection=cygwin
# #     sleep     60s
# #     csn.disconnect     connection=cygwin
# # 
# # LTE4053 Start UL Traffic and change attenuator
# #     Log    Start UL Traffic and change attenuator once   console=yes
# #     UE Start UL Traffic   throughput=50M    ue_index=2    ul_time=30    ul_port=45001
# #     sleep    10
# #     Set PA LTE4053
# #     sleep    25
# #     Set PA Recover
# #     Log    Start UL Traffic and change attenuator twice   console=yes
# #     UE Start UL Traffic   throughput=50M    ue_index=2    ul_time=30    ul_port=45001
# #     sleep    10
# #     Set PA LTE4053
# #     sleep    25
# #     Set PA Recover
# #     Log    Start UL Traffic and change attenuator Third   console=yes
# #     UE Start UL Traffic   throughput=50M    ue_index=2    ul_time=30    ul_port=45001
# #     sleep    10
# #     Set PA LTE4053
# #     sleep    25
# #     Set PA Recover
# # 
# # 
# # Change prameter Lte4053 TC01
# #     Log    \nModify Parameter On BTS\n   console=yes
# #     Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-2
# # 	...    parameter=administrativeState
# # 	...    value=unlocked
# # 	...    connection=GNB_OAM
# # 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}
# # 	...    parameter=actAdvUlScellHandling
# # 	...    value=true
# # 	...    connection=GNB_OAM
# # 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/CAGENB-0
# # 	...    parameter=pcellUlPathlossThresh
# # 	...    value=100
# # 	...    connection=GNB_OAM
# # 
# # 
# # Recover the test ENV LTE4053
# #     Set PA Recover
# #     Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-2
# # 	...    parameter=administrativeState
# # 	...    value=locked
# # 	...    connection=GNB_OAM
# # 
# # 
# # Set PA Recover
# #     BuiltIn.Log    \n Step2: Set PA and check SBTS status \n    console=yes
# #     &{channels_to_modify}    create dictionary
# #     ...    1=0    2=0    3=0    4=0    5=0    6=0    7=0    8=0
# #     ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
# #    Mod Attenuation With Attenuator    channels_to_modify=${channels_to_modify}
# # 
# # Set PA LTE4053
# #     BuiltIn.Log    \n Step2: Set PA and check SBTS status \n    console=yes
# #     &{channels_to_modify}    create dictionary
# #     ...    1=0    2=45    3=0    4=45    5=0    6=45    7=0    8=45
# #     ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
# #    Mod Attenuation With Attenuator    channels_to_modify=${channels_to_modify}
# # 
# # 
# # 
# # Step1: Ue Attached UE1
# # #ue a972cb38
# #     BuiltIn.Log    \n Step1: Ue attached UE1 \n    console=yes
# #     UE Attach And Verify 4G    ue_index=0
# # 
# # Step1: Ue Attached UE2
# # #bc7cd605
# #     BuiltIn.Log    \n Step1: Ue attached UE2 \n    console=yes
# #     UE Attach And Verify 4G    ue_index=1
# # 
# # Step1: Ue Attached UE3
# # #11341f98
# #     BuiltIn.Log    \n Step1: Ue attached UE3 \n    console=yes
# #     UE Attach And Verify 4G    ue_index=2
# # 
# # Step1: Ue Attached UE1 and UE2
# #     BuiltIn.Log    \n Step1: Ue attached UE1 AND UE2 \n    console=yes
# #     UE Attach And Verify 4G    ue_index=0
# #     UE Attach And Verify 4G    ue_index=1
# # 
# # Step2: Start DL UDP-traffic UE2
# #     BuiltIn.Log    \n Step2: Start UDP-traffic UE2 \n    console=yes
# #     UE Start DL Traffic   throughput=300M    ue_index=1    dl_time=20    dl_port=45001
# #     Sleep    25s
# #     UE Start DL Traffic   throughput=300M    ue_index=1    dl_time=20    dl_port=45001
# #     Sleep    25s
# #     UE Start DL Traffic   throughput=300M    ue_index=1    dl_time=10    dl_port=45001
# #     Sleep    35s
# # 
# # Step2: Start DL UDP-traffic UE3
# #     BuiltIn.Log    \n Step2: Start UDP-traffic UE3 \n    console=yes
# #     UE Start DL Traffic   throughput=300M    ue_index=2    dl_time=30    dl_port=45001
# #     Sleep    35s
# #     UE Start DL Traffic   throughput=300M    ue_index=2    dl_time=20    dl_port=45001
# #     Sleep    25s
# #     UE Start DL Traffic   throughput=300M    ue_index=2    dl_time=10    dl_port=45001
# #     Sleep    15s
# # 
# # Step3: LTE5635 TC01 Check PM counter
# #     Get LTE5635 TC01 PM Counter
# #     Run keyword if    ${countervalue188} == 0 or ${countervalue264} == 0    Get LTE5635 TC01 PM Counter Again
# #     Check LTE5635 TC01 Counter
# # 
# # Get LTE5635 TC01 PM Counter
# #     [Arguments]    ${couter_path}=BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Throughput
# #     BuiltIn.Log    \n Get PM counter \n    console=yes
# #     ${countervalue188}    get PM counter latest value    counter_id=M8012C188
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue188}
# #     ${countervalue192}    get PM counter latest value    counter_id=M8012C192
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue192}
# #     ${countervalue264}    get PM counter latest value    counter_id=M8012C264
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue264}
# #     ${countervalue268}    get PM counter latest value    counter_id=M8012C268
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue268}
# # 
# # 
# # Get LTE5635 TC01 PM Counter Again
# #     Sleep    300s
# #     Get LTE5635 TC01 PM Counter
# # 
# # Check LTE5635 TC01 Counter
# #     BuiltIn.Log    \n Check PM counter \n    console=yes
# #     Should be True      ${countervalue188} > 0
# #     Should be True      ${countervalue192} > 0
# #     Should be True      ${countervalue264} > 0
# #     Should be True      ${countervalue268} > 0
# # 	${countervalueresult}    Evaluate    ${countervalue188}/(${countervalue192}*0.001)
# # 	Should be True       ${countervalueresult} > 250
# # 
# # Step3: LTE5635 TC07 Check PM counter
# #     Get LTE5635 TC07 PM Counter
# #     Run keyword if    ${countervalue187} == 0 or ${countervalue263} == 0    Get LTE5635 TC07 PM Counter Again
# #     Check LTE5635 TC07 Counter
# # 
# # Get LTE5635 TC07 PM Counter
# #     [Arguments]    ${couter_path}=BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Throughput
# #     BuiltIn.Log    \n Get PM counter \n    console=yes
# #     ${countervalue187}    get PM counter latest value    counter_id=M8012C187
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue187}
# #     ${countervalue191}    get PM counter latest value    counter_id=M8012C191
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue191}
# #     ${countervalue263}    get PM counter latest value    counter_id=M8012C263
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue263}
# #     ${countervalue267}    get PM counter latest value    counter_id=M8012C267
# #     ...    couter_path=${couter_path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue267}
# # 
# # Get LTE5635 TC07 PM Counter Again
# #     Sleep    300s
# #     Get LTE5635 TC07 PM Counter
# # 
# # Check LTE5635 TC07 Counter
# #     BuiltIn.Log    \n Check PM counter \n    console=yes
# #     Should be True      ${countervalue187} > 0
# #     Should be True      ${countervalue191} > 0
# #     Should be True      ${countervalue263} > 0
# #     Should be True      ${countervalue267} > 0
# # 	${countervalueresult}    Evaluate    ${countervalue187}/(${countervalue191}*0.001)
# # 	Should be True       ${countervalueresult} > 125
# # 
# # Step2: LTE5077 TC12 Check PM counter
# #     Get LTE5077 TC12 PM counter    couter_path262=${couter_path262}    couter_path460=${couter_path460}
# #     Run keyword if    ${countervalue44_262} == 0 or ${countervalue44_460} == 0    Get LTE5077 TC12 PM Counter Again
# #     Check LTE5077 TC12 Counter
# # 
# # Get LTE5077 TC12 PM Counter Again
# #     Sleep   300s
# #     Get LTE5077 TC12 PM counter    couter_path262=${couter_path262}    couter_path460=${couter_path460}
# # 
# # Check LTE5077 TC12 Counter
# #     BuiltIn.Log    \n Check PM counter \n    console=yes
# #     Should be True      ${countervalue44_262} > 0
# #     Should be True      ${countervalue45_262} > 0
# #     Should be True      ${countervalue44_460} > 0
# #     Should be True      ${countervalue45_460} > 0
# # 
# # Get LTE5077 TC12 PM counter
# #     [Arguments]    ${couter_path262}    ${couter_path460}
# #     BuiltIn.Log    \n Get PM counter \n    console=yes
# #     ${countervalue44_262}    get PM counter latest value    counter_id=M8038C44
# #     ...    couter_path=${couter_path262}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue44_262}
# #     ${countervalue45_262}    get PM counter latest value    counter_id=M8038C45
# #     ...    couter_path=${couter_path262}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue45_262}
# #     ${countervalue44_460}    get PM counter latest value    counter_id=M8038C44
# #     ...    couter_path=${couter_path460}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue44_460}
# #     ${countervalue45_460}    get PM counter latest value    counter_id=M8038C45
# #     ...    couter_path=${couter_path460}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue45_460}
# # 
# # 
# # Step2: LTE4053 TC02 Check PM counter
# #     Get LTE4053 TC02 PM counter    path=${couter_path_M8011C276}
# #     Run keyword if    ${countervalue_M8011C276} == 0    Get LTE4053 TC02 PM Counter Again
# #     Check LTE4053 TC02 Counter
# # 
# # Get LTE4053 TC02 PM Counter Again
# #     Sleep    300s
# #     Get LTE4053 TC02 PM counter    path=${couter_path_M8011C276}
# # 
# # Check LTE4053 TC02 Counter
# #     BuiltIn.Log    \n Check PM counter \n    console=yes
# #     Should be True      ${countervalue_M8011C276} > 0
# # 
# # 
# # Get LTE4053 TC02 PM counter
# #     [Arguments]    ${path}
# #     BuiltIn.Log    \n Get PM counter \n    console=yes
# #     ${countervalue_M8011C276}    get PM counter latest value    counter_id=M8011C276
# #     ...    couter_path=${path}
# #     ...    connection=GNB_OAM
# #     Set Test Variable    ${countervalue_M8011C276}
