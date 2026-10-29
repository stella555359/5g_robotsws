*** Settings ***
Documentation  SWCONFIG configuration

Library    taf.transport.ssh    WITH NAME   ssh
Library    OperatingSystem
Library    ./swconfig_flag_operation.py

Resource   ../admin/admin.robot

*** Variables ***
${SWCONFIG_BTS_PATH}=    /ffs/run/swconfig.txt
${SWCONFIG_LOCAL_PATH}=  ${OUTPUT_DIR}/swconfig.txt

*** Keywords ***
Add flags from list to swconfig
    [Arguments]  ${flags_list}  ${reboot_after_uploading}
    [Documentation]
    ...     Adds all the flags from list to swconfig.txt file on BTS.
    ...     In case if one of flags already appears in swconfig.txt file and is not commented skips it.
    ...     After modifying a swconfig.txt file on BTS reboot is requaired.
    ...     Does BTS reboot if reboot_after_uploading param equals to True.
    Download swconfig file
    ${lists_of_added_flags}=  add multiple flags to file  ${SWCONFIG_LOCAL_PATH}  ${flags_list}
    ${message_for_all_added_flags}=   Catenate  All the flags from list ${flags_list} were added to swconfig.txt
    ${message_for_not_added_flags}=    Catenate  All the flags from list ${flags_list} are already
    ...                                         present in swconfig.txt, nothing was added
    ${message_for_both_flags_added}=  Catenate  These flags ${lists_of_added_flags[0]} from list ${flags_list} were
    ...                                         added to swconfig.txt ${\n}and these flags ${lists_of_added_flags[1]}
    ...                                         from list ${flags_list} were not added, because they are already present
    Run Keyword If  ${lists_of_added_flags[0]} and ${lists_of_added_flags[1]}
    ...  log  ${message_for_both_flags_added}  console=yes
    ...  ELSE IF  ${lists_of_added_flags[0]}  log  ${message_for_all_added_flags}  console=yes
    ...  ELSE IF  ${lists_of_added_flags[1]}  log  ${message_for_no_flags_added}  console=yes
    Upload swconfig file to BTS
    Remove downloaded swconfig
    Run Keyword If  ${reboot_after_uploading} == True
    ...  Reboot BTS and wait until available
    log  swconfig change operation finished  console=yes

Add one flag to swconfig
    [Arguments]  ${flag}  ${reboot_after_uploading}
    [Documentation]
    ...     Adds one flag to swconfig.txt file on BTS.
    ...     If flag is already present in file, but has another value, replaces it.
    ...     After modifying a swconfig.txt file on BTS reboot is requaired.
    ...     Does BTS reboot if reboot_after_uploading param equals to True.
    Download swconfig file
    ${was_flag_added}=  add flag to file  ${SWCONFIG_LOCAL_PATH}  ${flag}
    Run Keyword If  ${was_flag_added} == True
    ...  log  Flag <${flag}> successfully added to ${SWCONFIG_LOCAL_PATH}  console=yes
    ...  ELSE  log  Flag ${flag} is already present in ${SWCONFIG_LOCAL_PATH}, nothing was added  console=yes
    Upload swconfig file to BTS
    Remove downloaded swconfig
    Run Keyword If  ${reboot_after_uploading} == True
    ...  Run Keywords
    ...  Reset Site And Reconnect
    ...  AND
    ...  Wait Until Keyword Succeeds    10x    1min    Check if BTS status is Configured or OnAir
    log  swconfig change operation finished  console=yes

Download swconfig file
    [Documentation]
    ...     Downloads a swconfig.txt file from BTS. In case if file already exists overwrites it.
    ...     Prints a message about successfull installation in case if source file exists.
    ...     Prints an " IOError: [Errno 2] No such file " in case if source file does not exist.
    ssh.connect to  ${SSH_IP}  ${SSH_USERNAME}  ${SSH_PASSWORD}
    ssh.download file  ${SWCONFIG_BTS_PATH}  ${SWCONFIG_LOCAL_PATH}
    ssh.disconnect
    log  ${\n}File swconfig.txt successfully downloaded to ${SWCONFIG_LOCAL_PATH}  console=yes

Remove downloaded swconfig
    [Documentation]
    ...     Removes a swconfig.txt file from local source.
    ...     Prints a message about successfull remove in case if local file exists.
    ...     Prints an message about absence in case if local file does not exist.
    ${output_message}=  Run  rm ${SWCONFIG_LOCAL_PATH}
    ${output_phrase}=  process remove output message  ${output_message}  ${SWCONFIG_LOCAL_PATH}
    log  ${output_phrase}  console=yes

