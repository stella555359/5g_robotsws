*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
#===============================================================================================================================================
#===============================================================================================================================================
#===============================================================================================================================================
#Admin CLI
COAM Login
    [Arguments]   ${bts_host}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAM
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${500}
    ...   admin_api_log_dir=${log_dir}
    ...   trim_logs=${True}
    ...   name=${alias}
#    Run Keyword If   not '${tl.gnbs[0].global_bts_id}'=='None'   coam.register_autoconnection
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


COAM Remote Login
    [Arguments]    ${bts_host}=192.168.255.129   ${username}=Nemuadmin   ${password}=nemuuser
    ...   ${remote_host}=127.0.0.1   ${remote_host_username}=ute   ${remote_host_password}=iW_K#8.ute%A10h0m0ra
    ...   ${connection}=COAM_REMOTE

    coam.setup_admin
    ...   bts_host=${bts_host}
    ...   bts_port=${443}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${500}
    ...   remote_host=${remote_host}
    ...   remote_host_username=${remote_host_username}
    ...   remote_host_password=${remote_host_password}
    ...   trim_logs=${True}
    ...   name=${connection}


COAM Remote Logout
    [Arguments]   ${connection}=COAM_REMOTE
    coam.teardown_admin   connection=${connection}


COAM Login ALL Testline
    [Arguments]   ${testline_list}
    FOR   ${testline}   IN   @{testline_list}
        ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
        ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
        ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
        COAM Login
        ...   bts_host=${webem_addr}
        ...   username=${webem_username}
        ...   password=${webem_password}
        ...   alias=${testline}
    END

COAM Logout ALL Testline
    [Arguments]   ${testline_list}
    FOR   ${testline}   IN   @{testline_list}
        ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
        ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
        ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
        Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    END


# COAM Check Connection Exist

#     ${coam_lib}   Get Library Instance   coam
#     ${connection_list}   Get Variable Value   ${coam_lib.store.all}
#     ${connection_list}   Evaluate   [i[0] for i in $connection_list]
#     Log To Console   ${connection_list}

COAM Backup Full SCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=full_commission.xml   ${connection}=COAM
    coam.get_current_scf_file
    ...   local_dir_path=${local_dir}
    ...   file_name=${file_name}
    ...   export_type=configurationAndRuntimeObjects
    ...   connection=${connection}
    ...   timeout=${300}

COAM SCF Commission
    [Arguments]   ${filepath}=${OUTPUT_DIR}/old_commission.xml   ${connection}=COAM
    coam.perform_commissioning
    ...   scf_file=${filepath}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${900}
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


COAM Get SW Release
    [Arguments]   ${connection}=COAM
    ${sw_release}   coam.get_sw_release_name   timeout=${120}   connection=${connection}
    [Return]   ${sw_release}


COAM Get BTS Info
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${300}
    [Return]   ${bts_info}


COAM Wait Software Update Possible
    [Arguments]   ${testline}   ${bts_ready}=${True}   ${readiness_timeout}=${600}   ${timeout}=${700}
    coam.wait_sw_update_possible
    ...   bts_ready=${bts_ready}
    ...   readiness_timeout=${readiness_timeout}
    ...   timeout=${timeout}
    ...   connection=${testline}


COAM Software Passive synchronize
    [Arguments]   ${testline}
    coam.passive_synchronize   copy_to_passive=${0}   connection=${testline}   timeout=${900}


COAM Dual Core Start Sync
    [Arguments]   ${connection}
    ${neighbor_dn}   coam.get_managed_objects   class_name=NEIGHBOR_NODE_R   timeout=${60}   connection=${connection}
    ${sync_status}   Run Keyword And Return Status   coam.start_sync   dist_name=${neighbor_dn[0]['distName']}   connection=${connection}
    Run Keyword If   not ${sync_status}   Fail   msg=COAM Dual Core Start Sync Failed!
    Log To Console   COAM Dual Core Start Sync Succeeded!

    ${hw_info}   coam.get_detected_hw_info   connection=${connection}   timeout=${60}
    ${smod_number}   Get Length   ${hw_info["systemModules"]}
    Should Be True   ${smod_number} >= 2


COAM Check Hardware Status
    [Arguments]   ${connection}
    ${hw_info}   coam.get_detected_hw_info   connection=${connection}
    # @{bbmod_info_list}   Create List
    # FOR   ${bbmod_info}   IN   @{hw_info['basebandModules']}
    #    Append To List   ${bbmod_info_list}   ${bbmod_info['status']}
    # END
    # @{smod_info_list}   Create List
    FOR   ${smod_info}   IN   @{hw_info['systemModules']}
       # Append To List   ${smod_info_list}   ${smod_info['status']}
       Should Be Equal   ${smod_info['status']['operationalState'].lower()}   enabled
    END
    Sleep   1m


Dual Core SystemModules Detected
    [Arguments]   ${connection}
    ${hw_info}   coam.get_detected_hw_info   connection=${connection}   timeout=${300}
    ${smod_number}   Get Length   ${hw_info["systemModules"]}
    Should Be True   ${smod_number} >= 2


COAM Reset RMOD
    [Arguments]   ${dist_name}   ${connection}    ${timeout}=${1200}
    coam.reset_unit
    ...   dist_name=${dist_name}
    ...   reset_type=Hard
    ...   force_radio_reset=True
    ...   connection=${connection}
    ...   timeout=${timeout}


#===============================================================================================================================================
#===============================================================================================================================================
#===============================================================================================================================================
# UUF Operation
UUF Backup All Testline SCF
    [Arguments]   ${scf_prefix}=BACKUP
    FOR   ${testline}   IN   @{ALL_CONFIG_INIT.keys()}
        Single Testline Backup SCF   scf_prefix=${scf_prefix}   testline=${testline}
    END

Single Testline Backup SCF
    [Arguments]   ${scf_prefix}   ${testline}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    COAM Backup Full SCF   file_name=${scf_prefix}_${testline}.xml   connection=${testline}

    [Teardown]   COAM Logout   connection=${testline}


UUF Get RMOD SerialNumber List
    [Arguments]   ${source}
    # ${source}   XML.Parse XML   ${full_scf_path}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    @{rmod_serial_list}   Create List
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        &{rmod_serial_mapping}   Create Dictionary
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]
        # Set To Dictionary   ${rmod_serial_mapping}   serialNumber   ${serialNumber}
        # Set To Dictionary   ${rmod_serial_mapping}   configDN   ${configDN}
        # Set To Dictionary   ${rmod_serial_mapping}   productName   ${productName}
        # Append To List   ${rmod_serial_list}   ${rmod_serial_mapping}
        Append To List   ${rmod_serial_list}   ${serialNumber}
    END
    # Log To Console   ${rmod_serial_mapping}
    [Return]   ${rmod_serial_list}


