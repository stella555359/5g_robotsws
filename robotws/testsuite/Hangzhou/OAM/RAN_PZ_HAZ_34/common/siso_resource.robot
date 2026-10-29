*** Settings ***
Documentation
...   author: shasha.liu
...   contact: shasha.liu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
#Library           taf.transport.ssh    WITH NAME    csn
Library           taf.pdu
Library           String
Library           Process
Library           OperatingSystem
Library           Collections

*** Variables ***
#webui
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
${WEBUI_USER}               ${tl.gnbs[0].cu.oam_http_connection_details.username}    #Nemuadmin
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}    #nemuuser

#bts id
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}

#UTE VM
${host_addr}                ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}            ${tl.test_pc.default_ssh_connection_details.username}
${host_password}            ${tl.test_pc.default_ssh_connection_details.password}

#gNB PB
${PDU_type}                  FACOM
${powerstation_ip}           ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${powerstation_port}         ${4001}
${powerstation_asik_port}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

#RU PB
${powerstation_ip_RU}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${powerstation_port_RU}       ${4001}
${powerstation_asik_port_RU}  ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

#ssh gNB
${asik_addr}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}      #toor4nsn
${asik_password}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}      #oZPS0POrRieRtu
${pb_model_gnb}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}

#ssh CapacityUnit
${CapUnit_addr}               ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}

#gNB LMP
${asik_LMP_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_LMP_username}          ${tl.gnbs[0].cu.oam_http_connection_details.username}     #Nemuadmin
${asik_LMP_password}          ${tl.gnbs[0].cu.oam_http_connection_details.password}     #nemuuser

#SWITCH Dtor
${SWITCH_IP_Dtor}            ${tl.switches[0].default_ssh_connection_details.addr}
${SWITCH_Username_Dtor}      ${tl.switches[0].default_ssh_connection_details.username}
${SWITCH_Password_Dtor}      ${tl.switches[0].default_ssh_connection_details.password}
${SWITCH_Port_Dtor}          ${tl.switches[0].default_ssh_connection_details.port}

#SWITCH Mtor
${SWITCH_IP_Mtor}            ${tl.switches[1].default_ssh_connection_details.addr}
${SWITCH_Username_Mtor}      ${tl.switches[1].default_ssh_connection_details.username}
${SWITCH_Password_Mtor}      ${tl.switches[1].default_ssh_connection_details.password}
${SWITCH_Port_Mtor}          ${tl.switches[1].default_ssh_connection_details.port}

#RU info
${ru_addr}                    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${ru_username}                ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${ru_password}                ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${ru_type_init}               ${tl.gnbs[0].dus[0].rus[0].radio_type.value}  # the 1st RU by default if mulitiple RUs used
${pb_model_ru}                ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}

*** Keywords ***
WEBUI Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}
    run keyword if     ${virtual_enable}     run keyword and ignore error    selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    run keyword and ignore error      selenium_coam.disable_message_box
    run keyword and ignore error      selenium_coam.disable_screen_lock
    sleep    10s
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

WEBUI Logout
    [Arguments]     ${virtual_disable}=${TRUE}
    selenium_coam.logout
    run keyword if      ${virtual_disable}    run keyword and ignore error    selenium_coam.disable_virtual_display

admin_login
    [Arguments]  ${connection}=admin_GNB_OAM    ${bts_host}=${asik_addr}    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

admin_logout
    [Arguments]    ${connection}=admin_GNB_OAM
    coam.teardown    connection=${connection}

Get Active SW Version Temp
    [Arguments]  ${connection}=GNB_OAM
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    ${sbts}    run keyword and return status     Should contain    ${sw_version}    SBTS
    return from keyword if    ${sbts}      ${sw_version}
    @{result}    string.split string    ${sw_version}    separator=_
    ${length}    Get Length    ${result}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     ${result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
         ${j} =    Evaluate    ${i} + ${2}
         ${build}    set variable    ${result}[${j}]
         ${build}    Run Keyword If    ${j} < 5    convert to integer    ${result}[${j}]    ELSE    set variable    ${result}[${j}]
         ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    [Return]   ${SW_vesion_tmp}

get stream from version Temp
    [Arguments]  ${version}
    ${sbts_21b}    run keyword and return status      Should Contain    ${version}    SBTS21B_ENB_0000
    return from keyword if    ${sbts_21b}    SBTS21B
    ${sbts_trunk}    run keyword and return status      Should Contain Any   ${version}    SBTS21B_ENB_9999    SBTS22R1_ENB_9999
    return from keyword if    ${sbts_trunk}    SBTS00
    ${stream_list}   String.Split String From Right    string=${version}   separator=.    max_split=1
    [Return]  ${stream_list}[0]

Check ABIL is UP
    run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    WEBUI Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    should be equal      ${output}[Availability status]     Online
    should be equal      ${output}[Procedural status]     configured

Check ASIK State
    run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    WEBUI Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIK}    selenium_coam.get_asik_info
    ${output_1}    set variable    ${output_ASIK}[Status]
    should be equal      ${output_1}[Administrative state]    Unlocked
    should be equal      ${output_1}[Availability status]     Online
    should be equal      ${output_1}[Procedural status]     configured

Check ASIB State
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIB}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIB}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled

Check ASIK is UP
    run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    WEBUI Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    ${P_name_smod}    set variable    ${output_tmp}[Product name]
    run keyword if    '${P_name_smod}' == 'ASIK AirScale Common'    Check ASIK State
    run keyword if    '${P_name_smod}' == 'ASIB AirScale Common'    Check ASIB State

Perform RUs Power Off
    admin_login
    ${ru_list}    Get list of all ru
    set test variable    ${ru_list}
    FOR    ${ru_id}    IN    @{ru_list}
          Perform RU Power Off    ru_index=${${ru_id}}    model=${tl.gnbs[0].dus[0].rus[${ru_id}-1].pdu_port.pdu.__class__.__name__}
    END
    [Teardown]  admin_logout

Perform RUs Power On
    admin_login
    ${ru_list}    Get list of all ru
    set test variable    ${ru_list}
    FOR    ${ru_id}    IN    @{ru_list}
          Perform RU Power On    ru_index=${${ru_id}}    model=${tl.gnbs[0].dus[0].rus[${ru_id}-1].pdu_port.pdu.__class__.__name__}
    END
    [Teardown]  admin_logout

#Check Cell is UP
#    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#    ${output_tmp}    selenium_coam.get_cell_info
#    ${output}    set variable    &{output_tmp}[Status]
#    should be equal      &{output}[Administrative state]    Unlocked
#    should be equal      &{output}[Availability status]     Online
#    should be equal      &{output}[Procedural status]     configured

Check Cell is UP
    [Documentation]  check all cells are on air
    admin_login
    WEBUI Login
    ${cells_list}    Get list of all cells    connection=admin_GNB_OAM
    FOR    ${cell_id}    IN    @{cells_list}
          run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
          ${output_tmp}    selenium_coam.get_cell_info    cell_idx=${cell_id}
          ${output}     set variable    ${output_tmp}[Status]
          should be equal      ${output}[Administrative state]    Unlocked
          should be equal      ${output}[Availability status]     Online
          should be equal      ${output}[Procedural status]       configured
    END
    [Teardown]  admin_logout

