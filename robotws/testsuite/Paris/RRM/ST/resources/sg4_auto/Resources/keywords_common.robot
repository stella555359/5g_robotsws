*** Settings ***
Documentation
...         common keywords for CB010513 testcases
Variables   ${CURDIR}/../Resources/common_import/python/custom.py
Variables   ${CURDIR}/../Resources/common_import/python/bfatToTl.py
#Variables   ${CURDIR}/../Resources/common_import/python/bfatToCustom.py

Library	    OperatingSystem
Library	    taf.sw.reporting_portal
Library	    taf.transport.ssh          		        WITH NAME    ssh
Library     taf.collectors.tcpdump    WITH NAME  tct
Library     taf.collectors.l2stream3  WITH NAME  tcl
Library     taf.collectors.core       WITH NAME  tcc
Library     taf.converters.eventdecoder  WITH NAME  tce
Library     taf.collectors.l1l2bip      WITH NAME   l1l2bip
Library     taf.config.scf      WITH NAME  scf
Library     taf.ue.prisma                WITH NAME   prismaTaf
Library     taf.analyzer.pcap                WITH NAME   pcap
Library     XML    True
Library	    ${CURDIR}/../Resources/common_import/python/swconfig_handler.py     WITH NAME    swconf
Library     ${CURDIR}/../Resources/common_import/python/yamlPrisma.py
Library     ${CURDIR}/../Resources/common_import/python/coam_parameter.py
Library     ${CURDIR}/../Resources/common_import/python/common_utilities.py
Library     ${CURDIR}/../Resources/common_import/python/CB010513_lib.py
Library     ${CURDIR}/../Resources/common_import/python/vm_handler.py
Library     ${CURDIR}/../Resources/common_import/python/MCSharkDissectors.py
#Resource    ${CURDIR}/../Resources/common_import/reporting.robot
Resource    ${CURDIR}/../Resources/common_import/coam_ulm.robot
Resource    ${CURDIR}/../Resources/common_import/ttitrace.robot
Resource    ${CURDIR}/../Resources/common_import/gnb.robot
Resource    ${CURDIR}/../Resources/common_import/testline.robot
#Resource    ${CURDIR}/../Resources/var.robot
Resource    ${CURDIR}/../Resources/prisma.robot
Resource    ${CURDIR}/../Resources/kw_Prisma_Taf.robot
Resource    ${CURDIR}/../Resources/traffic.robot
Resource    ${CURDIR}/../Resources/common_import/Keywords_iperf_prisma.robot
Resource    ${CURDIR}/../Resources/common_import/Aasyslogs.robot


Resource        taf/rfrl/bts/robot/common/gnb_log.robot


*** Variables ***

#${FILES_BASE_LINK}             http://files.ute.nsn-rdnet.net/builds/enb/base
${FILES_BASE_LINK}             https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${FILES_BASE_LINK_BRANCHES}    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public/System_Release

*** Keywords ***

Wait for next measurement interval
    [Arguments]
    ...     ${additional-waiting-time}=70s
    ...     ${is_reduce_waiting-time}=false
    ...     ${waiting-time_thresold}=7
    ...     ${measurement_period_in_min}=5
    @{act_time}    Get Time    hour min sec
    ${min}    set variable    ${act_time[1]}
    ${minute}    convert to integer    ${min}
    ${int}    Evaluate    int(${minute}/${measurement_period_in_min})
    ${CSV-creation-interval-begin}    Evaluate    int(${minute}/${measurement_period_in_min}) * ${measurement_period_in_min}
    ${waiting-time}    Evaluate    ${CSV-creation-interval-begin}+${measurement_period_in_min}-${minute}
    Run keyword if    ${waiting-time} > ${waiting-time_thresold} and '${is_reduce_waiting-time}' == 'true'
    ...    Return From Keyword    ${waiting-time}
    Sleep    ${waiting-time} minutes
    Sleep    ${additional-waiting-time}

SetFlagOnSwConfig
    [Arguments]       ${flag}      ${value}

    ${asik_cnx}       ssh.connect_to
        ...      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
        ...      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
        ...      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...      look_for_keys=False
    ...      alias=asik_als

    swconf.set_flag
    ...     ${asik_cnx}
    ...     /ffs/run/swconfig.txt
    ...     ${flag}
    ...     ${value}

    ${contents}=    ssh.Execute      more /ffs/run/swconfig.txt | grep 580220   connection=${asik_cnx}
    ssh.disconnect  connection=${asik_cnx}

Check CB007113 Activation
    ${commandToRun}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep
    ...     'l1SpMaxNumStreamPrb\"\:${maxNumStreamPrbL1Sp}\,\"l1SpMaxNumLayerPrb\"\:${maxNumLayerPrbL1Sp}'

    ${output1}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep 'slowPrbPoolingTddFr1UlAllowed\"\:true'
    ${output2}=        OperatingSystem.Run
    ...    command=${commandToRun}

    should not be empty                  ${output1}
    should not be empty                  ${output2}
    RETURN        ${output1}       ${output2}

Check CB008940 Activation
    ${commandToRun}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep
    ...     'l1SpMaxNumStreamPrb\"\:${maxNumStreamPrbL1Sp}\,\"l1SpMaxNumLayerPrb\"\:${maxNumLayerPrbL1Sp}'

    ${output1}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep 'slowPrbPoolingTddFr1DlAllowed\"\:true'
    ${output2}=        OperatingSystem.Run
    ...    command=${commandToRun}

    should not be empty                  ${output1}
    should not be empty                  ${output2}
    RETURN        ${output1}       ${output2}

Check CB010513 Activation
    ${commandToRunDl}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep -E
    ...     'l1DlSubPoolList\"?\:.*?l1SpMaxNumStreamPrb\"?\:${maxNumStreamPrbL1Sp}\, ?\"?l1SpMaxNumLayerPrb\"?\:${maxNumLayerPrbL1Sp}'
    ${commandToRunUl}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep -E
    ...     'l1UlSubPoolList\"?\:.*?l1SpMaxNumStreamPrb\"?\:${maxNumStreamPrbL1Sp_ul_1}\,\"?l1SpMaxNumLayerPrb\"?\:${maxNumLayerPrbL1Sp_ul_1}'

    ${slowPrbPoolingTddFr1DlAllowed}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'slowPrbPoolingTddFr1DlAllowed\"?\:true'
    ${MaxNumPrbDl}=        OperatingSystem.Run
    ...    command=${commandToRunDl}
    ${MaxNumPrbUl}=        OperatingSystem.Run
    ...    command=${commandToRunUl}
    ${actBbPoolExtensionTddFr1}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'actBbPoolExtensionTddFr1\"?\:true'
    ${slowPrbPoolingTddFr1UlAllowed}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'slowPrbPoolingTddFr1UlAllowed\"?\:true'
    ${scheUePoolingAllowed}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'scheUePoolingAllowed\"?\:true'
    should not be empty                  ${slowPrbPoolingTddFr1DlAllowed}
    log to console      slowPrbPoolingTddFr1DlAllowed: true
    should not be empty                  ${MaxNumPrbDl}
#    should not be empty                  ${MaxNumPrbUl}
    should not be empty                  ${actBbPoolExtensionTddFr1}
    should not be empty                  ${slowPrbPoolingTddFr1UlAllowed}
    should not be empty                  ${scheUePoolingAllowed}

Check Cell Setup Values
    ${commandToRunDl}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep -E
    ...     'l1DlSubPoolList\"?\:.*?l1SpMaxNumStreamPrb\"?\:\d*\, ?\"?l1SpMaxNumLayerPrb\"?\:${maxNumLayerPrbL1Sp}'
    ${commandToRunUl}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep -E
    ...     'l1UlSubPoolList\"?\:.*?l1SpMaxNumStreamPrb\"?\:${maxNumStreamPrbL1Sp_ul_1}\,\"?l1SpMaxNumLayerPrb\"?\:${maxNumLayerPrbL1Sp_ul_1}'

    ${slowPrbPoolingTddFr1DlAllowed}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'slowPrbPoolingTddFr1DlAllowed\"?\:true'
    ${MaxNumPrbDl}=        OperatingSystem.Run
    ...    command=${commandToRunDl}
    ${MaxNumPrbUl}=        OperatingSystem.Run
    ...    command=${commandToRunUl}
    ${actBbPoolExtensionTddFr1}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'actBbPoolExtensionTddFr1\"?\:true'
    ${slowPrbPoolingTddFr1UlAllowed}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'slowPrbPoolingTddFr1UlAllowed\"?\:true'
    ${scheUePoolingAllowed}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'scheUePoolingAllowed\"?\:true'
    should not be empty                  ${slowPrbPoolingTddFr1DlAllowed}
    log to console      slowPrbPoolingTddFr1DlAllowed: true
    should not be empty                  ${MaxNumPrbDl}
#    should not be empty                  ${MaxNumPrbUl}
    should not be empty                  ${actBbPoolExtensionTddFr1}
    should not be empty                  ${slowPrbPoolingTddFr1UlAllowed}
    should not be empty                  ${scheUePoolingAllowed}

Check CB010513 Activation with Aasyslogs
    [Arguments]
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    Aasyslog precondition
    ssh.connect_to      hostname=${host}    username=${username}    password=${password}    alias=BBMOD


    ${commandToRun}     Catenate
    ...     cat ${syslog_folder}/${syslog} | grep -E
    ...     'l1SpMaxNumStreamPrb\"?\:${maxNumStreamPrbL1Sp}\,\"?l1SpMaxNumLayerPrb\"?\:${maxNumLayerPrbL1Sp}'

    ${output1}=        ssh.Execute
    ...    cat /tmp/${syslog} | grep -aE 'slowPrbPoolingTddFr1DlAllowed\"?\:true'        connection=BBMOD
    ${output2}=        OperatingSystem.Run
    ...    command=${commandToRun}
    ${output3}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'actBbPoolExtensionTddFr1\"?\:true'
    ${output4}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'slowPrbPoolingTddFr1UlAllowed\"?\:true'
    ${output5}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep -E 'scheUePoolingAllowed\"?\:true'
    should not be empty                  ${output1}
    should not be empty                  ${output2}
    should not be empty                  ${output3}
    should not be empty                  ${output4}
    should not be empty                  ${output5}

    [Teardown]
    ...     Teardown the Aasyslog save progress
    ...     ssh.disconnect    connection=BBMOD

Check Ull1Subpool Assignment
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    #fix robocop
    ${syslogFile}=    Set Variable    ${syslogFile}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep CellMappingReq:
    should not be empty                  ${output}

    ${l1spcells}      extract_ull1sp_from_syslog     ${output}
#    Should Not Be Empty     ${l1spcells[1]}
    log to console      ${l1spcells}
    Set Suite Variable      ${l1spcells}
    RETURN        ${l1spcells}

Check Dll1Subpool Assignment
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslogFolder}/${syslogFile} | grep CellMappingReq:
    should not be empty                  ${output}

    ${l1spcells}      extract_dll1sp_from_syslog     ${output}
#    Should Not Be Empty     ${l1spcells[1]}
    log to console      ${l1spcells}
    Set Suite Variable      ${l1spcells}
    RETURN        ${l1spcells}

Check Dll1Subpool Assignment 1 Cell
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslogFolder}/${syslogFile} | grep CellMappingReq:
    should not be empty                  ${output}

    ${l1spnewcell}      extract_dll1sp_from_syslog_one_cell     ${output}
#    Should Not Be Empty     ${l1spcells[1]}
#    log to console      ${l1spnewcell}
    RETURN        ${l1spnewcell[0]}

Check Ull1Subpool Assignment 1 Cell

    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslog_folder}/${syslog} | grep CellMappingReq:
    should not be empty                  ${output}

    ${l1spnewcell}      extract_ull1sp_from_syslog_one_cell     ${output}
#    Should Not Be Empty     ${l1spcells[1]}
#    log to console      ${l1spnewcell}
    RETURN        ${l1spnewcell[0]}

Get longPucchNumPuschPrb
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog
    ...    ${syslogFolder}/${syslogFile}      -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'
    ${longPucchNumPuschPrb}     extract_longPucchNumPuschPrb_from_syslog     ${output}
    RETURN         ${longPucchNumPuschPrb}

Get resourceReq periodicity
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog        ${syslogFolder}/${syslogFile}      BbrmMessageSender::sendResourceReq
    ${periodicity}        ${distribution}     calculate_sfn_periodicity     ${output}
    Log To Console    \n\#SFN Distribution: ${distribution}
    RETURN         ${periodicity}

Get csirs Assignment
    [Arguments]     ${syslog_folder}=/tmp       ${syslog}=SYSLOG.LOG

    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog
    ...    ${syslog_folder}/${syslog}      -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'

    ${csirsGroups}     extract_csirsPoolingGroupId_from_syslog_v2     ${output}
    ${nrCellGroups}     extract_nrCellGrpId_from_syslog     ${output}

    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog
    ...    ${syslog_folder}/${syslog}     -e l2::ps::cell::CellGroupSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellGroupSetupReq:'
    ${trscsirs}     extract_trscsirs_from_syslog     ${output}      ${csirsGroups}      ${nrCellGroups}

    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog
    ...    ${syslog_folder}/${syslog}      -e l2::ps::cell::CellSetupResp_t: -e 'Received from L2PS itf::l2::ps::cell::CellSetupResp:'
    ${cellcsirs}     extract_cellcsirs_from_syslog     ${output}       ${csirsGroups}
    ${uecsirs}      extract_uecsirs_from_syslog     ${output}       ${csirsGroups}

    RETURN        ${csirsGroups}      ${nrCellGroups}     ${trscsirs}     ${cellcsirs}        ${uecsirs}


Check csirs Assignment
    [Arguments]     ${framestructure}

    #fix robocop
    ${framestructure}=    Set Variable    ${framestructure}
    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog
    ...        ${syslog_folder}/${syslog}      -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'

    ${csirsGroups}     extract_csirsPoolingGroupId_from_syslog     ${output}
    ${nrCellGroups}     extract_nrCellGrpId_from_syslog     ${output}

    ${output}              wait until keyword succeeds     300s        10s
    ...           Get filtered message from syslog
    ...         ${syslog_folder}/${syslog}     -e l2::ps::cell::CellGroupSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellGroupSetupReq:'
    ${trscsirs}     extract_trscsirs_from_syslog     ${output}      ${csirsGroups}      ${nrCellGroups}

    ${output}              wait until keyword succeeds     300s        10s
    ...           Get filtered message from syslog
    ...        ${syslog_folder}/${syslog}      -e l2::ps::cell::CellSetupResp_t: -e 'Received from L2PS itf::l2::ps::cell::CellSetupResp:'
    ${cellcsirs}     extract_cellcsirs_from_syslog     ${output}       ${csirsGroups}
    ${uecsirs}      extract_uecsirs_from_syslog     ${output}       ${csirsGroups}