UUF Get RMOD DN List
    [Arguments]   ${source}
    # ${source}   XML.Parse XML   ${full_scf_path}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    @{rmod_dn_list}   Create List
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        &{rmod_serial_mapping}   Create Dictionary
        # ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        # ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]
        # Set To Dictionary   ${rmod_serial_mapping}   serialNumber   ${serialNumber}
        # Set To Dictionary   ${rmod_serial_mapping}   configDN   ${configDN}
        # Set To Dictionary   ${rmod_serial_mapping}   productName   ${productName}
        # Append To List   ${rmod_dn_list}   ${rmod_serial_mapping}
        Append To List   ${rmod_dn_list}   ${configDN}
    END
    # Log To Console   ${rmod_serial_mapping}
    [Return]   ${rmod_dn_list}


UUF Get NRCELL ARFCN List
    [Arguments]   ${source}    ${testline_scf_dict}
    # ${source}   XML.Parse XML   ${full_scf_path}
    ${nrcell_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    &{nrcell_arfcn_mapping}   Create Dictionary
    FOR   ${nrcell}   IN   @{nrcell_list}
        ${nrarfcn}   XML.Get Element Text   ${nrcell}   p[@name="arfcnSsbPbch"]
        ${distName}    XML.Get Element Attribute    ${nrcell}    distName
        Set To Dictionary    ${nrcell_arfcn_mapping}     ${distName}=${nrarfcn}
#        Append To List   ${nrcell_arfcn_list}   ${nrcell_arfcn_mapping}
    END
    Set To Dictionary   ${testline_scf_dict}   nrcell_arfcn_mapping=${nrcell_arfcn_mapping}


UUF Get RMOD Detail List
    [Arguments]   ${source}
    # ${source}   XML.Parse XML   ${full_scf_path}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    @{rmod_detail_list}   Create List
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        &{rmod_serial_mapping}   Create Dictionary
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]

        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+

        ${status}   ${radioMasterDN}   Run Keyword And Ignore Error   XML.Get Element Text   ${rmod_r}   p[@name="radioMasterDN"]
        ${radioMasterDN}   Set Variable If   "${status}"=="PASS"   ${radioMasterDN}   ${EMPTY}
        ${isRadioMaster}   Set Variable If   "${radioMasterDN.find("SMOD_EXT")}"=="-1"   ${True}   ${False}

        Set To Dictionary   ${rmod_serial_mapping}   serialNumber   ${serialNumber}
        Set To Dictionary   ${rmod_serial_mapping}   configDN   ${configDN}
        Set To Dictionary   ${rmod_serial_mapping}   productName   ${productName}
        Set To Dictionary   ${rmod_serial_mapping}   radioMasterDN   ${radioMasterDN}
        Set To Dictionary   ${rmod_serial_mapping}   isRadioMaster   ${isRadioMaster}
        Append To List   ${rmod_detail_list}   ${rmod_serial_mapping}
    END
    [Return]   ${rmod_detail_list}


UUF Get RMOD SerialNumber Mapping
    [Arguments]   ${source}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    # @{rmod_detail_list}   Create List
    &{rmod_serial_mapping}   Create Dictionary
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]

        ${serial_mapping}   Evaluate   {"configDN": "${configDN}", "productName": "${productName}"}
        Set To Dictionary   ${rmod_serial_mapping}   ${serialNumber}=${serial_mapping}

    END
    [Return]   ${rmod_serial_mapping}


UUF Get RMOD DN Mapping
    [Arguments]   ${source}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    &{rmod_dn_mapping}   Create Dictionary
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]
        Set To Dictionary   ${rmod_dn_mapping}   ${configDN}=${productName}
    END
    [Return]   ${rmod_dn_mapping}


UUF Get Cablink Mapping
    [Arguments]   ${source}
    ${cablink_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:CABLINK"]
    # @{rmod_detail_list}   Create List
    &{cablink_mapping}   Create Dictionary
    FOR   ${cablink}   IN   @{cablink_list}
        ${secondEndpointDN}   XML.Get Element Text   ${cablink}   p[@name="secondEndpointDN"]
        ${distName}   XML.Get Element Attribute   ${cablink}   name=distName   xpath=.
        Set To Dictionary   ${cablink_mapping}   ${distName}=${secondEndpointDN}
    END
    [Return]   ${cablink_mapping}

UUF Get RMOD SN Cell Mapping From Full SCF
    [Arguments]   ${source}
    Log To Console   ${EMPTY}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    &{rmod_cell_mapping}   Create Dictionary
    ${total_cells_dn}    Create List
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        # Log To Console   serialNumber: ${serialNumber}
        # Log To Console   configDN: ${configDN}
        ${cell_dn_list}   Get Cell DN List   source=${source}   configDN=${configDN}
#        ${cell_param}   Create Dictionary   configDN=${configDN}   cellDN=${cell_dn_dict}
        ${total_cells_dn}    Combine Lists    ${total_cells_dn}    ${cell_dn_list}
        Set To Dictionary   ${rmod_cell_mapping}   ${serialNumber}=${cell_dn_list}
    END
    # Log To Console   ${rmod_serial_mapping}
    [Return]   ${rmod_cell_mapping}    len(${total_cells_dn})

Get Cell DN List
    [Arguments]   ${source}   ${configDN}

    ${narrorband_eles}
    ...   XML.Get Elements   ${source}
    ...      xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]/p[@name="cellTechnology" and text()="NB-IoT-FDD"]
    ${narrorband_celldn_list}    Create List
    FOR   ${narrorband_ele}   IN   @{narrorband_eles}
         ${narrorband_cell_dn}   XML.Get Element Attribute   ${narrorband_ele}   distName   xpath=..
         Append to list    ${narrorband_celldn_list}    ${narrorband_cell_dn}
    END

    ${channel_list_xpath}   Catenate   SEPARATOR=
    ...   cmData/managedObject[@class="com.nokia.srbts.mnl:CHANNEL"]/
    ...   p[(@name="antlDN" or @name="resourceDN") and contains(text(),'${configDN}/')]
    ${channel_list}   XML.Get Elements   ${source}   xpath=${channel_list_xpath}
    # Log To Console   ${rmod_r_list}
    @{nr_cell_dn_list}   Create List
    @{lte_cell_dn_list}   Create List
    FOR   ${channel}   IN   @{channel_list}
        # Log To Console   ${antlDN}
        ${local_cell}   XML.Get Element Attribute   ${channel}   distName   xpath=..
        ${local_cell}   Get Regexp Matches   ${local_cell}   CELLMAPPING-(.*)/(.*)/CHANNELGROUP   2
        # Log To Console   ${local_cell}
        Continue For Loop If   len(${local_cell})==0
        Continue For Loop If   '${local_cell[0].find("LCELNR")}'=='-1' and '${local_cell[0].find("LCELL")}'=='-1'
        ${local_cell}   Set Variable   ${local_cell[0]}
        ${local_cell_index}   Split String   ${local_cell}   -
        ${local_cell_index}   Set Variable   ${local_cell_index[1]}

        ${lcrid_ele}   Run Keyword If   '${local_cell.find("LCELNR")}'!='-1'
        ...   XML.Get Element   ${source}
        ...      xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="lcrId" and text()="${local_cell_index}"]
        ...   ELSE IF   '${local_cell.find("LCELL")}'!='-1'
        ...   XML.Get Element   ${source}
        ...      xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]/p[@name="lcrId" and text()="${local_cell_index}"]


        ${cell_dn}   XML.Get Element Attribute   ${lcrid_ele}   distName   xpath=..
        # Log To Console   ${cell_dn}

        ${status}   run keyword and return status    List Should Contain Value    ${narrorband_celldn_list}      ${cell_dn}
        Continue For Loop If   ${status}

        Run Keyword If   '${local_cell.find("LCELNR")}'!='-1'
        ...   Append To List   ${nr_cell_dn_list}   ${cell_dn}
        ...   ELSE IF   '${local_cell.find("LCELL")}'!='-1'
        ...   Append To List   ${lte_cell_dn_list}   ${cell_dn}
    END
    ${nr_cell_dn_list}   Remove Duplicates   ${nr_cell_dn_list}
    ${lte_cell_dn_list}   Remove Duplicates   ${lte_cell_dn_list}
