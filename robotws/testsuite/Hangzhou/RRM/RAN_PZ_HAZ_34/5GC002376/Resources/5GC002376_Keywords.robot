*** Settings ***
Documentation
...   This is for 2376 TA common keywords
...   squad group: MMW_SG1
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com

Library      OperatingSystem
Library      Collections
Library      taf.stc.config
Library      String
Library      BuiltIn
Library      taf.config.scf    WITH NAME    scf
Library      taf.transport.ssh    WITH NAME    csn
Library      taf.transport.ssh                 WITH NAME       ssh
Library      taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library      taf.gnb.oam.megazone_client       WITH NAME       megazone_client
Library      taf.gnb.oam.commissioning   WITH NAME    comissioning
Library    taf.analyzer.pcap     WITH NAME    cap
Resource     ./5GC002376_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
#Resource     resources/common/cloudbts_nsa.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
#Resource    ./../../../../../resources/sites/Hangzhou/PROD/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
#Resource    resources/common/asod.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot
Library    taf.analyzer.pcap    WITH NAME    pcap
Library      ./verify_values_in_list_are_different.py
Library      ArchiveLibrary
Library      ./2376_create_ciphering.py
Library     ./scf_operation.py
Variables    ./../TestData/2376_modify_nidd.py


*** Keywords ***
ENB CU and DU commission and wait until cell on air
    [Documentation]    author: Liu Zheng
    ${SCF_DEFAULT_FILE_PATH_CU}    Get SCF template path for CU
    Set suite variable    ${SCF_DEFAULT_FILE_PATH_CU}
    Commission on LTE    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}    is_called_in_test_case_level=${False}
    CU Full Commission  path_of_commission_file=${SCF_DEFAULT_FILE_PATH_CU}
    DU Commission with scf file    scf_file_path=${DU_SCF_DEFAULT_FILE_PATH}    is_pdl_checking_needed=${false}
    Cloud DU connect to gnb coam via ssl
    Wait until ASOD cells are on air status
    Wait until keyword succeeds    10 min    10 s     CU Verify All Cells Status Are Onair

Analysis wireshark log for sgnb message and get SgNBSecurityKey
    [Documentation]    author: Liu Zheng
    [Arguments]    ${pcap_file}    ${ciphering}    ${tshark_path}=/usr/bin/tshark    ${luashark_path}=${None}
    ...    ${x2ap.X2AP_PDU_ack}=1    ${x2ap.X2AP_PDU_req}=0    ${x2ap.X2AP_PDU_rel}=1    ${is_check_ue_detach_info_needed}=${False}
    ${command_template}    set variable     {tshark_path} -r {pcap_file} -Y \"x2ap\" -T pdml
    Check sgNBAdditionRequestAcknowledge info    pcap_file=${pcap_file}    command_template=${command_template}
    ...    x2ap.X2AP_PDU_ack=${x2ap.X2AP_PDU_ack}    ciphering=${ciphering}    tshark_path=${tshark_path}    luashark_path=${luashark_path}
    ${SgNBSecurityKey_list}    Check sgNBAdditionRequest info    pcap_file=${pcap_file}    command_template=${command_template}
    ...    x2ap.X2AP_PDU_req=${x2ap.X2AP_PDU_req}
    ...    tshark_path=${tshark_path}    luashark_path=${luashark_path}
    Run keyword if    ${is_check_ue_detach_info_needed}==${True}    Check SgNBReleaseRequestAcknowledge info    pcap_file=${pcap_file}
    ...    command_template=${command_template}    x2ap.X2AP_PDU_rel=${x2ap.X2AP_PDU_rel}
    ...    tshark_path=${tshark_path}    luashark_path=${luashark_path}
    [Return]    ${SgNBSecurityKey_list}

Check sgNBAdditionRequestAcknowledge info
    [Documentation]    author: Liu Zheng
    ...    by the x2ap.X2AP_PDU and x2ap.procedureCode value to confirm which info need to be checked.
    ...    for example 2ap.X2AP_PDU=1 and x2ap.procedureCode=27,  info 'sgNBAdditionRequestAcknowledge, RRC Reconfiguration' need be checked
    [Arguments]    ${pcap_file}    ${command_template}    ${x2ap.X2AP_PDU_ack}    ${ciphering}    ${tshark_path}==/usr/bin/tshark
    ...    ${luashark_path}=${None}
    ${CP_X2sgnback_ciphering} =    Catenate    x2ap.X2AP_PDU == ${x2ap.X2AP_PDU_ack} and x2ap.procedureCode == 27
    ...                and nr-rrc.cipheringAlgorithm == ${ciphering}
    ${filtered_packets_ack}    Load pcap with filter
    ...    pcap_file=${pcap_file}   tshark_path=${tshark_path}
    ...   luashark_path=${luashark_path}    command_template=${command_template}    filter_expression=${CP_X2sgnback_ciphering}
    @{filed_name_list_ack}    create list    x2ap.X2AP_PDU    x2ap.procedureCode    nr-rrc.cipheringAlgorithm
    ${fields_value_ack}    get and verify fields value    filtered_packets=${filtered_packets_ack}    field_name_list=${filed_name_list_ack}

