*** Settings ***
Documentation    Suite description

Library         taf.config.scf     WITH NAME  scf
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME   admin
Library         testsuite.Wroclaw.RRM.resources.webui.WebuiInterface  WITH NAME  WebUI
Library         taf.collectors.btslog  WITH NAME   btslog
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Library         DateTime
Library         String
Library         Collections
Library         ./keywords.py
Library         taf.ul.alarms_watchdog    WITH NAME    watchdog
Resource        testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
*** Variables ***
${resource_path_900}=  testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources
${SCF_modified}=    SCF_modified.xml
${SCF_basic}=    SCF_basic.xml
${atten_ip}                  ${tl.attenuators[0].ip_addr}
${att_api_port}              ${tl.attenuators[0].port}
${atten_ports}               ${tl.attenuators[0].attenuator_ports}
${atten_model}               ${tl.attenuators[0].model}
${atten_vendor}              JFW
${max_attenuation_value}     ${90}
${TEMP_ADMIN_CONN}=         temporary_admin_connection
${LMP_IP}=    10.44.80.175


*** Keywords ***
Lock LTE Site
   [Arguments]  ${connection}=${NONE}  ${rat}=LTE
    Make connection
    admin.block_all_cells    rat=${rat}
    ...                      timeout=2400
    ...                      connection=${connection}

Unlock LTE Site
    [Arguments]  ${connection}=${NONE}  ${rat}=LTE
    Make connection
    admin.unblock_all_cells    rat=${rat}
    ...                      timeout=2400
    ...                      connection=${connection}

Make connection
    [Arguments]       ${ip_address}=${LMP_IP}
    ${date}=	      Get Current Date
    ${connection}=    admin.connect_to
    ...               bts_host=${ip_address}
    ...               username=Nemuadmin
    ...               password=nemuuser
    ...               admin_api_log_dir=/home/ute/test_results/admin/${date}
    [Return]          ${connection}

Set global variable bts id
    ${bts_info}    admin.Get bts info    connection=cOAM
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    Set suite variable    ${bts_id}

Get number of cells and set ID
    ${no_cells}    AdminHelper.Get number of cells
    Set suite variable    ${no_cells}

Start BTSlog
    btslog.create_btslog_collector
    ...                         name=btslog
    ...                         log_dir=/tmp/btslog2
    btslog.setup_collectors     names=btslog
    btslog.start_collectors     names=btslog
    btslog.set_suite_alias      btslog

Stop BtsLog
    btslog.stop_collectors      names=btslog
    Builtin.Sleep               5 sec
    btslog.collect_collectors   names=btslog
    btslog.teardown_collectors  names=btslog
    Remove tmp btslog dir

Remove tmp btslog dir
    [Arguments]     ${path}=/tmp/btslog2
    Remove directory    ${path}    recursive=${True}

Connect To Coam
    [Arguments]  ${alias}=cOAM    ${bts_host}=192.168.255.129

    Log to console      Connect to cOAM
    admin.Connect to    name=${alias}    bts_host=${bts_host}

Disconnect coam
    [Arguments]  ${alias}=cOAM
    Run Keyword and Ignore Error    admin.Teardown     connection=${alias}

Collect snapshot
    [Arguments]         ${alias}=cOAM
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=600sec

    Log to console      Collect snapshot.
    admin.Connect to     name=coam_snap
    ${software_info}    admin.Get software info  connection=coam_snap
    admin.teardown       connection=coam_snap
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    Set variable  ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    admin.Connect to     name=${alias}
    admin.Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${alias}
    admin.teardown       connection=${alias}


Verify fault 7101
    [Arguments]    ${alias}=cOAM    ${id}=7101    ${name_7101}=GnbCpCellUpdateFailedAl    ${unit_status}=Degraded
    ${alarms}    admin.Get active alarms    connection=${alias}
    FOR    ${alarm}    IN    @{alarms}
           Exit for loop if     ${alarm['faultId']}==${id} and '${alarm['faultName']}'=='${name_7101}'
    END
    ${object}    Fetch from right    ${alarm['notifier']}    MRBTS
    ${cells}    admin.Get cells info    connection=${alias}
    FOR    ${cell}    IN    @{cells}
        Exit for loop if    '${cell['id']['configuration']}'=='MRBTS${object}'
    END
    Should be equal as strings    ${cell['status']['availabilityStatus']}    ${unit_status}

