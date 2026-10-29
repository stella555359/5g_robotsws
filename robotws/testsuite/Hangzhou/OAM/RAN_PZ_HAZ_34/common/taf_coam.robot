*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Library   taf.selenium.gnb.oam.core    WITH NAME      selenium_core
Library   taf.transport.ssh   WITH NAME   csn
Library   Collections
Library   OperatingSystem
Library   DateTime

Library   String
Library   XML   True
Library   ../libraries/selenium_utils.py
Library   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/vm_handle.py
Resource   gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
@{selenium_gnb_login}
${file_name}   old_commission.xml
${enb_web_alias}   ENB
${lmp_addr}   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${selenium_lib}

*** Keywords ***
#ADMIN COAM Keywords
COAM Login
    [Arguments]   ${bts_host}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAM
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
#    Run Keyword Unless   '${tl.gnbs[0].global_bts_id}'=='None'   coam.register_autoconnection
#    ...    site_id=${tl.gnbs[0].global_bts_id}   connection=${alias}   timeout=${30}
    [Return]   ${alias}

COAM Logout
    [Arguments]   ${connection}=COAM
    coam.teardown      connection=${connection}

COAM Reset Site
    [Documentation]   COAM Reset Site And Wait For Reconnection.
    ...   Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${wait_for_reconnection}=${True}   ${connection}=COAM
    coam.reset_site   connection=${connection}   wait_for_reconnection=${wait_for_reconnection}   timeout=${900}

COAM Reset RMOD
    [Documentation]   COAM Reset RMOD
    ...    Author: yin.4.chen@nokia-sbell.com
    ...    Example
    ...    | COAM Reset RMOD   dist_name=MRBTS-832/EQM-1/APEQM-1/RMOD-1 |
    [Arguments]   ${dist_name}   ${connection}=COAM    ${timeout}=${1200}
    coam.reset_unit
    ...   dist_name=${dist_name}
    ...   reset_type=Hard
    ...   force_radio_reset=True
    ...   connection=${connection}
    ...   timeout=${timeout}

COAM Reset BBMOD
    [Documentation]   COAM Reset BBMOD
    ...    Author: ruiyu.an@nokia-sbell.com
    ...    Example
    ...    | COAM Reset BBMOD   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1 |
    [Arguments]   ${dist_name}   ${connection}=COAM     ${timeout}=${1200}    ${graceful_cell_shutdown}=${False}
    ...   ${reset_type}=Warm
    coam.reset_unit
    ...   dist_name=${dist_name}
    ...   reset_type=${reset_type}
    ...   connection=${connection}
    ...   graceful_cell_shutdown=${graceful_cell_shutdown}
    ...   timeout=${timeout}

COAM Reset ALL RMOD
    [Documentation]   COAM Reset RMOD
    ...    Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${connection}=COAM
    ${release}   COAM Get SW Release   connection=${connection}
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${distname}   Set Variable   ${rmods[${index}]['id']['configuration']}
        ${status}   Set Variable   ${rmods[${index}]['status']['operationalState']}
        ${reset_status}   Run Keyword And Return Status   Run Keyword If  '${status.lower()}'=='enabled'
        ...   coam.reset_unit   dist_name=${distname}   timeout=${1200}   connection=${connection}
        run keyword if  not ${reset_status}   COAM Reset RMOD   dist_name=${distname}   connection=${connection}
    END
    Wait Until Keyword Succeeds   5m   1m   COAM Check All Radio Modules Status

COAM Reset Configuration
    [Documentation]   COAM Reset Configuration
    ...   Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${remove_operator_certificates}=${False}   ${remove_user_account_credentials}=${False}   ${connection}=COAM
    ...   ${reset_type}=${None}
    coam.reset_configuration
    ...   remove_operator_certificates=${remove_operator_certificates}
    ...   remove_user_account_credentials=${remove_user_account_credentials}
    ...   connection=${connection}
    ...   reset_type=${reset_type}

COAM Reset RAT
    [Documentation]   COAM Reset RAT
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    Example
    ...    | COAM Reset RAT   NR   Soft|
    [Arguments]   ${rat_type}=NR   ${reset_type}=Soft   ${connection}=COAM    ${timeout}=${1200}
    coam.rat_reset
    ...   rat_type=${rat_type}
    ...   reset_type=${reset_type}
    ...   connection=${connection}
    ...   timeout=${timeout}

Get BBMODs info
    [Arguments]   ${alias}=COAM
    wait until keyword succeeds   3x   10s   COAM Login
    ${hw_info}   coam.get_detected_hw_info   connection=${alias}
    ${bbmod_info_list}   Create List
    FOR   ${bbmod}   IN   @{hw_info['basebandModules']}
       ${bbmod_info}   Create Dictionary
       Continue For Loop If   'configuration' not in @{bbmod['id'].keys()}
       Set To Dictionary   ${bbmod_info}   internal=${bbmod['id']['internal']}   configuration=${bbmod['id']['configuration']}
    ...   product_name=${bbmod['productName'].split()[0]}
       Append To List   ${bbmod_info_list}   ${bbmod_info}
    END
    #${alarm_info}   coam.get_active_alarms   connection=${alias}
    [Return]   ${bbmod_info_list}

Get RMODs Info
    [Arguments]   ${connection}=COAM
    ${hw_info}   coam.get_detected_hw_info   connection=${connection}
    ${rmod_info_list}   Create List
    FOR   ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        ${rmod_info}   Create Dictionary
        Set To Dictionary   ${rmod_info}
        ...   productCode=${rmod['productCode']}
        ...   productName=${rmod['productName']}
        ...   status=${rmod['status']}
        Append To List   ${rmod_info_list}   ${rmod_info}
    END
    [Return]   ${rmod_info_list}

Get SMOD Product Name
    [Arguments]   ${connection}=COAM
    ${hw_info}   coam.get_detected_hw_info   connection=${connection}
    ${bbmod_info_list}   Create List
    [Return]   ${hw_info['systemModules'][0]['productName'].split()[0]}

COAM Change WEBEM Password
    [Documentation]   COAM change WebEM Password by admin
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | old_username | yes | Old Username |
    ...   | old_password | no | Old Password |
    ...   | new_username | yes | New Username |
    ...   | new_password | no | New Password |
    ...   | timeout | no | interface timeout |
    ...   | connection | no | connection name with coam |
    ...    *RETURN VALUE*
    ...    no return
    ...    Example
    ...    | COAM Change WEBEM Password |
    [Arguments]   ${old_username}=Nemuadmin   ${old_password}=nemuuser
    ...   ${new_username}=Nemuadmin   ${new_password}=nemu_Arthur08
    ...   ${connection}=COAM   ${timeout}=${120}
    coam.set_user_account
    ...   old_username=${old_username}
    ...   old_password=${old_password}
    ...   new_username=${new_username}
    ...   new_password=${new_password}
    ...   timeout=${timeout}
    ...   connection=${connection}

COAM Change SSH Password
    [Documentation]
    ...   toor4nsn      oZPS0POrRieRtu   nemu_Arthur08
    ...   serviceuser   Pl(FzaYj5~c5;q   nemu_Arthur08
    [Arguments]   ${username}=toor4nsn   ${old_password}=oZPS0POrRieRtu   ${new_password}=nemu_Arthur08   ${connection}=COAM   ${timeout}=120
    coam.change_ssh_password
    ...   username=${username}
    ...   new_password=${new_password}
    ...   old_password=${old_password}
    ...   timeout=${timeout}
    ...   connection=${connection}

COAM Get Active Alarms
    [Arguments]   ${connection}=COAM
    ${active_alarms}   coam.get_active_alarms   connection=${connection}   timeout=10
    ${new_active_alarms}   Create List
    FOR   ${active_alarm}   IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        Append To List   ${new_active_alarms}   ${active_alarm}
    END
    [Return]   ${new_active_alarms}

COAM Get Active Fault ID
    [Arguments]   ${connection}=COAM
    ${active_alarms}   coam.get_active_alarms   connection=${connection}   timeout=10
    ${active_fault}   Create List
    FOR   ${active_alarm}   IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        Append To List   ${active_fault}   ${faultId}
    END
    [Return]   ${active_fault}

COAM Get SW Version
    [Arguments]   ${connection}=COAM
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${active}   Set Variable   ${sw_info['Active SW version']}
    ${passive}   Set Variable   ${sw_info['Passive SW version']}
    ${planned}   Set Variable   ${sw_info['Planned SW version']}

    ${active}   Set Variable If   "${active}"!="${None}" and "${active}"!=""   ${active}   None
    ${passive}   Set Variable If   "${passive}"!="${None}" and "${passive}"!=""   ${passive}   None
    ${planned}   Set Variable If   "${planned}"!="${None}" and "${planned}"!=""   ${planned}   None

    ${active_sw_version}   Run Keyword If   "${active}"!="${None}" and "${active}"!="" and "${active.find('SBTS')}"=="-1"
    ...   COAM Transfer SW Version   ${active}
    ...   ELSE   Set Variable   ${active}
    ${passive_sw_version}   Run Keyword If   "${passive}"!="${None}" and "${passive}"!="" and "${passive.find('SBTS')}"=="-1"
    ...   COAM Transfer SW Version   ${passive}
    ...   ELSE   Set Variable   ${passive}
    ${planned_sw_version}   Run Keyword If   "${planned}"!="${None}" and "${planned}"!="" and "${planned.find('SBTS')}"=="-1"
    ...   COAM Transfer SW Version   ${planned}
    ...   ELSE   Set Variable   ${planned}
    [Return]   ${active_sw_version}   ${passive_sw_version}   ${planned_sw_version}

COAM Transfer SW Version
    [Arguments]   ${sw_version}
    Run Keyword If   "${sw_version}"=="" or "${sw_version}"=="-"   Fail   Please Enter Correct Parameter!
    @{list}   Split String   ${sw_version}   _
    ${new_sw_version}   Set Variable If
    ...   len(${list})==5   ${${list[-3]}}.${${list[-2]}}.${${list[-1]}}
    ...   len(${list})==6   ${${list[-4]}}.${${list[-3]}}.${${list[-2]}}_${list[-1]}
    [Return]   ${new_sw_version}

COAM Get SW Release
    [Arguments]   ${connection}=COAM
    ${sw_release}   coam.get_sw_release_name   timeout=${120}   connection=${connection}
    [Return]   ${sw_release}

COAM SWM Update
    [Arguments]   ${file_path}   ${activate}=yes   ${connection}=COAM
    Log To Console   Start Software Updating...
    ${should_activate}   Set Variable If   '${activate}'=='yes'   ${True}
    ...   '${activate}'=='no'   ${False}
    coam.update_software   sw_package=${file_path}   should_activate=${True}   timeout=${5400}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
    COAM Logout   connection=${connection}
    Sleep   5m
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Log To Console   Reset finished!
    Log To Console   COAM SWM Update Done!

COAM Backup SCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=old_commission.xml   ${connection}=COAM
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name}   connection=${connection}   timeout=${60}

