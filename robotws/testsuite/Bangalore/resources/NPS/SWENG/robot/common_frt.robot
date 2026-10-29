*** Settings ***
Documentation    :copyright: Nokia

Library           OperatingSystem
Library           Collections
Library           DateTime
Library           ArchiveLibrary
Library           taf.gnb.oam.commissioning    WITH NAME    commissioning
Library           taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.gnb.entities.bb2    WITH NAME    bb2lib
#Library           taf.cloud.openstack    WITH NAME    openstack
Library           taf.config.scf    WITH NAME    scf
Library           ../python/ece_fastReg.py
Library           logging
Library           taf.pdu

*** Variables ***
#${Scf_Add_Clock_Dist_Name}    MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
${Scf_Add_PPS_Element_Name}    outputConfiguration1Pps
${Scf_Add_PPS_Element_Value}    EnabledWithBtsInputReference

*** Keywords ***
Connect to LTEEMU
    [Arguments]    ${alias}=lteemu
    csn.connect_to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...               username=${tl.core.default_ssh_connection_details.username}
    ...               password=${tl.core.default_ssh_connection_details.password}
    ...               alias=${alias}

Connect to AP BB2
    [Arguments]    ${alias}=AirphoneBB2
    csn.Connect To    hostname=${tl.ues[0].l2_ssh_connection_details.addr}
    ...               username=${tl.ues[0].l2_ssh_connection_details.username}
    ...               password=${tl.ues[0].l2_ssh_connection_details.password}
    ...               alias=${alias}

Remove Elements From Scf
    [Arguments]    ${scf_local_path}
    ${parameters_lists}=    scf_elements_remove    ${tl.scf.filename}
    Builtin.log    ${tl.scf.filename}
    scf.Load Scf    ${scf_local_path}
    FOR    ${parameters_list}    IN    @{parameters_lists}
        scf.remove_element_from_scf    &{parameters_list}
    END
    scf.Save Scf    ${scf_local_path}

Add Elements To Scf
    [Arguments]    ${scf_local_path}    ${Scf_Add_Clock_Dist_Name}
    scf.Load Scf    ${scf_local_path}
    scf.add_element_to_scf    ${Scf_Add_Clock_Dist_Name}    ${Scf_Add_PPS_Element_Name}    ${Scf_Add_PPS_Element_Value}
    scf.Save Scf    ${scf_local_path}

Add NTP to Scf
    [Arguments]    ${scf_local_path}
    &{dict}=    Create Dictionary    ntpServerIpAddr=192.168.125.1    ntpStatus=notReachable
    ${version}=    get_nidd_from_scf    ${scf_local_path}    MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    scf.Load Scf    ${scf_local_path}
    scf.Add Object To Scf
    ...    class_name=com.nokia.srbts.mnl:NTP
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1
    ...    version=${version}
    scf.Add List To Scf
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1
    ...    list_name=ntpServerList
    scf.Add Item To List
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1
    ...    list_name=ntpServerList
    ...    elements=&{dict}
    scf.Save Scf    ${scf_local_path}

Update_scf_interface_distname
    [Arguments]    ${scf_path}    ${scf_para_list}
    [Documentation]    This keyword is added Flexible SCF changes for interface distName
    ...    This keyword using in FRT.
    ...    Changes need in config file for interface ip changes.
    ...    PARAMS_TO_MODIFY_SCF = [......
    ...    dict(value='192.168.xx.xx', dist_name='CU_f1Cplane',p_name='localIpAddr'),
    ...    dict(value='192.168.xx.xx', dist_name='CU_f1Mplane',p_name='localIpAddr'),
    ...    dict(value='192.168.xx.xx', dist_name='CU_s1Cplane',p_name='localIpAddr'),
    ...    dict(value='192.168.xx.xx', dist_name='CU_s1Uplane',p_name='localIpAddr'),
    ...    ..........]
    ${updated_scf_paras}=    update_scf_parameter_of_interface    ${scf_path}    ${scf_para_list}
    ${tl.scf.scf_params}    set variable    ${updated_scf_paras}
    [Return]    ${updated_scf_paras}

Powerreset BTS
    taf.pdu.setup_pdu       host=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...     model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ...     version=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.version}
    ...     alias=BTS_PDU
    ${pdu_port_number}    Create List    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    taf.pdu.reset_ports    ports=${pdu_port_number}    time_interval=20    pdu_device=BTS_PDU

Connect to OAM via Https
    run keyword and ignore error    megazone_client.teardown_session
    megazone_client.create_session    base_url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

Verify Snapshot
    [Arguments]  ${SoftwareReleaeVersion}=5G_${version}
    extract zip file    ${snapshot_path}    ${TEMP_PATH}/Snapshot
    #check OAM logs, SCF file exist
    archive should contain file    ${snapshot_path}    OAMLogs/config/${SoftwareReleaeVersion}/SBTS_SCF.xml
    archive should contain file    ${snapshot_path}    OAMLogs/logs/RacOAM/startup_RACOAM.log
    archive should contain file    ${snapshot_path}    OAMLogs/logs/SiteOAM/startup_SITEOAM.log
    #check RAC(CU) logs, rcp alarms exist
    extract zip file    ${TEMP_PATH}/Snapshot/RAC/racoam_snapshot.zip
    ...    ${TEMP_PATH}/Snapshot/RAC/racoam_snapshot
    ${racoam_snapshot}=    set variable    ${TEMP_PATH}/Snapshot/RAC/racoam_snapshot
    archive should contain file    ${racoam_snapshot}/RAC/RACLogFiles/rcpAlarms/rcpAlarms.zip    rcpAlarmsActive.log
    archive should contain file    ${racoam_snapshot}/RAC/RACLogFiles/rcpAlarms/rcpAlarms.zip    rcpAlarmsHistory.log
    #check site logs, such as HW and SW infos, exist
    archive should contain file    ${snapshot_path}    SITE/siteReport.html

