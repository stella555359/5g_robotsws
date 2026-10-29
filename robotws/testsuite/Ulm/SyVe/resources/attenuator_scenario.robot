*** Settings ***
Documentation   KWs related to handover scenario

Library           OperatingSystem
Library           XML    lxml=TRUE
Library           String
Library           Collections
Library           python_libs/attenuator_scenario.py   WITH NAME  att_scen_py
Library           Telnet
Library           taf.hw.rf_attenuator
Resource          ../../resources/Common/connect.robot
Resource          ../../resources/Common/testline.robot
Resource          attenuator.robot


*** Keywords ***
Register All Attenuators
    [Documentation]
    ...    setup all attenuators defined in init file if not already done
    ...    aliases are stored in 'P_attenuators'  dict defined in attenuator.robot

    ${attenuator_counter}=  Get length  ${tl.attenuators}

    FOR  ${i}  IN RANGE  ${0}  ${attenuator_counter}
        ${existing_attenuator_device}=    Check if attenuator is already setup
        ...    attenuator_ip=${tl.attenuators[${i}].ip_addr}
        ${attenuator_device}=    IF    '${existing_attenuator_device}'=='None'  taf.hw.rf_attenuator.setup_attenuator
        ...                                         attenuator=${tl.attenuators[${i}]}
        ...                                         alias=attenuator_device
        ...                                  ELSE
        ...                                         Set variable    ${existing_attenuator_device}
        IF    '${existing_attenuator_device}'=='None'    Collections.Set To Dictionary    ${P_attenuators}
        ...    ${tl.attenuators[${i}].ip_addr}=${attenuator_device}
        TRY
            Log  Setting preattenuation for ATT-IP ${tl.attenuators[${i}].ip_addr}  console=${P_console}
            attenuator_scenario.Set Pre Attenuation Values  ${tl.attenuators[${i}].ip_addr}
        EXCEPT
            Log  Setting preattenuation values not possible for ATT-IP ${tl.attenuators[${i}].ip_addr}  level=WARN  console=${P_console}
        END
    END
    Log Dictionary  ${P_attenuators}


Set Pre Attenuation Values
    [Arguments]   ${att_ip}
    [Documentation]
    ...    upload pre defined damping values to attenuator to harmonize tests
    ...   | att_ip | ip address of attenuator |

    Set Test Variable    ${PreAtt_path}    /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/preAtt
    ${tl_name}=     testline.Get Testline Name
    ${file}    OperatingSystem.Get Binary File    ${PreAtt_path}/${tl_name}/preAtt_${att_ip}.txt
    @{read}    Create List    ${file}
    ${firstLine}    String.Get Line    @{read}    0    # Read the number of attenuator ports, which is stated in the first line of the file.
    @{lines}    String.Split To Lines    @{read}    2    # Get the third line from the file.
    @{preAttValues}    String.Split String    @{lines}    # Inser the values from the third line into a list.
    Telnet.Open Connection    ${att_ip}    23
    Telnet.Login    USER 8    ${EMPTY}    UserName:    ${EMPTY}
    Telnet.Set Prompt    Radio Rack\>    True
    ${port_length}=    Set Variable If
    ...    '${firstLine}'=='16-16'    16
    ...    '${firstLine}'=='32-32'    32
    FOR    ${port}    IN RANGE    0    ${port_length}
        Telnet.Execute Command    PREATT ${port+1} ${preAttValues}[${port}]
    END
    ${output}=    Telnet.Write    PREATT
    Log  telnet output: ${output}  console=${P_console}


Run Attenuator Scenario By Cell
    [Arguments]    ${att_file}    ${scenario}    ${wait_time}=500ms
    [Documentation]
    ...    set attenator ports according defined scenario
    ...    scenario file syntax:
    ...    SECTION test
    ...    gnb0_1  = (1,0) (10,30) (20,30) (40,50)
    ...    gnb1_2  = (1,0) (10,100)
    ...    with gnb0_1 means <node_type><node_id>_<cellid>
    ...    corresponding attenenuator-device and ports are taken from KW: Get Cell Attenuator Port Mapping
    ${blocks}=    att_scen_py.read_att_section    ${att_file}    ${scenario}
    ${number_of_blocks}=    Get Length    ${blocks}
    FOR    ${step_index}    IN RANGE    0    ${number_of_blocks}    1
      set att per cell per step  ${blocks}[${step_index}]    ${wait_time}
    END


