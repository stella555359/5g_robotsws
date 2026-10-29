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
...             | TxtConfig Init                  | To generate a .lua file from the .cfg one                      |
...             | Set Fields in swconfig DU       | To set some fields in a swconfig.txt file                      |
...             | Get XML AirPhoneConfig Path     | To retrieve name of AirPhoneConfig XML file in basic.cfg file  |
...             | Modify Field in WtsEmu Cfg File | To modify a field in WTS basic.cfg file (use sed)              |
...

Resource          Restart.robot
Resource          Tools.robot
Library           ../../../resources/NPS/SWENG/python/StringTool.py
Library           ../../../resources/NPS/SWENG/python/TxtConfig.py    WITH NAME   TxtConfig
Library           ../../../resources/NPS/SWENG/python/OsTool.py

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
    # ${sed_cmd}                      set variable
    # ...                             sed -i "s/${field}=[[:graph:]]*/${field}=${value}/g" < ${cfg_file} 1<> ${cfg_file}
    ${sed_cmd}                      set variable
    ...                             sed --follow-symlinks -i "s/${field}=[[:graph:]]*/${field}=${value}/g" ${cfg_file}
    Dated log                       Configure config file on ePCSim (${cfg_file})
    Dated Log                       \tSetting ${field} to ${value} in ${cfg_file} on ePCSim (${sed_cmd})
    SSH Wait For Connect and Cmd    command=sudo ${sed_cmd}                 host=${HOST_EPCSIM}

Change NIDD Hidden param
    [Documentation]                 To update a hidden NIDD param in vendor file.
    ...                             Save current SCF & vendor file to local vm.
    ...                             Change a param value in new vendor file & load it.
    ...                             Do a full commissioning with previous saved SCF & wait until all nodes are READY.
    ...                             *Argument details:*
    ...                              - param : Param to modify (ex: bbPoolMode - default: bbPoolMode).
    ...                              - value : new value for the param (default: round-robin)
    [Arguments]                     ${param}=bbPoolMode    ${value}=round-robin
    ${SCF_SETUP_PATH}               OAM Get SCF File
    ...                             oam=${GNB_DU.oam}   file=SCF_NIDD_chageParam.xml
    ${orig_vendorfile}              SSH Wait For Connect and Cmd    command=basename $(ls /ffs/run/swpool/OAM/vendor_*.xml)
    ...                             host=${GNB_DU.sys[0].M}

    ${orig_vendorfile}    SSH Wait For Connect and Cmd    command=basename $(ls /ffs/run/swpool/OAM/vendor_*.xml)    host=${GNB_DU.sys[0].M}
    ${orig_localvendorfile}    Run    echo ${orig_vendorfile.strip()}|sed 's/\.xml/_ori\.xml/'
    ${modified_vendorfile}     Run    echo ${orig_vendorfile.strip()}|sed 's/\.xml/_mod\.xml/'
    # download /ffs/run/swpool/OAM/vendor_xxxxxxxxx.xml   to   <vm_local_path>/vendor_xxxxxxxxx_ori.xml
    SSH Download File    host=${GNB_DU.sys[0].M}
    ...                  remotePath=/ffs/run/swpool/OAM/${orig_vendorfile.strip()}
    ...                  localPath=${LOG_PATH}/${orig_localvendorfile}
    Run    cp -p ${LOG_PATH}/${orig_localvendorfile} ${LOG_PATH}/${modified_vendorfile}
    # Modify provided param in <vm_local_path>/vendor_xxxxxxxxx_mod.xml to provided value
    Run    sed -i 's#<p name="${param}">[[:graph:]]*<#<p name="${param}">${value}<#g' ${LOG_PATH}/${modified_vendorfile}
    # set_vendor_file     <vm_local_path>/vendor_xxxxxxxxx_mod.xml
    &{args}    Create Dictionary    vendor_file="${LOG_PATH}/${modified_vendorfile}"
    OAM Run Command    cmd=set_vendor_file    cmd_args=${args}
    OAM Perform Full Commissioning  oam=${GNB_DU.oam}   scf_file=${SCF_SETUP_PATH}
    Airscale Wait for Ready         ${GNB_DU}
