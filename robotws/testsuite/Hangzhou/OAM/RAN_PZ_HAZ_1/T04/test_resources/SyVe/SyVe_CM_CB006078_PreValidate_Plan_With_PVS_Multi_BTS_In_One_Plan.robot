*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${MO_DN_BTS_1}    PLMN-PLMN/MRBTS-1810
${MO_DN_BTS_2}    PLMN-PLMN/MRBTS-1815
${MPLAN_IP_BTS_1}    10.106.253.2
${MPLAN_IP_BTS_2}    10.106.253.3
${PVS_Docker}     10.56.221.130
${PVS_Dok_Usname}    ute
${PVS_Dok_Password}    RAN_pz_HAZ1_SG11
${NEED_UPLOAD_PACKAGE_TO_NETACT}    True

*** Keywords ***
SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22314
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New testcase transform from CB006078_ST_03_Pre-validate Configuration Plan with PDL Validation Service.
    ...    1.Prepare one SCF file contains configuration of SBTS A and SBTS B, and then update the value of plannedSWReleaseVersion.
    ...    2.Do pre-validation via NetAct and check validation should be pass.
    ...    3.Check the log on PVS, should add new record of the validation
    ...    Use the docker PVS, set 'HostName' of PLMN-PLMN/VALIDATIONSERVICE-1/HTTP-1 HostName as 10.56.221.130
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Get PreValidate Times From PVS Docker
    ...    - Get Target SBTS Current Version
    ...    - Upload configuration status
    ...    - Export the plan SyVe
    ...    - Modify Plan File
    ...    - Import the plan
    ...    - PreValidate Plan And Check Result
    ...    - Check PVS Log
    ...
    ...    Pass criteria: pre-validate successful, PVS log record increased, time spend of pre-validation less then 20 seconds.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22314 - SyVe_CM_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan_CB006078
    ...    - 05.08.2022 - Update docker PVS IP from 10.108.183.215 to 10.56.221.130 by Carl
    ...    - 17.03.2023 - Add option to download and import sw build to NetAct by Kang Lixin
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22314-SyVe_CM_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan_CB006078.png
    Set Tags    SyVe    AUTHOR-bin.7.liu@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Get PreValidate Times From PVS Docker
    Step 2: Get Target SBTS Current Version
    Step 3: Upload configuration status
    Step 4: Export the plan SyVe
    Step 5: Modify Plan File
    Step 6: Import the plan
    Step 7: PreValidate Plan And Check Result
    Step 8: Check PVS Log

TC Setup
    Common Test Setup
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MO_DN_BTS_1}1
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MO_DN_BTS_2}1

TC Teardown
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MO_DN_BTS_1}1
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MO_DN_BTS_2}1
    Common Test Teardown

Get PreValidate Times
    [Arguments]    ${PreValiLogFileName}    ${PVS_IP}    ${PVS_Usname}    ${PVS_Password}
    SSHLibrary.Open Connection    ${PVS_IP}
    SSHLibrary.Login    ${PVS_Usname}    ${PVS_Password}
    Execute CMD Via SSH connection    su -    assword
    Execute CMD Via SSH connection    ${PVS_Dok_Password}    root\@
    Execute CMD Via SSH connection    docker logs pvs>/home/ute/${PreValiLogFileName} ; echo "FINISH"    FINISH
    Execute CMD Via SSH connection    chown ${PVS_Dok_Usname} /home/ute/${PreValiLogFileName} ; echo "FINISH"    FINISH
    Execute CMD Via SSH connection    tail /home/ute/${PreValiLogFileName} ; echo "FINISH"    FINISH
    sleep    2s
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${PVS_Dok_Password} scp ${PVS_Dok_Usname}@${PVS_Docker}:/home/ute/${PreValiLogFileName} ${OUTPUT_DIR}${/}${PreValiLogFileName}
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${OUTPUT_DIR}${/}${PreValiLogFileName}
    ${file_content}    OperatingSystem.Get File    ${OUTPUT_DIR}${/}${PreValiLogFileName}
    ${times_list}    Get Regexp Matches    ${file_content}
    ...    \\d{4}-\\d{2}-\\d{2}.+c.n.v.rest.task.ValidationTask+\\s+- completed validation task, totally spent=\\d+\\sms
    [Return]    ${times_list}

Step ${index}: Get PreValidate Times From PVS Docker
    Log    Step ${index}: Get PreValidate Times From PVS Docker    console=${True}
    ${Times_Initial_lst}    Get PreValidate Times    pvs_log_initial.log    ${PVS_Docker}    ${PVS_Dok_Usname}    ${PVS_Dok_Password}
    ${Initial_length}    Get Length    ${Times_Initial_lst}
    Set Test Variable    ${Times_Initial_lst}
    Set Test Variable    ${Initial_length}