#    &{cell_dn_dict}   Create Dictionary   NR=${nr_cell_dn_list}   LTE=${lte_cell_dn_list}
    ${cell_dn_list}   Combine Lists  ${nr_cell_dn_list}    ${lte_cell_dn_list}
    # Log To Console   ${nr_cell_index_list}
    # Log To Console   ${lte_cell_index_list}
    # Log To Console   ${cell_dn_dict}

    # Log To Console   --------------------------------
    [Return]   ${cell_dn_list}


UUF Get TDD FDD Variant
    [Arguments]   ${source}
    @{celltech_elems}   XML.Get Elements   ${source}   xpath=cmData/managedObject/p[@name="cellTechnology"]
    @{cellTechnology_list}   Create List
    FOR   ${cellltech_elem}   IN   @{celltech_elems}
        ${cellTechnology}   XML.Get Element Text   ${cellltech_elem}   .
        Append To List   ${cellTechnology_list}   ${cellTechnology}
    END
    ${TDD_FDD_variant}   Set Variable If
    ...   "TDD" in ${cellTechnology_list} and "FDD" not in ${cellTechnology_list}   TDD
    ...   "TDD" not in ${cellTechnology_list} and "FDD" in ${cellTechnology_list}   FDD
    ...   "TDD" in ${cellTechnology_list} and "FDD" in ${cellTechnology_list}       TDD+FDD
    [Return]   ${TDD_FDD_variant}


UUF Get Hardware Config
    [Arguments]   ${source}
    @{smod_elems}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]
    @{bbmod_elems}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:BBMOD_R"]
    @{rmod_elems}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]

    &{smod_number}   Create Dictionary
    FOR   ${smod_elem}   IN   @{smod_elems}
        # ASIK AirScale Common
        ${smod_name}   XML.Get Element Text   ${smod_elem}   p[@name="productName"]
        ${smod_name_list}   Split String   ${smod_name}   ${SPACE}
        ${smod_name}   Get Variable Value   ${smod_name_list[0]}   ${EMPTY}
        Continue For Loop If   "${smod_name}"=="${EMPTY}"
        ${smod_count}   Get Variable Value   ${smod_number["${smod_name}"]}   ${0}
        ${smod_count}   Evaluate   ${smod_count} + 1
        Set To Dictionary   ${smod_number}   ${smod_name}=${smod_count}
    END

    &{bbmod_number}   Create Dictionary
    FOR   ${bbmod_elem}   IN   @{bbmod_elems}
        # ABIL AirScale Capacity
        ${bbmod_name}   XML.Get Element Text   ${bbmod_elem}   p[@name="productName"]
        ${bbmod_name_list}   Split String   ${bbmod_name}   ${SPACE}
        ${bbmod_name}   Get Variable Value   ${bbmod_name_list[0]}   ${EMPTY}
        Continue For Loop If   "${bbmod_name}"=="${EMPTY}"
        ${bbmod_count}   Get Variable Value   ${bbmod_number["${bbmod_name}"]}   ${0}
        ${bbmod_count}   Evaluate   ${bbmod_count} + 1
        Set To Dictionary   ${bbmod_number}   ${bbmod_name}=${bbmod_count}
    END

    &{rmod_number}   Create Dictionary
    FOR   ${rmod_elem}   IN   @{rmod_elems}
        # <p name="productName">AHLOA</p>
        ${rmod_name}   XML.Get Element Text   ${rmod_elem}   p[@name="productName"]
        ${rmod_name}   Get Variable Value   ${rmod_name}   ${EMPTY}
        Continue For Loop If   "${rmod_name}"=="${EMPTY}"
        ${rmod_count}   Get Variable Value   ${rmod_number["${rmod_name}"]}   ${0}
        ${rmod_count}   Evaluate   ${rmod_count} + 1
        Set To Dictionary   ${rmod_number}   ${rmod_name}=${rmod_count}
    END

    ${hw_config}   Set Variable   ${EMPTY}
    @{smod_number_keys}   Get Dictionary Keys   ${smod_number}
    FOR   ${smod_name}   IN   @{smod_number_keys}
        ${smod_count}   Get Variable Value   ${smod_number["${smod_name}"]}   ${EMPTY}
        Continue For Loop If   "${smod_count}"=="" or "${smod_count}"=="0"
        ${hw_config}   Set Variable If   "${hw_config}"=="${EMPTY}"   ${smod_count}${smod_name}   ${hw_config}+${smod_count}${smod_name}
    END
    @{bbmod_number_keys}   Get Dictionary Keys   ${bbmod_number}
    FOR   ${bbmod_name}   IN   @{bbmod_number_keys}
        ${bbmod_count}   Get Variable Value   ${bbmod_number["${bbmod_name}"]}   ${EMPTY}
        Continue For Loop If   "${bbmod_count}"=="" or "${bbmod_count}"=="0"
        ${hw_config}   Set Variable   ${hw_config}+${bbmod_count}${bbmod_name}
    END
    @{rmod_number_keys}   Get Dictionary Keys   ${rmod_number}
    FOR   ${rmod_name}   IN   @{rmod_number_keys}
        ${rmod_count}   Get Variable Value   ${rmod_number["${rmod_name}"]}   ${EMPTY}
        Continue For Loop If   "${rmod_count}"=="" or "${rmod_count}"=="0"
        ${hw_config}   Set Variable   ${hw_config}+${rmod_count}${rmod_name}
    END
    Log To Console   ${hw_config}
    [Return]   ${hw_config}


