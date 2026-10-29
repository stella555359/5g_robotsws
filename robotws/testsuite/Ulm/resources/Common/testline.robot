*** Settings ***

Documentation     Keywords related to testline handling
...

Library    String
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    XML

Library    taf.sbts.oam.coam.admin                               WITH NAME    admin
Library    taf.transport.ssh                                     WITH NAME    ssh
Library    taf.hw.pdu                                            WITH NAME    pdu
Library    taf.config.testline.info.testline_info.TestlineInfo   WITH NAME    testline_info
Library    python/gnb.py                                         WITH NAME    gnb_py
Library    python/testline.py                                    WITH NAME    testline_py
Library    python/ip_utils.py                                    WITH NAME    iputils
Library    python/testline_information.py

Resource   connect.robot

*** Variables ***
&{P_COMMON_UNIT_TYPE}      &{EMPTY}
&{P_UE_COMMON_UNIT_TYPE}   &{EMPTY}
&{P_UE_CAPA_UNIT_TYPE}     &{EMPTY}
&{P_CAPA_UNIT_TYPE}        &{EMPTY}
&{P_GNBSWVERSION}          &{EMPTY}
${P_TL_NAME}               ${EMPTY}
${P_console}               ${False}

*** Keywords ***
Create Test Suite Log Folders
    [Documentation]
    ...    Create Log & Config folders for Test Suite.
    ...    Must be used as first keyword at Suite Setup
    ...
    ...    *Note* Keyword will fail if GNB doesn't work
    ...
    Get Test Suite Result Base Directory
    Get Test Suite Log Directory
    Get Test Suite Config Directory


Create Testcase Log Directory
    [Documentation]
    ...    Create Log folder for each testcase, should be used at testcase setup.
    ...    TestCase folder will be automatically created when KW "Get Testcase Log Directory" is used.
    ...    legacy: return should not be used
    ...
    ${resultSuiteBaseDir}   Get Test Suite Result Base Directory
    ${P_resultTestDir}   Set Variable    ${resultSuiteBaseDir}/${TEST_NAME}
    ${P_resultTestDir}   String.Replace String   ${P_resultTestDir}   search_for=${SPACE}   replace_with=_

    OperatingSystem.Create Directory   ${P_resultTestDir}

    Set Test Variable   ${P_resultTestDir}
    RETURN   ${P_resultTestDir}


Get Test Suite Result Base Directory
    [Documentation]
    ...    Check if Log base directory exists,
    ...    if not it will created it automatically.
    ...
    ...    *Returns* path for Log base folder
    ...
    ${P_resultSuiteBaseDir}   Get Variable Value   ${P_resultSuiteBaseDir}
    IF   '${P_resultSuiteBaseDir}'=='None'   Create Test Suite Result Base Directory
    RETURN   ${P_resultSuiteBaseDir}


Get Test Suite Log Directory
    [Documentation]
    ...    Returns path for TestSuite log directory,
    ...    if Testsuite Log directory does not exist it will created automatically.
    ...
    ...    *Returns* Path for TestSuite log folder
    ...
    ${P_resultSuiteLogDir}   Get Variable Value   ${P_resultSuiteLogDir}
    IF   '${P_resultSuiteLogDir}'=='None'   Create Test Suite Log Directory
    RETURN   ${P_resultSuiteLogDir}


Get Test Suite Config Directory
    [Documentation]
    ...    Returns folder for TestSuite config, if TestSuite config folder
    ...    does not exist it will created automatically.
    ...
    ...    *Returns* Path for Testsuites logs
    ...
    ${P_resultSuiteConfigDir}    Get Variable Value    ${P_resultSuiteConfigDir}
    IF   '${P_resultSuiteConfigDir}'=='None'   Create Test Suite Config Directory
    RETURN   ${P_resultSuiteConfigDir}


