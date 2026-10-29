*** Settings ***

Documentation     Keywords related to testline handling
...               :Author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com

Library    String
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    XML
Library    taf.sbts.oam.coam.admin             WITH NAME    admin
Library    taf.gnb.oam.coam.cu                WITH NAME    coam_cu
Library    taf.transport.ssh                  WITH NAME    ssh
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.pdu                            WITH NAME    pdu
Library    ute_fsmaccess
Library    ../python/Testline.py               WITH NAME    testline
Library    ../python/Gnb.py                    WITH NAME    gnb_lib
Resource   Connect.robot

*** Variables ***
&{P_UETYPE}             &{EMPTY}
&{P_GNBTYPE}            &{EMPTY}
&{P_COMMON_UNIT_TYPE}   &{EMPTY}
&{P_CAPA_UNIT_TYPE}     &{EMPTY}
&{P_OAMTYPE}            &{EMPTY}
&{P_CORETYPE}           &{EMPTY}
&{P_GNBSWVERSION}       &{EMPTY}
&{P_attenuators}        &{EMPTY}
${P_TL_NAME}            ${EMPTY}
${P_console}            ${False}

*** Keywords ***
Get GNB initial config path
    [Documentation]        :Author: Masiar Makkinejad
    ...                    used to retrieve the full storage path of the SCF config file, that is to be applied for the
    ...                    current testline and the current SW branch during the Robot Testsuite Teardown phase of
    ...                    test runs on Common CRT testlines of Pz Ulm Tribe (SyVe). This reset of the commissioning at
    ...                    the end of each Testsuite execution shall assure, that the next Testsuite execution running
    ...                    on the same testline, can assume a known and defined initial configuration as stored at
    ...                    the path returned by this keyword.
    ...                    The keyword takes the logical ID of the GNB of the current testline as input parameter. The
    ...                    current SW branch information is fetched from the target.
    ...    :param gnb_id:  logical ID of the GNB on the current testline, for which the full storage path shall be
    ...                    returned. Allowed range is [0 .. (maxNumGnbInTlConfig-1)]. Default value is 0.
    ...    :param du_id:   (optional) logical ID of the DU on the gNB. Only needed in case of cloudBTS testlines
    ...    :param config_path:   (optional) default is /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    ...    ${config_path}=/mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    ${tl_name}=    testline.Get Testline Name
    ${sw_branch}=    testline.Get gNB SW Branch    gnb_id=${gnb_id}    du_id=${du_id}
    ${sw_branch_adapted}=    Set Variable If    'SBTS00_ENB_9999' in '${sw_branch}'    5G_0.800    ${sw_branch}
    ${inital_scf_path}=    set variable    ${config_path}/${sw_branch_adapted}/${tl_name}/GNB-${gnb_id}/scf.xml
    File Should Exist    ${inital_scf_path}
    ...  The initial SCF for GNB-${gnb_id} of Common CRT testline '${tl_name}' doesn't exist at path \n'${inital_scf_path}'\nPlease create it first!
    [Return]    ${inital_scf_path}


Get ENB initial config path
    [Documentation]        :Author: Amr Aboushehata
    ...                    used to retrieve the full storage path of the SCF config file, that is to be applied for the
    ...                    current testline and the current SW branch during the Robot Testsuite Teardown phase of
    ...                    test runs on Common CRT testlines of Pz Ulm Tribe (SyVe). This reset of the commissioning at
    ...                    the end of each Testsuite execution shall assure, that the next Testsuite execution running
    ...                    on the same testline, can assume a known and defined initial configuration as stored at
    ...                    the path returned by this keyword.
    ...                    The keyword takes the logical ID of the ENB of the current testline as input parameter. The
    ...                    current SW branch information is fetched from the target.
    ...    :param enb_id:  logical ID of the ENB on the current testline, for which the full storage path shall be
    ...                    returned. Allowed range is [0 .. (maxNumEnbInTlConfig-1)]. Default value is 0.
    ...    :param config_path:   (optional) default is /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    [Arguments]    ${enb_id}=0
    ...    ${config_path}=/mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    ${tl_name}=    testline.Get Testline Name
    ${sw_branch}=    testline.Get eNB SW Branch    enb_id=${enb_id}
    ${sw_branch_adapted}=    Set Variable If    'ENB_9999' in '${sw_branch}'    5G_0.800    ${sw_branch}
    ${inital_scf_path}=    set variable    ${config_path}/${sw_branch_adapted}/${tl_name}/ENB-${enb_id}/scf.xml
    File Should Exist    ${inital_scf_path}
    ...  The initial SCF for ENB-${enb_id} of Common CRT testline '${tl_name}' doesn't exist at path \n'${inital_scf_path}'\nPlease create it first!
    [Return]    ${inital_scf_path}

