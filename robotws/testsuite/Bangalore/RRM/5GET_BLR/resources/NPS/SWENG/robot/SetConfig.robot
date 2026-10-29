*** Settings ***
Resource          Restart.robot
Resource          Tools.robot
Library           ../python/StringTool.py
#Resource          ../common/cloudbts_nsa.robot
Library           ../python/TxtConfig.py    WITH NAME   TxtConfig
Library           ../python/OsTool.py

*** Variables ***
#${SSH_AUTHENTICATION_RETRY_INTERVAL}    5 s
#${SSH_AUTHENTICATION_TIMEOUT}       5 min
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
    [Arguments]                     ${nbUe}=1       ${nbSaUe}=0
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
    # Upload generated file (.lua) on WTS
    Dated Log                       \tUploading ${TxtConfigLocalDir}/${LuaConfigName} into ${tl.core.dir_path}/${LuaConfigName}
    ${outload}                      csn.upload_file
    ...                                 remote_path=${tl.core.dir_path}/${LuaConfigName}
    ...                                 local_path=${TxtConfigLocalDir}/${LuaConfigName}
    ...                                 connection=${alias}
    [Return]                        ${LuaConfigName}

#===========================================================================================================
#   KW to get/set some values in swconfig file
#===========================================================================================================
Set Fields in swconfig DU
    [Documentation]                 Generic service to set a list of parameters into swconfig file
    ...                             param_list should be a list od dictionaries, each containing a "field" and a "value"
    [Arguments]                     ${param_list}                           ${host}=${AIRSCALE_GNB.entryCard[0]}
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
    ${alias}                        SSH Connect                             host=${HOST_EPCSIM}
    ${cfgPath}                      set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${cmd}                          set variable                            grep "^set_uec " ${cfgPath} | sed -e "s/.*file=//g" | cut -d " " -f1
    ${path}                         SSH Exec                                ${cmd}
    ...                             alias=${alias}
    [Return]                        ${path.replace("\n","").replace("\r","")}

#=======================================================================================================================
# KW to modify a field in config file on ePCSIM
#=======================================================================================================================
Modify Field in WtsEmu Cfg File
    [Documentation]                 Modify an existing field in basic config file on ePCSim
    [Arguments]                     ${field}
    ...                             ${value}
    ${cfg_file}                     set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${sed_cmd}                      set variable                            sed -i "s/${field}=[[:graph:]]*/${field}=${value}/g" ${cfg_file}
    Dated log                       Configure config file on ePCSim (${cfg_file})
    Dated Log                       \tSetting ${field} to ${value} in ${cfg_file} on ePCSim (${sed_cmd})
    SSH Wait For Connect and Cmd    command=sudo ${sed_cmd}                 host=${HOST_EPCSIM}


