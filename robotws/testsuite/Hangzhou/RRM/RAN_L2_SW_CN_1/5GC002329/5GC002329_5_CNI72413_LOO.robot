*** Settings ***
Documentation    ...
#Resource    ./5GC002329_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    shen_yulei
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${WTS_AP_XML}    new2TDD.xml
#${WTS_CFG}    basic_setup_6cell_LOO.cfg
#${WTS_DIR}    /opt/iphy/latest
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${CNI72413_scf}    ${LOCAL_WTS_DIR}/SCF_6Cell_LOO.xml
#${iphy}    ${LOCAL_WTS_DIR}/6Cell_LOO_iphy.xml
#${SCF_PATH}    ${CURDIR}/config
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#CNI72413-ET-02-Verify nrOfSrsPorts Update From SelectFeatureSet During ScellAddition And ScellRelease When 2226Disable
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case1
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do A1scellAddition and A2release   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    Save Egate Log    log_path=${Egatelog_path}
#    Check SRSport In Egatelog case02
#
#CNI72413-ET-03-Verify nrOfSrsPorts Update From SelectFeatureSet When ActCoverageNonCoherentUes Enable During TwiceScellAddition And ScellRelease
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case2
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_2226enable.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do TwiceScellAddition And ScellRelease    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    Save Egate Log    log_path=${Egatelog_path}
#    Check SRSport In Egatelog case03
#
#CNI72413-ET-08-Verify nrOfSrsPorts Update From SelectFeatureSet During ScellAddition And IntraDuHandover
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case4
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_2226disable.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do A1ScellAdd And A3HO A1ScellAdd    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    Check SRSport In Egatelog case08
#
#CNI72413-ET-04-Verify nrOfSrsPorts Update From RDParams During ScellAddition And Update From FeatureSet In ScellRelease When 2226Enable
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case3
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_2226enable.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Change UE Capacity for NO supportedSRS-Resources N2N1
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do A1scellAddition and A2release   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    Save Egate Log    log_path=${Egatelog_path}
#    Check SRSport In Egatelog case04
#
#*** Keywords ***
#Change UE Capacity for N2N1
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    SA_Capa_Full=[0-9a-zA-Z]+
#    ${UE_CAPACITY_n2n1}=    Catenate    SEPARATOR=    SA_Capa_Full=E980D000574D5A13160003C320016093160019C3D09009B
#    ...    20C39F30C7942C0E098040623809D46C28C0D608C21A08107482C02CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C0017C00
#    ...    70005F000540001C0A83E20EB04610D04083C4160125B262A82471E439F18E7CC31E50B0381C3C09FD0000007F4000000540001C0A83E
#    ...    236B04610C0408380580356098AA081C790E7C639F30C7827F0000001FC000000150000703A8D89B81AC1184341020E90580596C98AA1
#    ...    A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E000BE000A8000380144C043741D03741D005281C41040000100541C1401C41
#    ...    000002120542E2080061040C2080008200AC3C4D000E2080000309023071342000207187850001828000287587850001C4600000C1205
#    ...    41E230007104000038581587850001C4D000010100EA0701000004840100901060144046809B00104500E60A813B639F0E14E9DB1CF87
#    ...    1274E9DB1CF870A74ED8E7C38113639F0E14489B1CF870A74FC0FF5EDC29D3F03FD7B70A244D8E7C3813B639F0C1E14200180000003D0
#    ...    4800F8405006030090018090010180F85400800000004000008020000000100000200800002004000018020000100100000A008004010
#    ...    040100000C008000060040000380200001C01000800000020000200100080601802000024010000140080000B0040020280A008004000
#    ...    1C01000818038020000340100001D24A0040F03CB925000079724A00C0F03C0F03CB9250040781E079724A0180F03C0F03C0F03C0F2E4
#    ...    940201E0781E0781E5C9280703C0F03C0F03C0F03C0F2E0940001E5C9280003D39250020781E9C9280203C0F03D382500007A724A01C0
#    ...    F03C0F03C0F03C0F03D39250060781E0781E9C9280003C392500E0781E0781E0781E0781E1C9280103C0F0E4940181E0781E078704A00
#    ...    00F0C10E54D654D60A5606560CD606D652D64CD602D6025604560AD650D646D60ED6E9190940F04000025949410000196524040000A59
#    ...    4941000039652404000125949010000596525040001A594901000079652404000225949010000996524040002A5949010000B96525040
#    ...    00325949410000D9652404010380E96525040003A594940F52AAAA55174AAAE95455058AA075541A2A94C55268AA031540A2A9355523A
#    ...    AA0F155DA864250903281510080402030180C06010080402010080C06030180C060100804060100804020100804020100804020100804
#    ...    020100804002400205003040400800010100184020200300808000020200004040180401010018002038018404018030100200020200C
#    ...    020080800C10101001804040060808030060200C0180040880A0
#    @{new_params_list}    Create List    ${UE_CAPACITY_n2n1}
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Change UE Capacity for NO supportedSRS-Resources N2N1
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    SA_Capa_Full=[0-9a-zA-Z]+
#    ${UE_CAPACITY_n1n1}=    Catenate    SEPARATOR=    SA_Capa_Full=E980D000574D5A13160003C320016093160019C3D09009B20C39F
#    ...    30C7942C0E098040623809D46C28C0D608C21A08107482C02CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C0017C0070005F
#    ...    000540001C0A83E20EB04610D04083C4160125B262A82471E439F18E7CC31E50B0381C3C09FD0000007F4000000540001C0A83E236B04
#    ...    610C0408380580356098AA081C790E7C639F30C7827F0000001FC000000150000703A8D89B81AC1184341020E90580596C98AA1A1CF88
#    ...    E3D033EC09F18E7CC31E50B0381C3C0B8002F800E000BE000A8000380144C043741D03741D005281C41040000100541C1401C41000002
#    ...    120542E2080061040C2080008200AC3C4D000E2080000309023071342000207187850001828000287587850001C4600000C120541E230
#    ...    007104000038581587850001C4D000010100EA0701000004840100901060144046809B00104500E60A813B639F0E14E9DB1CF871274E9
#    ...    DB1CF870A74ED8E7C38113639F0E14489B1CF870A74FC0FF5EDC29D3F03FD7B70A244D8E7C3813B639F0C1E14200180000003D04800F8
#    ...    405006030090018090010180F85400800000004000008020000000100000200800002004000018020000100100000A008004010040100
#    ...    000C008000060040000380200001C01000800000020000200100080601802000024010000140080000B0040020280A0080040001C0100
#    ...    0818038020000340100001D24A0040F03CB925000079724A00C0F03C0F03CB9250040781E079724A0180F03C0F03C0F03C0F2E4940201
#    ...    E0781E0781E5C9280703C0F03C0F03C0F03C0F2E0940001E5C9280003D39250020781E9C9280203C0F03D382500007A724A01C0F03C0F
#    ...    03C0F03C0F03D39250060781E0781E9C9280003C392500E0781E0781E0781E0781E1C9280103C0F0E4940181E0781E078704A0000F0C1
#    ...    0E54D654D60A5606560CD606D652D64CD602D6025604560AD650D646D60ED6E9190940F04000025949410000196524040000A59490100
#    ...    0039652404000125949010000596525040001A594901000079652404000225949010000996524040002A5949010000B96525040003259
#    ...    49410000D9652404010380E96525040003A594940F52AAAA55174AA2E95455058AA075541A2A94C55268AA031540A2A9355523AAA0F15
#    ...    5DA864250903281510080402030180C06010080402010080C06030180C060100804060100804020100804020100804020100804020100
#    ...    804002400205003040400800010100184020200300808000020200004040180401010018002038018404018030100200020200C020080
#    ...    800C10101001804040060808030060200C0180040880A0
#    @{new_params_list}    Create List    ${UE_CAPACITY_n1n1}
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Set WTS UE To Pcell
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 cell=[0-9]
#    @{new_params_list}    Create List    enb=2 cell=3
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Attach SA UE Do A1scellAddition and A2release
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1
#    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2 release
#    Trigger A2 Release    ${UE_ID}   meas_id=${measIdA2}
#    Sleep    3s
#    Get CA Cell Average Throughput    1    dl    pcell    0
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Attach SA UE Do TwiceScellAddition And ScellRelease
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1
#    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2 release
#    Trigger A2 Release    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1 Twice
#    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2 release Twice
#    Trigger A2 Release    ${UE_ID}   meas_id=${measIdA2}
#    Sleep    3s
#    Get CA Cell Average Throughput    1    dl    pcell    0
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Attach SA UE Do A1ScellAdd And A3HO A1ScellAdd
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1
#    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    ${measIdA2}=    Get MeasID A2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA3}=    Get MeasID A3 After A2
#    Trigger A3 Handover    ${UE_ID}   meas_id=${measIdA3}
#    Save Egate Log    log_path=${Egatelog_path}
#    Sleep    3s
#    Get CA Cell Average Throughput    1    dl    pcell    0
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#SA 5G PDU Session Setup CA
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session Setup CA...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#Get MeasID A1
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA1}
#
#Get MeasID A1 Twice
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA1}
#
#Get MeasID A2 release
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A2 release Twice
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[2]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A3
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA3}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA3}
#
#Get MeasID A1 Second Pcell
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[2]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA1}
#
#Get MeasID A2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A3 After A2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measId}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measId}
#
#Trigger A1 Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=95 phycell_id=52
#    ...    pass_regexp=SCellIndex 1 activated successfully
#
#Trigger A2 Release
#   [Arguments]    ${UE_ID}    ${meas_id}=1    ${SCellIndex}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=${SCellIndex} scell_rsrp=50
#    ...    pass_regexp=rrcReconfigurationComplete
#
#Trigger A3 Handover
#    [Arguments]    ${UE_ID}    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5
#    ...    ssinr_nr=10 phycell_id=55 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.6 performed
#
#Trigger A2 MG Setup
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=gapUE setup
#    Sleep    5s
#
#Check SRSport In Egatelog case02
#    ${SRSport_list}=    Get SRSport In Egatelog
#    Log To Console    Check SRSport Before A1ScellAddition
#    Should Be True    '${SRSport_list}[1]'=='2'
#    Log To Console    Check SRSport After A1ScellAddition
#    Should Be True    '${SRSport_list}[2]'=='1'
#    Log To Console    Check SRSport After A2ScellRelease
#    Should Be True    '${SRSport_list}[3]'=='2'
#
#Check SRSport In Egatelog case03
#    ${SRSport_list}=    Get SRSport In Egatelog
#    Log To Console    Check SRSport Before A1ScellAddition
#    Should Be True    '${SRSport_list}[2]'=='2'
#    Log To Console    Check SRSport After A1ScellAddition
#    Should Be True    '${SRSport_list}[3]'=='1'
#    Log To Console    Check SRSport After A2ScellReleaseTwice
#    Should Be True    '${SRSport_list}[4]'=='2'
#
#Check SRSport In Egatelog case04
#    ${SRSport_list}=   Get SRSport In Egatelog
#    ${SRSport_list_new}=    Remove Duplicates    ${SRSport_list}
#    Log To Console    Check SRSport Before A1ScellAddition
#    Should Be True    '${SRSport_list}[1]'=='1'
#    Log To Console    Check SRSport After A1ScellAddition
#    ${SRSport_number}=    Get Length    ${SRSport_list_new}
#    Should Be True    '${SRSport_number}'=='2'
#
#Check SRSport In Egatelog case08
#    ${SRSport_list}=    Get SRSport In Egatelog
#    Log To Console    Check SRSport Before A1ScellAddition
#    Should Be True    '${SRSport_list}[1]'=='2'
#    Log To Console    Check SRSport After A1ScellAddition
#    Should Be True    '${SRSport_list}[2]'=='1'
#    Log To Console    Check SRSport After IntraDuHandover
#    Should Be True    '${SRSport_list}[3]'=='2'
#
#Get SRSport In Egatelog
#    ${SRSportindex}=    Set Variable    nrofSRS-Ports\\sport\.\?(\\d)
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${SRSport_list}=    String.Get Regexp Matches    ${content}    ${SRSportindex}    1
#    [Return]    ${SRSport_list}
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}    swconfig_param=0x590072=1;    iphy_file=${iphy}    scf_file=${CNI72413_scf}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    #Modify IPHY File And Send to Airphone    ${iphy}
#    #Full Commission With SCF File    ${CNI72413_scf}
#    #Reboot TL And Check Configured
#    #Get All Testline Information And Set Suite Variable
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
#
#Configure UTE ETH For GNB3
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
