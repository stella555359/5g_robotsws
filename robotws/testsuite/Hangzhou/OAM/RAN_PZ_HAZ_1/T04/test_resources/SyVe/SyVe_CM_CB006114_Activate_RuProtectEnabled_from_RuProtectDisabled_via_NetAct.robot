*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{CB006114_AFFECTED_RMOD_TYPE}    AZHL    AZQP    AZHM

*** Keywords ***
SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22179
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New TC for CB006114.
    ...
    ...    Enable or disable feature CB006114 by setting parameter actEcpriRuMPlaneSecurity,
    ...    and check if the encrypted connection between SBTS and RMOD is established or not via SSH.
    ...
    ...    The main steps performed for the test are:
    ...    - Get CB006114 Initial Parameters
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe And Check RMOD Action
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Check IPSec Infor Should Be ESTABLISHED
    ...    - Provision the backup plan SyVe And Check RMOD Action
    ...    -- Check IPSec Infor Should Be ABOLLISHED
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected,
    ...    the encrypted connection between SBTS and RMOD is established or not as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22179 - New case
    ...    - 13.01.2022 - Modified by Liu Bin - https://jira3.ext.net.nokia.com/browse/TAT-22482 - Account root is disable for RMOD
    ...    - 20.01.2022 - Modified by Liu Bin  - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 07.03.2025 - Update by Xu Yuyan -  Adjust code to compatible with AZxx and AVxx
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22179_SyVe_CM_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct_CB006114.png
    Set Tags    CM    AUTHOR-bin.7.liu@nokia.com    PHASE-SyVe    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Get CB006114 Initial Parameters
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe And Check RMOD Action
    Step 9: Check modified parameter in Netact after provision plan
    Step 10: Check modified parameter in Admin after provision plan
    Step 11: Check IPSec Infor Should Be ESTABLISHED
    Step 12: Provision the backup plan SyVe And Check RMOD Action
    Step 13: Check IPSec Infor Should Be ABOLLISHED
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact


Step ${index}: Get CB006114 Initial Parameters
    Log    Step ${index}: Get CB006114 Initial Parameters    console=True
    ${INITIAL_VALUE_CB006114}    Create Dictionary
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${element}    L_XML.Get Element    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]
    ${dn}    L_XML.Get Element Attribute    ${element}    distName
    ${version}    L_XML.Get Element Attribute    ${element}    version
    ${initial_val_actEcpriRuMPlaneSecurity}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actEcpriRuMPlaneSecurity"]
    ${val_actEcpriRuMPlaneSecurity}    Create Dictionary    meta_class=com.nokia.srbts.mnl:FEATCADM    meta_version=${version}
    ...    actEcpriRuMPlaneSecurity=${initial_val_actEcpriRuMPlaneSecurity}
    Should Be Equal As Strings    ${val_actEcpriRuMPlaneSecurity["actEcpriRuMPlaneSecurity"]}    RuProtectDisabled
    Set To Dictionary    ${INITIAL_VALUE_CB006114}    ${dn}=${val_actEcpriRuMPlaneSecurity}
    Set Test Variable    ${DN_FEATCADM}    ${dn}
    ${CB006114_AFFECTED_RMODs}    Create Dictionary
    ${CB006114_NOT_AFFECTED_RMODs}    Create Dictionary
    #Product name is not contains in SCF, so get it from running time
    ${dic_bts_infor}    coam.Get Bts Info
    ${list_rmod_infor}    Set Variable    ${dic_bts_infor["radioModules"]["rmod"]}
    FOR    ${rmod_infor}    IN    @{list_rmod_infor}
        ${dn}    Set Variable    ${rmod_infor["id"]["configuration"]}
        ${productName}    Set Variable    ${rmod_infor["productName"]}
        L_XML.Element Should Not Exist    ${scf_xml}    .//managedObject[@distName="${dn}"]/p[@name="plainTextConnectionAllowed"]
        ${is_CB006114_RMOD}    Run Keyword And Return Status    List Should Contain Value    ${CB006114_AFFECTED_RMOD_TYPE}    ${productName}
        ${dic_pointer}    Set Variable If    ${is_CB006114_RMOD}    ${CB006114_AFFECTED_RMODs}    ${CB006114_NOT_AFFECTED_RMODs}
        ${element}    L_XML.Get Element    ${scf_xml}    .//managedObject[@distName="${dn}"]
        ${version}    L_XML.Get Element Attribute    ${element}    version
        ${val_actEcpriRuMPlaneSecurity}    Create Dictionary    meta_class=com.nokia.srbts.eqm:RMOD    meta_version=${version}
        ...    plainTextConnectionAllowed=${EMPTY}    productName=${productName}
        Set To Dictionary    ${dic_pointer}    ${dn}=${val_actEcpriRuMPlaneSecurity}
    END
    Set Test Variable    ${INITIAL_VALUE_CB006114}
    Set Test Variable    ${CB006114_AFFECTED_RMODs}
    Set Test Variable    ${CB006114_NOT_AFFECTED_RMODs}
    LOG Dictionary    ${INITIAL_VALUE_CB006114}
    LOG Dictionary    ${CB006114_AFFECTED_RMODs}
    LOG Dictionary    ${CB006114_NOT_AFFECTED_RMODs}


Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Check SBTS SMOD RMOD Cells Alarms
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${NAME}    CB006114_TC11
    ${status}    ${plan}    Run Keyword And Ignore Error   netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    ${param}    Get From Dictionary    ${INITIAL_VALUE_CB006114}    ${DN_FEATCADM}
    ${dic_param_value}    Create Dictionary    actEcpriRuMPlaneSecurity=${0}
    ${managed_object}    netact.Create Managed Object    plan=${plan}    meta_class=${param['meta_class']}    meta_version=${param['meta_version']}
    ...    mo_id=PLMN-PLMN/${DN_FEATCADM}    operation=update
    ...    &{dic_param_value}
    ${list_rmod}    Get Dictionary Keys    ${CB006114_AFFECTED_RMODs}
    ${expect_status}    Set Variable
    FOR    ${rmod}    IN    @{list_rmod}
        ${expect_status}    Set Variable    ${rmod}:availabilityStatus:offline;${rmod}:operationalState:disabled;${expect_status}
    END
    Set Test Variable    ${EXPECT_STATUS}    ${expect_status.strip()}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    ${dic_param_value_checker}    Create Dictionary    actEcpriRuMPlaneSecurity    RuProtectEnabled
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${DN_FEATCADM}    ui_values=true    &{dic_param_value_checker}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    ${dic_param_value_checker}    Create Dictionary    actEcpriRuMPlaneSecurity    RuProtectEnabled
    Check WebEM After Modify Parameters    ${DN_FEATCADM}    &{dic_param_value_checker}

