*** Settings ***

Documentation
...    author: VRF ULM T01 01 and VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 1' and 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: PM counters for CB009267-A,-B and -D

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***

@{D_EI_B1_PM_PSCELL}
...    M55114C01539  >=  50   The number of NSA UEs supporting max 1CC DL
...    M55114C01539  <=  55   The number of NSA UEs supporting max 1CC DL
...    M55114C01540  >=  230  The number of NSA UEs supporting max 2CC DL
...    M55114C01540  <=  235  The number of NSA UEs supporting max 2CC DL
...    M55114C01541  ==  0    The number of NSA UEs supporting max 3CC DL
...    M55114C01542  ==  0    The number of NSA UEs supporting max 4CC DL
...    M55114C01543  ==  0    The number of NSA UEs supporting max 5CC DL
...    M55114C01544  ==  0    The number of NSA UEs supporting max 6CC DL
...    M55114C01545  ==  0    The number of NSA UEs supporting max 7CC DL
...    M55114C01546  ==  0    The number of NSA UEs supporting max 8CC DL
...    M55114C01547  >=  280  The number of NSA UEs supporting max 1CC UL
...    M55114C01547  <=  290  The number of NSA UEs supporting max 1CC UL
...    M55114C01548  ==  0    The number of NSA UEs supporting max 2CC UL
...    M55114C01549  ==  0    The number of NSA UEs supporting max 3CC UL
...    M55114C01550  ==  0    The number of NSA UEs supporting max 4CC UL
...    M55114C01551  ==  1    The max number of NSA UEs supporting max 1CC DL
...    M55114C01552  ==  1    The max number of NSA UEs supporting max 2CC DL
...    M55114C01553  ==  0    The max number of NSA UEs supporting max 3CC DL
...    M55114C01554  ==  0    The max number of NSA UEs supporting max 4CC DL
...    M55114C01555  ==  0    The max number of NSA UEs supporting max 5CC DL
...    M55114C01556  ==  0    The max number of NSA UEs supporting max 6CC DL
...    M55114C01557  ==  0    The max number of NSA UEs supporting max 7CC DL
...    M55114C01558  ==  0    The max number of NSA UEs supporting max 8CC DL
...    M55114C01559  ==  2    The max number of NSA UEs supporting max 1CC UL
...    M55114C01560  ==  0    The max number of NSA UEs supporting max 2CC UL
...    M55114C01561  ==  0    The max number of NSA UEs supporting max 3CC UL
...    M55114C01562  ==  0    The max number of NSA UEs supporting max 4CC UL
...    M55114C01587  >=  298  The number of samples for counting the UEs supporting different CCs
...    M55114C01587  <=  300  The number of samples for counting the UEs supporting different CCs

@{D_EI_B2_1_PM_PCELL}
...    M55118C00087  ==   0     The duration when 1 DL SCell was configured to a UE in PCell
...    M55118C00088  ==   0     The duration when 2 DL SCell was configured to a UE in PCell
...    M55118C00089  ==   0     The duration when 3 DL SCell was configured to a UE in PCell
...    M55118C00090  >=   50    The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00090  <=   55    The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00091  ==   0     The duration when 5 DL SCell was configured to a UE in PCell
...    M55118C00092  ==   0     The duration when 6 DL SCell was configured to a UE in PCell
...    M55118C00093  ==   0     The duration when 7 DL SCell was configured to a UE in PCell
...    M55118C00094  >=   50    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00094  <=   55    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00095  ==   0     The duration when 2 UL SCell was configured to a UE in PCell
...    M55118C00096  ==   0     The duration when 3 UL SCell was configured to a UE in PCell

