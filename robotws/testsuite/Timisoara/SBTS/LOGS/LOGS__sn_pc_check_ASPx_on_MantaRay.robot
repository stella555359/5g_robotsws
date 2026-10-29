*** Settings ***
Documentation
...    Test for CB013694
...    check core SN and core PC in NMS and compare with BTS for SMODs and BBMODs

Library    XML    use_lxml=${TRUE}
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library        ute_admin_infomodel

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700
${netAct_user_name}    omc
${netAct_user_password}    Medsql!_1893

*** Keywords ***
TC__LOGS__sn_pc_check_ASPx_on_MantaRay


    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22587
    ...  ******************
    ...  Author: Cristinel Sava and Dan Moldovan
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check core SN and core PC in NMS and compare with BTS for SMODs and BBMODs
    ...  *******************

    Set Tags   LOGS    OWNER-cristinel.sava@nokia.com    AUTHOR-cristinel.sava@nokia.com
    ...    MAINTAINER-cristinel.sava@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf    PHASE-CRT    SW-SBTS25R3

    Step 0: Preconditions
    Step 1: Get SN and PC from BTS
    Step 2: Get SN and PC from NMS
    Step 3: Compare SN and PC from BTS vs NMS



Step 0: Preconditions
    [Documentation]
    ...  In this test step test check in NMS connection is active.
    ...  take bts id and sw release
    ...  variable are created

    Log  \nStep 0 Preconditions  console=${True}

    ${bts_connection}=  coam.connect_to
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}

    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

    Connect to NMS


Step 1: Get SN and PC from BTS
     Log  \nStep 1: Get SN and PC from BTS  console=${True}

    Get Core SN and PC from SMODs
    Get Core SN and PC from BBMODs

Step 2: Get SN and PC from NMS
     Log  \nStep 2: Get SN and PC from NMS  console=${True}

    Get core SN and PC SMOD Netact
    Get core SN and PC BBMOD Netact

Step 3: Compare SN and PC from BTS vs NMS
    Log  \nStep 3: Compare SN and PC from BTS vs NMS  console=${True}

    ${c}    Evaluate    0
    FOR  ${c}    IN RANGE  ${nr_smods}
        ${c}          Set Variable    ${c + 1}
        Should be equal   ${coreHwBoardSerialNumber_${c}}    ${cmeditor-SN-SMOD_${c}}
        Should be equal   ${coreHwBoardProductCode_${c}}    ${cmeditor-PC-SMOD_${c}}

    END

    ${d}    Evaluate    0
    FOR  ${d}    IN RANGE  ${nr_bbmods}
        ${d}          Set Variable    ${d + 1}
        Should be equal   ${coreHwBoardSerialNumberBB_${d}}    ${cmeditor-SN-BBMOD_${d}}
        Should be equal   ${coreHwBoardProductCodeBB_${d}}    ${cmeditor-PC-BBMOD_${d}}

    END


