*** Settings ***
Documentation
...  author:  Marcin Flis, Monika Mysliwiec
...  contact: marcin.1.flis@nokia.com, monika.banas@nokia.com
...  description: Test Cases for testline with ABIP and FR2

Resource    ./resources/suite_specific_keywords.robot

*** Test Cases ***
[1][1.0] CB010496_W_09_NSA_DL_peak_Tput_FR2_8CCDL_4CCUL_prach_175
    [Setup]   Common Test Setup for different configs
    ...             scfc_file=config_1a.xml
    Log Action To Console                                    Waiting for BTS after commisiong KW
    Sleep                                                    120s
    Require UE                                               QC_SDX75    REAL_ANDROID_UE
    Require UE                                               S21         SAMSUNG_S21
    Verify L3 call TCP DL                                    ue_type_1=QC_SDX75
    ...                                                      ue_type_2=S21
    [Teardown]    Common Postconditions

[1][1.0] CB010496_W_10_NSA_UL_peak_Tput_FR2_8CCDL_4CCUL_prach_175
    [Setup]   Common Test Setup for different configs
    ...             scfc_file=config_1a.xml
    Log Action To Console                                    Waiting for BTS after commisiong KW
    Sleep                                                    120s
    Require UE                                               QC_SDX75    REAL_ANDROID_UE
    Require UE                                               S21         SAMSUNG_S21
    Verify L3 call TCP UL                                    ue_type_1=QC_SDX75
    ...                                                      ue_type_2=S21
    [Teardown]    Common Postconditions

[1][1.0] CB010496_B_06_Other_subset_configurations_supported_4_sectors
    [Setup]   Common Test Setup for different configs
    ...             scfc_file=config_2c.xml
    Log Action To Console                                    Perform configuration parameters on gNB for config 3
    Perform Full Commissioning On Classical Gnb              config_3.xml
    Log Action To Console                                    Perform configuration parameters on gNB for config 4
    Perform Full Commissioning On Classical Gnb              config_4.xml
    [Teardown]    Common Postconditions

[1][1.0] CB010496_D_08_CSM_switch_between_CB010496_A_and_CB010496_B
    [Setup]   Common Test Setup for different configs
    ...             scfc_file=config_2c.xml
    Log Action To Console                                    Perform configuration parameters on gNB for config 1
    Perform Full Commissioning On Classical Gnb              config_1.xml
    Log Action To Console                                    ------Removing cells for 2nd sector------
    Remove Cell From Configuration                           55
    ...                                                      cell_group_id=0
    Remove Cell From Configuration                           56
    ...                                                      cell_group_id=0
    Remove Cell From Configuration                           57
    ...                                                      cell_group_id=0
    Remove Cell From Configuration                           58
    ...                                                      cell_group_id=0
    Log Action To Console                                    ------Removing cells for 4th sector------
    Remove Cell From Configuration                           65
    ...                                                      cell_group_id=1
    Remove Cell From Configuration                           66
    ...                                                      cell_group_id=1
    Remove Cell From Configuration                           67
    ...                                                      cell_group_id=1
    Remove Cell From Configuration                           68
    ...                                                      cell_group_id=1
    Log Action To Console                                    Perform configuration parameters on gNB for config 2
    Perform Full Commissioning On Classical Gnb              config_2.xml
    [Teardown]    Common Postconditions