COAM Backup Full SCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=full_commission.xml   ${connection}=COAM
    coam.get_current_scf_file
    ...   local_dir_path=${local_dir}
    ...   file_name=${file_name}
    ...   export_type=configurationAndRuntimeObjects
    ...   connection=${connection}
    ...   timeout=${300}

COAM Get SCF Content
    [Documentation]   export_type: configuration, configurationAndRuntimeObjects, runtimeObjects
    [Arguments]   ${export_type}=configurationAndRuntimeObjects   ${connection}=COAM
    ${scf_xml}   coam.get_scf
    ...   export_type=${export_type}
    ...   timeout=${300}
    ...   connection=${connection}
    [Return]   ${scf_xml}

COAM SCF Commission
    [Arguments]   ${filepath}=${OUTPUT_DIR}/old_commission.xml   ${connection}=COAM
    coam.perform_commissioning
    ...   scf_file=${filepath}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${900}
    ...   connection=${connection}

COAM Get Parameter Value By XPath
    [Arguments]   ${xpath}=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]/p[@name="btsName"]   ${connection}=COAM
    ${scf_xml}   coam.get_scf   connection=${connection}   timeout=${600}   export_type=configurationAndRuntimeObjects
    ...   with_auto_configured_parameters=${True}
    ${value}   XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]   ${value}

COAM Get Parameter Value
    [Arguments]   ${dist_name}   ${parameter}   ${connection}=COAM
    ${xpath}   Set Variable   cmData/managedObject[@distName="${dist_name}"]/p[@name="${parameter}"]
    ${scf_xml}   coam.get_scf   connection=${connection}   timeout=${600}
    ${value}   XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]   ${value}

COAM Update Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${value}   ${connection}=COAM
    coam.perform_parameter_recommissioning   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    ...   operation=update
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}

COAM Perform Delta Recommission
    [Documentation]   delta_file(string): Delta JSON or path to JSON file.
    ...   **SAMPLE DELTA:**
    ...   [
    ...       {
    ...           "distName": "MRBTS-1/LNBTS-1/LNMME-0",
    ...           "operation": "update",
    ...           "parameters": [
    ...               {
    ...                   "parameterName": "ipAddrPrim",
    ...                   "value": "10.0.1.99",
    ...                   "operation": "update"
    ...               }
    ...           ]
    ...       }
    ...   ]
    [Arguments]   ${delta_file}   ${connection}=COAM
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}

COAM Get BTS Info
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${300}
    [Return]   ${bts_info}

COAM Get BTS Status
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=30
    ${bts_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}   Set Variable   ${bts_info['requestMessage']}
    ...   ELSE   Set Variable   ${bts_info}
    ${system_status}   Set Variable   ${bts_info['systemModules'][0]['status']}
    ${baseband_status}   Set Variable If   ${bts_info['basebandModules']}
    ...   ${bts_info['basebandModules'][0]['status']}   ${bts_info['basebandModules']}
    ${radio_status}   Set Variable If   ${bts_info['radioModules']['rmod']}   ${bts_info['radioModules']['rmod'][0]['status']}
    ...   ${bts_info['radioModules']['rmod']}
    ${cells_status}   Set Variable If   ${bts_info['cells']['nr']}   ${bts_info['cells']['nr'][0]['status']}
    ...   ${bts_info['cells']['nr']}
    ${general_status}   Set Variable   ${bts_info['status']}
    [Return]   ${system_status}   ${baseband_status}   ${radio_status}   ${general_status}

COAM Get General Status
    [Arguments]   ${connection}=COAM
    ${general_status}   coam.get_bts_statuses   connection=${connection}   timeout=10
    [Return]   ${general_status}

COAM Get System Modules Status
    [Arguments]   ${connection}=COAM
    ${fsm_info}   coam.get_fsm_info   connection=${connection}   timeout=10
    ${system_status}   Set Variable   ${fsm_info[0]['status']}
    [Return]   ${system_status}

COAM Get Radio Module Status
    [Arguments]   ${connection}=COAM    ${rmod_index}=0
    ${frm_info}   coam.get_frm   connection=${connection}   timeout=10
    ${radio_status}   Set Variable   ${frm_info[${rmod_index}]['status']}
    [Return]   ${radio_status}

COAM Check Radio Module Status
    [Arguments]   ${connection}=COAM    ${rmod_index}=0
    ${release}   COAM Get SW Release   connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${release}
    ...    12.400    14.400    22R1    22R2    21B
    ${status}   COAM Get Radio Module Status   connection=${connection}   rmod_index=${rmod_index}
    Run Keyword If   '${result}'=='True'
    ...   Run Keywords
    ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
    ...      Should Be Equal   ${status['availabilityStatus']}   Online   AND
    ...      Should Be Equal   ${status['operationalState']}   Enabled
    ...   ELSE   Run Keywords
    ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
    ...      Should Be Equal   ${status['operationalState']}   enabled

COAM Check All Radio Modules Status
    [Arguments]   ${connection}=COAM
    ${release}   COAM Get SW Release   connection=${connection}
    ${frm_info}   coam.get_frm   connection=${connection}   timeout=10
    ${rmod_count}   Get Length   ${frm_info}
    FOR   ${index}    IN RANGE    ${rmod_count}
        ${status}   Set Variable   ${frm_info[${index}]['status']}
        Run Keyword If   '${release}'=='SBTS21B' or '${release}'=='SBTS22R1' or '${release}'=='SBTS22R2'
        ...   Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      Should Be Equal   ${status['availabilityStatus']}   Online   AND
        ...      Should Be Equal   ${status['operationalState']}   Enabled
        ...   ELSE   Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END

COAM Get Cell Status
    [Arguments]   ${cellgrp_index}=NRCELLGRP-0   ${cell_index}=NRCELL-1   ${connection}=COAM
    ${cell_info}   coam.get_subcells_status   connection=${connection}   timeout=10
    ${cell_status}   Set Variable   ${cell_info['${cellgrp_index}']['${cell_index}']['NRCELL_R']}
    [Return]   ${cell_status}

COAM Get Cell Info
    [Documentation]   cell_id: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-xxx/NRCELL_R-1
    [Arguments]   ${cell_id}   ${connection}=COAM
    ${cell_specific_info}   coam.get_cell_specific_info   cell_id=${cell_id}   connection=${connection}   timeout=${60}
    [Return]   ${cell_specific_info}

COAM Lock Cell
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.lock   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Unlock Cell
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.unlock   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Lock RU
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.lock   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Unlock RU
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.unlock   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Check Units Status Normal
    [Arguments]   ${component}   ${connection}=COAM
    Log   component='${component}' connection='${connection}'
    ${system_status}   ${baseband_status}   ${radio_status}   ${general_status}   COAM Get BTS Status
    ${cell_status}   COAM Get Cell Status
    Log To Console   TODO:

COAM Check BTS OnAir
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${status}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['status']['proceduralState']}
    ...   ELSE   Set Variable   ${bts_info['status']['proceduralState']}
    Should Contain   ${status}   OnAir

COAM Check Dedicated Cell Status
    [Arguments]   ${status}   ${connection}=COAM
    ${release}   COAM Get SW Release   connection=${connection}
    Run Keyword If   '${release}'=='SBTS21B' or '${release}'=='SBTS22R1' or '${release}'=='SBTS22R2'
        ...   Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      Should Be Equal   ${status['availabilityStatus']}   Online   AND
        ...      Should Be Equal   ${status['operationalState']}   Enabled
        ...   ELSE   Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      Should Be Equal   ${status['operationalState']}   enabled

COAM Check Cell Status
    [Arguments]   ${connection}=COAM    ${cell_index}=0
    ${release}   COAM Get SW Release   connection=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${status}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr'][${cell_index}]['status']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr'][${cell_index}]['status']}
    # ${availability_state}    Convert To Lower Case    ${status['availabilityStatus']}
    ${operational_state}    Convert To Lower Case    ${status['operationalState']}
    # Should Be Equal   ${availability_state}   online
    Should Be Equal   ${operational_state}   enabled

COAM Check All Cells Onair
    [Arguments]   ${connection}=COAM
    ${release}   COAM Get SW Release   connection=${connection}
    ${result}   Run Keyword And Return Status   Should Contain Any
    ...   ${release}
    ...   12.400   14.400   22R1   22R2   21B
    ${cell_list}   COAM Get Cell List   connection=${connection}
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        # Run Keyword and Continue on Failure   COAM Check Dedicated Cell Status   status=${status}
        Run Keyword If   '${result}'=='True'
        ...   Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      Should Be Equal   ${status['availabilityStatus']}   Online   AND
        ...      Should Be Equal   ${status['operationalState']}   Enabled
        ...   ELSE   Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END

