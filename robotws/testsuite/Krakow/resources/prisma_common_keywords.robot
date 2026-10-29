*** Settings ***
Documentation		Place for prisma attach_detach and  Monitor the UL_DL throughput
...			author: Xing Jing
...			contact: jing.1.xing@nokia-sbell.com
...			in case of changes please contact author,
...			do not modify without permission
...                     Modified : 14-12-2018
...                     Modified By: Xing jing

Library           OperatingSystem
Library           Collections
Library	          Process
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ue.prisma    WITH NAME    prisma
Library           taf.rfrl.common_resources.python.gNB_l2_lo_throughput


*** Variables ***
${lsu_uu}    lsu_uu
${lsu_tstmuu}    lsu_tstmuu
${airmosaic}    airmosaic
${node_name}    airmosaic
${fspa_1_1a}              192.168.253.20
${GNB_AIRSCALE_USERNAME}           toor4nsn
${GNB_AIRSCALE_PASSWORD}           oZPS0POrRieRtu
${5gcell_path}    /res/sdr/state/r5gnr.ue/01
${SYNC}    STATE_00 = SYNC
*** Keywords ***
Prisma setup
    [Arguments]     ${yml_path}    ${tl.ues}
    prisma.load_config    ${yml_path}    ${tl.ues}
    prisma.setup

Restart the prisma LSU
    Prisma setup    ${yml_path}    ${tl.ues}
    prisma.execute_script    node_name=lsu_uu    script_cmd=lsusuid shutdown

Prisma start lsu uu
    [Documentation]
    ...    This keyword is used to start Uu, and Prisma setup must be ok first.
    ${response}=    prisma.start_lsu    ${lsu_uu}    200
    ${LSU_uu Start Completed}=    Evaluate    "lsustart completed correctly" in """${response}"""
    Should be true    ${LSU_uu Start Completed}

Create 5g_cell and lte_cell
    prisma.create_5g_cell    ${lsu_uu}
    sleep    10s
    prisma.create_4g_cell    ${lsu_uu}
    Verify 5g and 4g cell already sync

Verify 5g and 4g cell already sync
    wait until keyword succeeds    5 min    20 sec    Check the NRcell sync
    wait until keyword succeeds    4 min    20 sec    Verify 4g cell already sync    ${4g_cellid_expected}

Verify 5g and 4g cell already sync new
    [Arguments]    ${4g_cellid_expected}
    wait until keyword succeeds    5 min    20 sec    Check the NRcell sync new
    wait until keyword succeeds    4 min    20 sec    Verify 4g cell already sync    ${4g_cellid_expected}

Verify 5g cell already sync
    [Arguments]    ${5g_cellid_expected}
    ${5g_cellid}=    prisma.get_5g_cell_id    node_name=${lsu_uu}
    should be equal    ${5g_cellid[1]}    ${5g_cellid_expected}

Check the NRcell sync
    [Arguments]    ${5gcell_path}=${5gcell_path}
    ${output}=    prisma.execute_script    node_name=${lsu_uu}
    ...    script_cmd=cat ${5gcell_path} | grep STATE
    should be equal    ${output[1]}    ${SYNC}

Check the NRcell sync new
    [Arguments]    ${5gcell_path}=${5gcell_path}
    ${output}=    prisma.execute_script    node_name=${lsu_uu}
    ...    script_cmd=cat ${5gcell_path} | grep STATE
    should contain any    ${output[1]}    ${SYNC}

Verify 4g cell already sync
    [Arguments]    ${4g_cellid_expected}
    ${4g_cellid}=    prisma.get_4g_cell_id    node_name=${lsu_uu}
    should be equal    ${4g_cellid[1]}    ${4g_cellid_expected}

Prisma start tstm uu
    prisma.clean tstm log    node_name=${lsu_tstmuu}
    prisma.start tstm    node_name=${lsu_tstmuu}
	sleep    15s
    ${response}=    prisma.get tstm log    node_name=${lsu_tstmuu}
    ...                                    expected_regex="SOKLISTEN"
    ${Start tstm uu Completed}=    Evaluate    "SOKLISTEN" in """${response}"""
    should be true    ${Start tstm uu Completed}

Start airmosaic
    ${output}=    prisma.start_mosaic
	sleep    60s

Perform UE attach
    [Arguments]    ${sid_file_name}    ${scenario}
    prisma.prepare_test    ${sid_file_name}    ${scenario}    60
    ${output}=     prisma.get_scenario_status
	sleep    40s
    prisma.ue_attach
    ${output}=      prisma.get_scenario_status