Step ${index}: Get Target SBTS Current Version
    Log    Step ${index}: Get Target SBTS Current Version    console=True
    SSHLibrary.Open Connection    ${MPLAN_IP_BTS_1}    BTS_1
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${output}    SSHLibrary.Execute Command    ls /ffs/run/TargetBD*.xml
    ${tmp_ver_str}    Fetch From Left    ${output}    .xml
    ${CUR_VER_BTS_1}    Fetch From Right    ${tmp_ver_str}    /ffs/run/TargetBD_
    Set Test Variable    ${CUR_VER_BTS_1}
    SSHLibrary.Switch Connection    BTS_1
    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${MPLAN_IP_BTS_2}    BTS_2
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${output}    SSHLibrary.Execute Command    ls /ffs/run/TargetBD*.xml
    ${tmp_ver_str}    Fetch From Left    ${output}    .xml
    ${CUR_VER_BTS_2}    Fetch From Right    ${tmp_ver_str}    /ffs/run/TargetBD_
    Set Test Variable    ${CUR_VER_BTS_2}
    SSHLibrary.Switch Connection    BTS_2
    SSHLibrary.Close Connection

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MO_DN_BTS_1}
    NetAct CM Upload    dist_names=${MO_DN_BTS_2}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    Set Test Variable    ${PLAN_NAME}    multi_sbts_plan_TA
    Set Test Variable    ${scf_file_name}    multi_sbts_plan_TA.xml
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.get_plan_configuration    ${PLAN_NAME}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${PLAN_NAME}    ${plan}
    ${DNs}    Create List    ${MO_DN_BTS_1}    ${MO_DN_BTS_2}
    netact.export_configuration    file_name=${scf_file_name}    local_dir=${Test Results Dir}/NetActLogs
    ...    dist_names=${DNs}    ui_values=${True}

Step ${index}: Modify Plan File
    Log    Step ${index}: Modify Plan File    console=True
    Set Test Variable    ${scf_full_name}    ${Test Results Dir}/NetActLogs/${scf_file_name}
    Set Test Variable    ${new_scf_file_name}    multi_sbts_plan_TA_modified.xml
    Set Test Variable    ${new_scf_file_full_name}    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_full_name}
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="MNL"]/p[@name="plannedSWReleaseVersion"]    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="${MO_DN_BTS_1}/MNL-1"]
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="${MO_DN_BTS_2}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${CUR_VER_BTS_1}    \r\n
    ...    cmData/managedObject[@distName="${MO_DN_BTS_1}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Set Element Text    ${scf_xml}    ${CUR_VER_BTS_2}    \r\n
    ...    cmData/managedObject[@distName="${MO_DN_BTS_2}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Save XML    ${scf_xml}    ${new_scf_file_full_name}
    ${file_content}    OperatingSystem.Get File    ${new_scf_file_full_name}
    ${file_content}    Replace String    ${file_content}    BTS-${MO_DN_BTS_1.split('-')[-1]}    BTS-${MO_DN_BTS_1.split('-')[-1]}1
    ${file_content}    Replace String    ${file_content}    BTS-${MO_DN_BTS_2.split('-')[-1]}    BTS-${MO_DN_BTS_2.split('-')[-1]}1
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${new_scf_file_full_name}
    sleep    10s    time for file creation

Step ${index}: Import the plan
    Log    Step ${index}: Import the plan    console=True
    netact.import_configuration    file_name=${new_scf_file_name}    local_dir=${Test Results Dir}/NetActLogs    ui_values=${True}
    ...    plan_name=${PLAN_NAME}
    ${plan}    netact.get_plan_configuration    ${PLAN_NAME}

Step ${index}: PreValidate Plan And Check Result
    Log    Step ${index}: PreValidate Plan And Check Result    console=True
    Run Keyword If    ${NEED_UPLOAD_PACKAGE_TO_NETACT}    Upload SW Build Packages To NetAct
    SSHLibrary.Open Connection    ${NETACT['was_host']}    NetAct_1
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${output}    SSHLibrary.Execute Command    racclimx.sh -op PreValidate -DN "${MO_DN_BTS_1}1,${MO_DN_BTS_2}1" -planName ${PLAN_NAME} -v
    Log    ${output}    console=${true}
    SSHLibrary.Switch Connection    NetAct_1
    SSHLibrary.Close Connection
    Should Not Contain    ${output}    FAILURE    failed
    Should Not Contain    ${output}    pre-validate failed
    Should Contain    ${output}    pre-validate successful

Step ${index}: Check PVS Log
    Log    Step ${index}: Check PVS Log    console=${True}
    ${Times_Final_lst}    Get PreValidate Times    pvs_log_final.log    ${PVS_Docker}    ${PVS_Dok_Usname}    ${PVS_Dok_Password}
    ${Final_length}    Get Length    ${Times_Final_lst}
    Should Be True    ${Final_length}==${Initial_length+2}
    Sort List    ${Times_Initial_lst}
    Sort List    ${Times_Final_lst}
    Remove Values From List    ${Times_Final_lst}    @{Times_Initial_lst}
    Should Not Be Empty    ${Times_Final_lst}
    FOR    ${time_str}    IN    @{Times_Final_lst}
        ${time}    Fetch From Right    ${time_str}    totally spent=
        ${time}    Fetch From Left    ${time}    ms
        Should Be True    ${time}<20000    #time<20s
    END

Upload SW Build Packages To NetAct
    Log    Upload SW Build Packages To NetAct   console=True
    ${tmp_build_str}    Fetch From Right    ${CUR_VER_BTS_1}    ENB_
    ${sw_build_pkg1}    Set Variable    SBTS00_ENB_${tmp_build_str}
    ${build1_exist}    netact.Is Imported    ${CUR_VER_BTS_1}
    Run Keyword If    not ${build1_exist}    Download And Import Build To NetAct    ${sw_build_pkg1}
    ${tmp_build_str}    Fetch From Right    ${CUR_VER_BTS_2}    ENB_
    ${sw_build_pkg2}    Set Variable    SBTS00_ENB_${tmp_build_str}
    ${build2_exist}    netact.Is Imported    ${CUR_VER_BTS_2}
    Run Keyword If    not ${build2_exist}    Download And Import Build To NetAct    ${sw_build_pkg2}

Download And Import Build To NetAct
    [Arguments]    ${target_sw_name}
    Download SBTS SW Build    ${target_sw_name}
    Import SBTS SW Build To NetAct    ${target_sw_name}
