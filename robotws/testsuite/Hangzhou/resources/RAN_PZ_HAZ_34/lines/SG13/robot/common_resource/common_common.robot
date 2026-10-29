*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library     OperatingSystem
Resource    common_gnb.robot
Library     DateTime
Library     ../../python/tak_files/
Library     ../../python/tak_files/tak_files/yaml_parser.py       WITH NAME    YAMLPARSER
Library     ../../python/tak_qc/tak_qc/qc_info_parser.py    WITH NAME    QC_PARSER

*** Variables ***
${WTS_CONFIG_PATH}     ${CURDIR}
${WTS_DIR}                      /opt/wts/latest
#${GOLDEN_CONFIG_ADDRESS}    "ssh://ca_ute_gerrit@gerrit.ext.net.nokia.com:29418/MN/5G/TEST/testconfigs"
${GOLDEN_CONFIG_ADDRESS}    "ssh://ca_ute_gerrit@gerrit-hzsl2.int.net.nokia.com:29418/MN/5G/TEST/testconfigs"
${TOPOLOGY_CONFIG_ADDRESS}    git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git
#${PRIVATE_CONFIG_ADDRESS}     "https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git"
${PRIVATE_CONFIG_ADDRESS}     "https://ningyang:glpat-Gc57V-d3z7wryJevYy2k@gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git"
${WTS_AP_XML_FULL_PATH}     ${EMPTY}
${GOLDEN_LOCAL_PATH}        /home/ute/kiss_files/golden/
${PRIVATE_LOCAL_PATH}        /home/ute/kiss_files/private/
${TOPOLOGY_LOCAL_PATH}        /home/ute/kiss_files/private/



*** Keywords ***
git check and clone
    [Arguments]    ${git_link}    ${local_save_path}
    ${date}    	Get Current Date   	result_format=datetime
    ${ret}    Run Keyword And Ignore Error     Directory Should Exist    ${local_save_path}
    ${run_ret}   Run Keyword If     '${ret[0]}'=='FAIL'    OperatingSystem.Run
    ...    rm -rf ${local_save_path};mkdir -p ${local_save_path};git clone ${git_link} ${local_save_path}
    ${time_info}     OperatingSystem.Run     ls --full-time ${local_save_path}
    Run Keyword If     '${ret[0]}'=='FAIL'     Return From Keyword
    ${timestampe}    Split To Lines      ${time_info}
    ${ret}   Run Keyword If     '${date.month}-${date.day}' not in '${timestampe[-1]}'   OperatingSystem.Run
    ...    rm -rf ${local_save_path};mkdir -p ${local_save_path};git clone ${git_link} ${local_save_path}

Download Topology Config Files From gerrit
    [Arguments]    ${local_save_path}=${TOPOLOGY_LOCAL_PATH}
    [Documentation]    This keyword is to Download Common Config Files From Private Server ${PRIVATE_CONFIG_ADDRESS}
    ...    and return markdown file full path
    ...    Examples:
    ...    | Download Common Config Files From Private Server| |
    ...    | Download Common Config Files From Private Server| /tmp/ |
    git check and clone      ${PRIVATE_CONFIG_ADDRESS}     ${local_save_path}
    ${topology_path}     set variable       ${testline_type}/${SW_VERSION}/${GNBCUTYPE}_${L1_TYPE}_${RF_TYPE}_${FR_TYPE}_${CELLTECHNOLOGY}
    ${topology_path}      evaluate      '${topology_path}'.upper()
    ${dic}    create_dictionary      AP_iphy_xml=${topology_path}/iphy.xml
    ...    AP_swconfig=${topology_path}/swconfig_ap.txt
    ...    WTS_config=${topology_path}/iphy.xml
    ...    gNB_CU_scf=${None}
    ...    gNB_DU_scf=${topology_path}/scfc.xml
    ...    gNB_swconfig=${topology_path}/swconfig_gnb.txt
    [Return]    ${dic}

Download Common Config Files From Private Server
    [Arguments]    ${local_save_path}=${PRIVATE_LOCAL_PATH}
    [Documentation]    This keyword is to Download Common Config Files From Private Server ${PRIVATE_CONFIG_ADDRESS}
    ...    and return markdown file full path
    ...    Examples:
    ...    | Download Common Config Files From Private Server| |
    ...    | Download Common Config Files From Private Server| /tmp/ |
    git check and clone      ${PRIVATE_CONFIG_ADDRESS}     ${local_save_path}

    [Return]    ${local_save_path}/capability/ue_capability.md