#    Check UEcsirs Assignement      ${uecsirs}      ${framestructure}
#    Check cellcsirs Assignement       ${cellcsirs}      ${framestructure}
#    Check trscsirs Assignement       ${trscsirs}      ${framestructure}

Check csirsPoolingGroupId Assignment
    [Arguments]     ${framestructure}

    #fix robocop
    ${framestructure}=    Set Variable    ${framestructure}
    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog
    ...        ${syslog_folder}/${syslog}      -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'

    ${csirsGroups}     extract_csirsPoolingGroupId_from_syslog     ${output}
    RETURN        ${csirsGroups}

Calculate cellcsirs
    ${framestructure}    ${actCsiMux}      ${csiRsPeriod}    ${actExplicitCsirsPoolSolution}
    ...     ${beamCfg}       ${actBbPool}      ${actBbPoolExt}     ${actInfTddFrameMuting}
    ...     get_csirs_params     ${tl}
    ${csiRsConfig}     createCellCsiRs
    ...     ${framestructure}     ${actCsiMux}   ${actExplicitCsirsPoolSolution}    ${csiRsPeriod}     ${actInfTddFrameMuting}
    RETURN     ${csiRsConfig}

Calculate cellcsirs v2
    ${framestructure}    ${actCsiMux}      ${csiRsPeriod}    ${actExplicitCsirsPoolSolution}
    ...     ${beamCfg}       ${actBbPool}      ${actBbPoolExt}     ${actInfTddFrameMuting}      ${csirsNbWithinReportPeriod}
    ...       ${maxCsiRsNumber}        ${cellsList}
    ...     get_csirs_params_v2     ${tl}
    ${csiRsConfig}     createCellCsiRs_v2
    ...     ${framestructure}     ${actCsiMux}   ${actExplicitCsirsPoolSolution}    ${csiRsPeriod}     ${csirsNbWithinReportPeriod}
    ...     ${maxCsiRsNumber}    ${csirsGroups}    ${cellsList}        ${actTddCsirsAllocOptimization}        ${actInfTddFrameMuting}
    RETURN     ${csiRsConfig}


Calculate trscsirs
    ${framestructure}    ${actCsiMux}      ${csiRsPeriod}    ${actExplicitCsirsPoolSolution}
    ...     ${beamCfg}       ${actBbPool}      ${actBbPoolExt}     ${actInfTddFrameMuting}
    ...     get_csirs_params     ${tl}
    ${trscsiRsConfig}     createTrsCsiRs
    ...     ${framestructure}     ${beamCfg}   ${actBbPool}    ${actBbPoolExt}      ${actExplicitCsirsPoolSolution}
    RETURN     ${trscsiRsConfig}

Get filtered message from syslog
    [Arguments]     ${syslog}       ${texttofilter}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslog} | grep ${texttofilter}
    ${status}  run keyword and return status  should not be empty                  ${output}
    run keyword if  not(${status})  Fail   FAILURE: no data found in SYSLOG

    RETURN        ${output}


Check UEcsirs Assignment
    [Arguments]     ${uecsirs}          ${framestructure}       ${ref_file}=uecsirs.json
    ${json_string}=    Get File   ${CURDIR}/../Resources/${ref_file}
    ${parsed_json}=    Evaluate    json.loads('''${json_string}''')    json
    ${filtered_json}        Evaluate
    ...     [sub['csirsPoolingGroups'] for sub in ${parsed_json} if sub['frameStructure'] == '${framestructure}'][0]
     ${sorted_json}        Evaluate
    ...     sorted(${filtered_json}, key=lambda p: p['csirsPoolingGroupId'])
    Log     ${uecsirs}
    Log    ${sorted_json}
    Lists Should Be Equal     ${uecsirs}        ${sorted_json}



Check cellcsirs Assignment
    [Arguments]        ${syslog_folder}       ${syslog}

    ${csirsGroups}      ${nrCellGroups}     ${trscsirs}     ${cellcsirs}        ${uecsirs}
    ...     Get csirs Assignment        ${syslog_folder}       ${syslog}
    ${cellcsirs_calc}        Calculate cellcsirs
    Lists Should be Equal           ${cellcsirs_calc}       ${cellcsirs}
    RETURN      ${cellcsirs_calc}

Check cellcsirs Assignment v2
    [Arguments]        ${syslog_folder}       ${syslog}

    ${csirsGroups}      ${nrCellGroups}     ${trscsirs}     ${cellcsirs}        ${uecsirs}
    ...     Get csirs Assignment        ${syslog_folder}       ${syslog}
    set Test Variable       ${csirsGroups}
    ${cellcsirs_calc}        Calculate cellcsirs v2
    Lists Should be Equal           ${cellcsirs_calc}       ${cellcsirs}

Check trscsirs Assignment
    [Arguments]        ${syslog_folder}       ${syslog}

    ${csirsGroups}      ${nrCellGroups}     ${trscsirs}      ${cellcsirs}        ${uecsirs}
    ...     Get csirs Assignment        ${syslog_folder}       ${syslog}
    ${trscsirs_calc}        Calculate trscsirs
#    ${trscsirs_equal}      evaluate        ${trscsirs_calc} == ${trscsirs}
    Lists Should be Equal        ${trscsirs_calc}    ${trscsirs}

#Check Value of ${parameter} For ${object} / Useless
Check Value of parameter For object
    ${param_value}      coam.get_parameters_for_all      NRBTS       60      coam_admin
    log to console ${param_value}
    # coam.get_parameters      ${object}       ${parameter}        60      coam_admin
    RETURN        ${param_value}

json delta commissioning coam
    [Documentation]    [PRIVATE]   gnb delta commissioning coam
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]     ${param_list}     ${gnb_id}=0

    BuiltIn.Log To Console    \ndelta commissioning started on gnb_${gnb_id}
    ${update_status}    ${delta_store_file}    Update List of SCF parameters
    ...    parameters=${param_list}
    ...    timeout=600
    ...    alias=coam_admin
    BuiltIn.Log To Console    delta commissioning finished

Setup TTI Traces CB007113
    [Documentation]  :Author: Srihari Janardhan | This keyword detects the type of 5g bts and collects TTI traces
    ...  for a defined period of time.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    ...    :param tti_trace_path:     Directory where TTI Trace is placed     default - Test Case Log directory
    ...    :param tti_trace_filename: Name of tti trace file                  default - ttitrace_streaming.pcap
    ...    :param tti_trace_duration: Length of trace capture in seconds      [1.. ]  default 10
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param cell_distid:        DistName id of the cell                 [List of cell distnames]
    ...    default  All Cells
    ...
    [Arguments]  ${tti_trace_path}=None
    ...  ${tti_trace_duration}=10
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${P_INTERNAL_CELL_DIST_ID}

    #fix robocop
    ${tti_trace_path}=    Set Variable    ${tti_trace_path}
    ${tti_trace_duration}=    Set Variable    ${tti_trace_duration}
    ${du_id}=    Set Variable    ${du_id}
    ${comu_id}=    Set Variable    ${comu_id}
    ${capu_id}=    Set Variable    ${capu_id}
    ${tti_trace_filename}=    Set Variable    ${tti_trace_filename}

    SetFlagOnSwConfig      flag=0x580115      value=${filter_bitmap1}
    SetFlagOnSwConfig      flag=0x580116      value=${filter_bitmap2}

    ${cell_status}=    admin.get_cells_info    cell_type=nr     connection=coam_admin
    ${cell_distid}  create list     ${cell_status[0]['id']['internal']}     ${cell_status[1]['id']['internal']}
    ...     ${cell_status[2]['id']['internal']}
    #${celltest}     create list     ${cell_status[0]['id']['internal']}
    ${bts_type}=  Get gNB type  gnb_id=${gnb_id}
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    ${dest_ip}=  Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    BuiltIn.Log  TTI Traces are forwarded to IP: ${dest_ip}

Collect TTI Traces in Streaming mode CB007113
    [Documentation]  :Author: Srihari Janardhan | This keyword detects the type of 5g bts and collects TTI traces
    ...  for a defined period of time.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    ...    :param tti_trace_path:     Directory where TTI Trace is placed     default - Test Case Log directory
    ...    :param tti_trace_filename: Name of tti trace file                  default - ttitrace_streaming.pcap
    ...    :param tti_trace_duration: Length of trace capture in seconds      [1.. ]  default 10
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param cell_distid:        DistName id of the cell                 [List of cell distnames]
    ...    default  All Cells
    ...
    [Arguments]  ${tti_trace_path}=None
    ...  ${tti_trace_duration}=10
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${P_INTERNAL_CELL_DIST_ID}

    #fix robocop
    ${tti_trace_path}=    Set Variable    ${tti_trace_path}
    ${capu_id}=    Set Variable    ${capu_id}

    SetFlagOnSwConfig      flag=0x580115      value=${filter_bitmap1}
    SetFlagOnSwConfig      flag=0x580116      value=${filter_bitmap2}

    ${cell_status}=    admin.get_cells_info    cell_type=nr     connection=coam_admin
    ${cell_distid}  create list
    FOR     ${icell}        IN      @{cell_status}
        Run Keyword If        '${icell['status']['operationalState']}'=='enabled'    Append To list    ${cell_distid}     ${icell['id']['internal']}
    END
    #${celltest}     create list     ${cell_status[0]['id']['internal']}
    ${bts_type}=  Get gNB type  gnb_id=${gnb_id}
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    ${dest_ip}=  Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    BuiltIn.Log  TTI Traces are forwarded to IP: ${dest_ip}
    ${dir_tti_trace}=  run keyword if  '${tti_trace_path}'=='None'  Get testcase log directory
    ...  ELSE  Set Variable  ${tti_trace_path}
    ${collector}=   Identify TTI Trace Capture Location and start TCPDump
    ...  bts_type=${bts_type}  gnb_id=${gnb_id}  tti_trace_filename=${tti_trace_filename}
    Start Generation of TTI Trace Using TAF Lib  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ...  dest_ip=${dest_ip}  collector=${collector}  cell_dist_id=${cell_distid}  bts_type=${bts_type}
    Sleep  ${tti_trace_duration}s
    Stop Generation of TTI Trace Using TAF Lib  desired_storage_directory=${dir_tti_trace}
    ...    desired_file_name=${tti_trace_filename}      collector=${collector}
    RETURN        ${dir_tti_trace}/${tti_trace_filename}

Activate TTI Traces CB007113
    [Documentation]  :Author: Srihari Janardhan | This keyword detects the type of 5g bts and collects TTI traces
    ...  for a defined period of time.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    ...    :param tti_trace_path:     Directory where TTI Trace is placed     default - Test Case Log directory
    ...    :param tti_trace_filename: Name of tti trace file                  default - ttitrace_streaming.pcap
    ...    :param tti_trace_duration: Length of trace capture in seconds      [1.. ]  default 10
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param cell_distid:        DistName id of the cell                 [List of cell distnames]
    ...    default  All Cells
    ...
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${P_INTERNAL_CELL_DIST_ID}

    #fix robocop
    ${capu_id}=    Set Variable    ${capu_id}

    SetFlagOnSwConfig      flag=0x580115      value=${filter_bitmap1}
    SetFlagOnSwConfig      flag=0x580116      value=${filter_bitmap2}

    ${cell_status}=    admin.get_cells_info    cell_type=nr     connection=coam_admin
    ${cell_distid}  create list     ${cell_status[0]['id']['internal']}     ${cell_status[1]['id']['internal']}
    ...     ${cell_status[2]['id']['internal']}
    #${celltest}     create list     ${cell_status[0]['id']['internal']}
    ${bts_type}=  Get gNB type  gnb_id=${gnb_id}
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    ${dest_ip}=  Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    BuiltIn.Log  TTI Traces are forwarded to IP: ${dest_ip}
    Start Generation of TTI Trace Using TAF Lib  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ...  dest_ip=${dest_ip}  collector=${collector}  cell_dist_id=${cell_distid}  bts_type=${bts_type}
    Sleep  ${tti_trace_duration}s
    Stop Generation of TTI Trace Using TAF Lib  desired_storage_directory=${dir_tti_trace}  desired_file_name=${tti_trace_filename}
    ...  collector=${collector}

Verify that cells are onair with COAM CB007113
    [Documentation]     [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]     ${oam_alias}    ${num_of_cells}

    #fix robocop
    ${oam_alias}=    Set Variable    ${oam_alias}
    run keyword and continue on failure
    ...     coam.connect to     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}       name=coam_admin

    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        ${_internal_cell_dist_id}=  Verify cell setup with COAM    alias=${oam_alias}    cell_id=${cell_id}
        Append to list  ${P_INTERNAL_CELL_DIST_ID}     ${_internal_cell_dist_id}
    END

Verify that certain cells are onair with COAM
    [Documentation]     [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]     ${oam_alias}    ${list_of_cells}
    #fix robocop
    ${oam_alias}=    Set Variable    ${oam_alias}

    ${cellsNumber}       Get Cells Number OAM

    run keyword and continue on failure
    ...     coam.connect to     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}       name=coam_admin
    ${status}     admin.Get Cells Info     cell_type=nr      connection=coam_admin
    FOR    ${item}    IN     @{status}
        Run Keyword If                $item['id']['configuration'] in $list_of_cells
        ...        should be true   '${item['status']['operationalState']}'=='enabled'
    END

Convert TTI trace from pcap to excelCsv CB007113
    [Documentation]
    ...     :Author: Alberto Fernndez
    [Arguments]     ${ttitraceFilename}     ${ttitracepath}=/tmp/       ${csvout}=dlAndUl

    ${CsvFilename}      Remove String Using Regexp     ${ttitraceFilename}     .pcap.?
    ${CommandToExecute}     Catenate         python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py -o
    ...     ${ttitracepath}${CsvFilename}  ${ttitracepath}${ttitraceFilename} legacyCsv
    OperatingSystem.Run     ${CommandToExecute}

    RETURN        ${CsvFilename}.${csvout}.csv

