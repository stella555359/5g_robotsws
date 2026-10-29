*** Settings ***
Documentation       Test case for SyVe_CM_CB009451_H
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for TA_RAN_ST_CB009451-H_001_CM_Installing new FCT tool version to the FCE in online WebEM
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.08.2023 - New TC
    Set Tags    CM    UI    AUTHOR-Bin.7.Liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Install TA Origin FCT
    Step 2: Install Same FCT Package Failed
    Step 3: Install Lower Version FCT Package Failed
    Step 4: Install Last Or Middle Higher FCT Package Success
    Step 5: Install First Higher FCT Package Without Obsolete Success
    Step 6: Install First Higher FCT Package With Obsolete Success

Step ${index}: Install TA Origin FCT
    Log To Console    Step ${index}: Install TA Origin FCT
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${LOCAL_FCT_FILE}    ${REMOTE_FCT_FILE}
    SSHLibrary.Put File    ${FCT_RECOVER_FILE}    ${REMOTE_FCT_RECOVER_FILE}
    Append To List    ${EXCEL_FILE_LIST}    ${REMOTE_FCT_FILE}    ${REMOTE_FCT_RECOVER_FILE}
    Install FCT On NetAct    ${REMOTE_FCT_FILE}
    ${feature}    Get FCT Features On NetAct    ${FCT_FILE_FEATURE_FILTER}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}

Step ${index}: Install Same FCT Package Failed
    Log To Console    Step ${index}: Install Same FCT Package Failed
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Install -inputFile ${REMOTE_FCT_FILE} -v    return_stderr=${True}    return_rc=${True}
    Should Not Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    An identical FCT has already been installed   ignore_case=True
    Should Contain    ${stdout}    operation failed    ignore_case=True
    ${feature}    Get FCT Features On NetAct    ${FCT_FILE_FEATURE_FILTER}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}

Step ${index}: Install Lower Version FCT Package Failed
    Log To Console    Step ${index}: Install Lower Version FCT Package Failed
    ${Sub_Version_New}    Convert To Integer    ${FCT_VERSION_LIST[0]}
    ${FCT_Version_New}    Set Variable    ${Sub_Version_New-1}.${FCT_VERSION_LIST[1]}.${FCT_VERSION_LIST[2]}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New}    Tool Name=TA_CB009451_H_001    Abbreviated Tool Name=TA_CB009451_H_001
    ${New_FileName}    FCT_Excel.update_parameters    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx    #${LOCAL_FCT_FILE}
    ...    GENERAL-METADATA    ${Param_Value_Dic}
    ${time}    Get Time    epoch
    OperatingSystem.Move File    ${New_FileName}    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    ${New_FileName}    Set Variable    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    ${tmp_file_name}    Set Variable    ${New_FileName.split('/')[-1]}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${New_FileName}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Append To List    ${EXCEL_FILE_LIST}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Install -inputFile ${REMOTE_FCT_FOLDER}/${tmp_file_name} -v    return_stderr=${True}    return_rc=${True}
    Should Not Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}   The FCT version is lower than the existing one, operation failed
    ${feature}    Get FCT Features On NetAct    ${FCT_FILE_FEATURE_FILTER}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${0}

Step ${index}: Install Last Or Middle Higher FCT Package Success
    Log To Console    Step ${index}: Install Last Or Middle Higher FCT Package Success
    ${Sub_Version_Mid}    Convert To Integer    ${FCT_VERSION_LIST[1]}
    ${Sub_Version_Last}    Convert To Integer    ${FCT_VERSION_LIST[2]}
    ${index}    Evaluate    random.randint(0,1)    modules=random, sys
    ${FCT_Version_New1}    Set Variable If    ${index}==${0}
    ...    ${FCT_VERSION_LIST[0]}.${Sub_Version_Mid+1}.${FCT_VERSION_LIST[2]}    ${FCT_VERSION_LIST[0]}.${FCT_VERSION_LIST[1]}.${Sub_Version_Last+1}
    Set Test Variable    ${FCT_Version_New1}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New1}    Tool Name=TA_CB009451_H_001    Abbreviated Tool Name=TA_CB009451_H_001
    ${New_FileName}    FCT_Excel.update_parameters    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx    #${LOCAL_FCT_FILE}
    ...    GENERAL-METADATA    ${Param_Value_Dic}
    ${tmp_file_name}    Set Variable    ${New_FileName.split('/')[-1]}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${New_FileName}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Append To List    ${EXCEL_FILE_LIST}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Install FCT On NetAct    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    ${feature}    Get FCT Features On NetAct    ${FCT_FILE_FEATURE_FILTER}
    Should Be Equal As Integers    ${feature.__len__()}    ${0}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New1}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}