Set eNB cell attenuation
    [Documentation]    :Author: Vasileios Papoutsis
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param ru_id: (default=0) Id/Number of radio module
    ...    :param port_id: (default=0) Id/Number of port of radio module
    [Arguments]    ${value_in_db}    ${enb_id}=${0}    ${ru_id}=${0}    ${port_id}=${0}
    ${attenuation_port}=    Set variable    ${tl.enbs[${enb_id}].rms[${ru_id}].attenuation_ports[${port_id}]}
    Set cell attenuation    attenuation_port=${attenuation_port}    value_in_db=${value_in_db}
    BuiltIn.Log    Attenuation of eNB${enb_id} RM${ru_id} port${attenuation_port.port_no} is set to ${value_in_db}dB
    ...    console=${P_console}


Set gNB cell attenuation
    [Documentation]    :Author: Vasileios Papoutsis
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param ru_id: (default=0) Id/Number of radio unit
    ...    :param port_id: (default=0) Id/Number of port of radio unit
    [Arguments]    ${value_in_db}    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}    ${port_id}=${0}
    ${attenuation_port}=    Set variable    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].attenuation_ports[${port_id}]}
    Set cell attenuation    attenuation_port=${attenuation_port}    value_in_db=${value_in_db}
    BuiltIn.Log    Attenuation of gNB${gnb_id} DU${du_id} RU${ru_id} port${attenuation_port.port_no} is set to ${value_in_db}dB
    ...    console=${P_console}


Set eNB all ports attenuation
    [Documentation]    :Author: Michele
    ...    :iterate the ports of HBTE Highly Beyond The Expectation defined in __init__.py file
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param ru_id: (default=0) Id/Number of radio unit
    [Arguments]    ${value_in_db}    ${enb_id}=${0}    ${ru_id}=${0}
    ${Att_port_num}=    Get length    ${tl.enbs[${enb_id}].rms[${ru_id}].attenuation_ports}
    FOR    ${Att_port_id}    IN RANGE    ${Att_port_num}
          Set eNB cell attenuation    value_in_db=${value_in_db}    enb_id=${enb_id}    ru_id=${ru_id}    port_id=${Att_port_id}
    END

Set gNB all ports attenuation
    [Documentation]    :Author: Michele
    ...    :iterate the ports of HBTE Highly Beyond The Expectation defined in __init__.py file
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param ru_id: (default=0) Id/Number of radio unit
    [Arguments]    ${value_in_db}   ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    ${Att_port_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].attenuation_ports}
    FOR    ${Att_port_id}    IN RANGE    ${Att_port_num}
        Set gNB cell attenuation    value_in_db=${value_in_db}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}    port_id=${Att_port_id}
    END

Attenuate all cells in testline
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    attenuate all cells in a testline
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${off_value}=${95}
    ${enb_num}=    Get length    ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enb_num}
        Set attenuation to all 4G RMs   enb_id=${enb_id}    off_value=${off_value}
    END
    ${gnb_num}=    Get length    ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Set attenuation to all 5G DUs   gnb_id=${gnb_id}    off_value=${off_value}
    END

Set attenuation to all 4G RMs
    [Documentation]    :Author: Michele
    ...    attenuate all cells in 4G eNB
    ...    :param enb_id: id of eNB to be attenuated
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${enb_id}    ${off_value}=${95}
    ${rm_num}=    Get length    ${tl.enbs[${enb_id}].rms}
    FOR    ${ru_id}    IN RANGE    ${rm_num}
        Set eNB all ports attenuation    value_in_db=${off_value}    enb_id=${enb_id}    ru_id=${ru_id}
    END

Set attenuation to all 5G DUs
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    attenuate all cells in 5G gNB
    ...    :param gnb_id: id of gNB to be attenuated
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${gnb_id}    ${off_value}=${95}
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Set attenuation to all 5G radio units    ${gnb_id}     ${du_id}    ${off_value}
    END

Set attenuation to all 5G radio units
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    attenuate all cells in 5G gNB DU
    ...    :param gnb_id: id of gNB to be attenuated
    ...    :param du_id: id of DU to be attenuated
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${gnb_id}     ${du_id}     ${off_value}=${95}
    ${ru_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus}
    FOR    ${ru_id}    IN RANGE    ${ru_num}
        Set gNB all ports attenuation    value_in_db=${off_value}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
    END

Create Test Suite Log Folders
    [Documentation]    :Author: Jing Liang
    ...    Create Log & Config folders for Test Suite
    ...    Must be used as first keyword at Suite Setup
    ...    [WARNING] Keyword will fail if GNB doesn't work
    Get test suite result base directory
    Get test suite log directory
    Get test suite config directory


Create testcase log directory
    [Documentation]    :Author: Jing Liang
    ...    Create Log folder for each testcase
    ...    Should be used at testcase setup
    ...    TestCase folder will be automatically created when KW "Get testcase log directory" is used
    ...    legacy: return should not be used
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${P_resultTestDir}=    Set variable    ${resultSuiteBaseDir}/${TEST_NAME}
    ${P_resultTestDir}=    Replace string    ${P_resultTestDir}    search_for=${SPACE}    replace_with=_
    Create directory    ${P_resultTestDir}
    Set Test Variable    ${P_resultTestDir}
    [Return]    ${P_resultTestDir}


