*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005914_B/Resource/resouce.py
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/libraries/snapshot_files.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005914_B/Library/note_var.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
&{fault_4459}    faultId=${4459}
&{fault_4654}    faultId=${4654}
&{fault_4655}    faultId=${4655}
&{fault_61524}    faultId=${61524}
&{fault_61652}    faultId=${61652}
&{fault_61649}    faultId=${61649}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4654}   &{fault_4655}   &{fault_61524}   &{fault_61652}   &{fault_61649}
&{siso_fault}   faultId=${4681}
&{siso_fault_T088}   faultId=${4656}
&{siso_fault_T289}   faultId=${4293}
${TS_CASE_LOG_PATH}   ${OUTPUT_DIR}
${Instance_Id}      ${tl.gnbs[0].instance_id}
${MIN_SIZE}     ${1024}

*** Keyword ***
Suite Setup CB005914-B
    robot_common_operations.Common Suite Setup
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    CI_interface.Common Suite Setup
    Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error    ADMIN UnBlock NR cell and check status  cell_index=1
    run keyword and ignore error    ADMIN UnBlock NR cell and check status  cell_index=2
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check BTS OnAir
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
#    run keyword and ignore error    COAM Reset RAD Param    domain=NrUlPhy   name=phyEventEnableExt
#    run keyword and ignore error    Webem Disable iq Capture
#    Enable Phy Event Param
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}
    run keyword if   ${scf_imported_need}==${true} or ${is_cells_onair}==${false}
     ...   Import SCF by Custom for 5914
     ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_5914.xml
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    COAM Backup SCF
    COAM Backup Full SCF    file_name=5914_scf.xml
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/5914_scf.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${scf_xml}
    set suite variable     ${rmod_cell_mapping}
    set suite variable     ${rmod_serial_mapping}
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout    display=${${DEBUG}}

Suite Teardown CB005914-B
    Run Keyword And Ignore Error   COAM Logout
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    robot_common_operations.Common Suite Teardown

Case Setup CB005914-B
    robot_common_operations.Common Case Setup
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword and Ignore Error    Set Sanity Check to False
    Run Keyword and Ignore Error   Start BTS Log Collection
    run keyword and ignore error    ADMIN UnBlock NR cell and check status  cell_index=1
    run keyword and ignore error    ADMIN UnBlock NR cell and check status  cell_index=2
    run keyword and ignore error    COAM Reset RAD Param    domain=NrUlPhy   name=phyEventEnableExt
    run keyword and ignore error    Webem Disable iq Capture
    Enable Phy Event Param

Case Teardown CB005914-B
    run keyword and ignore error    Webem Disable iq Capture
    run keyword if test failed    Catch Snapshot COAM
    run keyword and ignore error    ADMIN UnBlock NR Cell And Check Status  cell_index=1
    run keyword and ignore error    ADMIN UnBlock NR Cell And Check Status  cell_index=2
    run keyword and ignore error    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error   Save or Remove logs
    run keyword if test failed    run keyword and ignore error    Capature Sreenshot COAM   file_dir=${OUTPUT_DIR}
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    run keyword and ignore error   COAM Logout
    Connect to gnb coam via ssl
    ${allowed_faults}   Create List   @{ALLOWED_FAULT}   ${siso_fault}   ${siso_fault_T088}   ${siso_fault_T289}
    Wait Until Keyword Succeeds   2m   30s   Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    CI_interface.Common Case Teardown

Trigger L1 uplink suspicious event
    wait until keyword succeeds   3x   1min
    ...  csn.Connect to   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    ${output}    csn.execute    bsh:0:1;confmgmtbrowser write NrUlPhy phyEventEnable 16   connection=gnb
    [Teardown]    csn.Disconnect   connection=gnb

Enable Phy Event Param
    COAM Set RAD Param   domain=NrUlPhy   name=phyEventEnableExt   value=0x80000000
