*** Settings ***
Documentation     author: Wang binbin
...               contact: binbin.wang@nokia-sbell.com
...               squad group: SG_02
Resource          5GC000679_common_keyword_Dingli.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Library           taf.rfrl.common_resources.python.counters_validation    WITH NAME    counters
Library           CB012238_UE.py

*** Keywords ***
Case Setup CB012238
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    Log To Console    ${build}
    ${result}    String.split string    string=${build}    separator=_
    Log To Console    ${result}
    Set Test Variable     ${version}     ${result}[0]
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932

Get BTS Counters From gNB
    [Arguments]    ${counters_id}
    ${output_counters}    Counters.Get Counters    ${counters_id}
    [Return]    ${output_counters}

Get latest counters values from gNB
    [Arguments]   ${counter_values}    ${counters_unique_path}
    ${counter_value}    Get Counter Values From dict    counter_values=${counter_values}
    ...                                                counters_unique_path=${counters_unique_path}
    ${latest_value}    Convert To Integer    ${counter_value}[-1]
    [Return]    ${latest_value}

Get counter values from dict
    [Documentation]    Get counter values from gNB
    [Arguments]    ${counter_values}    ${counters_unique_path}
    ${counter_values}    Counters.Split Counter Output    ${counter_values}    ${counters_unique_path}
    ${counter_values}    Get Dictionary Values    ${counter_values}[0]
    ${counter_values}    Get Dictionary Values    ${counter_values}[0]
    [Return]    ${counter_values}

CB012238 UE attach and start traffic
    [Arguments]    ${host}    ${port}    ${appserver}    ${appserver_username}    ${appserver_password}
    #create tcp connection to spark control PC
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    #attach UE#1 and start UL DL traffic
    ${ueip}          CB012238_UE.initial ue                       eq_index=1
    ...                                                           conn=${connection}
    ...                                                           apn=dxdata2
    CB012238_UE.ue start ul traffic                               eq_index=1
    ...                                                           conn=${connection}
    ${iperf_cmd}     CB012238_UE.create iperf cmd                 ipaddress=${ueip}
    ...                                                           bandwith=500M
    ...                                                           port=52222
    CB012238_UE.ssh execute command                               hostname=${appserver}
    ...                                                           username=${appserver_username}
    ...                                                           password=${appserver_password}
    ...                                                           command=${iperf_cmd}
    #attach UE#2 and start UL DL traffic
    ${ueip}          CB012238_UE.initial ue                       eq_index=2
    ...                                                           conn=${connection}
    ...                                                           apn=dxdata1
    CB012238_UE.ue start ul traffic                               eq_index=2
    ...                                                           conn=${connection}
    ${iperf_cmd}     CB012238_UE.create iperf cmd                 ipaddress=${ueip}
    ...                                                           bandwith=500M
    ...                                                           port=52222
    CB012238_UE.ssh execute command                               hostname=${appserver}
    ...                                                           username=${appserver_username}
    ...                                                           password=${appserver_password}
    ...                                                           command=${iperf_cmd}
    #attach UE#5 and start UL DL traffic
    ${ueip}          CB012238_UE.initial ue                       eq_index=5
    ...                                                           conn=${connection}
    ...                                                           apn=dxdata2
    CB012238_UE.ue start ul traffic                               eq_index=5
    ...                                                           conn=${connection}
    ${iperf_cmd}     CB012238_UE.create iperf cmd                 ipaddress=${ueip}
    ...                                                           bandwith=500M
    ...                                                           port=52222
    CB012238_UE.ssh execute command                               hostname=${appserver}
    ...                                                           username=${appserver_username}
    ...                                                           password=${appserver_password}
    ...                                                           command=${iperf_cmd}
    CB012238_UE.close tcp connection                              conn=${connection}
    Sleep    900s

CB012238 ue stop ul traffic
    [Arguments]    ${host}    ${port}
    #create tcp connection to spark control PC
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    #UE1 stop UL traffic
    CB012238_UE.ue stop traffic                                   eq_index=1
    ...                                                           conn=${connection}
    Sleep    2s
    #UE2 stop UL traffic
    CB012238_UE.ue stop traffic                                   eq_index=2
    ...                                                           conn=${connection}
    Sleep    2s
    #UE5 stop UL traffic
    CB012238_UE.ue stop traffic                                   eq_index=5
    ...                                                           conn=${connection}
    Sleep    2s