Check sgNBAdditionRequest info
    [Documentation]    author: Liu Zheng
    ...    by the x2ap.X2AP_PDU and x2ap.procedureCode value to confirm which info need to be checked.
    ...    for example 2ap.X2AP_PDU=0 and x2ap.procedureCode=27,  info 'sgNBAdditionRequest' need be checked
    [Arguments]    ${pcap_file}    ${command_template}    ${x2ap.X2AP_PDU_req}
    ...    ${tshark_path}==/usr/bin/tshark    ${luashark_path}=${None}
    ${CP_X2sgnbreq_ciphering} =    Catenate    x2ap.X2AP_PDU == ${x2ap.X2AP_PDU_req} and x2ap.procedureCode == 27
    ...    and x2ap.SgNBSecurityKey and x2ap.NRencryptionAlgorithms.NEA1 == 1 and x2ap.NRencryptionAlgorithms.NEA2 == 1
    ...    and x2ap.NRencryptionAlgorithms.NEA3 == 1
    ${filtered_packets_req}    Load pcap with filter
    ...    pcap_file=${pcap_file}   tshark_path=${tshark_path}
    ...   luashark_path=${luashark_path}    command_template=${command_template}    filter_expression= ${CP_X2sgnbreq_ciphering}
    @{filed_name_list_req}    create list    x2ap.X2AP_PDU    x2ap.procedureCode    x2ap.SgNBSecurityKey    x2ap.NRencryptionAlgorithms.NEA1
    ...    x2ap.NRencryptionAlgorithms.NEA2    x2ap.NRencryptionAlgorithms.NEA3
    ${fields_value_req}    get and verify fields value    filtered_packets=${filtered_packets_req}    field_name_list=${filed_name_list_req}
    ${SgNBSecurityKey_list}    set variable     ${fields_value_req.SgNBSecurityKey}
    [Return]    ${SgNBSecurityKey_list}

Check SgNBReleaseRequestAcknowledge info
    [Documentation]    author: Liu Zheng
    ...    by the x2ap.X2AP_PDU and x2ap.procedureCode value to confirm which info need to be checked.
    ...    for example 2ap.X2AP_PDU=1 and x2ap.procedureCode=31,  info 'SgNBReleaseRequestAcknowledge' need be checked
    [Arguments]    ${pcap_file}    ${command_template}    ${x2ap.X2AP_PDU_rel}=1
    ...    ${tshark_path}==/usr/bin/tshark    ${luashark_path}=${None}
    ${CP_X2sgnbrel_ciphering} =    Catenate    x2ap.X2AP_PDU == ${x2ap.X2AP_PDU_rel} and x2ap.procedureCode == 31
    ${filtered_packets_rel}    Load pcap with filter
    ...    pcap_file=${pcap_file}   tshark_path=${tshark_path}
    ...   luashark_path=${luashark_path}    command_template=${command_template}    filter_expression=${CP_X2sgnbrel_ciphering}
    @{filed_name_list_rel}    create list    x2ap.X2AP_PDU    x2ap.procedureCode
    ${fields_value_rel}    get and verify fields value    filtered_packets=${filtered_packets_rel}    field_name_list=${filed_name_list_rel}

get and verify fields value
    [Documentation]    author: Liu Zheng
    [Arguments]    ${filtered_packets}    ${field_name_list}
    &{dict_field}    Create dictionary
    FOR    ${field_name}    IN    @{field_name_list}
        ${value}    Get field value    packets=${filtered_packets}    field_name=${field_name}    attribute_name=show
        should not be empty    ${value}
        ${field_name_remove_x2ap}    Fetch from right    ${field_name}    .
        set to dictionary    ${dict_field}    ${field_name_remove_x2ap}=${value}
    END
    [Return]    ${dict_field}