Get test suite result base directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns path for Log base directory
    ...    If Log base directory does not exist it will created automatically
    ...
    ...    :returns: Path for Log base folder
    ...
    ${P_resultSuiteBaseDir}=    Get Variable Value    ${P_resultSuiteBaseDir}
    Run Keyword If    '${P_resultSuiteBaseDir}'=='None'
    ...    Create test suite result base directory
    [Return]    ${P_resultSuiteBaseDir}


Get test suite log directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns path for TestSuite log directory
    ...    If Testsuite Log directory does not exist it will created automatically
    ...
    ...    :returns: Path for TestSuite log folder
    ...
    ${P_resultSuiteLogDir}=    Get Variable Value    ${P_resultSuiteLogDir}
    Run Keyword If    '${P_resultSuiteLogDir}'=='None'
    ...    Create test suite log directory
    [Return]    ${P_resultSuiteLogDir}


Get test suite config directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns folder for TestSuite config
    ...    If TestSuite config folder does not exist it will created automatically
    ...
    ...    :returns: Path for Testsuites logs
    ...
    ${P_resultSuiteConfigDir}=    Get Variable Value    ${P_resultSuiteConfigDir}
    Run Keyword If    '${P_resultSuiteConfigDir}'=='None'
    ...    Create test suite config directory
    [Return]    ${P_resultSuiteConfigDir}


Get testcase log directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns path for Testcase log directory
    ...    If Testcase Log directory does not exist it will created automatically
    ...
    ...    :returns: Path for Testcase log
    ...
    ${P_resultTestDir}=    Get Variable Value    ${P_resultTestDir}
    Run Keyword If    '${P_resultTestDir}'=='None'
    ...    Create testcase log directory
    [Return]    ${P_resultTestDir}


Get test suite directory
    [Documentation]    :Author: Jing Liang
    ...    Returns path for current test suite on running system
    ...
    ...    :returns: Path for current test suite
    ...
    ${suiteDir}    ${rest}=    Split String From Right    ${SUITE SOURCE}    separator=/    max_split=1
    [Return]    ${suiteDir}


Get Workspace Directory
    [Documentation]    :Author: Jing Liang
    ...    Return path for robotws5g
    ...
    ${separator}=    Set Variable if    'robotws5g' in '${SUITE SOURCE}'    robotws5g    Auto5G
    ${workspaceDir}    ${rest}=    Split String    ${SUITE SOURCE}    separator=${separator}    max_split=1
    [Return]    ${workspaceDir}${separator}


Check TL Infos
    [Documentation]    :Author: Jing Liang
    ...    Check needed TL information, can be accessed by Get KWs
    ...    Should be used at Suite Setup
    ${gnb_num}=    Get length    ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        testline.Get gNB type    gnb_id=${gnb_id}
        testline.Get OAM type    gnb_id=${gnb_id}
        testline.Get gNB SW version    gnb_id=${gnb_id}
    END
    ${ue_num}=    Get length    ${tl.ues}
    FOR    ${ue_id}    IN RANGE    ${ue_num}
        Get UE type    ue_id=${ue_id}
    END

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
    ...    Fetch Current gNB SW Version    gnb_id=${gnb_id}  du_id=${du_id}
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
    @{gNB_branch}    Run Keyword If    'SBTS' in '${gnb_sw_version}'
    ...     Split String From Right    ${gnb_sw_version}    _    4
    ...    ELSE    Split String From Right    ${gnb_sw_version}    .    1
    [Return]    @{gNB_branch}[0]


Get eNB SW Branch
    [Documentation]    :Author: Amr Aboushehata
    ...    Fetch the prefix eNB SW branch
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :return: active Software branch on eNB (e.g 5G_0.800)
    ...
    [Arguments]    ${enb_id}=0  ${du_id}=0
    Log to console   ${du_id}
    ${enb_sw_version}=    Get eNB SW version    ${enb_id}
    ${enb_sw_version_prefix}=    Fetch from left     ${enb_sw_version}     _
    ${eNB_branch}=   set variable if    '_9999_' in '${enb_sw_version}'    SBTS00    ${enb_sw_version_prefix}
    [Return]    ${eNB_branch}

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
    ...    Fetch gNB type    gnb_id=${gnb_id}
    [Return]  ${P_GNBTYPE.gnb_${gnb_id}}


Get Airphone SW version
    [Documentation]    :Author: Jing Liang
    ...    reads active software from Airphone
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :return: active Software version on Airphone
    ...
    [Arguments]  ${ue_id}=0
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}
    ${ap_version}=    Get Common Unit SW Version    alias=${ap_alias}
    [Return]    ${ap_version}


Get UE type
    [Documentation]    :Author: Jing Liang
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


Get OAM type
    [Documentation]    :Author: Jing Liang
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :return: type of OAM    (coam, megazone)
    ...
    [Arguments]    ${gnb_id}=0
    ${oam_type}=    Get Variable Value    ${P_OAMTYPE.gnb_${gnb_id}}
    Run Keyword If    '${oam_type}'=='None'
    ...    Fetch OAM type    gnb_id=${gnb_id}
    [Return]    ${P_OAMTYPE.gnb_${gnb_id}}


