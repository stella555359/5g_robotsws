*** Settings ***
Documentation  Script for AllFeatures

Library    BuiltIn
Library    SeleniumLibrary
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin         WITH NAME    admin
Library    ta5g_commissioning              WITH NAME    tcom
Library    ute_fsmaccess
Library    ta5g_pm_counters
Library    taf.analyzer.pcap    WITH NAME    cap
Library         ../../../resources/PythonLib/UTILS.py
Library     ../Keywords/table.py
Variables       ta5g_global_var
Resource        ../../../resources/Keywords/generic_kw.robot
Resource        ../../../resources/Keywords/gnb_Keywords.robot
Resource        ../../../resources/Keywords/HO_KW.robot
Resource        ../ute/ute_wts_runner.robot
Resource        ../Keywords/common_keywords.robot
Resource        ../../../resources/Keywords/ap_Keywords.robot
Resource        ../../../resources/Keywords/tsharkPcapVerifyKeywords.robot


*** Variables ***
${DeltaConfigDir}       /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf
${APConfigDir}          /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/ap_iphy
${TOPOLOGY}     CLOUD_5G_I_LO_AP_LO
${UE1}        1
${UE2}        2
${UE_stats_pdsch_pattern}        NR PDSCH Throughput
${UE_stats_pusch_pattern}       NR PUSCH Throughput


*** Keywords ***
Commision scf and iphy
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword Unless    '${iphy}' == '${EMPTY}'    update_and_put_iphy_xml
    ...      input_filepath=${iphy}
    Run Keyword Unless    '${scf}' == '${EMPTY}'     tcom.Send Delta Commissioning
    ...    ${scf}

Prepare for test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#       iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_basic_call.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
     ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_basic_call.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    basic_auto.cfg
    Basic Bring up


Prepare for CA NSA test Case
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#   iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_ca_tandf_nsa.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
    ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_ca_tandf_nsa.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
##    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    ca_tandf_nsa.cfg
    Basic Bring up
    X2AP Link Should be UP
    ${cell_status}=  run keyword and return status    wait until keyword succeeds  10 min  1 min
    ...     AP Cell Setup should be Successful
    run keyword if   '${cell_status}'!='True'   fail    msg='cellsetup failed'
    ...     ELSE     set suite variable    ${CB008229_A_a_status}     True


Prepare for CA test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#  iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/ap_iphy/iphy_CA.xml
    Full Commission With SCF File For UTE      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_CA_Auto.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    CA_KR.cfg
    Basic Bring up

Prepare for CA_F+T and T+F test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/ap_iphy/iphy_ca_fandt_tandf.xml
    Full Commission With SCF File For UTE
    ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_ca_fandt_tandf.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    ca_fandt_tandf.cfg
    Basic Bring up

Prepare for CA_del test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#     iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_4wrkngcells.xml
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_4wrkngcells.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    4wrkngcells.cfg
    Basic Bring up


Prepare for Handover test Case
    [Documentation]     This Keyword is specifically used for setting up handover testcase
   ${Test_CaseNumber}=     Set Variable    HO_Auto
   ${Log_Path}=        Create Log Directory        ${Test_CaseNumber}
    Create Basic Interface on UTE
#   Commission scf and iphy for 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
#   ...                                       iphy=${IphyConfigDir}/new_iphy_AEHC_AEQE.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_HO_KR2.xml
    Full Commission With SCF File For UTE      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_HO_KR2.xml
    sleep    200s
    log to console           \n   Rebooting GNB wait for 360s
#    GNB Reboot
   sleep    360s
    Wait Coam Site to be Ready
    Start UTE WTS        HO_KR2.cfg
    [Return]                    ${Log_Path}
    Basic Bring up

Prepare for Ng Handover test Case for FDD cells
    [Documentation]     This Keyword is specifically used for setting up handover testcase
   ${Test_CaseNumber}=     Set Variable    HO_Auto
   ${Log_Path}=        Create Log Directory        ${Test_CaseNumber}
    Create Basic Interface on UTE
#   Commission scf and iphy for 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
#   ...                                       iphy=${IphyConfigDir}/new_iphy_AEHC_AEQE.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_ng_ho_fdd.xml
    Full Commission With SCF File For UTE
    ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_ng_ho_fdd.xml
    sleep    200s
    log to console           \n   Rebooting GNB wait for 360s
