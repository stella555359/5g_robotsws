
*** Settings ***
Documentation
...          Tests to add a bearer in basic_wts_step2.cfg file

Resource                            ../Connect.robot
Resource                            ../Setup.robot
Resource                            ../SetConfig.robot

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
Suite Teardown                      Suite teardown

*** Test Cases ***

Add Bearer
    [Documentation]                 Add a new Bearer in Basic_wts_step2.cfg File
    ${5qi}                          set variable    7
    ${proto}                        set variable    tcp
    Dated log                       \nSTART

    # Bearer Creation:
    Dated log                       Create Bearer for 5qi=${5qi} and proto=${proto}
    Create Bearer in Cfg File       5qi=${5qi}
    ...                             proto=${proto}


#=======================================================================================================================
# KW to create lots of SA or NSA UEs or modify a field in config file on ePCSIM
#=======================================================================================================================

*** Keywords ***

Create Bearer in Cfg File
    [Documentation]                 Create new bearer in basic_wts_step2.cfg file. This means:
    ...                             - create a new set_qosflow and set_qosrule items.
    ...                             - update the following nwslice_set parameter: qos_flows and qos_rules.
    ...                             Argument : 5qi : an integer
    ...                             Argument : proto : could be tcp or udp
    [Arguments]                     ${5qi}
    ...                             ${proto}
    ${cfg_file}                     set variable                ${tl.core.dir_path}/${tl.core.cfg_filename}
    # Step 1 : Get last set_qosflow id
    ${last_qosflow_id} =            Get Last Item in Cfg File
    ...                                 item_id=set_qosflow
    ...                                 cfg_file=${cfg_file}
    # Step 2 : Create a new set_qosflow instance
    ${new_qosflow_id} =             Add QosFlow Item in Cfg File
    ...                                 item_id=${last_qosflow_id}
    ...                                 5qi=${5qi}
    ...                                 cfg_file=${cfg_file}
    # Step 3 : Get last set_qosrule id
    ${last_qosrule_id} =            Get Last Item in Cfg File
    ...                                 item_id=set_qosrule
    ...                                 cfg_file=${cfg_file}
    # Step 4 : Create a new set_qosrule instance
    ${new_qosrule_id} =             Add QosRule Item in Cfg File
    ...                                 item_id=${last_qosrule_id}
    ...                                 proto=${proto}
    ...                                 qosflow_id=${new_qosflow_id}
    ...                                 cfg_file=${cfg_file}
    # Step 5 : Update the nwslice_set item with new set_qosflow id and set_qosrule id
    Update NwSlice in Cfg File      qosflow_id=${new_qosflow_id}
    ...                             qosrule_id=${new_qosrule_id}
    ...                             cfg_file=${cfg_file}

Get Last Item in Cfg File
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${item_id}
    ...                             ${cfg_file}
    ${nb_item} =                    Run                         grep ${item_id} ${cfg_file} | wc -l
    [Return]                        ${nb_item}


Add QosFlow Item in Cfg File
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${item_id}
    ...                             ${5qi}
    ...                             ${cfg_file}
    # Create a new set_qosflow item:
    ${new_id}                       evaluate                    ${item_id} + 1
    ${ref_item}                     set variable                set_qosflow id=${item_id}
    ${new_item}                     set variable                set_qosflow id=${new_id}
    ${field}                        set variable                5qi
    ${new_val}                      set variable                ${5qi}
    ${sed_cmd_part1}                set variable                sed --follow-symlinks -i '/^${ref_item} /p;
    ${sed_cmd_part2}                set variable                s/${ref_item} /${new_item} /;
    ${sed_cmd_part3}                set variable                s/${new_item} ${field}=[[:graph:]]*/${new_item} ${field}=${new_val}/'
    ${sed_cmd}                      Catenate                    ${sed_cmd_part1}    ${sed_cmd_part2}    ${sed_cmd_part3}
    Run                             ${sed_cmd} ${cfg_file}
    [Return]                        ${new_id}


Add QosRule Item in Cfg File
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${item_id}
    ...                             ${proto}
    ...                             ${qosflow_id}
    ...                             ${cfg_file}
    # Create a new set_qosrule item:
    ${new_id}                       evaluate                    ${item_id} + 1
    ${ref_item}                     set variable                set_qosrule id=${item_id}
    ${new_item}                     set variable                set_qosrule id=${new_id}
    ${field}                        set variable                proto
    ${new_val}                      set variable                ${proto}
    ${sed_cmd_part1}                set variable                sed --follow-symlinks -i '/^${ref_item} /p;
    ${sed_cmd_part2}                set variable                s/${ref_item} /${new_item} /;
    ${sed_cmd_part3}                set variable                s/${new_item} ${field}=[[:graph:]]*/${new_item} ${field}=${new_val}/'
    ${sed_cmd}                      Catenate                    ${sed_cmd_part1}    ${sed_cmd_part2}    ${sed_cmd_part3}
    Run                             ${sed_cmd} ${cfg_file}
    # Update the qos_flow param in the new set_qosrule item:
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -e '/^${new_item} / {s/ qos_flow=[[:graph:]]*/ qos_flow=${qosflow_id}/}'
    Run                             ${sed_cmd} ${cfg_file}
    [Return]                        ${new_id}


Update NwSlice in Cfg File
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${qosflow_id}
    ...                             ${qosrule_id}
    ...                             ${cfg_file}
    ${ref_nwslice}                  set variable                nwslice_set id=
    ${ref_qosflow}                  set variable                qos_flows
    ${old_qosflow} =                Run                         grep "${ref_nwslice}" ${cfg_file}|cut -f3 -d\=|cut -f1 -dq| sed "s/ //g"
    ${new_qosflow}                  set variable                ${old_qosflow},${qosflow_id}
    ${sed_cmd_part1}                set variable                sed --follow-symlinks -i '/^${ref_nwslice} /p;
    ${sed_cmd_part2}                set variable                s/ ${ref_qosflow}=${old_qosflow}/ ${ref_qosflow}=${new_qosflow}/'
    ${sed_cmd}                      Catenate                    ${sed_cmd_part1}    ${sed_cmd_part2}
    Run                             ${sed_cmd} ${cfg_file}

    ${ref_qosrule}                  set variable                qos_rules
    ${old_qosrule} =                Run                         grep "${ref_nwslice}" ${cfg_file}|cut -f4 -d\=|cut -f1 -ds| sed "s/ //g"
    ${new_qosrule}                  set variable                ${old_qosrule},${qosrule_id}
    ${sed_cmd_part1}                set variable                sed --follow-symlinks -i '/^${ref_nwslice} /p;
    ${sed_cmd_part2}                set variable                s/ ${ref_qosrule}=${old_qosrule}/ ${ref_qosrule}=${new_qosrule}/'
    ${sed_cmd}                      Catenate                    ${sed_cmd_part1}    ${sed_cmd_part2}
    Run                             ${sed_cmd} ${cfg_file}
