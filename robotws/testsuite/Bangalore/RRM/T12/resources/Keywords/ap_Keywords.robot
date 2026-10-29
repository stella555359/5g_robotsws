*** Settings ***
Documentation       :copyright:     Nokia
...                 :This File has Keywords related to the Airphone or iphy
Library      Collections
Library      DateTime
Library      OperatingSystem
Library      String
Library      Telnet
Library      ta5g_iphy
Library      ute_fsmaccess

*** Variables ***
${IPHY_FILE_PATH}      ${EXEC_DIR}/config/ap
${IPHY_DIRPATH}        /rom/simmode/


*** Keywords ***
Update Iphy Xml
    [Documentation]    This keyword is used for Update Iphy Xml with given file
    ...                which is stored in feature/config/ap directory.
    [Arguments]     ${IPHY_FILE_NAME}
    Update And Put Iphy Xml     input_filepath=${IPHY_FILE_PATH}/${IPHY_FILE_NAME}     output_dirpath=${iphy_dirpath}

Basic Bring Up
    [Documentation]       This keyword is for basic Ng, X2 and AP cell setup
    NG Link Should Be UP
    X2AP Link Should Be UP
    Sleep   90s

Trigger Reestablishment
    [Documentation]       This keyword shall be used to trigger re-establishment to either same or different cell.
    [Arguments]           ${ue_id}      ${gnb_id}    ${target_cellid}    ${reason}
    Log To Console      Trigger re-establishment
    wtsrunner.Ue RRC Reestablish     id=${ue_id}     gnb=${gnb_id}     cell=${target_cellid}    cause=${reason}

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
    wtsrunner.Script      file=${lua_file}      entry=sim_log_set_flush()
    Sleep   1s

Remotely Interferance In TestMode
    [Documentation]     Remotely Interfereance in Testmode NR
    ...     Usage->  Remote Interference In TestMode   Prof_Id=7   Start_Sym_Pos=0    Num_Symb=32    Noise_Pow=${noise_power}
    ...     If Few of the Parameters are same then Can skip as the default values are given.
    ...     ${noise_power} if this is not possible in one Line we can create two variable and use ${noise_pow1},${noise_pow2}
    [Arguments]   ${Prof_Id}=9    ${Start_Sym_Pos}=0    ${Num_Symb}=32    ${Noise_Pow}=${noise_pow1},${noise_pow2}
    Remote Interference Testmode NR     profile_id=${Prof_Id}    start_symbol_position=${Start_Sym_Pos}
    ...    num_of_symbols=${Num_Symb}   noise_power_values=${Noise_Pow}
    Log To Console      Remotely Interfereance in Testmode NR

Set NR Cell Testmode
    [Documentation]     Set NR Testmode for NR CELL
    ...     usage-> Set NR Cell Testmode    2   1   remote_interference     7   activate    200s
    ...     Set NR Cell Testmode   gnbId=2      cellId=1    testmode=rim_rs     profId=7    action=activate     wait_for=300s
    ...     You Can Use This Keyword to activate/deactivate testmode remote_interference or rim_rs for different Profiles
    ...     wait_for is the time required for which We need to wait after sending the command
    [Arguments]    ${gnbId}=2    ${cellId}=1    ${testmode}=remote_interference    ${profId}=7    ${action}=activate    ${wait_for}=200s
    Cell Testmode Set NR
    ...     gnb=${gnbId}
    ...     cell_id=${cellId}
    ...     testmode=${testmode}
    ...     profile_id=${profId}
    ...     action=${action}
    Log To Console      Wait for ${wait_for} to get Expected alarm on site
    Sleep   ${wait_for}

NR Testmode RIMRS
    [Documentation]     Set NR Testmode RIMRS Cell
    ...     Usage   ->
    ...     NR Testmode RIMRS   ProfId=2    confMod=standalone    aggrCell=1    VictCell=3
    ...     rsSetId=123456      prop_del=12     rsType1NScId=1,2,3,4,5,6,7,8    rsPat1=50
    ...     factorRsSequence=1  offsetRsSequence=0  startRbForRs=1,50,100,150   rimRsTxPower=-330
    ...     repetitionRsType1=1     numRsType1SetId=65536
    ...     If Few of the Parameters are same then Can skip as the default values are given.
    [Arguments]    ${ProfId}=2    ${confMod}=standalone    ${aggrCell}=1    ${VictCell}=3    ${rsSetId}=1234
    ...     ${prop_del}=12    ${rsType1NScId}=1,2,3,4,5,6,7,8     ${rsPat1}=50    ${factorRsSequence}=1
    ...     ${offsetRsSequence}=0   ${startRbForRs}=1,50,100,150    ${rimRsTxPower}=-330
    ...     ${repetitionRsType1}=1      ${numRsType1SetId}=65536
    Rimrs Testmode NR    profile_id=${ProfId}    config_mode=${confMod}   aggressor_cell=${aggrCell}
    ...    victim_cell=${VictCell}    rsSetId=${rsSetId}    propagation_delay=${prop_del}
    ...    rsType1NScId=${rsType1NScId}    rsPattern1Period=${rsPat1}     factorRsSequence=${factorRsSequence}
    ...    offsetRsSequence=${offsetRsSequence}    startRbForRs=${startRbForRs}    rimRsTxPower=${rimRsTxPower}
    ...    repetitionRsType1=${repetitionRsType1}   numRsType1SetId=${numRsType1SetId}
    Sleep       5s

