*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for CM__CB009939-A_012
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_HOST_USER_NAME}    ute
${REMOTE_HOST_PASSWD}    uteUTE!
${REMOTE_ALIAS}    remote_alias

*** Keywords ***
CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Setup remote alias for remote control PC and save original SCF files and create Redundancy
    ...    Case Precondition
    ...    Set Redundancy On BTS1 And BTS2
    ...    Full Commissioning On BTS1 From Active To Forced Active And Check
    ...    Delta Commissioning With Reset And Lock Cell On BTS1 And Check
    ...    Full Commissioning On BTS2 From Active To Forced Active And Check
    ...    Reset On BTS1 And Check When BTS2 Is Forced Active
    ...    Reset On BTS1 And Check When Removed BTS2
    ...    Remove Redundancy On BTS2 And Check
    ...    Reset On BTS1 And Check When Removed BTS2
    ...    Remove Redundancy On BTS1 And Check
    ...  Pass criteria: LNCELs NRCELs of standby BTS should be offline, LNCELs NRCELs of active BTS should be onair,
	...  fault 4737 4738 4739 should be raised and cleared as expected. LNCELs NRCELs should be onair after Redundancy removed.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.05.2024 - Xu Yuyan New case for CB009939-A case 12
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Set Redundancy On BTS1 And BTS2
    Step 3: Full Commissioning On BTS1 From Active To Forced Active And Check
    Step 4: Delta Commissioning With Reset And Lock Cell On BTS1 And Check
    #Step 5: Full Commissioning On BTS2 From Standby To Active And Check
    #Step 6: Reset On BTS1 And Check When BTS2 Is Active
    Step 7: Full Commissioning On BTS2 From Active To Forced Active And Check
    Step 8: Reset On BTS1 And Check When BTS2 Is Forced Active
    Step 9: Remove Redundancy On BTS2 And Check
    Step 10: Reset On BTS1 And Check When Removed BTS2
    Step 11: Remove Redundancy On BTS1 And Check


Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Remote BTS Setup   ${REMOTE_HOST_IP}    ${REMOTE_HOST_USER_NAME}    ${REMOTE_HOST_PASSWD}    ${REMOTE_ALIAS}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${bts_obj}    coam.Get parameters for all    BTS
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_1}    ${bts_id}
    ${bts_obj}    coam.Get parameters for all    BTS    alias=${REMOTE_ALIAS}
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_2}    ${bts_id}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_4}    Create Dictionary    faultId=${7300}    #No X2 link available
    ${redundancy_alarm_5}    Create Dictionary    faultId=${6327}    #Setup of X2 connectivity to gNB failed
    ${redundancy_alarm_6}    Create Dictionary    faultId=${7319}    #No X2 link available for a specific LTEENB
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4737_4738_4739}
    ${ALARMS_4738_4739}    Create List    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4738_4739}
    ${ALARMS_4737_7300_6327}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_4}    ${redundancy_alarm_5}
    Set test Variable    ${ALARMS_4737_7300_6327}
    ${ALARMS_7300_6327}    Create List    ${redundancy_alarm_4}    ${redundancy_alarm_5}
    Set test Variable    ${ALARMS_7300_6327}
    ${ALARMS_4739_7300_6327}    Create List    ${redundancy_alarm_3}    ${redundancy_alarm_4}    ${redundancy_alarm_5}
    Set test Variable    ${ALARMS_4739_7300_6327}
    ${ALARMS_4738_4739_7300_6327}    Create List    ${redundancy_alarm_2}    ${redundancy_alarm_3}    ${redundancy_alarm_4}    ${redundancy_alarm_5}
    Set test Variable    ${ALARMS_4738_4739_7300_6327}
    Set Test Variable   ${lte_failed_state}    administrativeState=unlocked, operationalState=disabled, availabilityStatus=failed
    Set Test Variable   ${nr_failed_state}    administrativeState=Unlocked, operationalState=disabled, availabilityStatus=failed
    Set Test Variable   ${RMOD_expected_state}    administrativeState=Unlocked, operationalState=enabled

