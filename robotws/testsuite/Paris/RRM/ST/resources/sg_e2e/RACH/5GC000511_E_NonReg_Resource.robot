*** Settings ***
Documentation   description


*** Keywords ***
Cell setup with X2 checks
    [Arguments]  ${arg_name}  ${param_name}  ${param_value}
    set test variable   ${currentValueStatus}          ${TRUE}
    Check current values and target values  ${param_name}  ${param_value}
    Apply new parameter and commission  ${param_name}  ${param_value}
    ${current_step}       set variable    callSetup
    ${filter}    catenate    ether[24:2]== 0x0240||ether[24:2]== 0x0219
    privateKW_RACH.Perform call with all traces   ${current_step}  ${filter}
    run keyword and continue on failure     privateKW_RACH.Check in X2 for call setup  callSetup  ${arg_name}=${param_value}


Cell setup with L2 X2 checks
    [Arguments]  ${arg_name}  ${param_name}  ${param_value}
    set test variable   ${currentValueStatus}          ${TRUE}
    Check current values and target values  ${param_name}  ${param_value}
    Apply new parameter and commission  ${param_name}  ${param_value}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell setup  cellSetup  ${arg_name}=${param_value}
    ${current_step}       set variable    callSetup
    ${filter}    catenate    ether[24:2]== 0x0240||ether[24:2]== 0x0219
    privateKW_RACH.Perform call with all traces   ${current_step}  ${filter}
    run keyword and continue on failure     privateKW_RACH.Check in X2 for call setup  callSetup  ${arg_name}=${param_value}


Cell setup with L1 X2 checks
    [Arguments]  ${arg_name}  ${param_name}  ${param_value}
    set test variable   ${currentValueStatus}          ${TRUE}
    Check current values and target values  ${param_name}  ${param_value}
    Apply new parameter and commission  ${param_name}  ${param_value}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L1 for cell setup  cellSetup  ${arg_name}=${param_value}
    ${current_step}       set variable    callSetup
    ${filter}    catenate    ether[24:2]== 0x0240||ether[24:2]== 0x0219
    privateKW_RACH.Perform call with all traces   ${current_step}  ${filter}
    run keyword and continue on failure     privateKW_RACH.Check in X2 for call setup  callSetup  ${arg_name}=${param_value}


Cell reconfiguration with L2 check
    [Arguments]  ${arg_name}  ${param_name}  ${param_value}

    set test variable   ${currentValueStatus}          ${TRUE}
    ${prev_value}=  Check current values and target values and return current  ${param_name}  ${param_value}

    #Set and Test paramater in Syscom L2 l2ps - cell reconfiguration
    ${current_step}       set variable    cellReconfiguration
    configuration.save scf  backup_scf.xml
    run keyword and continue on failure     logs.Start Syscom Traces   ${current_step}
    ${dist_name}     set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    configuration.Set Parameter Value  ${dist_name}   ${param_name}   ${param_value}
    run keyword and continue on failure     logs.Stop Syscom Traces
    run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell reconfiguration
    ...  ${current_step}  ${arg_name}=${param_value}

    configuration.Set Parameter Value  ${dist_name}   ${param_name}   ${prev_value}


Cell reconfiguration and call setup with X2 check
    [Arguments]  ${arg_name}  ${param_name}  ${param_value}

    set test variable   ${currentValueStatus}          ${TRUE}
    ${prev_value}=  Check current values and target values and return current  ${param_name}  ${param_value}

    #Set paramater before call setup
    configuration.save scf  backup_scf.xml
    ${dist_name}     set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    configuration.Set Parameter Value  ${dist_name}  ${param_name}   ${param_value}

    ${current_step}       set variable    callSetup
    ${filter}    catenate    ether[24:2]== 0x0240||ether[24:2]== 0x0219
    privateKW_RACH.Perform call with all traces   ${current_step}  ${filter}
    run keyword and continue on failure     privateKW_RACH.Check in X2 for call setup  callSetup  ${arg_name}=${param_value}

    configuration.Set Parameter Value  ${dist_name}   ${param_name}   ${prev_value}


Check current values and target values
    [Arguments]     ${param_name}  ${param_value}
    Append To File   ${suite_dir}/result.txt   \nCheck current values and target values
    configuration.save scf  current_scf_for_check.xml
    ${xml_root} =   XML.parse xml   ${scf_path}/current_scf_for_check.xml
     privateKW_RACH.Check not equal with current value      ${xml_root}     ${param_name}    ${param_value}
    #run keyword unless  ${currentValueStatus}  run keywords
    run keyword if  ${currentValueStatus} == ${False}  run keywords
    ...  Append To File      ${suite_dir}/result.txt     \n\n\tSome paramter(s) already set      AND
    ...  fail    Some paramter(s) already set


