*** Settings ***

Documentation
...   author: Pavan
...   contact: Pavan.3.kumar@nokia.com
...   Description: Test Suite for CB009130-B

Library     Process
Library     taf.collectors.tshark    WITH NAME    tshark
Library     taf.collectors.core    WITH NAME    core
Library     taf.collectors.btslog    WITH NAME   btslog
Library     String      WITH NAME   str
Library     taf.ue    WITH NAME    ue
Resource    ./testsuite/Bangalore/ORAN/resources/robot/common_admin.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library    DateTime
Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.sw.scout    WITH NAME    scout
Library    OperatingSystem     WITH NAME    os
Library    taf.analyzer.netconf
Library    Collections
Library    taf.collectors.simple    WITH NAME    simple
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Test Setup      Test Setup
Test Teardown   Test Teardown
Force Tags       CRT  SBTS24R1    FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[1][1.0] TC05_CB009130_B_To configure max cells in mixed configuration for multiband radio in Band(B1 B3) ORAN 5G radio}
...    QC_ID_FL00=QC_670099

@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_1
@{throughput_dl}=   0
@{throughput_ul}=   0
@{dt_name}=   iperf_dl_test
@{UE_alias}=  UE_1
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{timeout}      180
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{deviation_dl}=  20
@{deviation_ul}=  30
${packet_size}=  1400
${tput}=   250Mbits/sec
${ASP_BOARD_TYPE}     ABIO0
${log_path}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/resources/SCF
${SCF_PATH_B1_B3}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/resources/SCF/b1_b3.xml
${SCF_PATH_B1_B3_B3}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/resources/SCF/b1_b3_b3_4t_4r.xml
#${connection}    None
${SCF_PATH}         ${CURDIR}/resources/
${DELTA_FILE}       ${CURDIR}/resources/SCF/b1.xml
${scf_file}=        ${DELTA_FILE}
${CONFIG_PATH}      /home/ute/testline_configuration_5G/Bangalore/10_2_SG4MRBTS961/ta_ue_config.yaml
${connection}    Active_Session
${OUTPUT_DIR1}=    /home/ute/results
${CONFIGURATION}=    10_2_SG4MRBTS961

*** Test Cases ***
[1][1.0] TC05_CB009130_B_To configure max cells in mixed configuration for multiband radio in Band(B1 B3) ORAN 5G radio

    Step1: Commission the SBTS NR cell 1 with Band 1 and another cell with Band 3 as per configuration defined
    Step2: Lock Cell of Band-3
#    Step3: Initiate the TCP Downlink and uplink data transfer
    Step4: UnLock Cell of Band-3
    Step5: Lock Cell of Band-1
    Step6: Commission the SBTS O-RU with 2NR cells in Band 3
    Step7: Lock Cell of Band-3
#    Step8: Initiate the TCP Downlink and uplink data transfer
    Step9: UnLock Cells
    Step10: Netconf Log collection
#    Step11: Netcong Validation

*** Keywords ***
Test Setup
    Log to console   --Test setup--
    common_admin.Verify BTS Is OnAir
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    taf.sbts.oam.coam.admin.setup_admin   bts_host=192.168.255.129    timeout=300
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2

    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog

Test Teardown
    Log to console   --Test teardown--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${log_path}
    core.teardown_collectors     names=btslog
    ${snappath}    Run keyword And Continue On Failure     taf.sbts.oam.coam.admin.collect_snapshot
	...		target_file_name=${log_path}/Snapshot.zip    coverage=Full    force=True
    ...     timeout=2000s    connection=${connection}
    QC_Update

Step1: Commission the SBTS NR cell 1 with Band 1 and another cell with Band 3 as per configuration defined
    Set Suite Variable    ${scfc_file}    ${SCF_PATH_B1_B3}
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    Full Commission SCF File With Admin    scf_file=${scfc_file}
    sleep    600
    common_admin.Verify BTS Is OnAir
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    taf.sbts.oam.coam.admin.setup_admin   bts_host=192.168.255.129    timeout=300
    taf.sbts.oam.coam.admin.get_bts_info
    taf.sbts.oam.coam.admin.get_active_alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}

