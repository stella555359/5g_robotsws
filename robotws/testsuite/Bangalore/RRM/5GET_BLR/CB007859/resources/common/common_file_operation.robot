*** Keywords ***
Modify Wts Cfg File Content
    [Arguments]    ${cfg_file_path}    ${old_patterns_list}    ${new_patterns_list}
    [Documentation]    This keyword is to modify wts cfg file content according old and new parameres
    ...    offered by case owner
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cfg_file_path} | Yes | cfg file located |
    ...    | ${old_patterns_list} | Yes | a list contains paras patterns needed modify |
    ...    | ${new_patterns_list} | Yes | a list contains new paras after modified |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${CFG_FILE} | basic_fullstack_nsa_call_tdd_cmwv.cfg |
    ...    | @{CFG_OLD_PATTERNS} | plmn=[0-9]+:[0-9]+ | nr_arfcn=[0-9]+:[0-9]+ |
    ...    | @{CFG_NEW_PATTERNS} | plmn=302:610 | nr_arfcn=628333:628333 |
    ...
    ...    | Modify Wts Cfg File Content | ${CFG_FILE} | ${CFG_OLD_PATTERNS} | ${CFG_NEW_PATTERNS} |
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_file_path}
    FOR    ${old_val}    ${new_val}    IN ZIP    ${old_patterns_list}    ${new_patterns_list}
         ${content}    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${old_val}
    ...    replace_with=${new_val}
    END
    OperatingSystem.Create File    path=${cfg_file_path}    content=${content}

Delete Wts Cfg File Content
    [Arguments]    ${cfg_file_path}    ${patterns_list}
    [Documentation]    This keyword is to delete required wts cfg file content.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cfg_file_path} | Yes | cfg file located |
    ...    | ${patterns_list} | Yes | a list contains paras patterns needed delete |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${CFG_FILE} | basic_fullstack_nsa_call_tdd_cmwv.cfg |
    ...    | @{CFG_DELETE_CONTENT_PATTERNS} | mme_pool_area.* | set_mme.* |
    ...
    ...    | Delete Wts Cfg File Content | ${cfg_file_path} | ${CFG_DELETE_CONTENT_PATTERNS} |
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_file_path}
    ${content}    String.Remove String Using Regexp    ${content}    @{patterns_list}
    OperatingSystem.Create File    path=${cfg_file_path}    content=${content}

Add Wts Cfg File UE Numbers
    [Arguments]    ${cfg_file_path}    ${pdn_ip_list}    ${ue_nums}
    [Documentation]    This keyword is to add multiple UEs in cfg file.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cfg_file_path} | Yes | cfg file located |
    ...    | ${pdn_ip_list} | Yes | a list contains PDN_IP,eg: 4.7.254.208 |
    ...    | ${ue_nums} | Yes | UE nums used to control how many UE CONFIGURATION added  |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${CFG_FILE} | basic_fullstack_nsa_call_tdd_cmwv.cfg |
    ...    | @{PDN_IPS} | 4.7.254.208 | 4.7.254.203 | 4.7.254.204 |
    ...
    ...    | Add Wts Cfg File UE Numbers | ${CFG_FILE} | ${PDN_IPS} | 3 |
    ...
    Add Wts Cfg File PDN IPs    ${cfg_file_path}    ${pdn_ip_list}
    @{imsi}    Get Wts Cfg File Default IMSI    ${cfg_file_path}
    ${set_ue_cmd}    Get Wts Cfg File Command    ${cfg_file_path}    set_ue simulated.*
    ${ue_param_cmd}    Get Wts Cfg File Command    ${cfg_file_path}    ue_param.*
    ${set_bearer_cmd}    Get Wts Cfg File Command    ${cfg_file_path}    set_bearer.*
    ${total_add_cmd}    Set Variable    ${EMPTY}
    FOR    ${num}    IN RANGE    1    ${ue_nums}+1
         ${single_ue_cmd}    Get Single UE Add Command    ${set_ue_cmd}    ${ue_param_cmd}    ${set_bearer_cmd}    ${num}    ${imsi}
         ${total_add_cmd}    Catenate    SEPARATOR=\n    ${total_add_cmd}    ${single_ue_cmd}
    END
    @{del_patterns}    Create List    ue_param.*     set_bearer.*
    Delete Wts Cfg File Content    ${cfg_file_path}    ${del_patterns}
    @{old_patterns}    Create List    set_ue simulated.*
    @{new_patterns}    Create List    ${total_add_cmd}
    Modify Wts Cfg File Content    ${cfg_file_path}    ${old_patterns}    ${new_patterns}

