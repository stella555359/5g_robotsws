*** Settings ***
Library     OperatingSystem
Library     Collections

Library     taf.config.scf                WITH NAME    scf
Library     taf.gnb.oam.coam.admin        WITH NAME    admin
Library     taf.transport.ssh             WITH NAME    ssh
Library    ./python/ute_tl_mgt.py

*** Variables ***
&{P_GNBSWVERSION}      &{EMPTY}
${P_AP_STREAM}         None
${P_gNbCuType}         None
${P_cellTechnology}    None
${P_nrarfcn}           None
&{P_OAMTYPE}           &{EMPTY}
&{P_GNBTYPE}           &{EMPTY}

*** Keywords ***
# -----------------------------
# from ULM common/connect.robot
# -----------------------------
Connect to Core
    [Documentation]    :Author: Soenke Kullberg
    ...     setup ssh connection core and returns connection handle/alias
    ...     KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: alias for ssh connection to OAM
    ...
    [Arguments]    ${alias}=ssh_core
    ssh.Connect_to      hostname=${tl.core.default_ssh_connection_details.addr}
    ...                 username=${tl.core.default_ssh_connection_details.username}
    ...                 password=${tl.core.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}

Setup OAM session
    [Documentation]    :Author: Soenke Kullberg
    ...    setup session to OAM (COAM/CloudCOAM)
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...    :returns alias:     alias for http connection to OAM
    [Arguments]     ${gnb_id}=${0}  ${du_id}=${0}  ${component}=DU
    ${oam_alias}=    Set variable    gnb-${gnb_id}-${component}-OAM-local-session
    ${oam_type}=    ute_cfg_files_mgt.Get OAM type    gnb_id=${gnb_id}
    Run keyword if    '${oam_type}'=='cloud_coam' and '${component}'=='DU'       admin.connect_to
    ...                 bts_host=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}  name=${oam_alias}
    ...    ELSE IF    '${oam_type}'=='coam'         admin.connect_to
    ...                 bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  name=${oam_alias}
    ...    ELSE    Fail    Unknown OAM Type ${oamType}
    [Return]    ${oam_alias}

Connect to Airphone Common Unit
    [Documentation]    :Author: Jing Liang
    ...     setup ssh connection to Airphone Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param ue_id:             Id of UE                       [0.. ]  default=0
    ...     :param ue_comu_id:        Id of AP Common Unit           [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${ap_alias}=    ute_cfg_files_mgt.Connect to Airphone Common Unit    ue_id=0  ue_comu_id=0
    ...     | ssh.execute     command=uptime  connection=${ap_alias}
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}  ${alias}=ssh-ap-${ue_id}-${ue_comu_id}
    ssh.Connect_to      hostname=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.addr}
    ...                 username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...                 password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    [Return]    ${alias}

# ----------------------------
# from ULM common/wts_ue.robot
# ----------------------------
Get SCF Value from file
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    :param dist_name: ‘distName’, ${None} is default value
    ...     SBTS prefix can be ommited e.g.: both ‘SBTS-1900/NGNODEB-1’ and ‘NGNODE-1’ are valid and equivalent.
    ...    :param p_name: ‘name’ attribute in <p> tag, ${None} is default value
    ...    :param list_name: ‘name’ attribute in <list> tag, ${None} is default value
    [Arguments]    ${scf_path}    ${p_name}=${None}    ${list_name}=${None}    ${dist_name}=${None}
    scf.Load Scf    file_path=${scf_path}
    ${value}=    scf.Get Value from SCF    p_name=${p_name}    list_name=${list_name}    dist_name=${dist_name}
    [Return]    ${value}

# from ULM common/wts_ue.robot
Fetch gNB Info from SCF
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    If additional configuration needed, could be added into this keyword
    ${scf_path}=    Get SCF from gNB    target_dir=/tmp    gnb_id=0
    ${gNbCuType}=    Get SCF Value from file    p_name=gNbCuType    scf_path=${scf_path}
    ${cellTechnology}=    Get SCF Value from file    p_name=cellTechnology    scf_path=${scf_path}
    ${nrarfcn}=    Run Keyword If  '${cellTechnology}'=='TDD'  Get SCF Value from file    p_name=nrarfcn    scf_path=${scf_path}
    ${nrarfcnDl}=    Run Keyword If  '${cellTechnology}'=='FDD'  Get SCF Value from file    p_name=nrarfcnDl    scf_path=${scf_path}
    ${nrarfcnUl}=    Run Keyword If  '${cellTechnology}'=='FDD'  Get SCF Value from file    p_name=nrarfcnUl    scf_path=${scf_path}
    ${nrarfcn_wts}=    Set Variable If    '${cellTechnology}'=='TDD'    ${nrarfcn}:${nrarfcn}    ${nrarfcnUl}:${nrarfcnDl}
    Set Suite Variable    ${P_gNbCuType}    ${gNbCuType}
    Set Suite Variable    ${P_cellTechnology}    ${cellTechnology}
    Set Suite Variable    ${P_nrarfcn}    ${nrarfcn_wts}