UE attach and verify ciphering algorithm and security key
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ciphering}    ${x2_log_name}=X2_tcpdump    ${x2ap.X2AP_PDU_ack}=1    ${x2ap.X2AP_PDU_req}=0
    Start X2 log capture from eNB    log_name=${x2_log_name}    interface=br1
    UE attach and verify with soft reboot if needed
    ${pcap_log}    Stop X2 log capture from eNB    log_name=${x2_log_name}
    Analysis wireshark log for sgnb message and get SgNBSecurityKey     pcap_file=${pcap_log}    ciphering=${ciphering}
    ...    x2ap.X2AP_PDU_ack=${x2ap.X2AP_PDU_ack}    x2ap.X2AP_PDU_req=${x2ap.X2AP_PDU_req}

UE attach and detach and verify ciphering algorithm and security key
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ciphering}    ${x2_log_name}=X2_tcpdump    ${x2ap.X2AP_PDU_ack}=1    ${x2ap.X2AP_PDU_req}=0    ${x2ap.X2AP_PDU_rel}=1
    Start X2 log capture from eNB    log_name=${x2_log_name}    interface=br1
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}
    run keyword and continue on failure    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}
    sleep    5s
    wait until keyword succeeds    3x     30s    UE detach should be successed
    sleep    5s
    ${pcap_log}    Stop X2 log capture from eNB    log_name=${x2_log_name}
    ${SgNBSecurityKey_list}    Analysis wireshark log for sgnb message and get SgNBSecurityKey     pcap_file=${pcap_log}    ciphering=${ciphering}
    ...    x2ap.X2AP_PDU_ack=${x2ap.X2AP_PDU_ack}    x2ap.X2AP_PDU_req=${x2ap.X2AP_PDU_req}    x2ap.X2AP_PDU_rel=${x2ap.X2AP_PDU_rel}
    ...    is_check_ue_detach_info_needed=${True}
    [Return]    ${SgNBSecurityKey_list}

Commercial UE soft reboot
    [Documentation]  Actions for commercial UE reboot request needed.
    [Arguments]  ${ue_index}=${0}   ${detach_request}=${true}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    run keyword and ignore error    Check UE device exist    ${ue_index}
    Restart adb server and wait until status ready    ue_index=${ue_index}   serial_number=${serial_number}
    ADB reboot ue    ue_index=${ue_index}   serial_number=${serial_number}
    Log to console    wait for adb startup
    BuiltIn.sleep    30s
    Run Keyword If   ${detach_request}   wait until keyword succeeds    5min    10s    UE detach should be successed    ${ue_index}

Successive SgNB Addition and Release for many times
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ciphering}    ${attach_loop_times}=${10}
    ...    ${x2_log_name_loop}=x2_tcpdump_loop    ${x2_loop_name_each}=x2_tcpdump
    ...        ${x2ap.X2AP_PDU_ack}=1    ${x2ap.X2AP_PDU_req}=0
    run keyword and ignore error    wait until keyword succeeds    3x     30s    UE detach should be successed
    ${SgNBSecurityKey_list_all}    create list
    FOR    ${each_time}    IN RANGE    ${attach_loop_times}
        ${SgNBSecurityKey_list}    run keyword and continue on failure    UE attach and detach and verify ciphering algorithm and security key
        ...    ciphering=${ciphering}    x2_log_name=${x2_loop_name_each}_${each_time}
        ${SgNBSecurityKey_list_all}    combine lists    ${SgNBSecurityKey_list_all}    ${SgNBSecurityKey_list}
    END
    verify_values_in_list_are_different    input_list=${SgNBSecurityKey_list_all}

Get all cryptos status and Check the cpu status for DLUL Ciphering
    [Documentation]    author: Liu Zheng
    [Arguments]    ${dpm_path}=/opt/nokia/tools/SS_RCPDPM/tools/dpm_diag_cli cpustats
    Connect to OAM    alias=OAM
    Connect to UPUE    alias=UPUE    proxy=OAM
    ssh.sendCommand
    ...    command=sudo ${dpm_path} -P all | grep L2PdcpULCryptoQ*| head -24|tail -6|awk '{print $3}'| cut -d',' -f2
    ...    connection=UPUE
    sleep    8s
    ${cpu_ULstatus} =    ssh.read_output    connection=UPUE
    ssh.sendCommand
    ...    command=sudo ${dpm_path} -P all | grep L2PdcpDLCryptoQ*| head -24|tail -6|awk '{print $3}'| cut -d',' -f2
    ...    connection=UPUE
    sleep    8s
    ${cpu_DLstatus} =    ssh.read_output    connection=UPUE
    ssh.disconnect     connection=UPUE
    ssh.disconnect     connection=OAM
    ${cpu_ULstatus}    convert to string    ${cpu_ULstatus.strip()}
    @{UL_cpus}=    Split String    ${cpu_ULstatus}    \n
    ${cpu_DLstatus}    convert to string    ${cpu_DLstatus.strip()}
    @{DL_cpus}=    Split String    ${cpu_DLstatus}    \n
    Caculate cpu with ciphering is running    cpus_status=${UL_cpus}
    Caculate cpu with ciphering is running    cpus_status=${DL_cpus}