#     WEBEM Set RAD Param    domain=NrUlPhy   name=phyEventEnableExt   value=31 - EPhyEvent_PuschSnapshotVerification

Get ul_subcell_index
    [Arguments]   ${cellid}
    ${smod_name}   Get SMOD Product Name
    ${cells_info}   COAM Get Cell List
    FOR    ${cell}   IN   @{cells_info}
        Exit For Loop If  ${cell['globalCellId']}==${cellid}
    END
    ${physicalCellId}    set variable    ${cell['physicalCellId']}
    ${subCellList}    set variable   ${cell['subCellList']}
    FOR   ${subcell}   IN   @{subCellList}
        ${output}    run keyword if    ${subcell.count('UL')} >0
        ...   Get Regexp Matches      ${subcell}     Subcell-(\\d)\\s\\(UL\\)    1
        ${detect_ulsubcellid}    set variable if    ${subcell.count('UL')} >0    ${output[0]}
        Exit For Loop If    ${subcell.count('UL')} >0
    END
    ${ul_subcell_index}    set variable
    ...   [SMOD_R-1(${smod_name})] [PCI: ${physicalCellId}]NRCELL-${cellid}: Subcell ${detect_ulsubcellid}
    [Return]    ${ul_subcell_index}

Get RMOD name by id
    ${rmod_dic}    create dictionary
    ${btsinfo}   COAM Get BTS Info
    ${ru_num}    get length     ${btsinfo['radioModules']['rmod']}
    FOR  ${ru}   IN RANGE  ${ru_num}
        ${key}   set variable   ${btsinfo['radioModules']['rmod'][${ru}]['id']['configuration']}
        ${value}    set variable    ${btsinfo['radioModules']['rmod'][${ru}]['productName']}
        ${key}    Fetch from right    ${key}   /
        SET TO DICTIONARY   ${rmod_dic}    ${key}=${value}
     END
     [Return]   ${rmod_dic}

Webem Config RU iq Capture
    [Arguments]   ${cellid}=1
    ${ul_subcell}    Get ul_subcell_index    cellid=${cellid}
    ${ulsubcell_list}    create list
    append to list     ${ulsubcell_list}    ${ul_subcell}
    ${rmod_dic}    Get RMOD name by id
    ${rmod_key}    set variable    RMOD-${cellid}/RMOD_R-${cellid}(${rmod_dic['RMOD-${cellid}']})
    ${rmod_config}    run keyword if  '${scfname}'=='24R1' or '${scfname}'=='24R2'    create dictionary
    ...   ${rmod_key}=${radio_configuration_before24R3['${rmod_key}']}
    ...   ELSE   create dictionary   ${rmod_key}=${radio_configuration['${rmod_key}']}
    selenium_coam.configure_iq_capture    enable_capture_on_event=${True}   capture_event=${True}
    ...   ul_subcell_index_list=${ulsubcell_list}
    ...   buffer_cycle=16_FRAMES
    ...   capture_frame_offset=2
    ...   radio_configurations=${rmod_config}

Webem Disable iq Capture
    selenium_coam.disable_iq_capture

Get Coam Snapshop struct
    [Arguments]    ${snapshot_path}
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${snapshot_path} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
#    ${FILE_STRUCT}    snapshot_files.parse_snapshot_file_list   ${OUTPUT_DIR}/snapshot
    ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    ${OUTPUT_DIR}/snapshot
    set suite variable   ${FILE_STRUCT}
    set suite variable   ${Extracted_path}   ${OUTPUT_DIR}/snapshot

decode snapshot and check iq data file
    [Arguments]    ${snapshot_path}    ${decode_str}=fcpTriggeredCapture
    Get Coam Snapshop struct    snapshot_path=${snapshot_path}
     ${values}    Get Dictionary Values    ${FILE_STRUCT}
     FOR  ${list}   IN   @{values}
            ${status}    run keyword and return status    Should Contain Match    ${list}    regexp=\\S+${decode_str}\\S+
            exit for loop if   ${status}
     END
     should be true    ${status}

