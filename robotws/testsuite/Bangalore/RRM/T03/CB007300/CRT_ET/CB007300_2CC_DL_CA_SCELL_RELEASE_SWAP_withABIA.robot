*** Settings ***
Documentation    :copyright: Nokia

Force Tags         CLOUD_R4LAPO_CUS   CRT   SBTS00    CA_VRF_RRM     RAN_4G_FDD    RAN_4G   QCD_MN_RAN   QCP_RAN_VRF   CUS

Resource        ./resources/DevHZ5_resource.robot
Library    taf.ul.ue.sim.env_setup
Library    OperatingSystem
Library    ta_uexgate
Library    BuiltIn
Library           Collections
Library           taf.sw.scout    WITH NAME    scout
Library           ta_emss
Suite Setup         Custom Setup Environment
Test Teardown       Post condition
Library      taf.hw.pdu
Library      taf.sw.reporting_portal

*** Variables ***
${egate_port}=          20000
${edaemon_port}=        10000
${scfc}        ${CURDIR}/config_files/magenta.xml
${cus_ini}     ${CURDIR}/config_files/2CC_DL_CA_withABIA.ini
${lua}         ${CURDIR}/config_files/2CC_DL_CA_withABIA.lua
${ue_db}       ${CURDIR}/config_files/2CC_DL_CA_withABIA.db

*** Test Cases ***

[1][2.0] 2CC_DL_CA_SCell_swap_Pcell_MIMO
    Attach UE1 to CELL1
    Start observing for Step Wise sCell addition message on UE1
    Log To Console  Trigger sCell Step Wise addition by start dl udp traffic
    Start udp traffic with id 1 containing 430Mbps DL with packetSize 1400 on UE1
    Verify if Step Wise sCells were added
    Start observing for sCell Swap message on UE1
    UE1 sends measurement report with event A6
    Verify if sCell Swap succeded
    Start observing for Step Wise sCell deletion message on UE1
    Stop traffic with id 1 on UE1
    Verify if Step Wise sCells were deleted
    run UEx Command     ue_detach    id=1
    [Teardown]  Post condition

*** Keywords ***

Attach UE1 to CELL1
    run UEx Command     ue_attach     id=1     cell=1
	...    ue_eutra_capabilities=59A00201082010381C00800C0403C280060610401000C208024038410040440800E104012110200302010080414401C25340C03F9A0054000000

Attach UE2 to CELL1
    run UEx Command     ue_attach     id=2     cell=1
	...    ue_eutra_capabilities=59A00201082010381C00800C0403C280060610401000C208024038410040440800E104012110200302010080414401C25340C03F9A0054000000

Attach UE3 to CELL1
    run UEx Command     ue_attach     id=3     cell=1
	...    ue_eutra_capabilities=59A00201082010381C00800C0403C280060610401000C208024038410040440800E104012110200302010080414401C25340C03F9A0054000000

Stop traffic with id 1 on UE1
    run UEx Command     trf_data_stop     ue=1

Start udp traffic with id 1 containing 430Mbps DL with packetSize 1400 on UE1
     run UEx Command     trf_data_start     ue=1     dir=dl    protocol=udp    Mbps=430

Start observing for Step Wise sCell addition message on UE${ue_id}
    Log To Console  Start observing for Step Wise sCell addition message
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((sCellIndex-r10 contains (1)) and (length(sCellToAddModList-r10) eq 1))
    ...    alias=step_wise_sCell_addition_on_UE${ue_id}  overall_timeout=60

Start observing for Step Wise sCell deletion message on UE${ue_id}
    Log To Console  Start observing for Step Wise sCell deletion message
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((sCellToReleaseList-r10 is present) and ((length(sCellToReleaseList-r10) eq 1)))
    ...    alias=step_wise_sCell_deletion_on_UE${ue_id}   overall_timeout=30

Start observing for sCell Swap message on UE${ue_id}
    Log To Console   Start observing for sCell Swap message on UE${ue_id}
    Expect message flow
    ...     UE_${ue_id}:RRC_MeasurementReport
    ...     UE_${ue_id}:RRC_RRCConnectionReconfiguration (length(sCellToAddModList-r10) eq 1)
    ...     UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...     alias=reconfig_sCell_swap_on_UE${ue_id}  overall_timeout=60

Verify if Step Wise sCells were added
    Log To Console  Verify if Step Wise sCells were added
    Flow occurred as expected  alias=step_wise_sCell_addition_on_UE1

Verify if Step Wise sCells were deleted
    Log To Console  Verify if Step Wise sCells were deleted
    Flow occurred as expected  alias=step_wise_sCell_deletion_on_UE1

Verify if sCell Swap succeded
    Log To Console  Verify if sCell Swap succeded
    Flow occurred as expected  alias=reconfig_sCell_swap_on_UE1

UE${ue_id} sends measurement report with event ${event}
    Log To Console  UE${ue_id} sends measurement report with event ${event}
    Run UEX command  ue_measurement_send
    ...              id=${ue_id}
    ...              event=${event}
    ...              srsrp=60
    ...              srsrq=17
    ...              phycell_id=4
    ...              nrsrp=97
    ...              nrsrq=34

Set CA 2CC UE Capabilities for UE${ue_id}
    Log To Console   ${\n}Set CA 2CC UE Capabilities for UE${ue_id}
    Run UEx command  ue_param
    ...              id=${ue_id}
    ...              release=14
    ...              category=10
    ...              supported_bands=3,7
    ...              ca_supported_bands=3:a:a|3:a:c|3:a:a+7::a|3:a:c+7::a
    ...              category_dl=12
    ...              category_ul=13
    ...              dl_256QAM_supported=on
    ...              ul_64QAM_supported=on
    ...              freq_gaps=true

Set LNBTS-${enb_id}.${parameter} to ${value}
    Log To Console  Set LNBTS-${enb_id}.${parameter} to ${value}
    Change Enb Parameter Value  LNBTS-${enb_id}.${parameter}  ${value}  enb_id=${enb_id}

Perform setup for CPRI Step Wise CA 2CC
    Log To Console  ${\n}Perform setup for CPRI Step Wise CA 2CC
    Set LNBTS-1.numTxWithHighNonGbr to 1
    Set LNBTS-1.actAdvStepwiseScellAdd to oneStepAdvanced
    Set LNBTS-1.sCellActivationMethod to nonGBRBufferBasedStepWise

Custom Setup Environment
    Add Simulator       sim_type=cus    config=${cus_ini},${ue_db}
    Add Enb Configuration           ${scfc}
    Add Epc                         config=${lua}
    configure_environment
    Create UE alias       alias=UE_1    ue_id=1  id_type=cus


Stop Default Logging For CUS And Compress Test Logs
    [Arguments]     ${output_dir}=${OUTPUT_DIR}
    stop infomodel    log_filepath=${output_dir}/home/ute/logs
    print_current_active_faults_from_fsm

Post Condition
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
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
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
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