Step2: Lock Cell of Band-3
    Log to console   --Cell Lock of Band-3--
    ${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
    FOR    ${cell}    IN    @{cells}
    Log to console      \nLocking NRCell-Band3
    taf.sbts.oam.coam.admin.lock
	...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-961/NRCELL_R-1    timeout=120
	...    connection=${connection}
    END


Step3: Initiate the TCP Downlink and uplink data transfer
    OperatingSystem.Set Environment Variable        TA_UE_CONFIG        ${CONFIG_PATH}
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is success
    Log to console    \nStarting data transfer
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_dl}
    sleep    200
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
    sleep    200
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed

Step4: UnLock Cell of Band-3
    Log to console   --Cell UnLock of Band-3--
    ${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
    FOR    ${cell}    IN    @{cells}
    Log to console      \n UnLocking NRCell-Band-3
    taf.sbts.oam.coam.admin.unlock
	...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-961/NRCELL_R-1    timeout=120
	...    connection=${connection}
    END

Step5: Lock Cell of Band-1
    Log to console   --Cell Lock of Band-1--
    ${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
    FOR    ${cell}    IN    @{cells}
    Log to console      \nLocking NRCell-Band-1
    taf.sbts.oam.coam.admin.lock
	...     dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-961/NRCELL_R-2    timeout=120
	...    connection=${connection}
    END

Step6: Commission the SBTS O-RU with 2NR cells in Band 3
    Set Suite Variable    ${scfc_file}    ${SCF_PATH_B1_B3_B3}
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    Full Commission SCF File With Admin    scf_file=${scfc_file}
    sleep    600
    common_admin.Verify BTS Is OnAir
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    taf.sbts.oam.coam.admin.setup_admin   bts_host=192.168.255.129    timeout=300
    taf.sbts.oam.coam.admin.get_bts_info
    taf.sbts.oam.coam.admin.get_active_alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}


Step7: Lock Cell of Band-3
    Log to console   --Cell Lock of Band-3--
    ${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
    FOR    ${cell}    IN    @{cells}
    Log to console      \nLocking NRCell-Band-3
    taf.sbts.oam.coam.admin.lock
	...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-961/NRCELL_R-1    timeout=120
	...     connection=${connection}
    END

Step8: Initiate the TCP Downlink and uplink data transfer
    OperatingSystem.Set Environment Variable        TA_UE_CONFIG        ${CONFIG_PATH}
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is success
    Log to console    \nStarting data transfer
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_dl}
    sleep    200
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
    sleep    200
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed

Step9: UnLock Cells
    Log to console   --Cell UnLock of Band-1 and 3--
    ${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
    FOR    ${cell}    IN    @{cells}
    Log to console      \nUnLocking NRCell-Band-1 and 3
    taf.sbts.oam.coam.admin.unlock    dist_name=${cell}    timeout=120    connection=${connection}
    END

Step10: Netconf Log collection
    Log to console   \n --Netconf log collection started--\n

    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu

    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30s
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log
    ...    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log
    Log to console   \n --Netconf log collection completed--\n

Step11: Netcong Validation
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${OUTPUT_DIR1}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}

    @{max-num-component-carriers}=    create List
    @{max-power-per-pa-antenna}=    create List

    @{min-power-per-pa-antenna}=    create List
    @{max-power-per-pa-antenna}=    create List
    @{max-power-per-antenna}=    create List
    @{min-power-per-antenna}=    create List
    @{max-gain}=    create List


    @{min-supported-frequency-dl}=    create List
    @{min-supported-frequency-ul}=    create List
    @{max-supported-frequency-dl}=    create List
    @{max-supported-frequency-ul}=    create List

    @{min-carrier-bandwidth-dl}=    create List
    @{min-carrier-bandwidth-ul}=    create List
    @{max-carrier-bandwidth-dl}=    create List
    @{max-carrier-bandwidth-ul}=    create List



    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-num-component-carriers")}' != '[]'
	...    Append To List    ${max-num-component-carriers}    ${entry.message.xml.findall(".//max-num-component-carriers")}

		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-power-per-pa-antenna")}' != '[]'
	...    Append To List    ${min-power-per-pa-antenna}    ${entry.message.xml.findall(".//min-power-per-pa-antenna")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-power-per-pa-antenna")}' != '[]'
	...    Append To List    ${max-power-per-pa-antenna}    ${entry.message.xml.findall(".//max-power-per-antenna")}
	Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-power-per-antenna")}' != '[]'
	...    Append To List    ${max-power-per-antenna}    ${entry.message.xml.findall(".//min-power-per-pa-antenna")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-power-per-antenna")}' != '[]'
	...    Append To List    ${min-power-per-antenna}    ${entry.message.xml.findall(".//min-power-per-antenna")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-gain")}' != '[]'
	...    Append To List    ${max-gain}    ${entry.message.xml.findall(".//max-gain")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-dl")}' != '[]'
		...    Append To List    ${min-supported-frequency-dl}    ${entry.message.xml.findall(".//min-supported-frequency-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-ul")}' != '[]'
	...    Append To List    ${min-supported-frequency-ul}    ${entry.message.xml.findall(".//min-supported-frequency-ul")}
	Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-supported-frequency-dl")}' != '[]'
	...    Append To List    ${max-supported-frequency-dl}    ${entry.message.xml.findall(".//max-supported-frequency-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-ul")}' != '[]'
	...    Append To List    ${max-supported-frequency-ul}    ${entry.message.xml.findall(".//max-supported-frequency-ul")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-carrier-bandwidth-dl")}' != '[]'
	...    Append To List    ${min-carrier-bandwidth-dl}    ${entry.message.xml.findall(".//min-carrier-bandwidth-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-carrier-bandwidth-ul")}' != '[]'
	...    Append To List    ${min-carrier-bandwidth-ul}    ${entry.message.xml.findall(".//min-carrier-bandwidth-ul")}
	Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-carrier-bandwidth-dl")}' != '[]'
	...    Append To List    ${max-carrier-bandwidth-dl}    ${entry.message.xml.findall(".//max-carrier-bandwidth-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-carrier-bandwidth-ul")}' != '[]'
	...    Append To List    ${max-carrier-bandwidth-ul}    ${entry.message.xml.findall(".//max-carrier-bandwidth-ul")}


    END

	Parameter Check    ${max-num-component-carriers}    2

	Parameter Check    ${min-power-per-pa-antenna}    37.5
 	Parameter Check    ${max-power-per-pa-antenna}    49.5
        Parameter Check    ${max-power-per-antenna}    45.6
 	Parameter Check    ${min-power-per-antenna}    23.1
	Parameter Check    ${max-gain}    43.01
	Parameter Check    ${max-gain}    44.8
	Parameter Check    ${max-gain}    46.02


	Parameter Check    ${min-supported-frequency-dl}    2110000000
 	Parameter Check    ${min-supported-frequency-ul}    1920000000
 	Parameter Check    ${min-supported-frequency-dl}    1805000000
	Parameter Check    ${min-supported-frequency-ul}    1710000000
	Parameter Check    ${max-supported-frequency-dl}    2170000000
 	Parameter Check    ${max-supported-frequency-ul}    1980000000
 	Parameter Check    ${max-supported-frequency-dl}    1880000000
	Parameter Check    ${max-supported-frequency-ul}    1785000000

	Parameter Check    ${min-carrier-bandwidth-dl}    10000000
 	Parameter Check    ${min-carrier-bandwidth-ul}    10000000
 	Parameter Check    ${min-carrier-bandwidth-dl}    10000000
	Parameter Check    ${min-carrier-bandwidth-ul}    10000000
	Parameter Check    ${max-carrier-bandwidth-dl}    20000000
 	Parameter Check    ${max-carrier-bandwidth-ul}    20000000
 	Parameter Check    ${max-carrier-bandwidth-dl}    20000000
	Parameter Check    ${max-carrier-bandwidth-ul}    20000000
        Log to console   --\n Netconf log verification Completed\n--

Nested Looping
    [Arguments]    ${I}    ${value}
	@{parameter-check}=    create list
	FOR    ${line}    IN    @{I}
        Run Keyword If     '${line.text}'=='${value}'    Append To List    ${parameter-check}    ${line.text}
	END
	[RETURN]    ${parameter-check}


Parameter Check
	[Arguments]    ${parameter-check}    ${val}
	${final_band}=    create list
    FOR    ${I}    IN    @{parameter-check}
	    Log    ${I}
        ${aa}=    Nested Looping    ${I}	${val}
		${final_band}=    combine lists    ${aa}    ${final_band}
    END
	${len}=    get length    ${final_band}

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    taf.sbts.oam.coam.admin.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
#    Log To Console    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    scout.request_scf    use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}

    log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


QC_Update
    RP Settings
    Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

