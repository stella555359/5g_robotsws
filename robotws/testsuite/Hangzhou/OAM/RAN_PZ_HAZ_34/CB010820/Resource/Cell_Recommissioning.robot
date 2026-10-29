*** Settings ***
Documentation   This test suite handles cell recommissioning operations, including parameter updates, delta creation, and cell activation.
Resource   Common.robot

*** Keywords ***
Cell Recommissioning Common Keyword
    [Arguments]   ${parameter_config_list}   ${scf_local_dir}=${OUTPUT_DIR}   ${scf_file_name}=${None}
    ...   ${delta_id}=Cell_Recommissioning   ${connection}=Cell_Recommissioning

    Log To Console   Cell Recommissioning Common Keyword

    Return From Keyword If   len(${parameter_config_list})==0

    COAM Login   alias=${connection}
    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    ${scf_file_name}   Set Variable If   "${scf_file_name}"!="${None}"   ${scf_file_name}   Before_Cell_Recommissioning_${time}.xml
    coam.get_current_scf_file   local_dir_path=${scf_local_dir}   file_name=${scf_file_name}
    ...   connection=${connection}   timeout=${60}
    coam.create_delta   delta_id=${delta_id}

    FOR   ${parameter_config}   IN   @{parameter_config_list}
        Cell Recommissioning Single Cell   parameter_config=${parameter_config}   delta_id=${delta_id}   scf_path=${scf_local_dir}/${scf_file_name}
    END

    ${delta_file}   coam.get_delta   delta_id=${delta_id}
    Log To Console   ${delta_file}
    Log To Console   COAM Perform Delta Recommissioning...
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${900}
    ...   connection=${connection}

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    coam.get_current_scf_file   local_dir_path=${scf_local_dir}   file_name=After_Cell_Recommissioning_${time}.xml
    ...   connection=${connection}   timeout=${60}
    Log To Console   COAM Perform Delta Recommissioning Finished!
    Log To Console   Wait For Cell Onair...
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair   connection=${connection}
    Log To Console   Wait For Cell Onair Finished!

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${connection}


Cell Recommissioning Single Cell
    [Arguments]   ${parameter_config}   ${delta_id}   ${scf_path}

    ${cell_id}   Set Variable   ${parameter_config["nrCellId"]}
    COAM Get All Recommissioning Infomation From SCF   cell_id=${cell_id}   scf_path=${scf_path}

    ${chBw}   Get Variable Value   ${parameter_config["chBw"]}
    ${constant_parameter}   Get Variable Value   ${COMMON_CELL_CHBW_PARAMETER["${chBw}"]}   @{EMPTY}
    FOR   ${parameter}   IN   @{constant_parameter}
        ${value}   Set Variable   ${constant_parameter["${parameter}"]}
        coam.append_parameter_update_to_delta
        ...   dist_name=${NRBTS_DN}/NRCELL-${cell_id}
        ...   parameter=${parameter}
        ...   value=${value}
        ...   delta_id=${delta_id}
    END


    FOR   ${parameter}   IN   @{parameter_config}
        ${value}   Set Variable   ${parameter_config["${parameter}"]}
        Run Keyword If   "${parameter}"=="channel_grp_list"
        ...         COAM Update Delta Channel Group   delta_id=${delta_id}   cell_id=${cell_id}   channel_grp_list=${value}
        ...   ELSE IF   "${parameter}"=="cellBwpList"
        ...         COAM Update Delta Cell Bwp List   delta_id=${delta_id}   cell_id=${cell_id}   cellBwpList=${value}
        ...   ELSE IF   "${parameter}"=="csirsForTracking"
        ...         COAM Update Delta csirsForTracking   delta_id=${delta_id}   cell_id=${cell_id}   csirsForTracking=${value}
        ...   ELSE IF   "${parameter}"=="nrCellId"
        ...         Log To Console   Skip nrCellID
        ...   ELSE
        ...         coam.append_parameter_update_to_delta
        ...             dist_name=${NRBTS_DN}/NRCELL-${cell_id}
        ...             parameter=${parameter}
        ...             value=${value}
        ...             delta_id=${delta_id}
    END