#    GNB Reboot
    sleep    360s
    RAT Block Unblock
    Wait Coam Site to be Ready
    Start UTE WTS        ng_ho_fdd.cfg
    [Return]                    ${Log_Path}
    Basic Bring up

Prepare for Ng Handover test Case for TDD
    [Documentation]     This Keyword is specifically used for setting up Ng handover testcase for TDD
#   ${Test_CaseNumber}=     Set Variable    HO_Auto
#   ${Log_Path}=        Create Log Directory        ${Test_CaseNumber}
    Create Basic Interface on UTE
#   Commission scf and iphy for 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
#   ...                                       iphy=${IphyConfigDir}/new_iphy_AEHC_AEQE.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_ng_ho_tdd.xml
    Full Commission With SCF File For UTE
    ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_ng_ho_tdd.xml
    sleep    200s
    log to console           \n   Rebooting GNB wait for 360s
#    GNB Reboot
    sleep    360s
    Wait Coam Site to be Ready
    Start UTE WTS        ng_ho_tdd.cfg
    Basic Bring up

Prepare for Xn Handover test Case for TDD
    [Documentation]     This Keyword is specifically used for setting up Xn handover testcase for TDD
   ${Test_CaseNumber}=     Set Variable    HO_Auto
   ${Log_Path}=        Create Log Directory        ${Test_CaseNumber}
    Create Basic Interface on UTE
#   Commission scf and iphy for 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
#   ...                                       iphy=${IphyConfigDir}/new_iphy_AEHC_AEQE.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_xn_ho_tdd.xml
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_xn_ho_tdd.xml
    sleep    200s
    log to console           \n   Rebooting GNB wait for 360s
#    GNB Reboot
    sleep    360s
    Wait Coam Site to be Ready
    Start UTE WTS        xn_ho_tdd.cfg
    [Return]                    ${Log_Path}
    Basic Bring up

Prepare for Xn Handover test Case for FDD
    [Documentation]     This Keyword is specifically used for setting up Xn handover testcase for FDD
   ${Test_CaseNumber}=     Set Variable    HO_Auto
   ${Log_Path}=        Create Log Directory        ${Test_CaseNumber}
    Create Basic Interface on UTE
#   Commission scf and iphy for 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
#   ...                                       iphy=${IphyConfigDir}/new_iphy_AEHC_AEQE.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_xn_ho_fdd.xml
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_xn_ho_fdd.xml
    sleep    200s
    log to console           \n   Rebooting GNB wait for 360s
#    GNB Reboot
    sleep    360s
    RAT Block Unblock
    Wait Coam Site to be Ready
    Start UTE WTS        xn_ho_fdd.cfg
    [Return]                    ${Log_Path}
    Basic Bring up


Prepare for IntraGnb Inter Frequency HO
    [Documentation]     This Keyword is specifically used for setting up Xn handover testcase for TDD
   ${Test_CaseNumber}=     Set Variable    HO_Auto
   ${Log_Path}=        Create Log Directory        ${Test_CaseNumber}
    Create Basic Interface on UTE
#   Commission scf and iphy for 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
#   ...                                       iphy=${IphyConfigDir}/new_iphy_AEHC_AEQE.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_intraG_interF_HO.xml
    Full Commission With SCF File For UTE
    ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_intraG_interF_HO.xml
    sleep    200s
    RAT Block Unblock
    log to console           \n   Rebooting GNB wait for 360s
#    GNB Reboot
    sleep    360s
    Wait Coam Site to be Ready
    Start UTE WTS        intraG_interF_HO.cfg
    [Return]                    ${Log_Path}
    Basic Bring up


AP soft-reset
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_basic_call.xml
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_basic_call.xml
    sleep   200s
    log to console         \n Rebooting AP wait for 360s
    AP Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    basic_auto.cfg
    Basic Bring up

WTS soft-reset
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#    iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    log to console         \n Rebooting GNB wait for 360s
    WTS Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    SBTS00_SANSA_FS_wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Basic Bring up


PDU-IP gnb reset
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#     iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    log to console         \n Rebooting GNB from PDU,wait for 360s
    Browse to PDU-IP Address and Reset gnb
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    SBTS00_SANSA_FS_wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Basic Bring up