Download Ttitrace Decode Tool
    [Documentation]     Download Ttitrace decode tool and install it.
    ...    Examples:
    ...    | Download Ttitrace Decode Tool |
    ...    | Decoder Tttirace From Pcap To Csv | pcap_path=${pacp} | output_path_with_tag=/tmp/mytag |
    ${SOFTWARE_INFO}        testline.Get gNB SW version
    Set suite variable      ${SOFTWARE_INFO}
    _Download Ttitrace Decode Tool From WFT
    ${decode_tool_in_file_server}    _Download Ttitrace Decode Tool From File Server
    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${decode_tool_in_file_server}
    ${decode_tool}   Run Keyword If    '${status}' != 'True'    _Download Ttitrace Decode Tool From WFT
    ...    ELSE     Set Variable    ${decode_tool_in_file_server}
    OperatingSystem.File Should Exist    ${decode_tool}
    OperatingSystem.Run     sudo dpkg -i ${decode_tool}
    OperatingSystem.Run     rm -rf ${decode_tool}

_Download And Install Ttitrace Decode Tool From WFT
    ${base_url}    Set Variable    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${branches}    Set Variable If    '${sw_list[2]}'=='9999'    SBTS00     '${sw_list[2]}'=='0000'    ${sw_list[0]}
    #${sub_link}    Set Variable If
    #'${sw_list[1]}'=='ENB'    ${SW_VERSION_TOTAL}    '${sw_list[1]}'!='ENB'    ${SOFTWARE_INFO}

    #${sub_link} = ${SOFTWARE_INFO}
    OperatingSystem.Run     sudo wget -P /opt/ -q "${base_url}/${SOFTWARE_INFO}/${SOFTWARE_INFO}_tti-dec.deb"
    OperatingSystem.Run     sudo dpkg -i /opt/SBTS00_ENB_9999_221121_000002_tti-dec.deb
    RETURN    ${TEST_LOG_DIRECTORY()}${sub_link}_tti-dec.deb

_Get Base Download URL Address
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${base_url}=    Set Variable If
    ...     '${sw_list[1]}'=='ENB'    ${FILES_BASE_LINK}    '${sw_list[1]}'!='ENB'    ${FILES_BASE_LINK_BRANCHES}
    Log    ${base_url}
    RETURN    ${base_url}

_Download And Install Ttitrace Decode Tool From File Server
    ${url}=    _Get Base Download URL Address
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    #${sub_link}    Set Variable If
    #...'${sw_list[1]}'=='ENB'    ${SW_VERSION_TOTAL}    '${sw_list[1]}'!='ENB'    ${SOFTWARE_INFO}
    #${sub_link} = ${SOFTWARE_INFO}
    ${DecoderExists}        Run Keyword And Return Status        OperatingSystem.File Should Exist    /opt/${SOFTWARE_INFO}_tti-dec.deb
    Run Keyword If      '${DecoderExists}'=='False'
    ...        OperatingSystem.Run     sudo wget -P /opt/ -q "${url}/${sw_list[0]}/${SOFTWARE_INFO}/${SOFTWARE_INFO}_tti-dec.deb"
    Sleep       5s
    #OperatingSystem.Run     sudo dpkg -i /opt/${SOFTWARE_INFO}_tti-dec.deb
#    Run Keyword If      '${DecoderExists}'=='False'
#    ...            OperatingSystem.Run     sudo apt-get purge -y tti-dec.deb
    Run Keyword If      '${DecoderExists}'=='False'
    ...            OperatingSystem.Run     sudo apt -y -o Acquire::http::proxy=false install /opt/${SOFTWARE_INFO}_tti-dec.deb
   RETURN    /opt/${SOFTWARE_INFO}_tti-dec.deb

Get TTI trace Decoder CB007113
    ${SOFTWARE_INFO}        testline.Get gNB SW version
    Set suite variable      ${SOFTWARE_INFO}
    _Download And Install Ttitrace Decode Tool From File Server

Update mcshark
    ${SOFTWARE_INFO}        testline.Get gNB SW version
    Set suite variable      ${SOFTWARE_INFO}
    Update mcshark Dissector       ${SOFTWARE_INFO}

Convert TTI trace from csv to dict CB007113
    [Arguments]    ${TTITraceCsv}
    ${tti_trace_dict}    read_and_parse_tti_data    ${TTITraceCsv}
    RETURN       ${tti_trace_dict}

Get UL PRB Demand CB007113
    [Arguments]    ${TTITraceDict}
    ${UL_PRB_Demand}    get_ulPrb_Demand    ${TTITraceDict}
    RETURN       ${UL_PRB_Demand}

Get DL PRB Demand CB008940
    [Arguments]    ${TTITraceDict}
    ${DL_PRB_Demand}    get_dlPrb_Demand    ${TTITraceDict}
    RETURN       ${DL_PRB_Demand}

Check ZAB Privilege CB008940

    ${SFN}      Get From Dictionary     ${DL_PRB_Demand}        sfn
    ${SFNToCheck}       Evaluate      str(int(${SFN})+1)
    ${has_ZAB_Alloc}     get_hasZabPrivilege        ${TTI_Convert}          ${SFNToCheck}
    ${has_ZAB_Calcul}     calculate_hasZabPrivilege        ${numMinPrbAllocDl}    ${maxCellPrb['dl']}       ${DL_PRB_Demand}
    ...     ${Assigned_PRB}     ${${maxNumStreamPrbL1Sp}*2}      ${${maxNumWbStreamPrbL1Sp}*2}


    Lists Should Be Equal       ${has_ZAB_Alloc}        ${has_ZAB_Calcul}
   RETURN       ${has_ZAB_Alloc}

Check CB008662
    [Arguments]    ${TTITraceDict}

    #fix robocop
    ${TTITraceDict}=    Set Variable    ${TTITraceDict}
    ${adaptRetxStatus}     get_adaptRetxStatus        ${TTI_Convert}
    List Should Contain Value       ${adaptRetxStatus}      APPLY

   RETURN       ${adaptRetxStatus}

Get numMinPrbAlloc
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    ${output}    wait until keyword succeeds    300s    10s    Get filtered message from syslog    ${syslogFolder}/${syslogFile}
    ...    -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'

    ${numMinPrbAllocDl}   ${numMinPrbAllocUl}    extract_numMinPrbAlloc_from_syslog    ${output}
    RETURN       ${numMinPrbAllocDl}   ${numMinPrbAllocUl}

Get numMinLayerPrbAlloc
    [Arguments]     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}

    ${output}    wait until keyword succeeds    300s    10s    Get filtered message from syslog    ${syslogFolder}/${syslogFile}
    ...    -e l2::ps::cell::CellSetupReq_t: -e 'Sent to L2PS itf::l2::ps::cell::CellSetupReq:'

    ${numMinPrbAllocDl}   ${numMinPrbAllocUl}    extract_numMinLayerPrbAlloc_from_syslog    ${output}
    RETURN       ${numMinPrbAllocDl}   ${numMinPrbAllocUl}


Get numMinPrbAlloc back
    ${output}              wait until keyword succeeds     300s        10s
    ...    Get filtered message from syslog        ${syslog_folder}/${syslog}      NumMinPrbAllocSet
    ${numMinPrbAllocDl}   ${numMinPrbAllocUl}    extract_numMinPrbAlloc_from_syslog_alt    ${output}
    RETURN       ${numMinPrbAllocDl}   ${numMinPrbAllocUl}

Get bbPoolInfos
    [Arguments]     ${syslog_folder}=/tmp       ${syslog}=SysLog_CB010513-SR-B_02_Setup.log
#    ${output}              wait until keyword succeeds     300s        10s
#    ...    Get filtered message from syslog        ${syslog_folder}/${syslog}      l2::ps::cnfg::AddressDistributionReq_t:
    ${output}    Get filtered message from syslog    ${syslog_folder}/${syslog}
    ...    -e l2::ps::cnfg::AddressDistributionReq_t: -e 'Sent to L2PS itf::l2::ps::cnfg::AddressDistributionReq:'

    ${bbPoolInfos}     extract_bbPoolInfos_from_syslog    ${output}
    # Log To Console      ${bbPoolInfos}
    RETURN       ${bbPoolInfos}

Get Assigned PRB CB007113
    [Arguments]    ${TTITraceDict}      ${SFN}
    ${Assigned_PRB}    get_numAllocCellPrbUl    ${TTITraceDict}      ${SFN}
    RETURN       ${Assigned_PRB}

Get Assigned PRB CB008940
    [Arguments]    ${TTITraceDict}      ${SFN}
    ${Assigned_PRB}    get_numAllocCellPrbDl    ${TTITraceDict}      ${SFN}
    RETURN       ${Assigned_PRB}

Get CB007113B PRBs
    [Arguments]     ${MaxSpPRB}     ${streams}
    ...      ${numMinPrbAlloc}       ${maxCellPrb}    ${UL_PRB_Demand}       ${UL_PRB_Demand_Minus6}     ${l1spcells}
    ${Algorithm_PRBs}       Calculate_cb007113_prbs              ${MaxSpPRB}     ${streams}
    ...     ${numMinPrbAlloc}       ${maxCellPrb}    ${UL_PRB_Demand}       ${UL_PRB_Demand_Minus6}     ${l1spcells}
    RETURN        ${Algorithm_PRBs}

Get CB007113C PRBs
    [Arguments]     ${MaxSpPRB}     ${streams}
    ...      ${numMinPrbAlloc}       ${maxCellPrb}    ${UL_PRB_Demand}       ${UL_PRB_Demand_Minus6}     ${l1spcells}
    ${Algorithm_PRBs}       Calculate_cb007113_prbs_new              ${MaxSpPRB}     ${streams}
    ...      ${numMinPrbAlloc}       ${maxCellPrb}    ${UL_PRB_Demand}       ${UL_PRB_Demand_Minus6}     ${l1spcells}
    RETURN        ${Algorithm_PRBs}

Check PRB Assignment CB007113
    [Arguments]    ${TTITraceDict}      ${l1spcells}=${l1spcells}       ${streams}=${streams}    ${MaxSpPRB}=${MaxSpPRB}
    ${UL_PRB_Demand_total}        Get UL PRB Demand CB007113     ${TTITraceDict}
    ${UL_PRB_Demand}        Get from list     ${UL_PRB_Demand_total}        1
    ${UL_PRB_Demand_Minus6}     Get from list     ${UL_PRB_Demand_total}        0
    ${msgToLog}     Catenate
    ...   \nUL PRBs demand Cell 1: GBR: ${UL_PRB_Demand['gbrPrbDemand'][0]}, nonGBR: ${UL_PRB_Demand['nonGbrPrbDemand'][0]}
    ...  , Cell 2: GBR: ${UL_PRB_Demand['gbrPrbDemand'][1]}, nonGBR: ${UL_PRB_Demand['nonGbrPrbDemand'][1]}
    ...  , Cell 3: GBR: ${UL_PRB_Demand['gbrPrbDemand'][2]}, nonGBR: ${UL_PRB_Demand['nonGbrPrbDemand'][2]}
    Log To Console  ${msgToLog}
    ${SFN}      Get From Dictionary     ${UL_PRB_Demand}        sfn
    ${SFNToCheck}       Evaluate      str(int(${SFN})+1 if int(${SFN})<1023 else 0)
    Set Test Variable       ${SFNToCheck}
    ${Assigned_PRB}     Get Assigned PRB CB007113      ${TTITraceDict}       ${SFNToCheck}
    ${Algorithm_PRBs}       run keyword     Get CB007113${CB007113} PRBs    ${MaxSpPRB}      ${streams}
    ...      ${numMinPrbAllocUl}        ${maxCellPrb['ul']}     ${UL_PRB_Demand}     ${UL_PRB_Demand_Minus6}     ${l1spcells}
    # Set Variable If     ${CB007113} == B        ${Algorithm_PRBs[${l1spcells[1][0]}}
    Log To Console  Assigned PRBs: ${Assigned_PRB}
    Log To Console  Algorithm PRBs: ${Algorithm_PRBs}

    FOR     ${index}    IN RANGE       3
        ${Assignment}       Catenate
        ...     ${Algorithm_PRBs[${index}]}-2*${multiplierPRBdl} <= ${Assigned_PRB['numAllocCellPrbUl'][${index}]} <=
        ...     ${Algorithm_PRBs[${index}]}+2*${multiplierPRBdl}
        ...     or ${Assigned_PRB['numAllocCellPrbUl'][${index}]}==0
        ${AssignmentOK}     Evaluate      ${Assignment}
        Should Be True      ${AssignmentOK}
        BuiltIn.log     UL PRBs assigned to CELL ${index}+1: ${Algorithm_PRBs[${index}]}
    END