Fail if critical alarms occurs and show other alarms
    [Documentation]    Fails if there is any critical alarm. Otherwise print all alarms in console
    [Arguments]    ${alias}=cOAM

    admin.Connect to    name=${alias}
    ${alarms}    admin.Get active alarms    connection=${alias}

    ${find_crit}    Convert to string   ${alarms}
    Should not contain    ${find_crit}    Critical    msg=Critical alarm occurs    values=${FALSE}
    FOR    ${i}    IN    @{alarms}
           Log to console    \nseverity: ${i['severity']}\n alarm name: ${i['alarmName']}\n alarm detail: ${i['alarmDetail']}\n ------------
    END
    [Teardown]    admin.teardown    connection=${alias}


Commission with scf file
    [Documentation]  Author: Ding Binmei
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=cOAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    admin.Connect to    name=${connection}
    &{result}    admin.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    admin.Teardown     connection=${connection}
    [Return]  ${result}

Get SCF
    [Arguments]     ${name}=${SCF_basic}    ${alias}=cOAM
    admin.Get current scf file    local_dir_path=${resource_path_900}
    ...                          file_name=${name}
    ...                          timeout= 40s
    ...                          connection=${alias}

Remove cell during tput
    Log To Console  Cell deleting in progress

    @{empty_list}   Create List
    admin.perform_object_recommissioning   dist_name=MRBTS-51020/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3   parameter=${empty_list}
    ...   operation=delete
    ...   skip_parameter_relation_errors=True
    ...   should_activate=True
    ...   connection=cOAM

Remove cell
    [Arguments]    ${cell_id}
    ${cell_group}    Evaluate    ${cell_id}-1
    ${new_SCF_path}=    Remove cell objects from SCF     ${cell_id}    ${cell_group}
    Commission with scf file    ${new_SCF_path}      is_pdl_checking_needed=${False}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin

Remove cell objects from SCF
    [Arguments]   ${cell_id}=3    ${cell_group}=2
    ${cell_deptype}     Get cell DepType    ${cell_id}

    ${objects_to_remove}     Create list    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...                                     MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...                                     MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-${cell_group}
    ...                                     MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    ...                                     MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
    ...                                     MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-1
    ...                                     MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-2
    ...                                     MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-3
    ...                                     MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-4

    scf.Load Scf    file_path=${resource_path_900}/${SCF_basic}
    FOR    ${object}    IN    @{objects_to_remove}
           scf.Remove element from scf     dist_name=${object}
    END
    scf.Save Scf    file_path=${resource_path_900}/${SCF_modified}

    [Return]    ${resource_path_900}/${SCF_modified}

Add cell
    # [Arguments]    ${alias}=cOAM
    Commission with scf file    ${resource_path_900}/${SCF_basic}    is_pdl_checking_needed=${False}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin

Get cell DepType
    [Arguments]    ${cell_id}=3
    scf.Load Scf    file_path=${resource_path_900}/${SCF_basic}
    ${cell_deptype}    scf.Get value from scf    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...                                          p_name=cellDepType
    [Return]    ${cell_deptype}

Compare cell DepType
    [Arguments]    ${type}    ${cell_id}=2
    ${cell_deptype}     Get cell DepType    ${cell_id}
    Should be equal as strings    ${cell_deptype}    ${type}    msg=Cell ${cell_id} is not ${type}    values=${False}

# X2-C is available
#     [Arguments]    ${alias}=cOAM    ${status}=available
#     @{MOs_lteenb_a}    admin.Get managed objects    class_name=LTEENB_A    connection=${alias}
#     @{MOs_lteenb_r}    admin.Get managed objects    class_name=LTEENB_R    connection=${alias}
#     &{dict_x2LinkLock}     admin.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=x2LinkLock    connection=${alias}
#     &{dict_x2LinkStatus}    admin.get_parameters    dist_name=${MOs_lteenb_r[0]['distName']}  pattern=x2LinkStatus    connection=${alias}
#     should be equal as strings    ${dict_x2LinkLock['x2LinkLock']}    unlocked    msg=x2LinkLock is not in unlocked status    ignore_case=${True}
#     should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    ${status}    msg=x2LinkStatus is not in available status
#     ...                            ignore_case=${True}