#    close tcp connection to spark control PC
    CB012238_UE.close tcp connection                              conn=${connection}

CB008600 UEs attach and start traffic
    [Arguments]    ${host}    ${port}
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    #initial UEs
    ${ue_status}    CB012238_UE.verify ue status          conn=${connection}
    ...                                                   eq_index=${3}
    IF    ${ue_status}
    Log To Console                                        "UE3 status is OK"
    ELSE
    Log To Console                                        "UE3 status is nok,try to recover ue"
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${3}
    END
#    CB012238_UE.connect ue and initial                    conn=${connection}
#    ...                                                   eq_index=3
    CB012238_UE.initial SA UE                             conn=${connection}
    ...                                                   eq_index=${3}
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=3
    ...                                                   apn=mdrb.nokia.com
    CB012238_UE.lock cell ssb                             conn=${connection}
    ...                                                   eq_index=3
    ...                                                   pci=6
    ...                                                   ssb=509070
    ...                                                   scs=30
    ...                                                   band=41
    CB012238_UE.detach ue                                 eq_index=3
    ...                                                   conn=${connection}
    ${ue_status}    CB012238_UE.verify ue status          conn=${connection}
    ...                                                   eq_index=${4}
    IF    ${ue_status}
    Log To Console                                        "UE4 status is OK"
    ELSE
    Log To Console                                        "UE4 status is nok"
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${4}
    END
    CB012238_UE.initial SA UE                             conn=${connection}
    ...                                                   eq_index=${4}
#    CB012238_UE.connect ue and initial                    conn=${connection}
#    ...                                                   eq_index=4
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=4
    ...                                                   apn=mdrb.nokia.com
    CB012238_UE.lock cell ssb                             conn=${connection}
    ...                                                   eq_index=4
    ...                                                   pci=6
    ...                                                   ssb=509070
    ...                                                   scs=30
    ...                                                   band=41
    CB012238_UE.detach ue                                 eq_index=4
    ...                                                   conn=${connection}
    ${ue_status}    CB012238_UE.verify ue status          conn=${connection}
    ...                                                   eq_index=${7}
    IF    ${ue_status}
    Log To Console                                        "UE7 status is OK"
    ELSE
    Log To Console                                        "UE7 status is nok,try to recover ue"
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${7}
    END
#    CB012238_UE.connect ue and initial                    conn=${connection}
#    ...                                                   eq_index=7
    CB012238_UE.initial SA UE                             conn=${connection}
    ...                                                   eq_index=${7}
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=7
    ...                                                   apn=mdrb.nokia.com
    CB012238_UE.lock cell ssb                             conn=${connection}
    ...                                                   eq_index=7
    ...                                                   pci=6
    ...                                                   ssb=509070
    ...                                                   scs=30
    ...                                                   band=41
    CB012238_UE.detach ue                                 eq_index=7
    ...                                                   conn=${connection}
    Sleep    600s
    #attach UE 3 and start big UL traffic
#    CB012238_UE.attach ue                                 eq_index=3
#    ...                                                   conn=${connection}
    CB008118 Attach Ue                                    eq_index=3
    ...                                                   connection=${connection}
    CB012238_UE.ue start ul traffic                       eq_index=3
    ...                                                   conn=${connection}
    ...                                                   bandwith=204800
    ...                                                   port=52016
    #attach UE4
    CB012238_UE.attach ue                                 eq_index=4
    ...                                                   conn=${connection}
    #detach UE4
    CB012238_UE.detach ue                                 eq_index=4
    ...                                                   conn=${connection}
    #UE3 stop traffic and start small UL traffic
    CB012238_UE.ue stop traffic                           eq_index=3
    ...                                                   conn=${connection}
    Sleep    2s
    CB012238_UE.ue start ul traffic                       eq_index=3
    ...                                                   conn=${connection}
    ...                                                   bandwith=100
    ...                                                   port=52016
    #attach UE4