UUF Get Software Version
    [Arguments]   ${testline}
    ${sw_info}   coam.get_software_info   connection=${testline}   timeout=${60}
    ${active}   Set Variable   ${sw_info['Active SW version']}
    ${passive}   Set Variable   ${sw_info['Passive SW version']}
    ${planned}   Set Variable   ${sw_info['Planned SW version']}

    ${active}   Set Variable If   "${active}"!="${None}" and "${active}"!=""   ${active}   None
    ${passive}   Set Variable If   "${passive}"!="${None}" and "${passive}"!=""   ${passive}   None
    ${planned}   Set Variable If   "${planned}"!="${None}" and "${planned}"!=""   ${planned}   None

    ${active_version}   ${active_release}   Run Keyword If   "${active}"!="${None}" and "${active}"!=""
    ...   Transfer Trunk Software Version   software_version=${active}
    ...   ELSE   Set Variable   ZNone   ZNone
    ${passive_version}   ${passive_release}   Run Keyword If   "${passive}"!="${None}" and "${passive}"!=""
    ...   Transfer Trunk Software Version   software_version=${passive}
    ...   ELSE   Set Variable   ZNone   ZNone
    ${planned_version}   ${planned_release}   Run Keyword If   "${planned}"!="${None}" and "${planned}"!=""
    ...   Transfer Trunk Software Version   software_version=${planned}
    ...   ELSE   Set Variable   ZNone   ZNone

    ${software_dict}   Create Dictionary
    ...   active_version=${active_version}
    ...   passive_version=${passive_version}
    ...   planned_version=${planned_version}
    ...   active_release=${active_release}
    ...   passive_release=${passive_release}
    ...   planned_release=${planned_release}

    [Return]   ${software_dict}


Transfer Trunk Software Version
    [Arguments]   ${software_version}
    ${list}   Split String   ${software_version}   _
    ${prefix}   Set Variable   ${list[0]}
    Return From Keyword If   "${prefix}"=="LN"   ${software_version}   ZNone

    ${release}   Set Variable If
    ...   '${list[2]}'=='0000'   ${list[0]}
    ...   '${list[2]}'=='9999'   SBTS00
    ...   '${list[2]}'=='9990'   SBTS00
    ...   SBTS00

    ${new_software}   Replace String   ${software_version}   ${prefix}   ${release}
    [Return]   ${new_software}   ${prefix}


UUF Software Precheck Need Reset
    [Arguments]   ${testline}   ${package_type}=target
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['path']}

    Log To Console   Software Upgrade Precheck...

    ${status}   ${precheck_result}   Run Keyword And Ignore Error
    ...   coam.software_precheck_local   sw_package=${package_path}   precheck_type=RebootCheck
    ...   timeout=${300}   connection=${testline}
    Return From Keyword If   "${status}"=="FAIL"   ${True}

    @{resetCoverage}   Run Keyword If   "${status}"=="PASS"
    ...   Get Variable Value   ${precheck_result["reportResult"]["resetCoverageReport"][0]["resetCoverage"]}   @{EMPTY}
    # ${swPrecheckNeedReset}   Run Keyword And Return Status   Should Not Be Empty   ${resetCoverage}
    ${swPrecheckNeedReset}   Run Keyword And Return Status   List Should Contain Value   ${resetCoverage}   Site
    Log To Console   Precheck Finished. Software Upgrade Need Reset: ${swPrecheckNeedReset}

    Run Keyword If   not ${swPrecheckNeedReset}   Log To Console   Start To Synchronize Passive Software Version.
    Run Keyword If   not ${swPrecheckNeedReset}   Run Keyword And Ignore Error
    ...   coam.passive_synchronize   copy_to_passive=${0}   connection=${testline}   timeout=${900}

    [Return]   ${swPrecheckNeedReset}


UUF Get PM Counter
    [Arguments]   ${testline}   ${counter_ids}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    ${connection}   Set Variable   PM_${testline}_${time}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${connection}

    ${counters}   coam.get_pm_counters   counter_ids=${counter_ids}   connection=${connection}

    [Return]   ${counters}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${connection}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

UUF Modify PM Report Parameter
    # @{Modify_List}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    @{Modify_List}   Create List   @{ALL_GNB_LIST}
    FOR   ${testline}   IN   @{Modify_List}
        Single Testline Modify PM Report Parameter   testline=${testline}
    END

Single Testline Modify PM Report Parameter
    [Arguments]   ${testline}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${pm_dn}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_dn']}
    ${pm_param}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_param']}
    ${pm_value}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_value']}
    ${pm_value_r}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_value_r']}

    Return From Keyword If   "${pm_value}"=="${pm_value_r}"

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}


    COAM Update Parameter
    ...   dist_name=${pm_dn}
    ...   parameter=${pm_param}
    ...   value=${pm_value}
    ...   connection=${testline}


    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


UUF WorkAround Update SCF Configuration
    # @{Modify_List}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    @{Modify_List}   Create List   @{ALL_GNB_LIST}
    FOR   ${testline}   IN   @{Modify_List}
        UUF WorkAround Single Testline Update SCF Configuration   testline=${testline}
    END


