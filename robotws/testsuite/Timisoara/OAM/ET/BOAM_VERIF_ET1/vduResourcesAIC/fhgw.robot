*** Settings ***
Documentation
#...   jie.8.liu@nokia-sbell.com

#*** Variables ***

*** Keywords ***
############################## FHGW status keyword ##############################

Restore FHGW Status
    ${channel}  Connect to FHGW   alias=default
    ${initial_prompt}=   issh.set prompt     \\[y/N\\]:
    issh.Execute     command=fhgwcli has unlock managed-object-type FMOD    check_result=${False}   alias=default
    issh.set prompt  ${initial_prompt}
    ${out}  issh.Execute     command=y   check_result=${False}   alias=default
    ${cmd}=  set variable   fhgwcli has show state managed-object-type FMOD
    ${out}   issh.Execute   command=${cmd}  check_result=${False}   alias=default
    Should contain  ${out}  UNLOCKED
    Disconnect From FHGW

Get variable from NOM intergate file
    log to console   Get variable from intergate file
    ${USEFULL_VARIABLE}   Get Configuraion From Integration File   fhgw
    ${FHGW_DN_NAME}   set variable   ${USEFULL_VARIABLE['integratedId']}
    ${NEVERSION_NAME}  set variable   ${USEFULL_VARIABLE['neVersion']}
    ${AGENTID}  set variable   ${USEFULL_VARIABLE['agentId']}

    set test variable   ${FHGW_DN_NAME}
    set test variable   ${AGENTID}

    @{DN}=     split_string    ${FHGW_DN_NAME}   /
    ${PLAN_NAME_NE}   set variable   ${DN[1]}
    @{NE}=     split_string    ${PLAN_NAME_NE}   -
    ${PLAN_NAME}   set variable    ${NE[0]}_${NE[1]}
    ${DN_NAME}   set variable    ${NE[0]}-${NE[1]}
    ${DN_TYPE}   set variable     ${NE[0]}
    ${DN_ID}     set variable    ${NE[1]}
    set test variable   ${PLAN_NAME}
    set test variable   ${NEVERSION_NAME}
    set test variable   ${DN_NAME}
    set test variable   ${DN_TYPE}
    set test variable   ${DN_ID}


Import plan from NOM
    log to console   Import plan from NOM
#    ${path_of_fhgw_user_config}=   Get FHGW Config     gnb_index=0   vdu_index=0   fhgw_index=0
    ${local_path_of_config_dir}=     set variable
    ...  ${tl.gnbs[0].dus[0].fhgws[0].user_config_path}
    ${config_file_path}  ${config_file_name}=  split path  ${local_path_of_config_dir}

    ${local_path_of_config_file}=    set variable    ${config_file_path}/${PLAN_NAME}.xml

    ${nom_alias}=  SSH To NOM
    ${import_plantime}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"     alias=${nom_alias}
    ${import_plantime}=    Strip String     ${import_plantime}
    ${import_plantime}=    Split String     ${import_plantime}
    Set Suite Variable    ${import_plantime}
    log to console    ${import_plantime}
    Disconnect Interactive Connection  alias=${nom_alias}

    nom_selenium.login     ${NOM_1_WEBUI_LINK}

    nom_selenium.import_plan       ${local_path_of_config_file}    ${PLAN_NAME}_${import_plantime[1]}