Add Wts Cfg File PDN IPs
    [Arguments]    ${cfg_file_path}    ${pdn_ip_list}
    [Documentation]    This keyword is to add needed PDN_IPs in cfg file
    ${add_pdn_cmd}    Set Variable    ${EMPTY}
    FOR    ${index}    ${ip}    IN ENUMERATE    @{pdn_ip_list}
         ${set_pdn_ip}    Set Variable    set PDN_IP${index+1}="${ip}"
         ${add_pdn_cmd}    Catenate    SEPARATOR=\n    ${add_pdn_cmd}    ${set_pdn_ip}
    END
    ${old_patterns}    Create List    set PDN_IP[0-9]?=.*
    ${new_patterns}    Create List    ${add_pdn_cmd}
    Modify WTS Cfg File Content    ${cfg_file_path}    ${old_patterns}    ${new_patterns}

Get Single UE Add Command
    [Arguments]    ${set_ue_cmd}    ${ue_param_cmd}    ${set_bearer_cmd}    ${num}    ${imsi}
    [Documentation]    This keyword is to get single ue add commands contains set_ue, ue_param and set_bearer.
    ${val1}    ${val2}    ${val3}    Set Variable    @{imsi}
    ${val3}    Evaluate    ${val3}+${num}
    ${tmp1}    String.Replace String Using Regexp    ${set_ue_cmd}    id=[1-9]+    id=${num}
    ${tmp1}    String.Replace String Using Regexp    ${tmp1}    imsi=[0-9]+:[0-9]+:[0-9]+    imsi=${val1}:${val2}:${val3}
    ${tmp2}    String.Replace String Using Regexp    ${ue_param_cmd}    id=[1-9]+    id=${num}
    ${tmp3}    String.Replace String Using Regexp    ${set_bearer_cmd}    ue=[1-9]+    ue=${num}
    ${tmp3}    String.Replace String Using Regexp    ${tmp3}    ip=\\$PDN_IP[1-9]*   ip=$PDN_IP${num}
    ${single_ue_cmd}    Catenate    SEPARATOR=\n    \n#-----UE${num} CONFIGURATION -----    ${tmp1}    ${tmp2}    ${tmp3}
    [Return]    ${single_ue_cmd}

Get Wts Cfg File Default IMSI
    [Arguments]    ${cfg_file_path}
    [Documentation]    This keyword is to get default imsi values, eg: 250, 555, 21645405
    ${content}    OperatingSystem.Get File    path=${cfg_file_path}
    ${val1}    String.Get Regexp Matches    ${content}    imsi=([0-9]+):([0-9]+):([0-9]+)    1
    ${val2}    String.Get Regexp Matches    ${content}    imsi=([0-9]+):([0-9]+):([0-9]+)    2
    ${val3}    String.Get Regexp Matches    ${content}    imsi=([0-9]+):([0-9]+):([0-9]+)    3
    [Return]    @{val1}[0]    @{val2}[0]    @{val3}[0]

Get Wts Cfg File Command
    [Arguments]    ${cfg_file_path}    ${cmd_pattern}
    [Documentation]    This keyword is to get exact command in cfg file.
    ...    This keyword serves Add Wts Cfg File UE Numbers
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cfg_file_path} | Yes | wts cfg file located |
    ...    | ${cmd_pattern} | Yes | regular pattern for neede command |
    ...
    ...    Examples:
    ...    | ${cmd} | Get Wts Cfg File Command | basic_fullstack_nsa_call_tdd_cmwv.cfg | set_ue simulated.* |
    ...    | ${cmd} | Get Wts Cfg File Command | basic_fullstack_nsa_call_tdd_cmwv.cfg | ue_param.* |
    ...    | ${cmd} | Get Wts Cfg File Command | basic_fullstack_nsa_call_tdd_cmwv.cfg | set_bearer.* |
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_file_path}
    ${cmd}    String.Get Regexp Matches    ${content}    ${cmd_pattern}
    [Return]    ${cmd}[0]