#==============================================================================================================================================
#==============================================================================================================================================
#==============================================================================================================================================
COAM Get All Recommissioning Infomation From SCF
    [Arguments]   ${cell_id}   ${scf_path}=${OUTPUT_DIR}/old_commission.xml

    ${scf_xml}   XML.Parse XML   ${scf_path}

    ${MRBTS_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    ${NRBTS_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Set Suite Variable   ${MRBTS_DN}
    Set Suite Variable   ${NRBTS_DN}

    &{ALL_RECOM_VAR}   Create Dictionary
    @{all_cell_list}    Create List
    ${NRCELL_elem_list}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    FOR   ${NRCELL_elem}   IN   @{NRCELL_elem_list}
        ${NRCELL_DN}   XML.Get Element Attribute   ${NRCELL_elem}   name=distName   xpath=.
        ${cell_index}    Fetch From Right    ${NRCELL_DN}    -
        Append to list    ${all_cell_list}    ${cell_index}
    END
    Log To Console   all_cell_list: ${all_cell_list}
    Set To Dictionary   ${ALL_RECOM_VAR}   all_cell_list=${all_cell_list}

    ${channel_elem_list_xpath}   Catenate   SEPARATOR=
    ...   cmData/managedObject
    ...   [contains(@distName, "${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/") and @class="com.nokia.srbts.mnl:CHANNEL"]
    @{channel_elem_list}   XML.Get Elements   ${scf_xml}   xpath=${channel_elem_list_xpath}
    @{resourceDN_list}   Create List
    FOR   ${channel_elem}   IN   @{channel_elem_list}
        ${resourceDN}   XML.Get Element Text   ${channel_elem}   xpath=p[@name="resourceDN"]
        Append To List   ${resourceDN_list}   ${resourceDN}
    END
    ${resourceDN_list}   Remove Duplicates   ${resourceDN_list}
    Log To Console   resourceDN_list: ${resourceDN_list}
    Set To Dictionary   ${ALL_RECOM_VAR}   resourceDN_list=${resourceDN_list}


    ${channel_grp_elem_list_xpath}      Catenate   SEPARATOR=
    ...   cmData/managedObject[contains(@distName, "${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP")
    ...   ${SPACE}and @class="com.nokia.srbts.mnl:CHANNELGROUP"]
    ${channel_grp_num}   XML.Get Element Count   ${scf_xml}   xpath=${channel_grp_elem_list_xpath}
    @{channel_grp_elem_list}   XML.Get Elements   ${scf_xml}   xpath=${channel_grp_elem_list_xpath}
    @{channel_grp_id_list}   Create List
    FOR   ${channel_grp_elem}   IN   @{channel_grp_elem_list}
        ${channel_grp_distName}   XML.Get Element Attribute   ${channel_grp_elem}   name=distName   xpath=.
        ${channel_grp_id}   Fetch From Right   ${channel_grp_distName}   -
        Append To List   ${channel_grp_id_list}   ${channel_grp_id}
    END
    Log To Console   channel_grp_id_list: ${channel_grp_id_list}
    Set To Dictionary   ${ALL_RECOM_VAR}   channel_grp_num=${channel_grp_num}
    Set To Dictionary   ${ALL_RECOM_VAR}   channel_grp_id_list=${channel_grp_id_list}

    &{channelgroup_channellist_mapping}   Create Dictionary
    FOR   ${channel_grp_id}   IN   @{channel_grp_id_list}
        ${channel_id_list}   COAM Get ChannelGroup ChannelList Mapping   ${scf_xml}   ${cell_id}   ${channel_grp_id}
        Set To Dictionary   ${channelgroup_channellist_mapping}   ${channel_grp_id}=${channel_id_list}
    END
    Log To Console   channelgroup_channellist_mapping: ${channelgroup_channellist_mapping}
    Set To Dictionary   ${ALL_RECOM_VAR}   channelgroup_channellist_mapping=${channelgroup_channellist_mapping}

    &{lcelnr_rmodphy_mapping}   Create Dictionary
    @{lcelnr_elem_list}   Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:LCELNR"]
    FOR   ${lcelnr_elem}   IN   @{lcelnr_elem_list}
        ${lcelnr_dn}   XML.Get Element Attribute   ${lcelnr_elem}   name=distName   xpath=.
        ${rmod_phy_dn}   Get RMOD From LCELNR   scf_xml=${scf_xml}   lcelnr_dn=${lcelnr_dn}
        Set To Dictionary   ${lcelnr_rmodphy_mapping}   ${lcelnr_dn}=${rmod_phy_dn}
    END
    Log To Console   lcelnr_rmodphy_mapping: ${lcelnr_rmodphy_mapping}
    Set To Dictionary   ${ALL_RECOM_VAR}   lcelnr_rmodphy_mapping=${lcelnr_rmodphy_mapping}

    @{cellBwpList}   Create List
    ${bwpDN_item_elem_list}   XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@distName="${NRBTS_DN}/NRCELL-${cell_id}"]/list[@name="cellBwpList"]/item
    FOR   ${bwpDN_item_elem}   IN   @{bwpDN_item_elem_list}
        ${bwpDN_param}   COAM Get cellBwpList Parameter   bwpDN_item_elem=${bwpDN_item_elem}
        Append To List   ${cellBwpList}   ${bwpDN_param}
    END
    Log To Console   cellBwpList: ${cellBwpList}
    Set To Dictionary   ${ALL_RECOM_VAR}   cellBwpList=${cellBwpList}


    @{csirsForTracking}   Create List
    ${rbAllocation_item_elem_list}   XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@distName="${NRBTS_DN}/NRCELL-${cell_id}"]/list[@name="csirsForTracking"]/item
    FOR   ${rbAllocation_item_elem}   IN   @{rbAllocation_item_elem_list}
        ${rbAllocation_param}   COAM Get csirsForTracking Parameter   rbAllocation_item_elem=${rbAllocation_item_elem}
        Append To List   ${csirsForTracking}   ${rbAllocation_param}
    END
    Log To Console   csirsForTracking: ${csirsForTracking}
    Set To Dictionary   ${ALL_RECOM_VAR}   csirsForTracking=${csirsForTracking}

    Set Suite Variable   ${ALL_RECOM_VAR}