Get RMODs SN by cellid
    [Arguments]   ${cellid}    ${connection}=COAM
    ${hw_info}   coam.get_detected_hw_info   connection=${connection}
    ${rmod_info}   Create Dictionary
    FOR   ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        ${celldist}     set variable    'MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cellid}'
        run keyword if    ${celldist} in @{rmod_cell_mapping['${rmod['serialNumber']}']}
        ...    Set To Dictionary   ${rmod_info}
        ...   ${rmod['productName']}=${rmod['serialNumber']}
    END
    set suite variable    ${rmod_info}

Set rmod snapshot str dic
    ${rmod_snapshot}   Create Dictionary
    Set To Dictionary   ${rmod_snapshot}   AKQJ=gandalf_logs
#    Set To Dictionary   ${rmod_snapshot}   AQQK=bfw
    Set To Dictionary   ${rmod_snapshot}   AQQK=gandalf_logs
    set suite variable   ${rmod_snapshot}

23R3 decode snapshot and check bin file
    [Arguments]    ${snapshot_path}    ${decode_str}=fcpTriggeredCapture    ${runame}=AKQJ    ${cellid}=1
    Get RMODs SN by cellid     cellid=${cellid}
#    Set rmod snapshot str dic
    Get Coam Snapshop struct    snapshot_path=${snapshot_path}
    &{snapshot_bin}   Create Dictionary
    FOR   ${item}    IN    @{FILE_STRUCT}
        ${status}    run keyword and return status
        ...    Should Contain Match
        ...    ${FILE_STRUCT['${item}']}    regexp=BTS_${rmod_info['${runame}']}_RMOD_L_\\S+_${rmod_snapshot_23R3['${runame}']}
        ${snapshot_bin}   run keyword if   ${status}    _get match and set to dic 23R3
        ...   snapshot_bin=${snapshot_bin}
        ...   list=${FILE_STRUCT['${item}']}
        ...   item=${item}
        ...   runame=${runame}
        ...   ELSE    set variable   ${snapshot_bin}
    END
    ${result_list}    create list
    FOR   ${item}    IN    @{snapshot_bin}
        ${dirname}    fetch from left    ${item}    .zip
        RUN    unzip ${OUTPUT_DIR}/snapshot/${item} -d ${OUTPUT_DIR}/snapshot/${dirname}
        ${output}    run keyword if  '${runame}'=='AKQJ'
        ...   RUN    tar zxvf ${OUTPUT_DIR}/snapshot/${dirname}/${snapshot_bin['${item}']}
        ...   ELSE   _decompression_cmd_combination_AQQK
        ...   path=${OUTPUT_DIR}/snapshot/${dirname}/${snapshot_bin['${item}']}   dirname=${dirname}
        run keyword if    ${output.count('${decode_str}')}>0    append to list   ${result_list}    pass
        ...   ELSE    append to list   ${result_list}    fail
    END
    List Should Contain Value   ${result_list}    pass

_decompression_cmd_combination_AQQK
    [Arguments]   ${path}    ${dirname}
    RUN    unzip ${path} -d ${OUTPUT_DIR}/snapshot/${dirname}
    RUN    xz -d ${OUTPUT_DIR}/snapshot/${dirname}/bfw.zip.xz
    ${output}    RUN   unzip ${OUTPUT_DIR}/snapshot/${dirname}/bfw.zip -d ${OUTPUT_DIR}/snapshot/${dirname}
    [Return]   ${output}

decode snapshot and check bin file
    [Arguments]    ${snapshot_path}    ${runame}=AKQJ    ${cellid}=1
    Get RMODs SN by cellid     cellid=${cellid}