COAM Get Cell List
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${cell_list}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
    [Return]   ${cell_list}

COAM Get PM Counters
    [Arguments]   ${counter_id_list}   ${timeout}=${900}   ${connection}=COAM
    ${counter_ids}   Set Variable   ,
    ${counter_ids}   Set Variable   ${counter_ids.join(${counter_id_list})}
    ${counters}   coam.get_pm_counters
    ...   counter_ids=${counter_ids}
    ...   timeout=${timeout}
    ...   connection=${connection}
    [Return]   ${counters}

COAM Get Measurements
    [Arguments]   ${connection}=COAM
    Log   connection='${connection}'
    ${measurements}   coam.get_measurements   connection=COAM
    [Return]   ${measurements}

Catch Snapshot COAM
    [Timeout]   30m
    [Arguments]   ${local_file_path}=None   ${filename}=${EMPTY}    ${connection}=COAM
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${local_file_path}   Set Variable If
    ...   '${local_file_path}'=='None'   ${OUTPUT_DIR}/snapshot_coam_${filename}_${curr_data}.zip
    ...   ${true}   ${local_file_path}
    Wait Until Keyword Succeeds    1m   15s   COAM Login
    coam.get_snapshot   target_file_name=${local_file_path}   timeout=${1200}   connection=${connection}
    [Return]   ${local_file_path}

Catch IMS2 Snapshot COAM
    [Timeout]   15m
    [Arguments]   ${local_file_path}=None   ${connection}=COAM
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${local_file_path}   Set Variable If
    ...   '${local_file_path}'=='None'   ${OUTPUT_DIR}/ims2_snapshot_coam_${curr_data}.ims2
    ...   ${true}   ${local_file_path}
    Run Keyword And Ignore Error   coam.collect_im_snapshot   target_file_name=${local_file_path}   timeout=900   connection=${connection}
    [Return]   ${local_file_path}

COAM Get SFP Data
    [Arguments]   ${connection}=COAM
    ${sfp_data}   coam.get_sfp_links   connection=${connection}
    [Return]   ${sfp_data}

COAM Get Managed Objects
    [Arguments]   ${class_name}=NRCELL_R   ${connection}=COAM
    ${managed_objects}   coam.get_managed_objects   class_name=${class_name}   connection=${connection}   timeout=${300}
    [Return]   ${managed_objects}

COAM Reset to Test Dedicated State
    [Arguments]   ${connection}=COAM
    coam.reset_to_test_dedicated   connection=${connection}   timeout=${900}

COAM Start 5G Downlink Test
    [Arguments]   ${dist_name}   ${test_model}=TM1_1   ${beam_pattern_id}=${0}   ${polarization}=P_both   ${power_backoff}=${10}
    ...   ${ru_mode}=NR_Only   ${phys_cell_id}=${51}   ${p_max}=${26}   ${nrarfcn_dl}=${636200}   ${mimo_rank}=${1}   ${connection}=COAM
    coam.start_5g_downlink_test
    ...   dist_name=${dist_name}
    ...   test_model=${test_model}
    ...   beam_pattern_id=${beam_pattern_id}
    ...   polarization=${polarization}
    ...   power_backoff=${power_backoff}
    ...   ru_mode=${ru_mode}
    ...   phys_cell_id=${phys_cell_id}
    ...   i11_codebook_4_antports=${0}
    ...   i2_codebook_4_antports=${0}
    ...   i13_codebook_4_antports=${0}
    ...   p_max=${p_max}
    ...   nrarfcn_dl=${nrarfcn_dl}
    ...   codebook_2_antports=${0}
    ...   mimo_rank=${mimo_rank}
    ...   connection=${connection}

COAM Stop 5G Downlink Test
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.stop_5g_downlink_test
    ...   dist_name=${dist_name}
    ...   timeout=${600}
    ...   connection=${connection}

COAM Get Cell Freq
    [Arguments]   ${cell_index}=1   ${connection}=COAM
    ${cell_list}   COAM Get Cell List   connection=${connection}
    FOR   ${cell}   IN   @{cell_list}
        Return From Keyword If   '${cell['globalCellId']}'=='${cell_index}'   ${cell['nrarfcn']}
    END

COAM Install Certificate
    [Arguments]   ${cert_file}   ${password}=123456   ${connection}=COAM
    ${cert_format}   Set Variable   ${cert_file.split('.')[-1]}
    Run Keyword If   "${cert_format}"=="p12"   coam.install_certificate   cert_file=${cert_file}   cert_type=BtsTrustChain
    ...   cert_format=P12   password=${password}   connection=${connection}
    ...   ELSE IF   "${cert_format}"=="pem"   coam.install_certificate   cert_file=${cert_file}   cert_type=AdditionalCa
    ...   cert_format=PEM   connection=${connection}
    ...   ELSE   Log To Console   '${cert_file}' is not certificate

COAM Restore Vendor Certificate
    [Arguments]   ${connection}=COAM
    coam.restore_vendor_certificate    connection=${connection}

COAM Try Connect gNB
    [Arguments]   ${gnb_addr}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Run Keyword and Ignore Error   Wait Until Keyword Succeeds   2m   20s   gNB not Connected   gnb_addr=${gnb_addr}
    Wait Until Keyword Succeeds   5m   20s   Try Connect gNB   gnb_addr=${gnb_addr}
    ${COAM_connected}   Run Keyword and Return Status   Wait Until Keyword Succeeds   5m   20s   COAM Login   bts_host=${gnb_addr}
    run keyword if  not ${COAM_connected}   Run Keywords   gNB reboot from SSH   gnb_addr=${gnb_addr}
    ...   AND   Sleep   2m
    Wait Until Keyword Succeeds   5m   20s   Try Connect gNB   gnb_addr=${gnb_addr}
    [Teardown]   Run Keyword If   ${COAM_connected}   COAM Logout

COAM commissioning if not onair
    Wait Until Keyword Succeeds   15m   30s   COAM Login    bts_host=${lmp_addr}   alias=CI_commission
    ${gnb_stauts}   COAM Get General Status   connection=CI_commission
    run keyword if  not '${gnb_stauts['proceduralState']}'=='OnAir'   CI_interface.Common Suite Setup
    [Teardown]   Run Keywords   Run Keyword If   $KEYWORD_STATUS=='FAIL'   COAM RESET SITE   connection=CI_commission
    ...   AND   Run Keyword If   $KEYWORD_STATUS=='FAIL'   Sleep   300s
    ...   AND   Wait Until Keyword Succeeds   5m   20s   Get SMOD Product Name   connection=CI_commission
    ...   AND   COAM Logout   connection=CI_commission

COAM Judge selenium_lib
    [Arguments]   ${url}=${WEBUI_ADDR}    ${connection}=release
    COAM Login   bts_host=${url}    alias=${connection}
    ${release}   COAM Get SW Release   connection=${connection}
    ${selenium_lib}   Run Keyword If   ${release.startswith("5G")}   Set Variable   coam
    ...   ELSE   Set Variable   sbts
    Set Suite Variable   ${selenium_lib}
    [Return]   ${release}
    [Teardown]   COAM Logout   connection=${connection}

# --------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------Selenium COAM Keywords----------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------
Stop Firefox Pids
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

Get COAM Alias Dict
    [Arguments]   ${url}=${WEBUI_ADDR}    ${coam}=${None}
    Run Keyword If   $selenium_lib==""   COAM Judge selenium_lib    url=${url}
    ${res}   Run Keyword If   $selenium_lib=="sbts"   Create Dictionary   sbts=${coam}
    ...   ELSE   Create Dictionary   coam=${coam}
    [Return]   ${res}

Capature Sreenshot COAM
    [Arguments]   ${file_dir}=${OUTPUT_DIR}   ${coam}=${None}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${file_dir}   &{alias_dict}

COAM SSH Get Release
    [Arguments]   ${ssh_ip}=${oam_addr}   ${ssh_username}=${oam_username}   ${ssh_password}=${oam_password}   ${connection}=ssh_release
    csn.Connect To   hostname=${ssh_ip}   username=${ssh_username}   password=${ssh_password}   alias=${connection}
    ${info}   csn.Execute   command=ls /ffs/run/TargetBD*xml   connection=${connection}
    ${release}   Set Variable   ${info.split('_')[1]}
    [Return]   ${release}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


COAM WEBUI Login
    [Documentation]    login the coam webui
    [Arguments]   ${url}=https://${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${display}=${false}
    ...   ${driver_alias}=WEBEM_DRIVER   ${version}=None   ${modal_action_configurations}=${None}    ${alias}=${None}
    Return From Keyword If   '${alias}' in @{selenium_gnb_login}
    Run Keyword If   '${alias}'=='None'   Stop Firefox Pids
    run keyword if  not ${display}   selenium_coam.enable_virtual_display

    ${release}   COAM SSH Get Release
    ${version}   Set Variable If
    ...   "${version}"!="None"   ${version}
    ...   ${release}

    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${download_dir}   Set Variable   /tmp/tmp_download_${curr_data}
    ${driver}   selenium_core.create_firefox_web_driver   download_dir=${download_dir}   name=${driver_alias}
    selenium_core.set_scope   alias=${driver_alias}   scope=global
    selenium_coam.login
    ...   url=${url}
    ...   username=${username}
    ...   password=${password}
    ...   browser=${driver}
    ...   download_dir=${download_dir}
    ...   timeout=${120}
    ...   version=${version}
    ...   modal_action_configurations=${modal_action_configurations}
    ...   alias=${alias}
    ${url_addr}    fetch from right    ${url}    https://
    ${alias_dict}   Get COAM Alias Dict   url=${url_addr}    coam=${alias}
    Run Keyword and Ignore Error   selenium_coam.disable_message_box   &{alias_dict}
    Run Keyword and Ignore Error   selenium_coam.disable_screen_lock   &{alias_dict}
    Append To List   ${selenium_gnb_login}   ${alias}
    Set Global Variable   ${selenium_gnb_login}
    ${exists}   selenium_coam.start_up_view_window_exists   &{alias_dict}
    Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window   &{alias_dict}
    [Return]   ${driver}