Get gNbCuType Info
    [Documentation]    :Author: Jing Liang
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    :return: SA or NSA
    Run Keyword If    '${P_gNbCuType}'=='None'    Fetch gNB Info from SCF
    [Return]    ${P_gNbCuType}

Get cellTechnology Info
    [Documentation]    :Author: Jing Liang
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    :return: TDD or FDD
    Run Keyword If    '${P_cellTechnology}'=='None'    Fetch gNB Info from SCF
    [Return]    ${P_cellTechnology}

Update WTS config with Regex
    [Documentation]    :Author: Jing Liang
    ...    update value in WTS config file by using Regular expression, and verify if value has been correctly updated
    ...    it uses taf.transport.ssh to execute, therefore please use double '\' if you have '\' in arguments
    ...    :param regex:
    ...    :param value:
    ...
    ...    **Example:**
    ...    | wts_ue.Update WTS config with Regex    regex=nr_arfcn=\\S+    value=nr_arfcn=646000:646000
    [Arguments]    ${regex}    ${value}
    ${core_alias}=    ute_cfg_files_mgt.Connect to Core
    ssh.execute    command=sed -i -E 's/${regex}/${value}/g' ${tl.core.dir_path}/${tl.core.cfg_filename}
    ...    connection=${core_alias}
    ${output}=    ssh.execute    grep ${value} ${tl.core.dir_path}/${tl.core.cfg_filename}    connection=${core_alias}
    Should Contain    ${output}    ${value}

Update AirPhoneConfig file name in WTS Config
    [Documentation]    :Author: Jing Liang
    ...    update WTS Config with given file name
    ...
    ...    **Example:**
    ...    | wts_ue.Update AirPhoneConfig file name in WTS Config    file_name=AirPhoneConfig.xml
    ...
    [Arguments]    ${file_name}
    ${core_alias}=    ute_cfg_files_mgt.Connect to Core
    ${output}=    ssh.execute    command=ls ${tl.core.dir_path}/${file_name}    connection=${core_alias}
    Should Contain    ${output}    ${file_name}
    Update WTS config with Regex    regex= file=\\S+    value= file=${file_name}

# ------------------------------
# from ULM common/testline.robot
# ------------------------------
Get Common Unit SW Version
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    used to get GNB/Airphone SW on board
    ...    :param alias:               ssh connnection alias to common unit board
    ...    :return: software version
    [Arguments]    ${alias}
    ssh.Force Reconnect    ${alias}
    ssh.send command    cat /ffs/run/Target*xml   connection=${alias}
    ${cmd_output}=    ssh.read output   connection=${alias}
    ${parsed_xml}=    parse xml    ${cmd_output}
    ${software}=    get element attribute    ${parsed_xml}    cbtsSoftwareReleaseVersion
    ${rest}    ${sw_version}=    Split String    ${software}    separator=_
    [Return]    ${sw_version}

Get Airphone SW version
    [Documentation]    :Author: Jing Liang
    ...    reads active software from Airphone
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :return: active Software version on Airphone
    ...
    [Arguments]  ${ue_id}=0
    ${ap_alias}=    ute_cfg_files_mgt.Connect to Airphone Common Unit    ue_id=${ue_id}
    ${ap_version}=    ute_cfg_files_mgt.Get Common Unit SW Version    alias=${ap_alias}
    [Return]    ${ap_version}

Fetch gNB type
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${gnb_type}=    Set Variable If
    ...    '${tl.gnbs[${gnb_id}].__class__.__name__}'=='CloudBts'        cloud
    ...    '${tl.gnbs[${gnb_id}].__class__.__name__}'=='ClassicalBts'    classical
    Set To Dictionary    ${P_GNBTYPE}    gnb_${gnb_id}    ${gnb_type}
    Set Suite Variable    ${P_GNBTYPE}

