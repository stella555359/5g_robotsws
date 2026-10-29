*** Settings ***
Documentation
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    author: Fuzeng Zhu
...    contact: fuzeng.zhu@nokia-sbell.com
...    Generic Robot keywords for OAM.

Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    taf.ul.sc.gnb.oam.rest.CommonOAM    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}     WITH NAME    RestAPI
Library    taf.gnb.oam.coam.admin   WITH NAME  admin
Library    taf.sbts.oam.coam.admin  WITH NAME  SbtsAdmin
Library    taf.ul.sc.asimgr.AsiMgr  WITH NAME  AsiMgr
Library    ../python/DevNJ_5GOAM_keywords.py
Library    String
Library    Collections
Library    taf.selenium.sbts    WITH NAME    selenium_coam
Resource    taf/rfrl/common_resources/robot/coam.robot
Resource   ./DevNJ_DSS_keywords.robot
Library    ../python/DevNJ_ASIR_Selenium.py
Library    ../python/DevNJ_sbts_selenium.py
Library    SeleniumLibrary

*** Keywords ***
Lock Cell Groups
    [Documentation]  Lock Cell Groups
    ...  Description: Lock groups according to a given cell groups list, or lock all cell groups if no parameter
    ...  Example 1: Lock 1 Cell Group with id 1.
    ...    Lock Cell Groups  1
    ...  Example 2: Lock 2 Cell Groups with id 0 and 1, notify parameter 0 and 1 separated by single space.
    ...    Lock Cell Groups  0 1
    ...  Example 3: Lock all Cell Groups
    ...    Lock Cell Groups
    [Arguments]         ${str_cellgroups_list}=null
    ${cellgroup_list}   string.split string  ${str_cellgroups_list}
    Run Keyword If  '${str_cellgroups_list}' == 'null'  Log To Console  Lock All Cell Groups
    ...  ELSE  Log To Console  Lock cell groups in list @{cellgroup_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    FOR  ${cellgroup_info}  IN  @{bts_info['cellsGroup']}
        ${prefix}  ${cellgroup_id} =  string.Split String From Right  ${cellgroup_info['name']}  separator=-  max_split=${1}
        Run Keyword If  '${cellgroup_id}' in @{cellgroup_list} or '${str_cellgroups_list}' == 'null'  run keywords
        ...  Log To Console  Lock Cell Group ${cellgroup_info['id']['internal']}
        ...  AND  admin.lock cell group  ${cellgroup_info['id']['internal']}
    END

    [Teardown]    admin.Teardown admin

Unlock Cell Groups
    [Documentation]  Unlock Cell Groups
    ...  Description: Unlock groups according to a given cell groups list, or Unlock all cell groups if no parameter
    ...  Example 1: Unlock 1 Cell Group with id 1.
    ...    Unlock Cell Groups  1
    ...  Example 2: Unlock 2 Cell Groups with id 0 and 1, notify parameter 0 and 1 separated by single space.
    ...    Unlock Cell Groups  0 1
    ...  Example 3: Unlock all Cell Groups
    ...    Unlock Cell Groups
    [Arguments]         ${str_cellgroups_list}=null
    ${cellgroup_list}   string.split string  ${str_cellgroups_list}
    Run Keyword If  '${str_cellgroups_list}' == 'null'  Log To Console  Unlock All Cell Groups
    ...  ELSE  Log To Console  Unlock cell groups in list @{cellgroup_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    FOR  ${cellgroup_info}  IN  @{bts_info['cellsGroup']}
        ${prefix}  ${cellgroup_id} =  string.Split String From Right  ${cellgroup_info['name']}  separator=-  max_split=${1}
        Run Keyword If  '${cellgroup_id}' in @{cellgroup_list} or '${str_cellgroups_list}' == 'null'  run keywords
        ...  Log To Console  Unlock Cell Group ${cellgroup_info['id']['internal']}
        ...  AND  admin.unlock cell group  ${cellgroup_info['id']['internal']}
    END

    [Teardown]    admin.Teardown admin

Lock Cells
    [Documentation]  Lock cells
    ...  Description: Lock cells according to a given cells list, or lock all cells if no parameter
    ...  Example 1: Lock 1 Cell with id 2.
    ...    Lock Cells  2
    ...  Example 2: Lock 2 Cells with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Lock Cells  1 2
    ...  Example 3: Lock all Cells
    ...    Lock Cells
    [Arguments]         ${str_cells_list}=null  ${timeout}=60
    ${cells_list}   string.split string  ${str_cells_list}
    Run Keyword If  '${str_cells_list}' == 'null'  Log To Console  Lock All Cells
    ...  ELSE  Log To Console  Lock Cells in list @{cells_list}

    SbtsAdmin.Setup admin
    ${bts_info} =  SbtsAdmin.Get BTS info
    FOR  ${cell_info}  IN  @{bts_info['cells']['nr']}
        Run Keyword If  '${cell_info['globalCellId']}' in @{cells_list} or '${str_cells_list}' == 'null'  run keywords
        ...  Log To Console  Lock Cell ${cell_info['globalCellId']}
        ...  AND  SbtsAdmin.lock  dist_name=${cell_info['id']['internal']}  timeout=${timeout}
    END

    [Teardown]    SbtsAdmin.Teardown admin

Unlock Cells
    [Documentation]  Unlock cells
    ...  Description: Unlock cells according to a given cells list, or unlock all cells if no parameter
    ...  Example 1: Unlock 1 Cell with id 2.
    ...    Unlock Cells  2
    ...  Example 2: Unlock 2 Cells with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Unlock Cells  1 2
    ...  Example 3: Unlock all Cells
    ...    Unlock Cells
    [Arguments]         ${str_cells_list}=null  ${timeout}=60
    ${cells_list}   string.split string  ${str_cells_list}
    Run Keyword If  '${str_cells_list}' == 'null'  Log To Console  Unlock All Cells
    ...  ELSE  Log To Console  Unlock Cells in list @{cells_list}

    SbtsAdmin.Setup admin
    ${bts_info} =  SbtsAdmin.Get BTS info
    FOR  ${cell_info}  IN  @{bts_info['cells']['nr']}
        Run Keyword If  '${cell_info['globalCellId']}' in @{cells_list} or '${str_cells_list}' == 'null'  run keywords
        ...  Log To Console  Unlock Cell ${cell_info['globalCellId']}
        ...  AND  SbtsAdmin.unlock  dist_name=${cell_info['id']['internal']}  timeout=${timeout}
    END

    [Teardown]    SbtsAdmin.Teardown admin

Get HUB Ids of an BBMOD
    [Documentation]  Get HUB Ids of an BBMOD
    ...  Description: Get all HUB Id string of an BBMOD, can then be used to Lock/unlock or Reset HUBs
    ...  Example 1: Get HUB Ids of an BBMOD with Id 2
    ...    Get HUB Ids of an BBMOD  2
    ...    Return a string of HUB ids '3 4'
    ...  Example 2: Get HUB Ids of an BBMOD  3
    ...    Return a string of HUB ids 'None'
    ...  Pay attention that, before Lock/Unlock or Reset HUBs, should judge if 'None' returned

    [Arguments]         ${bbmod_id}
    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    ${hub_ids}   Get_Hub_Ids_Of_BBMOD  ${bts_info}  ${bbmod_id}
    [Return]  ${hub_ids}
    [Teardown]    admin.Teardown admin

Lock HUBS
    [Documentation]  Lock HUBs
    ...  Description: Lock HUBs according to a given HUB ID (ASIRMOD ID) list,  or lock all HUBs if no parameter
    ...  Example 1: Lock 1 HUB with id 2.
    ...    Lock HUBS  2
    ...  Example 2: Lock 2 HUBs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Lock HUBS  1 2
    ...  Example 3: Lock all HUBs
    ...    Lock HUBS
    [Arguments]         ${str_hubs_list}=null
    ${hubs_list}   string.split string  ${str_hubs_list}
    Run Keyword If  '${str_hubs_list}' == 'null'  Log To Console  Lock All HUBs
    ...  ELSE  Log To Console  Lock HUBs in list @{hubs_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    FOR  ${hub_info}  IN  @{bts_info['radioModules']['asirmod']}
        ${prefix}  ${hub_id} =  string.Split String From Right  ${hub_info['id']['configuration']}  separator=-  max_split=${1}
        Run Keyword If  '${hub_id}' in @{hubs_list} or '${str_hubs_list}' == 'null'  run keywords
        ...  Log To Console  Lock HUB ${hub_id}
        ...  AND  RestAPI.Lock hub  ${hub_id}
    END

    [Teardown]    admin.Teardown admin

Unlock HUBS
    [Documentation]  Unlock HUBs
    ...  Description: Unlock HUBs according to a given HUB ID (ASIRMOD ID) list,  or Unlock all HUBs if no parameter
    ...  Example 1: Unlock 1 HUB with id 2.
    ...    Unlock HUBS  2
    ...  Example 2: Unlock 2 HUBs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Unlock HUBS  1 2
    ...  Example 3: Unlock all HUBs
    ...    Unlock HUBS
    [Arguments]         ${str_hubs_list}=null
    ${hubs_list}   string.split string  ${str_hubs_list}
    Run Keyword If  '${str_hubs_list}' == 'null'  Log To Console  Unlock All HUBs
    ...  ELSE  Log To Console  Unlock HUBs in list @{hubs_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    FOR  ${hub_info}  IN  @{bts_info['radioModules']['asirmod']}
        ${prefix}  ${hub_id} =  string.Split String From Right  ${hub_info['id']['configuration']}  separator=-  max_split=${1}
        Run Keyword If  '${hub_id}' in @{hubs_list} or '${str_hubs_list}' == 'null'  run keywords
        ...  Log To Console  Unlock HUB ${hub_id}
        ...  AND  RestAPI.Unlock hub  ${hub_id}
    END

    [Teardown]    admin.Teardown admin

Reset Gnb
    [Documentation]  Reset Gnb
    RestAPI.Reset and Wait For Site

Reset HUBs via Gnb
    [Documentation]  Reset HUBs via Gnb
    ...  Description: Reset HUBs via Gnb according to a given HUB ID (ASIRMOD ID) list,  or reset all HUBs if no parameter
    ...  Example 1: Reset 1 HUB via Gnb with id 2.
    ...    Reset HUBs via Gnb  2
    ...  Example 2: Reset 2 HUBs via Gnb with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Reset HUBs via Gnb  1 2
    ...  Example 3: Reset all HUBs via Gnb
    ...    Reset HUBs via Gnb
    [Arguments]         ${str_hubs_list}=null
    ${hubs_list}   string.split string  ${str_hubs_list}
    Run Keyword If  '${str_hubs_list}' == 'null'  Log To Console  Reset All HUBs
    ...  ELSE  Log To Console  Reset HUBs in list @{hubs_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    FOR  ${hub_info}  IN  @{bts_info['radioModules']['asirmod']}
        ${prefix}  ${hub_id} =  string.Split String From Right  ${hub_info['id']['configuration']}  separator=-  max_split=${1}
        Run Keyword If  '${hub_id}' in @{hubs_list} or '${str_hubs_list}' == 'null'  run keywords
        ...  Log To Console  Reset HUB ${hub_id}
        ...  AND  admin.Reset Unit   dist_name=${hub_info['id']['configuration']}  force_radio_reset=${True}    timeout=300
    END

    [Teardown]    admin.Teardown admin

Get All HUB List Via AsiMgr
    [Documentation]  Reset HUBs via AsiMgr
    AsiMgr.Connect To AsiMgr
    ${all_hubs_list}  Create List
    ${hubs_count}  AsiMgr.Get hub number
    FOR  ${hub_id}  IN RANGE  1  ${hubs_count}+1
        Append To List  ${all_hubs_list}  ${hub_id}
    END
    [Return]  ${all_hubs_list}

Reset HUBs via AsiMgr
    [Documentation]  Reset HUBs via AsiMgr
    ...  Description: Reset HUBs via AsiMgr according to a given HUB ID (ASIRMOD ID) list,  or reset all HUBs if no parameter
    ...  Example 1: Reset 1 HUB via AsiMgr with id 2.
    ...    Reset HUBs via AsiMgr  2
    ...  Example 2: Reset 2 HUBs via AsiMgr with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Reset HUBs via AsiMgr  1 2  180
    ...  Example 3: Reset all HUBs via AsiMgr
    ...    Reset HUBs via AsiMgr
    [Arguments]         ${str_hubs_list}=null  ${timeout}=180
    ${hubs}     string.split string    ${str_hubs_list}
    ${all_hubs_list}  Get All HUB List Via AsiMgr

    ${hubs_list}  Set Variable If  '${str_hubs_list}' == 'null'  ${all_hubs_list}  ${hubs}

    Log To Console  Reset HUBs in list @{hubs_list}
    FOR  ${hub_id}  IN  @{hubs_list}
        Log To Console  Reset HUB Via AsiMgr ${hub_id}
        Reset HUB Via AsiMgr  ${hub_id}  ${timeout}
    END

Reset HUB Via AsiMgr
    [Documentation]  Reset 1 HUB via AsiMgr
    ...  Description: Reset HUB via AsiMgr by give a ASIRMOD ID
    ...  Example: Reset 1 HUB via AsiMgr with ASIRMOD ID 2.
    ...    Reset HUB via AsiMgr  2  180
    [Arguments]         ${asirmod_id}  ${timeout}=180
    ${reset_res}  Asir_reset_hub  ${asirmod_id}   ${timeout}
    Log To Console  asirmod_id ${asirmod_id} reset result: ${reset_res}
    should be True  ${reset_res['res']}

Reset Ants
    [Documentation]  Reset Ants
    ...  Description: Reset Ants via AsiMgr according to a given Ants list,  or reset all Ants if no parameter
    ...  Example 1: Reset 1 Ant with id 2.
    ...    Reset Ants  2
    ...  Example 2: Reset 2 Ants with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Reset Ants  1 2
    ...  Example 3: Reset all Ants
    ...    Reset Ants
    [Arguments]         ${str_ants_list}=null
    #Call Python keyword Get_Ant_Mod_Id_List to get all ant mod id list
    ${all_ants_mod_id_list}   Get_Ant_Mod_Id_List
    Log To Console  All Available Ant Mod ID: ${all_ants_mod_id_list}

    ${ants}     string.split string    ${str_ants_list}

    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    AsiMgr.Connect To AsiMgr
    Log To Console  Reset ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        Log To Console  Reset ANT ${ant_id}
        AsiMgr.Reset asirant  ${ant_id}
    END

Block Ants
    [Documentation]  Block Ants
    ...  Description: Block Ants via AsiMgr according to a given Ants list,  or block all ANTs if no parameter
    ...  Example 1: Block 1 Ant with id 2.
    ...    Block Ants  2
    ...  Example 2: Block 2 Ants with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Block Ants  1 2
    ...  Example 3: Block all Ants
    ...    Block Ants
    [Arguments]         ${str_ants_list}=null
    #Call Python keyword Get_Ant_Mod_Id_List to get all ant mod id list
    ${all_ants_mod_id_list}   Get_Ant_Mod_Id_List
    Log To Console  All Available Ant Mod ID: ${all_ants_mod_id_list}

    ${ants}     string.split string    ${str_ants_list}

    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    AsiMgr.Connect To AsiMgr
    Log To Console  Block ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        Log To Console  Block ANT ${ant_id}
        ${res}  AsiMgr.Block ant  ${ant_id}
        Log To Console  res:${res}
    END

Unblock Ants
    [Documentation]  Unblock Ants
    ...  Description: Unblock Ants via AsiMgr according to a given Ants list,  or Unblock all ANTs if no parameter
    ...  Example 1: Unblock 1 Ant with id 2.
    ...    Unblock Ants  2
    ...  Example 2: Unblock 2 Ants with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Unblock Ants  1 2
    ...  Example 3: Unblock all Ants
    ...    Unblock Ants
    [Arguments]         ${str_ants_list}=null
    #Call Python keyword Get_Ant_Mod_Id_List to get all ant mod id list
    ${all_ants_mod_id_list}   Get_Ant_Mod_Id_List
    Log To Console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants}     string.split string    ${str_ants_list}

    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    AsiMgr.Connect To AsiMgr
    Log To Console  Unblock ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        Log To Console  Unblock ANT ${ant_id}
        AsiMgr.Unblock ant  ${ant_id}
    END

Lock BBMODs
    [Documentation]  Lock BBMODs
    ...  Description: Lock HUBs according to a given BBMODs list,  or Lock all BBMODs if no parameter
    ...  Be aware that, some BBMOD e.g. BBMOD_R-3 has no 'configuration' entry in id, can not lock/unlock
    ...  Example 1: Lock 1 BBMOD with id 2.
    ...    Lock BBMODs  2
    ...  Example 2: Lock 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Lock BBMODs  1 2
    ...  Example 3: Lock all BBMODs
    ...    Lock BBMODs
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]         ${str_bbmods_list}=null
    ${bbmods_list}   string.split string  ${str_bbmods_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    ${all_avail_bbmods_list}  Create List

    FOR  ${bbmod_info}  IN  @{bts_info['basebandModules']}
        ${id_keys}=  Get Dictionary Keys  ${bbmod_info['id']}
        Continue For Loop If  'configuration' not in @{id_keys}
        ${prefix}  ${bbmod_id}   string.Split String From Right  ${bbmod_info['id']['configuration']}  separator=-  max_split=${1}
        Append To List  ${all_avail_bbmods_list}  ${bbmod_id}
    END

    Log To Console  All BBMODS Can be Locked ${all_avail_bbmods_list}
    ${bbmods_list}  Set Variable If  '${str_bbmods_list}' == 'null'  ${all_avail_bbmods_list}  ${bbmods_list}
    Log To Console  BBMODS to be Locked ${bbmods_list}

    FOR  ${bbmod_id}  IN  @{bbmods_list}
        Log To Console  Lock Baseband Module ${bbmod_id}
        RestAPI.Lock Baseband Module  ${bbmod_id}
    END

    [Teardown]    admin.Teardown admin

Unlock BBMODs
    [Documentation]  Unlock BBMODs
    ...  Description: Unlock HUBs according to a given BBMODs list,  or Unlock all BBMODs if no parameter
    ...  Be aware that, some BBMOD e.g. BBMOD_R-3 has no 'configuration' entry in id, can not lock/unlock
    ...  Example 1: Unlock 1 BBMOD with id 2.
    ...    Unlock BBMODs  2
    ...  Example 2: Unlock 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Unlock BBMODs  1 2
    ...  Example 3: Unlock all BBMODs
    ...    Unlock BBMODs
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]         ${str_bbmods_list}=null
    ${bbmods_list}   string.split string  ${str_bbmods_list}

    admin.Setup admin
    ${bts_info} =  admin.Get BTS info
    ${all_avail_bbmods_list}  Create List

    FOR  ${bbmod_info}  IN  @{bts_info['basebandModules']}
        ${id_keys}=  Get Dictionary Keys  ${bbmod_info['id']}
        Continue For Loop If  'configuration' not in @{id_keys}
        ${prefix}  ${bbmod_id} =  string.Split String From Right  ${bbmod_info['id']['configuration']}  separator=-  max_split=${1}
        Append To List  ${all_avail_bbmods_list}  ${bbmod_id}
    END

    Log To Console  All BBMODS Can be Unlocked ${all_avail_bbmods_list}
    ${bbmods_list}  Set Variable If  '${str_bbmods_list}' == 'null'  ${all_avail_bbmods_list}  ${bbmods_list}
    Log To Console  BBMODS to be Unlocked ${bbmods_list}

    FOR  ${bbmod_id}  IN  @{bbmods_list}
        Log To Console  Unlock Baseband Module ${bbmod_id}
        RestAPI.Unlock Baseband Module  ${bbmod_id}
    END

    [Teardown]    admin.Teardown admin

Reset BBMODs
    [Documentation]  Reset BBMODs
    ...  Description: Reset BBMODs via Gnb according to a given BBMODs list, or reset all BBMODs if no parameter
    ...  Example 1: Reset 1 BBMOD with id 2.
    ...    Reset BBMODs  2
    ...  Example 2: Reset 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Reset BBMODs  1 2
    ...  Example 3: Reset all BBMODs
    ...    Reset BBMODs
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]         ${str_bbmods_list}=null
    ${bbmods_list}   string.split string  ${str_bbmods_list}

    Run Keyword If  '${str_bbmods_list}' == 'null'  Log To Console  Reset All BBMODS
    ...  ELSE  Log To Console  Reset BBMODs in list @{bbmods_list}

    admin.Setup admin
    ${fbb_info}=  admin.Get fbb info
    FOR  ${fbb}  IN  @{fbb_info}
        ${prefix}  ${fbb_full_id} =  string.Split String From Right  ${fbb['id']['configuration']}  separator=/  max_split=${1}
        ${prefix}  ${fbb_id} =  string.Split String From Right  ${fbb_full_id}  separator=-  max_split=${1}
        Run Keyword If  '${fbb_id}' in @{bbmods_list} or '${str_bbmods_list}' == 'null'  run keywords
        ...  Log To Console  Reset BBMOD ${fbb_full_id}
        ...  AND  admin.Reset Unit  ${fbb['id']['internal']}   reset_type=Warm  timeout=${300}
    END

    [Teardown]    admin.Teardown admin

Reset gNB Configuration
    [Documentation]  Reset gNB Configuration
    ...  Description: Reset gNB Configuration, with an optional parameter timeout seconds
    [Arguments]     ${timeout}=900
    admin.Setup admin
    admin.Reset configuration
    ...    timeout=${timeout}
    [Teardown]    admin.Teardown admin

Reset ASIR Configuration
    [Documentation]  Reset ASIR Configuration
    AsiMgr.Connect To AsiMgr
    AsiMgr.Configuration reset

Perform gNB Full Commissioning
    [Documentation]  Perform gNB Full Commissioning
    ...
    ...    Arguments:
    ...    - _scf_file_:  SCF file path to perform
    ...    - _timeout_: timeout for commission finished
    ...
    ...    Examples:
    ...    - Perform gNB Full Commissioning
    ...    | Perform gNB Full Commissioning | scf_file= /20200918-1011.xml |
    ...    Return value:
    ...    - None
    [Arguments]  ${scf_file}  ${timeout}=300
    Wait Until Keyword Succeeds    6x   5s    admin.Setup admin
    admin.perform_commissioning
    ...  scf_file=${scf_file}
    ...  skip_parameter_relation_errors=true
    ...  timeout=${timeout}
    [Teardown]  admin.Teardown admin

Perform ASIR Full Commissioning
    [Documentation]  Perform ASIR Full Commissioning
    ...  Description: Perform ASIR Full Commissioning with a SCF path
    ...  Example:
    ...  Perform ASIR Full Commissioning  /home/ute/BTS_SW/7_21_CLOUD026TL061/5G20A_876_ASI-1_ASiR_20200918.xml
    [Arguments]  ${scf_file}
    AsiMgr.Connect To AsiMgr
    AsiMgr.Send Commission Fullfile  ${scf_file}

Get All Active Alarms Via Gnb
    [Documentation]  Get All Active Alarms Via Gnb
    ...  Description: Get All Active Alarms Via Gnb, return an alarms list
    admin.Setup admin
    @{output_alarms}    admin.get_active_alarms
    [Return]  ${output_alarms}
    [Teardown]  admin.Teardown admin

Check Allowed Or Required Alarm List Via Gnb
    [Documentation]  Check Allowed Or Required Alarm List Via Gnb
    ...  Description: Check Allowed Or Required Alarm List Via Gnb,
    ...     according to a given allowed alarms fault id list and a required alarms fault id list.
    ...  if str_allowed_fault_id_list not given, means all alarms are allowed
    ...  if required_alarms not given, means no alarms are required to appear
    ...  Example 1: Only allow alarms in fault id list '61649 61648 6450 61524'
    ...    Check Allowed Or Required Alarm List Via Gnb  str_allowed_fault_id_list=61649 61648 6450 61524
    ...  Example 2: Only allow alarms in fault id list '6450 61649' and alarm '6450 61649' must appear
    ...    Check Allowed Or Required Alarm List Via Gnb  str_allowed_fault_id_list=61649 61648 6450 61524  str_required_fault_id_list=6450 61649
    ...  Example 3: alarm 6450 61649 must appear
    ...    Check Allowed Or Required Alarm List Via Gnb  str_required_fault_id_list=6450 61649
    [Arguments]  ${str_allowed_fault_id_list}=null  ${str_required_fault_id_list}=null
    ${alarms}    Get All Active Alarms Via Gnb
    ${all_fault_id_list}  Create List
    FOR  ${alarm}  IN  @{alarms}
        Append To List  ${all_fault_id_list}  ${alarm['faultId']}
    END
    ${check_result}  Get_Check_Allowed_Or_Required_Alarm_List   ${all_fault_id_list}   ${str_allowed_fault_id_list}  ${str_required_fault_id_list}
    [Return]  ${check_result}

Get All Active Alarms Via ASIR
    [Documentation]  Get All Active Alarms Via ASIR
    ...  Description: Get All Active Alarms Via ASIR, return an alarms list
    AsiMgr.Connect To AsiMgr
    ${alarms_ordered_dict}   AsiMgr.Get_alarms_file_content
    Log To Console  alarms_ordered_dict:${alarms_ordered_dict}
    ${alarm_list}  Transfer_Activate_Alarms_ASIR  ${alarms_ordered_dict}
    Log To Console  Active Alarms: ${alarm_list}
    [Return]  ${alarm_list}

Check Allowed Or Required Alarm List Via Asir
    [Documentation]  Check Allowed Or Required Alarm List Via Asir
    ...  Description: Check Allowed Or Required Alarm List Via Asir,
    ...    according to a given allowed alarms fault id list and a required alarms fault id list.
    ...  if str_allowed_fault_id_list not given, means all alarms are allowed
    ...  if required_alarms not given, means no alarms are required to appear
    ...  Example 1: Only allow alarms in fault id list '61649 61648 6450 61524'
    ...    Check Allowed Or Required Alarm List Via Asir  str_allowed_fault_id_list=61649 61648 6450 61524
    ...  Example 2: Only allow alarms in fault id list '6450 61649' and alarm '6450 61649' must appear
    ...    Check Allowed Or Required Alarm List Via Asir  str_allowed_fault_id_list=61649 61648 6450 61524  str_required_fault_id_list=6450 61649
    ...  Example 3: alarm 6450 61649 must appear
    ...    Check Allowed Or Required Alarm List Via Asir  str_required_fault_id_list=6450 61649
    [Arguments]  ${str_allowed_fault_id_list}=null  ${str_required_fault_id_list}=null
    ${alarms}    Get All Active Alarms Via Asir
    ${all_fault_id_list}  Create List
    FOR  ${alarm}  IN  @{alarms}
        Append To List  ${all_fault_id_list}  ${alarm['faultId']}
    END
    ${check_result}  Get_Check_Allowed_Or_Required_Alarm_List   ${all_fault_id_list}   ${str_allowed_fault_id_list}  ${str_required_fault_id_list}
    [Return]  ${check_result}

Get All Cell Status Via Gnb
    [Documentation]     Get All Cell Status Via Gnb
    ...  Description: Get All Cell Status Via Gnb, return a cells status list
    admin.Setup admin
    @{cells_info}    admin.get_cells_info
    FOR  ${cell_info}  IN  @{cells_info}
        Keep In Dictionary  ${cell_info}  globalCellId  status
    END

    Log To Console  All Cell Status: ${cells_info}
    [Return]  ${cells_info}
    [Teardown]  admin.Teardown admin

Get All Ant Status
    [Documentation]     Get All Ant Status Via ASIR
    ...  Description: Get All Ant Status Via ASIR, return an Ants status list
    AsiMgr.Connect To AsiMgr
    ${ants_status_ordered_dict}   AsiMgr.get_all_ants_status
    ${ants_status_list}  Asir_OrderedDict_Info_To_List_Status  ${ants_status_ordered_dict}
    Log To Console  All Ants status: ${ants_status_list}
    #Log To Console  All ants status: ${ants_status_ordered_dict}
    [Return]  ${ants_status_list}

Get All HUB Status Via Gnb
    [Documentation]  Get All HUB Status Via Gnb
    ...  Description: Get All HUB Status Via Gnb, return an HUBs status list
    admin.Setup admin
    ${bts_info}=  admin.Get BTS info
    ${raw_hub_list}  Set Variable  ${bts_info['radioModules']['asirmod']}
    ${hubs_list}  Create List
    FOR  ${raw_hub_info}  IN  @{raw_hub_list}
        Keep In Dictionary  ${raw_hub_info}  id  status
        Log To Console  ${raw_hub_info}
        Append To List  ${hubs_list}  ${raw_hub_info}
    END

    Log To Console  All HUB Status: ${hubs_list}
    [Return]  ${hubs_list}
    [Teardown]  admin.Teardown admin

Get All HUB Status Via ASIR
    [Documentation]  Get All HUB Status Via ASIR
    ...  Description: Get All HUB Status Via ASIR, return an HUBs status list
    AsiMgr.Connect To AsiMgr
    ${hubs_status_ordered_dict}   AsiMgr.get_all_hubs_status
    ${hubs_status_list}  Asir_OrderedDict_Info_To_List_Status  ${hubs_status_ordered_dict}
    Log To Console  All HUBs status: ${hubs_status_list}
    [Return]  ${hubs_status_list}

Get All BBMOD Status
    [Documentation]  Get All BBMOD Status
    ...  Description: Get All BBMOD Status, return an BBMODs status list
    admin.Setup admin
    ${bts_info}=  admin.Get BTS info
    ${raw_bbmod_list}  Set Variable  ${bts_info['basebandModules']}
    ${bbmods_list}  Create List
    FOR  ${raw_bbmod_info}  IN  @{raw_bbmod_list}
        Keep In Dictionary  ${raw_bbmod_info}  id  status
        Log To Console  ${raw_bbmod_info}
        Append To List  ${bbmods_list}  ${raw_bbmod_info}
    END

    Log To Console  All BBMOD Status: ${bbmods_list}
    [Return]  ${bbmods_list}
    [Teardown]  admin.Teardown admin

Check Cell Status Consistency
    [Documentation]  Check Cell Status Consistency
    ...  Description: Check Cell Status Consistency between Gnb and ASIR, return a bool result
    ...  Currently only Gnb cell status administrativeState "Locked/Unlocked" is taken into account,
    ...  That if Cell Locked, ASIMgr cell's channels are disabled, otherwise enabled.
    admin.Setup admin
    @{cells_status_gnb}    admin.get_cells_info
    FOR  ${cell_info}  IN  @{cells_status_gnb}
        Keep In Dictionary  ${cell_info}  globalCellId  status
    END

    Log To Console  cells_status_gnb: ${cells_status_gnb}

    AsiMgr.Connect To AsiMgr
    ${path_to_scf}  AsiMgr.collect_commissioning_file  /tmp
    Log To Console  asir exported scf: ${path_to_scf}
    ${cells_status_asir}  Get_Cell_Status_List_Via_ASIR  ${path_to_scf}

    Log To Console  cells_status_asir: ${cells_status_asir}
    ${consistency_result}  Get_Check_Cell_Status_Consistency  list_gnb_cell_status=${cells_status_gnb}  list_asir_cell_status=${cells_status_asir}
    Log To Console  consistency_result: ${consistency_result}
    should Be True  ${consistency_result['consistent_result']}
    [Teardown]  admin.Teardown admin

Check Hub Status Consistency
    [Documentation]  Check Hub Status Consistency
    ...  Description: Check Hub Status Consistency between Gnb and ASIR, return a bool result
    ${hubs_status_gnb}  Get All HUB Status Via Gnb
    ${hubs_status_asir}  Get All HUB Status Via ASIR
    ${consistency_result}  Get Check Hub Status Consistency  list_gnb_hub_status=${hubs_status_gnb}  list_asir_hub_status=${hubs_status_asir}
    Log To Console  Consistency Result: ${consistency_result}
    should Be True  ${consistency_result['consistent_result']}

Check Cell Status
    [Documentation]  Check Cell Status
    ...  Description: Check if the cell status matches the expected value. Cell status are: usageState,
    ...               proceduralStatus, availabilityStatus, administrativeState, operationalState and blockingState.
    ...  Example:
    ...  Check Cell Status  1   administrativeState=unlocked  operationalState=Enabled
    ...  Check Cell Status  1   usageState=Active    proceduralStatus=configured    availabilityStatus=Online
    ...                         administrativeState=Unlocked    operationalState=Enabled    blockingState=Unblocked
    [Arguments]  ${cell_id}  &{dict_expected_status}
    ${list_cell_status}  Get All Cell Status Via Gnb

    ${check_result}   Get Check Cell Status  ${list_cell_status}  ${cell_id}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Check Ant Status
    [Documentation]  Check Ant Status
    ...  Description: Pass parameters Ant id and dictionary of expected status, return a bool result
    ...  Example:
    ...  Check Ant Status  1  swState=detected  localState=unblocked  availabilityStatus=None
    [Arguments]  ${ant_id}  &{dict_expected_status}
    ${list_ant_status}  Get All Ant Status
    Log To Console  ${list_ant_status}

    ${check_result}   Get Check Ant Status  ${list_ant_status}  ${ant_id}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Check Hub Status Via Gnb
    [Documentation]     Check if the Hub Status (displayed in GNB WebEM) is consistent with the expected value
    ...
    ...  Arguments:
    ...  - hub_id: HUB ID (ASIRMOD ID, not HUBMOD ID)
    ...  - dict_expected_status: dictionary that contains the expected status (key & value pairs)
    ...
    ...  Example:
    ...  | Check Hub Status Via Gnb | 2 | availabilityStatus=Online  administrativeState=unlocked  operationalState=Enabled |
    [Arguments]  ${hub_id}  &{dict_expected_status}
    ${list_hub_status}  Get All HUB Status Via Gnb
    Log To Console  ${list_hub_status}

    ${check_result}   Get Check Hub Status Via Gnb  ${list_hub_status}  ${hub_id}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Check Hub Status Via ASIR
    [Documentation]     Check if the Hub Status (displayed in ASiR WebEM) is consistent with the expected value
    ...
    ...  Arguments:
    ...  - hub_id: HUB ID (ASIRMOD ID, not HUBMOD ID)
    ...  - dict_expected_status: dictionary that contains the expected status (key & value pairs)
    ...
    ...  Example:
    ...  | Check Hub Status Via ASIR | 2 | availabilityStatus=None  operationalState=enabled  localState=unblocked |
    [Arguments]  ${hub_id}  &{dict_expected_status}
    ${list_hub_status}  Get All HUB Status Via ASIR
    Log To Console  ${list_hub_status}

    ${HUBMOD_ID}    Get Hubmod Id From Asirmod Id    ${hub_id}
    ${check_result}   Get Check Hub Status Via ASIR  ${list_hub_status}  ${HUBMOD_ID}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    Should Be True  ${check_result['check_result']}

Check BBMOD Status
    [Documentation]  Check BBMOD Status
    ...  Description: Pass parameters BBMOD id and dictionary of expected status, return a bool result
    ...  Example:
    ...  Check BBMOD Status  2
    ...  ...  availabilityStatus=Online  administrativeState=unlocked  proceduralStatus=configured  usageState=Idle  operationalState=Enabled
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]  ${bbmod_id}  &{dict_expected_status}
    ${list_bbmod_status}  Get All BBMOD Status
    Log To Console  ${list_bbmod_status}

    ${check_result}   Get Check BBMOD Status  ${list_bbmod_status}  ${bbmod_id}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Check All BBMODs Status
    [Documentation]    Check All BBMODs status with a expected status dictionary
    ...
    ...    Arguments:
    ...    - _dict_expected_status_:  dictionary of status key/value pair
    ...
    ...    Examples:
    ...    | Check All BBMODs Status | availabilityStatus=Online | administrativeState=unlocked |
    ...    | proceduralStatus=configured | usageState=Idle | operationalState=Enabled |
    [Arguments]   &{dict_expected_status}
    ${list_bbmod_status}  Get All BBMOD Status
    Log To Console  ${list_bbmod_status}

    ${check_result}   Get Check All BBMODs Status  ${list_bbmod_status}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Create Chrome Webdriver
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --maximized
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Call Method    ${chrome options}    add_argument    --disable-extensions
    Call Method    ${chrome options}    add_argument    --disable-dev-shm-usage
    ${webdriver}=    Create Webdriver    Chrome    alias=chromedriver    chrome_options=${chrome options}
    ${sl}=    BuiltIn.get_library_instance    SeleniumLibrary
    ${webdriver} =    Set Variable    ${sl.driver}
    set global variable    ${webdriver}

WebEM Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${webem_ip}=null  ${virtual_enable}=${TRUE}  ${logout_webem}=${TRUE}

    Create Chrome Webdriver

    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword if     ${logout_webem}    run keyword and ignore error    selenium_coam.logout
    ${WEBUI_USERNAME}  Set Variable   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}  Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${WEBUI_URL}  Set Variable If  '${webem_ip}'=='null'  https://${tl.gnbs[0].cu.oam_http_connection_details.addr}  https://${webem_ip}

    Log To Console    Login to URL: ${WEBUI_URL}
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USERNAME}  password=${WEBUI_PASSWORD}  browser=${webdriver}

    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