UUF WorkAround Single Testline Update SCF Configuration
    [Arguments]   ${testline}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${delta_list}   Create List
    Log   ${ALL_CONFIG_SCF}
    COAM SCF Delta actIndSwUpgradeForSharedRU   testline=${testline}   delta_list=${delta_list}
    COAM SCF Delta PM Report Parameter   testline=${testline}   delta_list=${delta_list}
    COAM SCF Delta actPowerMeter   testline=${testline}   delta_list=${delta_list}
    COAM SCF Delta Independent DU Upgrade Parameter   testline=${testline}   delta_list=${delta_list}
    Log   ${delta_list}
    Return From Keyword If   len(${delta_list})==0

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${delta_str}   Evaluate   json.dumps(${delta_list})   json
    COAM Perform Delta Recommission   delta_file=${delta_str}   connection=${testline}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


COAM SCF Delta actIndSwUpgradeForSharedRU
    [Arguments]   ${testline}   ${delta_list}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    Return From Keyword If   "${testline_type}"=="enb"
    Return From Keyword If   not ${isMoRAN}

    ${result}   ${enb_sn_list}   Run Keyword And Ignore Error
    ...   Evaluate   [item for testline, sn_list in $ALL_SAME_RU_SERIALNUMBER_MAPPING.items() if "enb" in testline for item in sn_list]
    @{enb_sn_list}   Run Keyword If   "${result}"=="PASS"   Set Variable   ${enb_sn_list}
    ...   ELSE   Create List

    @{serial_number_list}   Get Variable Value   ${ALL_SAME_RU_SERIALNUMBER_MAPPING["${testline}"]}   @{EMPTY}
    @{SharedRU_DN_List}   Create List
    FOR   ${serialNumber}   IN   @{serial_number_list}
        Continue For Loop If   "${serialNumber}" in ${enb_sn_list}
        ${SharedRU_DN}   Get Variable Value   ${ALL_CONFIG_SCF['${testline}']['rmod_serial_mapping']['${serialNumber}']['configDN']}   ${EMPTY}
        Continue For Loop If   "${SharedRU_DN}"=="${EMPTY}"
        Append To List   ${SharedRU_DN_List}   ${SharedRU_DN}
    END
    Log   ${SharedRU_DN_List}

    ${SharedRU_DN_List_r}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['SharedRU_DN_List']}
    ${status}   Run Keyword And Return Status   Lists Should Be Equal   ${SharedRU_DN_List}   ${SharedRU_DN_List_r}   ignore_order=${True}
    Return From Keyword If   ${status}

    FOR   ${SharedRU_DN}   IN   @{SharedRU_DN_List}
        ${delta_str}   Create Single Parameter Delta String   distName=${SharedRU_DN}   parameterName=actIndSwUpgradeForSharedRU   value=true
        ${delta_dict}   Evaluate   json.loads('${delta_str}')   json
        Append To List   ${delta_list}   ${delta_dict}
    END
    Log   ${delta_list}


COAM SCF Delta Independent DU Upgrade Parameter
    [Arguments]   ${testline}   ${delta_list}
    Return From Keyword If   not ${INDEPENDENT_DU_SW_UPGRADE}

    ${param_value}   Set Variable If   ${SEQUENTIAL_RU_SW_UPGRADE}   true   false
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF['${testline}']['MNL_DN']}
    ${param_name}   Set Variable   sequentialRuSwUpgrade

    ${delta_str}   Create Single Parameter Delta String   distName=${dist_name}   parameterName=${param_name}   value=${param_value}
    ${delta_dict}   Evaluate   json.loads('${delta_str}')   json
    Append To List   ${delta_list}   ${delta_dict}
    Log   ${delta_list}


COAM SCF Delta PM Report Parameter
    [Arguments]   ${testline}   ${delta_list}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${pm_dn}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_dn']}
    ${pm_param}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_param']}
    ${pm_value}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_value']}
    ${pm_value_r}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['pm_value_r']}

    Return From Keyword If   "${testline_type}"=="enb"
    Return From Keyword If   "${pm_value}"=="${pm_value_r}"

    ${delta_str}   Create Single Parameter Delta String   distName=${pm_dn}   parameterName=${pm_param}   value=${pm_value}
    ${delta_dict}   Evaluate   json.loads('${delta_str}')   json
    Append To List   ${delta_list}   ${delta_dict}


COAM SCF Delta actPowerMeter
    [Arguments]   ${testline}   ${delta_list}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${actPowerMeter_dn}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['actPowerMeter_dn']}
    ${actPowerMeter}   Set Variable   ${ALL_CONFIG_SCF['${testline}']['actPowerMeter']}

    Return From Keyword If   "${actPowerMeter}"=="true"

    ${delta_str}   Create Single Parameter Delta String   distName=${actPowerMeter_dn}   parameterName=actPowerMeter   value=true
    ${delta_dict}   Evaluate   json.loads('${delta_str}')   json
    Append To List   ${delta_list}   ${delta_dict}


Create Single Parameter Delta String
    [Arguments]   ${distName}   ${parameterName}   ${value}
    ${delta_str}   Catenate   SEPARATOR=
    ...   {
    ...       "distName": "${distName}",
    ...       "operation": "update",
    ...       "parameters": [{
    ...           "parameterName": "${parameterName}",
    ...           "value": "${value}",
    ...           "operation": "update"
    ...       }]
    ...   }
    [Return]   ${delta_str}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
COAM RU Detected And Fault23 Appeared
    [Arguments]   ${testline}
    # ${hw_info}   coam.get_detected_hw_info   connection=${testline}
    ${hw_info}   get_hardware_status   connection=${testline}   hardware_type=radioModules

    ${rmod_status_list}   Create List
    FOR   ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        Append To List   ${rmod_status_list}   ${rmod['status']['proceduralStatus'].lower()}
    END
    List Should Not Contain Value   ${rmod_status_list}   not initialized


    ${ru_not_initializing}   Run Keyword And Return Status   List Should Not Contain Value   ${rmod_status_list}   initializing
    ${ru_configured}   Run Keyword And Return Status   List Should Contain Value   ${rmod_status_list}   configured
    Return From Keyword If   ${ru_not_initializing} and ${ru_configured}   ${False}

    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    ${fault_list}   Evaluate   [alarm['faultId'] for alarm in $active_alarm_list]

    # ${active_alarms}   coam.get_active_alarms   connection=${testline}   timeout=${30}
    # ${fault_list}   Create List
    # FOR   ${active_alarm}    IN   @{active_alarms}
    #     ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
    #     Continue For Loop If   "${faultId}"=="${EMPTY}"
    #     Append To List   ${fault_list}   ${faultId}
    # END
    List Should Contain Value   ${fault_list}   ${23}
    [Return]   ${True}


