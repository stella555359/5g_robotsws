*** Settings ***
Documentation    QT CUS OnDemandRun Test

Library      BuiltIn
Library      taf.transport.ssh         WITH NAME    ssh
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.collectors.btslog    WITH NAME   btslog
Library      taf.ul.ue.sim.env_setup
Library      ta_uexgate
Library      OperatingSystem
Library      Collections
Library      String
Library      XML
Library      ute_admin_infomodel

Library      ${CURDIR}/../../resources/python/common.py
Library      ${CURDIR}/../../resources/python/TestCaseRequirement.py
Library      ${CURDIR}/../../resources/python/cus.py
Resource     ${CURDIR}/../../resources/robot/allowed_alarms.robot
Resource     ${CURDIR}/../../resources/robot/log_collector.robot
Resource     ${CURDIR}/../../resources/robot/additional_check.robot
Resource     ${CURDIR}/../../resources/robot/classical_keywords.robot
Resource     ${CURDIR}/../../resources/robot/states.robot
Resource     ${CURDIR}/../../resources/robot/common_variables.robot
Resource     ${CURDIR}/../../resources/robot/common.robot
Resource     ${CURDIR}/../../resources/robot/common_l3call.robot
Resource     ${CURDIR}/../../resources/robot/AIC_common_keywords.robot

Suite Setup        CUS OnDemandRun Suite Setup
Suite Teardown     Run Keyword And Ignore Error    CUS OnDemandRun Suite Teardown

*** Variables ***
#${bts_host}    ${LMP_IP}
${path}        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${gnb_or_enb}    enb
${tl.enbs[0].cu.oam_http_connection_details.addr}      10.0.1.2
${tl.enbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}     ${LMP_IP}
${tl.enbs[0].dus[0].airscale.common_units[0].lmp_connection.username}     ${asik_username}
${tl.enbs[0].dus[0].airscale.common_units[0].lmp_connection.password}     ${asik_password}
${ue_type}     cus
${tl.ues[0].ue_type}    cus
${UE}       cus
${UE_index}     0
${cus_ini}      /opt/cus/etc/cus.ini
${epc_lua}      /home/ute/MN/UTE/robotws/testsuite/QT/SRAN/configs/epc_sim_files/cus.lua
${moxa_ip_addr}     None
${moxa_port}     None

*** Test Cases ***
Quick_Test_as_a_Service_Cus_fullscope
    [Documentation]
    ...    This test case is designed to run a fullscope test for CUS on QT's testsuite for Quick Test as a Service
    Install Package
    Verify BTS Startup Before Commissioning
    Verify S1 Connection
    Verify Cell Setup
    Commissioning
    Verify BTS Startup After Commissioning
    Verify S1 Connection After Commissioning
    Verify Cell Setup After Commissioning
    L3 Call 4G
    Install Package T1
    Verify BTS Startup T1
    Verify S1 Connection T1
    Verify Cell Setup T1
    Check Active And Historical Alarms

*** Keywords ***
Install Package
    Run Keyword    Log to console    \nInstall Package
    Check SW version
    Install gNB package    sw_version=${loadBuild}
    Wait For BTS To Be Available    AF_PATH=${build_package}
    Check active SW version on cOAM    AF_PATH=${build_package}
    #Permissions And Additional Check
    Set Test Variable    ${Install_OK}    True

Verify BTS Startup Before Commissioning
    Run Keyword    Log to console    \nVerify BTS Startup Before Commissioning
    Run Keyword If    '${Install_OK}' != 'True'    Fail    Install Package was not successful
    Verify BTS Startup
    Set Test Variable    ${BtsStartupBC_OK}    True

Verify S1 Connection
    Run Keyword    Log to console    \nVerify S1 Connection
    Run Keyword If    '${BtsStartupBC_OK}' != 'True'    Fail    Verify BTS Startup Before Commissioning was not successful
    Reach OnAir With WTS
    Check IF WTS Is Active
    Set Test Variable    ${S1Connection_OK}    True

