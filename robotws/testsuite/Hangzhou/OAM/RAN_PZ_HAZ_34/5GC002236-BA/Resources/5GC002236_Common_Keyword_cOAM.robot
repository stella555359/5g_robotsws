*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py  WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Library           taf.pdu    WITH NAME    pdu
Library           taf.ul.oam.netact.cm     WITH NAME     netact_cm
Library           XML   use_lxml=True    WITH NAME    myxml
Library           taf.config.scf    WITH NAME    scf

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ue_type}    ${tl.ues[0].capabilities[1]}

${tmp_log_dir}    /home/ute/log
${testline}  7_5_UTE5G401T908
${scf_name}    5GC000159_scf.xml

${NETACT_USERNAME}=   omc
${NETACT_PASSWORD}=   Nokia126_

${Template_SCF}=     <?xml version="1.0" encoding="UTF-8"?>
...   <!DOCTYPE raml SYSTEM 'raml20.dtd'>
...   <raml version="2.0" xmlns="raml20.xsd">
...     <cmData type="plan" scope="all" name="SCF_Template" id="SCF_conf">
...       <header>
...         <log dateTime="2020-02-13T09:44:55.000+08:00" action="created" appInfo="ActualExporter">InternalValues are used</log>
...       </header>
...       <managedObject class="CMD" version="MNL5GC19B_1911_003" distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1" operation="create">
...       </managedObject>
...       <managedObject class="HWRESETREQ" version="MNL5GC19B_1911_003"
...    distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1/HWRESETREQ-1111" operation="create">
...         <p name="hwResetComment">Reset by Robot</p>
...       </managedObject>
...     </cmData>
...   </raml>

${Template_SCF_RMOD_Lock}=     <?xml version="1.0" encoding="UTF-8"?>
...   <!DOCTYPE raml SYSTEM 'raml20.dtd'>
...   <raml version="2.0" xmlns="raml20.xsd">
...     <cmData type="plan" scope="all" name="SCF_Template" id="SCF_conf">
...       <header>
...         <log dateTime="2020-02-13T09:44:55.000+08:00" action="created" appInfo="ActualExporter">InternalValues are used</log>
...       </header>
...       <managedObject class="com.nokia.srbts.eqm:RMOD" version="MNL5GC19B_1911_003"
...    distName="PLMN-PLMN/MRBTS-xxxx/EQM-1/APEQM-1/RMOD-1" operation="update">
...       </managedObject>
...     </cmData>
...   </raml>

${Template_SCF_Cell_Lock}=     <?xml version="1.0" encoding="UTF-8"?>
...   <!DOCTYPE raml SYSTEM 'raml20.dtd'>
...   <raml version="2.0" xmlns="raml20.xsd">
...     <cmData type="plan" scope="all" name="SCF_Template" id="SCF_conf">
...       <header>
...         <log dateTime="2020-02-13T09:44:55.000+08:00" action="created" appInfo="ActualExporter">InternalValues are used</log>
...       </header>
...       <managedObject class="com.nokia.srbts.eqm:NRCELL" version="MNL5GC19B_1911_003"
...    distName="PLMN-PLMN/MRBTS-xxxx/NRBTS-3171/NRCELL-1" operation="update">
...       </managedObject>
...     </cmData>
...   </raml>

${Template_SCF_DU_Reset}=     <?xml version="1.0" encoding="UTF-8"?>
...   <!DOCTYPE raml SYSTEM 'raml20.dtd'>
...   <raml version="2.0" xmlns="raml20.xsd">
...     <cmData type="plan" scope="all" name="SCF_Template" id="SCF_conf">
...       <header>
...         <log dateTime="2020-02-13T09:44:55.000+08:00" action="created" appInfo="ActualExporter">InternalValues are used</log>
...       </header>
...       <managedObject class="CMD" version="MNL5GC19B_1911_003" distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1" operation="create">
...       </managedObject>
...       <managedObject class="SWRESETREQ" version="MNL5GC19B_1911_003"
...    distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1/SWRESETREQ-111" operation="create">
...       </managedObject>
...     </cmData>
...   </raml>

