*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
 # nrcell delete plan will provision on NetAct
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_path}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/TDD_LTE_RAT_Delete_And_Add.xml

*** Keywords ***
TC__SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21584
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision TDD LTE cell delete and add from NetAct based on prepare a delete LNCEL plan
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Check initial SBTS TDD LTE RAT
    ...    - Upload configuration status
    ...    - Import the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check LTE Rat Reset
    ...    - Check final BTS state
    ...    - Check TDD LTE RAT be Deleted
    ...    - Provision the backup plan
    ...    - Check SBTS reset
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check TDD LTE RAT be Added
    ...
    ...    Pass criteria: delete and add LNCEL provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21584 - SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct
    ...    - 09.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking, and update Check LTE TDD Object ${Exist}, add step 8 12
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    change the value of gloable variable ${plan_path} from .csv to .xml
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21584_SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct.png
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Check initial SBTS TDD LTE RAT
    Step 5: Upload configuration status
    Step 6: Import the plan SyVe
    Step 7: Provision the plan SyVe
    Step 8: Check LTE Rat Reset
    Step 9: Check final BTS state
    Step 10: Check TDD LTE RAT be Deleted
    Step 11: Provision the backup plan
    Step 12: Check SBTS reset
    Step 13: Check final BTS state
    Step 14: Check TDD LTE RAT be Added
    Step 15: Check final alarms status from WebEM
    Step 16: Check final alarms status from Netact
    Step 17: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    20 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Check initial SBTS TDD LTE RAT
    Log To Console    Step ${index}: Check initial SBTS TDD LTE RAT
    ${current_lncel_list}    coam.Get Ids For All    LNCEL
    ${initial_lncel_num}    Evaluate    len(${current_lncel_list})
    ${initial_lncel_params_list}    coam.Get Parameters For All    LNCEL
    Set Test Variable    ${initial_lncel_num}
    ${TDD_lncel_list}    Create List
    FOR    ${item}    IN    @{initial_lncel_params_list}
        ${technology}    Pop From Dictionary    ${item}    technology
        ${lncel_runtime_id}    Pop From Dictionary    ${item}    id
        Run Keyword If    '${technology}'=='TDD'    Append To List    ${TDD_lncel_list}    ${lncel_runtime_id}
    END
    ${initial_tdd_lncel_num}    Evaluate    len(${TDD_lncel_list})
    Set Test Variable    ${initial_tdd_lncel_num}
    Run Keyword If    not ${initial_tdd_lncel_num}    Fail    There is no TDD RAT on this SBTS!

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

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check LTE Rat Reset
    Log    Step ${index}: Check LTE Rat Reset    console=True
    FOR    ${index}    IN RANGE    0    60
        sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check LTE RAT status
        Check other rat status enabled
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    should be equal as strings    ${reset}    True
    FOR    ${index}    IN RANGE    0    60
        sleep    3s
        ${LNcells_Status}    Run Keyword And Return Status    coam.Assert Every    LNCEL
        ...    operationalState=${_Enabled_}, proceduralState=${_OnAirDone_}, administrativeState=${_Unlocked_}
        Check other rat status enabled
        exit for loop if    ${LNcells_Status}
    END

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check SBTS reset
    Log    Step ${index}: Check SBTS reset    console=True
    Wait Until Keyword Succeeds    300s    1s    Check IP Is Pingable    192.168.255.129    expect_pingable=${False}

Step ${index}: Check TDD LTE RAT be Deleted
    Log    Step ${index}: Check TDD LTE RAT be Deleted    console=True
    ${current_lncel_list}    coam.Get Ids For All    LNCEL
    ${current_lncel_num}    Evaluate    len(${current_lncel_list})
    Should Be Equal As Integers    ${current_lncel_num}    ${initial_lncel_num-${initial_tdd_lncel_num}}
    Check LTE TDD Object Non-Exist

Step ${index}: Check TDD LTE RAT be Added
    Log    Step ${index}: Check TDD LTE RAT be added    console=True
    ${current_lncel_list}    coam.Get Ids For All    LNCEL
    ${current_lncel_num}    Evaluate    len(${current_lncel_list})
    Should Be Equal As Integers    ${current_lncel_num}    ${initial_lncel_num}
    Check LTE TDD Object Exist

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check LTE TDD Object ${Exist}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${BTS_scf_content}=    coam.Get SCF
    ${scf_xml}=    L_XML.Parse Xml    ${BTS_scf_content}
    ${LNBTS_TDD}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"LNBTS_TDD")]
    ${LNCEL_TDD}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"LNCEL_TDD")]
    Run Keyword If    "${Exist}"=="Exist"    Run Keywords    Should Not Be Empty    ${LNBTS_TDD}
    ...    AND    Should Not Be Empty    ${LNCEL_TDD}
    Run Keyword If    "${Exist}"=="Non-Exist"    Run Keywords    Should Be Empty    ${LNBTS_TDD}
    ...    AND    Should Be Empty    ${LNCEL_TDD}

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    Set Test Variable    ${btsinfo_list}
    [Return]    ${rat_status}

Check other rat status enabled
    ${gsm_state}    Check GSM RAT status
    ${wcdma_state}    Check WCDMA RAT status
    ${nr_state}    Check NR RAT status
    ${gNbCuType}    Pop From Dictionary    ${btsinfo_list}    gNbCuType    SA
    Should Be True    "${gsm_state}" == "ALL_ENABLED" or "${gsm_state}" == "NO_CELLS" \
    Should Be True    "${wcdma_state}" == "ALL_ENABLED" or "${wcdma_state}" == "NO_CELLS" \
    Run Keyword If    "${gNbCuType}" == "SA"    Should Be True    "${nr_state}" == "ALL_ENABLED" or "${nr_state}" == "NO_CELLS" \

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${final_lncel}    coam.Get Ids For All    LNCEL
    ${final_lncel_num}    Evaluate    len(${final_lncel})
    Run Keyword If    ${initial_lncel_num}!=${0} and ${initial_lncel_num}!=${final_lncel_num}    coam.Perform Commissioning
    ...    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
