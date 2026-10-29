*** Settings ***
Documentation       :setup environment
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           logging
Library           Process
Library           ArchiveLibrary
Library           taf.gnb.oam.commissioning         WITH NAME    commissioning
Library           taf.gnb.oam.megazone_client       WITH NAME    megazone_client
Library           taf.transport.ssh                 WITH NAME    csn
#Library           taf.cloud.openstack               WITH NAME    openstack
Library           taf.config.scf                    WITH NAME    scf
Library           taf.sbts.oam.coam.admin            WITH NAME    coam
Library           taf.pdu                           WITH NAME   pdu
Library           taf.gnb.oam.megazone_client            WITH NAME   megazone
Library           ../NPS/SWENG/python_libs/luashark_tools.py
Library           luashark_tools.analyzer       WITH NAME       analyzer
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource          ../NPS/SWENG/robot/Setup.robot
Library           ../python/Test_Verifiers.py
Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          ./Gnb.robot
Resource          ./Connect.robot
Resource          ./Capture.robot

*** Keywords ***

Fetch BBoard details and slot
    Fetch board type
    Run keyword if     '${BBoard_Type}'!='ASOE'     Set gnb slot and l2ps node

Set gnb slot and l2ps node
    ${BBoard_Type}    Get BB Board Type        airscale=${AIRSCALE_GNB}
    set suite variable     ${BBoard_Type}     ${BBoard_Type}
    Connect to DU
    ${domainId}    If GNB In Left Side Of AMIA      connection=DU_conn
    ${RLslot}      set variable if     ${domainId}     ${1}       ${5}
    set suite variable      ${RLslot}     ${RLslot}
    ${l2ps_node}     set variable if     '${BBoard_Type}'=='ABIO' or 'ABIN'   A     B
    set suite variable      ${l2ps_node}     ${l2ps_node}

Set Domain ID upon BB slot
    [Arguments]                     ${airscale}
    return from keyword if          '${airscale.domainId}'!='${EMPTY}'
    [Return]       ${airscale.domainId}

L2RT Nodes Discovery From Host
    [Documentation]                 Retrieve all nodes as defined as node_0x... in /tmp
    ...                             We add only non-existing nodes in final list
    [Arguments]                     ${host}
    ${alias}                        SSH Connect                     ${host}
    ${output}                       SSH Cmd                         cd /tmp;ls -lrt | grep node_0x
    ...                             alias=${alias}
    ${L2RTFound}     run keyword and return status     should contain    ${output}      L2RT
    ${L2RTFound}     Set variable if     ${L2RTFound}     A      B
    [RETURN]      ${L2RTFound}


Check and active the BTS l2ps DBG log
    [Arguments]    ${vm_path}=${epc_log_path}    ${abil_index}=${1}    ${feature_flag}=none
    Fetch BBoard details and slot
    ${status}    run keyword and return status    Check bts DBG status
    run keyword if    ${status}==${False}    Active the BTS L2PS DBG log    vm_path=${vm_path}    feature_flag=${feature_flag}
    Builtin.Log    ${abil_index}

Check the bts DBG log status on ASOE
    Connect to DU
    csn.send_command    command=ls /var/preserve/    connection=DU_conn
    sleep    3s
    ${result}    csn.read_output    connection=DU_conn
    Should contain   ${result}   feature_log_activation.txt

Check bts DBG status
    run keyword if     '${BBoard_Type}' == 'ASOE'     Check the bts DBG log status on ASOE
    ...     ELSE       Check the bts DBG log status

Check the bts DBG log status
    Run keyword if     '${BBoard_Type}'!='ASOE'     Set gnb slot and l2ps node
    ${capacityboard_index}    run keyword if    '${BBoard_Type}' == 'ABIO' or 'ABIN'    set variable     ${RLslot}
    ...     ELSE IF    '${BBoard_Type}' == 'ABIL'    set variable     ${RLslot}
    run keyword if    '${BBoard_Type}' == 'ABIO' or 'ABIN'   Connect to Capacity Unit Master    hw_slot=${capacityboard_index}   alias=aspa
    ...    ELSE IF    '${BBoard_Type}' == 'ABIL'    Connect to Capacity Unit Slave    hw_slot=${capacityboard_index}    alias=aspa
    csn.send_command    command=ls /var/preserve/    connection=aspa
    sleep    3s
    ${result} =    csn.read_output    connection=aspa
    Should contain   ${result}   feature_log_activation.txt