Check PRB Assignment CB008940
    [Arguments]    ${TTITraceDict}      ${l1spcells}=${l1spcells}      ${streams}=${streams}    ${MaxSpPRB}=${MaxSpPRB}
    ${DL_PRB_Demand_total}        Get DL PRB Demand CB008940     ${TTITraceDict}
    ${DL_PRB_Demand}        Get from list     ${DL_PRB_Demand_total}        1
    ${DL_PRB_Demand_Minus6}     Get from list     ${DL_PRB_Demand_total}        0
    Set Test Variable       ${DL_PRB_Demand}
    ${msgToLog}     Catenate
    ...    \nDL PRBs demand Cell 1: GBR: ${DL_PRB_Demand['gbrPrbDemand'][0]}, nonGBR: ${DL_PRB_Demand['nonGbrPrbDemand'][0]}
    ...  , Cell 2: GBR: ${DL_PRB_Demand['gbrPrbDemand'][1]}, nonGBR: ${DL_PRB_Demand['nonGbrPrbDemand'][1]}
    ...  , Cell 3: GBR: ${DL_PRB_Demand['gbrPrbDemand'][2]}, nonGBR: ${DL_PRB_Demand['nonGbrPrbDemand'][2]}
    Log To Console  ${msgToLog}
    ${SFN}      Get From Dictionary     ${DL_PRB_Demand}        sfn

    ${SFNToCheck}       Evaluate      str(int(${SFN})+1 if int(${SFN})<1023 else 0)
    ${Assigned_PRB}     Get Assigned PRB CB008940      ${TTITraceDict}       ${SFNToCheck}
    ${Algorithm_PRBs}       run keyword     Get CB007113${CB007113} PRBs    ${MaxSpPRB}      ${streams}
    ...      ${numMinPrbAllocDl}        ${maxCellPrb['dl']}     ${DL_PRB_Demand}     ${DL_PRB_Demand_Minus6}     ${l1spcells}
    Set Test Variable       ${Assigned_PRB}
    Set Test Variable       ${Algorithm_PRBs}
    Set Test Variable       ${SFNToCheck}

    # Set Variable If     ${CB007113} == B        ${Algorithm_PRBs[${l1spcells[1][0]}}
    Log To Console  Assigned PRBs: ${Assigned_PRB}
    Log To Console  Algorithm PRBs: ${Algorithm_PRBs}
    FOR     ${index}    IN RANGE       3
        ${Assignment}       Catenate
        ...     ${Algorithm_PRBs[${index}]}-2*${multiplierPRBdl} <= ${Assigned_PRB['numAllocCellPrbDl'][${index}]} <=
        ...     ${Algorithm_PRBs[${index}]}+2*${multiplierPRBdl}
        ...     or ${Assigned_PRB['numAllocCellPrbDl'][${index}]}==0
        ${AssignmentOK}     Evaluate      ${Assignment}
        Should Be True      ${AssignmentOK}
        BuiltIn.log     UL PRBs assigned to CELL ${index}+1: ${Algorithm_PRBs[${index}]}
    END

Check Pdsch Usage Per Slot
    [Arguments]    ${TTI_Convert}      ${SFNToCheck}
    ${SFN_ini}       Evaluate      str(int(${SFNToCheck}) if int(${SFNToCheck})<992 else 0)
    ${pdsch_usage}     get_pdschusage_per_slot      ${TTI_Convert}       ${SFN_ini}
    log to console      ${pdsch_usage}
    RETURN        ${pdsch_usage}

Check Slice Usage
    [Arguments]    ${TTI_Convert}
    ${avg_high}     get_rrmSliceAvgHighShare      ${TTI_Convert}
    ${avg_Low}     get_rrmSliceAvgLowShare      ${TTI_Convert}
    Should Be True      ${${avg_Low[0]['rrmSliceAvgLowShare']}} < ${${avg_Low[1]['rrmSliceAvgLowShare']}}
    Should Be True      (${${avg_Low[0]['rrmSliceAvgLowShare']}} + ${${avg_Low[1]['rrmSliceAvgLowShare']}}) <= 1
    log to console      ${avg_high}
    log to console      ${avg_Low}
    RETURN        ${avg_Low}

Convert TTI trace and Check PRB Assignment CB007113
    [Arguments]    ${TTITracepcap}      ${l1spcells}=${l1spcells}      ${streams}=${streams}    ${MaxSpPRB}=${MaxSpPRB}
    ${TTI_Convert}      Convert TTI trace       ${TTITracepcap}
    Check PRB Assignment CB007113
    ...      ${TTI_Convert}     ${l1spcells}      ${streams}    ${MaxSpPRB}

Convert TTI trace and Check PRB Assignment CB008940
    [Arguments]    ${TTITracepcap}      ${l1spcells}=${l1spcells}      ${streams}=${streams}    ${MaxSpPRB}=${MaxSpPRB}
    ${TTI_Convert}      Convert TTI trace       ${TTITracepcap}
    Check PRB Assignment CB008940
    ...     ${TTI_Convert}     ${l1spcells}      ${streams}    ${MaxSpPRB}

Convert TTI trace and Check CB008662
    [Arguments]    ${TTITracepcap}
    ${TTI_Convert}      Convert TTI trace       ${TTITracepcap}
    Check CB008662   ${TTI_Convert}

Convert TTI trace
    [Arguments]    ${TTITracepcap}
    ${TTIcsv}       Convert TTI trace from pcap to excelCsv CB007113    ${TTITracepcap}
    ${TTI_Convert}      Convert TTI trace from csv to dict CB007113     /tmp/${TTIcsv}
    Set Test Variable    ${TTI_Convert}
    RETURN           ${TTI_Convert}

Setup UEs
    [Arguments]     @{UEs}
    FOR    ${ue_id}    IN     @{UEs}
        ue.require_ue      ue_alias=${alias_${ue_id}}      capabilities=${capabilities_${ue_id}}
    END

Attach UEs
    [Arguments]     @{UEs}
    FOR    ${ue_id}    IN     @{UEs}
        ue.attach_ue       ue_alias=${alias_${ue_id}}
    END

Require UEs
    [Arguments]     @{UEs}
    FOR    ${ue_id}    IN     @{UEs}
        Run keyword and ignore error
        ...     ue.require_ue      ue_alias=${alias_${ue_id}}      capabilities=${capabilities_${ue_id}}
    END

Reboot UEs
    [Arguments]     @{UEs}
    FOR    ${ue_id}    IN     @{UEs}
        Run keyword and ignore error
        ...            ue.reboot ue    ${alias_${ue_id}}    timeout=120
    END

Detach UEs
    [Arguments]     @{UEs}
    FOR    ${ue_id}    IN     @{UEs}
        Run keyword and ignore error
        ...           ue.detach_ue       ue_alias=${alias_${ue_id}}
    END

Update Vendor File
    [Arguments]     ${argumentsList}

    ${vendor_response}     coam.download_vendor_file       target_file_name=/tmp/vendor_lte.xml    connection=coam_admin
    ${vendor_file_parsed}       Parse xml       /tmp/vendor_lte.xml
    FOR     ${item}     IN  @{argumentsList}
            ${vendor_file_parsed}       Add Items To Vendor File        ${vendor_file_parsed}       ${item}
    END

    Save Xml        source=${vendor_file_parsed}         path=/tmp/vendor_lte_modif.xml
    coam.set_vendor_file    vendor_file=/tmp/vendor_lte_modif.xml   connection=coam_admin

Reset Vendor File
    [Arguments]

    ${vendor_response}     coam.download_vendor_file       target_file_name=/tmp/vendor_lte.xml    connection=coam_admin
    coam.set_vendor_file    vendor_file=/tmp/vendor_lte.xml   connection=coam_admin

Add Items To Vendor File
    [Arguments]        ${vendor_file_parsed}      ${item}
    ${VendorParams}    	Get Dictionary Keys 	${item}
#    ${l1PoolType}       Set Variable If     '${bbmod_model}'=='ABIO'        NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
#    ...          '${bbmod_model}'=='ABIQ'        NR_L1Pool_Thor_TDD_FR1_eCPRI
    ${paramsCapa}        Evaluate        [d for d in ${VendorParams} if d not in ['bbHwVariant','direction', 'csSize', 'l1PoolType']]
    FOR     ${param}     IN     @{paramsCapa}
        ${valueparam}     Convert To String     ${item['${param}']}

        ${modifs_xml}       catenate
        ...     .//managedObject[@class='NRBTS']//list[@name="bbL1SpPrbInitCapacity"]//item[
        ...     p[@name="bbHwVariant" and text()="${item['bbHwVariant']}"] and
        ...     p[@name="direction" and text()="${item['direction']}"] and
        ...     p[@name="csSize" and text()="${item['csSize']}"] and
        ...     p[@name="l1PoolType" and text()="${item['l1PoolType']}"]]//p[@name="${param}"]

        ${vendor_file_parsed}       Set Element Text       source=${vendor_file_parsed}
        ...      text=${valueparam}     xpath=${modifs_xml}
   END
    RETURN        ${vendor_file_parsed}

Activate CB007113
    ${actBbPoolTddFr1}      create dictionary
    ...    dist_name    ${dn}
    ...    parameter    actBbPoolTddFr1
    ...    value        true
    ${bbmodBoardConfigType}      create dictionary
    ...    dist_name    MRBTS-511/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter    bbmodBoardConfigType
    ...    value        LTETDD_NRTDD

    ${actNonVoNRGbrService}         Create List
    ${actCsirsMultiplexing}             Create List
    ${actPdschRmCsirsForTracking}       Create List
    ${actPdschAtSsbSlots}               Create List
    ${actGBRAdmissionControl}               Create List

    FOR     ${nrcell}    IN RANGE       1   4

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actNonVoNRGbrService
        ...    value        true
        Append To List      ${actNonVoNRGbrService}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actGBRAdmissionControl
        ...    value        off
        Append To List      ${actGBRAdmissionControl}     ${item}

       ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actPdschRmCsirsForTracking
        ...    value        false
        Append To List      ${actPdschRmCsirsForTracking}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actPdschAtSsbSlots
        ...    value        false
        Append To List      ${actPdschAtSsbSlots}     ${item}
    END

    ${param_list}     Create List
    ...    ${actBbPoolTddFr1}
    ...    ${bbmodBoardConfigType}
    ...    ${actNonVoNRGbrService[0]}    ${actNonVoNRGbrService[1]}    ${actNonVoNRGbrService[2]}
    ...    ${actGBRAdmissionControl[0]}    ${actGBRAdmissionControl[1]}    ${actGBRAdmissionControl[2]}
    ...    ${actPdschRmCsirsForTracking[0]}    ${actPdschRmCsirsForTracking[1]}    ${actPdschRmCsirsForTracking[2]}
    ...    ${actPdschAtSsbSlots[0]}    ${actPdschAtSsbSlots[1]}    ${actPdschAtSsbSlots[2]}
    json delta commissioning coam       ${param_list}

    SetFlagOnSwConfig      flag=0x420068      value=4

Activate CB008940
    ${actBbPoolTddFr1}      create dictionary
    ...    dist_name    ${dn}
    ...    parameter    actBbPoolTddFr1
    ...    value        true
    ${bbmodBoardConfigType}      create dictionary
    ...    dist_name    MRBTS-511/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter    bbmodBoardConfigType
    ...    value        LTETDD_NRTDD

    ${actCsirsMultiplexing}             Create List
    ${actNonVoNRGbrService}             Create List
    ${actPdschRmCsirsForTracking}       Create List
    ${actPdschAtSsbSlots}               Create List
    FOR     ${nrcell}    IN RANGE       1   4

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actCsirsMultiplexing
        ...    value        true
        Append To List      ${actCsirsMultiplexing}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actNonVoNRGbrService
        ...    value        false
        Append To List      ${actNonVoNRGbrService}     ${item}

       ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actPdschRmCsirsForTracking
        ...    value        true
        Append To List      ${actPdschRmCsirsForTracking}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actPdschAtSsbSlots
        ...    value        true
        Append To List      ${actPdschAtSsbSlots}     ${item}
    END

    ${param_list}     Create List
    ...    ${actBbPoolTddFr1}
    ...    ${bbmodBoardConfigType}
    ...    ${actCsirsMultiplexing[0]}    ${actCsirsMultiplexing[1]}    ${actCsirsMultiplexing[2]}
    ...    ${actNonVoNRGbrService[0]}    ${actNonVoNRGbrService[1]}    ${actNonVoNRGbrService[2]}
    ...    ${actPdschRmCsirsForTracking[0]}    ${actPdschRmCsirsForTracking[1]}    ${actPdschRmCsirsForTracking[2]}
    ...    ${actPdschAtSsbSlots[0]}    ${actPdschAtSsbSlots[1]}    ${actPdschAtSsbSlots[2]}
    json delta commissioning coam       ${param_list}

    SetFlagOnSwConfig      flag=0x420068      value=3

Activate CB008662
    ${actBbPoolTddFr1}      create dictionary
    ...    dist_name    ${dn}
    ...    parameter    actBbPoolTddFr1
    ...    value        true
    ${bbmodBoardConfigType}      create dictionary
    ...    dist_name    MRBTS-511/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter    bbmodBoardConfigType
    ...    value        LTETDD_NRTDD

    ${actAdaptiveReTxResMcs}                     Create List
    ${targetPctResourceReservedMcsDl}            Create List
    ${minPctResourceReservedMcsDl}               Create List
    ${targetPctResourceReservedMcsUl}            Create List
    ${minPctResourceReservedMcsUl}               Create List
    FOR     ${nrcell}    IN RANGE       1   4
        ${item}        create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actAdaptiveReTxResMcs
        ...    value        true
        Append To List      ${actAdaptiveReTxResMcs}     ${item}
        ${item}        create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    targetPctResourceReservedMcsDl
        ...    value        75
        Append To List      ${targetPctResourceReservedMcsDl}     ${item}
        ${item}        create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    minPctResourceReservedMcsDl
        ...    value        50
        Append To List      ${minPctResourceReservedMcsDl}     ${item}
        ${item}        create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    targetPctResourceReservedMcsUl
        ...    value        75
        Append To List      ${targetPctResourceReservedMcsUl}     ${item}
        ${item}        create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    minPctResourceReservedMcsUl
        ...    value        50
        Append To List      ${minPctResourceReservedMcsUl}     ${item}
    END

    ${param_list}     Create List
    ...    ${actAdaptiveReTxResMcs[0]}    ${actAdaptiveReTxResMcs[1]}    ${actAdaptiveReTxResMcs[2]}
    ...    ${targetPctResourceReservedMcsDl[0]}    ${targetPctResourceReservedMcsDl[1]}    ${targetPctResourceReservedMcsDl[2]}
    ...    ${minPctResourceReservedMcsDl[0]}    ${minPctResourceReservedMcsDl[1]}    ${minPctResourceReservedMcsDl[2]}
    ...    ${targetPctResourceReservedMcsUl[0]}    ${targetPctResourceReservedMcsUl[1]}    ${targetPctResourceReservedMcsUl[2]}
    ...    ${minPctResourceReservedMcsUl[0]}    ${minPctResourceReservedMcsUl[1]}    ${minPctResourceReservedMcsUl[2]}
    json delta commissioning coam       ${param_list}
    wait until keyword succeeds     1200s        60s
    ...     Verify that cells are onair with COAM CB007113      coam_admin      3

