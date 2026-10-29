*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Wang kk
...              Contact: kk.wang@nokia-sbell.com
...              Already verified equipment: Multi pioneer Ues

Library     taf.ue.pioneer.client       WITH NAME           pclient

*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${host}=${host}    ${username}=${username}
        ...    ${password}=${password}    ${alias}=pioneer    ${ue_alias}=mate20x
        ...    ${port}=30999    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    pclient.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${username}
    ...    ssh_password=${password}
    ...    alias=${alias}
    pclient.prepare_ues    service=${alias}
#    pclient.stoplog    service=${alias}
    pclient.remove_remote_files    folder_path=c:/pioneer_logs/    service=${alias}
#    pclient.startlog    logpath=C:/pioneer_logs/    logname=ta_log    service=${alias}
    pclient.require_ue    service=${alias}     ue_alias=${ue_alias}
    ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias}
#    pclient.poweroff     ue=mate20x    ue_index=${1}
    sleep    2s

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_index}=${1}    ${ue_alias}=mate20x    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    run keyword and ignore error    pclient.poweroff     ue=${ue_alias}    until_timeout=90
    sleep    10s
    pclient.poweron     ue=${ue_alias}    until_timeout=90
    sleep    2s


################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    Log    Already verified inside UE Attach.


################################## STEP3: START DATA TRANSFER ##################################
#Start dl traffic

Start ul traffic in dingli
    [Arguments]    ${protocol}=udp    ${address}=${address}    ${port}=5001    ${testtime}=20
        ...    ${bandwidth}=1000    ${buffersize}=1024    ${packetsize}=1400
    pclient.startultraffic
    ...    protocol=${protocol}
    ...    address=${address}
    ...    port=${port}
    ...    testtime=${testtime}
    ...    bandwidth=${bandwidth}
    ...    buffersize=${buffersize}
    ...    packetsize=${packetsize}
    ...    ue=mate20x



################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${duration}=10min    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${Teardown_after_finished}=${True}    ${upload_duration}=${True}    &{kwargs}
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.

    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour

    ...                Should be used between Start traffic and Stop traffic!!!
    ...                E.G    Single direction
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic

    ...                E.G    BI-direction
    ...                Power_ue.Start Traffic     direction=ul
    ...                Power_ue.Start Traffic     direction=dl
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                The tput_log will contain both direction throughput data.

    ${log_path}    power_ue_throughput.__Standard Capturing Aasyslog Throughput
    ...            gnb_index=${gnb_index}    du_index=${du_index}
    ...            type=${type}    duration=${duration}    ignore_time=${ignore_time}
    ...            filter=${filter}    Teardown_after_finished=${Teardown_after_finished}
    ...            upload_duration=${upload_duration}
    [Return]    ${log_path}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${cell_indiv_tput}=${None}    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param target_throughput: theory target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.

    ...                E.G    Single direction
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                ${list_of_cell_ids}    Create list  16385
    ...                power_ue.Check Tput    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}
    ...                                                      target_throughput=2048  # unit is Mbps
    ...                E.G    Bi-direction with individual check.
    ...                Power_ue.Start Traffic
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                ${ul_cell}    Create list  16385
    ...                ${dl_cell}    Create list  16388
    ...                Power_ue.power_ue.Check Tput    direction=DL    cells=${ul_cell}    log=${tput_log}
    ...                                                target_throughput=2048  # unit is Mbps
    ...                Power_ue.power_ue.Check Tput    direction=DL    cells=${dl_cell}    log=${tput_log}
    ...                                                target_throughput=256  # unit is Mbps

    ${throughput_result}    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=${direction}    log=${log}    cells=${cells}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    ...    customized_log_name=${customized_log_name}    cell_indiv_tput=${cell_indiv_tput}
    [Return]    ${throughput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param ultarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param dltarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.

    ...                E.G
    ...                Power_ue.Start Traffic
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                ${list_of_cell_ids}    Create list    16385    16388
    ...                Power_ue.Check Bi Tput    cells=${list_of_cell_ids}    log=${tput_log}
    ...                                          ultarget_throughput=2048    dltarget_throughput=256   # unit is Mbps

    ${throughput_result}    power_ue_throughput.__Standard Check Bi Aasyslog Throughput
    ...    log=${log}    cells=${cells}    min_percent=${min_percent}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...    customized_log_name=${customized_log_name}
    [Return]    ${throughput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_index}    ${iperf_port}=default    ${iperf_type}=via_app    ${protocol}=udp    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    Replace with your keyword

stop uplink traffic
    pclient.stopultraffic    ue=mate20x

Check throughput
    [Arguments]    ${direction}    ${throughput}    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ${output}    pclient.getparammac    ue=mate20x
    ${Tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output['Param']['MACDL']} / 1000 / 1000
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output['Param']['MACDL']} / 1000 / 1000
    should be true    ${Tput} > ${throughput}
    [Return]    ${Tput}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}    ${ue_alias}=mate20x     &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    pclient.detach    ue=${ue_alias}    withpdu=1

################################## STEP7: start mos ##################################
start mos
    [Arguments]    ${ue_index}=${0}    ${callmode}=${0}    ${calledue}=${2}    ${callednum}=+8613100001137
    ...      ${videocall}=${0}   ${duration}=${800}    ${testcount}=${1}    ${algorithms}=${2}    ${polqaversion}=${1}
    ...      ${mosboxtype}=${1}    ${groupno}=${0}    ${ue_alias}=mate20x    &{kwargs}
    [Documentation]    start mos for vonr test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for start mos
    pclient.startmos
	...    ue=${ue_alias}
	...    callmode=${callmode}
	...    calledue=${calledue}
	...    callednum=${callednum}
	...    videocall=${videocall}
	...    duration=${duration}
	...    testcount=${testcount}
	...    algorithms=${algorithms}
	...    polqaversion=${polqaversion}
	...    mosboxtype=${mosboxtype}
	...    groupno=${groupno}

################################## STEP8: stop mos ##################################
stop mos
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=mate20x     &{kwargs}
    [Documentation]    stop mos for vonr test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for start mos
    pclient.stopmos    ue=${ue_alias}
