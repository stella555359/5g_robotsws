*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com
...   description: Common keywords for feature CB013895 - SR - VRF - RRM - ET

Library             taf.sbts.oam.coam.admin    WITH NAME    admin
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Library             taf.transport.ssh    WITH NAME    ssh
Library             taf.wts.runner    WITH NAME  wtsemu
Library             taf.sw.dcap.rd		WITH NAME   DCAP
Library             taf.collectors.tcpdump    WITH NAME    tcpdump
Library             taf.collectors.l2stream3    WITH NAME    l2stream3
Library             taf.collectors.l1l2bip
Library             taf.sw.reporting_portal
Library             OperatingSystem
Library             Process
Library             Collections
Library             String
Library             DateTime
Library             SSHLibrary
Library             BuiltIn
Library             XML     use_lxml=True

Library             ../python/k2.py
Library             ../python/slotProcessingDurationBudget.py
Library             ../python/Tti_data_extractor.py
Library             ../python/radParams_handler.py    WITH NAME   radParams

Resource            ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource            ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource            ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource            ../../../../../resources/SWENG/robot/Restart.robot
Resource            ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource            ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource            ../../../../../resources/SWENG/robot/GenericTest.robot
Resource            ../../../../../resources/SWENG/robot/Counters.robot
Resource            ../../../../../resources/SWENG/robot/Setup.robot
Resource            ../../../../../resources/SWENG/robot/CallSetup.robot
Resource            ../../../../../resources/SWENG/robot/Traffic.robot
Resource            ../../../../../resources/SWENG/robot/Sherpa.robot
Resource            ../../../../../resources/SWENG/robot/KPIs.robot

Resource            ../../../../../resources/SWENG/robot/TtiConvertInterface.robot
Resource            ../../../resources/common/TtiTrace/ttitrace.robot

*** Variables ***

${BTS_ADDRESS}                      192.168.255.129
${log_alias}                        btslog
${LOGS_PATH}                        /home/ute/test_results/logs
${BTS_ADDRESS_MPLANE}               10.0.1.2    # BTS M PLane IP
${btsuserremote}                    Nemuadmin
${btspassremote}                    nemuuser
${VM_IP}                            ${tl.test_pc.default_ssh_connection_details.addr}
${BTS_path}                         /home/ute/test_results

${TestSharkTool}                    MC_SHARK
${isAic}                            False
${TLConfig.isGnbCloud}              False

&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Keywords ***

Update bsr package BSR_AQQJ_4_H4 artifactory
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    admin.setup admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    admin.teardown admin

Update bsr package BSR_AQQJ_6_H6 artifactory
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    admin.setup admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    admin.teardown admin

Configure UTE ETH3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3 && sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3 && sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3 && sudo ip addr add 10.0.1.136/24 dev eth3
	OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3 && sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.101/24 dev eth3 && sudo ip addr add 10.0.1.102/24 dev eth3
    SSHLibrary.Open Connection    host=127.0.0.1    port=22    timeout=60
    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write   sudo pkill -9 edaemon && pkill -9 egate

Set New basic_setup_cfg in WTS
    [Arguments]    ${basic_setup_cfg}
    [Documentation]    Copy the basic setup configuration file to the WTS directory
    ${config_file_path}=    Set Variable    /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-B/resources/config/${basic_setup_cfg}
    OperatingSystem.File Should Exist    ${config_file_path}
    Log To Console    Copying config file: ${config_file_path} to /opt/iphy/latest
    OperatingSystem.Run    cp ${config_file_path} /opt/iphy/latest

Setup Airphone Env for CellSetup
    [Arguments]    ${basic_setup_cfg}
    ssh.Connect To    hostname=${VM_IP}    username=ute    key_path=/home/ute/.ssh/id_rsa    look_for_keys=True    alias=wtsemu
    wtsemu.configure_wtsemu_edaemon    edaemon_ssh_alias=wtsemu
    ...                                directory_path=/opt/iphy/latest
    ...                                port=22222
    wtsemu.configure_wtsemu_egate    egate_ssh_alias=wtsemu
    ...                              directory_path=/opt/iphy/latest
    ...                              port=20000
    wtsemu.start_wtsemu    egate_console_ip=${VM_IP}
    ...                    egate_port=20000
	BuiltIn.Sleep    5s
    wtsemu.configure    file=${basic_setup_cfg}
	Wait Until Keyword Succeeds    90    10   ADMIN Check Bts Status    status=OnAir
    BuiltIn.Sleep    60s

