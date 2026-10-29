***Settings***
Documentation
...     [Maintenance]        "TRS ET Bangalore Team"
...     [Procedure]          "The test case is planned to validate Linux File Permissions"
...     [Funtion_Hash_Tags]  "Linux_Hardening_on_RAU_and_RAC"
...     [QC_Path]            "QC_ID in Test Lab for reporting"
...     [QC_ID]              "QC_ID in Test Lab for reporting"
...     [Feature_ID]         "5GC000269"
...     [Requirement ID]     "WBTS_SEC_51946, WBTS_SEC_49140, WBTS_SEC_52641, WBTS_SEC_52642, WBTS_SEC_53359"
...     [Validated_TestLine] "2690"
...     [Config]             "IPv4 configuration."
...	    [Runtime param]	     "bts_id 2690 is provided at run time."


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keyword_SR001003.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${profile}            LTE10762_10op_basic

***Test cases***
[1][2.0] TRS_Delta_changes_of_M_Plane_Parameters_SR001003
    Perform Commissioning       scf_file=${Base_scf}    verify_bts_status=False     timeout=300
    Sleep   600
    Perform Recommissioning     type=delta        delta_file=${mplane_dscp_delta}
    ${enb_mPlane_ip} =  Get Parameter       param_path=${mplane_ip_moc_path}
    Set Suite Variable  ${enb_mPlane_ip}    ${enb_mPlane_ip}
    ${enb_mplane_dscp} =     Get Parameter       param_path=${mplane_dscp_moc_path}
    Set Suite Variable  ${enb_mplane_dscp}  ${enb_mplane_dscp}
    Traffic Capture Start   capture_device=bts     alias=default
    Sleep   60
    Setup Oamops    dut=bts12   alias=mplane1
    Sleep   10
    Teardown Oamops     dut=bts12   alias=mplane1
    ${filename_A}=  Traffic Capture Stop    capture_device=bts    alias=default
    Set Suite Variable  ${filename_A}   ${filename_A}
    VerifyMplaneDSCP    ${filename_A}
    Get IPv4 Address
    Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
    Traffic capture start           capture_device=vm_eth3_interface        alias=operator1
    Attach LTE UE with operator and send ul dl traffic      1      ${profile}   1
    Stop traffic and detach LTE UE          1      ${profile}
    ${pcap_file}=       Traffic capture stop      alias=operator1
    ${mme_ip}=     Get from List        ${MME_IP_List}     0
    ${sgw_ip}=     Get from List        ${SGW_IP_List}     0
    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}   0
    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}   0
    Get IP Version      ${mme_ip}
    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}      filter_file_name=${traffic_filter_file_name}
    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}      filter_file_name=${traffic_filter_file_name}
    [TEARDOWN]      Keyword to Run at end
***Keywords***

Get IPv4 Address
    Get MME IP Address
    Get LTE-C IP Address    ipV4
    Get LTE-U IP Address    ipV4
    Get SGW IP Address

Get SGW IP Address
	[Arguments]          ${operator}=1
	FOR   ${index}   IN RANGE   0    ${operator}
	     ${gtpu_dict}=     Query Admin Infomodel    query=get object ${gtpu_path}
	     ${sgw_list}=      Get From Dictionary       ${gtpu_dict}     sgwIpAddressList
	     ${sgw_dict}=      Get From List      ${sgw_list}            ${index}
	     ${sgw_ip}=       Get From Dictionary     ${sgw_dict}        sgwIpAddress
	     Append to List     ${SGW_IP_List}      ${sgw_ip}
	END

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate

VerifyMplaneDSCP
    [Arguments]     ${filename}
    Analyse Pcap    pcap_filename=${filename}  analysis=verify_mplane_dscp    filter_file_name=${traffic_capture_1}


Check the shadow file Permission
#/etc/shadow shall be owned by user root with group root and the file permissions shall be set to 600
    Execute command on gNB   ls -lrt /etc/shadow
    Should Match Regexp     '${stdout}'     (?im)\\-rw\\-\\-\\-\\-\\-.*shadow

Check the file Permission
#$file shall be owned by user root with group root and the file permissions shall be set to 644
     :FOR    ${file}    IN    @{files_list}
    \    Execute command on gNB    ls -lrt ${file}
    \    Should Match Regexp     '${stdout}'     (?im)\\-rw\\-r\\-\\-r\\-\\-.*${file}

Check the nologin permission
     :FOR    ${account}    IN    @{account_list}
    \    Execute command on gNB    cat /etc/passwd | grep ${account}
    \    Should contain     '${stdout}'     /sbin/nologin

Check temporary accounts to have non zero GID
    Execute command on gNB    ps -elf|egrep -v 'root|GID'|cut -d ' ' -f 3 | uniq
    Should not Be Empty     ${stdout}
    @{user_list} =    Split String      ${stdout}
    Execute command on gNB  cat /etc/passwd | uniq
	Should not Be Empty     ${stdout}

    :FOR    ${user}    IN    @{user_list}
    \    ${username}=    Run    echo ${user} | cut -c 1-7
    \    Should not Contain     ${stdout}       ${username}:x:0:0:

Check no dot is present in PATH
    Execute command on gNB   echo $PATH
    Should not Be Empty     ${stdout}
    Should not Contain  ${stdout}   ${dot}

Check file and process permissions
    check process    ps -elf | grep btssw | grep -v grep | cut -d ' ' -f 7

check process
    [Arguments]    ${cmd}
    Execute command on gNB    ${cmd}
    Should not Be Empty     ${stdout}
    @{process_list} =    Split String      ${stdout}

    :FOR    ${process}    IN    @{process_list}
    \    Execute command on gNB    ls -l /proc/${process}/fd | grep -v null | grep / | cut -d ' ' -f 11
    \    @{files_list} =    Split To Lines      ${stdout}
    \    check files    @{files_list}

check files
    [Arguments]    @{files_list}
    :FOR    ${file}    IN    @{files_list}
    \    Execute command on gNB    ls -la ${file} | cut -d ' ' -f 3
    \    ${status}       Should Not Contain    ${stdout}      No such file or directory
    \    Run Keyword If    '${stdout}'=='True'    Should Be Equal    '${stdout}'   'btssw'

Check process running as non root
     :FOR    ${process}    IN    @{process_name_list}
    \    Execute command on gNB    ps -elf|egrep ${process}|egrep -v 'bash|grep'|cut -d ' ' -f 3
    \    Should Be Equal    '${stdout}'   'btssw'
    \    Execute command on gNB     id -g ${stdout}
    \    Should Be Equal    ${stdout}  800
    \    Execute command on gNB    ps -elf|egrep ${process}|egrep -v 'bash|grep'|cut -d ' ' -f 3
    \    Execute command on gNB     id -u ${stdout}
    \    Should Be Equal    ${stdout}  800

Check encrypted file system for crypto agent
	check process_crypto    df -T /ffs/run/trs_data/active/keystorage/ | grep -v Filesystem |cut -d ' ' -f 1
	check process_crypto    df -T /ffs/run/trs_data/active/keystorage/cmpdb/ | grep -v Filesystem |cut -d ' ' -f 1
	check process_crypto    df -T /ffs/run/trs_data/active/keystorage/certs/ | grep -v Filesystem |cut -d ' ' -f 1

check process_crypto
    [Arguments]    ${cmd}
    Execute command on gNB    ${cmd}
    Should not Be Empty     ${stdout}
    @{user_list} =    Split String      ${stdout}

    :FOR    ${user}    IN    @{user_list}
    \    Should Be Equal    '${user}'   'encfs'