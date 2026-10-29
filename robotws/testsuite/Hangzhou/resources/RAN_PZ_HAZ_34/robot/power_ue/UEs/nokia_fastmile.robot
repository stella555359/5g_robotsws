*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Zhong Tingting
...              Contact: tingting.zhong@nokia-sbell.com
...              Verified equipment: nokia_fastmile support taf.ue.fastmile
...              testline_configuration refer to 7_5_UTE5G402T319

Library    robot.libraries.DateTime
Library    taf.ue    WITH NAME    ute_ue
Library    taf.ul.power_ue    WITH NAME    ul_power_ue
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.CI_Operations.CI_analyzation.RobotCaseInfo    WITH NAME    RobotCaseInfo
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.power_ue_adaption    WITH NAME    power_ue_adaption
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot


*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for reserve
    ...
    ...  If raised the exception "Ueproxy service is not available on XXX.XXX.XXX.XXX":
    ...  - Check the TafUeFastmile definition in your testline configuration
    ...  - Reference configuration example:
    ...   https://wrgitlab.ext.net.nokia.com/RAN/configuration-management/testline_configuration/-/blob/master/7_5_UTE5G402T319/__init__.py
    ...  - Verify UE proxy service is running on the specified IP address
    Log    message=\nArgument cap_index=${cap_index} is not used and will be removed in the future.
    Log    Prepare UE
    ${status}    run keyword and return status    append to list    ${tl.ues[${ue_index}].capabilities}    fastmile
    ul_power_ue.Prepare UE    ue_alias=UE_${ue_index}    ue_index=${ue_index}
    # ${version}    Set Variable    ${tl.ues[${ue_index}].version.lower()}
    # ${version_status}    run keyword and return status      Should Match Regexp    ${version}    .*5gmm.*
    # run keyword if    ${version_status}    run keywords
    # ...    ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=600
    # ...    AND    Log To Console    \nreboot the Receiver 5Gmm* 'ue_index: ${ue_index}' in Prepare UE
    [Teardown]  run keyword if    ${status}    remove from list    ${tl.ues[${ue_index}].capabilities}    -1

