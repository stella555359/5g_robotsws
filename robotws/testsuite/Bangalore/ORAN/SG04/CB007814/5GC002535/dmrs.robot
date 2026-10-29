*** Settings ***

Documentation
...   author: SG8
...   contact: SG8
...   Description: Test Suite for CB007814_DMRS_MUL_MCS24to27

Library     Process
Library    taf.hw.rf_attenuator  WITH NAME  at
Library    taf.file.pack
Resource    ./testsuite/Bangalore/ORAN/SG04/CB007814/resourcefile/CB007814_keywords.robot
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin    WITH NAME    COAM
Resource           ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library    taf.sw.scout    WITH NAME    scout
Force Tags       24R2    TRUNK_7814_NO    FL00    dmrs    QCD_MN_RAN    QCP_RAN_VRF
Test Teardown     Test Teardown
Test Setup      Test Setup

*** Variables ***
@{UE_alias}=  UE3
@{capabilities}=    Legacy_3
${connection_enb}=    eNB_Session
@{throughput_dl}    200
@{udpcalltype}=    UDP
@{dt_name_dl}    iperf_dl_test_NG
@{direction_dl}=      dl
@{deviation_dl}=      20
${bts_ip}=     192.168.255.129
${testcase_name}=    CB007814_5GC002535_DMRS_MUL_MCS24to27
${DELTA_FILE}     /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB007814/5GC002535/resources/Delta_Conf_5GC002535.json
${OUT_LOG_PATH}    /home/ute/results
${config_path}    /home/ute/robotws/testsuite/Bangalore/ORAN/resources/python/ta_ultracaller
${CONFIGURATION}		    1_2_CLOUD970
&{CB007814_5GC002535_ Dl max TP reached and FDM of PDSCH and DMRS is working when MCS greater than or equal to 15 on static UE}
...	   QC_ID_FL00=QC_31649    QC_ID_SBTS24R3=QC_852876


*** Test Cases ***
CB007814_5GC002535_ Dl max TP reached and FDM of PDSCH and DMRS is working when MCS greater than or equal to 15 on static UE
     step1: Setup
     step2: Attach UE and run DL data
     step3: RF coverage simulation
     step4: Stop dcap and Validate logs
     step5: BIP log validation
     RP Settings
     Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
     Set QC_Tag

*** Keywords ***

Test Setup
    Log to console    \n--Test Setup--\n
    Admin Setup
    Admin Setup2
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

    at.set_ports_attenuation     ports=${ports}   values=${values1}

    at.set_ports_attenuation     ports=${ports_FJT_LTE}   values=${values1}

    Log to console    \n-unlocking and locking other RMODs---\n
    Unlock cells  ${LTE_cells}
    Lock cells  ${LTE_cell}
    Log to console    \n-Blocking LTE RAT---\n
    COAM.block_rat    rat=LTE    timeout=100    connection=${connection}
    Log to console    \n-NR cell lock operation---\n
    Lock NR cells  ${NR_cell}
    Run Keyword And Ignore Error    OperatingSystem.Run   sudo rm -rf /home/ute/robotws/artifactory/wslte5g_plugins-local/MCShark/*
    Run Keyword And Ignore Error    OperatingSystem.Run   sudo rm -rf /home/ute/Dcap/*
    Log to console    \n--DCAP Log collection starting--\n
    Dcap Start Trace SA
    Log to console    \n--DCAP Traces Started--\n


step1: Setup

    Log to console    \n--Starting delta commissioning--\n
    COAM.perform_delta_recommissioning    ${DELTA_FILE}    skip_parameter_relation_errors=False    should_activate=True    timeout=300
    ...    connection=${connection}
    Log to console    \n--Parameter updated--\n

step2: Attach UE and run DL data
    Log to console    \n-- Setting 0db attenuation---\n
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

    at.set_ports_attenuation     ports=${ports}   values=${values1}
    Log to console    \n--0db attenuation set successfully---\n

    Log to console    \n--Attach validation step to be started---\n
    ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}

    Log to console    \n-- REG+PDU session establishment was successful---\n
    Log to console    \n-- Starting DL data transfer---\n
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    sleep     30s
    Log to console    \n-DL data transfer ongoing and now attenuating rf contd.---\n

step3: RF coverage simulation
     at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    @{values}=    create list      ${values1}     ${values2}    ${values3}    ${values5}     ${values6}    ${values7}     ${values8}

	FOR    ${value}    IN    @{values}
        at.set_ports_attenuation     ports=${ports}   values=${value}
        sleep   3s
	END

    Log to console    \n-Awaiting for the data transfer to be completed---\n
    Run keyword And Ignore Error    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_ul}


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

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line node_id: ${node_id}
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}



step4: Stop dcap and Validate logs
       Log to console    \n- Stopping DCAP logs--\n
       Dcap Stop Trace and Get results SA
       Log to console    \n- DCAP log collection stopped successfully--\n

       Log to console    \n-Extracting BIP traces and merging them.---\n
       Unpack log files


step5:BIP log validation
      BIP analysis
      Log to console    \n-BIP analysis completed--\n

Test Teardown
    Log to console   \n--End Test--\n
    Run Keyword And Ignore Error    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Run Keyword And Ignore Error    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=250
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    @{values}=    create list      ${values1}     ${values1}    ${values1}    ${values1}     ${values1}    ${values1}     ${values1}

	FOR    ${value}    IN    @{values}
        at.set_ports_attenuation     ports=${ports}   values=${value}
        sleep   3s
	END

    Run keyword And Continue On Failure    Unblock LTERAT
    Run keyword And Continue On Failure    Unlock NR cells    ${NR_cell}
    Run keyword And Continue On Failure    Unlock cells    ${LTE_cell}
	COAM.teardown_admin    ${connection}
    COAM.teardown_admin    ${connection_enb}

