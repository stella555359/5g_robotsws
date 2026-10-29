*** Settings ***

Force Tags         CLOUD_FCC_CUS   CRT   SBTS00   CUS

Documentation
...
...  AUTHOR          :   Shaheena Parveen
...  MAINTAINER      :   shaheena.parveen@nokia.com
...  INTRODUCTION    :   Verification of 2CC DL CA DATA TRANSMISSION - MIXED MIMO MODES
...  TEST SET NAME   :   CB012758 2CC DL CA DATA TRANSMISSION MIXED MIMO MODES
...  REFERENCES      :   CB007300-CFAM

Resource   ${CURDIR}/resources/DevHZ5_resource.robot
Library    BuiltIn
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    ../../../../ORAN/resources/python/Tshark_Validation.py
Library    ta_emss
Library    taf.sw.wtssim    WITH NAME    wtssim
Library    OperatingSystem     WITH NAME    os


Suite Setup         Custom Setup Environment
Test Teardown       Post condition

*** Variables ***
${reconf}=     		${True}
${tshark_path}=    /home/ute/logs/CB012758 2CC DL CA DATA TRANS MIXED MIMO MODES/CB012758_2CC DL CA DATA TRANSMISSION - MIXED MIMO MODES/tcpdump
${margin}=  		5
${local_cell_id_1}                DN:NE-LNBTS-1/LNCEL-3/MCC-244/MNC-09
${egate_port}=          20000
${edaemon_port}=        10000
${scfc}        ${CURDIR}/config_files/CB012758_scf.xml
${cus_ini}     ${CURDIR}/config_files/CB012758_cus.ini
${lua}         ${CURDIR}/config_files/CB012758_epc.lua
${ue_db}       ${CURDIR}/config_files/CB012758_ue.db

${F1BCS}=    (lte-rrc.n1PUCCH_AN_CS_List_r10 == 2) && (lte-rrc.N1PUCCH_AN_CS_r10 == 4)
${RI}=    lte-rrc.ri_ConfigIndex == 1


*** Test Cases ***
CB012758_2CC DL CA DATA TRANSMISSION - MIXED MIMO MODES

    [Tags]    CA_VRF_BLR1     4GFDD    CRT    SBTS00
    os.run    tshark -D -M
    os.run    ip addr show
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i eth4
    core.setup_collectors    names=tcpdump
    core.start_collectors    names=tcpdump
    sleep    10s
    Attach UE1 to CELL3
    Start observing for Step Wise sCell addition message on UE1
    Log To Console    Starting Data
    Start udp traffic with id 1 containing 200Mbps DL with packetSize 1400 on UE1
    Verify if Step Wise sCells were added
    Stop traffic with id 1 on UE1
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump

    Verify F1BCS
    Verify RI
    run UEx Command     ue_detach    id=1


*** Keywords ***
Attach UE1 to CELL3
    run UEx Command     ue_attach     id=1     cell=3
    ...    ue_eutra_capabilities=59A00201001010201000800C0403C280060610401000C2080220180100400700200808410018100804020A200E129A0601FDD002A00000

Start udp traffic with id 1 containing 200Mbps DL with packetSize 1400 on UE${ue_id}
     run UEx Command     trf_data_start    ue=${ue_id}    dir=dl    protocol=udp    Mbps=200

Start observing for Step Wise sCell addition message on UE${ue_id}
    Log To Console  Start observing for Step Wise sCell addition message
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((sCellIndex-r10 contains (1)) and (length(sCellToAddModList-r10) eq 1))
    ...    alias=step_wise_sCell_addition_on_UE${ue_id}  overall_timeout=60

Verify if Step Wise sCells were added
    Log To Console  Verify if Step Wise sCells were added
    Flow occurred as expected  alias=step_wise_sCell_addition_on_UE1

Stop traffic with id 1 on UE${ue_id}
    run UEx Command     trf_data_stop     ue=${ue_id}


Custom Setup Environment
    Add Simulator       sim_type=cus    config=${cus_ini},${ue_db}
    Add Enb Configuration           ${scfc}
    Add Epc                         config=${lua}
    configure_environment
    Setup egate  egate_port=${EGATE_PORT}
    Create UE alias       alias=UE_1    ue_id=1  id_type=cus


Stop Default Logging For CUS And Compress Test Logs
    [Arguments]     ${output_dir}=${OUTPUT_DIR}
    stop infomodel    log_filepath=${output_dir}/home/ute/logs
    print_current_active_faults_from_fsm

Post Condition
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting


Get Hostname
    ${rc}  ${hostname_tmp}=  os.Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Test Variable  ${HOSTNAME}  ${hostname_combined}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]

Verify F1BCS

    ${a}=    Validate_Tshark   ${tshark_path}    filter=${F1BCS}
    log       ${a}
    ${len}=    Get length	${a}
    should be true    ${len}>${0}    Fail

Verify RI
    ${a}=    Validate_Tshark    ${tshark_path}    filter=${RI}
    log       ${a}
    ${len}=    Get length	${a}
    should be true    ${len}>${0}    Fail


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${HOSTNAME}
    Log To Console    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

