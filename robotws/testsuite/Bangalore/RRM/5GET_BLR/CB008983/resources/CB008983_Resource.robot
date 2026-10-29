*** Settings ***
Documentation    :copyright: Nokia
...              :authors: T09
...              :contact: ganesha.u@nokia.com

Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
#Resource         common_dss_command.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py
Library          ./PRB.py
Library          OperatingSystem
Library          ./verify_reconfig.py
Library          ./verify_numoflayer.py
Library          taf.sw.scout    WITH NAME     scout

*** Variables ***
${SCF_PATH}                ${CURDIR}/resources/config
${port}                    22
${PRB_LIST_20M}            0,3|5,89|103,3
${PRB_LIST_15M}            0,3|5,62|76,3
${PRB_LIST_10M}            0,3|5,35|49,3
${ALLOC_SUBFRAME_20M}      0010101010-0100001000-0011101110-0000000110-0011100010-0111101110-0011101110-0000000010
${ALLOC_SUBFRAME_15M}      0010000000-0111101000-0011100000-0111100000-0010000000-0000001100-0000000000-0100000000
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ALLOC_SUBFRAME}          1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
${Xp_link_pattern}                   ENB-1: XpAP Link with GNB-2 .* is up
${CRM_partnership}                   CRM Partnership Creation
${ul_dss_partnership_pattern}        EN DSS UL Cell Subcarrier Resource Coordination
${DL_cell_resource_coordination}     EN DSS DL Cell Resource Are\na Coordination: both NEs synchronized
${UL_cell_resource_coordination}     EN DSS UL Cell Subcarrier R\nesource Coordination: both NEs synchronized
${UL_dss_resource_allocation}        Received EN DSS UL Subcarrier Resource Allocati\non Response
${Timeout_SA}             300
${cell_ID}                1
${dl_min_share_to_nr}     75
${dl_max_share_to_nr}     100
${dl_min_share_to_lte}    15
${dl_max_share_to_lte}    70
${ul_min_share_to_nr}     20
${ul_max_share_to_nr}     70
${FIX_SUBFRAMES}    0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
${eNB_ID}        1
${eNB_target}    2
${Timeout_NSA}    300
${X2_link_pattern}    ENB-1: X2AP Link with GNB-2 .* is up
${robotws}       /home/ute/MN/UTE/robotws

*** Keywords ***

XP Link Should be UP
    [Documentation]    This keyword is for setupping XP Link.
    Log To Console   \nSetup XP Link...\n
    wtsrunner.sim_trace    enb=${eNB_ID}    protocol=xp
    wtsrunner.enb_xp_param    id=${eNB_ID}    ignore_xp=off    xp_listening_socket=on
    wtsrunner.enb_xp_param    id=${eNB_ID}    xp_peers=${eNB_target}
    wtsrunner.enb_xp_link_up    enb=${eNB_ID}    target=${eNB_target}
    Read WTS Output For Pattern And Print matching Lines    ${Xp_link_pattern}    ${Timeout_SA}

Enable Phase3 DSS
    [Arguments]    ${prb_list}    ${ALLOC_SUBFRAME}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}    ${max_prb_ratio}    ${num_prb}
    X2AP Link Should be UP
    XP Link Should be UP
    Set LTE NR DSS Mode Phase3
    Setup DSS Link Phase3
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    Set UL Resource Cell Reservation    ${min_prb_ratio}    ${max_prb_ratio}
    Cell Resource Allocation    nor_subframe=${ALLOC_SUBFRAME}    prb_list=${prb_list}    num_prb=${num_prb}

Set LTE NR DSS Mode Phase3
    [Documentation]    This keyword is for setting LTE NR DSS MODE.
    Log To Console   \nSet LTE NR DSS Mode...\n
    wtsrunner.enb_cell_param    id=${cell_ID}    enb=${eNB_ID}    lte_nr_dss_mode=DSS_PHASE_3    antenna_ports_num=1

