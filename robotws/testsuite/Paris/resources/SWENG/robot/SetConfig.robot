*** Settings ***
Documentation
...             == Purpose ==
...             Library to provides some basics services to manipulate some Config file
...
...             == Description ==
...             This library aims at providing miscellaneous services to get/set some fields in some config files
...             on WTS (basic.cfg, airphone.xml) or on TL (swconfig.cfg).
...             Basic means they are based on some linux tools such grep or sed.
...             To manipulate more properly some structured files (.cfg, .xml), prefer the use of dedicated libraries
...             such as WtsCfgConfig.robot or WtsXmlConfig.robot.
...
...             *Services :*
...
...             | TxtConfig Init                    | To generate a .lua file from the .cfg one                      |
...             | Set Fields in swconfig DU         | To set some fields in a swconfig.txt file                      |
...             | Get XML AirPhoneConfig Path       | To retrieve name of AirPhoneConfig XML file in basic.cfg file  |
...             | Modify Field in WtsEmu Cfg File   | To modify a field in WTS basic.cfg file (use sed)              |
...             | Create UEs in Cfg File            | To create new UEs (up to 200) in basic_wts_step2.cfg file      |
...             | Create Bearer in Cfg File         | To create new bearer in basic_wts_step2.cfg file               |
...             | Modify UE Data in Cfg File        | To modify the UE nr_capa or cellId in basic_wts_step2.cfg file |
...             | Change NIDD Hidden param          | To Update a hidden NIDD parameter value in vendor file         |
...             | Change NIDD Hidden parameter list | To Update a hidden NIDD parameter list in vendor file          |
...             | Download Vendor File              | To download a vendor file                                      |
...

Resource          Restart.robot
Resource          Tools.robot
Library           ../python/StringTool.py
Library           ../python/TxtConfig.py    WITH NAME   TxtConfig
Library           ../python/OsTool.py

*** Variables ***
# ----- Global settings on swconfig file
${SWCONFIG_FILE}                    swconfig.txt
${SWCONFIG_PATH}                    /ffs/run/${SWCONFIG_FILE}

*** Keywords ***
#===========================================================================================================
#   KW to get/set some values in txt config file
#===========================================================================================================
TxtConfig Init
    [Documentation]                 Generate lua file from txt config file from WTS
    ...                             it means from basic...cfg file we will generate basic...lua
    ...                             will Lua syntax (exec(...command...), for loop, ...)
    ...                             It returns name (not path) of Lua config file
    [Arguments]                     ${nbUe}=1       ${nbSaUe}=0    ${list_of_UE_tobe_created}=${None}
    ${alias}                        SSH Wait For Connect                ${HOST_EPCSIM}
    # Download .cfg file locally
    ${TxtConfigLocalDir}            getTempDir
    Dated Log                       \tDownloading ${tl.core.dir_path}/${tl.core.cfg_filename} into ${TxtConfigLocalDir}
    ${outload}                      csn.download_file
    ...                                 remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                                 local_path=${TxtConfigLocalDir}/${tl.core.cfg_filename}
    ...                                 connection=${alias}
    # Generate .lua file upon nb of UE requested
    Dated Log                       \tGenerating Lua file with ${nbUe} UE
    ${LuaConfigName}                TxtConfig.generateLuaFile
    ...                                 path=${TxtConfigLocalDir}
    ...                                 name=${tl.core.cfg_filename}
    ...                                 nbUe=${nbUe}
    ...                                 nbSaUe=${nbSaUe}
    ...                                 list_of_UE_tobe_created=${list_of_UE_tobe_created}
    # Upload generated file (.lua) on WTS and clean the temporary dir
    Dated Log                       \tUploading ${TxtConfigLocalDir}/${LuaConfigName} into ${tl.core.dir_path}/${LuaConfigName}
    ${outload}                      csn.upload_file
    ...                                 remote_path=${tl.core.dir_path}/${LuaConfigName}
    ...                                 local_path=${TxtConfigLocalDir}/${LuaConfigName}
    ...                                 connection=${alias}
    OsTool.saveBasicFileWithPattern     pathname=${tl.core.dir_path}
    ...                                 fileName=${LuaConfigName}
    ...                                 logpath=${LOG_PATH}
    ...                                 pattern=Normalized_
    Dated Log                       \tCleaning the temporary repository: ${TxtConfigLocalDir}
    removeTempDir
    [Return]                        ${LuaConfigName}

