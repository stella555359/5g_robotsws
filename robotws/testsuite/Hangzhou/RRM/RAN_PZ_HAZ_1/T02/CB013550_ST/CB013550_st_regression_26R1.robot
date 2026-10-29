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
&{UE_INFO}                R3CRC011CQD=350166285465436    RFCNC0RNFJH=353158260231187
${serials}                R3CRC011CQD
${target_release}         TRUNK
${dial_number}            6688

*** Test Cases ***

[TC06]ST-6-CB013550-C#2-B2_Case6_ incrementation of counter for DL Air interface active session
    [Tags]    QC_251356    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                  counter_rule=${CURDIR}/counter_rule_activate.txt
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
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