Operate plan from CNMS side
    [Arguments]     ${download_operation}  ${validation_operation}   ${active_operation}
    ${cmd1} =  set variable   curl -v http://operations-execution.neo.svc.cluster.local/api/operations/v1/startRoot
    ${cmd2} =  set variable   "Content-Type: application/json"
    ${cmd3} =  set variable   ' {"operationName":"ne3s-plan-provision", "userName": "user", "operationAttributes":
    ${cmd4} =  set variable   {"planName": "${PLAN_NAME}_${import_plantime[1]}", "operations": {"download": ${download_operation},
    ${cmd5} =  set variable   "validation": ${validation_operation}, "activation": ${active_operation}}}}'
    ${cmd} =   set variable     ${cmd1} -H ${cmd2} -d ${cmd3} ${cmd4} ${cmd5}

    ${fhgw_alias}=   get unique id
    Connect to FHGW   alias=${fhgw_alias}
    ${STAR_TIME}    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"    alias=${fhgw_alias}
    log to console     ${STAR_TIME}
    ${STAR_TIME}=    Strip String     ${STAR_TIME}
    ${STAR_TIME}=    Split String     ${STAR_TIME}
    Set Suite Variable    ${STAR_TIME}
    log to console     ${STAR_TIME}
    Disconnect Interactive Connection  alias=${fhgw_alias}    #ssh to FHGW and get start time from FHGW

    ${connection}=  SSH To NOM
    issh.execute     ${cmd}   check_result=${False}   alias=${connection}
    Disconnect Interactive Connection  alias=${connection}

    sleep  90s

    ${fhgw_alias}=   get unique id
    Connect to FHGW   alias=${fhgw_alias}
    ${END_TIME}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"     alias=${fhgw_alias}
    ${END_TIME}=    Strip String     ${END_TIME}
    ${END_TIME}=    Split String     ${END_TIME}
    Set Suite Variable    ${END_TIME}
    log to console    ${END_TIME}
    Disconnect Interactive Connection  alias=${fhgw_alias}


Check the journal from FHGW side
    [Arguments]      ${journal_log_name}    ${plan_status}
    ${fhgw_alias}=   get unique id
    Connect to FHGW   alias=${fhgw_alias}

    ${cmd} =   set variable
    ...   journalctl --since="${STAR_TIME[0]} ${STAR_TIME[1]}" --until="${END_TIME[0]} ${END_TIME[1]}">/root/${journal_log_name}.log
    ${out}   issh.Execute  command= ${cmd}   alias=${fhgw_alias}
    ${result}     issh.Execute  command=cat ${journal_log_name}.log | grep ${plan_status} | grep success*    alias=${fhgw_alias}

    should not be empty    ${result}
    Disconnect Interactive Connection  alias=${fhgw_alias}


Get FHGW Package info
    [Arguments]    ${sw_package}
#    ${fhgw_build_info}=     split_string    ${sw_package_info}   _
#    ${sw_package}   set variable    ${fhgw_build_info[0]}_${fhgw_build_info[1]}_${fhgw_build_info[3]}
    log to console   ${sw_package}
    @{fhgw_version_list}=     split_string    ${sw_package}   _
    ${fhgw_version_name}   set variable   ${fhgw_version_list[0]}
    ${fhgw_version_num}    set variable    ${fhgw_version_list[1]}
    @{fhgw_num_list}      split_string     ${fhgw_version_num}  .
    ${fhgwversion}        set variable     ${fhgw_num_list[0]}A
    ${build_info}   set variable    ${fhgw_version_name}${fhgwversion}/${fhgw_version_name}_${fhgw_version_num}/${sw_package}
    ${report_build}   set variable    report-${fhgw_version_name}_${fhgw_version_num}
    ${report_info}    set variable   ${fhgw_version_name}${fhgwversion}/${fhgw_version_name}_${fhgw_version_num}/${report_build}
    ${package_link}   set variable     https://bhisoj70.apac.nsn-net.net/artifactory/fhgw-releasedbuilds/builds/${build_info}.tar.gz
    ${report_link}    set variable     https://bhisoj70.apac.nsn-net.net/artifactory/fhgw-releasedbuilds/builds/${report_info}.txt
    [Return]   ${package_link}   ${report_link}


Import integrate plan from NOM
    [Arguments]     ${integrate_plan}   ${plan_type}
    [Documentation]  Import integrate plan from NOM.
    ...    author: jie.8.liu@nokia-sbell.com
    ...    modified by:        <12-11-2020>, <j9liu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index    plan_type  | No |  Import integrate plan from NOM  |