#    CB012238_UE.attach ue                                 eq_index=4
#    ...                                                   conn=${connection}
    CB008118 Attach Ue                                    eq_index=4
    ...                                                   connection=${connection}
    #attach UE7
    CB012238_UE.attach ue                                 eq_index=7
    ...                                                   conn=${connection}
    Sleep    300s
    #UE3 stop traffic and detach all UEs
    CB012238_UE.ue stop traffic                           eq_index=3
    ...                                                   conn=${connection}
    CB012238_UE.close tcp connection                      conn=${connection}

CB008600 get latest counters from gNB
    [Arguments]   ${counter_values}    ${counters_unique_path}
    ${counter_value}    Get Counter Values From dict    counter_values=${counter_values}
    ...                                                 counters_unique_path=${counters_unique_path}
    ${cycle_1}    Convert To Integer    ${counter_value}[-1]
    ${cycle_2}    Convert To Integer    ${counter_value}[-2]
    ${sum}        Evaluate    ${cycle_1}+${cycle_2}
    [Return]    ${sum}

CB008600 check counters
    [Arguments]    ${counters_id}    ${counters_unique_path}
    ${counter_values}    Run Keyword And Continue On Failure    Get BTS Counters From GNB    counters_id=${counters_id}
    ${M55138C00075}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                         counters_unique_path=${counters_unique_path}[0]
    ${M55138C00076}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                         counters_unique_path=${counters_unique_path}[1]
    ${M55139C00034}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                         counters_unique_path=${counters_unique_path}[6]
    ${M55139C00035}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                         counters_unique_path=${counters_unique_path}[7]
    ${M55139C00037}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                         counters_unique_path=${counters_unique_path}[9]
    ${M55138C00077}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                         counters_unique_path=${counters_unique_path}[2]
    Run Keyword And Continue On Failure    Should Be True       ${M55138C00075}>=${4}
    Run Keyword And Continue On Failure    Should Be True       ${M55138C00076}>=${3}
    Run Keyword And Continue On Failure    Should Be True       ${M55139C00034}>=${3}
    Run Keyword And Continue On Failure    Should Be Equal      ${M55139C00035}    ${2}
    Run Keyword And Continue On Failure    Should Be True       ${M55139C00037}>=${1}
    Run Keyword And Continue On Failure    Should Be True       ${M55138C00077}>=${1}

CB008709 SR E UE attach and start ULDL traffic
    [Arguments]    ${host}    ${port}    ${appserver}    ${appserver_username}    ${appserver_password}
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    ${ue_status}    CB012238_UE.verify ue status         conn=${connection}
    ...                                                   eq_index=${1}
    IF    ${ue_status}
    Log To Console                                        "UE1 status is OK"
    ELSE
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${1}
    END
    CB012238_UE.initial SA UE                             conn=${connection}
    ...                                                   eq_index=${1}
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=1
    ...                                                   apn=dxdata2
    CB012238_UE.lock cell ssb                             conn=${connection}
    ...                                                   eq_index=1
    ...                                                   pci=6
    ...                                                   ssb=503310
    ...                                                   scs=30
    ...                                                   band=41
    Sleep    5s
    CB012238_UE.detach ue                                 eq_index=1
    ...                                                   conn=${connection}
    CB012238_UE.attach ue                                 eq_index=1
    ...                                                   conn=${connection}
    ${ue_status}    CB012238_UE.verify ue status         conn=${connection}
    ...                                                   eq_index=${4}
    IF    ${ue_status}
    Log To Console                                        "UE4 status is OK"
    ELSE
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${4}
    END
    CB012238_UE.initial SA UE                             conn=${connection}
    ...                                                   eq_index=${4}
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=4
    ...                                                   apn=dxdata2
    CB012238_UE.lock cell ssb                             conn=${connection}
    ...                                                   eq_index=4
    ...                                                   pci=6
    ...                                                   ssb=503310
    ...                                                   scs=30
    ...                                                   band=41
    Sleep    5s
    CB012238_UE.detach ue                                 eq_index=4
    ...                                                   conn=${connection}
    CB012238_UE.attach ue                                 eq_index=4
    ...                                                   conn=${connection}
    ${ue1_ip}    CB012238_UE.get ue ip                    conn=${connection}
    ...                                                   eq_index=1
    ...                                                   apn=dxdata2
    ${ue4_ip}    CB012238_UE.get ue ip                    conn=${connection}
    ...                                                   eq_index=4
    ...                                                   apn=dxdata2
    CB012238_UE.ue start ul traffic                       eq_index=1
    ...                                                   conn=${connection}
    ...                                                   bandwith=102400
    ...                                                   port=52016
    CB012238_UE.ue start ul traffic                       eq_index=4
    ...                                                   conn=${connection}
    ...                                                   bandwith=102400
    ...                                                   port=52016
    ${iperf_cmd}     CB012238_UE.create iperf cmd         ipaddress=${ue1_ip}
    ...                                                   bandwith=500M
    ...                                                   port=52222
    CB012238_UE.ssh execute command                       hostname=${appserver}
    ...                                                   username=${appserver_username}
    ...                                                   password=${appserver_password}
    ...                                                   command=${iperf_cmd}
    ${iperf_cmd}     CB012238_UE.create iperf cmd         ipaddress=${ue4_ip}
    ...                                                   bandwith=500M
    ...                                                   port=52222
    CB012238_UE.ssh execute command                       hostname=${appserver}
    ...                                                   username=${appserver_username}
    ...                                                   password=${appserver_password}
    ...                                                   command=${iperf_cmd}
    CB012238_UE.close tcp connection                      conn=${connection}

