*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage services related to PM counters.
...
...            == Description ==
...            Usage could be divided by 2 main steps:
...             - Collect phasis
...             - Analysis phasis
...
...             *Collect phasis:*.
...             Collect PM files from BTS (PM files are in XML format)
...              - Collect PM files from BTS
...
...             *Analysis phasis:*.
...             From collected PM files, retrieve values for a counter, verify if this value is in a range...
...             - Retrieve Latest Single Counter Value From Pm File
...             - Retrieve Counter Sum of Values From Pm Files For Object
...             - ...

Library           ../python/Counters.py
Resource          ./Tools.robot
Library           String
Library           Collections
Library           DateTime
Library           OperatingSystem
Library           XML
Library           taf.config.testline.info           WITH NAME      testlineInfo
Library           taf.gnb.oam.coam.admin             WITH NAME      coam
Library           taf.transport.ssh                  WITH NAME      ssh
Library           taf.collectors.core                WITH NAME      core
Library           taf.collectors.pmcounters          WITH NAME      pmcounters

*** Variables ***
${pmCollectSubDir}            pm_files

*** Keywords ***

Collect PM files from BTS
    [Documentation]    Collect PM files and return the latest PM file with directory.
    ...
    ...                *Definitions:*
    ...                A counter is defined by
    ...                - Name
    ...                - object associated or supported to this counter DN in PM file
    ...                - id of this object
    ...
    ...                For instance M55308C18002 is supported by a object like this <DN>PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1</DN> (see PM xml file)
    ...
    ...                So the object is NRCELL and the id of this object is 1 (extracted from NRCELL-1)
    ...                If the object is <DN>PLMN-PLMN/MRBTS-1/NRBTS-2</DN>,
    ...                the object is NRBTS and the id of this object is 2 (extracted from NRBTS-2)
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${optional_files}: Optional, for AiC TL only. By default is False, to set to True if needed ONLY to collect xml.gz files
    ...                - ${posProcess}: Optional, for AiC KPI only. By default is False, if True, optional_files has to be set be True also
    ...                - ${node}: Optional, for AiC KPI only. 'vdu' or 'vcu'
    [Arguments]    ${pm_files_path}
    ...            ${optional_files}=${False}
    ...            ${posProcess}=${False}
    ...            ${node}='vdu'
    ${pm_path}                      Run keyword if                  not ${isAic}
    ...                             Collect PM for Classical         ${pm_files_path}
    ...     ELSE                    Collect PM for AiC         ${pm_files_path}       ${optional_files}     ${posProcess}   ${node}
    [Return]    ${pm_path}

## UPDATE_AiC
Collect PM for Classical
    [Documentation]    INTERNAL USAGE
    [Arguments]    ${pm_files_path}
    ${pm_path}    Set variable    ${EMPTY}
    Empty dir if needed       ${pm_files_path}
    ${pm_path}    Extract Latest PM File From BTS    ${pm_files_path}
    Run Keyword If    '${pm_path}' == '${EMPTY}'   Fail		Collect Pm failed
    [Return]    ${pm_path}

Collect PM for AiC
    [Documentation]    INTERNAL USAGE
    [Arguments]    ${pm_files_path}
    ...            ${optional_files}=${False}
    ...            ${posProcess}=${False}
    ...             ${node}='vdu'
    ${pm_path}                      Run keyword if                  '${optional_files}'=='${True}'
    ...                             Perform Collect PM for AiC         ${pm_files_path}     ${posProcess}    ${node}
    ${pm_files_path}                Run Keyword If                  '${optional_files}'=='${True}' and '${posProcess}'=='${True}'
    ...                             Set Variable           ${pm_path}
    [Return]    ${pm_files_path}