#    ${local_path_of_config_dir}=     set variable
#    ...  ${tl.gnbs[0].cloud_deployment.default_cfg_dir}

    ${local_path_of_config_dir}=     set variable
    ...  ${tl.gnbs[0].dus[0].fhgws[0].user_config_path}
     ${config_file_path}  ${config_file_name}=  split path  ${local_path_of_config_dir}

    ${local_path_of_config_file}=    set variable    ${config_file_path}/${integrate_plan}.xml

    ${nom_alias}=  SSH To NOM
    ${import_plantime}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"     alias=${nom_alias}
    ${import_plantime}=    Strip String     ${import_plantime}
    ${import_plantime}=    Split String     ${import_plantime}
    Set Suite Variable    ${import_plantime}
    log to console    ${import_plantime}
    Disconnect Interactive Connection  alias=${nom_alias}

    nom_selenium.login     ${NOM_1_WEBUI_LINK}
    ${integrate_with_plan}=    set variable      ${integrate_plan}_${import_plantime[1]}
    nom_selenium.import_plan       ${local_path_of_config_file}    ${integrate_with_plan}      ${plan_type}
    [Return]    ${integrate_with_plan}

Import FHGW upgrade or downgrade package via NOM
    [Arguments]   ${fhgw_package}
    [Documentation]  Import FHGW upgrade or downgrade package via NOM.
    ...    author: jie.8.liu@nokia-sbell.com
    ...    modified by:        <16-11-2020>, <j9liu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  package_build  | No |  Import FHGW upgrade or downgrade package via NOM  |
#    ${fhgw_build_info}=     split_string    ${sw_package_info}   _
#    ${package_build}   set variable    ${fhgw_build_info[0]}_${fhgw_build_info[1]}_${fhgw_build_info[3]}
    log to console   ${fhgw_package}
    ${package_path} =   set variable    /home/cloud-user/fhgw_package
    ${cmd1} =    set variable    curl -X POST http://sw-inventory.neo.svc.cluster.local/api/swi/v1/packages/FHGW/import -F
    ${cmd2} =    set variable    uploadfile=@./${fhgw_package}.tar.gz -u "cnms04:Qwer_1234" -H "Content-Type:multipart/form-data"
    ${cmd} =     set variable    ${cmd1}${cmd2}
    ${nom_alias}=  SSH To NOM
    ${fhgw_build_link}  ${fhgw_report_link}  Get FHGW Package info   ${fhgw_package}
    ${file_info}=    issh.Execute    command=cd ${package_path}     alias=${nom_alias}
    issh.Execute    rm -rf FHGW*     alias=${nom_alias}
    ${out}   issh.Execute    wget ${fhgw_build_link}   alias=${nom_alias}
    sleep   10s
    issh.Execute      command= ${cmd}     alias=${nom_alias}
    Disconnect Interactive Connection  alias=${nom_alias}


Generate Deintegrate Config File which integrate via plan
   [Arguments]   ${ne_type}    ${ne_id}
   [Documentation]    Generate deintegrate config according to integrate config file.
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <23-11-2020>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  path_of_integrate_config_file  |  Yes  |  Path of ne integrate config file  |
    ...    |  path_of_deintegrate_config_file  |  Yes  |  Where to save deintegrate config file  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Generate Deintegrate Config File |  /tmp/cu0.json   |   /tmp/cu0_deintegrate.json  |
    ${path_of_deintegrate_config_file}=  get a file   integrate_config    deintegrate_config_file.json
    ${ne_type}=  Convert To Uppercase   ${ne_type}
    ${integrated_id}=  set variable     ${ne_type}-${ne_id}
    ${deintegate_config_file_content}=    set variable
    ...   {"neIntegrationData": {"integratedId": "${integrated_id}","neType": "MRBTS" } }
    create file     ${path_of_deintegrate_config_file}   ${deintegate_config_file_content}
    [Return]  ${path_of_deintegrate_config_file}

