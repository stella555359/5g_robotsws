*** Settings ***
Documentation
...     Author: Bartlomiej Lebda    |    Contact: bartlomiej.lebda@nokia.com
...     These keywords are designed to prepare TLs commissioning before testing and to check TLs health after testing.
...     The target platform for these keywords is no commissioning TLs, only with uploaded software.
...     Preparation of preconditions is related to carrying out the correct commissioning and its validation,
...     checking unexpected alarms and bringing to OnAir state without using the Custom commissioning mechanism.
...     Postconditions preparation involves checking the TLs status after performing the tests
...     and performing simple corrective actions in the event of potential errors after testing.

Resource   ../Connections/Connectivity_keywords.robot
Resource   ../Logs_collection/BTSlog_operation.robot
Resource   ../Admin_CLI/Basic_WebEM_operation.robot
#Resource   ../admin/component_states_verification/OnAirCheckers/CheckOnAir.robot
Resource   ../Component_states/Check_while_component_status.robot
Library    taf.sbts.oam.coam.admin     WITH NAME     admin_cli
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.pdu    WITH NAME    pdu
Library    OperatingSystem
Library    resources.py
Variables  variables.py

*** Variables ***
${MRBTS_ID}=    ${tl.gnbs[0].instance_id}
${comm_timer}=    15 min
${sw_path_prepare}=    /home/ute
${SW_sufix}=    _release_BTSSM_downloadable_A54.zip

*** Keywords ***
Prepare and check TL
    [Tags]      WIP
    [Documentation]    Supported TLs:
    ...    52,55,56,57,58,59,60,145,146,147,148,149,150,191,192,193,194,195,196,601,602
    [Arguments]    ${upload_default_scf}=True    ${skip_parameter_relation_errors}=False    ${add_syslog_flag}=False
    ${TL_state}    Set variable   ${False}
    #Reboot SMOD
    Run keyword if   ${add_syslog_flag}    Add Flag In Swconfig File cOAM1    0x10041=5
    ${agreement_for_collecting_logs}  ${test_level}   Log collector level decision for Preparing TL
    Run keyword if   ${agreement_for_collecting_logs}   Start Logs collection   test_level=${test_level}  F_sysLog=${True}
    Run keyword and ignore error    Check AdetS status
    Run keyword and ignore error    Check software on SMOD before preparation
    Create connection via adminCLI
    ${output}    Run     pip freeze
    ${active_SW}=        admin_cli.get_sw_version
    ${is_site_ready}=    run keyword and return status    wait until keyword succeeds  10 min    20 sec    Check if BTS is ready for commisioning
    run keyword if    '${is_site_ready}'=='False'    log     Pre-check failed. SCF will be uploaded.     level=WARN
    ${TLstate}=    run keyword and return status    Check if BTS is OnAir state
    run keyword if   '${TLstate}'=='False'     Perform correct commissioning    ${skip_parameter_relation_errors}
    ...    ELSE IF    '${upload_default_scf}'=='True'    Perform correct commissioning    ${skip_parameter_relation_errors}
    Check unwanted alarms list
    ${TLstate}=    run keyword and return status    Check cells_status
    [Teardown]    Run keywords
    ...  Run keyword if    ${agreement_for_collecting_logs} and ${TLstate}==${False}   run keyword and ignore error
    ...    Stop Logs collection   ${OUTPUTDIR}/${SUITENAME}  test_level=${test_level}   F_sysLog=${True}   F_snapshot=${True}  AND
    ...  ADMIN CLI disconnection

Log collector level decision for Preparing TL
    [Documentation]
    ...  collects logs when:
    ...  If Suite Setup(SS) fail then collect logs only for SS but not for Suite Teardown(ST)
    ...  If SS pass and Test pass and ST fail then collect logs for ST
    ...  If SS pass and last Test pass then collect logs for ST
    ...  If SS pass and last Test fail then not collect logs for ST
    ${Logvariables}   Log variables
    ${variables}   Get variables
    ${is_SUITE_NAME}  Run Keyword And Return Status  Evaluate   $SUITE_NAME in $variables
    ${is_TEST_NAME}   Run Keyword And Return Status  Evaluate   $TEST_NAME in $variables
    ${is_Suite_Setup_level}     Run keyword if  '${is_TEST_NAME}'=='${False}' and '${PREV_TEST_STATUS}'=='${EMPTY}'  Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    ${is_Test_Cases_level}      Run keyword if  '${is_TEST_NAME}'=='${True}'   Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    ${is_Suite_Teardown_level}  Run keyword if  '${is_TEST_NAME}'=='${False}' and '${PREV_TEST_STATUS}'!='${EMPTY}'  Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    ${test_level}     Run keyword if
    ...            ${is_Suite_Setup_level}        Set variable   "Suite_Setup_level"
    ...  ELSE IF   ${is_Test_Cases_level}         Set variable   "Test_Cases_level"
    ...  ELSE IF   ${is_Suite_Teardown_level}     Set variable   "Suite_Teardown_level"