#===========================================================================================================
#   KW to get/set some values in swconfig file
#===========================================================================================================
Set Fields in swconfig DU
    [Documentation]                 Generic service to set a list of parameters into swconfig file
    ...                             param_list should be a list of dictionaries, each containing a "field" and a "value"
    [Arguments]                     ${param_list}                           ${host}=${GNB_DU.entryCard[0]}
    ${local_file}                   set variable                            ${LOG_PATH}/${SWCONFIG_FILE}
    ${remote_file}                  set variable                            ${SWCONFIG_PATH}
    ${alias}                        SSH Wait For Connect                    host=${host}
    csn.download_file               remote_path=${remote_file}
    ...                             local_path=${local_file}
    ...                             connection=${alias}

    # Adding newline at the end of the file to avoid appending data on the same line
    # (this happens if the last line does not have newline char at the end)
    run                             echo "" >> ${local_file}

    setFieldsInFile                 srcFile=${local_file}                   paramList=${param_list}
    csn.upload_file                 local_path=${local_file}
    ...                             remote_path=${remote_file}
    ...                             connection=${alias}
    SSH Exec                        command=crasign ${remote_file}           alias=${alias}

#=======================================================================================================================
# SET of KW to set some parameters in AirphoneConfig file on ePCSIM
#=======================================================================================================================
Get XML AirPhoneConfig Path
    [Documentation]                 Read config file on EPCSIM the set uec ... file=... line to build path to AirPhone config file
    ...                             the KW returns EMPTY if xml file is not found in basic_setup.cfg
    ${alias}                        SSH Connect                             host=${HOST_EPCSIM}
    ${cfgPath}                      set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${cmd}                          set variable                            grep "^set_uec " ${cfgPath} | sed -e "s/.*file=//g" | cut -d " " -f1
    ${path}                         SSH Exec                                ${cmd}
    ...                             alias=${alias}
    ${path}                         Replace String                          ${path}
    ...                             set_uec                                 ${EMPTY}
    [Return]                        ${path.replace("\n","").replace("\r","")}

#=======================================================================================================================
# KW to modify a field in config file on ePCSIM
#=======================================================================================================================
Modify Field in WtsEmu Cfg File
    [Documentation]                 Modify an existing field in basic config file on ePCSim
    [Arguments]                     ${field}
    ...                             ${value}
    ${cfg_file}                     set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    # ${sed_cmd}                      set variable
    # ...                             sed -i "s/${field}=[[:graph:]]*/${field}=${value}/g" < ${cfg_file} 1<> ${cfg_file}
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i "s/${field}=[[:graph:]]*/${field}=${value}/g" ${cfg_file}
    Dated log                       Configure config file on ePCSim (${cfg_file})
    Dated Log                       \tSetting ${field} to ${value} in ${cfg_file} on ePCSim (${sed_cmd})
    SSH Wait For Connect and Cmd    command=sudo ${sed_cmd}                 host=${HOST_EPCSIM}