#    Set rmod snapshot str dic
    Get Coam Snapshop struct    snapshot_path=${snapshot_path}
    &{snapshot_bin}   Create Dictionary
    FOR   ${item}    IN    @{FILE_STRUCT}
        ${status}    run keyword and return status
        ...    Should Contain Match
        ...    ${FILE_STRUCT['${item}']}
        ...    regexp=BTS${Instance_Id}_${rmod_info['${runame}']}_RMOD_L_\\S+_${rmod_snapshot['${runame}']}\\S+_rxArray\\S+.bin
        ${snapshot_bin}   run keyword if   ${status}    _get match and set to dic
        ...   snapshot_bin=${snapshot_bin}
        ...   list=${FILE_STRUCT['${item}']}
        ...   item=${item}
        ...   runame=${runame}
        ...   ELSE    set variable   ${snapshot_bin}
    END
    ${result_list}    create list
    FOR   ${item}    IN    @{snapshot_bin}
        ${result_list}    _decode bin file in list    ${snapshot_bin}    item=${item}
        ...   result_list=${result_list}
    END
    List Should Contain Value   ${result_list}    pass

Extract and check IQ Data from on DU or RU
    [Arguments]    ${snapshot_path}    ${radio_iq}=True   ${du_iq}=True
#    Get RMODs SN by cellid     cellid=${cellid}
    Get Coam Snapshop struct    snapshot_path=${snapshot_path}
    Run keyword if   ${radio_iq}   Check IQ DATA Captured on Radio
    Run keyword if   ${du_iq}   Check IQ DATA Captured on DU

Check IQ DATA Captured on Radio
    [Arguments]    ${ru_decode_str}=fcpTriggeredCapture   ${TARGET_RU_FILE_NAME}=RadioIQData
    Log to console   Check IQ data on RU
    ${extracted_files}   snapshot_files.get_extracted_files   ${Extracted_path}
    FOR   ${file}   IN   @{extracted_files}
       ${ruiq_status}    run keyword and return status
       ...    Should Contain     ${file}    ${ru_decode_str}_thor.tar.gz
       ${ru_iq_data}   set variable if   ${ruiq_status}    ${file}
       ${ru_iq_data_size}   run keyword if   ${ruiq_status}
       ...   snapshot_files.get_file_size    ${Extracted_path}/${ru_iq_data}
       run keyword if   ${ruiq_status}  set test variable   ${ru_iq_data_size}
#       ...   AND   set test variable   ${ruiq_status}
       exit for loop if   ${ruiq_status}
    END
    should be true   ${ru_iq_data_size} > ${MIN_SIZE}
    ...   [ ERROR ] ${TARGET_RU_FILE_NAME} size should be greater than 1 KB :: ${ru_iq_data_size}

Check IQ DATA Captured on DU
    [Documentation]    To check IQ DATA file captured by DU side, below is how to catch the file name in different scenarios
    ...   L1 event: DL-*ContIqSnapshotBuffer, UL-*IqSnapshotBuffer
    ...   L2 event: DL&UL-*ContIqSnapshotBuffer
    [Arguments]    ${du_decode_str}=L1UlTrigger
    Log to console   Check IQ data on DU
    ${du_iq_key}   set variable if   '${du_decode_str}' == 'L1UlTrigger'      IqSnapshotBuffer    ContIqSnapshotBuffer
    FOR   ${item}    IN    @{FILE_STRUCT}
        ${duiq_status}    run keyword and return status
        ...    Should Contain Match  ${FILE_STRUCT['${item}']}    regexp=BTS${Instance_Id}\\S+_${du_iq_key}.xz
        ${iqdata_exist}    run keyword if   ${duiq_status}  _Check IQ Data Size not Empty    item=${item}    du_iq_key=${du_iq_key}
        exit for loop if   ${iqdata_exist}
    END