Verify Cell Setup
    Run Keyword    Log to console    \nVerify Cell Setup
    Run Keyword If    '${S1Connection_OK}' != 'True'    Fail    Verify S1 Connection was not successful
    ${status}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    5min    30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=installation package
    Run Keyword If    '${status}' == 'True'    Set Test Variable    ${CellSetup_OK}    True
    Run Keyword If    '${status}' == 'False'    Set Test Variable    ${CellSetup_OK}    False
    Run Keyword If    '${status}' == 'False'    Set Suite Variable    ${ims_log_name}    _after_installation_gNB_package_
    Run Keyword If    '${status}' == 'False'    Set Suite Variable    ${ims_dir_name}    SW_Download_With_Activation/
    Run Keyword If    '${status}' == 'True'
    ...    Run Keyword And Ignore Error    Report KPI    target_dir=${OUTPUT_DIR}/SW_Download_With_Activation

Commissioning
    Run Keyword    Log to console    \nCommissioning
    Run Keyword If    '${CellSetup_OK}' != 'True'    Fail    Verify Cell Setup was not successful
    Perform commissioning
    Set Test Variable    ${Commissioning_OK}    True

Verify BTS Startup After Commissioning
    Run Keyword    Log to console    \nVerify BTS Startup After Commissioning
    Run Keyword If    '${Commissioning_OK}' != 'True'    Fail    Commissioning was not successful
    Verify BTS Startup
    Set Test Variable    ${BtsStartupAC_OK}    True

Verify S1 Connection After Commissioning
    Run Keyword    Log to console    \nVerify S1 Connection After Commissioning
    Run Keyword If    '${CellSetup_OK}' != 'True'    Fail    Verify Cell Setup was not successful
    Reach OnAir With WTS
    Check IF WTS Is Active
    Set Test Variable    ${S1ConnectionAC_OK}    True

Verify Cell Setup After Commissioning
    Run Keyword    Log to console    \nVerify Cell Setup After Commissioning
    ${status}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    3min    30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=commissioning    dir_name=Full_Commissioning/
    Run Keyword If    '${status}' == 'True'    Set Test Variable    ${CellSetup_OK}    True
    Run Keyword If    '${status}' == 'False'    Set Test Variable    ${CellSetup_OK}    False
    Run Keyword If    '${status}' == 'True'
    ...    Run Keyword And Ignore Error    Report KPI
    ...    kpi_name=kpi12_scf
    ...    target_dir=${OUTPUT_DIR}/Full_Commissioning
    ...    kpi_list=kpi12

L3 Call 4G
    Run Keyword    Log to console    \nL3 Call 4G
    Create CUS alias  alias=UE_1  ue_id=1  id_type=cus
    Perform L3call OnDemandRun      1       classical

Install Package T1
    Run Keyword    Log to console    \nInstall Package T1
    Install gNB package    sw_version=${loadBuild}       T0orT1=T1
    #Check SW version       component=T1
    Wait For BTS To Be Available    T1orT2=T1    AF_PATH=${build_package}
    Check active SW version on cOAM    T1orT2=T1    AF_PATH=${build_package}
    #Permissions And Additional Check
    Set Test Variable    ${InstallT1_OK}    True

Verify BTS Startup T1
    Run Keyword    Log to console    \nVerify BTS Startup T1
    Run Keyword If    '${InstallT1_OK}' != 'True'    Fail    Install Package T1 was not successful
    Verify BTS Startup
    Set Test Variable    ${BtsStartupT1_OK}    True

Verify S1 Connection T1
    Run Keyword    Log to console    \nVerify S1 Connection T1
    Run Keyword If    '${BtsStartupT1_OK}' != 'True'    Fail    Verify BTS Startup T1 was not successful
    Reach OnAir With WTS
    Check If WTS Is Active
    Set Test Variable    ${S1ConnectionT1_OK}    True

Verify Cell Setup T1
    Run Keyword    Log to console    \nVerify Cell Setup T1
    Run Keyword If    '${S1ConnectionT1_OK}' != 'True'    Fail    Verify S1 Connection T1 was not successful
    ${status}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    3min    30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=T1    dir_name=Upgradability_T1/
    Run Keyword If    '${status}' == 'True'    Set Test Variable    ${CellSetupT1_OK}    True
    Run Keyword If    '${status}' == 'False'    Set Test Variable    ${CellSetupT1_OK}    False
    Run Keyword If    '${status}' == 'True'
    ...    Run Keyword And Ignore Error    Report KPI
    ...    kpi_name=kpi4_T1
    ...    target_dir=${OUTPUT_DIR}/Upgradability_T1