Get gNB type
    [Documentation]    :Author: Jing Liang
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the BTS (cloud, classical)
    ...    *Note:* woks with COAM and MZOAM
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :return: type of BTS    (cloud,classical)
    ...
    [Arguments]  ${gnb_id}=0
    ${gnb_type}=    Get Variable Value    ${P_GNBTYPE.gnb_${gnb_id}}
    Run Keyword If    '${gnb_type}'=='None'
    ...    ute_cfg_files_mgt.Fetch gNB type    gnb_id=${gnb_id}
    [Return]  ${P_GNBTYPE.gnb_${gnb_id}}

Fetch OAM type
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${gnb_type}=    ute_cfg_files_mgt.Get gNB type    gnb_id=${gnb_id}
    Run Keyword if    '${gnb_type}'=='classical'    Set To Dictionary    ${P_OAMTYPE}    gnb_${gnb_id}    coam
    Return From Keyword If   '${gnb_type}'=='classical'
    ${output}=    OperatingSystem.Run    nc -w 1 -zv ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr} 3600
    ${oam_type}=    ute_tl_mgt.identify_oam_type    cmd_output=${output}
    Set To Dictionary    ${P_OAMTYPE}    gnb_${gnb_id}    ${oam_type}
    Set Suite Variable    ${P_OAMTYPE}

Get OAM type
    [Documentation]    :Author: Jing Liang
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :return: type of OAM    (coam, megazone)
    ...
    [Arguments]    ${gnb_id}=0
    ${oam_type}=    Get Variable Value    ${P_OAMTYPE.gnb_${gnb_id}}
    Run Keyword If    '${oam_type}'=='None'
    ...    ute_cfg_files_mgt.Fetch OAM type    gnb_id=${gnb_id}
    [Return]    ${P_OAMTYPE.gnb_${gnb_id}}

Create test suite result base directory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    example: Testsuite_name/SW_load/timestamp
    ...    legacy: return should not be used
    ${gnbSwVersion}=    ute_cfg_files_mgt.Get gNB SW version
    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y%m%d_%H%M%S
    ${P_resultSuiteBaseDir}=    Set variable    ${OUTPUT_DIR}/${SUITE_NAME}/${gnbSwVersion}/${timeStamp}
    ${P_resultSuiteBaseDir}=    Replace string    ${P_resultSuiteBaseDir}    search_for=${SPACE}     replace_with=_
    Create directory    ${P_resultSuiteBaseDir}
    Set Suite Variable    ${P_resultSuiteBaseDir}
    Create file    ${OUTPUT_DIR}/robotReportTargetDir.txt    ${P_resultSuiteBaseDir}
    [Return]    ${P_resultSuiteBaseDir}

Get test suite result base directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns path for Log base directory
    ...    If Log base directory does not exist it will created automatically
    ...
    ...    :returns: Path for Log base folder
    ...
    ${P_resultSuiteBaseDir}=    Get Variable Value    ${P_resultSuiteBaseDir}
    Run Keyword If    '${P_resultSuiteBaseDir}'=='None'
    ...    ute_cfg_files_mgt.Create test suite result base directory
    [Return]    ${P_resultSuiteBaseDir}

Create test suite config directory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    example: Testsuite_name/SW_load/timestamp/Configs
    ...    legacy: return should not be used
    ${resultSuiteBaseDir}=    ute_cfg_files_mgt.Get test suite result base directory
    ${P_resultSuiteConfigDir}=    Set variable    ${resultSuiteBaseDir}/Configs
    Set Suite Variable    ${P_resultSuiteConfigDir}
    Create directory    ${P_resultSuiteConfigDir}
    [Return]    ${P_resultSuiteConfigDir}

Get test suite config directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns folder for TestSuite config
    ...    If TestSuite config folder does not exist it will created automatically
    ...
    ...    :returns: Path for Testsuites logs
    ${P_resultSuiteConfigDir}=    Get Variable Value    ${P_resultSuiteConfigDir}
    Run Keyword If    '${P_resultSuiteConfigDir}'=='None'
    ...    ute_cfg_files_mgt.Create test suite config directory
    [Return]    ${P_resultSuiteConfigDir}

Fetch cloud COAM SW version
    [Documentation]    :Author: Srihari Janardhan
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${du_id}=0  ${component}=DU
    ${gnb_sw_version}=  Run Keyword if  '${component}'=='DU'  ute_cfg_files_mgt.Fetch common OAM SW version  gnb_id=${gnb_id}
    ...  bts_host=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
    [Return]    ${gnb_sw_version}