PDU-IP AP reset
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#     iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    log to console         \n Rebooting AP from PDU,wait for 360s
    Browse to PDU-IP Address and Reset AP
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    SBTS00_SANSA_FS_wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Basic Bring up


Common test case tear down
    Delete Basic Interface on UTE
#    Collect Logs For The Test           ${Log_Path}
    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json        iphy=${APConfigDir}/TC_iphy.xml
    log to console         \n Rebooting GNB wait for 360s
    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready

Browse to PDU-IP Address and Reset gnb
    Open Browser    http://10.63.68.138/RRB/    Chrome
    sleep    10s
    Input Text    name=username    admin
    Input Text    name=password    admin
    Click Button    Submit
    sleep    10s
    Click Button    onOffButton2
    sleep    10s
#Wait for the JavaScript alert to appear
    Wait Until Keyword Succeeds    10s    1s    Alert Should Be Present
#Get the alert message only if an alert is present
    ${alert_is_present}=    Run Keyword And Return Status    Alert Should Be Present
    ${alert_message}=    Run Keyword And Ignore Error    Get Alert Message
    Run Keyword If    '${alert_is_present}' == 'True'    Log    Alert Text: ${alert_message}
#Handle the JavaScript alert
    Run Keyword If    '${alert_is_present}' == 'True'    Handle Alert    Accept    # Use Accept or Dismiss depending on your scenario
    sleep    20s
    Click Button    onOffButton2
    sleep    10s
#Wait for the JavaScript alert to appear
    Wait Until Keyword Succeeds    10s    1s    Alert Should Be Present
#Get the alert message only if an alert is present
    ${alert_is_present}=    Run Keyword And Return Status    Alert Should Be Present
    ${alert_message}=    Run Keyword And Ignore Error    Get Alert Message
    Run Keyword If    '${alert_is_present}' == 'True'    Log    Alert Text: ${alert_message}
#Handle the JavaScript alert
    Run Keyword If    '${alert_is_present}' == 'True'    Handle Alert    Accept    # Use Accept or Dismiss depending on your scenario
    sleep    10s
    [teardown]   Close Browser

Browse to PDU-IP Address and Reset AP
    Open Browser    http://10.63.68.138/RRB/    Chrome
    sleep    10s
    Input Text    name=username    admin
    Input Text    name=password    admin
    Click Button    Submit
    sleep    10s
    Click Button    onOffButton1
    sleep    10s
#Wait for the JavaScript alert to appear
    Wait Until Keyword Succeeds    10s    1s    Alert Should Be Present
#Get the alert message only if an alert is present
    ${alert_is_present}=    Run Keyword And Return Status    Alert Should Be Present
    ${alert_message}=    Run Keyword And Ignore Error    Get Alert Message
    Run Keyword If    '${alert_is_present}' == 'True'    Log    Alert Text: ${alert_message}
#Handle the JavaScript alert
    Run Keyword If    '${alert_is_present}' == 'True'    Handle Alert    Accept    # Use Accept or Dismiss depending on your scenario
    sleep    20s
    Click Button    onOffButton1
    sleep    10s
#Wait for the JavaScript alert to appear
    Wait Until Keyword Succeeds    10s    1s    Alert Should Be Present
#Get the alert message only if an alert is present
    ${alert_is_present}=    Run Keyword And Return Status    Alert Should Be Present
    ${alert_message}=    Run Keyword And Ignore Error    Get Alert Message
    Run Keyword If    '${alert_is_present}' == 'True'    Log    Alert Text: ${alert_message}
#Handle the JavaScript alert
    Run Keyword If    '${alert_is_present}' == 'True'    Handle Alert    Accept    # Use Accept or Dismiss depending on your scenario
    sleep    10s
    [teardown]   Close Browser

Start and Validate Traffic For CA
    [Arguments]        ${UE_ID}    ${dl_rate}=170    ${ul_rate}=170
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}

Verification of Downlink throughput
    [Arguments]             ${id}
    wtsrunner.ue_stats_nr       scell=0-1    type=pdsch    id=${id}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_stats_pdsch_pattern}       ${Timeout_SA}
    ${result}       table.GetPDSCH       ${output}
    Run Keyword If    ${result} == 1       Log     pass

