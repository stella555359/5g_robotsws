*** Settings ***
Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Library   taf.selenium.gnb.oam.core    WITH NAME      selenium_core
Library   Collections
Library   OperatingSystem
Library   DateTime

Library   String
Library   XML   True
Library   ./libraries/selenium_utils.py
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
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.reset_unit
    ...   dist_name=${dist_name}
    ...   reset_type=Hard
    ...   force_radio_reset=True
    ...   connection=COAM
    ...   timeout=${1200}

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
    ...   ${reset_type}=ConfigurationWithResetOnlyActivePartitionAndRestoreNcf
    coam.reset_configuration
    ...   remove_operator_certificates=${remove_operator_certificates}
    ...   remove_user_account_credentials=${remove_user_account_credentials}
    ...   connection=${connection}
    ...   reset_type=${reset_type}

COAM Reset RAT
    [Documentation]   COAM Reset RAT
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    Example
    ...    | COAM Reset RAT   NR |
    [Arguments]   ${rat_type}=NR   ${connection}=COAM
    coam.reset_rat
    ...   rat_type=${rat_type}
    ...   connection=${connection}
    ...   timeout=${1200}

Get BBMODs info
    [Arguments]   ${alias}=COAM
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
    [Return]   ${active_alarms}

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
    ...   timeout=${600}
    ...   connection=${connection}

COAM Get Parameter Value By XPath
    [Arguments]   ${xpath}=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]/p[@name="btsName"]   ${connection}=COAM
    ${scf_xml}   coam.get_scf   connection=${connection}   timeout=${600}   export_type=configurationAndRuntimeObjects
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
    coam.lock_cell   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Unlock Cell
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.unlock_cell   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Lock RU
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.lock_RU   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Unlock RU
    [Arguments]   ${dist_name}   ${connection}=COAM
    coam.unlock_RU   dist_name=${dist_name}   connection=${connection}   timeout=${600}

COAM Check Units Status Normal
    [Arguments]   ${component}   ${connection}=COAM
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

Catch Snapshot COAM
    [Timeout]   30m
    [Arguments]   ${local_file_path}=None   ${connection}=COAM
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${local_file_path}   Set Variable If
    ...   '${local_file_path}'=='None'   ${OUTPUT_DIR}/snapshot_coam_${curr_data}.zip
    ...   ${true}   ${local_file_path}
    Run Keyword And Ignore Error   coam.get_snapshot   target_file_name=${local_file_path}   timeout=${2100}   connection=${connection}
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
    [Arguments]   ${cert_file}   ${password}=123456
    ${cert_format}   Set Variable   ${cert_file.split('.')[-1]}
    Run Keyword If   "${cert_format}"=="p12"   coam.install_certificate   cert_file=${cert_file}   cert_type=BtsTrustChain
    ...   cert_format=P12   password=${password}   connection=COAM
    ...   ELSE IF   "${cert_format}"=="pem"   coam.install_certificate   cert_file=${cert_file}   cert_type=AdditionalCa
    ...   cert_format=PEM   connection=COAM
    ...   ELSE   Log To Console   '${cert_file}' is not certificate

COAM Restore Vendor Certificate
    coam.restore_vendor_certificate    connection=COAM

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

COAM WEBUI Login
    [Documentation]    login the coam webui
    [Arguments]   ${url}=https://${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${display}=${false}
    ...   ${driver_alias}=WEBEM_DRIVER   ${version}=None   ${alias}=${None}
    Return From Keyword If   '${alias}' in @{selenium_gnb_login}
    Run Keyword If   '${alias}'=='None'   Stop Firefox Pids
    run keyword if  not ${display}   selenium_coam.enable_virtual_display

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
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}
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
    ${errors}    combine lists    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    ${errors_num}    Get Length   ${errors}
    Log to console    The current BTS exist ${errors_num} errors.
    Log to console    defination_errors: ${defination_errors}
    Log to console    relation_errors: ${relation_errors}
    Log to console    hardware_errors: ${hardware_errors}
    [Return]    ${errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}

Perform sub-feature SCF
   [Arguments]    ${feature_name}=7380
#   wait until keyword succeeds     10x    30s    COAM Login    bts_host=${LMP_ADDR}
   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
   ${gnb_release}    Run keyword if   '${gnb_release}'=='SBTS21B'     set variable   21B
   ...   ELSE IF    '${gnb_release}'=='5G21A'     set variable   21A
   ...   ELSE IF    '${gnb_release}'=='SBTS22R1'     set variable   22R1
   ...   ELSE IF    '${gnb_release}'=='SBTS22R2'     set variable   22R2
   ...   ELSE IF    '${gnb_release}'=='SBTS22R3'     set variable   22R3
   ...   ELSE IF    '${gnb_release}'=='TRUNK'     set variable   TRUNK
   wait until keyword succeeds     5x    5min
   ...   COAM SCF Commission    filepath=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${gnb_release}_${feature_name}.xml
#   [Teardown]    COAM Logout


Fault With Alarm Should Be Present
    [Arguments]  ${FaultID}     ${AlarmID}    ${alias}=COAM
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=${alias}
    ${len}    Get Length    ${active_alarms}
    ${fault_alarm_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
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
        ${f_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        ${a_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${fault_alarm_list}    ${f_id}+${a_id}
    END
    Log To Console    Active alarms: alarm_id_list=${fault_alarm_list}
    ${list}     convert to string  ${fault_alarm_list}
    Should Not Contain    ${fault_alarm_list}    ${FaultID}+${AlarmID}

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
