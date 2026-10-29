*** Settings ***
Documentation
...                author: Tomasz Sobania
...                modify: Michal Gradowski-Nowak
...                maintainer: Michal Gradowski-Nowak
...                contact: michal.gradowski-nowak@nokia.com
...                Test suite for CDRT UUF and L3call tests in the 5g configuration:

Force Tags         CA_VRF_WRO2  RF50

Library            OperatingSystem
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library            ta_attenuator
Library            taf.ue
Library            taf.sw.syslog
Library            qc_config.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T08/rfrl_csv4all_debug/resources/python/csv4all_attach_test.py
Library            testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Resource           testsuite/Wroclaw/RRM/resources/logs.robot

Suite Setup        Run Keywords    Mount Netdrive    AND    Remove Environment Variable    CM_EXECUTION_ID
Test Teardown      Run Keyword If Test Passed   Find Suspicious Prints In Passed Test

*** Variables ***
@{SA_UES}                                   ASUS
@{NSA_UES}                                  SAMSUNG_S23
${TPUT_DURATION}                            30
${ADB_REBOOT}                               ${False}
&{LOCAL_CELL_PER_ATT_PORT_MAPPING}          GNB_1_CELL_441=@{441, }
...                                         GNB_1_CELL_442=@{442, }
...                                         GNB_1_CELL_443=@{443, }
...                                         GNB_1_CELL_444=@{444, }
...                                         GNB_1_CELL_445=@{445, }
...                                         GNB_1_CELL_446=@{446, }
&{REMOTE_CELL_PER_ATT_PORT_MAPPING}        GNB_1_CELL_53=@{1, }
${ABSTRACT_LIB_CONFIG}              testsuite/Wroclaw/RRM/VRF_WRO2_T08/integration/MRBTS_50844/resources/ue_conf.yaml

${CELL_441}                         GNB_1_CELL_441
${CELL_442}                         GNB_1_CELL_442
${CELL_443}                         GNB_1_CELL_443
${CELL_444}                         GNB_1_CELL_444
${CELL_445}                         GNB_1_CELL_445
${CELL_446}                         GNB_1_CELL_446
${LTE_CELL_FOR_NSA}                 ENB_1_CELL
${REMOTE_VM_IP}                     10.44.75.195

${UPDATE_TEST_ITERATION}       	    	1
${SOURCE_SW}                            SBTS25R1_ENB_0000_000592_000004
${TARGET_SW}                            SBTS00_ENB_9999_250702_000006
${HOSTNAME}                             10_16_50844
${QC_DOMAIN}                            MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_02
@{CUSTOMERS}                            SKT  Korean Telecom
${EMAIL_RECIPIENTS}
...    michal.gradowski-nowak@nokia.com,i_mi_mn_ran_rd_vrf_wro2_8_sfe@internal.nsn.com,i_mi_mn_ran_rd_vrf_wro2_8@nokia.com

${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${False}
${USE_EXTERNAL_STORAGE}                 ${False}
@{NODES}                                ${GNB1}
@{TEST_NODES}                           ${GNB1}
@{NODES_NSA}                            ${GNB1}    ${ENB1}
@{TEST_NODES_NSA}                       ${GNB1}    ${ENB1}
@{CUSTOM_ALARMS}                        8150  7307  4740  7115  61631  7306  4011
...                                     1898  8000  7116  7115  7300  4268  7312  4681   4122
@{CRITICAL_FAULTS}                      10

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         custom_allowed_alarms=${CUSTOM_ALARMS}
...         critical_alarms=${CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}

&{ENB1}     node_alias=4G               testline_object=${tl.enbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_AND_L3_CALL
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${UPDATE_TEST_ITERATION}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     download_path=/MNT/UUF_SW/
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}
    ...     l3_call_method=attach_test_multiple_ues

Check Attach On Multiple UEs
    Attach Test Multiple Ues

Check Attach On Specific Ue
    Perform Attach On Specific Ue    ue=ASUS

Check Throughput On Multiple UEs
    Prepare Attenuator
    Set Attenuation    ${LTE_CELL_FOR_NSA}    0db
    Require Ue    ue_alias=Samsung    capabilities=SAMSUNG_S23
    Require Ue    ue_alias=Asus    capabilities=ASUS
    @{cells}=    Create List    ${CELL_441}
    FOR    ${cell}    IN    @{cells}
        Set Attenuation    ${cell}    0db
        taf.ue.Attach Ue    ue_alias=Samsung
        taf.ue.Attach Ue    ue_alias=Asus
        Start Data Transfer     ue_alias=Samsung  dt_name=DT_1  direction=dl
        ...                     duration=10s  throughput=10Mbits/sec    protocol=tcp
        Start Data Transfer     ue_alias=Asus  dt_name=DT_2  direction=dl
        ...                     duration=10s  throughput=10Mbits/sec    protocol=tcp
        Await Data Transfer Finish    dt_name=DT_1
        Await Data Transfer Finish    dt_name=DT_2
        Log To Console  Data transfer finish for cell: ${cell}
        Get Data Transfer Statistics  dt_name=DT_1
        Get Data Transfer Statistics  dt_name=DT_2
        taf.ue.Detach Ue    ue_alias=Samsung
        taf.ue.Detach Ue    ue_alias=Asus
    END

*** Keywords ***
Prepare Attenuator
    @{cells}=    Create List    ${CELL_441}    ${CELL_442}    ${CELL_443}    ${CELL_444}    ${CELL_445}    ${CELL_446}
    ...                         ${LTE_CELL_FOR_NSA}
    Set Global Variable    @{CELLS}    @{cells}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${cells}
    FOR    ${cell}    IN    ${cells}
        Set Attenuation    ${cell}    90dB
    END

Perform Ue Attach
    [Arguments]    ${cell}    ${ue}
    Prepare Attenuator
    taf.ue.Detach UE     UE_1
    BuiltIn.Sleep    5s
    Start Tcpdump On CU    filename=${cell}_${ue}_attach.pcap
    Set Attenuation    ${LTE_CELL_FOR_NSA}    0db
    Set Attenuation    ${cell}    0dB
    taf.ue.Attach UE    UE_1
    Log to Console    \nUE Attached!
    BuiltIn.Sleep    2s
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=20s
        ...     throughput=280Mbits/sec
        ...     protocol=udp
        ...     packet_size=1200
    BuiltIn.Sleep    20s
    [Teardown]    Run Keywords    taf.ue.Detach UE    UE_1  AND
    ...    Stop Tcpdump On CU And Download Logs    filename=${cell}_${ue}_attach.pcap   AND
    ...                           Set Attenuation    ${cell}    90dB

Perform Attach On Specific Ue
    [Arguments]    ${ue}=SAMSUNG_S23
    @{cells}=    Create List    ${CELL_441}
    taf.ue.Require UE    UE_1    capabilities=${ue}
    FOR    ${cell}    IN    @{cells}
        Perform Ue Attach    ${cell}    ${ue}
    END