Caculate cpu with ciphering is running
    [Documentation]    author: Liu Zheng
    [Arguments]    ${cpus_status}
    ${cry_ready}    Set variable    ${0}
    FOR    ${cpu}    IN    @{cpus_status}
        ${cpu}    convert to number    ${cpu}
        ${cry_status}    run keyword and return status    should be true    ${cpu}>0
        Exit for loop if    ${cry_status}==${True}
        ${cry_ready}    Evaluate    ${cry_ready}+1
    END
    Should be true    ${cry_ready} < 6    msg=All L2Pdcp cpu for cry not running

Get the bearer group on CU UPUP VM
    [Documentation]    download the /tmp/LINUX_startup.log from UPUE on CU to ${TS_CASE_LOG_PATH}. get the bearer group number.
    ...    For example:
    ...    If the bearer is setup with Bearer group 0, you will see the logs like this in syslog:
    ...    e4 VM-E100 LINUX-DispP3 <2020-08-01T08:56:11.144552Z> E38 INF/L2HiCu, g0r000u0000ucp0000h04/DlDrb.cpp:1357/DL-PDCP bIdx:0, st,1,
    ...    algoStateF1,0, algoStateX2,0, bSize:0, In:870 B/s, Out:870 B/s, OutF1:870 B/s, discard:0, DisPkt:0, tranF1,3891, delvF1, 3891,
    ...    prevF1,4294967295
    ...    g0r000u0000ucp0000h04
    ...    g0 -> Bearer group 0
    ...    This bearer will use L2pdcpDLCryptoQ0 and L2pdcpULCryptoQ0 for any algorithm AES/Snow3G/ZUC.
    ...    If the bearer is setup with Bearer group 2, you will see the logs like this in syslog:
    ...    e4 VM-E100 LINUX-DispP3 ... INF/L2HiCu, g2r001u0000ucp0000h04/DlDrb.cpp:1357/DL-PDCP
    ...    g2r001u0000ucp0000h04
    ...    g2 -> Bearer group 2
    ...    This bearer will use L2pdcpDLCryptoQ2 and L2pdcpULCryptoQ2 for any algorithm AES/Snow3G/ZUC.
    Connect to OAM    alias=OAM
    Connect to UPUE    alias=UPUE    proxy=OAM
    Verify syslog exist on CU UPUE VM

    ${rc}    ${bearer}    Run and return rc and output
    ...    cat ${log_path}/LINUX_startup.log |grep -i l2hicu |grep -i drb |grep -i bear |awk '{print $7}' | tail -10
    ${rc}    ${bearer_number}    Run and return rc and output
    ...    cat ${log_path}/LINUX_startup.log |grep -i l2hicu |grep -i drb |grep -i bear |awk '{print $7}' | tail -1 |cut -c 2
    ${bearer_number}    set variable    ${bearer_number.strip()}

    ssh.disconnect     connection=UPUE
    ssh.disconnect     connection=OAM
    [Return]    ${bearer_number}

Verify syslog exist on CU UPUE VM
    [Documentation]    author: Liu Zheng
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}
    ssh.sendCommand
    ...    command=ls /tmp |grep -i LINUX_startup
    ...    connection=UPUE
    sleep    8s
    ${upue_syslog} =    ssh.read_output    connection=UPUE
    ${upue_syslog}    set variable    ${upue_syslog.strip()}
    @{upue_syslog_list}=    Split String    ${upue_syslog}    \n
    should not be empty    ${upue_syslog_list}    msg=No LINUX_startup.zip or LINUX_startup.log found under UPUE tmp folder

    ssh.sendCommand
    ...    command=sudo cp -f /tmp/LINUX_startup* /home/robot/
    ...    connection=UPUE
    sleep    8s
    ssh.sendCommand
    ...    command=ls /home/robot |grep -i LINUX_startup
    ...    connection=UPUE
    sleep    8s
    ${upue_linux_startup_log} =    ssh.read_output    connection=UPUE
    ${list_log_path_local}    create list
    FOR  ${log_name}  IN    @{upue_syslog_list}
        Wait Until Keyword Succeeds     2 min    5 sec     csn.Download file
        ...                                                remote_path=/home/robot/${log_name}
        ...                                                local_path=${log_path}/${log_name}
        ...                                                connection=UPUE
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END

    FOR  ${local_log}  IN    @{list_log_path_local}
        run keyword if   'LINUX_startup.log' not in '${local_log}' and 'LINUX_startup.zip' in '${local_log}'
        ...    Extract zip file    ${local_log}      ${log_path}
    END
    OperatingSystem.File should exist    ${log_path}/LINUX_startup.log
    [Teardown]    run keyword and ignore error    ssh.sendCommand    command=rm -rf /home/robot/LINUX_startup*    connection=UPUE

