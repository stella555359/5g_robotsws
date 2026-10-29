*** Settings ***
Force Tags    PY36
Documentation    Suite description
Suite Setup           Setup Suite
Suite Teardown        Teardown Suite
Library               OperatingSystem
Library               taf.transport.ssh		                WITH NAME	 ssh
Library               taf.sbts.oam.coam.admin    WITH NAME    coam
Library               taf.fdsw.rc                            WITH NAME  fdswrc

*** Variables ***
${ASIK_IP}            192.168.255.129


*** Test Cases ***
5GC000829_A_004_Connections_to_dual-core_gNB_on_Second_UTE
    [Tags]  TC004
    KW.SSHtoLMP
    KW.WebEMLogin    IP=192.168.255.119
    KW.WebEMLogOut

5GC000829_105
    [Tags]  105
    KW.CollectSnapshotAndEnableSSh
5GC000829_104
    [Tags]  secondaryfallback
    KW.TriggerSecondaryCoreFallBack

5GC000829_C_004_Secondary_core_Recovery_reset_after_inter-core_connection_restored
    [Tags]    C-004
    [Teardown]  KW.DeleteSnapLog
    ssh.Connect to    192.168.255.119    toor4nsn    oZPS0POrRieRtu    alias=tmpConn
    ssh.Execute    command=ip link set dev etha01.212 down    connection=tmpConn
    ssh.disconnect    connection=tmpConn
    sleep    240s
    ${result}    run    command=ping 192.168.255.119 -c 30
    Should Contain    ${result}    Destination Host Unreachable

    sleep    5min
    wait until keyword succeeds    20min    1min    KW.VerifyAllCellsAreOnline    IP=192.168.255.119
    ${snapshot_file}    KW.CollectSnapshot
    Run Keyword And Ignore Error    run    command=mkdir /home/ute/snapshot ; cp ${snapshot_file} /home/ute/snapshot
    KW.Check_Snapshot_Log    check_value_1011=2011_part_1.zip    check_value_2011=2021_part_1.zip

5GC000829_A_Common_action_of_secondary_gNB_uncommision
    [Tags]  Unconmission
    KW.UnCommisionAirScale

5GC000829_A_Common_action_of_secondary_gNB_uncommision1
    [Tags]  Unconmission1
    KW.UnCommision

5GC000829_A_Common_action_of_secondary_gNB_commision
    [Tags]  Conmission
    KW.CommisionToSingleCore

Reboot_Secondary_Core
    [Tags]  RebootGnb
    KW.RebootSecondaryCore

Check File
    [Tags]  CheckFile
    ${snapshot_file}    KW.CollectSnapshot
    Should Not Contain   ${snapshot_file}   MRBTS

Activate_SBTS_Package_Secondary_Core_After_Configuration_Reset
    [Tags]  Upgrade2ndcore
    KW.upgradeSecondaryCore


*** Keywords ***
Setup Suite
    run keyword if    '${isCommonBuild}'=='true'
    ...  Import Library    taf.selenium.sbts    WITH NAME    selenium_coam
    ...  ELSE    Import Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam

Teardown Suite
    Run Keyword And Ignore error     KW.Kill Xvfb in UTE
    Run Keyword And Ignore error     run    commond=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver

KW.DeleteSnapLog
    Run Keyword And Return Status    run    command=cd /home/ute/
    Run Keyword And Return Status    run    command=rm -rf ./snapshot/

KW.Kill Xvfb in UTE
    ${Xvfb_Cnt}  run  command=ps -ef | grep -i Xvfb |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
    FOR    ${i}    IN RANGE    ${Xvfb_Cnt}
        ${PID1}  run  command=ps -ef|grep -i Xvfb|awk '{{print $2}}'|head -n 1
        Log  message=Killing ${i+1}st Xvfb process with PID ${PID1}.
        run  command=/bin/kill -9 ${PID1.strip()}
    END
    run  command=ps -ef | grep -i Xvfb |grep -v grep

KW.RebootSecondaryCore
    ssh.Connect to    192.168.255.119    toor4nsn    oZPS0POrRieRtu    alias=tmpConn
    #ssh.Execute    reboot    connection=tmpConn
    ssh.Execute    ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN    connection=tmpConn
    ssh.disconnect    connection=tmpConn

KW.TriggerSecondaryCoreFallBack
    ssh.Connect to    192.168.255.119    toor4nsn    oZPS0POrRieRtu    alias=tmpConn
    ssh.Execute    command=ddal -s ddal_boot_set_reset_loop_count 3    connection=tmpConn
    #ssh.Execute    reboot    connection=tmpConn
    ssh.Execute    ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN    connection=tmpConn
    ssh.disconnect    connection=tmpConn

KW.CollectSnapshotAndEnableSSh
    Wait Until Keyword Succeeds   15min   1min     KW.WebEMLogin    IP=192.168.255.119
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Should Contain   ${snapshot_file}   MRBTS
    log    COAM.EnableSSH
    run keyword and ignore error    selenium_coam.enable_ssh_service
    KW.SSHtoLMP
    KW.WebEMLogOut
    [Return]    ${snapshot_file}

KW.CollectSnapshot
    KW.WebEMLogin    IP=192.168.255.119
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    KW.WebEMLogOut
    [Return]    ${snapshot_file}

KW.Check_Snapshot_Log
    [Arguments]    ${check_value_1011}     ${check_value_2011}
     ${result}    run    command=unzip -o /home/ute/snapshot/Snapshot*.zip
     should contain     ${result}    snapshot_file_list.txt
     ${value}     run    command=cat snapshot*.txt
     should contain     ${value}    ${check_value_1011}
     should contain     ${value}    ${check_value_2011}