# NG-C is available
#     [Arguments]    ${alias}=cOAM    ${status}=Active
#     @{MOs_servedamf}    admin.Get managed objects    class_name=SERVEDAMF_R    connection=${alias}
#     &{dict_NGLinkStatus}    admin.get_parameters    dist_name=${MOs_servedamf[0]['distName']}  pattern=ngLinkStatus    connection=${alias}
#     should be equal as strings    ${dict_NGLinkStatus['ngLinkStatus']}    ${status}    msg=NGLinkStatus is not in active status
#     ...                            ignore_case=${True}

Change the trackingAreaDN
    [Arguments]    ${value}    ${cell_id}=1    ${alias}=cOAM
    admin.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...                                       parameter=trackingAreaDN
    ...                                       operation=update
    ...                                       value=MRBTS-${bts_id}/NRBTS-${bts_id}/TRACKINGAREA-${value}
    ...                                       skip_parameter_relation_errors=${True}
    ...                                       connection=${alias}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin

Check the trackingAreaDN
    [Arguments]    ${cell_id}=1    ${alias}=cOAM
    ${cells}    admin.Get managed objects    class_name=NRCELL_A   connection=${alias}
    FOR    ${cell}    IN    @{cells}
         ${id}    Fetch from right    ${cell['distName']}    NRCELL_A-
         Exit for loop if    ${id}==${cell_id}
    END
    ${trackingAreaDN}    FETCH FROM RIGHT    ${cell['parameters']['trackingAreaDN']}    TRACKINGAREA_A-
    [Return]    ${trackingAreaDN}

Compare trackingAreaDN
    [Arguments]    ${value}    ${cell_id}=1    ${alias}=cOAM
    ${actual_value}    Check the trackingAreaDN    cell_id=${cell_id}    alias=${alias}
    Should be equal as strings    ${actual_value}    ${value}    msg=trackingAreaDN of cell ${cell_id} is not ${value}

Compare DepType of cells
    [Arguments]    ${no_NSA_cells}    ${no_SA_cells}
    ${type_list}   Create list
    FOR   ${cell_id}    IN RANGE    1     ${no_cells}+1
        ${type}      Get cell DepType    cell_id=${cell_id}
        Run keyword if    '${type}'=='SA'
        ...                  Set test variable  ${SA_id}   ${cell_id}
        Run keyword if    '${type}'=='NSA'
        ...                  Set test variable  ${NSA_id}   ${cell_id}
        Append to list    ${type_list}   ${type}
    END
    Run keywords    Should contain X times    ${type_list}   SA   ${no_SA_cells}   AND
    ...             Should contain X times    ${type_list}   NSA  ${no_NSA_cells}


Get broadcast pcap
    [Arguments]  ${alias}=ASIK
    ...  ${dir}=${OUTPUT DIR}/tcpdumpL2L1_filtering.pcap
    ${com1}=  catenate  bsh 1:2 "echo 0x3 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x4
                        ...   > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    ${com2}=  catenate  timeout -s 2 --foreground 2 bsh 1:1 "tcpdump -i ethbp1 ether[0x36:2]==0x6c80
                        ...   -c 10 -C 10 -w /tmp/tcpdumpL2L1_filtering.pcap"
    ${com3}=  catenate  bsh 1:2 "echo 0x0 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo
                        ...   0x0 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    Connect to ASIK     ${alias}
    ssh.send command    command= ${com1}    connection=${alias}
    Sleep  5s
    ssh.send command    command=dbgrrc mirror sport 25 dport 21 enable both    connection=${alias}
    Sleep  5s
    ssh.send command    command=${com2}    connection=${alias}
    sleep  10s
    ssh.send command    command=bsh 1:1 "pkill -2 tcpdump"     connection=${alias}
    ssh.send command    command=bget 1:1 /tmp/tcpdumpL2L1_filtering.pcap /tmp/     connection=${alias}
    sleep  10s
    ssh.send command    command=bsh 1:1 "rm /tmp/tcpdumpL2L1*"     connection=${alias}
    ssh.send command    command=${com3}     connection=${alias}
    ssh.send command    command=dbgrrc mirror sport 25 dport 21 disable both      connection=${alias}
    ssh.download_file    /tmp/tcpdumpL2L1_filtering.pcap   ${dir}    connection=${alias}


