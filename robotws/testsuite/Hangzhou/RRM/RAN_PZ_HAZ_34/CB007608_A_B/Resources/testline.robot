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
Library    ./python/testline.py               WITH NAME    testline
Resource   ./connect.robot

*** Variables ***
&{P_UETYPE}          &{EMPTY}
&{P_GNBTYPE}         &{EMPTY}
&{P_OAMTYPE}         &{EMPTY}
&{P_CORETYPE}        &{EMPTY}
&{P_GNBSWVERSION}    &{EMPTY}
&{P_attenuators}     &{EMPTY}
${P_TL_NAME}         ${EMPTY}
${P_console}         ${False}

*** Keywords ***


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
    ...    :returns: Path for Log base folder
    ${P_resultSuiteBaseDir}=    Get Variable Value    ${P_resultSuiteBaseDir}
    Run Keyword If    '${P_resultSuiteBaseDir}'=='None'
    ...    Create test suite result base directory
    [Return]    ${P_resultSuiteBaseDir}

Get testcase log directory
    [Documentation]    :Author: Jing Liang
    ...    Retuns path for Testcase log directory
    ...    If Testcase Log directory does not exist it will created automatically
    ...    :returns: Path for Testcase log
    ${P_resultTestDir}=    Get Variable Value    ${P_resultTestDir}
    Run Keyword If    '${P_resultTestDir}'=='None'
    ...    Create testcase log directory
    [Return]    ${P_resultTestDir}


Get gNB SW version
    [Documentation]    :Author: Jing Liang
    ...    reads active software from gNB via OAM
    ...    *Note:* sw version is fetch only once
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id:  (default=0) Id/Number of DU
    ...    :return: active Software version on gNB
    [Arguments]    ${gnb_id}=0  ${du_id}=0
    ${gnb_sw_version}=    Get Variable Value    ${P_GNBSWVERSION.gnb_${gnb_id}}
    Run Keyword If    '${gnb_sw_version}'=='None'
    ...    Fetch Current gNB SW Version    gnb_id=${gnb_id}  du_id=${du_id}
    [Return]    ${P_GNBSWVERSION.gnb_${gnb_id}}


Get gNB type
    [Documentation]    :Author: Jing Liang
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the BTS (cloud, classical)
    ...    *Note:* woks with COAM and MZOAM
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :return: type of BTS    (cloud,classical)
    [Arguments]  ${gnb_id}=0
    ${gnb_type}=    Get Variable Value    ${P_GNBTYPE.gnb_${gnb_id}}
    Run Keyword If    '${gnb_type}'=='None'
    ...    Fetch gNB type    gnb_id=${gnb_id}
    [Return]  ${P_GNBTYPE.gnb_${gnb_id}}


Get UE type
    [Documentation]    :Author: Jing Liang
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the UE (viavi, qualcomm, airphone)
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :return: type of UE    (viavi, qualcomm, airphone)
    [Arguments]  ${ue_id}=0
    ${ueType}=    Get Variable Value    ${P_UETYPE.ue_${ue_id}}
    Run Keyword If    '${ueType}'=='None'
    ...    Fetch UE type    ue_id=${ue_id}
    [Return]    ${P_UETYPE.ue_${ue_id}}


Get OAM type
    [Documentation]    :Author: Jing Liang
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :return: type of OAM    (coam, megazone)
    [Arguments]    ${gnb_id}=0
    ${oam_type}=    Get Variable Value    ${P_OAMTYPE.gnb_${gnb_id}}
    Run Keyword If    '${oam_type}'=='None'
    ...    Fetch OAM type    gnb_id=${gnb_id}
    [Return]    ${P_OAMTYPE.gnb_${gnb_id}}


Get Common Unit Slave IP
    [Documentation]    :Author: Srihari Janardhan
    ...    Calculate Common Unit Slave IP
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :return slave_ip:   Ip of Slave on common unit
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}
    ${gnb_comu_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${grep_ipv6_cmd}=    Set Variable    echo "ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}\\:){7}(\\w{1,4})'"
    ${slave_ip}=    ssh.execute  command=${grep_ipv6_cmd} | bsh ${${comu_id}}:1  connection=${gnb_comu_alias}
    [RETURN]    ${slave_ip.strip()}


Disconnect all available ssh connections
    [Documentation]    :Author: Vasileios Papoutsis
    ...    TODO:  Do we really need this keyword? could go to connect.robot
    ssh.reset_cache


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
    ${gnb_sw_version}=  Run Keyword if  '${component}'=='DU'  Fetch common OAM SW version  gnb_id=${gnb_id}
    ...  bts_host=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
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