#    Log to console  ${\n}${is_Suite_Setup_level} ${is_Test_Cases_level} ${is_Suite_Teardown_level}
    ${is_Suite_setup_failed}  Run keyword if  ${is_Suite_Teardown_level}  Run Keyword And Return Status
    ...  Should contain  ${SUITE_MESSAGE}  Suite setup failed
    ${agreement_for_collecting_logs}    Run keyword if  ${is_Suite_Setup_level}
    ...                                                                                 Set variable  ${True}
    ...  ELSE IF         ${is_Test_Cases_level}                                         Set variable  ${False}
    ...  ELSE IF         ${is_Suite_Teardown_level} and ${is_Suite_setup_failed}        Set variable  ${False}
    ...  ELSE IF         ${is_Suite_Teardown_level} and '${PREV_TEST_STATUS}'=='PASS'   Set variable  ${True}
    ...  ELSE IF         ${is_Suite_Teardown_level} and '${PREV_TEST_STATUS}'=='FAIL'   Set variable  ${False}
    ...  ELSE                                                                           Set variable  ${True}
#    Log to console  ${\n}Colect logs:${agreement_for_collecting_logs}
	[Return]   ${agreement_for_collecting_logs}  ${test_level}

Check AdetS status
    ${broken_unit}    Create list
    Connect Ssh To Asix
     ${adet_status}    ssh.execute
     ...    command=export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s
     ...    connection=asik
     ${fct}    get lines matching pattern     ${adet_status}    *_FCT*
     @{fct}    Split String   ${fct}  ${\n}
     FOR    ${fct_status}    IN    @{fct}
        ${is_SM_ready}    run keyword and return status    should contain    ${fct_status}    ready
        Run keyword if    ${is_SM_ready}==False    Append to list    ${broken_unit}   ${fct_status}
     END
     ${fsp}    get lines matching pattern     ${adet_status}    *_FSP*
     @{fsp}    Split String   ${fsp}  ${\n}
     FOR    ${fsp_status}    IN    @{fsp}
        ${is_BB_ready}    run keyword and return status    should contain    ${fsp_status}    ready
        Run keyword if    ${is_BB_ready}==False    Append to list    ${broken_unit}   ${fsp_status}
     END
     should be empty    ${broken_unit}  msg=BTS is broken. These components are not working properly:${\n}${broken_unit}
    [Teardown]    Disconnect Ssh From Asix

#Check software on SMOD before preparation
#    Connect Ssh To Asix
#    ${first_partition}=    ssh.execute    ls /ffs/run   connection=Connect Ssh To Asix
#    ${second_partition}=    ssh.execute    ls /ffs/stb   connection=asik
#    log    ${first_partition}
#    log    ${second_partition}
#    [Teardown]    Disconnect Ssh From Asix
#
Create connection via adminCLI
    log    Logs from TL preparation:    level=WARN
    ${connection_established}=    run keyword and return status    wait until keyword succeeds  5 min   30 sec   ADMIN CLI connection
    run keyword if    '${connection_established}'=='True'    run keywords    log    Connection via adminCLI is created.
    ...    level=WARN    AND   return from keyword
    set suite variable    ${adminCLI_ready}    False
    Netboot check
    log    Connection via adminCLI cannot be created. Check and repair actions has been started.    level=WARN
    ${ssh_asix}=    run keyword and return status    Create connection to Asix
    run keyword if    '${ssh_asix}'=='False'    run keywords    log    Connection refused. Start SMOD reset procedure.
    ...    level=WARN    AND    Power reset SMOD during preparation
    run keyword if    '${adminCLI_ready}'=='True'    run keywords   log    Connection via adminCLI is created.    level=WARN    AND
    ...    return from keyword
    run keywords    Check BTS and reboot
    run keyword if    '${adminCLI_ready}'=='True'    run keywords    log    Connection via adminCLI is created.    level=WARN    AND
    ...    return from keyword    ELSE    run keywords    log    Conncection via adminCLI cannot be created despite repair actions.
    ...    level=WARN    AND    FAIL

