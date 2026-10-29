*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Milosz Dunikowski

Resource       taf/ul/ettf/main.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       CB009884_keywords.robot

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
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC}
...    AND         Wait For Testline Icmp Echo Replies And Ssh Services
...    AND         Set VM Ethernet Interfaces for Simulated Core Network
...    AND         With Simulator Configuration    config=${basic_setup}
...    AND         Activate And Check If X2 Link is active

Test Teardown      Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=         FULL_POLICY_WO_SOS_REPORT_WITH_EMIL
@{swconfig_8717_rdFlag}=   0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
${IPHY}=                   ${CURDIR}/config/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC}=                   CB009884_G_G1_Peak_number_UEs_one_gNB.xml
${basic_setup}=            ${CURDIR}/config/peak_UEs_intra_gnb.cfg
@{local_moid_NRCELLS}=              1    2    3    4    5    6    7    8
@{local_moid_NRCELLS_step_2}=       2    3    4    5    6    8
@{local_moid_NRCELLS_step_3_4}=     2    3    4    5    7    8
@{local_moid_NRCELLS_step_5}=       2    3    4    5    6    7    8

*** Test Cases ***
CB009884_G1_Counter_for_Peak_number_of_UEs_SA_and_NSA_one_gNB
    Verify Pm Counters Values Before Test Starts
    Attach Multiple UEs    first_ue_id=1    last_ue_id=30
    Attach Multiple UEs To Simulated eNB    UE_ID=31    ALL_UES=51
    Verify Pm Counters Values After Step 2 of Test
    Establish PDU Session With Traffic and Send A4 Measurement for NR-DC UEs    UE_ID=1    ALL_UES=16
    Establish PDU Session With Traffic For Multiple UEs    UE_ID=16    ALL_UES=31    PDU_ID=1
    Send Measurement A1 To Trigger SCell Addition For Multiple UEs    UE_ID=16    ALL_UES=31    MEAS_ID=3    SRSRP_NR=100    EVENT=A1
    Setup EN-DC for Multiple UEs From Simulated eNB    UE_ID=31    ALL_UES=51    TARGET_GNB=2    TARGET_CELLS=6    BEARER=2
    Verify Pm Counters Values After Step 3 of Test
    Trigger Handovers for CA UEs    UE_ID=16  ALL_UES=31  MEAS_TYPE=A3  SRC_RSRP=20  TGT_SSB_FREQ=425070  TGT_PCI=51
    Modify PDU Session For Multiple UEs    UE_ID=1    ALL_UES=16    QOS_TO_ADD=3
    Perform Sgnb Release For Multiple UEs    UE_ID=31    ALL_UES=51
    Verify Pm Counters Values After Step 4 of Test
    Verify Pm Counters Values After Step 5 of Test

*** Keywords ***
Verify Pm Counters Values Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS}
        Verify Any Counters In File
            ...    M55114C01588    0      PEAK_NUM_OF_UE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values After Step 2 of Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55114C01588    15      PEAK_NUM_OF_UE
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55114C01588    15      PEAK_NUM_OF_UE
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
        ...    file_path=${pm_counter_file}

    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_step_2}
        Verify Any Counters In File
            ...    M55114C01588    0      PEAK_NUM_OF_UE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values After Step 3 of Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55114C01588    30      PEAK_NUM_OF_UE
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55114C01588    35      PEAK_NUM_OF_UE
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
        ...    file_path=${pm_counter_file}

    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_step_3_4}
        Verify Any Counters In File
            ...    M55114C01588    15      PEAK_NUM_OF_UE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values After Step 4 of Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55114C01588
        ...    value_lower=28
        ...    value_higher=33
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}

    Verify Any Counters In File
        ...    M55114C01588    35      PEAK_NUM_OF_UE
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
        ...    file_path=${pm_counter_file}

    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_step_3_4}
        Verify Any Counters In File
            ...    M55114C01588    15      PEAK_NUM_OF_UE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values After Step 5 of Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55114C01588
        ...    value_lower=28
        ...    value_higher=33
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}

    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_step_5}
        Verify Any Counters In File
            ...    M55114C01588    0      PEAK_NUM_OF_UE

            ...    local_moid=${local_moid}
            ...    file_path=${pm_counter_file}
    END