Upload Integration Config File To NOM which integrte with plan
   [Arguments]   ${ne_type}    ${ne_id}   ${path_of_deintegrate_config_file}
   [Documentation]    Generate integrate/deintegrate config file and upload config files to nom.
    ...  author:           jie.8.liu@nokia-sbell.com
    ...  modified by:        <23-11-2020>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw  |
    ...    |  ne_id  |  No  |  cu/vdu/fhgw id  |
    ...    |  path_of_deintegrate_config_file  |  No  |  deintegrate file in local path   |
    ...    *RETURN VALUE*
    ...    ${remote_path_of_config_dir}
    ...    ${remote_deintegrate_config_file_name}
    ...    Example
    ...    | Upload Integration Config File To NOM |  FHGW   |  5555  |  path |

   ${remote_path_of_config_dir}=    set variable   /home/cloud-user/ta_integrate
   ${remote_deintegrate_config_file_name}=   set variable   ${ne_type}${ne_id}_deintegrate_config.json
   ${connection}=   SSH To NOM
   issh.execute   mkdir -p ${remote_path_of_config_dir}   check_result=${False}   alias=${connection}

   issh.upload file   local_path=${path_of_deintegrate_config_file}
   ...                remote_path=${remote_path_of_config_dir}/${remote_deintegrate_config_file_name}
   ...                alias=${connection}
   ${output}=  issh.execute   ls ${remote_path_of_config_dir} --color=never  check_result=${False}  alias=${connection}
   should contain    ${output}   ${remote_deintegrate_config_file_name}   Upload deintegrate config file to nom failed!
   [Return]    ${remote_path_of_config_dir}     ${remote_deintegrate_config_file_name}
   [Teardown]  Disconnect Interactive Connection   ${connection}


Deintegrate NE From NOM which integrte with plan
   [Arguments]       ${path_of_config_file}     ${deintegrate_config_file_name}     #${ne_type}    ${ne_id}
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/
   [Documentation]    Deintegrate ne from nom by ne type, ne index and which nom will be deintegrated from.
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <26-11-2020>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  Yes  |  Which type of ne will be deintegrated, can be cu/vdu/fhgw   |
    ...    |  ne_id  |  No  |  NE is, such as 5555  |
    ...    |  path_of_config_file  |  No  |  deintegrate file conent   |
    ...    |  deintegrate_config_file_name  |  No  |  deintegrate file name   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Deintegrate NE From NOM |  fhgw   |  5555 |   path  |   deintegrate_fhgw_5555  |

   ${file_name_obj}=     Split String    ${deintegrate_config_file_name}   .
   ${file_prefix}=  set variable  ${file_name_obj[0]}
   ${opt_1}=  set variable    auto-deintegrate?verbose
   ${opt_2}=  set variable    -H 'Content-type: application/json'
   ${connection}=  SSH To NOM
   issh.execute    cd ${path_of_config_file}   check_result=${False}   alias=${connection}
   ${nom_link}=   set variable    ${nom_integrate_link}
   ${cmd}=  set variable
   ...   curl -s '${nom_link}${opt_1}' ${opt_2} -d @${deintegrate_config_file_name} |jq '.' > ${file_prefix}__output_deintegrate_result.json
   issh.execute   rm -rf ${file_prefix}__output_deintegrate_result.json  check_result=${False}   alias=${connection}
#   log to console   \n*** Start execute ${ne_type} deintegrate command ***
   log to console   ${cmd}
   issh.set_timeout   120    alias=${connection}
   issh.execute     ${cmd}   check_result=${False}   alias=${connection}
#   log to console    \n*** Download ${ne_type} deintegrate log to local***
   [Teardown]   Disconnect Interactive Connection  alias=${connection}