Activate CB010513
    ${conftype}       Set Variable If     '${bbmod_model}'=='ABIO'        LTETDD_NRTDD
    ...          '${bbmod_model}'=='ABIQ'        NRFDD_NRTDD
    ${actBbPoolTddFr1}      create dictionary
    ...    dist_name    ${dn}
    ...    parameter    actBbPoolTddFr1
    ...    value        true
    ${bbmodBoardConfigType}      create dictionary
    ...    dist_name    ${mrbts}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter    bbmodBoardConfigType
    ...    value        ${conftype}
    ${actBbPoolExtensionTddFr1}      create dictionary
    ...    dist_name    ${dn}
    ...    parameter    actBbPoolExtensionTddFr1
    ...    value        true

    ${actCsirsMultiplexing}             Create List
    ${actNonVoNRGbrService}             Create List
    ${actDlMuMimo}                      Create List
    ${actSuperCell}                     Create List

    FOR     ${nrcell}    IN RANGE       1   4

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actCsirsMultiplexing
        ...    value        true
        Append To List      ${actCsirsMultiplexing}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actNonVoNRGbrService
        ...    value        false
        Append To List      ${actNonVoNRGbrService}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actDlMuMimo
        ...    value        false
        Append To List      ${actDlMuMimo}     ${item}

        ${item}      create dictionary
        ...    dist_name    ${dn}/NRCELL-${nrcell}
        ...    parameter    actSuperCell
        ...    value        false
        Append To List      ${actSuperCell}     ${item}


    END

    ${param_list}     Create List
    ...    ${actBbPoolTddFr1}
    ...    ${bbmodBoardConfigType}
    ...    ${actBbPoolExtensionTddFr1}
    ...    ${actCsirsMultiplexing[0]}    ${actCsirsMultiplexing[1]}    ${actCsirsMultiplexing[2]}
    ...    ${actNonVoNRGbrService[0]}    ${actNonVoNRGbrService[1]}    ${actNonVoNRGbrService[2]}
    ...    ${actDlMuMimo[0]}    ${actDlMuMimo[1]}    ${actDlMuMimo[2]}
    ...    ${actSuperCell[0]}    ${actSuperCell[1]}    ${actSuperCell[2]}
  json delta commissioning coam       ${param_list}

Get BBMOD Model
    scf.load_scf    /tmp/scf_orig.xml
    ${prodcodeplanned}     scf.get value from scf
    ...     dist_name=${mrbts}/EQM-1/APEQM-1/CABINET-1/BBMOD-1        p_name=prodCodePlanned
    ${prodcode}     Get Substring       ${prodcodeplanned}      0       6
    ${bbmod}        Set Variable If     '${prodcode}'=='476397'       ABIQ
    ...     '${prodcode}'=='474824'       ABIN
    ...     '${prodcode}'=='475266'       ABIO
    RETURN        ${bbmod}

Get lcrId
    [Arguments]     ${cell}
    scf.load_scf    /tmp/scf_orig.xml
    ${lcrId}     scf.get value from scf
    ...     dist_name=${cell}        p_name=lcrId
    RETURN        ${lcrId}

Get nrCellTypes
    [Arguments]     ${scf}=/tmp/scf_orig.xml
    ${cells}        Get Cells        ${scf}
    ${nrCellTypes}     Create List
    FOR    ${cell}    IN      @{cells}
        ${nrCellType}       scf.get value from scf
        ...     dist_name=${cell}        p_name=nrCellType
        Append To List      ${nrCellTypes}     ${nrCellType}
    END
    RETURN        ${nrCellTypes}

Get RMOD Model
    scf.load_scf    /tmp/scf_orig.xml
    ${prodcodeplanned}     scf.get value from scf
    ...     dist_name=${mrbts}/EQM-1/APEQM-1/RMOD-1        p_name=prodCodePlanned
    ${prodcode}     Get Substring       ${prodcodeplanned}      0       7
    ${bbmod}        Set Variable If     '${prodcode}'=='474876A'       AWHQF
    ...     '${prodcode}'=='475124B'       AEHC
    RETURN        ${bbmod}

Get Cells
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    scf.load_scf    ${scf_ref}
    ${cells}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRCELL
    #${cells_i}     Evaluate     [w.lstrip('${dn}/NRCELL-') for w in ${cells}]
    RETURN        ${cells}

Lock Cells
    [Arguments]     ${cellsToLock}    ${connection}=coam_admin
    ${cells}    Get Cells List OAM
    ${cellsNumber}   Get Length    ${cells}

    FOR        ${icell}        IN         @{cellsToLock}
        Run Keyword And Ignore Error        coam.Block Cell        ${cells[${icell}]}        timeout=180s        connection=${connection}
    END
    ${nonLockedCells}    Create List
    FOR    ${index}    IN RANGE    ${cellsNumber}
        ${currentCell}   Get From List    ${cells}    ${index}
        Run Keyword If    $index not in $cellsToLock    Append To List    ${nonLockedCells}    ${currentCell}
    END

    wait until keyword succeeds     1500s        60s
    ...     Verify that certain cells are onair with COAM      ${connection}      ${nonLockedCells}


Unlock Cells
    [Arguments]     ${cellsToLock}    ${scf_ref}=/tmp/scf_orig.xml        ${connection}=coam_admin
    ${cells}    Get Cells       ${scf_ref}
    FOR        ${icell}        IN         @{cellsToLock}
        coam.Block Cell        ${cells[${icell}]}        connection=${connection}
    END


Get Cells number OAM
    ${allcells}     Get Cells list OAM
    ${cellsNumber}   Get Length    ${allcells}
    RETURN        ${cellsNumber}

Get Cells list OAM
    ${allcellsdetailed}     coam.get_cell_list       connection=coam_admin
    ${allcells}        Evaluate        sorted([x['id']['configuration'] for x in $allcellsdetailed['cells']['nr']])
    RETURN        ${allcells}

Get NRCELLGRPS
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    scf.load_scf    ${scf_ref}
    ${cellgrps}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRCELLGRP
    #${cells_i}     Evaluate     [w.lstrip('${dn}/NRCELL-') for w in ${cells}]
    RETURN        ${cellgrps}

Get LCELNRS
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
    scf.load_scf    ${scf_ref}
    ${lcelnrs}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.mnl:LCELNR
    #${cells_i}     Evaluate     [w.lstrip('${dn}/NRCELL-') for w in ${cells}]
    RETURN        ${lcelnrs}

Get NRPGRPS
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
    scf.load_scf    ${scf_ref}
    ${nrpgrps}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRPGRP
    #${cells_i}     Evaluate     [w.lstrip('${dn}/NRCELL-') for w in ${cells}]
    RETURN        ${nrpgrps}

Get NRRELS
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
    scf.load_scf    ${scf_ref}
    ${nrrels}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRREL
    #${cells_i}     Evaluate     [w.lstrip('${dn}/NRCELL-') for w in ${cells}]
    RETURN        ${nrrels}

Get NRDUS
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
    scf.load_scf    ${scf_ref}
    ${nrdus}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRDU
    #${cells_i}     Evaluate     [w.lstrip('${dn}/NRCELL-') for w in ${cells}]
    RETURN        ${nrdus}

Get Object Id
    [Arguments]     ${object}
    ${object_id}        evaluate            str(${object.split('-')[-1]})
    RETURN        ${object_id}

Get NRCELLIDS
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
    scf.load_scf    ${scf_ref}
    ${nrcellIds}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.mnl:LCELNR
    ${object_id}        evaluate            [d.split('-')[-1] for d in ${nrcellIds}]
    RETURN        ${object_id}

Delete Cell
    [Arguments]     ${cellid}       ${scf_ref}=/tmp/scf_ref.xml
    ${cells}    Get Cells       /tmp/scf_orig.xml
    scf.load_scf    ${scf_ref}
    ${nrcellgrps}    Get NRCELLGRPS     /tmp/scf_orig.xml
    ${lcelnrs}    Get LCELNRS     /tmp/scf_orig.xml
    ${lcrId}    Get lcrId    ${cells[${cellid}]}
    ${lcrId_occurrences}        scf.get_all_values_from_scf      p_name=lcrId
    ${nrrels}       Get NRRELS     ${scf_ref}
    ${nrpgrps}       Get NRPGRPS     ${scf_ref}
    ${nrdus}       Get NRDUS     ${scf_ref}
    coam.create_delta

    FOR     ${nrrel}    IN     @{nrrels}
        ${lcrId_rel}     scf.get value from scf
        ...     dist_name=${nrrel}          p_name=lcrId
        run keyword if      '${lcrId_rel}' == '${lcrId}'
        ...      coam.append_managed_object_to_delta     ${nrrel}     operation=delete
    END
    FOR     ${nrpgrp}    IN     @{nrpgrps}
        ${nrCellId_rel}     scf.get value from scf
        ...     dist_name=${nrpgrp}        list_name=lbpsCellList   p_name=nrCellId
        run keyword if      '${nrCellId_rel}' == '${lcrId}'
        ...      coam.append_managed_object_to_delta     ${nrpgrp}     operation=delete
        run keyword if      '${nrCellId_rel}' == '${lcrId}'
        ...      Switch Off PS Parameters
    END
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_${d}.xml   connection=coam_admin
#    Log To Console      \nSCF saved in /tmp/scf_${d}.xml\n
    coam.append_managed_object_to_delta     ${cells[${cellid}]}     operation=delete
    coam.append_managed_object_to_delta     ${nrcellgrps[${cellid}]}     operation=delete
    coam.append_managed_object_to_delta     ${lcelnrs[${cellid}]}     operation=delete
    ${refgroups}      scf.get_all_values_from_scf_by_pattern      list_name=refNrCellGroup
    ${nrcellgr_id}      Get Object Id     ${nrcellgrps[${cellid}]}
    remove values from list      ${refgroups}      ${nrcellgr_id}
    coam.append_list_items_to_delta     ${nrdus[0]}      refNrCellGroup     @{refgroups}
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True        connection=coam_admin

Switch Off PS Parameters
    ${nrbts}    Get NRBTS Id
    coam.append_parameter_update_to_delta   dist_name=${nrbts}   parameter=actLbpsCtrlLogicEnh   value=false
    coam.append_parameter_update_to_delta   dist_name=${nrbts}   parameter=actNrExtCellSOMethod   value=false
    coam.append_parameter_update_to_delta   dist_name=${nrbts}   parameter=actNrLBPowerSaving   value=false
    coam.append_parameter_update_to_delta   dist_name=${nrbts}   parameter=actNrLBmMimoRTXPowerSaving   value=false
    coam.append_parameter_update_to_delta   dist_name=${nrbts}   parameter=actNrMixedSOMethod   value=false

Delete And check Cells
    [Arguments]     ${cellsToDelete}    ${numofcells}

    #fix robocop
    ${numofcells}=    Set Variable    ${numofcells}
    ${cells}    Get Cells       /tmp/scf_orig.xml
    ${cells_short}    Evaluate    [re.findall(r'\\d+',w)[-1] for w in ${cells}]       re

    FOR   ${cell}    IN     @{cellsToDelete}
        coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref_delete.xml   connection=coam_admin

        Log To Console      \nDeleting cell ${cells_short[${cell}]}...
        wait until keyword succeeds     120s        30s         gnb_log.Start Collecting GNB Btslog
        Delete Cell     ${cell}    /tmp/scf_ref_delete.xml
        ${dll1spcells}       Evaluate       [[w for w in d if w != ${cells_short[${cell}]}] for d in ${dll1spcells}]
        ${ull1spcells}       Evaluate       [[w for w in d if w != ${cells_short[${cell}]}] for d in ${ull1spcells}]
        set global variable       ${dll1spcells}
        set global variable       ${ull1spcells}
        ${remaining_cells}    Get Cells       /tmp/scf_ref_delete.xml
        ${numofremainingcells}    Get Length    ${remaining_cells}
        wait until keyword succeeds     600s        10s
        ...     Verify that cells are onair with COAM CB007113      coam_admin      ${${numofremainingcells}-1}
        Log To Console      Cell ${cells_short[${cell}]} deleted!\n
        coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_after_deletion_${cell}.xml   connection=coam_admin
        OperatingSystem.Run
        ...    command=cp ${syslog_folder}/${syslog} /tmp/SysLog_delete_cell_${cells_short[${cell}]}.log
        sleep       30s
        Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp
    END

Create And Check Cell
    [Arguments]     ${cell}    ${numofcells}    ${delta_scf}
    ${cells}    Get Cells       /tmp/scf_orig.xml
    ${cells_short}    Evaluate    [re.findall(r'\\d+',w)[-1] for w in ${cells}]       re
    Log To Console      \nCreating cell ${cells_short[${cell}]}...
    wait until keyword succeeds     120s        30s         gnb_log.Start Collecting GNB Btslog
    ${Result}       ${outputCommissioning}        Run Keyword and Ignore Error
    ...     coam.Perform delta recommissioning      ${delta_scf}     connection=coam_admin
    Run Keyword If  '${Result}'=='FAIL'
    ...     Wait until keyword succeeds     10x      1s        Correct delta scf and recommission   ${delta_scf}    ${outputCommissioning}
    wait until keyword succeeds     600s        10s
    ...     Verify that cells are onair with COAM CB007113      coam_admin      ${numofcells}
    Log To Console      Cell ${cells_short[${cell}]} created!\n
    log to console      \nCells assigned in Dl after creation:
    ${dll1spnewcell}       Check Dll1Subpool Assignment
    ${dll1spnewtotal}       Evaluate    [list(dict.fromkeys(d)) for d in [sorted(x+y) for x, y in zip(${dll1spcells}, ${dll1spnewcell})]]
    log to console      \nDl Assignment after creation:\n${dll1spnewtotal}\n
    log to console      \nCells assigned in Ul after creation:
#    Log To Console      \nCell ${dll1spnewcell[0]} assigned to dll1Subpool ${dll1spnewcell[1]}\n
    ${ull1spnewcell}       Check Ull1Subpool Assignment
#    log to console      \nAssignment after creation: ${ull1spnewcell}\n
    ${ull1spnewtotal}       Evaluate    [list(dict.fromkeys(d)) for d in [sorted(x+y) for x, y in zip(${ull1spcells}, ${ull1spnewcell})]]
    log to console      \nUl Assignment after creation:\n${ull1spnewtotal}\n
    set global variable     ${dll1spcells}    ${dll1spnewtotal}
    set global variable     ${ull1spcells}    ${ull1spnewtotal}
    OperatingSystem.Run
    ...    command=cp ${syslog_folder}/${syslog} /tmp/SysLog_create_cell_${cells_short[${cell}]}.log
    sleep       30s
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp

Remove RPGRP from Delta scf
    [Arguments]     ${delta_scf}
    ${delta_scf_contents}    get File       ${delta_scf}
    ${json_data}=    Evaluate    json.loads('''${delta_scf_contents}''')    json
    ${json_data_new}    Evaluate    [d for d in ${json_data} if 'NRPGRP' not in d['distName']]

    ${data_to_evaluate}=    catenate    SEPARATOR=${SPACE}
    ...    [d for d in ${json_data_new} if not ('parameters' in d and d['parameters'] and d['parameters'][0]['parameterName'] in
    ...    ['actLbpsCtrlLogicEnh', 'actNrExtCellSOMethod', 'actNrLBPowerSaving', 'actNrLBmMimoRTXPowerSaving', 'actNrMixedSOMethod'])]
    ${json_data_new}    Evaluate    ${data_to_evaluate}
    ${json_string}=    evaluate    json.dumps(${json_data_new})    json
    Create File            ${delta_scf}       ${json_string}


Correct delta scf and recommission
    [Arguments]     ${delta_scf}    ${output}
    ${refNrCellGroupToDel}       Get Regexp Matches       ${output}       refNrCellGroup-(\\d+)       1
    ${refNrCellGroupToAdd}       Get Regexp Matches       ${output}       relationErrors.*?NRCELLGRP-(\\d+)     1
    ${refRrrelToDel}       Get Regexp Matches       ${output}       'distName'.*?'(.*?)'.*?'NRREL should refer to an existing NRCELL'     1
    ${refObjToDel}       Get Regexp Matches       ${output}       Status reached.*?'distName'.*?'(.*?)'.*?'parent object not exists     1
    ${Todel}        Evaluate        len(${refNrCellGroupToDel}) > 0
    ${Toadd}        Evaluate        len(${refNrCellGroupToAdd}) > 0
    ${TodelObj}        Evaluate        len(${refObjToDel}) > 0
    ${delta_scf_contents}    get File       ${delta_scf}
    ${json_data}=    Evaluate    json.loads('''${delta_scf_contents}''')    json

    ${data_to_evaluate}=    catenate    SEPARATOR=${SPACE}
    ...    [d['parameters'][0]['value'] for d in ${json_data}
    ...    if 'parameters' in d and len(d['parameters']) > 0 and d['parameters'][0]['parameterName']=='refNrCellGroup'][0]

    ${refNrCellGroups}    Evaluate    ${data_to_evaluate}
    ${newrefNrCellGroups}      Run Keyword If       ${Todel}
    ...     Remove from List       ${refNrCellGroups}       ${${refNrCellGroupToDel[0]}-1}
    ${newrefNrCellGroups}      Run Keyword If       ${Toadd}
    ...     Append To List       ${refNrCellGroups}       ${refNrCellGroupToAdd[0]}


    ${data_to_evaluate}=    catenate    SEPARATOR=
    ...   [{'distName': d['distName'], 'operation': d['operation'], 'parameters': [{'value': ${refNrCellGroups}, 'parameterName': d['parameters']
    ...   [0]['parameterName'], 'operation': d['parameters'][0]['operation']}]} if 'parameters' in d and len(d['parameters']) > 0 and d['parameters']
    ...   [0]['parameterName']=='refNrCellGroup' else d for d in ${json_data}]

    ${json_data_new}    Run Keyword If      '${Todel}'=='True' or '${Toadd}'=='True'
    ...     Evaluate    ${data_to_evaluate}
    ...     ELSE    Set Variable    ${json_data}
    ${json_data_new} =  Evaluate
    ...    [d for d in ${json_data_new} if d['distName'] not in ${refObjToDel}]
    ${json_data_new} =  Evaluate
    ...    [d for d in ${json_data_new} if d['distName'] not in ${refRrrelToDel}]
#    ${new_json_data}      Evaluate
#        ...     [d['parameters'][0]['value'] for d in ${json_data} if 'parameters' in d and len(d['parameters']) > 0 and d['parameters'][0]
# ['parameterName']=='refNrCellGroup'][0]==${refNrCellGroups}
#    ${new_json_data}       Join        ${json_data}       separator=,
    ${json_string}=    evaluate    json.dumps(${json_data_new})    json
    Create File            ${delta_scf}       ${json_string}
    ${Result}       ${outputCommissioning}      Run Keyword And Ignore Error
    ...     coam.Perform delta recommissioning      ${delta_scf}     connection=coam_admin
    Set Global Variable    ${outputCommissioning}
    Run Keyword If  '${Result}'=='FAIL'     Fail

Get MaxCellPRB
    [Arguments]     ${scf}=/tmp/scf_ref.xml     ${syslogFolder}=${syslog_folder}        ${syslogFile}=${syslog}
    ${bw_list}      Create List     20      30      40      50      60      70      80      90      100
    ${prb_list}     Create List     51      78      106     133     162     189     217     245     273
    ${cells}        Get Cells       ${scf}
    scf.load_scf    ${scf}
    ${maxcellprb}       Create Dictionary
    ${maxcellprb_dl}       Create List
    ${maxcellprb_ul}       Create List
    ${numcells}=    Get Length    ${cells}

    FOR     ${icell}    IN RANGE       ${numcells}
        ${nrcell}       Set Variable        ${cells[${icell}]}
        ${chbw}     scf.get value from scf
        ...     dist_name=${nrcell}        p_name=chBw
        ${chbw_int}     Evaluate        re.search(r'\\d*', '${chbw}').group()     re
        ${mumimodl}     scf.get value from scf
        ...     dist_name=${nrcell}        p_name=actDlMuMimoEnh
        ${mumimoul}     scf.get value from scf
        ...     dist_name=${nrcell}        p_name=actUlMuMimo
        ${multiplierPRBdl}       Set variable if    '${mumimodl}' in ['True', 'true']       ${2}        ${1}
        ${longPucchNumPuschPrb}        Get longPucchNumPuschPrb       ${syslogFolder}      ${syslogFile}
        ${correctionUl}       Set variable if    '${mumimoul}' in ['True', 'true']        ${longPucchNumPuschPrb[${icell}]}        ${0}
        ${list_index}       Get Index From List     ${bw_list}      ${chbw_int}
        ${prbs}     Get From List       ${prb_list}     ${list_index}
        ${maxCellPrb_dl_i}        Evaluate        ${multiplierPRBdl}*int(${prbs})
        ${maxCellPrb_ul_i}        Evaluate        int(${correctionUl})+int(${prbs}) if not ${cb012605} else int(${longPucchNumPuschPrb[${icell}]})
        Log To Console      \nMaxCellPRBs Cell ${nrcell}: DL: ${maxCellPrb_dl_i}, UL: ${maxCellPrb_ul_i}
        Set Suite Variable      ${multiplierPRBdl}
        Append To List      ${maxcellprb_dl}     ${maxcellprb_dl_i}
        Append To List      ${maxcellprb_ul}     ${maxcellprb_ul_i}
    END
    Set To Dictionary       ${maxcellprb}       dl      ${maxcellprb_dl}
    Set To Dictionary       ${maxcellprb}       ul      ${maxcellprb_ul}
    RETURN        ${maxcellprb}

Get BWP_index
    scf.load_scf    /tmp/scf_orig.xml
    ${bwp_index}       Create List
    FOR     ${nrcell}    IN RANGE       1       4
        ${chbw}     scf.get value from scf
        ...     dist_name=${DN}/NRCELL-${nrcell}        p_name=chBw
    ${bwp_i}      Evaluate        int(int($chbw.replace("MHz","").strip())/10-3)
        Append To List      ${bwp_index}     ${bwp_i}
    END
    RETURN        ${bwp_index}

Set Framestructure
    [Arguments]     ${framestructure}       ${scf}=/tmp/scf_orig.xml

    ${all_modifs}       Set Framestructure wo Commissioning       framestructure=${framestructure}     scf=${scf}
    run keyword if      ${all_modifs}!=[]          coam.perform_commissioning	bts_id=0	scf_file=/tmp/scf_modif.xml
    ...     skip_parameter_relation_errors=True	should_activate=True	timeout=600  connection=coam_admin
    run keyword if      ${all_modifs}!=[]      wait until keyword succeeds     1500s        60s
    ...     Verify that cells are onair with COAM CB007113      coam_admin      3

Set Framestructure wo Commissioning
    [Arguments]     ${framestructure}       ${scf}=/tmp/scf_orig.xml
    ${RMOD}     Get RMOD Model
    Set Test Variable       ${RMOD}
    ${maxBeams}     Set Variable If     '${framestructure}'=='5GC001116_3'       8        6
    ${beams}        Set Variable If    '${RMOD}'=='AWHQF'       1        ${maxBeams}
    ${5GC001116_0_fs}      create dictionary
    ...     frameStructureType      tdLte
    ...     guardPeriodLength       4Symbols
    ...     lteToNrFrameShift       0ms
    ...     tdLteUlDlConfig         tdLteConfig2
    ...     ulDlDataSlotRatio       1/4

    ${5GC001116_0_bwp}      set variable       ${dn}/BWP_PROFILE-7
    ${5GC001116_0_prach}           set variable       96
    ${5GC001116_0_beamset}           set variable       beamSet_${beams}
    ${5GC001116_0_beams}           set variable if    '${beams}'=='1'    ${beams} beam          ${beams} beams
    ${5GC001116_3_fs}      create dictionary
    ...     frameStructureType      tdLte
    ...     guardPeriodLength       4Symbols
    ...     lteToNrFrameShift       3ms
    ...     tdLteUlDlConfig         tdLteConfig2
    ...     ulDlDataSlotRatio       1/4

    ${5GC001116_3_bwp}      set variable       ${dn}/BWP_PROFILE-8
    ${5GC001116_3_prach}           set variable     98
    ${5GC001116_3_beamset}           set variable       beamSet_{beams}
    ${5GC001116_3_beams}           set variable if    '${beams}'=='1'    ${beams} beam          ${beams} beams
    ${5GC001208_fs}      create dictionary
    ...     frameStructureType      semiStatic
    ...     guardPeriodLength       2Symbols
    ...     ulDlDataSlotRatio       1/4
    ${5GC001208_bwp}           set variable       ${dn}/BWP_PROFILE-5
    ${5GC001208_prach}           set variable       98
    ${5GC001208_beamset}           set variable       beamSet_${beams}
    ${5GC001208_beams}           set variable if    '${beams}'=='1'    ${beams} beam          ${beams} beams

    ${5GC001070_fs}      create dictionary
    ...     frameStructureType      semiStatic
    ...     guardPeriodLength       2Symbols
    ...     ulDlDataSlotRatio       3/7
    ${5GC001070_bwp}           set variable       ${dn}/BWP_PROFILE-6
    ${5GC001070_prach}           set variable       98
    ${5GC001070_beamset}           set variable       beamSet_${beams}
    ${5GC001070_beams}           set variable if    '${beams}'=='1'    ${beams} beam          ${beams} beams

    @{chbw_i}       Get BWP_index
    ${param_list}     Create List
    FOR     ${nrcell}    IN RANGE       1   4
        ${tddFrameParam}        convert to String      ${${framestructure}_fs}

        ${tddFrameParam}        Replace String      ${tddFrameParam}     '    "
        ${tddFrameStructure}      Set Variable       NRCELL-${nrcell}:tddFrameStructure
        ${cellBwpList}      Set Variable       NRCELL-${nrcell}:cellBwpList

        ${scf_modifs}      create list
        ...     add:${tddFrameStructure}:${tddFrameParam}
        ...     modify:${cellBwpList}:bwpDN=${${framestructure}_bwp}|cellBwpId=0
        ...     modify:${cellBwpList}:bwpDN=${${framestructure}_bwp}${chbw_i[${${nrcell}-1}]}|cellBwpId=1
        ...     modify:NRCELL-${nrcell}:prachConfigurationIndex=${${framestructure}_prach}
        ...     modify:NRCELL-${nrcell}:basicBeamSet=${${framestructure}_beamset}
        ...     modify:NRCELLGRP-${${nrcell}-1}:numberOfTransmittedSsBlocks=${${framestructure}_beams}


        Append To List       ${param_list}     delete:${tddFrameStructure}
        Append To List       ${param_list}     add:${tddFrameStructure}

        Append To List       ${param_list}     @{scf_modifs}
    END

    scf.load_scf    ${scf}
    scf.save_scf        file_path=/tmp/scf_ref.xml

    scf.perform_scf_modification        modification_strings=${param_list}
    scf.save_scf        file_path=/tmp/scf_modif.xml
    scf.calculate_delta_scf     target_scf_path=/tmp/scf_modif.xml      actual_scf_path=/tmp/scf_ref.xml
    ...         delta_scf_path=/tmp/scf_delta.xml
    ${all_modifs}       Get File       /tmp/scf_delta.xml
    RETURN        ${all_modifs}

Set Interfering Framestructure
    [Arguments]     ${framestructure}       ${scf}=/tmp/scf_orig.xml
    ${all_modifs}       Set Interfering Framestructure wo Commissioning       framestructure=${framestructure}     scf=${scf}

    run keyword if      ${all_modifs}!=[]          coam.perform_commissioning	bts_id=0	scf_file=/tmp/scf_modif.xml
    ...     skip_parameter_relation_errors=True	should_activate=True	timeout=300  connection=coam_admin
    run keyword if      ${all_modifs}!=[]      wait until keyword succeeds     900s        60s
    ...     Verify that cells are onair with COAM CB007113      coam_admin      3

