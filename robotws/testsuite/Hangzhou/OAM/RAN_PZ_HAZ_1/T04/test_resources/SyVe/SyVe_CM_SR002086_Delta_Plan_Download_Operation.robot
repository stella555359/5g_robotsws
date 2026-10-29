*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_info}      PLAN_5    # selected plan infomation define in netact_plan.yaml file;


*** Keywords ***
SyVe_CM_SR002086_Delta_Plan_Download_Operation
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18550
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing plan download from NetAct
    ...    based on selected PLAN_5
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Download the plan SyVe
    ...    - Check the plan stored in SBTS local
    ...    - Create Managed Object in plan
    ...    - Download the plan SyVe
    ...    - Check MO created in download plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, download operation works as expected; states and alarms are as expected.
    ...    Plan file generated or delete from SBTS local as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18550 - SyVe_CM_Delta_Plan_Download_Operation_SR002086
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-18550_SyVe_CM_Delta_Plan_Download_Operation_SR002086.png


    Set Tags    AUTHOR-yiqing.yu@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com

    Set Test Variable    ${plan_info}    ${NETACT_PLAN['${plan_info}']}
    TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Download the plan SyVe
    Step 7: Check the plan stored in SBTS local
    Step 8: Create Managed Object in plan
    Step 9: Download the plan SyVe
    Step 10: Check MO created in download plan
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs


TC parameters check
    Log    TC parameters check started    console=True
    ${same_values}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}

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
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{plan_info['parameter']}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Download the plan SyVe
    Log    Step ${index}: Download the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=preactivate

Step ${index}: Check the plan stored in SBTS local
    Log     Step ${index}: Check the plan stored in SBTS local    console=True
    ${bts_SW_list}=    Admin Get BTS SW Version
    ${activate_SW}    Set Variable    ${bts_SW_list[0]}
    Set Test Variable    ${activate_SW}
    ${plan_str}=     Convert To String       ${plan}
    ${plan_str}=     Fetch From Right        ${plan_str}      conf_id =
    ${plan_str}=     Fetch From Left         ${plan_str}      ): Automation SyVe
    ${conf_id}=      Strip String            ${plan_str}
    Set Test Variable      ${conf_id}
    Check File Exist From SBTS Local    file_path=/rom/config/ne3sadapt/plans/${activate_SW}      file_name=${conf_id}.xml
    ...    flag=${True}

Step ${index}: Create Managed Object in plan
    Log     Step ${index}: Create Managed Object in plan    console=True
    Import Library  XML  use_lxml=True  WITH NAME  L_XML
    ${scf_xml}=  L_XML.Parse xml  ${BTS_scf_initial}
    ${MO_items}=  L_XML.Get Element Attributes  ${scf_xml}  .//managedObject[@distName="${plan_info['scf_distName2']}"]
    NetAct Create Managed Object  plan=${plan}  meta_class=${MO_items['class']}  meta_version=${MO_items['version']}
    ...  mo_id=${plan_info['mo_id2']}  &{plan_info['parameter2']}


Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check MO created in download plan
    Log     Step ${index}: Check MO created in download plan    console=True
    ${cmd1}    Set Variable   sshpass -p ${SMOD1['PASSWORD']}
    ${cmd2}    Set Variable
    ...    scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:/rom/config/ne3sadapt/plans/${activate_SW}/${conf_id}.xml ${BTSFiles}
    Run    ${cmd1} ${cmd2}
    OperatingSystem.File Should Exist    ${BTSFiles}/${conf_id}.xml
    ${download_plan_xml}=  XML.Parse XML    ${BTSFiles}/${conf_id}.xml
    ${result_value}    XML.Get Elements   ${download_plan_xml}   .//managedObject[@distName="${plan_info['scf_distName2']}"]/p
    ${result_value_dict}=  Create dictionary
    ${key}=  XML.Get Element Attribute  ${result_value[0]}  name
    ${value}=  XML.Get Element Text  ${result_value[0]}
    Set To Dictionary  ${result_value_dict}  ${key}=${value}
    Dictionaries Should Be Equal  ${result_value_dict}  ${plan_info['parameter2']}


Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Common Test Teardown


TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown


