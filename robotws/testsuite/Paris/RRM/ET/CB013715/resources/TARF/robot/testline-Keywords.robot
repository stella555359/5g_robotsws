*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   testline-Keywords.robot
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Creation Date               : 10-03-2024
...               Modified Date               : 10-03-2024
...               Last Modified by            : christophe.samson@nokia.com
...               Version   Date          Author                                   Notes
...               0.1       10-03-2024    christophe.samson@nokia.com              Creation
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library      BuiltIn
Library      taf.transport.ssh                                   WITH NAME          ssh
Library      taf.sbts.oam.coam.admin.interface
Library      taf.sbts.oam.coam.admin                             WITH NAME          coam
Library      taf.collectors.tcpdump                              WITH NAME          tcpdump
Library      taf.collectors.core                                 WITH NAME          core
Library      taf.hw.pdu                                          WITH NAME          pdu
Library      ute_wtssim
Library      taf.config.wts                                      WITH NAME          wts_cfg
Library      re
Library      XML    True
Library      json
Library      taf.rfrl.common_resources.python.SWConfig           WITH NAME          swconf

# Libraries SWENG
Library      ../../../../../../resources/SWENG/python/StringTool.py

# Libraries TRF
Library      ../python/tools.py                                  WITH NAME          nps_trf_tools

# Resources
Resource     connect.robot
Resource     coam_nps.robot

*** Variables ***

&{P_COMMON_UNIT_TYPE}      &{EMPTY}
&{P_UE_COMMON_UNIT_TYPE}   &{EMPTY}
&{P_UE_CAPA_UNIT_TYPE}     &{EMPTY}
&{P_CAPA_UNIT_TYPE}        &{EMPTY}
&{P_GNBSWVERSION}          &{EMPTY}
${P_console}               ${False}    # output to console can be enabled via "Set Console Output" from testline-Keywords.robot
${P_gNbCuType}             None
${P_cellTechnology}        None
${P_nrarfcn}               None
${P_resultSuiteBaseDir}    None
${P_resultSuiteLogDir}     None
${P_resultSuiteConfigDir}  None
${P_lteNrDssMode}          None
${P_cellDepType_Cell1}     None

*** Keywords ***

# ------------------------------------------------------------------------------------------------------------------------------------
# testline Kw
# ------------------------------------------------------------------------------------------------------------------------------------

Get Node Deployment Type
    [Documentation]
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the BTS (aic, classical)
    ...
    ...    *Note:* supports classical and AiC vran2.0
    ...
    ...    | node_type | type of node, either gnb or enb |
    ...    | node_id   | Id/Number of node |
    ...
    ...    *Returns* type of BTS    (classical|aic|simulated)
    ...
    [Arguments]   ${node_id}=0   ${node_type}=gnb
    ${bts_type}   Set Variable If
    ...   $tl.${node_type}s[${node_id}].__class__.__name__=='ClassicalBts'   classical
    ...   $tl.${node_type}s[${node_id}].__class__.__name__=='RealEnb'        classical
    ...   $tl.${node_type}s[${node_id}].__class__.__name__=='LTEEmuEnb'      simulated
    ...   $tl.${node_type}s[${node_id}].dus[0].__class__.__name__=='VDU'     aic
    [Return]   ${bts_type}

Fetch UE type
    [Documentation]    :
    ...    [PRIVATE]
    [Arguments]    ${ue_id}=0
    ${ueType}=    Set Variable If
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'TM500'   viavi
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Android'    qualcomm
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Simulator'  airphone
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Airphone'   airphone
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Prisma'    prisma
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Qualcomm'    qualcomm
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'MediaTek'    mediatek
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'iphy'    iphy
    Set To Dictionary    ${P_UETYPE}    ue_${ue_id}    ${ueType}
    Set Suite Variable    ${P_UETYPE}

Get UE type
    [Documentation]    :
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the UE (viavi, qualcomm, airphone)
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :return: type of UE    (viavi, qualcomm, airphone)
    ...
    [Arguments]  ${ue_id}=0
    ${ueType}=    Get Variable Value    ${P_UETYPE.ue_${ue_id}}
    Run Keyword If    '${ueType}'=='None'
    ...    Fetch UE type    ue_id=${ue_id}
    [Return]    ${P_UETYPE.ue_${ue_id}}

Get OAM Type
    [Documentation]
    ...    This KW is used to determine which OAM interface the gnb supports.
    ...    Classical gNB uses the admin API whereas the AiC uses the REST API.
    ...
    ...    *Note*  This KW is deprecated, it is recommended to use tl_info.deployment_type() instead!
    ...    | Run Keyword If   '${tl_info.deployment_type()}'=='aic'
    ...    | ...              Bring Airphone TL to On air status with aic
    ...
    ...    | gnb_id | Id/Number of gNB |
    ...
    ...    *Returns* type of OAM
    ...
    [Arguments]   ${gnb_id}=0
    ${oam_type}   Set Variable If
    ...   $tl_info.deployment_type(${gnb_id})=='classical'   coam
    ...   $tl_info.deployment_type(${gnb_id})=='aic'   cloud_aic
    [Return]   ${oam_type}

Get Core type
    [Documentation]
    ...    Returns the information which core type the testline is connected to.
    ...
    ...    *Returns* type of CORE (real, epcsim)
    ...
    ${coreType}   Set Variable If
    ...   $tl.core.__class__.__name__=='LTEEmuCore'   lte_core
    ...   $tl.core.__class__.__name__=='RealCore4G'   real
    ...   $tl.core.__class__.__name__=='EPCSim'       epcsim
    ...   $tl.core.__class__.__name__=='RealCore5G'   real
    [Return]   ${coreType}

Get Common Unit SW Version
    [Documentation]    :
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
    [Documentation]    :
    ...    reads active software from Airphone
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :return: active Software version on Airphone
    ...
    [Arguments]  ${ue_id}=0
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}
    ${ap_version}=    testline-Keywords.Get Common Unit SW Version    alias=${ap_alias}
    Set Suite Metadata    AirPhone Version    ${ap_version}
    ssh.disconnect     ${ap_alias}
    [Return]    ${ap_version}

Get WTS Version
    [Documentation]    This keyword is to get WTS version including below 1 suite variable.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...
    # ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/iphy/latest
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/wts/latest
    @{split_list}    String.Split String    ${output}    /
    Set Suite Variable    ${WTS_VERSION}    ${split_list[-1]}
    # Log to console     WTS Version: ${WTS_VERSION}


Fetch Common Unit Type
    [Documentation]
    ...    Detects and returns type of common unit eg. ASIL.
    ...
    ...    *Note*    for classical gNB only!
    ...
    ...    *Scope*  Internal
    ...
    ...    | gnb_id         | Id of gnb [0.. ] |
    ...    | du_id          | Id of DU [0.. ] |
    ...    | common_unit_id | Id of Common Unit [0.. ] |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}
    ${alias_gnb_common_unit_identify_device_type}   connect.Connect to Node Common Unit
    ...   node_id=${gnb_id}   du_id=${du_id}   comu_id=${common_unit_id}
    ${common_unit}   nps_trf_tools.identify_module   connection=${alias_gnb_common_unit_identify_device_type}
    Collections.Set To Dictionary   ${P_COMMON_UNIT_TYPE}   gNB${gnb_id}_DU${du_id}_CM${common_unit_id}   ${common_unit}
    Set Suite Variable   ${P_COMMON_UNIT_TYPE}

