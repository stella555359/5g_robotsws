*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB010850_AA
...               Test Case Scenario author   : ilakcoumi.pareemanen@nokia.com
...               Test Case Scenario contact  : ilakcoumi.pareemanen@nokia.com
...               Creation Date               : 30-Aug-2023
...               Modified Date               : 2024/09/26
...               1.0 - FB2406 - vincent.boulet@nokia.com - Parity testing to introduce dRNIC RINLINE2
...               1.1 - FB2420 - blandine.garnier@nokia.com - No more buildversion present in iphy
...     6.02.25 - CloudRan TCs copied from NPS to WRO_2_4 (regression takeover), whole resources replaced

Resource          testsuite/Wroclaw/RRM/WRO_2/keywords/L3_Call.robot
Resource          testsuite/Wroclaw/RRM/WRO_2/keywords/traffic.robot

Library            ../python/CB010850_AA_RRC_Check.py
Library            OperatingSystem
Library            String
Library            BuiltIn
Library            ta5g_pm_counters
Library            DateTime
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/SWENG/KPIs.robot


*** Variables ***
${gnb_alias}                      gnb_under_test
${CB010850_AA__constraints}       ${CURDIR}/../../config/CB010850_AA_constraints.csv

&{dict_settings_ue_51}                                               ue=51
...                                                                  pdu=1
...                                                                  throughput=100
...                                                                  originalCell=60

&{dict_settings_ue_52}                                               ue=52
...                                                                  pdu=2
...                                                                  throughput=100
...                                                                  originalCell=60


&{dict_settings_ue_53}                                               ue=53
...                                                                  pdu=3
...                                                                  throughput=100
...                                                                  originalCell=60


&{dict_settings_ue_71}                                               ue=71
...                                                                  pdu=4
...                                                                  throughput=100
...                                                                  originalCell=61


&{dict_settings_ue_72}                                               ue=72
...                                                                  pdu=5
...                                                                  throughput=100
...                                                                  originalCell=61

&{dict_settings_ue_73}                                               ue=73
...                                                                  pdu=6
...                                                                  throughput=100
...                                                                  originalCell=61


&{dict_settings_ue_74}                                               ue=74
...                                                                  pdu=7
...                                                                  throughput=100
...                                                                  originalCell=61


&{dict_settings_ue_75}                                               ue=75
...                                                                  pdu=8
...                                                                  throughput=100
...                                                                  originalCell=61


@{dict_settings_all_ues}                                            ${dict_settings_ue_51}
...                                                                 ${dict_settings_ue_52}
...                                                                 ${dict_settings_ue_53}
...                                                                 ${dict_settings_ue_71}
...                                                                 ${dict_settings_ue_72}
...                                                                 ${dict_settings_ue_73}
...                                                                 ${dict_settings_ue_74}
...                                                                 ${dict_settings_ue_75}


&{BASIC_UE_SA}                      ue=1                                    profile=None        type=${None}
...                                 pdu=1                                   qfi=1               c_rnti=${None}
...                                 bearer=${None}                          testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${None}                      target_cells=1
...                                 throughput=2        testModeValue=csi_report_override
...                                 period_ms=${None}                       size=${None}

*** Keywords ***
Build UEs list SA Multi UEs

    ${totalNbOfUe}          get length          ${dict_settings_all_ues}
    Log To Console               Configure the setting for the ${totalNbOfUe} ue's
    Set Global Variable     ${totalNbOfUe}
    Log To Console      ${dict_settings_all_ues}

    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${totalNbOfUe}
        ${current_ue}=                Evaluate                      ${dict_settings_all_ues[${current_id}].ue}
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 ${dict_settings_all_ues[${current_id}].pdu}
        Set To Dictionary             ${current_ueSetting}          trf_id              ${current_ue}
        Set To Dictionary             ${current_ueSetting}          target_gnb          2
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_settings_all_ues[${current_id}].originalCell}
        Set To Dictionary             ${current_ueSetting}          throughput          ${dict_settings_all_ues[${current_id}].throughput}

        Append To List                ${listOfUes}                  ${current_ueSetting}
    END
    Log To Console                UE_List=${listOfUes}

    [Return]                          ${listOfUes}

