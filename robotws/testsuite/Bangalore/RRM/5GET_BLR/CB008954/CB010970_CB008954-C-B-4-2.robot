*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO
...             CRT    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    5G_RAN     SBTS00    SBTS24R2    CONFIGURED

Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008954_resource.robot

Suite Setup         Run keywords      Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Modify IPHY File And Send to Airphone Custom1    ${IPHY_FILE}
...                 AND     Perform SCF Delta Commissioning with C-B-4-2.json
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      80
#
Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...             author:            prerana.n_s@nokia.com
...             maintainer:        prerana.n_s@nokia.com
...
...             INTRODUCTION:     This test scenario describes the gNB behavior, when gNB performs handover to a cell in
...                               the same gNB-DU.  2 dedicated BWPs are configured at the source Cell
...                               and 3 BWPs are configured at Target Cell.
...             TEST SET NAME:    CB008954_C_B_4_2_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_source_cell_
...                                with_2BWPs_Target_Cell_with_3BWPs
...             TESTING SPLIT:    See CB008954 split C testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 split C CFAM
...             Requirement ID:   5G_RAN_USR_RRM_21348

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/20_90_100.cfg
#${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}
${IPHY_FILE}         ${CURDIR}/config/wts/20_90_100iphy.xml
${SCFC}     ${CURDIR}/config/SBTS24R3/CB010970_CB008954-C-B-4-2.xml

*** Test Cases ***
[1]CB008954_C_B_4_2_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_source_cell_with_2BWPs_Target_Cell_with_3BWPs
    set test variable      ${LOG_PATH}
    log to console    ${LOG_PATH}
    Increase Buffer Size for VM and IPHY

    ${small_bwp_rnti}   MultiUE Register should be Successful     ${1}    ${4}
    MultiUE Trigger UL Traffic for SA    ${1}  ${4}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${4}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

    Start Log   ttitrace
    sleep    5s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix1

    Wait until the next Measurement Period starts
    FOR  ${ue}   IN RANGE    ${1}    ${5}
       Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${ue}     1    51
    END

    Start Log     ttitrace
    sleep    5s
    ${scen4}     Stop Log     ttitrace         test_scenario=mix2

    Run Keyword And Continue on Failure     Get and Validate pm counters for HO
    Wait until the next Measurement Period starts
    Run Keyword And Continue on Failure     Get and Validate pm counters for HO1
    Run Keyword And Continue on Failure     Get and Validate pm counters1

    ${small_bwp_id}    Set variable    ${3}
    ${second_bwp_id}   Set Variable    ${2}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${51}
    ${second_bwp_size}    Set Variable    ${245}
    ${large_bwp_size}    Set Variable    ${273}

    Decode TTI Trace   mix1
    Decode TTI Trace   mix2

    MultiUE Deregister should be Successful      ${1}    ${4}

    validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}      ${second_bwp_id}     ${large_bwp_id}
    ...     ${small_bwp_size}     ${large_bwp_size}     ${second_bwp_size}     small_bwp_ues=${small_bwp_rnti}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting



*** Keywords ***
Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
    ${output2}   wtsrunner.read_wtsemu_output_until_re    expected=UE${ue_id}: Intra-eNB handover   timeout=15
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Get and Validate pm counters for HO
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Set Suite variable   ${PM_dir1}
    ${M55166C00001}      Check PM counter value   ${PM_dir1}    PM_counter=M55166C00001
    Run Keyword And Continue on Failure     Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55166C00001    expected_value=3

Get and Validate pm counters for HO1
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Set Suite variable   ${PM_dir1}
    ${M55166C00003}      Check PM counter value   ${PM_dir1}    PM_counter=M55166C00003
    Run Keyword And Continue on Failure     Validate PM Counters1    PM_dir=${PM_dir1}    PM_counter=M55166C00003    expected_value=1

Get and Validate pm counters1
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${M55308C28001}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C28001
    ${M55308C28003}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C28003
    ${M55139C02501}    Check PM counter value   ${PM_dir1}    PM_counter=M55139C02501
    ${M55308C29001}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C29001
    ${M55308C29002}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C29002
    Run Keyword And Continue on Failure    PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C28001   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C28003   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55139C02501   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C29001   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C29002   moc=NRCELL-1

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=NRCELL-1
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}

Modify IPHY File And Send to Airphone Custom1
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom1   ${iphy_path}    ${frag}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom1    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom1    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    Send IPHY XML To Airphone custom1    ${iphy_path}
    END

Get RRU Type From Local IPHY XML Custom1
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable      <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    ${f1}   Set Variable
    ...     <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<fragmentationCapabilities>)
    ${x}    set variable if    ${frag}==${1}     ${f1}     ${x}
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom1
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHFII"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHEH"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom1
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Send IPHY XML To Airphone custom1
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0