Get Core type
    [Documentation]    :Author: Vasileios Papoutsis
    ...    TODO: add wts for simulated 5G core, no entry could be used
    ...
    ...    :return: type of CORE (real, epcsim)
    ...
    ${coreType}=    Get Variable Value    ${P_CORETYPE.core}
    Run Keyword If    '${coreType}'=='None'
    ...    Fetch Core type
    [Return]    ${P_CORETYPE.core}


Get eNB SW Version
    [Documentation]    :Author: Jing Liang
    ...    also work with enb which is connected with other test pc
    ...
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param remote_host: (default=None) ip for remote test pc, tl.test_pcs[*].default_ssh_connection_details.addr
    ...    :param remote_user: (default=None) username for remote test pc, tl.test_pcs[*].default_ssh_connection_details.username
    ...    :param remote_pass: (default=Nome) password for remote test pc, tl.test_pcs[*].default_ssh_connection_details.password
    ...
    ...    :return: active Software version on eNB
    ...
    [Arguments]    ${enb_id}=0    ${remote_host}=${None}    ${remote_user}=ute    ${remote_pass}=ute
    ${enb_check}=    Get Variable Value    ${tl.enbs[${enb_id}]}
    Return From Keyword If    '${enb_check}'=='None'    ${EMPTY}
    ute_fsmaccess.setup_enb_fsm_access    host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}    alias=enb
    ...    remote_host=${remote_host}    remote_ssh_user=${remote_user}    remote_ssh_pass=${remote_pass}
    ${enbSwVersion}=    ute_fsmaccess.get_enb_sw_version    alias=enb
    ute_fsmaccess.teardown_enb_fsm_access    alias=enb
    [Return]    ${enbSwVersion}


Get Capacity Slave IP
    [Documentation]    :Author: Soenke Kullberg
    ...    Calculate Capacity Unit IP depending on slave  a(master)|b|loner
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...    :param slave:       Name of Slave of Capacity unit  a,b,loner       default=a (Master)
    ...    :return slave_ip:   Ip of Slave on capacity unit
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${capu_id}=${0}    ${slave}=a

    ${gnb_comu_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${grep_ipv6_cmd}=    Set Variable    echo "ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}\\:){7}(\\w{1,4})'"
    ${slave_ip}=    Run Keyword If    '${slave}'=='a'    ssh.execute
    ...    command=${grep_ipv6_cmd} | bsh ${${capu_id}+1}:0
    ...    connection=${gnb_comu_alias}
    ...    ELSE IF    '${slave}'=='b'    ssh.execute
    ...    command=${grep_ipv6_cmd} | bsh ${${capu_id}+1}:1
    ...    connection=${gnb_comu_alias}
    ...    ELSE IF    '${slave}'=='loner'    ssh.execute
    ...    command=${grep_ipv6_cmd} | bsh ${${capu_id}+1}:2
    ...    connection=${gnb_comu_alias}
    ...    ELSE    Fail    Unknown Capacity Unit Slave name. Must a|b|loner
    [RETURN]    ${slave_ip.strip()}

Get Common Unit Slave IP
    [Documentation]    :Author: Srihari Janardhan
    ...    Calculate Common Unit Slave IP
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :return slave_ip:   Ip of Slave on common unit
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}
    ${gnb_comu_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${grep_ipv6_cmd}=    Set Variable    echo "ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}\\:){7}(\\w{1,4})'"
    ${slave_ip}=    ssh.execute  command=${grep_ipv6_cmd} | bsh ${${comu_id}}:1  connection=${gnb_comu_alias}
    [RETURN]    ${slave_ip.strip()}


Get AP Capacity Slave IP
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Calculate Capacity Unit IP depending on slave  a(master)|b|loner
    ...
    ...    :param ue_id:       Id of ue                       [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...    :param slave:       Name of Slave of Capacity unit  a,b,phoner       default=a (Master)
    ...    :return slave_ip:   Ip of Slave on capacity unit
    ...
    [Arguments]    ${ue_id}=${0}  ${comu_id}=${0}  ${capu_id}=${0}  ${slave}=a
    ${slave_ip}=  Run Keyword If    '${slave}'=='a'   Set Variable
    ...         ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}
    ...     ELSE IF  '${slave}'=='b'     testline.increment_ip
    ...         ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}   factor=1
    ...     ELSE IF  '${slave}'=='phoner'    testline.increment_ip
    ...         ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}   factor=2
    ...     ELSE            Fail    Unknown Capacity Unit Slave name. Must a|b|phoner
    [RETURN]    ${slave_ip}


Disconnect all available ssh connections
    [Documentation]    :Author: Vasileios Papoutsis
    ...    TODO:  Do we really need this keyword? could go to connect.robot
    ssh.reset_cache


Identify Interface with IP
    [Documentation]  :Author: Srihari Janardhan | The keyword returns the interface name associated with an IP.
    ...    If no interface is found with the corrosponding IP, None is returned
    ...
    ...    :param ip: the ip address for which the corrosponding interface name needs to be found
    ...    :param connection: the alias to an ssh connection to the machine on which the interface name has to be determined
    ...    :return: interface name
    ...
    [Arguments]    ${ip}    ${connection}
    ${cl_output}=    ssh.execute  ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}     connection=${connection}
    @{words}=    Split String    ${cl_output}
    ${if_name}=    Run keyword and ignore error    Set variable    ${words[0]}
    ${interface_name}=    Set variable if    '${if_name[0]}'=='PASS'    ${if_name[1]}
    [Return]    ${interface_name}