Get Testcase Log Directory
    [Documentation]
    ...    Returns path for Testcase log directory, if Testcase Log directory
    ...    does not exist it will created automatically.
    ...
    ...    *Returns* Path for Testcase log
    ...
    ${P_resultTestDir}   Get Variable Value   ${P_resultTestDir}
    IF   '${P_resultTestDir}'=='None'   Create Testcase Log Directory
    RETURN   ${P_resultTestDir}


Get Test Suite Directory
    [Documentation]
    ...    Returns path for current test suite on running system.
    ...
    ...    *Returns* Path for current test suite
    ...
    ${suiteDir}   ${_}   String.Split String From Right   ${SUITE SOURCE}   separator=/   max_split=1
    RETURN   ${suiteDir}


Get Workspace Directory
    [Documentation]
    ...    Returns path to local repository root folder.
    ...
    ...    *Returns* Path to repository
    ...
    ${separator}   Set Variable If
    ...   'robotws/' in '${SUITE SOURCE}'     robotws
    ...   'Auto5G' in '${SUITE SOURCE}'       Auto5G
    ${workspaceDir}    ${_}    String.Split String    ${SUITE SOURCE}    separator=${separator}    max_split=1
    RETURN   ${workspaceDir}${separator}


Check TL Infos
    [Documentation]
    ...    Check needed TL information, can be accessed by Get KWs,
    ...    should be used at Suite Setup.
    ...
    IF   ${tl.gnbs != None}
        ${gnb_num}    Get Length       ${tl.gnbs}
    ELSE
        ${gnb_num}    Set Variable     ${0}
    END
    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
        Log    ${tl_info.deployment_type(node_id=${gnb_id}, node_type='gnb')}
        testline.Get OAM Type         gnb_id=${gnb_id}
        testline.Get GNB SW Version   gnb_id=${gnb_id}
    END

    IF   ${tl.ues != None}
        ${ue_num}    Get Length       ${tl.ues}
    ELSE
        ${ue_num}    Set Variable     ${0}
    END
    FOR   ${ue_id}   IN RANGE   ${ue_num}
        Get UE Type   ue_id=${ue_id}
    END

    IF   ${tl.core != None}   testline.Get Core Type

    IF   ${tl.enbs != None}
        ${enb_num}    Get Length       ${tl.enbs}
    ELSE
        ${enb_num}    Set Variable     ${0}
    END
    FOR   ${enb_id}   IN RANGE   ${enb_num}
        Log   ${tl_info.deployment_type(node_id=${enb_id}, node_type='enb')}
    END


Get GNB SW Version
    [Documentation]
    ...    Reads active software from gNB via OAM.
    ...
    ...    *Note:* sw version is fetch only once
    ...
    ...    | gnb_id | Id/Number of gNB |
    ...    | du_id  | Id/Number of DU |
    ...
    ...    *Returns* active Software version on gNB
    ...
    # robocop: off=unused-argument
    [Arguments]   ${gnb_id}=0   ${du_id}=0
    ${gnb_sw_version}   Get Variable Value   ${P_GNBSWVERSION.gnb_${gnb_id}}
    IF   '${gnb_sw_version}'=='None'   Fetch Current GNB SW Version   gnb_id=${gnb_id}
    RETURN   ${P_GNBSWVERSION.gnb_${gnb_id}}


Get GNB SW Branch
    [Documentation]
    ...    Fetch the prefix gNB SW branch.
    ...
    ...    | gnb_id | Id/Number of gNB |
    ...    | du_id  | Id/Number of DU |
    ...
    ...    *Returns* active Software branch on gNB (e.g SBTS23R1)
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0
    ${gnb_sw_version}   Get GNB SW Version   ${gnb_id}   ${du_id}=0

    IF          'SBTS' in '${gnb_sw_version}'
        ${gNB_branch}   String.Split String From Right    ${gnb_sw_version}    _    4
    ELSE
        ${gNB_branch}   String.Split String From Right    ${gnb_sw_version}    .    1
    END

    RETURN   ${gNB_branch}[0]


