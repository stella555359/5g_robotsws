*** Settings ***
Documentation

Library    OperatingSystem
Library    SSHExtension.py  WITH NAME  ssh
Library    taf.wts.runner   WITH NAME  wtsrunner
Library    ../../resources/DevHZ5_lib/src/common_lib.py
Variables   variables.py


*** Keywords ***
SANSA Common Suite Setup
    Add IP addresses for NSA
#    Copy WTS Configuration
    Start WTS
    Wait for SimMode is ACTIVE
    Wait for SIB-NR

Add IP addresses for NSA
    Run  sudo ip a add 10.0.1.131/24 dev eth3
    Run  sudo ip a add 10.0.1.132/24 dev eth3
    Run  sudo ip a add 10.0.1.133/24 dev eth3
    Run  sudo ip a add 10.0.1.134/24 dev eth3
    Run  sudo ip a add 10.0.1.135/24 dev eth3
    Run  sudo ip a add 10.0.1.136/24 dev eth3
    Run  sudo ip a add 10.0.1.137/24 dev eth3

Wait for SimMode is ACTIVE
    [Arguments]  ${timeout}=60
    wtsrunner.read_wtsemu_output_until_re  CHANGE STATE: ACTIVE  timeout=${timeout}
    Log to console  WTS: ACTIVE

Start WTS
    [Arguments]  ${timeout}=60
    ssh.connect_to  ${WTS['host']['hostname']}    ${WTS['host']['username']}    alias=${WTS['host']['alias']}
    wtsrunner.Configure WTSemu edaemon  ${WTS['edaemon']['edaemon_ssh_alias']}     ${WTS['edaemon']['directory_path']}    
    ...    ${WTS['edaemon']['port']}    ${WTS['edaemon']['sudo_password']}
    wtsrunner.Configure WTSemu egate  ${WTS['egate']['egate_ssh_alias']}     ${WTS['egate']['directory_path']}
    ...    ${WTS['egate']['port']}    ${WTS['egate']['sudo_password']}   ${WTS['egate']['nostats']}
    wtsrunner.Start WTSemu
    ...  egate_console_ip=${WTS}[host][hostname]
    ...  egate_port=${WTS}[egate][port]
    wtsrunner.Configure  file=${WTS_CFG}
    wtsrunner.read_wtsemu_output_until_re  CHANGE STATE: STARTED  timeout=${timeout}
    Log to console  WTS: STARTED

Wait for SIB-NR
    [Arguments]  ${timeout}=60
    Repeat keyword  6 times  wtsrunner.read_wtsemu_output_until_re  SystemInformationBlockType[123]-NR updated  timeout=${timeout}
    Log to console  WTS: SIB-NR type 1, 2, 3 updated

SA attach
    [Arguments]  ${id}  ${timeout}=30
    wtsrunner.ue_register  id=${id}
    wtsrunner.read_wtsemu_output_until_re  REGISTRATION COMPLETE  timeout=${timeout}
    Log to console  WTS: REGISTRATION COMPLETE for UE-${id}

Setup PDU session
    [Arguments]  ${pdu}  ${ue}  ${nwslice}  ${gw}  ${timeout}=15
    wtsrunner.set_pdu_param  ue=${ue}  pdu=${pdu}  trf_type=internal
    wtsrunner.ue_pdu_session_setup  pdu=${pdu}  ue=${ue}  nwslice=${nwslice}  gw=${gw}
    wtsrunner.read_wtsemu_output_until_re  Initial Context Setup Successful  timeout=${timeout}
    Log to console  WTS: Initial Context Setup Successful for UE-${ue}

Trigger X2 link
    [Arguments]  ${enb}  ${target}  ${timeout}=15
    wtsrunner.enb_x2_link_up  enb=${enb}  target=${target}
    wtsrunner.read_wtsemu_output_until_re  ENB-${enb}: X2AP Link with GNB-${target}.* is up  timeout=${timeout}
    Log to console  WTS: X2 link is up

LTE attach
    [Arguments]  ${id}  ${timeout}=15
    wtsrunner.ue_attach  id=${id}
    wtsrunner.read_wtsemu_output_until_re  UE IS ACTIVE  timeout=${timeout}
    Log to console  WTS: UE${id} is active

sgNB addition
    [Arguments]  ${ue}  ${target_gnb}  ${target_cells}  ${bearer}  ${type}=split_scg  ${timeout}=15
    wtsrunner.enb_ue_dc_start  ue=${ue}  target_gnb=${target_gnb}  target_cells=${target_cells}  bearer=${bearer}  type=${type}
    wtsrunner.read_wtsemu_output_until_re  UE${ue}: Proxy .* reported successful RA  timeout=${timeout}
    Log to console  WTS: sgNB addition for UE${ue} completed

NSA attach
    [Arguments]  ${ue}  ${enb}  ${gnb}  ${target_cells}  ${bearer}
    LTE attach  ${ue}
    sgNB addition  ${ue}  ${gnb}  ${target_cells}  ${bearer}

Start SA traffic
    [Arguments]  ${ue}  ${pdu}  ${qfi}  ${dir}  ${trf_id}  ${protocol}  ${mbps}  ${timeout}=15
    wtsrunner.trf_data_start  ue=${ue}  pdu=${pdu}  qfi=${qfi}  dir=${dir}  trf_id=${trf_id}  protocol=${protocol}  mbps=${mbps}
    ${regexp}=  Set variable if
    ...  "${dir}" == "dl"    Started Downlink Internal traffic
    ...  "${dir}" == "ul"    Started Uplink Internal traffic
    wtsrunner.read_wtsemu_output_until_re  ${regexp}  timeout=${timeout}
    Log to console  WTS: SA: ${regexp}

