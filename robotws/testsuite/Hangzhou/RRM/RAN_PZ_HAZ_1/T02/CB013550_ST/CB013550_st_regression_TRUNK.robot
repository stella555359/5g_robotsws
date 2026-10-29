*** Settings ***

Documentation
...    Author: jim.3.liu
...    Contact: jim.3.liu@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for Jim CB013550 ST test

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***

${TestLine_Name}          10_5_UTESRAN001T37096
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241028_000001
&{UE_INFO}                R3CRC011CQD=350166285465436    RFCNC0RNFJH=353158260231187
${serials}                R3CRC011CQD
${target_release}         TRUNK
${dial_number}            6688

*** Test Cases ***

[1][1.0] Site reset
    [Tags]    QC_32545    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC01]ST-1-CB013550-A#1-B1_Case1_ incrementation of counter for UL Air interface mute rate during a VoNR call per BIN
    [Tags]    QC_99167    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC02]ST-2-CB013550-A#2-B2_Case2_ incrementation of counter for UL Air interface active session
    [Tags]    QC_99172    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC03]ST-3-CB013550-B#1-B1_Case3_ incrementation of counter for DL Backhaul interface mute rate during a VoNR call per BIN
    [Tags]    QC_99169    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC04]ST-4-CB013550-B#2-B2_Case4_ incrementation of counter for DL Backhaul interface active session
    [Tags]    QC_99174    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC05]ST-5-CB013550-C#1-B1_Case5_ incrementation of counter for DL Air interface mute rate during a VoNR call per BIN
    [Tags]    QC_99171    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC06]ST-6-CB013550-C#2-B2_Case6_ incrementation of counter for DL Air interface active session
    [Tags]    QC_99173    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC09]ST-9-CB013550-A#3-UDP001_Case9_ incrementation of counter for UL Air interface mute Voice Call
    [Tags]    QC_99166    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC10]ST-10-CB013550-B#3-UDP002_Case10_ incrementation of counter for DL Backhaul interface mute Voice Call
    [Tags]    QC_99168    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Get SCF Internal Id By Scout    no_ute=False

[TC11]ST-11-CB013550-C#3-UDP003_Case11_ incrementation of counter for DL interface mute Voice Call
    [Tags]    QC_99170    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Run Keyword And Ignore Error    UE_Traffic_stop
    Get SCF Internal Id By Scout    no_ute=False

*** Keywords ***

SCF_Config_deactivate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...      scf_path=${CURDIR}/config/${target_release}/CB013550_deactivate_37096.xml
    Log To Console    full commission result: ${out}

SCF_Config_activate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...      scf_path=${CURDIR}/config/${target_release}/CB013550_activate_37096.xml
    Log To Console    full commission result: ${out}

UE_Traffic_exc
    log to console    start to call ${dial_number}!!
    Commercial UE Operation    start call    serialno=${serials}  dial_number=${dial_number}

UE_Traffic_stop
    log to console    Call end!
    Commercial UE Operation    stop call    serialno=${serials}

UE_Prepare
    ssh.Connect to    hostname=10.56.201.155
    ...    username=five-tester
    ...    password=Nokia123!    alias=openssh
    ${uc_close_command}    Catenate    adb -s ${serials} shell am force-stop com.nokia.android.application
    ${uc_open_command}    Catenate    adb -s ${serials} shell am start com.nokia.android.application/.NaaActivity
    ${ue_airon_command}    Catenate    adb -s ${serials} shell settings put global airplane_mode_on 1
    ${ue_airoff_command}    Catenate    adb -s ${serials} shell settings put global airplane_mode_on 0
    ssh.send_command     command=${ue_airon_command}    connection=openssh
    Sleep    30s
    ssh.send_command     command=${ue_airoff_command}    connection=openssh
    Sleep    30s
    ssh.send_command     command=${uc_close_command}     connection=openssh
    ssh.send_command     command=${uc_open_command}    connection=openssh
    ssh.disconnect    connection=openssh