Remove flags from list from swconfig
    [Arguments]  ${flags_list}  ${reboot_after_uploading}
    [Documentation]
    ...     Removes all the flags from list from swconfig.txt file on BTS.
    ...     In case if one of flags already appears in swconfig.txt file and is commented doesnt remove it.
    ...     After modifying a swconfig.txt file on BTS reboot is requaired.
    ...     Does BTS reboot if reboot_after_uploading param equals to True.
    Download swconfig file
    ${lists_of_removed_flags}=  remove multiple flags from file  ${SWCONFIG_LOCAL_PATH}  ${flags_list}
    ${message_for_all_removed_flags}=   Catenate  All the flags from list ${flags_list} were removed from swconfig.txt
    ${message_for_not_removed_flags}=   Catenate  There are no flags from list ${flags_list} in swconfig.txt file,
    ...                                           nothing was removed
    ${message_for_both_flags_removed}=  Catenate  These flags ${lists_of_removed_flags[0]} from list ${flags_list} were
    ...                                           removed from swconfig.txt ${\n}and these flags
    ...                                           ${lists_of_removed_flags[1]} from list ${flags_list}
    ...                                           were not present in swconfig.txt file
    Run Keyword If  ${lists_of_removed_flags[0]} and ${lists_of_removed_flags[1]}
    ...  log  ${message_for_both_flags_removed}  console=yes
    ...  ELSE IF  ${lists_of_removed_flags[0]}  log  ${message_for_all_removed_flags}  console=yes
    ...  ELSE IF  ${lists_of_removed_flags[1]}  log  ${message_for_not_removed_flags}  console=yes
    Upload swconfig file to BTS
    Remove downloaded swconfig
    Run Keyword If  ${reboot_after_uploading} == True
    ...  Reboot BTS and wait until available
    log  swconfig change operation finished  console=yes

Remove one flag from swconfig
    [Arguments]  ${flag}  ${reboot_after_uploading}
    [Documentation]
    ...     Removes one flag from swconfig.txt file on BTS.
    ...     In case if flag already appears in swconfig.txt file and is commented doesnt remove it.
    ...     After modifying a swconfig.txt file on BTS reboot is requaired.
    ...     Does BTS reboot if reboot_after_uploading param equals to True.
    Download swconfig file
    ${was_flag_removed}=  remove flag from file  ${SWCONFIG_LOCAL_PATH}  ${flag}
    Run Keyword If  ${was_flag_removed} == True
    ...  log  Flag ${flag} was successfully removed from ${SWCONFIG_LOCAL_PATH}  console=yes
    ...  ELSE  log  Flag ${flag} is not present in ${SWCONFIG_LOCAL_PATH}, nothing to delete.  console=yes
    Upload swconfig file to BTS
    Remove downloaded swconfig
    Run Keyword If  ${reboot_after_uploading} == True
    ...  Reboot BTS and wait until available
    log  swconfig change operation finished  console=yes

SWconfig Setup
    log to console  Configuring swconfig...
    ${cur_swc}=  get_swconfig_from_bts
    ${cur_flags}=  get_current_flags_from_swconfig  ${cur_swc}
    clear swconfig  ${cur_swc}
    set suite variable  ${INITIAL_SWCONFIG_FLAGS}  ${cur_flags}
    ${new_flags}=  create dictionary  0x1a0020=0  0x45005a=1  0x1a1300=1
    add flags to sw config  ${new_flags}  ${cur_swc}
    put_swconfig_into_bts  ${cur_swc}
    Reset Site And Reconnect

SWconfig Teardown
    log to console  Configuring swconfig...
    create swconfig with flags  ${INITIAL_SWCONFIG_FLAGS}  final_swconfig.txt
    ${def}=  get_current_flags_from_swconfig  final_swconfig.txt
    put swconfig into bts  final_swconfig.txt
    Reset Site And Reconnect

Upload swconfig file to BTS
    [Arguments]  ${reboot_after_uploading}=False
    [Documentation]
    ...     Replaces swconfig.txt on a BTS with a local one.
    ...     After modifying a swconfig.txt file on BTS reboot is requaired.
    ...     Does BTS reboot if reboot_after_uploading param equals to True.
    ...     Prints a message about successfull remove in case if local file exists.
    ...     Prints an message about absence in case if local file does not exist.
    ssh.connect to  ${SSH_IP}  ${SSH_USERNAME}  ${SSH_PASSWORD}
    ssh.upload file  ${SWCONFIG_LOCAL_PATH}  ${SWCONFIG_BTS_PATH}
    Run Keyword If  ${reboot_after_uploading} == True
    ...  Reboot BTS and wait until available
    ssh.disconnect
    log  File swconfig.txt successfully uploaded to ${SWCONFIG_BTS_PATH}  console=yes
