*** Settings ***
Documentation     author: ruiyu.han
...               contact: ruiyu,han@nokia-sbell.com
...               squad group: SG_07
...               feature : CB012144

Library           OperatingSystem
Library           Collections
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/libraries/snapshot_files.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB012144/Resource/resource.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library     SSHLibrary


*** Keywords ***
Case Setup for CB012144
    [Arguments]
    Pass Execution If    '${MRBTS_ID}' in @{TESTLINE_ingore}
    ...    message=Test skipped because ${MRBTS_ID} is in TESTLINE_ingore_list
    ${fault_status}    run keyword and return status
    ...    Wait Until Keyword Succeeds   30m   1m   Fault With Alarm Should Be Present    FaultID=4420    AlarmID=7115
    run keyword if  ${fault_status}   wait until keyword succeeds   30m   1m
    ...   Fault With Alarm Should Not Be Present    FaultID=4420    AlarmID=7115
    robot_common_operations.Common Case Setup
#    Run Keyword And Ignore Error   Update Rad for BTSSyslog in AaShell via SSHLibrary
    Run Keyword And Ignore Error   Start Syslog Collection
    COAM Login
#    CI_interface.Common Suite Setup
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    COAM Backup Full SCF
    ${smod_name_postion}    Get SMOD Position Dic    full_scf_path=${OUTPUT_DIR}/full_commission.xml
    ${bbmod_name_postion}    Get BBMOD Position Dic    full_scf_path=${OUTPUT_DIR}/full_commission.xml
    ${rmod_name_dic}        Get RMOD SerialNumber List    full_scf_path=${OUTPUT_DIR}/full_commission.xml
    ${productcode_str}    Get Units ProductCode    full_scf_path=${OUTPUT_DIR}/full_commission.xml
    Set Suite Variable    ${smod_name_postion}
    Set Suite Variable    ${bbmod_name_postion}
    Set Suite Variable    ${rmod_name_dic}
    Set Suite Variable    ${productcode_str}
    Pass Execution If    ${productcode_str.count('M')}>0 or ${productcode_str.count('Y')}>0 or ${productcode_str.count('X')}>0
    ...    message=Test skipped because ${MRBTS_ID} have unofficial board!

     ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${OUTPUT_DIR}/full_commission.xml
     ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${OUTPUT_DIR}/full_commission.xml
     set test variable     ${rmod_cell_mapping}
     set test variable     ${rmod_serial_mapping}
     ${radios}   Set Variable   ${tl.gnbs[0].dus[0].rus}
     ${ru_count}   Get Length   ${radios}
     set test variable     ${radios}
     set test variable     ${ru_count}

Case Teardown for CB012144
    Pass Execution If    '${MRBTS_ID}' in @{TESTLINE_ingore}
    ...    message=Test skipped because ${MRBTS_ID} is in TESTLINE_ingore_list
    Pass Execution If    ${productcode_str.count('M')}>0 or ${productcode_str.count('Y')}>0 or ${productcode_str.count('X')}>0
    ...    message=Test skipped because ${MRBTS_ID} have unofficial board!
    Run Keyword If Test Passed    RU Log Operation Teardown if keyword passed
    Run Keyword If Test Failed    RU Log Operation Teardown if keyword failed
    Check Extra Reset From Blackbox
    Wait Until Keyword Succeeds   3x   30s   COAM Login
    Run Keyword If Test Failed    Catch Snapshot COAM
    Run Keyword and Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Stop and Save Syslog Collection
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown
    Run Keyword And Ignore Error   COAM Logout

