*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: EDA test case for 03620988

Resource       taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library       DateTime
Library       ./resources/memory_management.py
Library       testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.EDA_for_03620988.resources.netact.NetactScripts
Library       ta_emss
Resource      ../../../../resources/NJ_Resources/Resources/robot/DevNJ_emssim.robot

Library    OperatingSystem
Library    String
Library    taf.transport.ssh   WITH NAME    ssh
Library    Telnet

Test Timeout  24 hours

Suite Setup     Run Keywords
...             gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/7_7_UTE5GCLOUDT1SK148/swconfig.txt
...             AND  Common Suite Setup With Commissioning  asir_hub=${True}
#Suite Setup         Common Suite Setup With Commissioning  prefix_tag=EDA  asir_hub=${True}
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
${bts_id}=       ${tl.gnbs[0].global_bts_id}
${mplane_ip}=    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]}
${host_ip}=      ${tl.test_pcs[0].default_ssh_connection_details.addr}
${pm_interval}    15
${SAMPLES_CELL_AVAIL}    M55601C00002
&{counter_data}       technology=NRBTS-Nokia AirScale BTS 5G
...                   measurement=NR Cell Availability
...                   netact_counters=ALL
...                   filter_by=MRBTS
...                   mo_names=MRBTS-${bts_id}
...                   object_aggregation=NRCEL
...                   time_aggregation=RAW
...                   time_filter=realtime
...                   look_back_period=${90}
@{additional_allowed_alarms}
...    BTS site autonomous reset as recovery action
...    BTS Reset Cause
...    High memory consumption
...    No X2 link available

*** Test Cases ***
EDA_for_03620988
    gnb_counter.Wait for next PM period    interval=${pm_interval}
    allocate_all_memory
    gnb_counter.Wait for next PM period    interval=${pm_interval}
    ${counters}  get_netact_counters    &{counter_data}
    should not be empty    ${counters}
    gnb_counter.Wait for next PM period    interval=${pm_interval}
    ${counters}  get_netact_counters    &{counter_data}
    should not be empty    ${counters}

emssim
    gnb_counter.Validate counter interval    counter_id=${SAMPLES_CELL_AVAIL}    expected_interval=${pm_interval}     timeout=60
    allocate_all_memory
    gnb_counter.Wait for next PM period    interval=${pm_interval}
    Verify counters update via EMSSIM
    gnb_counter.Wait for next PM period    interval=${pm_interval}
    Verify counters update via EMSSIM



*** Keywords ***
Prepare gNB EMSSim Setup
    [Documentation]  This keyword is to prepare emssim env and start emssim.
    [Arguments]        ${bts_id}=${tl.gnbs[0].global_bts_id}
    ...                 ${mplane_ip}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    ...                 ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 ${json_port}=${0}

    ${macrouser}=        Set Variable    macro${bts_id}
    Run    sudo /opt/emssim/util/add_user.pl -u ${macrouser} -ip ${mplane_ip}
    Sleep    5s
    Run    cd /home/macro${bts_id}
    Telnet.Open Connection    host=0    port=8061
    Telnet.Set Prompt     FBOX>
    Telnet.Set Timeout    3 seconds
    Telnet.Write          reload
    Telnet.Close Connection

    Log To Console    \n start emssim
    ${default_port}=    Get EMSSim JSON Port From Local User    emssim_user=${macrouser}
    ${port}=    Set Variable If    ${json_port}==${0}    ${default_port}
    Log To Console    \nbts_id=${bts_id} host=${host} port=${port} user=${macrouser}
    Setup Emss    bts_id=${bts_id}    host=${host}    port=${port}    user=${macrouser}    wait_connected=False    alias=macroCM
    Log To Console    setup gNB emssim successfully on host  ${host}_${macrouser}

Get EMSSim JSON Port From Local User
    [Arguments]         ${emssim_user}
    ${file}=       Set Variable    /home/${emssim_user}/start
    ${content}=    OperatingSystem.Get File    ${file}
    ${port}=    Get Regexp Matches    ${content}    JSON_PORT\\s*(\\d+)    1

    [return]    ${port[0]}

Get current BTS date
    ${epoch_time}    Run    sshpass -p "oZPS0POrRieRtu" ssh toor4nsn@192.168.255.129 "date '+%Y-%m-%d %H:%M:%S'"
    #    ${epoch_time}    convert to integer   ${epoch_time.split('\n')[1]}
    ${date}    DateTime.convert_date    ${epoch_time}
    [return]    ${date}

Verify counters update via EMSSIM
    [Arguments]        ${bts_id}=${tl.gnbs[0].global_bts_id}
    ...                 ${mplane_ip}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    ...                 ${host_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    Prepare gNB EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}
    ${update_date}    get_time_of_latest_counter_update
    ...    object_name=NE-NRBTS-77116/NRCELL-1    counter_id=M55601C00002    enb_id=0  bts_id=0  alias=macroCM
    ${counter_value}    get_value_of_counter
    ...    object_name=NE-NRBTS-77116/NRCELL-1    counter_id=M55601C00002    enb_id=0  bts_id=0  alias=macroCM
    should be equal    ${counter_value}    ${900}
    ${update_date}    DateTime.convert_date    ${update_date}
    ${current_date}    Get current BTS date
    ${time_difference}    DateTime.subtract date from date    ${current_date}    ${update_date}
    should be true    ${1800}>${time_difference}>${900}
