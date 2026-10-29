*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_syve.robot
#Library           hran_tools
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${TARGET_SW_NAME}                                  ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW'
${UPDATE_TIMEOUT}                                   1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}                              1800
${SW Activation Timeout}                            150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                                420  # Timeout for ping loss during reset
${Ping regain timeout}                              600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                                15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                     30  # Test timeout (in minutes)


*** Keywords ***
TC_RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to verified unsingned package update
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    100 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335
    Step 1: Check signed active BTS SW
    Step 2: Get unsigned Knife
    Step 3: Download unsigned SW
    #Step 4: Check fault 4268 after Download
    Step 5: Set R&D flag to hard enable
    Step 6: Update software with Second unsigned SW
   #Step 7: Check fault 4269 after update software
    Step 8: Recover BTS

Step ${index}: Check signed active BTS SW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step ${index}: Check active BTS SW is signed.
    set test variable  ${HCS_find}  ls /ffs/run | grep HashContainerSignature.*sig$
    SSHLibrary.Open Connection    192.168.255.1
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${stdout}    ${rc}=    SSHLibrary.Execute Command    ${HCS_find}    return_rc=True
    ${check_result}  should contain   ${stdout}  HashContainerSignature
    Run keyword if  ${check_result}  Log  Active BTS SW is signed
    SSHLibrary.Close Connection

Step ${index}: Get unsigned Knife
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step ${index}: Get unsigned Knife
    ${conn_local}  SSHLibrary.Open Connection    ${BTS_PC_INFO.IP}
#    SSHLibrary.Login    ${BTS_PC_INFO.USERNAME}    ${BTS_PC_INFO.PASSWORD}
    SSHLibrary.Login with public key  ute    /home/ute/.ssh/id_rsa
    set test variable    ${conn_local}
    ${Directory_status}=    run keyword and return status  OperatingSystem.directory should exist    /home/ute/Knife913/
    run keyword if  ${Directory_status}=='False'  OperatingSystem.Create Directory    /home/ute/Knife913
    set test variable   ${local_knife_path}  /home/ute/Knife913
    ${check_file_result}    run keyword and return status    Check files is exist    ${local_knife_path}/
    Run keyword if   '${check_file_result}'=='False'  Get Files From remote
    Run keyword if   '${check_file_result}'=='True'   Get Files From local

Get Files From remote
    [Documentation]    Short description.
    SSHLibrary.Open Connection    ${down_server}
    SSHLibrary.Login    ute    ute@dmin5
    @{file_list}    SSHLibrary.List Files In Directory    /home/ute/HZOAM/01_BTS_SW/RP000913/
    SSHLibrary.Get File  /home/ute/HZOAM/01_BTS_SW/RP000913/${file_list[0]}  ${local_knife_path}/${file_list[0]}
    SSHLibrary.Get File  /home/ute/HZOAM/01_BTS_SW/RP000913/${file_list[1]}  ${local_knife_path}/${file_list[1]}
    SSHLibrary.Close Connection
    ${Package_size}    Get File Size    ${local_knife_path}/${file_list[0]}
    Should Be True    ${Package_size} > 800000000
    ${unsigned_sw_path2}  catenate  SEPARATOR=  ${local_knife_path}/  ${file_list[0]}
    ${unsigned_sw_path1}  catenate  SEPARATOR=  ${local_knife_path}/  ${file_list[1]}
    set test variable  ${unsigned_sw_path1}
    set test variable  ${unsigned_sw_path2}

Get Files From local
    [Documentation]    Short description.
    SSHLibrary.switch connection  ${conn_local}
    @{file_list}    SSHLibrary.List Files In Directory    ${local_knife_path}
    SSHLibrary.Close Connection
    ${unsigned_sw_path2}  catenate  SEPARATOR=  ${local_knife_path}/  ${file_list[0]}
    ${unsigned_sw_path1}  catenate  SEPARATOR=  ${local_knife_path}/  ${file_list[1]}
    set test variable  ${unsigned_sw_path1}
    set test variable  ${unsigned_sw_path2}

Check files is exist
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PATH}: <description>
    ...
    ...    Returns:
    ...        ${status}: <description>
    [Arguments]  ${PATH}
    SSHLibrary.switch connection  ${conn_local}
    ${files_list}    List Files In Directory    ${PATH}
    ${Package_size}    Get File Size    ${PATH}/${files_list[0]}
    ${status}  Run keyword and return status  Should Be True    ${Package_size} > 800000000
    [Return]   ${status}

