*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var
Library           OperatingSystem
Library           Telnet
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ul.ue.sim.env_setup
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../resources/robot/TTI_Traces.robot
Library          ../../../../resources/python/CPRT_Capture.py
Resource         ../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Resource         ../../../../resources/robot/Airphone.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Resource         ../../../../resources/robot/common_log_collection.robot
Resource         ../../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../../resources/robot/BBpooling_MuMIMO.robot
Library         ta5g_egate
Library         Process
Library         Collections
Library         taf.converters.pcaptopdml      WITH NAME    pcaptopdml
Library         taf.collectors.tshark          WITH NAME    tshark
Library         taf.collectors.l2stream3       WITH NAME    ttistream
Library         taf.sbts.oam.coam.admin        WITH NAME    CoamAdmin
Library         taf.transport.ssh              WITH NAME    taf_ssh
Library         taf.sw.dcap.rd                 WITH NAME    rd
Library         taf.wts.runner              WITH NAME    wtsrunner
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sw.wtssim
Library         taf.ue.airphone
Library         taf.config.scf
Library         ta_emss
Library         ta5g_tshark
Library         ta5g_commissioning
Library         ta5g_pm_counters
Library         String
Library         file_operation.py

*** Variables ***
${scf_folder}       ${CURDIR}/../config/scf/
${bsr_iphy_folder}     ${CURDIR}/../config/
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_folder}     ${CURDIR}/../config/wts
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/BSR/
${BSR_FILENAME}=    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${connection}				admin_1
${path1}=         BTS']['MRBTS-1']['NRBTS-1']['[VRF_BLR_T10_JIO_FUll_TDD_1]NRCELL-1']['NNGCC
@{REMOTE_HOSTS}

*** Keywords ***
Configure Routes in WTS
     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.132/24 dev eth3
     Run    sudo ip addr add 10.0.1.133/24 dev eth3
     Run    sudo ip addr add 10.0.1.134/24 dev eth3
     Run    sudo ip addr add 10.0.1.135/24 dev eth3
     Run    sudo ip addr add 10.0.1.136/24 dev eth3
     Run    sudo ip addr add 10.0.1.137/24 dev eth3
     Run    sudo ip addr add 10.0.1.138/24 dev eth3
     Run    sudo ip addr add 10.0.1.139/24 dev eth3
     Run    sudo ip addr add 10.0.1.140/24 dev eth3
     Run    sudo ip addr add 10.0.1.112/24 dev eth3
     Run    sudo ip addr add 10.0.1.113/24 dev eth3
     Run    sudo ip addr add 10.0.1.102/24 dev eth3
     Run    sudo ip addr add 10.0.1.101/24 dev eth3
     Run    sudo ip addr add 10.0.1.200/24 dev eth3



Run cfg file

       [Arguments]    ${wts_cfg_file_TC}
    Stop Edaemon and Egate process
    Stop Sim_enb

    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000

    wtsrunner.configure                   file=${wts_cfg_file_TC}

    Sleep    30s
    wtsrunner.enb_x2_link_up    enb=1    target=2
     sleep    30s

Check SIB messagges for all cells
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 5: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 6: SystemInformationBlockType1-NR updated

Delta file commissioning to lock slices
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_Lock_Slices}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to update slices
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_Update_Slices}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to unlock slices
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_Unlock_Slices}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Update bsr package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${bsr_iphy_folder} ${BSR_FILEPATH}    shell=yes
    CoamAdmin.Setup Admin
    CoamAdmin.Update Software    sw_package=${bsr_iphy_folder}/${BSR_FILENAME}
    CoamAdmin.Teardown admin


Verify cell-2 barred
    ${1}=    taf.sw.syslog.count_syslog_messages   alias=feat_act
    ...    regexp=cells barred: [16386]
	Should be True     ${1} == 1

Decommission the feature changes
     CoamAdmin.Setup Admin
     CoamAdmin.perform_delta_recommissioning    delta_file=${decommission_A_B1_TC1}    skip_parameter_relation_errors=True
     CoamAdmin.Teardown admin
     Sleep    20s

Start Tshark on eth3
      start_tshark   log_filename=CB013880_ABC.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC

Stop Tshark on eth3
     stop_tshark     alias=ABC

Delta file commissioning to lock slice_1
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_TC2_lock}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Add slice_1 for NRCELL_2
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_TC2_addition}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to unlock slice_1
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_TC2_unlock}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to update slices for TC3
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_Update_Slices_TC3}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to lock slice_3
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_TC3_lock}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Add slice_3 for NRCELL_2
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_TC3_addition}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to unlock slice_3
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_TC3_unlock}   skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Check If Alarm Appeared for NRCELL2_tc1
    [Documentation]    This keyword is used to check if alarm appeared
    [Arguments]    ${fault_id}    ${configObjectName_id}
    CoamAdmin.Setup Admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a6     timeout=120
    @{alarms}=    CoamAdmin.Get Active Alarms    connection=a6    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
         ${fault}=    Get From Dictionary    ${alarm}    faultId
         Append To List    ${active_fault_list}    ${fault}    #${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    #${fault_id} is a string,it must be changed to number
    List Should Contain Value    ${active_fault_list}    ${fault_id}

    ${count}=    Count Values In List     ${active_fault_list}      ${fault_id}
     @{active_fault_list_1}=    Create List
    FOR    ${configObjectName}   IN    @{alarms}    # get list right, must @
         ${configObjectName}=    Get From Dictionary    ${configObjectName}    configObjectName

         Append To List    ${active_fault_list_1}   ${configObjectName}   #${fault} is a number,not a string
    END
     Get Matches   ${active_fault_list_1}    *${configObjectName_id}*
    [Teardown]    CoamAdmin.Teardown Admin     connection=a6

Check If Alarm Disappeared_tc2
    [Documentation]    This keyword is used to check if alarm disappeared
    [Arguments]    ${fault_id}
    CoamAdmin.Setup Admin  bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}     name=a7     timeout=120
    @{alarms}=    CoamAdmin.Get Active Alarms     connection=a7    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
         ${fault}=    Get From Dictionary    ${alarm}    faultId
         Append To List    ${active_fault_list}    ${fault}    #${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    #${fault_id} is a string,it must be changed to number
    List Should Not Contain Value    ${active_fault_list}    ${fault_id}
    [Teardown]    CoamAdmin.Teardown Admin         connection=a7