WebEM Logout
    [Arguments]   ${virtual_enable}=${TRUE}
    selenium_coam.logout
    run keyword if      ${virtual_enable}    run keyword and ignore error  selenium_coam.disable_virtual_display

WebEM ValidateAndActiveParameters
    [Documentation]  WebEM ValidateAndActiveParameters
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${300}

ASIR Manager Sync Directly
    [Documentation]  ASIR Manager Sync
    [Arguments]     ${virtual_enable}=${TRUE}
    Log To Console  Asir Mgr Sync Configuration
    ${WEBUI_USERNAME}  Set Variable   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}  Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${WEBUI_URL}  Set Variable  https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    DevNJ_ASIR_Selenium.clean_browser
    DevNJ_ASIR_Selenium.set_virtual_enable   ${virtual_enable}
    DevNJ_ASIR_Selenium.login  url=${WEBUI_URL}:3601  user_name=${WEBUI_USERNAME}  user_password=${WEBUI_PASSWORD}
    DevNJ_ASIR_Selenium.enter_config_man   overwrite=$True
    ${sync_res}  DevNJ_ASIR_Selenium.sync_config_with_gnb
    Should Be True  ${sync_res['res']}
    [Teardown]  DevNJ_ASIR_Selenium.logout

ASIR Manager Sync
    [Documentation]  ASIR Manager Sync
    [Arguments]     ${virtual_enable}=${TRUE}
    Log To Console  Asir Mgr Sync Configuration
    ${WEBUI_USERNAME}  Set Variable   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}  Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${WEBUI_URL}  Set Variable  https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

    ${sync_res}  selenium_asir_webem_sync  ${WEBUI_URL}  ${WEBUI_USERNAME}  ${WEBUI_PASSWORD}   ${virtual_enable}
    Log To Console  ASIR Manager Sync Result: ${sync_res}
    Should Be True  ${sync_res['res']}

