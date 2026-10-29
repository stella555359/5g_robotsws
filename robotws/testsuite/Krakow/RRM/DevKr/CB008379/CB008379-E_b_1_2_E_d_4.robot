*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...            CB008379-E_b, CB008379-E_d
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Tomasz Pyrek <michal.szymakowski@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [11.04.2022] - Create Test Suite
...         [30.04.2022] - Peer review closed 
...         [18.01.2023] - Switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Keywords
...  Run Setup     gbr_mixed_mode=${True}  f1ap=${True}
...  AND  Set Maximum GBR Rate for DL and UL for 5QI-1 to 10000kb/s and set GBRService AdmissionControl

*** Variables ***
${ON_FAILURE}=           CONTINUE
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua

${LUA_CFG}=              ${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          5s
${SKIP_COUNTERS}=        ${FALSE}

*** Test Cases ***
CB008379-E-b_1 ICS with VoNR GBR and PDU session setup with VoNR GBR rejected by too high GFBR-AMF GFBR value change-PM counters
    [Tags]    E_b-1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify rejection of
    ...     - ICS with PDU session with non-GBR and VoNR-GBR
    ...     - PDU session Setup with non-GBR and VoNR-GBR
    ...     when requested GFBR for VoNR 5QI is above maxDataRateGbrDl/maxDataRateGbrUl
    ...     Test is checked for actGBRAdmissionControl equal to GBRService and EnhancedVoNR
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - RLC mode = RLC_AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actEnhancedVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actCDrxVoNR = false
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - For 5QI1:
    ...    - NRDRB.maxDataRateGbrDl = 10 Mb/s
    ...    - NRDRB.maxDataRateGbrUl = 10 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 %
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_CP_IF_NTW_4978
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Paulina Jedras <paulina.jedras@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [11.04.2022] - Create Test Case
    ...  [30.04.2022] - Peer review closed 

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI1
		#    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...   Repeat PDU session setup rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI1
		#    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0

   Log to console   Waiting for parameters modification...
   Modify actGBRAdmissionControl to EnhancedVoNR

    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI1
		#    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...   Repeat PDU session setup rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI1
		#    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0


    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 8, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 8, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test E_b-1

CB008379-E-b_2 Modification of PDU session with VoNR GBR rejected by too high GFBR- AMF GFBR value change
    [Tags]    E_b-2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify rejection of
    ...     - Modification of PDU session with addition of VoNR 5QI
    ...     - Modification of PDU session for VoNR 5QI with changed GFBR
    ...     due to requested GFBR is above maxDataRateGbrDl/maxDataRateGbrUl
    ...     Test is checked for actGBRAdmissionControl equal to GBRService and EnhancedVoNR
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - RLC mode = RLC_AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actEnhancedVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actCDrxVoNR = false
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - For 5QI1:
    ...    - NRDRB.maxDataRateGbrDl = 10 Mb/s
    ...    - NRDRB.maxDataRateGbrUl = 10 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 %
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_CP_IF_NTW_4978
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Paulina Jedras <paulina.jedras@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [12.04.2022] - Create Test Case
    ...  [30.04.2022] - Peer review closed 

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Run Keyword And Continue On Failure
    ...   GBR not admitted yet-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI1

   Log to console   Waiting for parameters modification...
   Modify actGBRAdmissionControl to EnhancedVoNR

    Run Keyword And Continue On Failure
    ...   GBR not admitted yet-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE2 and 5QI1

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    [Teardown]  Cleanup after test E_b-2

CB008379-E-bd Modification of PDU session for GBR rejected by too high GFBR- AMF GFBR value change
#CB008379-E-d_4 Modification of PDU session with GFBR value change rejected by too high GFBR
    [Tags]    E_d-4
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform unsuccessful modification of PDU session
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254 due to too high requested GFBR value.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - RLC mode = RLC_AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actEnhancedVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actCDrxVoNR = false
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - For all 5QI:
    ...    - NRDRB.maxDataRateGbrDl = 10 Mb/s
    ...    - NRDRB.maxDataRateGbrUl = 10 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 %
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_CP_IF_NTW_4978
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Paulina Jedras <paulina.jedras@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [12.04.2022] - Create Test Case
    ...  [30.04.2022] - Peer review closed 

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Log to console      1/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI2

    Log to console      2/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE2 and 5QI3

    Log to console      3/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE3 and 5QI4

    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Log to console      4/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE4 and 5QI71

    Log to console      5/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE5 and 5QI72

    Log to console      6/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE6 and 5QI76

    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0

    Log to console      7/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE7 and 5QI128

    Log to console      8/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE8 and 5QI212

    Log to console      9/9
    Run Keyword And Continue On Failure
    ...   GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE9 and 5QI254

    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Run Test Teardown