Step ${index}: Install First Higher FCT Package Without Obsolete Success
    Log To Console    Step ${index}: Install First Higher FCT Package Without Obsolete Success
    ${Sub_Version_Fst}    Convert To Integer    ${FCT_VERSION_LIST[0]}
    ${FCT_Version_New2}    Set Variable    ${Sub_Version_Fst+1}.${FCT_VERSION_LIST[1]}.${FCT_VERSION_LIST[2]}
    Set Test Variable    ${FCT_Version_New2}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New2}    Tool Name=TA_CB009451_H_001    Abbreviated Tool Name=TA_CB009451_H_001
    ${New_FileName}    FCT_Excel.update_parameters    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx    #${LOCAL_FCT_FILE}
    ...    GENERAL-METADATA    ${Param_Value_Dic}
    ${time}    Get Time    epoch
    OperatingSystem.Move File    ${New_FileName}    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    ${New_FileName}    Set Variable    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    ${tmp_file_name}    Set Variable    ${New_FileName.split('/')[-1]}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${New_FileName}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Append To List    ${EXCEL_FILE_LIST}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Install FCT On NetAct    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New1}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New2}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}

Step ${index}: Install First Higher FCT Package With Obsolete Success
    Log To Console    Step ${index}: Install First Higher FCT Package With Obsolete Success
    ${Sub_Version_New}    Convert To Integer    ${FCT_VERSION_LIST[0]}
    ${FCT_Version_New3}    Set Variable    ${Sub_Version_New+2}.${FCT_VERSION_LIST[1]}.${FCT_VERSION_LIST[2]}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New3}    Tool Name=TA_CB009451_H_001    Abbreviated Tool Name=TA_CB009451_H_001
    #Obsoletes version(s) :=5.2.0
    #${New_FileName1}    FCT_Excel.update_parameters    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx    #${LOCAL_FCT_FILE}
    #...    GENERAL-METADATA    ${Param_Value_Dic}
    #${New_FileName}    FCT_Excel.add_obsolete
    #...    ${New_FileName1}    GENERAL-METADATA    ${FCT_INFO["Abbreviated Tool Name"]}    ${FCT_Version_New2.split('.')[0]}
    ${Obsolete_List}    Create List    ${FCT_INFO["Abbreviated Tool Name"]}=${FCT_Version_New2.split('.')[0]}
    ${New_FileName}    FCT_Excel.update_with_obsoletes    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx
    ...    GENERAL-METADATA    ${Param_Value_Dic}    ${Obsolete_List}
    #OperatingSystem.Remove Files    ${New_FileName1}
    ${time}    Get Time    epoch
    OperatingSystem.Move File    ${New_FileName}    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    ${New_FileName}    Set Variable    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    ${tmp_file_name}    Set Variable    ${New_FileName.split('/')[-1]}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${New_FileName}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Append To List    ${EXCEL_FILE_LIST}    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    Install FCT On NetAct    ${REMOTE_FCT_FOLDER}/${tmp_file_name}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New1}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New2}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${0}
    ${feature_filter}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_Version_New3}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}