Check CPU status for specific l2pdcp crypto
    [Arguments]    ${cryptoq_number}
    ${ul_crypto_name}    set variable    L2PdcpULCryptoQ${cryptoq_number}
    ${dl_crypto_name}    set variable    L2PdcpDLCryptoQ${cryptoq_number}
    Connect to OAM    alias=OAM
    Connect to UPUE    alias=UPUE    proxy=OAM
    ${command_ul_crypto}    catenate    sudo /opt/nokia/tools/SS_RCPDPM/tools/dpm_diag_cli cpustats -P all |
    ...    grep L2PdcpULCryptoQ*| head -24|grep ${ul_crypto_name} |awk '{print $3}' | cut -d',' -f2
    ${command_dl_crypto}    catenate    sudo /opt/nokia/tools/SS_RCPDPM/tools/dpm_diag_cli cpustats -P all |
    ...    grep L2PdcpDLCryptoQ*| head -24|grep ${dl_crypto_name} |awk '{print $3}' | cut -d',' -f2
    ssh.sendCommand    command=${command_ul_crypto}    connection=UPUE
    sleep    8s
    ${spec_cpu_ul_status} =    ssh.read_output    connection=UPUE
    ssh.sendCommand    command=${command_dl_crypto}    connection=UPUE
    sleep    8s
    ${spec_cpu_dl_status} =    ssh.read_output    connection=UPUE
    ssh.disconnect     connection=UPUE
    ssh.disconnect     connection=OAM
    ${spec_cpu_ul_status}    convert to string    ${spec_cpu_ul_status.strip()}
    @{spec_UL_cpus}=    Split String    ${spec_cpu_ul_status}    \n
    ${spec_cpu_dl_status}    convert to string    ${spec_cpu_dl_status.strip()}
    @{spec_DL_cpus}=    Split String    ${spec_cpu_dl_status}    \n
    CPU for specific l2pdcp crypto should not be zero    cpus_status=${spec_UL_cpus}
    CPU for specific l2pdcp crypto should not be zero    cpus_status=${spec_DL_cpus}

CPU for specific l2pdcp crypto should not be zero
    [Documentation]    author: Liu Zheng
    [Arguments]    ${cpus_status}
    ${cry_ready}    Set variable    ${0}
    FOR    ${cpu}    IN    @{cpus_status}
        ${cpu}    convert to number    ${cpu}
        ${cry_status}    run keyword and return status    should be true    ${cpu}>0
        ${cry_ready}    run keyword if    ${cry_status}==${False}    evaluate    ${cry_ready}+1    ELSE    set variable    ${cry_ready}
    END
    Should be true    ${cry_ready} < 1    msg=All L2Pdcp cpu for cry not running

Get specific crypto status and Check the cpu status for DLUL Ciphering
    [Documentation]    author: Liu Zheng
    ${cryptoq_number}    Get the bearer group on CU UPUP VM
    Check CPU status for specific l2pdcp crypto    cryptoq_number=${cryptoq_number}

Check cpu status for DLUL Ciphering
    [Documentation]    author: Liu Zheng
    Get all cryptos status and Check the cpu status for DLUL Ciphering
    Get specific crypto status and Check the cpu status for DLUL Ciphering

Update nullFallback parameter and NEA Ciphering value
    [Documentation]    Update nullFallback parameter if needed and update NEA Ciphering value
    [Arguments]    ${nea0_value}    ${nea1_value}    ${nea2_value}    ${nea3_value}
    check nullfallback and updated if needed
    Change the NEA Ciphering online    nea0_value=${nea0_value}    nea1_value=${nea1_value}    nea2_value=${nea2_value}    nea3_value=${nea3_value}

check nullfallback and updated if needed
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}    check nullfallback and updated if needed on CU
    ...    ELSE   update nullfallback parameter

