*** Settings ***

Documentation    Common keywords for ST

Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.nms.netact    WITH NAME    nms_netact
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.l1l2bip        WITH NAME      l1l2bip
Library    taf.collectors.core           WITH NAME      core
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.hw.rf_attenuator.attenuator  WITH NAME  attenuator
Library    taf.transport.ssh    WITH NAME    SSH
Library    taf.sw.reporting_portal    WITH NAME    rp
Library   taf.sw.dcap.rd    WITH NAME    rd
Library   taf.collectors.btslog  WITH NAME   btslog
Library   taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library   ../../../../ORAN/resources/python/SysValidation.py  WITH NAME  Validation
Library   testsuite.Bangalore.ORAN.resources.python.ta_ultracaller  WITH NAME  uc
#library   OperatingSystem    WITH NAME    os
Library   ta5g_pm_counters
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library    ute_fsmaccess



*** Keywords ***
Require ue for ue functions
    uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}

initial ue attach via ultracaller
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}

detach ue via ultracaller
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}


Test_Setup_keywords
    [Documentation]    Test Pre condition
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...    password=${BTS_Details.password}  admin_api_log_dir=${BTS_Details.admin_api_log_dir}    release=${BTS_Details.release}
    #Run Keyword And Ignore Error    Start_Dcap
    Get_Pre_Active_alarms


Test_Teardown_Keywords
    [Documentation]    Test post condition

    #Run Keyword And Ignore Error    Stop_Dcap
    Get_Post_Active_alarms
    #Run Keyword And Continue On Failure    interface.Common step trigger
    admin.teardown_admin

Get_Pre_Active_alarms
    [Documentation]    Active Alarms
    ${Pre_Active_Alarm}    admin.get_active_alarms
    Log    ${Pre_Active_Alarm}

Get_Post_Active_alarms
    [Documentation]    Keyword is feature purpose for alarm validation.
    ${Post_Active_Alarm}    admin.get_active_alarms
    Log    ${Post_Active_Alarm}

start Btslogs from Local machine
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Stops Btslogs from Local machine
    [Arguments]    ${log_alias}
    core.stop_collectors      names=${log_alias}
    core.collect_collectors      names=${log_alias}
    core.teardown_collectors      names=${log_alias}

Setup_attenuator_objects
	[Documentation]  Author: Arunkumar A
    ...    Integrated along with https://taf-hw-rf-attenuator.docs.taf.ute.nsn-rdnet.net/
    [Arguments]   ${attenuation_ports}
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}

Attenuate the Port Value
    [Arguments]     ${attenuation_ports}   ${set_value}
    FOR  ${port}  IN  @{attenuation_ports}
    ${port_value}  attenuator.read_attenuation  port=${port}
        Run keyword    Run Keyword If   "${port_value}dB"!="${set_value}"  attenuator.set_attenuation    port=${port}
     ...    value=${set_value}  confirm=${True}   confirmation_delay=5
     ...    ELSE    BuiltIn.Log To console    [ INFO ]: Port Number: ${port} and value: ${port_value}
    END

Perform delta commissioning
    [Arguments]    ${DELTA_PATH}
    admin.Perform Delta Recommissioning
    ...    delta_file=${DELTA_PATH}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=${connection}
    Log To Console    success

Perform commissioning
    [Arguments]    ${commision_file}
    admin.perform_commissioning
    ...    bts_id=${BTS_ID}
    ...    scf_file=${commision_file}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=300
    ...    alias=${connection}
    Log To Console    success