Power reset SMOD during preparation
        [Arguments]    ${model}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ...               ${ip_pdu}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...               ${port}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...               ${version}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.version}
    run keyword if    "Gude"=="${model}"
    ...    Set Gude PDU power off RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power off RU    ${model}    ${ip_pdu}    ${port}
    sleep    10s
    run keyword if    "Gude"=="${model}"
    ...    Set Gude PDU power on RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power on RU    ${model}    ${ip_pdu}    ${port}
    ${is_SMOD_pingable}=    run keyword and return status    wait until keyword succeeds    5 min    30 sec    Check ping on SMOD
    run keyword if    '${is_SMOD_pingable}'=='False'    run keywords    log
    ...    SMOD is not responding still after power reset. Test suite is canceled.    level=WARN    AND    FAIL
    ${adminCLI_1_try}=    run keyword and return status    wait until keyword succeeds  5 min   30 sec   ADMIN CLI connection
    run keyword if    '${adminCLI_1_try}'=='True'    run keywords    set suite variable    ${adminCLI_ready}    True
    ...    AND    return from keyword
    ${ssh_asix_ready}=    run keyword and return status   Create connection to Asix
    run keyword if    '${ssh_asix_ready}'=='False'    run keywords    log
    ...    SMOD is not responding still after power reset. Test suite is canceled.    level=WARN    AND    FAIL

Check ping on SMOD
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 1 received

Create connection to Asix
    ${129_ready}=    run keyword and return status    trs_ssh.Connect To
    ...    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=asik
    run keyword if    '${129_ready}'=='False'    trs_ssh.Connect To
    ...    hostname=192.168.255.1
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=asik

Check BTS and reboot
    ${active_partition}=    ssh.execute    ls /ffs/run   connection=asik
    ${valid_partition}=    run keyword and return status    Check partition    ${active_partition}
    run keyword if    '${valid_partition}'=='False'    run keywords   log    Files are missing on active partition
    ...    level=WARN    AND    FAIL
    #ssh.execute    rm /ffs/run/config/users.json   connection=asik
    ssh.Send Command     /sbin/reboot    connection=asik
    ${adminCLI_2_try}=    run keyword and return status    wait until keyword succeeds  5 min   30 sec   ADMIN CLI connection
    run keyword if    '${adminCLI_2_try}'=='True'    set suite variable    ${adminCLI_ready}    True

Check partition
    [Arguments]    ${to_check}
    should contain X times    ${to_check}    HashContainer    6
    should contain X times    ${to_check}    TargetBD    2

Netboot check
    run    sudo systmectl stop dnsmasq

Check unwanted alarms
    [Tags]      WIP
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Perform correct commissioning
    [Tags]      WIP
    [Arguments]    ${skip_parameter_relation_errors}=False
    ${SW}=              admin_cli.get_sw_version
    ${SW1}=             fetch from left    ${SW}    _
    ${SW1}=             remove string    ${SW1}    SBTS
    ${MRBTS_ID}=    convert to string     ${MRBTS_ID}
    ${upload_SCF}=    proper_scf_mapping    ${MRBTS_ID}
    ${True}=   convert to boolean   True
    ${upload_SCF_path}=    replace string    ${upload_SCF}    /scfs/   /scfs/${SW1}/
    ${scf_exist}=    run keyword and return status    OperatingSystem.file should exist    ${upload_SCF_path}
    run keyword if    '${scf_exist}'=='True'    set suite variable    ${upload_SCF}    ${upload_SCF_path}
    wait until keyword succeeds  7 min   30 sec   admin_cli.Perform Commissioning
        ...     scf_file=testsuite/Wroclaw/SISO/TestLines/7_16_UTE5GSISOAUTOT055/SCF/5G/SCF_SISOAUTOT055_SBTS_master.xml
        ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
        ...     connection=default
        ...     timeout=1800
    set suite variable    ${bts_is_ready}    False
    ${more_time_needed}=    run keyword and return status    variable should exist    ${AZQL}
    run keyword if    '${more_time_needed}'=='True'    set suite variable    ${comm_timer}    30 min
    ${OnAir_State_Reached}=    run keyword and return status    wait until keyword succeeds  ${comm_timer}    1 sec    Check gNB status after Commm
    run keyword if    '${OnAir_State_Reached}'=='False'    Reset site if OnAir cannot be reached
    run keyword if    '${OnAir_State_Reached}'=='False'    FAIL    OnAir status cannot be achieved

Check SMOD and BBMOD
    Check if BTS is ready for commisioning