_Check IQ Data Size not Empty
    [Arguments]    ${item}    ${du_iq_key}    ${TARGET_DU_FILE_NAME}=DUIQData
    RUN    unzip ${Extracted_path}/${item} -d ${Extracted_path}/duiq
    ${du_iq_file}   RUN   ls ${Extracted_path}/duiq | grep '_${du_iq_key}'
    ${du_iq_file}    strip string    ${du_iq_file}
    ${du_iq_file_list}    split string    ${du_iq_file}    \n
    FOR    ${du_iq_file}    IN    @{du_iq_file_list}
        ${du_iq_data_size}   snapshot_files.get_file_size    ${Extracted_path}/duiq/${du_iq_file}
        ${status}    run keyword and return status    should be true   ${du_iq_data_size} > ${MIN_SIZE}
        ...   [ ERROR ] ${TARGET_DU_FILE_NAME} size should be greater than 1 KB :: ${du_iq_data_size}
        Exit For Loop If    ${status}
    END
    run keyword if  '${status}'=='${False}'    RUN   rm -rf ${Extracted_path}/duiq
    ${iqdata_exist}    Set Variable if  ${status}    ${true}    ${false}
    [Return]    ${iqdata_exist}

#_decode bin file in list
#    [Arguments]   ${snapshot_bin}    ${item}    ${result_list}    ${decode_str}
#    ${dirname}    fetch from left    ${item}    .zip
#    FOR   ${zip}    IN    @{snapshot_bin['${item}']}
#        RUN    unzip ${OUTPUT_DIR}/snapshot/${item} -d ${OUTPUT_DIR}/snapshot/${dirname}
#        ${output}   RUN    tar zxvf ${OUTPUT_DIR}/snapshot/${dirname}/${zip}
#        run keyword if    ${output.count('${decode_str}')}>0    append to list   ${result_list}    pass
#        ...   ELSE    append to list   ${result_list}    fail
#        RUN    rm -rf ${OUTPUT_DIR}/snapshot/${dirname}
#    END
#    [Return]   ${result_list}

_decode bin file in list
    [Arguments]   ${snapshot_bin}    ${item}    ${result_list}
    ${dirname}    fetch from left    ${item}    .zip
    FOR   ${zip}    IN    @{snapshot_bin['${item}']}
        RUN    unzip ${OUTPUT_DIR}/snapshot/${item} -d ${OUTPUT_DIR}/snapshot/${dirname}
        ${output}   RUN    du -b ${OUTPUT_DIR}/snapshot/${dirname}/${zip}
        ${bin_size}    split string   ${output}    \t
        run keyword if    ${bin_size}[0] > 0    append to list   ${result_list}    pass
        ...   ELSE    append to list   ${result_list}    fail
        RUN    rm -rf ${OUTPUT_DIR}/snapshot/${dirname}
    END
    [Return]   ${result_list}

_get match and set to dic 23R3
    [Arguments]    ${snapshot_bin}    ${list}    ${item}    ${runame}=AKQJ
    ${matches}    Get Matches    ${list}    regexp=BTS_${rmod_info['${runame}']}_RMOD_L_\\S+_${rmod_snapshot_23R3['${runame}']}
    set to dictionary     ${snapshot_bin}    ${item}=${matches[0]}
    [Return]      ${snapshot_bin}

_get match and set to dic
    [Arguments]    ${snapshot_bin}    ${list}    ${item}    ${runame}=AKQJ
    ${matches}    Get Matches    ${list}    regexp=BTS_${rmod_info['${runame}']}_RMOD_L_\\S+_${rmod_snapshot['${runame}']}
    set to dictionary     ${snapshot_bin}    ${item}=${matches}
    [Return]      ${snapshot_bin}

ADMIN Config RU iq Capture
    [Arguments]   ${cellid}=1