Add Cell
    [Documentation]  Add Cell
    ...  Description: Add a cell, by copying from an existing cell and modifying necessary parameter
    ...  Example 1 for TDD:
    ...    Add Cell   cell_id_copy_from=1  cell_id=2  cell_group_id=1  asirmod_id=2
    ...        physCellId=2  lcrId=2  freqBandIndicatorNR=41
    ...        type0CoresetConfigurationIndex=12  gscn=6498  prachConfigurationIndex=96
    ...        virtual_disable=${False}
    ...  Example 2 for FDD:
    ...    Add Cell   cell_id_copy_from=1  cell_id=2  cell_group_id=1  asirmod_id=2
    ...        physCellId=2  lcrId=2  freqBandIndicatorNR=41
    ...        type0CoresetConfigurationIndex=12  gscn=6498  prachConfigurationIndex=96
    ...        virtual_disable=${False}
    ...        nrarfcnDl=22222   nrarfcnUl=33333
    ...        chBwDl=20MHz  chBwUl=15MHz
    [Arguments]   ${cell_id_copy_from}  ${cell_id}  ${cell_group_id}   ${asirmod_id}
    ...  ${physCellId}  ${lcrId}  ${freqBandIndicatorNR}  ${nrarfcn}=${NULL}  ${nrarfcnDl}=${NULL}  ${nrarfcnUl}=${NULL}
    ...  ${type0CoresetConfigurationIndex}=${NULL}  ${gscn}=${NULL}  ${prachConfigurationIndex}=${NULL}
    ...  ${chBw}=${NULL}  ${chBwDl}=${NULL}  ${chBwUl}=${NULL}  ${gscnOrSsPbchArfcn}=${NULL}
    ...  ${virtual_enable}=${TRUE}
    admin.Setup admin
    ${bts_info}  admin.Get BTS info
    ${sw_rel_name}  admin.get_sw_release_name
    admin.Teardown admin
    ${dict_cell_cellgroup_relation}  Get_Cell_CellGroup_Relation  ${bts_info}  ${cell_id}

    Log To Console  dict_cell_cellgroup_relation: ${dict_cell_cellgroup_relation}

    Log To Console  Check if cell to add ${cell_id} not exists
    Should Be True  ${dict_cell_cellgroup_relation['cell_id']}==${null}

    ${dict_cell_cellgroup_relation}  Get_Cell_CellGroup_Relation  ${bts_info}  ${cell_id_copy_from}

    Log To Console  dict_cell_cellgroup_relation: ${dict_cell_cellgroup_relation}
    Log To Console  Check if cell to copy from ${cell_id_copy_from} exists
    Should Be True  ${dict_cell_cellgroup_relation['cell_id']}!=${null}
    ${cellgroup_id_copy_from}  Set Variable  ${dict_cell_cellgroup_relation['cell_group_id']}

    ${MRBTS_ID}  Set Variable  MRBTS-${tl.gnbs[0].instance_id}
    ${NRBTS_ID}  Set Variable  NRBTS-${tl.gnbs[0].global_bts_id}
    WebEM Login  virtual_enable=${virtual_enable}


    #1. Add a NRCELL object under MRBTS-x/NRBTS-x, copy from existing object
    Log To Console  Add a NRCELL object under ${MRBTS_ID}/${NRBTS_ID}, copy from ${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id_copy_from}
    selenium_coam.add_object  object_name=${MRBTS_ID}/${NRBTS_ID}  object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1  copy_from=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id_copy_from}
    ...    include_subobject=${TRUE}  id_value=${cell_id}
    #Set parameter physCellId
    Log To Console  Set parameter physCellId ${physCellId}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Physical cell identifier   new_value=${physCellId}    abbr=physCellId
    #Set parameter lcrId
    Log To Console  Set parameter lcrId ${lcrId}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID    new_value=${lcrId}    abbr=lcrId

    #Set parameter freqBandIndicatorNR
    Log To Console  Set parameter freqBandIndicatorNR ${freqBandIndicatorNR}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Frequency band Indicator NR    new_value=${freqBandIndicatorNR}    abbr=freqBandIndicatorNR

    #Set parameter prachConfigurationIndex
    Run Keyword If  ${prachConfigurationIndex}!=${NULL}
    ...   Log To Console  Set parameter prachConfigurationIndex ${prachConfigurationIndex}
    Run Keyword If  ${prachConfigurationIndex}!=${NULL}  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=PRACH configuration index    new_value=${prachConfigurationIndex}    abbr=prachConfigurationIndex

    #Set parameter type0CoresetConfigurationIndex
    Run Keyword If  ${type0CoresetConfigurationIndex}!=${NULL}
    ...   Log To Console  Set parameter type0CoresetConfigurationIndex ${type0CoresetConfigurationIndex}
    Run Keyword If  ${type0CoresetConfigurationIndex}!=${NULL}  selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Coreset configuration Index    new_value=${type0CoresetConfigurationIndex}    abbr=type0CoresetConfigurationIndex
    #Set parameter gscn
    Run Keyword If  ${gscn}!=${NULL}  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Global synchronization channel number    new_value=${gscn}    abbr=gscn

    #Set parameter gscnOrSsPbchArfcn
    Run Keyword If  ${gscnOrSsPbchArfcn}!=${NULL}  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Synchronization channel number    new_value=${gscnOrSsPbchArfcn}    abbr=gscnOrSsPbchArfcn

    #Set parameter rModDNList
    ${has_rModDNList}  Run Keyword And Return Status  selenium_coam.get_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...  filter_param=List of RMOD distinguished names   abbr=rModDNList
    Run Keyword If  ${has_rModDNList}==${False}  Log To Console  SW Version=${sw_rel_name} has_rModDNList=${has_rModDNList}
    Run Keyword If  ${has_rModDNList}  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...  filter_param=List of RMOD distinguished names  node_index=${0}  new_value=${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-${asirmod_id}  abbr=rModDNList

    Run Keyword If  ${nrarfcn}!=${NULL}   selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...  filter_param=NR Absolute radio frequency channel number  abbr=nrarfcn  new_value=${nrarfcn}
    Run Keyword If  ${nrarfcnDl}!=${NULL}   selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...  filter_param=NR Absolute radio frequency channel number in downlink  abbr=nrarfcnDl  new_value=${nrarfcnDl}
    Run Keyword If  ${nrarfcnUl}!=${NULL}   selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...  filter_param=NR Absolute radio frequency channel number in uplink  abbr=nrarfcnUl  new_value=${nrarfcnUl}

    #Set parameter chBw
    Run Keyword If  '${chBw}'!='None'
    ...   Log To Console  Set parameter chBw ${chBw}
    Run Keyword If  '${chBw}'!='None'  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Channel bandwidth  new_value=${chBw}    abbr=chBw

    #Set parameter chBwDl
    Run Keyword If  '${chBwDl}'!='None'
    ...   Log To Console  Set parameter chBwDl ${chBwDl}
    Run Keyword If  '${chBwDl}'!='None'  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink  new_value=${chBwDl}    abbr=chBwDl

    #Set parameter chBwUl
    Run Keyword If  '${chBwUl}'!='None'
    ...   Log To Console  Set parameter chBwUl ${chBwUl}
    Run Keyword If  '${chBwUl}'!='None'  selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink  new_value=${chBwUl}    abbr=chBwUl

    #2. Add a NRCELLGRP object under MRBTS-x/NRBTS-x, copy from existing object:
    Log To Console  Add a NRCELLGRP object under ${MRBTS_ID}/${NRBTS_ID}, copy from ${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-${cellgroup_id_copy_from}
    selenium_coam.add_object    object_name=${MRBTS_ID}/${NRBTS_ID}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1  copy_from=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-${cellgroup_id_copy_from}
    ...    include_subobject=${TRUE}  id_value=${cell_group_id}
    #Modify value of nrCelllList #1 to lcrId of new cell:
    Log To Console  Set parameter nrCellList ${lcrId}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-${cell_group_id}
    ...    filter_param=List of NR cells assigned to cell group  node_index=${0}  new_value=${lcrId}    abbr=nrCellList

    #3. Add a LCELNR object under MRBTS-x/MNL-1/MNLENT-1/CELLMAPPING-1/, copy from existing object


    ${cell_map_node_list}   selenium_coam.get_object_name_list   CELLMAPPING
    Log To Console  cell_map_node_list: ${cell_map_node_list}
    ${cell_map_node}   Set Variable   ${cell_map_node_list[0]}

    ${channel_list}   expand_object_and_get_children   object_name=LCELNR-${cell_id_copy_from}  children_name=CHANNEL-
    Log To Console  Channel list: ${channel_list}

    Log To Console  Add a LCELNR object under CELLMAPPING-1, copy from ${MRBTS_ID}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-${cell_id_copy_from}

    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/${cell_map_node}
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${MRBTS_ID}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-${cell_id_copy_from}
    ...    include_subobject=${TRUE}    id_value=${cell_id}

    Log To Console  Set parameter   LCELNR-${cell_id}/lCelnrId ${lcrId}

    Log To Console  change antlDN in channel list: ${channel_list}

    FOR   ${channel}   IN   @{channel_list}
        ${copy_from_channel_distname}  set variable
        ...  ${MRBTS_ID}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-${cell_id_copy_from}/CHANNELGROUP-1/${channel}
        ${channel_distname}  set variable  ${MRBTS_ID}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-${cell_id}/CHANNELGROUP-1/${channel}
        Log To Console  copy_from_channel_distname:${copy_from_channel_distname}
        Log To Console  channel_distname:${channel_distname}
        ${cur_DN}   selenium_coam.get_parameter_value   dist_name=${copy_from_channel_distname}
        ...  filter_param=Distinguished Name of antenna line   abbr=antlDN
        Log To Console  current DN:${cur_DN}
        ${set_DN}   String.Replace String Using Regexp   ${cur_DN}   RMOD\-\\d+   RMOD-${asirmod_id}
        Log To Console  set new DN: ${set_DN}
        run keyword and ignore error  selenium_coam.set_parameter_value    dist_name=${channel_distname}
        ...  filter_param=Distinguished Name of antenna line  abbr=antlDN  new_value=${set_DN}
    END

    Log To Console  change antlDN in channel list: ${channel_list}
    #4. Add value of new cellgroup id in refNrCellGroup under MRBTS-x/NRBTS-x/NRDU-1
    Log To Console  Add value of new cellgroup id in refNrCellGroup under ${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    selenium_coam.add_element    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    Log To Console  Set parameter refNrCellGroup ${cell_group_id}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group  new_value=${cell_group_id}
    ...    node_index=${dict_cell_cellgroup_relation['nrdu_cellgroup_list_len']}  abbr=refNrCellGroup

    Log To Console  Validate And Activate parameters
    WebEM ValidateAndActiveParameters
    run keyword and ignore error  WebEM Logout  virtual_enable=${virtual_enable}
    sleep  10s
    Log To Console  ASIR Manager Sync
    ASIR Manager Sync  virtual_enable=${virtual_enable}

Delete Cell
    [Documentation]  Delete Cell
    ...  Description: Delete a cell, according to a given cell id
    ...  Example 1: Delete Cell 2, showing internet explorer procdure for debug
    ...    Delete Cell  cell_id=2  virtual_enable=${TRUE}
    ...  Example 2: Delete Cell 2, without virtual display
    ...    Delete Cell  cell_id=2
    [Arguments]     ${cell_id}   ${webem_ip}=null   ${virtual_enable}=${TRUE}
    run keyword if  '${webem_ip}'=='null'   admin.Setup admin
    ...  ELSE   admin.Setup admin  bts_host=${webem_ip}
    ${bts_info}  admin.Get BTS info
    admin.Teardown admin
    ${dict_cell_cellgroup_relation}  Get_Cell_CellGroup_Relation  ${bts_info}  ${cell_id}
    Log To Console  dict_cell_cellgroup_relation: ${dict_cell_cellgroup_relation}
    Log To Console  Check if Cell ${cell_id} exists
    Should Be True  ${dict_cell_cellgroup_relation['cell_id']}!=${null}

    ${MRBTS_ID}  Set Variable  MRBTS-${tl.gnbs[0].instance_id}
    ${NRBTS_ID}  Set Variable  NRBTS-${tl.gnbs[0].global_bts_id}
    WebEM Login   webem_ip=${webem_ip}  virtual_enable=${virtual_enable}
    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}
    run keyword if  ${dict_cell_cellgroup_relation['cell_group_has_other_cell']}==${FALSE}
    ...  selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-${dict_cell_cellgroup_relation['cell_group_id']}
    run keyword if  ${dict_cell_cellgroup_relation['cell_group_has_other_cell']}==${FALSE}
    ...  selenium_coam.remove_element   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${dict_cell_cellgroup_relation['nrdu_refNrCellGroup_index']}  abbr=refNrCellGroup
    selenium_coam.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    Log To Console  Validate And Activate parameters
    WebEM ValidateAndActiveParameters
    run keyword and ignore error  WebEM Logout
    Log To Console  ASIR Manager Sync
    ASIR Manager Sync  virtual_enable=${virtual_enable}

Set Cell Parameters To Be Same With Another
    [Documentation]    Get value of certain parameters from the *source cell* and set the corresponding parameters of the
    ...                *target cell* to the same value.
    ...
    ...    Arguments:
    ...    - _source_cell_id_: source cell where the value of parameter gets from
    ...    - _target_cell_id_: target cell that is going to be set with the parameter value getting from source cell
    ...    - _parameters_: parameters (at least one) whose value will be propagated from source cell to target cell
    ...
    ...    Examples:
    ...    - Get value of parameter ``Cell reserved for other use`` from Cell 1 and set the corresponding parameter of Cell 2 to the same value
    ...    | Set Cell Parameters To Be Same With Another | 1 | 2 | Cell reserved for other use |
    ...
    ...    - Get value of three parameters from Cell 1 and set to the corresponding parameters of cell 2 to the same value respectively
    ...    | Set Cell Parameters To Be Same With Another | 1 | 2 | NR Absolute radio frequency channel number |
    ...    | | | | Global synchronization channel number |
    ...    | | | | Coreset configuration Index |
    ...
    ...    Return value:
    ...    - None
    [Arguments]   ${source_cell_id}
    ...           ${target_cell_id}
    ...           @{parameters}

    WebEM Login

    ${MRBTS_ID}  Set Variable  MRBTS-${tl.gnbs[0].instance_id}
    ${NRBTS_ID}  Set Variable  NRBTS-${tl.gnbs[0].global_bts_id}

    FOR  ${param}  IN	@{parameters}
        ${s_value}=    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${source_cell_id}
         ...                                                 filter_param=${param}
        Log To Console  Value of \"${param}\" in source cell is : ${s_value}
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${target_cell_id}
         ...                                  filter_param=${param}
         ...                                  new_value=${s_value}
    END

    WebEM ValidateAndActiveParameters
    Run Keyword And Ignore Error    WebEM Logout

Perform Delta Commission On gNB
    [Documentation]    Perform Delta Commission On gNB, specifying necessary parameters to replace in template file,
    ...                and SCF template file path.
    ...
    ...    Arguments:
    ...    - _dict_scf_para_rep_: Dictionary of key/value of the parameter to replace
    ...    - _delta_template_path_: Delta SCF template file path
    ...    - _delta_format_: delta commissioning file format: ‘xml' or 'json'. Default is 'xml'
    ...
    ...    Examples:
    ...    - Configure MOs and activate DSS on gNB
    ...    | ${dict_scf_para_rep} | create Dictionary | gnb_bts_id=3486 | gnb_cell_id=1 | enb_bts_id=34861 | enb_cell_id=2 |
    ...    | Perform Delta Commission On gNB | dict_scf_para_rep=${dict_scf_para_rep}
    ...    ...  | delta_template_path=testsuite/OAM/Nanjing/Resources/python/delta_templates/gnb_configure_and_activate_dss_template |
    ...
    ...    Return value:
    ...    - None
    [Arguments]   ${dict_scf_para_rep}  ${delta_template_path}    ${delta_format}=xml
    ${delta_scf_path}  generate_scf_from_template   delta_template_path=${delta_template_path}  dict_scf_para_replace=${dict_scf_para_rep}
    ...                                             format=${delta_format}
    Teardown cOAM session
    Wait Until Keyword Succeeds    6x    5s    coam.connect to  name=cOAM

    ${convert_status}    Run Keyword If    '${delta_format}'.lower() == 'xml'
        ...    coam_parameter.convert_delta_scf_xml_multi_operation  delta_xml_path=${delta_scf_path}
    ${delta}    Set Variable If    '${delta_format}'.lower() == 'xml'    ${convert_status['updated']}    ${delta_scf_path}

    ${res}   coam_parameter.perform_scf_delta_commission  delta_file=${delta}  timeout=900  connection=cOAM
    [Teardown]  Teardown cOAM session

Check Hub Optical Interface Link Mode
    [Documentation]  Check Hub Optical Interface Link Mode
    ...    Arguments:
    ...    - _asirmod_id_: ASIRMOD ID, for example ASIRMOD-1, default value is 1
    ...    - _opt_if_: optical number dsiplay on webem, range 1-6
    ...    -_input_linkMode_dic_-: linkMode status want to check, for example: synchronization=${True}
    ...
    ...    Examples:
    ...    - Test Check Hub Optical Interface Link Mode
    ...    | ${dict_para} | Create Dictionary | synchronization=${True} | data=${True} |
    ...    | Check Hub Optical Interface Link Mode | asirmod_id=1 | opt_if=1 | input_linkMode_dic=${dict_para} |
    ...
    ...    Return value:
    ...    - None
    [Arguments]    ${input_linkMode_dic}  ${asirmod_id}=1  ${opt_if}=1

    Log To Console  \nInput_LinkMode=${input_linkMode_dic}

    SbtsAdmin.Setup Admin
    ${bts_info}  SbtsAdmin.Get BTS Info
    ${cables}    Set Variable  ${bts_info['cables']}
    ${linkMode}  Create List

    FOR  ${linkMode_ele}  IN  @{cables}
        Keep In Dictionary  ${linkMode_ele}  secondEndPointId  linkMode
        Append To List  ${linkMode}  ${linkMode_ele}
    END
    Log To Console  \nTotal_LinkMode=${linkMode}

    ${asir_opt_if}  Set Variable  'ASIRMOD-${asirmod_id}/OPT_IF${opt_if}'
    FOR   ${ele}  IN  @{linkMode}
        Run Keyword If  ${asir_opt_if} in '${ele['secondEndPointId']['configuration']}'  Run Keywords
    ...  Log To Console  ${ele['linkMode']  AND
    ...  Collections.Dictionary Should Contain Sub Dictionary  ${ele['linkMode']}  ${input_linkMode_dic}
    END

    [Teardown]  SbtsAdmin.Teardown Admin

Lock DASRFMs
    [Documentation]    Lock DASRFMs according to a given DASRFM list,  or lock all DASRFMs if no parameter
    ...
    ...    Arguments:
    ...    - _str_dasrfm_list_: dasrfm IDs, or all dasrfm if not specified
    ...
    ...    Examples:
    ...    - Lock 1 DASRFM with id 2.
    ...    | Lock DASRFMs | _str_dasrfm_list_=2 |
    ...   - Lock 2 DASRFMs with id 1 and 2.
    ...    | Lock DASRFMs | _str_dasrfm_list_=1 2 |
    ...   - Lock all DASRFMs
    ...    | Lock DASRFMs |
    ...    Return value:
    ...    - None
    [Arguments]         ${str_dasrfm_list}=null
    ${dasrfm_list}   string.split string  ${str_dasrfm_list}
    Run Keyword If  '${str_dasrfm_list}' == 'null'  Log To Console  Lock All DASRFMs
    ...  ELSE  Log To Console  Lock DASRFMs in list @{dasrfm_list}

    SbtsAdmin.Setup admin    name=coam_admin
    ${bts_info} =  SbtsAdmin.Get BTS info    connection=coam_admin

    FOR  ${dasrfm_info}  IN  @{bts_info['radioModules']['rmod']}
        ${prefix}  ${dasrfm_id} =  string.Split String From Right  ${dasrfm_info['id']['configuration']}  separator=-  max_split=${1}
        Run Keyword If  '${dasrfm_id}' in @{dasrfm_list} or '${str_dasrfm_list}' == 'null'  run keywords
        ...  Log To Console  Lock DASRFM ${dasrfm_id}
        ...  AND  RestAPI.Lock DASRFM  ${dasrfm_id}
    END
    [Teardown]    SbtsAdmin.Teardown admin    connection=coam_admin

Unlock DASRFMs
    [Documentation]    Unlock DASRFMs according to a given DASRFM list,  or Unlock all DASRFMs if no parameter
    ...
    ...    Arguments:
    ...    - _str_dasrfm_list_: dasrfm IDs, or all dasrfm if not specified
    ...
    ...    Examples:
    ...    - Unlock 1 DASRFM with id 2.
    ...    | Unlock DASRFMs | _str_dasrfm_list_=2 |
    ...   - Unlock 2 DASRFMs with id 1 and 2.
    ...    | Unlock DASRFMs | _str_dasrfm_list_=1 2 |
    ...   - Unlock all DASRFMs
    ...    | Unlock DASRFMs |
    ...    Return value:
    ...    - None
    [Arguments]         ${str_dasrfm_list}=null
    ${dasrfm_list}   string.split string  ${str_dasrfm_list}
    Run Keyword If  '${str_dasrfm_list}' == 'null'  Log To Console  Unlock All DASRFMs
    ...  ELSE  Log To Console  Unlock DASRFMs in list @{dasrfm_list}

    SbtsAdmin.Setup admin    name=coam_admin
    ${bts_info} =  SbtsAdmin.Get BTS info    connection=coam_admin

    FOR  ${dasrfm_info}  IN  @{bts_info['radioModules']['rmod']}
        ${prefix}  ${dasrfm_id} =  string.Split String From Right  ${dasrfm_info['id']['configuration']}  separator=-  max_split=${1}
        Run Keyword If  '${dasrfm_id}' in @{dasrfm_list} or '${str_dasrfm_list}' == 'null'  run keywords
        ...  Log To Console  Unlock DASRFM ${dasrfm_id}
        ...  AND  RestAPI.Unlock DASRFM  ${dasrfm_id}
    END
    [Teardown]    SbtsAdmin.Teardown admin    connection=coam_admin

Reset DASRFMs
    [Documentation]    Reset DASRFMs via Gnb according to a given DASRFMs list,  or reset all DASRFMs if no parameter
    ...
    ...    Arguments:
    ...    - _str_dasrfm_list_: dasrfm IDs, or all dasrfm if not specified
    ...
    ...    Examples:
    ...    - Reset 1 DASRFM with id 2.
    ...    | Reset DASRFMs | _str_dasrfm_list_=2 |
    ...   - Reset 2 DASRFMs with id 1 and 2.
    ...    | Reset DASRFMs | _str_dasrfm_list_=1 2 |
    ...   - Reset all DASRFMs
    ...    | Reset DASRFMs |
    ...    Return value:
    ...    - None
    [Arguments]         ${str_dasrfms_list}=null
    ${dasrfms_list}   string.split string  ${str_dasrfms_list}
    Run Keyword If  '${str_dasrfms_list}' == 'null'  Log To Console  Reset All DASRFMs
    ...  ELSE  Log To Console  Reset DASRFMs in list @{dasrfms_list}

    SbtsAdmin.Setup admin
    ${bts_info} =  SbtsAdmin.Get BTS info
    FOR  ${dasrfm_info}  IN  @{bts_info['radioModules']['rmod']}
        ${prefix}  ${dasrfm_id} =  string.Split String From Right  ${dasrfm_info['id']['configuration']}  separator=-  max_split=${1}
        Run Keyword If  '${dasrfm_id}' in @{dasrfms_list} or '${str_dasrfms_list}' == 'null'  run keywords
        ...  Log To Console  Reset DASRFM ${dasrfm_id}
        ...  AND  SbtsAdmin.Reset Unit   dist_name=${dasrfm_info['id']['configuration']}  force_radio_reset=${True}    timeout=300
    END
    [Teardown]    SbtsAdmin.Teardown admin

Get All DASRFM Status
    [Documentation]    Get All DASRFM Status Via Gnb, return an DASRFMs status list
    ...
    ...    Arguments:
    ...    - None
    ...
    ...    Examples:
    ...    - Get All DASRFM Status Via Gnb.
    ...    | Get All DASRFM Status |
    ...    Return value:
    ...    - _dasrfms_status_list_ , List of DASRFMs' status
    SbtsAdmin.Setup admin
    ${bts_info}=  SbtsAdmin.Get BTS info
    ${raw_dasrfm_list}  Set Variable  ${bts_info['radioModules']['rmod']}
    ${dasrfms_list}  Create List
    FOR  ${raw_dasrfm_info}  IN  @{raw_dasrfm_list}
        Keep In Dictionary  ${raw_dasrfm_info}  id  status
        Log To Console  ${raw_dasrfm_info}
        Append To List  ${dasrfms_list}  ${raw_dasrfm_info}
    END
    Log To Console  All DASRFM Status: ${dasrfms_list}
    [Return]  ${dasrfms_list}
    [Teardown]  SbtsAdmin.Teardown admin

Check DASRFM Status
    [Documentation]    Check DASRFM Status Via Gnb
    ...                Pass parameters DASRFM id and dictionary of expected status, return a bool result
    ...
    ...    Arguments:
    ...    - _dict_expected_status_ : Dictionary of status Key/Value pairs to check
    ...
    ...    Examples:
    ...    - Check DASRFM Status with ID 1
    ...    | Check DASRFM Status | dasrfm_id=1 | availabilityStatus=Online | administrativeState=unlocked | operationalState=Enabled |
    ...    Return value:
    ...    - None
    [Arguments]  ${dasrfm_id}  &{dict_expected_status}
    ${list_dasrfm_status}  Get All DASRFM Status
    Log To Console  ${list_dasrfm_status}

    ${check_result}   Get Check DASRFM Status  ${list_dasrfm_status}  ${dasrfm_id}  ${dict_expected_status}
    Log To Console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}