Get core SN and PC SMOD Netact

    ${actual_conf}=    taf.nms.netact.Get Actual Configuration  alias=netactlab

    ${n}    Evaluate    0
    FOR  ${n}    IN RANGE  ${nr_smods}
        ${n}          Set Variable    ${n + 1}
        ${mo_id}=    Set Variable    PLMN-PLMN/MRBTS-${bts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-${n}
        ${managed_object}=    taf.nms.netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=netactlab

        Set test variable    ${cmeditor-SN-SMOD_${n}}    ${managed_object.parameters}[coreHwBoardSerialNumber]
        Set test variable    ${cmeditor-PC-SMOD_${n}}    ${managed_object.parameters}[coreHwBoardProductCode]

        log to console    cmeditor-SN-SMOD${n}:${managed_object.parameters}[coreHwBoardSerialNumber]
        log to console    cmeditor-PC-SMOD${n}:${managed_object.parameters}[coreHwBoardProductCode]

    END

Get core SN and PC BBMOD Netact

    ${actual_conf}=    taf.nms.netact.Get Actual Configuration  alias=netactlab

    ${p}    Evaluate    0
    FOR  ${p}    IN RANGE  ${nr_bbmods}
        ${p}          Set Variable    ${p + 1}
        ${mo_id}=    Set Variable    PLMN-PLMN/MRBTS-${bts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${p}
        ${managed_object}=    taf.nms.netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=netactlab

        Set test variable    ${cmeditor-SN-BBMOD_${p}}    ${managed_object.parameters}[coreHwBoardSerialNumber]
        Set test variable    ${cmeditor-PC-BBMOD_${p}}    ${managed_object.parameters}[coreHwBoardProductCode]

        log to console    cmeditor-SN-BBMOD${p}:${managed_object.parameters}[coreHwBoardSerialNumber]
        log to console    cmeditor-PC-BBMOD${p}:${managed_object.parameters}[coreHwBoardProductCode]

    END


Get Core SN and PC from SMODs

    ## Get core SMODs SN from BTS
    ${smods_distnames}  coam.Get Ids For All  SMOD
    ${lenght}=   Get Length    ${smods_distnames}
    Set Test Variable    ${nr_smods}    ${lenght}

    ${i}    Evaluate    1
    FOR  ${smod_single_distname}  IN  @{smods_distnames}

        ${smod_obj}  Query Infomodel  get object /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-${i}
    Set test variable    ${coreHwBoardProductCode_${i}}    ${smod_obj['coreHwBoardProductCode']}
    Set test variable    ${coreHwBoardSerialNumber_${i}}    ${smod_obj['coreHwBoardSerialNumber']}

    log to console    coreHwBoardProductCodeSMOD${i}:${coreHwBoardProductCode_${i}}
    log to console    coreHwBoardSerialNumberSMOD${i}:${coreHwBoardSerialNumber_${i}}

    ${i}          Set Variable    ${i + 1}
    END

Get Core SN and PC from BBMODs
    ## Get core BBMODs SN from BTS
    ${bbmods_distnames}  coam.Get Ids For All  BBMOD
    ${lenght}=   Get Length    ${bbmods_distnames}
    Set Test Variable    ${nr_bbmods}    ${lenght}
    ${j}    Evaluate    1
    FOR  ${bbmod_single_distname}  IN  @{bbmods_distnames}

        ${bbmod_obj}  Query Infomodel  get object /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${j}
    Set test variable    ${coreHwBoardProductCodeBB_${j}}    ${bbmod_obj['coreHwBoardProductCode']}
    Set test variable    ${coreHwBoardSerialNumberBB_${j}}    ${bbmod_obj['coreHwBoardSerialNumber']}

    log to console    coreHwBoardProductCodeBBMOD${j}:${coreHwBoardProductCodeBB_${j}}
    log to console    coreHwBoardSerialNumberBBMOD${j}:${coreHwBoardSerialNumberBB_${j}}

    ${j}          Set Variable    ${j + 1}
    END

Connect to NMS
    add_node   service_name=cmwas   hostname=${NETACT_LAB.cmwas}
    ...        username=${netAct_user_name}  password=${netAct_user_password}    alias=netactlab
    ${web_url}   Detect WEB URL    alias=netactlab
    Set Test Variable   ${web_url}
    taf.nms.netact.add_web_url   web_url=${web_url}   username=${netAct_user_name}   password=${netAct_user_password}   alias=netactlab

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
#    Unblocket Cell
#    ${delta_id}  Set Variable  teardown
#    coam.Create Delta  ${delta_id}
#    Run Keyword If  ${TRBLCADM_MO_ADDED} and ${FAULT_SNAPSHOT_TRIGGER_ADDED}  Run Keywords
#    ...  Log  Removing TRBLCADM managed object from configuration  console=${True}
#    ...  AND  coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  delete  ${delta_id}
#    ...  AND  coam.Get Delta  ${delta_id}
#    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
#    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
#    ...  ELSE IF  ${FAULT_SNAPSHOT_TRIGGER_ADDED} and not ${TRBLCADM_MO_ADDED}  Run Keywords
#    ...  Log  Removing faultSnapshotTriggers list from configuration  console=${True}
#    ...  AND  coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  faultSnapshotTriggers  ${delta_id}
#    ...  AND  coam.Get Delta  ${delta_id}
#    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
#    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
#    coam.Remove All Delta Id
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}




TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