CB008709 SR E UE stop ULDL traffic
    [Arguments]    ${host}    ${port}    ${appserver}    ${appserver_username}    ${appserver_password}
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    ${ue1_ip}    CB012238_UE.get ue ip                    conn=${connection}
    ...                                                   eq_index=1
    ...                                                   apn=dxdata2
    CB012238_UE.ue stop traffic                           eq_index=1
    ...                                                   conn=${connection}
    CB012238_UE.kill iperf process                        hostname=${appserver}
    ...                                                   username=${appserver_username}
    ...                                                   password=${appserver_password}
    ...                                                   ipaddress=${ue1_ip}
    ${ue4_ip}    CB012238_UE.get ue ip                    conn=${connection}
    ...                                                   eq_index=4
    ...                                                   apn=dxdata2
    CB012238_UE.ue stop traffic                           eq_index=4
    ...                                                   conn=${connection}
    CB012238_UE.kill iperf process                        hostname=${appserver}
    ...                                                   username=${appserver_username}
    ...                                                   password=${appserver_password}
    ...                                                   ipaddress=${ue4_ip}
    CB012238_UE.close tcp connection                      conn=${connection}

CB008709 SR E check pm counters
#    [Arguments]    ${cell_id}    ${counter_id}    ${rg_id}
    ${rg1_dl_used}    CB012238_UE.get sas related counters                cellid=10
    ...                                                                   counterid=M55910C00001
    ...                                                                   rgid=1
    ${rg1_dl_ratio}    CB012238_UE.get sas related counters               cellid=10
    ...                                                                   counterid=M55910C00002
    ...                                                                   rgid=1
    ${rg4_dl_used}    CB012238_UE.get sas related counters                cellid=10
    ...                                                                   counterid=M55910C00001
    ...                                                                   rgid=4
    ${rg4_dl_ratio}    CB012238_UE.get sas related counters               cellid=10
    ...                                                                   counterid=M55910C00002
    ...                                                                   rgid=4
    ${rg1_ul_used}    CB012238_UE.get sas related counters                cellid=10
    ...                                                                   counterid=M55910C00003
    ...                                                                   rgid=1
    ${rg1_ul_ratio}    CB012238_UE.get sas related counters               cellid=10
    ...                                                                   counterid=M55910C00004
    ...                                                                   rgid=1
    ${rg4_ul_used}    CB012238_UE.get sas related counters                cellid=10
    ...                                                                   counterid=M55910C00003
    ...                                                                   rgid=4
    ${rg4_ul_ratio}    CB012238_UE.get sas related counters               cellid=10
    ...                                                                   counterid=M55910C00004
    ...                                                                   rgid=4
    ${cell_dl_abvaliable_prb}    CB012238_UE.get sas related counters     cellid=10
    ...                                                                   counterid=M55308C10013
    ${cell_ul_abvaliable_prb}    CB012238_UE.get sas related counters     cellid=10
    ...                                                                   counterid=M55308C10012
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg1_dl_ratio}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg1_ul_ratio}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg4_dl_ratio}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg4_ul_ratio}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0.31}<${rg1_dl_used}/${cell_dl_abvaliable_prb}<${0.36}
    Run Keyword And Continue On Failure    Should Be True    ${0.6}<${rg4_dl_used}/${cell_dl_abvaliable_prb}<${0.65}
    Run Keyword And Continue On Failure    Should Be True    ${0.31}<${rg1_ul_used}/${cell_ul_abvaliable_prb}<${0.36}
    Run Keyword And Continue On Failure    Should Be True    ${0.6}<${rg4_ul_used}/${cell_ul_abvaliable_prb}<${0.65}