Modify IPHY XML With New Optlinks
    [Arguments]    ${physical_ids}
    [Documentation]    This keyword is to modify iphy.xml to add multiple optlinks in <optlink_List>.
    ...    This keyword contains 3 steps:
    ...    1. Get IPHY XML file from Airphone
    ...    2. Add new optlinks
    ...    3. Send IPHY XML file back to Airphone
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${physical_ids} | Yes | physicalId list |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | @{PHYSICALL_ID} | 1.1 | 1.2 | 1.8 | 1.9 |
    ...
    ...     | Modify IPHY XML With New Optlinks | ${PHYSICALL_ID} |
    ...
    ${iphy_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Add Optlink In IPHY XML    ${iphy_path}    ${physical_ids}
    Send IPHY XML To Airphone    ${iphy_path}

Get IPHY XML From Airphone
    [Arguments]    ${save_dir}
    [Documentation]    This keyword is to get iphy.xml from Airphone, return file_path include name
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_dir} | Yes | where to save iphy.xml |
    ...
    ...    Examples:
    ...    | ${iphy_path} | Get IPHY XML From Airphone | ${OUTPUT_DIR} |
    ...
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy.xml ${save_dir}
    OperatingSystem.Should Exist    ${save_dir}/iphy.xml
    ${iphy_path}    Set Variable    ${save_dir}/iphy.xml
    [Return]    ${iphy_path}

Add Optlink In IPHY XML
    [Arguments]    ${iphy_path}    ${physical_ids}
    [Documentation]    This keyword is to add new optlink in optlink_List to support multi subcells test.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml path, eg: /home/ute/results/iphy.xml |
    ...    | ${physical_ids} | Yes | physicalId list |
    ...
    ...    Examples:
    ...    | *** Settings *** |
    ...    | Library | XML |
    ...
    ...    | *** Variables *** |
    ...    | @{PHYSICALL_ID} | 1.1 | 1.2 | 1.8 | 1.9 |
    ...
    ...    | Add Optlink In IPHY XML | /home/ute/iphy.xml | ${PHYSICALL_ID} |
    ...
    ${root}    XML.Parse Xml    ${iphy_path}
    ${base_optlink}    XML.Get Element    ${root}    .//optlink[1]
    XML.Remove Elements    ${root}    xpath=.//optlink    remove_tail=${True}
    FOR    ${index}    ${id}    IN ENUMERATE    @{physical_ids}
         ${index}    Convert To String    ${index + 1}
         XML.Set Element Text    ${base_optlink}    ${id}    xpath=physicalId
         XML.Set Element Text    ${base_optlink}    ${index}    xpath=virtualId
         XML.Add Element    ${root}    ${base_optlink}    xpath=.//optlink_List
    END
    XML.Save Xml    ${root}    ${iphy_path}

Send IPHY XML To Airphone
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ...
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/
    Should Be Equal As Integers    ${rc}    0

Send IPHY XML To Airphone New
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ...
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/new_iphy.xml
    Should Be Equal As Integers    ${rc}    0