Verification of Uplink throughput
    [Arguments]             ${id}
    wtsrunner.ue_stats_nr       scell=0-1    type=pusch    id=${id}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_stats_pusch_pattern}       ${Timeout_SA}
    ${result}      table.GetPDSCH    ${output}
    Run Keyword If    ${result} == 1       Log     pass

Prepare for CA_6cell test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#   iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_chandra.xml
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_chandra.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    chandra_LATEST.cfg
    Basic Bring up

Lock cell
    [Documentation]     This Keyword Locking the cell as per the requirement
    Log to Console      Locking the cell
    admin.Setup admin
    Online NIDD parameter change    paramName=administrativeState            paramValue=Locked
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-1
    sleep               60s
    [Teardown]          admin.Teardown admin

Lock cell A1
    [Documentation]     This Keyword Locking the cell as per the requirement
    Log to Console      Locking the cell
    admin.Setup admin
    Online NIDD parameter change    paramName=administrativeState            paramValue=Locked
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-1
    [Teardown]          admin.Teardown admin

Unlock cell
    [Documentation]     This Keyword Unlocking the cell as per the requirement
    Log to Console      Unlocking the cell
    admin.Setup admin
    Online NIDD parameter change    paramName=administrativeState             paramValue=Unlocked
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-1
    sleep                               60s
    [Teardown]          admin.Teardown admin

GNB soft-reset
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    log to console         \n Rebooting GNB wait for 360s
    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS    SBTS00_SANSA_FS_wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Basic Bring up


Prepare for test Case_7103B
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_7103.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_working_7103_B.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    wts_7103_low_PAPR_DMRS_PUCCH_only.cfg
    Basic Bring up

Prepare for test Case_7103A
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_7103.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_working_7103_A.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    wts_7103_low_PAPR_DMRS_PUSCH_only.cfg
    Basic Bring up

Prepare for test Case_12544B
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_basic_call.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_12544_B.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    basic_auto.cfg
    Basic Bring up

Prepare for test Case_12544C
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#       iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_basic_call.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_12544_C.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    12544_C_latest.cfg
    Basic Bring up

Prepare for test Case_12544D
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#   iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
##    update_and_put_iphy_xml         ${APConfigDir}/iphy_basic_call.xml
#    Updated Suite Setup
##    Full Commission With SCF File For UTE      /home/ute/robotws/testsuite/Bangalore/RRM/5GL3ET_BLR/Sharanya/config/gnb_scf/scf_12544_D.xml
##    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
##    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    12544_C_latest.cfg
    Basic Bring up


Prepare for test Case CB010507
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#    iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_CB010507.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_CB010507.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
	sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    CB010507.cfg
    Basic Bring up

Prepare for test Case CB010507_TC2
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#      iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_CB010507_TC2.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
    ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_CB010507_TC2.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    CB010507_TC2.cfg
    Basic Bring up

Prepare for test Case CB010887
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#     iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_CB010887_TC3.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
     ...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_CB010887_TC3.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    CB010887_TC3.cfg
    Basic Bring up

Prepare for CB008224 test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#   iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy8224_DK_updated.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE
    ...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/Mallar8224TCReleaseSCF.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    basic_setup8224DK.cfg
    Basic Bring up

Prepare for CB011123 test Case
#    ${Test_CaseNumber}=     Set Variable    CB008152_TC13
#    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
#    Commision scf and iphy      scf=${DeltaConfigDir}/Delta_TC.json
#     iphy=${APConfigDir}/SBTS00_SANSA_FS_AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    update_and_put_iphy_xml         ${APConfigDir}/iphy_11123.xml
#    Updated Suite Setup
    Full Commission With SCF File For UTE     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/config/gnb_scf/scf_11123.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    basic_11123.cfg
    Basic Bring up

Prepare for CB008490 test Case
    Create Basic Interface on UTE
    update_and_put_iphy_xml         /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/CB008490/config/ap_iphy/8490_iphy.xml
    Full Commission With SCF File For UTE
...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/CB008490/config/gnb_scf/8490_MN_Simulated_SCF.xml
    sleep   200s
    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS   /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/CB008490/config/wts/nrdc_8490_MN_sim_working.cfg
    Basic Bring up