Check Active And Historical Alarms
    Run Keyword    Log to console    \nCheck Active And Historical Alarms
    ${status}=    Run Keyword And Return Status
    ...    Check Alarms In Ims File Common TS    name=_all_test
    Run Keyword If    '${status}' == 'False' and '${are_logs_checked}' == 'False'
    ...    Run Keyword And Ignore Error    Additional check in TC Common TS

# ____Other Keywords____

CUS OnDemandRun Suite Setup
    Set Suite Variable  ${tl.tl_cloud_topology}  CLOUD_onDemandRun_CUS
    Log To Console      ============================== [ SUITE SETUP ] ===============================\n
    Create Directory    ${OUTPUT DIR}/Additional_Execution_Logs
    Create Directory    ${OUTPUT DIR}/Full_Run
    Log To Console      \t- TestLine: ${tl.tl_cloud_topology}
    Wait Until Keyword Succeeds    1min    15s    coam.connect to
    ...                bts_host=${LMP_IP}
    ...                update_interval=1000
    ...                name=coam_admin
    Set Color For Logs
    Set Variable stream_nr
    Get Baseline
    Start syslog
    Get Smod Type
    Setup WTS
    Testline reconfiguration
    ${dualcore}                    Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIM_ASIM
    BuiltIn.Set Global Variable    ${dualcore}
    Setup And Connect IM    alias=default
    Log To Console      \n============================ [ SUITE SETUP DONE ] ============================
    Log To Console      ------------------------------------------------------------------------------

Start syslog
    [Arguments]    ${host_ip}=127.0.0.1    ${user}=ute    ${password}=ute    ${btslog_collector_name}=btslog
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${user}
    ...  password=${password}
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${executor_test_vm}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}

Stop and collect btslog
    [Arguments]    ${target_dir}=${EXECDIR}/logs/   ${btslog_collector_name}=btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}

CUS OnDemandRun Suite Teardown
    [Timeout]           35 min
    [Arguments]         ${snapshot_only}=False
    ${common_ts}        Get Variable Value    ${is_common_ts}    ${True}
    Run Keyword IF      '${snapshot_only}'=='False'
    ...                 Save Infomodel Log  ${OUTPUT_DIR}/Full_Run/${tl.tl_cloud_topology}_${ENB_BUILD}_admin_infomodel.ims2
    ...                 alias=default
    ${connection_status}    Run Keyword and return status       coam.connect_to
    ...                   bts_host=192.168.255.129
    ...                   update_interval=1000
    ...                   name=coam_admin
    ${connection_status}    Run Keyword IF    '${connection_status}'=='False'
    ...                   Run Keyword and return status    coam.connect_to
    ...                   bts_host=${tl.$enbs[0].trs_ip.v4}
    ...                   update_interval=1000
    ...                   name=coam_admin
    ...                   ELSE    Set Variable    ${connection_status}
    ${sw_d}=    Run Keyword IF     ${connection_status}     coam.get_sw_version    connection=coam_admin
    Set Suite Variable    ${sw_d}
    Stop and collect btslog    ${OUTPUT_DIR}
    Save Snapshot For Classical    connection_status=True    bts_lmp_ip=${LMP_IP}
    ${additional_logs}    Set Variable    ${OUTPUT DIR}/Additional_Execution_Logs
    Teardown WTS  subdirectory=${additional_logs}
    Run Keywords    coam.teardown    connection=coam_admin
    ...           AND             Disconnect Infomodel    alias=default
    ...           AND             Teardown Infomodel      alias=default

Download package
    [Documentation]    Download selected package.
    ...                author: Emilia Sadowska
    [Arguments]    ${url}    ${target_dir}=/tmp
    ${status}    Run Keyword And Return Status
    ...          Download Build    url=${url}
    ...                            target_dir=${target_dir}
    Run Keyword IF    '${status}'=='${False}'    Run Keywords
    ...               Log To Console    \n Download build failed, start download build using WGET
    ...        AND    Download Build Using WGET    url=${url}
    ...                                            target_dir=${target_dir}

