*** Settings ***
Documentation
...    author: yingying.li
...    contact:yingying.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC001358-B

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap    WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library    taf.analyzer.pcap   WITH NAME    cap
#Library     get_pm_counter.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.rfrl.common_resources.python.SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     ../../libraries/L3Call.py
#Library     ../../libraries/TTI_Trace_Analysis_dl.py
#Library     ../../../../../resources/python_libs/check_csv_log.py
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/common/connection_with_hostname.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Variables    ./5GC001358_variables.py

*** Variables ***
##PATH##
${TS_LOG_PATH_BASE}          /home/ute/log
${tshark_path}              /usr/bin/tshark
${LUA_SCRIPT_PATH}          /home/ute/luashark/generated_luashark/luashark.lua
${gnb_path}                 /tmp
${SCF_TEMPLATE_PATH}       ${commissionings_path}/HGZ/${testline_name}
##GNB##
@{params_in_swconfig}        0x5800DD=1     0x580017=1
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
${gnb_instance_0}           ${tl.gnbs[0].instance_id}

##Iperf##
${appserver_addr}           ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}       ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}       ${tl.ues[0].iperf_details.ssh_connection_details.password}

##UE##
${SN}                       ${tl.ues[0].serial_number}
${ue_type}                  ${tl.ues[0].capabilities[1]}
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${biplog_rank1}             tcpdumpL2L1_rank1.pcap

*** Keywords ***

Common Suite Setup for COAM
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    ${sw_version}    replace string   ${sw_version}    SBTS22R2    SBTS00
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}
	robot_common_operations.Common Suite Setup

Common Suite Teardown for COAM
    [Arguments]    ${localFilePath}=${TS_LOG_PATH_BASE}
    Connect to gnb coam via ssl
    Restore SwConfig File To Asik And Crasign
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    Scf commission and wait for onair    scf_name=Golden.xml
	robot_common_operations.Common Suite Teardown

Restore SwConfig File To Asik And Crasign
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt.bak /ffs/run/swconfig.txt   connection=ASIK Master
    csn.send command    command=crasign /ffs/run/swconfig.txt    connection=ASIK Master

Tests Recover NSA
    disconect all connections
    CI_interface.Common Case Teardown

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK


Prepare testline to cell onair for NSA
    Modify Swconfig File
    Scf commission and wait for onair    scf_name=SCF_SBTS00.xml
    Change Parameter    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    actDl256Qam     update    false

Modify Swconfig File
    [Arguments]    ${para_update}=${params_in_swconfig}    ${local_path}=${TS_LOG_PATH_BASE}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master


Scf commission and wait for onair
    [Arguments]   ${scf_name}
    Connect to gnb coam via ssl
    coam.perform_commissioning
    ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair    connection=GNB_OAM
#    ssh.force_reconnect    connection=ASIK Master

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    coam.perform_parameter_recommissioning       ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=GNB_OAM


##PM counter##
Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3.5    Record time again
    ${utc_left} =    Evaluate    5-${utc_min}+1
    set suite variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Check PM counter with sort list
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${result} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    Sort list    ${result}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections

Catch Bip log on trunk and download BIP log to UTE
    Log To Console    \n ###start to catch bip log ###
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts
    csn.send command    command=killall tcpdump     connection=ASIK Master

Download BIP Logs
    [Arguments]       ${log_path}=${SUITE_LOG_PATH}    ${download_type}=Download
    Log To Console    \n ###download bip log to testPC ###
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    download_type=${download_type}
    [Return]    ${list_log_path_local}
    Set Suite Variable      ${list_log_path_local}

Check RU Calibration Status And Power
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.3    ${asik_connection}=ASIK Master    ${retry_time}=3
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
            Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}
            ...    asik_alias=${asik_connection}   connection=${connection}
           Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
           ...    Check RU Calibration Status    ru_alias=RU${ru_index}
           run keyword if    "AZQ" in "${tl.gnbs[0].dus[0].rus[0].radio_type}"    Check AZGX RU Power on DFE   ru_alias=RU${ru_index}
           ...    ELSE
           ...             Check AEHC RU Power on DFE    ru_alias=RU${ru_index}    ru_dfe_ip=${ru_dfe_ip}
           csn.Disconnect  connection=RU${ru_index}
    END
   [Teardown]  COAM Teardown gnb connections


Check RU Calibration Status
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${carrier_name}=NR
    ${calibration_output}    csn.execute    command=bfcali -stat    connection=${ru_alias}
    ${nr_calibration}    Split String From RU Calibration Output    calibration_output=${calibration_output}
    Get RU Calibration Value And Compare    nr_calibration=${nr_calibration}


Split String From RU Calibration Output
    [Documentation]  Author: Jia Lei
    [Arguments]    ${calibration_output}    ${carrier_name}=NR    ${sperator}=\r\n\r\n
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    [Return]    ${nr_calibration}

Get RU Calibration Value And Compare
    [Documentation]  Author: Jia Lei
    [Arguments]    ${nr_calibration}
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           should be equal   ${attempt_count}    ${success_count}
    END


Check AZGX RU Power on DFE
    [Documentation]  Author: haoxiaoxia
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.3    ${all_attenna_ports}=8
    ${connection}    csn.get connection by alias    alias=${ru_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send     ssh ${ru_dfe_ip}\n
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        Call Method    ${channel}    send     dapd -stat ${index}\n
        sleep  2s
        ${dfe_power_output}    Call Method    ${channel}    recv    ${65535}
        Log    ${dfe_power_output}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  Call Method    ${channel}    close

Check AEHC RU Power on DFE
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.3    ${ru_dfe_alias}=ru_dfe
    ...    ${all_attenna_ports}=8
    csn.connect to    hostname=${ru_dfe_ip}
    ...               username=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...               alias=${ru_dfe_alias}
    ...               proxy=${ru_alias}
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        ${dfe_power_output}    csn.execute    command=dapd -stat ${index}    connection=${ru_dfe_alias}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  csn.Disconnect  connection=${ru_dfe_alias}


Power UE Precondition
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}    ${gnb_index}=${0}
     Log To Console    \n ###UE attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_index}=${0}    ${gnb_index}=${0}    ${ue_type}=askey
    Log To Console    \n *** Start to check DL throughput
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Power UE Start traffic and check throughput
    [Arguments]    ${dl_throughput}    ${Expect_DOWNLINK}    ${ue_index}=${0}    ${gnb_index}=${0}
    Log To Console    \n ###UE Start traffic and check TP ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}    duration=120s
    sleep    5s
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Power UE Start dl traffic
    [Arguments]    ${dl_throughput}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}    duration=3600s

Power UE stop dl traffic
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE Detach
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}


Stop traffic and detach UE
    Log To Console    \n ### Stop traffic ###
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