#=======================================================================================================================
# KW to create lots of SA or NSA UEs or modify a field in config file on ePCSIM
#=======================================================================================================================
Create UEs in Cfg File
    [Documentation]                 Create new UEs in basic_wts_step2.cfg file based on SA UE_1 or NSA UE_11.
    ...                             One retriction: no more than 200 UEs can be created !
    ...                             The reason is the limitation to the IP address used in set_bearer.
    [Arguments]                     ${nb_nsa_ues}=0
    ...                             ${nb_sa_ues}=0
    ${cfg_file}                     set variable                ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${nb_ues}                       evaluate                    ${nb_nsa_ues} + ${nb_sa_ues}
    Should Be True                  ${nb_ues}<=200              ERROR:You asked for ${nb_ues} UEs and it is limited to 200: Bye Bye!
    ${first_sa_id}                  evaluate                    1
    ${first_nsa_id}=                evaluate                    ${nb_sa_ues} + 1
    Run Keyword If                  ${nb_sa_ues}==0             Run Keywords
    ...                             Remove UE from Cfg File     cfg_file=${cfg_file}    ue_id=${FIRST_SA_UE_ID}
    ...                             AND
    ...                             Set New NSA Ref UE          cfg_file=${cfg_file}        new_id=${first_nsa_id}      first_nsa_id=${first_nsa_id}
    Run Keyword If                  ${nb_nsa_ues}==0            Remove UE from Cfg File     cfg_file=${cfg_file}        ue_id=${FIRST_NSA_UE_ID}
    ...         ELSE                Set New NSA Ref UE          cfg_file=${cfg_file}        new_id=${first_nsa_id}      first_nsa_id=${first_nsa_id}
    # Create ${nb_nsa_ues} NSA UEs starting from Id=${first_nsa_id}:
    FOR                             ${index}   IN RANGE   ${nb_nsa_ues}   1   -1
        ${ue_id}                    evaluate                    ${first_nsa_id} + ${index} -1
        Remove UE from Cfg File     cfg_file=${cfg_file}        ue_id=${ue_id}
        Create New UE               cfg_file=${cfg_file}        ue_id=${ue_id}          first_id=${first_nsa_id}   sa_or_nsa=NSA
    END
    # Create ${nb_sa_ues} SA UEs starting from Id=${first_sa_id}
    FOR                             ${index}   IN RANGE   ${nb_sa_ues}   1   -1
        ${ue_id}                    evaluate                    ${first_sa_id} + ${index} -1
        Remove UE from Cfg File     cfg_file=${cfg_file}        ue_id=${ue_id}
        Create New UE               cfg_file=${cfg_file}        ue_id=${ue_id}      first_id=${first_sa_id}   sa_or_nsa=SA
    END

Modify UE Data in Cfg File
    [Documentation]                 Modify an existing field in basic_wts_step2.cfg file on ePCSim
    [Arguments]                     ${sa_or_nsa}
    ...                             ${ue_id}
    ...                             ${ue_nr_capa}=None
    ...                             ${ue_eutra_nr_capa}=None
    ...                             ${cell_id}=-1
    ${cfg_file}                     set variable                ${tl.core.dir_path}/${tl.core.cfg_filename}
    # ue_param item: update the NR capabilities if requested
    ${ref_ue}                       set variable                ue_param id=${ue_id}
    ${field}                        set variable                ue_nr_capabilities
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -e '/^${ref_ue} / {s/${field}=[[:graph:]]*/${field}=${ue_nr_capa}/}'
    Run Keyword If                  '${ue_nr_capa}'!='None'     Run     ${sed_cmd} ${cfg_file}
    # ue_param item: update the EUTRA NR capabilities if requested
    ${ref_ue}                       set variable                ue_param id=${ue_id}
    ${field}                        set variable                ue_eutra_nr_capabilities
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -e '/^${ref_ue} / {s/${field}=[[:graph:]]*/${field}=${ue_eutra_nr_capa}/}'
    Run Keyword If                  '${ue_eutra_nr_capa}'!='None' and '${sa_or_nsa}'=='NSA'         Run     ${sed_cmd} ${cfg_file}
    # set_ue simulated item: update the SA cell Id if requested
    ${ref_ue}                       set variable                set_ue simulated id=${ue_id}
    ${field}                        set variable                cell
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -e '/^${ref_ue} / {s/${field}=[[:graph:]]*/${field}=${cell_id}/}'
    Run Keyword If                  ${cell_id} != -1 and '${sa_or_nsa}'=='SA'       Run     ${sed_cmd} ${cfg_file}

Add listed UEs to Cfg File
    [Arguments]       ${UEs_list}    ${totalNbOfUe}    ${sa_or_nsa}=SA
    Create UEs in Cfg File             nb_sa_ues=${totalNbOfUe}
    FOR    ${current_elem}    IN    @{UEs_list}
        Modify UE Data in Cfg File     sa_or_nsa=${sa_or_nsa}    ue_id=${current_elem.ue}    ue_nr_capa=${current_elem.ue_nr_capa}
        ...                            cell_id=${current_elem.target_cells}
    END

