*** Settings ***
Documentation    ...
#Resource    ./5GC002329_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    shen_yulei
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${WTS_AP_XML}    new2TDD.xml
#${WTS_CFG}    basic_l1bypass_sa_call_tdd_cmwv_2TDD.cfg
#${WTS_DIR}    /opt/iphy/latest
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${CNI72413_scf}    ${LOCAL_WTS_DIR}/SCF_2TDD.xml
#${iphy}    ${LOCAL_WTS_DIR}/n25_Ecpri_iphy_2TDD.xml
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
#    Change UE Capacity for N2N1
#    Set WTS UE To Pcell
#    5GC002329_resource.Start WTS And Check OnAir
#    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
#    #Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    Attach SA UE Do A1scellAddition and A2release   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    #Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
#    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
#    ...    destination_file=${TEST_LOG_DIRECTORY}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
#    Check SRSport In Btslog case02    ${TEST_LOG_DIRECTORY}/target_syslog.txt
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
#    Change UE Capacity for N2N1
#    Set WTS UE To Pcell
#    5GC002329_resource.Start WTS And Check OnAir
#    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
#    #Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    Attach SA UE Do TwiceScellAddition And ScellRelease    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    #Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
#    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
#    ...    destination_file=${TEST_LOG_DIRECTORY}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
#    Check SRSport In Btslog case03    ${TEST_LOG_DIRECTORY}/target_syslog.txt
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
#    Set WTS UE To Pcell
#    5GC002329_resource.Start WTS And Check OnAir
#    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
#    #Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    Attach SA UE Do A1scellAddition and A2release   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    #Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
#    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
#    ...    destination_file=${TEST_LOG_DIRECTORY}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
#    Check SRSport In Btslog case04    ${TEST_LOG_DIRECTORY}/target_syslog.txt
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
#    Change UE Capacity for N2N1
#    Set WTS UE To Pcell
#    5GC002329_resource.Start WTS And Check OnAir
#    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
#    #Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    Attach SA UE Do A1ScellAdd And A3HO A1ScellAdd    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    #Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
#    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
#    ...    destination_file=${TEST_LOG_DIRECTORY}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
#    Check SRSport In Btslog case08    ${TEST_LOG_DIRECTORY}/target_syslog.txt
#
#*** Keywords ***
#Change UE Capacity for N2N1
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    ue_nr_capabilities=[0-9a-zA-Z]+
#    ${UE_CAPACITY_n2n1}=    Catenate    SEPARATOR=    ue_nr_capabilities=E980D000574D5A13160003C12016093160019C3D0304D9061CF9863CA
#    ...    160704C020311C01EA3614606B04610D04083A4022CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C0017C0070005F00024807001B280002
#    ...    800000A0F831AC1184341020F100892D931541238F21CF8C73E618F28581C0E1E04FE0000003F80000000800706000000283C18000C1
#    ...    400004240AC3818038500000082008C1C280800061C01401880510118151681204ED8E7C3853A76C73E1C29D3B639F0E044D8E7C3048
#    ...    2084310F40E007C2018060300540600060240040603E1500200000001000002008000000040000080200000801000006008000040040
#    ...    000280200100401004000030020000180100000E00800007004002000000080000800400201806008000090040000500200002C01000
#    ...    80A02802001000070040020600E0080000D0040000749280103C0F2E4940001E5C9280303C0F03C0F2E4940101E0781E5C9280603C0F
#    ...    03C0F03C0F03CB9250080781E0781E079724A01C0F03C0F03C0F03C0F03CB825000079724A0000F4E4940081E07A724A0080F03C0F4E
#    ...    0940001E9C9280703C0F03C0F03C0F03C0F4E4940181E0781E07A724A0000F0E4940381E0781E0781E0781E078724A0040F03C392500
#    ...    60781E0781E1C1280003C303F9535953582958195833581B594B5933580B58095811582B5943591B583B5BA403C10000096525040000
#    ...    65949010000296525040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A9652
#    ...    4040002E5949410000C9652504000365949010040E03A5949410000E965250394AAAA9545D2AABA55154162A81C55068AA531549A2A8
#    ...    0C55028AA4D5548EAA83C5576A018CA054402010080C06030180402010080402030180C0603018040201018040201008040201008040
#    ...    201008040201008040201000300080800C10101001804008000808080000200C02000407003
#    @{new_params_list}    Create List    ${UE_CAPACITY_n2n1}
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Change UE Capacity for NO supportedSRS-Resources N2N1
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    ue_nr_capabilities=[0-9a-zA-Z]+
#    ${UE_CAPACITY_n2n1}=    Catenate    SEPARATOR=    ue_nr_capabilities=E980D000574D5A13160003C0A02C1262C003387A0609B20
#    ...    C39F30C7942C0E098040623803D46C28C0D608C21A081074804596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E00
#    ...    0BE000280380507C18D608C21A081078804496C98AA091C790E7C639F30C7942C0E070F027F0000001FC0000000400383000000141E0C
#    ...    00060A00002120561C0C01C28000004100460E140400030E00A020C028808C0A8B4090276C73E1C29D3B639F0E14E9DB1CF870226C73E
#    ...    182410421887A05007C2018060300540600060240040603E1500200000001000002008000000040000080200000801000006008000040
#    ...    040000280200100401004000030020000180100000E00800007004002000000080000800400201806008000090040000500200002C010
#    ...    0080A02802001000070040020600E0080000D0040000749280103C0F2E4940001E5C9280303C0F03C0F2E4940101E0781E5C9280603C0
#    ...    F03C0F03C0F03CB9250080781E0781E079724A01C0F03C0F03C0F03C0F03CB825000079724A0000F4E4940081E07A724A0080F03C0F4E
#    ...    0940001E9C9280703C0F03C0F03C0F03C0F4E4940181E0781E07A724A0000F0E4940381E0781E0781E0781E078724A0040F03C3925006
#    ...    0781E0781E1C1280003C303F9535953582958195833581B594B5933580B58095811582B5943591B583B5BA403C1000009652504000065
#    ...    949010000296525000000C1000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E
#    ...    5949410000C9652504000365949010040E03A5949410000E965250394AAAA9545D2AABA55154162A81C55068AA531549A2A80C55028AA
#    ...    4D5548EAA83C5576A009940A880402010180C06030080402010080406030180C060300804020300804020100804020100804020100804
#    ...    0201008040200060010100182020200300801000101010000040180400080E006
#    @{new_params_list}    Create List    ${UE_CAPACITY_n2n1}
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Set WTS UE To Pcell
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 cell=[0-9]
#    @{new_params_list}    Create List    enb=2 cell=1
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
#    ${measIdA1}=    Get MeasID A1 Second Pcell
#    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
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
#    ${report_id}=    Set Variable    @{report_id_list}[0]
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
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=95 phycell_id=50
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
#    ...    ssinr_nr=10 phycell_id=53 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.4 performed
#
#Trigger A2 MG Setup
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=gapUE setup
#    Sleep    5s
#
##Common Test Setup 2
##    Create Test Directory
#
##Start GNB Syslog
##    [Arguments]    ${log_dir}
##    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
##    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
##    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}
##
##Stop And Collect Syslog
##    [Arguments]    ${log_dir}
##    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=True    destination=${log_dir}/Gnb_syslog
##    Set Test Variable    ${btslog}    ${log_dir}/Gnb_syslog/Gnb_syslog_*
#
#Check SRSport In Btslog case02
#    [Arguments]    ${btslog}
#    ${SCellAdditionregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"ESTATUS5G_OK",
#    ...    "cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellAdditionregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Pcell Attach UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[1]
#    Log To Console    Check Scell Addition UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[2]
#    ${SCellreleaseregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserStopResp_t: {"ueIdDu":1}
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellreleaseregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Scell release UserStopResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#
#Check SRSport In Btslog case03
#    [Arguments]    ${btslog}
#    ${SCellAdditionregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"ESTATUS5G_OK",
#    ...    "cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellAdditionregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Pcell Attach UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[1]
#    Log To Console    Check Scell Addition UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[2]
#    Log To Console    Check Twice Scell Addition UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[3]
#    ${SCellreleaseregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserStopResp_t: {"ueIdDu":1}
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellreleaseregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Scell release UserStopResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#    Log To Console    Check Scell Twice release UserStopResp Srsport ...
#    Should Not Be Empty    @{Srslog}[1]
#    ${SCellreleasemodifyregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"
#    ...    ESTATUS5G_OK","cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellreleasemodifyregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Scell release UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#    Log To Console    Check Scell Twice release UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[1]
#
#Check SRSport In Btslog case04
#    [Arguments]    ${btslog}
#    ${SCellAdditionregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"ESTATUS5G_OK",
#    ...    "cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellAdditionregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Pcell Attach UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[1]
#    Log To Console    Check Scell Addition UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[2]
#    ${SCellreleaseregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserStopResp_t: {"ueIdDu":1}
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellreleaseregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Scell release UserStopResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#    ${SCellreleasemodifyregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"
#    ...    ESTATUS5G_OK","cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellreleasemodifyregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Scell release UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#
#Check SRSport In Btslog case08
#    [Arguments]    ${btslog}
#    ${PcellAttachregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"ESTATUS5G_OK",
#    ...    "cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_2"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${PcellAttachregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Pcell Attach UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#    ${SCellAdditionregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"ESTATUS5G_OK",
#    ...    "cause":0},"ueIdDu":1,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SCellAdditionregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Scell Addition UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
#    ${SecondPcellSCellAdditionregex}=    Catenate    SEPARATOR=    itf::l2::ps::user::UserModifyResp_t: {"messageResult":{"status":"ESTATUS5G_OK",
#    ...    "cause":0},"ueIdDu":2,"needForRollback":false,"nrofSrsPortsToConfigure":"SRS_PORT_1"
#    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${SecondPcellSCellAdditionregex}' ${btslog}
#    @{Srslog}=    Split To Lines    ${ret}
#    Log To Console    Check Second Pcell Scell Addition UserModifyResp Srsport ...
#    Should Not Be Empty    @{Srslog}[0]
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