Modify Text File
    [Arguments]    ${file_path}    ${old_params_list}    ${new_params_list}
    [Documentation]    This keyword is used for modifying Text file content, like .txt, .Cfg
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | file path, such as /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.Cfg |
    ...    | ${old_params_list} | Yes |  params list which need to be changed    https://www.runoob.com/regexp/regexp-syntax.html |
    ...    | ${new_params_list} | Yes |  new params list which corressponding to old params |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.Cfg |
    ...    | @{old_params_list} | Create List | plmn=[0-9]+:[0-9]+ | ue_nr_capabilities=[0-9a-zA-Z]+ |
    ...    | @{new_params_list} | Create List | plmn=302:610 | ${empty} |
    ...    | Modify Text File | ${file_path} | ${old_params_list} | ${new_params_list} |
    ...
    ...    Example 2:
    ...    | *** Variables *** |
    ...    | ${wts_cfg} | /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.Cfg |
    ...    | @{cfg_old_params} | plmn=[0-9]+:[0-9]+ | ue_nr_capabilities=[0-9a-zA-Z]+ |
    ...    | @{cfg_new_params} | plmn=302:610 | ${empty} |
    ...
    ...    | *** Keywords *** |
    ...    | Modify Text File | ${wts_cfg} | ${cfg_old_params} | ${cfg_new_params} |
    ${content}    OperatingSystem.Get File    path=${file_path}
    Log    ${content}
    FOR    ${patt}    ${value}    IN ZIP    ${old_params_list}    ${new_params_list}
         Log Many    ${patt}    ${value}
         ${content}=    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${patt}
    ...    replace_with=${value}
    END
    OperatingSystem.Create File    path=${file_path}    content=${content}

Modify UE Capabilities In CFG
    [Arguments]    ${file_path}    ${old_values_patts}    ${new_values}
    [Documentation]    This keyword is to modify default ue capabilities in xxx.cfg.
    ...    ${new_values} can cantain spaces to avoid more than 150 limitation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | str, file path, such as /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.cfg |
    ...    | ${old_values_patts} | Yes | list, such as: ue_nr_capabilities=[0-9a-zA-Z]+    ue_eutra_nr_capabilities=[0-9a-zA-Z]+ |
    ...    | ${new_values} | Yes | list, such as? ue_nr_capabilities=aaa    ue_eutra_nr_capabilities=bbb |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    ${WTS_CFG}                    /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.cfg
    ...    ${NR_CAPBAILITIES}            E1201000014F5A0302C00201404820D9C4C3E140C1360107FE618F28581C130
    ...    ...                           080C41000A0F88DAC31B47498A823F96524CA01105B260901831E31FF9863CA
    ...    ...                           160703878089C0270000841808DC9A1F00E41000000A41000002A41000004A4
    ...    ...                           94000069807C0DBCA9BC0CADD2000080001CB292803E016DF00B60083C00D008
    ...    @{UE_NR_CAPABILITIES_PATT}    ue_nr_capabilities=[0-9a-zA-Z]+    ue_eutra_nr_capabilities=[0-9a-zA-Z]+
    ...    @{UE_NR_CAPABILITIES_VAL}     ue_nr_capabilities=${NR_CAPBAILITIES}     ue_eutra_nr_capabilities=xxx
    ...
    ...    | Modify UE Capabilities In CFG | ${WTS_CFG} | ${UE_NR_CAPABILITIES_PATT} | ${UE_NR_CAPABILITIES_VAL} |
    ...
    ${content}    OperatingSystem.Get File    path=${file_path}
    Log    ${content}
    FOR    ${patt}    ${value}    IN ZIP    ${old_values_patts}    ${new_values}
         Log Many    ${patt}    ${value}
         ${value}    String.Remove String    ${value}    ${SPACE}
         ${content}=    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${patt}
    ...    replace_with=${value}
    END
    OperatingSystem.Create File    path=${file_path}    content=${content}

Modify XML File
    [Arguments]    ${file_path}    ${params_dict}    ${count}=-1
    [Documentation]    This Keywod Is Used For Modifying XML File Current Content With Give Items
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | file path, such as /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | ${params_dict} | Yes | items to be changed, use dict in robotframework |
    ...    | ${count} | Yes | replace times if there are many mathes items, default -1 means replace all |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | &{xml_params_dict} | Create Dictionary | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...    | Modify XML File | ${file_path} | ${xml_params_dict} |
    ...
    ...    Example 2:
    ...    | *** Variables *** |
    ...    | ${wts_ap_xml} | /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | &{xml_params_dict} | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...
    ...    | *** Keywords *** |
    ...    | Modify XML File | ${wts_ap_xml} | ${xml_params_dict} |
    Log Many    ${params_dict.keys()}    ${params_dict.values()}
    ${content}    OperatingSystem.Get File    path=${file_path}
    FOR    ${key}    ${val}    IN ZIP    ${params_dict.keys()}    ${params_dict.values()}
         Log Many    ${key}    ${val}
         ${content}    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=<${key}>.*</${key}>
    ...    replace_with=<${key}>${val}</${key}>
    ...    count=${count}
    END
    OperatingSystem.Create File    path=${file_path}    content=${content}