Get Testline Name
    [Documentation]  :Author: Soenke Kullberg
    ...     retuns Name of testline base on testline config path
    ...     robot -V config/Ulm/TL26 tescase.robot
    ...     'Get Testline Name' returns TL26
    ...
    ...     :return:  testline_name
    ...
    ${tl_name}=    Run Keyword If    '${P_TL_NAME}'==''    testline.get_testline
    ...    ELSE    Set Variable    ${P_TL_NAME}
    Set Global Variable    ${P_TL_NAME}    ${tl_name}
    [RETURN]        ${tl_name}


Save Current Workspace Info
    [Documentation]    :Author: Jing Liang
    ...    Save robotws5g branch and commit ID information for debugging or reproducing
    ...    Save modified files in robotws5g
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${workspaceDir}=    Get Workspace Directory
    ${output_1}=   Run    cd ${workspaceDir}; git rev-parse --abbrev-ref HEAD
    ${output_2}=   Run    cd ${workspaceDir}; git rev-parse HEAD
    Save Modified Files in Git
    Create file    ${resultSuiteBaseDir}/robotws5gInfo.txt   Working on branch: ${output_1} with Commit-ID ${output_2}


Save current loads
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Save eNB and gNB load to file for reporting after test end
    ...
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param gnb_ids: (default=EMPTY) List of Id/Number of gNBs
    ...
    [Arguments]    ${enb_id}=${0}    ${gnb_ids}=${EMPTY}
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${enbSwVersion}=    testline.Get eNB SW version    enb_id=${enb_id}
    ${gnb_versions}=    Set variable    ${EMPTY}
    @{target_gnb_ids}=    Run keyword if    '${gnb_ids}'=='${EMPTY}'    Create List    ${0}
    ...    ELSE
    ...    Set Variable    ${gnb_ids}
    FOR    ${gnb_id}    IN    @{target_gnb_ids}
        ${gnb_version}=    testline.Get gNB SW version    gnb_id=${gnb_id}
        ${gnb_versions}=    Run keyword if    '${gnb_versions}'!='${EMPTY}'    Catenate    SEPARATOR=;    ${gnb_versions}    ${gnb_version}
        ...    ELSE    Set variable    ${gnb_version}
    END
    Create file    ${resultSuiteBaseDir}/reportingInfo.txt   gNB: ${gnb_versions}\neNB: ${enbSwVersion}


Set Console Output
    [Documentation]    :Author: Soenke Kullberg
    ...    Enable/Disable Console output
    ...
    ...    :param Output:      True(default) enable console output of common keywords, ${False} disable output
    [Arguments]    ${Output}=True
    Set Global Variable     ${P_console}     ${Output}


Identify Common Unit Type
    [Documentation]    :Author: Srihari Janardhan
    ...
    ...    :Detects and returns type of common unit eg. ASIK / ASIB
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param du_id:          Id of DU                        [0.. ]  default=0
    ...    :param common_unit_id:          Id of Common Unit                        [0.. ]  default=0
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}
    ${common_unit}=     Get Variable Value  ${P_COMMON_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}}
    Run Keyword If      '${common_unit}'=='None'
    ...                 Get Common Unit Type    gnb_id=${gnb_id}    du_id=${du_id}      common_unit_id=${common_unit_id}
    [Return]  ${P_COMMON_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}}


Identify Capacity Unit Type
    [Documentation]    :Author: Jing Liang
    ...
    ...    :Detects and returns type of common unit eg. ABIL / ABIO
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param du_id:          Id of DU                        [0.. ]  default=0
    ...    :param common_unit_id: Id of Common Unit               [0.. ]  default=0
    ...    :param capu_id:        Id of Capacity Unit             [0.. ]  default=0
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}  ${capu_id}=${0}
    ${capa_unit}=     Get Variable Value  ${P_CAPA_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}}
    Run Keyword If      '${capa_unit}'=='None'
    ...                 Get Capacity Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${common_unit_id}    capu_id=${capu_id}
    [Return]  ${P_CAPA_UNIT_TYPE.gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}}


Identify L2PS Node ID
    [Documentation]    :Author: Jing Liang
    ...
    ...    :Detects and returns L2RT node ID on capacity unit, node ID is in decimal, to be used in AirPhone Config files
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param du_id:          Id of DU                        [0.. ]  default=0
    ...    :param common_unit_id: Id of Common Unit               [0.. ]  default=0
    ...    :param capu_id:        Id of Capacity Unit             [0.. ]  default=0
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}  ${capu_id}=${0}
    ${comu_alias}=    Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${common_unit_id}
    ${capa_unit_type}=    Identify Capacity Unit Type    gnb_id=${gnb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}  capu_id=${capu_id}
    ${output}=   Run Keyword If    '${capa_unit_type}'=='ABIL'
    ...    ssh.execute    echo "ps -ef | grep CCS_RT | grep nid" | bsh ${${capu_id}+1}:1    connection=${comu_alias}
    ...    ELSE IF    '${capa_unit_type}'=='ABIO'
    ...    ssh.execute    echo "ps -ef | grep CCS_RT | grep L2RT" | bsh ${${capu_id}+1}:0    connection=${comu_alias}
    ...    ELSE    BuiltIn.Log    not supported Capacity Unit    console=${P_console}
    ${node_id}=    identify_node_id    ${output}
    [Return]    ${node_id}