Fetch common OAM SW version
    [Documentation]    :Author: Jing Liang
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    admin.connect_to    bts_host=${bts_host}    name=gnb
    ${gnb_sw_version}=    admin.get_sw_version    connection=gnb
    admin.teardown    connection=gnb
    ${gnb_sw_version}=    ute_tl_mgt.reform_coam_sw_version    ${gnb_sw_version}
    [Return]    ${gnb_sw_version}

Fetch Current gNB SW Version
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${du_id}=0  ${component}=DU
    ${oam_type}=    ute_cfg_files_mgt.Get OAM type    gnb_id=${gnb_id}
    ${gnb_sw_version}=    Run keyword if    '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...    ute_cfg_files_mgt.Fetch cloud COAM SW version  gnb_id=${gnb_id}  du_id=${du_id}
    ...    ELSE IF    '${oam_type}'=='coam'    ute_cfg_files_mgt.Fetch common OAM SW version    gnb_id=${gnb_id}
    ...    ELSE    Fail    Unknown OAM type !!!
    Set To Dictionary    ${P_GNBSWVERSION}    gnb_${gnb_id}    ${gnb_sw_version}
    Set Suite Variable    ${P_GNBSWVERSION}

Get gNB SW version
    [Documentation]    :Author: Jing Liang
    ...    reads active software from gNB via OAM
    ...    *Note:* sw version is fetch only once
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id:  (default=0) Id/Number of DU
    ...    :return: active Software version on gNB
    ...
    [Arguments]    ${gnb_id}=0  ${du_id}=0
    ${gnb_sw_version}=    Get Variable Value    ${P_GNBSWVERSION.gnb_${gnb_id}}
    Run Keyword If    '${gnb_sw_version}'=='None'
    ...    ute_cfg_files_mgt.Fetch Current gNB SW Version    gnb_id=${gnb_id}  du_id=${du_id}
    [Return]    ${P_GNBSWVERSION.gnb_${gnb_id}}

Get gNB SW Branch
    [Documentation]    :Author: Jeissel Flores
    ...    Fetch the prefix gNB SW branch
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id:  (default=0) Id/Number of DU
    ...    :return: active Software branch on gNB (e.g 5G_0.800)
    ...
    [Arguments]    ${gnb_id}=0  ${du_id}=0
    ${gnb_sw_version}=    Get gNB SW version    ${gnb_id}    ${du_id}=0
    @{gNB_branch}=        Split String From Right    ${gnb_sw_version}    .    1
    [Return]    @{gNB_branch}[0]

# -------------------------
# from ULM common/gnb.robot
# -------------------------
Get SCF from gNB with cOAM
    [Documentation]    :Author: Nikolay Shkulepov, [PRIVATE]
    [Arguments]     ${gnbScfName}    ${resultConfigDir}     ${gnb_id}=${0}
    ${oam_alias}=       ute_cfg_files_mgt.Setup OAM session   gnb_id=${gnb_id}
    admin.get_current_scf_file    ${resultConfigDir}    ${gnbScfName}    timeout=${10}    connection=${oam_alias}
    [Teardown]  admin.teardown    connection=${oam_alias}

Get SCF from gNB with cloud cOAM
    [Documentation]    :Author: Srihari Janardhan
    ...    [PRIVATE]    Stores SCF of gNB Cloud COAM (DU) in desired directory
    [Arguments]  ${gnbScfName}    ${resultConfigDir}    ${gnb_id}  ${component}
    Run Keyword if   '${component}'=='DU'  Get SCF from gNB with cOAM  gnbScfName=${gnbScfName}
    ...  resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}

Get SCF from gNB
    [Documentation]    :Author: Nikolay Shkulepov
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param target_dir: (default None) save SCF to path
    ...     :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...     :return:   scf path for further usage
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None  ${component}=DU
    ${oamType}=    ute_cfg_files_mgt.Get OAM Type     gnb_id=${gnb_id}
    ${gnbScfName}=    Set variable    SCFC_gNB${gnb_id}_${component}.xml
    Set Suite Variable    ${private_gnbScfName${gnb_id}}    ${gnbScfName}
    ${resultConfigDir}=    Run Keyword If    '${target_dir}'=='None'    ute_cfg_files_mgt.Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    Run keyword if    '${oamType}'=='cloud_coam'    Get SCF from gNB with cloud cOAM  component=${component}
    ...                             gnbScfName=${gnbScfName}    resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}
    ...    ELSE IF    '${oamType}'=='coam'        Get SCF from gNB with cOAM
    ...                             gnbScfName=${gnbScfName}    resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}
    ...    ELSE    Fail    Unknown OAM Type ${oamType}
    [Return]    ${resultConfigDir}/${gnbScfName}