COAM WEBUI Logout
    [Documentation]   Logout the coam webui
    [Arguments]   ${display}=${false}   ${coam}=${None}
    Return From Keyword If   not ${selenium_gnb_login}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.logout   &{alias_dict}
    Remove Values From List   ${selenium_gnb_login}   ${coam}
    Set Global Variable   ${selenium_gnb_login}
    run keyword if  not ${display}   selenium_coam.disable_virtual_display
    Sleep   2s

COAM WEBUI Reset RU
    [Arguments]   ${type}   ${ru_index}   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.reset_ru_from_site_view
    ...   type=${type}
    ...   ru_index=${ru_index}
    ...   timeout=${60}
    ...   &{alias_dict}

COAM WEBUI GET LED status
    [Documentation]   COAM WEBUI GET LED status
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | unit | yes | Unit such as SMOD-1, BBMOD-1, or just cell id ex. '4' for cell with id 4 |
    ...    *RETURN VALUE*
    ...    led_status
    ...    Example
    ...    | COAM WEBUI GET LED status | SMOD-1 |
    ...    | COAM WEBUI GET LED status | BBMOD-1 |
    ...    | COAM WEBUI GET LED status | 1 |
    [Arguments]   ${unit}   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${led_status}   selenium_coam.get_led_status_of_an_unit   unit=${unit}   &{alias_dict}
    [Return]   ${led_status}

COAM WEBUI Whether Close Start Up View Window
    [Documentation]   Close Start Up View Window
    [Arguments]   ${coam}=${None}
    Sleep   5s
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${exists}   selenium_coam.start_up_view_window_exists   &{alias_dict}
    Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window   &{alias_dict}
    Sleep   5

COAM WEBUI Create Plan
    [Documentation]   Create Plan
    [Arguments]   ${is_copy}=${True}   ${copy_from}=CURRENT_BTS_CONF-1   ${config_name}=None   ${coam}=${None}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y%m%d%H%M%S
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${config_name}   Set Variable If
    ...   '${config_name}'=='None'   Plan_Copy_${curr_data}
    ...   ${True}   ${config_name}

    ${config_name}   Set Variable   Plan_Copy_${curr_data}
    selenium_coam.create_plan
    ...   is_copy=${is_copy}
    ...   copy_configuration_from=${copy_from}
    ...   configuration_name=${config_name}
    ...   timeout=${60}
    ...   &{alias_dict}

COAM WEBUI Save BTS Configuration
    [Arguments]   ${SCF_path}=${OUTPUT_DIR}/old_commission.xml   ${type}=0   ${change}=${True}   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${path}   selenium_coam.save_bts_configuration
    ...   save_configuration_type=${type}
    ...   is_save_planned_parameter_changes_selected=${change}
    ...   &{alias_dict}
    Sleep   10s
    Wait Until Keyword Succeeds   2m   20s   OperatingSystem.File Should Not Be Empty   path=${path}
    Move File   ${path}   ${SCF_path}

COAM WEBUI Load SCF
    [Arguments]   ${file_path}=${OUTPUT_DIR}/old_commission.xml   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${status}   selenium_coam.load_commissioning_file_and_check_load_status
    ...   file_path=${file_path}
    ...   timeout=${60}
    ...   &{alias_dict}
    [Return]   ${status}

COAM WEBUI Validate Plan
    [Documentation]   Validate Plan
    [Arguments]     ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.validate_plan   &{alias_dict}
    Sleep   10s

COAM WEBUI Get Definition Errors
    [Documentation]   Get Definition Errors
    [Arguments]   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${definition_errors}   selenium_coam.get_definition_errors   &{alias_dict}
    [Return]   ${definition_errors}

COAM WEBUI Get Relation Errors
    [Documentation]   Get Relation Errors
    [Arguments]   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${relation_errors}   selenium_coam.get_relation_errors   &{alias_dict}
    [Return]   ${relation_errors}

COAM WEBUI Get Parameter Details
    [Documentation]   Get Parameter Details
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${exists}   selenium_coam.start_up_view_window_exists   &{alias_dict}
    Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window   &{alias_dict}
    ${para_details}   selenium_coam.get_parameter_details
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   timeout=${60}
    ...   &{alias_dict}
    [Return]   ${para_details}

COAM WEBUI Get Parameter Value
    [Documentation]   Get Parameter Value
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${para_value}   selenium_coam.get_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   timeout=${60}
    ...   &{alias_dict}
    [Return]   ${para_value}

COAM WEBUI Get Parameter Plan Value
    [Documentation]   Get Parameter Plan Value
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}
    ...   ${node_index}=${0}   ${bts_configuration}=Current   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${para_value}   get_planned_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   node_index=${node_index}
    ...   abbr=${abbr}
    ...   bts_configuration=${bts_configuration}
    ...   timeout=${60}
    ...   &{alias_dict}
    [Return]   ${para_value}

COAM WEBUI Set Parameter Value
    [Documentation]   Set Parameter Value
    [Arguments]   ${dist_name}   ${filter_param}   ${new_value}    ${abbr}=${None}
    ...   ${node_index}=${0}   ${parameter_status}=All parameters
    ...   ${bts_configuration}=Current   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.set_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   new_value=${new_value}
    ...   node_index=${node_index}
    ...   parameter_status=${parameter_status}
    ...   abbr=${abbr}
    ...   bts_configuration=${bts_configuration}
    ...   timeout=${60}
    ...   &{alias_dict}

COAM WEBUI Undo Changes
    [Documentation]   Undo Changes
    [Arguments]     ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.undo_changes   timeout=${60}   &{alias_dict}

COAM WEBUI Check Cell Status
    [Arguments]   ${cell_index}=1   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${cell_index}   &{alias_dict}
    ${status}   Set Variable   ${cell_info['Status']}
#    Should Contain   ${status['Procedural status'].lower()}   configured
    # Should Contain   ${status['Availability status'].lower()}   online
    Should Contain   ${status['Operational state'].lower()}   enabled
    Should Contain   ${status['Administrative state'].lower()}   unlocked

COAM WEBUI Login ENB
    [Documentation]    login the ENB coam webui
    [Arguments]   ${url}=https://${Enb_ip}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    ...   ${display}=${false}   ${coam}=${enb_web_alias}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9
    run keyword if  not ${display}   selenium_coam.enable_virtual_display
    selenium_coam.login   url=${url}   username=${username}   password=${password}   timeout=${120}   alias=${coam}
    selenium_coam.disable_message_box   &{alias_dict}
    selenium_coam.disable_screen_lock   &{alias_dict}

COAM WEBUI Logout ENB
    [Documentation]   Logout the ENB coam webui
    [Arguments]   ${display}=${false}   ${coam}=${enb_web_alias}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.logout   &{alias_dict}
    run keyword if  not ${display}   selenium_coam.disable_virtual_display
    Sleep   2s
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

COAM WEBUI Add Object With Close Startup View window Retry
    [Arguments]   ${object_name}    ${object_class_name}   ${id_value}
    ...   ${is_load_default_values}=${false}    ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${obj_res}   Run Keyword And Return Status   selenium_coam.add_object    object_name=${object_name}
    ...    object_class_name=${object_class_name}   id_value=${id_value}
    ...   is_load_default_values=${is_load_default_values}   &{alias_dict}
    Return From Keyword If   ${obj_res}
    COAM WEBUI Whether Close Start Up View Window   coam=${coam}
    selenium_coam.add_object    object_name=${object_name}
    ...    object_class_name=${object_class_name}   id_value=${id_value}
    ...   is_load_default_values=${is_load_default_values}   &{alias_dict}

COAM WEBUI Remove Object by Check Exists
    [Arguments]   ${object_name}    ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${check_param}   Run Keyword If   $selenium_lib=="sbts"   Create Dictionary   sbts=${coam}   object_name=${object_name}
    ...   ELSE   Create Dictionary   parent_name=${object_name}   parameter_name=${EMPTY}   coam=${coam}
    ${obj_list}   selenium_coam.get_object_name_list   &{check_param}
    Run Keyword If   ${obj_list}   selenium_coam.remove_object   object_name=${object_name}   &{alias_dict}

Cell Operation State
    [Arguments]   ${cell_index}=1   ${INSID}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    ${state}=Unlocked   ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.set_parameter_value   dist_name=${INSID}/NRCELL-${cell_index}
    ...    filter_param=Administrative state    new_value=${state}   &{alias_dict}
    selenium_coam.validate_plan   &{alias_dict}
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120   &{alias_dict}
    Sleep   10s
    COAM WEBUI Whether Close Start Up View Window   coam=${coam}