Add XML Items
    [Arguments]    ${file_path}    ${delta_xml_path}
    [Documentation]    This keyword is used for appending more elements in .Xml File
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | file path, such as /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | ${delta_path} | Yes | items need to be added, such as ../../delta.xml |
    ...    delta.xml format like below:
    ...    | <ulSinrTestModeConfig> |
    ...    | <ulSinrTestMode index="0"> |
    ...    | <sinrTargetSrs>100</sinrTargetSrs> |
    ...    | <sinrTargetPusch>50</sinrTargetPusch> |
    ...    | <sinrTargetPucch>100</sinrTargetPucch> |
    ...    | <sinrTargetPreamble>100</sinrTargetPreamble> |
    ...    | </ulSinrTestMode> |
    ...    | <ulSinrTestMode index="1"> |
    ...    | <sinrTargetSrs>100</sinrTargetSrs> |
    ...    | <sinrTargetPusch>100</sinrTargetPusch> |
    ...    | <sinrTargetPucch>100</sinrTargetPucch> |
    ...    | <sinrTargetPreamble>100</sinrTargetPreamble> |
    ...    | </ulSinrTestMode> |
    ...    | </ulSinrTestModeConfig> |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | ${delta_xml_path} | Set Variable | /opt/iphy/latest/delta.xml |
    ...    | Add XML Items | ${file_path} | ${delta_xml_path} |
    ...
    ...    Example 2:
    ...    | *** Variables **** |
    ...    | ${xml_file_path} | /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | ${delta_xml_path} | opt/iphy/latest/delta.xml |
    ...
    ...    | *** Keywords *** |
    ...    | Add XML Items | ${xml_file_path} | ${delta_xml_path} |
    ${new_source}    XML.Add Element    source=${file_path}    element=${delta_xml_path}
    Log    ${new_source}
    XML.Save Xml    source=${new_source}    path=${file_path}

Add Xml Element
    [Arguments]    ${file_path}    ${name_list}    ${index_list}    ${xpath_list}
    [Documentation]    This Keywod Is Used For Adding Elements In Xml
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | The File Path And Name Which To Add Element, |
    ...    | ${name_list} | Yes | nama list is the element name which to add, such as <p name="linkSpeed">false</p> |
    ...    | ${index_list} | Yes | index is filter of index of distname "MRBTS-1900/EQM-1/HWTOP-1/CABLINK-2", such as 1 or 2... |
    ...    | ${xpath_list} | Yes | element node which to add, such as class="com.nokia.srbts.eqm:PHYANT" |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /home/lte/robotws5g/testsuite/RRM/Shanghai/training/tf/cmword/test.xml |
    ...    | @{name_list} | Create List | <p name="linkSpeed">false</p> | <p name="prodCodePlanned">474020A</p> |
    ...    | @{index_list} | Create List | 1 | 1 |
    ...    | @{xpath_list} | Create List | class="com.nokia.srbts.eqm:PHYANT" | class="com.nokia.srbts.eqm:CABINET" |
    ...    | Add Xml Element | ${file_path} | ${name_list} | ${index_list} | ${xpath_list} |
    ...
    ...    Example 2:
    ...    | *** Variables *** |
    ...    | ${file_path} | /home/lte/robotws5g/testsuite/RRM/Shanghai/training/tf/cmword/test.xml |
    ...    | ${name_list} | <p name="linkSpeed">false</p> | <p name="prodCodePlanned">474020A</p> |
    ...    | ${index_list} | 1 | 1 |
    ...    | @{xpath_list} | class="com.nokia.srbts.eqm:PHYANT" | class="com.nokia.srbts.eqm:CABINET" |
    ...
    ...    | *** Keywords *** |
    ...    | Add Xml Element | ${file_path} | ${name_list} | ${index_list} | ${xpath_list} |
    Log To Console    Start to add elements in ${file_path} xml file...
    ${xml}    XML.Parse XML    ${file_path}
    Log    ${xml}
    FOR    ${name}    ${index}    ${xpath}    IN ZIP    ${name_list}    ${index_list}    ${xpath_list}
         XML.Add Element    ${xml}    ${name}\n    index=${index}    xpath=.//*[@${xpath}]
         XML.Save Xml    ${xml}    ${file_path}

    END
