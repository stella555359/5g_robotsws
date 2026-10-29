*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22176
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New testcase transform from LTE4934-A_ST_LBT1133-a_CM provision to trigger CCN upload by modify
    ...    create and delete parameter. To check the CNN message after add/remove parameters via NetAct,
    ...    cover two types of parameter: value and structure.
    ...
    ...    The main steps performed for the test are:
    ...    - Select MO Randomly And Check Params
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create Paramaters Via NetAct
    ...    - Delete Paramaters Via NetAct
    ...    - Check Final BTS state
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms
    ...    are as expected; CNN message is correct.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22176 - New case
    ...    - 08.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22321 -
    ...    Use a intermediate server which intalled tshark to analysis tcp dumped before
     ...    UTE_Cloud reserved debian has tshark installed.
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
     ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> Get Plan Configuration
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22176-SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.png
    Set Tags    CM    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Select MO Randomly And Check Params
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create Paramaters Via NetAct
    Step 7: Delete Paramaters Via NetAct
    Step 8: Check Final BTS state
    Step 9: Check final alarms status from WebEM
    Step 10: Check final alarms status from Netact
    Step 11: Check final number and state of Cells and RMs

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown

Particular Teardown
    Stop TCPDump On SBTS
    FOR    ${plan_name}    IN    @{NAMES_OF_SYVE_PLAN}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    END
    Run Keyword If Test Failed    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC parameters check
    Log    TC parameters check started    console=True
    ${dic_param_value_check}    Create Dictionary    enableAutoLock=Disabled    planFileActivationMode=totalServiceLossAllowed
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    PLMN-PLMN/${LNBTS_DN}
    ...    true    &{dic_param_value_check}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}

Select MO Randomly And Check Params
    ${NAME_LIST_PARAM}    Set Variable    blacklistHoL
    ${NAME_PARAM_1}    Set Variable    useId
    ${NAME_PARAM}    Set Variable    acbECTimer
    ${val_list}    Evaluate    [{"blacklistTopo":0,"freqEutra":2,"phyCellIdStart":3}]
    ${VALUE_LIST_PARAM}    Create Dictionary    blacklistHoL=${val_list}    useId=2
    ${VALUE_PARAM}    Create Dictionary    acbECTimer=2
    ${NAMES_OF_SYVE_PLAN}    Create List
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${lte_cell_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${element}    IN    @{lte_cell_elements}
        ${mo_dn}    L_XML.Get Element Attribute    ${element}    distName
        ${has_blacklistHoL}    Run Keyword And Return Status    L_XML.Element Should Exist
        ...    .//managedObject[@distName="${mo_dn}"]/list[@name="${NAME_LIST_PARAM}"]
        ${has_acbECTimer}    Run Keyword And Return Status    L_XML.Element Should Exist
        ...    .//managedObject[@distName="${mo_dn}/SIB-0"]/p[@name="${NAME_PARAM}"]
        Run Keyword If    ${has_blacklistHoL} or ${has_acbECTimer}    Remove Values From List    ${lte_cell_elements}    ${element}
    END
    Should Not Be Empty    ${lte_cell_elements}
    ${count}    Get Length    ${lte_cell_elements}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${CELL_DN}    L_XML.Get Element Attribute    ${lte_cell_elements[${index}]}    distName
    ${SIB_DN}    Set Variable    ${CELL_DN}/SIB-0
    ${LNBTS_DN}    Fetch From Left    ${CELL_DN}    /LNCEL-
    ${MRBTS_DN}    Fetch From Left    ${CELL_DN}    /LNBTS-
    ${version}    L_XML.Get Element Attribute    ${lte_cell_elements[${index}]}    version
    Set To Dictionary    ${VALUE_LIST_PARAM}    meta_class=NOKLTE:LNCEL    meta_version=${version}
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="${SIB_DN}"]
    Set To Dictionary    ${VALUE_PARAM}    meta_class=NOKLTE:SIB    meta_version=${version}
    Set Test Variable    ${CELL_DN}
    Set Test Variable    ${SIB_DN}
    Set Test Variable    ${LNBTS_DN}
    Set Test Variable    ${MRBTS_DN}
    Set Test Variable    ${NAME_LIST_PARAM}
    Set Test Variable    ${NAME_PARAM}
    Set Test Variable    ${VALUE_LIST_PARAM}
    Set Test Variable    ${VALUE_PARAM}
    Set Test Variable    ${NAMES_OF_SYVE_PLAN}

Step ${index}: Select MO Randomly And Check Params
    Log    Step ${index}: Select MO Randomly And Check Params    console=True
    Select MO Randomly And Check Params

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=PLMN-PLMN/${MRBTS_DN}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Create Paramaters Via NetAct
    Log    Step ${index}: Create Paramaters Via NetAct    console=True
    Set Test Variable    ${name}    LTE4934-A_ST_LBT1133-a_Create
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${VALUE_LIST_PARAM['meta_class']}
    ...    meta_version=${VALUE_LIST_PARAM['meta_version']}    mo_id=PLMN-PLMN/${CELL_DN}    operation=Create    &{VALUE_LIST_PARAM}
    netact.Create Managed Object    plan=${plan}    meta_class=${VALUE_PARAM['meta_class']}
    ...    meta_version=${VALUE_PARAM['meta_version']}    mo_id=PLMN-PLMN/${SIB_DN}    operation=Create    &{VALUE_PARAM}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    Start TCPDump On SBTS
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Delete Paramaters Via NetAct
    Log    Step ${index}: Delete Paramaters Via NetAct    console=True
    Set Test Variable    ${name}    LTE4934-A_ST_LBT1133-a_Delete
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    Set To Dictionary    ${VALUE_LIST_PARAM}    blacklistHoL=${EMPTY}    useId=${EMPTY}
    Set To Dictionary    ${VALUE_PARAM}    acbECTimer=${EMPTY}
    netact.Create Managed Object    plan=${plan}    meta_class=${VALUE_LIST_PARAM['meta_class']}
    ...    meta_version=${VALUE_LIST_PARAM['meta_version']}    mo_id=PLMN-PLMN/${CELL_DN}    operation=Update
    ...    &{VALUE_LIST_PARAM}
    netact.Create Managed Object    plan=${plan}    meta_class=${VALUE_PARAM['meta_class']}
    ...    meta_version=${VALUE_PARAM['meta_version']}    mo_id=PLMN-PLMN/${SIB_DN}    operation=Update    &{VALUE_PARAM}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Sleep    3 min
    Stop TCPDump And Check CCN Messages

Start TCPDump On SBTS
    ${ssh_connection}    Establish SSH to SBTS    ${SMOD1['IP']}
    Execute CMD Via SSH connection
    ...    nohup tcpdump -i any -w ~/LTE4934-LBT1133.cap src host ${MPLANE_IP} and dst host ${NETACT['lbwas_host']} > out.log 2>&1 &    root\@
    SSHLibrary.Close Connection

Stop TCPDump On SBTS
    ${ssh_connection}    Establish SSH to SBTS    ${SMOD1['IP']}
    Execute CMD Via SSH connection    pkill -f \ tcpdump    root\@
    SSHLibrary.Close Connection

Stop TCPDump And Check CCN Messages
    Stop TCPDump On SBTS
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['IP']}:~/LTE4934-LBT1133.cap ${OUTPUT_DIR}/ \
    ${cmd1}    Set Variable   tshark -r "${OUTPUT_DIR}/LTE4934-LBT1133.cap" -Y "xml.attribute contains blacklistHoL or
    ${cmd2}    Set Variable   xml.attribute contains useId or xml.attribute contains acbECTimer or xml.attribute contains changeNotification"
    ${cmd3}    Set Variable   -x -V > "${OUTPUT_DIR}/LTE4934-LBT1133.txt"
    OperatingSystem.Run And Return Rc And Output    ${cmd1} ${cmd2} ${cmd3}
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${OUTPUT_DIR}/LTE4934-LBT1133.txt
    ${file_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/LTE4934-LBT1133.txt
    ${matches1}    Get Regexp Matches    ${file_content}    name="acbECTimer">\\s\+2
    ${matches2}    Get Regexp Matches    ${file_content}    name="useId">\\s\+2
    ${tmp_str1}    Set Variable
    ...    <list\\s\+name="blacklistHoL">\\s\+<item>\\s\+<p\\s\+name="blacklistTopo">\\s\+allEqual\\s\+</p>\\s\+<p\\s\
    ${tmp_str2}    Set Variable
    ...    +name="freqEutra">\\s\+2\\s\+</p>\\s\+<p\\s\+name="phyCellIdStart">\\s\+3\\s\+</p>\\s\+</item>\\s\+</list>
    ${matches3}    Get Regexp Matches    ${file_content}    ${tmp_str1}${tmp_str2}
    ${matches4}    Get Regexp Matches    ${file_content}    name="acbECTimer"/>
    ${matches5}    Get Regexp Matches    ${file_content}    name="useId"/>
    ${matches6}    Get Regexp Matches    ${file_content}    name="blacklistHoL">\\s\+</list>
    should not be empty    ${matches1}
    should not be empty    ${matches2}
    should not be empty    ${matches3}
    should not be empty    ${matches4}
    should not be empty    ${matches5}
    should not be empty    ${matches6}

Use tshark From Remote Server
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p RAN_pz_HAZ1_SG11 scp ${OUTPUT_DIR}/LTE4934-LBT1133.cap ute@10.106.253.52:~/LTE4934-LBT1133.cap \
    ${ssh_connection}    SSHLibrary.Open Connection    host=10.106.253.52    prompt=\$
    SSHLibrary.Login    ute    RAN_pz_HAZ1_SG11
    ${cmdstr1}    Set Variable   tshark -r ~/LTE4934-LBT1133.cap -Y
    ${cmdstr2}    Set Variable   "http contains changeNotification and http contains acbECTimer and http contains useId and
    ${cmdstr3}    Set Variable    http contains blacklistHoL" -x -V > ~/LTE4934-LBT1133.txt    ute\@
    Execute CMD Via SSH connection    ${cmdstr1} ${cmdstr2} ${cmdstr3}
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p RAN_pz_HAZ1_SG11 scp ute@10.106.253.52:~/LTE4934-LBT1133.txt ${OUTPUT_DIR}/ \
    Execute CMD Via SSH connection    rm ~/LTE4934-LBT1133.cap    ute\@
    Execute CMD Via SSH connection    rm ~/LTE4934-LBT1133.txt    ute\@
    [Teardown]    SSHLibrary.Close Connection
