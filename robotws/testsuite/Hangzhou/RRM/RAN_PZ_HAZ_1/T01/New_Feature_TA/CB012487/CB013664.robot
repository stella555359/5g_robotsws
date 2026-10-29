*** Settings ***
Documentation
...   Author: Song Jiana
...   Contact: jiana.song@nokia.com
...   Description: An operator-initiated SW rollback to pre-listed unwanted SW versions is blocked.
...   In case of rollback the BTS sends an alarm in addition to the existing change notification to the NMS SW Manager.

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM
Force Tags
...                CRT
...                TRUNK
#Test Timeout    60 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../../Resources/Common/AIC_UE.robot
#Resource    ../Resources/RRM2_Resource.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Alarm_Operation.robot

*** Variables ***
${scf_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB012487/config
${ue_index}    0
${iperf_port}    ${tl.ues[0].iperf_details.port}
${ul_data_addr}    10.97.97.18
*** Test Cases ***

[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_Radio_path_failure
    [Tags]    QC_240849      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664.
    ${scfinfo}=    evaluate    '${RELEASE}'.split('SBTS')[1]    sys
    ${scf_build}=    Set Variable If    '${RELEASE}'=='SBTS00'    SBTS00    ${scfinfo}
    Adjust PA Signal for cell3
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}/SCF_${scf_build}.xml
    Log To Console    full commission result: ${out}
    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=gnb
    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
    Run Keyword And Continue On Failure   Prepare UE
    Run Keyword And Continue On Failure   Start dl_ul data and Check data transfer
    ${out_}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}/SCF_${scf_build}_original.xml
    Log To Console    full commission result: ${out_}
    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=gnb
    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
    Run Keyword And Continue On Failure   Start dl_ul data and Check data transfer
    Close PA Signal for ALL RUs
    Log To Console    CB013664
    [Teardown]    TC01 Teardown
*** Keywords ***
TC01 Teardown
    Qualcomm.Teardown UE
    Common Test Teardown For RRM

Prepare UE
    Qualcomm.Prepare UE

Start dl_ul data and Check data transfer
    [Arguments]    ${dlthroughput}=200M    ${duration}=360    ${direction}=dl    ${dl_expect}=10    ${cell_id}=5816323
    Log To Console    Start prepare UE and check data transfer
    Qualcomm.UE Attach
    Qualcomm.Start traffic    direction=dl    iperf_port=${iperf_port}    throughput=${dlthroughput}    duration=${duration}
    Start data transfer for ul    ${ue_index}    ul_time=${duration}    ul_port=44379    ul_throughput=50M    ul_length=1400B
    sleep   15s
    Check throughput     direction=${direction}    dl_expect=${dl_expect}    cell_id=${cell_id}
    Log To Console     stop traffic
    Close the iperf process for ul    ue_index=${ue_index}    iperf_port=44379
    Qualcomm.Stop traffic    iperf_port=${iperf_port}
    sleep   5s

Connect to APPserversim
    Connect to APPserver

Adjust PA Signal for RU
    [Arguments]    ${RU_id}=0    ${adjust_att_value1}=120    ${adjust_att_value2}=120
    Log to Console    \n***Start to ajust PA power....or you may say that attenuation ports power...***
    ${attenuation_port_numbers}     Get Attenuation port    RU_id=${RU_id}
    ${port_number}    Get Length    ${attenuation_port_numbers}
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=${RU_id}    vendor=TopYoung
    ${channels_to_modify}    create dictionary
    FOR    ${index}    IN RANGE    ${port_number}
        ${port}    Set Variable    ${attenuation_port_numbers[${index}]}
        # 端口号从1开始，index从0开始 cell3-RU1-1&3,RU2-2&4
        ${port_idx}    Evaluate    ${index}+1
        Run Keyword If    ${port_idx} == 1 or ${port_idx} == 3    Set To Dictionary    ${channels_to_modify}    ${port}    ${adjust_att_value1}
        ...    ELSE IF    ${port_idx} == 2 or ${port_idx} == 4    Set To Dictionary    ${channels_to_modify}    ${port}    ${adjust_att_value2}
    END
    Modify Attenuation Value    ${channels_to_modify}    RU_id=${RU_id}
    sleep    10s
    Log to console    \n***Attenuation ports ajusted......***
    [Return]    ${initial_att_values}

Adjust PA Signal for cell3
    Adjust PA Signal for RU    RU_id=0    adjust_att_value1=30    adjust_att_value2=120
    Adjust PA Signal for RU    RU_id=1    adjust_att_value1=120    adjust_att_value2=30

Close PA Signal for ALL RUs
    Adjust PA Signal for RU    RU_id=0    adjust_att_value1=120    adjust_att_value2=120
    Adjust PA Signal for RU    RU_id=1    adjust_att_value1=120    adjust_att_value2=120

Start data transfer for ul
    [Arguments]    ${ue_index}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}    ${appserver}=APPserver
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Close the iperf process for ul    ue_index=${ue_index}    iperf_port=44379
    Connect to control pc enhanced    ue_index=${ue_index}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'    catenate    adb -s ${serial_number} shell
    ...    /system/bin/iperf -c ${ul_data_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${ul_port} |grep -v grep |awk '{print $2}'
    ...    connection=cpc_${ue_index}    timeout=60
    ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
    ${iperf_pid}    evaluate    ${output.strip()}
    should be true    ${iperf_pid} > ${0}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Close the iperf process for ul
    [Arguments]    ${ue_index}    ${iperf_port}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    Log To Console    kill iperf process for ul traffic
    # 查找进程PID
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${iperf_port} |grep -v grep |awk '{print $2}'
    ...    connection=cpc_${ue_index}    timeout=60
    ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
    # 如果有PID则直接kill
    Run Keyword If    '${output.strip()}' != ''    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${output}
    ...    connection=cpc_${ue_index}
    sleep    5s
    # 再次确认进程已被杀掉
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${iperf_port} |grep -v grep |awk '{print $2}'
    ...    connection=cpc_${ue_index}    timeout=60
    ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
    should be empty      ${output}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}