Check attach to eNB
    [Arguments]    ${attach_times}
    ${output}=    prisma.get_scenario_logger
	Sleep    10s
	${output}=    Convert to string    ${output}
	Should contain X times    ${output}    UE Attached    ${attach_times}

Check detach eNB
     [Arguments]    ${detach_times}
	 ${output}=    prisma.get_scenario_logger
	 ${output}=    Convert to string    ${output}
	 Should contain X times    ${output}    UE Detached    ${detach_times}

Check keep attach to eNB
     [Arguments]    ${detach_times}
     ${output}=    prisma.get_scenario_logger
     ${output}=    Convert to string    ${output}
	 Should contain X times    ${output}    UE Detached    ${detach_times}
     sleep   5s

Check Random access
    [Arguments]    ${ra_times}
    wait until keyword succeeds    1min    5s    gNB random access    ${ra_times}

gNB random access
    [Arguments]    ${ra_times}
	${output}=        prisma.get_ra_status        node_name=${lsu_uu}
    ${output}=    Convert to string    ${output}
    Should contain X times    ${output}    RA_SuccessCompletion    ${ra_times}

Get the prisma IP
    wait until keyword succeeds    1min    10s    Check the prisma IP

Check the prisma IP
    ${output}=    prisma.execute_script    node_name=${lsu_uu}
    ...    script_cmd=trcinfo -p 0-6|grep pdpip|tail -1|head -1|awk '{print $11}'|cut -d'=' -f2
    set global variable     ${ue_addr}    ${output[1]}
    Should Not Be Empty     ${ue_addr}

Check scenario status
    ${output}=    prisma.get_scenario_status

get scenario log
    [Arguments]    ${log_name}
    prisma.get_scenario_logger    ${log_name}

Teardown prisma
    run keyword and ignore error    prisma.close_mosaic
    run keyword and ignore error    prisma.teardown

Connect to ASIK
    [Arguments]    ${alias}=ASIK
    csn.Connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

Connect to asp1a
    [Arguments]    ${alias}=asp1a    ${proxy}=ASIK
    csn.Connect to    hostname=${fspa_1_1a}    username=${GNB_AIRSCALE_USERNAME}    password=${GNB_AIRSCALE_PASSWORD}
    ...    alias=${alias}    proxy=${proxy}

Monitor the UL_DL throughput
    [Arguments]    ${repeat_times}
    Repeat Keyword    ${repeat_times} times    Count the UL_DL throughput    ${UPLINK_DATA_TRANSFER}    ${DOWNLINK_DATA_TRANSFER}

Count the UL_DL throughput
    [Arguments]     ${UPLINK_DATA_TRANSFER}    ${DOWNLINK_DATA_TRANSFER}
    wait until keyword succeeds    1min    10s    Connect to ASIK
    wait until keyword succeeds    1min    10s    Connect to asp1a
    ${UL_throughoutput}=    Calculate UL throughoutput    alias=asp1a
    ${DL_throughoutput}=    Calculate DL throughoutput    alias=asp1a
    should be true    ${UL_throughoutput} >= ${UPLINK_DATA_TRANSFER}
    should be true    ${DL_throughoutput} >= ${DOWNLINK_DATA_TRANSFER}
    csn.disconnect    connection=asp1a
    csn.disconnect    connection=ASIK

Monitor the DL throughput
    [Arguments]     ${repeat_times}
	Repeat Keyword    ${repeat_times} times     Evaluate DL throughput    ${DOWNLINK_DATA_TRANSFER}

Evaluate DL throughput
    [Arguments]     ${DOWNLINK_DATA_TRANSFER}
    wait until keyword succeeds    1min    10s    Connect to ASIK
	wait until keyword succeeds    1min    10s    Connect to asp1a
    ${DL_throughoutput}=    Calculate DL throughoutput    alias=asp1a
    should be true    ${DL_throughoutput} >= ${DOWNLINK_DATA_TRANSFER}
    csn.disconnect    connection=asp1a
    csn.disconnect    connection=ASIK

Monitor the UL throughput
    [Arguments]     ${repeat_times}
	Repeat Keyword    ${repeat_times} times    Evaluate UL throughput    ${UPLINK_DATA_TRANSFER}

Evaluate UL throughput
    [Arguments]     ${UPLINK_DATA_TRANSFER}
    wait until keyword succeeds    1min    10s    Connect to ASIK
	wait until keyword succeeds    1min    10s    Connect to asp1a
	${UL_throughoutput}=    Calculate UL throughoutput    alias=asp1a
    should be true    ${UL_throughoutput} >= ${UPLINK_DATA_TRANSFER}
    csn.disconnect    connection=asp1a
    csn.disconnect    connection=ASIK
