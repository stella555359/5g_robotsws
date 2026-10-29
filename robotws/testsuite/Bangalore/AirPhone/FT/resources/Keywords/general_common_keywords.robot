*** Settings ***
Documentation       :copyright    : Nokia
...                 :author    : Vadivelan Manickavasagam
...                 :contact    : vadivlean.manickavasagam@nokia.com
...                 :Description    : This file contains general common keywords
...                 Any changes review needed before commit

Library             OperatingSystem
Library             Telnet
Library             BIP_Capture.py
Library             taf.transport.ssh    WITH NAME    csn
Library             String
Library             taf.ul.gnb.bip.collection    WITH NAME    bip_collection
Library             taf.ul.ue.sim.env_setup
Library             taf.sbts.oam.coam.admin    WITH NAME    COAM
Library             ta5g_pm_counters
# Library    ute_wtssim
Resource            Capture.robot
Resource            ./ap_gnb_tti_Keywords.robot
Resource            ./common_resource.robot
Resource            ./5G_SW_Keywords.robot
Resource            ./sosreport_utility.robot
Resource            ./gnbbip_convert.robot
Resource            ./swconfig_keywords.robot
Library             ../Python/ScfVlanUpdater.py    WITH NAME    scf_update


*** Variables ***
${GNB_IP}       192.168.255.129

${ECPRI72E}     Ecpri72eULDL
${BETAEC}       13
${XEC}          14


*** Keywords ***
Configure Routes in WTS
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3

Start UTE WTS
    [Arguments]    ${lua_cfg}    ${dir}    ${edaemon_port}    ${egate_port}    ${gnb_dep_mode}
    Configure Routes in WTS
    ute_wtssim.Setup Edaemon    edaemon_port=${edaemon_port}    tool_dir=${dir}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${egate_port}    tool_dir=${dir}
    ute_wtssim.Start Egate Process
    IF    '${gnb_dep_mode}'=='SA'
        ute_wtssim.Execute Egate Command    cmd=cfg file=${lua_cfg}    pass_regexp=SCTP proxy link
    END
    IF    '${gnb_dep_mode}'=='NSA' or '${gnb_dep_mode}'=='SANSA'
        ute_wtssim.Execute Egate Command
        ...    cmd=cfg file=${lua_cfg}
        ...    pass_regexp=(SimMode is ready now|UEC-1 is active)
    END
    ute_wtssim.execute_egate_command    cmd=ue_disp id=1
    Sleep    45
    ute_wtssim.execute_egate_command    cmd=${CM_SET_LOG_FLUSH}

Get cell On Air
    [Arguments]    ${iphy}=none    ${scf_delta}=none    ${cfg}='none'    ${bsr}=none
    ...    ${vendor_update}=none    ${wts_dir}=/opt/wts/latest/    ${edaemon_port}=22222
    ...    ${egate_port}=20000    ${gnb_dep_mode}=SA
    IF    '${bsr}' != 'none'    Get and Update BSR File    ${bsr}
    Update Iphy Configuration And Modify Swconfig
    ...    iphy_xml_filepath=${iphy}
    ${extension}    Evaluate    os.path.splitext("${scf_delta}")[1]    os
    IF    '${vendor_update}' == 'yes'
        Download and Update 72e Vendor File with scf commisioning
        ...    test_log_directory=/home/ute/logs/vendor
        ...    scf_delta=${scf_delta}
        ...    extension=${extension}
    END
    IF    '${vendor_update}' == 'none'
        Run Keyword If
        ...    '${extension}' == '.xml'
        ...    Find Scfc And Fix And Send Full Commissioning
        ...    scfc_filename=${scf_delta}
    ELSE IF    '${extension}' == '.json'
        Find Scfc and Send Delta Commissioning    scfc_filename=${scf_delta}
    END
    Sleep    5
    Check Radios Availability
    Sleep    10

    Start UTE WTS    lua_cfg=${cfg}    dir=${wts_dir}    edaemon_port=${edaemon_port}    egate_port=${egate_port}
    ...    gnb_dep_mode=${gnb_dep_mode}

Get and Update BSR File
    [Arguments]    ${bsr_file_path}="none"
    COAM.setup admin
    ${ret}    COAM.Update Software    ${bsr_file_path}
    COAM.teardown admin