Set Interfering Framestructure wo commissioning
    [Arguments]     ${framestructure}      ${scf}=/tmp/scf_orig.xml

    ${5GC001116_0_fs}      create dictionary
    ...     infFrameStructureType      tdLte
    ...     infGuardPeriodLength       4Symbols
    ...     infLteToNrFrameShift       0ms
    ...     infTdLteUlDlConfig         tdLteConfig2
    ...     infUlDlDataSlotRatio       1/4
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true

    ${5GC001116_3_fs}      create dictionary
    ...     infFrameStructureType      tdLte
    ...     infGuardPeriodLength       4Symbols
    ...     infLteToNrFrameShift       3ms
    ...     infTdLteUlDlConfig         tdLteConfig2
    ...     infUlDlDataSlotRatio       1/4
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true

    ${5GC001208_fs}      create dictionary
    ...     infFrameStructureType      semiStatic
    ...     infGuardPeriodLength       2Symbols
    ...     infUlDlDataSlotRatio       1/4
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true


    ${5GC001070_fs}      create dictionary
    ...     infFrameStructureType      semiStatic
    ...     infGuardPeriodLength       2Symbols
    ...     infUlDlDataSlotRatio       3/7
    ...     infScs                     30 KHz
    ...     infTddFrameMutingBiAgreement       true


    @{chbw_i}       Get BWP_index
    ${param_list}     Create List
    scf.load_scf    ${scf}
    scf.save_scf        file_path=/tmp/scf_ref.xml

    FOR     ${nrcell}    IN RANGE       1   4
        ${tddFrameParam}        convert to String      ${${framestructure}_fs}

        ${tddFrameParam}        Replace String      ${tddFrameParam}     '    "
        ${tddFrameStructure}      Set Variable       NRCELL-${nrcell}:infTddFrameStructure

        ${scf_modifs}      create list
        ...     add:${tddFrameStructure}:${tddFrameParam}

        ${infExist}     scf.get_all_values_from_scf     dist_name=${dn}/NRCELL-${nrcell}     list_name=infTddFrameStructure
        Run Keyword if      ${infExist}!=[]       Append To List       ${param_list}     delete:${tddFrameStructure}
        Append To List       ${param_list}     add:${tddFrameStructure}

        Append To List       ${param_list}     @{scf_modifs}
    END


    scf.perform_scf_modification        modification_strings=${param_list}
    scf.save_scf        file_path=/tmp/scf_modif.xml
    scf.calculate_delta_scf     target_scf_path=/tmp/scf_modif.xml      actual_scf_path=/tmp/scf_ref.xml
    ...         delta_scf_path=/tmp/scf_delta.xml
    ${all_modifs}       Get File       /tmp/scf_delta.xml
    RETURN        ${all_modifs}

