*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
#&{plan_info_8660_001_1}      plan_info_8660_001_1scf_distName=MRBTS-1905/GNBTS-1/GNBCF-1    mo_id=PLMN-PLMN/MRBTS-1905/GNBTS-1/GNBCF-1
#...     parent_parameter_name=None    parameter_name=mPlaneLocalIpAddressDN    shortenedDN=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
#...     incorrect_shortenedDN=IPADDRESSV4-1    flag=None
&{plan_info_8660_001_2}      scf_distName=MRBTS-1894/NRBTS-10694/NRDU-1    mo_id=PLMN-PLMN/MRBTS-1894/NRBTS-10694/NRDU-1   parent_parameter_name=None
...    parameter_name=targetDN    shortenedDN=APEQM-1   incorrect_shortenedDN=APEQM-3    flag=None
#&{plan_info_8660_001_3}      scf_distName=MRBTS-1894/MNL-1/MNLENT-1/CELLMAPPING-1/LCELC-1/CHANNELGROUP-1/CHANNEL-9
#...    mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/CELLMAPPING-1/LCELC-1/CHANNELGROUP-1/CHANNEL-9   parent_parameter_name=None
#...    parameter_name=antlDN    shortenedDN=RMOD-1/ANTL-1   incorrect_shortenedDN=ANTL-1    flag=None
&{plan_info_8660_001_4}      scf_distName=MRBTS-1894/LNBTS-5076/TRSNW-0    mo_id=PLMN-PLMN/MRBTS-1894/LNBTS-5076/TRSNW-0
...    parent_parameter_name=cPlane    parameter_name=ipV4AddressDN1    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1
...    incorrect_shortenedDN=IPADDRESSV4-1    flag=lte
&{plan_info_8660_001_5}      scf_distName=MRBTS-1894/NRBTS-10694   mo_id=PLMN-PLMN/MRBTS-1894/NRBTS-10694
...    parent_parameter_name=s1Uplane    parameter_name=ipV4AddressDN1    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-2
...    incorrect_shortenedDN=IPADDRESSV4-2    flag=None
#&{plan_info_8660_001_6}      scf_distName=MRBTS-1905/WNBTS-1/WNCEL-19051    mo_id=PLMN-PLMN/MRBTS-1905/WNBTS-1/WNCEL-19051
#...    parent_parameter_name=None    parameter_name=lCelwDN    shortenedDN=LCELW-0    incorrect_shortenedDN=LCELW-5    flag=None
#&{plan_info_8660_001_7}      scf_distName=MRBTS-1905/WNBTS-1/WNCELG-1    mo_id=PLMN-PLMN/MRBTS-1905/WNBTS-1/WNCELG-1   parent_parameter_name=None
#...    parameter_name=smodDN    shortenedDN=SMOD-1    incorrect_shortenedDN=SMOD-3    flag=None
&{plan_info_8660_001_8}      scf_distName=MRBTS-1894/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
...    mo_id=PLMN-PLMN/MRBTS-1894/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1   parent_parameter_name=None
...    parameter_name=ethlkDN    shortenedDN=TNL-1/ETHSVC-1/ETHLK-1    incorrect_shortenedDN=ETHSVC-1/ETHLK-5    flag=None
&{plan_info_8660_001_9}      scf_distName=MRBTS-1894/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3
...    mo_id=PLMN-PLMN/MRBTS-1894/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3     parent_parameter_name=None
...    parameter_name=linkSelectorDN    shortenedDN=TNL-2/ETHSVC-1/ETHLK-3    incorrect_shortenedDN=ETHLK-5    flag=None
&{plan_info_8660_001_10}      scf_distName=MRBTS-1894/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1
...    mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1     parent_parameter_name=None
...    parameter_name=ntpSourceIpAddressDN    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1   incorrect_shortenedDN=IPADDRESSV4-1    flag=None
#&{plan_info_8660_001_11}      scf_distName=MRBTS-1894/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-700/CHANNELGROUP-1/CHANNEL-1
#...    mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-700/CHANNELGROUP-1/CHANNEL-1    parent_parameter_name=None
#...    parameter_name=resourceDN    shortenedDN=RMOD-9/PHYANT-1   incorrect_shortenedDN=PHYANT-1    flag=None
&{plan_info_8660_001_12}      scf_distName=MRBTS-1894/MNL-1/MNLENT-1/MPLANENW-1
...    mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/MPLANENW-1     parent_parameter_name=None
...    parameter_name=mPlaneIpv4AddressDN    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1   incorrect_shortenedDN=IPADDRESSV4-1    flag=None
&{plan_info_8660_001_13}      scf_distName=MRBTS-1894/NRBTS-10694
...    mo_id=PLMN-PLMN/MRBTS-1894/NRBTS-10694    parent_parameter_name=ngCplane
...    parameter_name=ipV4AddressDN1    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-2   incorrect_shortenedDN=IPADDRESSV4-1    flag=None
#&{plan_info_8660_001_14}      scf_distName=MRBTS-1894/MNL-1/MNLENT-1/MPLANEFHNW-1   mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/MPLANEFHNW-1
#...    parent_parameter_name=None    parameter_name=mPlaneFHIPAddressV4DN    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1
#...    incorrect_shortenedDN=IPADDRESSV4-1    flag=None

