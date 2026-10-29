*** Settings ***
Documentation
...  author:  Jakub Bak, Szymon Mastalski, Krzysztof Michalski
...  contact: jakub.1.bak@nokia.com, szymon.mastalski@nokia.com, krzysztof.michalski@nokia.com

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/macro_cell_specific_keywords.robot

Suite Setup     Macro Cell Suite Setup

*** Test Cases ***

CB007219-AA#B10_Successful_DL_CA_setup_with_alternative_bands_when_there_are_candidate_ext-SCells
    [Setup]       Test Setup With Ext-gNB Preparation
    Check CA with MFBI   pcell_id=941  scell_ids=971,972  scell_freqBands=77,77  pcell_freqBand=2
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=1200 Mbits/sec
    ...    tput_ul_min=40 Mbits/sec
    [Teardown]    Common Test Teardown

CB007219-AA#B11_Successful_DL_CA_setup_with_alternative_bands_when_there_are_candidate_ext-SCells_in_the_extended_band_77_in_USA
    [Setup]       Test Setup With n77 USA Config Preparation
    Check CA with MFBI    pcell_id=941  scell_ids=971,972  scell_freqBands=77,77  pcell_freqBand=2
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=1200 Mbits/sec
    ...    tput_ul_min=40 Mbits/sec
    [Teardown]    Test Teardown With n77 USA Flag Clean

CB007219-AA#B12_Successful_DL_CA_setup_with_alternative_bands_when_there_are_candidate_ext-SCells_in_the_extended_band_77_in_Canada
    [Setup]       Test Setup With n77 Canada Config Preparation
    Check CA with MFBI    pcell_id=941  scell_ids=971,972  scell_freqBands=77,77  pcell_freqBand=2
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=1150 Mbits/sec
    ...    tput_ul_min=40 Mbits/sec
    [Teardown]    Test Teardown With n77 Canada Flag Clean

CB007219-AA#B12.1_Unsuccessful_DL_CA_setup_with_alternative_bands_when_there_are_candidate_ext-SCells_in_the_extended_band_77_in_Canada
    [Setup]       Test Setup With n77-ext-2 band disable
    Check CA with MFBI    pcell_id=941  scell_ids=942,943  scell_freqBands=2,66  pcell_freqBand=2
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=1200 Mbits/sec
    ...    tput_ul_min=40 Mbits/sec
    [Teardown]   Test Teardown With n77-ext-2 band enable

CB007219-AA#B27_Successful_DL_CA_setup_with_ext-SCell_in_native_band_as_ext-gNB_does_not_support_FR1_CA_with_MFBI
    [Setup]       Test Setup Without CA MFBI
    Check CA with MFBI   pcell_id=944  scell_ids=973  scell_freqBands=78  pcell_freqBand=78
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=400 Mbits/sec
    ...    tput_ul_min=17 Mbits/sec
    [Teardown]    Test Teardown Without CA MFBI