Setup DSS Link Phase3
    [Documentation]    This keyword is for setupping DSS Link.
    Log To Console   \nSetup DSS Link...\n
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    wtsrunner.enb_dss_param    id=${eNB_ID}    feature_flag=on    message_sets=DMS3
    wtsrunner.enb_cell_dss_feature    enb=${eNB_ID}    id=${cell_ID}    nr_dl_peak_rate_increase=on
    wtsrunner.enb_cell_dss_feature    enb=${eNB_ID}    id=${cell_ID}    superfast_allocation=off
    wtsrunner.enb_cell_dss_param    enb=${eNB_ID}    id=${cell_ID}    dl_resource_sharing_algo=dl_prb_load_based
    wtsrunner.enb_dss_configure_partnership    enb=${eNB_ID}     cell=${cell_ID}    dss_peer=2:1
    Read WTS Output For Pattern And Print matching Lines    ${CRM_partnership}    ${Timeout_SA}
    Log to Console    \nCRM_partnership_is_ok
    wtsrunner.enb_crm_cell_resource_reservation    enb=${eNB_ID}    cell=${cell_ID}    tgt_enb=${eNB_target}    tgt_cell=${cell_ID}
    ...    assigned_dl_minimum_share_to_nr=${dl_min_share_to_nr}      assigned_dl_maximum_share_to_nr=${dl_max_share_to_nr}
    ...    assigned_dl_minimum_share_to_lte=${dl_min_share_to_lte}    assigned_dl_maximum_share_to_lte=${dl_max_share_to_lte}
    ...    assigned_ul_minimum_share_to_nr=${ul_min_share_to_nr}      assigned_ul_maximum_share_to_nr=${ul_max_share_to_nr}
    wtsrunner.enb_crm_param    id=${eNB_ID}    ul_qos_load_meas_timer=200    dl_qos_load_meas_timer=200
    wtsrunner.sim_trace    enb=${eNB_ID}     protocol=xp
    wtsrunner.enb_dss_establish_partnership    enb=${eNB_ID}    cell=${cell_ID}    tgt_enb=${eNB_target}    tgt_cell=${cell_ID}
    Read WTS Output For Pattern And Print matching Lines    ${ul_dss_partnership_pattern}    ${Timeout_SA}
    Log to Console   \nDSS_is_configured

Set DL RESOURCE Cell Reservation
    [Arguments]    ${min_dss_ratio}    ${max_dss_ratio}
    [Documentation]    This keyword is used to set DL resource cell reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    Example:
    ...    | Set DL RESOURCE Cell Reservation | 75 | 100 |
    DL Resource cell Reservation Phase3   subframes=${FIX_SUBFRAMES}  min_dss_ratio=${min_dss_ratio}  max_dss_ratio=${max_dss_ratio}

DL Resource cell Reservation Phase3
    [Arguments]  ${subframes}   ${min_dss_ratio}    ${max_dss_ratio}
    [Documentation]    This keyword is for dl resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | subframes | Yes | Fixed normal subframes |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    Example:
    ...    | DL Resource cell Reservation | 1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111 | 75 | 100|
    wtsrunner.enb_dss_dl_cell_resource_reservation    cell=${cell_ID}    enb=${eNB_ID}
    ...     prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    wtsrunner.enb_dss_dl_cell_resource_reservation    cell=${cell_ID}    enb=${eNB_ID}    reserved_fixed_normal_subframes=${subframes}
    wtsrunner.enb_dss_dl_cell_resource_reservation    cell=${cell_ID}    enb=${eNB_ID}    min_lte_nr_dss_ratio=${min_dss_ratio}
    ...     max_lte_nr_dss_ratio=${max_dss_ratio}
    Log to Console    \nDL_cell_resource_reservation_is_ok

Cell Resource Coordination
    [Documentation]    This keyword is for cell resource coordination.
    wtsrunner.enb_dss_cell_resource_coordination     enb=${eNB_ID}     cell=${cell_ID}    tgt_enb=${eNB_target}    tgt_cell=${cell_ID}     dir=DL
    Read WTS Output For Pattern And Print matching Lines    ${DL_cell_resource_coordination}    ${Timeout_SA}
    Log to Console   DL_cell_resource_coordination_is_ok