Download and Update 72e Vendor File with scf commisioning
    [Arguments]    ${vendor_path}="none"    ${test_log_directory}=/home/ute/logs/vendor
    ...    ${scf_delta}="none"    ${extension}="none"
    COAM.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory}/vendor_ini.xml
    COAM.Download Vendor File    ${vendor_path}
    Modify Vendor betaec XML File    ${vendor_path}
    Modify Vendor xec XML File    ${vendor_path}
#    Modify Vendor 72e XML File    ${vendor_path}
    COAM.Set Vendor File    ${vendor_path}
    Log to console    ${extension}
    Log to console    ${scf_delta}
    IF    '${extension}' == '.xml'
        scf_update.Update Scf With Tl Info    ${scf_delta}
    END
    IF    '${extension}' == '.json'
        COAM.perform_delta_recommissioning
        ...    delta_file=${scf_delta}
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True
        ...    timeout=300
    END

    IF    '${extension}' == '.xml'
        COAM.Perform Commissioning
        ...    bts_id=${GNB_IP}
        ...    scf_file=${scf_delta}
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True
        ...    timeout=300
    END
    COAM.teardown admin

Modify Vendor 72e XML File
    [Arguments]    ${vendor_path}
    ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}

Modify Vendor betaec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}

Modify Vendor xec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}

Check gnbTTI
    [Arguments]    ${logfile_with_path}="none"    ${filter}="none"    ${element}="none"    ${value}="none"
    Validate GNB TTI    ${tti_pcap_path}=${logfile_with_path}
    ...    ${validation_ini_path}=${element}
    Log to console    "checking gnbTTI ${filter} ${value} "

Check apTTI
    [Arguments]    ${logfile_with_path}="none"    ${filter}="none"    ${element}="none"    ${value}="none"
    Log to console    "checking apTTI"
    Log to console    ${logfile_with_path}    ${filter}
    Log to console    ${element}    ${value}

Check apBIP
    [Arguments]    ${logfile_with_path}="none"    ${filter}="none"    ${element}="none"    ${value}="none"
    Log to console    "checking apBIP"
    Log to console    ${logfile_with_path}    ${filter}
    Log to console    ${element}    ${value}

Check gnbBIP
    [Arguments]    ${logfile_with_path}="none"    ${filter}="none"    ${element}="none"    ${value}="none"
    Log to console    "checking gnbBIP"
    Log to console    ${logfile_with_path}    ${filter}
    Log to console    ${element}    ${value}

Check Pattern In Log
    [Documentation]    This keyword checks if the ${pattern} is present in the log
    ...                If special characters are inlcuded in search element to be with special characters
    ...                value to be without special characters
    [Arguments]    ${logfile_with_path}=none    ${filter}=none    ${element}=none    ${value}=none
    ${value}    set variable if    '${value}'=='none'    ${element}    ${value}
    Log to console    element print : ${element}
    ${grepArgs}    Set Variable    grep -i
    ${command}    Catenate    ${grepArgs} '${element}' ${logfile_with_path}
    Log to console    command print : ${command}
    ${result}    Run    ${command}
    Log to console    print result string:    ${result}
    Log    ${result}
    Log to console    ${filter}    ${value}
#    Should Contain    """${result}"""    ${element}    ignore_case=${TRUE}
    Should Contain    ${result}    ${value}    ignore_case=${TRUE}

# Check Pattern In Log
#    [Arguments]    ${logfile_with_path}=none    ${filter}=none    ${element}=none    ${value}=none
#    [Documentation]    This keyword checks if the ${pattern} is present in the log
#    ${grepArgs}    Set Variable    grep -i
#    ${command}    Catenate    ${grepArgs} '${element}' ${logfile_with_path}
#    ${result}    Run    ${command}
#    Log    ${result}
#    Log to console    ${filter}    ${value}
#    Should Contain    """${result}"""    ${element}    ignore_case=${TRUE}