Start NSA traffic
    [Arguments]  ${ue}  ${id}  ${dir}  ${trf_id}  ${protocol}  ${mbps}  ${timeout}=15
    wtsrunner.trf_data_start  ue=${ue}  id=${id}  dir=${dir}  trf_id=${trf_id}  protocol=${protocol}  mbps=${mbps}
    wtsrunner.read_wtsemu_output_until_re  UE ${ue}: ${protocol.upper()}\[\\s\\S\]*?${dir.upper()} TRF  timeout=${timeout}
    Log to console  WTS: NSA: Started ${dir} Internal traffic

Stop SA traffic
    [Arguments]  ${ue}  ${pdu}  ${qfi}  ${dir}  ${timeout}=15
    wtsrunner.trf_data_stop  ue=${ue}  pdu=${pdu}  qfi=${qfi}  dir=${dir}
    ${regexp}=  Set variable if
    ...  "${dir}" == "dl"    Stopped Downlink Internal traffic
    ...  "${dir}" == "ul"    Stopping Uplink Internal traffic
    wtsrunner.read_wtsemu_output_until_re  ${regexp}  timeout=${timeout}
    Log to console  WTS: SA: ${regexp}

Stop NSA traffic
    [Arguments]  ${ue}  ${id}  ${dir}  ${trf_id}  ${timeout}=15
    wtsrunner.trf_data_stop  ue=${ue}  id=${id}  dir=${dir}  trf_id=${trf_id}
    wtsrunner.read_wtsemu_output_until_re  Traffic was stopped for 1 bearers  timeout=${timeout}
    Log to console  WTS: NSA: Stopped ${dir} Internal traffic

Release PDU session
    [Arguments]  ${ue}  ${pdu}  ${timeout}=15
    wtsrunner.ue_pdu_session_release  ue=${ue}  pdu=${pdu}
    wtsrunner.read_wtsemu_output_until_re  Successfully released PDU Session  timeout=${timeout}
    Log to console  WTS: PDU session released

SA detach
    [Arguments]  ${id}  ${ue_deregister_type}  ${by}  ${timeout}=15
    wtsrunner.ue_deregister  id=${id}  ue_deregister_type=${ue_deregister_type}  by=${by}
    wtsrunner.read_wtsemu_output_until_re  UE${id}: detached  timeout=${timeout}
    Log to console  WTS: SA: UE${id}: detached

NSA Detach
    [Arguments]  ${ue}  ${bearer}  ${by}  ${cause}  ${timeout}=15
    wtsrunner.enb_ue_dc_release  ue=${ue}  bearer=${bearer}  by=${by}  cause=${cause}
    wtsrunner.read_wtsemu_output_until_re  Bearer-type change from SCG-split to MCG is[\\s\\S]*?successful  timeout=${timeout}
    Log to console  WTS: NSA: UE${ue}: detached

LTE detach
    [Arguments]  ${id}  ${timeout}=15
    wtsrunner.ue_detach  id=${id}
    wtsrunner.read_wtsemu_output_until_re  UE${id}: detached  timeout=${timeout}
    Log to console  WTS: UE${id}: detached

SANSA Common Suite Teardown
    wtsrunner.kill_wtsemu_egate    egate_port=${WTS}[egate][port]
    wtsrunner.kill_wtsemu_edaemon  edaemon_port=${WTS}[edaemon][port]
    SSH.reset_cache

Copy WTS Configuration
    Run    rm -rf ${WTS_DIR}/basic_setup.cfg
    Copy File   ${WTS_CFG_PATH}     ${WTS_DIR}/basic_setup.cfg

Verify SA Throughput
    [Documentation]    verify SA Tput
    [Arguments]    ${Tput_dl}=9.8    ${Tput_ul}=9.8    ${sleep_time}=600s
    Log to console  Begin to check SA throughput
    sleep    ${sleep_time}    
    ${dl_throughput_1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput_1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput_1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput_1}/1000>${Tput_ul}
    ${dl_throughput_2}    Ap Get SA Throughput    ue_id=2    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput_2}    Ap Get SA Throughput    ue_id=2    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput_2}/1000>${Tput_dl}
    Should Be True    ${ul_throughput_2}/1000>${Tput_ul}

Verify NSA Throughput
    [Documentation]    verify NSA Tput
    [Arguments]    ${Tput_dl}=9.8    ${Tput_ul}=9.8    ${sleep_time}=600s
    Log to console  Begin to check NSA throughput
    sleep    ${sleep_time}
    ${ul_throuput_1}    Ap Get NSA Throughput    ue_id=11    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throuput_1}    Ap Get NSA Throughput    ue_id=11    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${ul_throuput_1}/1000>${Tput_dl}
    Should Be True    ${dl_throuput_1}/1000>${Tput_ul}
    ${ul_throuput_2}    Ap Get NSA Throughput    ue_id=12    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throuput_2}    Ap Get NSA Throughput    ue_id=12    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${ul_throuput_2}/1000>${Tput_dl}
    Should Be True    ${dl_throuput_2}/1000>${Tput_ul}