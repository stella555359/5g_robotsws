*** Settings ***
Documentation    Keywords to modify or restore eventsCollect.sh TTI script since lxc Containerization
...              Author : Annie Wong          annie.wong@nokia.com
...              Last update : 04.04.2021


Library             OperatingSystem
Library             Collections
Library             String
Library             taf.transport.ssh               WITH NAME       ssh
Library             ../../Tti_Trace.py


*** Variables ***
${tti_script_name}=                    eventsCollect.sh
${save_modif_script}=                  eventsCollect.sh.automation_archive_modifs
${archive_ori_script}=                 eventsCollect.sh.automation_archive_original_script


*** Keywords ***
Modify tti start script lxc containerization in TC Setup
    [arguments]      ${tti_abil_cnx_option}=xeonA      ${gNB}=0
    ${asik_cnx}    ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                               ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                               ${GNB_AIRSCALE_PASSWORD[${gNB}]}     alias=als_asik     timeout=90.0
    ${_abil_ip}=   run keyword if     '${tti_abil_cnx_option}'=='xeonA'   set variable    ${GNB_ABIL0_xeonA[${gNB}]}
    ...                     ELSE      set variable    ${GNB_ABIL0_xeonB[${gNB}]}
    Set Test Variable     ${ABIL_IP_FOR_TTI_TRACE}        ${_abil_ip}
    ${abil_cnx}   ssh.connect_to   ${ABIL_IP_FOR_TTI_TRACE}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}    alias=als_abil   proxy=als_asik   timeout=90.0
    ${l2rt_container}=     Get Container L2rt     cnx=${abil_cnx}     type_info=nodename
    sleep                  3s
    Log           l2rt_container=${l2rt_container}      console=${DEBUG_MODE_CONSOLE}
    ${nodeid}=    Get Container L2rt     cnx=${abil_cnx}     type_info=nodeid
    sleep         3s
    Log           l2rt nodeid=${nodeid}      console=${DEBUG_MODE_CONSOLE}
    ${output}     ssh.execute    lxc-ls      connection=${abil_cnx}
    ${is_l2rt_node_active}    Run Keyword And Return Status    Should Contain    ${output}    ${nodeid}
    Log           list active containers=${output}      console=${DEBUG_MODE_CONSOLE}
    Log           is_l2rt_node_active=${is_l2rt_node_active}      console=${DEBUG_MODE_CONSOLE}
    Set Test Variable       ${ORI_TTI_START_SCRIPT_IS_ARCHIVED}       ${False}
    Run Keyword If         ${is_l2rt_node_active}
    ...      modify tti start script        abil_cnx=${abil_cnx}   l2rt_container=${l2rt_container}
    [Teardown]   Run Keywords     Run Keyword And Ignore Error    ssh.disconnect     connection=als_abil
    ...                AND        Run Keyword And Ignore Error    ssh.disconnect     connection=als_asik


modify tti start script
    [documentation]     private keyword
    [arguments]         ${abil_cnx}    ${l2rt_container}
    ${path}=      get_ttiTrace_tool_path    ${abil_cnx}
    ${fullfile}      Join Path       ${path}      ${tti_script_name}
    ${full_archive_ori}           Join Path       ${path}      ${archive_ori_script}
    ${full_save_modif_script}     Join Path       ${path}      ${save_modif_script}
    ssh.execute    command=cp ${fullfile} ${full_archive_ori}         connection=${abil_cnx}
    Set Test Variable       ${ORI_TTI_START_SCRIPT_IS_ARCHIVED}       ${True}
    #${result}=     ssh.execute    command=ls -ll ${path}         connection=${abil_cnx}
    #Log    List file in ${path}:\n${result}       console=${DEBUG_MODE_CONSOLE}
    ssh.execute
    ...    command=sed -i 's|OUTPUT_DIR=/ram.*|OUTPUT_DIR=/ram/node_${l2rt_container}/tmp/|' ${fullfile}
    ...    connection=${abil_cnx}
    ssh.execute
    ...    command=sed -i 's|(cat /tmp/CCSRT_NID)|(cat /tmp/node_${l2rt_container}/tmp/CCSRT_NID)|' ${fullfile}
    ...    connection=${abil_cnx}
    ${txt}   set variable    ARCHIVE_FILENAME=
    ssh.execute
    ...    command=sed -i 's|${txt}\$(strip_0x \"\$(get_nid)\")_\${FILENAME}|${txt}\${FILENAME}|' ${fullfile}
    ...    connection=${abil_cnx}
    #${res}=    ssh.execute    command=cat ${fullfile}          connection=${abil_cnx}
    #Log    \nMODIFIED ${fullfile} CONTENT:\n${res}     console=${DEBUG_MODE_CONSOLE}
    #save moifications for debug case:
    ssh.execute    command=cp ${fullfile} ${full_save_modif_script}         connection=${abil_cnx}


Restore original tti start script in TC Teardown
    [arguments]       ${gNB}=0
    Run Keyword If    ${ORI_TTI_START_SCRIPT_IS_ARCHIVED}    restore tti script    gNB=${gNB}