Validate Plan and Return Error
    [Documentation]   Validate Plan and Report Error
    [Arguments]     ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.validate_plan   &{alias_dict}
    Sleep   10s
    COAM WEBUI Whether Close Start Up View Window   coam=${coam}
    @{errors} =    create list
    ${defination_errors}    selenium_coam.get_definition_errors   &{alias_dict}
    COAM WEBUI Whether Close Start Up View Window   coam=${coam}
    ${relation_errors}      selenium_coam.get_relation_errors   &{alias_dict}
    COAM WEBUI Whether Close Start Up View Window   coam=${coam}
    ${hardware_errors}      selenium_coam.get_hardware_errors   &{alias_dict}
    COAM WEBUI Whether Close Start Up View Window   coam=${coam}
    ${validate_errors}    combine lists    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    ${validate_errors_num}    Get Length   ${validate_errors}
    Log to console    The current BTS exist ${validate_errors_num} errors.
    Log to console    defination_errors: ${defination_errors}
    Log to console    relation_errors: ${relation_errors}
    Log to console    hardware_errors: ${hardware_errors}
    [Return]    ${validate_errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}

Perform sub-feature SCF
   [Arguments]    ${scf_name}=7380
#   wait until keyword succeeds     10x    30s    COAM Login    bts_host=${LMP_ADDR}
   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
#   ${gnb_release}    Run keyword if   '${gnb_release}'=='SBTS21B'     set variable   21B
#   ...   ELSE IF    '${gnb_release}'=='5G21A'     set variable   21A
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R1'     set variable   22R1
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R2'     set variable   22R2
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R3'     set variable   22R3
#   ...   ELSE IF    '${gnb_release}'=='TRUNK'     set variable   TRUNK
   wait until keyword succeeds     3x    5min
   ...   COAM SCF Commission    filepath=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/${scf_name}_${gnb_release}.xml
   Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
#   [Teardown]    COAM Logout