KW.SSHtoLMP
    ssh.Connect to    192.168.255.119    toor4nsn    oZPS0POrRieRtu    alias=tmpConn
    ssh.disconnect    connection=tmpConn

KW.WebEMLogin
    [Arguments]   ${IP}
    run keyword and ignore error    selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=https://${IP}    username=Nemuadmin    password=nemuuser
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

KW.WebEMLogOut
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
    selenium_coam.logout
    run keyword and ignore error   selenium_coam.disable_virtual_display

KW.COAMAdminLogin
    coam.connect_to
    ...   bts_host=192.168.255.129
    ...   username=Nemuadmin
    ...   password=nemuuser
    ...   use_ssl=${True}
    ...   name=COAM

KW.COAMAdminLogout
    [Arguments]   ${connection}=COAM
    coam.teardown      connection=${connection}

KW.UnCommisionAirScale
    ${ret}  Run Keyword and Return Status  ssh.Connect to    hostname=192.168.255.129    username=toor4nsn
    ...                                    password=oZPS0POrRieRtu    alias=tmpConn
    ${mode}    Run Keyword If     ${ret}    Run Keywords
    ...                                     KW.WebEMLogin    IP=192.168.255.129
    ...                                     AND  selenium_coam.configuration_reset

KW.UnCommision
    ssh.Connect to    hostname=192.168.255.119    username=toor4nsn    password=oZPS0POrRieRtu    alias=tmpConn
    #KW.Connect_To_GNB    hostname=192.168.255.119    alias=${ALIAS_ASIK}
    ssh.send command    command=cd /rom/config&&rm -rf *&&ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN  connection=tmpConn
    #ssh.send command    command=cd /rom/config&&rm -rf *.*&&reboot  connection=tmpConn
    Run Keyword And Ignore Error    ssh.disconnect    connection=${ALIAS_ASIK}

KW.CommisionToSingleCore
    #KW.UnCommisionAirScale
    wait until keyword succeeds    15min   1min     KW.WebLoginWithoutSync
    run keyword and ignore error    selenium_coam.enable_ssh_service
    Set test variable    ${version}    ${AF_PATH}
    run keyword if    ${version.count('SBTS')}>${0}    run keywords
    ...    selenium_coam.continue_after_plug_and_play_modal_appear
    ...    AND  selenium_coam.load_commissioning_file_and_check_load_status    file_path=/tmp/TestLineSCF1Cell_Both_right.xml
    ...    AND  selenium_coam.validate_plan
    ...    AND  selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE    run keywords
    ...    selenium_coam.load_commissioning_file_and_check_load_status    file_path=/tmp/TestLineSCF1Cell_Both_right.xml
    ...    AND  selenium_coam.validate_plan
    ...    AND  selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3min
    wait until keyword succeeds    15min   1min     KW.VerifyAllCellsAreOnline    IP=192.168.255.129

KW.WebLoginWithoutSync
    [Arguments]    ${virtual_enable}=${TRUE}
     ${action}    Create Dictionary  modal_name=Additional hardware detected   button=close
     ${action_list}    Create List  ${action}
     run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
     run keyword and ignore error    selenium_coam.logout
     selenium_coam.login    url=https://192.168.255.129    username=Nemuadmin    password=nemuuser
     ...    modal_action_configurations=${action_list}
     selenium_coam.disable_message_box
     selenium_coam.disable_screen_lock
     sleep    15s
     ${res}    selenium_coam.start_up_view_window_exists
     run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

KW.VerifyAllCellsAreOnline
    [Documentation]   This kw is to check all cells are online in COAM
    [Arguments]    ${IP}
    KW.WebEMLogin    IP=${IP}
#    selenium_coam.login    url=https://${IP}    username=Nemuadmin    password=nemuuser
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${CellNum}
        ${Idx}    Evaluate     1+${i}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${Idx}
        log    ${cell_info} and ${cell_info['Status']['Operational state']}
        Should Be Equal As Strings    ${cell_info["Status"]["Operational state"]}    Enabled    ignore_case=${True}
    END
    selenium_coam.logout

KW.upgradeSecondaryCore
    wait until keyword succeeds     30min    1min    gNB.Activate_SBTS_Package_After_Configuration_Reset    ip_address=192.168.255.129

gNB.PingOAM
    [Arguments]    ${IP}=${ASIK_IP}
    ${result}  run   command=ping ${ASIK_IP} -c 10
    should contain    ${result}    64 bytes from ${IP}

gNB.Activate_SBTS_Package_After_Configuration_Reset
    #[Arguments]    ${ip_address}   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser  ${fdsw_version}=fdsw21c
    [Arguments]    ${ip_address}   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    wait until keyword succeeds     10min    30s     fdswrc.connect to    ip_address=${ip_address}   port=${port}    username=${username}
    ...    password=${password}   auto_discover=${auto_discover}    secure=${secure}    name=${name}
    ${activeslot_id}    fdswrc.get_active_sw_partition
    ${reset_option}    fdswrc.get_available_reset_options    slot_id=${activeslot_id}
    fdswrc.software_rollback    sw_slot_id=${activeslot_id}    reset_type=${reset_option[3]}
    sleep    180s
    wait until keyword succeeds     10min    30s    gNB.PingOAM    IP=${ip_address}


KW.SuiteSetup
    Log    Suite start

KW.SuiteTeardown
    Log    Suite teardown

KW.CaseSetup
    Log    Case start

KW.CaseTeardown
    Log    Case Teardown

