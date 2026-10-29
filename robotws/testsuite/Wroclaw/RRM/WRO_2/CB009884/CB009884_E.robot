
*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_LO_AP_LO

Documentation   :copyright: Nokia
...             :authors: Miłosz Komarczewski

Resource       taf/ul/ettf/main.robot

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       CB009884_keywords.robot
Resource       ../keywords/logging.robot


Library        taf.ul.ettf.setups
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Variables      logging_policy.py


Suite Setup        Run Keywords
...                Update And Put Iphy Xml    input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC}
...    AND         Wait For Testline Icmp Echo Replies And Ssh Services
...    AND         Set VM Ethernet Interfaces for Simulated Core Network
...    AND         With Simulator Configuration    config=${basic_setup}
...    AND         Activate And Check If X2 Link is active
...    AND         Activate X2 Link to gNB-4

Test Teardown      Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=         FULL_POLICY_WO_SOS_REPORT_WITH_EMIL
${IPHY}=                   ${CURDIR}/config/iphy_CB009884_E.xml
${SCFC}=                   scfc_CB009884_E.xml
${basic_setup}=            ${CURDIR}/config/120_NSA_UES.cfg



*** Test Cases ***
CB009884-E_1_Number_of_ERAB_Release_initiated_by_MeNB_with_cause_RNL_Normal_Release
     Attach Multiple UEs To Simulated eNB    UE_ID=1    ALL_UES=41
     Setup EN-DC for Multiple UEs From Simulated eNB    UE_ID=1     ALL_UES=21    TARGET_GNB=2    TARGET_CELLS=1    BEARER=2,3
     Setup EN-DC for Multiple UEs From Simulated eNB    UE_ID=21    ALL_UES=41    TARGET_GNB=2    TARGET_CELLS=2    BEARER=2
     Wait For Next Full Pm Interval
     Verify Pm Counters Values For Normal Release Before Test Starts
     Perform Sgnb Release For Multiple UEs    UE_ID=1    ALL_UES=41
     Verify Pm Counters Values For Normal Release After Test

CB009884_E_ERAB_setup_failure_in_SgNB_for_insufficient_UE_capabilities_caused_by_invalid_FeatureSet_reported_in_UE_capabilities
     Verify Pm Counters Values For Insufficient Capabilities Before Test Starts
     Attach Multiple UEs To Simulated eNB    UE_ID=41    ALL_UES=81
     Setup EN-DC for Multiple UEs From Simulated eNB     UE_ID=41     ALL_UES=81     TARGET_GNB=4     TARGET_CELLS=1     BEARER=2
     Wait For Next Full Pm Interval
     Trigger SgNB Change For Multiple UEs    UE_ID=41     ALL_UES=71     MEAS_ID=3    SRSRP_NR=1    TARGET_PCI=50    TARGET_RSRP=40    EVENT=A3
     Trigger SgNB Change For Multiple UEs    UE_ID=71     ALL_UES=81     MEAS_ID=4    SRSRP_NR=1    TARGET_PCI=51    TARGET_RSRP=40    EVENT=A3
     Verify Pm Counters Values For Insufficient Capabilities After Test

CB009884-E_8_ERAB_setup_failure_in_SgNB_for_Cell_Not_available_Cause-EnergySaving_cell_interworking_with_inter-SgNB_PSCell_change
     Find Scfc and Send Delta Commissioning   scfc_filename=delta_power_saving_activation.json
     Wait For Energy Saving State Activation
     Verify Pm Counters Values For Energy Saving Before Test Starts
     Attach Multiple UEs To Simulated eNB    UE_ID=81    ALL_UES=121
     Setup EN-DC for Multiple UEs From Simulated eNB    UE_ID=81    ALL_UES=82    TARGET_GNB=4    TARGET_CELLS=1    BEARER=2,3
     Setup EN-DC for Multiple UEs From Simulated eNB    UE_ID=82    ALL_UES=121    TARGET_GNB=4    TARGET_CELLS=1    BEARER=2
     Wait For Next Full Pm Interval
     Trigger SgNB Change For Multiple UEs    UE_ID=81     ALL_UES=121     MEAS_ID=3    SRSRP_NR=1    TARGET_PCI=51    TARGET_RSRP=50    EVENT=A3
     Verify Pm Counters Values For Energy Saving After Test