Single Testline Reset Site And Wait Cell Onair
    [Arguments]   ${testline}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    COAM Reset Site   connection=${testline}
    # Wait Until Keyword Succeeds   20m   1m   UUF Wait Cell Onair   testline=${testline}
    # Wait Until Keyword Succeeds   5m   1m   UUF Wait X2 Link Status   testline=${testline}
    UUF Wait Times For Cell OnAir   testline=${testline}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


# UUF Get Format Alarm List
#     [Arguments]   ${testline}   ${alarm_type}=active

#     @{alarm_list}   Run Keyword If   "${alarm_type}"=="active"   coam.get_active_alarms    connection=${testline}   timeout=${60}
#     ...   ELSE IF   "${alarm_type}"=="history"   coam.get_historic_alarms   load_history=${True}   connection=${testline}   timeout=${300}
#     Log   ${alarm_list}
#     @{format_alarm_list}   Create List
#     FOR   ${alarm_detail}   IN   @{alarm_list}
#         ${faultId}   Get Variable Value   ${alarm_detail['faultId']}   ${EMPTY}
#         Continue For Loop If   "${faultId}"=="${EMPTY}"

#         ${serialNo}             Get Variable Value   ${alarm_detail['serialNo']}                ${EMPTY}
#         ${severity}             Get Variable Value   ${alarm_detail['severity']}                ${EMPTY}
#         ${alarmId}              Get Variable Value   ${alarm_detail['alarmId']}                 ${EMPTY}
#         ${alarmName}            Get Variable Value   ${alarm_detail['alarmName']}               ${EMPTY}
#         # ${faultId}              Get Variable Value   ${alarm_detail['faultId']}                 ${EMPTY}
#         ${faultName}            Get Variable Value   ${alarm_detail['faultName']}               ${EMPTY}
#         ${configObjectName}     Get Variable Value   ${alarm_detail['configObjectName']}        ${EMPTY}
#         ${btsObservationTime}   Get Variable Value   ${alarm_detail['btsObservationTime']}      ${EMPTY}
#         ${clearedTime}          Get Variable Value   ${alarm_detail['clearedTime']}             ${EMPTY}
#         ${supplAlarmInfo}       Get Variable Value   ${alarm_detail['supplAlarmInfo']}          ${EMPTY}

#         ${configObjectName}   Split String   ${configObjectName}   ${SPACE}
#         ${configObjectName}   Get Variable Value   ${configObjectName[-1]}   NA

#         ${productName_1}   Get Variable Value   ${ALL_CONFIG_SCF['${testline}']['rmod_serial_mapping']['${serialNo}']['productName']}   N/A
#         ${productName_2}   Get Variable Value   ${ALL_CONFIG_SCF['${testline}']['rmod_dn_mapping']['${configObjectName}']}   N/A
#         ${productName}   Set Variable If
#         ...   "${productName_1}"!="N/A"   ${productName_1}
#         ...   "${productName_2}"!="N/A"   ${productName_2}
#         ...   N/A

#         # appeardTime
#         ${status}   ${format_appeard_time}   Run Keyword And Ignore Error
#         ...   DateTime.Convert Date   date=${btsObservationTime}   result_format=%Y-%m-%d %H:%M:%S.%f%z   date_format=%Y%m%d%H%M%S.%f%z
#         ${format_appeard_time}   Set Variable If
#         ...   "${status}"=="PASS"   ${format_appeard_time}
#         ...   "${status}"=="FAIL"   ${btsObservationTime}

#         # appeardTimeStamp
#         # ${status}   ${format_appeard_timestamp}   Run Keyword And Ignore Error
#         # ...   DateTime.Convert Date   date=${btsObservationTime}   result_format=epoch   date_format=%Y%m%d%H%M%S.%f%z
#         ${status}   ${format_appeard_timestamp}   Run Keyword And Ignore Error
#         ...   Covert Alarm Date Time   date=${btsObservationTime}   date_format=%Y%m%d%H%M%S.%f%z
#         ${appeardTimeStamp}   Set Variable If
#         ...   "${status}"=="PASS"   ${format_appeard_timestamp}
#         ...   "${status}"=="FAIL"   ${btsObservationTime}

#         # clearedTime
#         ${status}   ${format_clear_time}   Run Keyword And Ignore Error
#         ...   DateTime.Convert Date   date=${clearedTime}   result_format=%Y-%m-%d %H:%M:%S.%f%z   date_format=%Y%m%d%H%M%S.%f%z
#         ${format_clear_time}   Set Variable If
#         ...   "${status}"=="PASS"   ${format_clear_time}
#         ...   "${status}"=="FAIL"   ${clearedTime}

#         # clearedTimeStamp
#         # ${status}   ${format_clear_timestamp}   Run Keyword And Ignore Error
#         # ...   DateTime.Convert Date   date=${clearedTime}   result_format=epoch   date_format=%Y%m%d%H%M%S.%f%z
#         ${status}   ${format_clear_timestamp}   Run Keyword And Ignore Error
#         ...   Covert Alarm Date Time   date=${clearedTime}   date_format=%Y%m%d%H%M%S.%f%z
#         ${clearedTimeStamp}   Set Variable If
#         ...   "${status}"=="PASS"   ${format_clear_timestamp}
#         ...   "${status}"=="FAIL"   ${clearedTime}

#         ${format_alarm_detail}   Create Dictionary
#         ...   severity=${severity}
#         ...   alarmId=${alarmId}
#         ...   alarmName=${alarmName}
#         ...   faultId=${faultId}
#         ...   faultName=${faultName}
#         ...   appeardTime=${format_appeard_time}
#         ...   appeardTimeStamp=${appeardTimeStamp}
#         ...   clearedTime=${format_clear_time}
#         ...   clearedTimeStamp=${clearedTimeStamp}
#         ...   configObjectName=${configObjectName}
#         ...   serialNo=${serialNo}
#         ...   productName=${productName}
#         ...   supplAlarmInfo=${supplAlarmInfo}
#         ...   testline=${testline}
#         Append To List   ${format_alarm_list}   ${format_alarm_detail}
#     END
#     [Return]   ${format_alarm_list}


# Covert Alarm Date Time
#     [Arguments]   ${date}   ${date_format}
#     ${datetime}   DateTime.Convert Date   date=${date}   result_format=datetime   date_format=${date_format}
#     ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil,dateutil.parser
#     [Return]   ${timestamp}


#===============================================================================================================================================
#===============================================================================================================================================
#===============================================================================================================================================
#WebEM Selenium
UUF WebEM Get Release
    [Arguments]   ${testline}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    csn.Connect To   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${info}   csn.Execute   command=ls /ffs/run/TargetBD*xml   connection=${testline}
    ${release}   Set Variable   ${info.split('_')[1]}
    [Return]   ${release}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}