Remove All listed UEs from Cfg File
    [Documentation]    Remove all UEs in list_OfUes from basic_wts_step2.cfg file
    [Arguments]       ${UEs_list}    ${cfg_file}
    FOR    ${current_elem}    IN    @{UEs_list}
        Remove UE from Cfg File     ${cfg_file}    ue_id=${current_elem.ue}
    END

Remove UE from Cfg File
    [Documentation]                 INTERNAL USAGE
    ...                             Remove All data linked to specified UE
    [Arguments]                     ${cfg_file}
    ...                             ${ue_id}=0
    Run                             sed --follow-symlinks -i -e '/^set_ue simulated id=${ue_id} /d' ${cfg_file}
    Run                             sed --follow-symlinks -i -e '/^ue_param id=${ue_id} /d' ${cfg_file}
    Run                             sed --follow-symlinks -i -e '/^set_pdu_gateway id=${ue_id} /d' ${cfg_file}
    Run                             sed --follow-symlinks -i -e '/^set_bearer id=2 ue=${ue_id} /d' ${cfg_file}

Create New UE
    [Documentation]                 INTERNAL USAGE
    ...                             Search the referenced UE, duplicate all its parameters and update them
    [Arguments]                     ${cfg_file}
    ...                             ${ue_id}=0
    ...                             ${first_id}=0
    ...                             ${sa_or_nsa}=None
    Create ue_param item            cfg_file=${cfg_file}        first_id=${first_id}    ue_id=${ue_id}
    Create set_ue simulated item    cfg_file=${cfg_file}        first_id=${first_id}    ue_id=${ue_id}
    Create set_pdu_gateway item     cfg_file=${cfg_file}        first_id=${first_id}    ue_id=${ue_id}
    Run Keyword If                  "${sa_or_nsa}"=="SA"
    ...                             Update specific SA items    cfg_file=${cfg_file}    first_id=${first_id}   ue_id=${ue_id}
    Run Keyword If                  "${sa_or_nsa}"=="NSA"
    ...                             Update specific NSA items   cfg_file=${cfg_file}    first_id=${first_id}   ue_id=${ue_id}

Create ue_param item
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${cfg_file}
    ...                             ${first_id}
    ...                             ${ue_id}
    ${ref_ue}                       set variable                ue_param id=${first_id}
    ${new_ue}                       set variable                ue_param id=${ue_id}
    ${sed_cmd}                      set variable                sed --follow-symlinks -i '/^${ref_ue} /p;s/${ref_ue} /${new_ue} /'
    Run                             ${sed_cmd} ${cfg_file}

Create set_ue simulated item
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${cfg_file}
    ...                             ${first_id}
    ...                             ${ue_id}
    ${ref_ue}                       set variable                set_ue simulated id=${first_id}
    ${new_ue}                       set variable                set_ue simulated id=${ue_id}
    ${sed_cmd}                      set variable                sed --follow-symlinks -i '/^${ref_ue} /p;s/${ref_ue} /${new_ue} /'
    Run                             ${sed_cmd} ${cfg_file}

Create set_pdu_gateway item
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${cfg_file}
    ...                             ${first_id}
    ...                             ${ue_id}
    ${ref_ue}                       set variable                set_pdu_gateway id=${first_id}
    ${new_ue}                       set variable                set_pdu_gateway id=${ue_id}
    ${field}                        set variable                ue_nat_ip
    ${new_val}                      set variable                72.23.0.${ue_id}
    ${sed_cmd_part1}                set variable                sed --follow-symlinks -i '/^${ref_ue} /p;
    ${sed_cmd_part2}                set variable                s/${ref_ue} /${new_ue} /;
    ${sed_cmd_part3}                set variable                s/${new_ue} ${field}=[[:graph:]]*/${new_ue} ${field}=${new_val}/'
    ${sed_cmd}                      Catenate                    ${sed_cmd_part1}    ${sed_cmd_part2}    ${sed_cmd_part3}
    Run                             ${sed_cmd} ${cfg_file}

