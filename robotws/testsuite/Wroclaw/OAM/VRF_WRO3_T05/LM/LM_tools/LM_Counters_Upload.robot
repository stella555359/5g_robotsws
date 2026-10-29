*** Settings ***
Documentation
        ...  Simple PM counters upload with aggregation

Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         String
Library         XML    use_lxml=True
Library         ute_admin
Library         ute_admin_infomodel
Library         taf.nms.netact
Resource        ../LM_resources/lib_SFE.robot


Suite Teardown  Run Keyword And Ignore Error    Close Connection


*** Variables ***
${ENB_ROOT_USER}        root
${ENB_ROOT_PASS}        arthur
@{backup_list}
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans
${SSH_IP}               10.82.44.108
${PMNODE_IP}            10.82.44.110


*** Test Cases ***
Start Upload
    [Documentation]    This test checks if eNB is ready for test.
    File Prep
    Open Connection And Log In
    File Upload
    Log    \nPrepare files to aggregate    console=True
    SSH Command    chown omc /d/oss/global/var/mediation/south/pm/import/omes_*
    SSH Command    chmod 777 /d/oss/global/var/mediation/south/pm/import/omes_*
    SSH Command    rename .xml.in-progress .xml /d/oss/global/var/mediation/south/pm/import/*.xml.in-progress
    Log    \nPrepare files to aggregate - DONE!    console=True
    Close Connection
    Aggregate Files


*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${SSH_IP}
   SSHLibrary.Login               ${ENB_ROOT_USER}        ${ENB_ROOT_PASS}

SSH Command
   [Arguments]        ${command}
    SSHLibrary.Execute Command    ${command}

Close Connection
    SSHLibrary.Close Connection

File Upload
    Log    \nFiles upload    console=True
    @{pm_list}=    OperatingSystem.List Files In Directory    ${CURDIR}/../LM_resources/PM_files/    omes_*    absolute
    FOR  ${pm}  IN  @{pm_list}
        Log    \nPut File ${pm} /d/oss/global/var/mediation/south/pm/import/    console=True
        Put File    ${pm}    /d/oss/global/var/mediation/south/pm/import/
    END
    Log    \nFiles upload - DONE!    console=True

File Prep
    ${Getdate}=    Get Current Date
    ${FileDate}=    Subtract Time From Date    ${Getdate}    1day    result_format=%Y%m%d
    ${ContentDate}=    Subtract Time From Date    ${Getdate}    1day    result_format=%Y-%m-%d
    Log    \nRemove old files   console=True
    @{pm_list}=    OperatingSystem.List Files In Directory    ${CURDIR}/../LM_resources/PM_files/    omes_*    absolute
    FOR  ${pm}  IN  @{pm_list}
        Log    \nRemoving ${pm}    console=True
        Remove File    ${pm}
    END
    Log    \nRemove old files - DONE!   console=True
    Log    \nNew files prep for day: ${FileDate}   console=True
    @{templates}=    OperatingSystem.List Files In Directory    ${CURDIR}/../LM_resources/PM_files/    template_*
    FOR  ${template}  IN  @{templates}
        Log    \nTemplate: ${template}    console=True
        ${file_name1}=    Replace String    ${template}    CDATE    ${FileDate}
        ${file_name2}=    Replace String    ${file_name1}    template_    ${EMPTY}
        Log    \nTarget File: ${CURDIR}/../LM_resources/PM_files/${file_name2}    console=True
        Copy File    ${CURDIR}/../LM_resources/PM_files/${template}    ${CURDIR}/../LM_resources/PM_files/${file_name2}
    END
    Log    \nNew files prep for day: ${FileDate} - DONE!  console=True
    @{pm_list}=    OperatingSystem.List Files In Directory    ${CURDIR}/../LM_resources/PM_files/    omes_*    absolute
    FOR  ${pm}  IN  @{pm_list}
        Log    \nContent update for ${pm}    console=True
        Run    sed -i 's/<DATEHERE>/${ContentDate}/g' ${pm}
    END
    Log    \nContents update - DONE!  console=True

Aggregate Files
    Log    \nFiles aggregate    console=True
    ${Date}=    Get Current Date
    ${InputDate}=    Subtract Time From Date    ${Date}    1day    result_format=%Y%m%d
    SSHLibrary.Open Connection     ${PMNODE_IP}
    SSHLibrary.Login               omc        Medsql!_1893
    Log    \nLogged as omc to PM Node    console=True
    SSH Command    cosprcmx.pl -dm nokmrn -a -s ${InputDate} -e
    Log    \nnokmrn done    console=True
    SSH Command    cosprcmx.pl -dm nokgnb -a -s ${InputDate} -e
    Log    \nnokgnb done    console=True
    Close Connection
    Log    \nFiles aggregate - DONE!    console=True