Active the BTS L2PS DBG log
    [Arguments]    ${vm_path}    ${feature_flag}
    run keyword if    '${feature_flag}' == 'CB008232'    Make the knife for DBG l2ps CB008232   path=${vm_path}
    ...     ELSE IF    '${feature_flag}' == 'CB010544'    Make the knife for DBG l2ps CB010544    path=${vm_path}
    ...     ELSE    Make the knife for DBG l2ps    path=${vm_path}
    copy knife and activate      vm_path=${vm_path}

Copy and active the knife on BTS
    [Arguments]    ${vm_path}    ${knife_path}=/ffs/run/swpool/L2RT/addons    ${gnb_index}=0    ${du_index}=0
#    ${capacitycard}     set variable if    '${BBoard_Type}' == 'ABIO'    mcu-aspd    mcu-aspa
    ${capacitycard}     Run Keyword if    '${BBoard_Type}' == 'ABIN'     set variable    mcu-aspc
    ...     ELSE    set variable if    '${BBoard_Type}' == 'ABIO'    mcu-aspd    mcu-aspa
    ${asik_addr}     Set Variable        ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ${asik_username}     Set Variable     ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ${asik_password}     Set Variable     ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Run Keyword And Ignore Error    Process.Run Process
    ...    command=sudo sshpass -p ${asik_password} scp -p ${vm_path}trace.tgz ${asik_username}@${asik_addr}:/user/toor4nsn/
    ...    shell=yes
    Run Keyword And Ignore Error    csn.execute     command=mkdir -p ${knife_path}    connection=ASIK Master
    Run Keyword And Ignore Error    csn.execute     command=scp /user/toor4nsn/trace.tgz ${knife_path}/    connection=ASIK Master
    Run Keyword And Ignore Error    csn.execute     command=crasign ${knife_path}/trace.tgz    connection=ASIK Master
    Run Keyword And Ignore Error    csn.execute     command=rm -rf /ffs/run/boardcfg/${RLslot}/${l2ps_node}/${capacitycard}/addons/trace.tgz*
    ...                             connection=ASIK Master
    Run Keyword And Ignore Error    csn.execute
    ...                             command=ln ${knife_path}/trace.tgz /ffs/run/boardcfg/${RLslot}/${l2ps_node}/${capacitycard}/addons/trace.tgz
    ...                             connection=ASIK Master
    Run Keyword And Ignore Error    csn.execute
    ...                        command=ln ${knife_path}/trace.tgz.p7 /ffs/run/boardcfg/${RLslot}/${l2ps_node}/${capacitycard}/addons/trace.tgz.p7
    ...                             connection=ASIK Master
    Run Keyword And Ignore Error    csn.execute     command=rm /ffs/run/HashContainer*    connection=ASIK Master

copy knife and activate
    [Arguments]     ${vm_path}
    Run keyword if     '${BBoard_Type}' == 'ASOE'      Copy and active the knife on ASOE     ${vm_path}
    ...     ELSE       Copy and active the knife on BTS     ${vm_path}
    Reboot gNB System Module from Console and check Airscale is ready
    Check bts DBG status