Step ${index}: Provision the plan SyVe And Check RMOD Action
    Log    Step ${index}: Provision the plan SyVe And Check RMOD Action    console=True
    ${dic_mapping}    ${dic_all_status}    Get BTS Key MOs Status
    ${gNbCuType}    Pop From Dictionary    ${dic_all_status}    gNbCuType    SA
    Set Test Variable    ${GNB_CU_TYPE}    ${gNbCuType}
    Check BTS Key MOs Status All Online    ${dic_all_status}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true -backupPlanName ${name}_backup
    ${cmdstr2}    Set Variable   -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmdstr1} ${cmdstr2}
    ${list_record_of_change1}    Get BTS Key MOs Status Duration Until Expected Changes    ${EXPECT_STATUS}
    ${list_record_of_change2}    Get BTS Key MOs Status Duration Until All Online    retry=600
    ${list_record_of_change}    Combine Lists    ${list_record_of_change1}    ${list_record_of_change2}
    ${dic_key_MOs_status_duration}    Combine Changes Of BTS Key MOs Status    ${list_record_of_change}
    ${ignore_type}    Create List    site    cell    bbmod    rat
    Check BTS Key MOs Status Duration    ${dic_key_MOs_status_duration}    ${EXPECT_STATUS}    @{ignore_type}
    [Teardown]    Run Keywords    SSHLibrary.Read Command Output
    ...    AND    SSHLibrary.Close All Connections

Step ${index}: Check IPSec Infor Should Be ${status}
    Log    Step ${index}: Check IPSec Infor Should Be ${status}    console=True
    ${list_IPSec_Infor}    Get IPSec Infor
    FOR    ${IPSec_Infor}    IN    @{list_IPSec_Infor}
        ${rmstring}    Set Variable If    "${RMOD_TYPE_Family}"=="AV"    root\@simics    rfsw\@stratix
        ${IPSec_Infor}    Remove String    ${IPSec_Infor}    ${rmstring}    #rfsw\@stratix
        Run Keyword If    '${status}'=='ESTABLISHED'    Should Contain    ${IPSec_Infor}    ESTABLISHED
        ...    ELSE    Should Be Empty    ${IPSec_Infor.strip()}
    END