Step ${index}: Set Redundancy On BTS1 And BTS2
    Log To Console    Step ${index}: Set Redundancy On BTS1 And BTS2
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${parameters_dic1}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active
    ${parameters_dic2}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    Wait Until Keyword Succeeds    10x    45 sec    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    Wait Until Keyword Succeeds    10x    45 sec    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=60
    Wait Until Keyword Succeeds    10x    45 sec
    ...    coam.assert_every    LNCEL    ${cells_LTE_offline_state}    timeout=60    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    45 sec
    ...    coam.assert_every    NRCEL    ${cells_NR_offline_state}    timeout=60    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Full Commissioning On BTS1 From Active To Forced Active And Check
    Log To Console    Step ${index}: Full Commissioning On BTS1 From Active To Forced Active And Check
    ${full_scf_bts1}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${full_scf_bts1}
    L_XML.Set Element Text    ${scf_xml}    forced active
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/REDUNDANCY-1"]/p[@name="redundancyRole"]
    L_XML.Set Element Text    ${scf_xml}    false
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_1}/MNL-1"]/p[@name="validatePlanAgainstDetectedHW"]
    L_XML.Save Xml    ${scf_xml}    ${BTSFiles}/scf_bts1_forced_active.xml
    coam.Perform Commissioning    ${MRBTS_ID_1}    ${BTSFiles}/scf_bts1_forced_active.xml    skip_parameter_relation_errors=${TRUE}
    ...    timeout=600s
    Sleep    240s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    standby    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    standby    "forced active"    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}

Step ${index}: Delta Commissioning With Reset And Lock Cell On BTS1 And Check   #bts2 not check??
    Log To Console    Step ${index}: Delta Commissioning With Reset And Lock Cell On BTS1 And Check
    ${nrcells_list}    Fetch ID Mapping From Admin For Cells    NRBTS
    ${current_value}    Get Parameter Value From WebEM
    ...    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall
    ${value_to_set}    Set Variable If    "${current_value}"=="true"    false    true
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID_1}_${time}
    coam.append_parameter_update_to_delta
    ...    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall    ${value_to_set}    ${MRBTS_ID_1}_${time}
    #5G cell-1 locked
    ${nrcell}    Set Variable    ${nrcells_list[0]}
    ${nrcell_dn}    Get From Dictionary    ${nrcell}    configuration
    coam.append_parameter_update_to_delta    ${nrcell_dn}    administrativeState    Locked    ${MRBTS_ID_1}_${time}
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID_1}_${time}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    timeout=600
    Log To Console    Check BTS1
    #yuki0429 need update
    Set Test Variable   ${nr_state}    blockingState=Unblocked
    Check SBTS Redundancy States    "forced active"    standby    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${nr_state}
    coam.assert    NRCEL    ${nrcell["internal"]}    ${cells_NR_locked_state}    timeout=100
    Wait Until Keyword Succeeds    10x    45 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces
    Log To Console    unlock cell
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID_1}_${time}
    ${nrcell}    Set Variable    ${nrcells_list[0]}
    ${nrcell_dn}    Get From Dictionary    ${nrcell}    configuration
    coam.append_parameter_update_to_delta    ${nrcell_dn}    administrativeState    Unlocked    ${MRBTS_ID_1}_${time}
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID_1}_${time}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}
    Wait Until Keyword Succeeds    5 min    45 sec
    ...    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    Wait Until Keyword Succeeds    5 min    45 sec
    ...    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=60

Step ${index}: Full Commissioning On BTS2 From Standby To Active And Check
    Log To Console    Step ${index}: Full Commissioning On BTS2 From Standby To Active And Check
    ${full_scf_bts2}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}    alias=${REMOTE_ALIAS}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${full_scf_bts2}
    L_XML.Set Element Text    ${scf_xml}    active
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1"]/p[@name="redundancyRole"]
    L_XML.Set Element Text    ${scf_xml}    false
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1"]/p[@name="validatePlanAgainstDetectedHW"]
    L_XML.Save Xml    ${scf_xml}    ${BTSFiles}/scf_bts2_active.xml
    coam.Perform Commissioning    ${MRBTS_ID_2}    ${BTSFiles}/scf_bts2_active.xml    skip_parameter_relation_errors=${TRUE}
    ...    connection=${REMOTE_ALIAS}    timeout=600s
    Sleep    240s
    Log To Console    Check BTS2
    ute_admin_infomodel.teardown_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_HOST_USER_NAME}    remote_host_password =${REMOTE_HOST_PASSWD}
    Check SBTS Redundancy States    active    "forced active"    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20 min    45 sec
    ...   coam.assert_every    RMOD    ${RMOD_expected_state}    timeout=60    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    45 sec    Admin Check Active Alarms TAF
    ...    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}    expected_patterns=@{ALARMS_7300_6327}
    Wait Until Keyword Succeeds    10x    60 sec
    ...    Check BTS Interfaces    alias=${REMOTE_ALIAS}    ngLinkStatus=Inactive    xnLinkStatus=unavailable    x2ToGnbLinkStatus=unavailable
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    active    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    45 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Check BTS Interfaces
    Sleep    180s