#if __name__ == '__main__':
##    nom = nom()
##    nom.login("https://neo-hosting-page.srncnms04.srnblr.nsn-rdnet.net/")
#   Import FHGW upgrade or downgrade package via NOM    FHGW_20.014.1.8_f1b13c9
Change FHGW configuration from FHGW side
    [Documentation]     Change the FHGW FMOD Lock and Unlock Status
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ...  |  ...  |  ...  |
    ...    *RETURN VALUE*
    ...
    log to console  Change FHGW configuration from FHGW side
    ${channel}  Connect to FHGW   alias=default
    ${cmd}=  set variable   fhgwcli has show state managed-object-type FMOD
    ${out}   issh.Execute   command=${cmd}  check_result=${False}   alias=default
    Should contain  ${out}  UNLOCKED

    ${initial_prompt}=   issh.set prompt     \\[y/N\\]:
    issh.Execute     command=fhgwcli has lock managed-object-type FMOD    check_result=${False}   alias=default
    issh.set prompt  ${initial_prompt}
    ${out}  issh.Execute     command=y   check_result=${False}   alias=default
    sleep  120s
    Should contain  ${out}  successfully

    ${out}   issh.Execute   command=${cmd}  check_result=${False}   alias=default
    Should contain  ${out}  LOCKED
    Disconnect From FHGW

Check the FHGW FMOD Status
    [Documentation]     Change the FHGW FMOD Lock and Unlock Status
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  command  |  YES  |  ...  |
    ...    |  status   |  YES  |  ...  |
    ...    *RETURN VALUE*
    ...
    [Arguments]  ${command}   ${status}
    ${channel}  Connect to FHGW   alias=default
    ${out}   issh.Execute   command=${command}  check_result=${False}   alias=default
    Should contain  ${out}  ${status}
    Disconnect From FHGW

Change the FHGW FMOD Lock and Unlock Status
    [Documentation]     Change the FHGW FMOD Lock and Unlock Status
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  command  |  YES  |  ...  |
    ...    |  status   |  YES  |  ...  |
    ...    *RETURN VALUE*
    ...
    [Arguments]  ${command}   #${status}
    ${channel}  Connect to FHGW   alias=default
    ${initial_prompt}=   issh.set prompt     \\[y/N\\]:
    issh.Execute     command=${command}    check_result=${False}   alias=default
    issh.set prompt  ${initial_prompt}
    ${out}  issh.Execute     command=y   check_result=${False}   alias=default
    Disconnect From FHGW

From NOM Side Check the NE Alarm Upload Success
    [Documentation]     From NOM Side Check the NE Alarm Upload Success
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  NE_ID  |  YES  |  FHGW-5555  |
    ...    |  alarm  |  YES  |  ...  |
    ...    *RETURN VALUE*
    ...
    [Arguments]   ${ne_id}   ${special_alarm}
    nom_selenium.login     ${NOM_1_WEBUI_LINK}
    @{alarms}    nom_selenium.get_historical_alarms  distinguished_name=${ne_id}   specific_problem=${special_alarm}
    ${out}   set variable   ${alarms[0]}
    ${out1}   set variable   ${alarms[0]['specific_problem']}
    run keyword if   ${out1}=='${special_alarm}'    log to console  alarm upload success
    [Teardown]  nom_selenium.Logout

Upload FHGW plan from NOM side success
    [Documentation]    Upload FHGW plan from NOM side success
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  no  |  ...  |  ...  |
    ...    *RETURN VALUE*
    ...
    log to console  Upload FHGW plan from NOM side success
    nom_selenium.login     ${NOM_1_WEBUI_LINK}

    ${channel}  Connect to FHGW   alias=default
    ${STAR_TIME}    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"
    log to console     ${STAR_TIME}
    ${STAR_TIME}=    Strip String     ${STAR_TIME}
    ${STAR_TIME}=    Split String     ${STAR_TIME}
    Set Suite Variable    ${STAR_TIME}
    log to console     ${STAR_TIME}
    Disconnect Interactive Connection  alias=default    #ssh to FHGW and get start time from FHGW

    nom_selenium.configuration_upload   ${FHGW_DN_NAME}  #now the keyword not ok
    [Teardown]  nom_selenium.Logout