COAM Get ChannelGroup ChannelList Mapping
    [Arguments]   ${scf_xml}   ${cell_id}   ${channel_grp_id}

    ${channel_elem_list_xpath}      Catenate   SEPARATOR=
    ...   cmData/managedObject
    ...   [contains(@distName, "${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channel_grp_id}/CHANNEL")
    ...   ${SPACE}and @class="com.nokia.srbts.mnl:CHANNEL"]
    @{channel_elem_list}   XML.Get Elements   ${scf_xml}   xpath=${channel_elem_list_xpath}
    @{channel_id_list}   Create List
    FOR   ${exist_channel_elem}   IN   @{channel_elem_list}
        ${channel_distName}   XML.Get Element Attribute   ${exist_channel_elem}   name=distName   xpath=.
        ${channel_id}   Fetch From Right   ${channel_distName}   -
        Append To List   ${channel_id_list}   ${channel_id}
    END
    [Return]   ${channel_id_list}


Get RMOD From LCELNR
    [Arguments]   ${scf_xml}   ${lcelnr_dn}

    @{channel_elem_list}   XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[contains(@distName, "${lcelnr_dn}/") and @class="com.nokia.srbts.mnl:CHANNEL"]
    @{rmod_phy_dn_list}   Create List
    FOR   ${channel_elem}   IN   @{channel_elem_list}
        ${resourceDN_exist}   ${resourceDN}   Run Keyword And Ignore Error   XML.Get Element Text   ${channel_elem}   xpath=p[@name="resourceDN"]
        ${antlDN_exist}   ${antlDN}   Run Keyword And Ignore Error   XML.Get Element Text   ${channel_elem}   xpath=p[@name="antlDN"]

        ${check_dn}   Set Variable If
        ...   "${resourceDN_exist}"=="PASS"   ${resourceDN}
        ...   "${antlDN_exist}"=="PASS"   ${antlDN}

        Append To List   ${rmod_phy_dn_list}   ${check_dn}
    END
    ${rmod_phy_dn_list}   Remove Duplicates   ${rmod_phy_dn_list}
    [Return]   ${rmod_phy_dn_list[0]}


COAM Get cellBwpList Parameter
    [Arguments]   ${bwpDN_item_elem}
    &{bwpDN_param}   Create Dictionary
    ${bwpDN_param_elem_list}   XML.Get Elements   ${bwpDN_item_elem}   xpath=p
    FOR   ${param_elem}   IN   @{bwpDN_param_elem_list}
        ${key}   XML.Get Element Attribute   ${param_elem}   name=name   xpath=.
        ${value}   XML.Get Element Text   ${param_elem}   xpath=.
        Set To Dictionary   ${bwpDN_param}   ${key}=${value}
    END
    [Return]   ${bwpDN_param}


