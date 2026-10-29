# @Time    : 2021/10/27 14:11
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Globe_Lab_LTE_Keywords.robot
# @Software: PyCharm
# @Doc     : Globe LTE Special Keywords
*** Settings ***
Resource    basic_keywords/enb.robot
Resource    basic_keywords/ue.robot
Resource    basic_keywords/wireshark.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/pmcounters.robot

*** Keywords ***
Keep enb1 single cell unlock
    Connect to eNB via ssl
    Lock Parameter    ${ENB0 DIST CELL11}
    Unlock Parameter    ${ENB0 DIST CELL12}
    Lock Parameter    ${ENB0 DIST CELL13}
    [Teardown]    Enblte close down

Verify S1 Link Established After Reboot ENB
    [Arguments]    ${file_name}
    Start Capture Wireshark Log On Control PC    file_name=${file_name}
    enblte.reset_site    timeout=10min    connection=enb_lte    wait_for_reconnection=TRUE
    Wait Until Keyword Succeeds     10min    5s    Check enb status is in cell on air status
    Collect Wireshark Log On Control PC    file_name=${file_name}
    Verify S1 Link Established    file_name=${file_name}

Verify S1 Link Established After Reboot MME
    [Arguments]    ${file_name}
    Start Capture Wireshark Log On Control PC    file_name=${file_name}
    Lock Parameter    ${ENB0 DIST MME0}
    Lock Parameter    ${ENB0 DIST MME1}
    Unlock Parameter    ${ENB0 DIST MME0}
    Unlock Parameter    ${ENB0 DIST MME1}
    Wait Until Keyword Succeeds    10min    5s    Check enb status is in cell on air status
    Collect Wireshark Log On Control PC    file_name=${file_name}
    Verify S1 Link Established    file_name=${file_name}

Set PA Make Enb1 Signal Stronger
    [Documentation]    enb1:2010(2&4)    enb2:1838(1&3)
    ${channels_to_modify}    create dictionary    1=120    2=0    3=120    4=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}

Set PA Make Enb1 Signal Stronger Slowly
    [Documentation]    enb1:2010(2&4)    enb2:1838(1&3)
    ${channel_1_value}    Set Variable    0
    ${channel_3_value}    Set Variable    0
    FOR  ${num}  IN RANGE  20
        ${channel_1_value}    Evaluate    ${channel_1_value}+5
        ${channel_3_value}    Evaluate    ${channel_3_value}+5
        ${channels_to_modify}    create dictionary    1=${channel_1_value}    2=0    3=${channel_3_value}    4=0
        gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}
    END

Set PA Make Enb2 Signal Stronger
    [Documentation]    enb1:2010(2&4)    enb2:1838(1&3)
    ${channels_to_modify}    create dictionary    1=0    2=120    3=0    4=120
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}

Verify Enb1 Support Handover To Enb2
    ${old_cell_tac}    Get UE Cell Tac
    Set PA Make Enb2 Signal Stronger
    Wait Until Keyword Succeeds    30s    5s    Check UE Cell Changed    old_cell_tac=${old_cell_tac}

Verify Enb2 Support Handover To Enb1
    ${old_cell_tac}    Get UE Cell Tac
    Set PA Make Enb1 Signal Stronger
    Wait Until Keyword Succeeds    30s    5s    Check UE Cell Changed    old_cell_tac=${old_cell_tac}

Verify Enbs Support Handover Multiple Times
    [Arguments]    ${exec_num}
    FOR  ${num}  IN RANGE  ${exec_num}
        UE Attach And Detach
        UE Start DL Traffic    throughput=100M
        Verify Enb1 Support Handover To Enb2
        Verify Enb2 Support Handover To Enb1
        Close the iperf process on APPserver    port=${dl_port}
        UE UE detach
    END

Globe Commission With Scf File
    [Arguments]    ${gnb_index}    ${scf_file_path}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf_file_path}    is_pdl_checking_needed=False
    Wait Until Keyword Succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Keep Enb1 Single Cell12 Unlock
    Connect to eNB via ssl
    Unlock Parameter    ${ENB0 DIST CELL12}
    Lock Parameter    ${ENB0 DIST CELL11}
    Lock Parameter    ${ENB0 DIST CELL13}
    [Teardown]    Enblte close down

Keep Enb1 Single Cell13 Unlock
    Connect to eNB via ssl
    Unlock Parameter    ${ENB0 DIST CELL13}
    Lock Parameter    ${ENB0 DIST CELL11}
    Lock Parameter    ${ENB0 DIST CELL12}
    [Teardown]    Enblte close down

Keep Enb1 Cell12 And Cell13 Unlock
    Connect to eNB via ssl
    Unlock Parameter    ${ENB0 DIST CELL12}
    Unlock Parameter    ${ENB0 DIST CELL13}
    Lock Parameter    ${ENB0 DIST CELL11}
    [Teardown]    Enblte close down

Collect Download PM Counter
    [Arguments]    ${pi_id_1}    ${pi_id_2}    ${moc}    ${wait_time}=120
    Sleep    ${wait_time}
    ${pm_files_location}    Collect PM Counter
    ${counter_value1}    Get PM counter value    pm_files_location=${pm_files_location}    pi_id=${pi_id_1}    moc=${moc}
    ${counter_value2}    Get PM counter value    pm_files_location=${pm_files_location}    pi_id=${pi_id_2}    moc=${moc}
    ${real_counter_value}    Evaluate    ${counter_value1}/${counter_value2}*0.001
    Empty Directory    ${pm_files_location}
    [Return]    ${real_counter_value}

Collect Upload PM Counter
    [Arguments]    ${pi_id}    ${moc}    ${wait_time}=120
    Sleep    ${wait_time}
    ${pm_files_location}    Collect PM Counter
    ${counter_value}    Get PM counter value    pm_files_location=${pm_files_location}    pi_id=${pi_id}    moc=${moc}
    ${real_counter_value}    Evaluate    ${counter_value}*0.001
    Empty Directory    ${pm_files_location}
    [Return]    ${real_counter_value}