Download Build
    [Documentation]    Download selected package.
    ...                author: Emilia Sadowska
    [Arguments]    ${url}    ${target_dir}
    OperatingSystem.Run    aria2c -x 16 -s 16 ${url} -d ${target_dir}
    ${build_package}       Fetch From Right    ${url}    /
    OperatingSystem.File Should Exist      ${target_dir}/${build_package}
    Set Test Variable    ${sw_package_location}    ${target_dir}/${build_package}

Download Build Using WGET
    [Documentation]    Different way to download selected package IF lterel fail.
    ...                author: Emilia Sadowska
    [Arguments]    ${url}    ${target_dir}
    OperatingSystem.Run    cd ${target_dir} && wget ${url}
    ${build_package}       Fetch From Right    ${url}    /
    OperatingSystem.File Should Exist      ${target_dir}/${build_package}
    Set Test Variable    ${sw_package_location}    ${target_dir}/${build_package}

Check IF SW version is not empty
    [Documentation]    Check IF any software version is visible.
    ...                author: Emilia Sadowska
    Wait Until Keyword Succeeds    1min  20s    coam.connect to
    ...    bts_host=${LMP_IP}    update_interval=1000   name=coam_admin
    ${sw_version}          coam.get_sw_version    timeout=30    connection=coam_admin
    RETURN      ${sw_version}

Install gNB package
    [Documentation]    Install selected software version.
    ...                author: Emilia Sadowska
    [Arguments]          ${sw_version}       ${T0orT1}=${EMPTY}
    ${component}         Set Variable IF    '${T0orT1}'!='${EMPTY}'    _testpackage_${T0orT1}    ${EMPTY}
    ${knife_url}         Get Variable Value    ${knife_url}    ${False}
    IF    '${knife_url}'!='${False}'
          IF    '${T0ORT1}'!='${EMPTY}'
               Get T1 Knife URL    ${knife_url}    ${component}
          END
          ${url}    Set Variable     ${knife_url}
    ELSE IF    '${TESTBUILD_STATUS}' == '${True}'
          Find Testbuild    ${component}
          ${url}    Set Variable     ${testbuild_package}
          ${build_package}       Fetch From Right    ${url}    /
          Set Test Variable    ${build_package}
    ELSE IF    '${URL_STATUS}' == '${True}'
          Find URL     ${component}
          ${url}    Set Variable     ${url_link}
          ${build_package}       Fetch From Right    ${url}    /
          Set Test Variable    ${build_package}
    ELSE
          Set Test Variable    ${build_package}    ${sw_version}_release_BTSSM_downloadable${component}_A54.zip
          ${sw_version}        Fetch From Left     ${sw_version}    _release_
          ${url}    Set Variable     ${path}/${stream_nr}/${sw_version}/${build_package}
    END
    Download package    ${url}
    Log to console    \n Install SW Package: ${url}
    Wait Until Keyword Succeeds    4min  20s    coam.connect to
    ...    bts_host=${LMP_IP}    update_interval=1000   name=coam_admin
    coam.update_software    ${sw_package_location}    timeout=3600    connection=coam_admin
    Run Keywords    OperatingSystem.Run    rm -f /tmp/${stream_nr}_*
    ...           AND             OperatingSystem.Run    df
#    ...           AND             OperatingSystem.Run    rm -rf /home/ute/MN/UTE/robotlte

Get T1 Knife URL
    [Arguments]          ${knife_url}       ${component}
    ${part_of_url}       Fetch From Left    ${knife_url}    _A54.zip
    Set Test Variable    ${knife_url}    ${part_of_url}${component}_A54.zip

Check SW version
    [Documentation]    Check IF installed software version is correct.
    ...                author: Emilia Sadowska
    [Arguments]        ${component}=none
    ${sw_version}        Wait Until Keyword Succeeds    3min  30s    Check IF SW version is not empty
    ${sw_version}        Fetch From Right    ${sw_version}    _ENB_
    Log to console       \n SW Version: ${stream_nr}_ENB_${sw_version}
    Run Keyword IF       '${component}'!='none'    Should Contain    ${sw_version}    ${component}
    ...                  ELSE    Set Suite Variable    ${sw_version}     ${stream_nr}_ENB_${sw_version}
    Set Suite Variable    ${loadBuild}     ${sw_version}

Perform commissioning
    [Documentation]    Perform commissioning with scf from testconfigs repository.
    ...                author: Emilia Sadowska
    Get Current SCF
    Log To Console       eNB SCF: ${scf}
    Wait Until Keyword Succeeds    1min  15s    coam.connect_to    bts_host=${LMP_IP}
    ...                                                            update_interval=1000
    ...                                                            name=coam_admin
    ${scf_validation_result}    coam.validate_scf    ${scf}    connection=coam_admin
    Log to console     \n--> Validation status: ${scf_validation_result['niddValidationResult']['status']}
    Wait until Keyword Succeeds    3x    10s
    ...                            coam.perform_commissioning     scf_file=${scf}    skip_parameter_relation_errors=False
    ...                            timeout=660    connection=coam_admin

Get Current SCF
    Wait Until Keyword Succeeds    1min  15s    coam.connect_to    bts_host=${LMP_IP}
    ...                                                            update_interval=1000
    ...                                                            name=coam_admin
    coam.get_current_scf_file    local_dir_path=${EXECDIR}/logs
    ...                          file_name=scf_from_webui.xml
    ...                          connection=coam_admin
    Set Test Variable    ${scf}    ${EXECDIR}/logs/scf_from_webui.xml

Get Baseline
    [Documentation]        Get environment variable: TESTBUILD
    ${TESTBUILD_STATUS}    Run Keyword And Return Status        Variable Should Exist    ${TESTBUILD}
    ${URL_STATUS}          Run Keyword And Return Status        Variable Should Exist    ${URL}
    BuiltIn.Set Global Variable     ${TESTBUILD_STATUS}
    BuiltIn.Set Global Variable     ${URL_STATUS}
    Run Keyword IF         '"knife": true' in '%{CM_ARTIFACTS}'         Find Knife Build
    ...       ELSE         Check SW version



Find Testbuild
    [Arguments]      ${component}
    ${xml_status}    Run Keyword And Return Status    File Should Not Exist    /tmp/Content_${TESTBUILD}.xml
    ${wft}           Set Variable    https://wft.int.net.nokia.com/ext/build_content/${TESTBUILD}
    Run Keyword IF   '${xml_status}'=='True'    Run
    ...              curl -o /tmp/Content_${TESTBUILD}.xml --connect-timeout 5 --max-time 25 --retry 3 --retry-delay 0 --retry-max-time 40 -k ${wft}
    Set Test Variable    ${testbuild_package}    ${TESTBUILD}_release_BTSSM_downloadable${component}_A54.zip
    ${status}        ${storage}    Run Keyword And Ignore Error    Get Elements Texts
    ...              /tmp/Content_${TESTBUILD}.xml    xpath=.//storages/storage[@title="ARTIFACTORY"]/file[@title="${testbuild_package}"][@url]
    BuiltIn.Set Global Variable    ${testbuild_package}    ${storage}[0]

Find URL
    [Documentation]    Get url for build.
    [Arguments]      ${component}
    ${url_link}    Fetch From Left    ${URL}    _A54.zip
    Set Test Variable    ${url_link}    ${url_link}${component}_A54.zip

Find Knife Build
    [Documentation]    Check IF knife build is set.
    Check SW version
    ${knife_url}    Fetch From Right    %{CM_ARTIFACTS}    btssw_url": "
    ${knife_url}    Fetch From Left     ${knife_url}       ", "knife
    ${knife_url}    Fetch From Left     ${knife_url}       "}, "add_date":
    BuiltIn.Set Global Variable    ${knife_url}

Set Variable stream_nr
    [Documentation]    stream_nrvariable depends on the loads
    ...                IF SBTS load: SBTSXX_ENB_YYYY_DDDD_VVVV (standard form) where YYYY = 9999 (reserved for trunk),
    ...                YYYY = other values for branch; list_index=2 (used for identification of load).
    ...                list_index[2]=9999, then stream_nr=SBTS00 else IF list_index[2]=0000/0100 then stream_nr=SBTSXX
    ...                else stream_nr will get assigned with perticular trunk or branch load.
    ${sw_version}                 coam.get_sw_version    timeout=30    connection=coam_admin
    @{sw_version_list}=           Split String    ${sw_version}    separator=_
    IF    "SBTS" not in "${sw_version}"
        FAIL    SBTS build not found
    ELSE IF    "${sw_version_list}[2]"=="9999"
        ${stream_nr}     Set Variable     SBTS00
        Set Global Variable           ${stream_nr}
    ELSE
        ${stream_nr}     Set Variable     ${sw_version_list}[0]
        Set Global Variable           ${stream_nr}
    END

Get Smod Type
    ${smod_type}       get_board_name    board=master    connection=smod
    IF    '${smod_type}'==''
        ${smod_type}    Set Variable    ASIB
    END
    BuiltIn.Set Global Variable    ${smod_type}
    BuiltIn.Set Global Variable    ${hw_config}        ${smod_type}

Perform L3call OnDemandRun
    [Arguments]    ${RF}    ${test_line_type}
    ${first_call}                   Run Keyword And Return Status    Test L3 Call OnDemandRun    RF=${RF}
    Retry Preparation For L3Call    ${first_call}    ${test_line_type}
    Run Keyword IF                  ${first_call}==False    Run Keyword And Continue On Failure
    ...                             Test L3 Call OnDemandRun    RF=${RF}
    ${detach}                       Run Keyword And Return Status     Detach UE    RF=${RF}
    Run Keyword IF                  '${detach}'=='False'    Log    UE detach failed on RF${RF}, pls check    WARN
    End CUS Scope

Test L3 Call OnDemandRun
    [Arguments]       ${RF}=1
    ${attach}    Run Keyword And Return Status    UE Attach CUS
    Postconditions For Attach    ${attach}    ${RF}
    ${data_transfer}    Run Keyword And Return Status    Perform Data Transfer CUS
    Postconditions For Data Transfer    ${data_transfer}    ${RF}

Perform Data Transfer CUS
    Log To Console    \n\t ========================== DATA TRANSFER ============================
    TRY
        Run Keyword IF    '${UE}' == 'cus'               Check CUS Data Transfer OnDemandRun
        ...       ELSE    Fail
        ...    No UE defined.
    EXCEPT  .*AssertionError.*    type=Regexp
        Run Keywords
        ...    Log    AssertionError occurs, skip log warning to console!
        ...    AND    Fail
    EXCEPT  AS  ${error}
        Run Keywords
        ...    Log    ${UE} data transfer failed due to ${error}    WARN
        ...    AND    Fail
    END
    Log To Console    \n\t ======================== DATA TRANSFER END ===========================

Check CUS Data Transfer OnDemandRun
    ${data_transfer_protocol}    Get Variable Value    ${data_transfer_protocol}    UDP
    Log To Console    Perform Traffic CUS
    Perform Traffic CUS    ${data_transfer_protocol}    time=120    dl_throughput=15    ul_throughput=7
    Stop Traffic CUS
    Verify Traffic CUS OnDemandRun    ${data_transfer_protocol}

Testline reconfiguration
    [Arguments]    ${validate_sim}=True
    Run raw command  help
    Add Simulator    sim_type=cus    config=${cus_ini}
    Add Epc                          config=${epc_lua}
    Configure environment            validate_sim=${validate_sim}

Verify Traffic CUS OnDemandRun
    [Arguments]    ${data_transfer_protocol}
    Log To Console    Verify Traffic CUS
    IF    '${data_transfer_protocol}' != 'UDP' and '${data_transfer_protocol}' != 'TCP'
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    ${min_success_rate}    Set Variable If    '${data_transfer_protocol}' == 'UDP'    90    70
    Check CUS Throughput
    ...    ${data_transfer_protocol}    exp_tput=15    dir=dl    trf_id=1    ue_id=1    min_success_rate=${min_success_rate}
    Check CUS Throughput
    ...    ${data_transfer_protocol}    exp_tput=7    dir=ul    trf_id=2    ue_id=1    min_success_rate=${min_success_rate}