#    Check SMOD
#    Check BBMOD

Check SMOD
    ${bts_info}=  admin_cli.get_fsm_info
    set suite variable    ${SMOD_status}    valid
    FOR    ${SMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${SMOD["status"]["operationalState"]}
        set suite variable    ${availabilityStatus}    ${SMOD["status"]["availabilityStatus"]}
        run keyword if    '${operationalState}'!='Enabled'    set suite variable    ${SMOD_status}    invalid
        run keyword if    '${availabilityStatus}'!='Online'    set suite variable    ${SMOD_status}    invalid
    END
    should be equal as strings  ${SMOD_status}    valid

Check BBMOD
    ${bts_info}=  admin_cli.get_fbb_info
    set suite variable    ${BBMOD_status}    valid
    FOR    ${BBMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${BBMOD["status"]["operationalState"]}
        set suite variable    ${availabilityStatus}    ${BBMOD["status"]["availabilityStatus"]}
        run keyword if    '${operationalState}'!='Enabled'    set suite variable    ${BBMOD_status}    invalid
        run keyword if    '${availabilityStatus}'!='Online'    set suite variable    ${BBMOD_status}    invalid
    END
    should be equal as strings  ${BBMOD_status}    valid

Check gNB status after Commm
    [Documentation]    This keywords will check: OnAir state, error 23 and 10.
    ${onAir_state}=    run keyword and return status    Check if BTS is OnAir state
    run keyword if    '${onAir_state}'=='True'    return from keyword
    ${alarm_list_actual}=    Check unwanted alarms
    ${is_23_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    run keyword if    '${is_23_active}'=='True'    Perform_update
    ${is_10_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    10
    run keyword if    '${is_10_active}'=='True'    Check PDU and set RU power reset
    ${onAir_state_after_check}=    run keyword and return status    Check if BTS is OnAir state
    run keyword if    '${onAir_state_after_check}'=='True'    return from keyword
    FAIL    No onAir state

Check if alarm exist
    [Arguments]    ${alarm_list}    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='False'    FAIL

Check if alarm exist in loop
    [Arguments]    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    ${alarm_list}=    Check unwanted alarms
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='True'    FAIL

Perform_update
    log    Fault 23 was detected. Starting sw update procedure.    level=WARN
    ${SMOD_version}=    Get SMOD version
    ${actual_SW}=       Get Current Soft version
    ${is_CommonBuild}=  Run keyword and return status    Should Contain      ${actual_SW}      SBTS
    ${Downloaded_SW}=   Run keyword if    ${is_CommonBuild}==True    Download CommonBuild Soft
    ...    ELSE    Download Soft    ${actual_SW}    ${SMOD_version}
    ${bool}    ${mesg}    Run keyword and ignore error    Perform Soft Update     ${Downloaded_SW}
    ${is_BTS_busy}        Run keyword and return status    should contain    ${mesg}    ErrorCode: 17
    Run keyword if      '${is_BTS_busy}'=='True'    wait until keyword succeeds    25 min    30 sec    Perform Soft Update     ${Downloaded_SW}
    Run keyword if    '${bool}'=='FAIL' and '${is_BTS_busy}'=='False'     FAIL    ${mesg}
    run keyword if    '${comm_timer}'=='30 min'    set suite variable    ${timer_after_update}    35 min
    ...    ELSE     set suite variable    ${timer_after_update}    20 min
    wait until keyword succeeds  ${timer_after_update}    1 min    Check if BTS is OnAir state
    [Teardown]    Remove unused build

Remove unused build
    ${SW_Version}      admin_cli.get_sw_version
    ${is_TrunkBuild}   Run keyword and return status    Should Contain    ${SW_Version}    ENB_9999
    ${SW_Version}      Run keyword if    ${is_TrunkBuild}==True
    ...  Replace String Using Regexp   ${SW_Version}   ^SBTS[A-Za-z0-9]+_   SBTS00_
    ...  ELSE   Set variable    ${SW_Version}
    ${sw_ready}=        run keyword and return status    OperatingSystem.file should exist
    ...    ${sw_path_prepare}/${SW_Version}${SW_sufix}
    run keyword if    '${sw_ready}'=='False'    Return from keyword
    Run keyword and ignore error    Run    sudo rm ${sw_path_prepare}/${SW_Version}${SW_sufix}

Get Current Soft version
    ${SW}=              admin_cli.get_sw_version
    ${SW1}=             Replace String      ${SW}       _00000    .
    ${SW2}=             Replace String      ${SW1}      _0000    .
    ${SW3}=             Replace String      ${SW2}      _000     .
    ${SW4}=             Replace String      ${SW3}      _00     .
    ${SW5}=             Replace String      ${SW4}      _0     .
    ${SW6}=             Replace String      ${SW5}      _     .
    ${is_trunk}         run keyword and return status    Should Contain      ${SW6}      ..800
    ${SW7}=             Fetch From Right    ${SW6}      GNB.
    ${SW_trunk}=        run keyword if    ${is_trunk}==True    Replace String      ${SW7}      .800.    0.800.
    run keyword if    ${is_trunk}==True    set suite variable    ${SW7}    ${SW_trunk}
    [Return]            ${SW7}

Get SMOD version
    ${SMOD_name}=    admin_cli.get_fsm_info
    ${SMOD_name}=    set variable    ${SMOD_name[0]["productName"]}
    ${SMOD_name}=    fetch from left    ${SMOD_name}    ${SPACE}
    ${SMOD_name}=    catenate    SEPARATOR=    _    ${SMOD_name}    _ABIL.zip
    [Return]    ${SMOD_name}

Download Soft
    [Arguments]         ${SW_Version}    ${SMOD_version}
    ${version}=         Fetch From Right    ${SW_Version}   .
    ${fetcher}=         Catenate       .${version}
    ${branch}=          Remove String     ${SW_Version}    ${fetcher}
    ${pkg}=             Set Variable    .zip
    ${sw_name}=         Catenate    AirScale-${SW_Version}${pkg}
    ${sw_ready}=        run keyword and return status    OperatingSystem.file should exist    ${sw_path_prepare}/${sw_name}
    run keyword if    '${sw_ready}'=='True'    Return from keyword    ${sw_name}
    ${sw_url}=          Catenate    sudo wget ${arti}${SW_Version}/${sw_name} -nv -P ${sw_path_prepare}
    ${res}=             Run         ${sw_url}
    [Return]            ${sw_name}

Download CommonBuild Soft
    ${SW_Version}      admin_cli.get_sw_version
    ${is_TrunkBuild}   Run keyword and return status    Should Contain    ${SW_Version}    ENB_9999
    ${SW_Version}      Run keyword if    ${is_TrunkBuild}==True
    ...  Replace String Using Regexp   ${SW_Version}   ^SBTS[A-Za-z0-9]+_   SBTS00_
    ...  ELSE   Set variable    ${SW_Version}
    ${SW_prefix}       Run keyword if    ${is_TrunkBuild}==True   Set Variable    SBTS00
    ...  ELSE          Get Substring    ${SW_Version}    0    8
    ${sw_ready}=        run keyword and return status
    ...  OperatingSystem.file should exist    ${sw_path_prepare}/${SW_Version}${SW_sufix}
    run keyword if    '${sw_ready}'=='True'    Return from keyword   ${SW_Version}${SW_sufix}
    ${sw_url}          Catenate    sudo wget ${rdnet_disc}/${SW_prefix}/${SW_Version}/${SW_Version}${SW_sufix} -nv -P ${sw_path_prepare}
    ${res}             Run         ${sw_url}
    [Return]           ${SW_Version}${SW_sufix}


Perform Soft Update
    [Arguments]         ${sw}
    ${sw_name}=             Catenate    ${sw_path_prepare}/${sw}
    admin_cli.update_software     sw_package=${sw_name}     should_activate=True    timeout=1800

Check PDU and set RU power reset
    ${Alarm_10_is_resolved}=    run keyword and return status    wait until keyword succeeds    3 min    30 sec
    ...    Check if alarm exist in loop    10
    ${RUs_not_working}=    Check if all RU are enabled
    ${list_is_not_empty}=    run keyword and return status    should not be empty    ${RUs_not_working}
    run keyword if    '${list_is_not_empty}'=='False'    run keywords    log    List of disabled RU's is empty
    ...    level=WARN    AND    return from keyword
    Check SMOD and BBMOD
    run keyword if    '${Alarm_10_is_resolved}'=='True'    Return from keyword
    FOR    ${RU}    IN    @{RUs_not_working}
        log    Starting power reset on RMOD ${RU}.    level=WARN
        ${ru_string}=    convert to string    ${RU}
        ${RMOD_id}=    fetch from right    ${ru_string}    -
        ${RMOD_id}=    fetch from left    ${RMOD_id}    '
        ${RMOD_id}=    evaluate    ${RMOD_id}-1
        set suite variable    ${model}    ${tl.gnbs[0].dus[0].rus[${RMOD_id}].pdu_port.pdu.__class__.__name__}
        set suite variable    ${ip_pdu}    ${tl.gnbs[0].dus[0].rus[${RMOD_id}].pdu_port.pdu.addr}
        set suite variable    ${port}    ${tl.gnbs[0].dus[0].rus[${RMOD_id}].pdu_port.port_no}
        set suite variable    ${version}    ${tl.gnbs[0].dus[0].rus[${RMOD_id}].pdu_port.pdu.version}
        run keyword if    "Gude"=="${model}"
        ...    Set Gude PDU power off RU    ${model}    ${ip_pdu}    ${version}    ${port}
        ...    ELSE    Set PDU power off RU    ${model}    ${ip_pdu}    ${port}
        sleep    10s
        run keyword if    "Gude"=="${model}"
        ...    Set Gude PDU power on RU    ${model}    ${ip_pdu}    ${version}    ${port}
        ...    ELSE    Set PDU power on RU    ${model}    ${ip_pdu}    ${port}
        log    Done.    level=WARN
    END
    wait until keyword succeeds    10 min    1 min    Check if RU's is not in disabled state
    wait until keyword succeeds    ${comm_timer}    30 sec    Check BTS status after RU power reset
    ${alarm_list_actual}=    Check unwanted alarms
    ${23_is_reported}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    run keyword if    '${23_is_reported}'=='True'    Perform_update

Check BTS status after RU power reset
    ${alarm_list_actual}=    Check unwanted alarms
    ${Alarm_10_dissapear_after_reset}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    10
    run keyword if     '${Alarm_10_dissapear_after_reset}'=='True'    FAIL


Set Gude PDU power off RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set PDU power off RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu       model=${model}    host=${host}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set Gude PDU power on RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Set PDU power on RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu       model=${model}    host=${host}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Check if RU's is not in disabled state
    ${bts_info}=  admin_cli.get_frm
    set suite variable    ${RUs_status}    valid
    &{rmod_s}    create dictionary    availabilityStatus=NotInstalled    operationalState=Disabled
    FOR    ${RU}    IN    @{bts_info}
        ${RMOD_R}=    Fetch from right    ${RU["id"]["internal"]}    /
        ${r_status}  run keyword and return status    Check specific status on selected component   ${RMOD_R}    ${rmod_s}
        run keyword if    '${r_status}'=='True'    set suite variable    ${RUs_status}    invalid
    END
    should not be equal as strings  ${RUs_status}    invalid

Reset site if OnAir cannot be reached
    [Documentation]    This keyword will trigger site reset when OnAir state cannot be achieved and faults 10 and 23
    ...    wasn't found
    admin_cli.reset_site
    run keyword and ignore error    wait until keyword succeeds    15 min    1 min    Check if BTS is OnAir state
    ${alarm_list_actual}=    Check unwanted alarms
    ${is_23_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    run keyword if    '${is_23_active}'=='True'    Perform_update
    ${OnAir_lc}=    run keyword and return status    Check if BTS is OnAir state
    run keyword if    '${OnAir_lc}'=='True'    set suite variable    ${OnAir_State_Reached}    True

Check if all RU are enabled
    [Documentation]    This keyword will check status of all RU's. If more than one will have state othe than enabled
    ...   warning log will be created. This keyword will not trigger RMOD reset.
    &{expected_rmod_status}    create dictionary    availabilityStatus=Online    operationalState=Enabled
    ${RU_info}=  admin_cli.get_frm
    ${list_of_disabled_RUs}=    Create list
    ${list_of_disabled_RUs_by_name}=    Create list
    FOR     ${RU}    IN    @{RU_info}
        set suite variable    ${valid}    True
        set suite variable    ${RU_number}    ${RU["id"]["configuration"]}
        ${RU_name}=    Fetch from right    ${RU_number}    /
        ${RU_number}=    Fetch from right    ${RU_number}    -
        ${status}=    Run Keyword And return Status    Check Specific Status On Selected Component   RMOD-${RU_number}  ${expected_rmod_status}
        Run Keyword Unless  '${status}'=='True'  set suite variable    ${valid}    False
        run keyword if    '${valid}'=='False'    append to list    ${list_of_disabled_RUs}    ${RU_number}
        run keyword if    '${valid}'=='False'    append to list    ${list_of_disabled_RUs_by_name}    ${RU_name}
    END
    ${empty_RU_list}=    run keyword and return status    should be empty    ${list_of_disabled_RUs}
    run keyword if    '${empty_RU_list}'=='False'    run keywords    log   Not all RUs were enabled. List of malfunction RUs:
    ...    level=WARN    AND    log list    ${list_of_disabled_RUs_by_name}    level=WARN
    [Return]    ${list_of_disabled_RUs}

Check cells_status
    run keyword and ignore error    wait until keyword succeeds  5 min    10 sec   Check all cells
    ${alarm_dict}=    Check unwanted alarms list
    log    Active alarm list:    level=WARN
    log list    ${alarm_dict}    level=WARN
    ${get_cell_status}=    admin_cli.get_cells_info
    set suite variable    ${cells_enabled}    True
    ${cells_status_list}    create list
    &{cell_s}    create dictionary    availabilityStatus=Online    operationalState=Enabled
    FOR    ${cell}    IN    @{get_cell_status}
        log    ${cell}
        set suite variable    ${cell_status}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        ${cell_number_R}=    Fetch from right    ${cell["id"]["internal"]}    /
        ${c_status}  run keyword and return status    Check specific status on selected component   ${cell_number_R}    ${cell_s}
        run keyword if    '${c_status}'!='True'    run keywords    set suite variable    ${cell_status}
        ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
        ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    ${not_full_check}=    run keyword and return status    should be equal    ${only_OnAir}    True
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='True'    Log as success    ${cells_status_list}
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='False'    run keywords
    ...    Log as failure    ${cells_status_list}    AND    FAIL
    run keyword if    '${not_full_check}'=='True'    Log as unimportant    ${cells_status_list}

Send info as list
    [Arguments]    ${list_to_log}
    log list    ${list_to_log}    level=WARN

Log as success
    [Arguments]    ${cells_status_list}
    log    All cells are enabled    level=WARN
    Send info as list    ${cells_status_list}

Log as failure
    [Arguments]    ${cells_status_list}
    log    One or more cells are disabled. All tests are canceled.    level=WARN
    Send info as list    ${cells_status_list}

Log as unimportant
    [Arguments]    ${cells_status_list}
    log    Cells status list    level=WARN
    Send info as list    ${cells_status_list}

Check unwanted alarms list
    [Tags]      WIP
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        ${tmp_alarm}    create dictionary    id    ${tmp_id}
        ${tmp_an}    Get From Dictionary    ${active_alarms[${i}]}    alarmName
        set to dictionary    ${tmp_alarm}    Alarm Name    ${tmp_an}
        ${tmp_fn}    Get From Dictionary    ${active_alarms[${i}]}    faultName
        set to dictionary    ${tmp_alarm}    Fault Name    ${tmp_fn}
        ${tmp_cl}    Get From Dictionary    ${active_alarms[${i}]}    impactedCellsList
        set to dictionary    ${tmp_alarm}    Cell List    ${tmp_cl}
        Append To List    ${alarm_id_list}    ${tmp_alarm}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check all cells
    &{unexpected_cell_status}    create dictionary    availabilityStatus=Online    operationalState=Enabled
    ${cells_statuses}    run keyword and return status    Check specific status on selected component     NRCELL_R-all    ${unexpected_cell_status}
    run keyword if    '${cells_statuses}'=='False'   FAIL    One or more cells are disabled.

Check software on SMOD before preparation
    Connect Ssh To Asix
    ${first_partition}=    ssh.execute    ls /ffs/run   connection=asik
    ${second_partition}=    ssh.execute    ls /ffs/stb   connection=asik
    log    ${first_partition}
    log    ${second_partition}
    [Teardown]    Disconnect Ssh From Asix

Lock RMODs
    ${variables}   Get variables
    ${is_SUITE_NAME}  Run Keyword And Return Status  Evaluate   $SUITE_NAME in $variables
    ${is_TEST_NAME}   Run Keyword And Return Status  Evaluate   $TEST_NAME in $variables
    ${is_Suite_Setup_level}     Run keyword if  '${is_TEST_NAME}'=='${False}' and '${PREV_TEST_STATUS}'=='${EMPTY}'  Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    run keyword if    '${is_Suite_Setup_level}'=='True'    return from keyword
    ${RU_info}=  admin_cli.get_frm
    FOR     ${RU}    IN    @{RU_info}
        set suite variable    ${RU_number}    ${RU["id"]["runtime"]}
        ${RU_number}=    Fetch from right    ${RU_number}    -
        Lock RU    ${RU_number}
    END

Unlock RMODs
    ${variables}   Get variables
    ${is_SUITE_NAME}  Run Keyword And Return Status  Evaluate   $SUITE_NAME in $variables
    ${is_TEST_NAME}   Run Keyword And Return Status  Evaluate   $TEST_NAME in $variables
    ${is_Suite_Setup_level}     Run keyword if  '${is_TEST_NAME}'=='${False}' and '${PREV_TEST_STATUS}'=='${EMPTY}'  Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    run keyword if    '${is_Suite_Setup_level}'=='False'    return from keyword
    ${RU_info}=  admin_cli.get_frm
    FOR     ${RU}    IN    @{RU_info}
        set suite variable    ${RU_number}    ${RU["id"]["runtime"]}
        ${RU_number}=    Fetch from right    ${RU_number}    -
        Unlock RU    ${RU_number}
    END
    &{expected_status}    create dictionary    availabilityStatus=online
    ...                                        operationalState=enabled
    ...                                        administrativeState=unlocked
    Wait Until Keyword Succeeds    2min    5sec
    ...    Check specific status on selected component    NRCELL-All    ${expected_status}

Shutdown SMOD
    ${variables}   Get variables
    ${is_SUITE_NAME}  Run Keyword And Return Status  Evaluate   $SUITE_NAME in $variables
    ${is_TEST_NAME}   Run Keyword And Return Status  Evaluate   $TEST_NAME in $variables
    ${is_Suite_Setup_level}     Run keyword if  '${is_TEST_NAME}'=='${False}' and '${PREV_TEST_STATUS}'=='${EMPTY}'  Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    run keyword if    '${is_Suite_Setup_level}'=='True'    return from keyword
    Power off SMOD after execution

Reboot SMOD
    ${variables}   Get variables
    ${is_SUITE_NAME}  Run Keyword And Return Status  Evaluate   $SUITE_NAME in $variables
    ${is_TEST_NAME}   Run Keyword And Return Status  Evaluate   $TEST_NAME in $variables
    ${is_Suite_Setup_level}     Run keyword if  '${is_TEST_NAME}'=='${False}' and '${PREV_TEST_STATUS}'=='${EMPTY}'  Set variable  ${True}
    ...  ELSE  Set variable  ${False}
    ${SMOD_pingable}=    run keyword and return status    Check ping on SMOD
    run keyword if    '${is_Suite_Setup_level}'=='False' or '${SMOD_pingable}'=='True'    return from keyword
    Power on SMOD before execution
    sleep    5m

Power off SMOD after execution
        [Arguments]    ${model}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ...               ${ip_pdu}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...               ${port}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...               ${version}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.version}
    run keyword if    "Gude"=="${model}"
    ...    Set Gude PDU power off RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power off RU    ${model}    ${ip_pdu}    ${port}
    sleep    10s
    ${is_SMOD_disabled}=    run keyword and return status    wait until keyword succeeds    2 min    10 sec    Ping disabled SMOD
    run keyword if    '${is_SMOD_disabled}'=='True'    run keywords    log
    ...    SMOD was turned down    level=WARN    AND    return from keyword
    ...    ELSE    run keywords    log
    ...    SMOD is not disabled.    level=WARN    AND    FAIL

Power on SMOD before execution
        [Arguments]    ${model}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ...               ${ip_pdu}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...               ${port}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...               ${version}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.version}
    run keyword if    "Gude"=="${model}"
    ...    Set Gude PDU power on RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power on RU    ${model}    ${ip_pdu}    ${port}
    sleep    10s
    ${is_SMOD_pingable}=    run keyword and return status    wait until keyword succeeds    5 min    30 sec    Check ping on SMOD
    run keyword if    '${is_SMOD_pingable}'=='False'    run keywords    log
    ...    SMOD is not responding. Please check module.    level=WARN    AND    FAIL

Ping disabled SMOD
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 0 received

#Perform correct SW configuration
  #  [Tags]     WIP
  #  ${sw_version}=    admin_cli.Get Sw Version
  #  ...    connection=default
  #  ssh.connect to    192.168.255.1    toor4nsn    oZPS0POrRieRtu
  #  ssh.download file    /ffs/run/swconfig.txt    ${sw_Path}
  #  ${Valid_state}=    check valid sw config    ${sw_version}    ${sw_Path}
  #  run keyword unless     ${Valid_state}    modify sw config    ${sw_version}    ${sw_Path}
  #  ssh.upload file    /home/ute/swconfig_from_bts.txt    /ffs/run/swconfig.txt
  #  ssh.send command    reboot
  #  ssh.disconnect
  #  wait until keyword succeeds    5 min    1 min    Check if eNB is pingable
