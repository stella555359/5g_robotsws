*** Settings ***
Documentation
...  AUTHOR          :   Kiran Vilas Gawade
...  MAINTAINER      :   Kiran Vilas Gawade
...  INTRODUCTION    :  CB014134 Feature which interacts LTE 928 and LTE 3544
...  TEST SET NAME   :   [1]CB014134_RRMT_LTE3544#7_DwPTS_rollback_triggered_by_RI_sequences_
...                    detection_with_CA_config_and_verification_of_PM_counetres
...  REFERENCES      :   CFAM CB014134
...  REQUIREMENT ID  :   RRM_LTE_SFS_RRMT_15792

Resource   ./CA_resources/main_resources.robot
Resource    ./CB014134_resource.robot

# -- extra resources --
Library    taf.ul.ue.sim.env_setup
Library    XML
Library    ta_uexgate    compress_logs=True
Library     OperatingSystem
Library     ta_uexgate
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Library     ta_messaging
Library		taf.sw.syslog
Library     taf.sw.wtssim
Library		taf.sbts.oam.coam.admin
#Library     ute_admin_infomodel


# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Backup BTS Configuration Files
...    AND    Test suite preconditions

Test Teardown    RUN KEYWORDS     Stop Log  snapshot
...     AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
...     AND     Testing environment cleanup


*** Variables ***
${TEST_NAME}        testcase
${gNB_IP} 		  192.168.255.129
${connection}		oam

${STEM}    ${SUITE SOURCE.split('/')[-1][:-6]}

# -- test scenario variables --
${RESOURCES}             ${CURDIR}/config

${SCFC_PATH_REL4}        ${RESOURCES}/scfc.xml
${COCO_YAML}             ${RESOURCES}/coco.yaml
${PROTOCOL}              udp
${SWCONFIG}              ${CURDIR}/CA_resources/swconfig.txt

${DELTA}    ${RESOURCES}/Delta_config_leagcy_RIM.json
${disable}    ${RESOURCES}/Delta_config_disable_928.json

*** Test Cases ***
[1][1.0] CB014134_RRMT_LTE3544#7_DwPTS_rollback_triggered_by_RI_sequences_detection_with_CA_config_and_verification_of_PM_counetres
#LTE2511_CA_28A_40A_2CC

    Allocate test variables for LTE2511_CA_28A-40A_2CC_Carrier_Aggregation_throughput_check
#    eNB Commissioning    ${RESOURCES}/Delta_config_leagcy_RIM.json
    Perform SCF Delta Commissioning with Delta_config_leagcy_RIM.json
    Sleep       300s
#    Check if all cells from tested CA combination are OnAir
    Enable Macpscli To UTE
    Sleep  60s