Verify Snapshot has SMOD BBMOD POST
    [Arguments]    ${path}    ${smod_name_postion}    ${bbmod_name_postion}
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${path} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    wait until keyword succeeds    5min   30s
    ...   snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
    ${strs}    Convert To String    ${FILE_STRUCT}
    ${smodbbmod_blackbox_list}    Create List
    ${L1_blackbox_list}    Create List
    ${timestamp_check_ignore}    Create List
    #verify SMOD post blackbox
    FOR    ${smod_pro}    IN    @{smod_name_postion}
          Continue For Loop If    '${smod_name_postion['${smod_pro}']}' in @{BBPlatform_ignore}
          ${filename}    run keyword and continue on failure    Should Match Regexp
          ...      ${strs}    BTS${GLOBAL_BTS_ID}_${smod_pro}011_blackbox_post_result_A\\S*.xz
          Append To List    ${smodbbmod_blackbox_list}    ${filename}
          run keyword if   '${smod_name_postion['${smod_pro}']}' in @{BB_timestamp_ingore}
          ...   Append To List    ${timestamp_check_ignore}    ${filename}
          ${filename}    run keyword if   '${smod_name_postion['${smod_pro}']}' in @{BB_2file_product}
          ...   run keyword and continue on failure
          ...   Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${smod_pro}011_blackbox_post_result_B\\S*.xz
          run keyword if   '${smod_name_postion['${smod_pro}']}' in @{BB_2file_product}    run keywords
          ...    Append To List    ${smodbbmod_blackbox_list}    ${filename}
          ...   AND   run keyword if   '${smod_name_postion['${smod_pro}']}' in @{BB_timestamp_ingore}
          ...   Append To List    ${timestamp_check_ignore}    ${filename}
    END

    #verify SMOD L1 post blackbox
    FOR    ${smod_pro}    IN    @{smod_name_postion}
          Continue For Loop If    '${smod_name_postion['${smod_pro}']}' in @{BBPlatform_ignore}
          ${filename}    run keyword if   '${smod_name_postion['${smod_pro}']}' in @{L1_2FILE_product}
          ...   run keyword and continue on failure      Should Match Regexp
          ...   ${strs}    BTS${GLOBAL_BTS_ID}_${smod_pro}011_blackbox_post_results_\\S+_B.\\S*.xz
          run keyword if   '${smod_name_postion['${smod_pro}']}' in @{L1_2FILE_product}    Append To List    ${L1_blackbox_list}    ${filename}
          ${filename}    run keyword if   '${smod_name_postion['${smod_pro}']}' in @{L1_2FILE_product}
          ...   run keyword and continue on failure    Should Match Regexp
          ...   ${strs}    BTS${GLOBAL_BTS_ID}_${smod_pro}011_blackbox_post_results_\\S+_C\\S*.xz
          run keyword if   '${smod_name_postion['${smod_pro}']}' in @{L1_2FILE_product}
          ...   Append To List    ${L1_blackbox_list}    ${filename}
    END

    Set Test Variable    ${smodbbmod_blackbox_list}
    Set Test Variable    ${L1_blackbox_list}
    Set Test Variable    ${timestamp_check_ignore}
    ${bbmod_name_postion_value}    Get Variable Value    ${bbmod_name_postion}
    Return From Keyword If    ${bbmod_name_postion_value}==${None}

    #verify bbmod post blackbox
    FOR    ${bbmod}    IN    @{bbmod_name_postion}
        Continue For Loop If    '${bbmod_name_postion['${bbmod}']}' in @{BBPlatform_ignore}
        ${filename}    run keyword and continue on failure    Should Match Regexp
        ...   ${strs}    BTS${GLOBAL_BTS_ID}_${bbmod}\\dD_blackbox_post_result_A\\S*.xz
        run keyword if   '${bbmod_name_postion['${bbmod}']}' in @{BB_timestamp_ingore}
          ...   Append To List    ${timestamp_check_ignore}    ${filename}
        Append To List    ${smodbbmod_blackbox_list}    ${filename}
        ${filename}    run keyword if   '${bbmod_name_postion['${bbmod}']}' in @{BB_2file_product}
        ...   run keyword and continue on failure
        ...    Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${bbmod}\\dD_blackbox_post_result_B\\S*.xz
        run keyword if   '${bbmod_name_postion['${bbmod}']}' in @{BB_2file_product}   run keywords
        ...    Append To List    ${smodbbmod_blackbox_list}    ${filename}
        ...    AND   run keyword if   '${bbmod_name_postion['${bbmod}']}' in @{BB_timestamp_ingore}
          ...   Append To List    ${timestamp_check_ignore}    ${filename}
    END

   #veriy bbmod L1 post blackbox
    FOR    ${bbmod}    IN    @{bbmod_name_postion}
        Continue For Loop If
        ...    '${bbmod_name_postion['${bbmod}']}' in @{BBPlatform_ignore} or '${bbmod_name_postion['${bbmod}']}' in @{L1BB_ignore}
        ${filename}    run keyword and continue on failure    Should Match Regexp
        ...    ${strs}    BTS${GLOBAL_BTS_ID}_${bbmod}\\dD_blackbox_post_results_\\S+_B\\S*.xz
        Append To List    ${L1_blackbox_list}    ${filename}
        ${filename}    run keyword if   '${bbmod_name_postion['${bbmod}']}' in @{L1_2FILE_product}
        ...   run keyword and continue on failure   Should Match Regexp
        ...       ${strs}    BTS${GLOBAL_BTS_ID}_${bbmod}\\dD_blackbox_post_results_\\S+_C\\S*.xz
        run keyword if   '${bbmod_name_postion['${bbmod}']}' in @{L1_2FILE_product}    Append To List    ${L1_blackbox_list}    ${filename}
    END
    Set Test Variable    ${smodbbmod_blackbox_list}
    Set Test Variable    ${L1_blackbox_list}