*** Keywords ***
SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-xxx
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing mainly to check operator provision a configuration plan that contains a new parameter of
    ...    a distname-type, configured to the shortened form or Fully Distinguished Name form from NetAct
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Random Select Parameter
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in Netact after provision plan
    ...    - Provision the backup plan
    ...    - Create and edit plan SyVe with incorrect shortenedDN
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe with incorrect shortenedDN
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.01.2023 - New by Xu Yuyan - New case
    Set Tags    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-yuyan.xu@nokia-sbell.com
    Step 1: Random Select Parameter
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check modified parameter in Netact after provision plan
    Step 10: Provision the backup plan
    Step 11: Create and edit plan SyVe with incorrect shortenedDN
    Step 12: Export the plan SyVe
    Step 13: Provision the plan SyVe with incorrect shortenedDN
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

Step ${index}: Random Select Parameter
    Log    Step ${index}: Random Select Parameter    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${tmp_list}    Create List    #${plan_info_8660_001_1}    ${plan_info_8660_001_2}    ${plan_info_8660_001_3}    ${plan_info_8660_001_4}
    ...    ${plan_info_8660_001_2}    ${plan_info_8660_001_4}
#    ...    ${plan_info_8660_001_5}    ${plan_info_8660_001_6}    ${plan_info_8660_001_7}    ${plan_info_8660_001_8}    ${plan_info_8660_001_9}
    ...    ${plan_info_8660_001_5}    ${plan_info_8660_001_8}    ${plan_info_8660_001_9}
    ...    ${plan_info_8660_001_10}    ${plan_info_8660_001_12}    ${plan_info_8660_001_13}    #${plan_info_8660_001_14}
    ${plan_info}    Evaluate    random.choice(${tmp_list})    modules=random, sys
    Set Test Variable    ${plan_info}
    ${parameter}    Run Keyword If    "${plan_info['parent_parameter_name']}"=="None" and "${plan_info['flag']}"=="None"
    ...    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['shortenedDN']}
    ...    ELSE IF    "${plan_info['parent_parameter_name']}"!="None" and "${plan_info['flag']}"=="lte"
    ...    Create Dictionary    ${plan_info['parent_parameter_name']}${plan_info['parameter_name']}=${plan_info['shortenedDN']}
    ...    ELSE    Set_Complex_Parameter    ${plan_info}    ${plan_info['shortenedDN']}
    ${incorrect_parameter}    Run Keyword If    "${plan_info['parent_parameter_name']}"=="None" and "${plan_info['flag']}"=="None"
    ...    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['incorrect_shortenedDN']}
    ...    ELSE IF    "${plan_info['parent_parameter_name']}"!="None" and "${plan_info['flag']}"=="lte"
    ...    Create Dictionary    ${plan_info['parent_parameter_name']}${plan_info['parameter_name']}=${plan_info['incorrect_shortenedDN']}
    ...    ELSE    Set_Complex_Parameter    ${plan_info}    ${plan_info['incorrect_shortenedDN']}
    ${TNL_RELATED}    Run Keyword And Return Status    Should Contain    ${plan_info['shortenedDN']}    TNL
    ${tmp_err_1}    Set Variable    references non-existing '${plan_info['incorrect_shortenedDN']}' object
    ${tmp_err_2}    Set Variable    under TNL object model tree must start at least from TNL and cannot be shortened further
    ${tmp_err_3}    Set Variable    Distname parameter '${plan_info['parameter_name']}'
    ${tmp_err_4}    Set Variable    Distname parameter '${plan_info['parent_parameter_name']}-1.${plan_info['parameter_name']}'
    ${tmp_err_5}    Set Variable   '${plan_info['incorrect_shortenedDN']}' is invalid because the shortened distinguished names pointing to objects
    ${error_message}    Set Variable If    ${TNL_RELATED}     ${tmp_err_5} ${tmp_err_2}
    ...    "${plan_info['parent_parameter_name']}"=="None"    ${tmp_err_3} ${tmp_err_1}
    ...    "${plan_info['parent_parameter_name']}!"="None"    ${tmp_err_4} ${tmp_err_1}
    Set Test Variable    ${parameter}
    Set Test Variable    ${incorrect_parameter}
    Set Test Variable    ${error_message}
    ${same_values}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{parameter}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}
    Log    plan_info:${plan_info}    console=True

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains
    ...    informations   such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{parameter}
    Set Test Variable    ${plan}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    ${NEED_SCF_RECOVERY_FLAG}    Set Variable    True
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    30
        sleep    2s
        ${gncell_onair}    Run Keyword If      ${GSM_cell_ids}      Run Keyword And Return Status
        ...    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
        ${wncell_onair}    Run Keyword If      ${WCDMA_cell_ids}    Run Keyword And Return Status
        ...    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
        ${lncell_onair}    Run Keyword If      ${LTE_cell_ids}      Run Keyword And Return Status
        ...    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}
        ${nrcell_onair}    Run Keyword If      ${NRBTS_cell_ids}    Run Keyword And Return Status
        ...    coam.Assert Every    NRCEL    ${cells_NR_expected_state}
        Run Keyword If    ${GSM_cell_ids}      Should Be True    ${gncell_onair}
        Run Keyword If    ${WCDMA_cell_ids}    Should Be True    ${wncell_onair}
        Run Keyword If    ${LTE_cell_ids}      Should Be True    ${lncell_onair}
        Run Keyword If    ${NRBTS_cell_ids}    Should Be True    ${nrcell_onair}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful


Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    ui_values=false    &{parameter}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{parameter}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Create and edit plan SyVe with incorrect shortenedDN
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe with incorrect shortenedDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{incorrect_parameter}
    Set Test Variable    ${plan}

Step ${index}: Provision the plan SyVe with incorrect shortenedDN
    Log    Step ${index}: Provision the plan SyVe with incorrect shortenedDN    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}
    ...    create_backup_plan=False    provisioning_operation=activate
    Should Contain    ${feedback}    ${error_message}
    Should Contain    ${feedback}    FAILURE    failed
    Should Contain    ${feedback}    Validation failed

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Set_Complex_Parameter
    [Arguments]    ${plan_info}    ${value}
    &{parameter_child}    Create Dictionary    ${plan_info['parameter_name']}=${value}
    @{parameter_child_list}    Create List    ${parameter_child}
    &{parameter}    Create Dictionary    ${plan_info['parent_parameter_name']}=@{parameter_child_list}
    [Return]    ${parameter}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{parameter}
    Run Keyword If    ${plan_values} and not ${same_values}    Run Keywords
    ...   Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

