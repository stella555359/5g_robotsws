*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for CB010846 test

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

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
${serials}                R3CRC011CQD

*** Test Cases ***

CB010846-G#41 CPRI RU resiliency to BTS-DU Capacity Unit reset Controlled case-Primary Link
    # [Tags]    QC_12034    QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    17.10.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for capacity unit (bbmod) reset, cases based in 10_5_5G-MRBTS-37096 ASIK+ABIL+AHLOA*3 config
     [Setup]    Common Test Setup For RRM
     BTS Operation    operation=bbmod_reset          product_type=gnb    bts_index=0    distname_id=BBMOD-3            need_verify=yes
     sleep    10s
     log to console    BBMOD Reset done, to check UE traffic
     UE_Pre
     sleep    10s
     UE_attach
     log to console    UE attached, then to do DL traffic
     UE_dltraffic
     UE_detach
     Collect Coam Snapshot    name=CB010846_CPRI-AHLOA_bbmodreset
     log to console    snapshot collected... END

    # Collect Coam Snapshot    name=CB010846_activate

*** Keywords ***
SCF_Config_deactivate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...      scf_path=${CURDIR}/config/CB013550_deactivate.xml
    Log To Console    full commission result: ${out}

SCF_Config_activate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...      scf_path=${CURDIR}/config/CB013550_activate.xml
    Log To Console    full commission result: ${out}

UE_Pre
    Commercial UE Operation    reboot    serialno=R3CRC011CQD    item=kill_nass
    Commercial UE Operation    ui_operation      serialno=R3CRC011CQD    item=launch_naa
    #Commercial UE Operation    stop_uc_all      serialno=R3CRC011CQD

UE_attach
    Commercial UE Operation    attach    serialno=R3CRC011CQD


UE_dltraffic
    Commercial UE Operation    start traffic    serialno=R3CRC011CQD    IperfOptions=-u -i 1 -t 120 -b 100M -p 50001 -l 1024B   direction=dl
    sleep   30s
    Commercial UE Operation    stop traffic     serialno=R3CRC011CQD    direction=dl  IperfOptions=-u -i 1 -t 120 -b 100M -p 50001 -l 1024B
    log to console    dl traffic stopped

UE_detach
    Commercial UE Operation    detach    serialno=R3CRC011CQD
    #Commercial UE Operation    detach    serialno=${serials}