Assert fault are presents
    [Arguments]  ${present_faults}  ${unwanted_faults}
    FOR  ${f}  IN    @{present_faults}
        ${txt}=  Get from dictionary  ${f}  additionalText1
        @{words}=  Split String  ${txt}
        ${fault_no}=  get from list  ${words}  0
        ${status}=     run keyword and return status  list should not contain value  ${unwanted_faults}    ${fault_no}
        run keyword if  ${status}  fail  msg=Faults are present.
    END

Assert fault is not present
    [Arguments]  ${present_faults}  ${checked_fault}
    FOR  ${f}  IN    @{present_faults}
        ${txt}=  Get from dictionary  ${f}  additionalText1
        @{words}=  Split String  ${txt}
        ${fault_no}=  get from list  ${words}  0
        ${status}=     run keyword and return status  Should Be Equal   ${checked_fault}    ${fault_no}
        run keyword if  ${status}  fail  msg=Fault is present.
    END

Kill Previous services on LTEEMU
    [Arguments]
    Connect to LTEEMU    alias=lteemu
    #kill edaemon
    ${output}    Ssh Execute With Timeout    sudo netstat -anp | grep edaemon    connection=lteemu
    ${len}    Get Length    ${output}
    ${edaemon_pid}    Run Keyword If    ${len}>0    Ssh Execute With Timeout    sudo netstat -anp | grep edaemon | awk '{print $7}'
    ...     connection=lteemu
    ${edaemon_pid}    Run Keyword If    ${len}>0    Fetch From Left    ${edaemon_pid}    /
    Run Keyword If    ${len}>0    Ssh Execute With Timeout    sudo kill -9 ${edaemon_pid}    connection=lteemu
    #kill egate
    ${output}    Ssh Execute With Timeout    sudo netstat -anp | grep egate    connection=lteemu
    ${len}    Get Length    ${output}
    ${egate_pid}    Run Keyword If    ${len}>0    Ssh Execute With Timeout    sudo pkill -9 -f './egate.* --port ${tl.core.egate_port}'
    ...     connection=lteemu

Sync Time
    [Arguments]     ${base_alias}   ${target_alias}     ${sudo_flag}='False'
    [Documentation]     This KW sync time from base_alias to target_alias
    ${time_base}=    csn.execute      date -u     connection=${base_alias}
    ${time_base}=    Strip String    ${time_base}
    BuiltIn.Log     Set time ${time_base}
    Run Keyword if  ${sudo_flag}=='True'
    ...     csn.execute      date -s "${time_base}"   connection=${target_alias}
    ...     ELSE
    ...     csn.execute      date -s "${time_base}"   connection=${target_alias}

Check CPRI Status
    [Arguments]     ${log_path}     ${connection}
    [Documentation]     This KW to check the CPRI status should be ok
    ${cpri_cont}    Ssh Execute With Timeout    grep 'CPRI link state' ${log_path}    ${connection}
    Should Contain    ${cpri_cont}    link state is F

Get SWconfig from QT and Upload
    [Arguments]      ${swconfig_in_qt}  ${swconfig_addon}   ${connection}
    [Documentation]     Download swconfig.txt from Quicktest repository on Gerrit server
    ...     https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/CI/QT/qt_configs.git;a=tree;f=${swconfig_in_qt};hb=HEAD
    ...     and upload it to DU
    ${swconfig_url}     Set Variable
    ...     https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/CI/QT/qt_configs.git;a=tree;f=${swconfig_in_qt};hb=HEAD
    ${rc}   Run And Return Rc
    ...     curl -k -s "${swconfig_url}" > ${TEMP_PATH}/swconfig.txt
    Should Be Equal As Integers     ${rc}   0
    ...     msg=No access to ${swconfig_url}
    ${swconfig}     Get File    ${TEMP_PATH}/swconfig.txt
    # if qt file not exists, curl returns html page containing "Cannot find file"
    Should Not Contain      ${swconfig}     Cannot find file    msg=Do not find ${swconfig_url}     values=False
    # add FRT specific changes to swconfig
    ${command1}    Set Variable    a=`cat ${TEMP_PATH}/swconfig.txt| grep -v grep | grep "^0x1A1300=0"| wc -l`;
    ${command2}    Set Variable    if (($a==0)); then sed -i '/# 0x1A1300=1 : enabled (default)/a\0x1A1300=0'
    ${command3}    Set Variable    ${TEMP_PATH}/swconfig.txt; fi
    ${command}     Set Variable    ${command1} ${command2} ${command3}
    OperatingSystem.Run    ${command}
    OperatingSystem.Run    cat ${swconfig_addon} >> ${TEMP_PATH}/swconfig.txt
    csn.upload_file
    ...    local_path=${TEMP_PATH}/swconfig.txt
    ...    remote_path=/ffs/run/swconfig.txt    connection=${connection}

Ssh Execute With Timeout
    [Arguments]      ${command}     ${connection}   ${timeout}=10
    [Documentation]    Exceute command via ssh (with timeout)
    csn.Send Command    ${command}    timeout=${timeout}     connection=${connection}
    ${output}=    csn.Read Output     connection=${connection}
    [Return]    ${output}

Install Certificate On CU
    [Arguments]    ${raps}    ${session}=default
    @{rap_list}    Create List    ${raps}
    megazone_client.install_certificate_on_cu    cert_path=${CURDIR}/../../config/CloudBTS/RnD_Root_CA.cert.pem
    ...    rap_ids=@{rap_list}    session=${session}