Power Cycle UE
    [Documentation]    :Author: Noli Valdez III
    ...
    ...     :Currently only supports AirPhone
    ...
    [Arguments]    ${ue_id}=${0}    ${common_unit_id}=${0}    ${time_interval}=10
    ${pdu}         Set Variable    ${tl.ues[${ue_id}].l1.common_units[${common_unit_id}].pdu_port.pdu}
    ${pdu_port}    Set Variable    ${tl.ues[${ue_id}].l1.common_units[${common_unit_id}].pdu_port.port_no}
    PDU power reset    ${pdu}    ${pdu_port}    time_interval=${time_interval}

### Private ###
Create test suite result base directory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    example: Testsuite_name/SW_load/timestamp
    ...    legacy: return should not be used
    ${gnbSwVersion}=    testline.Get gNB SW version
    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y%m%d_%H%M%S
    ${P_resultSuiteBaseDir}=    Set variable    ${OUTPUT_DIR}/${SUITE_NAME}/${gnbSwVersion}/${timeStamp}
    ${P_resultSuiteBaseDir}=    Replace string    ${P_resultSuiteBaseDir}    search_for=${SPACE}     replace_with=_
    Create directory    ${P_resultSuiteBaseDir}
    Set Suite Variable    ${P_resultSuiteBaseDir}
    Create file    ${OUTPUT_DIR}/robotReportTargetDir.txt    ${P_resultSuiteBaseDir}
    [Return]    ${P_resultSuiteBaseDir}


Create test suite log directory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    example: Testsuite_name/SW_load/timestamp/Logs
    ...    legacy: return should not be used
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${P_resultSuiteLogDir}=    Set variable    ${resultSuiteBaseDir}/Logs
    Set Suite Variable    ${P_resultSuiteLogDir}
    Create directory    ${P_resultSuiteLogDir}
    [Return]    ${P_resultSuiteLogDir}


Create test suite config directory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    example: Testsuite_name/SW_load/timestamp/Configs
    ...    legacy: return should not be used
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${P_resultSuiteConfigDir}=    Set variable    ${resultSuiteBaseDir}/Configs
    Set Suite Variable    ${P_resultSuiteConfigDir}
    Create directory    ${P_resultSuiteConfigDir}
    [Return]    ${P_resultSuiteConfigDir}


Fetch Current gNB SW Version
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${du_id}=0  ${component}=DU
    ${oam_type}=    Get OAM type    gnb_id=${gnb_id}
    ${gnb_sw_version}=    Run keyword if    '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...    Fetch cloud COAM SW version  gnb_id=${gnb_id}  du_id=${du_id}
    ...    ELSE IF    '${oam_type}'=='coam'    Fetch common OAM SW version    gnb_id=${gnb_id}
    ...    ELSE    Fail    Unknown OAM type !!!
    Set To Dictionary    ${P_GNBSWVERSION}    gnb_${gnb_id}    ${gnb_sw_version}
    Set Suite Variable    ${P_GNBSWVERSION}


Fetch cloud COAM SW version of all DUs
    [Documentation]    [PRIVATE]     get sw version of all cloud coam DUs
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        ${sw_du}   Fetch cloud COAM SW version  gnb_id=${gnb_id}  du_id=${du_id}
        Set To Dictionary    ${P_GNBSWVERSION}    gnb_${gnb_id}_du_${du_id}    ${sw_du}
    END

Fetch cloud COAM SW version of CU
    [Documentation]    [PRIVATE]     get sw version of cloud coam CU
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${gnb_id}=0
    ${oam_alias}=    Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${cu_sw_version}=    coam_cu.get_active_software_version    connection=${oam_alias}
    Set To Dictionary    ${P_GNBSWVERSION}    gnb_${gnb_id}_cu    ${cu_sw_version}
    Teardown OAM session	component=CU    connection=${oam_alias}


Fetch common OAM SW version
    [Documentation]    :Author: Jing Liang
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    admin.connect_to    bts_host=${bts_host}    name=gnb
    ${gnb_sw_version}=    admin.get_sw_version    connection=gnb
    admin.teardown    connection=gnb
    ${gnb_sw_version}=    testline.reform_coam_sw_version    ${gnb_sw_version}
    [Return]    ${gnb_sw_version}


Fetch cloud COAM SW version
    [Documentation]    :Author: Srihari Janardhan
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${du_id}=0  ${component}=DU
    ${bts_host_ip}=    gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    ${gnb_sw_version}=  Run Keyword if  '${component}'=='DU'  Fetch common OAM SW version  gnb_id=${gnb_id}
    ...  bts_host=${bts_host_ip}
    [Return]    ${gnb_sw_version}