UUF WebEM Login
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF WebEM Login

    ${status}   ${release}   Run Keyword And Ignore Error   UUF WebEM Get Release   testline=${testline}
    ${version}   Set Variable If
    ...   "${status}"=="PASS"   ${release}
    ...   ${None}

    selenium_sbts.enable_virtual_display

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    selenium_sbts.login
    ...   url=https://${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   version=${version}
    ...   alias=${testline}

    Run Keyword And Ignore Error   selenium_sbts.disable_message_box   sbts=${testline}
    Run Keyword And Ignore Error   selenium_sbts.disable_screen_lock   sbts=${testline}

    ${exists}   selenium_sbts.start_up_view_window_exists   sbts=${testline}
    Run Keyword If   ${exists}   selenium_sbts.close_start_up_view_window   sbts=${testline}

    # Run Keyword And Ignore Error   selenium_sbts.continue_after_plug_and_play_modal_appear   timeout=${10}   sbts=${testline}
    Log To Console   UUF WebEM Login Finished.


UUF WebEM Logout
    [Arguments]   ${testline}
    ${logout_status}   Run Keyword And Return Status   selenium_sbts.logout   sbts=${testline}
    Run Keyword If   not ${logout_status}   Run Keyword And Ignore Error   selenium_sbts.close_browser   sbts=${testline}
    Run Keyword And Ignore Error   selenium_sbts.disable_virtual_display


UUF WebEM Upgrade
    [Arguments]   ${testline}   ${package_path}
    Log To Console   //TODO: UUF WebEM Upgrade
    ${result}   selenium_sbts.load_software_package_from_local_drive   file_path=${package_path}   sbts=${testline}
    Should Be Equal   ${result}   software package load success
    Sleep   3s

    selenium_sbts.software_update   is_activate=${True}   sbts=${testline}

    ${RETRY_FLAG}   Wait Until Keyword Succeeds   60m   1m   UUF WebEM Wait Software Process Done   testline=${testline}
    Run Keyword If   "${RETRY_FLAG}"=="RETRY_FLAG"   Fail   msg=UUF WebEM Upgrade Failed. Retry...

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Run Keyword And Ignore Error   Run Keyword If   ${swPrecheckNeedReset}
    ...   Wait Until Keyword Succeeds   10m   1m   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    # ...   Wait Until Keyword Succeeds   10m   1m   UUF WebEM Wait Software Reset Done   testline=${testline}


UUF ADMIN Upgrade
    [Arguments]   ${testline}   ${package_path}   ${independent_sw_update_type}=${None}
    Log To Console   //TODO: UUF ADMIN Upgrade
    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${3600}   connection=${testline}
    ...   independent_sw_update_type=${independent_sw_update_type}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Run Keyword And Ignore Error   Run Keyword If   ${swPrecheckNeedReset}
    ...   Wait Until Keyword Succeeds   5m   1m   Check Connection Status   ip_address=${ssh_addr}   status=disconnect


UUF WebEM Rollback
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF WebEM Rollback

    selenium_sbts.software_rollback   sbts=${testline}

    ${RETRY_FLAG}   Wait Until Keyword Succeeds   60m   1m   UUF WebEM Wait Software Process Done   testline=${testline}
    Run Keyword If   "${RETRY_FLAG}"=="RETRY_FLAG"   Fail   msg=UUF WebEM Rollback Failed. Retry...

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    # Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   UUF WebEM Wait Software Reset Done   testline=${testline}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   Check Connection Status   ip_address=${ssh_addr}   status=disconnect


UUF ADMIN Rollback
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF ADMIN Rollback
    coam.rollback_software   connection=${testline}   timeout=${600}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   5m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect


UUF WebEM Reset
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF WebEM Reset
    selenium_sbts.reset_site   sbts=${testline}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   5m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect


UUF ADMIN Reset
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF ADMIN Reset
    coam.reset_site   connection=${testline}   wait_for_reconnection=${False}   timeout=${900}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Wait Until Keyword Succeeds   5m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect


UUF WebEM Wait Software Process Done
    [Arguments]   ${testline}
    ${fail_list}   Create List   fail   reject
    ${pass_list}   Create List   reset   Activating software...   Activation completed   Passive software version checking...
    ${retry_list}   Create List   BTS is busy

    ${result}    selenium_sbts.check_software_update_progress   sbts=${testline}
    ${result_status}   Get Variable Value   ${result["status"]}

    ${retry_status}   Run Keyword And Return Status   Should Contain Any    ${result_status}    @{retry_list}
    Return From Keyword If   ${retry_status}   RETRY_FLAG

    ${fail_status}   Run Keyword And Return Status   Should Contain Any    ${result_status}    @{fail_list}
    Run Keyword If   ${fail_status}   Fatal Error   msg=UUF Upgrade Failed(Testline: ${testline}): ${result_status}

    ${empty_status}   Run Keyword And Return Status   Should Be Empty   ${result_status}
    Return From Keyword If   ${empty_status}

    Should Contain Any    ${result_status}    @{pass_list}

    Log To Console   WebEM Software Process Ongoing...


UUF WebEM Wait Software Reset Done
    [Arguments]   ${testline}
    ${fail_list}   Create List   fail   reject

    ${result}    selenium_sbts.check_software_update_progress   sbts=${testline}

    ${fail_status}    Run Keyword And Return Status   Should Contain Any    ${result["status"]}    @{fail_list}
    Run Keyword If   ${fail_status}   Fatal Error   msg=UUF Upgrade Failed: ${testline}

    Should Be Empty   ${result["status"]}

    Log To Console   WebEM Software Reset Done...

UUF Get Bts Info
    [Arguments]   ${testline}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${bts_info}    COAM Get BTS Info    connection=${testline}

    [Return]    ${bts_info}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}

UUF Get nrCellIdentity
    [Arguments]   ${source}    ${dist_name}
    ${nrCellIdentity}   XML.Get Element Text   ${source}
    ...   xpath=cmData/managedObject[@distName="${dist_name}"]/p[@name="nrCellIdentity"]
    [Return]    ${nrCellIdentity}