################################## STEP1.1: Modify UE Capatibility ##################################
Modify UE Capatibility
    [Arguments]    ${ue_index}=${0}    ${mobile_network_system}=NR    ${pci}=${0}    ${arfcn}=${0}
    ...    ${band}=${None}    ${scs}=${0}
    [Documentation]    Modify UE Capatibility
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for reserve
    ...
    ...  If raised the exception "UnknownAlias":
    ...  - Check that "Prepare UE" keyword was executed successfully before this step
    ...  - Verify the UE alias UE_${ue_index} exists and was properly created
    ...  - Ensure the ue_index parameter matches the one used in Prepare UE
    Run Keyword If    '${scs}'!='${0}'    Run Keywords    ute_ue.reset_earfcn_lock    UE_${ue_index}    network_mode=${mobile_network_system}
    ...    AND    ute_ue.set_earfcn_lock    UE_${ue_index}    network_mode=${mobile_network_system}
    ...    earfcn=${arfcn}    scs=${scs}
    ...    AND    Log To Console    \nlock ue ${ue_index} to {frequency=${arfcn}, scs=${scs}kHz}
    ...    ELSE    Run Keywords    ute_ue.lock_cell    UE_${ue_index}    network_technology=${mobile_network_system}
    ...    pci=${pci}    arfcn=${arfcn}    band=${band}
    ...    AND    Log To Console    \nlock ue ${ue_index} to {pci=${pci}, arfcn=${arfcn}, band=${band}}, won't set band if band equals None

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_index}=${0}    ${log_type}=Aasyslog    ${gnb_index}=${0}    ${du_index}=0
    ...    ${pci}=${0}    ${power_reset}=${False}    ${reboot_timeout}=200    ${retry}=${2}    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for attach
    ...  :param  log_type: <String> Attach log type, Aasyslog/Iperf
    ...
    ...  If raised the exception "VerifyAttachTimeout":
    ...  - Check the UE index mapping corresponds to correct cell configuration
    ...  - Reference configuration example:
    ...    https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob/master/commissionings/HGZ/7_5_UTE5G402T319/__init__.py
    ...  - Ensure cell PCI and ARFCN parameters match between UE and gNB configuration
    ...  - Check if UE is in range and properly powered on
    ...
    ...  If raised the exception "UnknownAlias":
    ...  - Check that "Prepare UE" keyword was executed successfully before this step
    ...  - Verify the UE alias UE_${ue_index} exists and was properly created
    ...  - Ensure the ue_index parameter matches the one used in Prepare UE
    ${version}    Set Variable    ${tl.ues[${ue_index}].version.lower()}
    ${is_5gmm_version}    run keyword and return status      Should Match Regexp    ${version}    .*5gmm.*
    IF    ${is_5gmm_version}
        run keyword if    '${log_type.lower()}'=='aasyslog'    run keywords
        ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    AND
        ...    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    AND
        ...    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
        ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=${reboot_timeout}
        ${status}    run keyword and return status    Wait Until Keyword Succeeds    3x     2s    ul_power_ue.Verify Ue Attach
        ...    ue=UE_${ue_index}    pci=${pci}
        FOR    ${index}    IN RANGE    ${1}    ${retry}+1
            IF    ${status}    BREAK
            log to console    \nue attach failed, retry attach ${index} time by rebooting ue
            Modify UE Capatibility to Given Params    ue_index=${ue_index}    mobile_network_system=NR    scf_path=${Case_SCF_Path}
            ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=${reboot_timeout}
            ${status}    run keyword and return status    Wait Until Keyword Succeeds    3x    2s    ul_power_ue.Verify Ue Attach
            ...    ue=UE_${ue_index}    pci=${pci}
        END
    ELSE
        ul_power_ue.UE Detach    ue=UE_${ue_index}
        run keyword if    '${log_type.lower()}'=='aasyslog'    run keywords
        ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    AND
        ...    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    AND
        ...    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
        ul_power_ue.UE Attach    ue=UE_${ue_index}
        ${status}    run keyword and return status    Wait Until Keyword Succeeds    3x     2s    ul_power_ue.Verify Ue Attach
        ...    ue=UE_${ue_index}    pci=${pci}
        FOR    ${index}    IN RANGE    ${1}    ${retry}+1
            IF    ${status}    BREAK
            ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=${reboot_timeout}
            log to console    \nreboot ue_index ue ${ue_index} ${index} time because of attach failed
            ul_power_ue.UE Detach    ue=UE_${ue_index}
            Sleep    5s
            ul_power_ue.UE Attach    ue=UE_${ue_index}
            ${status}    run keyword and return status    Wait Until Keyword Succeeds    3x    2s    ul_power_ue.Verify Ue Attach
            ...    ue=UE_${ue_index}    pci=${pci}
        END
    END
    run keyword if    not ${status} and ${power_reset}    run keywords
    ...    ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=${reboot_timeout}    AND
    ...    log to console    \nreboot ue_index ue ${ue_index}
    should be true    ${status}    msg=ue ${ue_index} attach failed
    run keyword if    '${log_type.lower()}'=='aasyslog'
    ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    Log    Already verified inside UE Attach.

################################## STEP2.2: Create additional PDN ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${protocol}=udp    ${ue_index}=${0}    ${iperf_port}=default
    ...    ${packet}=1378    ${process_num}=1    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic. E.G 120
    ...  :param  throughput: Throughput(M) of new data transfer, Unit in Mbps
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${throughput}    convert to string    ${throughput}
    ${throughput}    Get Regexp Matches    ${throughput}    (\\d+\\.?\\d*)    1
    ${throughput}    set variable    ${throughput[0]}
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ...                                                           ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[1]}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ${iperf_options}    create dictionary    packet=${packet}    parallel_streams=${process_num}
    ul_power_ue.Start traffic    direction=${direction}    dt_name=${dt_name}    throughput=${throughput}    protocol=${protocol}
    ...    duration=${duration}    ue=UE_${ue_index}    iperf_port=${port}
    ...    iperf_options=${iperf_options}