#    eNB Commissioning      ${RESOURCES}/Delta_config_block.json
    Perform SCF Delta Commissioning with Delta_config_block.json
    Start Log   btslog

    Generate RI sequences with CA      6
    Wait For Fault To Be Up     fault_id=6124   timeout=600
    Log To Console      Fault 6124 appeared


    Cell reset     6
    Attach "UE_6"
    Perform data traffic for "UE_6"

    Generate RI sequences with CA      6
    Sleep    200s
    Generate RI sequences with CA      6

    Wait Until Keyword Succeeds         6 times     5 minute     Wait for 6127 Fault

    #eNB Commissioning      ${RESOURCES}/Delta_config_CB014134_activate.json
   Perform SCF Delta Commissioning with Delta_config_CB014134_activate.json
    Wait For Fault To Be Down     fault_id=6127   timeout=600
    Sleep    1800s
    ${moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-6/LNCEL_TDD-0/RIMINFO-0
    CB014134_resource.Make connection
    ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
    should contain        ${ret1}      remote interference detected with DHE
    ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
    should contain        ${ret2}      DL mitigation with SSP PDSCH muting only
    ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
    Should Be Equal        ${ret3}      ${2}
    Sleep    300s
    VerIfy LTE RIM Counters with CA



*** Keywords ***
VerIfy LTE RIM Counters with CA
    ${counter_moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-6/PLMN-PLMN/MCC-311/MNC-09
    ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
    ${ENB_DUR_UL_IMPACT_RI}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C432    moc=${counter_moc}
    ${ENB_DUR_RI_DHT}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C433    moc=${counter_moc}
    ${ENB_DUR_SSP_ROL_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C448    moc=${counter_moc}
    ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C449   moc=${counter_moc}
    ${ENB_DUR_UL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C450    moc=${counter_moc}
    ${ENB_NUM_DET_RI_ENB_ID}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C447    moc=${counter_moc}
    Should Contain       ${ENB_DUR_UL_IMPACT_RI}      900
    Should Contain       ${ENB_DUR_RI_DHT}      0
    Should Contain       ${ENB_DUR_SSP_ROL_DL_MTG}       0
    Should Contain       ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}      900
    Should Contain       ${ENB_DUR_UL_MTG}      900
    Should Contain Any      ${ENB_NUM_DET_RI_ENB_ID}      2     0

Wait for 6127 Fault
    Log To Console      waiting for Fault 6127
    Generate RI sequences with CA      6
    Sleep    3000s
    Wait For Fault To Be Up     fault_id=6127   timeout=600
    Sleep    60s

Cell reset
    [Arguments]      ${id}
    Modify NIDD parameters     paramName=administrativeState       paramValue=locked       operation=update
    ...     paramDst=MRBTS-1/LNBTS-1/LNCEL-${id}
    Sleep    60s
    Modify NIDD parameters     paramName=administrativeState       paramValue=unlocked       operation=update
    ...     paramDst=MRBTS-1/LNBTS-1/LNCEL-${id}
    Sleep    60s

Modify NIDD parameters
    [Documentation]      This Keyword modify NIDD parameter as per the requirement of the feature
    [Arguments]      ${paramName}='None'      ${paramValue}='None'       ${operation}=update      ${paramDst}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramName=${paramName}         paramValue=${paramValue}        operation=${operation}
    ...                             paramDst=${paramDst}
    sleep               60s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    log to console      ${timeout}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

Generate RI sequences with CA
    [Arguments]      ${id}
    log to console   Generate RI sequences commands
    FOR    ${i}    IN RANGE    ${50}     ${1000}      ${150}
    Run UEx command    uec_cell_param       id=${id}     ul_noise=-40
    Run UEx command    cell_ri_param         id=${id}       hyperframe_num=${i}       frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=1         sequence_num=1          power_dBFS=-2
    Run UEx command     cell_ri_param        id=${id}       hyperframe_num=${i}       frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=1         sequence_num=2           power_dBFS=-2
    Run UEx command    cell_ri_param         id=${id}       hyperframe_num=${i}       frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=2         sequence_num=3          power_dBFS=-2
    Run UEx command     cell_ri_param        id=${id}       hyperframe_num=${i}       frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=2         sequence_num=4           power_dBFS=-2
    sleep  30s
    END

Test suite preconditions
    [Documentation]    Upload custom swconfig, CUS configuration and SCF.
    ...
    ...    Custom swconfig is copied to BTS (added UEC logging).
    ...    Custom CUS configuration is updated.
    ...    All RFs and cells parameters should be changed so full commissioning is necessary.

    Put On Smod    ${SWCONFIG}    /ffs/run/swconfig.txt
    Add eNB configuration    scfc=${SCFC_PATH_REL4}
    Add simulator    sim_type=cus    config=${COCO_YAML}
    Configure environment
#    Setup Real Time Performance Monitoring
#    Check if eNB is correctly configured    ${SCFC_PATH_REL4}

[PRE]LTE2511_CA_28A-40A_2CC_Carrier_Aggregation_throughput_check
    [Documentation]    Allocate variables for test (Cells PCI, UE ID, throughput parameters). Estabilish S1 connection.

    Allocate test variables for LTE2511_CA_28A-40A_2CC_Carrier_Aggregation_throughput_check
    Wait for OnAir


[POST]LTE2511_CA_28A-40A_2CC_Carrier_Aggregation_throughput_check
    Report miscellaneous KPIs
    Detach "UE_6"

# -- test steps --
Check if all cells from tested CA combination are OnAir
    [Documentation]    All cells from tested CA are OnAir. Verification in WebEM/IM log.
    [Tags]    DESIGNSTEP
    Verify if S1 link and specific cells on BTS are OnAir    cells_list=${CELLS_PCI}


Attach "${Equipment_ID}"
    [Documentation]    Attach is checked in runtime based on Egate console output.
    [Tags]    DESIGNSTEP
    ${ue_id}=    Evaluate    $Equipment_ID.partition('_')[-1]
    Start tshark packet capturing    id=${ue_id}
    Run UEx command    ue_attach    id=${ue_id}    cell=${PCELL_PCI}
    Sleep    3
    Stop tshark packet capturing    id=${ue_id}


Detach "${Equipment_ID}"
    [Documentation]    Detach is checked in runtime based on Egate console output.
    [Tags]    DESIGNSTEP
    ${ue_id}=    Evaluate    $Equipment_ID.partition('_')[-1]
    Run UEx command    ue_detach    id=${ue_id}


Verify if expected "${CA_combination}" combination was used by UE
    [Documentation]    Verify if sCells with correct PCI were added.
    [Tags]    DESIGNSTEP
    ${TSHARK_CA_COMBINATION_FILTER}    Set Variable If
    ...    "${CA_combination}" == "CA_1A-3A-38A"
    ...    lte-rrc.physCellId_r10==1&&lte-rrc.physCellId_r10==5
    ...    "${CA_combination}" == "CA_1A-3A-41A"
    ...    lte-rrc.physCellId_r10==1&&lte-rrc.physCellId_r10==7
    ...    "${CA_combination}" == "CA_3A-28A-41A-42A"
    ...    lte-rrc.physCellId_r10==2&&lte-rrc.physCellId_r10==8&&lte-rrc.physCellId_r10==9
    ...    "${CA_combination}" == "CA_18A-41A"    lte-rrc.physCellId_r10 == 7
    ...    "${CA_combination}" == "CA_1A-41C"    lte-rrc.physCellId_r10==7&&lte-rrc.physCellId_r10==8
    ...    "${CA_combination}" == "CA_28A-40A"    lte-rrc.physCellId_r10 == 6

    ${packets_number}=    Count packets    ${UE_ATTACH_PCAP}    ${TSHARK_CA_COMBINATION_FILTER}
    Should be true    ${packets_number}>=1
    ...    msg=Expected CA combination was *not* used! Packets count (${packets_number}) differ from expected value: 1


Perform data traffic for "${Equipment_ID}"
    [Documentation]    Traffic value should be greater than expected throughput by a margin.
    [Tags]    DESIGNSTEP
    ${ue_id}=    Evaluate    $Equipment_ID.partition('_')[-1]
    Run UEx command    trf_data_start    ue=${ue_id}    dir=dl    protocol=${PROTOCOL}
    ...    Mbps=${${Equipment_ID}_DATA_TRAFFIC_VOLUME_MBITS}    size=64000    trf_id=1
    Run UEx command    trf_data_start    ue=${ue_id}    dir=dl    protocol=${PROTOCOL}
    ...    Mbps=${${Equipment_ID}_DATA_TRAFFIC_VOLUME_MBITS}    size=64000    trf_id=2
    Run UEx command    trf_data_start    ue=${ue_id}    dir=dl    protocol=${PROTOCOL}
    ...    Mbps=${${Equipment_ID}_DATA_TRAFFIC_VOLUME_MBITS}    size=64000    trf_id=3
    Run UEx command    ue_stats    clear    id=${ue_id}
    Verify tput is ongoing    dir=dl    id=${ue_id}

Verify tput is ongoing
    [Arguments]    ${dir}    ${id}
    ${trf_stats}=    Run UEx command    get_ue_stats    id=${id}    type=${dir}_rlc    unit=Mbps
    ${tputs_ue}=    Get From Dictionary    ${trf_stats}    UE
    ${tputs_all}=    Get From Dictionary    ${tputs_ue}    Overall
    ${throughput_mbps}=    Get From Dictionary    ${tputs_all}    avg
    Should Be True    ${throughput_mbps}>0    msg=Throughput is not ongoing


Verify throughput level reached by "${Equipment_ID}"
    [Documentation]    Throughput level should not be less than expected (2% margin error included).
    [Tags]    DESIGNSTEP
    ${expected_throughput_in_kbps}=    Evaluate    ${${Equipment_ID}_EXPECTED_THROUGHPUT_MBITS} * 1000
#    ${pdcp_data_rate_mean_dl}=    Get Pm Counters List    M8012C26    network_element=LNCEL-${PCELL_PCI}
#    Pm Counters Avg Should Be Greater Equal    ${pdcp_data_rate_mean_dl}    ${expected_throughput_in_kbps}    start=${PMC_START_DATE}
    Wait until the current Measurement Period stops  additional_time=${0}
    Get Throughput counters and validate     M8012C26     value_expected=${expected_throughput_in_kbps}     cellid=3

Collect PM Counters
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

Get Throughput counters and validate
    [Arguments]     ${PM_counter}
    ...          ${value_expected}      ${cellid}=1
    Collect PM Counters
    PM_Counters.Check PM counter value equal    expected_value=${value_expected}   pm_files_location=${pm_counters_dir}
    ...  pi_id=${PM_counter}      moc=LNCEL-${cellid}
    Log To Console      Counter Value Verified

# -- internals --
Start tshark packet capturing
    [Arguments]    ${id}
    ${log_directory_path}=    Prepare Logs Directory Path    UE_ID_${id}_attach
    Set Suite variable    ${UE_ATTACH_PCAP}    ${log_directory_path}/UE_ID_${id}_eth4.pcap
    Start packets capturing    any    ${UE_ATTACH_PCAP}    session_name=UE_ID_${id}_attach

Stop tshark packet capturing
    [Arguments]    ${id}
    Stop packets capturing    session_name=UE_ID_${id}_attach

Allocate test variables for LTE2511_CA_28A-40A_2CC_Carrier_Aggregation_throughput_check
    [Documentation]    Allocates test specific variables.

    Set test variable    ${PCELL_PCI}    3
    Set test variable    @{SCELL_PCI}    6
    Set test variable    @{CELLS_PCI}    3    6
    Set test variable    ${DATA_TRAFFIC_TIME_MINUTES}    10
    Set test variable    ${UE_6_EXPECTED_THROUGHPUT_MBITS}    102
    Set test variable    ${UE_6_DATA_TRAFFIC_VOLUME_MBITS}    106