Set Att Per Cell Per Step
    [Arguments]    ${step}    ${wait_time}
    [Documentation]
    ...    sets all attenuator ports in one scenario step
    ...    | step      |  single scenario step |
    ...    | wait_time |  time to wait between steps |
    ${block_length}=    Get length    ${step}
    FOR    ${index}    IN RANGE    0    ${block_length}    1
        ${elements}=    String.Split String    ${step}[${index}]    :
        ${node}  ${cell}=      String.Split String    ${elements[0]}  _
        ${ports_per_node}  get variable value  ${PORTS_${node}}
        set att per cell per step per port  ${ports_per_node[${cell}]}  ${elements[1]}
    END
    Sleep  ${wait_time}


Set Att Per Cell Per Step Per Port
   [Arguments]    ${param_1}  ${param_2}
   [Documentation]
    ...    sets all attenuator ports in one scenario step for one cell
    ...    | param_1 | dict entry with all related ports per cell |
    ...    | param_2 | attenuator value to set per port |
    @{ports_list}   Create List
    @{values_list}  Create List
    ${value}  Convert To Integer  ${param_2}
    FOR  ${i}  IN  @{param_1}
        Append To List  ${ports_list}  ${i.port_no}
        Append To List  ${values_list}  ${value}
    END
    ${device}=  Collections.Get From Dictionary  ${P_attenuators}  ${param_1[0].attenuator.ip_addr}
    taf.hw.rf_attenuator.Set Ports Attenuation  ${ports_list}  ${values_list}  attenuator_device=${device}


Set Att Per Cell Per Step Per Single Port
    [Arguments]    ${param_1}  ${param_2}
    [Documentation]
    ...    sets all attenuator ports in one scenario step for one cell
    ...    | param_1 | dict entry with all related ports per cell |
    ...    | param_2 | attenuator value to set per port |
    FOR  ${i}  IN  @{param_1}
      ${device}=  Collections.Get From Dictionary  ${P_attenuators}  ${i.attenuator.ip_addr}
      ${value}  Convert To Integer  ${param_2}
      taf.hw.rf_attenuator.Set Attenuation            port=${i.port_no}  value=${value}  attenuator_device=${device}
    END


Prepare Scenario File
    [Documentation]
    ...   replaces variables, doubles scell lines if necessary
    ...   | source_node_id        | node to start |
    ...   | source_p_cell         | cell to start |
    ...   | target_node_id        | node to stop |
    ...   | target_p_cell         | cell to stop |
    ...   | source_node_type      | enb or gnb |
    ...   | target_node_type      | enb or gnb |
    ...   | source_s_cell         | s_cells in HO source, might be a comma seperated list (e.g. 1,2,3,4) |
    ...   | target_s_cell         | s_cells in HO target, might be a comma seperated list |
    ...   | scenfile | attenuator scenario with parametrized ports |
    ...   parametrized scenario file has to be following form:
    ...   SECTION  TEST
    ...       ${source_node_type}${source_node_id}_${source_p_cell} = (1,60)  (20,20) ..
    ...       ${source_node_type}${source_node_id}_${source_s_cell} = (1,60)  (20,20) ..
    ...       ${target_node_type}${target_node_id}_${target_p_cell} = (1,20)  (20,60) ..
    ...       ${target_node_type}${target_node_id}_${target_s_cell} = (1,20)  (20,60) ..
    [Arguments]  ${scenfile}  ${source_node_id}  ${source_node_type}  ${source_p_cell}
    ...          ${source_s_cell}  ${target_node_id}  ${target_node_type}  ${target_p_cell}  ${target_s_cell}
    ${template}=  OperatingSystem.Get File  ${scenfile}
    OperatingSystem.Remove File  ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt
    @{lines}  string.split to lines  ${template}
    FOR  ${i}  IN  @{lines}
      ${scellline}   evaluate  "source_s_cell" in """${i}"""
      ${tscellline}  evaluate  "target_s_cell" in """${i}"""
      IF   ${tscellline}  double target_scell lines  ${i}  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
      ...          ${source_node_type}  ${target_node_type}  ${source_s_cell}  ${target_s_cell}
      ...    ELSE IF   ${scellline}  double source_scell lines  ${i}  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
      ...          ${source_node_type}  ${target_node_type}  ${source_s_cell}  ${target_s_cell}
      ...    ELSE      replace variables in line  ${i}  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
      ...          ${source_node_type}  ${target_node_type}  ${source_s_cell}  ${target_s_cell}
    END
    RETURN  ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt


Replace Variables In Line
  [Documentation]
  ...  replaces variables in given line, writes the result to attenuator file
  ...  used internally
  ...
  # robocop: off=unused-argument
  [Arguments]  ${line}  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
  ...          ${source_node_type}  ${target_node_type}  ${source_s_cell}  ${target_s_cell}
  ${j}    Replace Variables  ${line}
  OperatingSystem.Append to file    ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt    ${j}\n


Double Source_scell Lines
  [Documentation]
  ...  splits s_cell variable into single entries
  ...  doubles scell line and replaces variables
  ...  writes the result to attenuator file
  ...  used internally
  ...
  # robocop: off=unused-argument
  [Arguments]  ${line}  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
  ...          ${source_node_type}  ${target_node_type}  ${source_s_cell}  ${target_s_cell}
  IF  '${source_s_cell}' == '${EMPTY}'   RETURN
  ${cells}  split string  ${source_s_cell}  ,
  log to console  scells: ${cells}
  FOR  ${i}  IN  @{cells}
     ${source_s_cell}  Set Variable  ${i}   # robocop: off=unused-variable,possible-variable-overwriting
     ${j}       Replace Variables  ${line}
     OperatingSystem.Append to file    ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt   ${j}\n
  END


Double Target_scell Lines
  [Documentation]
  ...  splits target_s_cell variable into single entries
  ...  doubles scell line and replaces variables
  ...  writes the result to attenuator file
  ...  used internally
  ...
  # robocop: off=unused-argument
  [Arguments]  ${line}  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
  ...          ${source_node_type}  ${target_node_type}  ${source_s_cell}  ${target_s_cell}
  IF  '${target_s_cell}' == '${EMPTY}'   RETURN
  ${cells}  split string  ${target_s_cell}  ,
  FOR  ${i}  IN  @{cells}
     ${target_s_cell}  set variable  ${i}   # robocop: off=unused-variable
     ${j}              Replace Variables  ${line}
     OperatingSystem.Append to file    ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt    ${j}\n
  END


Prepare Single Scenario File
    [Documentation]
    ...    extract a single scenario from scenario file and replace the variables in this scenario
    ...    this is meant for special variants which are not covered by default "prepare scenario file" KW
    [Arguments]  ${scenfile}  ${scenario}
    ${single_scenario}=  att_scen_py.extract_section  ${scenfile}  ${scenario}
    ${scenario_replaced}=  replace variables  ${single_scenario}
    OperatingSystem.Append To File  ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  SECTION ${scenario}\n
    OperatingSystem.Append To File  ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  ${scenario_replaced}
    RETURN  ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt


Get ANTL Id
    [Documentation]
    ...    internal KW to get the attenuator ports dedicated to specific antenna lines
    ...    arguments derived from "Get Cell Attenuator Port Mapping" KW
    ...
    [Arguments]     ${cell_info}  ${ports}  ${rmod_real}  ${node_id}  ${node_type}
    ${antenna_line_configs}=  Evaluate    list(set([(x["antennaLineId"]["configuration"]) for x in ${cell_info}[carrierList]]))
    IF  ${{ len(${antenna_line_configs})==1 }}  #special handling for phyant
        ${antennas}=  Set Variable  ${tl.${node_type}s[${node_id}].dus[0].rus[${rmod_real}].attenuation_ports}
    ELSE
        ${antennas}=   Create List
        FOR  ${i}  IN  @{antenna_line_configs}
            ${__}  ${antl}=  String.Split String From Right  ${i}  -  1
            ${att_port}=  Evaluate  ${antl} - 1
            IF    '${node_type}'=='gnb'
                 ${ant_port}=   Get Variable Value  ${tl.${node_type}s[${node_id}].dus[0].rus[${rmod_real}].attenuation_ports[${att_port}]}
                 ...   port not defined
            ELSE
                 ${ant_port}=   Get Variable Value  ${tl.${node_type}s[${node_id}].rms[${rmod_real}].attenuation_ports[${att_port}]}
                 ...   port not defined
            END
            IF  '${ant_port}' != 'port not defined'  Append To List  ${antennas}  ${ant_port}
        END
    END
    ${antenna_ports}=  Collections.Remove Duplicates  ${antennas}
    Collections.Set To Dictionary  ${ports}  ${cell_info}[globalCellId]  ${antenna_ports}
    RETURN  ${antenna_ports}


Get Cell Attenuator Port Mapping
    [Documentation]
    ...    The kw determines the radio modules for the given cell an the related Attenuator Ports
    ...    cell type: NRCEL, LNCEL
    [Arguments]       ${node_id}=0   ${node_type}=gnb
    ${ports}  Create Dictionary
    ${oam_alias}   connect.Setup OAM HTTP Session   node_type=${node_type}   node_id=${node_id}
    ${node_type}    Convert To Lower Case    ${node_type}
    ${class}    Set Variable If    '${node_type}'=='gnb'    NRCEL   LNCEL
    ${list_cells}   testline.Get All Ids Of Class   alias=${oam_alias}   class=${class}
    FOR   ${cell}    IN   @{list_cells}
        ${cell_info}=    admin.get_cell_specific_info   cell_id=${cell}   connection=${oam_alias}
        ${rmod_list}=        Evaluate    list(set([os.path.dirname(x["antennaLineId"]["configuration"]) for x in ${cell_info}[carrierList]]))    os
        ${__}  ${rmod}=  String.Split String From Right  ${rmod_list}[0]  RMOD-  1
        ${rmod_real}=  Evaluate  ${rmod} - 1
        Get ANTL ID  ${cell_info}  ${ports}  ${rmod_real}  ${node_id}  ${node_type}
    END
    Log Dictionary   ${ports}
    Set Suite Variable  ${PORTS_${node_type}${node_id}}  ${ports}


Set Cell Attenuation
    [Documentation]
    ...   Sets all attenuator ports for given cell to to given value
    ...   | globalcellid | cellid given in scf |
    ...   | value        | attenuator port value to be set |
    ...   | node_id      | enb/gnb number like given in testline_configuration |
    [Arguments]  ${globalcellid}  ${value}  ${node_id}=0  ${node_type}=gnb
    ${globalcellid}  Convert To Integer  ${globalcellid}
    ${value}  Convert To Integer  ${value}
    ${node_type}    Convert To Lower Case    ${node_type}
    ${ports_per_node}  Get Variable Value  ${PORTS_${node_type}${node_id}}
    Set Att Per Cell Per Step Per Port  ${ports_per_node[${globalcellid}]}  ${value}


Log Att Per Cell
    [Arguments]    ${param_1}
    [Documentation]
    ...    read actual attenuator values for one cell
    ...    | param_1 | dict entry with all related ports per cell |
    FOR  ${i}  IN  @{param_1}
      ${device}=  Collections.Get From Dictionary  ${P_attenuators}  ${i.attenuator.ip_addr}
      ${read}  taf.hw.rf_attenuator.read_attenuation  port=${i.port_no}  attenuator_device=${device}
      Log To Console  ---ATT_PORT: ${i.port_no} VALUE: ${read}
    END