update nullfallback parameter
    [Arguments]    ${nullfallback_value}=true
    &{nullfallback_para}    create dictionary     dist_name=NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=nullFallback    value=${nullfallback_value}
    @{modify_nullfallback}    Evaluate    [&{nullfallback_para}]
    ${update_status}    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${modify_nullfallback}    timeout=${TIMEOUT_MODIFY_PARA}    connection=${GNB_COAM_ALIAS}
    Run keyword and continue on failure    Should be equal as strings    ${update_status}    PASS

check nullfallback and updated if needed on CU
    [Arguments]    ${scf_file_path}=${SCF_DEFAULT_FILE_PATH_CU}
    ${local_log_file_folder}    set variable    ${TS_CASE_LOG_PATH}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${local_log_file_folder}
    ${nullfallback_value}    get nullFallback parameter value from scf    scf_file_path=${default_scf_file_path}
    run keyword if    '${nullfallback_value}' != 'true'     CU Delta Commission update    parameters=${NULLFALLBACK_VALUE}
    ...    cu_ip=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ...    cu_username=${tl.gnbs[${0}].cu.oam_http_connection_details.username}
    ...    cu_password=${tl.gnbs[${0}].cu.oam_http_connection_details.password}

Change the NEA Ciphering online
    [Arguments]    ${nea0_value}    ${nea1_value}    ${nea2_value}    ${nea3_value}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}    Change the NEA Ciphering online on CU
    ...    nea0_value=${nea0_value}    nea1_value=${nea1_value}    nea2_value=${nea2_value}    nea3_value=${nea3_value}
    ...    ELSE    Change the NEA Ciphering online on classicalBTS
    ...    nea0_value=${nea0_value}    nea1_value=${nea1_value}    nea2_value=${nea2_value}    nea3_value=${nea3_value}

Change the NEA Ciphering online on classicalBTS
    [Arguments]    ${nea0_value}    ${nea1_value}    ${nea2_value}    ${nea3_value}
    &{cipherprefl_dict}    Create Dictionary    nea0=${nea0_value}    nea1_128=${nea1_value}    nea2_128=${nea2_value}    nea3_128=${nea3_value}
    @{cipherprefl_list}    Evaluate    [&{cipherprefl_dict}]
    &{cipherperfl_para}    create dictionary     dist_name=NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=cipherPrefL    value=${cipherprefl_list}
    @{modify_cipherprefl}    Evaluate    [&{cipherperfl_para}]
    ${update_status}    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${modify_cipherprefl}    timeout=${TIMEOUT_MODIFY_PARA}    connection=${GNB_COAM_ALIAS}
    Run keyword and continue on failure    Should be equal as strings    ${update_status}    PASS

Change the NEA Ciphering online on CU
    [Documentation]    author: Liu Zheng
    ...    update ciphering values.
    ...    'MRBTS-247/NRBTS-1':{'cipherPrefL': [{'nea0': '1',
    ...    'nea1_128': '3',
    ...    'nea2_128': '4',
    ...    'nea3_128': '2'}]}
    ...    }
    [Arguments]    ${nea0_value}    ${nea1_value}    ${nea2_value}    ${nea3_value}
    ${para_dict}   get_parameters_of_current_plan    parameter_name=cipherPrefL    cu_ip=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ${ciphering_dict_on_cu}    get_ciphering_value_of_current_plan    para_dict=${para_dict}
    ${do_delta_commission_condition}    Catenate    ${nea0_value}==${ciphering_dict_on_cu['nea0']}
    ...    and ${nea1_value}==${ciphering_dict_on_cu['nea1_128']}
    ...    and ${nea2_value}==${ciphering_dict_on_cu['nea2_128']}
    ...    and ${nea3_value}==${ciphering_dict_on_cu['nea3_128']}
    run keyword and continue on failure    run keyword if  not ${do_delta_commission_condition}    update ciphering value by delta commission
    ...    nea0_value=${nea0_value}    nea1_value=${nea1_value}    nea2_value=${nea2_value}    nea3_value=${nea3_value}

update ciphering value by delta commission
    [Documentation]    author: Liu Zheng
    ...    update ciphering values.
    ...    'MRBTS-247/NRBTS-1':{'cipherPrefL': [{'nea0': '1',
    ...    'nea1_128': '3',
    ...    'nea2_128': '4',
    ...    'nea3_128': '2'}]}
    ...    }
    [Arguments]    ${nea0_value}    ${nea1_value}    ${nea2_value}    ${nea3_value}
    ${ciphering_value}    create_ciphering_data    nea0_value=${nea0_value}    nea1_value=${nea1_value}
    ...    nea2_value=${nea2_value}    nea3_value=${nea3_value}
    CU Delta Commission update    parameters=${ciphering_value}    cu_ip=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ...    cu_username=${tl.gnbs[${0}].cu.oam_http_connection_details.username}
    ...    cu_password=${tl.gnbs[${0}].cu.oam_http_connection_details.password}