Get Common Unit Type
    [Documentation]
    ...    Detects and returns type of gnb common unit eg. ASIK / ASIB.
    ...
    ...    | gnb_id         | Id of gnb [0.. ] |
    ...    | du_id          | Id of DU [0.. ] |
    ...    | common_unit_id | Id of Common Unit [0.. ] |
    ...
    ...    *Returns*    gnb common unit HW board name
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}

    ${common_unit}   Get Variable Value   ${P_COMMON_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}}

    Run Keyword If   '${common_unit}'=='None'
    ...   Fetch Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${common_unit_id}
    [Return]   ${P_COMMON_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}}

Get Capacity Slave IP
    [Documentation]
    ...    Calculate Capacity Unit IP depending on slave a(master)|b|loner.
    ...
    ...    | gnb_id  | Id of gnb [0.. ] |
    ...    | du_id   | Id of DU [0.. ] |
    ...    | comu_id | Id of Common Unit [0..1] |
    ...    | capu_id | Id of Capacity Unit [0..5] |
    ...    | slave   | Name of Slave of Capacity unit (a/0|b/1|loner/2) |
    ...
    ...    *Returns*    slave_ip (Ip of Slave on capacity unit)
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}   ${slave}=a
    # Run Keyword If   $tl_info.deployment_type(${gnb_id})=='aic'   Run Keywords
    # ...            Log To Console   ${\n}AiC isn't supported!
    # ...   AND      Return From Keyword   ${None}

    ${comu_type}   Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${comu_id}
    Run Keyword And Return If   $comu_type=='ASOE'
    ...   Log To Console   ${\n}KW 'Get Capacity Slave IP' is not applicable for ${comu_type}!

    ${gnb_comu_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ${grep_ipv6_cmd}    Set Variable   echo "ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}:){7}(\\w{1,4})'"

    ${slave_ip}   Run Keyword If   '${slave}'=='a' or '${slave}'=='0'   ssh.execute
    ...       command=${grep_ipv6_cmd} | bsh ${${capu_id}+1}:0
    ...       connection=${gnb_comu_alias}
    ...       timeout=30s
    ...   ELSE IF   '${slave}'=='b' or '${slave}'=='1'                  ssh.execute
    ...       command=${grep_ipv6_cmd} | bsh ${${capu_id}+1}:1
    ...       connection=${gnb_comu_alias}
    ...       timeout=30s
    ...   ELSE IF   '${slave}'=='loner' or '${slave}'=='2'              ssh.execute
    ...       command=${grep_ipv6_cmd} | bsh ${${capu_id}+1}:2
    ...       connection=${gnb_comu_alias}
    ...       timeout=30s
    ...   ELSE   Fail   Unknown Capacity Unit Slave name. Must a/0|b/1|loner/2 !

    nps_trf_tools.should_be_valid_ip     ${slave_ip.strip()}

    [RETURN]   ${slave_ip.strip()}

Get Common Unit Slave IP
    [Documentation]
    ...    Calculate Common Unit Slave IP.
    ...
    ...    *Note*   usable for ASIK
    ...
    ...    | gnb_id  | Id of gnb [0.. ] |
    ...    | du_id   | Id of DU [0.. ] |
    ...    | comu_id | Id of Common Unit [0..1] |
    ...
    ...    *Returns*    slave_ip (Ip of Slave on common unit)
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}
    # Run Keyword If   $tl_info.deployment_type(${gnb_id})=='aic'   Run Keywords
    # ...              Log To Console   ${\n}AiC is not supported!
    # ...   AND        Return From Keyword   ${None}

    ${comu_type}   Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${comu_id}

    Run Keyword And Return If   $comu_type!='ASIK'
    ...   Log To Console   ${\n}KW 'Get Common Unit Slave IP' is not applicable for ${comu_type}!

    ${gnb_comu_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ${grep_ipv6_cmd}    Set Variable   echo "ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}:){7}(\\w{1,4})'"
    ${slave_ip}   ssh.execute  command=${grep_ipv6_cmd} | bsh ${${comu_id}}:1   connection=${gnb_comu_alias}   timeout=30s
    [RETURN]   ${slave_ip.strip()}

Backup WTS Config
    [Arguments]    ${basic_setup_file_name}=basic_setup.cfg
    Copy File   ${tl.core.dir_path}/${tl.core.cfg_filename}  ${configuration_directory}/${basic_setup_file_name}


Restore WTS Config
    copy file   ${configuration_directory}/basic_setup.cfg.orig  ${tl.core.dir_path}/${tl.core.cfg_filename}


Restore original gnb SCF
    Run Keyword   Restore SCF for Classical gNB


Restore SCF for Classical gNB
    Run Keyword  Execute full commissioning  gnb_id=${0}  scf_path=${original_gnb_scf}

Set Console Output
    [Documentation]
    ...    Enable/Disable Console output. This defines the value of the global variable P_console.
    ...    This variable could be used with -v to control the output from robot command line!
    ...
    ...    | Output | ${True} to enable console output of common keywords, ${False} disable output |
    ...
    [Arguments]   ${Output}=${True}
    Set Global Variable   ${P_console}   ${Output}

Create Test Suite Log Folders
    [Documentation]
    ...    Create Log & Config folders for Test Suite.
    ...    Must be used as first keyword at Suite Setup
    ...
    ...    *Note* Keyword will fail if GNB doesn't work
    ...
    Get test suite result base directory
    Get Test Suite Config Directory

Get SCF Value From File
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    | dist_name |  distName of a managed object   |
    ...    | p_name    |  ‘name’ attribute in <p> tage   |
    ...    | list_name |  ‘name’ attribute in <list> tag |
    ...
    ...    *Returns*    first match of given regexp
    ...
    [Arguments]   ${scf_path}   ${p_name}=${None}   ${list_name}=${None}   ${dist_name}=${None}
    scf.Load Scf   file_path=${scf_path}
    ${value}   scf.Get Value from SCF   p_name=${p_name}   list_name=${list_name}   dist_name=${dist_name}
    [Return]   ${value}


Get SCF Value From File By Pattern
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    ...    | dist_name |  expects regular expressions |
    ...    | p_name    |  expects regular expressions |
    ...    | list_name |  expects regular expressions |
    ...
    ...    *Returns*    first match of given regexp
    ...
    [Arguments]   ${scf_path}   ${p_name}=${None}   ${list_name}=${None}   ${dist_name}=${None}
    scf.Load Scf   file_path=${scf_path}
    ${value}   scf.Get all values from scf by pattern   p_name=${p_name}   list_name=${list_name}   dist_name=${dist_name}
    # [Return]   ${value}[0]
    [Return]   ${value}

Fetch gNB Info From SCF
    [arguments]    ${w_display}=${True}
    [Documentation]
    ...
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    If additional configuration needed, could be added into this keyword
    ...
    ...     *Scope* Internal
    ...
    ${scf_path}     COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml    alias=coam_gnb

    ${P_gNbCuType}   Get SCF Value from file   p_name=gNbCuType   scf_path=${scf_path}
    ${P_cellTechnology}   Get SCF Value from file by pattern   p_name=cellTechnology   scf_path=${scf_path}   dist_name=.*NRCELL-*
    ${P_freqBandIndicatorNR}   Get SCF Value from file by pattern   p_name=freqBandIndicatorNR   scf_path=${scf_path}   dist_name=.*NRCELL-*
    ${P_actLteNrDss}   Get SCF Value from file   p_name=actLteNrDss   scf_path=${scf_path}
    ${P_lteNrDssMode}   Get SCF Value from file by pattern   p_name=lteNrDssMode   scf_path=${scf_path}   dist_name=.*NRCELL-*
    ${P_cellDepType}   Get SCF Value from file by pattern   p_name=cellDepType   scf_path=${scf_path}    dist_name=.*NRCELL-*

    # ${nrarfcn}     Run Keyword If  '${P_cellTechnology[0]}'=='TDD'   Get SCF Value from file by pattern
    # ...   p_name=nrarfcn    scf_path=${scf_path}     dist_name=.*NRCELL-*
    # ${nrarfcnDl}   Run Keyword If  '${P_cellTechnology[0]}'=='FDD'   Get SCF Value from file by pattern
    # ...   p_name=nrarfcnDl   scf_path=${scf_path}   dist_name=.*NRCELL_FDD-1
    # ${nrarfcnUl}   Run Keyword If  '${P_cellTechnology[0]}'=='FDD'   Get SCF Value from file by pattern
    # ...   p_name=nrarfcnUl    scf_path=${scf_path}   dist_name=.*NRCELL_FDD-1

    ${P_nrarfcn}    Create List
    ${index_cell}   set variable    ${0}
    FOR     ${i}   IN RANGE  len(@{P_cellTechnology})
        ${index_cell}   Evaluate    ${i}+${1}
        ${nrarfcn}     Run Keyword If  '${P_cellTechnology[${i}]}'=='TDD'   Get SCF Value from file by pattern
        ...   p_name=nrarfcn    scf_path=${scf_path}     dist_name=.*NRCELL-${index_cell}
        ${nrarfcnDl}   Run Keyword If  '${P_cellTechnology[${i}]}'=='FDD'   Get SCF Value from file by pattern
        ...   p_name=nrarfcnDl   scf_path=${scf_path}   dist_name=.*NRCELL-${index_cell}/NRCELL_FDD-1
        ${nrarfcnUl}   Run Keyword If  '${P_cellTechnology[${i}]}'=='FDD'   Get SCF Value from file by pattern
        ...   p_name=nrarfcnUl    scf_path=${scf_path}   dist_name=.*NRCELL-${index_cell}/NRCELL_FDD-1
        IF    '${P_cellTechnology[${i}]}'=='TDD'
            Collections.append to list   ${P_nrarfcn}    ${nrarfcn[0]}:${nrarfcn[0]}
        ELSE
            Collections.append to list   ${P_nrarfcn}    ${nrarfcnUl[0]}:${nrarfcnDl[0]}
        END
    END

    # ${P_nrarfcn}   Set Variable If   '${P_cellTechnology}'=='TDD'   ${nrarfcn[0]}:${nrarfcn[0]}   ${nrarfcnUl[0]}:${nrarfcnDl[0]}

    FOR   ${varname}   IN   P_gNbCuType   P_cellTechnology  P_freqBandIndicatorNR  P_nrarfcn    P_actLteNrDss   P_lteNrDssMode   P_cellDepType
       Set Suite Variable   ${${varname}}
    END
    return from Keyword if    ${w_display}==${False}
    StringTool.printLineWithTitle     title=TL info
    ${msg}=   StringTool.getHeaderLine    P_gNbCuType       ${P_gNbCuType}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    P_cellTechnology       ${P_cellTechnology}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    P_freqBandIndicatorNR       ${P_freqBandIndicatorNR}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    P_nrarfcn       ${P_nrarfcn}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    P_actLteNrDss       ${P_actLteNrDss}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    P_lteNrDssMode       ${P_lteNrDssMode}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    P_cellDepType       ${P_cellDepType}
    dated log      ${msg}
    StringTool.printLineWithTitle     title=-

Get gNbCuType Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `Fetch gNB Info from SCF`.
    ...    If the global variable P_gNbCuType isn't None it returns its value.
    ...    Otherwise it calls `Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    SA or NSA or both
    ...
    Run Keyword If   '${P_gNbCuType}'=='None'   Fetch gNB Info from SCF
    [Return]   ${P_gNbCuType}


Get CellDepType_Cell1 Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `Fetch gNB Info from SCF`.
    ...    If the global variable P_gNbCuType isn't None it returns its value.
    ...    Otherwise it calls `Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    SA or NSA or both
    ...
    Run Keyword If   '${P_cellDepType[0]}'=='None'   Fetch gNB Info from SCF
    [Return]   ${P_cellDepType[0]}


Get CellDepType Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `Fetch gNB Info from SCF`.
    ...    If the global variable P_gNbCuType isn't None it returns its value.
    ...    Otherwise it calls `Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    SA or NSA or both
    ...
    Run Keyword If   '${P_cellDepType[0]}'=='None'   Fetch gNB Info from SCF
    [Return]   ${P_cellDepType}


Get Dss Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `Fetch gNB Info from SCF`.
    ...    If the global variable P_gNbDssType isn't None it returns its value.
    ...    Otherwise it calls `Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    Dss or not Dss
    ...
    Run Keyword If   '${P_lteNrDssMode[0]}'=='None'   Fetch gNB Info from SCF
    [Return]   ${P_lteNrDssMode[0]}

Get Dss Info All cells
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `Fetch gNB Info from SCF`.
    ...    If the global variable P_gNbDssType isn't None it returns its value.
    ...    Otherwise it calls `Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    Dss or not Dss
    ...
    Run Keyword If   '${P_lteNrDssMode[0]}'=='None'   Fetch gNB Info from SCF
    [Return]   ${P_lteNrDssMode}

Get Airphone Common Unit Type
    [Documentation]
    ...    Detects and returns type of Airphone common unit eg. ASIK / ASIB.
    ...
    ...    | ue_id | Id of ue(ap) [0.. ] |
    ...
    ...    *Returns*    AP common unit HW board name
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}
    ${common_unit}   Get Variable Value   ${P_UE_COMMON_UNIT_TYPE.ue${ue_id}}

    Run Keyword If   '${common_unit}'=='None'
    ...   Fetch Airphone Common Unit Type   ue_id=${ue_id}   comu_id=${comu_id}
    [Return]   ${P_UE_COMMON_UNIT_TYPE.ue${ue_id}}


Get Airphone Capacity Unit Type
    [Documentation]
    ...    Detects and returns type of Airphone capacity unit eg. ABIL / ABIO
    ...
    ...    | ue_id   | Id of ue [0.. ] |
    ...    | comu_id | Id of Common Unit [0.. ] |
    ...    | capu_id | Id of Capacity Unit [0.. ] |
    ...
    ...    *Returns*    AP capacity unit HW board name
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ${capa_unit}   Get Variable Value  ${P_UE_CAPA_UNIT_TYPE.ap${ue_id}_CM${comu_id}_CA${capu_id}}

    Run Keyword If   '${capa_unit}'=='None'
    ...   Fetch Airphone Capacity Unit Type   ue_id=${ue_id}   comu_id=${comu_id}   capu_id=${capu_id}
    [Return]   ${P_UE_CAPA_UNIT_TYPE.ap${ue_id}_CM${comu_id}_CA${capu_id}}


Get Capacity Unit Type
    [Documentation]
    ...    Detects and returns type of capacity unit eg. ABIL / ABIO.
    ...
    ...    *Note* only for classical gNB
    ...
    ...    | gnb_id         | Id of gnb [0.. ] |
    ...    | du_id          | Id of DU [0.. ] |
    ...    | common_unit_id | Id of Common Unit [0.. ] |
    ...    | capu_id        | Id of Capacity Unit [0.. ] |
    ...
    ...    *Returns*    gNB capacity unit HW board name
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}   ${capu_id}=${0}
    ${capa_unit}   Get Variable Value   ${P_CAPA_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}}
    Run Keyword If   '${capa_unit}'=='None'
    ...   Fetch Capacity Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${common_unit_id}   capu_id=${capu_id}
    [Return]   ${P_CAPA_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}}


Get cellTechnology Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `gnb.Fetch gNB Info from SCF`.
    ...    If the global variable P_cellTechnology isn't None it returns its value.
    ...    Otherwise it calls `gnb.Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    TDD or FDD
    ...
    Run Keyword If   '${P_cellTechnology}'=='None'   Fetch gNB Info from SCF
    [Return]   ${P_cellTechnology}


Get nrarfcn Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `testline-Keywords.Fetch gNB Info from SCF`.
    ...    If the global variable P_nrarfcn isn't None it returns its value.
    ...    Otherwise it calls `testline-Keywords.Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    nrarfcn value
    ...
    Run Keyword If   '${P_nrarfcn}'=='None'   testline-Keywords.Fetch gNB Info from SCF
    [Return]   ${P_nrarfcn}

Set SW Duplex Variable according to cellTechnology
    ${SW_DUPLEX}=         Get cellTechnology Info
    Set Suite Variable    ${SW_DUPLEX}


Set SW Wavelength Variable according to nrarfcn
    ${nrarfcn_Str}=      Get nrarfcn Info
    @{nrarfcn_List}=     Split string    ${nrarfcn_Str}    :
    ${nrarfcn}=          Convert to integer    ${nrarfcn_List}[0]
    ${SW_WAVELENGTH}=    Set variable if  ${nrarfcn} > 2000000    MMWV    CMWV
    Set Suite Variable   ${SW_WAVELENGTH}

Save Current Workspace Info
    [Documentation]
    ...    Save robotws5g branch and commit ID information for debugging or reproducing
    ...    Save modified files in robotws5g
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${workspaceDir}=    Get Workspace Directory
    ${output_1}=   Run    cd ${workspaceDir}; git rev-parse --abbrev-ref HEAD
    ${output_2}=   Run    cd ${workspaceDir}; git rev-parse HEAD
    Save Modified Files in Git
    Create file    ${resultSuiteBaseDir}/robotws5gInfo.txt   Working on branch: ${output_1} with Commit-ID ${output_2}
    StringTool.printLineWithTitle   title=-
    ${msg}=    StringTool.getHeaderLine    Git Branch     ${output_1}
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    ${msg}=    StringTool.getHeaderLine    Git Commit     ${output_2}
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    StringTool.printLineWithTitle   title=-


Save Modified Files in Git
    [Documentation]
    ...    [PRIVATE]
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${workspaceDir}=    Get Workspace Directory
    ${modifiedFiles}=    Run    cd ${workspaceDir}; git ls-files -m
    ${modifiedFiles}=    Replace String    ${modifiedFiles}    search_for=\n    replace_with=${SPACE}
    Run Keyword If    '${modifiedFiles}'!=''
    ...    Run    cd ${workspaceDir}; tar czvf ${resultSuiteBaseDir}/modifedFiles.tgz ${modifiedFiles}


Get Workspace Directory
    [Documentation]
    ...    Returns path to local repository root folder.
    ...
    ...    *Returns* Path to repository
    ...
    ${separator}   Set Variable If
    ...   'robotws/' in '${SUITE SOURCE}'     robotws
    ...   'Auto5G' in '${SUITE SOURCE}'       Auto5G    robotws
    ${workspaceDir}    ${_}    String.Split String    ${SUITE SOURCE}    separator=${separator}    max_split=1
    [Return]   ${workspaceDir}${separator}

set resultSuiteBaseDir
    ${P_resultSuiteBaseDir}    set variable    ${LOG_PATH}
    set suite variable     ${P_resultSuiteBaseDir}

Get test suite result base directory
    [Documentation]
    ...    Retuns path for Log base directory
    ...    If Log base directory does not exist it will created automatically
    ...
    ...    :returns: Path for Log base folder
    ...
    ${P_resultSuiteBaseDir}=    Get Variable Value    ${P_resultSuiteBaseDir}
    Run Keyword If    '${P_resultSuiteBaseDir}'=='None' or '${P_resultSuiteBaseDir}'=='${EMPTY}'
    ...    Run Keywords    set resultSuiteBaseDir
    ...      AND           BuiltIn.Log     P_resultSuiteBaseDir is ${P_resultSuiteBaseDir}       level=INFO
    [Return]    ${P_resultSuiteBaseDir}

Get Test Suite Config Directory
    [Documentation]
    ...    Returns folder for TestSuite config, if TestSuite config folder
    ...    does not exist it will created automatically.
    ...
    ...    *Returns* Path for Testsuites logs
    ...
    ${P_resultSuiteConfigDir}    Get Variable Value    ${P_resultSuiteConfigDir}
    Run Keyword If    '${P_resultSuiteConfigDir}'=='None'
    ...    Create Test Suite Config Directory
    [Return]   ${P_resultSuiteConfigDir}

create Test Suite Config Directory
    [Documentation]
    ...    Creates global Configs directory for the running test suite.
    ...    Naming rule: ${OUTPUT_DIR}/${SUITE_NAME}/${gnbSwVersion}/${timeStamp}/Configs
    ...    legacy: return should not be used
    ...
    ...    *Scope*  Internal
    ...
    ${resultSuiteBaseDir}   Get Test Suite Result Base Directory

    Set Suite Variable   ${P_resultSuiteConfigDir}   ${resultSuiteBaseDir}/Configs

    OperatingSystem.Create Directory   ${P_resultSuiteConfigDir}
    [Return]   ${P_resultSuiteConfigDir}

Get Test Suite Directory
    [Documentation]
    ...    Returns path for current test suite on running system.
    ...
    ...    *Returns* Path for current test suite
    ...
    ${suiteDir}   ${_}   String.Split String From Right   ${SUITE SOURCE}   separator=/   max_split=1
    [Return]   ${suiteDir}

Fetch Capacity Unit Type
    [Documentation]
    ...    Detects type of gnb capacity unit eg. ABIO and stores it in a global
    ...    dictionary P_CAPA_UNIT_TYPE.
    ...
    ...    They keys follow the naming rule:
    ...    gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}
    ...
    ...    Don't use this KW directly, use wrapper KW `Get Capacity Unit Type` instead!
    ...
    ...    *Note*    for classical gNB only!
    ...
    ...    *Scope*  Internal
    ...
    ...    | gnb_id         | Id of gnb [0.. ] |
    ...    | du_id          | Id of DU [0.. ] |
    ...    | common_unit_id |  Id of Common Unit [0.. ] |
    ...    | capu_id        | Id of Capacity Unit [0.. ] |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}   ${capu_id}=${0}
    ${comu_type}   Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${common_unit_id}

    Run Keyword If   $comu_type=='ASOE'   Run Keywords
    ...         Log To Console        ${\n}ASOE has no Capacity Unit!
    ...   AND   Collections.Set To Dictionary    ${P_CAPA_UNIT_TYPE}   gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}   ${None}
    ...   AND   Set Suite Variable    ${P_CAPA_UNIT_TYPE}
    ...   AND   Return From Keyword   ${P_CAPA_UNIT_TYPE}

    ${comu_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${common_unit_id}
    ${capa_unit_type}   nps_trf_tools.identify_module   connection=${comu_alias}    capu_id=${capu_id}
    Set To Dictionary   ${P_CAPA_UNIT_TYPE}   gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}   ${capa_unit_type}
    Set Suite Variable   ${P_CAPA_UNIT_TYPE}

Power Cycle UE
    [Documentation]
    ...     Performs a power off/on cycle for the given `ue_id`. The off duration is specified by `time_interval`.
    ...
    ...     *Note*  Currently only supports AirPhone
    ...
    [Arguments]   ${ue_id}=${0}   ${common_unit_id}=${0}   ${time_interval}=10
    ${pdu}        Set Variable   ${tl.ues[${ue_id}].l1.common_units[${common_unit_id}].pdu_port.pdu}
    ${pdu_port}   Set Variable   ${tl.ues[${ue_id}].l1.common_units[${common_unit_id}].pdu_port.port_no}
    PDU power reset   ${pdu}   ${pdu_port}   time_interval=${time_interval}

PDU power reset
    [Documentation]
    ...    KW is used to reset a device which is connected to PDU.
    ...
    ...    *Note* Needs proper SMNP settings on PDU aligned with settings in testline configuration file!
    ...
    ...    *Scope*  Internal
    ...
    ...    | pdu           | pdu object |
    ...    | pdu_port      | port on the PDU: Bank A - Port 1 -> Port 6, Bank B - Port 7 -> Port 12 |
    ...    | time_interval |  number of seconds to wait between OFF/ON actions |
    ...
    ...    *Example*
    ...    | PDU power reset  pdu=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    ...    | ...              pdu_port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...    | ...              time_interval=5
    ...
    [Arguments]   ${pdu}   ${pdu_port}   ${time_interval}=10
    ${pdu_alias}   pdu.setup pdu   ${pdu}
    ${pdu_ports}   Create list   ${pdu_port}
    pdu.reset_ports   ports=${pdu_ports}   time_interval=${time_interval}   pdu_device=${pdu_alias}


Get PDU power status
    [Documentation]
    ...    This KW checks the status of the given `pdu_port` of the PDU the TL is connected to.
    ...    So the `pdu` must be the one define in the testline configuration file.
    ...
    ...    *Note* Needs proper SMNP settings on PDU aligned with settings in testline configuration file!
    ...
    ...    | pdu      | pdu object |
    ...    | pdu_port | port on the PDU: Bank A - Port 1 -> Port 6, Bank B - Port 7 -> Port 12 |
    ...
    ...    *Example*
    ...    | Get PDU power status  pdu=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    ...    | ...                   pdu_port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...
    ...    *Returns*   port status (off|on)
    ...
    [Arguments]   ${pdu}   ${pdu_port}
    ${pdu_alias}     pdu.setup pdu   ${pdu}
    ${port_status}   pdu.get_port_status   port=${pdu_port}   pdu_device=${pdu_alias}
    [Return]   ${port_status}

Get All Ids Of Class
    [Documentation]
    ...     Returns the list of item ids for the given class in runtime view
    ...     for the given gNB.
    ...
    ...     *Scope* Internal
    ...
    ...     | gnb_id | Id of gNB [0..] |
    ...     | class  | Class name you get items for, e.g. LNCEL, NRCEL |
    ...     | alias  | re-use session alias or not (setup/teardown session within KW if not provided) |
    ...
    ...     *Returns*   list of runtime view class items
    ...     | e.g. ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-2', '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1']
    ...
    ...
    [Arguments]   ${gnb_id}=${0}   ${class}={}   ${alias}=${None}
    ${oam_alias}   Run Keyword If   '${alias}'=='${None}'
    ...          connect.Setup OAM Http session   node_type=gnb  node_id=${gnb_id}
    ...   ELSE   Set Variable   ${alias}

    ${item_list}   coam.get_ids_for_all   connection=${oam_alias}   class_name=${class}
    [Return]   ${item_list}
    [Teardown]   Run Keyword If   '${alias}'=='${None}'   connect.Teardown OAM http session

Get Number Of Cells
    [Documentation]
    ...     The KW determines the number of configured cells for the given gNB.
    ...
    ...     | cell_type  | 5G or 4G cell [NRCEL|LNCEL] |
    ...     | connection | optional connection alias |
    ...
    ...     *Returns*   nbr of cells
    ...
    [Arguments]   ${cell_type}=${NRCEL}   ${connection}=${None}
    @{cell_list}   testline-Keywords.Get All Ids Of Class   class=${cell_type}   alias=${connection}
    ${cell_nbr}    Get Length  ${cell_list}
    [Return]   ${cell_nbr}

Fetch Airphone Common Unit Type
    [Documentation]
    ...    Detects type of Airphone common unit eg. ASIK
    ...
    ...    *Scope*  Internal
    ...
    ...    | ue_id | Id of ue (ap) [0.. ] |
    ...
    ...    *Returns*    AP common unit board name
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}
    ${alias_ap_common_unit_identify_device_type}   Connect.Connect to Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${comu_id}
    ${common_unit}   nps_trf_tools.identify_module   connection=${alias_ap_common_unit_identify_device_type}
    Collections.Set To Dictionary   ${P_UE_COMMON_UNIT_TYPE}   ue${ue_id}   ${common_unit}
    Set Suite Variable   ${P_UE_COMMON_UNIT_TYPE}


Fetch Airphone Capacity Unit Type
    [Documentation]
    ...    Detects type of Airphone capacity unit eg. ABIL.
    ...
    ...    *Scope*  Internal
    ...
    ...    | ue_id          | Id of ue [0.. ] |
    ...    | common_unit_id |  Id of Common Unit [0.. ] |
    ...    | capu_id        |         Id of Capacity Unit [0.. ] |
    ...
    ...    *Returns*    AP capacity unit board name
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ${ap_alias}   Connect.Connect to Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${comu_id}
    ${capa_unit_type}   nps_trf_tools.identify_module   connection=${ap_alias}    capu_id=${capu_id}
    Collections.Set To Dictionary   ${P_UE_CAPA_UNIT_TYPE}   ap${ue_id}_CM${comu_id}_CA${capu_id}   ${capa_unit_type}

# -------COAM---------------------------------------------------------------------------------------------------------------------------------------
Wait until Node to be onair state
    [Documentation]
    ...     Wait for Node to be onAir, checked via oam interface.
    ...     Currently checks cell on air for 1 DU/comu.
    ...
    ...     | node_id        | Id/Number of Node (eNB|gNB) |
    ...     | node_type      | Node type; possible values: (gnb|enb) |
    ...     | timeout        | time till gNB must be on air |
    ...     | retry_interval | Time to wait next retry. |
    ...
    [Arguments]    ${node_id}=${0}   ${node_type}=gnb   ${timeout}=600s   ${retry_interval}=20s
    ${cell_type}   Set Variable    nr
    ${class_name}   Set Variable   NRCEL
    ${oam_alias}    connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ${list_cells}   testline-Keywords.Get All Ids Of Class   alias=${oam_alias}   class=${class_name}
    ${num_of_cells}   Get Length   ${list_cells}
    Run Keyword If    ${num_of_cells} < 1   FAIL   No ${class_name} configured!
    ${status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   ${timeout}   ${retry_interval}
    ...   testline-Keywords.Verify That NR Cells Are Onair With COAM   oam_alias=${oam_alias}   num_of_cells=${num_of_cells}   type=${cell_type}
    Return From Keyword If   ${status}   ${status}

    ${active_alarms}   admin.get active alarms   connection=${oam_alias}
    ${nbr_alarms}   Get Length   ${active_alarms}
    Collections.Log List   ${active_alarms}
    BuiltIn.Log   ${node_type}_${node_id} has ${nbr_alarms} active alarm(s), check log file for further info!   console=${P_console}
    FAIL   KW 'Verify that NR cells are onair with COAM' failed!

Verify That NR Cells Are Onair With COAM
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${oam_alias}   ${num_of_cells}   ${type}=nr
    ${internal_cell_list}   testline-Keywords.Get list of cells onair   ${oam_alias}   ${num_of_cells}  ${type}
    ${list_length}   Get Length   ${internal_cell_list}
    Should Be Equal As Integers   ${list_length}   ${num_of_cells}   msg=${list_length} of ${num_of_cells} cell(s) onAir!

Get List Of Cells Onair
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    ...     *Returns* list of onair cells
    ...
    [Arguments]   ${oam_alias}   ${num_of_cells}  ${type}
    ${internal_cell_list}   Create List
    FOR   ${cell_id}   IN RANGE   ${num_of_cells}
       ${setup_state}   ${_internal_cell_dist_id}   Run Keyword And Ignore Error
       ...   coam_nps.Verify cOAM Cell Setup
       ...   alias=${oam_alias}   cell_id=${cell_id}   cell_type=${type}   use_cache=${True}
       Run keyword If   '${setup_state}'=='PASS'   Collections.Append To List   ${internal_cell_list}   ${_internal_cell_dist_id}
    END
    [Teardown]   Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}
    [Return]     ${internal_cell_list}

Get Number Of All Configured NRCELLs
    [Documentation]
    ...    This KW returns the number of all configured NRCELLs, which can be used to check cell setup
    ...
    ...     *Scope*  Internal
    ...
    ${total_cells}   Set Variable   ${0}
    ${gnb_num}       Get Length    ${tl.gnbs}
    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
        ${status}    ${number_of_cells}    Run Keyword and ignore error    testline-Keywords.Get Number Of Cells     cell_type=NRCEL
        ...                                                                                                          connection=coam_gnb
        IF     '${status}'=='FAIL'
            ${oam_alias}         connect.Setup OAM Http session   node_id=${gnb_id}    node_type=gnb
            ${number_of_cells}   testline-Keywords.Get Number Of Cells     cell_type=NRCEL   connection=${oam_alias}
            connect.Teardown OAM http session     node_id=${gnb_id}    node_type=gnb
        END
        ${total_cells}       Evaluate   ${total_cells} + ${number_of_cells}
    END
    [Return]   ${total_cells}

Get File Path on Target
    [Documentation]
    ...
    ...    | file_pattern | file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz |
    ...    | connection   | alias name |
    ...
    ...    *Returns* file_path
    [Arguments]    ${file_pattern}    ${connection}
    ${output}=    ssh.execute    ls ${file_pattern}    connection=${connection}
    ${file_path}=    String.Strip String    ${output}
    [Return]    ${file_path}

Get RU Info from TargetBD
    [Arguments]    ${ru_type}=AEQE
    ${gnb_alias}=    connect.Connect to gNB Capacity Unit
    ${file_path}=    testline-Keywords.Get File Path on Target    file_pattern=/ffs/run/TargetBD*ENB*.xml    connection=${gnb_alias}
    ssh.download file    remote_path=${file_path}    local_path=${configuration_directory}/TargetBD.xml    connection=${gnb_alias}
    ssh.disconnect    ${gnb_alias}
    ${ru_version}  ${frm_sw}    nps_trf_tools.get_values_from_targetbd    ${configuration_directory}/TargetBD.xml    ${ru_type}
    [Return]    ${ru_version}    ${frm_sw}

Get Topology from Common Agent File OLD VERSION
    [Arguments]    ${file_path}=/home/ute/testline_init_results/agent.log
    ${file_content}           OperatingSystem.Get File    ${file_path}
    ${label_from_install}     Should Match Regexp         ${file_content}    LABEL:\\s+(\\S+)
    ${variant_from_install}   Should Match Regexp         ${file_content}    VARIANT:\\s+(\\S+)
    Set Suite Variable        ${TOPOLOGY_LABEL}           ${label_from_install[1]}
    Set Suite Variable        ${TOPOLOGY_VARIANT}         ${variant_from_install[1]}
    Set Suite Metadata        Topology [Common Agent]     ${TOPOLOGY_LABEL}
    Set Suite Metadata        Variant [Common Agent]      ${TOPOLOGY_VARIANT}

Get Topology from Common Agent File
    [Arguments]    ${file_path}=/opt/ute/reservation.context.json
    ${status}  ${ret}    Run Keyword and ignore error    nps_trf_tools.Get Topology from Reservation Context File    ${file_path}
    IF    '${status}'=='FAIL'
        BuiltIn.log    Get Topology from Reservation Context File FAIL!!!    ERROR
        Set Suite Metadata        Topology [Common Agent]     Unknown
        Set Suite Metadata        Variant [Common Agent]      Unknown
        Set Suite Variable        ${TOPOLOGY_LABEL}           Unknown
        Set Suite Variable        ${TOPOLOGY_VARIANT}         Unknown
    ELSE
        ${TOPOLOGY_LABEL}    set variable   ${ret[0]}
        ${TOPOLOGY_VARIANT}  set variable   ${ret[1]}
        Set Suite Metadata        Topology [Common Agent]     ${TOPOLOGY_LABEL}
        Set Suite Metadata        Variant [Common Agent]      ${TOPOLOGY_VARIANT}
        Set Suite Variable        ${TOPOLOGY_LABEL}
        Set Suite Variable        ${TOPOLOGY_VARIANT}
    END

Get AP Capacity Slave IP
    [Documentation]
    ...    Calculate Capacity Unit IP depending on slave a(master)|b|loner.
    ...
    ...    | ue_id   | Id of ue [0.. ] |
    ...    | comu_id | Id of Common Unit [0..1] |
    ...    | capu_id | Id of Capacity Unit [0..5] |
    ...    | slave   | Name of Slave of Capacity unit (a|b|phoner) |
    ...
    ...    *Returns*    slave_ip (Ip of Slave on capacity unit)
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}   ${slave}=a
    ${slave_ip}   Run Keyword If   $slave=='a'   Set Variable
    ...             ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}
    ...   ELSE IF   $slave=='b'   tools.increment_ip
    ...             ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}   factor=1
    ...   ELSE IF   $slave=='phoner'    tools.increment_ip
    ...           ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}   factor=2
    ...   ELSE    Fail   Unknown Capacity Unit Slave name. Must a|b|phoner
    RETURN   ${slave_ip}

Identify Interface With IP
    [Documentation]
    ...    Searches for the network interface by the given ``ip`` on a local or remote host depending whether
    ...    or not ``connection`` is given.
    ...
    ...    | ip | the ip address for which the corrosponding interface name needs to be found |
    ...    | connection | optional alias for a ssh connection to a remote host on which the interface name has to be determined |
    ...
    ...    *Returns* interface name, None if nothing found
    ...
    [Arguments]   ${ip}   ${connection}=${None}
    ${cl_output}   Run Keyword If   '${connection}'=='${None}'
    ...          OperatingSystem.Run   ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}
    ...   ELSE   ssh.execute  ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}   connection=${connection}   timeout=30s

    @{words}     String.Split String   ${cl_output}
    ${if_name}   Run Keyword And Ignore Error   Set Variable   ${words[0]}
    ${interface_name}   Set Variable If   $if_name[0]=='PASS'   ${if_name[1]}
    RETURN   ${interface_name}

Update SW Config file on AP System Module
    [Documentation]
    ...    This KW connects to the ``comu_id`` of the Airphone given by ``ue_id`` and
    ...    sets the RND params given by ``param_list`` in the swconfig.txt.
    ...    The `param_list` is a list of key:value pairs, e.g. ["0x4600BA=6", "0x460002=6"].
    ...
    ...    | param_list | list the update content   |
    ...    | ue_id      | Id of ue                  |
    ...    | ue_comu_id | Id of Common Unit         |
    ...
    [Arguments]   ${param_list}   ${ue_id}=${0}   ${ue_comu_id}=${0}
    ${ap_alias}   connect.Connect to Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${ue_comu_id}
    swconf.download_swConfig_file_from_asik_to_test_pc   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${ap_alias}
    swconf.modify_swConfig_file   parametersList=${param_list}   filePath=/tmp/swconfig_tmp.txt
    swconf.upload_swConfig_file_to_asik_and_crasign   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${ap_alias}

Add RD Parameters in AP swconfig File Exemple
    [Documentation]    Additional AP RD flags
    @{ap_params}=  create list  0x300010=1   # Prevent SW fallback if SCFC validation fails
    Update SW Config file on AP System Module  param_list=${ap_params}
    Set suite variable    ${force_reboot}    ${true}

Update SW Config file on System Module
    [Documentation]
    ...     This keyword sets the rnd params in the swconfig.txt .
    ...
    ...     | param_list     | list the update content, example input can be: ["0x4600BA=6","0x460002=6"] |
    ...     | del_param_list | list the delete content, example input can be: ["0x4600BA","0x460002"] |
    ...     | gnb_id         | Id of gnb [0.. ] |
    ...     | du_id          | Id of DU  [0.. ] |
    ...     | comu_id        | Id of Common Unit [0..1] |
    ...
    [Arguments]   ${param_list}=@{EMPTY}   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${del_param_list}=@{EMPTY}
    ${comu_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${comu_alias}

    Run Keyword If   ${del_param_list} != @{EMPTY}   swconf.delete_parameter_of_swConfig_file
    ...              parametersList=${del_param_list}   filePath=/tmp/swconfig_tmp.txt
    Run Keyword If   ${param_list}!=@{EMPTY}   swconf.modify_swConfig_file
    ...              parametersList=${param_list}   filePath=/tmp/swconfig_tmp.txt

    swconf.upload_swConfig_file_to_asik_and_crasign   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${comu_alias}

Wait For Minimum Required State For AP Cell Setup
    [Documentation]
    ...     Waits until all pre-conditions for cell setup on all or specific cell(s) are reached.
    ...     Utilizes only admin API to check, session setup must be possible within 3min!
    ...
    ...     | node_type     | either gnb or enb (gnb|enb) |
    ...     | node_id       | Id of gNB|eNB [0.. ]        |
    ...     | cell_id       | Id of cell [0..x|all]       |
    ...     | ru_id         | Id of RU [0..x|all]         |
    ...     | timeout       | TO for individual checks    |
    ...     | kw_timeout    | overall TO for the whole KW |
    ...     | skip_F1_check | boolean switch to skip checking for successful F1Setup prior to checking for \
    ...                       cells reaching configured state. Set to False by default. |
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}   ${cell_id}=all   ${ru_id}=all   ${timeout}=5min   ${kw_timeout}=60min
    ...           ${skip_F1_check}=${False}    ${skip_oam_connection}=${True}
    [Timeout]     ${kw_timeout}
    BuiltIn.Log     [ INFO ] Waiting until node ${node_type}_${node_id} is ready for Cell Setup ...   console=True
    IF     ${skip_oam_connection}
        ${oam_alias}    set variable    coam_gnb
    ELSE
        ${oam_alias}    connect.Setup OAM Http session   node_type=${node_type}   node_id=${node_id}
    END

    Wait Until Keyword Succeeds   ${timeout}   20s   testline-Keywords.Get BTS Active Sync Source   alias=${oam_alias}
    Wait Until Keyword Succeeds   ${timeout}   20s   testline-Keywords.Verify Single BTS is Configured   connection=${oam_alias}

    Run Keyword If  '${ru_id}'=='all'   Wait Until Keyword Succeeds   ${timeout}   20s
    ...             testline-Keywords.Verify All Radios are Online    connection=${oam_alias}
    ...   ELSE      Wait Until Keyword Succeeds   ${timeout}   20s
    ...             testline-Keywords.Verify Single Radio is Online   connection=${oam_alias}    ru_id=${ru_id}

    Run Keyword If  '${node_type}'=='gnb' and not ${skip_F1_check}   testline-Keywords.Wait Until F1 Link Up   gnb_id=${node_id}  timeout=${timeout}

    Run Keyword If  '${cell_id}'=='all'   Wait Until Keyword Succeeds   ${timeout}   20s
    ...             testline-Keywords.Verify All Cells are Configured  node_type=${node_type}   connection=${oam_alias}
    ...   ELSE      Wait Until Keyword Succeeds   ${timeout}   20s
    ...             testline-Keywords.Verify Single Cell is Configured   node_type=${node_type}   connection=${oam_alias}   cell_id=${cell_id}

    # Sleep   10s   reason=problems with cell setup on AP

Wait For Minimum Required State For Cell Setup For All gNBs
    [Documentation]
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]   ${timeout}=10min
    FOR   ${gnb_id}   ${_}   IN ENUMERATE   ${tl.gnbs}
       testline-Keywords.Wait For Minimum Required State For AP Cell Setup   node_id=${gnb_id}   timeout=${timeout}
    END

Get BTS Active Sync Source
    [Documentation]
    ...     Get Active Sync source from BTS
    ...
    ...     | sync_mode   | BTS Sync mode |
    ...     | tuning_mode | BTS Sync status i.e Normal or Holdover |
    ...     | alias       | AdminConnection object or if used, string name alias |
    ...
    ...     *Returns*   active synchronisation status dictionary
    ...
    [Arguments]              ${sync_mode}=PhaseSync      ${tuning_mode}=Normal tuning    ${alias}=cOAM
    ${bts_sync_status}       admin.get_bts_sync_source_status      connection=${alias}
    ${bts_tuningMode}        Get From Dictionary                  ${bts_sync_status}         tuningMode
    coam_nps.Nidd Value Should be Equal  ${bts_tuningMode}                 ${tuning_mode}
    ${bts_syncMode}          Get From Dictionary                  ${bts_sync_status}         syncMode
    coam_nps.Nidd Value Should be Equal  ${bts_syncMode}                   ${sync_mode}
    ${syncSourceInfo}        Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
    ${active_sync_dict}      create dictionary
    FOR    ${sync}    IN    @{syncSourceInfo}
        ${sync_status}          Get From Dictionary   ${sync}        isActive
        ${active_sync_dict}     set variable if   '${sync_status}' == 'True'      ${sync}
        Run Keyword If          '${sync_status}' == 'True'     Exit For Loop
        ...     ELSE            BuiltIn.Log  [INFO] BTS sync status isActive: ${sync_status}   console=True
    END
    should not be empty      ${active_sync_dict}
    nps_trf_tools.log_to_console_with_time_prefix     BTS sync status isActive : ${active_sync_dict['isActive']}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix     BTS sync syncInputType : ${active_sync_dict['syncInputType']}     level=INFO
    [Return]                 ${active_sync_dict}

Verify Single BTS is Configured
    [Documentation]
    ...     Checks if gNB is Configured.
    ...
    ...     | connection | connection alias |
    ...
    [Arguments]   ${connection}={}
    ${bts_state}   admin.Get Mrbts State   connection=${connection}
    # BuiltIn.Log    [INFO] BTS STATE : ${bts_state}   console=${P_console}
    nps_trf_tools.log_to_console_with_time_prefix     BTS STATE : ${bts_state}    level=INFO
    coam_nps.Nidd Value Should be One Of   ${bts_state}   Configured, IntegratedToRan, onAir

Get All Class Items
    [Documentation]
    ...     Returns the list of items for the given class configured for the given gNB.
    ...
    ...     *Scope* Internal
    ...
    ...     | gnb_id | Id of gNB [0..] |
    ...     | class  | Class name you get items for [“SMOD”,“RMOD”,“TRX”,“WNCEL”,“DSP”,“ASIRMOD”,“NRCEL”] |
    ...     | alias  | re-use session alias or not, if not provided setup/teardown session within KW |
    ...
    ...     *Returns*   list of class items, but the list item content is class dependend!
    ...     | e.g. [{name': 'RMOD_R-1', 'ipAddress': '172.22.8.2'}, {'name': 'RMOD_R-2', 'ipAddress': '172.22.8.154'}]
    ...     | or   ['SMOD_R-1']
    ...     | or   ['NRCELL_R-1', 'NRCELL_R-2']
    ...     https://onion.wroclaw.nsn-rdnet.net/branches/master/cli-docs/tutorial-getListOfItemsByClassName.html
    ...
    [Arguments]   ${gnb_id}=${0}   ${class}={}   ${alias}=${None}
    @{class_list}   Create List   SMOD  RMOD  TRX  WNCEL  DSP  ASIRMOD  NRCEL

    Collections.List Should Contain Value   ${class_list}   ${class}
    ...   msg=Class '${class}' isn't supported, must be one of '${class_list}'!

    ${oam_alias}   Run Keyword If   '${alias}'=='${None}'
    ...          connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    ...   ELSE   Set Variable    ${alias}

    ${item_list}   admin.Get All Items By Class Name   connection=${oam_alias}   class_name=${class}
    RETURN   ${item_list}

Get Number Of RMOD
    [Documentation]
    ...     Retrieves the number of connected RMODs for the given gNB.
    ...
    ...     | gnb_id     | Id of gNB [0..] |
    ...     | connection | optional connection alias |
    ...
    ...     *Returns*   nbr of radio modules
    ...
    [Arguments]   ${gnb_id}=${0}   ${connection}=${None}
    ${rmod_names}   Create List
    @{rmod_list}    Get All Class Items   gnb_id=${gnb_id}   class=RMOD   alias=${connection}

    FOR   ${rmod}   IN   @{rmod_list}
       Collections.Append To List   ${rmod_names}   ${rmod['name']}
    END

    ${rmod_nbr}   Get Length   ${rmod_names}
    RETURN   ${rmod_nbr}

Verify All Radios are Online
    [Documentation]
    ...     Checks if  all RU/rmod are Online.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     | connection | connection alias |
    ...
    [Arguments]   ${connection}={}
    ${number_of_radios}   Get Number of RMOD   connection=${connection}
    FOR   ${ru_id}   IN RANGE   ${number_of_radios}
       testline-Keywords.Verify Single Radio is Online   connection=${connection}   ru_id=${ru_id}   use_cache=${True}
    END
    [Teardown]   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${None}

Verify Single Radio is Online
    [Documentation]
    ...     Checks if a given RU/rmod is Online.
    ...     Utilizes only coam M-plane based API to check it.
    ...     *Note* Don't forget to unset the cache container var P_CACHED_FRM_STATUS if caching is True!
    ...
    ...     | connection | connection alias |
    ...     | ru_id      | Id of RU [0.. ]  |
    ...     | use_cache  | use global cache container [False|True] |
    ...
    [Arguments]   ${connection}={}   ${ru_id}=0   ${use_cache}=${False}
    ${cache_is_filled}   Get Variable Value   ${P_CACHED_FRM_STATUS[${ru_id}]['productName']}

    ${frm_info}   Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   admin.Get Frm   connection=${connection}

    Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${frm_info}

    ${radio_state}   coam_nps.Get avaiabilityStatus from Status Dictionary   ${P_CACHED_FRM_STATUS[${ru_id}]['status']}
    BuiltIn.Log   [ INFO ] ${P_CACHED_FRM_STATUS[${ru_id}]['id']['configuration']} : availabilityStatus=${radio_state}   console=True
    coam_nps.Nidd availabilityStatus Value Should Be One Of   ${P_CACHED_FRM_STATUS[${ru_id}]['status']}   Degraded, Online
    [Teardown]   Run keyword If   '${use_cache}'=='${False}'   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${None}

Wait Until F1 Link Up
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0   ${timeout}=5min
    Wait Until Keyword Succeeds   ${timeout}   10s   testline-Keywords.Verify F1 Status   gnb_id=${gnb_id}

Verify F1 Status
    [Documentation]
    ...     check F1 link on GNB
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${master_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}

    ${cpif_log}     Run Keyword     ssh.execute   xzgrep -i 'f1 setup successful' /tmp/node_CPRT*/tmp/startup_cp_rt.log*
    ...                                           connection=${master_alias}   timeout=30s

    Should Not Contain   ${cpif_log}   No such file or directory   ignore_case=True
    ${status}    ${result}=    Run Keyword And ignore error    Should Contain       ${cpif_log}   f1 setup successful     ignore_case=True
    ...   msg=[INFO] F1 link is down for gnb${gnb_id}!   values=${False}
    Run Keyword If    '${status}' == 'FAIL'
    ...    Run Keywords    nps_trf_tools.log_to_console_with_time_prefix   WARNING: F1 link is down for gnb${gnb_id}!    level=WARN
    ...       AND          Fail    The log does not contain the expected message: ${result}
    Run Keyword If    '${status}' == 'PASS'    nps_trf_tools.log_to_console_with_time_prefix     F1 link for gnb${gnb_id} is up!    level=INFO

Verify All Cells are Configured
    [Documentation]
    ...     Checks if all cell are configured.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     | connection | connection alias |
    ...     | node_type  | either gnb or enb, defines the cell type (nr or lte) |
    ...
    [Arguments]   ${connection}={}   ${node_type}=gnb
    ${number_of_cells}  Run Keyword If  '${node_type}'=='gnb'  testline-Keywords.Get Number of Cells  cell_type=NRCEL  connection=${connection}
    ...                 ELSE IF         '${node_type}'=='enb'  testline-Keywords.Get Number of Cells  cell_type=LNCEL  connection=${connection}
    ...                 ELSE                                   FAIL     Unsupported node_type ${node_type}!
    BuiltIn.Log         Fetch number of cells for node ${node_type}: ${number_of_cells} found.   console=True
    FOR     ${cell_id}      IN RANGE   ${number_of_cells}
            testline-Keywords.Verify Single Cell is Configured   node_type=${node_type}  connection=${connection}  cell_id=${cell_id}
            ...                                                  use_cache=${True}
    END
    [Teardown]  Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}

Verify Single Cell is Configured
    [Documentation]
    ...     Checks if a given cell is configured or 'not initialized'.
    ...     Utilizes only coam M-plane based API to check it.
    ...     As eNB/LTE cells don't support procedural status we check then availability  status instead.
    ...     *Note* Don't forget to unset the cache container var P_CACHED_CELL_STATUS if caching is True!
    ...
    ...     | connection | connection alias |
    ...     | cell_id    | Id of cell [0.. ] |
    ...     | use_cache  | use global cache container [False|True] |
    ...     | node_type  | either gnb or enb, defines the cell type [gnb|enb] |
    ...
    [Arguments]   ${connection}={}   ${cell_id}=0   ${use_cache}=${False}   ${node_type}=gnb
    ${cell_type}   Set Variable If   '${node_type}'=='gnb'                            nr
    ...                              '${node_type}'=='enb'                            lte
    ...                              '${node_type}'!='gnb' and '${node_type}'!='enb'  unknown

    ${cache_is_filled}   Get Variable Value   ${P_CACHED_CELL_STATUS[${cell_id}]['id']['internal']}
    ${cell_info}   Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   admin.Get Cells Info   connection=${connection}   cell_type=${cell_type}

    Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   Set Suite Variable    ${P_CACHED_CELL_STATUS}   ${cell_info}

    ${check_status}   Run Keyword If   '${node_type}'=='gnb'
    ...               Set Variable   ${P_CACHED_CELL_STATUS[${cell_id}]['status']['proceduralStatus']}
    ...   ELSE        Set Variable  ${P_CACHED_CELL_STATUS[${cell_id}]['status']}

    BuiltIn.Log   [ INFO ] ${P_CACHED_CELL_STATUS[${cell_id}]['id']['configuration']} : ${check_status}   console=True
    Run Keyword If   '${node_type}'=='gnb'   coam_nps.Nidd Value Should be One Of   ${check_status}   Configured, not initialized
    ...   ELSE       coam_nps.Nidd availabilityStatus Value Should Be One Of   ${check_status}   Offline, Online, Degraded
    [Teardown]   Run keyword If   '${use_cache}'=='${False}'   Set Suite Variable   ${P_CACHED_CELL_STATUS}   ${None}