From NOM side check the FHGW parameter change success
    [Documentation]    From NOM side check the FHGW parameter change success
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  no  |  ...  |  ...  |
    ...    *RETURN VALUE*
    ...
    log to console    From NOM side check the FHGW parameter change success

    nom_selenium.login     ${NOM_1_WEBUI_LINK}
    ${outfile}    nom_selenium.export_actual_configuration      ${FHGW_DN_NAME}

    ${planfile}=    Parse XML     ${outfile}
    ${dist_name}  set variable    ${FHGW_DN_NAME}/EQM-1/FMOD-1
    ${statues_value}=    XML.Get Element Text      ${planfile}   .//managedObject[@distName="${dist_name}"]/p[@name='availabilityStatus']

    ${statues_value}    run    command=cat ${outfile} | grep availabilityStatus
    Should contain     ${statues_value}   4
    [Teardown]  nom_selenium.Logout

Check and Trigger new alarm from FHGW
    [Documentation]    Check and Trigger new alarm from FHGW
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ${alarm}  |  yes  |  ...  |
    ...    *RETURN VALUE*
    ...
    [Arguments]      ${alarm}
    log to console  Check and Trigger new alarm from FHGW
    ${channel}  Connect to FHGW   alias=default
    ${out}   issh.Execute    command=flexalarm --clear -sp=${alarm} -mo=test_alarm -ap=test_alarm_ap     alias=default
    sleep  5s
    ${out}   issh.Execute    command=flexalarm --raise -sp=${alarm} -mo=test_alarm -ap=test_alarm_ap      alias=default
    Disconnect From FHGW

Clear alarm from FHGW
    [Documentation]    Clear alarm from FHGW
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ${alarm}  |  yes  |  ...  |
    ...    *RETURN VALUE*
    ...
    [Arguments]      ${alarm}
    log to console  Step:Repair alarm from FHGW
    ${channel}  Connect to FHGW   alias=default
    ${out}   issh.Execute    command=flexalarm --clear -sp=${alarm} -mo=test_alarm -ap=test_alarm_ap       alias=default
    Disconnect From FHGW

Acknowledge alarm from CNMS WEBUI
     [Documentation]    Acknowledge alarm from CNMS WEBUI
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_id  |  yes  |  FHGW-555  |
    ...    *RETURN VALUE*
    ...
    [Arguments]  ${ne_id}
    log to console  Acknowledge alarm from CNMS WEBUI
    run keyword and ignore error   nom_selenium.login     ${NOM_1_WEBUI_LINK}
    ${acknowledge_user}  nom_selenium.acknowledge_alarm  distinguished_name=${ne_id}
    run keyword if   "${acknowledge_user}" == "${ACKNOWLEDGE_USER}"    log to console  alarm acknowledge success