*** Keywords ***
Prepare UE only once
    log to console      Prepare UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
UE Call And Check TP

    log to console      UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    log to console      Start traffic
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=40M    duration=1100    ue_type=${ue_type}    iperf_type=via_command
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=200M    duration=1100    ue_type=${ue_type}
    sleep    30s
    Get ul and dl peak and ave throughput and return result
    Check Call Is Up by Throughput
    log to console      Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    log to console      UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}


Check Call Is Up by Throughput
    log to console      Check throughput
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
    Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}

Get ul and dl peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Confirm cell status is locked
    &{Cell_locked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_Locked}    set variable    ${Cell_locked}[Status]
    should be equal    ${Cell_Locked}[Operational state]    Disabled    ignore_case=True
    should be equal    ${Cell_Locked}[Procedural status]    initialization required    ignore_case=True
#    should be equal    ${Cell_Locked}[Availability status]    offline   ignore_case=True
    should be equal    ${Cell_Locked}[Administrative state]    Locked    ignore_case=True

Confirm cell status is unlocked
    &{Cell_locked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_Locked}    set variable    ${Cell_locked}[Status]
    should be equal    ${Cell_Locked}[Operational state]    Enabled    ignore_case=True
    should be equal    ${Cell_Locked}[Procedural status]    configured    ignore_case=True
#    should be equal    ${Cell_Locked}[Availability status]    Online   ignore_case=True
    should be equal    ${Cell_Locked}[Administrative state]    Unlocked    ignore_case=True

Conect to DU COAM
    [Arguments]    ${connection}=DU_COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

Get Active Alarms
    @{alarm_list_details}    admin_cli.get_active_alarms    connection=DU_COAM
    ${act_alarm_length}    admin_cli.get_active_alarms_number    connection=DU_COAM
    @{act_alarm_ID_list}    Create List
    FOR    ${alarm}    IN    @{alarm_list_details}
        Append To List    ${act_alarm_ID_list}    ${alarm["alarmId"]}
    END
    set suite variable    @{act_alarm_ID_list}
    set suite variable    ${act_alarm_length}

Check Active Alarms
    ${current_alarm_length}    admin_cli.get_active_alarms_number    connection=DU_COAM
    @{current_alarm_list_details}    admin_cli.get_active_alarms    connection=DU_COAM
    FOR    ${alarm}    IN    @{current_alarm_list_details}
        Should be true    ${alarm["alarmId"]} in ${act_alarm_ID_list}
    END

5GC002236_Common Suite Setup for COAM
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC002236_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId

5GC002236_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

5GC002236_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=DU_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

5GC002236_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC002236_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=DU_OAM    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=DU_OAM

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=DU_OAM
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

DU RU Reset
    log to console      DU RU Reset
    selenium_coam.enable_virtual_display
    selenium_coam.login               url=https://${DU_OAM_IP}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    selenium_coam.disable_screen_lock
    selenium_coam.reset_ru
    [Teardown]          selenium_coam.logout

Check If BTS Is OnAir
    log to console      Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=DU_OAM
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Check Active Alarms in DU
    log to console      Check Active Alarms in DU
    Conect to DU COAM
    Get Active Alarms

Wait for BTS OnAir
    log to console      Wait for BTS OnAir
    wait until keyword succeeds     10min    1min    Check If BTS Is OnAir