@{D_EI_B2_2_PM_PCELL}
...    M55118C00087  >=   70    The duration when 1 DL SCell was configured to a UE in PCell
...    M55118C00087  <=   75    The duration when 1 DL SCell was configured to a UE in PCell
...    M55118C00088  ==   0     The duration when 2 DL SCell was configured to a UE in PCell
...    M55118C00089  ==   0     The duration when 3 DL SCell was configured to a UE in PCell
...    M55118C00090  ==   0     The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00091  ==   0     The duration when 5 DL SCell was configured to a UE in PCell
...    M55118C00092  ==   0     The duration when 6 DL SCell was configured to a UE in PCell
...    M55118C00093  ==   0     The duration when 7 DL SCell was configured to a UE in PCell
...    M55118C00094  >=   70    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00094  <=   75    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00095  ==   0     The duration when 2 UL SCell was configured to a UE in PCell
...    M55118C00096  ==   0     The duration when 3 UL SCell was configured to a UE in PCell

@{D_EI_B2_3_PM_PCELL}
...    M55118C00087  >=   25    The duration when 1 DL SCell was configured to a UE in PCell
...    M55118C00087  <=   30    The duration when 1 DL SCell was configured to a UE in PCell
...    M55118C00088  >=   20    The duration when 2 DL SCell was configured to a UE in PCell
...    M55118C00088  <=   25    The duration when 2 DL SCell was configured to a UE in PCell
...    M55118C00089  >=   15    The duration when 3 DL SCell was configured to a UE in PCell
...    M55118C00089  <=   20    The duration when 3 DL SCell was configured to a UE in PCell
...    M55118C00090  >=   10    The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00090  <=   15    The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00091  ==   0     The duration when 5 DL SCell was configured to a UE in PCell
...    M55118C00092  ==   0     The duration when 6 DL SCell was configured to a UE in PCell
...    M55118C00093  ==   0     The duration when 7 DL SCell was configured to a UE in PCell
...    M55118C00094  >=   45    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00094  <=   55    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00095  ==   0     The duration when 2 UL SCell was configured to a UE in PCell
...    M55118C00096  ==   0     The duration when 3 UL SCell was configured to a UE in PCell

@{D_EI_B2_4_PM_PCELL}
...    M55118C00087  ==   0     The duration when 1 DL SCell was configured to a UE in PCell
...    M55118C00088  ==   0     The duration when 2 DL SCell was configured to a UE in PCell
...    M55118C00089  ==   0     The duration when 3 DL SCell was configured to a UE in PCell
...    M55118C00090  >=   50    The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00090  <=   55    The duration when 4 DL SCell was configured to a UE in PCell
...    M55118C00091  ==   0     The duration when 5 DL SCell was configured to a UE in PCell
...    M55118C00092  ==   0     The duration when 6 DL SCell was configured to a UE in PCell
...    M55118C00093  ==   0     The duration when 7 DL SCell was configured to a UE in PCell
...    M55118C00094  >=   50    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00094  <=   55    The duration when 1 UL SCell was configured to a UE in PCell
...    M55118C00095  ==   0     The duration when 2 UL SCell was configured to a UE in PCell
...    M55118C00096  ==   0     The duration when 3 UL SCell was configured to a UE in PCell