COAM Get csirsForTracking Parameter
    [Arguments]   ${rbAllocation_item_elem}
    &{rbAllocation_param}   Create Dictionary
    ${rbAllocation_param_elem_list}   XML.Get Elements   ${rbAllocation_item_elem}   xpath=p
    FOR   ${param_elem}   IN   @{rbAllocation_param_elem_list}
        ${key}   XML.Get Element Attribute   ${param_elem}   name=name   xpath=.
        ${value}   XML.Get Element Text   ${param_elem}   xpath=.
        Set To Dictionary   ${rbAllocation_param}   ${key}=${value}
    END
    [Return]   ${rbAllocation_param}



#==============================================================================================================================================
#==============================================================================================================================================
#==============================================================================================================================================
# Update BWP DN
COAM Update Delta Cell Bwp List
    [Arguments]   ${delta_id}   ${cell_id}   ${cellBwpList}
    ${new_cellBwpList}   Copy List   ${ALL_RECOM_VAR["cellBwpList"]}   deepcopy=${True}

    FOR   ${index}   IN RANGE   len(${cellBwpList})
        ${item}   Set Variable   ${cellBwpList[${index}]}
        COAM Update Delta Cell Bwp List Parameter   index=${index}   item=${item}   new_cellBwpList=${new_cellBwpList}
    END
    Log To Console   new_cellBwpList:
    Log To Console   ${new_cellBwpList}
    coam.append_list_items_to_delta   ${NRBTS_DN}/NRCELL-${cell_id}   cellBwpList   @{new_cellBwpList}   delta_id=${delta_id}


COAM Update Delta Cell Bwp List Parameter
    [Arguments]   ${index}   ${item}   ${new_cellBwpList}
    FOR   ${key}   IN   @{item}
        ${value}   Set Variable If
        ...   "${key}"=="bwpDN"   ${NRBTS_DN}/BWP_PROFILE-${item["${key}"]}
        ...   ${item["${key}"]}
        Set To Dictionary   ${new_cellBwpList[${index}]}   ${key}   ${value}
    END


# Update csirsForTracking
COAM Update Delta csirsForTracking
    [Arguments]   ${delta_id}   ${cell_id}   ${csirsForTracking}
    ${new_csirsForTracking}   Copy List   ${ALL_RECOM_VAR["csirsForTracking"]}   deepcopy=${True}

    FOR   ${index}   IN RANGE   len(${csirsForTracking})
        ${item}   Set Variable   ${csirsForTracking[${index}]}
        COAM Update Delta csirsForTracking Parameter   index=${index}   item=${item}   new_csirsForTracking=${new_csirsForTracking}
    END
    Log To Console   new_csirsForTracking:
    Log To Console   ${new_csirsForTracking}
    coam.append_list_items_to_delta   ${NRBTS_DN}/NRCELL-${cell_id}
    ...   csirsForTracking   @{new_csirsForTracking}   delta_id=${delta_id}


COAM Update Delta csirsForTracking Parameter
    [Arguments]   ${index}   ${item}   ${new_csirsForTracking}
    FOR   ${key}   IN   @{item}
        ${value}   Set Variable If
        ...   "${key}"=="rbAllocation"   ${item["${key}"]}    ${item["${key}"]}
        Set To Dictionary   ${new_csirsForTracking[${index}]}   ${key}   ${value}
    END


# Update Channel Group
COAM Update Delta Channel Group
    [Arguments]   ${delta_id}   ${cell_id}   ${channel_grp_list}

    ${new_channel_grp_num}   Get Length   ${channel_grp_list}
    ${new_channel_grp_id_list}   Evaluate   [str(i+1) for i in range(int(${new_channel_grp_num}))]
    Log To Console   new_channel_grp_id_list: ${new_channel_grp_id_list}

    ${channel_grp_num}   Set Variable   ${ALL_RECOM_VAR["channel_grp_num"]}
    ${channel_grp_id_list}   Set Variable   ${ALL_RECOM_VAR["channel_grp_id_list"]}

    @{NeedCreateChannelGroupList}   Evaluate   [i for i in ${new_channel_grp_id_list} if i not in ${channel_grp_id_list}]
    @{NeedDeleteChannelGroupList}   Evaluate   [i for i in ${channel_grp_id_list} if i not in ${new_channel_grp_id_list}]
    FOR   ${channel_grp_id}   IN   @{NeedCreateChannelGroupList}
        coam.append_managed_object_to_delta
        ...   dist_name=${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channel_grp_id}
        ...   operation=create
        ...   delta_id=${delta_id}
    END
    FOR   ${channel_grp_id}   IN   @{NeedDeleteChannelGroupList}
        coam.append_managed_object_to_delta
        ...   dist_name=${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channel_grp_id}
        ...   operation=delete
        ...   delta_id=${delta_id}
    END

    FOR   ${channel_grp_id}   IN   @{new_channel_grp_id_list}
        ${index}   Evaluate   ${channel_grp_id} - 1
        ${channel}   Set Variable   ${channel_grp_list[${index}]}
        COAM Update Delta Channel List   ${delta_id}   ${cell_id}   ${channel_grp_id}   ${channel}
    END