Get Node Deployment Type
    [Documentation]
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the BTS (classical, simulated)
    ...
    ...    *Note:* supports classical and simulated (wts based)
    ...
    ...    | node_type | type of node, either gnb or enb |
    ...    | node_id   | Id/Number of node |
    ...
    ...    *Returns* type of BTS    (classical|simulated)
    ...
    [Arguments]   ${node_id}=0   ${node_type}=gnb
    ${bts_type}   Set Variable If
    ...   $tl.${node_type}s[${node_id}].__class__.__name__=='ClassicalBts'   classical
    ...   $tl.${node_type}s[${node_id}].__class__.__name__=='RealEnb'        classical
    ...   $tl.${node_type}s[${node_id}].__class__.__name__=='LTEEmuEnb'      simulated
    RETURN   ${bts_type}


Get Airphone SW Version
    [Documentation]
    ...    Reads active software from Airphone.
    ...
    ...    | ue_id | Id/Number of UE |
    ...
    ...    *Returns* active Software version on Airphone
    ...
    [Arguments]  ${ue_id}=0
    ${ap_alias}   connect.Connect To Airphone Common Unit   ue_id=${ue_id}
    ${ap_version}   Get Common Unit SW Version   alias=${ap_alias}
    RETURN   ${ap_version}


Get UE Type
    [Documentation]
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the UE (airphone|qualcomm|mediatek|iphy).
    ...
    ...    | ue_id | Id/Number of UE |
    ...
    ...    *Returns* type of UE    (e.g. qualcomm, airphone)
    ...
    [Arguments]   ${ue_id}=0
    ${ueType}   Set Variable If
    ...   $tl.ues[${ue_id}].__class__.__name__=='Airphone'       airphone
    ...   $tl.ues[${ue_id}].__class__.__name__=='Simulator'      airphone
    ...   $tl.ues[${ue_id}].__class__.__name__=='TafUeAndroid'   android
    ...   $tl.ues[${ue_id}].__class__.__name__=='TafUeMtk'       mediatek
    ...   $tl.ues[${ue_id}].__class__.__name__=='MediaTek'       mediatek
    ...   $tl.ues[${ue_id}].__class__.__name__=='Android'        qualcomm
    ...   $tl.ues[${ue_id}].__class__.__name__=='Qualcomm'       qualcomm
    ...   $tl.ues[${ue_id}].__class__.__name__=='iphy'           iphy
    ...   ${True}                                                $tl.ues[${ue_id}].__class__.__name__
    RETURN   ${ueType}


Get OAM Type
    [Documentation]
    ...    This KW is used to determine which OAM interface the gnb supports.
    ...
    ...    *Note*  This KW is deprecated, it is recommended to use tl_info.deployment_type() instead!
    ...
    ...    | gnb_id | Id/Number of gNB |
    ...
    ...    *Returns* type of OAM
    ...
    [Arguments]   ${gnb_id}=0
    ${oam_type}   Set Variable If
    ...   $tl_info.deployment_type(${gnb_id})=='classical'   coam
    ...   ${True}                                            unknown
    RETURN   ${oam_type}


Get Core Type
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
    RETURN   ${coreType}


Get ENB SW Version
    [Documentation]
    ...    Returns the running enb software version if the testline object has tl.enb configured.
    ...
    ...    | enb_id | Id/Number of eNB |
    ...
    ...    *Returns* active Software version on eNB
    ...
    [Arguments]   ${enb_id}=0
    ${enb}   Get Variable Value   ${tl.enbs[${enb_id}]}
    ${is_RealEnb_Object}   testline_py.Is Realenb   ${enb}
    IF   not ${is_RealEnb_Object}
        ${oam_alias}    Set Variable    ${None}
        RETURN   ${EMPTY}
    END

    ${oam_alias}   connect.Setup OAM HTTP Session  node_id=${enb_id}  node_type=enb
    ${enbSwVersion}   admin.Get SW Version   connection=${oam_alias}
    RETURN   ${enbSwVersion}
    [Teardown]    Teardown Real ENB Object    is_RealEnb_Object=${is_RealEnb_Object}    oam_alias=${oam_alias}