Step ${index}: Download unsigned SW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
     Log Step Header  Step ${index}: Download unsigned SW
     ${sw_update_result}  ${sw_update_msg}    Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Update Software  ${unsigned_sw_path1}
     ...    False  1800s
     Log  ${sw_update_msg}  console=${true}
     Run keyword if  '${sw_update_result}'=='FAIL'  Fail  Software update did not pass:${sw_update_msg}
     ...   ELSE   log  Software update pass with these message: ${sw_update_msg}

STep ${index}: Check fault 4268 after Download
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step ${index}: Check fault 4268 after Download
    wait until keyword succeeds   10min  30s  Check fualts on admin  4268  Minor

Check fualts on admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${faultId}: <description>
    ...        ${severity}: <description>
    [Arguments]   ${faultId}   ${severity}
    ${EXPECTED_ALARM1}     Create Dictionary  faultId=${faultId}  severity=${severity}
    ${EXPECTED_ALARMs}            Create List  ${EXPECTED_ALARM1}
    Admin Check Active Alarms  expected_patterns=${EXPECTED_ALARMs}

Step ${index}: Set R&D flag to hard enable
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step ${index}: Set R&D flag to hard enable
    set test variable  ${SWCONFIG_FLAGS1}  0x4B0005=1
    ${SWCONFIG_FLAGS}  create list  ${SWCONFIG_FLAGS1}
    set test variable  ${SWCONFIG_FLAGS}
    Add Swconfig Flags  ${SWCONFIG_FLAGS}
    Reset testline

Step ${index}: Update software with Second unsigned SW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
     Log Step Header  Step ${index}: Update software with Second unsigned SW
#    set test variable  ${unsigned_sw_path2}  /home/ute/Knife913/SBTS00_ENB_9999_210127_000023_release_BTSSM_downloadable_A54.zip
     ${sw_update_result}  ${sw_update_msg}    Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Update Software  ${unsigned_sw_path2}
     ...    True  1800s
     Log  ${sw_update_msg}  console=${true}
     Run keyword if  '${sw_update_result}'=='FAIL'  Log   Software update failed as expected:${sw_update_msg}

Step ${index}: Check fault 4269 after update software
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
     Log Step Header  Step ${index}: Check fault 4269 after update software
    wait until keyword succeeds   5min  30s  Check fualts on admin  4269  Minor

Step ${index}: Recover BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
#    set test variable  ${SWCONFIG_FLAGS1}  0x4B0005=1
#    ${SWCONFIG_FLAGS}  create list  ${SWCONFIG_FLAGS1}
    Delete Swconfig Flags  ${SWCONFIG_FLAGS}
    Reset testline
    Run keyword and ignore error    Run    rm -r /home/ute/Knife913/

Add Swconfig Flags
    [Documentation]  Adds swconfig flags from passed list, and performs reset.
    [Arguments]  ${flag_list}
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    Run Remote Linux Command  echo ' ' >> /ffs/run/swconfig.txt
    FOR  ${FLAG}  IN  @{flag_list}
     ${removed_comments}=  split string  ${FLAG}  \#
     ${check_flag}=  Run Remote Linux Command  cat /ffs/run/swconfig.txt
     ${status}=  Evaluate  """${removed_comments[0]}""" in """${check_flag}"""
     Run keyword if    not ${status}  Run Remote Linux Command    echo ${removed_comments[0]} >> /ffs/run/swconfig.txt
     run keyword if  ${status}  log to console with time  Flag: ${removed_comments[0]} already in swconfig
        ...  ELSE  log to console with time  Added flag:${removed_comments[0]}
    END

Delete Swconfig Flags
    [Documentation]  Delete swconfig flags from passed list, and performs reset.
    [Arguments]  ${flag_list}
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    Run Remote Linux Command  echo ' ' >> /ffs/run/swconfig.txt
    FOR  ${FLAG}  IN  @{flag_list}
     ${removed_comments}=  split string  ${FLAG}  \#
     ${check_flag}=  Run Remote Linux Command  cat /ffs/run/swconfig.txt
     ${status}=  Evaluate  """${removed_comments[0]}""" in """${check_flag}"""
     run keyword if  ${status}  Run Remote Linux Command    sed -i '/${removed_comments[0]}/d' /ffs/run/swconfig.txt
     run keyword if  '${status}'=='False'  log to console with time  Flag:${removed_comments[0]}already not in swconfig
        ...  ELSE    log to console with time    Delete flag:${removed_comments[0]}
    END

Reset testline
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.run keyword in background  Reset  timeout=300
    log to console with time  Check if reset is performed
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    log to console with time  Reset completed. Waiting for eNB to be pingable...
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for reset  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after Reset
    Log  BTS is stable after Reset.  console=${TRUE}