Update specific SA items
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${cfg_file}
    ...                             ${first_id}
    ...                             ${ue_id}
    ${ref_ue}                       set variable                set_ue simulated id=${ue_id}
    ${field}                        set variable                sec_key=0102030405060708090A0B0C0D0EFF
    ${new_val}                      evaluate                    ${ue_id} - ${first_id}
    ${new_val}                      Convert To Hex              ${new_val}      length=2
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -r '/^${ref_ue} /s/(.*)(${field})([0-9]+)(.*)/echo "\\1\\2${new_val}\\4"/e'
    Run                             ${sed_cmd} ${cfg_file}
    ${ref_ue}                       set variable                set_ue simulated id=${ue_id}
    ${new_val}                      evaluate                    ${ue_id} - ${first_id}
    ${cmd_part1}                    set variable                sed --follow-symlinks -i -r '/^${ref_ue}
    ${cmd_part2}                    set variable                /s/(.*)(suci=0:)([0-9]+:[0-9]+):([0-9]+:[0-9]+:[0-9]+:0)([0-9]+)(.*)/echo
    ${cmd_part3}                    set variable                "\\1\\2\\3:\\4$((\\5+${new_val}))\\6"/e'
    ${sed_cmd}                      catenate                    ${cmd_part1}    ${cmd_part2}    ${cmd_part3}
    Run                             ${sed_cmd} ${cfg_file}

Update specific NSA items
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${cfg_file}
    ...                             ${first_id}
    ...                             ${ue_id}
    ${ref_ue}                       set variable                set_ue simulated id=${ue_id}
    ${new_val}                      evaluate                    ${ue_id} - ${first_id}
    ${cmd_part1}                    set variable                sed --follow-symlinks -i -r '/^${ref_ue}
    ${cmd_part2}                    set variable                /s/(.*)(imsi=)([0-9]+):([0-9]+):([0-9]+)(.*)/echo
    ${cmd_part3}                    set variable                "\\1\\2\\3:\\4:$((\\5+${new_val}))\\6"/e'
    ${sed_cmd}                      catenate                    ${cmd_part1}    ${cmd_part2}    ${cmd_part3}
    Run                             ${sed_cmd} ${cfg_file}
    ${ref_ue}                       set variable                set_bearer id=2 ue=${first_id}
    ${new_ue}                       set variable                set_bearer id=2 ue=${ue_id}
    ${sed_cmd}                      set variable                sed --follow-symlinks -i '/^${ref_ue} /p;s/${ref_ue} /${new_ue} /'
    ${response}                     Run                         ${sed_cmd} ${cfg_file}
    # case with IP address starting at standard value: 208
    #    ${ref_ue}                       set variable                set_bearer id=2 ue=${ue_id}
    #    ${field}                        set variable                ip
    #    ${new_val}                      evaluate                    208 + ${ue_id} - ${first_id}
    #    ${new_val}                      set variable                4.7.254.${new_val}
    #    ${sed_cmd}                      set variable
    #    ...                             sed --follow-symlinks -i -e '/^${ref_ue} / {s/${field}=[[:graph:]]*/${field}=${new_val}/}'
    #    Run                             ${sed_cmd} ${cfg_file}
    # case with IP address setting to UE id: it allows to get more NSA UEs
    ${ref_ue}                       set variable                set_bearer id=2 ue=${ue_id}
    ${field}                        set variable                ip
    ${new_val}                      set variable                4.7.254.${ue_id}
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -e '/^${ref_ue} / {s/${field}=[[:graph:]]*/${field}=${new_val}/}'
    ${response}                     Run                         ${sed_cmd} ${cfg_file}

