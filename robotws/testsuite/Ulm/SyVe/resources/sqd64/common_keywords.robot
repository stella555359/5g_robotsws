*** Settings ***

Documentation
...    This robot resource file contains shared KWs for test suites of former sqd64 by SyVe.
...    We should check which of the KWs can be moved to the global SyVe resource folder.

Library     ute_tshark

Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/pmcounters.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/connect.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/attenuator.robot


*** Keywords ***
Prepare TL for Testing
    [Documentation]    Basic preparation of test line for test cases
    testline.Set Console Output
    Log Variables
    git_handling.Save Current Workspace Info
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Save current loads
    syve_testline.Testline Setup for CCRT
    ${capu_type}=     testline.Get Capacity Unit Type    gnb_id=${gnb_id}
    Set Suite Variable    ${capu_type}
    ${target_dir}=    testline.Get Test Suite Config Directory
    ${TL_scf_gnb0}=     gnb.Get SCF from gNB    gnb_id=${0}    target_dir=${target_dir}
    ${TL_scf_gnb1}=     gnb.Get SCF from gNB    gnb_id=${1}    target_dir=${target_dir}
    Set suite variable    ${TL_scf_gnb0}
    Set suite variable    ${TL_scf_gnb1}
    attenuator.Set Attenuator to Max Value
    setup tshark    eth1  preferences=ntrstr.port:20500,20501,49148,4321


Kill all iperf process
   ssh.Connect_to      hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
   ...                 username=${tl.appserver.iperf_details.ssh_connection_details.username}
   ...                 password=${tl.appserver.iperf_details.ssh_connection_details.password}
   ...                 alias=ssh-AppSvr
   Run Keyword and ignore error    ssh.Execute    killall -9 iperf    connection=ssh-AppSvr


Set MRBTS/NRBTS ID as Suite Variable
    [Arguments]    ${gnb_id}=${0}
    admin.connect to   bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...                bts_port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    ...                name=default
    ${bts_distNames_1}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${gnb_id}
    ${bts_distNames_2}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+    gnb_id=${gnb_id}
    ${distName_BTS_ID}=    Collections.Get From List    ${bts_distNames_1}      ${0}
    ${distName_MRBTS_ID}=  Collections.Get From List    ${bts_distNames_2}      ${0}
    Set Suite Variable     ${distName_BTS_ID}
    Set Suite Variable     ${distName_MRBTS_ID}


Get gnb physCellIds
    [Documentation]     get the physCellId for the testscenario
    [Arguments]    ${physSCell}=${None}  ${physPCell}=${None}
    ${ru_id_Psource}=    Evaluate  ${ru_id_source_pcell}+${1}
    IF  '${physPCell}'=='None'    Set Test Variable  ${ru_id_Psource}
    ...    ELSE    Set Test Variable  ${ru_id_Psource}  ${physPcell}
    ${PHYSCELLIDSOURCEPCELL}  Get gnb physCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_Psource}
    set suite variable  ${PHYSCELLIDSOURCEPCELL}
    ${ru_id_Ssource}=    Evaluate  ${ru_id_source_scell}+${1}
    IF  '${physSCell}'=='None'     Set Test Variable  ${ru_id_Ssource}
    ...    ELSE    Set Test Variable  ${ru_id_Ssource}  ${physSCell}
    ${PHYSCELLIDSOURCESCELL}  Get gnb physCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_Ssource}
    set suite variable  ${PHYSCELLIDSOURCESCELL}


Get gnb physCellId
    [Arguments]    ${gnb_id}  ${nrcell_id}
    [Documentation]     get physical cell id from gnb
    ${oam_alias}   connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ${physCellId}  coam_ulm.Get SCF Single Value From Current Xml File   alias=${oam_alias}
    ...   dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}
    ...   parameter=physCellId
    RETURN  ${physCellId}