@{D_EI_B3_1_PM_PCELL}
...    M55114C01563  >=   70     The number of SA UEs supporting max 1CC DL
...    M55114C01563  <=   75     The number of SA UEs supporting max 1CC DL
...    M55114C01564  >=   170    The number of SA UEs supporting max 2CC DL
...    M55114C01564  <=   175    The number of SA UEs supporting max 2CC DL
...    M55114C01565  ==   0      The number of SA UEs supporting max 3CC DL
...    M55114C01566  ==   0      The number of SA UEs supporting max 4CC DL
...    M55114C01567  >=   70     The number of SA UEs supporting max 5CC DL
...    M55114C01567  <=   80     The number of SA UEs supporting max 5CC DL
...    M55114C01568  ==   0      The number of SA UEs supporting max 6CC DL
...    M55114C01569  ==   0      The number of SA UEs supporting max 7CC DL
...    M55114C01570  ==   0      The number of SA UEs supporting max 8CC DL
...    M55114C01571  >=   240    The number of SA UEs supporting max 1CC UL
...    M55114C01571  <=   250    The number of SA UEs supporting max 1CC UL
...    M55114C01572  >=   70     The number of SA UEs supporting max 2CC UL
...    M55114C01572  <=   80     The number of SA UEs supporting max 2CC UL
...    M55114C01573  ==   0      The number of SA UEs supporting max 3CC UL
...    M55114C01574  ==   0      The number of SA UEs supporting max 4CC UL
...    M55114C01575  ==   1      The max number of SA UEs supporting max 1CC DL
...    M55114C01576  ==   1      The max number of SA UEs supporting max 2CC DL
...    M55114C01577  ==   0      The max number of SA UEs supporting max 3CC DL
...    M55114C01578  ==   0      The max number of SA UEs supporting max 4CC DL
...    M55114C01579  ==   2      The max number of SA UEs supporting max 5CC DL
...    M55114C01580  ==   0      The max number of SA UEs supporting max 6CC DL
...    M55114C01581  ==   0      The max number of SA UEs supporting max 7CC DL
...    M55114C01582  ==   0      The max number of SA UEs supporting max 8CC DL
...    M55114C01583  ==   2      The max number of SA UEs supporting max 1CC UL
...    M55114C01584  ==   2      The max number of SA UEs supporting max 2CC UL
...    M55114C01585  ==   0      The max number of SA UEs supporting max 3CC UL
...    M55114C01586  ==   0      The max number of SA UEs supporting max 4CC UL
...    M55114C01587  >=  298     The number of samples for counting the UEs supporting different CCs
...    M55114C01587  <=  300     The number of samples for counting the UEs supporting different CCs

@{D_EI_B3_2_PM_PCELL}
...    M55114C01563  ==   0      The number of SA UEs supporting max 1CC DL
...    M55114C01564  ==   0      The number of SA UEs supporting max 2CC DL
...    M55114C01565  ==   0      The number of SA UEs supporting max 3CC DL
...    M55114C01566  ==   0      The number of SA UEs supporting max 4CC DL
...    M55114C01567  ==   0      The number of SA UEs supporting max 5CC DL
...    M55114C01568  ==   0      The number of SA UEs supporting max 6CC DL
...    M55114C01569  ==   0      The number of SA UEs supporting max 7CC DL
...    M55114C01570  ==   0      The number of SA UEs supporting max 8CC DL
...    M55114C01571  ==   0      The number of SA UEs supporting max 1CC UL
...    M55114C01572  ==   0      The number of SA UEs supporting max 2CC UL
...    M55114C01573  ==   0      The number of SA UEs supporting max 3CC UL
...    M55114C01574  ==   0      The number of SA UEs supporting max 4CC UL
...    M55114C01575  ==   0      The max number of SA UEs supporting max 1CC DL
...    M55114C01576  ==   0      The max number of SA UEs supporting max 2CC DL
...    M55114C01577  ==   0      The max number of SA UEs supporting max 3CC DL
...    M55114C01578  ==   0      The max number of SA UEs supporting max 4CC DL
...    M55114C01579  ==   0      The max number of SA UEs supporting max 5CC DL
...    M55114C01580  ==   0      The max number of SA UEs supporting max 6CC DL
...    M55114C01581  ==   0      The max number of SA UEs supporting max 7CC DL
...    M55114C01582  ==   0      The max number of SA UEs supporting max 8CC DL
...    M55114C01583  ==   0      The max number of SA UEs supporting max 1CC UL
...    M55114C01584  ==   0      The max number of SA UEs supporting max 2CC UL
...    M55114C01585  ==   0      The max number of SA UEs supporting max 3CC UL
...    M55114C01586  ==   0      The max number of SA UEs supporting max 4CC UL
...    M55114C01587  ==   0      The number of samples for counting the UEs supporting different CCs