Teardown Real ENB Object
    [Arguments]     ${is_RealEnb_Object}    ${oam_alias}
    IF   ${is_RealEnb_Object}    Run Keyword And Ignore Error   admin.Teardown    connection=${oam_alias}


Get Capacity Slave IP
    [Documentation]
    ...    Calculate Capacity Unit IP depending on slave a(master)|b|loner.
    ...
    ...    | gnb_id  | Id of gnb [0.. ] |
    ...    | du_id   | Id of DU [0.. ] |
    ...    | comu_id | Id of Common Unit [0..1] |
    ...    | capu_id | Id of Capacity Unit [0..5] |
    ...    | slave   | Id of Slave of Capacity unit (0|1|2) |
    ...
    ...    *Returns*    slave_ip (Ip of Slave on capacity unit)
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}   ${slave}=0
    ${comu_type}   Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${comu_id}
    IF   $comu_type in ['ASOE', 'ASOH', 'ASOG']
            Log To Console   ${\n}KW 'Get Capacity Slave IP' is not applicable for ASOE, ASOH and ASOG!
            RETURN
    END

    ${gnb_comu_alias}   connect.Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ${board_id}   Evaluate   int(${capu_id}) + 1
    ${slave_ip}   testline_py.Get CPU IP   connection=${gnb_comu_alias}   board_id=${board_id}   cpu_id=${slave}

    iputils.Should Be Valid IP     ${slave_ip.strip()}

    RETURN   ${slave_ip.strip()}


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

    IF          $slave=='a'
        ${slave_ip}     Set Variable                ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}
    ELSE IF     $slave=='b'
        ${slave_ip}     testline_py.Increment IP    ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}   factor=1
    ELSE IF     $slave=='phoner'
        ${slave_ip}     testline_py.Increment IP    ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}   factor=2
    ELSE
        Fail   Unknown Capacity Unit Slave name. Must a|b|phoner
    END
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

    IF   '${connection}'=='${None}'
        ${cl_output}    OperatingSystem.Run   ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}
    ELSE
        ${cl_output}    ssh.Execute  ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}   connection=${connection}   timeout=30s
    END
    @{words}     String.Split String   ${cl_output}
    ${if_name}   Run Keyword And Ignore Error   Set Variable   ${words[0]}
    ${interface_name}   Set Variable If   $if_name[0]=='PASS'   ${if_name[1]}
    RETURN   ${interface_name}


Get Testline Name
    [Documentation]
    ...     Returns the name of testline base on testline config path
    ...     robot -V config/Ulm/TL26 tescase.robot
    ...     'Get Testline Name' returns TL26
    ...
    ...     *Returns*  testline name
    ...

    IF   $P_TL_NAME==''
        ${tl_name}      testline_py.Get Testline
    ELSE
        ${tl_name}      Set Variable   ${P_TL_NAME}
    END
    Set Global Variable   ${P_TL_NAME}   ${tl_name}
    RETURN   ${tl_name}


Set Console Output
    [Documentation]
    ...    Enable/Disable Console output. This defines the value of the global variable P_console.
    ...    This variable could be used with -v to control the output from robot command line!
    ...
    ...    | Output | ${True} to enable console output of common keywords, ${False} disable output |
    ...
    [Arguments]   ${Output}=${True}
    Set Global Variable   ${P_console}   ${Output}


Get Common Unit Type
    [Documentation]
    ...    Detects and returns type of gnb common unit eg. ASIL.
    ...
    ...    | gnb_id         | Id of gnb [0.. ] |
    ...    | du_id          | Id of DU [0.. ] |
    ...    | common_unit_id | Id of Common Unit [0.. ] |
    ...
    ...    *Returns*    gnb common unit HW board name
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}
    ${common_unit}   Get Variable Value   ${P_COMMON_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}}

    IF   '${common_unit}'=='None'   Fetch Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${common_unit_id}
    RETURN   ${P_COMMON_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}}