Check current values and target values and return current
    [Arguments]     ${param_name}  ${param_value}
    Append To File   ${suite_dir}/result.txt   \nCheck current values and target values
    configuration.save scf  current_scf_for_check.xml
    ${xml_root} =   XML.parse xml   ${scf_path}/current_scf_for_check.xml
     privateKW_RACH.Check not equal with current value      ${xml_root}     ${param_name}    ${param_value}
    #run keyword unless  ${currentValueStatus}  run keywords
    run keyword if  ${currentValueStatus} == ${False}  run keywords
    ...  Append To File      ${suite_dir}/result.txt     \n\n\tSome paramter(s) already set      AND
    ...  fail    Some paramter(s) already set
    ${dist_name}=    set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    ${xpath}=  set variable  //managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ${value}=  XML.Get Element Text  ${xml_root}  ${xpath}
    [return]  ${value}


Apply new parameter and commission
    [Arguments]     ${param_name}  ${param_value}
    ${current_step}       set variable    cellSetup
    Append To File   ${suite_dir}/result.txt   \n\nApply target configuration
    configuration.save scf  backup_scf.xml
    ${xml_root} =   XML.parse xml   ${scf_path}/backup_scf.xml
    configuration.Change NRCELL parameter in SCF      ${xml_root}     ${param_name}    ${param_value}
    XML.saveXML        ${xml_root}      ${scf_path}/scf_to_apply.xml
    privateKW_RACH.Commission and wait for cell setup   ${scf_path}/scf_to_apply.xml   ${current_step}


