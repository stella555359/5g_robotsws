*** Settings ***

Documentation   :copyright: Nokia
...             :authors: Priya Bakshi
...             :contact: Priya.Bakshi@nokia.com
...             TEST SET NAME:    CB013880
...             TESTING SPLIT:    Refer CB013880 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013880_CFAM



Library        ute_wtssim
Library        ta5g_commissioning
Library        ute_fsmaccess
Library        ta5g_file_system
Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_testline_management
Variables        ta5g_global_var
Library           OperatingSystem
Library           Telnet
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ul.ue.sim.env_setup
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Library         ta5g_egate
Library         Process
Library         Collections
Library         taf.collectors.tshark          WITH NAME    tshark
Library         taf.collectors.l2stream3       WITH NAME    ttistream
Library         taf.sbts.oam.coam.admin        WITH NAME    CoamAdmin
Library         taf.transport.ssh              WITH NAME    taf_ssh
Library         taf.wts.runner              WITH NAME    wtsrunner
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sw.wtssim
Library         taf.ue.airphone
Library         taf.config.scf
Library         ta_emss
Library         ta5g_tshark
Library         ta5g_pm_counters
Library         String
Library         file_operation.py



*** Variables ***
@{REMOTE_HOSTS}
${scf_folder}       ${CURDIR}/../config/scf/
${bsr_iphy_folder}     ${CURDIR}/../config/
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_folder}     ${CURDIR}/../config/wts
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts


*** Keywords ***

perform delta and add 3rd slice
   CoamAdmin.Setup Admin     bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a8
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_add_slice3}    skip_parameter_relation_errors=True
    ...      connection=a8
    CoamAdmin.Teardown admin      connection=a8

perform delta and delete 3rd slice
   CoamAdmin.Setup Admin     bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a9
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_delete_slice3}    skip_parameter_relation_errors=True
    ...      connection=a9
    CoamAdmin.Teardown admin      connection=a9

Disable feature
    CoamAdmin.Setup Admin     bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a5
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_decommission}    skip_parameter_relation_errors=True
    ...      connection=a5
    CoamAdmin.Teardown admin      connection=a5

Enable feature
    CoamAdmin.Setup Admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=ABC
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_commission}    skip_parameter_relation_errors=True
    ...      connection=ABC
    CoamAdmin.Teardown admin      connection=ABC

Check If Alarm Disappeared_tc7
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

Check If Alarm Appeared for NRCELL5_tc9
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

Check If Alarm Appeared for NRCELL6_tc9
    [Documentation]    This keyword is used to check if alarm appeared
    [Arguments]    ${fault_id}    ${configObjectName_id}
    CoamAdmin.Setup Admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a10     timeout=120
    @{alarms}=    CoamAdmin.Get Active Alarms    connection=a10    #both $ and @ are OK
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
    [Teardown]    CoamAdmin.Teardown Admin     connection=a10

Check If Alarm Appeared for NRCELL6_tc7
    [Documentation]    This keyword is used to check if alarm appeared
    [Arguments]    ${fault_id}     ${configObjectName_id}
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


block cells
    CoamAdmin.Setup Admin     bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}     name=a2
    CoamAdmin.Setup Admin     bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}     name=a3
    CoamAdmin.Setup Admin     bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}     name=a4
    CoamAdmin.block_cell     dist_name=MRBTS-3/NRBTS-3/NRCELL-6   connection=a2
    CoamAdmin.block_cell     dist_name=MRBTS-3/NRBTS-3/NRCELL-7   connection=a3
    CoamAdmin.block_cell     dist_name=MRBTS-3/NRBTS-3/NRCELL-8   connection=a4
    CoamAdmin.teardown_all_aliases_for_admin


unblock cell-6
    CoamAdmin.Setup Admin      bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a1
    CoamAdmin.unblock_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-6    connection=a1
    CoamAdmin.Teardown admin      connection=a1

Initiate sgnb addition
    wtsrunner.ue_meas_cfg_disp    id=1
    sleep    2s
    wtsrunner.ue_measurement_send_nr    id=1    meas_id=1    event=A4    phycell_id=52    nrsrp_nr=80
    sleep    2s

detach_ue_with_power_off
    [Arguments]  ${ue_id}=1
    wtsrunner.ue_deregister   id=${ue_id}   ue_deregister_type=switch_off
    log to console  \nUE-${ue_id} Detached!


Register UE and start data traffic
         wtsrunner.ue_register    id=1
         sleep    2s
   	     wtsrunner.set_pdu_param    ue=1  pdu=1    trf_type=internal
   	     sleep    10s
         wtsrunner.ue_pdu_session_setup    pdu=1    ue=1    nwslice=1  gw=1
         sleep   2s
         wtsrunner.trf_data_start    ue=1    pdu=1    dir=dl    mbps=5
         wtsrunner.trf_data_start    ue=1    pdu=1    dir=ul    mbps=5
         sleep   5s


Check SIB messagges for all cells
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated

Kill WTS processes Using WTS_Runner
    wtsrunner.kill_wtsemu_edaemon    edaemon_port=10000   connection=${WTS.Connection}    sudo_password=ute
    sleep      5s
    wtsrunner.kill_wtsemu_egate      egate_port=20000     connection=${WTS.Connection}    sudo_password=ute


Run cfg file
    [Arguments]    ${wts_cfg_file_TC1}
    Stop Edaemon and Egate process
    Stop Sim_enb
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=10000
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000

    wtsrunner.configure                   file=${wts_cfg_file_TC1}
    Sleep    90s
    wtsrunner.Gnb Param    id=3    xn_listening_socket=1    send_xn_setup=true
    wtsrunner.Gnb Xn Link Up    gnb=3    target=2
    sleep    30s

Check If Alarm Appeared for NRCELL5_tc8
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


Check If Alarm Appeared for NRCELL6_tc8
    [Documentation]    This keyword is used to check if alarm appeared
    [Arguments]    ${fault_id}    ${configObjectName_id}
    CoamAdmin.Setup Admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=a8     timeout=120
    @{alarms}=    CoamAdmin.Get Active Alarms    connection=a8    #both $ and @ are OK
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
    [Teardown]    CoamAdmin.Teardown Admin     connection=a8


Configure Routes in WTS

     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.132/24 dev eth3
     Run    sudo ip addr add 10.0.1.133/24 dev eth3
     Run    sudo ip addr add 10.0.1.134/24 dev eth3
     Run    sudo ip addr add 10.0.1.135/24 dev eth3
     Run    sudo ip addr add 10.0.1.136/24 dev eth3
     Run    sudo ip addr add 10.0.1.137/24 dev eth3
     Run    sudo ip addr add 10.0.1.138/24 dev eth3
     Run    sudo ip addr add 10.0.1.112/24 dev eth3
     Run    sudo ip addr add 10.0.1.101/24 dev eth3
     Run    sudo ip addr add 10.0.1.102/24 dev eth3
     Run    sudo ip addr add 10.0.1.140/24 dev eth3


Run cfg file_1

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


Delta file commissioning to delete slices

    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_slice_deletion}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to add 2000 slices
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning   delta_file=${delta_configuration_slice_addition}   skip_parameter_relation_errors=True   timeout=500
    CoamAdmin.Teardown admin

Delta file commissioning to add 2nd PLMN and TAC
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_PLMN_TAC_addition}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to Lock 1999 slices
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_Lock_1999_Slices}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to add 2 SNSSAI
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${Delta_Configuration_2SNSSAI_addition}     skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file commissioning to lock slices-1
    Send Delta Commissioning    ${Delta_Configuration_slice-1_lock}    skip_relation_errors=True

Delta file commissioning to add 5-SNSSAI
    Send Delta Commissioning    ${Delta_Configuration_5_addition}    skip_relation_errors=True

Delta file commissioning to add SNSSAI to amf
    Send Delta Commissioning    ${Delta_Configuration_SNSSAI_1_addition_amf}

Delta file commissioning to remove 2-SNSSAI
    Send Delta Commissioning    ${Delta_Configuration_SNSSAI_1_removal}

Delta file commissioning to remove 1_3-SNSSAI
    Send Delta Commissioning    ${Delta_Configuration_SNSSAI_1_3_removal}

Delta file commissioning to enable feature flag & Add slices
    Send Delta Commissioning    ${Delta_Configuration_feature_enable_2slices}

Delta file commissioning to lock 2 slices
    Send Delta Commissioning    ${Delta_Configuration_lock_2_slices}

Delta file commissioning to disable feature flag
     Send Delta Commissioning    ${Delta_Configuration_feature_disable}

Delta_Configuration_undo_changes
     Send Delta Commissioning    ${Delta_Configuration_undo_changes}

Delta file commissioning to lock slices-3
    Send Delta Commissioning    ${Delta_Configuration_slice-3_lock}

Delta file commissioning to lock slices-1_3
    Send Delta Commissioning    ${Delta_Configuration_slice-1_3_lock}

Delta file commissioning to change sd and unlock slices-3
    Send Delta Commissioning    ${Delta_Configuration_slice-3_unlock}

Delta file commissioning to change sd and unlock slices-1
    Send Delta Commissioning    ${Delta_Configuration_slice-1_unlock}

Delta file commissioning to change sd and unlock slices-1_3
    Send Delta Commissioning    ${Delta_Configuration_slice-1_3_unlock}

Delta file commissioning to re-change sd and unlock slices-1
    Send Delta Commissioning    ${Delta_Configuration_reslice-1_unlock}

undo scf changes
    Send Delta Commissioning    ${Delta_Configuration_undo_TC6}


Syslog stop
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    taf.sw.syslog.teardown_all_aliases_for_syslog


Start Tshark on eth3
      start_tshark   log_filename=CB013880_ABC.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC

Stop Tshark on eth3
     stop_tshark     alias=ABC

Start Tshark on eth3_1
      start_tshark   log_filename=CB013880_ABC_1.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC_1

Stop Tshark on eth3_1
     stop_tshark     alias=ABC_1