Copy and active the knife on ASOE
    [Arguments]    ${vm_path}    ${knife_path}=/ffs/run/swpool/5G/L2RTNODE_ASOE/addons    ${gnb_index}=0    ${du_index}=0
    run keyword if    '${BBoard_Type}' == 'ASOE'   set suite variable    ${capacitycard}     mcu-asce
    run keyword if    '${BBoard_Type}' == 'ASOE'   set suite variable    ${l2ps_node}     A
    run keyword if    '${BBoard_Type}' == 'ASOE'   set suite variable    ${RLslot}     ${0}
    ${asik_addr}     Set Variable        ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ${asik_username}     Set Variable     ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ${asik_password}     Set Variable     ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Run Keyword And Ignore Error    Process.Run Process
    ...    command=sudo sshpass -p ${asik_password} scp -p ${vm_path}trace.tgz ${asik_username}@${asik_addr}:/user/toor4nsn/
    ...    shell=yes
    Run Keyword And Ignore Error    csn.execute     command=mkdir -p ${knife_path}    connection=DU_conn
    Run Keyword And Ignore Error    csn.execute     command=scp /user/toor4nsn/trace.tgz ${knife_path}/    connection=DU_conn
    Run Keyword And Ignore Error    csn.execute     command=crasign ${knife_path}/trace.tgz    connection=DU_conn
    Run Keyword And Ignore Error    csn.execute     command=rm -rf /ffs/run/boardcfg/${RLslot}/${l2ps_node}/${capacitycard}/addons/trace.tgz*
    ...                             connection=DU_conn
    Run Keyword And Ignore Error    csn.execute
    ...                             command=ln ${knife_path}/trace.tgz /ffs/run/boardcfg/${RLslot}/${l2ps_node}/${capacitycard}/addons/trace.tgz
    ...                             connection=DU_conn
    Run Keyword And Ignore Error    csn.execute
    ...                        command=ln ${knife_path}/trace.tgz.p7 /ffs/run/boardcfg/${RLslot}/${l2ps_node}/${capacitycard}/addons/trace.tgz.p7
    ...                             connection=DU_conn
    Run Keyword And Ignore Error    csn.execute     command=rm /ffs/run/HashContainer*    connection=DU_conn