@{D_EI_B3_3_PM_PCELL}
...    M55114C01563  ==   0      The number of SA UEs supporting max 1CC DL
...    M55114C01564  ==   0      The number of SA UEs supporting max 2CC DL
...    M55114C01565  ==   0      The number of SA UEs supporting max 3CC DL
...    M55114C01566  ==   0      The number of SA UEs supporting max 4CC DL
...    M55114C01567  >=   420    The number of SA UEs supporting max 5CC DL
...    M55114C01567  <=   450    The number of SA UEs supporting max 5CC DL
...    M55114C01568  ==   0      The number of SA UEs supporting max 6CC DL
...    M55114C01569  ==   0      The number of SA UEs supporting max 7CC DL
...    M55114C01570  ==   0      The number of SA UEs supporting max 8CC DL
...    M55114C01571  ==   0      The number of SA UEs supporting max 1CC UL
...    M55114C01572  >=   420    The number of SA UEs supporting max 2CC UL
...    M55114C01572  <=   450    The number of SA UEs supporting max 2CC UL
...    M55114C01573  ==   0      The number of SA UEs supporting max 3CC UL
...    M55114C01574  ==   0      The number of SA UEs supporting max 4CC UL
...    M55114C01575  ==   0      The max number of SA UEs supporting max 1CC DL
...    M55114C01576  ==   0      The max number of SA UEs supporting max 2CC DL
...    M55114C01577  ==   0      The max number of SA UEs supporting max 3CC DL
...    M55114C01578  ==   0      The max number of SA UEs supporting max 4CC DL
...    M55114C01579  ==   6      The max number of SA UEs supporting max 5CC DL
...    M55114C01580  ==   0      The max number of SA UEs supporting max 6CC DL
...    M55114C01581  ==   0      The max number of SA UEs supporting max 7CC DL
...    M55114C01582  ==   0      The max number of SA UEs supporting max 8CC DL
...    M55114C01583  ==   0      The max number of SA UEs supporting max 1CC UL
...    M55114C01584  ==   6      The max number of SA UEs supporting max 2CC UL
...    M55114C01585  ==   0      The max number of SA UEs supporting max 3CC UL
...    M55114C01586  ==   0      The max number of SA UEs supporting max 4CC UL
...    M55114C01587  >=  298     The number of samples for counting the UEs supporting different CCs
...    M55114C01587  <=  300     The number of samples for counting the UEs supporting different CCs

@{A_EI_B101_1_PM_PCELL}
...    M55138C03510  ==   1      Number of radio admission requests for 1 DL SCell
...    M55138C03512  ==   1      Number of radio admission requests for 3 DL SCell
...    M55138C03524  ==   2      Number of radio admission requests for 1 UL SCell
...    M55138C03517  ==   2      Number of successful radio admissions for 1 DL SCell
...    M55138C03527  ==   2      Number of successful radio admissions for 1 UL SCell
...    M55118C11051  ==   2      Number of successful selections for 1 DL SCell
...    M55118C11058  ==   2      Number of successful selections for 1 UL SCell
...    M55139C05502  ==   2      Number of radio admission requests for 1 DL SCell in DU
...    M55139C05516  ==   2      Number of radio admission requests for 1 UL SCell in DU
...    M55139C05509  ==   2      Number of radio admission successes for 1 DL SCell in DU
...    M55139C05519  ==   2      Number of radio admission successes for 1 UL SCell in DU
...    M55118C11061  ==   2      Total number of 1 DL SCells configured
...    M55118C11068  ==   2      Total number of 1 UL SCells configured
...    M55118C11095  ==   1      Number of UL full SCell release attempts on PCell for SA
...    M55118C11096  ==   1      Number of successful UL full SCell release attempts on PCell for SA