Fault With Alarm Should Be Present
    [Arguments]  ${FaultID}     ${AlarmID}    ${alias}=COAM
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=${alias}
    ${len}    Get Length    ${active_alarms}
    ${fault_alarm_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${activ_faultId}   Get Variable Value   ${active_alarms[${i}]['faultId']}   ${EMPTY}
        Continue For Loop If   "${activ_faultId}"=="${EMPTY}"
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        ${a_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${fault_alarm_list}    ${f_id}+${a_id}
    END
    Log To Console    Active alarms: alarm_id_list=${fault_alarm_list}
    ${list}     convert to string  ${fault_alarm_list}
    Should Contain    ${fault_alarm_list}    ${FaultID}+${AlarmID}

Fault With Alarm Should Not Be Present
    [Arguments]  ${FaultID}     ${AlarmID}   ${alias}=COAM
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=${alias}
    ${len}    Get Length    ${active_alarms}
    ${fault_alarm_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${active_faultId}   Get Variable Value   ${active_alarms[${i}]['faultId']}   ${EMPTY}
        Continue For Loop If   "${active_faultId}"=="${EMPTY}"
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        ${a_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${fault_alarm_list}    ${f_id}+${a_id}
    END
    Log To Console    Active alarms: alarm_id_list=${fault_alarm_list}
    ${list}     convert to string  ${fault_alarm_list}
    Should Not Contain    ${fault_alarm_list}    ${FaultID}+${AlarmID}

Faults Should Not Be Present in Active and History
    [Arguments]  @{Fault_list}     ${alias}=COAM
    ${active_alarms}    coam.get_active_alarms    timeout=${300}    connection=${alias}
    ${history_alarms}    coam.get_historic_alarms    connection=${alias}    load_history=${True}    timeout=${300}
    ${len}    Get Length    ${active_alarms}
    ${active_fault_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${faultId}   Get Variable Value   ${active_alarms[${i}]['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${active_fault_list}    ${f_id}
    END
    Log To Console    Active alarms: active_fault_list=${active_fault_list}
    ${active_fault_list}     convert to string  ${active_fault_list}
    FOR   ${fault}   IN  @{Fault_list}
        Should Not Contain    ${active_fault_list}    ${fault}   msg=active fault list contain unexpected fault:${fault}
    END
    ${len}    Get Length    ${history_alarms}
    ${history_fault_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${f_id}    Get From Dictionary    ${history_alarms[${i}]}    faultId
        Append To List    ${history_fault_list}    ${f_id}
    END
    Log To Console    history alarms: history_fault_list=${history_fault_list}
    ${history_fault_list}     convert to string  ${history_fault_list}
    FOR   ${fault}   IN   @{Fault_list}
        Should Not Contain    ${history_fault_list}    ${fault}   msg=history fault list contain unexpected fault:${fault}
    END

check Faults for siso common
    [Arguments]  ${allowedfault_list}     ${alias}=COAM
    ${active_alarms}    coam.get_active_alarms    timeout=${300}    connection=${alias}
    ${history_alarms}    coam.get_historic_alarms    connection=${alias}    load_history=${True}    timeout=${300}
    ${len}    Get Length    ${active_alarms}
    ${active_fault_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${faultId}   Get Variable Value   ${active_alarms[${i}]['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${active_fault_list}    ${f_id}
    END
    Log To Console    Active alarms: active_fault_list=${active_fault_list}
#    ${active_fault_list}     convert to string  ${active_fault_list}
    FOR   ${fault}   IN  @{active_fault_list}
        run keyword if    '${fault}' not in @{allowedfault_list}     FAIL    msg=active fault list contain unexpected fault:${fault}
    END
    ${len}    Get Length    ${history_alarms}
    ${history_fault_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${f_id}    Get From Dictionary    ${history_alarms[${i}]}    faultId
        Append To List    ${history_fault_list}    ${f_id}
    END
    Log To Console    history alarms: history_fault_list=${history_fault_list}
#    ${history_fault_list}     convert to string  ${history_fault_list}
    FOR   ${fault}   IN   @{history_fault_list}
        run keyword if    '${fault}' not in @{allowedfault_list}     FAIL   msg=history fault list contain unexpected fault:${fault}
    END


check Active Faults for siso common
    [Arguments]  ${allowedfault_list}     ${alias}=COAM
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=${alias}
    ${len}    Get Length    ${active_alarms}
    ${active_fault_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${faultId}   Get Variable Value   ${active_alarms[${i}]['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${active_fault_list}    ${f_id}
    END
    Log To Console    Active alarms: active_fault_list=${active_fault_list}
#    ${active_fault_list}     convert to string  ${active_fault_list}
    FOR   ${fault}   IN  @{active_fault_list}
        run keyword if    '${fault}' not in @{allowedfault_list}     FAIL    msg=active fault list contain unexpected fault:${fault}
    END


check History Faults for siso common
    [Arguments]  ${allowedfault_list}     ${alias}=COAM
    ${history_alarms}    coam.get_historic_alarms    connection=${alias}    load_history=${True}    timeout=${300}
    ${len}    Get Length    ${history_alarms}
    ${history_fault_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${f_id}    Get From Dictionary    ${history_alarms[${i}]}    faultId
        Append To List    ${history_fault_list}    ${f_id}
    END
    Log To Console    history alarms: history_fault_list=${history_fault_list}
#    ${history_fault_list}     convert to string  ${history_fault_list}
    FOR   ${fault}   IN   @{history_fault_list}
        run keyword if    '${fault}' not in @{allowedfault_list}     FAIL   msg=history fault list contain unexpected fault:${fault}
    END

BBMOD Should Be initializing
    [Documentation]
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['administrativeState']}    UnLocked
                                  ...  msg=Current bbmod administrativeState is not in locked status    ignore_case=${True}
    Should be equal as strings    ${bbmod_status['status']['operationalState']}       Disabled
                                  ...  msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus']}       initializing
                                  ...  msg=Current bbmod proceduralStatus is not in configured status    ignore_case=${True}
    Should be equal as strings    ${bbmod_status['status']['availabilityStatus']}     Offline
                                  ...  msg=Current bbmod availabilityStatus is not in Online status    ignore_case=${True}


BBMOD Should Be enabled
    [Documentation]
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['administrativeState']}    UnLocked
                                  ...  msg=Current bbmod administrativeState is not in locked status    ignore_case=${True}
    Should be equal as strings    ${bbmod_status['status']['operationalState']}       enabled
                                  ...  msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus']}       configured
                                  ...  msg=Current bbmod proceduralStatus is not in configured status    ignore_case=${True}


RU Should Be initializing
    [Arguments]  ${rmod_index}=0    ${connection}=COAM
    &{ru_status}    COAM Get Radio Module Status   connection=${connection}   rmod_index=${rmod_index}
    Should be equal as strings    ${ru_status['administrativeState'].lower()}   unlocked
                                  ...  msg=Current RU administrativeState is not in locked status    ignore_case=${True}
    Should be equal as strings    ${ru_status['operationalState'].lower()}   disabled
                                  ...  msg=Current RU operationalState is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['proceduralStatus'].lower()}   initializing
                                  ...  msg=Current RU proceduralStatus is not in configured status    ignore_case=${True}
    Should be equal as strings    ${ru_status['availabilityStatus'].lower()}   failed
                                  ...  msg=Current RU availabilityStatus is not in Online status    ignore_case=${True}

Get BBMOD Number
    @{bbmod_info_list}    Get BBMODs info
    ${bbmod_num}    get length  ${bbmod_info_list}
    [Return]    ${bbmod_num}

Get RU Number
    @{RU_info_list}    taf_coam.Get RMODs Info
    ${ru_num}    get length  ${RU_info_list}
    [Return]    ${ru_num}

Add COAM User at VM
    add_vm_user    username=coam   password=zO&n1W*ktp7
    vm_network_config

COAM Block Cell
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.block_cell   ${dist_name}   connection=${connection}   timeout=${600}

COAM Unblock Cell
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.unblock_cell   ${dist_name}   connection=${connection}   timeout=${600}

COAM Lock BBMOD
    [Documentation]
    ...   | Author: ruiyu.han@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    led_status
    ...    Example
    ...    | COAM Lock BBMOD| dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1 |
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.lock   ${dist_name}   connection=${connection}   timeout=${120}

COAM Unlock BBMOD
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.unlock   ${dist_name}   connection=${connection}   timeout=${120}


COAM Block Rat
    [Documentation]
    ...   | Author: ruiyu.han@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    led_status
    ...    Example
    ...    | COAM Block Rat| 1 |
    [Arguments]   ${rat_name}=NR   ${connection}=COAM    ${timeout}=${60}
    coam.block_rat   rat=${rat_name.upper()}   connection=${connection}   timeout=${timeout}

COAM Unlock Rat
    [Arguments]   ${rat_name}=NR   ${connection}=COAM    ${timeout}=${60}
    coam.unblock_rat   rat=${rat_name.upper()}  connection=${connection}   timeout=${timeout}


COAM Set RAD Param
    [Arguments]    ${domain}   ${name}    ${value}   ${persistency}=NotPersistent   ${connection}=COAM   ${timeout}=600
    coam.set_rad_debug_parameters    domain=${domain}    name=${name}    value=${value}    persistency=${persistency}
    ...   connection=${connection}   timeout=${timeout}

COAM Reset RAD Param
    [Arguments]    ${domain}   ${name}    ${connection}=COAM   ${timeout}=600
    coam.reset_rad_debug_parameters    domain=${domain}    name=${name}
    ...   connection=${connection}   timeout=${timeout}

COAM Lock NRDU
    [Arguments]    ${distname}
    ${nrdu}    create dictionary    dist_name=${distname}
    ...    value=Locked
    ...     parameter=administrativeState
    ${nrdu_list}     create list     ${nrdu}
    ${update_nrdu}     create dictionary     update=${nrdu_list}
    COAM Commission Prameters Operation      param_dic_to_change=${update_nrdu}

COAM Unlock NRDU
    [Arguments]    ${distname}
    ${nrdu}    create dictionary    dist_name=${distname}
    ...    value=Unlocked
    ...     parameter=administrativeState
    ${nrdu_list}     create list     ${nrdu}
    ${update_nrdu}     create dictionary     update=${nrdu_list}
    COAM Commission Prameters Operation      param_dic_to_change=${update_nrdu}

WebEM Check X2 Link Status
    [Arguments]   ${x2_enb_mrbtsId}
    ${x2_info}  selenium_sbts.get_hw_info  hw_name=LTEENB-${x2_enb_mrbtsId}
    Log To Console  X2 Link Info:${x2_info}
    Log To Console  X2 link status:${x2_info['X2 Link Status']}, should be available
    Log To Console  X2 link lock:${x2_info['X2 link lock']}, should be unlocked
    ${link_state}    Convert To Lower Case    ${x2_info['X2 Link Status']}
    ${link_lock}    Convert To Lower Case    ${x2_info['X2 link lock']}
    Should Be Equal   ${link_state}    available
    Should Be Equal   ${link_lock}    unlocked

COAM Commission Prameters Operation
     [Documentation]  Author: Han Ruiyu
    ...              Description: this keyword is to add or update or delete several parameters/lists via rest api.
    ...    ${param_dic_to_change} should be given in special format, as the following:
    ...    ${param_dic_to_change}={
    ...   'update': [
    ...    dict(value='7_5_CLOUD402T091 20+20+20 nonCA', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
    ...                 parameter='btsName'),
    ...            dict(value='BasicCAMode', dist_name='MRBTS-%s/NRBTS-%s/NRDU-1' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...                 parameter='flexibleCAMode'),    -----update parameter type
    ...            dict(dist_name='MRBTS-%s/NRBTS-%s/NRDU-1' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...                 parameter='carrierAggregationSupportList', -----update list type parameter , notice the value should be list type
    ...                 value=['none']),
    ...            dict(dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
    ...                 list_name='preventParamModifList',
    ...                 value='NRCELL-cellBwpList.cellBwpId'),----just support update one value
    ...        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...         list_name='tddFrameStructure',
    ...         value=dict(frameStructureType='tdLte', guardPeriodLength='6Symbols', lteToNrFrameShift='0ms',
    ...                    tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='2/8')),   ----change complex list value, each parameter is needed
    ...        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...         list_name='cellBwpList',
    ...         value=dict(bwpDN='MRBTS-858/NRBTS-858/BWP_PROFILE-8', cellBwpId='0')),
    ...        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...         list_name='cellBwpList',
    ...         value=dict(bwpDN='MRBTS-858/NRBTS-858/BWP_PROFILE-80', cellBwpId='1'))
    ...        ],
    ...        'delete': [
    ...            dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...                 parameter='sCellAdditionMethod'),----delete parameter
    ...            # dict(dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
    ...            #      list_name='preventParamModifList'),
    ...            # dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
    ...            #      list_name='cellBwpList'),
    ...            dict(dist_name='MRBTS-%s/NRBTS-%s/BWP_PROFILE-5' % (GLOBAL_BTS_ID, MRBTS_ID))---delete object
    ...        ]
    ...    }
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    ...     Note: if use this keyword to modify p_name involving in list_name, then all other p_name which exist in this list_name
    ...          should be given thoroughly as well.
    [Arguments]    ${param_dic_to_change}    ${timeout}=${360}    ${connection}=COAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True

    ${update_param_list}    Create List
    ${update_simple_list}    Create List
    ${update_complex_list}    Create List
    ${del_param_list}    Create List
    ${del_obj_list}    Create List
    ${del_list_list}    Create List
#
    _Sort types of parameters list      ${param_dic_to_change}     ${update_param_list}    ${update_simple_list}    ${update_complex_list}
    ...   ${del_param_list}   ${del_obj_list}   ${del_list_list}
#
#    #Create delta for recommission
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_${timestamp}
    coam.Create Delta  delta_id=${delta_id}

    #append update_param_list to delta
    FOR  ${dic}  IN  @{update_param_list}
        Exit For Loop If     len(${update_param_list})<=0
        coam.Append Parameter Update To Delta  dist_name=${dic['dist_name']}   parameter=${dic['parameter']}
    ...   value=${dic['value']}  delta_id=${delta_id}
    END

    #append update_simple_list to delta
    FOR  ${dic}  IN  @{update_simple_list}
         Exit For Loop If     len(${update_simple_list})<=0
         coam.append_list_items_to_delta  ${dic['dist_name']}   ${dic['list_name']}
    ...   ${dic['value']}  delta_id=${delta_id}
    END

    #append update_complex_list to delta
    FOR  ${dic}  IN  @{update_complex_list}
         Exit For Loop If     len(${update_complex_list})<=0
         coam.append_complex_item_to_delta  ${dic['dist_name']}   ${dic['list_name']}
    ...   &{dic['value']}   delta_id=${delta_id}
    END


    #append delete object list to delta
    FOR  ${dic}  IN  @{del_obj_list}
        Exit For Loop If     len(${del_obj_list})<=0
        coam.Append Managed Object To Delta  dist_name=${dic['dist_name']}    operation=delete    delta_id=${delta_id}
    END

    #append delete param_list to delta
    FOR  ${dic}  IN  @{del_param_list}
        Exit For Loop If     len(${del_param_list})<=0
        coam.append parameter delete to delta    dist_name=${dic['dist_name']}   parameter=${dic['parameter']}    delta_id=${delta_id}
    END

    #append delete list_list to delta
    FOR  ${dic}  IN  @{del_list_list}
        Exit For Loop If     len(${del_list_list})<=0
        coam.append parameter delete to delta    dist_name=${dic['dist_name']}   parameter=${dic['list_name']}    delta_id=${delta_id}
    END

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    log to console    ${delta_file}
    ${update_via_api_status}    run keyword and return status    coam.Perform Delta Recommissioning
    ...    delta_file=${delta_file}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Should be True   ${update_via_api_status}
    ...    msg=parameters do not update successfully.

    coam.Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True

_Sort types of parameters list
    [Arguments]     ${param_dic_to_change}     ${update_param_list}    ${update_simple_list}    ${update_complex_list}    ${del_param_list}
    ...   ${del_obj_list}   ${del_list_list}
    @{param_list_update}   Get Variable Value   ${param_dic_to_change['update']}    @{EMPTY}
    FOR  ${dic}  IN  @{param_list_update}
        Exit For loop if    len(${param_dic_to_change['update']})<=0
        ${keys}   Get Dictionary Keys    ${dic}
        run keyword if    'parameter' in ${keys}    Append to list   ${update_param_list}    ${dic}
        ...   ELSE IF   'list_name' in ${keys}    _Judge Value Type and Sort   ${dic}  ${update_simple_list}    ${update_complex_list}
    END

    @{param_list_delete}   Get Variable Value   ${param_dic_to_change['delete']}    @{EMPTY}
    FOR  ${dic}  IN  @{param_list_delete}
        Exit For loop if     len(${param_list_delete})<=0
        ${keys}   Get Dictionary Keys    ${dic}
        run keyword if    'parameter' in ${keys}    Append to list   ${del_param_list}    ${dic}
        ...   ELSE IF    'list_name' in ${keys}    Append to list   ${del_list_list}    ${dic}
        ...   ELSE        Append to list   ${del_obj_list}    ${dic}
    END


    LOG    ${update_param_list}
    LOG    ${update_simple_list}
    LOG    ${update_complex_list}
    LOG    ${del_param_list}
    LOG    ${del_obj_list}
    LOG    ${del_list_list}


_Judge Value Type and Sort
    [Arguments]      ${dic}    ${update_simple_list}    ${update_complex_list}
     ${is_str} =    Evaluate    "${dic['value'].__class__.__name__}" == "str"
    run keyword if  ${is_str}    Append to list  ${update_simple_list}    ${dic}
    ...   ELSE    _Auto Fill Complex List  update_complex_list=${update_complex_list}    dic=${dic}


_Auto Fill Complex List
    [Arguments]    ${dic}    ${update_complex_list}
     ${scf_xml}   coam.get_scf   connection=COAM   timeout=${600}
     ${list_item_p_dict}    XML Get List Item Parameter    dist_name=${dic['dist_name']}   scf_xml=${scf_xml}
     ${dic_update}    create dictionary
     ${needchange}    set variable    ${False}
     FOR   ${key}    IN   @{dic['value']}
         FOR   ${parentkey}    IN   @{list_item_p_dict}
             ${subkeys}    Get Dictionary Keys     ${list_item_p_dict['${parentkey}'][0]}
             continue for loop if  '${key}' not in ${subkeys}
             Run Keyword If   '${key}' in ${subkeys}
             ...    set to dictionary    ${list_item_p_dict['${parentkey}'][0]}    ${key}=${dic['value']['${key}']}
             ${needchange}    set variable if    '${key}' in ${subkeys}    ${True}   ${False}
             Exit For Loop If   '${key}' in ${subkeys}
         END
     END
     run keyword if  ${needchange}    set to dictionary    ${dic_update}    dist_name=${dic['dist_name']}
     ...    list_name=${dic['list_name']}
     ...    value=${list_item_p_dict['${parentkey}'][0]}
     run keyword if  ${needchange}    Append To List    ${update_complex_list}    ${dic_update}
     ...   ELSE    Append To List    ${update_complex_list}    ${dic}
     [Return]    ${update_complex_list}

ADMIN Block NR cell and check status
    [Arguments]   ${cell_index}
    COAM Block Cell   MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell_index}
    wait Until Keyword Succeeds   1m   10s   ADMIN check NR cell status    cell_index=${cell_index}   expected_status='blocked'

ADMIN UnBlock NR cell and check status
    [Arguments]   ${cell_index}
    COAM Unblock Cell   MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell_index}
    wait Until Keyword Succeeds   10m   10s   ADMIN check NR cell status    cell_index=${cell_index}
    ...     expected_status='operationalstate': 'enabled'

ADMIN check NR cell status
    [Arguments]    ${cell_index}   ${expected_status}=unblocked
    ${nrcell}   COAM Get Managed Objects   class_name=NRCELL_R
    FOR  ${cellinfo}   IN  @{nrcell}
         ${nrcell_r}    Run Keyword If   ${cellinfo['distName'].count('NRCELL_R-${cell_index}')} > 0
         ...   set variable    ${cellinfo['distName']}
         exit for loop if   ${cellinfo['distName'].count('NRCELL_R-${cell_index}')} > 0
    END
    ${output}    COAM Get Cell Info   cell_id=${nrcell_r}
    ${output}    convert to string    ${output}
    should contain    ${output.lower()}    ${expected_status}

ADMIN check NR cell availability Status
    [Arguments]    ${cell_index}   ${expected_status}=unblocked
    ${nrcell}   COAM Get Managed Objects   class_name=NRCELL_R
    FOR  ${cellinfo}   IN  @{nrcell}
         ${nrcell_r}    Run Keyword If   ${cellinfo['distName'].count('NRCELL_R-${cell_index}')} > 0
         ...   set variable    ${cellinfo['distName']}
         exit for loop if   ${cellinfo['distName'].count('NRCELL_R-${cell_index}')} > 0
    END
    ${cell}    COAM Get Cell Info   cell_id=${nrcell_r}
    ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
    ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
    ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
    ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
    ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A

#    Run Keyword If   "${operationalState}"!="N/A"
#    ...   Should Be Equal   ${operationalState.lower()}       enabled
#    # # Sometimes usageState=Idle
#    # Run Keyword If   "${usageState}"!="N/A"
#    # ...   Should Be Equal   ${usageState.lower()}             active
#    Run Keyword If   "${proceduralStatus}"!="N/A"
#    ...   Should Be Equal   ${proceduralStatus.lower()}       configured
#    Run Keyword If   "${administrativeState}"!="N/A"
#    ...   Should Be Equal   ${administrativeState.lower()}    unlocked

    Run Keyword If   "${availabilityStatus}"!="N/A"
    ...   should contain    ${availabilityStatus.lower()}   ${expected_status}
    ...   ELSE IF   ${expected_status.count(":'-'")}>0
    ...   should contain    ${operationalState.lower()}   enabled


ADMIN Block LTE cell and check status
    [Arguments]   ${cell_index}
    COAM Block Cell   MRBTS-${GLOBAL_BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${cell_index}

    Wait Until Keyword Succeeds   1m   10s   ADMIN check LTE cell status    cell_index=${cell_index}   expected_status='blocked'

ADMIN UnBlock LTE cell and check status
    [Arguments]   ${cell_index}
    COAM Unblock Cell   MRBTS-${GLOBAL_BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${cell_index}
    wait Until Keyword Succeeds   10m   10s   ADMIN check LTE cell status    cell_index=${cell_index}

ADMIN check LTE cell status
    [Arguments]    ${cell_index}    ${expected_status}=unblocked
    ${ltecell}   COAM Get Managed Objects   class_name=LNCEL_R
    FOR  ${cellinfo}   IN  @{ltecell}
         ${ltecell_r}    Run Keyword If   ${cellinfo['distName'].count('LNCEL_R-${cell_index}')} > 0
         ...   set variable    ${cellinfo['distName']}
         exit for loop if   ${cellinfo['distName'].count('LNCEL_R-${cell_index}')} > 0
    END
#    Set Suite Variable   ${nrcell_r}
    ${output}    COAM Get Cell Info   cell_id=${ltecell_r}
    ${output}    convert to string    ${output}
    should contain    ${output.lower()}    ${expected_status}

Get Runtime FRM info
    [Arguments]     ${connection}=COAM
    ${frm_output}=    coam.get_fsm_info   connection=${connection}
    Log Many    ${frm_output}
    ${runtime_smod_list}  create list
    FOR    ${item}    IN    @{frm_output}
        append to list    ${runtime_smod_list}    ${item['id']['internal']}
    END
    [Return]    ${runtime_smod_list}

COAM Lock unclock Cell via Change Parameter
    [Arguments]    ${celltype}    ${cellid}     ${operation}=Locked
    ...    ${timeout}=${180}    ${connection}=COAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_${timestamp}
    coam.Create Delta  delta_id=${delta_id}
    run keyword if    ${celltype.count('nr')}>0
    ...   coam.Append Parameter Update To Delta
    ...   dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cellid}
    ...   parameter=administrativeState
    ...   value=${operation}
    ...   delta_id=${delta_id}
    ...   ELSE IF   ${celltype.count('lte')}>0
    ...   coam.Append Parameter Update To Delta
    ...   dist_name=MRBTS-${GLOBAL_BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${cellid}
    ...   parameter=administrativeState
    ...   value=${operation.lower()}
    ...   delta_id=${delta_id}
    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    log to console    ${delta_file}
    ${update_via_api_status}    run keyword and return status    coam.Perform Delta Recommissioning
    ...    delta_file=${delta_file}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Should be True   ${update_via_api_status}
    ...    msg=parameters do not update successfully.
    coam.Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True


WEBUI Check NR Cell Status
    [Arguments]   ${cell_index}=1   ${expected}=enabled    ${coam}=${None}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${cell_index}   &{alias_dict}
    ${status}   Set Variable   ${cell_info['Status']}
#    Should Contain   ${status['Procedural status'].lower()}   configured
    # Should Contain   ${status['Availability status'].lower()}   online
    Should Contain   ${status['Operational state'].lower()}   ${expected}

COAM Check Validation Error
    [Arguments]   ${save_check_point}=${True}     ${connection}=COAM
    Log   save_check_point='${save_check_point}'
    Log To Console   //TODO: COAM Check Validation Error
    ${file_name}   Set Variable   SCF_Validate.xml
    coam.get_current_scf_file
    ...   local_dir_path=${OUTPUT_DIR}
    ...   file_name=${file_name}
    ...   connection=${connection}
    ...   timeout=${60}

    ${output}   coam.validate_scf_online
    ...   scf_file=${OUTPUT_DIR}/${file_name}
    ...   connection=${connection}
    ...   timeout=180

    ${pdl_logs}   Get Variable Value   ${output["requestMessage"]["pdlValidationResult"]["logs"]}
    ${nidd_logs}   Get Variable Value   ${output["requestMessage"]["niddValidationResult"]["logs"]}

    ${pdl_status}   Get Variable Value   ${output["requestMessage"]["pdlValidationResult"]["status"]}
    ${nidd_status}   Get Variable Value   ${output["requestMessage"]["niddValidationResult"]["status"]}

    Should Be Equal   ${pdl_status}   OK
    Should Be Equal   ${nidd_status}   OK


COAM Check X2 Link Status at Gnb
    [Arguments]   ${connection}=COAM
    Log To Console   //TODO: COAM Check X2 Link Status at Gnb

    ${scf_content}   coam.get_scf   export_type=configurationAndRuntimeObjects   connection=${connection}

    # Check X2 Status on GNB testline
    ${LTEENB_element_list}   Get Elements   ${scf_content}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:LTEENB"]
    ${LTEENB_element_length}   Get Length   ${LTEENB_element_list}

    FOR   ${LTEENB_element}   IN   @{LTEENB_element_list}
        ${x2LinkStatus}   Get Element Text    ${LTEENB_element}   xpath=p[@name="x2LinkStatus"]
        ${x2LinkLock}   Get Element Text    ${LTEENB_element}   xpath=p[@name="x2LinkLock"]
        Should Be Equal   ${x2LinkStatus.lower()}   available
        Should Be Equal   ${x2LinkLock.lower()}   unlocked
    END


COAM Online Delete Nrcell
    [Arguments]   ${cell_index}=1    ${timeout}=${360}    ${connection}=COAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True

    #    #Create delta for recommission
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_${timestamp}
    coam.Create Delta  delta_id=${delta_id}

    ${nrcell_distname}   Set Variable   MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell_index}
    coam.append_managed_object_to_delta    dist_name=${nrcell_distname}   operation=delete   delta_id=${delta_id}

    ${nrcellgrp_distname}   Set Variable   MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${cell_index}
    coam.append_managed_object_to_delta    dist_name=${nrcellgrp_distname}   operation=delete   delta_id=${delta_id}

    ${lcelnr_distname}   Set Variable   MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}
    coam.append_managed_object_to_delta    dist_name=${lcelnr_distname}   operation=delete   delta_id=${delta_id}

    ${parameter_list}    Create List    refNrCellGroup
    ${refNrCellGroup_dic}    coam.get_parameter_by_distname
    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=COAM
    ${refNrCellGroup_list}    Set Variable    ${refNrCellGroup_dic[0]['parameters']['refNrCellGroup']}
    Remove Values From List    ${refNrCellGroup_list}    ${cell_index}
    coam.Append Parameter Update To Delta  dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1   parameter=refNrCellGroup
    ...   value=${refNrCellGroup_list}  delta_id=${delta_id}

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    log to console    ${delta_file}
    ${update_via_api_status}    run keyword and return status    coam.Perform Delta Recommissioning
    ...    delta_file=${delta_file}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Should be True   ${update_via_api_status}
    ...    msg=parameters do not update successfully.

    coam.Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True



XML Get List Item Parameter
    [Arguments]    ${dist_name}    ${scf_xml}
#    ${scf_xml}   coam.get_scf   connection=COAM   timeout=${600}

    ${elements}    XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@distName="${dist_name}"]/list/item/..

    ${list_item_p_dict}   Create Dictionary
    FOR   ${element}   IN   @{elements}
        ${list_item_p_name}   XML.Get Element Attribute   ${element}   name=name   xpath=.

        ${item_p_list}   Create List
        ${item_elements}    XML.Get Elements   ${element}   xpath=item
        FOR  ${item_element}   IN   @{item_elements}
            ${param_elem_list}   XML.Get Elements   ${item_element}   xpath=p
            &{param_dict}    Create Dictionary
            FOR   ${param_elem}   IN   @{param_elem_list}
                ${param_key}   XML.Get Element Attribute   ${param_elem}   name=name   xpath=.
                ${param_value}   XML.Get Element Text   ${param_elem}   xpath=.
                Set To Dictionary   ${param_dict}   ${param_key}=${param_value}
            END
            Append To List    ${item_p_list}   ${param_dict}
        END
        ${item_p_list_not_empty}   Run Keyword And Return Status   Should Not Be Empty   ${item_p_list}
        Run Keyword If   ${item_p_list_not_empty}   Set To Dictionary   ${list_item_p_dict}   ${list_item_p_name}=${item_p_list}
    END
    [Return]    ${list_item_p_dict}


XML Get P List Parameter
    [Arguments]    ${dist_name}    ${scf_xml}

    ${elements}    XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@distName="${dist_name}"]/list

    ${list_p_dict}   Create Dictionary
    FOR   ${element}   IN   @{elements}
        ${list_item_p_name}   XML.Get Element Attribute   ${element}   name=name   xpath=.
        ${p_elements}    XML.Get Elements   ${element}   xpath=p
        @{p_list}    Create List
        FOR   ${p_element}   IN   @{p_elements}
            ${p_value}   XML.Get Element Text   ${p_element}   xpath=.
            Append To List    ${p_list}   ${p_value}
        END
        ${p_list_not_empty}   Run Keyword And Return Status   Should Not Be Empty   ${p_list}
        Run Keyword If   ${p_list_not_empty}   Set To Dictionary   ${list_p_dict}   ${list_item_p_name}=${p_list}
    END
    [Return]    ${list_p_dict}


XML Get P Name Parameter
    [Arguments]    ${dist_name}    ${scf_xml}
    ${elements}    XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@distName="${dist_name}"]/p
    ${p_name_dict}   Create Dictionary
    FOR   ${element}   IN   @{elements}
        ${p_name}   XML.Get Element Attribute   ${element}   name=name   xpath=.
        ${p_value}   XML.Get Element Text   ${element}   xpath=.
        Set To Dictionary    ${p_name_dict}   ${p_name}=${p_value}
    END
    [Return]    ${p_name_dict}


XML Get Child distname
    [Arguments]    ${dist_name}    ${scf_xml}
    ${child_elements}   Get Elements   ${scf_xml}   xpath=cmData/managedObject[contains(@distName, "${dist_name}/")]

    ${child_distname_list}   Create List
    FOR   ${element}   IN   @{child_elements}
        ${child_dn}   XML.Get Element Attribute   ${element}   name=distName   xpath=.
        Append To List    ${child_distname_list}   ${child_dn}
    END
    [Return]    ${child_distname_list}



COAM Online Add Nrcell
    [Arguments]   ${params_change}    ${copy_cellindx}=1    ${cell_index}=2    ${timeout}=${360}
    ...    ${connection}=COAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True

    ${params_change_str}    convert to string    ${params_change}

    #    #Create delta for recommission
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_${timestamp}
    coam.Create Delta  delta_id=${delta_id}

    ${tochange_list}    create list
    ${tochange_step1_list}    create list


    Append To List      ${tochange_step1_list}      MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${copy_cellindx}
    Append To List      ${tochange_step1_list}      MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${copy_cellindx}
    Append To List      ${tochange_step1_list}      MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cellindx}

    ${scf_xml}   coam.get_scf   connection=${connection}   timeout=${600}
    ${nrcell_child_list}
    ...    XML Get Child distname    dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${copy_cellindx}    scf_xml=${scf_xml}
    ${lcelnr_child_list}
    ...    XML Get Child distname    dist_name=MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cellindx}
    ...    scf_xml=${scf_xml}

    ${tochange_list}    combine lists    ${tochange_step1_list}   ${nrcell_child_list}    ${lcelnr_child_list}

    FOR   ${dist}    IN   @{tochange_list}
        ${ori_distname}    set variable    ${dist}
        ${dist_name}    Replace String Using Regexp   ${dist}    -${copy_cellindx}   -${cell_index}
        coam.append_managed_object_to_delta    dist_name=${dist_name}  operation=create   delta_id=${delta_id}
        ${list_item_p_dict}    XML Get List Item Parameter   dist_name=${ori_distname}   scf_xml=${scf_xml}
        ${p_name_dict}    XML Get P Name Parameter    dist_name=${ori_distname}   scf_xml=${scf_xml}
        ${list_p_dict}    XML Get P List Parameter    dist_name=${ori_distname}   scf_xml=${scf_xml}
        FOR    ${param}    IN    @{list_item_p_dict}
            continue for loop if    ${params_change_str.count('${param}')}>0
            FOR   ${item}   IN    @{list_item_p_dict['${param}']}
                coam.Append Complex Item To Delta  ${dist_name}   ${param}
                ...   &{item}  delta_id=${delta_id}
            END
        END

        FOR    ${param}    IN    @{list_p_dict}
            continue for loop if    ${params_change_str.count('${param}')}>0
            coam.Append Parameter Update To Delta  dist_name=${dist_name}   parameter=${param}
            ...    value=${list_p_dict['${param}']}   delta_id=${delta_id}
        END


        FOR    ${param}    IN    @{p_name_dict}
            continue for loop if    ${params_change_str.count('${param}')}>0
            coam.Append Parameter Update To Delta  dist_name=${dist_name}   parameter=${param}
            ...    value=${p_name_dict['${param}']}   delta_id=${delta_id}
        END

    END


    FOR   ${parameter}    IN   @{params_change}
        ${is_str} =    Evaluate    "${parameter['value'].__class__.__name__}" == "str"
        ${is_bool} =    Evaluate    "${parameter['value'].__class__.__name__}" == "bool"
        ${is_int} =    Evaluate    "${parameter['value'].__class__.__name__}" == "int"
        ${is_float} =    Evaluate    "${parameter['value'].__class__.__name__}" == "float"
        ${is_list} =    Evaluate    "${parameter['value'].__class__.__name__}" == "list"
        ${is_dic}   run keyword if  ${is_list}
        ...   Evaluate    "${parameter['value'][0].__class__.__name__}" == "dict"
        run keyword if    ${is_str}    coam.append_parameter_update_to_delta
        ...    dist_name=${parameter['dist_name']}   parameter=${parameter['parameter']}
        ...   value=${parameter['value']}  delta_id=${delta_id}
        ...   ELSE IF    ${is_list} and ${is_dic}    coam.append_complex_item_to_delta   ${parameter['dist_name']}
        ...   ${parameter['parameter']}
        ...   &{parameter['value']}    delta_id=${delta_id}
        ...   ELSE    coam.Append Parameter Update To Delta   dist_name=${parameter['dist_name']}
        ...   parameter=${parameter['parameter']}
        ...   value=${parameter['value']}    delta_id=${delta_id}
    END


    ${parameter_list}    Create List    refNrCellGroup
    ${refNrCellGroup_dic}    coam.get_parameter_by_distname
    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=COAM
    ${refNrCellGroup_list}    Set Variable    ${refNrCellGroup_dic[0]['parameters']['refNrCellGroup']}
    append to list    ${refNrCellGroup_list}    ${cell_index}
    coam.Append Parameter Update To Delta  dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1   parameter=refNrCellGroup
    ...   value=${refNrCellGroup_list}  delta_id=${delta_id}


    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    log to console    ${delta_file}
    ${update_via_api_status}    run keyword and return status    coam.Perform Delta Recommissioning
    ...    delta_file=${delta_file}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Should be True   ${update_via_api_status}
    ...    msg=parameters do not update successfully.

    coam.Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True