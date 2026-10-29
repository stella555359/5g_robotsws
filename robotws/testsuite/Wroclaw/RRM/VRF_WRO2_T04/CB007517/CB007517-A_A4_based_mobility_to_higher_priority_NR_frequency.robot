*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Resource   ./resources/keywords_7517.robot


*** Keywords ***
CB007517-A_NSA_multiple_intra_MeNB_HO_LTE
    [Documentation]   This scenario describes gNB and eNB behaviour during and after SgNB Addition procedure and intra MeNB HO procedure.

    Choose Traffic Direction Randomly And Set Value Of Expected Tput
    Log Info On Console   [A4 Measurement parameters setting in progress...]
    Configure A4 Measurement Parameters
    Set Test Variable   ${ue_alias}   UE_1
    Attach UE And Verify A4 Measurements After Attach   ue_alias=${ue_alias}
    Start Traffic In Chosen Direction   ue_alias=${ue_alias}

    Verify Average Tput in Given Period   expected_tput=${tput}

    Log Info On Console   [Attenuate active LTE cell, PCI=${lte_pci} and check LTE HO]
    Set Test Variable    ${log_index}  _A4_meas
    Start Tracing On SMOD   smod slave=False
    Attenuate Active LTE Cell   pci=${lte_pci}
    Check New LTE Cell

    Log Info On Console   [Verifying A4 Measurements after LTE HO in progess...]
    Wait For All A4Measurements Messages
    ${log_path}   Stop Tracing And Download Logs From SMOD
    Run Keyword And Continue On Failure   Verify A4 Meas Max Number
    ...   pcap_file=${log_path}  no_cells=${num_cells}  a4_meas_max_number=${a4MeasMaxNumber}

    Verify Average Tput in Given Period   expected_tput=${tput}

    [Teardown]   Run Keywords
    ...   Stop Data Transfer   DT_DATA         AND
    ...   Detach Ue   ${ue_alias}              AND
    ...   Clear NAA Storage   UE_1             AND
    ...   Clear Attenuation For LTE Cells      AND
    ...   Stop Tracing On SMOD