Download All Common Config Files From Golden Server
    [Arguments]    ${local_save_path}=${GOLDEN_LOCAL_PATH}
    [Documentation]    This keyword is to Download All Common Config Files From Golden Server
    ...    Examples:
    ...    | Download All Common Config Files From Golden Server |
    ${AP_BUILD}    OperatingSystem.Run    ls -l /opt/wts/ | grep latest
    ${AP_build_number}    String.Fetch From Right    ${AP_BUILD}    /opt/wts/
    OperatingSystem.Run    rm -rf ${local_save_path}
    OperatingSystem.Run    git clone ${GOLDEN_CONFIG_ADDRESS} ${local_save_path}
    OperatingSystem.Run    cd ${local_save_path}; git checkout tags/${AP_build_number}
    [Return]    ${local_save_path}

Find Match WTS CFG Files And Copy To WorkSpace
    [Arguments]    ${scfc_file}=${EMPTY}    ${iphy_file}=${EMPTY}   ${AP_configs_local_path}=${GOLDEN_LOCAL_PATH}
    ...            ${work_space_path}=${WTS_DIR}
    [Documentation]    This keyword is to find match WTS CFG files and copy To workspace
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_file} | No | scfc file, default ${EMPTY} where download SCF from GNB |
    ...    | ${iphy_file} | No | iphy.xml file, default ${EMPTY} |
    ...    | ${AP_configs_local_path} | No | local AP config path which download from golden server |
    ...    | ${work_space_path} | No | the directory will copy WTS CFG files destination, default: ${WTS_DIR} |
    ...    Examples:
    ...    | Find Match WTS CFG Files And Copy To WorkSpace | scfc.xml |
    ${nrbts_distname}=    Get NRBTS DistName    ${scfc_file}
    ${scfc_file_tmp}=    Run Keyword If    '${scfc_file}'=='${EMPTY}'    Backup Scf    /tmp
    ${scfc_file}=    Set Variable If    '${scfc_file}'=='${EMPTY}'    ${scfc_file_tmp}    ${scfc_file}
    ${gnb_cu_type}=    Get GNB Type    ${scfc_file}    ${nrbts_distname}
    ${celltechnology}=    Get CELL Technology    ${scfc_file}    ${nrbts_distname}
    ${fr}=    Get FR Type    ${scfc_file}   ${nrbts_distname}
    ${ru_type}=    Get RU Type    ${iphy_file}
    Run Keyword If     "${L1_TYPE}"=="${EMPTY}"    Get L1Bypass Type
    Run Keyword If     "${RF_TYPE}"=="${EMPTY}"    Get Radio Protocol Type    ${scfc_file}
    Run Keyword If     "${SW_VERSION}"=="${EMPTY}"    Get GNB Software Version
    Run Keyword If     "${FCT_BOARD_TYPE}"=="${EMPTY}"    Get Control Board Type
    Run Keyword If     "${ASP_BOARD_TYPE}"=="${EMPTY}"    Get Base Band Board Type
    ${config_yaml}=    Set Variable    ${AP_configs_local_path}/${SW_VERSION}/${gnb_cu_type}/${L1_TYPE}/config.yaml
    ${dic}=    YAMLPARSER.Parse Yaml    file_name=${config_yaml}
    ...    duplex=${celltechnology}
    ...    FH_mode=${RF_TYPE}
    ...    RF_mode=${fr}
    ...    RU_type=${ru_type}
    ...    gNB_common_unit=${FCT_BOARD_TYPE}
    ...    gNB_capacity_unit=${ASP_BOARD_TYPE}
    Log    ${dic}
    ${ap_xml_file}=    Collections.Get From Dictionary    ${dic}   WTS_ap
    ${wts_cfg_file}=    Collections.Get From Dictionary    ${dic}   WTS_config
    ${path}    ${WTS_AP_XML}=    OperatingSystem.Split Path    ${ap_xml_file}
    ${path}    ${WTS_CFG}=    OperatingSystem.Split Path    ${wts_cfg_file}
    OperatingSystem.Remove File    ${work_space_path}/AirPhoneConfig*.xml
    OperatingSystem.Remove File    ${work_space_path}/basic*.cfg
    OperatingSystem.Run    cp ${AP_configs_local_path}/${ap_xml_file} ${work_space_path}/${WTS_AP_XML}
    OperatingSystem.Run    cp ${AP_configs_local_path}/${wts_cfg_file} ${work_space_path}/${WTS_CFG}
    OperatingSystem.Run    sed -i 's/file=.*\.xml/file=${WTS_AP_XML}/' ${work_space_path}/${WTS_CFG}
    ${WTS_CFG_FULL_PATH}=    Set Variable    ${work_space_path}/${WTS_CFG}
    ${WTS_AP_XML_FULL_PATH}=    Set Variable    ${work_space_path}/${WTS_AP_XML}
    Set Global Variable   ${WTS_CFG_FULL_PATH}
    Set Global Variable   ${WTS_AP_XML_FULL_PATH}
    [Return]    ${WTS_CFG_FULL_PATH}