#check RU STATUS
##    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#    ${output_tmp}    selenium_coam.get_ru_info
#    ${RU_info}    set variable    &{output_tmp}[Status]
#    should match regexp    &{RU_info}[Operational state]    Enabled
#    should match regexp    &{RU_info}[Availability status]    Online
#    should match regexp    &{RU_info}[Administrative state]    Unlocked
#    should match regexp    &{RU_info}[Procedural status]    configured

check RU STATUS
    [Arguments]   ${expected_status}=Unlocked
    admin_login
    WEBUI Login
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
          ${output_tmp}    selenium_coam.get_ru_info     type_=RMOD_R    ru_index=${ru_id}
          ${RU_info}    set variable    ${output_tmp}[Status]
          should match regexp    ${RU_info}[Operational state]    Enabled
          should match regexp    ${RU_info}[Availability status]    Online
          should match regexp    ${RU_info}[Procedural status]    configured
          run keyword if    '${expected_status}'=='Unlocked'
          ...    should match regexp    ${RU_info}[Administrative state]    Unlocked
          ...    ELSE IF   '${expected_status}'=='Locked'
          ...    should match regexp    ${RU_info}[Administrative state]    Locked
          ...    ELSE   log to console   WRN: RU_${ru_id} status is ${RU_info}[Administrative state], not Unlocked or Locked.
    END
    [Teardown]  admin_logout

Check all RUs Disabled
    admin_login
    ${ru_list}    Get list of all ru
    set test variable    ${ru_list}
    FOR    ${ru_id}    IN    @{ru_list}
          ${output_tmp}    selenium_coam.get_ru_info    type_=RMOD_R    ru_index=${ru_id}
          ${RU_info}    set variable    ${output_tmp}[Status]
          should match regexp    ${RU_info}[Operational state]    Disabled
    END
    [Teardown]  admin_logout

lock RU via webui
    [Documentation]  lock all rus on webui
    admin_login
    WEBUI Login
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          selenium_coam.lock_ru    type_=RMOD_R  ru_index=${ru_id}
          sleep    30s
    END
    [Teardown]  admin_logout

unlock RU via webui
    [Documentation]  unlock all rus on webui
    admin_login
    WEBUI Login
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          selenium_coam.unlock_ru   type_=RMOD_R  ru_index=${ru_id}
          sleep    30s
    END
    [Teardown]  admin_logout

check gNB Staus onAir
    [Arguments]    ${dist_name}    ${search_text}
    WEBUI Login
    ${status}    selenium_coam.get_parameter_value    ${dist_name}    ${search_text}
    should be equal    ${status}    onAir

Get list of all cells
    [Arguments]    ${connection}=admin_GNB_OAM
    admin_login
    ${cells}=       coam.Get parameters for all    class_name=NRCEL   connection=${connection}
    ${cells_id}=    Create List
    FOR    ${cell}    IN    @{cells}
          ${cell_id}=          Get From Dictionary    ${cell}        configurationId
          Append To List       ${cells_id}       ${cell_id}
    END
    [Return]       ${cells_id}
    [Teardown]  admin_logout

Get list of all ru
    [Arguments]    ${connection}=admin_GNB_OAM
    admin_login
    ${rmods}    coam.get_ids_for_all    class_name=RMOD   connection=${connection}
    ${rmods_id}    Create List
    FOR    ${rmod}    IN    @{rmods}
          ${rmod_id}    Fetch From Right    ${rmod}    -
          Append To List   ${rmods_id}    ${rmod_id}
    END
    [Return]    ${rmods_id}
    [Teardown]  admin_logout

check SW version
    [Documentation]     output planned/active/passive version like:5G19_FSMK_0000_018351_000316
    [Arguments]      ${version_type}
    ${version}    selenium_coam.check_current_software_version
    ${output}    set variable    ${version}[${version_type}]
    [Return]      ${output}    ${version}

SW Version convert
    [Documentation]    Convert SW build version(e.g.: 5G19_FSMK_0000_018351_000316) get from WEBUI to x.xx.xxx (e.g.: 0.1835.316)
    [Arguments]    ${Webui_version}
    @{temp}    string.split string    ${Webui_version}     _
    ${T1}    convert to integer    ${temp}[-3]
    ${T2}    convert to integer    ${temp}[-2]
    ${T3}    convert to integer    ${temp}[-1]
    ${digit_version}  set variable  ${T1}.${T2}.${T3}
    [Return]    ${digit_version}

get CIT build
    [Documentation]   get CIT build from AF_PATH.
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    SW build with three digital segments mode
    ...    Example
    ...    | ${CIT_build} | get CIT build |
    @{Location_array}=    Split String    ${AF_PATH}     separator=/
    [Return]  ${Location_array}[-2]

Capture journal log
    [Arguments]    ${cmd}    ${alias}
    [Documentation]    Capture journal log used journal command
    ${output}    csn.execute    ${cmd}    connection=${alias}

backup commission file via WebUI
    [Documentation]   get scf from wbui and stored
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    scf file
    ...    Example
    ...    | ${scfFile} | backup commission file via WebUI | ${scfSaved_dir} |
    [Arguments]    ${scfSaved_dir}=${SAVE LOG DIRECTORY}
    ${commission_file}=    selenium_coam.backup_bts_site_configuration    download_timeout=${300}
    ${Status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${scfSaved_dir}
    Run Keyword If    '${Status}'== 'False'    OperatingSystem.Create Directory    ${scfSaved_dir}
    OperatingSystem.Copy File    ${commission_file}    ${scfSaved_dir}/scf.xml
    OperatingSystem.File Should Exist    ${scfSaved_dir}/scf.xml
    set test variable    ${scfFile}    ${scfSaved_dir}/scf.xml
    [Return]    ${scfFile}

Validate and activate and check activate plan status
    selenium_coam.validate_plan
    sleep    5s
    ${output}    selenium_coam.activate_plan
    ...    download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}
    ...    execute=${True}
    ...    timeout=${200}
    sleep    10s
    ${output}   Run Keyword And Ignore Error    selenium_coam.check_activate_plan_status
    sleep    5s

Check ASIK status with command
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/AdetS.py -s    connection=gNB
    sleep    15s
    ${output1}    csn.read output    connection=gNB
    Should Match Regexp    ${output1}    0x10.*FSM1_FCT.*ready
    Should Match Regexp    ${output1}    0x12.*FSM1_FSP1.*ready
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Turn Off PDU
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}    ${Port_Number}
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=${pdu_type}    port=${pdu_port}
    taf.pdu.power_off    port=${Port_Number}
    sleep   15s
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    should be equal    ${state}    off
    sleep    30s

Turn On PDU
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}    ${Port_Number}
    [Documentation]    5gNB is turned on and check 5GNB is in configured state.
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=${pdu_type}    port=${pdu_port}
    taf.pdu.power_on    port=${Port_Number}
    sleep    15s
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    should be equal    ${state}    on