Log Cell Attenuation
    [Documentation]
    ...   Reads actual attenuator values for given cell
    ...   | globalcellid | cellid given in scf |
    ...   | node_id      | enb/gnb number like given in testline_configuration |
    [Arguments]  ${globalcellid}  ${node_id}=0  ${node_type}=gnb
    ${globalcellid}  convert to integer  ${globalcellid}
    ${node_type}    Convert to lower case    ${node_type}
    ${ports_per_node}  get variable value  ${PORTS_${node_type}${node_id}}
    Log Att Per Cell  ${ports_per_node[${globalcellid}]}


Execute HO With Scenario
    [Documentation]
    ...   starts predefined attenuation scenario
    ...   | source_node_id         | node to start |
    ...   | source_p_cell          | cell to start |
    ...   | target_node_id         | node to stop |
    ...   | target_p_cell          | cell to stop |
    ...   | source_s_cell=EMPTY    | scells to start (optional) |
    ...   | target_s_cell=EMPTY    | scell to stop (optional) |
    ...   | source_node_type=gnb   | optional |
    ...   | target_node_type=gnb   | optional |
    ...   | scenario=SEN1          | scenario to execute |
    ...   | scenfile=CURDIR/att_scen.txt | file with listed scenarios |
    ...   scells can be a comma seperated list of cells
    [Arguments]  ${source_node_id}  ${source_p_cell}  ${target_node_id}  ${target_p_cell}
    ...          ${source_s_cell}=${EMPTY}  ${target_s_cell}=${EMPTY}  ${source_node_type}=gnb
    ...          ${target_node_type}=gnb  ${scenario}=SEN1  ${scenfile}=${CURDIR}/att_scen.txt
    log to console  Execute HO from \n ${source_node_type}${source_node_id}: p_cell ${source_p_cell}, s_cell ${source_s_cell} to\n
    log to console  ${target_node_type}${target_node_id}: p_cell ${target_p_cell}, s_cell ${target_s_cell}
    register all attenuators
    ${single_scenario}=  att_scen_py.extract_section  ${scenfile}  ${scenario}
    OperatingSystem.Remove File  ${P_resultSuiteBaseDir}/att_scen_${scenario}.txt
    OperatingSystem.Create File  ${P_resultSuiteBaseDir}/att_scen_${scenario}.txt  ${scenario}\n${single_scenario}
    prepare scenario file  ${P_resultSuiteBaseDir}/att_scen_${scenario}.txt  ${source_node_id}  ${source_node_type}  ${source_p_cell}
    ...          ${source_s_cell}  ${target_node_id}  ${target_node_type}  ${target_p_cell}  ${target_s_cell}
    run attenuator scenario by cell    att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt   scenario=${scenario}
#
# OLD, has to stay during transformation, will be deleted afterwards
#
Prepare Scenfile
    [Documentation]  [DEPRECATED]
    ...   OLD VERSION, WILL BE REMOVED AFTER REFACTOR PHASE
    ...   replaces variables, doubles scell lines if necessary
    ...   | ${scenfile} | attenuator scenario with parametrized ports |
    ...   | ${s_cell} | s_cells in HO source, might be a comma seperated list (e.g. 1,2,3,4) |
    ...   | ${target_s_cell} | s_cells in HO target, might be a comma seperated list |
    ...   parametrized scneario file has to be following form:
    ...   SECTION  TEST
    ...       gnb${gnb_id}_${p_cell}                 =   (1,60)  (20,20) ..
    ...       gnb${gnb_id}_${s_cell}                 =   (1,60)  (20,20) ..
    ...       gnb${target_gnb_id}_${target_p_cell}   =   (1,20)  (20,60) ..
    ...       gnb${target_gnb_id}_${target_s_cell}   =   (1,20)  (20,60) ..
    [Arguments]  ${scenfile}  ${s_cell}   ${target_s_cell}
    ${template}=  OperatingSystem.Get File  ${scenfile}
    OperatingSystem.Remove File  ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt
    @{lines}  string.split to lines  ${template}
    FOR  ${i}  IN  @{lines}
      ${scellline}   evaluate  "s_cell" in """${i}"""
      ${tscellline}  evaluate  "target_s_cell" in """${i}"""
      IF   ${tscellline}  double t_scell lines  ${i}  ${target_s_cell}
      ...    ELSE IF   ${scellline}  double scell lines  ${i}  ${s_cell}
      ...    ELSE      replace vars in line  ${i}
    END


