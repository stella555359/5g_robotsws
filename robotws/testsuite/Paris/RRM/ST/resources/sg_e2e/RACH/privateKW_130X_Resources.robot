*** Settings ***
Documentation   description


*** Keywords ***
130X Apply new prachConfigIndex and recommission
    [Arguments]  ${prachConfigurationIndex}  ${current_step}
    Append To File      ${suite_dir}/result.txt     \n\nApply target prachConfigurationIndex - Recommission

    configuration.Mirroring Create SSH

    set test variable  ${ext_mirroring}  1
    ${filter}=  catenate  ether[24:2]!=0x012b && ether[24:2]!=0x0122 && ether[24:2]!=0x0127 && ether[24:2]!=0x0131 && ether[24:2]!=0x0240
    run keyword and continue on failure     privateKW_RACH.Start Syscom on mirroring        ${current_step}   ${filter}
    run keyword and continue on failure     logs.Start X2 Traces       ${current_step}

    ${dist_name}     set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1
    configuration.Set Parameter Value  ${dist_name}   prachConfigurationIndex   ${prachConfigurationIndex}

    # Wait for cell to be online
    wait until keyword succeeds    20 min     30 sec      gnbStatus.Check Cell Availability Status V2
    Append To File      ${suite_dir}/result.txt     \n\nCell Setup Done

    # Stop and collect SYSCOM for cell setup
    sleep   10
    run keyword and continue on failure     logs.Stop X2 Traces
    run keyword and continue on failure     privateKW_RACH.Stop Syscom on mirroring


130X Commission
    [Arguments]  ${xml_root}  ${current_step}
    130X Compare and update parameter in SCF
    ...  ${xml_root}  MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1   prachConfigurationIndex  ${prachConfIdx_target}
    Append To File   ${suite_dir}/result.txt     \n\nApply configuration - SCF Commission
    XML.saveXML  ${xml_root}  ${scf_path}/scf_to_apply.xml
    privateKW_RACH.Commission and wait for cell setup   ${scf_path}/scf_to_apply.xml   ${current_step}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L1 for cell setup  cellSetup
    ...  expectedPrachConfigurationIndex=${prachConfIdx_target}
    ...  expectedUlBandwidth=${expectedChBw_target}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell setup  cellSetup
    ...  expectedPrachConfigurationIndex=${prachConfIdx_target}


130X Recommission
    [Arguments]  ${current_step}
    130X Apply new prachConfigIndex and recommission  ${prachConfIdx_target}  ${current_step}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L1 for cell setup  cellSetup
    ...  expectedPrachConfigurationIndex=${prachConfIdx_target}
    ...  expectedUlBandwidth=${expectedChBw_target}
    run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell setup  cellSetup
    ...  expectedPrachConfigurationIndex=${prachConfIdx_target}


######################################################
# Parameter Handling                                 #
######################################################
130X Compare and update parameter in SCF
    [Documentation]  Update SCF if target value is different from current one. Use a variable (test level): paramUpToDate to notify any updtate
    ...  Arguments
    ...     Root element of the SCF file
    ...     Distinguished name (MRBTS-Id/NRBTS-Id , MRBTS-Id/NRBTS-Id/NRCELL-Id..)
    ...     Name of the parameter
    ...     Target value of the parameter
    ...     If required, name of the list containing the parameters
    [Arguments]    ${xml_root}  ${dist_name}  ${param_name}  ${param_value}  ${list}=${EMPTY}
    ${status}  ${cur_value}  130X Compare target value with current configuration
    ...  ${xml_root}  ${dist_name}  ${param_name}  ${param_value}  ${list}
    run keyword if  ${status}
    ...  Append To File   ${suite_dir}/result.txt   \n\t\t${param_name}: OK (${cur_value})
    #run keyword unless  ${status}  run keywords
    run keyword if  ${status} == ${False}  run keywords
    ...  set test variable   ${paramUpToDate}   ${FALSE}    AND
    ...  Append To File   ${suite_dir}/result.txt   \n\t\t${param_name}: not OK (current=${cur_value}, target=${param_value})  AND
    ...  130X Update value in SCF  ${xml_root}  ${dist_name}  ${param_name}  ${param_value}   ${list}

130X Compare target value with current configuration
    [Documentation]  Compare current and target value. Return result status (True if equal else False) and current configuration value.
    ...  Arguments:
    ...     Root element of the SCF file
    ...     Distinguished name (MRBTS-Id/NRBTS-Id , MRBTS-Id/NRBTS-Id/NRCELL-Id..)
    ...     Name of the parameter
    ...     Target value of the parameter
    ...     If required, name of the list containing the parameters
    [Arguments]  ${xml_root}  ${dist_name}  ${param_name}  ${param_value}  ${list}=${EMPTY}
    ${xpath}=  set variable if
    ...  '${list}'=='${EMPTY}'  //managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ...  '${list}'!='${EMPTY}'  //managedObject[@distName="${dist_name}"]/list[@name="${list}"]//p[@name="${param_name}"]
    ${value}=  XML.Get Element Text  ${xml_root}  ${xpath}
    ${status}=  run keyword and return status
        ...     should be equal    ${param_value}   ${value}
    [Return]  ${status}   ${value}

130X Update value in SCF
    [Documentation]  Update parameter in SCF
    ...  Arguments:
    ...     Root element of the SCF file
    ...     Distinguished name (MRBTS-Id/NRBTS-Id , MRBTS-Id/NRBTS-Id/NRCELL-Id..)
    ...     Name of the parameter
    ...     Target value of the parameter
    ...     If required, name of the list containing the parameters
    [Arguments]  ${xml_root}  ${dist_name}  ${param_name}  ${param_value}  ${list}=${EMPTY}
    ${xpath}=  set variable if
    ...  '${list}'=='${EMPTY}'  //managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ...  '${list}'!='${EMPTY}'  //managedObject[@distName="${dist_name}"]/list[@name="${list}"]//p[@name="${param_name}"]
    XML.Set Element Text  ${xml_root}  xpath=${xpath}  text=${param_value}
    Append To File   ${suite_dir}/result.txt   \n\t\t\tUpdate parameter in SCF: ${param_name}