Check pcap
    [Arguments]  ${dir}=${OUTPUT DIR}/tcpdumpL2L1_filtering.pcap
    ${sfn}    check_sfn_for_cellid   ${dir}
    should be true    ${sfn}
    ${values}    check_values    ${dir}
    should be equal as strings    ${values}     [True, True, True]


Break AMF connection
    scf.Load Scf    file_path=${resource_path_900}/${SCF_basic}
    ${amf_ip}    scf.Get value from scf    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/SERVEDAMF-1
    ...                                          p_name=amfIPAddress
    set test variable    ${amf_ip}
    admin.Reset site   connection=cOAM
    Connect to ASIK   alias=asik
    ssh.send_command   command=iptables -I INPUT 1 -s ${amf_ip} -j DROP   connection=asik

Break AMF connection without reset site
    scf.Load Scf    file_path=${resource_path_900}/${SCF_basic}
    ${amf_ip}    scf.Get value from scf    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/SERVEDAMF-1
    ...                                          p_name=amfIPAddress
    set test variable    ${amf_ip}
    Connect to ASIK   alias=asik
    ssh.send_command   command=iptables -I INPUT 1 -s ${amf_ip} -j DROP   connection=asik

Wait for fault 7103
    admin.Connect to    name=COAM
    Wait until keyword succeeds    15 min   3 min    Check If Mandatory Alarm Exist   faultId=7103   alarmSeverity=Major
                                        ...  alarmDetail=SA cell activation failed  faultNr=${no_cells}  connection=COAM
    [Teardown]  admin.Teardown     connection=COAM

Wait for fault id 7103
    [Arguments]    ${faultNr_value}
    admin.Connect to    name=COAM
    Wait until keyword succeeds    15 min   3 min    Check If Mandatory Alarm Exist   faultId=7103   alarmSeverity=Major
                                        ...  alarmDetail=SA cell activation failed  faultNr=${faultNr_value}  connection=COAM
    [Teardown]  admin.Teardown     connection=COAM


Bring Up AMF connection
    Connect to ASIK   alias=asik
    ssh.send_command   command=iptables -D INPUT 1    connection=asik
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    # Fail if critical alarms occurs and show other alarms
    Check if NGlinkUp

Lock gNB NSA+SA cells
    admin.Connect to    name=COAM
    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
         ${cell_deptype}  Get cell DepType    cell_id=${cell_id}
         Run keyword if  '${cell_deptype}'=='SA+NSA' or '${cell_deptype}'=='both'  admin.lock_cell
                           ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${bts_id}/NRCELL_R-${cell_id}
                           ...      connection=COAM
    END
    [Teardown]  admin.Teardown     connection=COAM


Lock gNB NSA+SA local cells
    admin.Connect to    name=COAM
    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
         ${dist_name_local}  admin.get_managed_objects    NRCELL_R-${cell_id}    connection=coam
         ${cell_deptype}  Get cell DepType    cell_id=${cell_id}
         Run keyword if  '${cell_deptype}'=='SA+NSA' or '${cell_deptype}'=='both' admin.lock_cell
                           ...  dist_name=${dist_name_local}
                           ...      connection=COAM
    END
    [Teardown]  admin.Teardown     connection=COAM


Unlock gNB NSA+SA cells
    admin.Connect to    name=COAM
    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
        ${cell_deptype}  Get cell DepType    cell_id=${cell_id}
        Run keyword if  '${cell_deptype}'=='SA+NSA' or '${cell_deptype}'=='both'  admin.unlock_cell
                           ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${bts_id}/NRCELL_R-${cell_id}
                           ...      connection=COAM
    END
    [Teardown]  admin.Teardown     connection=COAM