Set New NSA Ref UE
    [Documentation]                 INTERNAL USAGE
    ...                             Change the Id of the NSA reference UE in basic_setup.cfg file on ePCSim
    [Arguments]                     ${cfg_file}
    ...                             ${new_id}
    ...                             ${first_nsa_id}
    ...                             ${old_id}=${FIRST_NSA_UE_ID}
    # Rename The New NSA from UE_id=${old_id} to ${new_id}
    ${ref_ue}                       set variable                ue_param id=${old_id}
    ${new_ue}                       set variable                ue_param id=${new_id}
    ${sed_cmd}                      set variable                sed --follow-symlinks -i '/^${ref_ue} / s/${ref_ue} /${new_ue} /'
    Run                             ${sed_cmd} ${cfg_file}
    ${ref_ue}                       set variable                set_ue simulated id=${old_id}
    ${new_ue}                       set variable                set_ue simulated id=${new_id}
    ${sed_cmd}                      set variable                sed --follow-symlinks -i '/^${ref_ue} / s/${ref_ue} /${new_ue} /'
    Run                             ${sed_cmd} ${cfg_file}
    ${ref_ue}                       set variable                set_pdu_gateway id=${old_id}
    ${new_ue}                       set variable                set_pdu_gateway id=${new_id}
    ${field}                        set variable                ue_nat_ip
    ${new_val}                      set variable                72.23.0.${new_id}
    ${sed_cmd_part1}                set variable                sed --follow-symlinks -i '/^${ref_ue} / s/${ref_ue} /${new_ue} /;
    ${sed_cmd_part2}                set variable                s/${new_ue} ${field}=[[:graph:]]*/${new_ue} ${field}=${new_val}/'
    ${sed_cmd}                      catenate                    ${sed_cmd_part1}    ${sed_cmd_part2}
    Run                             ${sed_cmd} ${cfg_file}
    ${ref_ue}                       set variable                set_bearer id=2 ue=${old_id}
    ${new_ue}                       set variable                set_bearer id=2 ue=${new_id}
    ${sed_cmd}                      set variable                sed --follow-symlinks -i '/^${ref_ue} / s/${ref_ue} /${new_ue} /'
    Run                             ${sed_cmd} ${cfg_file}
    ${ref_ue}                       set variable                set_bearer id=2 ue=${new_id}
    ${field}                        set variable                ip
    ${new_val}                      set variable                4.7.254.${first_nsa_id}
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i -e '/^${ref_ue} / {s/${field}=[[:graph:]]*/${field}=${new_val}/}'
    Run                             ${sed_cmd} ${cfg_file}


#=======================================================================================================================
# KW to create new bearer in config file on ePCSIM
#=======================================================================================================================
Create Bearer in Cfg File
    [Documentation]                 Create new bearer in basic_wts_step2.cfg file. This means:
    ...                             - create new set_qosflow and set_qosrule items.
    ...                             - update the following nwslice_set parameters: qos_flows and qos_rules.
    ...                             Argument : 5qi : an integer
    ...                             Argument : proto : could be tcp or udp or ...
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


#=======================================================================================================================
# KW to change NIDD Hidden parameters
#=======================================================================================================================
Change NIDD Hidden param
    [Documentation]                 Update a hidden NIDD parameter value in vendor file.
    ...                             Save current SCF and vendor file to local vm.
    ...                             Change a parameter value in new vendor file and load it.
    ...                             Do a full commissioning with previous saved SCF and wait until all nodes are READY.
    ...                             *Argument details:*
    ...                              - param : Param to modify (ex: bbPoolMode - default: bbPoolMode).
    ...                              - value : new value for the param (default: round-robin)
    [Arguments]                     ${param}=bbPoolMode    ${value}=round-robin
    ${original_vendorfile}          ${modified_vendorfile}              Download Vendor File
    Modify Vendor File Parameter    ${original_vendorfile}              ${modified_vendorfile}
    ...                             ${param}                            ${value}
    Vendor File Commissioning       vendorfile_path=${modified_vendorfile}

Change NIDD Hidden parameter list
    [Documentation]                 Update a hidden NIDD parameter list in vendor file.
    ...                             Save current SCF and vendor file to local vm.
    ...                             Change a list of parameter values in new vendor file and load it.
    ...                             Do a full commissioning with previous saved SCF and wait until all nodes are READY.
    ...                             *Argument details:*
    ...                              - listName : new value for the param (default: round-robin)
    ...                              - filter parameter_dict : item parameters filter matching items to be modified in the list, contained in a dict
    ...                              - new parameter_dict : item parameters to be modified, in dict format: key = name, value = new value
    [Arguments]                     ${listName}                         ${filter_parameter_dict}
    ...                             ${new_parameter_dict}
    ${original_vendorfile}          ${modified_vendorfile}              Download Vendor File
    Modify Vendor File List         ${original_vendorfile}              ${modified_vendorfile}
    ...                             ${listName}                         ${filter_parameter_dict}
    ...                             ${new_parameter_dict}
    Vendor File Commissioning       vendorfile_path=${modified_vendorfile}

