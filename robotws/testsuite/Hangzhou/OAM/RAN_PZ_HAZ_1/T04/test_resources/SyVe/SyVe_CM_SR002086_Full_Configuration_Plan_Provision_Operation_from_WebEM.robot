*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_SR002086_Full_Configuration_Plan_Provision_Operation_from_WebEM
    [Documentation]    [CASE]: RmtOAM_CM_Full_configuration_plan_to_provision_operation_from_WebEM_for_cOAM_SBTS_SR002086_035_Automated
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from WEBEM and check CCN from wireshark
    ...    Transfer from RMT case: RmtOAM_CM_Full_configuration_plan_to_provision_operation_from_WebEM_for_cOAM_SBTS_SR002086_035_Automated
    ...    The main steps performed for the test are:
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Provision full plan with param change from admin
    ...    - Check modified parameter in Admin after provision plan
    ...    - Check modified parameter in Netact after provision plan
    ...    - Provision delta plan for recovery
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; CCN message as expected;
    ...    states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.11.2023 - New Added
    ...    - 06.12.2023 - Updated by kang lixin - update wireshark collection logic
    Set Tags    SyVe    AUTHOR-lixin.kang@nokia-sbell.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 0: TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Provision full plan with param change from admin
    Step 5: Check modified parameter in Admin after provision plan
    Step 6: Check modified parameter in Netact after provision plan
    Step 7: Provision delta plan for recovery
    Step 8: Check final alarms status from WebEM
    Step 9: Check final alarms status from Netact
    Step 10: Check final BTS state
    Step 11: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check   console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable   ${mrbts_id}
    ${plan_info}    Create Dictionary    mo_id=${MRBTS_DN}    scf_distName=MRBTS-${mrbts_id}
    ...    parameter=btsName    value=Testing case35
    ${param_dic}    Create Dictionary    ${plan_info['parameter']}=${plan_info['value']}
    Set Test Variable    ${plan_info}
    Set Test Variable    ${param_dic}
    Log    ${plan_info}    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${same_values}    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{param_dic}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Run Keywords
    ...    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Create And Perform Delta Recommision
    ...    ELSE    Log    TC parameters successfully checked    console=True

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
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

Step ${index}: Provision full plan with param change from admin
    Log    Step ${index}: Provision full plan with param change from admin   console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${target_plan}    Set Variable    ${Test Results Dir}/NetActLogs/full_plan_with_param_change.xml
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts:MRBTS"]/p[@name="${plan_info['parameter']}"]
    ...    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="${plan_info['parameter']}"/>     xpath=cmData/managedObject[@distName="${plan_info['scf_distName']}"]
    L_XML.Set Element Text    ${scf_xml}    ${plan_info['value']}   \r\n
    ...    cmData/managedObject[@distName="${plan_info['scf_distName']}"]/p[@name="${plan_info['parameter']}"]
    L_XML.Save XML    ${scf_xml}    ${target_plan}
    ${file_content}    OperatingSystem.Get File    ${target_plan}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${target_plan}
    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${target_plan}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600
    Wait Until Keyword Succeeds    20x    0.5ms    Start TCPDump On SBTS Common
    Wait Until Keyword Succeeds    10 min   30 sec    Check SBTS SMOD RMOD Cells Alarms
    Sleep    10s    #Time for the delay of CCN for parameter changed.
    Stop TCPDump And Check CCN Messages For Full Plan     ${param_dic}

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{param_dic}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan   console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{param_dic}

Step ${index}: Provision delta plan for recovery
    Log    Step ${index}: Provision the backup plan    console=True
    Create And Perform Delta Recommision

Create And Perform Delta Recommision
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=MRBTS-${mrbts_id}  parameter=${plan_info['parameter']}    value=${mrbts_id}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{param_dic}
    Run Keyword If    ${current_value}    Run Keywords
    ...    Log    Parameter not recovered, will perform delta recommision    level=WARN
    ...    AND    Create And Perform Delta Recommision
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Common Test Teardown

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown