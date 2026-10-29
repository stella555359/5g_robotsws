*** Settings ***
Documentation
...    Author: Jacek Dziedzicki, Natalia Czech
...    Contact: jacek.dziedzicki@nokia.com, natalia.czech@nokia.com
...    Description: Common keywords for RAN PZ KRK8 team


Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library      SSHLibrary
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library      taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library      testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.py
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/utilities/settings.py

*** Variables ***
${artifactory_login}    -u${KRK_VRF_USER}:${KRK_VRF_PASSWORD}

*** Keywords ***
Block unblock RU with NRPOSCELL
    [Arguments]     @{radio_unit_id}
    FOR    ${id}    IN    @{radio_unit_id}
        gnbru.lock radio unit
        ...    radio_unit_id=${id}    radio_type=rmod
        gnbru.verify radio unit is locked
        ...    radio_unit_id=${id}    radio_type=rmod
        gnbru.unlock_radio_unit
        ...    radio_unit_id=${id}    radio_type=rmod
        gnbru.verify radio unit is unlocked
        ...    radio_unit_id=${id}    radio_type=rmod
    END
    Wait Until Keyword Succeeds     1200 sec     1 sec    gnbcell.verify all cells are onair

Cdd Connect And Load Config
    [Arguments]    ${file_name}    ${cdd_url}=https://172.16.0.1/    ${radio_unit_id}=${1}    ${password}=EZ4Techs
    ${status}=    Run Keyword And Return Status    Cdd Connect And Load Config File
    ...                                            file_name=${file_name}    cdd_url=${cdd_url}    password=${password}
    IF    not ${status}
            Cdd Connect And Load Config File    file_name=${file_name}    cdd_url=${cdd_url}    password=${password}
    END
    ${all_radio_units_online}    Run keyword And Ignore Error
    ...    Wait Until Keyword Succeeds  1min  30s  gnbru.Verify All Radio Units Are Online
    ${radio_offline}=    Run Keyword And Return Status    Should Contain    ${all_radio_units_online}    FAIL
    Run Keyword if    not ${radio_offline}
    ...    Run keyword And Ignore Error    Wait For CDD Not Installed On GNB    id=${radio_unit_id}
    ...  ELSE
    ...    BuiltIn.Sleep     1min

Cell activation deactivation veryfication
    [Arguments]     ${delta}    ${prefix_tag}
    taf.rfrl.bts.commissioning.Perform Full Commissioning On Classical Gnb     prefix_tag=${prefix_tag}    update_timeout=1200
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir
    Perform Delta Commissioning On gNB          delta=${delta}
    Wait Until Keyword Succeeds     300 sec     15 sec   Verify gNB is onAir

Custom Suite Setup
    taf.rfrl.bts.commissioning.Perform Full Commissioning On Classical Gnb     prefix_tag=${BTS_config_main}    update_timeout=1200
    Wait For Cells To Be Onair
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb    sw_config_path=${BTS_config_main}
    Common Suite Setup

Download CDD configuration files
    [Arguments]    ${cdd_file_path}    ${CDD_URL}    ${cdd_config_list}    ${cdd_project_path}    ${CDD_directory}
    logger.log_info_to_console    Downloading CDD configs...\n
    Run    cd ${cdd_project_path} ; mkdir ${CDD_directory} ; pwd
    FOR    ${config}    IN    @{cdd_config_list}
        logger.log_info_to_console    Downloading ${config}
        ${status}=    Run Keyword And Return Status    Run Keywords
        ...    Run    cd ${cdd_file_path} ; curl ${artifactory_login} ${CDD_URL}/${config} --output ${config}    AND
        ...    ${file_size}    Run    cd ${cdd_file_path} ; ls -l ${config} | cut -d " " -f5    AND
        ...    Should Be True    ${file_size} > 80
        IF    not ${status}
            Run    cd ${cdd_file_path} ; curl ${artifactory_login} ${CDD_URL}/${config} --output ${config}
            ${file_size}    Run    cd ${cdd_file_path} ; ls -l ${config} | cut -d " " -f5
            Should Be True    ${file_size} > 80
        END
    END
    Get BTS Instance Id

Enable CDD access
    [Arguments]    ${new_adress_ip}=172.16.0.2
    Run    cat /etc/network/interfaces
    Run    sudo sed -i -e 's/172.25.30.1/${new_adress_ip}/g' /etc/network/interfaces
    Run    cat /etc/network/interfaces
    Run    sudo /etc/init.d/networking restart

Fail And Log Error
    [Arguments]   ${msg}
    [Documentation]  :param msg:     message logged
    Log    message=${msg}    level=ERROR
    Fail   msg=${msg}

Get BTS Instance Id
    [Arguments]    ${gnb_instance_id}=${tl.gnbs[0].cu.instance_id}
    ${bts_instance_id}=    Set Variable    ${gnb_instance_id}
    Set Global Variable    ${bts_instance_id}
    logger.log_info_to_console     ---- BTS ID: ${bts_instance_id} ----\n
    [Return]  ${bts_instance_id}

Load SCF and verify BTS onAir
    [Arguments]    ${prefix_tag}
    taf.rfrl.bts.commissioning.Perform Full Commissioning On Classical Gnb     prefix_tag=${prefix_tag}    update_timeout=1200
    Wait Until Keyword Succeeds     1200 sec     1 sec    gnbcell.verify all cells are onair

Perform CDD and BTS Commissioning
    [Arguments]    ${file_name}    ${cdd_url}    ${prefix_tag}    ${radio_unit_id}=${1}  ${password}=EZ4Techs
    Cdd Connect And Load Config    file_name=${file_name}    cdd_url=${cdd_url}    radio_unit_id=${radio_unit_id}    password=${password}
    ${status}=    Run Keyword And Return Status    Perform Commissioning on BTS    prefix_tag=${prefix_tag}
    IF    not ${status}
        Reboot ERA System    cdd_url=${cdd_url}    radio_unit_id=${radio_unit_id}
    END

Perform Commissioning on BTS
    [Arguments]    ${prefix_tag}  ${build_directory}=/home/ute/Downloads/  ${remove_build}=${False}  ${bts_id}=${0}
    ${GNB_SW}=    Get gNB Sw Version
    logger.log_info_to_console    ---- Perform Commissioning on eNB/gNB (${GNB_SW}: ${prefix_tag}) and Wait for onAir ----\n
    Perform Full Commissioning and Wait for onAir  prefix_tag=${prefix_tag}    build_directory=${build_directory}
    ...                                            remove_build=${remove_build}  update_timeout=${900}  bts_id=${bts_id}
    Wait For Cells To Be Onair
    logger.log_info_to_console    ---- eNB/gNB (${GNB_SW}: ${prefix_tag}) Commissioning DONE ----\n

Power Reset CDD
    [Arguments]    ${radio_unit_id}=${1}    ${timeout}=${400}
    logger.log_info_to_console    ******* Starting to Power Reset CDD ******* \n
    gnb_ru.Power Reset gNB Radio Unit    radio_unit_id=${0}
    Wait For CDD Offline On GNB    id=${radio_unit_id}
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair

Prepare Testline
    [Arguments]    ${scf_prefix_tag}    ${swconfig_from_path}=${False}
    ${status}=  Run Keyword And Return Status  tl_prep.prepare_testline    scf_prefix_tag=${scf_prefix_tag}
                                               ...                         incompatible_error_timer=1500
                                               ...                         increase_timeout_for_update_sw=1500
                                               ...                         increase_time_for_checking_cells=600
                                               ...                         swconfig_from_path=${swconfig_from_path}
                                               ...                         should_LTE_neighbour_be_changed=${False}
                                               ...                         should_5G_neighbour_be_changed=${False}
    IF    not ${status}
            tl_prep.prepare_testline    scf_prefix_tag=${scf_prefix_tag}
            ...                         incompatible_error_timer=1500
            ...                         increase_timeout_for_update_sw=1500
            ...                         increase_time_for_checking_cells=600
            ...                         swconfig_from_path=${swconfig_from_path}
            ...                         should_LTE_neighbour_be_changed=${False}
            ...                         should_5G_neighbour_be_changed=${False}
    END

Reboot ERA System
    [Arguments]    ${cdd_url}=https://172.16.0.1/    ${radio_unit_id}=${1}    ${password}=EZ4Techs    ${timeout}=${2400}
    Reboot Cdd    cdd_url=${cdd_url}    password=${password}
    Run keyword And Ignore Error    Wait For CDD Not Installed On GNB    id=${radio_unit_id}
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair

Reboot UE
    [Arguments]    ${ue_alias}
    ${PLINK}=    Set Variable    C:\\plink\\plink.exe
    ${CONFIG}=    Set Variable    9600,8,n,1,N
    ${CMD}=    Set Variable    AT+CFUN=1,1\r
    IF    '${ue_alias}' == 'UE_1'
        ${PORT}=    Set Variable   COM59
    ELSE IF    '${ue_alias}' == 'UE_2'
        ${PORT}=    Set Variable   COM56
    END
    Run Keyword And Ignore Error    Run Command On Ue Pc    command=cmd /c "taskkill /IM plink.exe /F"    sleep_time=2s
    Run Keyword And Ignore Error    Run Command On Ue Pc    command=cmd /c "taskkill /IM putty.exe /F"    sleep_time=2s
    ${command}=    Set Variable    cmd.exe /C "echo ${CMD} | ${PLINK} -v -serial ${PORT} -sercfg ${CONFIG} -batch"
    Run Keyword And Ignore Error    Run Command On Ue Pc     command=${command}    sleep_time=10s
    BuiltIn.Sleep     5s
    Run Keyword And Ignore Error    Run Command On Ue Pc    command=cmd /c "taskkill /IM plink.exe /F"    sleep_time=2s
    BuiltIn.Sleep     60s

Reset BBMOD
    [Arguments]    ${bbmod_id}=${1}    ${id}=${1}    ${timeout}=${400}
    logger.log_info_to_console    ******* Starting to Reset BBMOD ******* \n
    gnbbbu.reset_bbmod    bbmod_id=${bbmod_id}
    Wait For CDD Offline On GNB    id=${id}
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair

Reset BTS
    [Arguments]    ${id}=${1}    ${timeout}=${400}
    logger.log_info_to_console    ******* Starting to Reset BTS ******* \n
    gnb_bbu.Reset gNB
    Wait For CDD Offline On GNB    id=${id}
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair

Reset CDD
    [Arguments]    ${radio_unit_id}=${1}    ${timeout}=${400}
    logger.log_info_to_console    ******* Starting to Reset CDD ******* \n
    gnb_ru.Reset gNB Radio Unit  radio_unit_id=${radio_unit_id}
    Wait For CDD Offline On GNB    id=${radio_unit_id}
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair

Reset Cell and check onair
    [Arguments]       @{cell_id}
    FOR    ${id}    IN    @{cell_id}
        gnbcell.reset cell
        ...     cell_id=${id}
    END
    Wait Until Keyword Succeeds     1200 sec     1 sec    gnbcell.verify all cells are onair

Reset NRPOSCELL
    [Arguments]       @{cell_id}
    FOR    ${id}    IN    @{cell_id}
        gnbcell.reset cell
        ...     cell_id=${id}
    END

Restart SMAWave
    [Arguments]    ${SMAWave_address}    ${ue_index}=1
    logger.log_info_to_console    -- Restarting SMAWave (IP address = ${SMAWave_address}) --\n
    Reboot UEs    ue_index=${ue_index}

Restart Ue Proxy On Ue PC
    Run Keyword And Continue On Failure
    ...    Run Command On Ue Pc     command=c:/Windows/System32/net.exe stop "UE PROXY RUNNER"     sleep_time=5s
    Run Keyword And Continue On Failure
    ...    Run Command On Ue Pc     command=c:/Windows/System32/net.exe start "UE PROXY RUNNER"

Run Command On Ue Pc
    [Arguments]    ${command}    ${sleep_time}=60s
    SSHLibrary.Open Connection    host=${ue_pc_address}    timeout=300 sec
    Wait Until Keyword Succeeds     120 sec     5 sec
    ...     SSHLibrary.Login    username=${ue_pc_login}    password=${ue_pc_password}
    ${output}    SSHLibrary.Execute Command    ${command}    output_during_execution=${True}    timeout=180
    ...                                        sudo_password=${ue_pc_password}    output_if_timeout=${True}
    logger.log_info_to_console    Output: ${output}
    BuiltIn.Sleep     ${sleep_time}
    SSHLibrary.Close Connection

Test Setup
    [Arguments]    ${custom_taf_tl_config}=${None}    ${timeout}=${400}
    logger.log_info_to_console    -- Start Test Setup --\n
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair
    logger.log_info_to_console    ---- Common Preconditions With Watching Alarms...----\n
    Run Keyword if    '${custom_taf_tl_config}'=='${None}'
    ...    Common Preconditions With Watching Alarms
    ...  ELSE
    ...    Common Preconditions With Watching Alarms    custom_taf_tl_config=${custom_taf_tl_config}
    logger.log_info_to_console    -- Test Setup DONE --\n

Test Setup with TDS enter and BTS commissioning
    [Arguments]    ${prefix_tag}=${None}
    Run Keyword if  '${prefix_tag}'!='${None}'
    ...    Run Keywords    Perform Commissioning on BTS    prefix_tag=${prefix_tag}    AND
           ...             Test Setup    AND
           ...             Create admin session with custom alias    connection=admin    AND
           ...             Enter Test Dedicated State
    ...    ELSE
    ...    Run Keywords    Test Setup    AND
           ...             Create admin session with custom alias    connection=admin    AND
           ...             Enter Test Dedicated State

Test Suite Teardown
    logger.log_info_to_console    --Start Test Suite Teardown--\n
    Common Suite Teardown
    logger.log_info_to_console    --Test Suite Teardown DONE--\n

Test Teardown
    [Arguments]    ${timeout}=${400}
    logger.log_info_to_console    -- Start Test Teardown --\n
    gnbru.wait_for_all_radio_units_to_be_online    timeout=${timeout}
    Wait For Cells To Be Onair
    logger.log_info_to_console    ---- Common Postconditions With Watching Alarms...----\n
    Common Postconditions With Watching Alarms
    logger.log_info_to_console    -- Test Teardown DONE --\n

Test Teardown with TDS exit
    Run Keywords    Exit Test Dedicated State And Close Connections    AND
    ...             Test Teardown

Verify if BTS and RMODs are Online
    [Arguments]    ${bts_id}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    logger.log_info_to_console     **** Verify if BTS and RMODs are Online ****
    Set Global Variable    ${radio_offline}    ${False}
    ${connection}    Run keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    2min  15s    coam.connect to
           ...                            bts_host=${bts_id}
           ...                            update_interval=1000  name=default
    ${connection_fails}=    Run Keyword And Return Status    Should Contain    ${connection}    FAIL
    Run Keyword if    ${connection_fails}
    ...    Run Keyword And Return    logger.log_info_to_console     ---- Cannot connect to BTS ----\n
    ...  ELSE    logger.log_info_to_console     ---- Connection to BTS established ----\n
    ${bts_online}    Run keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    5min  30s    coam.get_bts_statuses    timeout=20    connection=default
    ${bts_offline}=    Run Keyword And Return Status    Should Contain    ${bts_online}    FAIL
    Run Keyword if    ${bts_offline}
    ...    Run Keyword And Return    logger.log_info_to_console     ---- BTS is NOT online ----\n
    ...  ELSE    logger.log_info_to_console     ---- BTS is online ----\n
    ${all_radio_units_online}    Run keyword And Ignore Error
    ...    Wait Until Keyword Succeeds  5min  30s  gnbru.Verify All Radio Units Are Online
    ${radio_offline}=    Run Keyword And Return Status    Should Contain    ${all_radio_units_online}    FAIL
    Set Global Variable    ${radio_offline}
    Run Keyword if    ${radio_offline}
    ...    logger.log_info_to_console     ---- At least one radio unit is not online ----\n
    ...  ELSE    logger.log_info_to_console     ---- All radio units are online ----\n
    [Teardown]    Run Keyword if    not ${connection_fails}    coam.teardown    connection=default

Verify NRPOSITION CELLS status
    [Arguments]       @{cell_id}
    FOR    ${id}    IN    @{cell_id}
        verify_cell_statuses
        ...     cell_id=${id}
        ...     availability_status=online
        ...     operational_state=enabled
        ...     administrative_state=unlocked
        ...     procedural_status=configured
        ...     blocking_state=unblocked
        ...     usage_state=None
        ...     cell_type="all"
        ...     barring_status=unbarred
    END

Wait For Cells To Be Onair
    [Arguments]    ${timeout}=${1500}
    logger.log_info_to_console    ---- Wait for cells to be onair...----\n
    gnbcell.Wait For All Cells To Be Onair    timeout=${timeout}
    logger.log_info_to_console    ---- All cells are onair...----\n

Wait For CDD Not Installed On GNB
    [Arguments]    ${id}=${1}    ${timeout}=4min
    Wait Until Keyword Succeeds  ${timeout}  20s  gnbru.verify_radio_unit_statuses  ru_id=${id}  availability_status=notinstalled

Wait For CDD Offline On GNB
    [Arguments]    ${id}=${1}
    Wait Until Keyword Succeeds  10min  20s  gnbru.verify_radio_unit_statuses  ru_id=${id}  availability_status=offline
