*** Settings ***
Documentation     author: yulu
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.analyzer.pcap        WITH NAME    pcap
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/py_script.py
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008744/Resources/read_pdml.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Variables         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008744/Resources/8744_TLConfigration.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot



*** Variables ***
${scf_path_22R2}       /home/ute/Downloads/SCF/22R2
${scf_path_22R3}       /home/ute/Downloads/SCF/22R3
${scf_path_22R4}       /home/ute/Downloads/SCF/22R4
${scf_path_23R1}       /home/ute/Downloads/SCF/23R1
${filter_expression_ue}      !f1ap.initiatingMessage_element
${srs_msg}      \"uldata_srsreceivereq\"
${pusch_msg}      \"uldata_puschreceivereq\"
${tshark_path}    /usr/bin/tshark
${srsBmEnable_filed_name}    UlData_srsReceiveReqSubcell_t.srsBmEnable
${maxNumberSRS-Ports-PerResource}      nr-rrc.maxNumberSRS_Ports_PerResource
${nrofSRS-Ports}            nr-rrc.nrofSRS_Ports
${patternIdMin_value}      UlData_eCpriConfigStruct_t.patternId_item

*** Keywords ***
CB008744 Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${build}    '22R2'
    ...    ELSE IF    'SBTS22R3' in ${result}    set test variable    ${build}    '22R3'
    ...    ELSE IF    'SBTS22R4' in ${result}    set test variable    ${build}    '22R4'
    ...    ELSE IF    'SBTS23R1' in ${result}    set test variable    ${build}    '23R1'
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${scf_path}    ${scf_path_22R2}
    ...    ELSE IF    'SBTS22R3' in ${result}    set test variable    ${scf_path}    ${scf_path_22R3}
    ...    ELSE IF    'SBTS22R4' in ${result}    set test variable    ${scf_path}    ${scf_path_22R4}
    ...    ELSE IF    'SBTS23R1' in ${result}    set test variable    ${scf_path}    ${scf_path_23R1}
    robot_common_operations.Common Case Setup

CB008744 Case Teardown
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

Load Case SCF and Commission SCF
    [Arguments]    ${default_scf}
    COAM Commission with scf file    scf_file_path=${default_scf}
    COAM Wait for gnb ready and cell setup    timeout=15 min

MultiUE check tput and check ue attach log
    log to console      "UE_attach"
    power_ue.Prepare UE    ue_type=sigspark_multiUE    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
    Start capture UE attach log      filename=UE_attach_CPIFLOG.pcap
    power_ue.UE Attach     ue_type=sigspark_multiUE
    sleep    5s
    stop and download UE attach log      filename=UE_attach_CPIFLOG.pcap
    power_ue.Start traffic    ue_type=sigspark_multiUE    direction=dl
    power_ue.Start traffic    ue_type=sigspark_multiUE    direction=ul
    sleep    3s
    Common Capture BIP log and download
    log to console      "UE_check_Tput"
    Run Keyword And Ignore Error    power_ue.Check Bi Tput    ue_type=sigspark_multiUE
    power_ue.Stop traffic     ue_type=sigspark_multiUE    direction=dl
    power_ue.Stop traffic     ue_type=sigspark_multiUE    direction=ul
    power_ue.UE Detach        ue_type=sigspark_multiUE
    Check ue attach Log by Luashark       filename=UE_attach_CPIFLOG.pcap

Check CRPT file
    ${xz_file}    Download File From ASIB for 8744   log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
	Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
	Run    ${unxz_command}
	Check item on crpt file for 8744    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=-138    check_item="gainCorrection":(\\S\\d*)
	Check item on crpt file for 8744    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=true    check_item="pSRSact":(\\w{4,10})
	Check item on crpt file for 8744    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=86    check_item="occasionDelay":(\\d{1,10})
	Check item on crpt file for 8744    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=8    check_item="ruNumOfTrxInRow":(\\d)
	${status}    Run keyword and return status    Check item on crpt file for 8744
    ...    file_path=${log_path}/runtime_cp_rt.log    check_value=4    check_item="ruNumOfTrxInColumn":(\\d)
    Run keyword if    '${status}'=='False'    Check item on crpt file for 8744
    ...    file_path=${log_path}/runtime_cp_rt.log    check_value=2    check_item="ruNumOfTrxInColumn":(\\d)
	Check item on crpt file for 8744    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=NUMBEROFCOLTRX_8    check_item="numberOfColTRX":"(\\w{8,20})