Provision pm plan from NOM
    [Documentation]    Provision pm plan from NOM
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ...  |  ...  |  ...  |
    ...    *RETURN VALUE*
    ...
    log to console    Provision pm plan from NOM
    Operate plan from CNMS side    true  true  true
    Check the journal from FHGW side    journal_provision     Activation

    ${nom_alias}=  SSH To NOM

    ${initial_prompt}=   issh.set prompt   prompt_str=[^\\\/\^]   alias=${nom_alias}
    ${import_plantime}=    issh.Execute    command=sudo -i   check_result=${False}   alias=${nom_alias}

    issh.set prompt     prompt_str=[^\"\']       alias=${nom_alias}                            #####^/[a-z]*[A-Z]*\$
    ${out}  issh.Execute     command=kubectl exec -it -nneo neo-minio-0 sh    check_result=${False}   alias=${nom_alias}

    ${import_plantime}=    issh.Execute    command=ls    check_result=${False}   alias=${nom_alias}
    ${cmd} =  set variable    rm -rf /export/pm-file-transfer/omes/HQZ-${NEVERSION_NAME}
    ${import_plantime}=    issh.Execute    command=${cmd}    check_result=${False}   alias=${nom_alias}

    Disconnect Interactive Connection  alias=${nom_alias}

Check PM files sync success from NOM
    [Documentation]    Check PM files sync success from NOM
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ...  |  ...  |  ...  |
    ...    *RETURN VALUE*
    ...
    log to console    Check PM files sync success from NOM
    Sleep  20min
    ${nom_alias}=    SSH To NOM
    ${initial_prompt}=   issh.set prompt    prompt_str=[^\\\/\^]     alias=${nom_alias}
    ${import_plantime}=    issh.Execute    command=sudo -i   check_result=${False}   alias=${nom_alias}

    issh.set prompt     prompt_str=[^\"\']       alias=${nom_alias}                        #####^/[a-z]*[A-Z]*\$
    ${out}  issh.Execute     command=kubectl exec -it -nneo neo-minio-0 sh    check_result=${False}   alias=${nom_alias}

    ${import_plantime}=    issh.Execute    command=ls    check_result=${False}   alias=${nom_alias}
    ${cmd} =  set variable     cd /export/pm-file-transfer/omes/HQZ-${NEVERSION_NAME}      alias=${nom_alias}
    ${import_plantime}=    issh.Execute    command=${cmd}     check_result=${False}   alias=${nom_alias}
    Disconnect Interactive Connection  alias=${nom_alias}

Check the SyncStatus
    [Documentation]    check clock sync status
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <27-07-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  dn_name  |  Yes  |  plan name for import plan  |
    ...    |  sync_status  |  Yes  |  1-- lock;0--unlock  |
    ...    *RETURN VALUE*
    ...
    [Arguments]    ${dn_name}    ${sync_status}
    log to console   Check the SyncStatus
    nom_selenium.login     ${NOM_1_WEBUI_LINK}
    ${outfile}    nom_selenium.export_actual_configuration      ${dn_name}

    ${planfile}=    Parse XML      ${outfile}
    ${dist_name}  set variable    ${dn_name}/MNL-1/SYNC-1/CLOCK-1
    ${statues_value}=    XML.Get Element Text      ${planfile}   .//managedObject[@distName="${dist_name}"]/p[@name='syncStatus']
    Should contain     ${statues_value}   ${sync_status}
    ${cmd}   set variable   rm -rf ${outfile}
    ${out}   run    command= ${cmd}
    [Teardown]  nom_selenium.Logout

#************USE REST API**************#

Import FHGW plan from NOM via Rest
    [Documentation]   import plan use rest
    ...   author:             jie.8.liu@nokia-sbell.com
    ...   write by:        <7-12-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  Yes  |  plan name for import plan  |
    ...    |  fhgw_index  |  Yes  |  defaute 0 |
    ...    |  pm_interval_time  |  Yes  |  fhgw pm value , no default value |
    ...    *RETURN VALUE*
    ...
    [Arguments]   ${gnb_index}=0   ${fhgw_index}=0    ${pm_interval_time}=15
    log to console   Import plan from NOM
    ${Delta_plan_path}  ${Delta_Plan_name}  _Generate FHGW Delta PLan
    ...   gnb_index=${gnb_index}   fhgw_index=${fhgw_index}   pm_interval_time=${pm_interval_time}
    ${client_id}  Wait Until Keyword Succeeds  180  10   Nom Rest Login
	nom_rest.import_plan  path_to_plan=${Delta_plan_path}  name=${Delta_Plan_name}
    sleep    10
    [Return]    ${Delta_plan_path}    ${Delta_Plan_name}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

_Generate FHGW Delta plan
    [Arguments]   ${gnb_index}=0   ${fhgw_index}=0   ${pm_interval_time}=15
    [Documentation]    Generate delta/dedelta config for specified ne.
    ...  create by:        <8-Nove-2021>, jie.8.liu@nokia-sbell.com
    ${timestamp}    Get Timestamp
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    set variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_root_password}=    set variable   ${fhgw_config["USERS"]["root_password_plain"]}
    ${fhgw_ssh_ip}=  Set Variable
    ...   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    ${delta_file_name}=  set variable      cu${gnb_index}_fhgw${fhgw_index}.json
    ${dedelta_file_name}=  set variable    cu${gnb_index}_fhgw${fhgw_index}_dedelta.json
    ${path_of_delta_config_file}=   get a file    delta_config   ${delta_file_name}
    ${path_of_dedelta_config_file}=   get a file    delta_config   ${dedelta_file_name}
    ${Plan_name}   Set Variable    ${fhgw_id}_plan_${timestamp}
    ${plan_file}   _Generate FHGW Delta Plan content
    ...   ${Plan_name}   ${fhgw_id}    ${fhgw_ssh_ip}   ${fhgw_id}  ${fhgw_root_password}   ${pm_interval_time}
    ${delta_plan}  Get A File  delta_Plan  ${Plan_name}.xml
    create file   ${delta_plan}   ${plan_file}
    [Return]   ${delta_plan}  ${Plan_name}

_Generate FHGW Delta Plan content
    [Arguments]   ${Plan_name}   ${mrbts_id}      ${pm_interval_time}       #${oam_ip}  ${ne_id}  ${fhgw_password}
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  create by:        <8-Nove-2021>, jie.8.liu@nokia-sbell.com
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8" standalone="yes"?><raml version="2.1" xmlns="raml21.xsd">
    ${xml2}   set variable   <cmData type="plan" scope="changes" name="${Plan_name}">
    ${xml3}   set variable   <header>
    ${xml4}   set variable   ${SPACE}<log action="update" dateTime="2020-05-22T08:57:52+02:00">Creating 1 MO(s)</log>
    ${xml5}   set variable   </header>
    ${xml6}   set variable   <managedObject distName="HQZ-FHGW/FHGW-${mrbts_id}/MNL-1/PMMNL-1"
    ${xml61}   set variable   class="com.nokia.fhgw:PMMNL" version="FHGW" operation="update">
    ${xml7}   set variable   ${SPACE}${SPACE}${SPACE}${SPACE}<p name="miCpuUsage">${pm_interval_time}</p>
    ${xml8}   set variable   ${SPACE}${SPACE}${SPACE}${SPACE}<p name="miDiskUsage">${pm_interval_time}</p>
    ${xml9}   set variable   ${SPACE}${SPACE}${SPACE}${SPACE}<p name="miMemUsage">${pm_interval_time}</p>
    ${xml10}   set variable   </managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml6}${xml61}${xml7}${xml8}${xml9}${xml10}
    [Return]   ${xmlfile}

Check alarm status via NOM rest API
    [Arguments]   ${specific_problem}
    [Documentation]    Check alarm status via NOM rest API
    ...  create by:        <13-12-2021>, jie.8.liu@nokia-sbell.com
    ${fhgw_config}    ${fhgw_id}   ${fhgw_root_password}      Get FHGW info from FHGW config file

    ${client_id}  Wait Until Keyword Succeeds  180  10   Nom Rest Login
    ${alarms_info}    NOM Get Active Alarms Via Rest     FHGW-${fhgw_id}
    log to console    ${alarms_info}
    ${length}     get length    ${alarms_info}
    log to console     ${length}
    FOR    ${i}    IN RANGE    ${length}
       Exit For Loop If    '&{alarms_info[${i}]}[specific_problem]' == '${specific_problem}'
       log to console     ${i}
    END
    ${system_alarm_id}=    Set Variable      &{alarms_info[${i}]}[system_alarm_id]
    log to console    ${system_alarm_id}
    [Return]    ${system_alarm_id}     ${fhgw_id}