SA Attach and Start Traffic Multi UEs
    [Arguments]                     ${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Log To Console     === SA Register UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        Wait Until Keyword Succeeds    2x    100ms   Attach UE And Establish PDU Session    ue_id=${current_elem.ue}    cell_id=${None}
        ...  enb_id=${current_elem.target_gnb}  pdu_id=${current_elem.pdu}    gw_id=${current_elem.pdu}

    END

    # Start the Non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        Log To Console   === Start Traffic UL on UE ${current_elem.ue} ===
        Send Data Traffic In Direction    ${current_elem.ue}    ${current_elem.pdu}    dir=ul    mbps=${current_elem.throughput}
    END
Detach Multi UEs
    [Arguments]  ${listOfUes}
    FOR  ${current_ue}  IN  @{listOfUes}
    	Log To Console  Detach ue: ${current_ue.ue}
	Execute Egate Command    cmd=ue_deregister id=${current_ue.ue} ue_deregister_type=switch_off
    END

Collect And Check CB010850 Counter And KPI
    [Documentation]                 Retrieve and Check 10850 AA PM counter and KPI values are as expected
    ...                             M55308C10004 M55308C36002 M55308C18001 M55308C18002 Counters
    ...                             Check also UL initial BLER and UL residual BLER
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${OUTPUT_DIR}/PM_${date_in_dir_name}
    Log To Console                       The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    vdu=1

    set Suite Variable              ${LATEST_PM_FILE}       ${pm_counter_file}
    set Suite Variable              ${log_path_pm}
    Log To Console                       Latest pm counters file : ${LATEST_PM_FILE}

    Log To Console                        ===> check counter and KPI constraints is started

    KPI Evaluate                     pmFile=${LATEST_PM_FILE}
    ...                              constraintsFile=${CB010850_AA__constraints}
    ...                              failOnError=${True}

    Log To Console                        ===> check counter and KPI constraints is ended

CB010850_AA_Check_RRC
    [Documentation]                 Check RRC message for Cell 3 and 4
    ...                             Pucch-ResourceCommon in SIBs
    ...                             LocationAndBandwidth in initial UL BWP in SIBs
    ...                             LocationAndBandwidth in dedicated UL BWP during UE register
    ...                             Check SRS prbs are not in blanked area during UE register
    ${current_date}=                    DateTime.Get Current Date       result_format=%Y%m%d-%H%M%S
    ${filename}                         set variable                    ${current_date}_egate_console_Check_AA_RRC_UL_Blanking.log
    ${output}                           Copy File    /opt/iphy/latest/egate_console.log     ${OUTPUT_DIR}/${filename}
    Log To Console                           === check Cell 61 ====
    ${rrc_status}                       CB010850_AA_RRC_Check_Cell4                  ${OUTPUT_DIR}/${filename}
    Should Be True                      ${rrc_status} == True

    Log To Console                           === check Cell 60 ====
    ${rrc_status}                       CB010850_AA_RRC_Check_Cell3                  ${OUTPUT_DIR}/${filename}
    Should Be True                      ${rrc_status} == True

    Log To Console                           === check UEs ====
    ${rrc_status}                       CB010850_AA_RRC_Check_Ues                    ${OUTPUT_DIR}/${filename}
    Should Be True                      ${rrc_status} == True

CB010850_AA_PRB_BLANKING
    [Documentation]        Test to check that ul blanked prbs are not used
    ...                    Counters, KPI and RRC message checks
    ${listOfUes}         Build UEs list SA Multi UEs
    ${zoi}                          ZOI Start    pmAvailDelay=100    gp=600
    SA Attach and Start Traffic Multi UEs       ${listOfUes}
    CB010850_AA_Check_RRC
    Log To Console              === Starting collecting PM
    ZOI Wait End                    zoi=${zoi}
    Collect And Check CB010850 Counter And KPI
    [Teardown]  Detach Multi UEs  ${listOfUes}