Make the knife for DBG l2ps
    [Arguments]    ${path}
    run    command=mkdir -p ${path}var/preserve/;touch ${path}var/preserve/feature_log_activation.txt
    run    command=echo "level=DBG" >${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.PER_SRS=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.COMMON.dummy_remove_me=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.BSR=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.RACH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.PER_CSI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.DCI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.PUCCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.XPDSCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.HARQ=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.PUCCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.TA=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.SR=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.SUMIMO=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.SUMIMO=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.BSR=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.DCI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.XPUSCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.HARQ=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.BWP_ADAPTATION=1">>${path}var/preserve/feature_log_activation.txt
    run    command=cd ${path};tar czf ${path}trace.tgz var/preserve/feature_log_activation.txt

Make the knife for DBG l2ps CB010544
    [Arguments]    ${path}
    run    command=mkdir -p ${path}var/preserve/;touch ${path}var/preserve/feature_log_activation.txt
    run    command=echo "level=DBG" >${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.RACH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.FDM=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.DCI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.HARQ=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.DCI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.HARQ=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.CS1_LIST=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.PF_METRIC=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.CONT_RES_TIMER=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.PDCCH.DYN_TD_MGT=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.BFR_NOPRACH_PSBWP=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.SMALLRRC=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.BWP_ADAPTATION=1">>${path}var/preserve/feature_log_activation.txt
    run    command=cd ${path};tar czf ${path}trace.tgz var/preserve/feature_log_activation.txt

Make the knife for DBG l2ps CB008232
    [Arguments]    ${path}
    run    command=mkdir -p ${path}var/preserve/;touch ${path}var/preserve/feature_log_activation.txt
    run    command=echo "level=DBG" >${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.DCI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.PUCCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.XPDSCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.HARQ=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.PUCCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.SR=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.DCI=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.XPUSCH=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.UL.HARQ=1">>${path}var/preserve/feature_log_activation.txt
    run    command=echo "L2.L2_PS.DL.PAGING=1">>${path}var/preserve/feature_log_activation.txt
    run    command=cd ${path};tar czf ${path}trace.tgz var/preserve/feature_log_activation.txt

Reboot gNB System Module from Console and check Airscale is ready
#    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    Fetch board type
#    ssh.execute    ddal -s ddal_boot_set_reset_loop_count 0    connection=DU_conn
#    ssh.execute    system-module-reboot    connection=DU_conn
    gnb.Perform gNB reboot
    Sleep    600s       #Due to TMO sleep time is inceased from 240s to 600s
    Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    5min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Run Keyword And Ignore Error    Builtin.Log     ${gnb_id}   ${du_id}    ${comu_id}

Connect to DU
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=DU_conn

Check gNB Airscale is Ready - ${BBoard_Type}
    Dated log   \n  Check gNB Airscale is Ready - ${BBoard_Type}
    ${GNB_NODE_1}=    get variable value  ${AIRSCALE_GNB.listNodeId[0]}
    ${GNB_NODE_2}=    get variable value  ${AIRSCALE_GNB.listNodeId[1]}
    run keyword if    '${BBoard_Type}'=='ASOH'    gNB Check Airscale One Time for ASOH ${GNB_NODE_1}
    run keyword if    '${BBoard_Type}'!='ASOE'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
#    run keyword if    '${BBoard_Type}'=='ASIB'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
#    run keyword if    '${BBoard_Type}'=='ASIL'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
    run keyword if    '${BBoard_Type}'=='ASOE'    gNB Check Airscale One Time for ASOE ${GNB_NODE_1}

Check gNB Airscale is Ready ASOH - ${BBoard_Type}
    Dated log   \n  Check gNB Airscale is Ready ASOH - ${BBoard_Type}
    ${GNB_NODE_1}=    get variable value  ${AIRSCALE_GNB.listNodeId[0]}
#    ${GNB_NODE_2}=    get variable value  ${AIRSCALE_GNB.listNodeId[1]}
    run keyword if    '${BBoard_Type}'=='ASOH'    gNB Check Airscale One Time for ASOH ${GNB_NODE_1}

gNB Check Airscale One Time for ${node_id_1} and ${node_id_2}
    Dated log        \n  gNB Check Airscale One Time for ${node_id_1} and ${node_id_2}
    csn.disconnect      DU_conn
    Wait Until Keyword Succeeds    5min  30s   Connect to DU
    Dated Log       checking ${node_id_1} board status      first=True
    Wait Until Keyword Succeeds    5min  30s        Check HW    ${node_id_1}    alias=DU_conn     CCS_Daemon_node_id=${node_id_1}11
    Dated log       checking ${node_id_2} board status
    Wait Until Keyword Succeeds    5min  30s        Check HW    ${node_id_2}    alias=DU_conn     CCS_Daemon_node_id=${node_id_1}11

gNB Check Airscale One Time for ASOE ${node_id_1}
    Dated log        \n  gNB Check Airscale One Time for ${node_id_1}
    csn.disconnect      DU_conn
    Wait Until Keyword Succeeds    5min  30s   Connect to DU
    Dated Log       checking ${node_id_1} board status      first=True
    Wait Until Keyword Succeeds    5min  30s        Check HW    ${node_id_1}    alias=DU_conn     CCS_Daemon_node_id=${node_id_1}11

gNB Check Airscale One Time for ASOH ${node_id_1}
    Dated log        \n  gNB Check Airscale One Time ASOH for ${node_id_1}
    csn.disconnect      DU_conn
    Wait Until Keyword Succeeds    6min  30s   Connect to DU
    Dated Log       checking ${node_id_1} board status      first=True
    Wait Until Keyword Succeeds    5min  30s        Check HW    ${node_id_1}    alias=DU_conn     CCS_Daemon_node_id=${node_id_1}11

Fetch board type
    Connect to DU
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_unit_id 0
    ${SYS_BOARD_TYPE}               SSH Cmd                                 ${cmd} | grep value | cut -d= -f2
    ...                             alias=DU_conn
    ${SYS_BOARD_TYPE}               Remove String                           ${SYS_BOARD_TYPE}    '
    ${SYS_BOARD_TYPE}               getStringFromCmdReturn                  ${SYS_BOARD_TYPE}
    set suite variable    ${BBoard_Type}    ${SYS_BOARD_TYPE}

Check HW
    [Arguments]     ${addr}
    ...             ${alias}
    ...             ${CCS_Daemon_node_id}
    ${status}       verify_hw_status
    ...                 ${addr}
    ...                 alias=${alias}
    ...                 ccs_daemon_node_id=${CCS_Daemon_node_id}
    should be True  ${status}
    Dated Log       Board ${addr} on ${alias} : OK

Connect to TestPc
    [Documentation]    connect to TestPc. addr, username, password are from testline_configuration.
    ...                :param ${alias}: TestPc is default value, you can set with other name.
    [Arguments]    ${alias}=TestPc
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${alias}

Connect to Cloud OAM
    [Documentation]    connect to cloud gNB OAM VM. addr, username, password are from testline_configuration.
    ...                :param ${gnb_index}: testline_info.get_cloudbts_gnbs will return cloud gNB list, any element can be visited in list.
    ...                :param ${alias}: OAM is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${alias}=OAM
    ${gnbs}    testline_info.get_cloudbts_gnbs    ${tl}
    Run Keyword If    ${gnbs}
    ...               ssh.Connect to    ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                 ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                                 ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                                 alias=${alias}
    ...       ELSE    Fail    There is no CloudBts in testline.

Connect to VM ${vmname}
    [Documentation]    connect to cloud gNB VM which need "OAM" as proxy.
    ...                :param ${vmname}: VM name, include CPCL, CPIF, CPNB, CPUE, UPUE, CPNRT, DBVM...
    ...                default alias is ${vmname}, can't be reset.
    Connect to Cloud OAM
    ${dbvmhostname} =    ssh.Execute    echo -n `hostname | sed s/'oam-0'/'db-0'/`.local    OAM
    ${cbts}    testline_info.get_cloudbts_gnbs    ${tl}
    ${vm}=    Convert To Lowercase    ${vmname}
    ${hostname} =    Set Variable If    '${vm}' == 'dbvm'
    ...              ${dbvmhostname}
    ...              ${vm}-0.local -vv
    ssh.Connect to    hostname=${hostname}
    ...               username=${cbts[0].cu.oam_ssh_connection_details.username}
    ...               password=${cbts[0].cu.oam_ssh_connection_details.password}
    ...               proxy=OAM    alias=${vmname}

Connect to Common Unit Master
    [Documentation]    Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe ASIK.
    ...                In cloud gNB, ASIK Master connection need OAM as proxy.
    ...                In classical gNB, ASIK Master connection don't need any proxy.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
	${is_ipv4}       Get Variable Value       ${is_ipv4}       True
    ${proxy}    Set Variable If    ${has_cbts} and ${is_ipv4}    OAM    ${None}
    ssh.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${proxy}   alias=${alias}

Connect to All Common Unit Master
    [Documentation]    Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                In cloud gNB, ASIK Master connection need OAM as proxy.
    ...                In classical gNB, ASIK Master connection don't need any proxy.
    ...                :param ${alias}: it's part of final alias. For example: ASIK Master0, ASIK Master1...
    ...                :return: final ${asik_index} is asik number
    [Arguments]    ${alias}=ASIK Master
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ${dus}    testline_info.get_du_list    ${tl}
    ${asik_index}    Set Variable    ${0}
    FOR    ${du}    IN    @{dus}
           ssh.Connect to    ${du.f1_m_ip_addr}
    ...                       ${du.airscale.common_units[0].lmp_connection.username}
    ...                       ${du.airscale.common_units[0].lmp_connection.password}
    ...                       proxy=${proxy}    alias=${alias}${asik_index}
                             ${asik_index}    Evaluate    ${asik_index}+1
    END
    Return From Keyword    ${asik_index}

Connect to Common Unit Slave
    [Documentation]    Connect to Common Unit Slave with IP or hostname which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK only have one ASIK Master and one ASIK Slave.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Slave is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Slave    ${gnb_index}=${0}    ${asik_alias}=ASIK Master
    ${is_asib}    If ASIB card used    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${hw_type}    Get hardware type    alias=${asik_alias}
    Run keyword if    'ASIK' in '${hw_type}'    Connect to Common Unit Slave with IP    du_index=${du_index}
    ...                                                                                 alias=${alias}
    ...                                                                                 asik_alias=${asik_alias}
    ...                                                                                 gnb_index=${gnb_index}

Connect to Common Unit Slave with IP
    [Documentation]    Connect to Common Unit Slave with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK only have one ASIK Master and one ASIK Slave.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Slave is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Slave    ${asik_alias}=ASIK Master    ${gnb_index}=${0}
    Connect to Common Unit Master    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${hoststr}    ssh.Execute    command=arp -a | grep fct    connection=${asik_alias}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    @{hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asik_alias}    alias=${alias}

Connect to All Common Unit Slave
    [Documentation]    Connect to All Common Unit Slave with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK only have one ASIK Master and one ASIK Slave.
    ...                :param ${alias}: it's part of final alias. For example: ASIK Slave0, ASIK Slave1...
    ...                :return: final ${asik_index} is asik number
    [Arguments]    ${alias}=ASIK Slave
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ${dus}    testline_info.get_du_list    ${tl}
    ${asik_index}    Set Variable    ${0}
    FOR    ${du}    IN    @{dus}
           ssh.Connect to    ${du.f1_m_ip_addr}
    ...                       ${du.airscale.common_units[0].lmp_connection.username}
    ...                       ${du.airscale.common_units[0].lmp_connection.password}
    ...                       proxy=${proxy}    alias=ASIK Master${asik_index}
           ${hoststr}    ssh.Execute    arp -a | grep fct    ASIK Master${asik_index}
           ${hostnames}    Get Hosts From String    ${hoststr}
           ssh.Connect to    @{hostnames}[0]    ${du.airscale.common_units[0].lmp_connection.username}
    ...                       ${du.airscale.common_units[0].lmp_connection.password}    proxy=ASIK Master${asik_index}
    ...                       alias=ASIK Slave${asik_index}
           ${asik_index}    Evaluate    ${asik_index}+1
    END
    Return From Keyword    ${asik_index}


Connect to Capacity Unit Master
    [Documentation]    Connect to Capacity Unit Master with IP or hostname which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master    ${asik_alias}=ASIK Master    ${gnb_index}=${0}
    ${is_asib}    If ASIB card used    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_alias}
    ${hw_slot}    Run Keyword If    '${is_left_enabled}'=='${True}' and 0 < ${hw_slot} < 4    Set Variable    ${hw_slot}
    ...    ELSE IF    '${is_left_enabled}'=='${True}' and ${hw_slot} > 4    Evaluate    ${hw_slot}-4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and 0 < ${hw_slot} < 4    Evaluate    ${hw_slot}+4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and ${hw_slot} > 4    Set Variable    ${hw_slot}
    ...    ELSE    Set Variable    ${hw_slot}
    ${hw_type}    Get hardware type    alias=${asik_alias}
    Run keyword if    ${is_asib}    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    du_index=${du_index}
    ...    hw_slot=${hw_slot}    alias=${alias}    master_alias=${asik_alias}
    ...    ELSE IF    'ASOD' in '${hw_type}'    Connect to fctlb    alias=${alias}    asik_alias=${asik_alias}
    ...    ELSE    Connect to Capacity Unit Master with IP    du_index=${du_index}    hw_slot=${hw_slot}
    ...    alias=${alias}    asik_alias=${asik_alias}    gnb_index=${gnb_index}

Connect to Capacity Unit Master with IP
    [Documentation]    Connect to Capacity Unit Master with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master    ${asik_alias}=ASIK Master    ${gnb_index}=${0}
    Connect to Common Unit Master    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${hoststr}    ssh.Execute    arp -a| grep 'fsp-.*${hw_slot}a[[:space:]].*$'    ${asik_alias}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    ${hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asik_alias}    alias=${alias}

Connect to Capacity Unit Slave
    [Documentation]    Connect to Capacity Unit Slave with IP or hostname which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Slave    ${asik_alias}=ASIK Master    ${gnb_index}=${0}
    ${is_asib}    If ASIB card used    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_alias}
    ${hw_slot}    Run Keyword If    '${is_left_enabled}'=='${True}' and 0 < ${hw_slot} < 4    Set Variable    ${hw_slot}
    ...    ELSE IF    '${is_left_enabled}'=='${True}' and ${hw_slot} > 4    Evaluate    ${hw_slot}-4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and 0 < ${hw_slot} < 4    Evaluate    ${hw_slot}+4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and ${hw_slot} > 4    Set Variable    ${hw_slot}
    ...    ELSE    Set Variable    ${hw_slot}
    ${hw_type}    Get hardware type    alias=${asik_alias}
    run keyword if    ${is_asib}    Connect to Capacity Unit Slave with hostname    gnb_index=${gnb_index}    du_index=${du_index}
    ...    hw_slot=${hw_slot}    alias=${alias}    master_alias=${asik_alias}
    ...    ELSE IF    'ASOD' in '${hw_type}'    Connect to fctlb    alias=${alias}    asik_alias=${asik_alias}
    ...    ELSE    Connect to Capacity Unit Slave with IP    du_index=${du_index}
    ...    hw_slot=${hw_slot}    alias=${alias}    asik_alias=${asik_alias}    gnb_index=${gnb_index}

Connect to Capacity Unit Slave with IP
    [Documentation]    Connect to Capacity Unit Slave with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Slave    ${asik_alias}=ASIK Master    ${gnb_index}=${0}
    Connect to Common Unit Master    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${hoststr}    ssh.Execute    arp -a| grep 'fsp-.*${hw_slot}b[[:space:]].*$'    ${asik_alias}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    @{hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asik_alias}    alias=${alias}

Get CommonUnit List
    [Documentation]    get CommonUnit list from testline_configuration
    ...                :return: CommonUnits List
    ${dus}    testline_info.get_du_list    ${tl}
    @{commonunits}    Create List
    FOR    ${du}    IN    @{dus}
        ${commonunit}    Set Variable    ${du.airscale.common_units}
        ${commonunits}=    Combine Lists    ${commonunits}    ${commonunit}
    END
    Return From Keyword    ${commonunits}

Get Hosts From String
    [Documentation]    get IP list from String which search from ASIK Master
    ...                :param ${output_string}: is output of searching asik slave ip string
    ...                or abil master ip string, or abil slave ip string, or abil loner ip string from asik master
    ...                :return: asik slave ip list, or abil master ip list, or abil slave ip list, or abil loner ip list.
    [Arguments]    ${output_string}
    @{lines}=    Split To Lines    ${output_string}
    @{hosts}    Create List
    FOR    ${line}    IN    @{lines}
        @{first_split}=    Split String    ${line}    (
        @{second_split}=    Split String    ${first_split}[1]    )
        Append To List    ${hosts}    ${second_split}[0]
    END
    sort list    ${hosts}
    Return From Keyword    @{hosts}

Get RU List
    [Documentation]    get RU list from testline_configuration
    ...                :return: Rus List
    ${dus}    testline_info.get_du_list    ${tl}
    @{rus}    Create List
    FOR    ${du}    IN    @{dus}
        ${ru}    Set Variable    ${du.rus}
        ${rus}=    Combine Lists    ${rus}    ${ru}
    END
    Return From Keyword    ${rus}

Connect to ue control pc
    [Documentation]    Author: Ding Binmei
    ...                Description: Connect to UE control pc via ssh
    [Arguments]    ${ue_index}=${0}    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${cpc_alias}=cpc_${ue_index}    ${timeout}=3 min
    Wait Until Keyword Succeeds    ${timeout}    3s
    ...   ssh.Connect to    hostname=${cpc_ip}    username=${cpc_username}    password=${cpc_password}    alias=${cpc_alias}


Connect to fctlb
    [Documentation]    Connect to fctlb from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: fctlb is default value, you can set with other name.
    [Arguments]  ${du_index}=${0}    ${alias}=fctlb    ${asik_alias}=asik
    Connect to Common Unit Master      du_index=${du_index}   alias=${asik_alias}
    ${hoststr}    ssh.Execute    command=arp -a| grep 'fctlb[[:space:]].*$'    connection=${asik_alias}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    @{hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asik_alias}    alias=${alias}

Connect to fsp-1c
    [Documentation]    Connect to fsp-.*1c from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: fsp-1c is default value, you can set with other name.
    [Arguments]  ${du_index}=${0}    ${alias}=fsp-1c    ${fsp-1c}=192.168.253.22
    Connect to Common Unit Master      du_index=${du_index}   alias=asik
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    ${fsp-1c}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=asik    alias=${alias}

Connect to Capacity Unit Master with hostname
    [Documentation]    Connect to Capacity Unit Master with hostname.
    ...                username and password are same to related ASIK/ASIB Master.
    ...                set related ASIK/ASIB Master as proxy is mandantory.
    ...                :param ${gnb_index}: is index for which gnb prepare to visited.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master    ${master_alias}=Common Master
    Connect to Common Unit Master with gnbindex    gnb_index=${gnb_index}    du_index=${du_index}    alias=${master_alias}
    ${hostnames}    set variable    fsp-${hw_slot}a
    ${dus}    testline_info.get_du_list    tl=${tl}
    ssh.Connect to    hostname=${hostnames}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${master_alias}    alias=${alias}

Connect to Capacity Unit Slave with hostname
    [Documentation]    Connect to Capacity Unit Slave with hostname.
    ...                username and password are same to related ASIK/ASIB Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                :param ${gnb_index}: is index for which gnb prepare to visited.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Slave    ${master_alias}=Common Master
    Connect to Common Unit Master with gnbindex    gnb_index=${gnb_index}    du_index=${du_index}    alias=${master_alias}
    ${hostnames}    set variable    fsp-${hw_slot}b
    ${dus}    testline_info.get_du_list    tl=${tl}
    ssh.Connect to    hostname=${hostnames}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${master_alias}    alias=${alias}

Connect to Capacity Unit Loner with hostname
    [Documentation]    Connect to Capacity Unit Loner with hostname.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                :param ${gnb_index}: is index for which gnb prepare to visited.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Loner is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Loner    ${master_alias}=Common Master
    Connect to Common Unit Master with gnbindex    gnb_index=${gnb_index}    du_index=${du_index}    alias=${master_alias}
    ${hostnames}    set variable    fsp-${hw_slot}c
    ${dus}    testline_info.get_du_list    tl=${tl}
    ssh.Connect to    hostname=${hostnames}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${master_alias}    alias=${alias}

Connect to Common Unit Slave with hostname
    [Documentation]    Connect to Common Unit Slave with hostname from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK only have one ASIK Master and one ASIK Slave.
    ...                :param ${gnb_index}: is index for which gnb prepare to visited.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Slave is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=Common Slave    ${master_alias}=Common Master
    Connect to Common Unit Master with gnbindex    gnb_index=${gnb_index}    du_index=${du_index}    alias=${master_alias}
    ${hostnames}    set variable    fctlb
    ${dus}    testline_info.get_du_list    tl=${tl}
    ssh.Connect to    hostname=${hostnames}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${master_alias}    alias=${alias}

Connect to Common Unit Master with gnbindex
    [Documentation]    Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe ASIK.
    ...                In cloud gNB, ASIK Master connection need OAM as proxy.
    ...                In classical gNB, ASIK Master connection don't need any proxy.
    ...                :param ${gnb_index}: is index for which gnb prepare to visited.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Master is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=Common Master
    ${has_cbts}    testline_info.has_cloudBts    tl=${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

If ASIB card used
    [Documentation]    Author: Wang Yixiang     5G_PZ_MMW_HZ_1_SG
    ...    Get info from testline and check if ASIB used.
    ...    return ${True} or ${False}
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    ssh.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}
    ${gnb_card_info}=    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0
    ...    connection=${alias}
    ${ret}    run keyword and return status    should contain    ${gnb_card_info}    ASIB
    [Return]    ${ret}

Get hardware type
    [Documentation]    Author: Ding Binmei
    ...    Description: Get hardware type from SSH connection. alias can be SSH connection for capcity unit or common unit
    [Arguments]    ${alias}=ABIL Master
    ${cmd_get_hw_type}    Set variable    ddal -s ddal_sysinfo_module_get_unit_id 0|grep "value"
    ${output}    ssh.execute    command=${cmd_get_hw_type}    connection=${alias}
    ${hw_type}    Get Regexp Matches    ${output}    value='(.*)'    1
    [Return]  ${hw_type[0].strip()}

# --- For GNB location is amia ---
If GNB In Left Side Of AMIA
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=ASIK Master
    ${cmd_output0}    csn.Execute    command=cat /etc/hosts   connection=${connection}
    ${fctid}    get regexp matches      ${cmd_output0}     fct(\\d+)s0lla    1
    ${is_left_enabled}    Set Variable If    '0' in '${fctid[0]}'    ${True}    ${False}
    [Return]    ${is_left_enabled}