get nullFallback parameter value from scf
    [Documentation]    author: Liu Zheng
    [Arguments]    ${dist_name_nullfallback}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...   ${scf_file_path}=${CU_SCF_DEFAULT_FILE_PATH}
    &{para}    Create Dictionary    dist_name=${dist_name_nullfallback}    p_name=nullFallback
    @{scf_parameters_list}     Evaluate    [&{para}]
    ${value_from_scf}    get values from scf file    scf_local_path=${scf_file_path}    parameters_list=@{scf_parameters_list}
    ${nullfallback_value}    set variable    ${value_from_scf[0]['value']}
    [Return]    ${nullfallback_value}

UE attach and verify with soft reboot if needed
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ue_index}=${0}
    ${attach_status}    run keyword and return status    ue attach and verify
    run keyword if    ${attach_status}==${False} and '${UE_TYPE}'!='qct_dx50'    run keywords
    ...    run keyword and ignore error   Commercial UE soft reboot    AND
    ...    Wait until keyword succeeds    2X    10 s    Check UE device exist    AND
    ...    ue attach and verify
    run keyword if    ${attach_status}==${False} and '${UE_TYPE}'=='qct_dx50'    run keywords
    ...    wait until keyword succeeds    5min    10s    UE detach should be successed    ${ue_index}    AND
    ...    ue attach and verify

Get average tput from GNB within duration
    [Documentation]  Author: Liu Zheng
    ...    Check tput for period and user can define the duration for checking in each time,
    ...    ${total_time}: is the duration time in which the throughput need to be checked. The time unit is second.
    [Arguments]    ${duration_time}=30s    ${nr_cell_index}=1
    ...    ${gnb_ssl_connection}=GNB_OAM    ${alias}=ASOD     ${du_index}=0
    Wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master    alias=${alias}
    &{dict_tput_info}    Run keyword and continue on failure    Get tput info from GNB    duration=${duration_time}
    ...    nr_cell_index=${nr_cell_index}    gnb_ssl_connection=${gnb_ssl_connection}    asik_alias=${alias}    du_index=${du_index}
    Log to console    tput info: ${dict_tput_info}
    [Return]    ${dict_tput_info}

Update NEA ciphering to none ciphering and return the average throughput
    [Documentation]    ${ul_throughput} and ${dl_throughput} are used for start traffic.
    ...    ${ul_throughput} and ${dl_throughput} unit can be G,M,K and Mbit/sec and lower cases unit.
    ...    for the testline which can receive same throughput as send, then the traffic check standard can be higher.
    ...    if only need check there is throughput, then the traffic standard can be lower such as larger than ${1}.
    [Arguments]    ${nea0_value}=5    ${nea1_value}=0    ${nea2_value}=0    ${nea3_value}=0
    ...    ${duration_time}=${30}    ${nr_cell_index}=1
    ...    ${gnb_ssl_connection}=GNB_OAM    ${alias}=ASOD     ${du_index}=0
    ...    ${dl_throughput}=${DL_THROUGHPUT}    ${ul_throughput}=${UL_THROUGHPUT}
    ...    ${tput_percentage}=${EXP_AVG_TPUT_PERCENTAGE}    ${if_use_default_value_1}=${True}
    ${ul_tp_value}    Get tp value from input throughput    tput=${ul_throughput}
    ${dl_tp_value}    Get tp value from input throughput    tput=${dl_throughput}
    ${ul_tput_exp_tmp}    Evaluate    ${ul_tp_value}*${tput_percentage}
    ${dl_tput_exp_tmp}    Evaluate    ${dl_tp_value}*${tput_percentage}
    ${ul_tput_exp}    Set variable if    ${if_use_default_value_1}    ${1}    ${ul_tput_exp_tmp}
    ${dl_tput_exp}    Set variable if    ${if_use_default_value_1}    ${1}    ${dl_tput_exp_tmp}
    Update nullFallback parameter and NEA Ciphering value
    ...    nea0_value=${nea0_value}    nea1_value=${nea1_value}    nea2_value=${nea2_value}    nea3_value=${nea3_value}
    ${traffic_time}    Evaluate    ${duration_time}*20
    UE attach and verify with soft reboot if needed
    Start data transfer based on direction    dl_tput=${dl_throughput}   ul_tput=${ul_throughput}   duration=${traffic_time}
    ...    data_transfer_direction=both
    sleep    90s
    ${dict_tput_info}    Get average tput from GNB within duration    duration_time=${duration_time}    nr_cell_index=${nr_cell_index}
    ...    gnb_ssl_connection=${gnb_ssl_connection}    alias=${alias}     du_index=${du_index}
    Run Keyword And Ignore Error   wait until keyword succeeds    3x   10s   Stop data transfer based on direction    data_transfer_direction=both
    wait until keyword succeeds    3x     30s    UE detach should be successed
    log to console     average throughput is ul:${dict_tput_info['ul_tput_avg']}   dl:${dict_tput_info['dl_tput_avg']}
    run keyword and continue on failure    should be true    ${dict_tput_info['dl_tput_avg']} > ${dl_tput_exp}
    run keyword and continue on failure    should be true    ${dict_tput_info['ul_tput_avg']} > ${ul_tput_exp}
    [Return]    ${dict_tput_info}

