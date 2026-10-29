*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh
Library    taf.sbts.oam.coam.admin
Library    taf.ul.oam.selenium_coam


Resource    ../../resources/admin.robot
Resource    ../../resources/fault_trigger.robot


*** Variables ***
# ${SMOD_SW_Update_directory_planned}    /ffs/stb/planned/
# ${SMOD_SW_Update_file_SWDLreport}    /tmp/SWDLreport.txt
${SMOD_com_reboot}    ddal -s ddal_reboot_graceful

${SW_DESTINATION}       /home/ute
${swDownloadInfo.result}=  Successful
${jenkins_url}          http://files.ute.nsn-rdnet.net/builds/enb/base/
# ${TRUNK_VERSION}        SBTS22R3

*** Keywords ***
Check If BTS Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured


Comment DnR flag if exists
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/0x4B0014=1/#0x4B0014=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt
#    SYSTEM Execute Command On gNB
#    ...    command=reboot
#    sleep  10s

Uncomment DnR flag if commented
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/#0x4B0014=1/0x4B0014=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt

Start software update in background
    [Timeout]    50 min
    Log To Console                                 start swr in background
    ${CLI_INTERFACE}                               Get Library Instance    taf.sbts.oam.coam.admin
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_in_background
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update_in_background
    Sleep  10
    log to console      start swr in background
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background    interface=${CLI_INTERFACE}
    ...                                                                                      name=update_software
    ...                                                                                      sw_package=${SW_DESTINATION}/${T1_package}
    ...                                                                                      should_activate=${TRUE}
    ...                                                                                      connection=ADMIN_SW_Update_in_background
    ...                                                                                      timeout=1800
    IM Wait Until SWM usageState Should Be Busy         retry=5 min                          retry_interval=10 sec
    Sleep  10
    log to console      check that /stb/dnr_temp is populated
     ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	dnr_temp
#    Should Be Equal As Strings  ${output}  dnr_temp
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/dnr_temp/
#    should contain   ${output}  	HashContainerSpecific_${active_sw_version}.txt
#    should contain   ${output}  	TargetBD_${active_sw_version}.xml
#    should contain   ${output}  	dnr-files_*.conf
#    should contain   ${output}  	dnr-distribute_*.sh
    ${output_dnr_temp}=  run keyword and return status  should not be empty  ${output}
    Sleep  10
    log to console      sw activation ongoing
    keyword.IM Wait Until SW activation is ongoing    retry=50 min    retry_interval=5 sec
#    Sleep  180