Fetch gNB type
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${gnb_type}=    Set Variable If
    ...    '${tl.gnbs[${gnb_id}].__class__.__name__}'=='CloudBts'        cloud
    ...    '${tl.gnbs[${gnb_id}].__class__.__name__}'=='ClassicalBts'    classical
    Set To Dictionary    ${P_GNBTYPE}    gnb_${gnb_id}    ${gnb_type}
    Set Suite Variable    ${P_GNBTYPE}


Fetch UE type
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${ue_id}=0
    ${ueType}=    Set Variable If
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'TM500'   viavi
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Android'    qualcomm
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Airphone'    airphone
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Prisma'    prisma
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'Qualcomm'    qualcomm
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'MediaTek'    mediatek
    ...    '${tl.ues[${ue_id}].__class__.__name__}' == 'iphy'    iphy
    Set To Dictionary    ${P_UETYPE}    ue_${ue_id}    ${ueType}
    Set Suite Variable    ${P_UETYPE}


Fetch OAM type
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${gnb_type}=    Get gNB type    gnb_id=${gnb_id}
    Run Keyword if    '${gnb_type}'=='classical'    Set To Dictionary    ${P_OAMTYPE}    gnb_${gnb_id}    coam
    Return From Keyword If   '${gnb_type}'=='classical'
    ${output}=    OperatingSystem.Run    nc -w 1 -zv ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr} 3600
    ${oam_type}=    testline.identify_oam_type    cmd_output=${output}
    Set To Dictionary    ${P_OAMTYPE}    gnb_${gnb_id}    ${oam_type}
    Set Suite Variable    ${P_OAMTYPE}


Fetch Core type
    [Documentation]    :Author: Vasileios Papoutsis
    ...    [PRIVATE]
    ${coreType}=    Set Variable If
    ...    '${tl.core.__class__.__name__}' == 'RealCore4G'   real
    ...    '${tl.core.__class__.__name__}' == 'EPCSim'    epcsim
    ...    '${tl.core.__class__.__name__}' == 'LTEEmuCore'    lte_core
    ...    '${tl.core.__class__.__name__}' == 'RealCore5G'   real
    Set To Dictionary    ${P_CORETYPE}    core    ${coreType}
    Set Suite Variable    ${P_CORETYPE}


Save Modified Files in Git
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${workspaceDir}=    Get Workspace Directory
    ${modifiedFiles}=    Run    cd ${workspaceDir}; git ls-files -m
    ${modifiedFiles}=    Replace String    ${modifiedFiles}    search_for=\n    replace_with=${SPACE}
    Run Keyword If    '${modifiedFiles}'!=''
    ...    Run    cd ${workspaceDir}; tar czvf ${resultSuiteBaseDir}/modifedFiles.tgz ${modifiedFiles}


Get RU SW Version from TargetBD
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    To get RU SW version from GNB, used for testline with Airphone
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param ru_type:        TODO shoud get from init        default=AEQA
    ...
    ...    :return ru_version:    e.g. 5GL39.11.R04
    ...    :return frm_fpga:      e.g. FRM-FPGA_110310_935370A7.LAR
    ...    :return frm_sw:        e.g. FRM-SW_110310_EAE00FD6.LAR
    ...
    [Arguments]    ${gnb_id}=0    ${ru_type}=AEQA
    ${ru}=   Fetch From Left     ${ru_type}      _
    ${asik_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}
    ${file_path}=    Get File Path on Target    file_pattern=/ffs/run/TargetBD*.xml    connection=${asik_alias}
    Should not contain      ${file_path}    Permission denied     ignore_case=True    msg=Cannot access TargetBD file
    ${ru_version}=    ssh.execute    sed -nr 's/.*${ru}.*SWVersion\="([A-Z0-9\.]+)".*/\\1/p' ${file_path}    connection=${asik_alias}
    ${frm_fpga}=    ssh.execute    sed -nr 's/.*>LTX_${ru}_(FRM-FPGA.*)<.*/\\1/p' ${file_path}    connection=${asik_alias}
    ${frm_sw}=    ssh.execute    sed -nr 's/.*>LTX_${ru}_(FRM-SW.*)<.*/\\1/p' ${file_path}    connection=${asik_alias}
    ${ru_version}=    Strip String    ${ru_version}
    ${frm_fpga}=      Strip String    ${frm_fpga}
    ${frm_sw}=        Strip String    ${frm_sw}
    ssh.disconnect    ${asik_alias}
    [Return]    ${ru_version}    ${frm_fpga}    ${frm_sw}


Get Common Unit SW Version
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    used to get GNB/Airphone SW on board
    ...    :param alias:               ssh connnection alias to common unit board
    ...    :param xml_element:         default cbtsSoftwareReleaseVersion,   for SBTS load  softwareReleaseVersionFlexiRel3
    ...    :return: software version
    [Arguments]    ${alias}    ${xml_element}=cbtsSoftwareReleaseVersion
    ssh.Force Reconnect    ${alias}
    ssh.send command    cat /ffs/run/Target*xml   connection=${alias}
    ${cmd_output}=    ssh.read output   connection=${alias}
    ${parsed_xml}=    parse xml    ${cmd_output}
    ${software}=    get element attribute    ${parsed_xml}    ${xml_element}
    ${sw_version}=    testline.reform_coam_sw_version    ${software}
    Return From Keyword If    'SBTS' in '${sw_version}'    ${sw_version}
    ${rest}    ${sw_version}=    Split String    ${software}    separator=_
    [Return]    ${sw_version}