Get SCF and Warn if Validate Plan Fail
    [Documentation]    :Author: Michele
    ...    Use for Getting the Running SCF, Connect OaM and Check for NIDD validation succeeded.
    ...    Connection is still open...
    [Arguments]    ${gnb_id}=0
    Log To Console    ${\n}SCF Validate Plan: NIDD validation for gNB=${gnb_id}
    ${TC_LOG_DIR}=   testline.Get testcase log directory
    Log To Console    ${\n}Current TC Logging PATH: ${\n}${TC_LOG_DIR}
    ${scf_file}=    gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${TC_LOG_DIR}/gnb${gnb_id}_actual_scf
    ${oam_alias}  connect.Setup OAM http session  node_id=${gnb_id}  node_type=gnb
    Run Keyword And Warn On Failure    admin.validate_scf_online    scf_file=${scf_file}    validation_type=NIDD_AND_RELATIONS
    ...    timeout=900    connection=${oam_alias}


Register UE
    [Arguments]    ${ue_alias}=${UE_ALIAS_1}
    Log To Console  \nINFO: Register ${ue_alias}
    taf.ue.Register   ${ue_alias}
    Sleep    5s    reason=Wait for setup


Connect PDU
    [Arguments]    ${ue_alias}    ${pdn}    ${qci}   ${pdu_alias}
    Log To Console  \nINFO: Add PDU for 5QI-${qci} for ${ue_alias}
    taf.ue.connect_additional_pdn    ue_alias=${ue_alias}    pdn=${pdn}
    taf.ue.Create Bearer Alias    alias=${pdu_alias}    qci=${qci}    pdn=${pdn}


Log all PM counters to Console
    [Documentation]     This KW logs the PM counters in ${PM_counters_list} and its values to Console, which are stored in ${PMCounters_dir}.
    [Arguments]    ${PMCounters_dir}    ${PM_counters_list}
    Log To Console    \nThese are the collected PM Counter values for cell ${CELL_ID}:
    FOR   ${pi_id}    IN    @{PM_counters_list}
       Get PM Counter Value   pm_files_location=${PMCounters_dir}   pi_id=${pi_id}    moc=NRCELL-${CELL_ID}
    END


Start PM Counter
    [Arguments]    ${gnb_id}=0
    Log To Console    \n"PMcounters: Wait next Measurement Period Starts."
    pmcounters.Wait until the next Measurement Period starts    gnb_id=${gnb_id}


Add Trace Collection Entity to SCF
    [Arguments]    ${gnb_id}=0
    ${mrbts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${gnb_id}
    ${MRBTS_distName}=    Collections.Get From List    ${mrbts_distNames}    ${0}
    Log To Console  ${\n}Add Trace Collection Entity to SCF.
    scf.add_object_to_scf     class_name=TCEADM    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1    version=${NIDD_VERSION}
    scf.add_object_to_scf     class_name=TCE    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1/TCE-1    version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1/TCE-1    p_name=certTypeForTlsAuth    value=RSA
    scf.add_element_to_scf    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1/TCE-1    p_name=tceIdentifier    value=1
    scf.add_element_to_scf    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1/TCE-1    p_name=tceIpAddress    value=10.46.235.233
    scf.add_element_to_scf    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1/TCE-1    p_name=tcePortNumber    value=49148
    scf.add_element_to_scf    dist_name=${MRBTS_distName}/MNL-1/TCEADM-1/TCE-1    p_name=tlsEnabled    value=false


Start Tracing
    ${eth3_collector}=  tcpdump.Start Tcpdump on TestPc   options=-i eth3 sctp or tcp port 49148
    Set Test Variable    ${eth3_collector}


Stop Tracing and Save As
    [Arguments]    ${file_name}
    ${tc_log_directory}=  testline.Get testcase log directory
    ${file_captured}  tcpdump.Stop Tcpdump on TestPc   collector=${eth3_collector}  target_dir=${tc_log_directory}
    OperatingSystem.Run  cp ${file_captured} ${tc_log_directory}/${file_name}.pcap
    Set Test Variable    ${${file_name}}         ${file_captured}
    # next line is only to keep compatibility with older test cases after removal of duplicated keyword
    Set Test Variable    ${${file_name}_trace}   ${file_captured}


Stop Data Transfers
    [Documentation]    Stop Data Transfers by provided data alias
    ...               :param data_alias:    a list of data alias, for which data transfer shall be stopped
    [Arguments]     ${data_alias}
    FOR    ${traffic_alias}   IN    @{data_alias}
        taf.ue.Stop Data Transfer    ${traffic_alias}
    END