Step ${index}: Reset On BTS1 And Check When BTS2 Is Active
    Log To Console    Step ${index}: Reset On BTS1 And Check When BTS2 Is Active
    coam.reset_site
    Sleep    240s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    active    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    20 min    45 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    "forced active"    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}    expected_patterns=@{ALARMS_7300_6327}
    Check BTS Interfaces    alias=${REMOTE_ALIAS}    ngLinkStatus=Inactive    xnLinkStatus=unavailable    x2ToGnbLinkStatus=unavailable

Step ${index}: Full Commissioning On BTS2 From Active To Forced Active And Check
    Log To Console    Step ${index}: Full Commissioning On BTS2 From Active To Forced Active And Check
    ${full_scf_bts2}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}    alias=${REMOTE_ALIAS}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${full_scf_bts2}
    L_XML.Set Element Text    ${scf_xml}    forced active
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1"]/p[@name="redundancyRole"]
    L_XML.Set Element Text    ${scf_xml}    false
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1"]/p[@name="validatePlanAgainstDetectedHW"]
    L_XML.Save Xml    ${scf_xml}    ${BTSFiles}/scf_bts2_forcedactive.xml
    coam.Perform Commissioning    ${MRBTS_ID_2}    ${BTSFiles}/scf_bts2_forcedactive.xml    skip_parameter_relation_errors=${TRUE}
    ...    connection=${REMOTE_ALIAS}    timeout=600s
    Sleep    240s
    Log To Console    Check BTS2
    ute_admin_infomodel.teardown_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_HOST_USER_NAME}    remote_host_password =${REMOTE_HOST_PASSWD}
    Check SBTS Redundancy States    "forced active"    "forced active"    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    45 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    expected_patterns=@{ALARMS_4737_7300_6327}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}    x2ToGnbLinkStatus=unavailable
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    "forced active"    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Wait Until Keyword Succeeds    30x    90 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4737_7300_6327}
    Wait Until Keyword Succeeds    20x    60 sec    Check BTS Interfaces
    ...   ngLinkStatus=Inactive    xnLinkStatus=unavailable    x2ToGnbLinkStatus=unavailable

Step ${index}: Reset On BTS1 And Check When BTS2 Is Forced Active
    Log To Console    Step ${index}: Reset On BTS1 And Check When BTS2 Is Forced Active
    coam.reset_site
    Sleep    240s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    "forced active"    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Wait Until Keyword Succeeds    20x    60 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4737_7300_6327}
    Wait Until Keyword Succeeds    20x    90 sec
    ...    Check BTS Interfaces    ngLinkStatus=Inactive    xnLinkStatus=unavailable    x2ToGnbLinkStatus=unavailable
    Log To Console    Check BTS2
    Check SBTS Redundancy States    "forced active"    "forced active"    ${MRBTS_ID_1}    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20x    90 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    expected_patterns=@{ALARMS_4737_7300_6327}
    Wait Until Keyword Succeeds    20x    75 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}    x2ToGnbLinkStatus=unavailable

Step ${index}: Remove Redundancy On BTS2 And Check
    Log To Console    Step ${index}: Remove Redundancy On BTS2 And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    empty    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Wait Until Keyword Succeeds    10x    45 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4738_4739_7300_6327}
    Wait Until Keyword Succeeds    20x    90 sec
    ...    Check BTS Interfaces    x2ToGnbLinkStatus=unavailable    ngLinkStatus=Inactive    xnLinkStatus=unavailable
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    "forced active"    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    60 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Reset On BTS1 And Check When Removed BTS2
    Log To Console    Step ${index}: Reset On BTS1 And Check When Removed BTS2
    coam.reset_site
    Sleep    240s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    "forced active"    empty    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Wait Until Keyword Succeeds    10x    45 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4738_4739_7300_6327}
    Wait Until Keyword Succeeds    20x    90 sec
    ...    Check BTS Interfaces    x2ToGnbLinkStatus=unavailable    ngLinkStatus=Inactive    xnLinkStatus=unavailable
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    "forced active"    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Remove Redundancy On BTS1 And Check
    Log To Console    Step ${index}: Remove Redundancy On BTS1 And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Set Test Variable    ${NEED_COMMISSION}    ${False}

Case Special Teardown
    Log To Console    Case Special Teardown
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    alias=${REMOTE_ALIAS}
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_initial}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS}