parse yaml file and return dict
    [Arguments]    ${scfc_file}=${EMPTY}    ${AP_configs_local_path}=${GOLDEN_LOCAL_PATH}
    [Documentation]    This keyword is to find git qt file path, and return dict
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_file} | No | scfc file, default ${EMPTY} where download SCF from GNB |
    ...    | ${AP_configs_local_path} | No | local AP config path which download from golden server |
    ...    Examples:
    ...    | parse yaml file and return dict  | scfc.xml |
    ${nrbts_distname}=    Get NRBTS DistName    ${scfc_file}
    ${scfc_file_tmp}=    Run Keyword If    '${scfc_file}'=='${EMPTY}'    Backup Scf    /tmp
    ${scfc_file}=    Set Variable If    '${scfc_file}'=='${EMPTY}'    ${scfc_file_tmp}    ${scfc_file}
    ${gnb_cu_type}=    Get GNB Type    ${scfc_file}    ${nrbts_distname}
    ${celltechnology}=    Get CELL Technology    ${scfc_file}    ${nrbts_distname}
    Set suite Variable    ${CELLTECHNOLOGY}    ${celltechnology}
    ${fr}=    Get FR Type    ${scfc_file}   ${nrbts_distname}
    Set suite Variable    ${FR_TYPE}    ${fr}
    Run Keyword If     "${L1_TYPE}"=="${EMPTY}"    Get L1Bypass Type
    Run Keyword If     "${RF_TYPE}"=="${EMPTY}"    Get Radio Protocol Type    ${scfc_file}
    Run Keyword If     "${SW_VERSION}"=="${EMPTY}"    Get GNB Software Version
    Run Keyword If     "${FCT_BOARD_TYPE}"=="${EMPTY}"    Get Control Board Type
    Run Keyword If     "${ASP_BOARD_TYPE}"=="${EMPTY}"    Get Base Band Board Type
    ${config_yaml}=    Set Variable    ${AP_configs_local_path}/${SW_VERSION}/${gnb_cu_type}/${L1_TYPE}/config.yaml
    ${ret}    run keyword and ignore error     File Should Exist      ${config_yaml}
    run keyword if     '${ret[0]}'=='FAIL'    Return From Keyword
    ${dic}=    YAMLPARSER.Parse Yaml    file_name=${config_yaml}
    ...    duplex=${celltechnology}
    ...    FH_mode=${RF_TYPE}
    ...    RF_mode=${fr}
   # ...    gNB_common_unit=${FCT_BOARD_TYPE}
    ...    gNB_capacity_unit=${ASP_BOARD_TYPE}
    Log    ${dic}
    [Return]    ${dic}


Find Match GNB swconfig Golden Files
    [Arguments]    ${scfc_file}=${EMPTY}    ${AP_configs_local_path}=${GOLDEN_LOCAL_PATH}
    [Documentation]    This keyword is to get GNB swconfig file from dic
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_file} | No | scfc file, default ${EMPTY} where download SCF from GNB |
    ...    | ${AP_configs_local_path} | No | local AP config path which download from golden server |
    ...    Examples:
    ...    | Find Match GNB swconfig Golden Files | scfc.xml |
    ${dic}=     parse yaml file and return dict   ${scfc_file}     ${AP_configs_local_path}
#    ${new_dic}    run keyword if    ${dic}==None    Download Topology Config Files From gerrit
#    ${AP_configs_local_path}     set variable if      ${dic}==None      ${TOPOLOGY_LOCAL_PATH}/local_topology_config
#    ...      ${dic}!=None     ${GOLDEN_LOCAL_PATH}
#    ${dic}    set variable if      ${dic}==None      ${new_dic}
#    ...     ${dic}!=None      ${dic}
    ${gnb_swconfig_file}=    Collections.Get From Dictionary    ${dic}   gNB_swconfig
    ${gnb_swconfig_path}=    Catenate     SEPARATOR=${/}    ${AP_configs_local_path}    ${gnb_swconfig_file}
    OperatingSystem.File Should Exist       ${gnb_swconfig_path}
    [Return]    ${gnb_swconfig_path}

