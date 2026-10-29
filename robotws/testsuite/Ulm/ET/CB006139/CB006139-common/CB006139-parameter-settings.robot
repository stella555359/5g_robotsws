*** Settings ***
Documentation   This is a keyword file for CB006139, part parameter settings
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${measurement_period_in_min}    5


${text_M55301C20021}    Wideband CQI Histogram when UE reports related to 256QAM table - CQI Level 1
${text_M55301C20035}    Wideband CQI Histogram when UE reports related to 256QAM table - CQI Level 15

${text_M55310C01006}    DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
${text_M55310C03006}    UL RLC data PDU volume received by Low RLC - QoS Group 06

${text_M55118C00053}    Accumulated number of UEs configured with UL TX switching option 1

${text_M55118C00088}    Duration in which 2 DL SCells were configured for a UE in PCell
${text_M55118C00089}    Duration in which 3 DL SCells were configured for a UE in PCell
${text_M55118C00094}    Duration in which 1 UL SCell was configured for a UE in PCell

${text_M55118C06501}    Number of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for SA
${text_M55118C06502}    Number of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for SA

${text_M55118C00031}    Number of SCells added as A4-based SCells during FR1 CA SCell Addition
${text_M55118C00032}    Number of SCells added as A1-based SCells during FR1 CA SCell Addition
${text_M55118C11051}    Number of successful selections for 1 DL SCell
${text_M55118C11058}    Number of successful selections for 1 UL SCell
${text_M55118C11061}    Total number of 1 DL SCells configured
${text_M55118C11068}    Total number of 1 UL SCells configured
${text_M55118C11106}    RRC reconfigurations attempts for stepwise DL SCell addition to SA UE that is in CA
${text_M55118C11107}    Successful RRC reconfiguration attempts for stepwise DL SCell addition to SA UE that is in CA
${text_M55118C11108}    RRC reconfigurations attempts for stepwise UL SCell addition to SA UE that is in CA
${text_M55118C11109}    Successful RRC reconfiguration attempts for stepwise UL SCell addition to SA UE that is in CA

${text_M55138C01503}    Unsuccessful radio admissions for SCell additions in SA mode

${text_M55138C03501}    Number of radio admission requests for the inter-gNB SCell setup
${text_M55138C03502}    Number of successful radio admissions for the inter-gNB SCell additions in SA mode
${text_M55138C03510}    Number of radio admission requests for 1 DL SCell
${text_M55138C03517}    Number of successful radio admissions for 1 DL SCell
${text_M55138C03524}    Number of radio admission requests for 1 UL SCell
${text_M55138C03527}    Number of successful radio admissions for 1 UL SCell
${text_M55138C03530}    Number of unsuccessful radio admissions for 1 DL SCell
${text_M55138C03537}    Number of unsuccessful radio admissions for 1 UL SCell

${text_M55139C01003}    Number of radio admission requests for 1 SCell in DU in SA mode
${text_M55139C01004}    Number of successful radio admissions for 1 SCell addition in DU in SA mode

${text_M55139C05502}    Number of radio admission requests for 1 DL SCell in DU
${text_M55139C05509}    Number of radio admission successes for 1 DL SCell in DU
${text_M55139C05516}    Number of radio admission requests for 1 UL SCell in DU
${text_M55139C05519}    Number of radio admission successes for 1 UL SCell in DU

${text_M55167C00090}    Number of times 1 DL SCell setup failed in gNB-DU due to insufficient UE Capab



*** Keywords ***

Prepare Counters And Expected Values 1st Measurement Period t2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_AA_ET_TC01_B1_ALT1_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55310C01006     >0     NRCELL-1   NLRLC
    Set Test Variable    @{counter_2}             M55310C01006     >0     NRCELL-2   NLRLC
    Set Test Variable    @{counter_3}             M55310C01006     ==0    NRCELL-3   NLRLC
    Set Test Variable    @{counter_4}             M55310C01006     ==0    NRCELL-4   NLRLC
    Set Test Variable    @{counter_5}             M55310C01006     >0     NRCELL-5   NLRLC
    Set Test Variable    @{counter_6}             M55310C01006     >0     NRCELL-6   NLRLC
    Set Test Variable    @{counter_7}             M55301C20021     >0     NRCELL-2   NDLSQ

    Set Test Variable    ${no_counters_to_check}  7