Set UL Resource Cell Reservation
    [Arguments]    ${min_prb_ratio}    ${max_prb_ratio}
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation    | 2 | 1 | 30 | 70
    wtsrunner.enb_dss_ul_cell_resource_reservation     enb=${eNB_ID}     cell=${cell_ID}     minimum_prb_share=${min_prb_ratio}
    ...    maximum_prb_share=${max_prb_ratio}
    wtsrunner.enb_dss_cell_resource_coordination     enb=${eNB_ID}     cell=${cell_ID}     tgt_enb=${eNB_target}     tgt_cell=${cell_ID}    dir=UL
    Read WTS Output For Pattern And Print matching Lines    ${UL_cell_resource_coordination}    ${Timeout_SA}
    Log to Console     UL_cell_resource_reservation_and_resource_coordination_ok
    wtsrunner.enb_crm_status     enb=${eNB_ID}     cell=${cell_ID}

Cell Resource Allocation
    [Arguments]    ${nor_subframe}    ${prb_list}     ${num_prb}
    [Documentation]    This keyword is used to allocate cell resource.
    ...    | Input Parameters | Man. | Description |
    ...    | nor_subframe | Yes | The dl allocated normal subframes |
    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 0,52 0:startprb    52:amount of prbs.|
    ...    Example:
    ...    | Cell Resource Allocation | 1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111 | 0,52 |
    ${PRB_string}    PRB.allign_prb    ${num_prb}
	wtsrunner.enb_dss_resource_allocation    enb=${eNB_ID}    cell=${cell_ID}    tgt_enb=${eNB_target}    tgt_cell=${cell_ID}
    ...    dir=DL   allocation_start_time=immediate    dl_allocated_normal_subframes=${nor_subframe}
    ...    dl_prb_area_allocation_list=${PRB_string}
    wtsrunner.enb_dss_resource_allocation    enb=${eNB_ID}    cell=${cell_ID}    tgt_enb=${eNB_target}    tgt_cell=${cell_ID}
    ...    dir=UL   allocation_start_time=immediate    ul_allocated_prb_list=${prb_list}
    Read WTS Output For Pattern And Print matching Lines    ${UL_dss_resource_allocation}     ${Timeout_SA}
    Sleep     5s
#    wtsrunner.enb_crm_status     enb=${eNB_ID}     cell=${cell_ID}
    Log to Console     cell_resource_allocation_is_ok


Verify NSA log
    [Arguments]     ${file_path}    ${DSS_flag}    ${SA_flag}
    verify_reconfig.check_reconfig_msg     ${file_path}    ${SA_flag}

    FOR    ${INDEX}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        OperatingSystem.Run    mv ${robotws}/Reconfig_MSG_* ${LOG_PATH}/
        ${output}    OperatingSystem.Get File    ${LOG_PATH}/Reconfig_MSG_${INDEX}.txt
#       xOverhead is coming in DSS case only
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp
        ...     ${output}    xOverhead\\s${overhead}
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp
        ...     ${output}    lte-CRS-ToMatchAround setup.*\\n.*\\n.*\\n.*\\n.*nrofCRS-Ports\\sn${no_of_ports}.*\\n.*v-Shift\\s${v-Shift}
         Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp     ${output}
        ...     pdsch-ServingCellConfig setup.*\\n.*\\n.*\\n.*\\n.*maxMIMO-Layers\\s${mimolayer}
        ...     ELSE    BuiltIn.Should Match Regexp     ${output}
        ...     pdsch-ServingCellConfig setup.*\\n.*\\n.*\\n.*maxMIMO-Layers\\s${mimolayer}
#       Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    ss-PBCH-BlockPower\\s${ss_pbch_power}
        BuiltIn.Should Match Regexp     ${output}
        ...     nzp-CSI-RS-ResourceToAddModList.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*frequencyDomainAllocation other : '000001'B
        BuiltIn.Should Match Regexp     ${output}
        ...     nzp-CSI-RS-ResourceToAddModList.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*nrofPorts\\sp2
        ...  .*\\n.*\\n.*cdm-Type\\s${cdm_type}.*\n.*density\\s${density}
    END