Download snapfile and Check CRPT file
    ${snap_path}    COAM Save snapshot via rest api
    should not be empty    ${snap_path} 
    run    unzip -o ${snap_path} -d ${log_path}
    ${zip_name}    search_list_from_snap    file_name=${log_path}/snapshot_file_list.txt    cprt_name=BTS17_1515_runtime.zip
    should not be empty    ${zip_name}
    run    unzip -o ${log_path}/${zip_name} -d ${log_path}
    run    unzip -o ${log_path}/BTS17_1515_runtime.zip -d ${log_path}
    run    unxz -f ${log_path}/runtime_cp_rt.log.xz
    Check item on crpt file for 8744    file_path=${log_path}/runtime_cp_rt.log
	...    check_value=-138    check_item="gainCorrection":(\\S\\d*)
	Check item on crpt file for 8744    file_path=${log_path}/runtime_cp_rt.log
	...    check_value=true    check_item="pSRSact":(\\w{4,10})
	Check item on crpt file for 8744    file_path=${log_path}/runtime_cp_rt.log
	...    check_value=86    check_item="occasionDelay":(\\d{1,10})
	Check item on crpt file for 8744    file_path=${log_path}/runtime_cp_rt.log
	...    check_value=8    check_item="ruNumOfTrxInRow":(\\d)
	${status}    Run keyword and return status    Check item on crpt file for 8744
    ...    file_path=${log_path}/runtime_cp_rt.log    check_value=4    check_item="ruNumOfTrxInColumn":(\\d)
    Run keyword if    '${status}'=='False'    Check item on crpt file for 8744
    ...    file_path=${log_path}/runtime_cp_rt.log    check_value=2    check_item="ruNumOfTrxInColumn":(\\d)
	Check item on crpt file for 8744    file_path=${log_path}/runtime_cp_rt.log
	...    check_value=NUMBEROFCOLTRX_8    check_item="numberOfColTRX":"(\\w{8,20})
    [Teardown]    run    rm -r ${log_path}/*

Download File From ASIB for 8744
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    Connect to Common Unit Master
	@{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folde
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}

Check item on crpt file for 8744
    [Arguments]    ${check_value}    ${check_item}    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	${output}    get_value_from_log_file    file_path=${file_path}    check_item=${check_item}
	Should Contain    ${output}    ${check_value}

Start capture UE attach log
    [Arguments]   ${filename}
    ssh.Connect To   hostname=10.57.223.233
    ...              username=toor4nsn
    ...              password=oZPS0POrRieRtu
    ...              alias=GNB_OAM
    ssh.send command    command=lxc-attach -n 0x1514    connection=GNB_OAM
    sleep   3s
    csn.send command    command=tcpdump -i any -w /tmp/${filename}    connection=GNB_OAM
    sleep   3s

stop and download UE attach log
    [Arguments]     ${filename}
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=GNB_OAM
    ssh.send command     command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=GNB_OAM
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${TS_CASE_LOG_PATH}/${filename}   connection=GNB_OAM
    sleep    2s
    ssh.execute    command=sudo rm /tmp/${filename}    connection=GNB_OAM
    ssh.disconnect    connection=GNB_OAM

Check ue attach Log by Luashark
    [Arguments]    ${filename}
    Load BIP with Luashark for 8744    bip_file=${TS_CASE_LOG_PATH}/${filename}
    ...    command_template={tshark_path} -r ${TS_CASE_LOG_PATH}/${filename} -T pdml
    Filter Packets By Expression       filter_expression=${filter_expression_ue}
    ${maxNumberSRS-Ports-PerResource_list}    Get value from Bip Log    field_name=${maxNumberSRS-Ports-PerResource}
    ${nrofSRS-Ports_list}     Get value from Bip Log      field_name=${nrofSRS-Ports}
    Should Contain    ${maxNumberSRS-Ports-PerResource_list}      1

Check L2L1 BIp Log by Luashark
    [Arguments]     ${bip_log}    ${alias}=CB8744
    ${packets_srs}    Load BIP with Luashark for 8744    bip_file=${bip_log}
    ...    command_template={tshark_path} -r ${bip_log} -Y ${srs_msg} -T pdml
    ...    alias=srs_8744
    ${srsBmEnable_value_list}    pcap.get_field_value_by_name    pdml_list=${packets_srs}
    ...      field_name=${srsBmEnable_filed_name}
    ...      pcap_parser=srs_8744
    Should Contain       ${srsBmEnable_value_list}    1
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_log}
	...    tshark_path=${tshark_path}
    ...    command_template={tshark_path} -r ${bip_log} -Y 'uldata_puschreceivereq' -T pdml
    ...    alias=${alias}
    ${values}    Get value from Bip Log    field_name=${patternIdMin_value}    pcap_parser=${alias}
    Should Be True    ${values}[0] > 1024 or ${values}[1] > 1024 or ${values}[2] > 1024

Check L2L1 Bip log
    Check L2L1 BIp Log by Luashark    bip_log=${bip_log_path}

Load BIP with Luashark for 8744
    [Arguments]     ${bip_file}      ${command_template}     ${alias}=${None}
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template=${command_template}
    ...                                 alias=${alias}
    [Return]   ${packets}
