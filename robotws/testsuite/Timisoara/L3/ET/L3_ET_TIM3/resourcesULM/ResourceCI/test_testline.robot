*** Settings ***
Library     OperatingSystem
Library     Collections
Resource    ../testline.robot
Resource    ../ute_workarounds.robot
Resource    ../gnb.robot
Resource    ../connect.robot
Resource    ../networking.robot
Library     ../python/ip_utils.py       WITH NAME   iputils
Library     taf.config.testline.info    WITH NAME   testlineInfo
Library     taf.sbts.oam.coam.admin     WITH NAME   admin
Library     taf.transport.ssh           WITH NAME   ssh


*** Test Cases ***
Test Create Test Suite Log Folders
    [TAGS]              TESTLINE
    Create Test Suite Log Folders
    Log To Console  \nCheck previous KW filled the 'private cache' variables
    @{cache_variables}      Create List     P_resultSuiteBaseDir    P_resultSuiteLogDir  P_resultSuiteConfigDir
    FOR     ${variable}     IN      @{cache_variables}
        Log To Console              Check cache variable ${variable}
        Run Keyword If  '${${variable}}'=='None'    Fail    Private variable ${variable} is None!
    END
    Directory Should Exist   ${P_resultSuiteBaseDir}/Configs
    Directory Should Exist   ${P_resultSuiteBaseDir}/Logs

Test Get test suite directory
    [TAGS]              TESTLINE
    ${suite_folder}     Get test suite directory
    Directory should exist  ${suite_folder}

Test get gnb SW Version
    [TAGS]              TESTLINE
    ${gnb_sw_version}=    Get gnb SW Version
    Log    \nSW Version is ${gnb_sw_version}   console=True

Test Get gNB SW Branch
    [TAGS]              TESTLINE
    ${sw_branch}=    Get gNB SW Branch
    Log    \nSW Branch is ${sw_branch}   console=True

Test Get Node Deployment Type
    [TAGS]              TESTLINE
    ${gnb_type}=     Get Node Deployment Type  node_id=0   node_type=gnb
    Log    \ngNB type is ${gnb_type}   console=True

Test Get Airphone SW version
    [TAGS]              TESTLINE
    ${ap_sw_version}=   Get Airphone SW version
    Log     \nAirphone SW version is ${ap_sw_version}    console=True

Test Get UE type
    [TAGS]              TESTLINE
    ${ue_type}=   Get UE type
    Log   \nUE type is ${ue_type}   console=True

Test Get eNB SW Version
    [TAGS]              TESTLINE
    ${enb_sw_version}=    Get eNB SW Version
    Log    \neNB SW Version is ${enb_sw_version}

Test Get Capacity Slave IP
    [TAGS]              TESTLINE
    Pass Execution If   '${tl_info.deployment_type()}' == 'aic'
    ...     KW 'Get Capacity Slave IP' isn't applicable for AiC!
    ${cu_type}=   Get Common Unit Type
    ${capacity_slave_ip}=    Get Capacity Slave IP
    Pass Execution If   $cu_type=='ASOE' and $capacity_slave_ip==${None}
    ...     KW 'Get Capacity Slave IP' returned None as expected for '${cu_type}'!
    Log    \nCapacity Slave IP is ${capacity_slave_ip}   console=True
    Should Be Valid Ip    ${capacity_slave_ip}

Test Get Common Unit Slave IP
    [TAGS]              TESTLINE
    Pass Execution If   '${tl_info.deployment_type()}' == 'aic'
    ...     KW 'Get Capacity Slave IP' isn't applicable for AiC!
    ${cu_type}=   Get Common Unit Type
    ${common_unit_slave_ip}=   Get Common Unit Slave IP
    Pass Execution If   $cu_type!='ASIK' and $common_unit_slave_ip==${None}
    ...     KW 'Get Common Unit Slave IP' returned None as expected for '${cu_type}'!
    Log    \nCommon Unit Slave IP is ${common_unit_slave_ip}   console=True
    Should Be Valid Ip     ${common_unit_slave_ip}

