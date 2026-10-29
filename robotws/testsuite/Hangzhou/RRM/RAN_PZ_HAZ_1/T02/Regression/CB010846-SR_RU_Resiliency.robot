
*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for RU Resiliency testing

Force Tags
...      TRUNK          #Tag Item
...      VRF_RRM        #Competence Area
...      VRF_HAZ1_T02   #Organization
...      TA_LEVEL_23    #Detailed Automation Level[TA_LEVEL_21， TA_LEVEL_22，TA_LEVEL_23]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py
Library     taf.sw.scout    WITH NAME    scout


*** Variables ***

${TestLine_Name}          10_5_UTESRAN001T37096
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241016_000001
${serials}                R3CRC011CQD
#RFCNC0RNFJH



*** Test Cases ***

RU Resiliency via BBMOD reset
    [Tags]    QC_66243    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    24.10.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency testing via 'BBMOD reset'

    [Setup]    Common Test Setup For RRM
    Key_Parameters_Checking_and_Updating
    Log to console    \n Begin to reset bbmod
    BTS Operation    operation=bbmod_reset     product_type=gnb    bts_index=0    distname_id=BBMOD-3      need_verify=yes
    sleep    10s
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n BBMOD Reset done and cells onair

    #UE_Traffic
    #log to console    \n UE traffic done, collectting snapshot logs

    Collect Coam Snapshot    name=RU_Resiliency_CB010846_AHLOA_bbmodreset
    log to console    \n Snapshot collected... END
    [Teardown]    Teardown_for_CB010846


RU Resiliency via site_reset_without_RU_resetting
    [Tags]    QC_63471    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    14.11.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency testing via 'site reset without RU resetting'

    [Setup]    Common Test Setup For RRM
    Key_Parameters_Checking_and_Updating
    Log to console    \n Begin to reset site without RU resetting
    BTS Operation    operation=bts_reset       product_type=gnb    bts_index=0    need_verify=yes    reset_without_ru=${True}
    sleep    10s
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n Site reset without RU resetting is done and cells onair
    #UE_Traffic
    #log to console    \n UE traffic done, collectting snapshot logs
    Collect Coam Snapshot    name=RU_Resiliency_CB010846_AHLOA_site_reset_without_RU_resetting
    log to console    \n Snapshot collected... END
    [Teardown]    Teardown_for_CB010846

RU Resiliency via NR_hard_reset
    [Tags]    QC_74464   QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    13.11.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency testing via 'NR_hard_reset'

    [Setup]    Common Test Setup For RRM
    Key_Parameters_Checking_and_Updating
    Log to console    \n Begin to NR hard reset
    BTS Operation    operation=rat_reset       product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=yes
    ...    reset_type=Hard
    sleep    10s
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n NR hard reset done and cells onair
    #UE_Traffic
    #log to console    \n UE traffic done, collectting snapshot logs
    Collect Coam Snapshot    name=RU_Resiliency_CB010846_AHLOA_NR_hard_reset
    log to console    \n Snapshot collected... END
    [Teardown]    Teardown_for_CB010846

*** Keywords ***
UE_Traffic
    UE_Pre
    sleep    10s
    UE_attach
    log to console    \n UE attached, then to do DL traffic
    UE_dltraffic
    UE_detach

UE_Pre
    Commercial UE Operation    ui_operation    serialno=${serials}   item=kill_naa
    Commercial UE Operation    ui_operation    serialno=${serials}   item=launch_naa
    #Commercial UE Operation    stop_uc_all    serialno=${serials}

UE_attach
    Commercial UE Operation    attach    serialno=${serials}

UE_dltraffic
    Commercial UE Operation    start traffic    serialno=R3CRC011CQD    IperfOptions=-u -i 1 -t 180 -b 100M -p 50001 -l 1024B   direction=dl
    sleep   180s
    Commercial UE Operation    stop traffic     serialno=R3CRC011CQD    direction=dl  IperfOptions=-u -i 1 -t 120 -b 100M -p 50001 -l 1024B
    log to console     \n DL traffic stopped

UE_detach
    Commercial UE Operation    detach    serialno=${serials}


Key_Parameters_Checking_and_Updating
    @{para_list}    Create List   actRuResetResiliency
    @{mo_list}      Create List   MRBTS-37096/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List    true
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb   para_list=${para_list}    mo_list=${mo_list}

    #Log To Console    paramter update result: ${out}
    #log to console    it's ${mo_list}[0]
    #log to console    it's ${out}[${mo_list}[0]]
    #log to console    the first parameter is ${para_list}[0]
    #log to console    the first parameter's value is ${out}[${mo_list}[0]][${para_list}[0]]

    ${value_read}    set Variable    ${out}[${mo_list}[0]][${para_list}[0]]
    run keyword if      '${value_read}'=='${value_list}[0]'
    ...    Log To Console    \nParameter Check Result: ${out}
    ...    ELSE     run Keywords
    ...    log to console    \n'${para_list}[0]'='${value_read}', need to update to '${value_list}[0]'
    ...    AND    Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    ${out_new}    Parameter Operation    operation=parameter_value_check   product_type=gnb   para_list=${para_list}    mo_list=${mo_list}
    log to console    \n>>>> Double Check: Parameter ${para_list}[0] is: ${out_new}[${mo_list}[0]][${para_list}[0]]

Teardown_for_CB010846
    Get SCF Internal Id By Scout    no_ute=False
    Common Test Teardown For RRM