Remove Xml Element
    [Arguments]    ${file_path}    ${xpath_list}
    [Documentation]    This Keywod Is Used For Removing Elements In Xml
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | The File Path And Name Which To Remove Element |
    ...    | ${xpath_list} | Yes | element name which to remove, such as class="com.nokia.srbts.eqm:PHYANT" |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /home/lte/robotws5g/testsuite/RRM/Shanghai/training/tf/cmword/test.xml |
    ...    | @{xpath_list} | Create List | class="com.nokia.srbts.eqm:PHYANT" | class="com.nokia.srbts.eqm:CABINET" |
    ...    | Remove Xml Element | ${file_path} | ${xpath_list} |
    ...
    ...    Example 2:
    ...    | *** Variables *** |
    ...    | ${file_path} | /home/lte/robotws5g/testsuite/RRM/Shanghai/training/tf/cmword/test.xml |
    ...    | @{xpath_list} | class="com.nokia.srbts.eqm:PHYANT" | class="com.nokia.srbts.eqm:CABINET" |
    ...
    ...    | *** Keywords *** |
    ...    | Remove Xml Element | ${file_path} | ${xpath_list} |
    ${xml}    XML.Parse XML    ${file_path}
    FOR    ${xpath}    IN ZIP    ${xpath_list}
         XML.Remove Element    ${xml}    xpath=.//*[@${xpath}]    remove_tail=True
         XML.Save Xml    ${xml}    ${file_path}

    END
Modify Swconfig File Parameters
    [Arguments]    ${path}    ${rd_parametrs}
    [Documentation]    This keyword is to append new RD parametes to the end of swconfig.txt or modify if RD already exists.
    ...    This keyword is excuted locally, not on gnb or airphone
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${path} | Yes | str, like: /home/ute/results/swconfig.txt |
    ...    | ${rd_parametrs} | Yes | str, like: 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ...    Examples:
    ...    | Modify Swconfig File Parameters | /home/ute/results/swconfig.txt | 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ${content}    OperatingSystem.Get File    ${path}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
         Continue For Loop If    '${item}'=='${EMPTY}'
         ${key}    ${val}    String.Split String    ${item}    =    1
         ${matches}    String.Get Regexp Matches    ${content}    (?m)^${key} ?= ?\\w+
         ${content}    Run Keyword If    len(${matches})>0    String.Replace String Using Regexp
    ...    ${content}    ${matches}[0]    ${key}=${val}    ELSE    Set Variable    ${content}\n${item}
    END
    OperatingSystem.Create File    ${path}    ${content}

Adapt Cfg File Nrafcn Value With Scf
    [Arguments]    ${cfg_file}
    [Documentation]    works on both TDD and FDD environment. For TDD, nrarfcn is enough, for FDD, nrarfcnDl and nrarfcnUl needed
    Backup Scf    ${OUTPUT_DIR}    running
    ${cell_type}    Get Single Value From Scf File    ${OUTPUT_DIR}/SCF_running.xml    MRBTS-1/NRBTS-1/NRCELL-1    cellTechnology
    ${val_tdd}    Run Keyword If    '${cell_type}'=='TDD'
    ...    Get Single Value From Scf File    ${OUTPUT_DIR}/SCF_running.xml    MRBTS-1/NRBTS-1/NRCELL-1    nrarfcn
    ${val_dl_fdd}    Run Keyword If    '${cell_type}'=='FDD'
    ...    Get Single Value From Scf File    ${OUTPUT_DIR}/SCF_running.xml    MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1    nrarfcnDl
    ${val_ul_fdd}    Run Keyword If    '${cell_type}'=='FDD'
    ...    Get Single Value From Scf File    ${OUTPUT_DIR}/SCF_running.xml    MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1    nrarfcnUl
    ${content}    OperatingSystem.Get File    ${cfg_file}
    ${nrarfcn_default}    String.Get Regexp Matches    ${content}    nr_arfcn=\\d+:\\d+
    ${content}    Run Keyword If    '${cell_type}'=='TDD'
    ...    String.Replace String Using Regexp    ${content}    nr_arfcn=\\d+:\\d+    nr_arfcn=${val_tdd}:${val_tdd}
    ...    ELSE    String.Replace String Using Regexp    ${content}    nr_arfcn=\\d+:\\d+    nr_arfcn=${val_ul_fdd}:${val_dl_fdd}
    OperatingSystem.Create File    ${cfg_file}    ${content}