Get Common Unit Type
    [Documentation]    :Author: Torsten Dieckmann
    ...
    ...    [PRIVATE]    Detects and returns type of common unit eg. ASIK / ASIB
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param du_id:          Id of DU                        [0.. ]  default=0
    ...    :param common_unit_id:          Id of Common Unit                        [0.. ]  default=0
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}
    ${alias_gnb_common_unit_identify_device_type}=  Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${common_unit_id}
    ${output}=  ssh.execute  timeout 1 sysinfo | grep ID_00_MODULE_ID_  connection=${alias_gnb_common_unit_identify_device_type}
    ${common_unit}=   identify_module  sysinfo_extract=${output}
    Set To Dictionary       ${P_COMMON_UNIT_TYPE}    gNB${gnb_id}_DU${du_id}_CM${common_unit_id}    ${common_unit}
    Set Suite Variable      ${P_COMMON_UNIT_TYPE}


Get Capacity Unit Type
    [Documentation]    :Author: Torsten Dieckmann
    ...
    ...    [PRIVATE]    Detects and returns type of common unit eg. ABIL / ABIO
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param du_id:          Id of DU                        [0.. ]  default=0
    ...    :param common_unit_id: Id of Common Unit               [0.. ]  default=0
    ...    :param capu_id:        Id of Capacity Unit             [0.. ]  default=0
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}  ${capu_id}=${0}
    ${comu_alias}=    Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${common_unit_id}
    ${output}=    ssh.execute    echo "timeout 0.1 sysinfo | grep ID_00_MODULE_ID_" | bsh ${${capu_id}+1}:0    connection=${comu_alias}
    ${capa_unit_type}=    identify_module    sysinfo_extract=${output}
    Set To Dictionary       ${P_CAPA_UNIT_TYPE}    gNB${gnb_id}_DU${du_id}_CM${common_unit_id}_CA${capu_id}    ${capa_unit_type}
    Set Suite Variable      ${P_CAPA_UNIT_TYPE}


Set cell attenuation
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...
    ...    :param attenuation_port: Attenuation port object
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...
    [Arguments]    ${attenuation_port}    ${value_in_db}
    ${value_in_db}=    Convert to Integer    ${value_in_db}
    ${existing_attenuator_device}=    Check if attenuator is already setup
    ...    attenuator_ip=${attenuation_port.attenuator.ip_addr}
    ${random}=    Evaluate    random.randint(0, 10000)    modules=random, sys
    ${attenuator_device}=    Run keyword if    '${existing_attenuator_device}'=='None'    attenuator.setup_attenuator
    ...    attenuator=${attenuation_port.attenuator}
    ...    alias=attenuator_device_${random}
    ...    ELSE
    ...    Set variable    ${existing_attenuator_device}
    Run keyword if    '${existing_attenuator_device}'=='None'    Set to dictionary    ${P_attenuators}
    ...    ${attenuation_port.attenuator.ip_addr}=${attenuator_device}
    attenuator.set_attenuation    port=${attenuation_port.port_no}    value=${value_in_db}    attenuator_device=${attenuator_device}
    ${attenuation}=    attenuator.read_attenuation    port=${attenuation_port.port_no}    attenuator_device=${attenuator_device}
    Should be equal    ${attenuation}    ${value_in_db}


Check if attenuator is already setup
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...
    ...    :param attenuator_ip: IP of the attenuator
    ...
    [Arguments]    ${attenuator_ip}
    ${attenuator_ips}=    Get dictionary keys    ${P_attenuators}
    ${count}=    Get match count    ${attenuator_ips}    ${attenuator_ip}
    ${attenuator_device}=    Run keyword if    '${count}'!='${0}'    Get from dictionary    ${P_attenuators}    ${attenuator_ip}
    [Return]    ${attenuator_device}


PDU power reset
    [Documentation]         :Author: Furkan Tombul
    ...    [PRIVATE]       used to reset a device which is connected to PDU
    ...    :param pdu:      pdu object from testline config,
    ...    e.g. tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu, tl.pdus[0]
    ...    :param pdu_port:    Port on the PDU: Bank A - Port 1 -> Port 6, Bank B - Port 7 -> Port 12
    ...    Hint: Activate SMNP settings on PDU
    ...    :param time_interval: number of seconds to wait between OFF/ON actions, defaults to 10
    [Arguments]    ${pdu}    ${pdu_port}    ${time_interval}=10
    ${pdu_alias}=    pdu.setup pdu    ${pdu}
    ${pdu_ports}    Create list    ${pdu_port}
    pdu.reset_ports    ports=${pdu_ports}    time_interval=${time_interval}    pdu_device=${pdu_alias}
