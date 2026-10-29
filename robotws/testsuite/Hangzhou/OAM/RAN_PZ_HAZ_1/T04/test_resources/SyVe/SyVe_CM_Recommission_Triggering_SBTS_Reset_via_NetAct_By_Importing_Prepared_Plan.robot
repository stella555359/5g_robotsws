*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_path}      /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/Top50_CM_SiteReset.xml
${NEED_SCF_RECOVERY_FLAG}    False
&{IGNORED_FAULT_61524}    faultId=61524  faultName=SSH enabled
&{IGNORED_FAULT_61652}    faultId=61652  faultName=R&D Service Port enabled
&{IGNORED_FAULT_61649}    faultId=61649  faultName=LMP access via port
&{IGNORED_FAULT_4655}    faultId=4655  faultName=Service account root access is enabled
&{IGNORED_FAULT_4654}    faultId=4654  faultName=Ethernet port security is disabled
&{IGNORED_FAULT_61074}    faultId=61074    faultName=CRL Update Failure
&{IGNORED_FAULT_4657}    faultId=4657    faultName=Nokia MN BTS SFP validation failure
&{IGNORED_FAULT_6322}    faultId=6322    faultName=RIM interface timeout
&{IGNORED_FAULT_6327}    faultId=6327    faultName=Setup of X2 connectivity to gNB failed
&{IGNORED_FAULT_4124}    faultId=4124    faultName=GPS receiver alarm: no stored position
&{IGNORED_FAULT_4123}    faultId=4123    faultName=GPS receiver alarm: survey in progress
&{IGNORED_FAULT_4125}    faultId=4125    faultName=GPS receiver alarm: position questionable
&{IGNORED_FAULT_1898}    faultId=1898    faultName=PPS reference missing
&{IGNORED_FAULT_6323}    faultId=6323  faultName=RIM interface error
&{IGNORED_FAULT_4298}    faultId=4298  faultName=ToP reference missing
&{IGNORED_FAULT_61644}    faultId=61644  faultName=IKE authentication failure
&{IGNORED_FAULT_61510}    faultId=61510  faultName=Automatic BTS Operator Certificate retrieval unsuccessful
@{GLOBALLY_IGNORED_ALARMS}=         ${IGNORED_FAULT_61524}    ${IGNORED_FAULT_61652}    ${IGNORED_FAULT_61649}
...    ${IGNORED_FAULT_4655}    ${IGNORED_FAULT_4654}    ${IGNORED_FAULT_61074}
...    ${IGNORED_FAULT_4657}    ${IGNORED_FAULT_6322}    ${IGNORED_FAULT_6327}    ${IGNORED_FAULT_4124}    ${IGNORED_FAULT_4123}
...    ${IGNORED_FAULT_4125}    ${IGNORED_FAULT_1898}    ${IGNORED_FAULT_6323}    ${IGNORED_FAULT_4298}    ${IGNORED_FAULT_61644}
...    ${IGNORED_FAULT_61510}

*** Keywords ***
TC__SyVe_CM_Recommission_Triggering_SBTS_Reset_via_NetAct_By_Importing_Prepared_Plan
    [Documentation]    [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23298
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing plan activation from NetAct
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Get initial BTS RESET info from blackbox file
    ...    - Upload configuration status
    ...    - Import the plan SyVe
    ...    - Provision the plan and wait for BTS recovery
    ...    - Check modified parameter in Netact after provision plan
    ...    - Get final BTS RESET info from blackbox file
    ...    - Check BTS RESET behavior
    ...    - Provision the backup plan and wait for BTS recovery
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: import and provision works as expected; states and alarms are as expected.
    ...    Plan file generated or deletet from SBTS local as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.06.2022 - New added for Top50 requirment - https://jiradc.ext.net.nokia.com/browse/TAT-23298
	...    - 15.09.2022 - Xu Yuyan - Update alarm check from WebEM for Top50 requirment
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
	...    TAT-23298_SyVe_CM_Online_Recommission_via_NetAct_By_Importing_Prepared_Plan.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Get initial BTS RESET info from blackbox file
    Step 5: Upload configuration status
    Step 6: Import the plan SyVe
    Step 7: Provision the plan and wait for BTS recovery
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Get final BTS RESET info from blackbox file
    Step 10: Check BTS RESET behavior
    Step 11: Provision the backup plan and wait for BTS recovery
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs

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
    Comment    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}
    ${CRITICAL_ALARMS1}=    Create Dictionary    severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary    severity=Critical
    ${CRITICAL_ALARMS3}=    Create Dictionary    severity=Minor
    ${CRITICAL_PATTERNS}=    Create List    ${CRITICAL_ALARMS1}    ${CRITICAL_ALARMS2}    ${CRITICAL_ALARMS3}
    ${alarms_status}    ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms TAF    critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if    '${alarms_status}'=='FAIL'    Fail    Minor/Major/Critical alarm found.

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Get ${when} BTS RESET info from blackbox file
    [Documentation]    Get RESET info from blackbox file
    [Timeout]    15 min
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=${SMOD1['TRS_IP']}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Import the plan SyVe
    Log    Step ${index}: Import the plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${mrbts_id}
    ${file_name}    Fetch From Right    ${plan_path}    /
    ${file_path}    Remove String    ${plan_path}    /${file_name}
    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name}    plan_name=${name}

Step ${index}: Provision the plan and wait for BTS recovery
    Log    Step ${index}: Provision the plan and wait for BTS recovery    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=activate
    ${NEED_SCF_RECOVERY_FLAG}    Set Variable    True
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check BTS RESET behavior
    [Documentation]    Final RESET info is compared with initial RESET info: reset number is 1
    [Timeout]    10 min
    Log    Step ${index}: Check BTS RESET behavior    console=True
    Check BTS RESET behavior SyVe    1

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    ${plan_info}    Get TestData From XML
    ${dist_names}    Get Dictionary Keys    ${plan_info}
    FOR    ${dist_name}    IN    @{dist_names}
        NetAct Check Actual Configuration Parameters    dist_name=${dist_name}    ui_values=false    &{plan_info['${dist_name}']}
    END

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${plan_info_ui['scf_distName']}    &{plan_info_ui['parameter']}

Step ${index}: Provision the backup plan and wait for BTS recovery
    Log    Step ${index}: Provision the backup plan and wait for BTS recovery    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    ${NEED_SCF_RECOVERY_FLAG}    Set Variable    False
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Get TestData From XML
    ${plan_xml}    XML.Parse Xml    ${plan_path}
    ${objects}    XML.Get Elements    ${plan_xml}    .//managedObject
    ${testdata}    Create Dictionary
    FOR    ${obj}    IN    @{objects}
        ${dn}    XML.Get Element Attribute    ${obj}    distName
        ${p_objs}    XML.Get Elements    ${plan_xml}    .//managedObject[@distName="${dn}"]/p
        ${param_value_dict}    Generate Parameter Value Dic    ${p_objs}
        Set To Dictionary    ${testdata}    ${dn}=${param_value_dict}
    END
    [Return]    ${testdata}

Generate Parameter Value Dic
    [Arguments]    ${objs}
    ${param_value_dict}    Create Dictionary
    FOR    ${element}    IN    @{objs}
        ${key}    XML.Get Element Attribute    ${element}    name
        ${value}    XML.Get Element Text    ${element}
        Set To Dictionary    ${param_value_dict}    ${key}=${value}
    END
    [Return]    ${param_value_dict}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword If    ${NEED_SCF_RECOVERY_FLAG}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