Get Average Traffic Rate SA
    [Documentation]    Get Average Traffic Rate SA from bearer stat WTS function
    [Arguments]    ${ue}    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl
    Log to console  Arguments : ${ue} ${pdu} ${qfi} ${trf_id} ${dir}

    wtsemu.Bearer Stats             ue=${ue}
    ...                             dir=${dir}                        trf_id=${trf_id}
    ...                             qfi=${qfi}                        pdu=${pdu}
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=20
    ${output}=                 Get Lines Containing String             ${output}          Average data rate
    ${output}=                 Replace String      ${output}      Average data rate       ${EMPTY}
    @{words}=                  Split String        ${output}      (
    ${average_out}=            Strip String        ${words[0]}
    [Return]    ${average_out}

Get Average Traffic Rate NSA
    [Documentation]    Get Average Traffic Rate NSA from bearer stat WTS function
    [Arguments]    ${ue}    ${id}=1    ${dir}=dl    ${dc_cell_group}=scg
    Log to console  Arguments : ${id} ${dir} ${dc_cell_group}
    wtsemu.Bearer Stats    ue=${ue}
    ...    id=${id}    dir=${dir}    dc_cell_group=${dc_cell_group}
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=20
    ${output}=                 Get Lines Containing String             ${output}          Average data rate
    ${output}=                 Replace String      ${output}      Average data rate       ${EMPTY}
    @{words}=                  Split String        ${output}      (
    ${average_out}=            Strip String        ${words[0]}
    [Return]    ${average_out}

Traffic_DL_UL_SA
    [Arguments]    ${ue}
    wtsemu.ue_register    id=${ue}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=crnti    timeout=30
    Run Keyword If    '${status}' == 'FAIL'    wtsemu.ue_register    id=${ue}
    wtsemu.set_pdu_param    ue=${ue}    pdu=1    trf_type=internal
    BuiltIn.Sleep    2s
    wtsemu.ue_pdu_session_setup    pdu=1    gw=1    ue=${ue}    nwslice=1
    BuiltIn.Sleep    3s

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=1    size=1350    mbps=10    protocol=tcp
    BuiltIn.Sleep    2s


    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=1    mbps=1    protocol=tcp
    BuiltIn.Sleep    10s

    ${traffic_dl}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=1  dir=dl
    ${traffic_ul}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=1  dir=ul

    ${Ue_PDSCH_Tput}=    Set Variable    ${traffic_dl}
    ${Ue_PUSCH_Tput}=    Set Variable    ${traffic_ul}
    Log to console    traffic dl: ${Ue_PDSCH_Tput}
    Log to console    traffic ul: ${Ue_PUSCH_Tput}

    ${result}=  Evaluate    " cell"
    wtsemu.ue_stats_nr    id=${ue}    type=pdsch    scell=0-5
    ${traffic_dl_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic dl NR: ${traffic_dl_NR}
    wtsemu.ue_stats_nr    id=${ue}    type=pusch    scell=0-5
    ${traffic_ul_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic ul NR: ${traffic_ul_NR}

Traffic_DL_UL_SA Low_Load
    [Arguments]    ${ue}
    wtsemu.ue_register    id=${ue}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=crnti    timeout=30
    Run Keyword If    '${status}' == 'FAIL'    wtsemu.ue_register    id=${ue}
    wtsemu.set_pdu_param    ue=${ue}    pdu=1    trf_type=internal
    BuiltIn.Sleep    2s
    wtsemu.ue_pdu_session_setup    pdu=1    gw=1    ue=${ue}    nwslice=1
    BuiltIn.Sleep    3s

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=1    size=1350    mbps=1    protocol=tcp
    BuiltIn.Sleep    2s


    # wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=1    mbps=1    protocol=tcp
    BuiltIn.Sleep    10s

    ${traffic_dl}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=1  dir=dl
    ${traffic_ul}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=1  dir=ul

    ${Ue_PDSCH_Tput}=    Set Variable    ${traffic_dl}
    ${Ue_PUSCH_Tput}=    Set Variable    ${traffic_ul}
    Log to console    traffic dl: ${Ue_PDSCH_Tput}
    Log to console    traffic ul: ${Ue_PUSCH_Tput}

    ${result}=  Evaluate    " cell"
    wtsemu.ue_stats_nr    id=${ue}    type=pdsch    scell=0-5
    ${traffic_dl_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic dl NR: ${traffic_dl_NR}
    wtsemu.ue_stats_nr    id=${ue}    type=pusch    scell=0-5
    ${traffic_ul_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic ul NR: ${traffic_ul_NR}

Traffic_DL_UL_SA High_Load
    [Arguments]    ${ue}

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=2    size=1350    mbps=15    protocol=tcp
    BuiltIn.Sleep    2s


    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=2    mbps=10    protocol=tcp
    BuiltIn.Sleep    10s

    ${traffic_dl}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=2  dir=dl
    ${traffic_ul}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=2  dir=ul

    ${Ue_PDSCH_Tput}=    Set Variable    ${traffic_dl}
    ${Ue_PUSCH_Tput}=    Set Variable    ${traffic_ul}
    Log to console    traffic dl: ${Ue_PDSCH_Tput}
    Log to console    traffic ul: ${Ue_PUSCH_Tput}

    ${result}=  Evaluate    " cell"
    wtsemu.ue_stats_nr    id=${ue}    type=pdsch    scell=0-5
    ${traffic_dl_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic dl NR: ${traffic_dl_NR}
    wtsemu.ue_stats_nr    id=${ue}    type=pusch    scell=0-5
    ${traffic_ul_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic ul NR: ${traffic_ul_NR}

Traffic_DL_UL_SA Low_Load_Ramp
    [Arguments]    ${ue}

    wtsemu.trf_data_stop    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=2
    BuiltIn.Sleep    2s


    wtsemu.trf_data_stop    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=2
    BuiltIn.Sleep    10s

    ${traffic_dl}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=2  dir=dl
    ${traffic_ul}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=2  dir=ul

    ${Ue_PDSCH_Tput}=    Set Variable    ${traffic_dl}
    ${Ue_PUSCH_Tput}=    Set Variable    ${traffic_ul}
    Log to console    traffic dl: ${Ue_PDSCH_Tput}
    Log to console    traffic ul: ${Ue_PUSCH_Tput}

    ${result}=  Evaluate    " cell"
    wtsemu.ue_stats_nr    id=${ue}    type=pdsch    scell=0-5
    ${traffic_dl_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic dl NR: ${traffic_dl_NR}
    wtsemu.ue_stats_nr    id=${ue}    type=pusch    scell=0-5
    ${traffic_ul_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic ul NR: ${traffic_ul_NR}

Traffic_DL_UL_SA_stop
    [Arguments]    ${ue}
    wtsemu.ue_deregister    id=${ue}    by=ue    ue_deregister_type=switch_off
    # run keyword and continue on failure
    # ...    wtsemu.read_wtsemu_output_until    expected=UE Context Release Complete
    # ...                                       timeout=40

ADMIN Check Bts Status
    [Arguments]    ${status}=OnAir
    ${bts_state}=    admin.get_bts_statuses    connection=mplane
    BuiltIn.Log    [INFO] BTS STATE : ${bts_state}
    BuiltIn.Log To Console     ${BTS STATE['proceduralState']}
	BuiltIn.Should Be True    '${BTS STATE['proceduralState']}' == '${status}'

Login To Admin
    wait until keyword succeeds     5min    30s
    ...    admin.setup_admin    bts_host=${BTS_ADDRESS}    alias=oam

LoginToAdminMplane
    admin.setup_admin    bts_host=${BTS_ADDRESS_MPLANE}    alias=mplane

Start Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    btslog.create_btslog_collector    btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors    names=btslog
    core.start_collectors    names=btslog
    btslog.set_suite_alias    alias=btslog

Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    Run Keyword And Continue On Failure    core.stop_collectors    names=btslog
    Run Keyword And Continue On Failure    core.collect_collectors    names=btslog    target_dir=${out}
    Run Keyword And Continue On Failure    core.teardown_collectors    names=btslog

Get Date
    [Documentation]    Get date to create testcase folder
    ${date}=    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}=    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Collect_Alarms
    Wait Until Keyword Succeeds
    ...    3min
    ...    30s
    ...    admin.collect_raw_alarm_history_file
    ...    target_file_name=${out}/AllAlarms.txt
    ...    connection=mplane

Collect_ImSnapshot
    Wait Until Keyword Succeeds    2min    30s    admin.collect_im_snapshot    target_file_name=${out}/ImSnapshot.ims2    connection=mplane

Collect_SCF
    Wait Until Keyword Succeeds    2min    30s    admin.get_current_scf_file
    ...    file_name=SCF.xml
    ...    timeout=60
    ...    local_dir_path=${out}
    ...    connection=mplane

Download Snapshot
    Wait Until Keyword Succeeds
    ...    10min
    ...    120s
    ...    admin.collect_snapshot
    ...    target_file_name=${out}/Snapshot.zip
    ...    connection=mplane

Reset Site
    admin.reset_site
    ...    wait_for_reconnection=true
    ...    connection=mplane
    ...    timeout=1200

Get vlanIdOAM parameter from Info Model
    [Documentation]    This keyword is used to get vlanIdOAM parameter from Info Model.
    Log To Console    Get vlanIdOAM parameter from Info Model.
    ${vlanIdOAM_DICT}=    admin.get_parameters
    ...    /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/TNLSVC_A-1/TNL_A-1/ETHSVC_A-1/ETHIF_A-1/VLANIF_A-1
    ...    connection=mplane
    ${vlanIdOAM_param}=    Get From Dictionary    ${vlanIdOAM_DICT}    vlanId
    Set Global Variable    ${vlanIdOAM_param}
    [Return]    ${vlanIdOAM_param}

Update VLAN ID For Specific VLANIF
    [Documentation]    Update vlanId for VLANIF with specific distName in SCF XML.
    ${xml}=    Parse XML    ${SCF_FILE_PATH_1}
    ${node}=    Get Element    ${xml}
    ...    //managedObject[@class="com.nokia.srbts.tnl:VLANIF" and @distName="MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"]/p[@name="vlanId"]
    ${vlanId_str}=    Convert To String    ${vlanIdOAM_param}
    Set Element Text    ${node}    ${vlanId_str}
    Save XML    ${xml}    ${SCF_FILE_PATH_1}
    Log To Console    vlanId updated to ${vlanId_str} for VLANIF-1

SCF commissioning
    [Documentation]  ... Commissiioning BTS and checking BTS status
    [Arguments]    ${scf}
    Log to console    BTS commissioning is Ongoing
    ${status}=    admin.perform_commissioning    scf_file=${scf}    timeout=2000    connection=mplane

iphy commissioning
    [Arguments]    ${iphy}
    [Documentation]  ... Commissiioning iphy and checking BTS status
    Log to console    iphy commissioning is Ongoing
    OperatingSystem.Run    scp ${iphy} toor4nsn@192.168.200.1:/ffs/run/simmode/

Reset AP
    ssh.connect_to    hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
    ssh.send command    reboot
    ssh.disconnect
    BuiltIn.Sleep    360s
    Log to console    AP reset is done

Collect swconfig file
    [Teardown]    Run Keyword And Continue On Failure    ssh.Disconnect    connection=GNB
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    180s    1s    ssh.Connect To
    ...    hostname=${BTS_ADDRESS}    username=toor4nsn    password=oZPS0POrRieRtu    alias=GNB
    ${swconfig_exist}=    Run Keyword And Continue On Failure    ssh.File Exists    /ffs/run/swconfig.txt
    ...    timeout=10    connection=GNB
    Run Keyword If    ${swconfig_exist}==True    Run Keyword And Continue On Failure    ssh.Download File
    ...    /ffs/run/swconfig.txt    ${out}/swconfig.txt    timeout=10    connection=GNB

Collect iphy xml file
    [Teardown]    Run Keyword And Continue On Failure    ssh.Disconnect    connection=AP
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    180s    1s    ssh.Connect To
    ...    hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    alias=AP
    ${iphy_xml_exist}=    Run Keyword And Continue On Failure    ssh.File Exists    /ffs/run/simmode/iphy.xml
    ...    timeout=10    connection=AP
    Run Keyword If    ${iphy_xml_exist}==True    Run Keyword And Continue On Failure    ssh.Download File
    ...    /ffs/run/simmode/iphy.xml    ${out}/iphy.xml    timeout=10    connection=AP

Collect egate_console file
    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${out}

Collect basic_setup_cfg_B1 file
    OperatingSystem.Run    cp /opt/iphy/latest/${basic_setup_cfg_B1} ${out}

Test Setup
    Run Keywords    LoginToAdminMplane
    Create testcase folder
    OperatingSystem.run    chmod 777 ${out}
    Run Keyword And Ignore Error    Start Btslogs from Local machine

Test Teardown
    Collect_Alarms
    Collect_ImSnapshot
    Collect_SCF
    Collect swconfig file
    Collect egate_console file
    Collect basic_setup_cfg_B1 file
    Collect iphy xml file
    Download Snapshot
    admin.teardown_admin    mplane
    wtsemu.stop_wtsemu
    Log to console    --End test--\n

Create testcase folder
    [Documentation]    Create testcase folder in VM
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M%S
    ${CurrentDate}=    Convert to String    ${CurrentDate}
    OperatingSystem.create directory    ${BTS_path}/${CurrentDate}/
    ${out}=    Set Variable    ${BTS_path}/${CurrentDate}/
    set test variable    ${out}

Start Capture SosReport
    [Arguments]    ${check_time}=2min    ${wts_dir}=/opt/iphy/latest/sosReport_ASIL    ${tmp_dir}=${out}
    [Documentation]    This keyword uses the script 'startTest_ASIL.sh' to start Airphone SosReport capture.
    ...    | ${check_time} | Log checking duration
    ...    | ${wts_dir} | Script directory
    ...    | ${tmp_dir} | Directory for the stdout file
    OperatingSystem.Run    chmod 777 ${wts_dir}${/}startTest_ASIL.sh
    OperatingSystem.Run    rm /opt/iphy/latest/sosReport_ASIL/SosReport*.tgz
    Log To Console    Starting startTest_ASIL.sh Sosreport...
    ${start_sosreport_cmd}    Set Variable    .${/}startTest_ASIL.sh
    ${result}    Process.Start Process    ${start_sosreport_cmd}    shell=True    cwd=${wts_dir}    stdout=${tmp_dir}${/}start_stdout.txt
    ${success_msg}    Set Variable    You can now start your tests in egate
    Wait Until Keyword Succeeds    ${check_time}    10s    Check Suscess Msg Exist    ${tmp_dir}${/}start_stdout.txt    ${success_msg}

Stop Capture SosReport
    [Arguments]    ${check_time}=15min    ${wts_dir}=/opt/iphy/latest/sosReport_ASIL    ${tmp_dir}=${out}
    [Documentation]    This keyword uses the script 'stopTest_ASIL.sh' to stop Airphone SosReport capture.
    ...    | ${check_time} | Log checking duration
    ...    | ${wts_dir} | Script directory
    ...    | ${tmp_dir} | Directory for the stdout file
    OperatingSystem.Run    chmod 777 ${wts_dir}${/}stopTest_ASIL.sh
    Log To Console    Stopping stopTest_ASIL.sh Sosreport...
    ${stop_sosreport_cmd}    Set Variable    .${/}stopTest_ASIL.sh
    ${result}    Process.Start Process    ${stop_sosreport_cmd}    shell=True    cwd=${wts_dir}    stdout=${tmp_dir}${/}stop_stdout.txt
    ${success_msg}    Set Variable    _UEAPP1.tgz created
    Wait Until Keyword Succeeds    ${check_time}    10s    Check Suscess Msg Exist    ${tmp_dir}${/}stop_stdout.txt    ${success_msg}
    OperatingSystem.Run    mv /opt/iphy/latest/sosReport_ASIL/SosReport*.tgz ${out}

Check Suscess Msg Exist
    [Arguments]    ${file_path}    ${success_msg}
    [Documentation]    This keyword is to check a msg exsit in a file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file path need to check |
    ...    | ${success_msg} | Yes | the message need to check |
    ...
    ...    Examples:
    ...    | Check Suscess Msg Exist | ${TEMPDIR}${/}stop_stdout.txt | You can now start your tests in egate |
    ...    | Check Suscess Msg Exist | ${TEMPDIR}${/}start_stdout.txt | _iphy1.tgz created |
    ${ret}    OperatingSystem.Grep File    ${file_path}    ${success_msg}
    Should Not Be Empty    ${ret}

Test Setup CB013895-SR_B1
	[Documentation]
    ...    | Description | Test Setup CB013895-SR_B1 |
    ...    | . | .       |
    ...    | Test Steps  | 1. Configure UTE ETH3 |
    ...    | Test Steps  | 1. Set New basic_setup_cfg in WTS |
    ...    | Test Steps  | 3. Setup Airphone Env for CellSetup |
	##########################################################################################
    #1. Configure UTE ETH3
    ##########################################################################################
    Run keyword and continue on failure    Configure UTE ETH3
    BuiltIn.Sleep    10s
    ##########################################################################################
    #2. Set New basic_setup_cfg in WTS
    ##########################################################################################
    Set New basic_setup_cfg in WTS    basic_setup_cfg=${basic_setup_cfg_B1}
    BuiltIn.Sleep    40s
    ##########################################################################################
    #3. Setup Airphone Env for CellSetup
    ##########################################################################################
    Setup Airphone Env for CellSetup    basic_setup_cfg=${basic_setup_cfg_B1}
    BuiltIn.Sleep    40s

Recommission GNB With Delta
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    #LoginToAdminMplane
    admin.Perform Delta Recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}    connection=mplane
    #[Teardown]    admin.teardown_admin    mplane

TTI Conversion and CSV Generation Low_Load
    ${path_to_pcap}=    Set Variable    ${out}/Low_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    ${TTIjson}=         Set Variable    ${out}/Low_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.json
    TtiConvertInterface.Convert TTI capture    ${path_to_pcap}    tti_decoder_path=/opt/tti-dec/tti-dec-bin/
    ${TTIcsv}    decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=500000

Check K2 Occurrences Low_Load K2 In 2
    ${file_path}=    Set Variable    ${out}/Low_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${k2_check_value}=    Create List    2
    ${result}=    Read And Process K2 File    ${file_path}    ${k2_check_value}
    Run Keyword If    ${result} is None    Log    No occurrences of K2 found in the file.
    Run Keyword If    ${result} == True    Log    All occurrences of K2 are in [2].
    Run Keyword If    ${result} == False    Log    At least one occurrence of K2 is not in [2].
    Should Be True    ${result}

Check Slot Processing Duration Budget Low_Load
    [Arguments]    ${slotProcessingDurationBudget}
    ${file_path}=    Set Variable    ${out}/Low_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${result}=    read_and_process_slotProcessingDurationBudget_file    ${file_path}    ${slotProcessingDurationBudget}
    Run Keyword If    ${result} is None    Log
    ...    No occurrences of slotProcessingDurationBudget with LOADTYPEMIXED found in the file.
    Run Keyword If    ${result} == True    Log
    ...    All occurrences of slotProcessingDurationBudget == ${slotProcessingDurationBudget} with LOADTYPEMIXED in the file are True.
    Run Keyword If    ${result} == False    Log
    ...    At least one occurrence of slotProcessingDurationBudget != ${slotProcessingDurationBudget} with LOADTYPEMIXED in the file.
    Should Be True    ${result}

TTI Conversion and CSV Generation High_Load
    ${path_to_pcap}=    Set Variable    ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    ${TTIjson}=         Set Variable    ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.json
    TtiConvertInterface.Convert TTI capture    ${path_to_pcap}    tti_decoder_path=/opt/tti-dec/tti-dec-bin/
    ${TTIcsv}    decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=500000

Check K2 Occurrences High_Load K2 In 2 3 4
    ${file_path}=    Set Variable    ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${k2_check_value}=    Create List    2    3    4
    ${result}=    Read And Process K2 File    ${file_path}    ${k2_check_value}
    Run Keyword If    ${result} is None    Log    No occurrences of K2 found in the file.
    Run Keyword If    ${result} == True    Log    All occurrences of K2 are in [2, 3, 4].
    Run Keyword If    ${result} == False    Log    At least one occurrence of K2 is not in [2, 3, 4].
    Should Be True    ${result}

Check Slot Processing Duration Budget High_Load
    [Arguments]    ${slotProcessingDurationBudget}
    ${file_path}=    Set Variable    ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${result}=    read_and_process_slotProcessingDurationBudget_file    ${file_path}    ${slotProcessingDurationBudget}
    Run Keyword If    ${result} is None    Log
    ...    No occurrences of slotProcessingDurationBudget with LOADTYPEMIXED found in the file.
    Run Keyword If    ${result} == True    Log
    ...    All occurrences of slotProcessingDurationBudget == ${slotProcessingDurationBudget} with LOADTYPEMIXED in the file are True.
    Run Keyword If    ${result} == False    Log
    ...    At least one occurrence of slotProcessingDurationBudget != ${slotProcessingDurationBudget} with LOADTYPEMIXED in the file.
    Should Be True    ${result}

Check Slot Processing Duration Budget switch High_Load
    [Arguments]    ${slotProcessingDurationBudget1}    ${slotProcessingDurationBudget2}
    ${file_path}=    Set Variable     ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${budget_check_values}=    Create List    ${slotProcessingDurationBudget1}    ${slotProcessingDurationBudget2}
    ${result}=    read_and_process_slotProcessingDurationBudget_switch    ${file_path}    ${budget_check_values}
    Run Keyword If    ${result} is None    Log
    ...    No occurrences of slotProcessingDurationBudget with LOADTYPEMIXED found in the file.
    Run Keyword If    ${result} == True    Log
    ...    All occurrences of BI == ${slotProcessingDurationBudget1} and ${slotProcessingDurationBudget2} with LOADTYPEMIXED in the file are True.
    Run Keyword If    ${result} == False    Log
    ...    At least one occurrence of BI != ${slotProcessingDurationBudget1} or ${slotProcessingDurationBudget2} with LOADTYPEMIXED in the file.
    Should Be True    ${result}

TTI Conversion and CSV Generation Low_Load_Ramp
    ${path_to_pcap}=    Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    ${TTIjson}=         Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.json
    TtiConvertInterface.Convert TTI capture    ${path_to_pcap}    tti_decoder_path=/opt/tti-dec/tti-dec-bin/
    ${TTIcsv}    decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=500000

Check K2 Occurrences Low_Load_Ramp K2 In 2
    ${file_path}=    Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${k2_check_value}=    Create List    2
    ${result}=    Read And Process K2 File    ${file_path}    ${k2_check_value}
    Run Keyword If    ${result} is None    Log    No occurrences of K2 found in the file.
    Run Keyword If    ${result} == True    Log    All occurrences of K2 are in [2].
    Run Keyword If    ${result} == False    Log    At least one occurrence of K2 is not in [2].
    Should Be True    ${result}

Check K2 Occurrences Low_Load_Ramp K2 In 2 3 4
    ${file_path}=    Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${k2_check_value}=    Create List    2    3    4
    ${result}=    Read And Process K2 File    ${file_path}    ${k2_check_value}
    Run Keyword If    ${result} is None    Log    No occurrences of K2 found in the file.
    Run Keyword If    ${result} == True    Log    All occurrences of K2 are in [2, 3, 4].
    Run Keyword If    ${result} == False    Log    At least one occurrence of K2 is not in [2, 3, 4].
    Should Be True    ${result}

Check Slot Processing Duration Budget Low_Load_Ramp
    [Arguments]    ${slotProcessingDurationBudget}
    ${file_path}=    Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${result}=    read_and_process_slotProcessingDurationBudget_file    ${file_path}    ${slotProcessingDurationBudget}
    Run Keyword If    ${result} is None    Log
    ...    No occurrences of slotProcessingDurationBudget with LOADTYPEMIXED found in the file.
    Run Keyword If    ${result} == True    Log
    ...    All occurrences of slotProcessingDurationBudget == ${slotProcessingDurationBudget} with LOADTYPEMIXED in the file are True.
    Run Keyword If    ${result} == False    Log
    ...    At least one occurrence of slotProcessingDurationBudget != ${slotProcessingDurationBudget} with LOADTYPEMIXED in the file.
    Should Be True    ${result}

Check Slot Processing Duration Budget switch Low_Load_Ramp
    [Arguments]    ${slotProcessingDurationBudget1}    ${slotProcessingDurationBudget2}
    ${file_path}=    Set Variable     ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${budget_check_values}=    Create List    ${slotProcessingDurationBudget1}    ${slotProcessingDurationBudget2}
    ${result}=    read_and_process_slotProcessingDurationBudget_switch    ${file_path}    ${budget_check_values}
    Run Keyword If    ${result} is None    Log
    ...    No occurrences of slotProcessingDurationBudget with LOADTYPEMIXED found in the file.
    Run Keyword If    ${result} == True    Log
    ...    All occurrences of BI == ${slotProcessingDurationBudget1} and ${slotProcessingDurationBudget2} with LOADTYPEMIXED in the file are True.
    Run Keyword If    ${result} == False    Log
    ...    At least one occurrence of BI != ${slotProcessingDurationBudget1} or ${slotProcessingDurationBudget2} with LOADTYPEMIXED in the file.
    Should Be True    ${result}

Extract Data From File Low_Load
    ${INPUT_FILE}=    Set Variable    ${out}/Low_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    @{KEYWORDS}=    Create List
    ...    dlLoadControlData
    ...    ulLoadControlData
    ...    slotTimingSwitching
    ...    dlFdSchedData
    ...    ulFdSchedData
    ...    dlTdSchedSubcellData
    FOR    ${keyword}    IN    @{KEYWORDS}
        ${output_file}=    Set Variable    ${out}/Low_Load/l2stream3_ttitrace/tcpdump_ttitrace/extracted_${keyword}.xlsx
        ${result}=    Process File    ${INPUT_FILE}    ${keyword}    ${output_file}
        Log    ${result}
    END

Extract Data From File High_Load
    ${INPUT_FILE}=    Set Variable    ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    @{KEYWORDS}=    Create List
    ...    dlLoadControlData
    ...    ulLoadControlData
    ...    slotTimingSwitching
    ...    dlFdSchedData
    ...    ulFdSchedData
    ...    dlTdSchedSubcellData
    FOR    ${keyword}    IN    @{KEYWORDS}
        ${output_file}=    Set Variable    ${out}/High_Load/l2stream3_ttitrace/tcpdump_ttitrace/extracted_${keyword}.xlsx
        ${result}=    Process File    ${INPUT_FILE}    ${keyword}    ${output_file}
        Log    ${result}
    END

Extract Data From File Low_Load_Ramp
    ${INPUT_FILE}=    Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    @{KEYWORDS}=    Create List
    ...    dlLoadControlData
    ...    ulLoadControlData
    ...    slotTimingSwitching
    ...    dlFdSchedData
    ...    ulFdSchedData
    ...    dlTdSchedSubcellData
    FOR    ${keyword}    IN    @{KEYWORDS}
        ${output_file}=    Set Variable    ${out}/Low_Load_Ramp/l2stream3_ttitrace/tcpdump_ttitrace/extracted_${keyword}.xlsx
        ${result}=    Process File    ${INPUT_FILE}    ${keyword}    ${output_file}
        Log    ${result}
    END

Set CB013895 Rad Parameters
    [Documentation]    Set the RD params of logs.
    ${0x58012d}=    Set Variable    2        # k2min for Airphone 2 for CB013305
    ${0x5800f4}=    Set Variable    4        # k1Min_for_AirPhone
    ${0x4B000F}=    Set Variable    1        # RF_SW_Version_check_disabled
    ${0x590072}=    Set Variable    1        # CP-RT log level (0=disable, 1=debug, 2=info, 3=warning, 4=error, 5=vip, 6=disable)
    ${0x58057A}=    Set Variable    4        # L2 feature logs ERR & WRN & INF & DBG
    ${0x58057C}=    Set Variable    0x3800   # rdFeatureFlagBitmap1: PRB_POOLING.BASIC, DL, UL – CB013709 enabled
    ${0x5809b5}=    Set Variable    0x190    # rdAvgMaxSizeDlCs1BiSlotThreshold 400 – CB013895-B
    ${0x580581}=    Set Variable    8        # rdFeatureFlagBitmap6: Enable UL_BEAM_USAGE_LIMIT (Bit 3, CB013895-B); all other bits disable
    ${parametersList}=    Catenate    SEPARATOR=${SPACE}
    ...    0x58012d=${0x58012d}
    ...    0x5800f4=${0x5800f4}
    ...    0x4B000F=${0x4B000F}
    ...    0x590072=${0x590072}
    ...    0x58057A=${0x58057A}
    ...    0x58057C=${0x58057C}
    ...    0x5809b5=${0x5809b5}
    ...    0x580581=${0x580581}
    radParams.set_rad_flags    ${parametersList}    persistently=${True}

Start Ttitrace With Streaming Mode For GNB
    [Arguments]    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=10.0.1.2
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    tcpdump.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    # ...  sudo_password=ute
    l2stream3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    l2stream3.Set Suite Alias
    ...  alias=${names}
    core.setup_collectors
    ...  names=${names}
    core.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace, start to catch ttitrace log...

Get Software Version
    [Arguments]          ${alias}=mplane
    [Documentation]      Return software version
    ...     alias:   AdminConnection object or if used, string name alias
    ${software_info}=    admin.get_software_info     connection=${alias}
    ${sw_version}=       set variable    ${software_info['Active SW version']}
    Set global variable    ${SW_BRANCH}    ${sw_version}

Stop Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace    ${log_dir}=${out}/output_dir/
    log to console    stop catching ttitrace...
    core.stop_collectors
    ...  names=${names}
    core.collect_collectors
    ...  names=${names}    target_dir=${log_dir}
    core.teardown_collectors
    ...  names=${names}

Start Collect interface mirroring with nr phy cell ids
    log to console    setup admin for l1l2bip...
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    taf.collectors.l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=50
    ...  timeout=300
    taf.collectors.l1l2bip.setup_collectors    names=l1l2bip
    taf.collectors.l1l2bip.start_collectors    names=l1l2bip
    taf.collectors.l1l2bip.set_suite_alias     alias=l1l2bip

Stop Collect interface mirroring with nr phy cell ids
    log to console    stop catching l1l2bip...
    OperatingSystem.Create Directory    ${out}l1l2bip_trace/
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip    target_dir=${out}l1l2bip_trace/
    core.teardown_collectors    names=l1l2bip

Collect and Check Counter
    [Documentation]                 Check Counters M55308C18001, M55308C18002
    Run keyword and continue on failure    Counter value NRCELL NCELA    counter_name=M55308C18001
    Run keyword and continue on failure    Counter value NRCELL NCELA    counter_name=M55308C18002
    Download PM files

Counter value NRCELL NCELA
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    admin.reset_admin    connection=mplane
    ${result}     admin.get_pm_counters    counter_ids=${counter_name}    timeout=60    connection=mplane
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NCELA']['${counter_name}']}
    log    ${values}
    log to console    \nCounter value for ${counter_name} is ${values}
    ${timestamp}    Get Dictionary Keys    ${result['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NCELA']['${counter_name}']}
    log    ${timestamp}

    # Convert timestamps to human-readable format
    ${readable_times}=    Evaluate    [datetime.datetime.utcfromtimestamp(int(ts)).strftime('%Y-%m-%d %H:%M:%S') for ts in ${timestamp}]    datetime

    log    ${readable_times}
    log to console    \nReadable timestamps: ${readable_times}

    ${json_data}    Create Dictionary    ${counter_name}=${values}
    ${json_string}    Convert To String    ${json_data}
    Create File    ${out}${counter_name}_counter.json    ${json_string}

    # Check if at least one value equals 24 (only for M55308C18002)
    Run Keyword If    '${counter_name}' == 'M55308C18002'    Verify Counter Contains Value    ${values}    24

Verify Counter Contains Value
    [Arguments]    ${values}    ${expected_value}
    # Check UE scheduler in the last 7 counter values (or all if less than 7)
    ${values_length}=    Get Length    ${values}
    Should Not Be Equal As Numbers    ${values_length}    0    msg=Counter values list is empty - cannot verify expected value
    ${last_seven_values}=    Evaluate    ${values}[-7:] if len(${values}) >= 7 else ${values}
    log to console    \nChecking last counter values (up to 7 last counter values): ${last_seven_values}
    ${ue_scheduler_check}=    Evaluate    ${expected_value} in ${last_seven_values}
    Should Be True    ${ue_scheduler_check}    msg=Expected value ${expected_value} not found in last counter values: ${last_seven_values}
    log to console    \nUE scheduler verification passed: Value ${expected_value} found in last counter values

Download PM files
    admin.get_pm_files    timeout=300    local_file_path=${out}pmfile.txt    connection=mplane
    OperatingSystem.Run    base64 -d < ${out}pmfile.txt > ${out}pmfile.zip
    OperatingSystem.Run    cd ${out};unzip ${out}pmfile.zip
    OperatingSystem.Remove File    ${out}pmfile.txt
    OperatingSystem.Remove File    ${out}pmfile.zip

Check Maximum scheduled UEs in UL
    [Documentation]    This test case runs the specified Python script with given arguments.
    ${INPUT_FILE}=    Set Variable    ${out}High_Load/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.csv
    ${COMMAND}    Set Variable    python ${Script_ue_schedule_analysis} ${INPUT_FILE} ue_schedule_analysis.csv
    ${result}=    Run Process    ${COMMAND}    shell=True    timeout=300    cwd=${out}High_Load/l2stream3_ttitrace/tcpdump_ttitrace
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Be Equal As Numbers    ${result.rc}    0
    ${stdout}=    Set Variable    ${result.stdout}
    Log To Console    \n\n${stdout}

TC Teardown Action
    Produce Scout Data