# *** Settings ***
# Documentation
# ...               author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Force Tags        5G_SISO    CB007608    CRT_22R1    CRT_TRUNK
# ...    PY36
# Suite Setup       2083 Suite Setup
# Suite Teardown    2083 Suite Teardown
#
#
# Library           ute_admin   WITH NAME    admin
# Library           ute_syslog
# Library           taf.config.scf    WITH NAME    cscf
# #Library           taf.sbts.oam.coam.admin    WITH NAME    coam
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Variables         ./resource/paramter_modify.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#
# *** Variables ***
# ${4G_IP}                     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${4G_USERNAME}               ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# ${4G_PASSWORD}               ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
# ${DU_OAM_IP}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${DU_IP}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_USERNAME}            ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}            ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TEST_PC_IP}                ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}          ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}          ${tl.test_pc.default_ssh_connection_details.password}
# ${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
# ${vendor}                    HBTE
# ${max_attenuation_value}     ${127}
# ${Netact_SSH_IP}             10.107.178.210
# ${Netact_SSH_USERNAME}       omc
# ${Netact_SSH_PASSWORD}       Nokia123!
# ${Netact_Snapshot_path}      /d/oss/global/diagsnap/ne3sws/
# ${att_ipaddr}                ${tl.attenuator.ip_addr}
# ${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_api_port}              ${tl.attenuator.port}
# ${att_port_3}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_4}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# ${att_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
# ${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
# ${onecell_scf}               ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/2083_1cell_SCF.xml
# ${twocells_22R1_scf}         ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB1.xml
# ${twocells_Trunk_scf}        ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
# ${port1}                     51000
# ${port2}                     51003
#
# *** Test Cases ***
# [1]CB007608-A-5GC002083-001_Phase1_Detection_Cancel_Netact_alarm
#     [Tags]
#     [Timeout]    150 min
#     [Setup]
#     cell config and adjust PA
#     Delete Snapshot if exists    filename=${MRBTS_ID}_Snapshot_${MRBTS_ID}_TL735*
#     Act Case1 para on WEBEM
#     FOR    ${i}    IN RANGE    0   3
#         trigger attach
#         sleep    120
#     END
#     sleep    120
#     Wait Until Keyword Succeeds    10 min    10 s    check fault
#     Wait Until Keyword Succeeds    15 min    5 min    check counter phase1 increase
#     sleep    300
#     Wait Until Keyword Succeeds    10 min    10 s    check none fault
#     sleep    60 min
#     Check snapshot existed    filename=${MRBTS_ID}_Snapshot_${MRBTS_ID}_TL735*
#     [Teardown]    Disconnect cobham connection
#
# [1]CB007608-A-5GC002083-002_Phase2_Detection_Cancel
#     [Tags]
#     [Timeout]    150 min
#     [Setup]
#     cell config and adjust PA
#     Act Case2 para on WEBEM
#     FOR    ${i}    IN RANGE    0   3
#         trigger attach
#         sleep    90
#     END
#     Wait Until Keyword Succeeds    10 min    10 s    check fault
#     Wait Until Keyword Succeeds    5 min    10 s    Verify BBMOD Reset
#     Wait Until Keyword Succeeds    10 min    10 s    Check BTS Should Be Normal
#     Wait Until Keyword Succeeds    15 min    5 min    check counter phase2 increase
#     sleep    180
#     Wait Until Keyword Succeeds    10 min    10 s    check none fault
#     [Teardown]    Disconnect cobham connection
#
# [1]CB007608-A-5GC002083-003_Phase3_Detection_Cancel
#     [Tags]
#     [Timeout]    150 min
#     [Setup]
#     cell config and adjust PA
#     Act Case3 para on WEBEM
#     start btslog capture on ute    btslog_name=btslog_name_3.log
#     FOR    ${i}    IN RANGE    0   3
#         trigger attach
#         sleep    90
#     END
#     Wait Until Keyword Succeeds    10 min    10 s    check fault
#     Wait Until Keyword Succeeds    5 min    10 s    gNB.CheckBTSReset
#     Wait Until Keyword Succeeds    10 min    10 s    Check BTS Should Be Normal
#     Wait Until Keyword Succeeds    15 min    5 min    check counter phase3 increase
#     sleep    180
#     Wait Until Keyword Succeeds    10 min    10 s    check none fault
#     Stop syslog    alias=ute
#     [Teardown]    Disconnect cobham connection
#
# [1]CB007608-A-5GC002083-004_Check_all_phases
#     [Tags]      CRT_22R1    CRT_TRUNK    CRT_22R2
#     [Timeout]    250 min
#     [Setup]
#     cell config and adjust PA
#     Act Case4 para on WEBEM
#     start btslog capture on ute    btslog_name=btslog_name_4.log
#     trigger attach
#     sleep    190
#     Wait Until Keyword Succeeds    10 min    10 s    check fault
#     Wait Until Keyword Succeeds    10 min    30    check counter phase1 increase
#     Wait Until Keyword Succeeds    15 min    10 s    check fault
#     Wait Until Keyword Succeeds    10 min    10 s    Verify BBMOD Reset
#     Wait Until Keyword Succeeds    10 min    30 s    check counter phase2 increase
#     Wait Until Keyword Succeeds    15 min    10 s    Verify BBMOD normal
#     Wait Until Keyword Succeeds    10 min    10 s    check fault
#     Wait Until Keyword Succeeds    15 min    10 s    gNB.CheckBTSReset
#     Wait Until Keyword Succeeds    10 min    10 s    Check BTS Should Be Normal
#     Wait Until Keyword Succeeds    10 min    30s    check counter phase3 increase
#     sleep    400
#     Stop syslog    alias=ute
#     check case4 counter from BTSLog
#     [Teardown]    Disconnect cobham connection
#
# [1]CB007608-A-5GC002083-006_Healthy_cell_with_sleeping_cell_detected_phase3
#     [Tags]
#     [Timeout]    150 min
#     [Setup]
#     cell config and adjust PA
#     Act Case6 para on WEBEM
#     start btslog capture on ute    btslog_name=btslog_name_6.log
#     FOR    ${i}    IN RANGE    0   3
#         trigger attach
#         sleep    90
#     END
#     Wait Until Keyword Succeeds    10 min    10 s    check fault
#     Wait Until Keyword Succeeds    5 min    10 s    Check Cell State
#     FOR    ${i}    IN RANGE    0   4
#         gNB.CheckBTSNormal
#         sleep    30
#     END
#     Wait Until Keyword Succeeds    10 min    10 s    Check BTS Should Be Normal
#     Stop syslog    alias=ute
#     [Teardown]    Disconnect cobham connection
#
# [1]CB007608-A-5GC002083-008_Healthy_cell_with_sleeping_cell_detected_phase3_forced
#     [Tags]        CRT_22R1
#     [Timeout]    150 min
#     [Setup]
#     cell config and adjust PA
#     Act Case8 para on WEBEM
#     start btslog capture on ute    btslog_name=btslog_name_8.log
#     FOR    ${i}    IN RANGE    0   3
#         trigger attach
#         sleep    90
#     END
#     Wait Until Keyword Succeeds    5 min    10 s    check fault
#     Wait Until Keyword Succeeds    5 min    10 s    gNB.CheckBTSReset
#     Wait Until Keyword Succeeds    10 min    10 s    Check BTS Should Be Normal
#     Wait Until Keyword Succeeds    15 min    5 min    check counter phase3 increase
#     Stop syslog    alias=ute
#     [Teardown]    Disconnect cobham connection
#
# *** Keywords ***
# Get Version
#     Log To Console    Get Version
#     ${connection}    coam.connect_to    bts_host=${DU_OAM_IP}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${versiontitle}    set variable    ${version_list[0]}
#     [Return]    ${versiontitle}
#     [Teardown]    coam.Teardown  connection=${connection}
#
# Case Teardown
#     Adjust the HBTE attenuation value    ${8}    ${8}    ${8}    ${8}
#     CI_interface.Common Case Teardown
#
# 2083 Suite Setup
#     teardown SCF reduct
#     change 4G configuration
#
# 2083 Suite Teardown
#     Adjust the HBTE attenuation value    ${8}    ${8}    ${8}    ${8}
#     teardown SCF reduct
#     reduct 4G configuration
#     CI_interface.Common Case Teardown
#
# COAM Commission with scf file ignore error
#     [Arguments]    ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
#     &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
#     ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
#
# check counter phase1 increase
#     ${M55601C00006}    Check PM counter result    counter_id=M55601C00006
#     ${counter_value_sum}    Get length and Check sum counter value    ${M55601C00006}
#     should be true    ${counter_value_sum}==${1}
#
# check counter phase2 increase
#     ${M55601C00007}    Check PM counter result    counter_id=M55601C00007
#     ${counter_value_sum}    Get length and Check sum counter value    ${M55601C00007}
#     should be true    ${counter_value_sum}==${1}
#
# check counter phase3 increase
#     ${M55601C00008}    Check PM counter result    counter_id=M55601C00008
#     ${counter_value_sum}    Get length and Check sum counter value    ${M55601C00008}
#     should be true    ${counter_value_sum}==${1}
#
# Get length and Check sum counter value
#     [Arguments]     ${list_input}
#     ${length}      Get Length       ${list_input}
#     ${counter_value_sum}       Set Variable          0
#     FOR   ${i}    IN RANGE    ${0}    ${length}     1
#         ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
#     END
#     [Return]    ${counter_value_sum}
#
# get SCF from WEBEM
#     [Arguments]     ${scf_mame}=SCF_C.xml
#     Connect to DU
#     coam.get_current_scf_file    local_dir_path=${output_dir}    file_name=${scf_mame}    connection=cOAM_admin    timeout=60
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# teardown SCF reduct
#     [Arguments]     ${scf_mame}=SCF_C.xml
#     ${conn}    Connect to DU
#     ${versiontitle}    Get Version
#     run keyword if    '${versiontitle}'=='SBTS22R1'
#     ...    COAM Commission with scf file ignore error    scf_file_path=${twocells_22R1_scf}     connection=${conn}
#     ...    ELSE    COAM Commission with scf file ignore error    scf_file_path=${twocells_Trunk_scf}     connection=${conn}
# #    COAM Commission with scf file ignore error    scf_file_path=${twocells_scf}     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/${scf_mame}
#
# Modify and Commission case1 scf file
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min
#     ${scf_path}     set vari able    ${onecell_scf}
#     cscf.load_scf    ${scf_path}
#     cscf.modify_scf_element    value=${True}    dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
#     cscf.add_element_to_scf    value=${300}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
#     cscf.add_element_to_scf    value=${350}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh1Timer
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
#     cscf.add_list_to_scf    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers
#     cscf.add_item_to_list    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers    elements=${faultSnapshotTriggers_1}
#     cscf.save_scf    ${output_dir}/scf.xml
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/scf.xml
#
# Modify and Commission case2 scf file
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min
#     ${scf_path}     set vari able    ${onecell_scf}
#     cscf.load_scf    ${scf_path}
#     cscf.modify_scf_element    value=${True}    dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
#     cscf.add_element_to_scf    value=${180}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh2Timer
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
#     cscf.add_element_to_scf    value=${2}   dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBbuPerDay
#     cscf.add_list_to_scf    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers
#     cscf.add_item_to_list    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers    elements=${faultSnapshotTriggers_1}
#     cscf.save_scf    ${output_dir}/scf.xml
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/scf.xml
#
# Modify and Commission case3 scf file
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min
#     ${scf_path}     set vari able    ${onecell_scf}
#     cscf.load_scf    ${scf_path}
#     cscf.modify_scf_element    value=${True}    dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
#     cscf.add_element_to_scf    value=${180}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh3Timer
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
#     cscf.add_element_to_scf    value=${2}   dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBtsPerDay
#     cscf.add_list_to_scf    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers
#     cscf.add_item_to_list    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers    elements=${faultSnapshotTriggers_1}
#     cscf.save_scf    ${output_dir}/scf.xml
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/scf.xml
#
# Modify and Commission case4 scf file
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
#     ${scf_path}     set variable    ${onecell_scf}
#     cscf.load_scf    ${scf_path}
#     cscf.modify_scf_element    value=${True}   dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrBeamforming
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrCaCu
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrCaDu
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrCellAvailability
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrCellUtilization
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrDlHarq
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrDlSignalQuality
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrE1InterfaceBts
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrE1InterfaceCuCpNsa
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrE1InterfaceCuCpSa
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrE1InterfaceCuUp
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrE1InterfaceCuUpNsa
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrE1InterfaceCuUpSa
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrEcpriUpFCp
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrEirp
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrF1CC
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrF1CD
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrF1UCInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrF1UDInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrF1UU
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrGnss
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrHighRlcReport
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrIfPsCellChange
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrLowRlcReport
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrLteMgPerCell
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrLteMobilityReport
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrMacPduTput
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrMacSduReport
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrMgPerCell
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrMobilityReportCu
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrMobilityReportDu
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrNgInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrNgUReport
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrNRMOP
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrNTRAF
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrPDCP1Report
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrPDCP2Report
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrPdcpC
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrPsCellChange
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRacCu
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRacDu
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRachUsage
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRadBearer
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRANS
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRlfPerCell
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRRCC
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRRCD
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRSACU
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRSADU
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRSANB
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrRSUP
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrS1UInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSfpBbmod
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSfpRmod
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSfpSmod
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSlicingCuCp
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSlicingCuUp
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSrb3C
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSrb3D
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrSrvcAvaStats
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrTimingAdvance
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrUeState
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrUlHarq
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrUlSignalQuality
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrX2CB
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrX2CC
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrX2UInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrXnCCInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrXnInterface
#     cscf.modify_scf_element    value=5min    dist_name=${NRPMRNL_1}    p_name=miNrXnUCInterface
#     cscf.add_element_to_scf    value=${180}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
#     cscf.add_element_to_scf    value=${0}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
#     cscf.add_element_to_scf    value=${0}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh1Timer
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh2Timer
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh3Timer
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBbuPerDay
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBtsPerDay
#     cscf.add_list_to_scf    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers
#     cscf.add_item_to_list    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers    elements=${faultSnapshotTriggers_1}
#     cscf.save_scf    ${output_dir}/scf.xml
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/scf.xml
#
# Modify and Commission case6 scf file
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min
#     ${versiontitle}    Get Version
#     ${scf_path}=    run keyword if    '${versiontitle}'=='SBTS22R1'     set variable    ${twocells_22R1_scf}
#     ...    ELSE    set variable    ${twocells_Trunk_scf}
#     cscf.load_scf    ${scf_path}
#     cscf.modify_scf_element    value=${True}    dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
#     cscf.add_element_to_scf    value=${180}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh3Timer
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
#     cscf.add_element_to_scf    value=${2}   dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBtsPerDay
#     cscf.modify_scf_element    value=${False}    dist_name=${FMCADM_1_NAME}    p_name=actForceAutoReset
#     cscf.add_list_to_scf    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers
#     cscf.add_item_to_list    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers    elements=${faultSnapshotTriggers_1}
#     cscf.save_scf    ${output_dir}/scf.xml
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/scf.xml
#
# Modify and Commission case8 scf file
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
#     ${versiontitle}    Get Version
#     ${scf_path}=    run keyword if    '${versiontitle}'=='SBTS22R1'     set variable    ${twocells_22R1_scf}
#     ...    ELSE    set variable    ${twocells_Trunk_scf}
#     cscf.load_scf    ${scf_path}
#     cscf.modify_scf_element    value=${True}    dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
#     cscf.add_element_to_scf    value=${180}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
#     cscf.add_element_to_scf    value=${1}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
#     cscf.add_element_to_scf    value=${200}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh3Timer
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
#     cscf.add_element_to_scf    value=${True}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
#     cscf.add_element_to_scf    value=${False}   dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
#     cscf.add_element_to_scf    value=${2}   dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBtsPerDay
#     cscf.modify_scf_element    value=${True}    dist_name=${FMCADM_1_NAME}    p_name=actForceAutoReset
#     cscf.add_list_to_scf    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers
#     cscf.add_item_to_list    dist_name=${TRBLCADM_1_NAME}    list_name=faultSnapshotTriggers    elements=${faultSnapshotTriggers_1}
#     cscf.save_scf    ${output_dir}/scf.xml
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS Should Be Normal
#     [Teardown]    Remove File    ${output_dir}/scf.xml
#
# Adjust the HBTE attenuation value
#     [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}     ${port1}=${att_port_3}
#     ...    ${port2}=${att_port_4}    ${port3}=${att_port_7}    ${port4}=${att_port_8}
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#     att.set_attenuation     port=${port1}    value=${value_1}
#     att.set_attenuation     port=${port2}    value=${value_2}
#     att.set_attenuation     port=${port3}    value=${value_3}
#     att.set_attenuation     port=${port4}    value=${value_4}
#     ${value_port1}    att.read_attenuation    port=${port1}
#     should be equal    '${value_port1}'    '${value_1}.0'
#     ${value_port2}    att.read_attenuation    port=${port2}
#     should be equal    '${value_port2}'    '${value_2}.0'
#     ${value_port3}    att.read_attenuation    port=${port3}
#     should be equal    '${value_port3}'    '${value_3}.0'
#     ${value_port4}    att.read_attenuation    port=${port4}
#     should be equal    '${value_port4}'    '${value_4}.0'
#
# gNB.CheckBTSReset
#     ${status}    Run Keyword And Return Status    gNB.PingOAM
#     Should Be True    '${status}'=='False'
#
# gNB.CheckBTSNormal
#     ${status}    Run Keyword And Return Status    gNB.PingOAM
#     Should Be True    '${status}'=='True'
#
# gNB.PingOAM
#     ${result}  run   command=ping ${DU_IP} -c 10
#     should contain    ${result}    64 bytes from ${DU_IP}
#
# Check BBmod State
#     Connect to DU
#     ${bbmod_state}   Get SCF single Value from current xml file
#     ...   parameter=operationalState   list_name=${None}   dist_name=${BBMOD_R_DN}   p_index=${0}
#     ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     should be true    '${bbmod_state}'=='disabled'
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# Verify BBMOD normal
#     Connect to DU
#     ${bbmod_state}   Get SCF single Value from current xml file
#     ...   parameter=operationalState   list_name=${None}   dist_name=${BBMOD_R_DN}   p_index=${0}
#     ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     should be true    '${bbmod_state}'=='enabled'
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# Check Cell State
#     Connect to DU
#     ${cell_state}   Get SCF single Value from current xml file
#     ...   parameter=operationalState   list_name=${None}   dist_name=${cell_R_DN}   p_index=${0}
#     ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     should be true    '${cell_state}'=='enabled'
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# Verify BBMOD Reset
#     Connect to DU
#     Wait Until Keyword Succeeds    5 min    10 sec    Check BBmod State
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# Get All Cell Status Via Gnb
#     [Documentation]     Get All Cell Status Via Gnb
#     ...  Description: Get All Cell Status Via Gnb, return a cells status list
#     admin.Setup admin
#     @{cells_info}    admin.get_cells_info
#     :FOR  ${cell_info}  IN  @{cells_info}
#     \    Keep In Dictionary  ${cell_info}  globalCellId  status
#
#     Log To Console  All Cell Status: ${cells_info}
#     [Return]  ${cells_info}
#     [Teardown]  admin.Teardown admin
#
# start btslog capture on ute
#     [Arguments]      ${connection}=ute     ${btslog_name}=btslog.log
# #    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
#     log to console    start syslog...
#     ${list}    Create list     ${port1}    ${port2}
#     ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}      log_name=${btslog_name}
#     ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    ports=${list}    alias=${connection}
#
# Check PM counter result
#     [Arguments]    ${counter_id}    ${index}=${0}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=CELLS
#     ...    ${NRCELL}=NRCELL-2    ${counter_object}=NCAV
#     ${connection}    Rest Login DU    index=${index}    enb=${enb}
#     ${counter_values}=    coam.get pm counters   couter_ids=${counter_id}    connection=${connection}
#     ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
#     [Return]    ${result}
#     [Teardown]    Run Keyword And Ignore Error   Rest Logout DU    alias=${connection}
#
# Rest Login DU
#     [Arguments]    ${index}=${0}        ${alias}=default    ${enb}=${False}
#     [Documentation]   Rest Login DU
#     ${btsip}=    Set Variable If    ${enb}==${False}
#     ...  ${tl.gnbs[${index}].dus[0].f1_m_ip_addr}    ${tl.enbs[${index}].airscale.common_units[0].lmp_connection.addr}
#     Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
#     Connect to gnb coam via ssl    bts_host=${btsip}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     ...    connection=${alias}
#     ${connection}    set variable    ${alias}
#     [Return]  ${connection}
#
# Rest Logout DU
#     [Arguments]  ${alias}=default
#     [Documentation]   Rest Logout DU
#     coam.Teardown  connection=${alias}
#
# Check BTS Should Be Normal
#     Log To Console  Check BTS Should Be Normal
#     [Arguments]    ${index}=${0}    ${enb}=${False}
#     ${connection}    Rest Login DU    index=${index}    enb=${enb}
#     Wait Until BTS Should Be Normal    connection=${connection}
#     [Teardown]   Run Keyword And Ignore Error   Rest Logout DU    alias=${connection}
#
# Online update paramters
#     Log To Console  online check paramter
#     [Arguments]    ${parameters}    ${index}=${0}    ${enb}=${False}
#     ${connection}    Rest Login DU    index=${index}    enb=${enb}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}    connection=${connection}
#     Wait Until BTS Should Be Normal    connection=${connection}
#     [Teardown]   Run Keyword And Ignore Error   Rest Logout DU    alias=${connection}
#
# Wait Until BTS Should Be Normal
#     [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${connection}=default
#     [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
#     Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair    alias=${connection}
#
# #Gnb Cell Should Be Onair
# #    [Arguments]  ${alias}=default  ${cell_type }=nr
# #    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
# #    ${bts_info}   coam.get_bts_info   connection=${alias}   timeout=10
# #    ${cell_list}    Set Variable   ${bts_info['cells']['nr']}
# #    FOR    ${cell}    IN    @{cell_list}
# #        ${status}   Set Variable   ${cell['status']}
# #        Should Contain   ${status['proceduralStatus']}   configured
# #        Should Contain   ${status['availabilityStatus']}   Online
# #        Should Contain   ${status['operationalState']}   Enabled
# #        Should Contain   ${status['usageState']}   Active
# #    END
#
# Gnb Cell Should Be Onair
#     [Arguments]    ${alias}=default    ${cell_type}=nr
#     [Documentation]    Gnb Cell Should Be Onair, check method is via REST
#     log to console    waiting for BTS onair
#     ${status}      coam.Get_Bts_Statuses   connection=${alias}
#     ${proceduralState}   Get From Dictionary    ${status}   proceduralState
#     Should Be Equal as strings    ${proceduralState}    OnAir
#     #cell info
#
# check case4 counter from BTSLog
#     [Arguments]    ${btslog_name}=${OUTPUT_DIR}/btslog_name_4.log
#     ssh.Connect to            ${TEST_PC_IP}
#     ...                       ${TEST_PC_USERNAME}
#     ...                       ${TEST_PC_PASSWORD}    alias=sshtestpc
#     ${outph2}    ssh.Execute     command=cat ${btslog_name} | grep -i "maxNumSlCellRecActForPh2PerDay"
#     ...    connection=sshtestpc
#     Should Match Regexp    ${outph2}    [\\s\\S]*is 1, current value is 0[\\s\\S]*is 1, current value is 1
#     ${outph3}    ssh.Execute     command=cat ${btslog_name} | grep -i "maxNumSlCellRecActForPh3PerDay"
#     ...    connection=sshtestpc
#     Should Match Regexp    ${outph3}    [\\s\\S]*is 1, current value is 0[\\s\\S]*is 1, current value is 1
#     [Teardown]    ssh.disconnect    connection=sshtestpc
#
# Check snapshot existed
#     [Arguments]    ${filename}
#     [Documentation]    Check File Existed or not in general linux server with taf.transport.ssh library
#     ...    | Input Parameters | Man. | Description |
#     ...    | filename | yes | file name |
#     ...    | alias    | no | alias name |
#     ...    *RETURN VALUE*
#     ...    return 1 if file exists, otherwise return 0
#     ...    Example
#     ...    | ${bExit} | Check File Existed |  /root/a.txt |
#     ssh.Connect to            ${Netact_SSH_IP}
#     ...                       ${Netact_SSH_USERNAME}
#     ...                       ${Netact_SSH_PASSWORD}    alias=sshnetact
#     ${out}    ssh.Execute     command=find ${Netact_Snapshot_path} -type f -name "${filename}.zip"    connection=sshnetact
# #    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
#     Should Match Regexp    ${out}    MRBTS-10314_Snapshot_MRBTS-10314_TL735
#     [Teardown]    ssh.disconnect    connection=sshnetact
#
# Delete Snapshot if exists
#     [Arguments]    ${filename}
#     ssh.Connect to            ${Netact_SSH_IP}
#     ...                       ${Netact_SSH_USERNAME}
#     ...                       ${Netact_SSH_PASSWORD}    alias=sshnetact
#     ssh.Execute     command=rm -rf ${Netact_Snapshot_path}${filename}    connection=sshnetact
#     [Teardown]    ssh.disconnect    connection=sshnetact
#
# perform muti object recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${operation}=create   ${skip_parameter_relation_errors}=${True}
#     ...    ${should_activate}=${True}    ${connection}=cOAM_admin
#     coam.perform_object_recommissioning
#     ...      dist_name=${dist_name}
#     ...      parameter=${parameter}
#     ...      operation=${operation}
#     ...      skip_parameter_relation_errors= ${skip_parameter_relation_errors}
#     ...      should_activate=${should_activate}
#     ...      connection=${connection}
#
# perform muti Parameter recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
#     ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=${dist_name}
#     ...    parameter=${parameter}
#     ...    value=${value}
#     ...    operation=${operation}
#     ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...    should_activate=${should_activate}
#     ...    connection=${connection}
#
# change 4G configuration
#     Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=4G_admin
#     perform muti Parameter recommissioning
#     ...    dist_name=MRBTS-735/LNBTS-735/LNCEL-2
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=1
#     ...    operation=update
#     ...    connection=4G_admin
#     coam.teardown     connection=4G_admin
#
# reduct 4G configuration
#     Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=4G_admin
#     perform muti Parameter recommissioning
#     ...    dist_name=MRBTS-735/LNBTS-735/LNCEL-2
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=0
#     ...    operation=update
#     ...    connection=4G_admin
#     coam.teardown     connection=4G_admin
#
# Act Case1 para on WEBEM
#     Modify and Commission case1 scf file
#
# Act Case2 para on WEBEM
#     Modify and Commission case2 scf file
#
# Act Case3 para on WEBEM
#     Modify and Commission case3 scf file
#
# Act Case4 para on WEBEM
#     Modify and Commission case4 scf file
#
# Act Case6 para on WEBEM
#     Modify and Commission case6 scf file
#
# Act Case8 para on WEBEM
#     Modify and Commission case8 scf file
#
# Get Alarm Info
#     [Arguments]    ${timeout}=50s    ${connection}=cOAM_admin    ${faultID}=${4547}
# #    sleep    10s
#     @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
#     sleep    1s
#     log     ${alarms}
#     ${alarm_list}    create list
#     FOR    ${item}    IN     @{alarms}
#         ${fault_id}    get from dictionary    ${item}      faultId
#         ${alarm_id}    get from dictionary    ${item}      alarmId
#         run keyword if    '${fault_id}'=='${faultID}'    append to list    ${alarm_list}    ${alarm_id}
#     END
#     ${fault_id_list}    create list
#     FOR    ${item}    IN    @{alarms}
#         ${fault_id}    get from dictionary    ${item}    faultId
#         ${fault_name}    get from dictionary    ${item}    faultName
#         append to list    ${fault_id_list}    ${fault_id}
#     END
#     [Return]    ${alarm_list}    ${fault_id_list}
#
# check fault
#     [Arguments]    ${faultID}=${4547}
#     Connect to DU
#     ${alarm_list}    ${fault_id_list}    Get Alarm Info
#     list should contain value    ${fault_id_list}    ${faultID}
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# check none fault
#     [Arguments]    ${faultID}=${4547}
#     Connect to DU
#     ${alarm_list}    ${fault_id_list}    Get Alarm Info
#     list should not contain value    ${fault_id_list}    ${faultID}
#     [Teardown]    run keyword and ignore error    Disconnect from DU
#
# Connect to DU
#     [Arguments]    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
#     Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
#     ${conn}    set variable    ${alias}
#     [Return]    ${conn}
#
# Disconnect from DU
#     [Arguments]    ${alias}=cOAM_admin
#     coam.teardown     connection=${alias}
#
# cell config and adjust PA
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
#     Adjust the HBTE attenuation value    ${80}    ${80}    ${80}    ${80}
#
# trigger attach
#     run keyword and expect error    *    E500 attach and verify
#            ...                              attach_script_path=${CURDIR}/E500_scripts/NSA_5G_UEattach.txt
#            ...                              e500_alias=${TMA_APP_ALIAS}
#            ...                              is_need_to_check_mul_drb_established=${False}
#            ...                              mul_drb_code_stream=142D28DFAFC7370CD311FAFC7370CC28    rrc_count=2
#     sleep    5
#     [Teardown]     run keyword and continue on failure    tm500_hangzhou.TM500 detach
#     ...    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${CURDIR}/E500_scripts/NSA_5G_UEdetach.txt