Set NRCELL fPdcchMonOccsnPo
    [Arguments]    ${value}=279
    DeltaStore.Initialise delta store
    ${fPdcchMonOccsnPo}  create list  ${value}
    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
        ${cell_deptype}      Get cell DepType    cell_id=${cell_id}
        Run keyword if  '${cell_deptype}'=='both'   DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=fPdcchMonOccsnPo
                ...                              value=${fPdcchMonOccsnPo}
    END
    ${delta}     DeltaStore.Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}

Wait for fault 7101
    admin.Connect to    name=COAM
    wait until keyword succeeds    15 min   3 min   Check If Mandatory Alarm Exist  faultId=7101  alarmSeverity=Major
                                        ...  alarmDetail=gNB CpCell configuration update failure  faultNr=${no_cells}  connection=COAM
    [Teardown]  admin.Teardown     connection=COAM
Recover
    admin.Connect to    name=COAM
    Set NRCELL fPdcchMonOccsnPo    0
    admin.Reset site   connection=COAM
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    [Teardown]  admin.Teardown     connection=COAM

Set cell DepType
    [Arguments]    ${type}    ${cell_id}
    DeltaStore.Initialise delta store
    DeltaStore.Add param to delta    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...                              param_name=cellDepType
    ...                              value=${type}
    ${delta}     DeltaStore.Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}
    Wait until keyword succeeds    20min    1min    Verify all cells are onair with admin


Set cell DepType for all cells
    [Arguments]    ${type}
    DeltaStore.Initialise delta store
    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
        ${cell_deptype}      Get cell DepType    cell_id=${cell_id}
        DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=cellDepType
                ...                              value=${type}
    END
    ${delta}     DeltaStore.Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}
    Wait until keyword succeeds    20min    30s    Verify all cells are onair with admin

Set diverse cell DepType for all cells
    [Documentation]    This keyword sets cellDepType for diverse types. Arguments relate to number of desired cells of
    ...                given type.
    [Arguments]    ${nsa_type}=0    ${sa_type}=0
    DeltaStore.Initialise delta store
    FOR   ${cell_id}    IN RANGE    1    ${nsa_type}+1
        ${cell_deptype}      Get cell DepType    cell_id=${cell_id}
        DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=cellDepType
                ...                              value=NSA
    END
    FOR   ${cell_id}    IN RANGE    ${nsa_type}+1    ${nsa_type}+${sa_type}+1
        ${cell_deptype}      Get cell DepType    cell_id=${cell_id}
        DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=cellDepType
                ...                              value=SA
    END
    ${delta}     DeltaStore.Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}
    Wait until keyword succeeds    20min    30s    Verify all cells are onair with admin

Find cell id with specific deptype
    [Arguments]   ${type}

    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
        ${cell_deptype}      Get cell DepType    cell_id=${cell_id}
        Exit for loop if    '${cell_deptype}'=='${type}'
    END
    Set test variable   ${specific_cell_id}    ${cell_id}

Replace swconfig
    [Arguments]     ${swconfig_local_path}=testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/swconfig.txt
    ...             ${swconfig_remote_path}=/rom/swconfig.txt
    ...             ${asik_connection}=asik
    admin.Connect to    name=coam
    OperatingSystem.File should exist    ${swconfig_local_path}
    ${flags}    Run    cat ${swconfig_local_path}
    Connect to asik     ${asik_connection}
    ${ssh_command}    Set variable    echo "${flags}" >> ${swconfig_remote_path} && crasign ${swconfig_remote_path}
    ssh.Execute     command=${ssh_command}    connection=${asik_connection}
    admin.Reset Site    connection=coam
    Wait until keyword succeeds    20min    30s    Verify all cells are onair with admin
    [Teardown]  run keywords    admin.Teardown     connection=coam    AND
    ...         ssh.Disconnect  connection=${asik_connection}

Check X2 IP
    admin.Connect to    name=coam
    ${x2_param}        admin.get_managed_objects  LTEENB_R  connection=coam
    ${x2_ip}      Set variable  ${x2_param[0]['parameters']['ipAddr']}
    set test variable  ${x2_ip}
    [Teardown]    admin.Teardown     connection=coam