Validate
    [Arguments]
    ...    ${log}="none"
    ...    ${filter}="none"
    ...    ${element}="none"
    ...    ${value}="none"
    ...    ${logfile_with_path}="none"
    IF    '${log}' == '${L_EGATE_CONSOLE}'
        Check Pattern In Log    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_TTI}'
        check gnbTTI    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_BIP}'
        check gnbBIP    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_SYS}'
        Check Pattern In Log    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_L3}'
        Validate PCAP With Fields    ${logfile_with_path}    ${filter}    ${element}
    END
    IF    '${log}' == '${L_WTS_L3}'
        Validate PCAP With Fields    ${logfile_with_path}    ${filter}    ${element}
    END
#    \    Run Keyword If    '${log}' == '${L_EGEN}'    Start eGen Logs
#    \    Run Keyword If    '${log}' == '${L_EMIL}'    Start EMIL Logs
#    \    Run Keyword If    '${log}' == '${L_GNB_BIP}'    Start gnbBIP Logs
#    \    Run Keyword If    '${log}' == '${L_AP_BIP}'    Start apBIP Logs

Validate L2 Data Throughput
    [Arguments]    ${ue_id}    ${expected}    ${direction}    ${cell_id}
    Log to console    To be written for l2 data tput validation
    Log to console    ${ue_id}    ${expected}
    Log to console    ${direction}    ${cell_id}

Start Logs
    [Arguments]    ${in_logs}
    @{logs}    Split String    ${in_logs}
#    :FOR    ${log}    IN    @{logs}
    FOR    ${log}    IN    @{logs}
        IF    '${log}' == '${L_GNB_TTI}'    start gNB tti stream
        IF    '${log}' == '${L_AP_TTI}'    Start apTTI Logs
        IF    '${log}' == '${L_AP_GNB_SYS}'    Start AP and GNB sys logs
        IF    '${log}' == '${L_EGEN}'    Start eGen Logs
        IF    '${log}' == '${L_EMIL}'    Start EMIL Logs
        IF    '${log}' == '${L_GNB_BIP}'    Start gnbBIP Logs
        IF    '${log}' == '${L_AP_BIP}'    Start apBIP Logs
        IF    '${log}' == '${L_GNB_L3}'    Start gnbL3 Logs
        IF    '${log}' == '${L_WTS_L3}'    Start WTSL3 Logs
    END

Stop Logs
    [Arguments]    ${in_logs}
    @{logs}    Split String    ${in_logs}
#    :FOR    ${log}    IN    @{Logs}
    FOR    ${log}    IN    @{logs}
        IF    '${log}' == '${L_GNB_TTI}'    stop gNB tti stream
        IF    '${log}' == '${L_AP_TTI}'    Stop apTTI Logs
        IF    '${log}' == '${L_AP_GNB_SYS}'    Stop AP and GNB sys logs
#    \    Run Keyword If    '${log}' == '${L_EGEN}'    Stop eGen Logs
#    \    Run Keyword If    '${log}' == '${L_EMIL}'    Stop EMIL Logs
        IF    '${log}' == '${L_GNB_BIP}'    Stop gnbBIP Logs
#    \    Run Keyword If    '${log}' == '${L_AP_BIP}'    Stop apBIP Logs
        IF    '${log}' == '${L_GNB_L3}'    Stop gnbL3 Logs
        IF    '${log}' == '${L_WTS_L3}'    Stop WTSL3 Logs
    END

Start apTTI Logs
    AP Activate TTI Trace Streaming
    AP Trigger TTI traces

Start gnbBIP Logs
    Log to console    gnbBIP logs started\n
    Start BIP capture taf

Start apBIP Logs
    Log to console    "apBIP logs started - yet to plug the function"

Start eGen Logs
    Log to console    "eGen logs started - yet to plug the function"

Start EMIL Logs
    Log to console    "EMIL logs started - yet to plug the function"

Start gnbL3 Logs
    Start Pcap Collection In gNB    name=gnbl3

Start WTSL3 Logs
    Start Tcpdump On WTS    name=wts

Stop gnbL3 Logs
    Stop Pcap Collection In gNB    name=gnbl3    Log_Path=/home/ute/logs/

Stop gnbBIP Logs
    Log to console    gnbBIP logs being stopped\n
    Stop BIP capture taf

Stop WTSL3 Logs
    Stop Tcpdump On WTS    name=wts    Log_Path=/home/ute/logs/