Find Match AP swconfig Golden Files
    [Arguments]    ${scfc_file}=${EMPTY}    ${AP_configs_local_path}=${GOLDEN_LOCAL_PATH}
    [Documentation]    This keyword is to get AP swconfig file from dic
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_file} | No | scfc file, default ${EMPTY} where download SCF from GNB |
    ...    | ${AP_configs_local_path} | No | local AP config path which download from golden server |
    ...    Examples:
    ...    | Find Match AP swconfig Golden Files | scfc.xml |
    ${dic}=     parse yaml file and return dict   ${scfc_file}     ${AP_configs_local_path}

    ${new_dic}    run keyword if    ${dic}==None    Download Topology Config Files From gerrit
    ${AP_configs_local_path}     set variable if      ${dic}==None      ${TOPOLOGY_LOCAL_PATH}/local_topology_config
    ...      ${dic}!=None     ${GOLDEN_LOCAL_PATH}
    ${dic}    set variable if      ${dic}==None      ${new_dic}
    ...     ${dic}!=None      ${dic}
    ${ap_swconfig_file}=    Collections.Get From Dictionary    ${dic}   AP_swconfig
    ${ap_swconfig_path}=    Catenate     SEPARATOR=${/}    ${AP_configs_local_path}    ${ap_swconfig_file}
    OperatingSystem.File Should Exist       ${ap_swconfig_path}
    [Return]    ${AP_swconfig_path}

Get BIP Scripts Files
    [Arguments]    ${local_path}=./BIP
    [Documentation]    This keyword is to Download BIP scripts files save to local path
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_path} | N | Get BIP scripts to which path, default: ./BIP |
    ...    Examples:
    ...    | Get BIP Scripts Files | |
    ...    | Get BIP Scripts Files | ${CURDIR}/BIP |
    Run Keyword And Ignore Error    OperatingSystem.Run    rm -rf ${local_path}/gnbMirroring.sh
    Run Keyword And Ignore Error    OperatingSystem.Run    rm -rf ${local_path}/gnbMirroringConfig.sh
    OperatingSystem.Run    mkdir -p ${local_path}
    OperatingSystem.Run    cp -rf ${CURDIR}/scripts/shell/*.sh ${local_path}

Modify File List Paramters
    [Arguments]    ${file_path}    ${paras_dict}
    [Documentation]    This keyword is to modify parameter in file base dictionary
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Y | the file which need modify parameters |
    ...    | ${paras_dict} | Y | parameter dictionary such as key1=value1    key2=value2 |
    ...    Examples:
    ...    | ${params} | Create Dictionary | a | 1 |
    ...    | Modify File List Paramters | swconfig.txt | ${params} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    FOR    ${key}     IN    @{paras_dict}
        Log    ${key}, ${paras_dict['${key}']}
        ${old_value}=    Set Variable    ${key}=\\S+
        ${new_value}=    Set Variable    ${key}=${paras_dict['${key}']}
        ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    END
    OperatingSystem.Create File    path=${file_path}    content=${content}

Download All Tools
    [Arguments]       ${tools_list}=${TOOLS_LIST}
    [Documentation]    This keyword is to modify parameter in file base dictionary.Defalut tool list is defined in ${TOOLS_LIST} in base.robot.
    ...    It contains: luashark, ttitrace_decode, btp_script,common_config_golden,common_config_private.
    ...    Case can reset its value in 'Variables' parts, for example:
    ...    @{TOOLS_LIST}      luashark    common_config_golden
    ...    ALL Download Tool List:
    ...    luashark: "Download Luashark Tool" path in "/opt/luashark"
    ...    ttitrace_decode: "Download Ttitrace Decode Tool" path in "${TEST_LOG_DIRECTORY()}" and delete after check ok
    ...    common_config_private: "Download Common Config Files From Private Server" path in "/home/ute/kiss_files/private"
    ...    common_config_golden: "Download All Common Config Files From Golden Server" path in "/home/ute/kiss_files/golden"
    ...    bip_script: "Download GNB BIP" path in "/home/ute/kiss_files/GNB_BIP"
    ...    mcshark: "Download Mcshark" path in  "/usr/lib/x86_64-linux-gnu/wireshark/plugins/*/epan/"
    FOR    ${tool}    IN    @{tools_list}
        ${tool}    String.Convert To Lowercase    ${tool}
        Run Keyword If    '${tool}'=='common_config_private'    Run Keyword And Ignore Error    Download Common Config Files From Private Server
        Run Keyword If    '${tool}'=='luashark'    Run Keyword And Ignore Error    Download Luashark Tool
        Run Keyword If    '${tool}'=='ttitrace_decode'    Run Keyword And Ignore Error    Download Ttitrace Decode Tool
        #Run Keyword If    '${tool}'=='bip_script'    Run Keyword And Ignore Error    Download GNB BIP
        Run Keyword If    '${tool}'=='common_config_golden'    Run Keyword And Ignore Error    Download All Common Config Files From Golden Server
        Run Keyword If    '${tool}'=='mcshark'    Run Keyword And Ignore Error    download_mcshark     ${SW_VERSION_TOTAL}
    END