*** Keywords ***
Verify Pm Counters Values For Normal Release Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55112C08012    0      NX2CC_RAB_REL_RNL_NORMAL_MENB
        ...    M55112C06001    0      NX2CC_RAB_REL_ATT_MENB
        ...    M55112C06002    0      NX2CC_RAB_REL_NORM_MENB
        ...    M55180C00005    0      NX2CC_RAB_REL_NORM_MENB_NRREL
        ...    M55112C06013    0      NX2CC_RAB_REL_RNL_UNSPC_MENB
        ...    M55112C06003    0      NX2CC_RAB_REL_ABNORM_MENB
        ...    M55180C00002    0      NX2CC_RAB_REL_ABNOR_MENB_NRREL

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55112C08012    0      NX2CC_RAB_REL_RNL_NORMAL_MENB
        ...    M55112C06001    0      NX2CC_RAB_REL_ATT_MENB
        ...    M55112C06002    0      NX2CC_RAB_REL_NORM_MENB
        ...    M55180C00005    0      NX2CC_RAB_REL_NORM_MENB_NRREL
        ...    M55112C06013    0      NX2CC_RAB_REL_RNL_UNSPC_MENB
        ...    M55112C06003    0      NX2CC_RAB_REL_ABNORM_MENB
        ...    M55180C00002    0      NX2CC_RAB_REL_ABNOR_MENB_NRREL

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

Verify Pm Counters Values For Normal Release After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55112C08012    40      NX2CC_RAB_REL_RNL_NORMAL_MENB
        ...    M55112C06001    40      NX2CC_RAB_REL_ATT_MENB
        ...    M55112C06002    40      NX2CC_RAB_REL_NORM_MENB
        ...    M55180C00005    40      NX2CC_RAB_REL_NORM_MENB_NRREL
        ...    M55112C06013    0       NX2CC_RAB_REL_RNL_UNSPC_MENB
        ...    M55112C06003    0       NX2CC_RAB_REL_ABNORM_MENB
        ...    M55180C00002    0       NX2CC_RAB_REL_ABNOR_MENB_NRREL

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55112C08012    20      NX2CC_RAB_REL_RNL_NORMAL_MENB
        ...    M55112C06001    20      NX2CC_RAB_REL_ATT_MENB
        ...    M55112C06002    20      NX2CC_RAB_REL_NORM_MENB
        ...    M55180C00005    20      NX2CC_RAB_REL_NORM_MENB_NRREL
        ...    M55112C06013    0       NX2CC_RAB_REL_RNL_UNSPC_MENB
        ...    M55112C06003    0       NX2CC_RAB_REL_ABNORM_MENB
        ...    M55180C00002    0       NX2CC_RAB_REL_ABNOR_MENB_NRREL

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

Verify Pm Counters Values For Insufficient Capabilities Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55112C06029    0      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0      NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0      NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0      NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0      NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0      NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0      NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0      NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0      NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0      NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0      NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55112C06029    0      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0      NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0      NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0      NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0      NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0      NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0      NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0      NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0      NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0      NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0      NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

Verify Pm Counters Values For Insufficient Capabilities After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55112C06029    30      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    30      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0       NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0       NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0       NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0       NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0       NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0       NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0       NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0       NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0       NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0       NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55112C06029    0       NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0       NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0       NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0       NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0       NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0       NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0       NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0       NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0       NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0       NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0       NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0       NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

Verify Pm Counters Values For Energy Saving Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55112C06029    0      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0      NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0      NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0      NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0      NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0      NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0      NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0      NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0      NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0      NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0      NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55112C06029    0      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0      NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0      NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0      NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0      NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0      NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0      NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0      NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0      NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0      NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0      NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

Verify Pm Counters Values For Energy Saving After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55112C06029    0      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    0      NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0      NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0      NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0      NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0      NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0      NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0      NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0      NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0      NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0      NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55112C06029    41      NX2CC_RAB_SETUP_FL_TOT
        ...    M55112C08010    0      NX2CC_RAB_SETUP_FL_INSF_UE_CAP
        ...    M55112C08011    41      NX2CC_RAB_SETUP_FL_CNA
        ...    M55112C06024    0      NX2CC_RAB_SETUP_FL_RN_UNSPC
        ...    M55112C06025    0      NX2CC_RAB_SETUP_FL_NO_RES
        ...    M55112C06026    0      NX2CC_RAB_SETUP_FL_MSG_NOCPTBL
        ...    M55112C06027    0      NX2CC_RAB_SETUP_FL_MISC_UNSPC
        ...    M55112C06028    0      NX2CC_RAB_SETUP_FL_CP_OVL
        ...    M55112C06031    0      NX2CC_RAB_SETUP_FL_TRSRES_INIT
        ...    M55112C06032    0      NX2CC_RAB_SETUP_FL_TRSRES_TOT
        ...    M55112C06033    0      NX2CC_RAB_SETUP_FL_DSS
        ...    M55112C06030    0      NX2CC_RAB_SETUP_FL_INIT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}