COAM Update Delta Channel List
    [Arguments]   ${delta_id}   ${cell_id}   ${channel_grp_id}   ${channel}

    ${isTX}   ${TX_channel}   Run Keyword And Ignore Error   Should Match Regexp   ${channel}   (\\d+)TX
    ${isRX}   ${RX_channel}   Run Keyword And Ignore Error   Should Match Regexp   ${channel}   (\\d+)RX
    ${TX_num}   Set Variable If   "${isTX}"=="PASS"   ${TX_channel[1]}   ${0}
    ${RX_num}   Set Variable If   "${isRX}"=="PASS"   ${RX_channel[1]}   ${0}
    ${config_channel_num}   Evaluate   int(${TX_num}) + int(${RX_num})
    ${config_channel_id_list}   Evaluate   [str(i+1) for i in range(int(${config_channel_num}))]

    ${lcelnr_dn}   Set Variable   ${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    ${lcelnr_rmodphy_mapping}   Get Variable Value   ${ALL_RECOM_VAR["lcelnr_rmodphy_mapping"]}
    ${channel_id_list}   Get Variable Value   ${ALL_RECOM_VAR["channelgroup_channellist_mapping"]["${channel_grp_id}"]}   @{EMPTY}
    ${resourceDN_list}   Set Variable   ${ALL_RECOM_VAR["resourceDN_list"]}
    ${resourceDN}   Set Variable   ${resourceDN_list[0]}

    @{NeedCreateChannelList}   Evaluate   [i for i in ${config_channel_id_list} if i not in ${channel_id_list}]
    @{NeedDeleteChannelList}   Evaluate   [i for i in ${channel_id_list} if i not in ${config_channel_id_list}]

    FOR   ${channel_id}   IN   @{NeedCreateChannelList}
        coam.append_managed_object_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   operation=create
        ...   delta_id=${delta_id}
    END

    FOR   ${channel_id}   IN   @{NeedDeleteChannelList}
        coam.append_managed_object_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   operation=delete
        ...   delta_id=${delta_id}
    END


    FOR   ${index}   IN RANGE   ${TX_num}
        ${channel_id}   Evaluate   ${index} + 1
        ${channel_exit}   Set Variable If   "${channel_id}" in ${channel_id_list}   ${True}   ${False}
        ${rmod_phy_dn}   Set Variable   ${lcelnr_rmodphy_mapping["${lcelnr_dn}"]}

        Run Keyword If   not ${channel_exit}   coam.append_managed_object_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   operation=create
        ...   delta_id=${delta_id}
        coam.append_parameter_update_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   parameter=direction
        ...   value=TX
        ...   delta_id=${delta_id}
        coam.append_parameter_update_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   parameter=resourceDN
        ...   value=${rmod_phy_dn}
        ...   delta_id=${delta_id}
    END

    FOR   ${index}   IN RANGE   ${RX_num}
        ${channel_id}   Evaluate   ${TX_num} + ${index} + 1
        ${channel_exit}   Set Variable If   "${channel_id}" in ${channel_id_list}   ${True}   ${False}
        Run Keyword If   not ${channel_exit}   coam.append_managed_object_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   operation=create
        ...   delta_id=${delta_id}
        coam.append_parameter_update_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   parameter=direction
        ...   value=RX
        ...   delta_id=${delta_id}
        coam.append_parameter_update_to_delta
        ...   dist_name=${lcelnr_dn}/CHANNELGROUP-${channel_grp_id}/CHANNEL-${channel_id}
        ...   parameter=resourceDN
        ...   value=${rmod_phy_dn}
        ...   delta_id=${delta_id}
    END