@{A_EI_B101_2_PM_PCELL}
...    M55138C03510  ==   2      Number of radio admission requests for 1 DL SCell
...    M55138C03512  ==   1      Number of radio admission requests for 3 DL SCell
...    M55138C03524  ==   3      Number of radio admission requests for 1 UL SCell
...    M55138C03517  ==   3      Number of successful radio admissions for 1 DL SCell
...    M55138C03527  ==   3      Number of successful radio admissions for 1 UL SCell
...    M55118C11051  ==   3      Number of successful selections for 1 DL SCell
...    M55118C11058  ==   3      Number of successful selections for 1 UL SCell
...    M55139C05502  ==   3      Number of radio admission requests for 1 DL SCell in DU
...    M55139C05516  ==   3      Number of radio admission requests for 1 UL SCell in DU
...    M55139C05509  ==   3      Number of radio admission successes for 1 DL SCell in DU
...    M55139C05519  ==   3      Number of radio admission successes for 1 UL SCell in DU
...    M55118C11061  ==   3      Total number of 1 DL SCells configured
...    M55118C11068  ==   3      Total number of 1 UL SCells configured
...    M55118C11095  ==   1      Number of UL full SCell release attempts on PCell for SA
...    M55118C11096  ==   1      Number of successful UL full SCell release attempts on PCell for SA

@{A_EI_B201-1_PM_PCELL}
...    M55118C11079  ==   2      Number of DL SCells to be released on PCell due to UE overheating for SA
...    M55118C11080  ==   2      Number of DL SCells released on PCell due to UE overheating for SA
...    M55118C11081  ==   1      Number of UL SCells to be released on PCell due to UE overheating for SA
...    M55118C11082  ==   1      Number of UL SCells released on PCell due to UE overheating for SA

@{A_EI_B201-2_1_PM_PCELL}
...    M55118C11087  ==   2      Number of DL SCells to be released on PCell due to incompatible DRB for SA
...    M55118C11088  ==   2      Number of DL SCells released on PCell due to incompatible DRB for SA
...    M55118C11089  ==   1      Number of UL SCells to be released on PCell due to incompatible DRB for SA
...    M55118C11090  ==   1      Number of UL SCells released on PCell due to incompatible DRB for SA

@{A_EI_B201-2_2_PM_PCELL}
...    M55118C11091  ==   2      Number of DL SCells to be released on PCell due to releasing the last CA-eligible DRB for SA
...    M55118C11092  ==   2      Number of DL SCells released on PCell due to releasing the last CA-eligible DRB for SA
...    M55118C11093  ==   1      Number of UL SCells to be released on PCell due to releasing the last CA-eligible DRB for SA
...    M55118C11094  ==   1      Number of UL SCells released on PCell due to releasing the last CA-eligible DRB for SA

@{A_EI_B201-3_PM_PCELL}
...    M55118C11083  ==   2      Number of DL SCells to be released on PCell due to HR DRB for SA
...    M55118C11084  ==   2      Number of DL SCells released on PCell due to HR DRB for SA
...    M55118C11085  ==   1      Number of UL SCells to be released on PCell due to HR DRB for SA
...    M55118C11086  ==   1      Number of UL SCells released on PCell due to HR DRB for SA

@{A_EI_B3_1_PM_PCELL}
...    M55167C00071  ==   1      Number of times 2 DL SCell setup failed in gNB-DU due to cell not available
...    M55167C00077  ==   1      Number of times 1 UL SCell setup failed in gNB-DU due to cell not available

@{A_EI_B3_2_PM_PCELL}
...    M55167C00091  ==   1      Number of times 2 DL SCell setup failed in gNB-DU due to insufficient UE Capab
...    M55167C00097  ==   1      Number of times 1 UL SCell setup failed in gNB-DU due to insufficient UE Capab

@{B_EI_B201_PM_PCELL}
...   M55118C11039  ==  1       Number of DL SCells to be released on PSCell due to HR DRB for NSA
...   M55118C11040  ==  1       Number of DL SCells released on PSCell due to HR DRB for NSA
...   M55118C11043  ==  1       Number of DL full SCell release attempts on PSCell for NSA
...   M55118C11044  ==  1       Number of successful DL full SCell release attempts on PSCell for NSA