Prepare Counters And Expected Values 2nd Measurement Period t2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_AA_ET_TC01_B1_ALT1_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55310C01006     >0     NRCELL-1   NLRLC
    Set Test Variable    @{counter_2}             M55310C01006     >0     NRCELL-2   NLRLC
    Set Test Variable    @{counter_3}             M55310C01006     ==0    NRCELL-3   NLRLC
    Set Test Variable    @{counter_4}             M55310C01006     ==0    NRCELL-4   NLRLC
    Set Test Variable    @{counter_5}             M55310C01006     >0     NRCELL-5   NLRLC
    Set Test Variable    @{counter_6}             M55310C01006     >0     NRCELL-6   NLRLC
    Set Test Variable    @{counter_7}             M55301C20021     ==0    NRCELL-2   NDLSQ
    Set Test Variable    @{counter_8}             M55301C20035     >0     NRCELL-2   NDLSQ
    Set Test Variable    ${no_counters_to_check}  8


Prepare Counters And Expected Values 1st Measurement Period t3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_AA_ET_TC14_B12_Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55310C01006     >0     NRCELL-1   NLRLC
    Set Test Variable    @{counter_2}             M55310C01006     >0     NRCELL-2   NLRLC
    Set Test Variable    @{counter_3}             M55310C01006     >0     NRCELL-3   NLRLC
    Set Test Variable    @{counter_4}             M55310C01006     >0     NRCELL-4   NLRLC
    Set Test Variable    @{counter_5}             M55310C01006     >0     NRCELL-5   NLRLC
    Set Test Variable    @{counter_6}             M55310C01006     >0     NRCELL-6   NLRLC
    Set Test Variable    @{counter_7}             M55310C03006     >0     NRCELL-1   NLRLC
    Set Test Variable    @{counter_8}             M55310C03006     ==0    NRCELL-5   NLRLC
    Set Test Variable    @{counter_9}             M55138C01503     ==1    NRCELL-1   RSACU
    Set Test Variable    @{counter_10}            M55118C11051     ==2    NRCELL-1   NCAC
    Set Test Variable    @{counter_11}            M55118C11058     ==2    NRCELL-1   NCAC
    Set Test Variable    @{counter_12}            M55118C11061     ==2    NRCELL-1   NCAC
    Set Test Variable    @{counter_13}            M55118C11068     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_14}            M55118C11106     ==2    NRCELL-1   NCAC
    Set Test Variable    @{counter_15}            M55118C11107     ==2    NRCELL-1   NCAC
    Set Test Variable    @{counter_16}            M55118C11108     ==0    NRCELL-1   NCAC
    Set Test Variable    @{counter_17}            M55118C11109     ==0    NRCELL-1   NCAC
    Set Test Variable    @{counter_18}            M55138C03510     ==3    NRCELL-1   RSACU
    Set Test Variable    @{counter_19}            M55138C03517     ==2    NRCELL-1   RSACU
    Set Test Variable    @{counter_20}            M55138C03524     ==5    NRCELL-1   RSACU
    Set Test Variable    @{counter_21}            M55138C03527     ==3    NRCELL-1   RSACU
    Set Test Variable    @{counter_22}            M55138C03530     ==2    NRCELL-1   RSACU
    Set Test Variable    @{counter_23}            M55138C03537     ==2    NRCELL-1   RSACU
    Set Test Variable    @{counter_24}            M55139C01003     ==2    NRCELL-1   RSADU
    Set Test Variable    @{counter_25}            M55139C01004     ==2    NRCELL-1   RSADU
    Set Test Variable    @{counter_26}            M55139C05502     ==2    NRCELL-1   RSADU
    Set Test Variable    @{counter_27}            M55139C05509     ==2    NRCELL-1   RSADU
    Set Test Variable    @{counter_28}            M55139C05516     ==2    NRCELL-1   RSADU
    Set Test Variable    @{counter_29}            M55139C05519     ==1    NRCELL-1   RSADU
    Set Test Variable    ${no_counters_to_check}  29