#    ${ul_subcell}    Get ul_subcell_index    cellid=${cellid}
    ${smod_dist_list}=    Get Runtime FRM info
    ${smod_dist}    set variable    ${smod_dist_list[0]}
    @{MO_list}    Split String    ${smod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    ${cell_dist}    set variable    ${runtime_info}/NRBTS_R-${MRBTS_ID}/NRCELL_R-${cellid}
    ${subcellId}    Get Subcell id by Cell_dist    cell_dist=${cell_dist}
    ${subcellId}   Convert To Integer   ${subcellId}
    ${ulsubcell_list}    create list
    ${uliq_dic}    create dictionary    nrcellDN=${cell_dist}    subcellId=${subcellId}
    append to list     ${ulsubcell_list}    ${uliq_dic}
    ${antennaList}    _set_antenna_list_by_cellid    cellid=${cellid}
    ${captureRUList}    create list
    ${captureru_dic}    create dictionary    targetRMOD=${runtime_info}/EQM_R-1/APEQM_R-1/RMOD_R-${cellid}    antennaList=${antennaList}
    ...    captureActivityTimer=${2}
    append to list    ${captureRUList}    ${captureru_dic}
    coam.configure_uplane_l1_iq_data
    ...   module_dn=23R4
    ...   capture_on_event=${True}
    ...   capture_on_event_bb_ru=${True}
    ...   ul_nr_subcell_list=${ulsubcell_list}
    ...   capture_ru_list=${captureRUList}
    ...   buffer_cycle=16frames
    ...   capture_frame_offset=${2}
    ...   connection=COAM

ADMIN Config RU iq Capture Update
    [Arguments]   ${cellid}=1   ${profile}=UL_PROFILE_1
#    ${ul_subcell}    Get ul_subcell_index    cellid=${cellid}
    ${smod_dist_list}=    Get Runtime FRM info
    ${smod_dist}    set variable    ${smod_dist_list[0]}
    @{MO_list}    Split String    ${smod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    ${cell_dist}    set variable    ${runtime_info}/NRBTS_R-${MRBTS_ID}/NRCELL_R-${cellid}
    ${subcellId}    Get Subcell id by Cell_dist    cell_dist=${cell_dist}
    ${subcellId}   Convert To Integer   ${subcellId}
    ${ulsubcell_list}    create list
    ${uliq_dic}    create dictionary    nrcellDN=${cell_dist}    subcellId=${subcellId}
    append to list     ${ulsubcell_list}    ${uliq_dic}
#    ${antennaList}    _set_antenna_list_by_cellid    cellid=${cellid}
    ${ru_index}   Mapping Nrcell Id to RU Index   cellid=${cellid}
    ${captureRUList}    create list
    ${captureru_dic}    create dictionary    targetRMOD=${runtime_info}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    ...    captureActivityTimer=${2}
    append to list    ${captureRUList}    ${captureru_dic}
    coam.configure_uplane_l1_iq_data
    ...   module_dn=${None}
    ...   capture_on_event=${True}
    ...   capture_on_event_bb_ru=${True}
    ...   profile=${profile}
    ...   ul_nr_subcell_list=${ulsubcell_list}
    ...   capture_ru_list=${captureRUList}
    ...   connection=COAM


Mapping Nrcell Id to RU Index
    [Arguments]    ${cellid}
    [Documentation]    Map NR cell ID to RMOD index based on rmod_cell_mapping and rmod_serial_mapping
    ${target_cell_dn}    Set Variable    MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cellid}
    ${rmod_serial_number}    Set Variable    ${EMPTY}
    ${rmod_index}    Set Variable    ${EMPTY}

    # Find the RMOD serial number that contains the target cell DN
    FOR    ${serial_number}    IN    @{rmod_cell_mapping.keys()}
        ${cell_list}    Set Variable    ${rmod_cell_mapping['${serial_number}']}
        ${found}    Run Keyword And Return Status    Should Contain    ${cell_list}    ${target_cell_dn}
        IF    ${found}
            ${rmod_serial_number}    Set Variable    ${serial_number}
            Exit For Loop
        END
    END

    Should Not Be Empty    ${rmod_serial_number}
    ...    No RMOD found for cell ID ${cellid} with DN ${target_cell_dn}

    # Get RMOD configuration DN from serial mapping
    ${rmod_config}    Set Variable    ${rmod_serial_mapping['${rmod_serial_number}']}
    ${config_dn}    Set Variable    ${rmod_config['configDN']}
    ${product_name}    Set Variable    ${rmod_config['productName']}

    # Extract RMOD index from configuration DN (e.g., MRBTS-835/EQM-1/APEQM-1/RMOD-3 -> 3)
    ${rmod_index}    Get Regexp Matches    ${config_dn}    RMOD-(\\d+)    1
    Should Not Be Empty    ${rmod_index}    Failed to extract RMOD index from ${config_dn}
    ${rmod_index}    Set Variable    ${rmod_index[0]}

    Log    Cell ID ${cellid} maps to RMOD index ${rmod_index} (Serial: ${rmod_serial_number}, Product: ${product_name})
    [Return]    ${rmod_index}

ADMIN disable L1 IQ capture
    coam.disable_uplane_l1_iq_capture   connection=COAM

_set_antenna_list_by_cellid
    [Arguments]   ${cellid}=1
    ${antennaList}    create list
    ${minusatt_list}    run keyword if   '${cellid}'=='1'  create list    ANT1
    ...   ELSE    Create list   0  2
    ${plusatt_list}    run keyword if   '${cellid}'=='2'   create list    0   2
    ${minusantennadic}     create dictionary    polarization=MINUS_45   antenna=${minusatt_list}
    ${plusantennadic}    run keyword if   '${cellid}'=='2'
    ...   create dictionary    polarization=PLUS_45   antenna=${plusatt_list}
    run keyword if   '${cellid}'=='2'     append to list    ${antennaList}    ${minusantennadic}   ${plusantennadic}
    ...   ELSE    append to list    ${antennaList}    ${minusantennadic}
    [Return]    ${antennaList}

Get Subcell id by Cell_dist
    [Arguments]   ${cell_dist}
    ${output}    COAM Get Cell Info   cell_id=${cell_dist}
    ${subcelllist}    set variable   ${output['subCellList']}
    ${subcellId}    Get Regexp Matches   ${subcelllist[0]}   Subcell-(\\d)${space}   1
    should not be empty   ${subcellId}
    [Return]   ${subcellId[0]}

Return scf name for release
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${scfname}    Run keyword if   '${gnb_release}'=='TRUNK'     set variable   TRUNK
       ...   ELSE IF    '${gnb_release}'!='TRUNK'    String.Fetch From Right    string=${gnb_release}    marker=SBTS
       [Return]     ${scfname}

Import SCF and Wait to onair
    [Arguments]   ${ip_addr}   ${SCF_FILE}
    coam.Import SCF On COAM   IP_WEBUI=${ip_addr}  SCF_FILE=${SCF_FILE}
    Wait Until Keyword Succeeds   10m   30s   Try Connect gNB    gnb_addr=${ip_addr}
    Wait until keyword succeeds  10min   1min   COAM Login
    Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

Return scf name by release
   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
   ${value}    run keyword if   '${gnb_release}'!='trunk'    fetch from right    ${gnb_release}    SBTS
   ${scfname}    set variable if   '${gnb_release}'=='trunk'   TRUNK     ${value}
   [Return]     ${scfname}

Import SCF by Custom for 5914
    [Arguments]   ${local_path}
    log to console    Import SCF for normal cell for 5914
    Import SCF and Wait to onair   ip_addr=${asik_addr}   SCF_FILE=${local_path}
#    COAM WEBUI Whether Close Start Up View Window
#    COAM WEBUI Logout    display=${${DEBUG}}

Case Setup for 5914
    robot_common_operations.Common Case Setup
    [Documentation]   Setup WEBUI login and  Check All Cells Onair
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}

