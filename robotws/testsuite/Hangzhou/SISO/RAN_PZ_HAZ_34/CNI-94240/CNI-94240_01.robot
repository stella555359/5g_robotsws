*** Settings ***
Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature CNI-94240 supercell in AZQG/L

Force Tags
...    PY36
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    ./Resources/CNI-94240_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Variables      ./Resources/CNI-94240_Parameters.py

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${data_amount}    2M
${seg_size}    1300
${process_num}    5
${protocol}  udp
${deviation}    1%
${ue_type}    ${tl.ues[-1].capabilities[-1]}
${sleep_time}    3min
${ultp_expected}    85
${data_send_ul}    120M
${dltp_expected}    1350
${data_send_dl}    1500M
${dltp_expected_without256}     950
#${SCF_TEMPLATE_PATH}    /home/ute/wxc/scf/SCF_SBTS00.xml
${SCF_TEMPLATE_PATH}       ${commissionings_path}/HGZ/${testline_name}
${vendor}                   HBTE
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_12}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_api_port}             ${tl.attenuator.port}
${HBTE_max_value}           ${127}
${model}    PA-16-16-6-127-0.5-B-S


*** Test Cases ***
[1]CNI-94240_01_CB008434-A_SiSo_E2E_system_setup_L3call_3_RUs_1_supercell_half_ABIO_or_ASOE_NSA
    [Documentation]    supercell:HALF ABIO/ASOE,Full ABIN
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
    Test Case setup to on air
	Prepare UE for ${ue_type}
	Peak Tput check for every subcell    dltp_expected=${dltp_expected}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
    [Teardown]     Test case teardown

[1]CNI-94240_14_General_SiSo_Cell_Block_unblock
    [Documentation]    supercell:HALF ABIO/ASOE,Full ABIN
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
    Test Case setup to on air
	Prepare UE for ${ue_type}
	UE attached in subcell1 and check TP    dltp_expected=${dltp_expected}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
	Lock and unlock cell
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    UE attached in subcell1 and check TP    dltp_expected=${dltp_expected}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
    [Teardown]     Test case teardown


[1]CNI-94240_15_General_SiSo_Cell_RU_lock_unlock
    [Documentation]    supercell:HALF ABIO/ASOE,Full ABIN
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
    Test Case setup to on air
	Prepare UE for ${ue_type}
	UE attached in subcell1 and check TP    dltp_expected=${dltp_expected}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
	Perform RU Lock     ru_index=${1}     download_dir=${TestCase_Log_Path}
	Perform RU Unlock   ru_index=${1}     download_dir=${TestCase_Log_Path}
    Connect to gnb coam via ssl
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    UE attached in subcell1 and check TP    dltp_expected=${dltp_expected}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
    [Teardown]     Test case teardown


[1]CNI-94240_13_General_SiSo_Parameter_Modification
    [Documentation]    supercell:HALF ABIO/ASOE,Full ABIN
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
    Test Case setup to on air
	Prepare UE for ${ue_type}
	UE attached in subcell1 and check TP    dltp_expected=${dltp_expected}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
    Connect to gnb coam via ssl
    Change Parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsId}/NRCELL-1    parameter=actDl256Qam
    ...    operation=update    value=false
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    UE attached in subcell1 and check TP    dltp_expected=${dltp_expected_without256}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
	Change Parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsId}/NRCELL-1    parameter=pMax
    ...    operation=update    value=410
    UE attached in subcell1 and check TP    dltp_expected=${dltp_expected_without256}    data_send_dl=${data_send_dl}
	...    data_send_ul=${data_send_ul}    ultp_expected=${ultp_expected}
    [Teardown]     Test case teardown





*** Keywords ***
Test case teardown
	robot_common_operations.Common Case Teardown

Test Case setup to on air
    COAM Create log directory
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}.xml
    ...    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections



Peak Tput check for every subcell
    [Arguments]    ${dltp_expected}    ${data_send_dl}    ${ultp_expected}    ${data_send_ul}
    FOR    ${i}    IN RANGE    3
        Adjust HBTE ATT Values    ${ATTENUATION_VALUE_${i}}
        UE Attach and verify attach    ue_index=${0}    ue_type=${ue_type}
	    Start traffic and check result    dltp_expected=${dltp_expected}     data_send_dl=${data_send_dl}   tp_direction=both
	    	...    ultp_expected=${ultp_expected}     data_send_ul=${data_send_ul}
	       ...    sleep_time=${sleep_time}    ue_index=${0}
	    UE Detach for    ue_type=${ue_type}     ue_index=${0}
        sleep    3s
    END


Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR  ${port_num}    IN RANGE    1    13
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


UE attached in subcell1 and check TP
     [Arguments]    ${dltp_expected}    ${data_send_dl}    ${ultp_expected}    ${data_send_ul}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_0}
    UE Attach and verify attach    ue_index=${0}    ue_type=${ue_type}
	Start traffic and check result    dltp_expected=${dltp_expected}     data_send_dl=${data_send_dl}   tp_direction=both
	...    ultp_expected=${ultp_expected}     data_send_ul=${data_send_ul}     sleep_time=${sleep_time}    ue_index=${0}
   	UE Detach for    ue_type=${ue_type}     ue_index=${0}
    sleep    3s


 Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    admin_cli.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=GNB_OAM

Lock and unlock cell
    Connect to gnb coam via ssl
    log to console    Lock cell
    coam.lock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=GNB_OAM
    sleep    5s
    log to console    unlock cell
    coam.unlock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=GNB_OAM
