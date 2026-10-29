*** Settings ***
Documentation
...  author: Tomasz Dabrowski
...  contact: tomasz.dabrowski@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Library     ta5g_pm_counters
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources/CB008950_kw.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/resources/keywords.py


*** Variables ***
${resource_path_10741}    /home/ute/testline_configuration
#PCI 924 - AHFII 1 - PCell
#PCI 346 - AHFII 2 - barred
#PCI 917 - AHFII 3 - barred
#PCI 26 - AHLOB 1 - PCELL
#PCI 232 - AHLOB 2
#PCI 51 - AHLOB 3
#PCI 258 - AVHA 1 - SCell_1
#PCI 565 - AVHA 2
#PCI 482 - AVHA 3


*** Keywords ***
Env Setup
    Set test variable  ${test_name}  CB010741-D_B4
    @{cells}=    Create List    22   301
    CB008950_kw.Load scf for 8950    ${resource_path_10741}    SCFs    scf_10741-D_B4.xml
    Check specific cells are on air    ${cells}  connection=cOAM
    Check gNB status after Commm  connection=cOAM
    set mtk deployment mode    UE_1    SA
    set mtk bands    UE_1    010000000000010000000042000000000    #n25n41n66n71
    Wait until keyword succeeds  15min      1min    Check if X2 link Up


[1]CB010741_D_B4_2_Retest_of_CB010741-A#B4_with_one-shot_buffer_based_SCell_Addition
    [Documentation]    This test confirms the CB010741-A#B4 scenario functionality when one-shot
    ...                buffer based SCell Addition is activated.
    ...                PCELL: PCI 924
    ...                SCELL: PCI 301
    Env Setup

    Prepare and start new DCAP   dcap_host=10.44.180.37  bts_mplane=${bts_mplane}  nrCells=NRCELL_R-22 NRCELL_R-301

    Register UE and move into coverage of PCI 924
    UE moves to the coverage of PCI 301
    Initiate high bitrate uplink TCP data transmission  dt_name=UL_SA
    Trigger PCell Switch by attenuating PCell 924 and deattenuating Cell 301 RF signal
    UE moves to the coverage of PCI 924 to trigger ScellAddition after PCell Switch
    Initiate high bitrate uplink TCP data transmission  dt_name=UL_SA_2
    Stop all traffic and detach UE

    Stop new DCAP trace and download logs json    subdir=${test_name}
    Verify JSON file from DCAP  expected_messages=${messages_10741_D_B4}

    Verify PM Counters 10741-D_B4



*** Keywords ***
Register UE and move into coverage of PCI 924
    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}  value=10   alias=att_2
    Sleep  10s
    ute_ue.Attach Ue    UE_1    timeout=60
    turn_mobile_data_on    UE_1
    Sleep  10s
    ${PCI_UE4}=       ute_ue.Get Ue Info    UE_1   PCI
    Log to Console    UE attached PCI now: ${PCI_UE4}


UE moves to the coverage of PCI 301
    Set attenuation on ports and check    lines=${lines_gNB_310_AVHA_1_TDD_n41}  value=85    alias=att_1
    Sleep  5s
    Set attenuation on ports and check    lines=${lines_gNB_310_AVHA_1_TDD_n41}  value=80    alias=att_1
    Sleep  5s


Trigger PCell Switch by attenuating PCell 924 and deattenuating Cell 301 RF signal
    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}  value=55    alias=att_2
    Sleep  10s
    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}  value=65    alias=att_2
    Sleep  20s
    Set attenuation on ports and check    lines=${lines_gNB_310_AVHA_1_TDD_n41}  value=70    alias=att_1
    Sleep  5s
    Set attenuation on ports and check    lines=${lines_gNB_310_AVHA_1_TDD_n41}  value=60    alias=att_1
    Sleep  5s
    ${PCI_UE4}=       ute_ue.Get Ue Info    UE_1   PCI
    Log to Console    UE attached PCI now: ${PCI_UE4}

UE moves to the coverage of PCI 924 to trigger ScellAddition after PCell Switch
    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}  value=55    alias=att_2
    Sleep  20s


Initiate high bitrate uplink TCP data transmission
    [Arguments]  ${dt_name}
    Start Data Transfer    dt_name=${dt_name}   ue_alias=UE_1    direction=ul    duration=500s    throughput=500Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    Sleep  60s


Stop all traffic and detach UE
    Run keyword and ignore error    Stop Data Transfer     UL_SA
    Run keyword and ignore error    Stop Data Transfer     UL_SA_2
    ute_ue.Detach Ue     UE_1


Verify PM Counters 10741-D_B4
    Wait For Next Full Pm Interval Classical
    ${output}=    Set Variable  ${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${output}
    Verify Any Counters In All Files
    ...    M55118C00031    >0    A4_SCELL_ADDED_SA
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-21
    ...    files_path=${output}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55118C00031    >0    A4_SCELL_ADDED_SA
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-301
    ...    files_path=${output}
    ...    report_pm_counter=True