@{B_EI_B301_PM_PCELL}
...  M55114C01529  ==  1              Number of unsuccessful radio admissions for 1 DL SCell
...  M55118C11049  ==  1              Number of SCell configuration fails due to no SCell candidate found

@{SCELL_1_SA}                  # Common CA Counters regarding 1 Scell SA
...  M55138C03510  ==  1       Number of radio admission requests for 1 DL SCell
...  M55138C03524  ==  0       Number of radio admission requests for 1 UL SCell
...  M55139C05502  ==  1       Number of radio admission requests for 1 DL SCell in DU
...  M55139C05516  ==  0       Number of radio admission requests for 1 UL SCell in DU
...  M55138C03517  ==  1       Number of successful radio admissions for 1 DL SCell
...  M55138C03530  ==  0       Number of unsuccessful radio admissions for 1 DL SCell
...  M55118C11051  ==  1       Number of successful selections for 1 DL SCell
...  M55118C11061  ==  1       Total number of 1 DL SCells configured

@{SCELL_2_SA}                  # Common CA Counters regarding 2 Scell SA
...  M55138C03511  ==  1       Number of radio admission requests for 2 DL SCell
...  M55138C03525  ==  0       Number of radio admission requests for 2 UL SCell
...  M55139C05503  ==  1       Number of radio admission requests for 2 DL SCell in DU
...  M55139C05517  ==  0       Number of radio admission requests for 2 UL SCell in DU
...  M55138C03518  ==  1       Number of successful radio admissions for 2 DL SCell
...  M55138C03531  ==  0       Number of unsuccessful radio admissions for 2 DL SCell
...  M55118C11052  ==  1       Number of successful selections for 2 DL SCell
...  M55118C11062  ==  0       Total number of 2 DL SCells configured

@{A_EI_B202_PM_PCELL}          # CA Counters for inter gNB CA SCell release
...  M55118C11099  ==  0       Number of DL ext-SCells to be released. on PCell due to link failure in ext- gNB for SA
...  M55118C11100  ==  0       Number of DL ext-SCells released on PCell due to link failure in ext-gNB for SA
...  M55118C11101  ==  0       Number of DL ext-SCells to be released. on PCell due to Rad Network Unspecified for SA
...  M55118C11102  ==  0       Number of DL ext-SCells released on PCell due to Rad Network Unspecified for SA
...  M55118C06501  ==  0       Number of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for SA
...  M55118C06502  ==  0       Number of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for SA

@{A_EI_B3_PM_PCELL}            # CA Counters for inter gNB CA SCell config failures
...  M55118C11104  ==  0       Number of SCell configuration fails due to max CA users exceeded for SCell
...  M55118C11105  ==  0       Number of SCell configuration fails due to no SCell candidate found for SCell
...  M55167C00134  ==  0       Number of times 1 DL ext-SCell setup failed in gNB-DU due to no CA-eligible DRB
...  M55167C00141  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to radioNetwork: target-not-allowed
...  M55167C00148  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to C-RNTI collision
...  M55167C00155  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to incompatible configuration
...  M55167C00162  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to no resources
...  M55167C00169  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to cell not available
...  M55167C00176  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to no UP resources
...  M55167C00183  ==  0       Number of times 1 DL ext-SCell setup failed in ext gNB-DU due to no UE capability

@{SCELL_1_NSA}                 # Common CA Counters regarding 1 Scell NSA
...  M55114C01509  ==  1       The number of radio admission requests for 1 DL SCell
...  M55114C01516  ==  0       The number of successful radio admissions for 1 DL SCell
...  M55114C01529  ==  1       The number of unsuccessful radio admissions for 1 DL SCell
...  M55118C11013  ==  0       The number of successful selections for 1 DL SCell as the best SCell
...  M55118C11023  ==  0       Total number of 1 DL SCells configured