Get X2 IP from LTE side
    ${x2_ip}      set variable  ${tl.gnbs[0].cu.x2c.v4}
    set test variable  ${x2_ip}

Break X2 connection
    [Arguments]  ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asia
    admin.Reset site    connection=cOAM
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    ssh.send_command   command=iptables -I INPUT 1 -s ${x2_ip} -j DROP   connection=${alias}

Break X2 connection without reset site
    [Arguments]  ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asia
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    wait until keyword succeeds    5 min    1 min    ssh.send_command
    ...    command=iptables -I INPUT 1 -s ${x2_ip} -j DROP   connection=${alias}
    # ssh.send_command   command=reboot   connection=${alias}

Wait for fault 7100
    admin.Connect to    name=COAM
    wait until keyword succeeds    15 min   3 min   Check If Mandatory Alarm Exist
                            ...                faultId=7100
                            ...                alarmSeverity=Major
                            ...                alarmDetail=F1 Cell activation failed due to X2 link unavailable
                            ...                faultNr=${no_cells}   connection=COAM
    [Teardown]  admin.Teardown     connection=COAM

Bring Up X2 connection
    [Arguments]  ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asia
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    ssh.send_command   command=iptables -D INPUT 1    connection=${alias}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    # Fail if critical alarms occurs and show other alarms
    Wait until keyword succeeds    10 min    1 min   Check if X2 link Up
    Check If Mandatory Alarm NOT Exist   faultId=7100


Check if X2 link Up
    admin.Connect to    name=coam
    ${x2_param}  admin.get_managed_objects  LTEENB_R  connection=coam
    ${x2linkstatus}      Set variable  ${x2_param[0]['parameters']['x2LinkStatus']}
    should be equal as strings   available    ${x2linkstatus}
    [Teardown]    admin.Teardown     connection=coam


Restrict X2
    [Arguments]  ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asik
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    ssh.send_command   command=iptables -I INPUT 1 -s ${x2_ip} -p sctp --chunk-types any DATA -j REJECT
    ...                connection=${alias}

Reset ASIA
    [Arguments]  ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asik
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    ssh.send_command   command=reboot    connection=${alias}

Check If Mandatory Alarm NOT Exist
    [Arguments]    ${faultId}=none
    admin.Connect to    name=COAM
    ${active_alarms_list}=   admin.get_active_alarms   connection=COAM
    ${active_alarms_number}=   Get Length  ${active_alarms_list}
    @{list_of_mandatory_alarm_index}=    Create List
    FOR  ${index}  IN RANGE  ${active_alarms_number}
        ${exist}=   Run Keyword And Return Status   Dictionary Should Not Contain Key  ${active_alarms_list[${index}]}
               ...        faultId    ${faultId}
    END
    [Teardown]    admin.Teardown     connection=COAM

Reset and wait OnAir
    admin.Connect to    name=COAM
    admin.Reset site   connection=COAM
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    [Teardown]  admin.Teardown     connection=COAM

Check NGLink
    admin.Connect to    name=coam
    ${ng_param}   admin.get_parameters  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${bts_id}/SERVEDAMF_R-1  connection=coam
    ${nglinkstatus}      Set variable  ${ng_param['ngLinkStatus']}
    should be equal as strings   Active   ${nglinkstatus}
    [Teardown]    admin.Teardown     connection=coam


Check if NGlinkUp
    admin.Connect to    name=coam
    ${ng_param}  admin.get_managed_objects  SERVEDAMF_R  connection=coam
    ${nglinkstatus}      Set variable  ${ng_param[0]['parameters']['ngLinkStatus']}
    should be equal as strings   Active    ${nglinkstatus}
    [Teardown]    admin.Teardown     connection=coam

### 900-C ###

Bring Up AMF by iptables
    scf.Load Scf    file_path=${resource_path_900}/${SCF_basic}
    ${amf_ip}    scf.Get value from scf    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/SERVEDAMF-1
    ...                                          p_name=amfIPAddress
    set test variable    ${amf_ip}
    # admin.Reset site   connection=cOAM
    Connect to ASIK   alias=asik
    ssh.send_command   command=iptables -D INPUT -s ${amf_ip} -j DROP   connection=asik

