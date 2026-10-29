*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008731
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot

Resource        CB008731-commissioning-forced-HO.robot
Resource        CB008731-wts-forced-HO.robot
Resource        CB008731-parameter-settings-force-HO.robot
Resource        CB008731-parameter-definitions.robot
Resource        CB008731-verify-counter.robot
Resource        CB008731-verify-wireshark.robot
Resource        CB008731-keywords-egate-verify-force-HO.robot
#Resource        CB008731-counter.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot

Suite Setup       Suite Setup CB008731_force_HO
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***



CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    [Documentation]    CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    ...       :Autor: Sylvia Schneider
    [Tags]    t11
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    start wireshark trace
    activate SCF and bring tl onAir force HO
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    set sib period
    ue change location            ue_id=1   cell=2
    Set traffic type              ue_id=1   pdu_id=1    trf_type=internal   log_traffic_stats=off

    start wireshark trace

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE                   ue_id=1
    start PDU session             ue_id=1    check=Pdu Session Resource Setup Response Message with RAN UE NGAP ID 2 handled successfully
    modify ue pdu session         ue_id=1    qosflows_to_add=2
    modify ue pdu session         ue_id=1    qosflows_to_add=3

    send B2       ue_id=1    B2_meas_id=19   check=Successful handover from ENB-3.2 to ENB-4.1

    start UDP traffic force HO

    change ue capabilities
    trigger handover to 5G which fails    ue_id=1   cause=radio resources not available

    set actForceHoInsuffUeCap to true
    get time before_HO
    trigger handover to 5G   ue_id=1    check=a1-Threshold rsrp : 88,   target_cell=1
    display measurements of UE   ue_id=1   log=_1

    send A2 and check            ue_id=1   A2_meas_id=1
    display measurements of UE   ue_id=1   log=_2

    get bearer statistics force HO
    get time after_bearer_stats
    UE Deregister            ue_id=1


    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_force_HO.pcap

    Run Keyword And Warn On Failure         dcap tracing stop

    run keyword and continue on Failure    Verify counter forced-HO
    run keyword and continue on Failure    verify wireshark 8731 force HO
    save last SCF
    run keyword and continue on Failure    verify egate log force HO

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace






*** Keywords ***

Suite Setup CB008731_force_HO
    [Documentation]    [PRIVATE]    Prepare TL for CB008731_force_HO
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC CB008731 force HO
    Update SCF file for TCCB008731 force HO
    update iphy file CB008731_force_HO


update iphy file CB008731_force_HO
    [Documentation]    [PRIVATE]    update iphy file CB008731_force_HO
    ...       :Autor: Sylvia Schneider

    get gnb TargetBD file
    get resourceBuildKey and swFileKey for AEHC from TargetBD file
    update iphy with AEHC data for 2nd rmod


get gnb TargetBD file
    [Documentation]    [PRIVATE]    get gnb TargetBD file
    ...       :Autor: Sylvia Schneider
    ${gNBCommUnit_alias}    Connect to Node Common Unit
    ${file_name}   ssh.execute      ls /ffs/run/TargetBD_SBTS*.xml   connection=${gNBCommUnit_alias}
    ${file_name}   remove string   ${file_name}   \n   \r
    ssh.Download File   remote_path=${file_name}   local_path=${resultBaseDir}/TargetBD.xml   connection=${gNBCommUnit_alias}
    [Teardown]    ssh.Disconnect   connection=${gNBCommUnit_alias}


get resourceBuildKey and swFileKey for AEHC from TargetBD file
    [Documentation]    [PRIVATE]    get resourceBuildKey and swFileKey for AEHC from TargetBD file
    ...       :Autor: Sylvia Schneider
    ${target_xml}    Parse XML      ${resultBaseDir}/TargetBD.xml
    ${TargetBD_resourceBuildKey}    get element attribute    ${target_xml}    resourceSWVersion    xpath=.//hwResource[@resourceBuildKey="LTX_AEHC"]
    set suite variable      ${TargetBD_resourceBuildKey}
    ${TargetBD_swFileKey}           get element text         ${target_xml}    xpath=.//hwResource[@resourceBuildKey="LTX_AEHC"]
    set suite variable      ${TargetBD_swFileKey}


update iphy with AEHC data for 2nd rmod
    [Documentation]    [PRIVATE]    update iphy with AEHC data for 2nd rmod
    ...       :Autor: Sylvia Schneider

    log to console    update iphy file
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>

    ${upd1}    Replace String Using Regexp    ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>6351<\/GSCN>
    ${upd2}    Replace String Using Regexp    ${upd1}      <cardName>.*</cardName>     <cardName>AEHC</cardName>
    ${upd3}    Replace String Using Regexp    ${upd2}      <bldVersion>.*</bldVersion>     <bldVersion>${TargetBD_resourceBuildKey}</bldVersion>
    ${upd4}    Replace String Using Regexp    ${upd3}      <productCode>.*</productCode>     <productCode>475124A</productCode>
    ${upd5}    Replace String Using Regexp    ${upd4}      <resourceBuildKey>.*</resourceBuildKey>     <resourceBuildKey>LTX_AEHC</resourceBuildKey>
    ${upd6}    Replace String Using Regexp    ${upd5}      <name>.*</name>     <name>${TargetBD_swFileKey}</name>
    ${upd7}    Replace String Using Regexp    ${upd6}      <version>.*</version>     <version>${TargetBD_resourceBuildKey}</version>

    ${new contents}      catenate         SEPARATOR=</RE>   ${all_parts}[0]            ${upd7}
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[2]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[3]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


get time ${event}
    [Documentation]    [PRIVATE]    get time
    ...       :Autor: Sylvia Schneider
    ${time_stamp}    DateTime.Get Current date
    set test variable   ${time_stamp_${event}}  ${time_stamp}
