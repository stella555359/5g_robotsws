*** Settings ***
Documentation
...   author:  Jakub Kokoszka
...   contact: jakub.kokoszka@nokia.com

Library     BuiltIn
Library     DateTime
Library     Collections
Library     String
Library     OperatingSystem
Library     taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library     utils.py
Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot
Resource    ../../Resources/aic_common_resources_new.robot
Resource    ../../Resources/cu_trs_conn.robot
Resource    ../../Resources/cu_cloud_deployment.robot
Resource    ../../Resources/cu_cloud_recovery.robot
Resource    ../../Resources/vdu_oam_state.robot


*** Variables ***
@{VCU_REST_TAF_LIB_SUPPORTED_VERSION}=   cuoam_19b   cuoam_21b   cuoam_22r4  cuoam_23r1  cuoam_23r2
${VCU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
${VCU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$

*** Keywords ***
CB007800_B_CB007406_C_Cloud_Oamagent_Critical_Container_Failure
    [Documentation]
    ...    author: jie.1.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    24,02.2022, jie.1.yang@nokia-sbell.com, add script
    ...    01.12.2024, jakub.kokoszka@nokia.com, adapt to new team TL


    Step 0: Recovery CU Specfic Pods Restart Times If Not Equal Zero
    Step 1: Trigger CU Specific Process Recovery By Delete Process
    Step 2: Trigger CU Specific Process Recovery By Delete Process




Step 0: Recovery CU Specfic Pods Restart Times If Not Equal Zero
    Log  \nStep 0: Recovery CU Specfic Pods Restart Times If Not Equal Zero  console=${True}

    Recovery CU Specfic Pods Restart Times If Not Equal Zero    pod_abbr=oamext

Step 1: Trigger CU Specific Process Recovery By Delete Process
    Log  \nStep 1: Trigger CU Specific Process Recovery By Delete Process  console=${True}

    ${active_pod}=  CU Get Active Pod Name By Specified Pod  pod_abbr=oamext
    Set Test Variable    ${active_pod_full_name}    ${active_pod}

    Trigger CU Specific Process Recovery By Delete Process    oamext    oamagent    CCSMCUDaemonExe

Step 2: Trigger CU Specific Process Recovery By Delete Process
    Log  \nStep 2: Trigger CU Specific Process Recovery By Delete Process  console=${True}

    Trigger CU Specific Process Recovery By Delete Process    oamext    oamagent    CCSMCUDaemonExe
    ${active_pod}=  CU Get Active Pod Name By Specified Pod  pod_abbr=oamext
    wait until keyword succeeds   10min   1min   Get CU Specfic 2N Pods Recovery State After Pods Rebuild  full_pod_name=${active_pod}

