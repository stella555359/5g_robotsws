*** Settings ***
Documentation    All T123 CRT regression TCs shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   5G_RAN   5G_RAN_FDD
...           RAN_5G    RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   PY36   CRT
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB
...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB

Library         taf.ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008935/resources/keywords_8935.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Test Teardown    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

*** Test Cases ***

[1]CB008935-A#B2 Successful UE attachment and traffic SA Mode Thor
    [Documentation]  This user scenario describes setup of FDD cell with 50MHz bandwidth
    ...              followed by system information transmission and UE attach/data transfer in SA mode.
    ...              Cell:               pCell   sCell1  sCell2
    ...              Tech:               FDD     FDD     FDD
    ...              Bandwidths:         50MHz   50MHz   50MHz
    ...              SBands:             n7      n7      n7N
    ...              Global cell ID:     1       18      19
    ...              Phys lay cell ID:   165     166     167
    ...              NR cell ID:         848805889 848805906 848805907
    ...              Attenuator:         3, 4    1, 2    23, 24
    CB008935_AB2_Successful_UE_attachment_and_traffic_SA_Mode_Thor


[1]CB008935-A#B1 Successful UE attachment and traffic NSA Mode Thor
    [Documentation]  This user scenario describes setup of FDD cell with 50MHz bandwidth
    ...              followed by system information transmission and UE attach/data transfer in NSA mode.
    ...              Cell:               pCell   sCell1  sCell2        LTE
    ...              Tech:               FDD     FDD     FDD           FDD
    ...              Bandwidths:         50MHz   50MHz   50MHz         5MHz
    ...              SBands:             n7      n7      n7            b20
    ...              Global cell ID:     1       18      19            12
    ...              Phys lay cell ID:   165     166     167           278
    ...              Cell ID:         848805889 848805906 848805907    10702604
    ...              Attenuator:         3, 4    1, 2    23, 24        11, 12
    CB008935_AB1_Successful_UE_attachment_and_traffic_NSA_Mode_Thor


CB008935_B_IWK_2_3_Interworking_with_CB007552_SA
    [Documentation]    Interworking between CB007552 and CB008435. This test case verifies that the UEs
    ...                attache to the correct BWP profiles on a 50 MHz cell.
    USCB008935_B_IWK_2_3_Interworking_with_CB007552_SA


CB009333_F_2_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_NSA
   [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...              are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...              micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...              Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...              other SIBs (only for SA), paging – NSA Case.
    CB009333_F_2_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_NSA