Launch cell setup test
    [Arguments]  ${rsrpThresholdSSB}  ${powerRampingStep}  ${preambleReceivedTargetPower}  ${preambleTransMax}
    ...  ${raContentionResolutionTimer}  ${raResponseWindow}  ${zeroCorrelationZoneConfig}  ${prachConfigurationIndex}
    ...  ${prachRootSequenceIndex}  ${cbraPreamblesPerSsb}  ${msg1FrequencyStart}  ${msg3DeltaPreamble}  ${lteToNrFrameShift}=${EMPTY}
    ...  ${frameStructureType}=${EMPTY}  ${guardPeriodLength}=${EMPTY}  ${ulDlDataSlotRatio}=${EMPTY}

    #Check current values and target values
    Append To File   ${suite_dir}/result.txt   \nCheck current values and target values
    set test variable   ${currentValueStatus}          ${TRUE}
    configuration.save scf  current_scf_for_check.xml
    ${xml_root} =   XML.parse xml   ${scf_path}/current_scf_for_check.xml
    Run keyword if    '${rsrpThresholdSSB}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     rsrpThresholdSSB    ${rsrpThresholdSSB}
    Run keyword if    '${powerRampingStep}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     powerRampingStep    ${powerRampingStep}
    Run keyword if    '${preambleReceivedTargetPower}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     initialPreambleReceivedTargetPower   ${preambleReceivedTargetPower}
    Run keyword if    '${preambleTransMax}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     preambleTransMax    ${preambleTransMax}
    Run keyword if    '${raContentionResolutionTimer}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     raContentionResolutionTmr    ${raContentionResolutionTimer}
    Run keyword if    '${raResponseWindow}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     raResponseWindow    ${raResponseWindow}
    Run keyword if    '${zeroCorrelationZoneConfig}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     zeroCorrelationZoneConfig    ${zeroCorrelationZoneConfig}
    Run keyword if    '${prachConfigurationIndex}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     prachConfigurationIndex    ${prachConfigurationIndex}
    Run keyword if    '${prachRootSequenceIndex}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     prachRootSequenceIndex    ${prachRootSequenceIndex}
    Run keyword if    '${cbraPreamblesPerSsb}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     cbraPreamblesPerSsb    ${cbraPreamblesPerSsb}
    Run keyword if    '${msg1FrequencyStart}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     msg1FrequencyStart    ${msg1FrequencyStart}
    Run keyword if    '${msg3DeltaPreamble}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     msg3DeltaPreamble    ${msg3DeltaPreamble}
    log    ${currentValueStatus}

    run keyword if     ${currentValueStatus} == ${FALSE} and ${is_unitary_test} == ${TRUE}
    ...    Fail    parameter is already set


    #run keyword unless  ${currentValueStatus}  run keywords
    run keyword if  ${currentValueStatus} == ${False}  run keywords
    ...  Append To File      ${suite_dir}/result.txt     \n\n\tSome paramter(s) already set      AND
    ...  run keyword and continue on failure  fail    Some paramter(s) already set

    ${current_step}       set variable    cellSetup

    #Apply target configuration
    Append To File   ${suite_dir}/result.txt   \n\nApply target configuration
    ${xml_root} =   XML.parse xml   ${scf_path}/save_initial_scf.xml
    run keyword if  '${lteToNrFrameShift}'!='${EMPTY}'
    ...  511 Change parameter in SCF     ${xml_root}     lteToNrFrameShift    ${lteToNrFrameShift}  list=tddFrameStructure
    run keyword if  '${frameStructureType}'!='${EMPTY}'
    ...  511 Change parameter in SCF     ${xml_root}     frameStructureType   ${frameStructureType}  list=tddFrameStructure
    run keyword if  '${guardPeriodLength}'!='${EMPTY}'
    ...  511 Change parameter in SCF     ${xml_root}     guardPeriodLength    ${guardPeriodLength}  list=tddFrameStructure
    run keyword if  '${ulDlDataSlotRatio}'!='${EMPTY}'
    ...  511 Change parameter in SCF     ${xml_root}     ulDlDataSlotRatio    ${ulDlDataSlotRatio}  list=tddFrameStructure
    Run keyword if    '${rsrpThresholdSSB}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     rsrpThresholdSSB    ${rsrpThresholdSSB}
    Run keyword if    '${powerRampingStep}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     powerRampingStep    ${powerRampingStep}
    Run keyword if    '${preambleReceivedTargetPower}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     initialPreambleReceivedTargetPower    ${preambleReceivedTargetPower}
    Run keyword if    '${preambleTransMax}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     preambleTransMax    ${preambleTransMax}
    Run keyword if    '${raContentionResolutionTimer}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     raContentionResolutionTmr    ${raContentionResolutionTimer}
    Run keyword if    '${raResponseWindow}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     raResponseWindow    ${raResponseWindow}
    Run keyword if    '${zeroCorrelationZoneConfig}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     zeroCorrelationZoneConfig    ${zeroCorrelationZoneConfig}
    Run keyword if    '${prachConfigurationIndex}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     prachConfigurationIndex    ${prachConfigurationIndex}
    Run keyword if    '${prachRootSequenceIndex}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     prachRootSequenceIndex    ${prachRootSequenceIndex}
    Run keyword if    '${cbraPreamblesPerSsb}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     cbraPreamblesPerSsb    ${cbraPreamblesPerSsb}
    Run keyword if    '${msg1FrequencyStart}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     msg1FrequencyStart    ${msg1FrequencyStart}
    Run keyword if    '${msg3DeltaPreamble}' != '${EMPTY}'
    ...    511 Change parameter in SCF     ${xml_root}     msg3DeltaPreamble    ${msg3DeltaPreamble}
    XML.saveXML        ${xml_root}      ${scf_path}/scf_to_apply.xml


    # Download and configure mirroring scripts on system module board - ASIK or ASOD
    Run keyword if    '${system_module_type}' == 'ASIK'    Run keywords
    ...                               privateKW_RACH.Prepare Mirroring ASIK                AND
    ...                               logs.Update gnbMirroringConfig    connection=asikFhCnx    mirroring_mode=manual
    ...                               l2_l1_bip=true    syscom_mirroring=true
    Run keyword if    '${system_module_type}' == 'ASOD'    privateKW_RACH.Prepare Mirroring ASOD

    privateKW_RACH.Commission and wait for cell setup   ${scf_path}/scf_to_apply.xml   ${current_step}


    #Check parameter value in SYSCOM L1 and L2 for cell setup
    run keyword and continue on failure   privateKW_RACH.Check in syscom L1 for cell setup  ${current_step}
    ...  expectedZeroCorrelationZoneConfig=${zeroCorrelationZoneConfig}
    ...  expectedPrachRootSequenceIndex=${prachRootSequenceIndex}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell setup  ${current_step}
    ...  expectedPrachConfigurationIndex=${prachConfigurationIndex}
    ...  expectedMacContentionResTimer=${raContentionResolutionTimer}
    ...  expectedRaResponseWindowSizeSize=${raResponseWindow}
    ...  expectedCbraPreamblesPerSsb=${cbraPreamblesPerSsb}

    ${current_step}       set variable    callSetup
    ${filter}    catenate    ether[24:2]== 0x0240||ether[24:2]== 0x0219


    run keyword and continue on failure  privateKW_RACH.Perform call with all traces   ${current_step}  ${filter}

    #Check parameters value in X2 for call setup
    run keyword and continue on failure     privateKW_RACH.Check in X2 for call setup  ${current_step}
    ...  ${rsrpThresholdSSB}  ${powerRampingStep}  ${preambleReceivedTargetPower}  ${preambleTransMax}  ${raContentionResolutionTimer}
    ...  ${raResponseWindow}  ${zeroCorrelationZoneConfig}  ${prachConfigurationIndex}  ${prachRootSequenceIndex}
    ...  ${cbraPreamblesPerSsb}  ${msg1FrequencyStart}  ${msg3DeltaPreamble}


511 Change parameter in SCF
    [Arguments]  ${xml_root}  ${param_name}  ${param_value}  ${list}=${EMPTY}
    ${dist_name}=    set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    ${xpath}=  set variable if
    ...  '${list}'=='${EMPTY}'  //managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ...  '${list}'!='${EMPTY}'  //managedObject[@distName="${dist_name}"]/list[@name="${list}"]//p[@name="${param_name}"]
    XML.Set Element Text  ${xml_root}  xpath=${xpath}  text=${param_value}