Get Airphone Common Unit Type
    [Documentation]
    ...    Detects and returns type of Airphone common unit eg. ASIL.
    ...
    ...    | ue_id | Id of ue(ap) [0.. ] |
    ...
    ...    *Returns*    AP common unit HW board name
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}
    ${common_unit}   Get Variable Value   ${P_UE_COMMON_UNIT_TYPE.ue${ue_id}}

    IF   '${common_unit}'=='None'   Fetch Airphone Common Unit Type   ue_id=${ue_id}   comu_id=${comu_id}
    RETURN   ${P_UE_COMMON_UNIT_TYPE.ue${ue_id}}


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

    IF   '${capa_unit}'=='None'   Fetch Airphone Capacity Unit Type   ue_id=${ue_id}   comu_id=${comu_id}   capu_id=${capu_id}
    RETURN   ${P_UE_CAPA_UNIT_TYPE.ap${ue_id}_CM${comu_id}_CA${capu_id}}


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
    IF   '${capa_unit}'=='None'  Fetch Capacity Unit Type  gnb_id=${gnb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}  capu_id=${capu_id}
    RETURN   ${P_CAPA_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}}


Power Cycle UE
    [Documentation]
    ...     Performs a power off/on cycle for the given `ue_id`. The off duration is specified by `time_interval`.
    ...
    ...     *Note*  Currently only supports AirPhone
    ...
    [Arguments]   ${ue_id}=${0}   ${common_unit_id}=${0}   ${time_interval}=10
    ${pdu}        Set Variable   ${tl.ues[${ue_id}].l1.common_units[${common_unit_id}].pdu_port.pdu}
    ${pdu_port}   Set Variable   ${tl.ues[${ue_id}].l1.common_units[${common_unit_id}].pdu_port.port_no}
    PDU Power Reset   ${pdu}   ${pdu_port}   time_interval=${time_interval}


Get All Ids Of Class
    [Documentation]
    ...     Returns the list of item ids for the given class in runtime view
    ...     for the given gNB.
    ...
    ...     *Scope* Internal
    ...
    ...     | node_id | Id of gNB or eNB [0..] |
    ...     | node_type | type of BTS node ('gnb' or 'enb'). Will assume node_type 'gnb' by default. |
    ...     | class  | Class name you get items for, e.g. LNCEL, NRCEL |
    ...     | alias  | re-use session alias or not (setup/teardown session within KW if not provided) |
    ...
    ...     *Returns*   list of runtime view class items
    ...     | e.g. ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-2', '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1']
    ...
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${class}={}   ${alias}=${None}

    IF   '${alias}'=='${None}'
        ${oam_alias}    connect.Setup OAM HTTP Session   node_type=${node_type}  node_id=${node_id}
    ELSE
        ${oam_alias}    Set Variable   ${alias}
    END

    ${item_list}   admin.Get IDs For All   connection=${oam_alias}   class_name=${class}
    RETURN   ${item_list}
    [Teardown]    Teardown OAM HTTP Session If Alias Is Not None    alias=${alias}


Teardown OAM HTTP Session If Alias Is Not None
    [Arguments]     ${alias}=${None}
    IF   '${alias}'=='${None}'   Teardown OAM HTTP Session


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

    IF   '${alias}'=='${None}'
        ${oam_alias}     connect.Setup OAM HTTP Session   node_type=gnb   node_id=${gnb_id}
    ELSE
        ${oam_alias}    Set Variable   ${alias}
    END


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
    @{rmod_list}    Get All Class Items   gnb_id=${gnb_id}   class=RMOD   alias=${connection}
    RETURN   ${{ len($rmod_list) }}