Get BTS ID
    [Documentation]   get MRBTSID and NRBTSID offline
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    MRBTSID(e.g. 1900) and NRBTSID(e.g. 1)
    ...    Example
    ...    |${mrbts_id}|${nrbts_id}| Get BTS ID |
    Backup commission file via WebUI
    ${mrbts_id}    lib.Get_MRBTSID_cOAM    scf_path=${scfFile}
    ${nrbts_id}    lib.Get_NRBTSID_cOAM    scf_path=${scfFile}
    set suite variable     ${mrbts_id}
    set suite variable     ${nrbts_id}
    [Return]    ${mrbts_id}    ${nrbts_id}

#common keyword for siso feature based on selenium-coam
check TargetBD exist and match
    [Documentation]   verify TaretBD_*.xml file and download
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    file name: TaretBD_*.xml; save path
    ...    Example
    @{version}=    check SW version    Active
    set test variable    ${active_version}    ${version}[0]
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=gNB_target
    sleep   2s
    csn.send command    command=cd /ffs/run/;ls TargetBD_*.xml    connection=gNB_target
    ${TargetBD_FileName}=    csn.read output    connection=gNB_target
    run keyword and ignore error    csn.download file
    ...    /ffs/run/TargetBD_${active_version}.xml    ${SAVE LOG DIRECTORY}/TargetBD_${active_version}.xml
    ...    connection=gNB_target
    csn.disconnect    connection=gNB_target
    @{TargetBD_FileName}    string.split string    ${TargetBD_FileName}    separator=\
    ${TargetBD_FileName}    set variable    ${TargetBD_FileName}[0]
    should be equal as strings    '${TargetBD_FileName}'   'TargetBD_${active_version}.xml'
    ${save_path}    set variable    ${SAVE LOG DIRECTORY}
    [Return]    ${TargetBD_FileName}    ${save_path}

check RU registration info
    [Documentation]   check ru registration info in TaretBD_*.xml file
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    details about RU info matched
    ...    Example
    ...    | ${regist_info} | check RU registration info | TargetBD_5G19A_FSMK_0006_028352_000150.xml | AWHQG |
    [Arguments]    ${TargetBD_FileName}    ${radio_type}=${ru_type_init}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=RegistRU
    sleep   2s
    csn.send command    command=cd /ffs/run/;grep -o ${radio_type} /ffs/run/${TargetBD_FileName}|wc -l    connection=RegistRU
    ${output_grep}=    csn.read output    connection=RegistRU
    ${output_grep}=    convert to integer    ${output_grep}
    should be true    ${output_grep}>=4
    csn.send command    command=cd /ffs/run/;find /ffs/run/${TargetBD_FileName}|xargs grep ${radio_type}    connection=RegistRU
    ${regist_info}=    csn.read output    connection=RegistRU
    csn.disconnect    connection=RegistRU
    [Return]    ${regist_info}

get BPF gz fileName
    [Documentation]   get BPF .gz file name
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    BPF .gz file name
    ...    Example
    ...    | ${bpf_gzfileName} | get BPF gz fileName | AWHQG |
    [Arguments]   ${radio_type}=${ru_type_init}
    ${outPut}    selenium_coam.get_ru_info
    set test variable    ${prodName_str}    ${outPut}[Product name]
    set test variable    ${prodCode_str}    ${outPut}[Product code]
    run keyword and ignore error    should be equal as strings    ${prodName_str}    ${radio_type}
    ...    msg=Warning: RU not matched with your ENV!    ignore_case=true
    set test variable    ${prodName_str}    ${radio_type}
    ${prodName_str}=    convert to uppercase    ${prodName_str}
    ${prodName_tmp0}    string.get substring    ${prodName_str}    start=0    end=2
    ${prodName_tmp1}    string.get substring    ${prodName_str}    start=2
    ${tmp1}    set variable    ${prodName_tmp0}_${prodName_tmp1}
    @{tmp2}    string.split string    ${prodCode_str}    separator=.
    ${bpf_gzfileName}    set variable    ${tmp2}[0]_${tmp1}.gz
    [Return]    ${bpf_gzfileName}

get BPF file content
    [Documentation]   get BPF file content after download gz file to TestPC and gunzip
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    BPF file and content
    ...    Example
    ...    | ${bpf_gzfileName} | get BPF gz fileName | AWHQG |
    ...    | ${bpf_content} | ${bpf_file} | get BPF file content | ${bpf_gzfileName} |
    [Arguments]   ${bpf_gzfileName}
    OperatingSystem.Create Directory     ${SAVE LOG DIRECTORY}/bpf/
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=gNB_gz
    sleep   2s
    ${file_exist}    csn.file exists    /tmp/bpf/${bpf_gzfileName}    connection=gNB_gz
    run keyword if    ${file_exist}
    ...    csn.download file    /tmp/bpf/${bpf_gzfileName}    ${SAVE LOG DIRECTORY}/bpf/${bpf_gzfileName}    connection=gNB_gz
    csn.disconnect    connection=gNB_gz
    OperatingSystem.File Should Exist    ${SAVE LOG DIRECTORY}/bpf/${bpf_gzfileName}
    process.run process    gunzip -k ${SAVE LOG DIRECTORY}/bpf/${bpf_gzfileName}    timeout=30s    shell=True
    ${bpf_localPath}    List Directory    ${SAVE LOG DIRECTORY}/bpf/    absolute=True
    ${bpf_file}    set variable    ${bpf_localPath}[0]
    ${bpf_content}    OperatingSystem.get file    ${bpf_file}
    [Return]    ${bpf_content}    ${bpf_file}

define BPF params value from spec
    [Documentation]   This keyword defines BPF params value from Spec pov, such as
    ...    unit name, type, variant, product code, supported technologies, bands, bandwidth, powers, antennas, optical ports
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    |     | define BPF params value from spec | AWHQG |
    [Arguments]   ${radio_type}=${ru_type_init}
    set test variable   ${radio_type}
    run keyword if     '${radio_type}'=='AWHQG'         run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">474877A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AW</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>HQG</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1;2</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.RX">16</p><p Name="Num.Of.TX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">120</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3460.0</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3579.9</p>
    ...    ELSE IF     '${radio_type}'=='AWHHD'         run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475068A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AW</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>HHD</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>   AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>2600</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1;2</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.RX">16</p><p Name="Num.Of.TX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">160</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>41</p><p>41</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">2515.0</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">2674.9</p>
    ...    ELSE IF     '${radio_type}'=='AWHQM'         run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475246A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AW</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>HQM</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>   AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3700</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1;2</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.RX">20</p><p Name="Num.Of.TX">20</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3800.0</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">4099.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQV'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475294A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QV</variant>   AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3700</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">16</p>   AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3700</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3999.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQE'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">474750A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QE</variant>   AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">32</p>   AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3480</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3799.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQP'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475238A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QP</variant>   AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">32</p>   AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3410</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3699.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQQ'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475252A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QQ</variant>   AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">16</p>   AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3420</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3799.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQY'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475538A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QY</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3400</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3699.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQZ'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475444A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QZ</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3300</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3599.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQI'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475440A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QI</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">32</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3300</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3599.9</p>
    ...    ELSE IF    '${radio_type}'=='AEQC'           run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">475431A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AE</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QC</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.TRX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">200</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3410</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3799.9</p>
    ...    ELSE   log to console    no RU params defined