Get active and passive sw versions before sw update
	PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${pre_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${pre_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${pre_update_active_sw}
	set test variable	   ${pre_update_passive_sw}

Get active and passive sw versions after sw update
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post_update_active_sw}
	set test variable	   ${post_update_passive_sw}

Get active and passive sw versions before rollback
	PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${pre_rollback_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${pre_rollback_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${pre_rollback_active_sw}
	set test variable	   ${pre_rollback_passive_sw}

Get active and passive sw versions after rollback
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post_rollback_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post_rollback_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post_rollback_active_sw}
	set test variable	   ${post_rollback_passive_sw}

Check if sw after sw update is the same
#    [Arguments]     ${post_update_active_sw}
#    ...             ${pre_update_active_sw}
    Log To Console  Check if SW ${post_update_passive_sw} is the same with ${pre_update_active_sw}
    Should Be True  '${post_update_passive_sw}' == '${pre_update_active_sw}'
    ...  msg=Post update SW doesn't match target Sw.

Check if sw after sw update is the same as active version
    Log To Console  Check if SW ${pre_update_active_sw} is the same with ${pre_update_active_sw}
    Should Be True  '${pre_update_active_sw}' == '${pre_update_active_sw}'
    ...  msg=Post update SW doesn't match target Sw.

Software_Rollback
    Get active and passive sw versions before rollback
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${pre_rollback_active_sw}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${pre_rollback_passive_sw}.xml
    ADMIN Rollback Software
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  240s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions after rollback
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${post_rollback_active_sw}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${post_rollback_passive_sw}.xml

check if the dnr files distribution was successful
#    Run    mv /tmp/btslog2/SYSLOG* /tmp/btslog2/enb_syslog.log
     Run   cat /tmp/btslog2/SYSLOG* > /tmp/btslog2/SYSLOG_concatenate.log
     ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "STB Mount with succeeded"
#    Log To Console    \${syslog} ="temperature"
#    [Return]    ${syslog}
    Should contain   ${syslog}   STB Mount with succeeded

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DNR Mount with succeeded"
#    [Return]    ${syslog}
    Should contain   ${syslog}  DNR Mount with succeeded

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DnR: HashContainer file downloaded with success"
#    [Return]    ${syslog}
    Should contain   ${syslog}  DnR: HashContainer file downloaded with success

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DnR: HashContainerSignature file downloaded with success"
#    [Return]    ${syslog}
    Should contain   ${syslog}  DnR: HashContainerSignature file downloaded with success

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "Hash files downloaded with success, start DnR-BD distribution"
#    [Return]    ${syslog}
    Should contain   ${syslog}  Hash files downloaded with success, start DnR-BD distribution

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "Runtime DNR install script completed"
#    [Return]    ${syslog}
    Should contain   ${syslog}  Runtime DNR install script completed

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DnR: Start to perform clean up"
#    [Return]    ${syslog}
    Should contain   ${syslog}  DnR: Start to perform clean up

    ${syslog}    OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "Mount DNR RO succeeded"
#    [Return]    ${syslog}
    Should contain   ${syslog}  Mount DNR RO succeeded
#    Run    mv /tmp/btslog2/enb_syslog.log /tmp/btslog2/SYSLOG.LOG

Check if RMOD is in availabilityStatus Online
    [Arguments]      ${timeout}=30s
    ${status}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=Online
    Run Keyword Unless   ${status}    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=None

check if swr is successfully done
    ${status}  Wait Until Keyword Succeeds  20  0.1      ADMIN INFOMODEL Check Parameter Value In Dictionary
        ...    dist_name=/MRBTS-1/RAT-1/SWM-${BTS_side}
        ...    dict_name=swDownloadInfo
        ...    dict_param=result
        ...    value=Success
#        Should Be True  '${value}' == '${swDownloadInfo.result}'

Check recovery partition before rollback
    ${content1}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/
    ${content1}  Set Variable    ${content1}
    set test variable  ${content1}
    ${output1}=  SYSTEM Execute Command On gNB
    ...    command=mkdir /ffs/dnr_partition1
    ${output1}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/
#    Sleep  5
    wait until keyword succeeds  20  5   should contain  ${output1}  	dnr_partition1
    SYSTEM Execute Command On gNB
    ...    command=mount -r /dev/sda6 /ffs/dnr_partition1/
    Sleep  5
    ${output1}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/dnr_partition1/
    [Return]    ${output1}
    ${output1_dnr}=  run keyword and return status  should not be empty  ${output1}
    ${output1_dnr}=   Set variable   ${output1}
	set test variable      ${output1}

Check recovery partition after rollback
    ${content2}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/
    ${output2}=  SYSTEM Execute Command On gNB
    ...    command=mkdir /ffs/dnr_partition2
#    Sleep  5
    ${output2}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/
    wait until keyword succeeds  20  5   should contain  ${output2}  	dnr_partition2
    SYSTEM Execute Command On gNB
    ...    command=mount -r /dev/sda6 /ffs/dnr_partition2/
    Sleep  5
    ${output2}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/dnr_partition2/
    [Return]    ${output2}
    ${output2_dnr}=  run keyword and return status  should not be empty  ${output2}
    ${output2_dnr}=   Set variable   ${output2}
	set test variable      ${output2}

Check if recovery partition content after rollback is the same
    ${status}    Run Keyword And Return Status    Should Be Equal   ${output1}    ${output2}
    [Return]     ${status}


Unmount dnr partition
    ${content3}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/
    ${output3}=  SYSTEM Execute Command On gNB
    ...    command=umount -f /ffs/dnr_partition2
    ${output3}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/dnr_partition2/
    Should Be Empty    ${output3}
    ${output3}=  SYSTEM Execute Command On gNB
    ...    command=rm -rf /ffs/dnr_partition2
    ${output3}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/
    ${output3}=  Set Variable    ${output3}
    set test variable      ${output3}
    ${status}    Run Keyword And Return Status    Should Be Equal   ${output3}    ${content1}
    [Return]     ${status}

Get Status Should Be Equal
    [Documentation]    Returns Boolean. True or False.
    [Arguments]        ${first}
    ...                ${second}
    ${status}    Run Keyword And Return Status    Should Be Equal    ${first}    ${second}
    [Return]     ${status}

Prepare build for SWR
    Set Suite Variable    ${active_software}    ${OUT_PASSIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS00
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Set Suite Variable    ${T2_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T2.zip
    ADMIN Update Software With Activation
    ...            sw_package=${SW_DESTINATION}/${main_package}
    ...            timeout=2000
    log to console  sw activation ongoing - BTS reset
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  240s  10s    Check if RMOD is in availabilityStatus Online


ADMIN Update Software With Activation for T1
    ADMIN Update Software With Activation
    ...                             sw_package=${OUTPUT_DIR}/${T1_package}
    ...                             timeout=1500

Prepare SWR for T1 when T1 is already on active partition
    Set Suite Variable    ${active_software}    ${OUT_PASSIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS00
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Set Suite Variable    ${T2_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T2.zip
    ADMIN Update Software With Activation
    ...            sw_package=${OUTPUT_DIR}/${T1_package}
    ...            timeout=2000
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  240s  10s    Check if RMOD is in availabilityStatus Online

Unzip/zip sw build when DnRSW files are missing

    Run     unzip -o ${SW_DESTINATION}/${T1_package} -d /tmp
    Run     ls -ltr /tmp/bts_sw/DnR/FCTP
    Run     rm -rf /tmp/bts_sw/DnR/FCTP/dnr-files*
    Run     zip -r ${OUTPUT_DIR}/${T1_package} /tmp/bts_sw
    Remove Directory     /tmp/bts_sw   recursive=True

check messages when DnRSW files are missing
    Run   cat /tmp/btslog2/SYSLOG* > /tmp/btslog2/SYSLOG_concatenate.log
    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "failed download nRetry=0 aDownFileSucc=0 SRC=/DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   failed download nRetry=0 aDownFileSucc=0 SRC=/DnR/FCTP/dnr-files_
    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep ".retryDownload 1 for DEST /ram//DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   retryDownload 1 for DEST /ram//DnR/FCTP/dnr-files_

     ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep ".conf : Incremented failure count. Now its 1"
#    [Return]    ${syslog}
    Should contain   ${syslog}   .conf : Incremented failure count. Now its 1

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "failed download nRetry=1 aDownFileSucc=0 SRC=/DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   failed download nRetry=1 aDownFileSucc=0 SRC=/DnR/FCTP/dnr-files_

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "retryDownload 2 for DEST /ram//DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   retryDownload 2 for DEST /ram//DnR/FCTP/dnr-files_

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep ".conf : Incremented failure count. Now its 2"
#    [Return]    ${syslog}
    Should contain   ${syslog}   .conf : Incremented failure count. Now its 2

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DnR: Downloading failed for /ram//DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   DnR: Downloading failed for /ram//DnR/FCTP/dnr-files_

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DnR: Start to perform clean up"
#    [Return]    ${syslog}
    Should contain   ${syslog}   DnR: Start to perform clean up

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "Should proceed with DNR remove corrupt files"
#    [Return]    ${syslog}
     run_keyword_and_ignore_error  Should contain   ${syslog}   Should proceed with DNR remove corrupt files

check messages when DnRSW files are missing for robustness
    Run   cat /tmp/btslog2/SYSLOG* > /tmp/btslog2/SYSLOG_concatenate.log
    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c "failed download nRetry=0 aDownFileSucc=0 SRC=/DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5
    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c ".retryDownload 1 for DEST /ram//DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

     ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c ".conf : Incremented failure count. Now its 1"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c "failed download nRetry=1 aDownFileSucc=0 SRC=/DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c "retryDownload 2 for DEST /ram//DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c ".conf : Incremented failure count. Now its 2"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c "DnR: Downloading failed for /ram//DnR/FCTP/dnr-files_"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c "DnR: Start to perform clean up"
#    [Return]    ${syslog}
    Should contain   ${syslog}   5

    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep -c "Should proceed with DNR remove corrupt files"
#    [Return]    ${syslog}
     run_keyword_and_ignore_error  Should contain   ${syslog}   5