NetAct Lock RU
    log to console    Lock RU via NetAct
    Generate Netact plan file for RMOD Lock Unlock    new_plan_file=SCF_${mrbtsId}.xml   Value=0   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct Unlock RU
    log to console    Unlock RU via NetAct
    Generate Netact plan file for RMOD Lock Unlock    new_plan_file=SCF_${mrbtsId}.xml   Value=2   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct RMOD Reset
    log to console    Reset RMOD via NetAct
    Generate Netact plan file for RMOD Reset    new_plan_file=SCF_${mrbtsId}.xml   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct Lock Cell
    log to console    NetAct Lock Cell
    Generate Netact plan file for Cell Lock Unlock    new_plan_file=SCF_${mrbtsId}.xml   Value=1   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct Unlock Cell
    log to console    NetAct Unlock Cell
    Generate Netact plan file for Cell Lock Unlock    new_plan_file=SCF_${mrbtsId}.xml   Value=2   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct DU Reset
    log to console    NetAct DU Reset
    Generate Netact plan file for DU Reset   new_plan_file=SCF_${mrbtsId}.xml   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

Generate Netact plan file for RMOD Lock Unlock
    [Arguments]      ${new_plan_file}    ${Value}    ${Version}

        ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/EQM-1/APEQM-1/RMOD-1"]

         ${root}=        myxml.Parse XML    ${Template_SCF_RMOD_Lock}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1    xpath=${mo_xpath}
         myxml.Add Element	           ${root}   <p name="administrativeState">${Value}</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1"]
         Save XML  ${root}  ${epc_log_path}/${new_plan_file}

Generate Netact plan file for RMOD Reset
    [Arguments]      ${new_plan_file}    ${Version}

         ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1"]
         ${root}=        myxml.Parse XML    ${Template_SCF}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1    xpath=${mo_xpath}

         ${sub_mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1/HWRESETREQ-1111"]
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${sub_mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1111    xpath=${sub_mo_xpath}
         myxml.Add Element	           ${root}   <p name="targetHwResetUDN">MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1111"]
         myxml.Save XML  ${root}  ${epc_log_path}/${new_plan_file}

Generate Netact plan file for Cell Lock Unlock
    [Arguments]      ${new_plan_file}    ${Value}    ${Version}

        ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/NRBTS-3171/NRCELL-1"]

         ${root}=        myxml.Parse XML    ${Template_SCF_Cell_Lock}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-3171/NRCELL-1    xpath=${mo_xpath}
         myxml.Add Element	           ${root}   <p name="administrativeState">${Value}</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-3171/NRCELL-1"]
         Save XML  ${root}  ${epc_log_path}/${new_plan_file}

Generate Netact plan file for DU Reset
    [Arguments]      ${new_plan_file}    ${Version}

         ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1"]
         ${root}=        myxml.Parse XML    ${Template_SCF_DU_Reset}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1    xpath=${mo_xpath}

         ${sub_mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1/SWRESETREQ-111"]
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${sub_mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-111    xpath=${sub_mo_xpath}
         myxml.Add Element	           ${root}   <p name="swResetLevel">0</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-111"]
         myxml.Save XML  ${root}  ${epc_log_path}/${new_plan_file}

Connect to Netact
     netact_cm.connect_to    hostname=${NetAct_dmgr}
     ...                     username=${NETACT_USERNAME}
     ...                     password=${NETACT_PASSWORD}

Disconnect from Netact
    [Timeout]           30 seconds
     netact_cm.disconnect

Netact CM Upload
    [Timeout]  3 minutes
    netact_cm.upload    bts_dist_name=MRBTS-${mrbts_id}

Netact CM Import
    [Timeout]  3 minutes
    netact_cm.import_plan    path_to_file=${epc_log_path}/SCF_${mrbts_id}.xml     planname=SCF_${mrbts_id}

Netact Provision Plan
    [Timeout]  3 minutes
    netact_cm.provision    plan_name=SCF_${mrbts_id}

Netact Remove Plan
    [Timeout]  3 minutes
    netact_cm.remove_plan    plan_name=SCF_${mrbts_id}

Admin Get MO Version
    [Arguments]   ${dist_name}
    scf.load_scf    file_path=${epc_log_path}/${scf_name}
    ${version}   scf.get_mo_attribute    dist_name=${dist_name}   attribute=version
    [Return]     ${version}