Replace Vars In Line
  [Documentation]  [DEPRECATED]
  ...  replaces variables in given line, writes the result to attenuator file
  ...  used internally
  [Arguments]  ${line}
  ${j}    Replace Variables  ${line}
  OperatingSystem.Append to file    ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt    ${j}\n


Double SCell Lines
  [Documentation]  [DEPRECATED]
  ...  splits s_cell variable into single entries
  ...  doubles scell line and replaces variables
  ...  writes the result to attenuator file
  ...  used internally
  [Arguments]  ${line}  ${scell}
  ${cells}  split string  ${scell}  ,
  FOR  ${i}  IN  @{cells}
     ${s_cell}  Set Variable  ${i}   # robocop: off=unused-variable,possible-variable-overwriting
     ${j}       Replace Variables  ${line}
     OperatingSystem.Append To File    ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt   ${j}\n
  END


Double t_scell Lines
  [Documentation]  [DEPRECATED]
  ...  splits target_s_cell variable into single entries
  ...  doubles scell line and replaces variables
  ...  writes the result to attenuator file
  ...  used internally
  [Arguments]  ${line}  ${tscell}
  ${cells}  split string  ${tscell}  ,
  FOR  ${i}  IN  @{cells}
     ${target_s_cell}  Set Variable  ${i}   # robocop: off=unused-variable
     ${j}              Replace Variables  ${line}
     OperatingSystem.Append to file    ${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt    ${j}\n
  END


Run Attenuator Scenario
    [Arguments]    ${att}    ${att_file}    ${scenario}    ${wait_time}=500ms
    [Documentation]  [DEPRECATED]
    ...    Input Parameters:
    ...    | ${att}        | Attenuator name as defined in hosts file or ip address |
    ...    | ${att_file}   | File in which the attenuator scenarios are defined |
    ...    | ${scenario}   | specifies the scenario to run |
    ...    | ${wait_time}  | wait time between instances (optional) |
    ...    implementation of pegasus functionality:
    ...    takes a attenuator file with syntax:
    ...    SECTION test
    ...    CH1  = (1,0) (10,30) (20,30) (40,50)
    ...    CH2  = (1,0) (10,100)
    ...    (same syntax as used with pegasus)
    ${result}=    att_scen_py.read_att_section    ${att_file}    ${scenario}
    ${number_of_blocks}=    Get Length    ${result}
    FOR    ${step_index}    IN RANGE    0    ${number_of_blocks}    1
        Set Physical Blocks    ${att}  ${result}[${step_index}]    ${wait_time}
    END


Set Physical Blocks
    [Arguments]    ${att}  ${step}    ${wait_time}
    [Documentation]  [DEPRECATED]
    ...    sets all Attenuator channels on channel-list for given step
    ...    necessary keyword for 'run attenuator scenario'
    ...    for each step set all defined attenuator blocks
    ${block_length}=    Get length    ${step}
    FOR    ${index}    IN RANGE    0    ${block_length}    1
        @{elements}=    String.Split String    ${step}[${index}]    :
        ${channel}=    Collections.Get From List    ${elements}    0
        ${channel_nbr}=    String.Get Substring    ${channel}    2
        ${channel_nbr}=  Convert to integer  ${channel_nbr}
        ${value}=    Collections.Get From List    ${elements}    1
        ${value}=  Convert to integer  ${value}
        taf.hw.rf_attenuator.set_attenuation  port=${channel_nbr}  value=${value}  attenuator_device=${att}
    END
    Sleep    ${wait_time}


Get RuntimeObjects From GNB With COAM
    [Documentation]  [DEPRECATED]
    ...    Gets runtime objects from gNB
    ...    | ${gnbScfName}       | stored scf-filename |
    ...    | ${resultConfigDir}  | dir where scf file is stored |
    ...    | node_id             | Id of nodeB as index of list in testline configuration |
    ...
    [Arguments]     ${gnbScfName}    ${resultConfigDir}     ${node_id}=${0}  ${with_auto_configured_parameters}=${True}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}
    admin.Get Current SCF File    local_dir_path=${resultConfigDir}
    ...                           file_name=${gnbScfName}
    ...                           timeout=${30}
    ...                           connection=${oam_alias}
    ...                           export_type=runtimeObjects
    ...                           with_auto_configured_parameters=${with_auto_configured_parameters}