CB008118 verify ue status and detach ue
    [Arguments]    ${eq_index}    ${connection}
    ${eq_index_int}    Convert To Integer    ${eq_index}
    ${ue_status}    CB012238_UE.verify ue status          conn=${connection}
    ...                                                   eq_index=${eq_index_int}
    IF    ${ue_status}
    Log To Console                                        "ue status is OK"
    ELSE
    Log To Console                                        "ue status is nok,try to recover ue"
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${eq_index_int}
    END
    CB012238_UE.initial SA ue                             conn=${connection}
    ...                                                   eq_index=${eq_index_int}
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=${eq_index}
    ...                                                   apn=mdrb.nokia.com
    CB012238_UE.lock cell ssb                             conn=${connection}
    ...                                                   eq_index=${eq_index}
    ...                                                   pci=6
    ...                                                   ssb=509070
    ...                                                   scs=30
    ...                                                   band=41
    CB012238_UE.detach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}

CB008118 attach ue
    [Arguments]    ${eq_index}    ${connection}
    CB012238_UE.attach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}
    ${ue_status}        CB012238_UE.verify ue attach      conn=${connection}
    ...                                                   eq_index=${eq_index}
    ...                                                   apn=mdrbnokiacom
    IF    ${ue_status}
    Log To Console     "UE attached"
    ELSE
    Log To Console     "cannot get ue ip,try to detach and attach"
    CB012238_UE.detach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}
    Sleep                                                 30s
    CB012238_UE.attach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}
    END

ue start ul and dl traffic
    [Arguments]    ${eq_index}    ${connection}    ${appserver}    ${appserver_username}    ${appserver_password}
    ...            ${traffic_port}    ${bandwith_ul}    ${bandwith_dl}    ${apn}
    ${ue_ip}    CB012238_UE.get ue ip                     conn=${connection}
    ...                                                   eq_index=${eqindex}
    ...                                                   apn=${apn}
    CB012238_UE.ue start ul traffic                       eq_index=${eq_index}
    ...                                                   conn=${connection}
    ...                                                   bandwith=${bandwith_ul}
    ...                                                   port=${traffic_port}
    ${iperf_cmd}     CB012238_UE.create iperf cmd         ipaddress=${ue_ip}
    ...                                                   bandwith=${bandwith_dl}
    ...                                                   port=${traffic_port}
    CB012238_UE.ssh execute command                       hostname=${appserver}
    ...                                                   username=${appserver_username}
    ...                                                   password=${appserver_password}
    ...                                                   command=${iperf_cmd}