Get IpAddr From Scf And Cfg
    ${ipaddr}=    Get Value From XML File By Class    ${OUTPUT_DIR}/SCF_running.xml    com.nokia.srbts.tnl:IPADDRESSV4    localIpAddr
    ${content}    OperatingSystem.Get File    ${WTS_DIR}/${WTS_CFG}
    ${x2_addr}    String.Get Regexp Matches    ${content}    GNB_X2_ADDR=".*?"|ENB2_X2_ADDR=".*?"
    Set Suite Metadata    localIpAddr in scfc    ${ipaddr}
    Set Suite Metadata    x2 addr in cfg file    ${x2_addr}

Change Testline From Fullstack To L1bypass
    ${gnb_pos}    Get GNB Position
    ${gnb_sh}    Set Variable    ${CURDIR}/scripts/shell/fs_to_l1b_gnb.sh ${gnb_pos}
    ${ap_sh}    Set Variable    ${CURDIR}/scripts/shell/fs_to_l1b_ap.sh
    Process.Run Process    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} <${gnb_sh}    shell=${True}
    Process.Run Process    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} <${ap_sh}    shell=${True}

Get Value From XML File By Class
    [Documentation]    this keyword is used to get para from XML file
    ...    for example:
    ...    distName=com.nokia.srbts.nrbts:NRCELL
    ...    para=actCDrx
    [Arguments]    ${file_path}    ${class}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=   XML.Get Element Text    ${xml}    .//managedObject[@class\="${class}"]/p[@name\="${para}"]
    [Return]    ${text}

Get Values From XML File By Class
    [Documentation]    this keyword is used to get para from XML file
    ...    for example:
    ...    distName=com.nokia.srbts.nrbts:NRCELL
    ...    para=actCDrx
    [Arguments]    ${file_path}    ${class}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=   XML.Get Elements Texts    ${xml}    .//managedObject[@class\="${class}"]/p[@name\="${para}"]
    [Return]    ${text}

Get Value From XML File By DistName
    [Documentation]    this keyword is used to get para from XML file
    ...    for example:
    ...    distName=MRBTS-1/NRBTS-1/NRCELL-1
    ...    para=actCDrx
    [Arguments]    ${file_path}    ${distName}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=    XML.Get Element Text    ${xml}    .//managedObject[@distName\="${distName}"]/p[@name\="${para}"]
    [Return]    ${text}

Get Value From XML File By List And DistName
    [Documentation]    this keyword is used to get para from XML file
    ...    for example:
    ...    distName=MRBTS-1/NRBTS-1/NRCELL-1
    ...    list=periodicCsiAcquisition
    ...    para=csiReportPeriodicity
    [Arguments]    ${file_path}    ${distName}    ${list}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=    XML.Get Element Text    ${xml}    .//managedObject[@distName\="${distName}"]/list[@name\="${list}"]/item/p[@name\="${para}"]
    [Return]    ${text}

Get Value From XML File By List And Class
    [Documentation]    this keyword is used to get para from XML file
    ...    for example:
    ...    className=com.nokia.srbts.nrbts:NRDSSLTE
    ...    list=periodicCsiAcquisition
    ...    para=csiReportPeriodicity
    [Arguments]    ${file_path}    ${className}    ${list}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=    XML.Get Element Text    ${xml}    .//managedObject[@class\="${className}"]/list[@name\="${list}"]/item/p[@name\="${para}"]
    [Return]    ${text}