Test Get AP Capacity Slave IP
    [TAGS]              TESTLINE
    Pass Execution If   '${tl_info.deployment_type()}' == 'aic'
    ...     KW 'Get Capacity Slave IP' is not applicable for AiC!
    ${ap_capacity_slave_ip}=   Get AP Capacity Slave IP
    Log    \nAP Capacity Slave IP ${ap_capacity_slave_ip}    console=True
    Should Be Valid Ip     ${ap_capacity_slave_ip}

Test Disconnect all available ssh connections
    [TAGS]              TESTLINE
    Disconnect all available ssh connections

Test Get Testline Name
    [TAGS]              TESTLINE
    ${tl_name}=    Get Testline Name
    Log    \nTL Name is ${tl_name}   console=True

Test Set Console Output
    [TAGS]              TESTLINE
    Set Console Output

Test Get Common Unit Type And Capacity Unit Type
    [TAGS]              TESTLINE
    ${cu_type}=   Get Common Unit Type
    Should Start With   ${cu_type}              AS
    ${capacity_unit_type}=   Get Capacity Unit Type
    Run Keyword If  '${cu_type}'!='ASOE'    Should Start With   ${capacity_unit_type}   AB
    ...     ELSE    Should Be Equal As Strings  ${capacity_unit_type}   ${None}   

Test Power Cycle UE
    [TAGS]              TESTLINE
    Power Cycle UE
    Wait Until Ping Failed    ip_addr=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    Wait Until Ping Succeeds  ip_addr=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ...     iterations=60     ping_count=10     ping_deadline=10    interval=1
    Wait For Minimum Required State For Cell Setup  timeout=10min   kw_timeout=15min

Test Check TL Infos
    [TAGS]              TESTLINE
    Check TL Infos
    Log To Console  \nCheck previous KW filled the 'private cache' variables
    @{cache_variables}      Create List     P_GNBSWVERSION
    FOR     ${variable}     IN      @{cache_variables}
        Log To Console              Check cache variable ${variable}
        ${sorted}   Get Dictionary Keys     ${${variable}}
        Should Contain Match    ${sorted}   gnb_0   Private variable ${variable} has no key gnb_0!
        Run Keyword If  '${${variable}.gnb_0}'=='None'    Fail    Private variable ${variable}.gnb_0 is None!
    END

Test Get Core type
    [TAGS]              TESTLINE
    ute_workarounds.Patch testline configuration for UTE Cloud
    Get Core type

Test Get All Class Items With Alias
    [TAGS]              TESTLINE
    [Setup]     Create Admin Session
    @{class_list}       Create List     SMOD  RMOD  TRX  WNCEL  DSP  ASIRMOD  NRCEL
    FOR     ${item}     IN      @{class_list}
        ${item_list}    Get All Class Items     class=${item}   alias=${oam_alias}
        Log List    ${item_list}
    END

Test Get All Class Items Error Case
    [TAGS]              TESTLINE
    [Setup]     Create Admin Session
    Run Keyword And Expect Error    *   Get All Class Items     class=DUMMYCLASS  alias=${oam_alias}

Test Get All Class Items Without Alias
    [TAGS]              TESTLINE
    @{class_list}       Create List     SMOD  RMOD  TRX  WNCEL  DSP  ASIRMOD  NRCEL
    FOR     ${item}     IN      @{class_list}
        ${item_list}    Get All Class Items     class=${item}
        Log List    ${item_list}
    END

Test Identify Interface with IP on remote host
    [TAGS]              TESTLINE
    ${sysmodule_alias}=   Connect to Node Common Unit   node_type=gnb   node_id=0
    ${itf}=   Identify Interface with IP  ip=192.168.255.129  connection=${sysmodule_alias}
    Should be Equal As Strings   ${itf}   ethlmp0
    [Teardown]   ssh.disconnect   connection=${sysmodule_alias}


*** Keywords ***
Create Admin Session
    ${oam_alias}    connect.Setup OAM Http session  node_type=gnb   node_id=0
    Set Suite Variable   ${oam_alias}