Wait for cell to be online
   [Documentation]   Possible values to ask: online
   Wait until keyword succeeds   300 s
   ...                           20 s
   ...                           Is cell in state
   ...                           online

Prepare UEs MTK to AT
    ssh.connect_to   hostname=10.42.61.155
    ...              username=wro5grrm
    ...              password=5gpass!1
    ...              alias=uepc
    ssh.send command    command=cd /cygdrive/c/mtk_scripts/ && python set_serial_MTK.py         connection=uepc
    Sleep               10s
    ssh.send command    command=cd /cygdrive/c/mtk_scripts/ && python set_serial_MTK.py          connection=uepc

Set NRCELL gNB maxNum parameters
    [Documentation]  Hardcoded keyword to change maxNum parameters to 900_C_32 test
    [Arguments]    ${maxNumOfUsersNRCell}  ${maxNumOfRrcSA}  ${maxNumOfUsersPerCell}  ${maxNumOfSCellAlloc}
    DeltaStore.Initialise delta store
    FOR   ${cell_id}    IN RANGE    1    ${no_cells}+1
                DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=maxNumOfUsersNRCell
                ...                              value=${maxNumOfUsersNRCell}
                DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=maxNumOfRrcSA
                ...                              value=${maxNumOfRrcSA}
                DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=maxNumOfUsersPerCell
                ...                              value=${maxNumOfUsersPerCell}
                DeltaStore.Add param to delta
                ...            dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
                ...                              param_name=maxNumOfSCellAlloc
                ...                              value=${maxNumOfSCellAlloc}
    END
    ${delta}     DeltaStore.Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}


### 900-D ###

Connect To LTE
    ssh.connect_to   hostname=${tl.test_pcs[1].default_ssh_connection_details.addr}
    ...              username=${tl.test_pcs[1].default_ssh_connection_details.username}
    ...              password=${tl.test_pcs[1].default_ssh_connection_details.password}
    ...              alias=LTE

Start Tshark
    [Arguments]  ${filename}=test.pcap
    ...          ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asik
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    Wait until keyword succeeds    5 min    1 min
    ...    ssh.send_command    command=tcpdump sctp -i any -w ${filename}   connection=${alias}
    sleep  3s

Stop Tshark and download logs
    [Arguments]  ${filename}=test.pcap
    ...          ${alias}=LTE_asik
    sleep  3s
    ssh.execute  command=killall tcpdump  connection=${alias}
    sleep  3s
    ssh.download_file   /user/toor4nsn/${filename}  ${OUTPUT_DIR}/Handover_${TEST_NAME}.pcap  connection=${alias}
    sleep  3s
    ssh.disconnect  connection=${alias}

Verify hanodver success
    test pattern in pcap    ${OUTPUT_DIR}/Handover_${TEST_NAME}.pcap

Reset LTE
    [Arguments]  ${alias}=LTE
    # admin.Reset site    proxy=LTE
    admin.Reset site    connection=${alias}

Start LTE
    ssh.send command    command=cd /home/ute/ && touch dupa     connection=LTE
    Log  LTE wystartowal!

Check_handover_intra_freq_inter_gnb
    [Arguments]  ${dir}=${OUTPUT DIR}/Handover_${TEST_NAME}.pcap
    ...          ${cell_id_before_ho}=0   ${cell_id_after_ho}=0
    ${msgs}    check_handover_intra_freq_inter_gnb_success   ${dir}  ${cell_id_before_ho}   ${cell_id_after_ho}
    should be true    ${msgs}

Check measurements
    [Arguments]  ${dir}=${OUTPUT DIR}/Handover_${TEST_NAME}.pcap
    ...          ${cell_measurement}=0   ${cell_id_before_ho}=0
    ${msgs}    check_measurements_success   ${dir}  ${cell_measurement}    ${cell_id_before_ho}
    should be true    ${msgs}

Check measurements in NSA SA cell
    [Arguments]  ${dir}=${OUTPUT DIR}/Handover_${TEST_NAME}.pcap
    ...          ${cell_measurement}=0
    ${msgs}    check_measurements_success_in_NSA_SA_cell   ${dir}  ${cell_measurement}
    should be true    ${msgs}