Stop apTTI Logs
    AP Deactivate TTI Streaming
    AP Stop and Copy TTI Traces

Collect And Validate
    [Arguments]
    ...    ${log}="none"
    ...    ${filter}="none"
    ...    ${element}="none"
    ...    ${value}="none"
    ...    ${logfile_with_path}="none"
    IF    '${log}' == '${L_EGATE_CONSOLE}'
        Check Pattern In Log    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_TTI}'
        Collect And Check gnbTTI    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_BIP}'
        Collect And Check gnbBIP    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_AP_BIP}'
        Collect And Check apBIP    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_GNB_SYS}'
        Collect And Check gnbSys    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_AP_SYS}'
        Collect And Check apSys    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END
    IF    '${log}' == '${L_AP_TTI}'
        Collect And Check apTTI    ${logfile_with_path}    ${filter}    ${element}    ${value}
    END

Collect And Check gnbTTI
    [Arguments]    ${logfile_with_path}=none    ${filter}=none    ${element}=none    ${value}=none
    Log to console    "collect and validate gnbTTI"
    Log to console    ${logfile_with_path}    ${filter}
    Log to console    ${element}    ${value}

Collect And Check apTTI
    [Arguments]    ${logfile_with_path}=none    ${filter}=none    ${element}=none    ${value}=none
    Log to console    "collect and validate apTTI"
    Log to console    ${logfile_with_path}    ${filter}
    Log to console    ${element}    ${value}

Collect and check apSys
    [Arguments]    ${logfile_with_path}=none    ${filter}=none    ${element}=none    ${value}=none
    Log to console    "collect and validate apSys"
    Check Pattern In Log    ${logfile_with_path}
    ...    ${filter}    ${element}    ${value}

Collect and check gnbSys
    [Arguments]    ${logfile_with_path}=none    ${filter}=none    ${element}=none    ${value}=none
    Log to console    "collect and validate gnbSys"
    Check Pattern In Log    ${logfile_with_path}
    ...    ${filter}    ${element}    ${value}

Collect And Check gnbBIP
    [Arguments]    ${log}=/home/ute/logs/gnbBIP/    ${filter}=none    ${element}=none    ${value}=none
    Log to console    Collect bip and validate for gNB
    RUN    mkdir ${log}