Prepare Counters And Expected Values 2nd Measurement Period t3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_AA_ET_TC14_B12_Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55310C01006     >0     NRCELL-1   NLRLC
    Set Test Variable    @{counter_2}             M55310C01006     >0     NRCELL-2   NLRLC
    Set Test Variable    @{counter_3}             M55310C01006     >0     NRCELL-3   NLRLC
    Set Test Variable    @{counter_4}             M55310C01006     ==0    NRCELL-4   NLRLC
    Set Test Variable    @{counter_5}             M55310C01006     >0     NRCELL-5   NLRLC
    Set Test Variable    @{counter_6}             M55310C01006     ==0    NRCELL-6   NLRLC
    Set Test Variable    @{counter_7}             M55310C03006     >0     NRCELL-1   NLRLC
    Set Test Variable    @{counter_8}             M55310C03006     >0     NRCELL-5   NLRLC
    Set Test Variable    @{counter_9}             M55118C11051     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_10}            M55118C11058     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_11}            M55118C11061     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_12}            M55118C11068     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_13}            M55118C11106     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_14}            M55118C11107     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_15}            M55118C11108     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_16}            M55118C11109     ==1    NRCELL-1   NCAC
    Set Test Variable    @{counter_17}            M55138C03510     ==1    NRCELL-1   RSACU
    Set Test Variable    @{counter_18}            M55138C03517     ==1    NRCELL-1   RSACU
    Set Test Variable    @{counter_19}            M55138C03524     ==1    NRCELL-1   RSACU
    Set Test Variable    @{counter_20}            M55138C03527     ==1    NRCELL-1   RSACU
    Set Test Variable    @{counter_21}            M55139C01003     ==1    NRCELL-1   RSADU
    Set Test Variable    @{counter_22}            M55139C01004     ==1    NRCELL-1   RSADU
    Set Test Variable    @{counter_23}            M55139C05502     ==1    NRCELL-1   RSADU
    Set Test Variable    @{counter_24}            M55139C05509     ==1    NRCELL-1   RSADU
    Set Test Variable    @{counter_25}            M55139C05516     ==1    NRCELL-1   RSADU
    Set Test Variable    @{counter_26}            M55139C05519     ==1    NRCELL-1   RSADU
    Set Test Variable    ${no_counters_to_check}  26


Prepare Counters And Expected Values AA B7
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_AA_ET_TC06_B7_SCell_removed_from_SCell_Failed_to_Setup_List_after_SCell_Release
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55139C01003     ==2     NRCELL-1   RSADU
    Set Test Variable    @{counter_2}             M55139C01004     ==1     NRCELL-1   RSADU
    Set Test Variable    @{counter_3}             M55139C05502     ==2     NRCELL-1   RSADU
    Set Test Variable    @{counter_4}             M55139C05509     ==1     NRCELL-1   RSADU
    Set Test Variable    @{counter_5}             M55167C00090     ==1     NRCELL-1   NCADC
    Set Test Variable    @{counter_6}             M55118C11106     ==1     NRCELL-1   NCAC
    Set Test Variable    @{counter_7}             M55118C11107     ==1     NRCELL-1   NCAC
    Set Test Variable    ${no_counters_to_check}  7


Prepare Counters And Expected Values DA B1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_DA_ET_TC01_B1_StepWise_SCell_Addition_with_DL_maximum_MIMO_layer_change_in_existing_SCell
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55118C11106     ==2     NRCELL-1   NCAC
    Set Test Variable    @{counter_2}             M55118C11107     ==2     NRCELL-1   NCAC
    Set Test Variable    ${no_counters_to_check}  2


Prepare Counters And Expected Values DA B3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_DA_ET_TC03_B3_StepWise_SCell_Addition_with_CSI_RS_downgrade_in_existing_SCell
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55118C11106     ==1     NRCELL-6   NCAC
    Set Test Variable    @{counter_2}             M55118C11107     ==1     NRCELL-6   NCAC
    Set Test Variable    ${no_counters_to_check}  2


Prepare Counters And Expected Values DA B12
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_DA_ET_TC09_B12_StepWise_SCell_Addition_DL_UL_SCell_with_UL_Tx_Switching_Option_1
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55118C11106     ==1     NRCELL-1   NCAC
    Set Test Variable    @{counter_2}             M55118C11107     ==1     NRCELL-1   NCAC
    Set Test Variable    @{counter_3}             M55118C11108     ==1     NRCELL-1   NCAC
    Set Test Variable    @{counter_4}             M55118C11109     ==1     NRCELL-1   NCAC
    Set Test Variable    ${no_counters_to_check}  4


Prepare Counters And Expected Values For gNB1 1st And 2nd Measurement Period EB
    [Documentation]    [PRIVATE]    set expected values for
    ...                             Inter-gNB Scell addition with CSI-RS downgrade and MIMO changes
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55118C11051     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_2}             M55118C11061     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_3}             M55118C11106     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_4}             M55118C11107     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_5}             M55138C03510     ==2    NRCELL-4   RSACU
    Set Test Variable    @{counter_6}             M55138C03517     ==2    NRCELL-4   RSACU
    Set Test Variable    @{counter_7}             M55139C01003     ==2    NRCELL-4   RSADU
    Set Test Variable    @{counter_8}             M55139C01004     ==2    NRCELL-4   RSADU
    Set Test Variable    @{counter_9}             M55139C05502     ==2    NRCELL-4   RSADU
    Set Test Variable    @{counter_10}            M55139C05509     ==2    NRCELL-4   RSADU

    Set Test Variable    ${no_counters_to_check}  10