Get Number Of Cells
    [Documentation]
    ...     The KW determines the number of configured cells for the given gNB.
    ...
    ...     | cell_type    | 5G or 4G cell [NRCEL|LNCEL] |
    ...     | connection   | optional connection alias |
    ...     | fail_if_zero | optional boolean flag to make keyword fail (when setting fail_if_zero=${True})
    ...                      or to not fail (fail_if_zero=${False} default), even is  number of cells is zero  |
    ...
    ...     *Returns*   nbr of cells
    ...
    [Arguments]   ${cell_type}=${NRCEL}   ${connection}=${None}    ${fail_if_zero}=${False}
    @{cell_list}   Get All Ids Of Class   class=${cell_type}   alias=${connection}
    ${cell_nbr}    Get Length  ${cell_list}

    IF   ${{${fail_if_zero} == True}} and ${cell_nbr == 0}     Fail   The number of cells of type ${cell_type} is zero!

    RETURN   ${cell_nbr}


Get Number Of All Configured NRCELLs
    [Documentation]
    ...    This KW returns the number of all configured NRCELLs, which can be used to check cell setup
    ...
    ...     *Scope*  Internal
    ...
    ${total_cells}   Set Variable   ${0}
    ${gnb_num}       Get Length    ${tl.gnbs}
    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
        ${oam_alias}         connect.Setup OAM HTTP Session   node_type=gnb     node_id=${gnb_id}
        ${number_of_cells}   testline.Get Number Of Cells     cell_type=NRCEL   connection=${oam_alias}
        ${total_cells}       Evaluate   ${total_cells} + ${number_of_cells}
    END
    RETURN   ${total_cells}


Create Test Suite Result Base Directory
    [Documentation]
    ...
    ...    *Scope*  Internal
    ...
    ...    example: Testsuite_name/SW_load/timestamp
    ...    legacy: return should not be used

    IF   ${{$tl.gnbs is not None}}
        ${gnbSwVersion}     testline.Get GNB SW Version
    ELSE
        ${gnbSwVersion}     testline.Get ENB SW Version
    END
    ${timeStamp}      DateTime.Get Current Date   exclude_millis=True   result_format=%Y%m%d_%H%M%S

    ${P_resultSuiteBaseDir}   Set Variable   ${OUTPUT_DIR}/${SUITE_NAME}/${gnbSwVersion}/${timeStamp}
    ${P_resultSuiteBaseDir}   String.Replace String   ${P_resultSuiteBaseDir}   search_for=${SPACE}   replace_with=_

    OperatingSystem.Create Directory   ${P_resultSuiteBaseDir}

    Set Suite Variable   ${P_resultSuiteBaseDir}

    OperatingSystem.Create File   ${OUTPUT_DIR}/robotReportTargetDir.txt   ${P_resultSuiteBaseDir}
    RETURN   ${P_resultSuiteBaseDir}


Create Test Suite Log Directory
    [Documentation]
    ...    Creates global Logs directory for the running test suite.
    ...    Naming rule: ${OUTPUT_DIR}/${SUITE_NAME}/${gnbSwVersion}/${timeStamp}/Logs
    ...    legacy: return should not be used
    ...
    ...    *Scope*  Internal
    ...
    ${resultSuiteBaseDir}   Get Test Suite Result Base Directory

    Set Suite Variable   ${P_resultSuiteLogDir}   ${resultSuiteBaseDir}/Logs

    OperatingSystem.Create Directory   ${P_resultSuiteLogDir}
    RETURN   ${P_resultSuiteLogDir}


Create Test Suite Config Directory
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
    RETURN   ${P_resultSuiteConfigDir}


Fetch Current GNB SW Version
    [Documentation]
    ...    Fetches the running gnb SW version from target and stores it in a global dictionary
    ...    P_GNBSWVERSION. The key naming rule is gnb_${gnb_id}.
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${alias}            connect.Setup OAM HTTP Session      node_id=${gnb_id}
    ${gnb_sw_version}   gnb_py.Fetch Classical SW Version   alias=${alias}
    Collections.Set To Dictionary   ${P_GNBSWVERSION}   gnb_${gnb_id}   ${gnb_sw_version}
    Set Suite Variable   ${P_GNBSWVERSION}
    RETURN   ${gnb_sw_version}