Create Channels
    [Arguments]     ${direction}=RX     ${channelGroup}=1         ${channels}=[1]       ${scf}=/tmp/scf_orig.xml

    #fix robocop
    ${channelGroup}=    Set Variable    ${channelGroup}
    ${param_list}     Create List
    scf.load_scf    ${scf}
    scf.save_scf        file_path=/tmp/scf_ref.xml
    ${nrbts_version}        scf.get_mo_attribute        ${mrbts}/MNL-1       version
    FOR     ${channel}    IN     @{channels}
        ${channel_txt}      Set Variable    ${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-${channel}
        Append To List      ${param_list}
        ...     add:[com.nokia.srbts.mnl:CHANNEL, ${channel_txt}, ${nrbts_version}, create]
        Append To List      ${param_list}
        ...     add:${channel_txt}:direction=${direction}
        Append To List      ${param_list}
        ...     add:${channel_txt}:resourceDN=${mrbts}/EQM-1/APEQM-1/RMOD-1/PHYANT-1
        ${channel_txt}      Set Variable    ${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-${channel}
        Append To List      ${param_list}
        ...     add:[com.nokia.srbts.mnl:CHANNEL, ${channel_txt}, ${nrbts_version}, create]
        Append To List      ${param_list}
        ...     add:${channel_txt}:direction=${direction}
        Append To List      ${param_list}
        ...     add:${channel_txt}:resourceDN=${mrbts}/EQM-1/APEQM-1/RMOD-2/PHYANT-1
        ${channel_txt}      Set Variable    ${mrbts}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-${channel}
        Append To List      ${param_list}
        ...     add:[com.nokia.srbts.mnl:CHANNEL, ${channel_txt}, ${nrbts_version}, create]
        Append To List      ${param_list}
        ...     add:${channel_txt}:direction=${direction}
        Append To List      ${param_list}
        ...     add:${channel_txt}:resourceDN=${mrbts}/EQM-1/APEQM-1/RMOD-3/PHYANT-1
    END
    FOR     ${nrcell}   IN RANGE        1       4
        Append To List      ${param_list}
        ...     modify:${dn}/NRCELL-${nrcell}:nrCellType=8DL8UL
    END
    scf.perform_scf_modification        modification_strings=${param_list}
    scf.save_scf        file_path=/tmp/scf_modif.xml
    scf.calculate_delta_scf     target_scf_path=/tmp/scf_modif.xml      actual_scf_path=/tmp/scf_ref.xml
    ...         delta_scf_path=/tmp/scf_delta.xml
    ${all_modifs}       Get File       /tmp/scf_delta.xml
    RETURN        ${all_modifs}

Create Object
    [Arguments]     ${objectToCreate}     ${parentObject}       ${index}=1      ${scf}=/tmp/scf_orig.xml
    ${param_list}     Create List
    scf.load_scf             ${scf}
    scf.save_scf        file_path=/tmp/scf_ref.xml
    ${parents}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:${parentObject}
    FOR     ${parent}    IN     @{parents}
        ${nrbts_version}        scf.get_mo_attribute        ${parent}       version
        ${exist}      scf.is_object_in_scf    ${parent}/${objectToCreate}-${index}
        Run Keyword If      '${exist}'=='False'     Append To List      ${param_list}
        ...     add:[om.nokia.srbts.nrbts:${objectToCreate}, ${parent}/${objectToCreate}-${index}, ${nrbts_version}, create]
    END
    scf.perform_scf_modification        modification_strings=${param_list}
    scf.save_scf        file_path=/tmp/scf_modif.xml
    scf.calculate_delta_scf     target_scf_path=/tmp/scf_modif.xml      actual_scf_path=/tmp/scf_ref.xml
    ...         delta_scf_path=/tmp/scf_delta.xml
    ${all_modifs}       Get File       /tmp/scf_delta.xml
    RETURN        ${all_modifs}

Create NRDLMUMIMO
    [Arguments]     ${objectToCreate}=NRDLMUMIMO     ${parentObject}=NRCELL       ${index}=1      ${scf}=/tmp/scf_orig.xml
    ${param_list}     Create List
    scf.load_scf             ${scf}
    scf.save_scf        file_path=/tmp/scf_ref.xml
    ${parents}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:${parentObject}
    FOR     ${parent}    IN     @{parents}
        ${nrbts_version}        scf.get_mo_attribute        ${parent}       version
        ${exist}      scf.is_object_in_scf    ${parent}/${objectToCreate}-${index}
        Run Keyword If      '${exist}'=='False'     Append To List      ${param_list}
        ...     add:[om.nokia.srbts.nrbts:${objectToCreate}, ${parent}/${objectToCreate}-${index}, ${nrbts_version}, create]
        ...     add:${parent}/${objectToCreate}-${index}:actMuAwareTdSch=false
        ...     add:${parent}/${objectToCreate}-${index}:dlMuAwareCorrThd=10
        ...     add:${parent}/${objectToCreate}-${index}:dlMuAwarePrbRatio=100
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMaxNumLayerPerMuRbg=8
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMimoCorrThd=33
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMimoCqiThd=1
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMimoRankAdaption=adaptive
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMimoSpectralEffThd=10
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMimoTaperingH=25dB
        ...     add:${parent}/${objectToCreate}-${index}:dlMuMimoTaperingV=NoTapering
        ...     add:${parent}/${objectToCreate}-${index}:dlMuPairingPrbRatio=100
    END
    scf.perform_scf_modification        modification_strings=${param_list}
    scf.save_scf        file_path=/tmp/scf_modif.xml
    scf.calculate_delta_scf     target_scf_path=/tmp/scf_modif.xml      actual_scf_path=/tmp/scf_ref.xml
    ...         delta_scf_path=/tmp/scf_delta.xml
    ${all_modifs}       Get File       /tmp/scf_delta.xml
    RETURN        ${all_modifs}

Get Last Period And Value For Counter
    [Arguments]     ${counterId}          ${object}


    ${counterlist}     coam.get pm counters     counter_ids=${counterId}       connection=coam_admin        timeout=170s
    ${counterstring}    Convert To String       ${counterlist}
    ${counterlast}         ${counterlastperiod}     ${counterlastvalue}     Should Match Regexp
    ...         ${counterstring}
    ...        ${object}.*?${counterId}'.*?, '([0-9]*)': ([0-9]*)}
#    ${counterlastvalue}     evaluate
#    ...     re.findall(r"${object}.*?${counterId}'.*?, '([0-9]*)': ([0-9]*)}", "${counterstring}"), re
    RETURN         ${counterlastperiod}   ${counterlastvalue}

Get Last Period And Value For Counters
    [Arguments]     ${counterIds}          ${object}

    &{counterlastvaluedict}     Create Dictionary
    FOR     ${counterId}       IN      @{counterIds}
        ${counterlastvalue}     Get Last Period And Value For Counter      ${counterId}          ${object}
        Set To Dictionary      ${counterlastvaluedict}     ${counterId}=${counterlastvalue}
    END

    RETURN        ${counterlastvaluedict}

Get Value For Counters For Next Timestamp
    [Arguments]     ${counterIds}          ${object}        ${timestamp}        ${delta}={1}

    ${MeasPeriodinMin}     Set Variable      ${5}
    ${MeasPeriodinSec}     Evaluate        ${MeasPeriodinMin}*60

#    ${counterlast}     Get Last Period And Value For Counter      ${counterIds[0]}          ${object}
#    ${counterlastperiod}        Get From List        ${counterlast}     0
    ${MeasPeriodToCheck}        Evaluate
    ...     (${timestamp}//${MeasPeriodinSec})*${MeasPeriodinSec}+${MeasPeriodinSec}*${delta}
    Wait Until Keyword Succeeds     15min       3min        Counters Period Equal to
    ...        ${MeasPeriodToCheck}           ${counterIds[0]}          ${object}

    ${counterlastvaluedict}     Get Last Period And Value For Counters          ${counterIds}          ${object}
    RETURN        ${counterlastvaluedict}


Counters Period Equal to
   [Arguments]     ${MeasPeriod}          ${counterId}          ${object}
   ${counterlast}     Get Last Period And Value For Counter      ${counterId}          ${object}
   Should Be Equal As Integers      ${counterlast[0]}       ${MeasPeriod}

Calculate Counters CB008940_I_009
    [Arguments]     ${maxPRB}       ${framestructure}
    ${CounterValues}        Create Dictionary
    ${csirsPeriods}     Evaluate        5*60000/80
    ${DLSlots}     Set Variable If
    ...     '${framestructure}' == '5GC001116_0'     ${98}
    ...     '${framestructure}' == '5GC001116_3'     ${92}
    ...     '${framestructure}' == '5GC001070'        ${98}
    ...     '${framestructure}' == '5GC001208'        ${114}
   ${numSSB}     Set Variable If
    ...     '${framestructure}' == '5GC001116_0'     ${12}
    ...     '${framestructure}' == '5GC001116_3'     ${16}
    ...     '${framestructure}' == '5GC001070'        ${12}
    ...     '${framestructure}' == '5GC001208'        ${12}
   ${numTRS}     Set Variable If
    ...     '${framestructure}' == '5GC001116_0'     ${2}
    ...     '${framestructure}' == '5GC001116_3'     ${4}
    ...     '${framestructure}' == '5GC001070'        ${2}
    ...     '${framestructure}' == '5GC001208'        ${2}
    ${SSBPRB}     Evaluate       ${maxPRB}-${48}
    ${TRSPRB}       Evaluate       ${maxPRB}-${16}

    ${M55308C00001}     Evaluate        ${DLSlots}*${csirsPeriods}
    ${M55308C10005}     Evaluate        (${DLSlots}*${maxPRB}+${numSSB}*${SSBPRB}+${numTRS}*${TRSPRB})*${csirsPeriods}
    Set To Dictionary      ${CounterValues}     M55308C00001=${M55308C00001}        M55308C10005=${M55308C10005}
    RETURN        ${CounterValues}

Set Hytem Attenuations for cell 1
    [Arguments]     ${value}=9350
    Log to console               \nHytem Attenuations for cell 1 started
    vm_handler.connect
    ...      ${tl.test_pc.default_ssh_connection_details.addr}
    ...      ${tl.test_pc.default_ssh_connection_details.username}
    ...      ${tl.test_pc.default_ssh_connection_details.password}
    vm_handler.hytemTelnet323    ${hytem_ip}   10004   4   ${value}
    vm_handler.hytemTelnet323    ${hytem_ip}   10003   3   ${value}
    vm_handler.close
    Log to console               Hytem Attenuations for cell 1 finished

Set Hytem Attenuations for cell 2
    [Arguments]     ${value}=9350
    Log to console               \nHytem Attenuations for gNB 0 cell 0 started
    vm_handler.connect
    ...      ${tl.test_pc.default_ssh_connection_details.addr}
    ...      ${tl.test_pc.default_ssh_connection_details.username}
    ...      ${tl.test_pc.default_ssh_connection_details.password}
    vm_handler.hytemTelnet323    ${hytem_ip}   10005   5   ${value}
    vm_handler.hytemTelnet323    ${hytem_ip}   10006   6   ${value}
    vm_handler.close
    Log to console               Hytem Attenuations for cell 2 finished

Hytem Initialization
    Log to console               \nHytem Attenuators initalization 5G part started
    Set Hytem Attenuations for cell 1   value=0
    Set Hytem Attenuations for cell 2   value=0
    Log to console               Hytem Attenuators initalization 5G part ended

Connect to Askey PC
    [Documentation]   :Author: Jing Liang
    ...     Setup ssh connection to UE control PC
    ...
    ...     :param ue_id: (optional) ue id
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return: alias for ssh connection to Testpc
    ...
    [Arguments]    ${ue_id}=${1}    ${alias}=ssh-ue-pc-${ue_id}
    ssh.Connect to    hostname=${tl.ues[${ue_id}].ue_pc_address}
    ...    username=${tl.ues[${ue_id}].ue_pc_login}
    ...    password=${tl.ues[${ue_id}].ue_pc_password}
    ...    alias=${alias}
    RETURN    ${alias}

#Connect to UE PC
#    [Arguments]    ${ue_id}=${1}    ${alias}=ssh-ue-pc-${ue_id}
#    ssh.Connect to    hostname=${tl.ues[${ue_id}].ue_pc_address}
#    ...    username=${tl.ues[${ue_id}].ssh_connection_details.username}
#    ...    password=${tl.ues[${ue_id}].ssh_connection_details.password}
#    ...    alias=${alias}
#    RETURN    ${alias}

Set ADB ROOT in UE
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb root    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    BuiltIn.Log    ${\n}Askey is ${output}    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Set Airplane Mode Off
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ${ue_infos}        get ue info        ${alias_${ue_id}}
    ${serial}          set variable        ${ue_infos['serial']}
    ssh.Send Command    adb -s ${serial} shell cmd connectivity airplane-mode disable    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    BuiltIn.Log    ${\n}UE is ${output}    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Set Airplane Mode On
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ${ue_infos}        get ue info        ${alias_${ue_id}}
    ${serial}          set variable        ${ue_infos['serial']}
    ssh.Send Command    adb -s ${serial} shell cmd connectivity airplane-mode enable    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    BuiltIn.Log    ${\n}UE is ${output}    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Switch Airplane Mode On Off
   [Arguments]    ${ue_id}=1

    Set Airplane Mode On         ${ue_id}
    Sleep     1s
    Set Airplane Mode Off         ${ue_id}

Set Airplane Mode Off And Enable Data
    [Arguments]    ${ue_id}=1
    ${ue_infos}        get ue info        ${alias_${ue_id}}
    ${serial}          set variable        ${ue_infos['serial']}

    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb -s ${serial} shell cmd phone data enable    connection=${testpc_alias}
    sleep     2s
    ssh.Send Command    adb -s ${serial} shell cmd connectivity airplane-mode enable    connection=${testpc_alias}
    sleep     2s
    ssh.Send Command    adb -s ${serial} shell cmd connectivity airplane-mode disable    connection=${testpc_alias}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Launch UL GBR traffic
    [Arguments]    ${ue}   ${duration}        ${throughput}   ${protocol}   ${packet_size}        ${port}

    #fix robocop
    ${protocol}=    Set Variable    ${protocol}
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue}
    ${cmd}=    Catenate    SEPARATOR=
    ...    adb shell /data/data/com.nokia.android.application/iperf
    ...   -c ${tl.ues[${ue}].data_transfer[0].app_server.bind_interface_ip}
    ...   -u -i 1 -b ${throughput}M -i 1 -l ${Packet_Size} -t ${duration} -p ${port}

    ssh.Send Command    ${cmd}    connection=${testpc_alias}
#    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Kill Python On PC UE
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    taskkill /IM python.exe /F    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Kill ue_proxy On PC UE
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    taskkill /IM run_ue_proxy.exe /F    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Start ue proxy
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    py -m taf.ue.proxy.run_ue_proxy -u android    connection=${testpc_alias}
#    ${output}=    ssh.Read Output    connection=${testpc_alias}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}

Start ue proxy socketIO
    [Arguments]    ${ue_id}=1
    ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    run_ue_proxy --naa_protocol socketio    connection=${testpc_alias}
#    ${output}=    ssh.Read Output    connection=${testpc_alias}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Reset Site and check Cells Are On Air
    [Arguments]     ${connection}=coam_admin
    ${cellsNumber}       Get Cells Number OAM
    coam.reset_site	    connection=${connection}
    wait until keyword succeeds     1500s        60s
    ...     Verify that cells are onair with COAM CB007113      ${connection}      ${cellsNumber}

Reset Site and check l1Subpools

    coam.reset_site	    connection=coam_admin
    wait until keyword succeeds     120s        30s         gnb_log.Start Collecting GNB Btslog
    wait until keyword succeeds     900s        10s           Verify that cells are onair with COAM CB007113      coam_admin      3

#    Check CB010513 Activation
    ${dll1spcells}       Check Dll1Subpool Assignment
    ${ull1spcells}       Check Ull1Subpool Assignment
    ${numMinPrbAllocDl}           ${numMinPrbAllocUl}       Get numMinPrbAlloc

    OperatingSystem.Run
    ...    command=cp ${syslog_folder}/${syslog} /tmp/SysLog_Setup.log
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp/btslog2
    RETURN        ${dll1spcells}       ${ull1spcells}

Collect snapshot coam ext01
    [Documentation]    [PRIVATE]   collect snapshot on classical coam gnb
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0      ${resultBaseDir}=/tmp
    builtIn.Log To Console    \nsnapshot coam started gnb gnb_${gnb_id}
    coam.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    name=gnb

    ${path_SCF}     coam.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot_gnb_${gnb_id}.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=360
    ...    connection=gnb

    coam.teardown    connection=gnb
    BuiltIn.Log To Console    snapshot coam finished for gnb gnb_${gnb_id}

csirs Parameters
    ${framestructure}    ${fsActCsiMux}      ${fsCsiPeriod}        get_csirs_parameters        ${tl}
    RETURN        ${framestructure}    ${fsActCsiMux}      ${fsCsiPeriod}

Get NRBTS Id
    [Arguments]     ${scf_ref}=/tmp/scf_orig.xml
#    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    scf.load_scf    ${scf_ref}
    ${nrbts}     scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRBTS
    RETURN        ${nrbts[0]}

Start Ip Capture
    [Arguments]     ${connection}=coam_admin
    ...     ${measurement_point}=NE_Terminated
    ...     ${uplane_capturing }=false
    run keyword and ignore error     coam.stop_ip_capture_file       connection=${connection}
    ${status}       coam.start_ip_capture_file      connection=${connection}
    ...     measurement_point=${measurement_point}      uplane_capturing=${uplane_capturing}
    RETURN       ${status}

Stop Ip Capture
    [Arguments]     ${connection}=coam_admin
    ${status}       coam.stop_ip_capture_file       connection=${connection}
    RETURN       ${status}

Generate Ip Capture
    [Arguments]     ${connection}=coam_admin
    ${status}       coam.generate_ip_capture_file       connection=${connection}
    RETURN       ${status}

Download Ip Capture
    [Arguments]     ${connection}=coam_admin
    ...     ${target_file_name}=/tmp/ip_trace.gz
    ${status}       coam.download_ip_capture_file       connection=${connection}        target_file_name=${target_file_name}
    RETURN       ${status}

Stop And Download Ip Capture
    [Arguments]     ${connection}=coam_admin
    ...     ${target_file_name}=tmp/ip_trace.gz
    ${status}       Stop Ip Capture
    ${status}       Generate Ip Capture
    ${status}       Download Ip Capture     ${connection}       ${target_file_name}
    RETURN       ${status}

Setup pcap
    [Arguments]     ${file}=/tmp/ip_trace.gz
    ...     ${filter}=s1ap || x2ap || f1ap || e1ap || ngap
    ...     ${alias}=pcap_trace


    pcap.Setup      infile=${file}      display_filter=${filter}        alias=${alias}      tshark_path=/usr/bin/tshark

Get sNSSAI
    [Arguments]     ${alias}=pcap_trace
    ${ST}     pcap.get_field_value
    ...     field_name=ngap.sST
    ...     pcap_parser=${alias}
    RETURN        ${ST}

Get value from pcap
    [Arguments]     ${field}        ${alias}=pcap_trace
    ${field_value}     pcap.get_field_value
    ...     field_name=${field}
    ...     pcap_parser=${alias}
    RETURN        ${field_value}

Start GNB L1L2 BIP Trace Streaming
    [Documentation]        Starts streaming of L1L2 BIP messages on GNB
    ${state}    Get Variable Value    ${SUITE_TAF_collectors.l1l2bip}    DECONFIGURED
    Should Be Equal    ${state}    DECONFIGURED    msg=GNB L1L2 BIP streaming already started
    ${webservice}=  Create Dictionary
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  timeout=250
#    ...  target_file_name=l1l2bip.zip
#    ...  remove_zip_file=${False}
#    ...  specific_message_ids = 0x00000000
    Log to console       Starting GNB L1L2 trace streaming
    l1l2bip.setup_collectors    names=l1l2bip
    l1l2bip.set_suite_alias    l1l2bip
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=CONFIGURED

Start GNB L1L2 BIP Trace Collection
    [Documentation]    Starts capturing L1L2 BIP trace
    ...       L1L2 BIP stream needs to be started on GNB with ``Start L1L2 BIP Trace Streaming``.
    Should Contain Any    ${SUITE_TAF_collectors}[l1l2bip]    CONFIGURED    STOPPED
    ...    msg=GNB L1L2 BIP Trace streaming was not started
    Log to Console    Starting capture of L1L2 BIP Trace
    l1l2bip.start_collectors    names=l1l2bip
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=STARTED

Stop GNB L1L2 BIP Trace Streaming
    [Documentation]    Stops L1L2 BIP Trace streaming on GNB
    Should Not Be Equal    ${SUITE_TAF_collectors}[l1l2bip]    DECONFIGURED
    ...    msg=GNB L1L2 BIP Trace streaming was not started
    Log to Console    Stopping L1L2 Trace streaming
    l1l2bip.teardown_collectors    names=l1l2bip
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=DECONFIGURED

Stop GNB L1L2 BIP Trace Collection
    [Documentation]      Stops gNB L1L2 Traces
    ...       - ``log_dir``: Directory for BIP PCAPs, Default: ``$\{TEST_log_dir\}/Wireshark/``
    [Arguments]    ${log_dir}=/tmp/
    Should Be Equal    ${SUITE_TAF_collectors}[l1l2bip]    STARTED
    ...    msg=GNB L1L2 BIP Trace collection was not started
    Create Directory    ${log_dir}
    Log to console       Stopping capture and collect l1l2 BIP traces
    l1l2bip.stop_collectors        names=l1l2bip
    l1l2bip.collect_collectors     names=l1l2bip     target_dir=${log_dir}
    ${pcap_files}    List Files In Directory    ${log_dir}/l1l2bip      *.pcap      absolute=True
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=STOPPED
    RETURN    ${pcap_files[-1]}

Start L1L2 BIP Trace
    Start GNB L1L2 BIP Trace Streaming
    Start GNB L1L2 BIP Trace Collection

Stop L1L2 BIP Trace
    ${l1l2_pcap}        Stop GNB L1L2 BIP Trace Collection
    Stop GNB L1L2 BIP Trace Streaming
    RETURN    ${l1l2_pcap}

Create Pool Checks File
    [Arguments]    ${dll1spcells}    ${ull1spcells}    ${numMinPrbAllocDl}    ${numMinPrbAllocUl}    ${numMinLayerPrbAllocDl}
    ...    ${numMinLayerPrbAllocUl}    ${maxCellPrb}    ${longPucchNumPuschPrb}    ${syslog_folder}    ${syslog}    ${cellsOnAir}
    ...    ${cellsToLock}=[]    ${scf}=/tmp/scf_orig.xml
    OperatingSystem.Run    command=sudo rm ${syslog_folder}/check_cell_setup.json

    ${checks}        Create List
    ${gnb_cells}            Get Cells       ${scf}
    ${numofcells}  Get Length     ${gnb_cells}
    ${cellSetupInfos}      Create Dictionary
    ${cellTypes}           Get nrCellTypes        ${syslog_folder}/scf_modif.xml
    ${l1spcells}      Create Dictionary        dlL1SpCells     ${dll1spcells}       ulL1SpCells     ${ull1spcells}
    Set To Dictionary        ${cellSetupInfos}      nrCellType     ${cellTypes}

    Set To Dictionary        ${cellSetupInfos}      l1SpCells     ${l1spcells}
    ${bbpoolinfos}       Get bbPoolInfos        ${syslog_folder}       ${syslog}
    Set Test Variable       ${bbpoolinfos}
    Set To Dictionary        ${cellSetupInfos}      bbPoolInformations     ${bbpoolinfos}
#    ${csirsGroups}      ${nrCellGroups}     ${trscsirs}     ${cellcsirs}        ${uecsirs}
#    ...     Get csirs Assignment        ${syslog_folder}       ${syslog}
    ${numMinPrbAlloc}    Create Dictionary      numMinPrbAllocDl    ${numMinPrbAllocDl}    numMinPrbAllocUl    ${numMinPrbAllocUl}
    ${numMinLayerPrbAlloc}  Create Dictionary  numMinLayerPrbAllocDl    ${numMinLayerPrbAllocDl}    numMinLayerPrbAllocUl    ${numMinLayerPrbAllocUl}
    Set To Dictionary        ${cellSetupInfos}      numMinPrbAlloc        ${numMinPrbAlloc}
    Set To Dictionary        ${cellSetupInfos}      numMinLayerPrbAlloc        ${numMinLayerPrbAlloc}
    Set To Dictionary        ${cellSetupInfos}      maxCellPrb      ${maxCellPrb}
    Set To Dictionary        ${cellSetupInfos}      longPucchNumPuschPrb        ${longPucchNumPuschPrb}
    Set To Dictionary        ${cellSetupInfos}      rdMinSecondarSubcellCapacityMargin        ${0.1}
    Set To Dictionary        ${cellSetupInfos}      CellsOnAir        ${cellsOnAir}
    Set To Dictionary        ${cellSetupInfos}      LockedCells        ${cellsToLock}
#    Set To Dictionary        ${cellSetupInfos}      cellcsirs        ${cellcsirs}
#    Set To Dictionary        ${cellSetupInfos}      calculatedCellcsirs        ${cellcsirs_calc}
    ${json_data}        Evaluate    json.dumps(${cellSetupInfos})       json
    Create File    ${syslog_folder}/check_cell_setup.json    ${json_data}

Get From Pool Checks File
    [Arguments]     ${key}     ${pcFile}=${syslog_folder}/check_cell_setup.json

    ${json_string}=    Get File   ${pcFile}
    ${parsed_json}=    Evaluate    json.loads('''${json_string}''')    json
    ${value}        Get From Dictionary    ${parsed_json}       ${key}

    RETURN        ${value}

Rename Files Adding substring
    [Arguments]     ${folder}     ${pattern}    ${substring}       ${excpattern}=${EMPTY}
    ${files}=    List Files In Directory    path=${folder}     pattern=${pattern}*.*
    FOR    ${file}    IN    @{files}
        ${base}=    Evaluate    "${file}".rsplit('.', 1)[0]
        ${ext}=    Evaluate    "${file}".rsplit('.', 1)[1]
        ${exc}        Evaluate    '${excpattern}' not in '${base}'
        Run Keyword if   ${exc}    Move File    ${folder}/${file}    ${folder}/${base}_${substring}.${ext}
    END