define nrarfcn range from 3GPP FR1
    [Documentation]   This keyword defines NR-ARFCN per operating band in FR1 from TS38.104 table 5.4.2.3-1
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    |     | define nrarfcn range in FR1 | operateBand=n78 | scs_param=30 |
    [Arguments]   ${operateBand}   ${scs_param}
    run keyword if    '${operateBand}'=='n77' and '${scs_param}'=='15 KHz'    run keywords
    ...    set test variable    ${minNrarfcn_3gpp}    620000    AND
    ...    set test variable    ${maxNrarfcn_3gpp}    680000    AND
    ...    set test variable    ${NrarfcnStep_3gpp}    1
    ...    ELSE IF    '${operateBand}'=='n77' and '${scs_param}'=='30 KHz'    run keywords
    ...    set test variable    ${minNrarfcn_3gpp}    620000    AND
    ...    set test variable    ${maxNrarfcn_3gpp}    680000    AND
    ...    set test variable    ${NrarfcnStep_3gpp}    2
    ...    ELSE IF    '${operateBand}'=='n78' and '${scs_param}'=='15 KHz'    run keywords
    ...    set test variable    ${minNrarfcn_3gpp}    620000    AND
    ...    set test variable    ${maxNrarfcn_3gpp}    653333    AND
    ...    set test variable    ${NrarfcnStep_3gpp}    1
    ...    ELSE IF    '${operateBand}'=='n78' and '${scs_param}'=='30 KHz'    run keywords
    ...    set test variable    ${minNrarfcn_3gpp}    620000    AND
    ...    set test variable    ${maxNrarfcn_3gpp}    653332    AND
    ...    set test variable    ${NrarfcnStep_3gpp}    2
    ...    ELSE IF    '${operateBand}'=='n41' and '${scs_param}'=='15 KHz'    run keywords
    ...    set test variable    ${minNrarfcn_3gpp}    499200    AND
    ...    set test variable    ${maxNrarfcn_3gpp}    537999    AND
    ...    set test variable    ${NrarfcnStep_3gpp}    3
    ...    ELSE IF    '${operateBand}'=='n41' and '${scs_param}'=='30 KHz'    run keywords
    ...    set test variable    ${minNrarfcn_3gpp}    499200    AND
    ...    set test variable    ${maxNrarfcn_3gpp}    537996    AND
    ...    set test variable    ${NrarfcnStep_3gpp}    6
    ...    ELSE   log to console    \nthere's no nrarfcn range defined from 3GPP FR1

define GSCN range from 3GPP FR1
    [Documentation]   This keyword defines the distance between applicable GSCN entries in FR1 from TS38.104 table 5.4.3.3-1
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    |     | define nrarfcn range in FR1 | NRoperateBand=n78 | ssbSCS_param=30 |
    [Arguments]   ${NRoperateBand}   ${ssbSCS_param}
    run keyword if    '${NRoperateBand}'=='n77' and '${ssbSCS_param}'=='30 KHz'    run keywords
    ...    set test variable    ${minGSCN_3gpp}    7711    AND
    ...    set test variable    ${maxGSCN_3gpp}    8329    AND
    ...    set test variable    ${GSCNstep_3gpp}    1
    ...    ELSE IF    '${NRoperateBand}'=='n78' and '${ssbSCS_param}'=='30 KHz'    run keywords
    ...    set test variable    ${minGSCN_3gpp}    7711    AND
    ...    set test variable    ${maxGSCN_3gpp}    8051    AND
    ...    set test variable    ${GSCNstep_3gpp}    1

    ...    ELSE IF    '${NRoperateBand}'=='n41' and '${ssbSCS_param}'=='30 KHz'    run keywords
    ...    set test variable    ${minGSCN_3gpp}    6252    AND
    ...    set test variable    ${maxGSCN_3gpp}    6714    AND
    ...    set test variable    ${GSCNstep_3gpp}    3

#    ...    ELSE IF    '${NRoperateBand}'=='n78' and '${ssbSCS_param}'=='15 KHz'    run keywords
#    ...    set test variable    ${minGSCN_3gpp}    620000    AND
#    ...    set test variable    ${maxGSCN_3gpp}    653333    AND
#    ...    set test variable    ${GSCNstep_3gpp}    1
#    ...    ELSE IF    '${NRoperateBand}'=='n78' and '${ssbSCS_param}'=='30 KHz'    run keywords
#    ...    set test variable    ${minGSCN_3gpp}    620000    AND
#    ...    set test variable    ${maxGSCN_3gpp}    653332    AND
#    ...    set test variable    ${GSCNstep_3gpp}    2
    ...    ELSE   log to console    \nthere's no GSCN range defined from 3GPP FR1

