*** Settings ***
Documentation       :copyright:     Nokia
...                 :This File has Keywords related to the Airphone or iphy
Library      String
Library      OperatingSystem
Library      DateTime
Library      Telnet
Library      Collections
Library      ta5g_iphy

*** Variables  ***
${iphy_file_path}      ${EXEC_DIR}/config/ap
${iphy_dirpath}        /rom/simmode/
*** Keywords ***

Update Iphy Xml
    [Arguments]     ${iphy_file_name}
    Update And Put Iphy Xml     input_filepath=${iphy_file_path}/${iphy_file_name}     output_dirpath=${iphy_dirpath}

Basic Bring Up
    [Documentation]       This keyword is for basic Ng, X2 and AP cell setup
    NG Link Should be UP
    X2AP Link Should be UP
    Sleep   60s

Trigger Reestablishment
    [Documentation]       This keyword shall be used to trigger re-establishment to either same or different cell.
    [Arguments]           ${ue_id}      ${gnb_id}    ${target_cellid}    ${reason}
    Log to Console      Trigger re-establishment
    wtsrunner.ue_rrc_reestablish     id=${ue_id}     gnb=${gnb_id}     cell=${target_cellid}    cause=${reason}

Get IPHY File From AP
    [Documentation]       This keyword shall be used get iphy file from AP
    [Arguments]           ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/rom/simmode/iphy.xml ${save_dir}/iphy.xml
    OperatingSystem.Should Exist    ${save_dir}/iphy.xml
    ${path}    Set Variable    ${save_dir}/iphy.xml
    [Return]    ${path}

Pass Lua File
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.script      file=${lua_file}      entry=sim_log_set_flush()
    sleep   1s