CB008118 ue attach and start dl ul traffic
    [Arguments]    ${host}    ${port}    ${appserver}    ${appserver_username}    ${appserver_password}
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    Run Keyword And Continue On Failure    CB008118 Verify Ue Status And Detach Ue          eq_index=5
    ...                                                                                     connection=${connection}
    Run Keyword And Continue On Failure    CB008118 Verify Ue Status And Detach Ue          eq_index=6
    ...                                                                                     connection=${connection}
    Run Keyword And Continue On Failure    CB008118 Verify Ue Status And Detach Ue          eq_index=8
    ...                                                                                     connection=${connection}
    Sleep    600s
    Run Keyword And Continue On Failure    CB008118 Attach Ue                               eq_index=5
    ...                                                                                     connection=${connection}
    Run Keyword And Continue On Failure    CB008118 Attach Ue                               eq_index=6
    ...                                                                                     connection=${connection}
    Run Keyword And Continue On Failure    CB008118 Attach Ue                               eq_index=8
    ...                                                                                     connection=${connection}
    Ue Start Ul And Dl Traffic            eq_index=5
    ...                                   connection=${connection}
    ...                                   appserver=${appserver}
    ...                                   appserver_username=${appserver_username}
    ...                                   appserver_password=${appserver_password}
    ...                                   traffic_port=51016
    ...                                   bandwith_ul=10240
    ...                                   bandwith_dl=10M
    ...                                   apn=mdrbnokiacom
    Ue Start Ul And Dl Traffic            eq_index=6
    ...                                   connection=${connection}
    ...                                   appserver=${appserver}
    ...                                   appserver_username=${appserver_username}
    ...                                   appserver_password=${appserver_password}
    ...                                   traffic_port=51017
    ...                                   bandwith_ul=10240
    ...                                   bandwith_dl=10M
    ...                                   apn=mdrbnokiacom
    Ue Start Ul And Dl Traffic            eq_index=8
    ...                                   connection=${connection}
    ...                                   appserver=${appserver}
    ...                                   appserver_username=${appserver_username}
    ...                                   appserver_password=${appserver_password}
    ...                                   traffic_port=51018
    ...                                   bandwith_ul=10240
    ...                                   bandwith_dl=10M
    ...                                   apn=mdrbnokiacom
    CB012238_UE.close tcp connection                      conn=${connection}

CB0081118 check counters
    [Arguments]    ${counters_id}    ${counters_unique_path}
    ${counter_values}    Run Keyword And Continue On Failure    Get BTS Counters From GNB    counters_id=${counters_id}
    ${SA_GBR_DRB_REQ}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                           counters_unique_path=${counters_unique_path}[0]
    ${SA_GBR_DRB_SUCC}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                            counters_unique_path=${counters_unique_path}[1]
    ${SA_DU_GBR_DRB_REQ}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                              counters_unique_path=${counters_unique_path}[2]
    ${SA_DU_GBR_DRB_SUCC}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                               counters_unique_path=${counters_unique_path}[3]
    Run Keyword And Continue On Failure    Should Be True    ${SA_GBR_DRB_REQ}>=3
    Run Keyword And Continue On Failure    Should Be True    ${SA_GBR_DRB_SUCC}==3
    Run Keyword And Continue On Failure    Should Be True    ${SA_DU_GBR_DRB_REQ}>=3
    Run Keyword And Continue On Failure    Should Be True    ${SA_DU_GBR_DRB_SUCC}==3

stop ul and dl traffic
    [Arguments]    ${eq_index}    ${connection}    ${appserver}    ${appserver_username}    ${appserver_password}
    ...            ${apn}
    ${ue_ip}    CB012238_UE.get ue ip                    conn=${connection}
    ...                                                   eq_index=${eq_index}
    ...                                                   apn=${apn}
    CB012238_UE.ue stop traffic                           eq_index=${eq_index}
    ...                                                   conn=${connection}
    CB012238_UE.kill iperf process                        hostname=${appserver}
    ...                                                   username=${appserver_username}
    ...                                                   password=${appserver_password}
    ...                                                   ipaddress=${ue_ip}