Download Vendor File
    ${orig_vendorfile}              SSH Wait For Connect and Cmd    command=basename $(ls /ffs/run/swpool/OAM/vendor_*.xml)
    ...                             host=${GNB_DU.sys[0].M}
    ${orig_vendorfile}              SSH Wait For Connect and Cmd    command=basename $(ls /ffs/run/swpool/OAM/vendor_*.xml)
    ...                             host=${GNB_DU.sys[0].M}
    ${original_vendorfile}          Run                             echo ${orig_vendorfile.strip()}|sed 's/\.xml/_ori\.xml/'
    ${modified_vendorfile}          Run                             echo ${orig_vendorfile.strip()}|sed 's/\.xml/_mod\.xml/'
    # download /ffs/run/swpool/OAM/vendor_xxxxxxxxx.xml   to   <vm_local_path>/vendor_xxxxxxxxx_ori.xml
    SSH Download File               host=${GNB_DU.sys[0].M}
    ...                             remotePath=/ffs/run/swpool/OAM/${orig_vendorfile.strip()}
    ...                             localPath=${LOG_PATH}/${original_vendorfile}
    [Return]                        ${LOG_PATH}/${original_vendorfile}        ${LOG_PATH}/${modified_vendorfile}

Modify Vendor File Parameter
    [Documentation]                 INTERNAL USAGE
    ...                             modify a single parameter in a scf or vendor file
    [Arguments]                     ${original_vendorfile}      ${modified_vendorfile}
    ...                             ${param}                    ${value}
    Run                             cp -p ${original_vendorfile} ${modified_vendorfile}
    Run                             sed -i 's#<p name="${param}">[[:graph:]]*<#<p name="${param}">${value}<#g' ${modified_vendorfile}

Modify Vendor File List
    [Documentation]                 INTERNAL USAGE
    ...                             modify a single parameter in a scf or vendor file
    [Arguments]                     ${original_vendorfile}      ${modified_vendorfile}
    ...                             ${param}                    ${value}
    Run                             cp -p ${original_vendorfile} ${modified_vendorfile}
    Run                             sed -i 's#<p name="${param}">[[:graph:]]*<#<p name="${param}">${value}<#g' ${modified_vendorfile}

Vendor File Commissioning
    [Documentation]                 INTERNAL USAGE
    ...                             Perform commissioning for the given vendor file
    [Arguments]                     ${vendorfile_path}
    ${SCF_SETUP_PATH}               OAM Get SCF File
    ...                             oam=${GNB_DU.oam}   file=SCF_NIDD_chageParam.xml
    # set_vendor_file                 ${vendorfile_path}
    &{args}                         Create Dictionary    vendor_file="${vendorfile_path}"
    OAM Run Command                 cmd=set_vendor_file    cmd_args=${args}
    OAM Perform Full Commissioning  oam=${GNB_DU.oam}   scf_file=${SCF_SETUP_PATH}
    Airscale Wait for Ready         ${GNB_DU}

Vendor File And Commissioning
    [Documentation]                 Apply vendor file and
    ...                             Perform commissioning with provide SCF file if it's provided
    ...                             If Scf is not provided, current SCF is commissionned
    [Arguments]                     ${vendorfile_path}
    ...                             ${SCF_path}=${EMPTY}
    ${SCF_SETUP_PATH}               OAM Get SCF File
    ...                             oam=${GNB_DU.oam}   file=SCF_NIDD_chageParam.xml
    &{args}                         Create Dictionary    vendor_file="${vendorfile_path}"
    OAM Run Command                 cmd=set_vendor_file    cmd_args=${args}
    Run keyword if  '${SCF_path}' == '${EMPTY}'    OAM Perform Full Commissioning  oam=${GNB_DU.oam}   scf_file=${SCF_SETUP_PATH}
    ...                ELSE                  OAM Perform Full Commissioning  oam=${GNB_DU.oam}   scf_file=${SCF_path}
    OAM wait available