SetUp
    Common Test Setup    ${FALSE}    ${FALSE}    ${FALSE}
    Create Dummy FCT File
    Create FCT Recover File
    ${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    ...    Support Release(s) \\ NIDD adaptationId(s)
    Set Test Variable    ${REMOTE_FCT_FOLDER}    /d/oss/global/var/racprs/work
    ${file_name}    Set Variable    ${LOCAL_FCT_FILE.split('/')[-1]}
    Set Test Variable    ${REMOTE_FCT_FILE}    /d/oss/global/var/racprs/work/${file_name}
    ${file_name}    Set Variable    ${FCT_RECOVER_FILE.split('/')[-1]}
    Set Test Variable    ${REMOTE_FCT_RECOVER_FILE}    /d/oss/global/var/racprs/work/${file_name}
    #${FCT_INFO}    FCT_Excel.get_FCT_info    ${LOCAL_FCT_FILE}    GENERAL-METADATA    ${ParmName_Excel_list}
    ${FCT_Info}    FCT_Excel.get_FCT_info
    ...    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${ParmName_Excel_list}
    Set To Dictionary    ${FCT_Info}    Version=1.1.1    Tool Name=TA_CB009451_H_001    Abbreviated Tool Name=TA_CB009451_H_001
    ${FCT_Version}    Set Variable    ${FCT_INFO["Version"]}
    Set Test Variable    ${FCT_INFO}
    ${FCT_VERSION_LIST}    Split String    ${FCT_Version}    .
    ${EXCEL_FILE_LIST}    Create List
    ${FCT_FILE_FEATURE_FILTER}    Create Dictionary    toolName=${FCT_INFO["Abbreviated Tool Name"]}    toolVersion=${FCT_INFO["Version"]}
    Set Test Variable    ${FCT_FILE_FEATURE_FILTER}    #Filter for origin feature FCT file
    Set Test Variable    ${EXCEL_FILE_LIST}
    Set Test Variable    ${FCT_VERSION_LIST}

TearDown
    Common Test Teardown
    Run Keyword And Continue On Failure    Install FCT On NetAct    ${REMOTE_FCT_RECOVER_FILE}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    FOR    ${remote_file}    IN    @{EXCEL_FILE_LIST}
        ${file_not_exist}    Run Keyword And Return Status    SSHLibrary.File Should Not Exist    ${remote_file}
        Continue For Loop If    ${file_not_exist}
        Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${remote_file}
    END
    SSHLibrary.Close All Connections

Unzip FCT
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${Test Results Dir}/TestFiles
    Should Be Equal As Integers    ${rc}    ${0}
    ${fct_name}    Should Match Regexp    ${out_put}    \\w+\\.xlsx
    OperatingSystem.File Should Exist    ${Test Results Dir}/TestFiles/${fct_name}
    [Return]    ${fct_name}

Create Dummy FCT File
    ${fce_worker}    ${fct_files}    Download FCE Modules For Current SW
    Unzip FCT    ${Test Results Dir}/TestFiles/${fct_files}
    ${time}    Get Time    epoch
    ${Param_Value_Dic}    Create Dictionary    Version=1.1.1    Tool Name=TA_CB009451_H_001    Abbreviated Tool Name=TA_CB009451_H_001
    ${New_FileName}    FCT_Excel.update_parameters
    ...    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    Set Test Variable    ${LOCAL_FCT_FILE}    ${Test Results Dir}/TestFiles/CB009451_H_${time}.xlsx
    OperatingSystem.Move File    ${New_FileName}    ${LOCAL_FCT_FILE}
    Set Test Variable    ${CUR_FCT}    ${Test Results Dir}/TestFiles/FCT_PDCCH_MultiRelease.xlsx

Create FCT Recover File
    ${FCT_version_deleter}    Set Variable    1.0.1
    ${feature_filter}    Create Dictionary    toolName=TA_CB009451_H_001_Deleter
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    ${FCT_version_deleter}    Set Variable If    '${feature.__len__()}'=='${0}'    ${FCT_version_deleter}    ${feature[0]['toolVersion']}
    ${mid_ver}    Convert To Integer    ${FCT_version_deleter.split('.')[1]}
    ${FCT_version_deleter}    Set Variable    ${FCT_version_deleter.split('.')[0]}.${mid_ver+1}.${FCT_version_deleter.split('.')[2]}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_version_deleter}    Tool Name=TA_CB009451_H_001_Deleter
    ...    Abbreviated Tool Name=TA_CB009451_H_001_Deleter
    #${New_FileName1}    FCT_Excel.update_parameters    ${CUR_FCT}    GENERAL-METADATA    ${Param_Value_Dic}
    #${New_FileName2}    FCT_Excel.add_obsolete    ${New_FileName1}    GENERAL-METADATA    TA_CB009451_H_001    1
    #${New_FileName3}    FCT_Excel.add_obsolete    ${New_FileName2}    GENERAL-METADATA    TA_CB009451_H_001    2
    #${New_FileName}    FCT_Excel.add_obsolete    ${New_FileName3}    GENERAL-METADATA    TA_CB009451_H_001    3
    ${Obsolete_List}    Create List    TA_CB009451_H_001=1    TA_CB009451_H_001=2    TA_CB009451_H_001=3
    ${New_FileName}    FCT_Excel.update_with_obsoletes    ${CUR_FCT}    GENERAL-METADATA    ${Param_Value_Dic}    ${Obsolete_List}
    ${time}    Get Time    epoch
    Set Test Variable    ${FCT_RECOVER_FILE}    ${Test Results Dir}/TestFiles/CB009451_H_RECOVER_${time}.xlsx
    OperatingSystem.Move File    ${New_FileName}    ${FCT_RECOVER_FILE}
    #OperatingSystem.Remove Files    ${New_FileName1}    ${New_FileName2}    ${New_FileName3}