CB008118 stop dl ul traffic
    [Arguments]    ${host}    ${port}    ${appserver}    ${appserver_username}    ${appserver_password}
    ${connection}    CB012238_UE.create tcp connection    host=${host}    port=${port}
    Stop Ul And Dl Traffic                                eq_index=5
    ...                                                   connection=${connection}
    ...                                                   appserver=${appserver}
    ...                                                   appserver_username=${appserver_username}
    ...                                                   appserver_password=${appserver_password}
    ...                                                   apn=mdrbnokiacom
    Stop Ul And Dl Traffic                                eq_index=6
    ...                                                   connection=${connection}
    ...                                                   appserver=${appserver}
    ...                                                   appserver_username=${appserver_username}
    ...                                                   appserver_password=${appserver_password}
    ...                                                   apn=mdrbnokiacom
    Stop Ul And Dl Traffic                                eq_index=8
    ...                                                   connection=${connection}
    ...                                                   appserver=${appserver}
    ...                                                   appserver_username=${appserver_username}
    ...                                                   appserver_password=${appserver_password}
    ...                                                   apn=mdrbnokiacom
    CB012238_UE.close tcp connection                      conn=${connection}

CNI140147 block cell
    ${cells}    Create List    2    4    5    501    11
    FOR    ${i}    IN    @{cells}
        CB012238_UE.block cell        host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
        ...                           cellid=${i}
    END

CNI140147 recover cell
    ${cells}    Create List    4    5    501    11
    FOR    ${i}    IN    @{cells}
        CB012238_UE.unblock cell        host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
        ...                             cellid=${i}
    END

CNI140147 attach ue and verify
    [Arguments]    ${eq_index}    ${connection}
    CB012238_UE.attach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}
    ${ue_status}        CB012238_UE.verify ue attach      conn=${connection}
    ...                                                   eq_index=${eq_index}
    ...                                                   apn=dxdata2
    IF    ${ue_status}
    Log To Console     "UE attached"
    ELSE
    Log To Console     "cannot get ue ip,try to detach and attach"
    CB012238_UE.detach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}
    Sleep                                                 30s
    CB012238_UE.attach ue                                 eq_index=${eq_index}
    ...                                                   conn=${connection}
    END

CNI140147 verify ue status and initial ue
    ${connection}    CB012238_UE.create tcp connection    host=${tl.ues[0].ssh_connection_details.addr}
    ...                                                   port=${30999}
    ${ue_status}    CB012238_UE.verify ue status          conn=${connection}
    ...                                                   eq_index=${6}
    IF    ${ue_status}
    Log To Console                                        "ue status is OK"
    ELSE
    Log To Console                                        "ue status is nok,try to recover ue"
    CB012238_UE.recover ue                                conn=${connection}
    ...                                                   eq_index=${6}
    END
    CB012238_UE.initial SA ue                             conn=${connection}
    ...                                                   eq_index=${6}
    CB012238_UE.config ue apn                             conn=${connection}
    ...                                                   eq_index=6
    ...                                                   apn=dxdata2
    CB012238_UE.Unlock Cell Ssb                              conn=${connection}
    ...                                                   eq_index=6
    CB012238_UE.detach ue                                 eq_index=6
    ...                                                   conn=${connection}
    CNI140147 Attach Ue And Verify                        eq_index=6
    ...                                                   connection=${connection}
    CB012238_UE.close tcp connection                      conn=${connection}

CNI140147 attach ue and trigger handover
    CNI140147 block cell
    CNI140147 verify ue status and initial ue
    CB012238_UE.unblock cell        host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                             cellid=2
    Sleep    60s
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=15
    ...                                                                          RU_id=2

    Sleep    20s
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=0
    ...                                                                          RU_id=2
    CNI140147 recover cell

CNI140147 check counters
    [Arguments]    ${counters_id}    ${counters_unique_path}
    ${counter_values}    Run Keyword And Continue On Failure    Get BTS Counters From GNB    counters_id=${counters_id}
    ${SGNB_SA_HO_NGBR_DRB_REQ}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                           counters_unique_path=${counters_unique_path}[0]
    ${SGNB_SA_HO_NGBR_DRB_SUCC}    CB008600 Get Latest Counters From GNB    counter_values=${counter_values}
    ...                                                           counters_unique_path=${counters_unique_path}[1]
    Run Keyword And Continue On Failure    Should Be True    ${SGNB_SA_HO_NGBR_DRB_REQ}>=${1}
    Run Keyword And Continue On Failure    Should Be True    ${SGNB_SA_HO_NGBR_DRB_SUCC}>=${1}