Update NEA ciphering check throughput ciphering and SgNBSecurityKey
    [Arguments]    ${nea0_value}=0    ${nea1_value}=7    ${nea2_value}=3    ${nea3_value}=0
    ...    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${verify_duration}=${30}    ${ciphering}=1
    ...    ${is_cpu_check_needed}=${False}
    ...    ${ignore_time}=1min    ${data_transfer_direction}=both    ${traffic_duration}=3000s
    ...    ${seg_size}=1350    ${iperf_ul_port}=${None}    ${iperf_dl_port}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M
    ...    ${ue_type}=${UE_TYPE}    ${retry_time}=3    ${ue_index}=${0}    ${prepare_ue_needed}=${False}
    ...    ${detach_request}=${False}    ${connection}=GNB_OAM    ${is_ue_reboot}=${False}

    Update nullFallback parameter and NEA Ciphering value
    ...    nea0_value=${nea0_value}    nea1_value=${nea1_value}    nea2_value=${nea2_value}    nea3_value=${nea3_value}
    Start X2 log capture from eNB    log_name=X2_tcpdump
#    ${status}    Run keyword and return status    Call case with UE and verify throughput
#    ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
#    ...    duration_time=${duration_time}    interval_time=${interval_time}    verify_duration=${verify_duration}
#    ...    is_cpu_check_needed=${is_cpu_check_needed}

    ${status}    Run keyword and return status    L3 call check tput via power UE
    ...    dl_tput=${DL_THROUGHPUT}    ul_tput=${UL_THROUGHPUT}
    ...    exp_ul=${ul_exp_tput}    exp_dl=${dl_exp_tput}    tput_check_duration=${verify_duration}
    ...    ignore_time=${ignore_time}    actCarrierAggregation=${False}    data_transfer_direction=${data_transfer_direction}
    ...    traffic_duration=${traffic_duration}    protocol=udp    seg_size=${seg_size}
    ...    iperf_ul_port=${iperf_ul_port}    iperf_dl_port=${iperf_dl_port}    buffer_size=${buffer_size}
    ...    iperf_type_ul=${iperf_type_ul}    window=${window}
    ...    ue_type=${ue_type}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}
    ...    detach_request=${detach_request}    connection=${connection}    is_ue_reboot=${is_ue_reboot}

    run keyword and continue on failure     Run keyword if    ${is_cpu_check_needed}
    ...    Wait until keyword succeeds    1min    20s    Check cpu status for DLUL Ciphering
    Run Keyword And Ignore Error   wait until keyword succeeds    3x   10s   Stop data transfer based on direction    data_transfer_direction=both
    wait until keyword succeeds    3x     30s    UE detach should be successed
    log to console     Tput check for this time finished!
    Run keyword and continue on failure    Should be true    '${status}' == '${True}'
    ${pcap_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump
    Analysis wireshark log for sgnb message and get SgNBSecurityKey    pcap_file=${pcap_log}    ciphering=${ciphering}
    ...    is_check_ue_detach_info_needed=${True}

Get tp value from input throughput
    [Arguments]    ${tput}
    ${tput}    convert_to_uppercase    ${tput}
    ${tput_value}    run keyword if    'M' in '${tput}'    Fetch From Left    ${tput}    M
    ...    ELSE IF    'K' in '${tput}'    Fetch From Left    ${tput}    K
    ...    ELSE IF    'G' in '${tput}'    Fetch From Left    ${tput}    G
    ...    ELSE IF    'MBITS/SEC' in '${tput}'    Fetch From Left    ${tput}    MBITS
    ...    ELSE    Set variable    ${tput}
    [Return]    ${tput_value}