UUF Get Cells List for L3CALL Per UE
    [Arguments]    ${source}   ${btsinfo}    ${testline}    ${ue_index}
    ${value}    get variable value    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"]["${ue_index}"]}
    Return From Keyword If    ${value}==${None}
    #get nr_L3CALL_cell_list
    ${nr_L3CALL_cell_list}    create list
    ${nr_L3CALL_cell_list_tmp}    create list
    FOR    ${nrcell}    IN    @{btsinfo['cells']['nr']}
          ${cell_id}    get variable value    ${nrcell['id']['configuration']}
          ${nrCellIdentity}    UUF Get nrCellIdentity    source=${source}   dist_name=${cell_id}
#          LOG    ${btsinfo['cells']['nr']}
#          log    ${nr_L3CALL_cell_list_tmp}
          Exit For Loop If     len(${btsinfo['cells']['nr']})<=0
          ${nr_L3CALL_cell_dic}   Create Dictionary
          Set To Dictionary   ${nr_L3CALL_cell_dic}    nrCellIdentity=${nrCellIdentity}
          Set To Dictionary   ${nr_L3CALL_cell_dic}    pci=${nrcell['physicalCellId']}
          Set To Dictionary   ${nr_L3CALL_cell_dic}    band=${nrcell['band']}
          Set To Dictionary   ${nr_L3CALL_cell_dic}    celldn=${nrcell['id']['configuration']}
          Set To Dictionary   ${nr_L3CALL_cell_dic}    narrowbandIotMode=disabled
          Append to list    ${nr_L3CALL_cell_list_tmp}    ${nr_L3CALL_cell_dic}
#          log    ${nr_L3CALL_cell_list_tmp}
    END
    FOR    ${nrcell}    IN    @{nr_L3CALL_cell_list_tmp}
          Exit For Loop If     len(${nr_L3CALL_cell_list_tmp})<=0
          Set To Dictionary   ${nrcell}    arfcn=${L3CALL_CONFIG_SCF['${testline}']['nrcell_arfcn_mapping']['${nrcell['celldn']}']}
          Append to list    ${nr_L3CALL_cell_list}    ${nrcell}
    END
#    #SET nrcell celltechnology FDD/TDD
#    FOR    ${nrcell}    IN    @{nr_L3CALL_cell_list_tmp}
#          Exit For Loop If     len(${nr_L3CALL_cell_list_tmp})<=0
#          Set To Dictionary   ${nrcell}    cellTechnology=${L3CALL_CONFIG_SCF['${testline}']['nrcell_tech_mapping']['${nrcell['celldn']}']}
#          Append to list    ${nr_L3CALL_cell_list}    ${nrcell}
#    END

    #get lte_L3CALL_cell_dic
    ${lte_L3CALL_cell_list}    create list
    FOR    ${ltecell}    IN    @{btsinfo['cells']['lte']}
          Exit For Loop If     len(${btsinfo['cells']['lte']})<=0
          ${value_fdd}    get variable value    ${ltecell['earfcnDownlink']}
          ${value_tdd}    get variable value    ${ltecell['earfcn']}
#          ${narrowbandIotMode}    get variable value    ${ltecell['narrowbandIotMode']}
          continue for loop if   ${value_fdd}==${None} and ${value_tdd}==${None}
          ${arfcn_value}    set variable if   ${value_fdd}==${None}   ${value_tdd}    ${value_fdd}
          ${lte_L3CALL_cell_dic}   Create Dictionary
          Set To Dictionary   ${lte_L3CALL_cell_dic}    pci=${ltecell['physicalCellId']}
          Set To Dictionary   ${lte_L3CALL_cell_dic}    band=B${ltecell['bandNumber']}
          Set To Dictionary   ${lte_L3CALL_cell_dic}    celldn=${ltecell['id']['configuration']}
          Set To Dictionary   ${lte_L3CALL_cell_dic}    arfcn=${arfcn_value}
          Set To Dictionary   ${lte_L3CALL_cell_dic}    narrowbandIotMode=${ltecell['narrowbandIotMode']}
          Append to list    ${lte_L3CALL_cell_list}    ${lte_L3CALL_cell_dic}
    END


    #Combine LTE and NR cell list
    ${L3CALL_cell_list}   Combine Lists    ${nr_L3CALL_cell_list}    ${lte_L3CALL_cell_list}

    #Exclue L3 CALL cell by rmod SN
    ${exclude_L3CALL_cell_list}    Get Exclude L3CALL Celldn List By RMOD SN   testline=${testline}    ue_index=${ue_index}
    FOR   ${cell}   IN   @{L3CALL_cell_list}
        run keyword if   '${cell['celldn']}' in ${exclude_L3CALL_cell_list}
        ...   Remove Values From List    ${L3CALL_cell_list}    ${cell}
    END
    Log    ${L3CALL_cell_list}

    #Exclue L3 CALL cell by BAND
    ${L3CALL_BAND_ALL}   Create List
    FOR   ${ue_index}    IN   @{UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"].keys()}
        ${L3CALL_BAND_ALL}    Combine Lists
        ...   ${L3CALL_BAND_ALL}    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"]["${ue_index}"]["L3CALL_band"]}
    END
    FOR   ${cell}   IN   @{L3CALL_cell_list}
        run keyword if   '${cell['band'].upper()}' not in ${L3CALL_BAND_ALL}
        ...   Remove Values From List    ${L3CALL_cell_list}    ${cell}
    END
#    LOG   ${L3CALL_cell_list}
    [Return]    ${L3CALL_cell_list}


Get Exclude L3CALL Celldn List By RMOD SN
    [Arguments]    ${testline}    ${ue_index}
    #get exclude_L3CALL_celldn_list according to rmod in UUF_L3CALL
    ${connected_RU_ALL}    Create List
#    FOR   ${ue_index}    IN   @{UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"].keys()}
#        ${connected_RU_ALL}    Combine Lists
#        ...   ${connected_RU_ALL}    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"]["${ue_index}"]["connected_RU"]}
#    END
#    ${connected_RU_ALL}   Remove Duplicates    ${connected_RU_ALL}
    ${connected_RU_ALL}    set variable    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"]["${ue_index}"]["connected_RU"]}
    ${exclude_L3CALL_cell_list}    create list
    FOR   ${rmod}   IN    @{L3CALL_CONFIG_SCF['${testline}']['rmod_cell_mapping'].keys()}
         ${exclude_L3CALL_cell_list}    run keyword if  '${rmod}' not in ${connected_RU_ALL}
         ...    Combine Lists    ${exclude_L3CALL_cell_list}     ${L3CALL_CONFIG_SCF['${testline}']['rmod_cell_mapping']['${rmod}']}
         ...   ELSE   set variable    ${exclude_L3CALL_cell_list}
    END
    [Return]   ${exclude_L3CALL_cell_list}