#    RUN    cd ${log}
    RUN    scp toor4nsn@192.168.255.129:/tmp/sosReport/*.gz ${log}
    IF    '${element}'!='none'
        Validate    ${log}    ${filter}=none    ${element}=none    ${value}=none    ${log}=none
    END

Collect and check apBIP
    [Arguments]    ${log}=/home/ute/logs/apBIP/    ${filter}=none    ${element}=none    ${value}=none
    Log to console    Collect bip and validate for AP    ${log}
    RUN    mkdir ${log}
#    RUN    cd /home/ute/logs/apBIP/
    RUN    scp toor4nsn@192.168.200.1:/tmp/sosReport/*.gz ${log}
    IF    '${element}'!='none'
        Validate    ${gnbTTI}    ${filter}    ${element}    ${value}    ${log}
    END

Exe egate cmd
    [Arguments]    ${cmd}    ${return_output}=True
    IF    '${return_output}'=='True'
        Execute egate command and wait for data    cmd=${cmd}    timeout=30s    return_output=${return_output}
    END
    IF    '${return_output}'=='False'    Execute Egate Command    cmd=${cmd}
    Sleep    2
    Execute Egate Command    cmd=${CM_SET_LOG_FLUSH}
    Sleep    2
    Execute Egate Command    cmd=${CM_SET_LOG_FLUSH}

old version Exe egate cmd
    [Arguments]    ${cmd}
#    Execute Egate Command    cmd=${cmd}
    Execute egate command and wait for data    cmd=${cmd}    timeout=30s    return_output=True
    Sleep    2
    Execute egate command and wait for data    cmd=${CM_SET_LOG_FLUSH}    timeout=30s    return_output=True
#    Execute Egate Command    cmd=${CM_SET_LOG_FLUSH}
    Sleep    2
    Execute Egate Command    cmd=${CM_SET_LOG_FLUSH}

Start Pcap Collection In gNB
    [Arguments]    ${name}=gnbTcpdump    ${options}=-f sctp -i any -s0 -p    ${gnb_id}=0
    ${executor_oam_vm}    Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...    name=${name}
    ...    options=${options}
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}

Stop Pcap Collection In gNB
    [Arguments]    ${name}    ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}    set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]    ${pcap_file_path}

Start Tcpdump On WTS
    [Arguments]    ${name}
    ${command}    Set Variable    sudo tcpdump -i any -w ${name}.pcap > /dev/null 2>&1 &
    Run Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    [Return]    ${name}.pcap

Stop Tcpdump On WTS
    [Arguments]    ${name}    ${Log_Path}
    ${command}    Set Variable    sudo pkill tcpdump
    Run Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    Run    cp ${name}.pcap ${Log_Path}/${name}.pcap
    [Return]    ${name}.pcap

Validate PCAP With Fields
    [Arguments]    ${pcap_file_path}    ${filter}    ${field}
    ${rc}    ${tshark_output}    Run And Return Rc And Output
    ...    tshark -Y "${filter}" -T fields -e ${field} -r ${pcap_file_path}
    [Return]    ${tshark_output}

Validate PCAP
    [Arguments]    ${pcap_file_path}    ${filter}
    ${rc}    ${tshark_output}    Run And Return Rc And Output    tshark -Y "${filter}" -r ${pcap_file_path}
    [Return]    ${tshark_output}

Create IPHY Dir
    Run    rm -rf /opt/iphy/
    Run    mkdir -p /opt/iphy/
    Run    cd /opt/iphy/
    Run Process    ln    -s    /opt/wts/latest    /opt/iphy/

Cleanup Process After TC
    Upload Swconifg File to AP And Perform Signature    /home/ute/logs/swconfig_ap.txt
    Upload Swconifg File to GNB And Perform Signature    /home/ute/logs/swconfig_gnb.txt
    Run    sudo sudo df -hk
    Run    sudo sudo pkill edaemon
    Run    sudo pkill egate
    Run    ps -elf | grep -i edaemon
    Run    ps -elf | grep -i egate
#    Run    rm /home/ute/logs/default_syslog_iphyNone.log
#    Run    rm /home/ute/logs/default_syslog_enbNone.log

Clean up Preparation before TC
    Download SWConfig File From AP    sw_config_path=/home/ute/logs
    Download SWConfig File From GNB    sw_config_path=/home/ute/logs
    Run    mkdir -p /home/ute/logs/gNBbip/
    Run    mkdir -p /home/ute/logs/APbip/
    Run    mkdir -p /home/ute/logs/gNBtti/
    Run    mkdir -p /home/ute/logs/APtti/
    Run
    ...    cp -p /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/resources/Python/s*ASIL.sh /opt/wts/latest/sosReport_ASIL/
    Run    chmod 777 /opt/wts/latest/sosReport_ASIL/s*ASIL.sh

Add Rad Param Or Modify AP swconfig
    [Arguments]    &{rad_list}
    ${downloaded_swconfig_path}    Download SWConfig File From AP    sw_config_path=/tmp
    set suite variable    ${downloaded_swconfig_path}
    ${updated_swconfig_path_ap}    Modify SWConfig File For AP    sw_config_filepath=${downloaded_swconfig_path}
    ...    &{rad_list}
    Upload Swconifg File to AP And Perform Signature    ${updated_swconfig_path_ap}

Add Rad Param Or Modify GNB swconfig
    [Arguments]    &{rad_list}
    ${downloaded_swconfig_path}    Download SWConfig File From GNB    sw_config_path=/tmp
    set suite variable    ${downloaded_swconfig_path}
    ${updated_swconfig_path_ap}    Modify SWConfig File For GNB    sw_config_filepath=${downloaded_swconfig_path}
    ...    &{rad_list}
    Upload Swconifg File to GNB And Perform Signature    ${updated_swconfig_path_ap}

Get Coam Active Alarms
    COAM.Connect To
    ${alarms}    COAM.Get Active Alarms
    [Teardown]    COAM.Teardown
    [Return]    ${alarms}

Collect Cfg and egate logs
    Run    mkdir /home/ute/logs/config_with_logs/
    Run    cp /opt/wts/latest/egate_console.log /home/ute/logs/config_with_logs/
    Run    scp toor4nsn@192.168.200.1:/ffs/run/swconfig.txt /home/ute/logs/config_with_logs/swconfig.txt_ap
    Run    scp toor4nsn@192.168.200.1:/rom/simmode/iphy.xml /home/ute/logs/config_with_logs/ap_iphy.xml
    Run    scp toor4nsn@192.168.255.129:/ffs/run/swconfig.txt /home/ute/logs/config_with_logs/swconfig.txt_gnb
    Run    cp /home/ute/default_*.log /home/ute/logs/config_with_logs/

Validate PM counter
    [Arguments]    ${LST_OF_PM_COUNT_DICT}    ${PM_FILE}
    Wait For Next Full Pm Interval
    Log to console    ${LST_OF_PM_COUNT_DICT}
    ${PM_FILE}    Get Latest Unpacked Full Pm Counters File
    FOR    ${PM_COUNTER_LST}    IN    @{LST_OF_PM_COUNT_DIC}
        Log to console    ${PM_COUNTER_LST}
        Verify Last Counters In File    ${PM_COUNTER_LST}[${counter_id}]
        ...    ${PM_COUNTER_LST}[${condition}]    ${PM_COUNTER_LST}
    END

Get GNB Software Version
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...    Examples:
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | 0.800 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | 0.800.779 | total sw version |
    ...    | ${SW_BRANCH} | 5G20B | the folder to stort config files for case |
    ${sw_info}    _Get Software Info
    Log    Software Version: ${sw_info}    console=${True}
    @{sw_list}    String.Split String    ${sw_info}    _
    IF    "${sw_list[0][:4]}"=="SBTS"
        _Get Software Version On Common Package    ${sw_info}
    END
#    ...    ELSE    Get Software Version On 5G Pacakge    ${sw_info}

Download Ttitrace Decode Tool
    [Documentation]     Download Ttitrace decode tool and install it.
    ...    Examples:
    ...    | Download Ttitrace Decode Tool |
    ...    | Decoder Tttirace From Pcap To Csv | pcap_path=${pacp} | output_path_with_tag=/tmp/mytag |
    [Timeout]    300
    ${decode_tool_in_file_server}    _Download Ttitrace Decode Tool From File Server
    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${decode_tool_in_file_server}
    IF    '${status}' != 'True'
        ${decode_tool}    _Download Ttitrace Decode Tool From WFT
    ELSE
        ${decode_tool}    Set Variable    ${decode_tool_in_file_server}
    END
    OperatingSystem.File Should Exist    ${decode_tool}
    OperatingSystem.Run    scp /opt/ute/python3/bin/python /opt/ute/python3/bin/python3
    ${rc}    ${output}    OperatingSystem.Run and Return RC and Output    sudo dpkg -i ${decode_tool}
    IF    '${rc}'!= '0'    Log    ${output}    WARN
    OperatingSystem.Run    rm -rf ${decode_tool}
    update numpy

_Download Ttitrace Decode Tool From File Server
    ${url}    _Get Base Downalod URL Address
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    Log    Software version total: ${sw_list[1]}
    ${sub_link}    Set Variable If
    ...    '${sw_list[1]}'=='ENB'
    ...    ${SW_VERSION_TOTAL}
    ...    '${sw_list[1]}'!='ENB'
    ...    ${SOFTWARE_INFO}
    OperatingSystem.Run    wget -P ${TEST_LOG_DIRECTORY()} -q "${url}/${SW_VERSION_TOTAL}/${sub_link}_tti-dec.deb"
    [Return]    ${TEST_LOG_DIRECTORY()}${sub_link}_tti-dec.deb

_Download Ttitrace Decode Tool From WFT
    # ${base_url}    Set Variable    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
    ${base_url}    Set Variable
    ...    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    # ${branches}    Set Variable If    '${sw_list[2]}'=='9999'    SBTS00    '${sw_list[2]}'=='0000'    ${sw_list[0]}
    ${branches}    Set Variable If    '${sw_list[2]}'=='9999'    SBTS00    '${sw_list[2]}'=='9990'    SBTS00
    ...    '${sw_list[2]}'=='0000'    ${sw_list[0]}
    ${sub_link}    Set Variable If
    ...    '${sw_list[1]}'=='ENB'
    ...    ${SW_VERSION_TOTAL}
    ...    '${sw_list[1]}'!='ENB'
    ...    ${SOFTWARE_INFO}
    OperatingSystem.Run
    ...    wget -P ${TEST_LOG_DIRECTORY()} -q "${base_url}/${branches}/${SW_VERSION_TOTAL}/${sub_link}_tti-dec.deb"
    [Return]    ${TEST_LOG_DIRECTORY()}${sub_link}_tti-dec.deb

_Get Base Downalod URL Address
    IF    "${SOFTWARE_INFO}"=="${EMPTY}"    Get GNB Software Version
    Log    Software Info: ${SOFTWARE_INFO}
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${base_url}    Set Variable If
    ...    '${sw_list[1]}'=='ENB'
    ...    ${FILES_BASE_LINK}
    ...    '${sw_list[1]}'!='ENB'
    ...    ${FILES_BASE_LINK_BRANCHES}
    Log    ${base_url}
    [Return]    ${base_url}

_Get Software Info
    [Documentation]   Get GNB Software Info
    COAM.setup admin    bts_host=192.168.255.129    alias=COAM
    ${sw_info}    COAM.Get Sw Version    connection=COAM
    Set Global Variable    ${SOFTWARE_INFO}    ${sw_info}
    Set Suite Metadata    Software Version    ${SOFTWARE_INFO}
    [Teardown]    COAM.Teardown    COAM
    [Return]    ${sw_info}

_Get Software Version On Common Package
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...    | Global variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    [Arguments]    ${software_info}
    Log    Software Version: ${software_info}
    @{sw_list}    String.Split String    ${software_info}    _
    Log to console    ${sw_list}
    # ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    ${status}    Set Variable If
    ...    '${sw_list[2]}'=='9999'
    ...    True
    ...    '${sw_list[2]}'=='9990'
    ...    True
    ...    '${sw_list[2]}'=='0000'
    ...    False
    IF    '${status}'=='True'
        Set Global Variable    ${SW_VERSION}    SBTS00
    ELSE
        Set Global Variable    ${SW_VERSION}    ${sw_list[0]}
    END
    IF    '${status}'=='True'
        Set Global Variable    ${SW_VERSION_TOTAL}    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ELSE
        Set Global Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    END
    Set Global Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}

update numpy
    ssh.Connect To    127.0.0.1    ute    ute    alias=bsh
    ssh.Execute    cd    connection=bsh
    ssh.Send Command
    ...    source /opt/tti-dec/venv/bin/activate;cd /opt/tti-dec/tti-dec-bin;pip install --upgrade 'numpy<2.0'
    ...    connection=bsh

Lock cell
    [Documentation]     This Keyword Locking the cell as per the requirement
    [Arguments]    ${lock_element}=MRBTS-1/NRBTS-1/NRCELL-1
    Log to Console    Locking the cell
    admin.Setup admin
    Online NIDD parameter change    paramName=administrativeState    paramValue=Locked
    ...    paramDst=${lock_element}
    sleep    60s
    [Teardown]    admin.Teardown admin

Unlock cell
    [Documentation]     This Keyword Unlocking the cell as per the requirement
    [Arguments]    ${unlock_element}=MRBTS-1/NRBTS-1/NRCELL-1
    Log to Console    Unlocking the cell
    admin.Setup admin
    Online NIDD parameter change    paramName=administrativeState    paramValue=Unlocked
    ...    paramDst=${unlock_element}
    sleep    60s
    [Teardown]    admin.Teardown admin

Online NIDD parameter change
    [Documentation]    This Keyword used to update NIDD parameter(one at a time)
    ...                and returns the result
    ...        [Arguments]    parameter        :  Parameter names to parsed
    ...                       paramDst         :  Dist name should be parsed
    ...                       paramValue       :  Value for the parameter to be assigned should be parsed
    ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
    ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
    ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
    [Arguments]    ${paramName}='None'    ${paramValue}='None'
    ...    ${paramDst}='None'    ${operation}=update
    ...    ${should_activate}=${True}    ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning    parameter=${paramName}
    ...    value=${paramValue}    operation=${operation}    dist_name=${paramDst}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