# ------------------------------------
# from ULM common/ute_workaround.robot
# ------------------------------------
Set Airphone Gerrit Stream
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    base on variables to build AP Gerrit stream name
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=tree;f=global_configs/streams;hb=HEAD
    ${gNbCuType}=    Get gNbCuType Info
    ${cellTechnology}=    Get cellTechnology Info
    ${stream}=    Set Variable If
    ...    '${gNbCuType}'=='NSA' and '${cellTechnology}'=='TDD'    fs_tdd_nsa_cmwv
    ...    '${gNbCuType}'=='NSA' and '${cellTechnology}'=='FDD'    fs_fdd_nsa_cmwv
    ...    '${gNbCuType}'=='SA' and '${cellTechnology}'=='TDD'     l1b_tdd_sa_cmwv
    Set Suite Variable    ${P_AP_STREAM}    ${stream}

Get Airphone Gerrit Stream
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    Run Keyword If    '${P_AP_STREAM}'=='None'    Set Airphone Gerrit Stream
    [Return]    ${P_AP_STREAM}

Download file from Gerrit link
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE] Used for UTE Cloud Airphone TL
    [Arguments]    ${file_name}    ${file_link}
    ${rc}   Run And Return Rc    curl -k -s "${file_link}" > /tmp/${file_name}
    Should Be Equal As Integers     ${rc}   0    msg=No access to ${file_link}
    ${file}     OperatingSystem.Get File    /tmp/${file_name}
    # if qt file not exists, curl returns html page containing "Cannot find file"
    ${status}=    Run Keyword and Return Status    Should Not Contain      ${file}     Cannot find file
    Return From Keyword If    ${status}    /tmp/${file_name}
    [Return]    None

Download Airphone config files from Gerrit
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL
    ...
    ...    :param file_name: file name, must match file in Airphone Gerrit, check link
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=tree;f=global_configs/streams;hb=HEAD
    ...
    [Arguments]    ${file_name}
    ${ap_verion}=    ute_cfg_files_mgt.Get Airphone SW version
    ${stream}=    Get Airphone Gerrit Stream
    ${gnb_branch}=    Get gNB SW Branch
    ${ap_tag}=    Set Variable If    'nsa' in '${stream}'    ${ap_verion}    5G_${ap_verion}
    ${file_link}=    Catenate    SEPARATOR=/
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=blob_plain;f=global_configs/streams
    ...    ${gnb_branch}/${stream}/${file_name};hb=refs/tags/${ap_tag}
    ${file}=    Download file from Gerrit link    file_name=${file_name}    file_link=${file_link}
    Return From Keyword If    '${file}'!='None'    ${file}
    BuiltIn.Log    message=${file_link} doesn't exist    level=DEBUG
    ${file_link}=    Catenate    SEPARATOR=/
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=blob_plain;f=global_configs/streams
    ...    ${gnb_branch}/${stream}/${file_name}
    ${file}=    Download file from Gerrit link    file_name=${file_name}    file_link=${file_link}
    # Ugly WA while SA l1bypass is not yet on Trunk
    Return From Keyword If    '${file}'!='None'    ${file}
    BuiltIn.Log    message=${file_link} doesn't exist on trunk!    level=DEBUG
    ${file_link}=    Catenate    SEPARATOR=/
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=blob_plain;f=global_configs/streams
    ...    5G20A_9.1800/${stream}/${file_name}
    ${file}=    Download file from Gerrit link    file_name=${file_name}    file_link=${file_link}
    [Return]    ${file}

Download AirPhoneConfig from Gerrit
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL
    ...
    ${core_alias}=    ute_cfg_files_mgt.Connect to Core
    ${file_path}=    Download Airphone config files from Gerrit    file_name=AirPhoneConfig.xml
    ssh.Upload File    local_path=${file_path}    remote_path=${tl.core.dir_path}/AirPhoneConfig.xml    connection=${core_alias}

Download WTS config from Gerrit
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL
    ...
    ${core_alias}=    ute_cfg_files_mgt.Connect to Core
    ${file_path}=    Download Airphone config files from Gerrit    file_name=basic_wts.cfg
    ssh.Upload File    local_path=${file_path}    remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}    connection=${core_alias}

Download AirPhoneConfig and WTS config from Gerrit
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    Download WTS config from Gerrit
    Download AirPhoneConfig from Gerrit
    Update AirPhoneConfig file name in WTS Config    file_name=AirPhoneConfig.xml