Perform Collect PM for AiC
    [Documentation]    INTERNAL USAGE
    [Arguments]    ${pm_files_path}      ${posProcess}=${False}    ${node}='vdu'
    ##  ERROR CASE
    Run Keyword If              ${node} != 'vdu' and ${node} != 'vcu'
    ...                         Run Keywords
    ...                         Dated log       ERROR: value error in node=${node}
    ...     AND                 Return From Keyword
    ###### DU
    ${loc_namespace_vdu}                Set Variable        ${GNB_DU.mainNode.k8s.namespace}
    ${loc_pm_pod_name}                  Set Variable        oampm-0
    ${loc_pm_pod_pref}                  Retrieve PM pods    ${GNB_DU}    ute-${loc_pm_pod_name}
    ${loc_pm_container_name}            Set Variable        pmdataserver
    ${loc_pm_container_pref}            Set Variable        ctr
    ${pm_dir}                           Set Variable        /mnt/services/SS_OAM/PMSTAT/pm_result_files/
    ${du_pm_tmp}                        Set Variable        /mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpdu
    ${du_pm_tmp_dir}                    Set Variable        /mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpdu/.
    ${loc_pod_pm_complete_vdu}          Set Variable        ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vdu}    Set Variable    ${loc_pm_container_pref}-${loc_pm_container_name}
    ## STEP 1
    ${cmd}                          Set Variable         bash -c 'mkdir ${du_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 2
    # ${cmd}                          Set Variable         bash -c 'cp ${pm_dir}A20220509.0445+0000-20220509.0500+0000*gz ${du_pm_tmp}'
    ${cmd}                          Set Variable         bash -c 'cp ${pm_dir}A*gz ${du_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 3
    ${vDUPMPath}                          Set Variable            /var/home/core/tmp3
    ${cmdp1}                          Set Variable        kubectl cp -n ${loc_namespace_vdu} -c ${loc_container_pm_complete_vdu}
    ${cmdp2}                          Set Variable        ${loc_pod_pm_complete_vdu}:${du_pm_tmp_dir} ${vDUPMPath}
    ${cmd1}                          Set Variable        ${cmdp1} ${cmdp2}
    ${du_user}                        Set Variable            ${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.username}
    ${du_pas}                         Set Variable            ${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.password}
    ${du_ip}                          Set Variable            ${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    Run                             sshpass -p ${du_pas} ssh ${du_user}@${du_ip} "${cmd1}"
    ## STEP 4
    ${vDUFiles}                      Set Variable            ${vDUPMPath}/*.gz
    # ${vDUPMPathLocal}                Set Variable            vDU_PM
    ${timestamp}=                   DateTime.Get Current Date               result_format=%Y%m%d-%H%M%S
    Set suite variable              ${vDUPMPathLocal}           vDU_PM_${timestamp}
    ${vDUPMFullPathLocal}            Set Variable            ${pm_files_path}/${vDUPMPathLocal}
    Empty dir if needed             ${vDUPMFullPathLocal}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${pm_files_path}
    Run Keyword If                  ${result}==True        Create Directory      ${pm_files_path}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${vDUPMFullPathLocal}
    Run Keyword If                  ${result}==True        Create Directory      ${vDUPMFullPathLocal}
    ${cp_cmd}                        Set Variable            sshpass -p ${du_pas} scp ${du_user}@${du_ip}:${vDUFiles} ${vDUPMFullPathLocal}
    Run                             sshpass -p ${du_pas} scp ${du_user}@${du_ip}:${vDUFiles} ${vDUPMFullPathLocal}
    # STEP 5
    ${cmd}                          Set Variable         bash -c 'rm -r ${du_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## Cleanup vDU (/var/home/core/tmp3)
    ${rm_cmd}                        Set Variable            sshpass -p ${du_pas} ssh ${du_user}@${du_ip} rm -f ${vDUPMPath}/*
    Run                              ${rm_cmd}
    ###### CU
    ${loc_namespace_vcu}                Set Variable    ${GNB_CU.mainNode.k8s.namespace}
    ${cu_pm_tmp}                        Set Variable    /mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpcu
    ${cu_pm_tmp_dir}                    Set Variable    /mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpcu/.
    ${loc_pm_pod_pref}                  Retrieve PM pods    ${GNB_CU}    ute-${loc_pm_pod_name}
    ${loc_pod_pm_complete_vcu}          Set Variable    ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vcu}    Set Variable    ${loc_pm_container_pref}-${loc_pm_container_name}
    ${cmd}                              Set Variable         bash -c 'mkdir ${cu_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 2
    ${cmd}                          Set Variable         bash -c 'cp ${pm_dir}A*gz ${cu_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 3
    ${vCUPMPath}                      Set Variable            /var/home/core/tmp3
    ${cmdp1}                          Set Variable        kubectl cp -n ${loc_namespace_vcu} -c ${loc_container_pm_complete_vcu}
    ${cmdp2}                          Set Variable        ${loc_pod_pm_complete_vcu}:${cu_pm_tmp_dir} ${vCUPMPath}
    ${cmd1}                           Set Variable        ${cmdp1} ${cmdp2}
    ${cu_user}                        Set Variable            ${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.username}
    ${cu_pas}                         Set Variable            ${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.password}
    ${cu_ip}                          Set Variable            ${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    Run                             sshpass -p ${cu_pas} ssh ${cu_user}@${cu_ip} "${cmd1}"
    ## STEP 4
    ${vCUFiles}                      Set Variable            ${vCUPMPath}/*.gz
    # ${vCUPMPathLocal}                Set Variable            vCU_PM
    ${timestamp}=                   DateTime.Get Current Date               result_format=%Y%m%d-%H%M%S
    Set suite variable              ${vCUPMPathLocal}           vCU_PM_${timestamp}
    ${vCUPMFullPathLocal}            Set Variable            ${pm_files_path}/${vCUPMPathLocal}
    Empty dir if needed             ${vCUPMFullPathLocal}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${pm_files_path}
    Run Keyword If                  ${result}==True        Create Directory      ${pm_files_path}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${vCUPMFullPathLocal}
    Run Keyword If                  ${result}==True        Create Directory      ${vCUPMFullPathLocal}
    ${cp_cmd}                        Set Variable            sshpass -p ${cu_pas} scp ${cu_user}@${cu_ip}:${vCUFiles} ${vCUPMFullPathLocal}
    Run                             sshpass -p ${cu_pas} scp ${cu_user}@${cu_ip}:${vCUFiles} ${vCUPMFullPathLocal}
    # STEP 5
    ${cmd}                          Set Variable         bash -c 'rm -r ${cu_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## Cleanup vCU (/var/home/core/tmp3)
    ${rm_cmd}                        Set Variable            sshpass -p ${cu_pas} ssh ${cu_user}@${cu_ip} rm -f ${vCUPMPath}/*
    Run                              ${rm_cmd}
    # ${pm_files_path_res}            Set Variable            ${pm_files_path}/${vCUPMPathLocal}
    ## case for pos process
    ${pm_files_path_res_vdu}                      Run Keyword If                  '${posProcess}' == '${True}' and ${node} == 'vdu'
    ...                             Perform PosProcess PM Aic Files vDU      ${pm_files_path}    ${posProcess}
    ${pm_files_path_res_vcu}                      Run Keyword If                  '${posProcess}' == '${True}' and ${node} == 'vcu'
    ...                             Perform PosProcess PM Aic Files vCU      ${pm_files_path}    ${posProcess}
    ${pm_files_path_res}                      Run Keyword If                  ${node} == 'vcu'
    ...                             Set Variable    ${pm_files_path_res_vcu}
    ...                 ELSE        Set Variable    ${pm_files_path_res_vdu}
    ## CleanUp after pos process if it's needed
    ## for debug, comment these lines
    ${pm_vdu_loc_dir}               Set Variable             ${pm_files_path}/${vDUPMPathLocal}
    ${cmd}               Set Variable            cd ${pm_vdu_loc_dir} && if ls A*.gz 1\> /dev/null 2>&1; then rm A*.gz ; fi
    ${output}    OperatingSystem.Run     ${cmd}
    ${pm_vcu_loc_dir}               Set Variable             ${pm_files_path}/${vCUPMPathLocal}
    ${cmd}               Set Variable            cd ${pm_vcu_loc_dir} && if ls A*.gz 1\> /dev/null 2>&1; then rm A*.gz ; fi
    ${output}    OperatingSystem.Run     ${cmd}
    ## FINAL REMOVE
    Run Keyword If     ${node} == 'vcu'      Remove Useless Directory     ${pm_vdu_loc_dir}
    ...                ELSE                  Remove Useless Directory     ${pm_vcu_loc_dir}
    [Return]    ${pm_files_path_res}

Remove Useless Directory
    [Documentation]    INTERNAL USAGE
    [Arguments]    ${p_path}
    ${cmd}               Set Variable            rmdir ${p_path}
    ${output}    OperatingSystem.Run     ${cmd}

Perform Collect PM for AiC With Path
    [Documentation]    Collect PM for AiC on vDU and vCU for Debug purpose
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${optional_files}: Optional, for AiC TL only. By default is False, to set to True if needed ONLY to collect xml.gz files
    ...                - ${posProcess}: Optional, for AiC KPI only. By default is False, if True, optional_files has to be set be True also
    ...                *Return:*
    ...                - ${path_list}: list of directories, one for vDU and one for vCU
    [Arguments]    ${pm_files_path}      ${optional_files}=${False}         ${posProcess}=${False}
    ${pm_path_vdu}      Perform Collect PM for AiC vDU    ${pm_files_path}      optional_files=${True}       posProcess=${posProcess}
    ${pm_path_cu}       Perform Collect PM for AiC vCU    ${pm_files_path}      optional_files=${True}       posProcess=${posProcess}
    @{path_list}        create list      ${pm_path_vdu}      ${pm_path_cu}
    [Return]    ${path_list}

Perform Collect PM for AiC vDU
    [Documentation]    Collect PM for AiC vDU for Debug purpose
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${optional_files}: Optional, for AiC TL only. By default is False, to set to True if needed ONLY to collect xml.gz files
    ...                - ${posProcess}: Optional, for AiC KPI only. By default is False, if True, optional_files has to be set be True also
    ...                *Return:*
    ...                - ${dir_or_file_to_ret}: directory when optional_files is True and PM.xml file if posProcess is True
    [Arguments]    ${pm_files_path}      ${optional_files}=${False}         ${posProcess}=${False}
    ###### DU
    ${loc_namespace_vdu}    Set Variable        ${GNB_DU.mainNode.k8s.namespace}
    ${loc_pm_pod_name}      Set Variable    	oampm-0
    ${loc_pm_pod_pref}            Retrieve PM pods     ${GNB_DU}     ute-${loc_pm_pod_name}
    ${loc_pm_container_name}    Set Variable    		pmdataserver
    ${loc_pm_container_pref}    Set Variable    		ctr
    ${pm_dir}    Set Variable    		/mnt/services/SS_OAM/PMSTAT/pm_result_files/
    ${du_pm_tmp}    Set Variable    	/mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpdu
    ${du_pm_tmp_dir}    Set Variable    	/mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpdu/.
    ${loc_pod_pm_complete_vdu}  Set Variable    		    ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vdu}   Set Variable   		${loc_pm_container_pref}-${loc_pm_container_name}
    ## STEP 1
    ${cmd}                          Set Variable         bash -c 'mkdir ${du_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 2
    # ${cmd}                          Set Variable         bash -c 'cp ${pm_dir}A20220509.0445+0000-20220509.0500+0000*gz ${du_pm_tmp}'
    ${cmd}                          Set Variable         bash -c 'cp ${pm_dir}A*gz ${du_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 3
    ${vDUPMPath}                          Set Variable            /var/home/core/tmp3
    ${cmdp1}                          Set Variable        kubectl cp -n ${loc_namespace_vdu} -c ${loc_container_pm_complete_vdu}
    ${cmdp2}                          Set Variable        ${loc_pod_pm_complete_vdu}:${du_pm_tmp_dir} ${vDUPMPath}
    ${cmd1}                          Set Variable        ${cmdp1} ${cmdp2}
    ${du_user}                        Set Variable            ${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.username}
    ${du_pas}                         Set Variable            ${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.password}
    ${du_ip}                          Set Variable            ${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    Run                             sshpass -p ${du_pas} ssh ${du_user}@${du_ip} "${cmd1}"
    ## STEP 4
    ${vDUFiles}                      Set Variable            ${vDUPMPath}/*.gz
    # ${vDUPMPathLocal}                Set Variable            vDU_PM
    ${timestamp}=                   DateTime.Get Current Date               result_format=%Y%m%d-%H%M%S
    Set suite variable              ${vDUPMPathLocal}           vDU_PM_${timestamp}
    ${vDUPMFullPathLocal}            Set Variable            ${pm_files_path}/${vDUPMPathLocal}
    Empty dir if needed             ${vDUPMFullPathLocal}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${pm_files_path}
    Run Keyword If                  ${result}==True        Create Directory      ${pm_files_path}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${vDUPMFullPathLocal}
    Run Keyword If                  ${result}==True        Create Directory      ${vDUPMFullPathLocal}
    ${cp_cmd}                        Set Variable            sshpass -p ${du_pas} scp ${du_user}@${du_ip}:${vDUFiles} ${vDUPMFullPathLocal}
    Run                             sshpass -p ${du_pas} scp ${du_user}@${du_ip}:${vDUFiles} ${vDUPMFullPathLocal}
    # STEP 5
    ${cmd}                          Set Variable         bash -c 'rm -r ${du_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## Cleanup vDU (/var/home/core/tmp3)
    ${rm_cmd}                        Set Variable            sshpass -p ${du_pas} ssh ${du_user}@${du_ip} rm -f ${vDUPMPath}/*
    Run                              ${rm_cmd}
    ${pm_files_res}            Set Variable            ${pm_files_path}/${vDUPMPathLocal}
    ## case for pos process
    ${pm_last}                      Run Keyword If                  '${posProcess}'=='${True}'
    ...                             PosProcess PM Aic Files vDU      ${pm_files_path}
    ${dir_or_file_to_ret}                Run Keyword If                  '${posProcess}'=='${True}'
    ...                             Set Variable           ${pm_last}
    ...                             ELSE
    ...                             Set Variable           ${pm_files_res}
    [Return]    ${dir_or_file_to_ret}

Perform PosProcess PM Aic Files vDU
    [Arguments]    ${pm_files_path}      ${posProcess}=${False}    ${usePython}=${True}
    ${pm_last}                      Run Keyword If                  '${posProcess}'=='${True}'
    ...                             PosProcess PM Aic Files vDU      ${pm_files_path}    ${usePython}
    ${pm_files_path}                Run Keyword If                  '${posProcess}'=='${True}'
    ...                             Set Variable           ${pm_last}
    [Return]    ${pm_files_path}

Perform PosProcess PM Aic Files vCU
    [Arguments]    ${pm_files_path}      ${posProcess}=${False}    ${usePython}=${True}
    ${pm_last}                      Run Keyword If                  '${posProcess}'=='${True}'
    ...                             PosProcess PM Aic Files vCU      ${pm_files_path}    ${usePython}
    ${pm_files_path}                Run Keyword If                  '${posProcess}'=='${True}'
    ...                             Set Variable           ${pm_last}
    [Return]    ${pm_files_path}

Perform Collect PM for AiC vCU
    [Documentation]    Collect PM for AiC vCU for Debug purpose
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${optional_files}: Optional, for AiC TL only. By default is False, to set to True if needed ONLY to collect xml.gz files
    ...                - ${posProcess}: Optional, for AiC KPI only. By default is False, if True, optional_files has to be set be True also
    ...                *Return:*
    ...                - ${pm_files_path_res}: directory
    [Arguments]    ${pm_files_path}      ${optional_files}=${False}         ${posProcess}=${False}
    ### COMMON
    ${loc_pm_pod_name}      Set Variable    	oampm-0
    ${loc_pm_pod_pref}            Retrieve PM pods     ${GNB_DU}     ute-${loc_pm_pod_name}
    ${loc_pm_container_name}    Set Variable    		pmdataserver
    ${loc_pm_container_pref}    Set Variable    		ctr
    ${pm_dir}    Set Variable    		/mnt/services/SS_OAM/PMSTAT/pm_result_files/
    ###### CU
    ${loc_namespace_vcu}    Set Variable        ${GNB_CU.mainNode.k8s.namespace}
    ${cu_pm_tmp}    Set Variable    	/mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpcu
    ${cu_pm_tmp_dir}    Set Variable    	/mnt/services/SS_OAM/PMSTAT/pm_result_files/tmpcu/.
    ${loc_pm_pod_pref}            Retrieve PM pods     ${GNB_CU}     ute-${loc_pm_pod_name}
    ${loc_pod_pm_complete_vcu}  Set Variable    		    ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vcu}   Set Variable   		${loc_pm_container_pref}-${loc_pm_container_name}
    ${cmd}                          Set Variable         bash -c 'mkdir ${cu_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 2
    ${cmd}                          Set Variable         bash -c 'cp ${pm_dir}A*gz ${cu_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## STEP 3
    ${vCUPMPath}                          Set Variable            /var/home/core/tmp3
    ${cmdp1}                          Set Variable        kubectl cp -n ${loc_namespace_vcu} -c ${loc_container_pm_complete_vcu}
    ${cmdp2}                          Set Variable        ${loc_pod_pm_complete_vcu}:${cu_pm_tmp_dir} ${vCUPMPath}
    ${cmd1}                          Set Variable        ${cmdp1} ${cmdp2}
    ${cu_user}                        Set Variable            ${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.username}
    ${cu_pas}                         Set Variable            ${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.password}
    ${cu_ip}                          Set Variable            ${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    Run                             sshpass -p ${cu_pas} ssh ${cu_user}@${cu_ip} "${cmd1}"
    ## STEP 4
    ${vCUFiles}                      Set Variable            ${vCUPMPath}/*.gz
    # ${vCUPMPathLocal}                Set Variable            vCU_PM
    ${timestamp}=                   DateTime.Get Current Date               result_format=%Y%m%d-%H%M%S
    Set suite variable              ${vCUPMPathLocal}           vCU_PM_${timestamp}
    ${vCUPMFullPathLocal}            Set Variable            ${pm_files_path}/${vCUPMPathLocal}
    Empty dir if needed             ${vCUPMFullPathLocal}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${pm_files_path}
    Run Keyword If                  ${result}==True        Create Directory      ${pm_files_path}
    ${result}=       Run Keyword And Return Status    Directory Should Not Exist    ${vCUPMFullPathLocal}
    Run Keyword If                  ${result}==True        Create Directory      ${vCUPMFullPathLocal}
    ${cp_cmd}                        Set Variable            sshpass -p ${cu_pas} scp ${cu_user}@${cu_ip}:${vCUFiles} ${vCUPMFullPathLocal}
    Run                             sshpass -p ${cu_pas} scp ${cu_user}@${cu_ip}:${vCUFiles} ${vCUPMFullPathLocal}
    # STEP 5
    ${cmd}                          Set Variable         bash -c 'rm -r ${cu_pm_tmp}'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ## Cleanup vCU (/var/home/core/tmp3)
    ${rm_cmd}                        Set Variable            sshpass -p ${cu_pas} ssh ${cu_user}@${cu_ip} rm -f ${vCUPMPath}/*
    Run                              ${rm_cmd}
    ${pm_files_path_res}            Set Variable            ${pm_files_path}/${vCUPMPathLocal}
    ## case for pos process to add if needed
    [Return]    ${pm_files_path_res}

## UPDATE_AiC
Set Global Environment
    [Documentation]    INTERNAL USAGE
    Set suite variable    ${glo_mrbts_id_vdu}		${MRBTS_ID_DU}
    Set suite variable    ${glo_nrbts_id_vdu}		${NRBTS_ID_DU}
    Set suite variable    ${glo_mrbts_id_vcu}		${MRBTS_ID_CU}
    Set suite variable    ${glo_nrbts_id_vcu}		${NRBTS_ID_CU}

## UPDATE_AiC_OAM
Retrieve Latest Single Counter Value From Pm Files For Object and Id on vDU
    [Arguments]    &{expected_dict}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Set Global Environment
    ${dimension_dn}=    set variable    MRBTS-${glo_mrbts_id_vdu}/NRBTS-${glo_nrbts_id_vdu}/${object_name}-${object_id}
    Dated log                       \ndimension_dn=${dimension_dn}
    ${res}      Call method    ${GNB_DU.oam}    get_counter    counter_id=${counter_name}
    ...                           dimension_dn=${dimension_dn}
    Dated log                       res=${res}
    # ERROR CASE
    Run Keyword If                  '${res}'=='EMPTY'                            Fail      KW: No value found for ${counter_name}
    Set PM Audit Dict    ${counterName}     ${res}
    [Return]    ${res}

## UPDATE_AiC_OAM
Retrieve Latest Single Counter Value From Pm Files For Object and Id on vCU
    [Arguments]    &{expected_dict}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Set Global Environment
    ${dimension_dn}                       BuiltIn.Run Keyword if               '${object_name}' == 'NRBTS'
    ...                             set variable         MRBTS-${glo_mrbts_id_vcu}/NRBTS-${glo_nrbts_id_vcu}
    ...     ELSE                    set variable         MRBTS-${glo_mrbts_id_vcu}/NRBTS-${glo_nrbts_id_vcu}/${object_name}-${object_id}
    Dated log                       \ndimension_dn=${dimension_dn}
    ${res}      Call method    ${GNB_CU.oam}    get_counter_c2    counter_id=${counter_name}
    ...                           dimension_dn=${dimension_dn}
    Dated log                       res=${res}
    Set PM Audit Dict    ${counterName}     ${res}
    [Return]    ${res}

## UPDATE_AiC_OAM
Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    [Arguments]    &{expected_dict}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Set Global Environment
    ${dimension_dn}                       BuiltIn.Run Keyword if               '${object_name}' == 'NRBTS'
    ...                             set variable         MRBTS-${glo_mrbts_id_vdu}/NRBTS-${glo_nrbts_id_vdu}
    ...     ELSE                    set variable         MRBTS-${glo_mrbts_id_vdu}/NRBTS-${glo_nrbts_id_vdu}/${object_name}-${object_id}
    Dated log                       \ndimension_dn=${dimension_dn}
    ${res}      Call method    ${GNB_DU.oam}    get_counter_sum    counter_id=${counter_name}
    ...                           dimension_dn=${dimension_dn}
    Dated log                       res_sum=${res}
    # ERROR CASE
    Run Keyword If                  '${res}'=='EMPTY'                            Fail      KW: No value found for ${counter_name}
    Set PM Audit List        ${counter_name}
    [Return]    ${res}

## UPDATE_AiC_OAM
Retrieve Counter Sum of Values From Pm Files For Object and Id on vCU
    [Arguments]    &{expected_dict}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Dated log                       aaa_object_name=${object_name}
    #SET_GLOBAL
    Set Global Environment
    ${dimension_dn}                       BuiltIn.Run Keyword if               '${object_name}' == 'NRBTS'
    ...                             set variable         MRBTS-${glo_mrbts_id_vcu}/NRBTS-${glo_nrbts_id_vcu}
    ...     ELSE                    set variable         MRBTS-${glo_mrbts_id_vcu}/NRBTS-${glo_nrbts_id_vcu}/${object_name}-${object_id}
    Dated log                       \ndimension_dn=${dimension_dn}
    ${res}      Call method    ${GNB_CU.oam}    get_counter_sum_c2    counter_id=${counter_name}
    ...                           dimension_dn=${dimension_dn}
    Dated log                       res_sum=${res}
    # ERROR CASE
    Run Keyword If                  '${res}'=='EMPTY'                            Fail      KW: No value found for ${counter_name}
    Set PM Audit List        ${counter_name}
    [Return]    ${res}

## UPDATE_AiC KPI
PosProcess PM Aic Files vDU
    [Documentation]   INTERNAL USAGE
    ...               Post-process PM files: decompress, merge, and create consolidated PM.xml
    ...               *Arguments:*
    ...               - ${pm_path}: Base path containing PM files
    ...               - ${usePython}: If True (default), use Python implementation; if False, use shell scripts
    [Arguments]    ${pm_path}    ${usePython}=${True}
    # ${vDUPMPathLocal}                Set Variable            vDU_PM
    ${pm_vdu_loc_dir}               Set Variable             ${pm_path}/${vDUPMPathLocal}
    ${pm_last}                      Run Keyword If           ${usePython}
    ...                             PosProcess PM Python vDU      ${pm_vdu_loc_dir}    ${vDUPMPathLocal}
    ...                             ELSE
    ...                             PosProcess PM Shell vDU       ${pm_vdu_loc_dir}
    [Return]    ${pm_last}

PosProcess PM Shell vDU
    [Documentation]   INTERNAL USAGE - Shell script implementation
    [Arguments]    ${pm_vdu_loc_dir}
    ${cmd}               Set Variable            cp ${CURDIR}/../shell/pos_process.sh ${pm_vdu_loc_dir}
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cp ${CURDIR}/../shell/fic_rm.sh ${pm_vdu_loc_dir}
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vdu_loc_dir}; chmod a+x fic_rm.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vdu_loc_dir}; ./fic_rm.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vdu_loc_dir}; chmod a+x pos_process.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vdu_loc_dir}; ./pos_process.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vdu_loc_dir}; rm pos_process.sh ; rm fic_rm.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${pm_last}               Set Variable            ${pm_vdu_loc_dir}/PM.xml
    [Return]    ${pm_last}

PosProcess PM Python vDU
    [Documentation]   INTERNAL USAGE - Python implementation
    [Arguments]    ${pm_vdu_loc_dir}    ${vDUPMPathLocal}
    ${latest_date}      remove_old_pm_files    ${pm_vdu_loc_dir}
    ${pm_last}          post_process_pm_files  ${pm_vdu_loc_dir}    ${vDUPMPathLocal}
    [Return]    ${pm_last}

PosProcess PM Aic Files vCU
    [Documentation]   INTERNAL USAGE
    ...               Post-process PM files: decompress, merge, and create consolidated PM.xml
    ...               *Arguments:*
    ...               - ${pm_path}: Base path containing PM files
    ...               - ${usePython}: If True (default), use Python implementation; if False, use shell scripts
    [Arguments]    ${pm_path}    ${usePython}=${True}
    # ${vCUPMPathLocal}                Set Variable            vCU_PM
    ${pm_vcu_loc_dir}               Set Variable             ${pm_path}/${vCUPMPathLocal}
    ${pm_last}                      Run Keyword If           ${usePython}
    ...                             PosProcess PM Python vCU      ${pm_vcu_loc_dir}    ${vCUPMPathLocal}
    ...                             ELSE
    ...                             PosProcess PM Shell vCU       ${pm_vcu_loc_dir}
    [Return]    ${pm_last}

PosProcess PM Shell vCU
    [Documentation]   INTERNAL USAGE - Shell script implementation
    [Arguments]    ${pm_vcu_loc_dir}
    ${cmd}               Set Variable            cp ${CURDIR}/../shell/pos_process.sh ${pm_vcu_loc_dir}
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cp ${CURDIR}/../shell/fic_rm.sh ${pm_vcu_loc_dir}
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vcu_loc_dir}; chmod a+x fic_rm.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vcu_loc_dir}; ./fic_rm.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vcu_loc_dir}; chmod a+x pos_process.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vcu_loc_dir}; ./pos_process.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${cmd}               Set Variable            cd ${pm_vcu_loc_dir}; rm pos_process.sh ; rm fic_rm.sh
    ${output}    OperatingSystem.Run     ${cmd}
    ${pm_last}               Set Variable            ${pm_vcu_loc_dir}/PM.xml
    [Return]    ${pm_last}

PosProcess PM Python vCU
    [Documentation]   INTERNAL USAGE - Python implementation
    [Arguments]    ${pm_vcu_loc_dir}    ${vCUPMPathLocal}
    ${latest_date}      remove_old_pm_files    ${pm_vcu_loc_dir}
    ${pm_last}          post_process_pm_files  ${pm_vcu_loc_dir}    ${vCUPMPathLocal}
    [Return]    ${pm_last}

Retrieve Latest Single Counter Value From Pm File
    [Documentation]   Retrieve the latest (chronological order) single counter value from a PM file
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${counter_name}: counter name
    [Arguments]    ${pm_path}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    get_latest_single_counter_value       ${pm_path}      ${counter_name}
    ${msg}=    set variable    KW: Retrieve Latest Single Counter Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log      ${msg}
    Set PM Audit Dict    ${counterName}     ${counter_value_retrieved}
    [Return]    ${counter_value_retrieved}

Retrieve Earliest Single Counter Value From Pm File
    [Documentation]   Retrieve earliest (chronological order) single counter value from a PM file
    ...
    ...                *Argument:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${counter_name}: counter name
    [Arguments]    ${pm_path}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    get_earliest_single_counter_value       ${pm_path}      ${counter_name}
    ${msg}=    set variable    KW: Retrieve Earliest Single Counter Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log      ${msg}
    Set PM Audit Dict    ${counterName}     ${counter_value_retrieved}
    [Return]    ${counter_value_retrieved}

Retrieve Latest Single Counter Value From Pm File with CellID
    [Documentation]   Retrieve the latest (chronological order) single counter value from a PM file with CellID
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${counter_name}: counter name
    ...                - ${CellID}: cell id
    [Arguments]    ${pm_path}    ${counter_name}   ${CellID}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    get_latest_single_counter_value_with_CellID       ${pm_path}      ${counter_name}   ${CellID}
    ${msg}=    set variable    KW: Retrieve Latest Single Counter Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log      ${msg}
    Set PM Audit Dict    ${counterName}     ${counter_value_retrieved}
    [Return]    ${counter_value_retrieved}


Retrieve NRCell Counter Value From Pm File
    [Documentation]    INTERNAL USAGE
    ...                 DEPRECATED: NOT TO BE USED ANYMORE
    [Arguments]    ${pm_path}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    Fetch From File Counter Value By Object
    ...                           ${pm_path}    NRCELL    ${counter_name}
    ${msg}=    set variable    KW: Retrieve NRCell Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log		${msg}
    Set PM Audit Dict    ${counterName}     ${counter_value_retrieved}
    [Return]    ${counter_value_retrieved}

# Retrieve Counter Value From Pm File For Object
#     [Documentation]                INTERNAL USAGE
#     ...               DEPRECATED: COMMENTED FIRST THEN TO BE REMOVED
#     ...               Retrieve Counter (Counter with supported object defined in an argument) for an object value from a PM file
#     ...               with arguments
#     ...               ${pm_path}: complete path of PM xml
#     ...               ${object_name}: counter supported object name
#     ...               ${counter_name}: counter name
#     [Arguments]    ${pm_path}    ${object_name}    ${counter_name}
#     ${counter_value_retrieved}=    set variable    ${EMPTY}
#     ${counter_value_retrieved}    Fetch From File Counter Value By Object
#     ...                           ${pm_path}    ${object_name}    ${counter_name}
#     ${msg}=    set variable    KW: Retrieve Value From Pm File For Object: Retrieve failed for ${counter_name} ${object_name}
#     Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log		${msg}
#     [Return]    ${counter_value_retrieved}

Retrieve Counter Sum of Values From Pm Files For Object
    [Documentation]    Retrieve all values of a counter in all PM xml files
    ...                Return and provide the sum of all these values
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj
    ...                for instance: &{expected_dict}    obj=NRCELL   counter=M55308C18002
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${sumCal}      Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...            ${pm_path}      ${object_name}      ${counter_name}
    Set PM Audit List        ${counter_name}
    [Return]    ${sumCal}

Retrieve Counter Sum of Values From Pm Files For Object with ID
    [Documentation]    Retrieve all value of a counter (supported by the object defined in an argument) in all PM xml files
    ...                in all PM xml files
    ...                calculate the sum of these values and return it
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj objId
    ...                for instance: &{expected_dict}    counter=M55118C05505   obj=NRCELL objId=1
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    ${sumCal}      Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...            ${pm_path}      ${object_name}      ${counter_name}    ${object_id}
    Set PM Audit List        ${counter_name}
    [Return]    ${sumCal}

Retrieve Sum of Values Counter From Pm Files with CellID
    [Documentation]    Retrieve all value of a counter (supported by the object NRCELL) in all PM xml files
    ...                calculate the sum of these values and return it
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - &{expected_dict}:  a dictonnay with keys : counter objId
    ...                for instance: &{expected_dict}    counter=M55118C05505   objId=1
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    ${sumCal}      Retrieve Sum of Values From A Pm File with CellID
    ...            ${pm_path}      ${counter_name}    ${object_id}
    Set PM Audit List        ${counter_name}
    [Return]    ${sumCal}

Verify Object Counter Sum Of Values
    [Documentation]    Retrieve all value of a counter in all PM xml files
    ...                calculate the sum of these values and compare it with an expected value
    ...                And verify if the sum is equal to the expected value and return the result
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj expectedVal
    ...                for instance: &{expected_dict}   counter=M55320C09009   obj=NRBTS     expectedVal=10
    [Arguments]    ${pm_path}     &{expected_dict}
    ${res}=    set variable    True
    ${objectName}=     set variable    ${expected_dict}[obj]
    ${counterName}=    set variable    ${expected_dict}[counter]
    ${iExpected}=     evaluate      ${expected_dict}[expectedVal]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                 ${pm_path}      ${objectName}    ${counterName}
    Debug Dated Log     valRetrieved= ${valRetrieved} iExpected= ${iExpected}
    ${res}=     evaluate    ${valRetrieved} == ${iExpected}
    [Return]    ${res}

Verify Object Counter Sum Of Values In A Range
    [Documentation]    Retrieve all value of a counter in all PM xml files
    ...                calculate the sum of these values and compare it with a range Min and Max
    ...                And verify if the sum is in the range and return the result
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj min max
    ...                for instance: &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log     pm_path= ${pm_path}
    # ${res}=    set variable    True
    ${objectName}=     set variable    ${expected_dict}[obj]
    ${counterName}=    set variable    ${expected_dict}[counter]
    ${iMin}=     evaluate      ${expected_dict}[min]
    ${iMax}=     evaluate      ${expected_dict}[max]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                ${pm_path}      ${objectName}    ${counterName}
    Debug Dated Log     valRetrieved= ${valRetrieved} iMin= ${iMin} iMax= ${iMax}
    # Compare ivalue with Min Max     ${valRetrieved}       ${iMin}       ${iMax}
    ${result}=       Run Keyword And Return Status     Compare ivalue with Min Max
    ...              ${valRetrieved}       ${iMin}       ${iMax}
    Debug Dated Log     result= ${result}
    [Return]    ${result}

Verify Object Counter with ID Sum Of Values In A Range
    [Documentation]    Retrieve all value of a counter defined with object id in all PM xml files
    ...                calculate the sum of these values and compare it with a range Min and Max
    ...                And verify if the sum is in the range and return the result
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${pm_obj_id}: counter object id
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj min max
    ...                for instance: &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    ${pm_path}     ${pm_obj_id}      &{expected_dict}
    Debug Dated Log     pm_path= ${pm_path}
    Debug Dated Log     pm_obj_id= ${pm_obj_id}
    # ${res}=    set variable    True
    ${objectName}=     set variable    ${expected_dict}[obj]
    ${counterName}=    set variable    ${expected_dict}[counter]
    ${iMin}=     evaluate      ${expected_dict}[min]
    ${iMax}=     evaluate      ${expected_dict}[max]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                ${pm_path}      ${objectName}    ${counterName}     ${pm_obj_id}
    Debug Dated Log     valRetrieved= ${valRetrieved} iMin= ${iMin} iMax= ${iMax}
    # Compare ivalue with Min Max     ${valRetrieved}       ${iMin}       ${iMax}
    ${result}=       Run Keyword And Return Status     Compare ivalue with Min Max
    ...              ${valRetrieved}       ${iMin}       ${iMax}
    Debug Dated Log     result= ${result}
    [Return]    ${result}

## UPDATE_AiC_OAM
Verify Object Counter with ID Sum Of Values In A Range on vDU
    [Documentation]    Retrieve all value of a counter defined with object id in all PM xml files
    ...                calculate the sum of these values and compare it with a range Min and Max
    ...                And verify if the sum is in the range and return the result
    ...
    ...                *Arguments:*
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj min max
    ...                for instance: &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    &{expected_dict}
    Set Global Environment
    ${objectName}=     set variable    ${expected_dict}[obj]
    ${counterName}=    set variable    ${expected_dict}[counter]
    ${iMin}=     evaluate      ${expected_dict}[min]
    ${iMax}=     evaluate      ${expected_dict}[max]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                &{expected_dict}
    Debug PMC Log     valRetrieved= ${valRetrieved} iMin= ${iMin} iMax= ${iMax}
    ${result}=       Run Keyword And Return Status     Compare ivalue with Min Max
    ...              ${valRetrieved}       ${iMin}       ${iMax}
    Debug PMC Log     result= ${result}
    [Return]    ${result}

## UPDATE_AiC_OAM
Verify Object Counter with ID Sum Of Values In A Range on vCU
    [Documentation]    Retrieve all value of a counter defined with object id in all PM xml files
    ...                calculate the sum of these values and compare it with a range Min and Max
    ...                And verify if the sum is in the range and return the result
    ...
    ...                *Arguments:*
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj min max
    ...                for instance: &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    &{expected_dict}
    Set Global Environment
    ${objectName}=     set variable    ${expected_dict}[obj]
    ${counterName}=    set variable    ${expected_dict}[counter]
    ${iMin}=     evaluate      ${expected_dict}[min]
    ${iMax}=     evaluate      ${expected_dict}[max]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object and Id on vCU
    ...                &{expected_dict}
    Debug PMC Log     valRetrieved= ${valRetrieved} iMin= ${iMin} iMax= ${iMax}
    ${result}=       Run Keyword And Return Status     Compare ivalue with Min Max
    ...              ${valRetrieved}       ${iMin}       ${iMax}
    Debug PMC Log     result= ${result}
    [Return]    ${result}

Verify Object Counter with ID Sum Of Values In A Range Multi
    [Documentation]    Retrieve all value of a counter defined with object id in all PM xml files
    ...                calculate the sum of these values and compare it with a range Min and Max
    ...                And verify if the sum is in the range and return the result
    ...
    ...                *Arguments:*
    ...                - ${a_pm_path}: complete path of PM xml
    ...                - ${a_pm_obj_id}: counter object id
    ...                - ${aicEntity}: None or DU or CU (by default None)
    ...                            On Classical TL step 1:global variable ${isAIC} is used
    ...                            On Classical TL  step 2:this parameter is not used
    ...                            On Aic TL step 1:global variable ${isAIC} is used
    ...                            On Aic TL step 2:this paramter is used to treat counters on DU ou CU
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj min max
    ...                for instance: &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    ${a_pm_path}=None     ${a_pm_obj_id}=1      ${aicEntity}=None      &{expected_dict}
    Run Keyword if       ${isAIC}
    ...             Set Global Environment
    Dated Log       yy_debug_a_pm_path=${a_pm_path}
    ${objectName}=     set variable    ${expected_dict}[obj]
    ${counterName}=    set variable    ${expected_dict}[counter]
    ${iMin}=     evaluate      ${expected_dict}[min]
    ${iMax}=     evaluate      ${expected_dict}[max]
    # Classical
    ${result}        Run keyword and return if       not ${isAIC}
    ...             Verify Object Counter with ID Sum Of Values In A Range      ${a_pm_path}      ${a_pm_obj_id}        &{expected_dict}
    # AiC
    &{dict_withID}=	    Create Dictionary   counter=${expected_dict}[counter]   obj=${expected_dict}[obj]   objId=${a_pm_obj_id}
    ...                                     min=${expected_dict}[min]    max=${expected_dict}[max]
    ${resultCU}       Run keyword and return if       ${isAIC} and '${aicEntity}'=='CU'
    ...             Verify Object Counter with ID Sum Of Values In A Range on vCU      &{dict_withID}
    ${resultDU}       Run keyword and return if       ${isAIC} and '${aicEntity}'=='DU'
    ...             Verify Object Counter with ID Sum Of Values In A Range on vDU      &{dict_withID}
    [Return]    ${result}

Check At Least One Value Is In Criteria From Pm Files For Object With ID
    [Documentation]    Retrieve each value of a counter in all PM xml files
    ...                Check if a least one value is fulfil the criteria defined with:
    ...                expected_value and ${comparison} that could be '>=' '>' '<=' '<' '=='
    ...
    ...                The counter to retrieve is defined with   &{expected_dict} that contains
    ...                counter=<CounterName>    obj=<CounterSupprtedObject>     objId=<CounterSupprtedObject> example:
    ...                for instance: counter=M55308C17002    obj=NRCELL     objId=1
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${expected_value}: expected value
    ...                - ${comparison}: could be '>=' '>' '<=' '<' '=='
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj objId
    ...                for instance:  counter=M55308C17002    obj=NRCELL     objId=1
    [Arguments]    ${pm_path}       ${expected_value}	    ${comparison}       &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Set suite variable    ${curPmDir}    ${pm_path}/${pmCollectSubDir}
    ${sumCal}=  evaluate     0
    Debug Dated Log          curPmDir:${curPmDir}
    @{filesList}        List Directory      ${curPmDir}     *.xml
    ${counter_values}  Extract Counter Different Values From PM Files in dir
    ...     ${curPmDir}       ${object_name}    ${counter_name}        ${object_id}
    ${nbFound}=    Set Variable    0
    FOR        ${elem}   IN  @{counter_values}
        ${ret}=    Set Variable    ${False}
        Debug Dated Log  elem=${elem}
        ${ret}=  Compare with Expected Value  		${comparison}    ${expected_value}     ${elem}
        Debug Dated Log  ret=${ret}
        ${nbFound}=      Run Keyword if      ${ret}==${True}        Evaluate     ${nbFound} + 1
        ...                 ELSE             Evaluate       ${nbFound} + 0
        Debug Dated Log  nbFound=${nbFound}
    END
    ${retKW}=       Run Keyword if      ${nbFound}>0        Set Variable   ${True}
    ...             ELSE        Set Variable   ${False}
    [Return]    ${retKW}

## UPDATE_AiC_OAM
Check At Least One Value Is In Criteria From Pm Files For Object With ID on vDU
    [Documentation]    Retrieve each value of a counter
    ...                Check if a least one value is fulfil the criteria defined with:
    ...                expected_value and ${comparison} that could be '>=' '>' '<=' '<' '=='
    ...
    ...                The counter to retrieve is defined with   &{expected_dict} that contains
    ...                counter=<CounterName>    obj=<CounterSupprtedObject>     objId=<CounterSupprtedObject> example:
    ...                for instance: counter=M55308C17002    obj=NRCELL     objId=1
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${expected_value}: expected value
    ...                - ${comparison}: could be '>=' '>' '<=' '<' '=='
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj objId
    ...                for instance:  counter=M55308C17002    obj=NRCELL     objId=1
    [Arguments]    ${expected_value}	    ${comparison}       &{expected_dict}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Dated log                       expected_value=${expected_value}
    Dated log                       comparison=${comparison}
    Set Global Environment
    ${dimension_dn}=    set variable    MRBTS-${glo_mrbts_id_vdu}/NRBTS-${glo_nrbts_id_vdu}/${object_name}-${object_id}
    Dated log                       \ndimension_dn=${dimension_dn}
    ${counter_values}      Call method    ${GNB_DU.oam}    get_counter_values    counter_id=${counter_name}
    ...                           dimension_dn=${dimension_dn}
    Dated log                       counter_values=${counter_values}
    ${nbFound}=    Set Variable    0
    FOR        ${elem}   IN  @{counter_values}
        ${ret}=    Set Variable    ${False}
        Debug Dated Log  elem=${elem}
        ${ret}=  Compare with Expected Value        ${comparison}    ${expected_value}     ${elem}
        Debug Dated Log  ret=${ret}
        ${nbFound}=      Run Keyword if      ${ret}==${True}        Evaluate     ${nbFound} + 1
        ...                 ELSE             Evaluate       ${nbFound} + 0
        Debug Dated Log  nbFound=${nbFound}
    END
    ${retKW}=       Run Keyword if      ${nbFound}>0        Set Variable   ${True}
    ...             ELSE        Set Variable   ${False}
    [Return]    ${retKW}

## UPDATE_AiC_OAM
Check At Least One Value Is In Criteria From Pm Files For Object With ID on vCU
    [Documentation]    Retrieve each value of a counter
    ...                Check if a least one value is fulfil the criteria defined with:
    ...                expected_value and ${comparison} that could be '>=' '>' '<=' '<' '=='
    ...
    ...                The counter to retrieve is defined with   &{expected_dict} that contains
    ...                counter=<CounterName>    obj=<CounterSupprtedObject>     objId=<CounterSupprtedObject> example:
    ...                for instance: counter=M55308C17002    obj=NRCELL     objId=1
    ...
    ...                *Arguments:*
    ...                - ${pm_path}: complete path of PM xml
    ...                - ${expected_value}: expected value
    ...                - ${comparison}: could be '>=' '>' '<=' '<' '=='
    ...                - &{expected_dict}:  a dictonnay with keys : counter obj objId
    ...                for instance:  counter=M55308C17002    obj=NRCELL     objId=1
    [Arguments]    ${expected_value}	    ${comparison}       &{expected_dict}
    ${object_name}=     set variable    ${expected_dict}[obj]
    ${counter_name}=    set variable    ${expected_dict}[counter]
    ${object_id}=       set variable    ${expected_dict}[objId]
    Dated log                       expected_value=${expected_value}
    Dated log                       comparison=${comparison}
    Set Global Environment
    ${dimension_dn}=    set variable    MRBTS-${glo_mrbts_id_vdu}/NRBTS-${glo_nrbts_id_vdu}/${object_name}-${object_id}
    Dated log                       \ndimension_dn=${dimension_dn}
    ${counter_values}      Call method    ${GNB_CU.oam}    get_counter_values_2    counter_id=${counter_name}
    ...                           dimension_dn=${dimension_dn}
    Dated log                       counter_values=${counter_values}
    ${nbFound}=    Set Variable    0
    FOR        ${elem}   IN  @{counter_values}
        ${ret}=    Set Variable    ${False}
        Debug Dated Log  elem=${elem}
        ${ret}=  Compare with Expected Value    ${comparison}    ${expected_value}     ${elem}
        Debug Dated Log  ret=${ret}
        ${nbFound}=      Run Keyword if      ${ret}==${True}        Evaluate     ${nbFound} + 1
        ...                 ELSE             Evaluate       ${nbFound} + 0
        Debug Dated Log  nbFound=${nbFound}
    END
    ${retKW}=       Run Keyword if      ${nbFound}>0        Set Variable   ${True}
    ...             ELSE        Set Variable   ${False}
    [Return]    ${retKW}

Wait PM availability
    [Documentation]    Wait PM availability
    ...
    ...                *Arguments:*
    ...                - ${pmPeriodSec}: = 0, reportingIntervalPm in scf is used else PM Period in second. For AiC scf from vDU
    ...                - ${pmAvailDelay}: Delay after Period
    [Arguments]            ${pmPeriodSec}=0    ${pmAvailDelay}=60
    Dated Log              ===> Wait PM availablity period=${pmPeriodSec}
    ${startTime}           Evaluate    int(time.time())    time
    # Get reportingIntervalPm from SCF
    OAM Get SCF File       dir=/tmp    file=SCF_WaitPM.xml
    SCF StartSession       scf_file=/tmp/SCF_WaitPM.xml
    ${dist_name}           Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${repIntervalPm}       SCF Get Single Value    ${dist_name}         reportingIntervalPm
    ...                                            aicListEntity=vdu    scope=Both
    SCF StopSession        scf_file=/tmp/SCF_WaitPM.xml
    ${pmPeriodSec}                  Run Keyword If    ${pmPeriodSec} == 0
    ...                             Convert Time    ${repIntervalPm}[0]
    ...      ELSE                   Set Variable    ${pmPeriodSec}
    ${nextPeriodTime}               Evaluate    (int(${startTime} / ${pmPeriodSec}) + 1) * ${pmPeriodSec}
    ${pmAvailabilityTime}           Evaluate    ${nextPeriodTime} + ${pmAvailDelay}
    ${pmWaitDuration}               Evaluate    ${pmAvailabilityTime} - ${startTime}
    ${pmAvailabilityDate}           Convert date    ${pmAvailabilityTime}
    Dated Log                       ===> PM should be available in ${pmWaitDuration} sec, at ${pmAvailabilityDate}
    Sleep                           ${pmWaitDuration}    Wait for PM availability

## UPDATE_AiC_OAM
Clean PM on AiC TL
    [Documentation]    Clean PM files on vDU and vCU
    # ignore error to not block setup phasis
    Run Keyword And Ignore Error        Clean PM on vDU
    Run Keyword And Ignore Error        Clean PM on vCU

Clean PM on vDU
    [Documentation]    INTERNAL USAGE
    ${loc_namespace_vdu}    Set Variable        ${GNB_DU.mainNode.k8s.namespace}
    # ${loc_pm_pod_name}      Set Variable    	pm-0
    ${loc_pm_pod_name}      Set Variable    	oampm-0
    ${loc_pm_pod_pref}            Retrieve PM pods     ${GNB_DU}    ute-${loc_pm_pod_name}
    # ${loc_pm_container_name}    Set Variable    		pmcore
    ${loc_pm_container_name}    Set Variable    		pmdataserver
    ${loc_pm_container_pref}    Set Variable    		ctr
    ${pm_dir}    Set Variable    		/mnt/services/SS_OAM/PMSTAT/pm_report_files/
    ${loc_pod_pm_complete_vdu}  Set Variable    		    ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vdu}   Set Variable   		${loc_pm_container_pref}-${loc_pm_container_name}
    ${cmd}                          Set Variable         bash -c 'ls ${pm_dir}/A*.gz | while read -r line; do rm \${line} ; done'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ${pm_dir}    Set Variable    		/mnt/services/SS_OAM/PMSTAT/pm_result_files/
    ${loc_pod_pm_complete_vdu}  Set Variable    		    ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vdu}   Set Variable   		${loc_pm_container_pref}-${loc_pm_container_name}
    ${cmd}                          Set Variable         bash -c 'ls ${pm_dir}/A*.gz | while read -r line; do rm \${line} ; done'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}
    ...                             podName=${loc_pod_pm_complete_vdu}
    ...                             containerName=${loc_container_pm_complete_vdu}
    ...                             cmd=${cmd}
    ...                             debug=${False}

Clean PM on vCU
    [Documentation]    INTERNAL USAGE
    ${loc_namespace_vcu}    Set Variable        ${GNB_CU.mainNode.k8s.namespace}
    # ${loc_pm_pod_name}  Set Variable          pm-0
    ${loc_pm_pod_name}      Set Variable        oampm-0
    ${loc_pm_pod_pref}            Retrieve PM pods     ${GNB_CU}     ute-${loc_pm_pod_name}
    # ${loc_pm_container_name}    Set Variable          pmcore
    ${loc_pm_container_name}    Set Variable            pmdataserver
    ${loc_pm_container_pref}    Set Variable            ctr
    ${pm_dir}    Set Variable       /mnt/services/SS_OAM/PMSTAT/pm_report_files/
    ${loc_pod_pm_complete_vcu}  Set Variable                ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vcu}    Set Variable        ${loc_pm_container_pref}-${loc_pm_container_name}
    ${cmd}                          Set Variable         bash -c 'ls ${pm_dir}/A*.gz | while read -r line; do rm \${line} ; done'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}
    ${pm_dir}    Set Variable       /mnt/services/SS_OAM/PMSTAT/pm_result_files/
    ${loc_pod_pm_complete_vcu}  Set Variable        ${loc_pm_pod_pref}-${loc_pm_pod_name}
    ${loc_container_pm_complete_vcu}    Set Variable        ${loc_pm_container_pref}-${loc_pm_container_name}
    ${cmd}                          Set Variable            bash -c 'ls ${pm_dir}/A*.gz | while read -r line; do rm \${line} ; done'
    ${result}                       K8s cmd
    ...                             k8s=${GNB_CU}
    ...                             podName=${loc_pod_pm_complete_vcu}
    ...                             containerName=${loc_container_pm_complete_vcu}
    ...                             cmd=${cmd}
    ...                             debug=${False}

### internal usage only
Retrieve Counter Sum of Values From Pm Files For Object With Name
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${pm_path}    ${object_name}    ${counter_name}      ${object_id}=1
    Debug Dated Log          xxx_pm_path:${pm_path}
    Debug Dated Log          xxx_object_id:${object_id}
    Set suite variable    ${curPmDir}    ${pm_path}/${pmCollectSubDir}
    ${sumCal}=  evaluate     0
    Debug Dated Log          curPmDir:${curPmDir}
    @{filesList}        List Directory      ${curPmDir}     *.xml
    ${counter_values}  Extract Counter Different Values From PM Files in dir
        ...     ${curPmDir}       ${object_name}    ${counter_name}        ${object_id}
    FOR        ${counter_elem}   IN  @{counter_values}
        ${sumCal}=  evaluate   ${counter_elem}+${sumCal}
    END
    Debug Dated Log  sumCal= ${sumCal}
    Set PM Audit List        ${counter_name}
    [Return]    ${sumCal}

Retrieve Sum of Values From A Pm File with CellID
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${pm_path}    ${counter_name}      ${object_id}=1
    Debug Dated Log          xxx_pm_path:${pm_path}
    Debug Dated Log          xxx_object_id:${object_id}
    Set suite variable    ${curPmDir}    ${pm_path}/${pmCollectSubDir}
    ${sumCal}=  evaluate     0
    Debug Dated Log          curPmDir:${curPmDir}
    @{filesList}        List Directory      ${curPmDir}     *.xml
    Debug Dated Log          filesList:@{filesList}
    FOR        ${el}   IN  @{filesList}
        Set suite variable    ${fileToCheck}    ${pm_path}/${pmCollectSubDir}/${el}
        Debug Dated Log  fileToCheck= ${fileToCheck}
        ${sumInAFile}  Get Sum Of Counter Values With CellId
        ...     ${fileToCheck}    ${counter_name}        ${object_id}
        Debug Dated Log  sumInAFile= ${sumInAFile}
        ${sumCal}=  evaluate   ${sumInAFile}+${sumCal}
    END
    Debug Dated Log  sumCal= ${sumCal}
    [Return]    ${sumCal}

Empty dir if needed
    [Documentation]                 INTERNAL USAGE
    [Arguments]   ${pm_files_path}
    Remove Directory        ${pm_files_path}    recursive=True

Compare value with Min Max
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${val}       ${vMin}     ${vMax}
    ${iVal}=    evaluate      ${val}
    ${iMin}=    evaluate      ${vMin}
    ${iMax}=    evaluate      ${vMax}
    should be true     ${iMin} < ${val}
    should be true     ${iMax} > ${val}

Compare ivalue with Min Max
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${val}       ${iMin}     ${iMax}
    should be true     ${iMin} <= ${val}
    should be true     ${iMax} >= ${val}

Retrieve PM pods
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${GNB_NODE}       ${p_pm_pod_name}
    ${pod1}                          K8s Get Pod      k8s=${GNB_NODE}             name=${p_pm_pod_name}
    @{words}=    Split String    ${pod1.name.name}    -
    ${list1}=    Split String    ${words[0]}
    ${loc_pm_pod_pref}             set variable              ${list1}[0]
    [Return]    ${loc_pm_pod_pref}

Set PM Audit List
    [Documentation]                 INTERNAL USAGE
    [Arguments]   ${counter_name}
    @{LIST_C_V}      Create List
    Append To List    ${LIST_C_V}    ${TEST_NAME}        ${counterName}
    Append To List    ${AUDIT_CPT_TO_BE_TESTED}    ${LIST_C_V}

Set PM Audit Dict
    [Documentation]                 INTERNAL USAGE
    [Arguments]   ${counter_name}        ${val}
    @{LIST_C_V}      Create List
    Append To List    ${LIST_C_V}    ${TEST_NAME}        ${counterName}       ${val}
    Append To List    ${AUDIT_TC_CPT_TO_BE_TESTED}    ${LIST_C_V}


# ============================================================================
#         PM Counter Keywords
# ============================================================================

Get Latest PM File From BTS Without Collecting
    [Arguments]   ${pm_files_path}
    [Documentation]    Returns Latest PM File From BTS Without Collecting
    ${latest_pm_file}=   Counters.get_latest_pm_file   ${pm_files_path}
    [Return]   ${latest_pm_file}

Extract Counter Latest Value From a PM File
    [Arguments]   ${pm_file}  ${object_name}  ${counter_id}
    [Documentation]    Get Counter Latest Value From a PM File
    ${counter_value}=   Counters.fetch_from_file_counter_latest_values_by_object
    ...                 ${pm_file}   ${object_name}  ${counter_id}
    Run keyword if  '${counter_value}' == '${EMPTY}'  Fail      KW: No value found for ${counter_id} in ${pm_file}
    [Return]  ${counter_value}

Extract Counter Different Values From PM Files in dir
    [Arguments]   ${pm_dir}    ${object_name}     ${counter_name}      ${object_id}
    [Documentation]   Get Counter Different Values From a PM File dir
    @{counter_values}=   Counters.get_counter_values_from_dir
    ...                 pi_dir=${pm_dir}    object_name=${object_name}     counter_name=${counter_name}     object_id=${object_id}
    BuiltIn.log                     list_in_pm_robot @{counter_values}
    Run keyword if  @{counter_values} == @{EMPTY}  BuiltIn.log      KW: No value found for ${counter_name} in ${pm_dir}
    [Return]  @{counter_values}

Extract Latest PM File From BTS
    [Arguments]   ${pm_files_path}
    [Documentation]    Get Latest PM File From BTS
    ${latest_pm_file}    Set variable    ${EMPTY}
    Collect pm with path   ${pm_files_path}
    ${latest_pm_file}=   Counters.get_latest_pm_file   ${pm_files_path}
    Run keyword if  '${latest_pm_file}' == '${EMPTY}'  Collect Result Not Expected      ${pm_files_path}
    [Return]   ${latest_pm_file}

Compare with Expected Value
    [Arguments]    ${comparison}    ${expected_val}     ${val}
    ${compare_result}=    Set Variable    ${False}
    ${iVal}=    evaluate      ${val}
    ${iExpected}=    evaluate      ${expected_val}
    ${compare_result1}=   Evaluate     ${iVal} >= ${iExpected}
    ${compare_result2}=   Evaluate     ${iVal} > ${iExpected}
    ${compare_result3}=   Evaluate     ${iVal} <= ${iExpected}
    ${compare_result4}=   Evaluate     ${iVal} < ${iExpected}
    ${compare_result5}=   Evaluate     ${iVal} == ${iExpected}
    ${compare_result}=      Run Keyword if      ${comparison}=='>='
    ...                         Set Variable    ${compare_result1}
    ...                     ELSE IF        ${comparison}=='>'
    ...                         Set Variable    ${compare_result2}
    ...                     ELSE IF        ${comparison}=='<='
    ...                         Set Variable    ${compare_result3}
    ...                     ELSE IF        ${comparison}=='<'
    ...                         Set Variable    ${compare_result4}
    ...                     ELSE IF        ${comparison}=='=='
    ...                         Set Variable    ${compare_result5}
    ...                     ELSE
    ...                         Set Variable    ${False}
    Debug Dated Log  FINAL_compare_result=${compare_result}
    [Return]    ${compare_result}

Collect Result Not Expected
    [Arguments]   ${pm_path}
    [Documentation]   Collect Result Not Expected
    ${res}    run    ls -R ${pm_path}
    BuiltIn.log     Content of collect directory : ${res}
    log to console     Content of collect directory ${res}
    Fail        No PM xml found after collection


# ============================================================================
#         PM Collection Keywords
# ============================================================================

Collect log files
    [Documentation]                 collect the log files and close the all the connections at the end.
    [Arguments]                     ${names}    ${target_dir}=${EMPTY}
    ${log_file}=                    core.collect_collectors   names=${names}    target_dir=${target_dir}
    core.teardown_collectors        names=${names}
    [Return]                        ${log_file}


Collectors with YAML
    [Documentation]                 create collection via YAML on specified VM with name
    [Arguments]                     ${yaml_file}    ${names}=gnb_oam_tcpdump
    ${configurations}=              core.Load Configurations     ${yaml_file}
    core.Create Collectors          names=${names}               configurations=${configurations['collectors']}
    core.Set Suite Alias            ${names}


Collect collectors with path
    [Documentation]                 create collection with patch
    [Arguments]   ${names}    ${target_dir}=${EMPTY}
    core.collect_collectors   names=${names}   target_dir=${target_dir}
    core.teardown_collectors        names=${names}
    [Return]


Collect pm with path
    [Documentation]                 Collect pm with collectors
    [Arguments]   ${pm_files_path}=${EMPTY}
    # Richard : depending Cloud or Classical, we have to use a specific yaml file
    ${yaml_file}=                   Set Variable    ${CURDIR}/../config/counters/forpm.yaml
    ${yaml_file_cloud}=             Set Variable    ${CURDIR}/../config/counters/forpm_cloud.yaml
    ${yaml}=                        Set Variable If    '${TLConfig.isGnbCloud}'=='${False}'    ${yaml_file}    ${yaml_file_cloud}
    Collectors with YAML            ${yaml}          names=pm_files

    core.setup_collectors           names=pm_files
    Collect collectors with path    names=pm_files   target_dir=${pm_files_path}
