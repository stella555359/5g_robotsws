# # #*** Settings ***
# # #Documentation
# # #...    author: Bella Chen
# # #...    contact:bella.chen@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : CB007326_2200
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #
# # #
# # #Suite Setup       Run Keywords
# # #...    Run Keyword And Ignore Error       Common Suite Setup for COAM    AND
# # #...    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${scf_enable2200}    AND
# # #...    lock LTE
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       ../CB007326_2060/Resources/CB007326_2060_coam_common_keywords.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Variables    ./Resources/variables_2060.py
# # #
# # #*** Variables ***
# # #${scf_enable2200}           7326_784_SCF.xml
# # #${swconfig}                 /opt/workspace/SCF/2060/swconfig/swconfig.txt
# # #${2200_B_nglog}           2200_B_wireshark_enable.pcap
# # #${Send_Tput_DL}              1600M
# # #${Expect_peak}      1550
# # #${att_good}    ${0}
# # #${att_bad}    ${127}
# # #${atten_ip}                  ${tl.attenuator[0].ip_addr}
# # #
# # #*** Test Cases ***
# # #[1]CB007326_2200_B_004_max_DL_Tput_with_4_resources_and_good_condition_SA
# # #    [Documentation]
# # #    ...    this test case is to verify 8TRX(1*4*2) RU can do DL data transfer successfully when 2200 feature enable
# # #    ...    in good air condition(around -60dbm). DL tput can achieve to peak throughput and compare with DL tput when
# # #    ...    1856 enabled, There should be a little more or equal for the cell throughput with the same radio condition
# # #    ...    (good radio condition), if there is a bler, it should be a little less or equal to the bler of 1856 enabled.
# # #    ...    It can be no need be better(better will be good), but it should be commit no aggravate.
# # #    [Tags]      classical    CRT_TRUNK    CRT_22R2
# # #    [Timeout]    2 hour
# # #    [Setup]
# # #    Modify the COAM parameter with admin API    parameters=${parameter_2200_B_004}
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
# # #    ...    Adjust the tl HBTE attenuation value    tl=${376}    value1=${att_good}    value2=${att_bad}
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
# # #    ...    Adjust the tl HBTE attenuation value    tl=${388}    value1=${att_good}    value2=${att_bad}
# # #    ...    ELSE    Adjust the tl HBTE attenuation value    tl=${377}    value1=${att_good}    value2=${att_bad}
# # #    Test ON SA 388
# # #    Analysis 2200 enable
# # #    [Teardown]    Run keywords
# # #    ...    Run Keyword And Ignore Error    Tests Recover    AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #
# # #
# # #*** Keywords ***
# # #
# # #Test ON SA
# # #    ASKEY UE parameter setup
# # #    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    reset_sol=${true}
# # #    ##GOOD POINT##
# # #    wait until keyword succeeds    2min    10s    Start To Capture Wireshark Logs    filename=${2200_B_nglog}    connection=gnb    interface=any
# # #    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Start DL date transfer on appserver    traffic=${Send_Tput_DL}
# # #    Stop and download wireshark Logs    logname=${2200_B_nglog}    connection=gnb
# # #    Wait Until Keyword Succeeds   8m   10s   Check throughput For 2200
# # #    sleep    2s
# # #    Askey UE stop dl traffic on appserver and detach
# # #
# # #Test ON SA 388
# # #    lock LTE
# # #    Set Suite Variable    ${ue_type}    xiaomi
# # #    Set automatic rotation on UEs
# # #    Check UE device exist
# # #    Prepare env with UE
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'    Get all xiaomi11 pointer variable tl388
# # #    ...    ELSE    Get all xiaomi11 pointer variable tl377
# # #    ##GOOD POINT##
# # #    wait until keyword succeeds    2min    10s    Start To Capture Wireshark Logs    filename=${2200_B_nglog}    connection=gnb    interface=any
# # #    Power UE Attach and Verify attach
# # #    Start DL date transfer    dl_throughput=${Send_Tput_DL}    ue_index=${0}
# # #    sleep    10s
# # #    Stop and download wireshark Logs    logname=${2200_B_nglog}    connection=gnb
# # #    Wait Until Keyword Succeeds   8m   10s   Power UE check throughput    Expect_DOWNLINK=${Expect_peak}   ue_type=${ue_type}
# # #    sleep    2s
# # #    Xioami UE stop dl traffic and detach
# # #
# # #Analysis 2200 enable
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${2200_B_nglog}    tshark_path=${tshark_path}    command_template=${None}
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 12
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${n1_n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1_n2}    2
# # #
# # #    ${UeContextSetupResponse}=    Catenate    f1ap.procedureCode == 5
# # #    ${filtered_packets_1}=    cap.filter_packets_by_expression    filter_expression=${UeContextSetupResponse}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets_1}    xpath=.//nr-rrc.nrofPorts
# # #    should contain    ${nrofPorts}[0]    3
# # #    should contain    ${nrofPorts}[1]    3
# # #    should contain    ${nrofPorts}[2]    3
# # #    should contain    ${nrofPorts}[3]    3
# # #
# # #Tests Recover
# # #    Run Keyword And Ignore Error    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}
# # #    ...    asik_password=${asik_password}
# # #    Run Keyword And Ignore Error    csn.send command    command=killall tcpdump     connection=gnb
# # #    Run Keyword And Ignore Error    Xioami UE stop dl traffic and detach
# # #    Run Keyword And Ignore Error    unlock lte
# # #    Run Keyword And Ignore Error    disconect all connections
# # #
# # #
# # #Check throughput For 2200
# # #    ${list_of_cell_ids}    Create list    612941825
# # #    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=20s
# # #    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
# # #    ...    target_throughput=${Expect_peak}