restore tti script
    [documentation]     private keyword
    [arguments]       ${gNB}=0
    ${asik_cnx}        ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                                   ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                   ${GNB_AIRSCALE_PASSWORD[${gNB}]}    alias=als_asik     timeout=90.0
    ${abil_cnx}   ssh.connect_to   ${ABIL_IP_FOR_TTI_TRACE}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}    alias=als_abil   proxy=als_asik   timeout=90.0
    ${path}=            get_ttiTrace_tool_path    ${abil_cnx}
    ${fullfile}                Join Path       ${path}      ${tti_script_name}
    ${full_archive_ori}           Join Path       ${path}      ${archive_ori_script}
    ssh.execute           command=cp ${full_archive_ori} ${fullfile}        connection=${abil_cnx}
    #${res}=    ssh.execute    command=cat ${fullfile}             connection=${abil_cnx}
    #Log      \nRESTORED ${fullfile} CONTENT:\n${res}       console=${DEBUG_MODE_CONSOLE}
    [Teardown]   Run Keywords     Run Keyword And Ignore Error    ssh.disconnect     connection=als_abil
    ...                AND        Run Keyword And Ignore Error    ssh.disconnect     connection=als_asik


Restore original tti start script in Testsuite Teardown
    [arguments]       ${gNB}=0
    Run Keyword If    ${ORI_TTI_START_SCRIPT_IS_ARCHIVED}    restore tti script    gNB=${gNB}


Modify tti start script lxc containerization in Testsuite Setup
    [arguments]      ${tti_abil_cnx_option}=xeonA      ${gNB}=0
    ${asik_cnx}    ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                               ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                               ${GNB_AIRSCALE_PASSWORD[${gNB}]}     alias=als_asik     timeout=90.0
    ${_abil_ip}=   run keyword if     '${tti_abil_cnx_option}'=='xeonA'   set variable    ${GNB_ABIL0_xeonA[${gNB}]}
    ...                     ELSE      set variable    ${GNB_ABIL0_xeonB[${gNB}]}
    Set Suite Variable             ${ABIL_IP_FOR_TTI_TRACE}        ${_abil_ip}
    ${abil_cnx}   ssh.connect_to   ${ABIL_IP_FOR_TTI_TRACE}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}    alias=als_abil   proxy=als_asik   timeout=90.0
    ${l2rt_container}=     Get Container L2rt     cnx=${abil_cnx}     type_info=nodename
    sleep                  3s
    Log           l2rt_container=${l2rt_container}      console=${DEBUG_MODE_CONSOLE}
    ${nodeid}=    Get Container L2rt     cnx=${abil_cnx}     type_info=nodeid
    sleep         3s
    Log           l2rt nodeid=${nodeid}      console=${DEBUG_MODE_CONSOLE}
    ${output}     ssh.execute    lxc-ls      connection=${abil_cnx}
    ${is_l2rt_node_active}    Run Keyword And Return Status    Should Contain    ${output}    ${nodeid}
    Log           list active containers=${output}      console=${DEBUG_MODE_CONSOLE}
    Log           is_l2rt_node_active=${is_l2rt_node_active}      console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable       ${ORI_TTI_START_SCRIPT_IS_ARCHIVED}       ${False}
    Run Keyword If         ${is_l2rt_node_active}
    ...      modify tti start script testsuite level       abil_cnx=${abil_cnx}   l2rt_container=${l2rt_container}
    [Teardown]   Run Keywords     Run Keyword And Ignore Error    ssh.disconnect     connection=als_abil
    ...                AND        Run Keyword And Ignore Error    ssh.disconnect     connection=als_asik


modify tti start script testsuite level
    [documentation]     private keyword
    [arguments]         ${abil_cnx}    ${l2rt_container}
    ${path}=      get_ttiTrace_tool_path    ${abil_cnx}
    ${fullfile}      Join Path       ${path}      ${tti_script_name}
    ${full_archive_ori}           Join Path       ${path}      ${archive_ori_script}
    ${full_save_modif_script}     Join Path       ${path}      ${save_modif_script}
    ssh.execute    command=cp ${fullfile} ${full_archive_ori}         connection=${abil_cnx}
    Set Suite Variable      ${ORI_TTI_START_SCRIPT_IS_ARCHIVED}       ${True}
    #${result}=     ssh.execute    command=ls -ll ${path}         connection=${abil_cnx}
    #Log           List file in ${path}:\n${result}       console=${DEBUG_MODE_CONSOLE}
    ssh.execute
    ...    command=sed -i 's|OUTPUT_DIR=/ram.*|OUTPUT_DIR=/ram/node_${l2rt_container}/tmp/|' ${fullfile}
    ...    connection=${abil_cnx}
    ssh.execute
    ...    command=sed -i 's|(cat /tmp/CCSRT_NID)|(cat /tmp/node_${l2rt_container}/tmp/CCSRT_NID)|' ${fullfile}
    ...    connection=${abil_cnx}
    ${txt}   set variable    ARCHIVE_FILENAME=
    ssh.execute
    ...    command=sed -i 's|${txt}\$(strip_0x \"\$(get_nid)\")_\${FILENAME}|${txt}\${FILENAME}|' ${fullfile}
    ...    connection=${abil_cnx}
    #${res}=    ssh.execute    command=cat ${fullfile}          connection=${abil_cnx}
    #Log     \nMODIFIED ${fullfile} CONTENT:\n${res}     console=${DEBUG_MODE_CONSOLE}
    #save moifications for debug case:
    ssh.execute    command=cp ${fullfile} ${full_save_modif_script}         connection=${abil_cnx}