#Get PhysCellId Of GNB
#    ${str}=    Get File    ${OUTPUT_DIR}/SCF_before_suite.xml
#    ${pci}=    get_regexp_matches    ${str}    <p name=\"physCellId\">(?P<pci>[0-9]+)</p>    pci
#    ${pci}=    Evaluate  map(int, $pci)
#    log to console    pci=${pci}
#    [Return]    ${pci}

Get PhysCellId Of GNB
    [Arguments]    ${scfc_file}=${OUTPUT_DIR}/SCF_before_suite.xml
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get PhysCellId Of GNB | /tmp/SCF.xml |
    ${pci}=    Get Values From XML File By Class    ${scfc_file}    com.nokia.srbts.nrbts:NRCELL    physCellId
    ${pci}=    Evaluate  map(int, $pci)
    Log To Console    pci=${pci}
    [Return]    ${pci}

Get PhysCellId Of GNB Runtime
    [Arguments]    ${scfc_file}=${OUTPUT_DIR}/SCF_before_suite.xml
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get PhysCellId Of GNB | /tmp/SCF.xml |
    Backup Scf    ${OUTPUT_DIR}    ttitrace
    ${pci}=    Get Values From XML File By Class    ${OUTPUT_DIR}/SCF_ttitrace.xml    com.nokia.srbts.nrbts:NRCELL    physCellId
    ${pci}=    Evaluate  map(int, $pci)
    Log To Console    pci=${pci}
    [Return]    ${pci}

Get localIpAddr Of GNB
    ${str}=    Get File    ${OUTPUT_DIR}/SCF_before_suite.xml
    ${localIpAddr}=    get_regexp_matches    ${str}    <p name=\"localIpAddr\">(?P<localIpAddr>.*?)</p>    localIpAddr
    Log To Console    localIpAddr=${localIpAddr}
    ${localIpAddr}=    Set Variable    ${localIpAddr}[0]
    [Return]    ${localIpAddr}

Get EIF Info Of Control PC
    ${ret}=    Run    ip addr
    ${eth0_ip}=    get_regexp_matches    ${ret}    inet (?P<eth0>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth0    eth0
    ${eth3_ip}=    get_regexp_matches    ${ret}    inet (?P<eth3>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3    eth3
    ${eth0_ip}=    Set Variable    ${eth0_ip}[0]
    ${eth3_ip}=    Set Variable If    "${eth3_ip}"=="[]"    none    ${eth3_ip}[0]
    Log To Console    eth0_ip=${eth0_ip},eth3_ip=${eth3_ip}
    ${web_card}=    Set Variable If    "${eth3_ip}"=="none"    eth0    eth3
    ${dest_ip}=    Set Variable If    "${web_card}"=="eth0"    ${eth0_ip}    ${eth3_ip}
    Log To Console    web_card=${web_card},dest_ip=${dest_ip}
    [Return]    ${web_card}    ${dest_ip}

Add Multi UE NSA
    [Arguments]    ${ue_ids}
    [Documentation]
    ...    Library    taf.wts.config
    ...   ue_ids=12 or ue_ids=12-13 or ue_ids=12-13,14
    taf.wts.config.Load Cfg    ${WTS_DIR}/${WTS_CFG}
    taf.wts.config.Add Ue    ${ue_ids}    uec=1        ue_type=NSA
    taf.wts.config.Save Cfg    ${WTS_DIR}/${WTS_CFG}

Add Multi UE SA
    [Arguments]    ${ue_ids}
    [Documentation]
    ...    Library    taf.wts.config
    ...    ue_ids=2 or ue_ids=2-3 or ue_ids=2-3,4
    taf.wts.config.Load Cfg    ${WTS_DIR}/${WTS_CFG}
    taf.wts.config.Add Ue    ${ue_ids}    uec=1    ue_type=SA
    taf.wts.config.Save Cfg    ${WTS_DIR}/${WTS_CFG}
#    taf.config.wts.Load Wts Cfg    ${WTS_DIR}/${WTS_CFG}
#    taf.config.wts.Modify    set_nwslice id=1    ue=1,${ue_ids}
#    taf.config.wts.Save Wts Cfg    ${WTS_DIR}/${WTS_CFG}
