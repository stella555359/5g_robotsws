*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot


*** Keywords ***
Single_Cloud_SiSo_Common_vDU_Cell_Block_Unblock
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    ${tmp_scf_name}   Set Variable   tmp_vdu_cell_block_unblock.xml
    COAM VDU Backup Current SCF   local_dir_path=${OUTPUT_DIR}   filename=${tmp_scf_name}
    ${scf_xml}   XML.Parse XML  ${OUTPUT_DIR}/${tmp_scf_name}
    ${cell_elems}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    @{cell_id_list}   Create List
    FOR   ${cell_elem}   IN   @{cell_elems}
        ${cell_dn}   XML.Get Element Attribute   ${cell_elem}   distName   xpath=.
        ${cell_dn}   ${cell_id}   Should Match Regexp   ${cell_dn}   NRCELL-(\\d+)
        Append To List   ${cell_id_list}   ${cell_id}
    END
    Log To Console   ${cell_id_list}

    FOR   ${cell_id}   IN   @{cell_id_list}
        COAM VDU Block Cell   cell_id=${cell_id}
        Sleep   3s
    END
    Wait Until Keyword Succeeds   2m   10s   COAM VDU Check All Cell Status Blocked


    FOR   ${cell_id}   IN   @{cell_id_list}
        COAM VDU Unblock Cell   cell_id=${cell_id}
        Sleep   3s
    END

    Wait Until Keyword Succeeds   5m   20s   COAM VDU Check All Cell Status

    [Teardown]   VDU Siso Common Each Time Teardown


Single_Cloud_SiSo_Common_vDU_Cell_Reset
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    ${tmp_scf_name}   Set Variable   tmp_vdu_cell_reset.xml
    COAM VDU Backup Current SCF   local_dir_path=${OUTPUT_DIR}   filename=${tmp_scf_name}
    ${scf_xml}   XML.Parse XML  ${OUTPUT_DIR}/${tmp_scf_name}
    ${cell_elems}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    @{cell_dn_list}   Create List
    FOR   ${cell_elem}   IN   @{cell_elems}
        ${cell_dn}   XML.Get Element Attribute   ${cell_elem}   distName   xpath=.
        Append To List   ${cell_dn_list}   ${cell_dn}
        COAM VDU Reset Cell   cell_dn=${cell_dn}
    END
    Log To Console   ${cell_dn_list}

    Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status

    [Teardown]   VDU Siso Common Each Time Teardown


Single_Cloud_SiSo_Common_vDU_Import_SCF
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    COAM VDU Backup Current SCF
    COAM VDU Perform Commission

    Wait Until Keyword Succeeds   20m   1m   COAM VDU Check All Cell Status

    [Teardown]   VDU Siso Common Each Time Teardown


Single_Cloud_SiSo_Common_vDU_Rannic_Reset
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    ${tmp_scf_name}   Set Variable   tmp_vdu_rannic_reset.xml
    COAM VDU Backup Current SCF   local_dir_path=${OUTPUT_DIR}   filename=${tmp_scf_name}
    ${scf_xml}   XML.Parse XML  ${OUTPUT_DIR}/${tmp_scf_name}
    ${distName}   XML.Get Element Attribute   ${scf_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.vdu.5g:MRBTS"]
    ${distName}   ${mrbts_id}   Should Match Regexp   ${distName}   MRBTS-(\\d+)

    @{rannic_info_list}   COAM VDU Get Rannic Info   mrbts_id=${mrbts_id}
    FOR   ${rannic_info}   IN   @{rannic_info_list}
        ${r_nic_mod_dist_name}   Set Variable   ${rannic_info["r_nic_mod_dist_name"]}
        COAM VDU Reset Rannic   rannic_r_dn=${r_nic_mod_dist_name}
    END
    run keyword if  ${rulog_exist}    Wait Until Keyword Succeeds    5min   10s   VDU Enable LMI RU at ControlPC
    Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status
    [Teardown]   VDU Siso Common Each Time Teardown


Cloud_SiSo_Common_vDU_Reset_Keywords
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    COAM VDU Reset
    run keyword if  ${rulog_exist}    Wait Until Keyword Succeeds    5min   10s   VDU Enable LMI RU at ControlPC
    Wait Until Keyword Succeeds   20m   1m   COAM VDU Check All Cell Status

    [Teardown]   VDU Siso Common Each Time Teardown


Single_Cloud_SiSo_Common_vDU_RU_Lock_Unlock
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    @{rmod_id_list}   COAM VDU Get RMOD ID List
    COAM VDU Lock RU   rmod_id_list=${rmod_id_list}
    ${rmod_status_list}   COAM VDU Get RU Status
    FOR   ${rmod_status}   IN   @{rmod_status_list}
        ${administrative_state}   Set Variable   ${rmod_status["administrative_state"]}
        ${availability_status}   Set Variable   ${rmod_status["availability_status"]}
        ${operational_state}   Set Variable   ${rmod_status["operational_state"]}
        ${procedural_status}   Set Variable   ${rmod_status["procedural_status"]}

        Should Be Equal   ${administrative_state}   Locked
        # Should Be Equal   ${availability_status}    on line
        # Should Be Equal   ${operational_state}      enabled
        # Should Be Equal   ${procedural_status}      configured
    END


    COAM VDU Unlock RU   rmod_id_list=${rmod_id_list}
    ${rmod_status_list}   COAM VDU Get RU Status
    FOR   ${rmod_status}   IN   @{rmod_status_list}
        ${administrative_state}   Set Variable   ${rmod_status["administrative_state"]}
        ${availability_status}   Set Variable   ${rmod_status["availability_status"]}
        ${operational_state}   Set Variable   ${rmod_status["operational_state"]}
        ${procedural_status}   Set Variable   ${rmod_status["procedural_status"]}

        Should Be Equal   ${administrative_state}   Unlocked
        # Should Be Equal   ${availability_status}    on line
        # Should Be Equal   ${operational_state}      enabled
        # Should Be Equal   ${procedural_status}      configured
    END

    Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status
    [Teardown]   VDU Siso Common Each Time Teardown


Cloud_SiSo_Common_vDU_RU_Reset_Keywords
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    COAM VDU Login
    Clear Coredump files in OCP
    @{rmods_list}   COAM VDU Get RMOD ID List
    COAM VDU Reset RU   rmods_list=${rmods_list}
    run keyword if  ${rulog_exist}    Wait Until Keyword Succeeds    5min   10s   VDU Enable LMI RU at ControlPC
    Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status
    [Teardown]   VDU Siso Common Each Time Teardown


Single_Cloud_SiSo_Common_vDU_Snapshot
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    COAM VDU Login

    # Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status
    COAM VDU Save Local Snapshot

    [Teardown]   Run Keyword And Ignore Error   COAM VDU Logout