################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${duration}=10m    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${log_dir}=${OUTPUT_DIR}
    ...            ${Teardown_after_finished}=${True}    ${check_source}=Aasyslog    ${upload_duration}=${True}
    ...            ${alias}=log_0
    ...            &{kwargs}
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.

    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour
    ...                :param  check_source: check log type, Aasyslog/Iperf
    ${unused_arguments_list}    Create List    gnb_index=${gnb_index}   du_index=${du_index}   type=${type}   filter=${filter}
    ...    ue_alias=${ue_alias}   log_dir=${log_dir}   Teardown_after_finished=${Teardown_after_finished}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${duration}    DateTime.Convert Time    ${duration}
    ${omit}    DateTime.Convert Time    ${ignore_time}
    ${end}    DateTime.Add Time to Time    ${duration}    ${omit}
    ${log_details}    run keyword if    '${check_source.lower()}'=='aasyslog'    ul_power_ue.collect syslog for throughput
    ...    omit=${omit}    end=${end}    alias=${alias}    gnb_index=${gnb_index}
    ...    ELSE    sleep    ${end}
    ${log_path}    set variable if    '${check_source.lower()}'=='aasyslog'    ${log_details["log_path"][0]}    ${None}
    set test variable    ${omit}
    set test variable    ${end}
    run keyword if    '${upload_duration}'=='${True}'    run keyword and ignore error
    ...               RobotCaseInfo.add_throughput_duration     duration=${duration}
    ...                                                         ignore_time=${ignore_time}
    [Return]  ${log_path}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${target_throughput}    ${cells}=${1}    ${log}=none
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=Aasyslog    ${ue_index}=${0}
    ...            ${cell_indiv_tput}=${None}   ${actImgGeneration}=${True}    ${upload_tp}=${True}
    ...            ${omit_time}=10    ${end_time}=0    ${alias}=log_0    &{kwargs}
    [Documentation]   Check throughput from started traffic.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  target_throughput (M): theory target throughput. Unit in Mbps
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param  target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ${unused_arguments_list}    Create List    log=${log}   cell_indiv_tput=${cell_indiv_tput}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${omit_status}    run keyword and return status    variable should exist    ${omit}
    ${omit_time}    set variable if    ${omit_status}    ${omit}    ${omit_time}
    ${tput_result}    run keyword if    '${check_source.lower()}'=='aasyslog'
    ...                                                  power_ue_adaption.check_unidirectional_throughput_from_syslog
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  direction=${direction}
    ...                                                  theoretical_throughput=${target_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  cells=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...                                                  upload_tp=${upload_tp}
    ...    ELSE
    ...                                                  power_ue_adaption.check_unidirectional_tput
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  dt_name=${dt_name}
    ...                                                  direction=${direction}
    ...                                                  theoretical_throughput=${target_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  omit=${omit_time}
    ...                                                  end=${end_time}
    ...                                                  cells=${cells}
    ...                                                  upload_tp=${upload_tp}
    [Return]  ${tput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}=none    ${cells}=${1}    ${ultarget_throughput}=5    ${dltarget_throughput}=5
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${actImgGeneration}=${True}    ${upload_tp}=${True}
    ...            ${ue_index}=${0}    ${alias}=log_0    &{kwargs}
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
    ${unused_arguments_list}    Create List    log=${log}   ue_index=${ue_index}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${tput_result}    create list
    ${dl_tput_result}    run keyword and continue on failure
    ...                                                  power_ue_adaption.check_unidirectional_throughput_from_syslog
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  direction=dl
    ...                                                  theoretical_throughput=${dltarget_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  cells=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...                                                  upload_tp=${upload_tp}
    ${ul_tput_result}    run keyword and continue on failure
    ...                                                  power_ue_adaption.check_unidirectional_throughput_from_syslog
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  direction=ul
    ...                                                  theoretical_throughput=${ultarget_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  cells=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...                                                  upload_tp=${upload_tp}
    append to list    ${tput_result}    ${ul_tput_result}
    append to list    ${tput_result}    ${dl_tput_result}
    [Return]  ${tput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    &{kwargs}
    [Documentation]    stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ul_power_ue.Stop traffic    dt_name=${dt_name}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}=${0}   ${power_reset}=False     &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for traffic
    ...
    ...  If raised the exception "UnknownAlias":
    ...  - Check that "Prepare UE" keyword was executed successfully before this step
    ...  - Verify the UE alias UE_${ue_index} exists and was properly created
    ...  - Ensure the ue_index parameter matches the one used in Prepare UE
    run keyword if    '${power_reset}'=='True'    run keywords
    ...    ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=600    AND
    ...    log to console    \nreboot ue_index ue ${ue_index}
    ul_power_ue.UE Detach    ue=UE_${ue_index}