Verify SA log
    [Arguments]     ${file_path}    ${DSS_flag}    ${SA_flag}
	verify_reconfig.check_reconfig_msg     ${file_path}    ${SA_flag}
    verify_reconfig.check_rrcsetup_msg    ${file_path}

    FOR    ${INDEX}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        OperatingSystem.Run    mv ${robotws}/Reconfig_MSG_* ${LOG_PATH}/
        OperatingSystem.Run    mv ${robotws}/RrcSetup_MSG_* ${LOG_PATH}/
        ${output}    OperatingSystem.Get File   ${LOG_PATH}/Reconfig_MSG_${INDEX}.txt
#       xOverhead is coming in DSS case only
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp    ${output}    xOverhead\\s${overhead}
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp    ${output}
        ...    lte-CRS-ToMatchAround setup.*\\n.*\\n.*\\n.*\\n.*nrofCRS-Ports\\sn${no_of_ports}.*\\n.*v-Shift\\s${v-Shift}
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp     ${output}
        ...     pdsch-ServingCellConfig setup.*\\n.*\\n.*\\n.*\\n.*maxMIMO-Layers\\s${mimolayer}
        ...     ELSE    BuiltIn.Should Match Regexp     ${output}
        ...     pdsch-ServingCellConfig setup.*\\n.*\\n.*\\n.*maxMIMO-Layers\\s${mimolayer}
#       Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    ss-PBCH-BlockPower\\s${ss_pbch_power}
        ${output2}    OperatingSystem.Get File    ${LOG_PATH}/RrcSetup_MSG_${INDEX}.txt
        BuiltIn.Should Match Regexp     ${output2}
        ...     nzp-CSI-RS-ResourceToAddModList.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*frequencyDomainAllocation other : '000001'B
        BuiltIn.Should Match Regexp     ${output2}
        ...     nzp-CSI-RS-ResourceToAddModList.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*nrofPorts\\sp2
        ...  .*\\n.*\\n.*cdm-Type\\s${cdm_type}.*\n.*density\\s${density}
    END



Verify 1TX config from egate_log
    [Arguments]    ${DSS_flag}    ${st_ue_id}    ${en_ue_id}    ${SA_flag}
    log to console     Verifying egate_log    ${SA_flag}
    log to console   ${st_ue_id}   ${en_ue_id}
	Run Keyword If    ${SA_flag} == 1    Verify SA log    ${file_path}    ${DSS_flag}    ${SA_flag}
	...    ELSE    Verify NSA log    ${file_path}    ${DSS_flag}    ${SA_flag}

Create numofLayers Dictionary
    [Arguments]   ${rnti}   ${bwpid}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${rnti}
    FOR    ${i}    IN RANGE   ${len}
         Set To Dictionary   ${Dict1}    ${rnti}[${i}]   ${bwpid}[${i}]
    END
    Run Keyword if   ${len}==0    Set To Dictionary   ${Dict1}    ${EMPTY}   ${bwpid}
    Run Keyword if   ${len}==0    log to console     Length is 0
    [Return]   &{Dict1}

Verify numofLayers
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}
    ${rntibwp}   Create numofLayers Dictionary   ${rnti}   ${bwp}
    Log To Console    \n${rntibwp}
    ${Result}    verify_numoflayer.check_numoflayer    ${csv_file_path}   ${rntibwp}
    [Return]   ${Result}

Validate numofLayers from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}
    ${Check}  Verify numofLayers    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${bwp}
    Run Keyword if   ${Check}!=${True}   Fail   numofLayers is not matching


Capture TTI Traces and Validate numofLayers
     [Arguments]   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}
     Start And Stop Tti Trace Streaming after BWP switch   ${LOG_PATH}/ttitrace_streaming/${filename}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate numofLayers from TTI traces    ${LOG_PATH}/ttitrace_streaming/${filename}     ${rnti}   ${bwp}