Get Common Unit SW Version
    [Documentation]
    ...    Used to get GNB/Airphone SW on board
    ...
    ...    *Note*    for classical gNB only!
    ...
    ...    *Scope*  Internal
    ...
    ...    | alias       | ssh connnection alias to common unit board |
    ...    | xml_element | for SBTS load  softwareReleaseVersionFlexiRel3 |
    ...
    ...    *Returns* software version
    ...
    [Arguments]   ${alias}   ${xml_element}=cbtsSoftwareReleaseVersion
    ssh.Force Reconnect   ${alias}
    ssh.Send Command   cat /ffs/run/Target*xml   connection=${alias}
    ${cmd_output}    ssh.Read Output   connection=${alias}
    ${parsed_xml}    XML.Parse XML    ${cmd_output}
    ${software}      XML.Get Element Attribute   ${parsed_xml}   ${xml_element}


    IF   'SBTS' in '${software}'
        ${sw_version}   testline_py.Reform COAM SW Version   ${software}
    ELSE
        ${sw_version}   String.Fetch From Right   ${software}   marker=_
    END
    RETURN   ${sw_version}


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
    ${alias_gnb_common_unit_identify_device_type}   connect.Connect To Node Common Unit
    ...   node_id=${gnb_id}   du_id=${du_id}   comu_id=${common_unit_id}
    ${common_unit}   testline_py.Identify Module   connection=${alias_gnb_common_unit_identify_device_type}
    Collections.Set To Dictionary   ${P_COMMON_UNIT_TYPE}   gNB${gnb_id}_DU${du_id}_CM${common_unit_id}   ${common_unit}
    Set Suite Variable   ${P_COMMON_UNIT_TYPE}


Fetch Airphone Common Unit Type
    [Documentation]
    ...    Detects type of Airphone common unit eg. ASIL.
    ...
    ...    *Scope*  Internal
    ...
    ...    | ue_id | Id of ue (ap) [0.. ] |
    ...
    ...    *Returns*    AP common unit board name
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}
    ${alias_ap_common_unit_identify_device_type}   Connect.Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${comu_id}
    ${common_unit}   testline_py.Identify Module   connection=${alias_ap_common_unit_identify_device_type}
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
    ${ap_alias}   Connect.Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${comu_id}
    ${capa_unit_type}   testline_py.Identify Module   connection=${ap_alias}   capu_id=${capu_id}
    Collections.Set To Dictionary   ${P_UE_CAPA_UNIT_TYPE}   ap${ue_id}_CM${comu_id}_CA${capu_id}   ${capa_unit_type}


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
    ...    | common_unit_id | Id of Common Unit [0.. ] |
    ...    | capu_id        | Id of Capacity Unit [0.. ] |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}   ${capu_id}=${0}
    ${comu_type}   Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${common_unit_id}

    IF   $comu_type in ['ASOE', 'ASOG', 'ASOH']
            Log To Console        ${\n}ASOE has no Capacity Unit!
            Collections.Set To Dictionary    ${P_CAPA_UNIT_TYPE}   gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}   ${None}
            Set Suite Variable    ${P_CAPA_UNIT_TYPE}
            RETURN   ${P_CAPA_UNIT_TYPE}
    END

    ${capu_alias}   Connect To GNB Capacity Unit   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${common_unit_id}
    ...   capu_id=${capu_id}   slave=${0}

    ${capa_unit_type}   testline_py.Identify Module   connection=${capu_alias}   capu_id=${capu_id}
    Set To Dictionary   ${P_CAPA_UNIT_TYPE}   gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}   ${capa_unit_type}
    Set Suite Variable   ${P_CAPA_UNIT_TYPE}


PDU Power Reset
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
    ${pdu_alias}   pdu.Setup PDU   ${pdu}
    ${pdu_ports}   Create List   ${pdu_port}
    pdu.Reset Ports   ports=${pdu_ports}   time_interval=${time_interval}   pdu_device=${pdu_alias}


Get PDU Power Status
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
    ${pdu_alias}     pdu.Setup PDU   ${pdu}
    ${port_status}   pdu.Get Port Status   port=${pdu_port}   pdu_device=${pdu_alias}
    RETURN   ${port_status}