verify BPF params
    [Documentation]   Compare BPF with Spec, such as
    ...    "unit name, type, variant, product code, supported technologies,
    ...    bands, bandwidth, powers, antennas, optical ports"
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    |  | verify BPF params | ${bpf_content} |
    [Arguments]   ${bpf_content}    ${radio_type}=${ru_type_init}
    define BPF params value from spec   ${radio_type}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${ProductCode_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${unitType_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${variant_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${SuppTech_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${FreqBand_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${optical_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${NumTRX_expect}
    Run keyword and continue on failure    should contain    ${bpf_content}    ${Bandwidth_expect}

Check active fault on WebUI
    [Arguments]   ${alarm_filter}   ${Severity_expect}    ${AlarmID_expect}   ${AlarmName_expect}   ${FaultID_expect}
    ...    ${FaultName_expect}    ${AlarmOB_expect}
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    run keyword and ignore error      selenium_coam.disable_message_box
    sleep    15s
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ${Active_SW}    Get Active SW Version Temp
    ${stream}    get stream from version Temp    ${Active_SW}
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=60
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Severity}    set variable    ${fault_dic}[Severity]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    ${Fault_ID}    set variable    ${fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    ${Alarming_object}    set variable if   '${stream}'=='11.800' or '${stream}'=='10.1800'   ${fault_dic}[Alarming object]
    ...    ${fault_dic}[Configuration alarming object]
#    ${Alarming_object}    set variable    &{fault_dic}[Configuration alarming object]
    should be equal     ${Severity}     ${Severity_expect}
    should be equal     ${Alarm_ID}     ${AlarmID_expect}
    should be equal     ${Alarm_name}   ${AlarmName_expect}
    should be equal     ${Fault_ID}     ${FaultID_expect}
    should be equal     ${Fault_name}   ${FaultName_expect}
    run keyword and ignore error    should be equal     ${Alarming_object}     ${AlarmOB_expect}

get RFSW version from TargetBD
    [Documentation]   ssh to SMOD to get RFSW version that in used from TargetBD_*.xml file
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    RFSW version currently in used in TargetBD_*.xml file
    ...    Example
    ...    | ${ruSW_TargetBD} | get RFSW version from TargetBD | AWHQG |
    [Arguments]   ${radio_type}=${ru_type_init}
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat ${save_path}/${TargetBD_FileName}|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    set test variable    ${ruSW_TargetBD}    ${ru_version}[0]
    [Return]    ${ruSW_TargetBD}

get RFSW version from radio module
    [Documentation]   ssh to RMOD to get RFSW version that in used
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    RFSW version currently in used in radio module
    ...    Example
    ...    | ${ruSW_fromFRM} | get RFSW version from radio module | 192.168.254.52 |
    [Arguments]   ${ru_ip}=${ru_addr}
    Connect to gnb coam via ssl
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    #Connect to RU With Allocated IP     ru_alias=ru    asik_alias=asik
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asik
    Connect to RU With Allocated IP
    ...     ru_alias=ru
    ...     asik_alias=asik
    ...     container_id=${FHNETcontainer_id}

    set test variable    ${cmd_ruSW}    cat /etc/version
    ${output_cmd_ruSW}    csn.execute    command=${cmd_ruSW}    connection=ru    timeout=60s
    ${ruSW_fromModule}    Fetch from left   string=${output_cmd_ruSW}    marker=${SPACE}
    ${ruSW_fromModule}    Strip string    ${ruSW_fromModule}
    run keyword and ignore error    csn.disconnect    connection=ru
    run keyword and ignore error    csn.disconnect    connection=asik
    [Return]    ${ruSW_fromModule}

check ping is enabled
    [Documentation]   check unit can be pingable after reset, power off/on and so on
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    | | check ping is enabled | 10.1.1.10 |
    [Arguments]   ${Unit_ip}
    ${ping}=    run process    ping -c 10 ${Unit_ip}   timeout=60s   shell=True
    should contain    ${ping.stdout}    10 received

Verify CPRI link status via loner register
    [Documentation]   verify cpri link state from ABIL Loner
    ...    Author: shasha.liu@nokia-sbell.com
    [Arguments]     ${cpri_state_register}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    sleep   1s
    csn.connect to   hostname=${CapUnit_addr}   username=${asik_username}   password=${asik_password}   alias=loner   proxy=asik
    sleep   1s
    ${cmd_get_cpri_link_state}    set variable    devmem ${cpri_state_register}
    ${cpri_link_state_raw}    csn.Execute    command=${cmd_get_cpri_link_state}    connection=loner
    ${cpri_link_state}    Strip String     ${cpri_link_state_raw}
    ${cpri_link_state_explainatin}    Set variable if    '${cpri_link_state}'=='0x00000010'    Synced
    ...    '${cpri_link_state}'=='0x00000002'    Loss of Frame
    ...    '${cpri_link_state}'=='0x00000003'    Loss of Signal
    ...    Undefined state
    should be equal    ${cpri_link_state}    0x00000010
    ...    msg=CPRI Link NOT Synced, current state is: ${cpri_link_state}, ${cpri_link_state_explainatin}
    run keyword and ignore error    csn.disconnect    connection=loner
    run keyword and ignore error    csn.disconnect    connection=asik
    [Return]    ${cpri_link_state}

verify cpri link state from BTSOM
    [Documentation]   verify cpri link state from startup_BTSOM.log
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    input: startup_BTSOM.log which greped by "API_L1SW_CPRI_STATE_IND_MSG received for link"
    ...    *RETURN VALUE*
    ...    Example
    ...    verify cpri link state from BTSOM | ${output_links} |
    [Arguments]   ${output_links}
    @{link8}    get regexp matches    ${output_links}    8 with state: ECpriState_(.)    1
    ${link8_length}    Get Length    ${link8}
    run keyword if  ${link8_length} != 0    should be true    '${link8}[-1]'=='F'
    @{link9}    get regexp matches    ${output_links}    9 with state: ECpriState_(.)    1
    ${link9_length}    Get Length    ${link9}
    run keyword if  ${link9_length} != 0    should be true    '${link9}[-1]'=='G' or '${link9}[-1]'=='F'

Get cpri Link State from BTSOM
    ${cmd_grep}   Set Variable   startup_BTSOM.log | grep "API_L1SW_CPRI_STATE_IND_MSG received for link"
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik_cpri
    ${status}   get cpri online
#    Run Keyword Unless   ${status}   get cpri offline
    run keyword if    '${status}'=='False'    get cpri offline
    ${output_links}   Run Keyword If   ${status}   csn.Execute   command=cat /tmp/${cmd_grep}   connection=asik_cpri
    ...   ELSE   OperatingSystem.Run   cat ${SAVE LOG DIRECTORY}/${cmd_grep}
    [Teardown]   csn.Disconnect   connection=asik_cpri
    [Return]   ${output_links}

get cpri online
    ${file_path}   csn.Execute   command=find /tmp/ -name startup_BTSOM.log   connection=asik_cpri    timeout=60s
    ${status}   Run Keyword and Return Status   Should Not Be Empty   ${file_path}
    [Return]   ${status}

get cpri offline
    ${file_path}   csn.Execute   command=find /ffs/run/ -name startup_BTSOM.log.xz   connection=asik_cpri    timeout=60s
    Should Not Be Empty   ${file_path}
    csn.Download File   remote_path=${file_path.splitlines()[0]}   local_path=${SAVE LOG DIRECTORY}/startup_BTSOM.log.xz
    ...    connection=asik_cpri
    OperatingSystem.Run   xz -dvf ${SAVE LOG DIRECTORY}/startup_BTSOM.log.xz

recover environment
#    Wait Until Keyword Succeeds    8min    1min    WEBUI Login
     ${pmax_current}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    abbr=pMax
    Wait Until Keyword Succeeds    2min    30s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${pMax_origin}    abbr=pMax
    Validate and activate and check activate plan status
    Wait Until Keyword Succeeds    8min    1min    WEBUI Login
    ${flag}    Run Keyword And Return Status    wait until keyword succeeds    10min    1min
    ...    "StepX" Login WebEM and check gNB onair
    run keyword if     '${flag}'=='False'    reload scf

reload scf
    [Arguments]   ${scfFilePath}=${scfFile}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scfFilePath}
    sleep   3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    1min
    run keyword and ignore error    wait until keyword succeeds    20min    30s    Check Cell is UP

check ru ip allocation
    Wait Until Keyword Succeeds    3min    10s    csn.connect to    hostname=${asik_addr}    username=${asik_username}
    ...    password=${asik_password}   alias=asik1
    #${FRIps_path}    csn.execute    command=find /ffs/run/ -name FRIps*    connection=asik1   timeout=10s
    #Should Not Be Empty   ${FRIps_path}
    #${FRIps_path}    Fetch from left   string=${FRIps_path}    marker=${SPACE}
    #${FRIps_path}    Strip string    ${FRIps_path}
    #csn.download file    remote_path=${FRIps_path}   local_path=${SAVE LOG DIRECTORY}/FRIps.txt   connection=asik1
    set test variable    ${FRIps_path}    /ffs/run/config/FRIps.txt
    csn.download file    remote_path=${FRIps_path}   local_path=${SAVE LOG DIRECTORY}/FRIps.txt   connection=asik1
    csn.disconnect    connection=asik1
    OperatingSystem.File Should Exist    ${SAVE LOG DIRECTORY}/FRIps.txt
    ${FRIps_content}    OperatingSystem.get file    ${SAVE LOG DIRECTORY}/FRIps.txt
    @{ru_ip_list}    Get Regexp matches    ${FRIps_content}    (\\d+\\.\\d+\\.\\d+\\.\\d+)
    set test variable    ${ru_ip}    ${ru_ip_list}[0]
    Should Not Be Equal    ${ru_ip}    0.0.0.0

get nrarfcn general range from OAM webui
    ${fcnDetails}    selenium_coam.get_parameter_details   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number
    set test variable    ${fcnActu}    ${fcnDetails}[Actual value]
    set test variable    ${fcnStep}    ${fcnDetails}[Step]
    set test variable    ${fcnRang}    ${fcnDetails}[Range]
    @{result_tmp}    string.split string    ${fcnRang}    separator=...
    set test variable    ${minNrarfcn_General}    ${result_tmp}[0]   #0
    set test variable    ${maxNrarfcn_General}    ${result_tmp}[-1]  #3279165
    set test variable    ${nrarfcnStp_General}    ${fcnStep}         #1
    log to console    \nnrarfcn general range:${minNrarfcn_General} .. ${maxNrarfcn_General}

get nrarfcn range from TX/RX frequency
    define BPF params value from spec    #radio_type=AWHQG
    @{MinFreq_tmp}    Get Regexp matches    ${MinFreq_expect}    <p Name="Min.Frequency">(.*)</p>  1
    set test variable    ${MinFreq_bpf}    ${MinFreq_tmp}[0]    #3460.0
    @{MaxFreq_tmp}    Get Regexp matches    ${MaxFreq_expect}    <p Name="Max.Frequency">(.*)</p>  1
    set test variable    ${MaxFreq_bpf}    ${MaxFreq_tmp}[0]    #3579.9

    ${MinFreq_bpf}=    Evaluate    math.ceil(${MinFreq_bpf})   math   #round up   3460.0
    ${MaxFreq_bpf}=    Evaluate    math.ceil(${MaxFreq_bpf})   math   #round up   3580.0
#    ${MinFreq_bpf}=    Convert To Number   ${MinFreq_bpf}
#    ${MaxFreq_bpf}=    Convert To Number   ${MaxFreq_bpf}
    set test variable    ${MinFreq_bpf}
    set test variable    ${MaxFreq_bpf}

    #TS38.104 Table 5.4.2.1-1: NR-ARFCN parameters for the global frequency raster
    run keyword if     ${MinFreq_bpf} >= 0 and ${MaxFreq_bpf} < 3000    run keywords
    ...    log to console   \nget low nrarfcn according 3GPP: 0 .. 3000     AND
    ...    get low nrarfcn according 3GPP     Min_Freq=${MinFreq_bpf}    Max_Freq=${MaxFreq_bpf}
    ...    ELSE IF     ${MinFreq_bpf} >= 3000 and ${MaxFreq_bpf} < 24250   run keywords
    ...    log to console   \nget middle nrarfcn according 3GPP: 3000 .. 24250     AND
    ...    get middle nrarfcn according 3GPP   Min_Freq=${MinFreq_bpf}   Max_Freq=${MaxFreq_bpf}
    ...    ELSE IF     ${MinFreq_bpf} >= 24250 and ${MaxFreq_bpf} < 100000    run keywords
    ...    log to console   \nget high nrarfcn according 3GPP: 24250 .. 100000     AND
    ...    get high nrarfcn according 3GPP    Min_Freq=${MinFreq_bpf}   Max_Freq=${MaxFreq_bpf}
    ...    ELSE        log to console    \nInvalid frequency: the frequency range is not defined in 3GPP TS38.104
    set test variable    ${minNrarfcn_pbf}    ${min_Nrarfcn}
    set test variable    ${maxNrarfcn_pbf}    ${max_Nrarfcn}
    log to console     \n${radio_type} accurate working nrarfcn range without step align: ${minNrarfcn_pbf} .. ${maxNrarfcn_pbf}

    ${minNrarfcn_pbf}=    Evaluate    math.ceil(${minNrarfcn_pbf})   math  #round up   #630667.0
    ${maxNrarfcn_pbf}=    Evaluate    math.ceil(${maxNrarfcn_pbf})   math  #round up   #638667.0
    ${maxNrarfcn_pbf}=    Evaluate    int(${maxNrarfcn_pbf})
    ${minNrarfcn_pbf}=    Evaluate    int(${minNrarfcn_pbf})
    log to console      \n${radio_type} refined working nrarfcn range without step align: ${minNrarfcn_pbf} .. ${maxNrarfcn_pbf}

    #adjust range with chBw and filterBandwidth offset (1Mhz)
    ${chBw}=    Evaluate    int(${chBw})
    ${MinFreq_bpf_chBw}=    Evaluate    ${MinFreq_bpf}+${chBw}/2
    ${MaxFreq_bpf_chBw}=    Evaluate    ${MaxFreq_bpf}-${chBw}/2
    set test variable    ${MinFreq_bpf_chBw}
    set test variable    ${MaxFreq_bpf_chBw}

    ${MinFreq_bpf_chBw}=    Evaluate    math.ceil(${MinFreq_bpf_chBw})   math   #round up   3460.0
    ${MaxFreq_bpf_chBw}=    Evaluate    math.ceil(${MaxFreq_bpf_chBw})   math   #round up   3580.0

    run keyword if     ${MinFreq_bpf_chBw} >= 0 and ${MaxFreq_bpf_chBw} < 3000    run keyword
    ...    get low nrarfcn according 3GPP     Min_Freq=${MinFreq_bpf_chBw}    Max_Freq=${MaxFreq_bpf_chBw}
    ...    ELSE IF     ${MinFreq_bpf_chBw} >= 3000 and ${MaxFreq_bpf_chBw} < 24250   run keyword
    ...    get middle nrarfcn according 3GPP    Min_Freq=${MinFreq_bpf_chBw}    Max_Freq=${MaxFreq_bpf_chBw}
    ...    ELSE IF     ${MinFreq_bpf_chBw} >= 24250 and ${MaxFreq_bpf_chBw} < 100000    run keyword
    ...    get high nrarfcn according 3GPP    Min_Freq=${MinFreq_bpf_chBw}    Max_Freq=${MaxFreq_bpf_chBw}
    ...    ELSE         log to console    \nInvalid frequency: the frequency range is not defined in 3GPP TS38.104
    set test variable    ${minNrarfcn_pbf_chBw}    ${min_Nrarfcn}
    set test variable    ${maxNrarfcn_pbf_chBw}    ${max_Nrarfcn}
    log to console   \n${radio_type} accurate working nrarfcn range with chBw
    log to console   \nand without step align: ${minNrarfcn_pbf_chBw} .. ${maxNrarfcn_pbf_chBw}

    ${minNrarfcn_pbf_chBw}=    Evaluate    math.ceil(${minNrarfcn_pbf_chBw})   math  #round up   #630667.0
    ${maxNrarfcn_pbf_chBw}=    Evaluate    math.ceil(${maxNrarfcn_pbf_chBw})   math  #round up   #638667.0
    ${maxNrarfcn_pbf_chBw}=    Evaluate    int(${maxNrarfcn_pbf_chBw})
    ${minNrarfcn_pbf_chBw}=    Evaluate    int(${minNrarfcn_pbf_chBw})
    set test variable    ${maxNrarfcn_pbf_chBw}
    set test variable    ${minNrarfcn_pbf_chBw}
    log to console    \n${radio_type} refined working nrarfcn range with chBw
    log to console    \nand without step align: ${minNrarfcn_pbf_chBw} .. ${maxNrarfcn_pbf_chBw}

get nrarfcn recovery TX/RX frequency range
#    #adjust range of min/max to meet 'min/max nrarfcn for recovery'
#    #In case of mod(nrarfcn,2) != 0

    ${maxNrarfcn_pbf_chBw_tmp}=    Evaluate    ${maxNrarfcn_pbf_chBw}%${NrarfcnStep_3gpp}
    ${minNrarfcn_pbf_chBw_tmp}=    Evaluate    ${minNrarfcn_pbf_chBw}%${NrarfcnStep_3gpp}

    ${maxNrarfcn_pbf_chBw}=    Evaluate    ${maxNrarfcn_pbf_chBw}+(${NrarfcnStep_3gpp}-${maxNrarfcn_pbf_chBw_tmp})
    ${minNrarfcn_pbf_chBw}=    Evaluate    ${minNrarfcn_pbf_chBw}-${minNrarfcn_pbf_chBw_tmp}
    ${maxNrarfcn_pbf_chBw}=    Evaluate    int(${maxNrarfcn_pbf_chBw})
    ${minNrarfcn_pbf_chBw}=    Evaluate    int(${minNrarfcn_pbf_chBw})
    set test variable    ${maxNrarfcn_pbf_chBw}
    set test variable    ${minNrarfcn_pbf_chBw}

get nrarfcn out of TX/RX frequency range
    #In case of mod(nrarfcn,step) != 0
    ${maxNrarfcn_pbf_tmp}=    Evaluate    ${maxNrarfcn_pbf}%${NrarfcnStep_3gpp}
    ${minNrarfcn_pbf_tmp}=    Evaluate    ${minNrarfcn_pbf}%${NrarfcnStep_3gpp}
    ${maxNrarfcn_1807_modnonzero}=    Evaluate    ${maxNrarfcn_pbf}+(${NrarfcnStep_3gpp}-${maxNrarfcn_pbf_tmp})
    ${minNrarfcn_1807_modnonzero}=    Evaluate    ${minNrarfcn_pbf}-${minNrarfcn_pbf_tmp}
    ${maxNrarfcn_1807_modzero}=    Evaluate    ${maxNrarfcn_pbf}+${NrarfcnStep_3gpp}
    ${minNrarfcn_1807_modzero}=    Evaluate    ${minNrarfcn_pbf}-${NrarfcnStep_3gpp}

     run keyword if    ${maxNrarfcn_pbf_tmp} == 0   set test variable   ${maxNrarfcn_1807}   ${maxNrarfcn_1807_modzero}
    ...    ELSE    set test variable   ${maxNrarfcn_1807}   ${maxNrarfcn_1807_modnonzero}

     run keyword if    ${minNrarfcn_pbf_tmp} == 0   set test variable   ${minNrarfcn_1807}   ${minNrarfcn_1807_modzero}
    ...    ELSE    set test variable   ${minNrarfcn_1807}   ${minNrarfcn_1807_modnonzero}

    ${maxNrarfcn_1807}=    Evaluate    int(${maxNrarfcn_1807})
    ${minNrarfcn_1807}=    Evaluate    int(${minNrarfcn_1807})
    set test variable    ${maxNrarfcn_1807}
    set test variable    ${minNrarfcn_1807}

#    #In case of ${maxNrarfcn_1807} larger than ${maxNrarfcn_3gpp}
#    : For   ${1807_tmp}    IN RANGE    ${maxNrarfcn_1807}    ${maxNrarfcn_3gpp}   -${NrarfcnStep_3gpp}
##    \    run keyword if    '${1807_tmp}'>='${maxNrarfcn_3gpp}'    Continue For Loop
##    \    ${maxNrarfcn_1807}=    Evaluate    ${1807_tmp}-${NrarfcnStep_3gpp}
#    \    set test variable    ${maxNrarfcn_1807}    ${1807_tmp}

get nrarfcn out of band boundary from 3gpp
    ${minNrarfcn_validateErr}=    Evaluate    ${minNrarfcn_3gpp}-${NrarfcnStep_3gpp}
    ${maxNrarfcn_validateErr}=    Evaluate    ${maxNrarfcn_3gpp}+${NrarfcnStep_3gpp}
    set test variable    ${minNrarfcn_validateErr}
    set test variable    ${maxNrarfcn_validateErr}

get gscn align with nrarfcn from 3gpp FR1
    [Arguments]    ${nrarfcn}
    set test variable    ${nrarfcn}
    run keyword if    0<${nrarfcn}<=599999    get low gscn according 3GPP
    ...    ELSE IF    599999<${nrarfcn}<=2016666     get middle gscn according 3GPP
    ...    ELSE IF    2016666<${nrarfcn}<=3279165    get high gscn according 3GPP
    ...    ELSE       log to console    \nInvalid nrarfcn: the nrarfcn range is not defined in 3GPP TS38.104 Table 5.4.2.1-1
    [Return]    ${gscn}

get low gscn according 3GPP
    #the default value M=3
    ${gscn}=    Evaluate    3*(((0+0.005*(${nrarfcn}-0))-3*0.05)/1.2)+(3-3)/2
    ${gscn}=    Evaluate    int(${gscn})
    ${gscn_mod}=    Evaluate    ${gscn}%${GSCNstep_3gpp}
    ${gscn}=    Evaluate    ${gscn}-${gscn_mod}
    run keyword and ignore error    should be true    ${minGSCN_3gpp}<=${gscn}<=${maxGSCN_3gpp}
    set test variable    ${gscn}
    [Return]    ${gscn}

get middle gscn according 3GPP
    ${gscn}=    Evaluate    7499+((3000+15*(${nrarfcn}-600000)/1000)-3000)/1.44
    ${gscn}=    Evaluate    int(${gscn})
    ${gscn_mod}=    Evaluate    ${gscn}%${GSCNstep_3gpp}
    ${gscn}=    Evaluate    ${gscn}-${gscn_mod}
    run keyword and ignore error    should be true    ${minGSCN_3gpp}<=${gscn}<=${maxGSCN_3gpp}
    set test variable    ${gscn}
    [Return]    ${gscn}

get high gscn according 3GPP
    ${gscn}=    Evaluate    22256+((24250.08+60*(${nrarfcn}-2016667)/1000)-24250.08)/17.28
    ${gscn}=    Evaluate    int(${gscn})
    ${gscn_mod}=    Evaluate    ${gscn}%${GSCNstep_3gpp}
    ${gscn}=    Evaluate    ${gscn}-${gscn_mod}
    run keyword and ignore error    should be true    ${minGSCN_3gpp}<=${gscn}<=${maxGSCN_3gpp}
    set test variable    ${gscn}
    [Return]    ${gscn}

get low nrarfcn according 3GPP
    [Arguments]    ${Min_Freq}  ${Max_Freq}
    ${min_Nrarfcn}=    Evaluate    (${Min_Freq}-0)*1000/5+0
    ${max_Nrarfcn}=    Evaluate    (${Max_Freq}-0)*1000/5+0
    set test variable    ${min_Nrarfcn}
    set test variable    ${max_Nrarfcn}
    [Return]    ${min_Nrarfcn}    ${max_Nrarfcn}

get middle nrarfcn according 3GPP
    [Arguments]    ${Min_Freq}  ${Max_Freq}
    ${min_Nrarfcn}=    Evaluate    (${Min_Freq}-3000)*1000/15+600000
    ${max_Nrarfcn}=    Evaluate    (${Max_Freq}-3000)*1000/15+600000
    set test variable    ${min_Nrarfcn}
    set test variable    ${max_Nrarfcn}
    [Return]    ${min_Nrarfcn}    ${max_Nrarfcn}

get high nrarfcn according 3GPP
    [Arguments]    ${Min_Freq}  ${Max_Freq}
    ${min_Nrarfcn}=    Evaluate    (${Min_Freq}-24250.08)*1000/60+2016667
    ${max_Nrarfcn}=    Evaluate    (${Max_Freq}-24250.08)*1000/60+2016667
    set test variable    ${min_Nrarfcn}
    set test variable    ${max_Nrarfcn}
    [Return]    ${min_Nrarfcn}    ${max_Nrarfcn}

gNB uncommission via scf deletion
    [Documentation]   erasing commissioning data by delete files in /rom/config/, be sure gNB LMP is accessable before that
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    log to console    \ngNB uncommission via scf deletion
    siso_resource.check ping is enabled    Unit_ip=${asik_LMP_addr}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=uncommission
    sleep   2s
    csn.send command    command=rm /rom/config/*.*;reboot -f    connection=uncommission
    csn.disconnect    connection=uncommission

gNB commission with loading scf via LMP
    wait until keyword succeeds    6min    1min    siso_resource.check ping is enabled   ${asik_LMP_addr}
    run keyword and ignore error   selenium_coam.enable_virtual_display
    wait until keyword succeeds    6min   1min   selenium_coam.login
    ...    url=https://${asik_LMP_addr}
    ...    username=${asik_LMP_username}
    ...    password=${asik_LMP_password}
    run keyword and ignore error      selenium_coam.disable_message_box
    sleep    3s
    siso_resource.reload scf

#Get FHNET Container ID
#    [Arguments]    ${asik_alias}=ASIK Master
#    ${hostname}=    csn.execute    command=hostname    connection=${asik_alias}
#    ${container_id}=    Set Variable If    'fct-0a' in '''${hostname}'''    0x1018
#    ...    'fct-4a' in '''${hostname}'''    0x2018    None
#    [Return]   ${container_id}

#////////////////////////////////////////////
#common keyword for test suite and test cases
SISO Common Suite Setup
    set suite variable      ${OUTPUT_PATH}    %{HOME}/workspace/CIT/Master/Case_Logs
#   Run Keyword And Ignore Error    run process    chmod -R 777 ${OUTPUT_PATH}    shell=yes
    Run Keyword And Ignore Error    run process    taskkill /f /im chromedriver.exe    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True
    Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Logout
    sleep   10s
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Login

    ${output}    ${version}     check SW version     Active
    @{result}    string.split string    ${output}    separator=_
    ${length}    Get Length    ${result}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     ${result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
          ${j} =    Evaluate    ${i} + ${2}
          ${build}    set variable    ${result}[${j}]
          ${build}    Run Keyword If    ${j} < 5    convert to integer    ${result}[${j}]    ELSE    set variable    ${result}[${j}]
          ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    set suite variable    ${Active_SW_version}    ${SW_vesion_tmp}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Logout


    ${OUTPUT_PATH_with_SW}=    join path     ${OUTPUT_PATH}     ${asik_addr}__${Active_SW_version}
    set suite variable     ${OUTPUT_PATH_with_SW}

    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}

SISO Common Test Setup
    [Documentation]    this keyword create case name directory path as ${OUTPUT_DIR}//${SUITE_LOG_DIRECTORY}//
    ${TEST_LOG_DIR}=    Get A Directory
    Set Test Variable    ${TEST_LOG_DIR}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TEST_LOG_DIR}

SISO Common Suite Teardown
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Login
    ${flag_tmp}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration   download_timeout=300
    sleep    5s
    Run Keyword And Ignore Error    set suite variable    ${scf_file}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${scf_file}
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}

    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Logout
    #Run Keyword If    '${SUITE STATUS}' == 'FAIL'    Run Keyword And Ignore Error    Save Snapshot for Suite Teardown
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

Get A Directory
    [Arguments]    @{paths}
    [Documentation]    Create a specific directory under suite log directory and ${dir_name}
    ${log_path}=    _Get Log Path
    ${directory_path}=    OperatingSystem.Join Path    ${log_path}    @{paths}
    ${directory_path}=    Replace String    ${directory_path}    ${SPACE}    _
    Create Directory    ${directory_path}
    [Return]    ${directory_path}

_Get Log Path
    ${result}=    Run Keyword And Ignore Error    Variable Should Exist    ${TEST NAME}
    ${log_path}=    Run Keyword If    "${result[0]}"=="PASS"    _Get Case Log Path
    ...    ELSE    _Get Suite Log Path
    [Return]    ${log_path}

_Get Suite Log Path
    ${concated_suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${suite_log_path}=    OperatingSystem.Join Path    ${OUTPUT_PATH_with_SW}    ${timestamp}    TESTSUITE__${concated_suite_name}
    [Return]    ${suite_log_path}

_Get Case Log Path
    ${concated_suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_test_name}=    Replace String    ${TEST NAME}    ${SPACE}    _
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${case_log_path}=    OperatingSystem.Join Path    ${OUTPUT_PATH_with_SW}    ${timestamp}
    ...    TESTSUITE__${concated_suite_name}    TESTCASE__${concated_test_name}
    [Return]    ${case_log_path}