Get GNB Cell Mapping
    [Documentation]  [DEPRECATED]
    ...    with full scf file (including runtime)  KW gets mapping between
    ...    global cell id and RMOD_R (=RU)  / BBMOD (=DU)
    ...    | node_id    |  Id of gNB|eNB [0.. ]  default=0 |
    ...    |scf_file    |  scf file with running part |
    ...    take care that RU configuration maps to the RU list in init file....
    ...
    [Arguments]    ${scf_file}  ${node_id}=${0}
    ${RMOD}  create dictionary
    ${BBMOD}  create dictionary
    ${RMOD_R}  create dictionary
    ${PORTS}  create dictionary

    ${bar}  xml.parse xml  ${scf_file}
    ${RMOD_R_mapping}  xml.get elements   ${bar}  .//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    FOR  ${j}  IN  @{RMOD_R_mapping}
      ${related_RMOD}  xml.get element  ${j}  *[@name="configDN"]
      ${_}  ${RMOD_R_id}  String.Split String From Right  ${j.attrib["distName"]}  -  1
      ${_}  ${RMOD_id}    String.Split String From Right  ${related_RMOD.text}     -  1
      ${RMOD_R_id}  convert to integer  ${RMOD_R_id}
      ${RMOD_id}    convert to integer  ${RMOD_id}
      Collections.Set To Dictionary  ${RMOD_R}  ${RMOD_id}   ${RMOD_id}
    END
    log dictionary  ${RMOD_R}
    ${cellmapping}   xml.get elements  ${bar}  .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    FOR  ${i}  IN  @{cellmapping}
      ${frRefList}   xml.get element  ${i}  *[@name="frRefList"]
      ${frRef_item}  xml.get element  ${frRefList}  *
      ${modDNList}   xml.get element  ${i}  *[@name="modDNList"]
      ${modDN_item}  xml.get element  ${modDNList}  *
      ${_}  ${celid}     String.Split String From Right  ${i.attrib["distName"]}  -  1
      ${_}  ${frRes_id}  String.Split String From Right  ${frRef_item.text}       -  1
      ${_}  ${modDN_id}  String.Split String From Right  ${modDN_item.text}       -  1
      ${globalcelid}  convert to integer  ${celid}
      ${frRes_id}     convert to integer  ${frRes_id}
      ${frRes_real}  evaluate  ${RMOD_R[${frRes_id}]} - 1
      ${modDN_id}    evaluate  ${modDN_id} - 1
      Collections.Set To Dictionary  ${RMOD}   ${globalcelid}  ${frRes_real}
      Collections.Set To Dictionary  ${BBMOD}  ${globalcelid}  ${modDN_id}
      #actually only du=0 is possible in init file
      Collections.Set To Dictionary  ${PORTS}  ${globalcelid}  ${tl.gnbs[${node_id}].dus[0].rus[${frRes_real}].attenuation_ports}
    END
    log dictionary   ${RMOD}
    log dictionary   ${BBMOD}
    log dictionary   ${PORTS}
    Set Suite Variable  ${RU_gNB${node_id}}  ${RMOD}
    Set Suite Variable  ${DU_gNB${node_id}}  ${BBMOD}
    Set Suite Variable  ${PORTS_gNB${node_id}}  ${PORTS}