Verfy SNSSAI update for SNSSAI removal

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.tAC == 100 && ngap.sD == d1:43:a6 && ngap.sD == d1:43:a7 == 1
           ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a5

 Verfy SNSSAI update for SNSSAI removal TC6

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.tAC == 100 && ngap.sD == d1:43:a8 && ngap.sD == d1:43:a9 == 1
           ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a5 && ngap.sD == d1:43:a7 == 1
           ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a6

Verfy SNSSAI update for SNSSAI-1_3 removal TC6

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.tAC == 100 && ngap.sD == d1:43:a8 && ngap.sD == d1:43:a9 == 1
           ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a5
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a6
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a7


Verfy SNSSAI update for SNSSAI addition

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.tAC == 100 && ngap.sD == d1:43:a6 && ngap.sD == d1:43:a7 == 1
           ...    number_of_messages=1    alias=ABC
      Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=ngap.tAC == 200 && ngap.sD == d1:43:a5

Verify all cells barred except cell-8
    ${1}=    taf.sw.syslog.count_syslog_messages   alias=feat_act
    ...    regexp=cells barred: [16385, 16386, 16387, 16388, 16389, 16390, 16391, 16393, 16394, 16395, 16396]
	Should be True     ${1} == 1


Check If Alarm Appeared
    [Documentation]    This keyword is used to check if alarm appeared
    [Arguments]    ${fault_id}    ${supplAlarmInfo_id}    ${alarmAttribute}
    CoamAdmin.Setup Admin    timeout=120
    @{alarms}=    CoamAdmin.Get Active Alarms    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
         ${fault}=    Get From Dictionary    ${alarm}    faultId
         Append To List    ${active_fault_list}    ${fault}    #${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    #${fault_id} is a string,it must be changed to number
    List Should Contain Value    ${active_fault_list}    ${fault_id}
    ${count}=    Count Values In List     ${active_fault_list}      ${fault_id}

     @{active_fault_list_1}=    Create List
    FOR    ${supplAlarmInfo}   IN    @{alarms}    # get list right, must @
         ${slices_no}=   Run Keyword And Ignore Error    Get From Dictionary    ${supplAlarmInfo}    supplAlarmInfo
         Append To List    ${active_fault_list_1}   ${slices_no}
    END
      Get Matches    ${active_fault_list_1}   *${supplAlarmInfo_id}*

      @{active_fault_list_2}=    Create List
    FOR    ${cellidInfo}   IN    @{alarms}    # get list right, must @
         ${NR_cellid}=   Run Keyword And Ignore Error   Get From Dictionary     ${cellidInfo}    alarmAttribute
         Append To List    ${active_fault_list_2}    ${NR_cellid}
    END
     Get Matches   ${active_fault_list_2}    *${alarmAttribute}*
    [Teardown]    CoamAdmin.Teardown



Check If Alarm Disappeared
    [Documentation]    This keyword is used to check if alarm disappeared
    [Arguments]    ${fault_id}
    CoamAdmin.Setup Admin    timeout=120
    @{alarms}=    CoamAdmin.Get Active Alarms    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
         ${fault}=    Get From Dictionary    ${alarm}    faultId
         Append To List    ${active_fault_list}    ${fault}    #${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    #${fault_id} is a string,it must be changed to number
    List Should Not Contain Value    ${active_fault_list}    ${fault_id}
    [Teardown]    CoamAdmin.Teardown Admin

Check SIB messagges for all cells_TMO
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 7: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 8: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 10: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 11: SystemInformationBlockType1-NR updated


Start Tshark on eth3 after New VONR call
      start_tshark   log_filename=CB009429_ABC1.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC1



Stop Tshark on eth3 after New VONR call
     stop_tshark     alias=ABC1


syslog crash verification
#K2 DSP crash
    ${1}=    taf.sw.syslog.count_syslog_messages    regexp=faultID: 6706      alias=feat_act_2
    ${2}=    taf.sw.syslog.count_syslog_messages    regexp=faultId: 6707      alias=feat_act_2
    ${3}=    taf.sw.syslog.count_syslog_messages    regexp=faultID: 6709      alias=feat_act_2

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages  regexp=faultID: 6708      alias=feat_act_2
	${5}=    taf.sw.syslog.count_syslog_messages  regexp=faultId: 4019      alias=feat_act_2
	${6}=    taf.sw.syslog.count_syslog_messages  regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded  alias=feat_act_2
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages   regexp=faultID: 6450      alias=feat_act_2
	${8}=    taf.sw.syslog.count_syslog_messages  regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act_2
	${9}=    taf.sw.syslog.count_syslog_messages   regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=feat_act_2
    ${10}=    taf.sw.syslog.count_syslog_messages  regexp=EAaErrorFatality_Fatal      alias=feat_act_2

	Should be True     ${1} == 0
	Should be True     ${2} == 0
	Should be True     ${3} == 0
	Should be True     ${4} == 0
	Should be True     ${5} == 0
	Should be True     ${6} == 0
	Should be True     ${7} == 0
	Should be True     ${8} == 0
	Should be True     ${9} == 0
	Should be True     ${10} == 0