Prepare Counters And Expected Values For gNB2 1st Measurement Period EB
    [Documentation]    [PRIVATE]    set expected values for
    ...                             Inter-gNB Scell addition with CSI-RS downgrade and MIMO changes
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55138C03501     ==2    NRCELL-5   RSACU
    Set Test Variable    @{counter_2}             M55138C03502     ==2    NRCELL-5   RSACU
    Set Test Variable    @{counter_3}             M55138C03501     ==0    NRCELL-6   RSACU
    Set Test Variable    @{counter_4}             M55138C03502     ==0    NRCELL-6   RSACU
    Set Test Variable    @{counter_5}             M55138C03501     ==1    NRCELL-7   RSACU
    Set Test Variable    @{counter_6}             M55138C03502     ==1    NRCELL-7   RSACU
    Set Test Variable    @{counter_7}             M55138C03501     ==2    NRCELL-8   RSACU
    Set Test Variable    @{counter_8}             M55138C03502     ==2    NRCELL-8   RSACU

    Set Test Variable    ${no_counters_to_check}  8


Prepare Counters And Expected Values For gNB2 2nd Measurement Period EB
    [Documentation]    [PRIVATE]    set expected values for
    ...                             Inter-gNB Scell addition with CSI-RS downgrade and MIMO changes
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55138C03501     ==1    NRCELL-5   RSACU
    Set Test Variable    @{counter_2}             M55138C03502     ==1    NRCELL-5   RSACU
    Set Test Variable    @{counter_3}             M55138C03501     ==1    NRCELL-6   RSACU
    Set Test Variable    @{counter_4}             M55138C03502     ==1    NRCELL-6   RSACU
    Set Test Variable    @{counter_5}             M55138C03501     ==2    NRCELL-7   RSACU
    Set Test Variable    @{counter_6}             M55138C03502     ==1    NRCELL-7   RSACU
    Set Test Variable    @{counter_7}             M55138C03501     ==1    NRCELL-8   RSACU
    Set Test Variable    @{counter_8}             M55138C03502     ==1    NRCELL-8   RSACU

    Set Test Variable    ${no_counters_to_check}  8


Set Expected Throughput Values 2nd Measurement Period EB
    [Documentation]    [PRIVATE]    set expected values for
    ...                             Inter-gNB Scell addition with CSI-RS downgrade and MIMO changes
    ...       :Autor: Sylvia Schneider

    Set Test Variable    ${expected_cell0_throughput_run3}    450
    Set Test Variable    ${expected_cell0_throughput_run4}    230
    Set Test Variable    ${expected_cell1_throughput_run3}    100
    Set Test Variable    ${expected_cell1_throughput_run4}    200
    Set Test Variable    ${expected_4cell_throughput_run3}    1050
    Set Test Variable    ${expected_4cell_throughput_run4}    870


Prepare Counters And Expected Values 1st Measurement Period CG
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_CG_ET_TC10_InterGnb_Measurement_Based_Stepwise_SCell_Addition_Robustness_Test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55118C11106     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_2}             M55118C11107     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_3}             M55118C00031     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_4}             M55118C00032     ==2    NRCELL-4   NCAC
    Set Test Variable    @{counter_5}             M55118C06501     ==1    NRCELL-4   NCAC
    Set Test Variable    @{counter_6}             M55118C06502     ==1    NRCELL-4   NCAC

    Set Test Variable    ${no_counters_to_check}  6


Prepare Counters And Expected Values 2nd Measurement Period CG
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB006139_CG_ET_TC10_InterGnb_Measurement_Based_Stepwise_SCell_Addition_Robustness_Test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{counter_1}             M55118C11106     ==1    NRCELL-4   NCAC
    Set Test Variable    @{counter_2}             M55118C11107     ==1    NRCELL-4   NCAC
    Set Test Variable    @{counter_3}             M55118C00031     ==1    NRCELL-4   NCAC
    Set Test Variable    @{counter_4}             M55118C00032     ==0    NRCELL-4   NCAC
    Set Test Variable    @{counter_5}             M55118C06501     ==1    NRCELL-4   NCAC
    Set Test Variable    @{counter_6}             M55118C06502     ==1    NRCELL-4   NCAC

    Set Test Variable    ${no_counters_to_check}  6
