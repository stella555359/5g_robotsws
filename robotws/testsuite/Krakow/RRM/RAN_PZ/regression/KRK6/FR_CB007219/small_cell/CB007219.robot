*** Settings ***

Documentation
...  author:  Krzysztof Michalski, Jakub Bąk, Szymon Mastalski
...  contact: jakub.1.bak@nokia.com, krzysztof.michalski@nokia.com, szymon@mastalski@nokia.com

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/small_cells_specific_keywords.robot


Suite Setup     Suite Setup

*** Test Cases ***

CB007219-AA_TC02_B3_Successful_intra_and_inter_band_DL_CA_setup_with_alternative_bands
    [Setup]       Small Cell Test Setup    scf_prefix_tag=AA_B3
    Check CA with MFBI    pcell_id=281  scell_ids=282,283,284  scell_freqBands=77,77,2  pcell_freqBand=2
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=700 Mbits/sec
    ...    tput_ul_min=40 Mbits/sec
    [Teardown]    Common Test Teardown


CB007219-AA_TC03_B4_Successful_CA_setup_with_alternative_bands_and_extended_band 77_in_USA
    [Setup]       Small Cell Test Setup    scf_prefix_tag=AA_B4
    Check CA with MFBI    pcell_id=281  scell_ids=282,283  scell_freqBands=77,77  pcell_freqBand=66
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=900 Mbits/sec
    ...    tput_ul_min=50 Mbits/sec
    [Teardown]   Common Test Teardown


CB007219-AA_TC04_B5_Successful_CA_setup_with_alternative_bands_and_extended_band 77_in_Canada
    [Setup]       Small Cell Test Setup    scf_prefix_tag=AA_B5
    Check CA with MFBI    pcell_id=281  scell_ids=282,283  scell_freqBands=77,77  pcell_freqBand=66
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=900 Mbits/sec
    ...    tput_ul_min=50 Mbits/sec
    [Teardown]    Common Test Teardown


CB007219-AA_TC05_B8_Successful_CA_setup_with_alternative_bands_ when_one_of_the_SCells_is_configured_with_small_dedicated_BWP
    [Setup]       Small Cell Test Setup    scf_prefix_tag=AA_B8
    Check CA with MFBI    pcell_id=281  scell_ids=282,283,284  scell_freqBands=77,77, 25  pcell_freqBand=25
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=1500 Mbits/sec
    ...    tput_ul_min=40 Mbits/sec
    [Teardown]    Common Test Teardown