Get SMOD Position Dic
    [Arguments]   ${full_scf_path}
     ${source}   XML.Parse XML   ${full_scf_path}
    ${smod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]
    &{smod_name_postion}   Create Dictionary
    FOR   ${smod_r}   IN   @{smod_r_list}
        ${productName}    XML.Get Element Text   ${smod_r}   p[@name="productName"]
        ${productName}    Fetch From Left    ${productName}    ${SPACE}
        ${productName}    Set Variable    ${productName.strip()}
        ${status}    ${horizontal}   Run Keyword And Ignore Error    XML.Get Element Text   ${smod_r}   p[@name="horizontalPosition"]
        run keyword if  '${status}'!='FAIL'    Set To Dictionary    ${smod_name_postion}    ${horizontal}=${productName}
        run keyword if   '${status}'=='FAIL'   Set To Dictionary    ${smod_name_postion}   1=${productName}
    END
    [Return]     ${smod_name_postion}


Get BBMOD Position Dic
    [Arguments]   ${full_scf_path}
    ${source}   XML.Parse XML   ${full_scf_path}
    &{bbmod_name_postion}     Create Dictionary
    ${bbmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:BBMOD_R"]
    ${empty}    Run Keyword And Return Status    Should Be Empty    ${bbmod_r_list}
    Return From Keyword If    ${empty}
    FOR   ${bbmod_r}   IN   @{bbmod_r_list}
        ${horizontal}   XML.Get Element Text   ${bbmod_r}   p[@name="horizontalPosition"]
        ${vertical}     XML.Get Element Text   ${bbmod_r}   p[@name="verticalPosition"]
        ${productName}    XML.Get Element Text   ${bbmod_r}   p[@name="productName"]
        ${productName}    Fetch From Left    ${productName}    ${SPACE}
        ${productName}    Set Variable    ${productName.strip()}
        &{bbmod_name_postion}     Set To Dictionary    ${bbmod_name_postion}    ${horizontal}${vertical}=${productName}
    END
    [Return]    ${bbmod_name_postion}


Get Units ProductCode
    [Arguments]   ${full_scf_path}
    ${source}   XML.Parse XML   ${full_scf_path}
    ${smod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]
    ${bbmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:BBMOD_R"]
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    ${unit_list}    Combine Lists    ${smod_r_list}    ${bbmod_r_list}    ${rmod_r_list}
    ${empty}    Run Keyword And Return Status    Should Be Empty    ${unit_list}
    Return From Keyword If    ${empty}
    ${productcode_list}    Create List
    FOR   ${unit}   IN   @{unit_list}
        ${productCode}    XML.Get Element Text   ${unit}   p[@name="productCode"]
        Append to List    ${productcode_list}    ${productCode}
    END

    ${productcode_str}     Convert To String     ${productcode_list}
    [Return]    ${productcode_str}



Verify SMOD BBMOD POST is in Reset timeRange
    [Arguments]    ${smodbbmod_blackbox_list}    ${L1_blackbox_list}    ${snapshot_path}    ${start_time}    ${stop_time}
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${snapshot_path} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    wait until keyword succeeds    5min   30s
    ...   snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
    Set Test Variable    ${FILE_STRUCT}
    ##verify SMOD post blackbox timerange correct
    run    rm -rf ${OUTPUT_DIR}/snapshot/bb_blackbox;mkdir ${OUTPUT_DIR}/snapshot/bb_blackbox
    FOR  ${bb_blackbox}  IN  @{smodbbmod_blackbox_list}
        Continue For Loop If    '${bb_blackbox}' in @{timestamp_check_ignore}
        run keyword and continue on failure
        ...       Verify Single SMOD BBMOD POST is in Reset timeRange    bb_blackbox=${bb_blackbox}    FILE_STRUCT=${FILE_STRUCT}
        ...   start_time=${start_time}    stop_time=${stop_time}
    END
    ###verify L1 post blackbox timerange correct
    run    rm -rf ${OUTPUT_DIR}/snapshot/L1_blackbox;mkdir ${OUTPUT_DIR}/snapshot/L1_blackbox
    FOR  ${L1_blackbox}  IN  @{L1_blackbox_list}
        run keyword and continue on failure
        ...   Verify Single L1 POST is in Reset timeRange    L1_blackbox=${L1_blackbox}    FILE_STRUCT=${FILE_STRUCT}
        ...   start_time=${start_time}    stop_time=${stop_time}
    END


Verify Single SMOD BBMOD POST is in Reset timeRange
    [Arguments]    ${bb_blackbox}    ${FILE_STRUCT}    ${start_time}    ${stop_time}
    FOR  ${key}  IN  @{FILE_STRUCT}
        Continue For Loop If    ${key.endswith('.zip')}==${False}
        ${value}    Get From Dictionary    ${FILE_STRUCT}    ${key}
        run keyword if  '${bb_blackbox}' in ${value}
        ...   RUN keywords
        ...   run    rm -rf ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run    unzip ${OUTPUT_DIR}/snapshot/${key} -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run   xz -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${bb_blackbox}
        ...   AND   run   cp ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${bb_blackbox.split('.xz')[0]} ${OUTPUT_DIR}/snapshot/bb_blackbox
    END

    ${content}    OperatingSystem.Get File    ${OUTPUT_DIR}/snapshot/bb_blackbox/${bb_blackbox.split('.xz')[0]}
    ${time_content}   Get Regexp Matches   ${content}   \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d.\\d+
    log to console  ${time_content}
    ${converttime_list}    Create List
    FOR   ${time}   IN   @{time_content}
        ${datetime}   DateTime.Convert Date   date=${time}+0000   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S.%f%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Should Be True    ${timestamp} > ${start_time}
        Should Be True    ${timestamp} < ${stop_time}
        Append To List    ${converttime_list}    ${timestamp}
    END
    ${timelengh}    Evaluate    len(${converttime_list})
    run keyword if  not '${bb_blackbox}' in @{timestamp_check_ignore}
    ...   should be equal as numbers    ${timelengh}    3   msg=timestamp not be formatted!
    run keyword if  not '${bb_blackbox}' in @{timestamp_check_ignore}
    ...   should be true    ${converttime_list[0]}<${converttime_list[1]}<${converttime_list[2]}


Verify Single L1 POST is in Reset timeRange
    [Arguments]    ${L1_blackbox}    ${FILE_STRUCT}    ${start_time}    ${stop_time}
    FOR  ${key}  IN  @{FILE_STRUCT}
        Continue For Loop If    ${key.endswith('.zip')}==${False}
        ${value}    Get From Dictionary    ${FILE_STRUCT}    ${key}
        run keyword if  '${L1_blackbox}' in ${value}
        ...   RUN keywords
        ...   run    rm -rf ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run    unzip ${OUTPUT_DIR}/snapshot/${key} -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run   xz -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${L1_blackbox}
        ...   AND   run   cp ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${L1_blackbox.split('.xz')[0]} ${OUTPUT_DIR}/snapshot/L1_blackbox
    END

    ${content}    OperatingSystem.Get File    ${OUTPUT_DIR}/snapshot/L1_blackbox/${L1_blackbox.split('.xz')[0]}
    ${ramquick_content}    Fetch From Left    ${content}    Test type: Check RAM full
    ${time_content}   Get Regexp Matches   ${ramquick_content}
    ...   timestamp: (\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\+0\\d:00)   1
    log to console  ${time_content}
    ${converttime_list}    Create List
    FOR   ${time}   IN   @{time_content}
        ${datetime}    DateTime.Convert Date   date=${time}   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Should Be True    ${timestamp} > ${start_time}
        Should Be True    ${timestamp} < ${stop_time}
        Append To List    ${converttime_list}    ${timestamp}
    END
    ${timelengh}    Evaluate    len(${converttime_list})
    should be equal as numbers    ${timelengh}    3   msg=timestamp not be formatted!
    should be true    ${converttime_list[0]}>${converttime_list[1]}>${converttime_list[2]}

Modify ALL RU timeBetweenSaveOnNVM and Activate
    [Arguments]    ${init_value}=${300}    ${target_value}=${86400}    ${connection}=COAM
    FOR  ${i}   IN RANGE    ${ru_count}
         Modify timeBetweenSaveOnNVM Value In BBOX File    init_value=${init_value}    target_value=${target_value}
         ...    ru_index=${i+1}    connection=${connection}
    END
    COAM Reset ALL RMOD
    Wait Until Keyword Succeeds    20min   1min    COAM Check all cells should be onair    connection=COAM

Get RMOD SerialNumber List
    [Arguments]   ${full_scf_path}
    ${source}   XML.Parse XML   ${full_scf_path}
    &{rmod_name_dic}   Create Dictionary
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    ${empty}    Run Keyword And Return Status    Should Be Empty    ${rmod_r_list}
    Return From Keyword If    ${empty}
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${productName}    XML.Get Element Text   ${rmod_r}   p[@name="productName"]
        ${serialNumber}    XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        Set To Dictionary     ${rmod_name_dic}    ${serialNumber}=${productName}
    END
    [Return]    ${rmod_name_dic}

Verify Snapshot has RMOD POST
    [Arguments]    ${snapshot_path}    ${rmod_name_dic}
    Log To Console  Verify Snapshot has RMOD POST at: ${snapshot_path}
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${path} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    wait until keyword succeeds    5min   30s
    ...   snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot

    #veriy rmod have bbox5 file
    ${strs}    Convert To String    ${FILE_STRUCT}
    ${BBOX5_list}    Create List
    FOR    ${rmod}    IN    @{rmod_name_dic}
        ${filename}    Should Match Regexp       ${strs}    BTS_${rmod}_RMOD_L_\\S*_BBOX5_all
        Append To List    ${BBOX5_list}    ${filename}
    END

    #veriy rmod in bbox5 have post
    FOR  ${BBOX5_name}  IN  @{BBOX5_list}
         Verify Single BBOX5 Have RMOD Post    BBOX5_name=${BBOX5_name}    FILE_STRUCT=${FILE_STRUCT}
    END

#Verify Single BBOX5 have RMOD Post
#    [Arguments]    ${BBOX5_name}    ${FILE_STRUCT}
#    :For  ${key}  IN  @{FILE_STRUCT}
#        Continue For Loop If    ${key.endswith('.zip')}==${False}
#        ${value}    Get From Dictionary    ${FILE_STRUCT}    ${key}
#        run keyword if  '${BBOX5_name}.zip' in ${value}
#        ...   RUN keywords
#        ...   run    rm -rf ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
#        ...   AND    run    unzip ${OUTPUT_DIR}/snapshot/${key} -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
#        ...   AND   run   unzip ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${BBOX5_name}.zip -d ${OUTPUT_DIR}/snapshot/${BBOX5_name}
#    END
#
#    ${post_content}   Catenate   SEPARATOR=
#    ...    Item type: POST_results\n
#    ...    Item id: POST_results\n
#    ...    Last write: \\S+\n
#    ...    POST\\[0\\] result: \\S+\n
#    ...    POST\\[0\\] type: \\S+\n
#    ...    POST\\[0\\] timestamp: \\S+
#    #verify rmod post
#    ${content}    OperatingSystem.Get File    ${OUTPUT_DIR}/snapshot/${BBOX5_name}/BBOX5
#    Should Match Regexp    ${content}    ${post_content}
#
#
#Power Reset RMOD and Controlled Reset
#     All Site RUs Power Reset
#     COAM Reset ALL RMOD

Verify RMOD POST is in Reset timeRange when controlled reset
    [Arguments]    ${start_time}    ${stop_time}
    #veriy rmod have bbox5 file
    ${strs}    Convert To String    ${FILE_STRUCT}
    ${BBOX5_list}    Create List
    ${FRM5_BBOX5_LIST}    Create List
    FOR    ${rmod}    IN    @{rmod_name_dic}
        Continue For Loop If    '${rmod_name_dic['${rmod}']}' in @{RMOD_ignore}
        ${filename}   Run Keyword And Continue On Failure
        ...     Should Match Regexp       ${strs}    BTS\\d*_${rmod}_RMOD_L_\\S*_BBOX5_all.zip
        ...   msg=${rmod}:${rmod_name_dic['${rmod}']} has no BBOX5 FILE
        ${is_frm5}    Run Keyword And Return Status    Check RMOD is FRM5    rmod_sn=${rmod}    full_scf_path=${OUTPUT_DIR}/full_commission.xml
        Run Keyword If    ${is_frm5}    Append To List    ${FRM5_BBOX5_LIST}    ${filename}
        Run Keyword If    not ${is_frm5}    Append To List    ${BBOX5_list}    ${filename}
    END

    set suite variable    ${BBOX5_list}
    set suite variable    ${FRM5_BBOX5_LIST}

     ##verify FRM5 RMOD blackbox existing
    FOR  ${BBOX5}  IN  @{FRM5_BBOX5_LIST}
        Run Keyword And Continue On Failure
        ...    Verify Single RMOD POST is Existing    BBOX5=${BBOX5}    FILE_STRUCT=${FILE_STRUCT}
    END

    ##verify RMOD blackbox timerange correct
    FOR  ${BBOX5}  IN  @{BBOX5_list}
        Run Keyword And Continue On Failure
        ...   Verify Single RMOD POST is in Reset timeRange    BBOX5=${BBOX5}    FILE_STRUCT=${FILE_STRUCT}
        ...   start_time=${start_time}    stop_time=${stop_time}
    END

Verify Single RMOD POST is in Reset timeRange
    [Arguments]    ${BBOX5}    ${FILE_STRUCT}    ${start_time}    ${stop_time}
    FOR  ${key}  IN  @{FILE_STRUCT}
        Continue For Loop If    ${key.endswith('.zip')}==${False}
        ${value}    Get From Dictionary    ${FILE_STRUCT}    ${key}
        run keyword if  '${BBOX5}' in ${value}
        ...   RUN keywords
        ...   run    rm -rf ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run    unzip ${OUTPUT_DIR}/snapshot/${key} -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run   unzip ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${BBOX5} -d ${OUTPUT_DIR}/snapshot/${BBOX5.split('.')[0]}
    END
    ${content}    OperatingSystem.Get File    ${OUTPUT_DIR}/snapshot/${BBOX5.split('.')[0]}/BBOX5
    ${post_content}    Fetch From Right    ${content}    Item type: POST_results
    ${post_content}    Fetch From Left    ${post_content}    ---
    ${time_content}   Get Regexp Matches   ${post_content}
    ...   timestamp: (\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\+0\\d:00)   1
#    ${length_time}    Evaluate    len(${start_time_list})
    ${time_content}    Get Slice From List    ${time_content}    0    3
    log to console  ${time_content}
    ${converttime_list}    Create List
    FOR   ${time}   IN   @{time_content}
        ${datetime}    DateTime.Convert Date   date=${time}   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Should Be True    ${timestamp} > ${start_time}    msg=${timestamp} is not greater than ${start_time}
        Should Be True    ${timestamp} < ${stop_time}     msg=${timestamp} is not less than ${stop_time}
        Append To List    ${converttime_list}    ${timestamp}
    END
    ${timelengh}    Evaluate    len(${converttime_list})
    should be equal as numbers    ${timelengh}    3   msg=timestamp not be formatted!
    should be True    ${converttime_list[0]}>${converttime_list[1]}>${converttime_list[2]}
    ...   msg=the 3 timestamp is not in order


Verify Single RMOD POST is Existing
    [Arguments]    ${BBOX5}    ${FILE_STRUCT}
    FOR  ${key}  IN  @{FILE_STRUCT}
        Continue For Loop If    ${key.endswith('.zip')}==${False}
        ${value}    Get From Dictionary    ${FILE_STRUCT}    ${key}
        run keyword if  '${BBOX5}' in ${value}
        ...   RUN keywords
        ...   run    rm -rf ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run    unzip ${OUTPUT_DIR}/snapshot/${key} -d ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}
        ...   AND   run   unzip ${OUTPUT_DIR}/snapshot/${key.split('.')[0]}/${BBOX5} -d ${OUTPUT_DIR}/snapshot/${BBOX5.split('.')[0]}
    END
    ${content}    OperatingSystem.Get File    ${OUTPUT_DIR}/snapshot/${BBOX5.split('.')[0]}/BBOX5
    ${post_content}    Fetch From Right    ${content}    Item type: POST_results
    ${post_content}    Fetch From Left    ${post_content}    ---
    ${time_content}   Get Regexp Matches   ${post_content}
    ...   timestamp: (\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\+0\\d:00)   1
#    ${length_time}    Evaluate    len(${start_time_list})
    ${time_content}    Get Slice From List    ${time_content}    0    3
    ${timelengh}    Get Length    ${time_content}
    Should Be Equal As Numbers    ${timelengh}    3
    ...    msg=POST result have issue!


Check RMOD is FRM5
    [Arguments]    ${rmod_sn}    ${full_scf_path}
    ${source}   XML.Parse XML   ${full_scf_path}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}    XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        Continue For Loop If    '${serialNumber}' != '${rmod_sn}'
        ${activeSwBuild}    XML.Get Element Text   ${rmod_r}   p[@name="activeSwBuild"]
        Log To Console    RMOD ${rmod_sn} activeSwBuild=${activeSwBuild}
        ${is_frm5}    Evaluate    "FRM5" in """${activeSwBuild}"""
        Return From Keyword If    ${is_frm5}    ${True}
        Fail    RMOD ${rmod_sn} is not FRM5 platform, activeSwBuild=${activeSwBuild}
    END
    Fail    RMOD ${rmod_sn} not found in full SCF


#Update Rad for BTSSyslog in AaShell via SSHLibrary
#    [Documentation]  Update Rad for BTS Syslog Collection via telnet
#    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#    Log To Console   Update RaD for BTSSyslog in AaShell Starting ...
#    SSHLibrary.open connection  ${host}
#    SSHLibrary.Login  ${username}  ${password}
##    ${sm_ip}  Set Variable If  ${is_rfSharing}  192.168.255.5  192.168.255.1
#    ${smod_local_ip}  Set Variable   127.0.0.1
#    SSHLibrary.Write  kill $(ps aux | grep 'telnet')
#    SSHLibrary.Read until  ~ >
#    # Connect to AaShell
#    SSHLibrary.Write  telnet ${smod_local_ip} 15007
#    SSHLibrary.Read until  AaShell>
#    # update AasyslogUdpport and AasyslogUdpAddress in Aashell
#    SSHLibrary.Write  rad -w 0x10041 5
#    ${output}    wait until keyword succeeds  2x  3s  SSHLibrary.Read until    AaShell>
#    SSHLibrary.Write  rad -w 0x10042 0xC0A8FF7E
#    ${output}    wait until keyword succeeds  2x  3s  SSHLibrary.Read until    AaShell>
#    SSHLibrary.Write  rad -w 0x10043 0xC738
#    ${output}    wait until keyword succeeds  2x  3s  SSHLibrary.Read until    AaShell>
#    SSHLibrary.Write  quit
#    SSHLibrary.read until  ~ >
#    Log To Console    Update RaD for BTSSyslog in AaShell Done!
#    [Teardown]  Run Keyword And Ignore Error    SSHLibrary.Close Connection