Case Teardown for 5914
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    run keyword and ignore error    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword if test failed    run keyword and ignore error    Capature Sreenshot COAM   file_dir=${OUTPUT_DIR}
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    run keyword and ignore error   COAM Logout
    Connect to gnb coam via ssl
    ${allowed_faults}   Create List   @{ALLOWED_FAULT}   ${siso_fault}   ${siso_fault_T088}   ${siso_fault_T289}
    Wait Until Keyword Succeeds   2m   30s   Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    CI_interface.Common Case Teardown

Test Suite Setup For CB009514
    robot_common_operations.Common Suite Setup
#    Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
#    Import SCF by Custom for 5914
#    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL${Instance_Id}_CB005914.xml
    Wait Until Keyword Succeeds   2m   10s   COAM Login
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
#    COAM Add NOTE Object

Test Suite Teardown For CB009514
#    Import SCF by Custom for 5914
#    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL${Instance_Id}_default.xml
    Wait until keyword succeeds  2min   10s   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    Run keyword and ignore error   COAM Logout
    Run keyword and ignore error   COAM WEBUI Logout
    robot_common_operations.Common Suite Teardown


Case Setup for CB009514
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds   2m   1m   COAM Login
    COAM Backup Full SCF   file_name=siso_scf.xml
    Wait Until Keyword Succeeds    3m   30s   COAM Check All Cells Onair
    ${siso_scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/siso_scf.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${siso_scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${siso_scf_xml}
    set suite variable    ${siso_scf_xml}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    AlarmWatchdog.add_allow_alarms    fault_id=8101
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS OnAir
    run keyword and ignore error    COAM Reset RAD Param    domain=NrUlPhy   name=phyEventEnableExt
    Run Keyword and Ignore Error   Start BTS Log Collection
    run keyword and ignore error   ADMIN disable L1 IQ capture
    Enable Phy Event Param


Case Teardown for CB009514
    run keyword and continue on failure    Check Extra Reset From Blackbox
    Wait Until Keyword Succeeds   1m   3x   COAM Login
    run keyword if test failed    Catch Snapshot COAM
    run keyword if test failed   run keyword and ignore error    Stop and Save BTS Log Collection
    run keyword if test failed   run keyword and ignore error
    ...    Wait Until Keyword Succeeds   3x   10s    Change other cells qrxlevmin Except L3call Cell
    ...    l3call_cell=${L3CALL_CELLID}    qrxlevmin=-50
    run keyword and ignore error    COAM Reset RAD Param    domain=NrUlPhy   name=phyEventEnableExt
    run keyword and ignore error   ADMIN disable L1 IQ capture
    run keyword and ignore error   COAM Reset Site
    run keyword and ignore error   Wait Until Keyword Succeeds    20m   30s   COAM Check All Cells Onair
    Run keyword and ignore error   COAM WEBUI Logout
    CI_interface.Common Suite Setup
    Wait Until Keyword Succeeds   1m   3x   COAM Login
    Wait Until Keyword Succeeds    20m   30s   COAM Check All Cells Onair
    Run keyword and ignore error   COAM Logout
    robot_common_operations.Common Case Teardown

COAM Add NOTE Object
    ${note_object}   Set Variable   ${add_note_object}
    ${add_str}   Convert To String   ${note_object}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Delete NOTE Object
    ${note_object}   Set Variable   ${delete_note_object}
    ${add_str}   Convert To String   ${note_object}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

Change other cells qrxlevmin Except L3call Cell
    [Arguments]    ${l3call_cell}    ${qrxlevmin}=-22
    &{cell_value}    Create Dictionary
    FOR    ${cell}    IN    @{L3CALL_TL["${MRBTS_ID}"]}
        Run Keyword If    '${cell}'=='${l3call_cell}'    Set To Dictionary    ${cell_value}  ${cell}=-50
        ...   ELSE   Set To Dictionary    ${cell_value}  ${cell}=${qrxlevmin}
    END

    FOR   ${cell}    IN    @{cell_value}
        ${dict_param}    Create Dictionary    value=${cell_value['${cell}']}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell}
        ...    parameter=qRxLevMin
        ${list_param}    Create List    ${dict_param}
        ${param_dic_to_change}    Create Dictionary    update=${list_param}
        COAM Commission Prameters Operation    param_dic_to_change=${param_dic_to_change}
    END