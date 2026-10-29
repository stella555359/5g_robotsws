*** Settings ***

Documentation
...    Author: jim.3.liu
...    Contact: jim.3.liu@nokia-sbell@nokia-sbell.com
...    This scripts for Trunk CDRT test only

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           4h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***

${TestLine_Name}          10_5_UTESRAN001T11308
${target_release}         TRUNK
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241028_000001


*** Test Cases ***

[1][1.0] UUF_Upgrade And Rollback
    [Tags]    QC_49606    QCD_MN_RAN    QCP_RAN_VRF    CRT
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    [Setup]    Common Test Setup For RRM
    [Timeout]    3h
    Run keyword if    "${target_release}" != "TRUNK"    BTS Operation  operation=upgrade     product_type=gnb    bts_index=0
    ...    indicated_sw_version=${SELECTED_SW_VERSION}
    ...    ELSE    log to console    no need upgrade again.
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR
    FOR    ${i}    IN RANGE    2
        Roll_Back_SW
        log to console    ${i} round rollback done.
    END
    Get SCF Internal Id By Scout    no_ute=False

[1][1.0] Sleeping Cell Audit Testing With Multi-UE Call
    [Tags]    QC_49607    QCD_MN_RAN    QCP_RAN_VRF    CRT
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    [Setup]    Common Test Setup For RRM
    [Timeout]    1h
    FOR    ${i}    IN RANGE    5
        BTS Operation    operation=bts_reset    product_type=gnb    bts_index=0    need_verify=yes
    END
    Get SCF Internal Id By Scout    no_ute=False

[1][1.0] Attach SR with Multi-UE
    [Tags]    QC_49608    QCD_MN_RAN    QCP_RAN_VRF    CRT
        [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    [Setup]    Common Test Setup For RRM
    [Timeout]    1h
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55124C01031;
    ...         Counter rule: delta_value(M55124C01031)>=0
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${True}
    Sleep    15m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

*** Keywords ***

Roll_Back_SW
    COAM_Admin.Login
    coam.rollback_software    connection=COAM
    Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair
    ${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
    Run Keyword If    ${cell_status}==${False}    reset site and wait cell onair