*** Settings ***
Documentation
...    author: Yao Zhang
...    contact: yao.1.zhang@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002177

Library    OperatingSystem
Library    Collections
Library    taf.stc.config
Library    String
Library    BuiltIn
#Library    ../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library     taf.hw.rf_attenuator    WITH NAME    att
#Library    ../../libraries/ece_fastReg.py
Library     taf.rfrl.common_resources.python.SWConfig
Library    taf.transport.ssh    WITH NAME    csn
#Library    ../../../../../resources/python_libs/Attenuation.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Library    ../../libraries/L3Call.py
Variables    Test_Parameters.py
Variables    variables.py


*** Variables ***
${UE_pc_ip}    ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}    ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${SN}    ${tl.ues[0].serial_number}
${ue_type}    ${tl.ues[0].capabilities[1]}
${atten_ip}    ${tl.attenuator[0].ip_addr}
${atten1_ip}    ${tl.attenuator[1].ip_addr}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5GRU3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${ue_poweron}    AT+CFUN=1
${ue_poweroff}    AT+CFUN=0
${enbcell7_dist}    MRBTS-${enb_instance_id}/LNBTS-${enb_instance_id}/LNCEL-7
${enbcell8_dist}    MRBTS-${enb_instance_id}/LNBTS-${enb_instance_id}/LNCEL-8
${enbcell9_dist}    MRBTS-${enb_instance_id}/LNBTS-${enb_instance_id}/LNCEL-9
${enb_para}    administrativeState

### HBTE PA ###
${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
*** Keywords ***
Precondition for power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Attach and check power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}

Prepare the env with COAM classical BTS cell onair QCM
    Perform full commission for COAM gnb
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check coam classical gnb start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    2min    20s    Check the gnb cells onair


Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT1}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}    attenuation_port_numbers_oneport=${5GRU2_ANT1}

Adjust ${RU} four port to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}    attenuation_port_numbers_oneport=${5G${RU}_ANT1}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}    attenuation_port_numbers_oneport=${5G${RU}_ANT2}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT3}    value=${value}    attenuation_port_numbers_oneport=${5G${RU}_ANT3}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT4}    value=${value}    attenuation_port_numbers_oneport=${5G${RU}_ANT4}

#Adjust the Attenuation Value
#    [Arguments]    ${ports}    ${value}    ${atten_ip}=${atten_ip}
#    atten.connect to    ip=${atten_ip}
#    atten.get_value    channel=${ports}
#    atten.set_value    channel=${ports}    value=${value}
#    atten.disconnect

Adjust the Attenuation Value
    [Arguments]     ${ports}    ${value}    ${attenuation_port_numbers_oneport}=${5GRU1_ANT1}
    ...     ${atten_ip}=${atten_ip}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    @{attenuation_port_numbers_oneport}    create list    ${attenuation_port_numbers_oneport}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_oneport}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${ports}    value=${${value}}
    ${value_port_1}    attenuator.read_attenuation    port=${ports}
    should be equal    ${value_port_1}    ${${value}}
    sleep    5s

Adjust the HBTE attenuation value
    [Arguments]      ${value}    ${att_port1}=${att_port_1}
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value}
    att.set_attenuation     port=${att_port2}    value=${value}
    att.set_attenuation     port=${att_port3}    value=${value}
    att.set_attenuation     port=${att_port4}    value=${value}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value}

enb connections
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=enb

Start Capture Classical enb x2 Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    enb connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=enb    interface=br1
    sleep    3s

Stop and Save classical enb x2 Logs
    [Arguments]    ${x2logname}
    enb connections
    Stop and download Logs    logname=${x2logname}    connection=enb

Recover the env atten to normal value
    [Arguments]    ${value1}    ${value2}
    Adjust RU1 Attenuation to ${value1}
    Adjust RU2 Attenuation to ${value2}

Tests Recovery
    [Arguments]    ${x2logname}    ${default_value}={0}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword and ignore error  Stop and Save classical enb x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=enb
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Run Keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust RU1 four port to ${ru1_pa_value_default}
    ...    ELSE IF    '${release_info}' == 'SBTS21B'    Adjust the HBTE attenuation value    value=${${ru1_pa_value_default}}
    ...    ELSE    Run keywords    Adjust the Attenuation Value    ports=${5GRU2_ANT1}    value=${ru1_pa_value}    atten_ip=${atten1_ip}    AND
    ...    Adjust the Attenuation Value    ports=${5GRU3_ANT1}    value=${ru2_pa_value}    atten_ip=${atten1_ip}
    Run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Lock Unlock eNB cells    status=unlocked
    run keyword and ignore error    CI_interface.Common Case Teardown

Lock Unlock eNB cells
    [Arguments]    ${status}=locked
    Connect and Modify the parameter on enblte   dist_name=${enbcell7_dist}    parameter=${enb_para}    value=${status}
    sleep    5s
    Connect and Modify the parameter on enblte   dist_name=${enbcell8_dist}    parameter=${enb_para}    value=${status}
    sleep    5s
    Connect and Modify the parameter on enblte   dist_name=${enbcell9_dist}    parameter=${enb_para}    value=${status}

##Qualcomm keyword
Verify 5GRACH success times on gnb side
    [Arguments]    ${abil}=asp1a    ${gnb_index}=1
    wait until keyword succeeds    1 min    10 sec    Connect to BB${gnb_index} master     alias=asik
    wait until keyword succeeds    1 min    10 sec    Connect to ${abil}    alias=${abil}    proxy=asik
    ${output} =    csn.execute    command=journalctl -b | grep "flow control starts" |grep -v grep
    ...                           connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=asik
    @{list}    split string    ${output}    \n
    ${len} =    Get Length    ${list}
    [return]    ${len}

Get gnb release
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml    connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info
