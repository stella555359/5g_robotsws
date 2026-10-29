*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for RU Resiliency testing

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM     #Organization
...      TA_LEVEL_22                 #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py

*** Variables ***

${TestLine_Name}          10_5_UTESRAN001T37096
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241016_000001
&{UE_INFO}                R3CRC011CQD=350166285465436    RFCNC0RNFJH=353158260231187
${serials}                R3CRC011CQD

*** Test Cases ***

RU Resiliency via BBMOD reset
    [Tags]    QC_63471    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    30.10.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency testing via 'BBMOD reset' , cases based in 10_5_5G-MRBTS-37096 ASIK+ABIL+AHLOA*3 config

     [Setup]    Common Test Setup For RRM
     log to console    \n Start to reset bbmod ...
     BTS Operation    operation=bbmod_reset     product_type=gnb    bts_index=0    distname_id=BBMOD-3     need_verify=yes
     sleep    60s
     log to console    \n BBMOD Reset done, to prepare UE and do DL traffic
     UE_Traffic
     log to console    \n UE traffic done, collectting snapshot
     Collect Coam Snapshot    name=RU_Resiliency_CB010846_AHLOA_bbmodreset
     log to console    \n Snapshot collected... END



*** Keywords ***
SCF_Config_deactivate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...      scf_path=${CURDIR}/config/CB013550_deactivate.xml
    Log To Console    full commission result: ${out}

SCF_Config_activate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...      scf_path=${CURDIR}/config/CB013550_activate.xml
    Log To Console    full commission result: ${out}

UE_Traffic
    UE_Pre
    sleep    10s
    UE_attach
    log to console    \n UE attached, then to do DL traffic
    UE_dltraffic
    UE_detach

UE_Pre
    Commercial UE Operation    reboot    serialno=${serials}
    Commercial UE Operation    ui_operation    serialno=${serials}     item=kill_naa
    sleep   10s
    Commercial UE Operation    ui_operation    serialno=${serials}     item=launch_naa
    #Commercial UE Operation    stop_uc_all    serialno=${serials}


UE_attach
    Commercial UE Operation    attach    serialno=${serials}   forced=${True}


UE_dltraffic
    Commercial UE Operation    start traffic    serialno=${serials}    IperfOptions=-u -i 1 -t 120 -b 100M -p 50001 -l 1024B   direction=dl
    sleep   120s
    Commercial UE Operation    stop traffic     serialno=${serials}    direction=dl  IperfOptions=-u -i 1 -t 120 -b 100M -p 50001 -l 1024B
    log to console    dl traffic stopped

UE_detach
    Commercial UE Operation    detach    serialno=${serials}