Get IPSec Infor
    ${RMOD_params}    coam.get_managed_objects    RMOD_L
    Establish SSH to SBTS    192.168.255.129
    Execute CMD Via SSH connection    lxc-attach -n 0x1018    root\@FHNET00
    ${list_output}    Create List
    #${output}    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt    root\@FHNET00
    #${lines}    Split To Lines    ${output}
    FOR    ${RMOD}    IN    @{RMOD_params}
    #FOR    ${line}    IN    @{lines}
        #${type}    Fetch From Right    ${line}    ;
        ${not_CB006114_affected_type}    Run Keyword And Return Status    List Should Not Contain Value
        ...    ${CB006114_AFFECTED_RMOD_TYPE}    ${RMOD["parameters"]["productName"]}     #${type.strip()}
        Continue For Loop If    ${not_CB006114_affected_type}
        #${ip}    Should Match Regexp    ${line}    \\d+\\.\\d+\\.\\d+\\.\\d+
        ${ip}    Set Variable    ${RMOD["parameters"]["ipAddress"]}
        ${output}    Execute CMD Via SSH connection    rm /user/toor4nsn/.ssh/known_hosts    root\@FHNET00
        ${output}    Execute CMD Via SSH connection    ssh rfsw@${ip}    password\|yes/no    console_delay=1s
        Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    password
        ${passwd}    Set Variable If    "${RMOD_TYPE_Family}"=="AV"
        ...    f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
        ${consl}    Set Variable If    "${RMOD_TYPE_Family}"=="AV"    rfsw\@simics    rfsw\@stratix
        #${output}    Execute CMD Via SSH connection    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=    rfsw\@stratix
        ${output}    Execute CMD Via SSH connection    ${passwd}    ${consl}    console_delay=6s
        ${output}    Run Keyword If    "${RMOD_TYPE_Family}"=="AV"    Execute CMD Via SSH connection    sudo su    root\@simics
        ${cmd}    Set Variable If    "${RMOD_TYPE_Family}"=="AV"    swanctl --list-sas    sudo swanctl --list-sas
        ${consl}    Set Variable If    "${RMOD_TYPE_Family}"=="AV"    root\@simics    rfsw\@stratix
        #${output}    Execute CMD Via SSH connection    sudo swanctl --list-sas    rfsw\@stratix
        ${output}    Execute CMD Via SSH connection    ${cmd}    ${consl}
        #${output}    String.Remove String    ${output}    \$ sudo swanctl --list-sas
        ${output}    String.Remove String    ${output}    \$ ${cmd}
        Append To List    ${list_output}    ${output.strip()}
        ${output}    Run Keyword If    "${RMOD_TYPE_Family}"=="AV"    Execute CMD Via SSH connection    exit    rfsw@simics
        ${output}    Execute CMD Via SSH connection    exit    root\@FHNET00
    END
    [Teardown]    SSHLibrary.Close All Connections
    [Return]    ${list_output}

Step ${index}: Provision the backup plan SyVe And Check RMOD Action
    Log    Step ${index}: Provision the backup plan SyVe And Check RMOD Action    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    ${dic_mapping}    ${dic_all_status}    Get BTS Key MOs Status
    Check BTS Key MOs Status All Online    ${dic_all_status}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${name}_backup -DN ${MRBTS_DN} -createBackupPlan false -backupPlanName None
    ${cmdstr2}    Set Variable   -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmdstr1} ${cmdstr2}
    ${list_record_of_change1}    Get BTS Key MOs Status Duration Until Expected Changes    ${EXPECT_STATUS}
    ${list_record_of_change2}    Get BTS Key MOs Status Duration Until All Online    retry=600
    ${list_record_of_change}    Combine Lists    ${list_record_of_change1}    ${list_record_of_change2}
    ${dic_key_MOs_status_duration}    Combine Changes Of BTS Key MOs Status    ${list_record_of_change}
    ${ignore_type}    Create List    site    cell    bbmod    rat
    Check BTS Key MOs Status Duration    ${dic_key_MOs_status_duration}    ${EXPECT_STATUS}    @{ignore_type}
    [Teardown]    Run Keywords    SSHLibrary.Read Command Output
    ...    AND    SSHLibrary.Close All Connections

TC Setup
    Common Test Setup
    ${status_AV}    Run Keyword and Return Status    Should Start With   ${CB006114_AFFECTED_RMOD_TYPE[0]}    AV
    ${RMOD_TYPE_Family}    Set Variable If    ${status_AV}    AV    AZ
    Set Test Variable    ${RMOD_TYPE_Family}

TC Teardown
    Log To Console    TC Teardown
    Particular Teardown

Particular Teardown
    ${dic_param_value_checker}    Create Dictionary    actEcpriRuMPlaneSecurity    RuProtectDisabled
    ${CB006114_disabled}    Run Keyword And Return Status    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${DN_FEATCADM}    ui_values=true    &{dic_param_value_checker}
#    Run Keyword Unless    ${CB006114_disabled}    Step teardown: Provision the backup plan SyVe And Check RMOD Action
    Run Keyword If    not ${CB006114_disabled}    Step teardown: Provision the backup plan SyVe And Check RMOD Action
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Common Test Teardown