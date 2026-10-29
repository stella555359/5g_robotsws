*** Settings ***
Documentation  resource file


*** Variables ***
${NEW_NIDD}=  False
&{BRANCH_NAME_UPGRADE_PATH}=
...  SBTS00=SBTS25R1
...  SBTS23R1=SBTS22R4
...  SBTS23R2=SBTS23R1
...  SBTS23R3=SBTS23R2
...  SBTS23R4=SBTS23R3
...  SBTS24R1=SBTS23R4
...  SBTS24R2=SBTS24R1
...  SBTS24R3=SBTS24R2
...  SBTS25R1=SBTS24R3
...  SBTS25R2=SBTS25R1
...  5G20A=5G20A
...  5G20B=5G20A
...  5G21A=5G20A
...  5G21B=5G21A

@{GLO_ALLOWED_ALARMS}=
...  .*LMP access via port.*
...  .*SSH enabled.*
...  .*Service Port enabled.*
...  .*BTS Reset Cause.*
...  .*Service account root access is enabled.*
...  .*Ethernet port security is disabled.*
...  .*RRU power loss.*
...  .*Sanity Check Error.*
...  .*Diagnostic Check Error.*
...  .*Fault signature for crash or failure.*
...  .*Unit power reset.*

@{GLO_TRUNK_ALLOWED_ALARMS}=
...  .*Unsigned software release has been successfully downloaded.*

@{GLO_ADMIN_ALLOWED_ALARMS}=  faultId=61652, severity=Minor
...  faultId=61524, severity=Minor
...  faultId=61649, severity=Minor
...  faultId=2403, severity=Critical
...  faultId=4592, severity=Warning
...  faultId=4655, severity=Minor
...  faultId=4654, severity=Minor
...  faultId=4681, severity=Minor
...  faultId=4681, severity=Major
...  faultId=4681, severity=Warning
...  faultId=7300, severity=Major
...  faultId=6327, severity=Major
...  faultId=7319, severity=Major
...  faultId=4590, severity=Warning

@{GLO_SETUP_ADMIN_ALLOWED_ALARMS}=
...  faultId=7300, severity=Major
...  faultId=6327, severity=Major
...  faultId=7319, severity=Major

@{GLO_ADMIN_TRUNK_ALLOWED_ALARMS}=  @{EMPTY}

${GLO_ADDITIONAL_RD_FLAGS}=  ${EMPTY}

${FILES_UTE_PATH}=  //files.ute.nsn-rdnet/builds/enb/base/
${SW_BUILDS_DIR_PATH}=  /home/ute/SW/

@{RAD_DEFAULT}=
...  0x1003f,2,ERadCcs_AaSysLogInputLevel - Prints store
...  0x10040,2,ERadCcs_AaSysLogOutputLevel - Prints forw
...  0x10041,5,ERadCcs_AaSysLogOutputMode - Output mode
...  0x3A0001,1,IM^M
...  0x1A0020,1,enable ssh even with TRS^M
...  0x30000F,1,enable ssh even with TRS^M
...  0x19012,1,Enable SSH connection automatically in ev
...  0x480008,1,SSH^M
...  0x45005a,1,enable developer user login^M
...  0x1A0077,0,Disable LBT1698/CN5417 Prevent cross-site

@{UUF_CUSTOMERS_RP}=  Vodafone
${UUF_RU_TYPE}=  FRHA
${UUF_SMOD_TYPE}  ${EMPTY}
${UUF_CA}=  RAN_PZ_WRO_4
${UUF_QC_DOMAIN}=  ${EMPTY}
${UUF_QC_PROJECT}=  ${EMPTY}
${UUF_QC_ID}  ${EMPTY}
${UUF_NSA}  ${EMPTY}
${UUF_VARIANT}  ${EMPTY}
${RESET_TIME}  ${EMPTY}
${DOWNGRADE_TIME}  ${EMPTY}

${FAULT_10_TIMEOUT}=  200
${FR_AVAILABILITY_TIMEOUT}=  720

${HANGING_RESOURCES_CHECK}=  ${TRUE}

&{RF_PROMPT}=
...  AEHC=$
...  AAIFB=~#
...  AAFB=~#
...  AHLOA=~#
...  AAIB=~#
...  FXEF=$

&{MAX_MEMORY_CONSUMPTION_DICT}=
...  ASOE=83
...  ASIB=82
...  ASIL=82
...  ASIM=65

${GIT_ACCESS_TOKEN}=  glpat-fMsomzaTyjDz3tq8geUU

${FAULT_10_SCHEME}=  {'alarmDetail': 'Failure in optical interface', 'faultId': '10', 'alarmSeverity': 'Major|Critical|a2|a3'}
${FAULT_23_SCHEME}=  {'alarmDetail': 'Incompatible SW version detected', 'faultId': '23', 'alarmSeverity': 'Critical|a3'}
${FAULT_1927_MINOR_SCHEME}=  {'alarmDetail': 'RF Power decreased|RF Module Failure', 'faultId': '1927', 'alarmSeverity': 'Minor'}
${FAULT_1927_MAJOR_SCHEME}=  {'alarmDetail': 'RF Power decreased|RF Module Failure', 'faultId': '1927', 'alarmSeverity': 'Major'}
${FAULT_1938_SCHEME}=  {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938', 'alarmSeverity': 'Major|Critical'}
${FAULT_1999_SCHEME}=  {'alarmDetail': 'PIM Performance Measurement Threshold 2 Exceeded', 'faultId': '1999', 'alarmSeverity': 'Minor'}
${FAULT_2900_SCHEME}=  {'alarmDetail': 'PIM Performance Measurement Out-of-Correction Range', 'faultId': '2900\\D*', 'alarmSeverity': 'Major'}
${FAULT_2901_SCHEME}=  {'alarmDetail': 'Hardware and Pim Cancellation Feature Activation Mismatch', 'faultId': '2901', 'alarmSeverity': 'Minor'}
${FAULT_2902_SCHEME}=  {'alarmDetail': 'PIM Cancellation Enabling Failed', 'faultId': '2902', 'alarmSeverity': 'Minor'}
${FAULT_EAC_SCHEME}=  {'alarmDetail': 'descr', 'faultId': '1400\\D*', 'alarmSeverity': '(?:Minor|Major|Critical|a1|a2|a3)', 'distName': ''}
${FAULT_1972_SCHEME}=  {'alarmDetail': '.*power loss', 'faultId': '1972', 'alarmSeverity': 'Warning'}

@{FID1815_ALLOWED_SEVERITY_LIST}=
...  Minor
...  Major

@{FID1815_ALLOWED_HW_LIST}=
...  ABIA AirScale Capacity
...  ABIN AirScale Capacity
...  ABIO AirScale Capacity
...  ABIL AirScale Capacity
...  ABIP AirScale Capacity
...  ABIQ AirScale Capacity
...  ASOE AirScale Core
...  ASOH AirScale Core
...  ASIA
...  ASIB
...  ASIK
...  ASIL
...  AAFB
...  AAFIA
...  AAIB
...  AAIC
...  AEHE
...  AENB
...  AEQC
...  AEQE
...  AEQH
...  AEQI
...  AEQJ
...  AEQK
...  AEQM
...  AEQP
...  AEQQ
...  AEQV
...  AEQW
...  AEQY
...  AEQZ
...  AHAA
...  AHAB
...  AHBB
...  AHBC
...  AHBCA
...  AHBCB
...  AHBCC
...  AHBCD
...  AHBOA
...  AHCA
...  AHCA-B
...  AHCC
...  AHCE
...  AHCF
...  AHCG
...  AHCI
...  AHDA
...  AHDB
...  AHDC
...  AHEA
...  AHEB
...  AHEC
...  AHED
...  AHEE
...  AHEGA
...  AHEGB
...  AHEGC
...  AHEGG
...  AHEGHA
...  AHEGF
...  AHEGI
...  AHEGJ
...  AHEH
...  AHFB
...  AHFIA
...  AHFIB
...  AHFIC
...  AHFIE
...  AHFIG
...  AHFIHA
...  AHFII
...  AHGA
...  AHGC
...  AHGD
...  AHGE
...  AHGF
...  AHHA
...  AHHB
...  AHIB
...  AHLB
...  AHLBA
...  AHLBBA
...  AHLJA
...  AHLOA
...  AHLOB
...  AHMA
...  AHNA
...  AHOA
...  AHPB
...  AHPC
...  AHPCA
...  AHPCB
...  AHPCDB
...  AHPD
...  AHPDA
...  AHPDB
...  AHPDC
...  AHPE
...  AHPF
...  AHPG
...  AHPH
...  AHPJ
...  AHPL
...  AHPMDA
...  AHPMDB
...  AHPMDD
...  AHPMDG
...  AHPMDH
...  AHPMDI
...  AHPMDJ
...  AHRA
...  AHSA
...  AHSB
...  ANEGA
...  ARCA
...  ARDA
...  ARDB
...  AREA
...  ARGA
...  ARHA
...  ARMA
...  ARPA
...  ARPB
...  AWHHD
...  AWHHF
...  AWHHG
...  AWHHI
...  AWHKA
...  AWHKB
...  AWHQE
...  AWHQF
...  AWHQM
...  AWHQV
...  AWHTA
...  AWMFIA
...  AZFGA
...  AZHA
...  AZHE
...  AZHL
...  AZHM
...  AZHN
...  AZNA
...  AZNB
...  AZNC
...  AZND
...  AZNE
...  AZQC
...  AZQD
...  AZQE
...  AZQF
...  AZQI
...  AZQJ
...  AZQO
...  AZQR
...  AZQW
...  AZRA
...  AZRB
...  AZRC
...  AZTA

${FID1815_TIMEOUT}=  10

@{EXPECTED_LINK_BREAK_LIST}

${INFO_MODEL_CELL_NODE_PATH}=  //LNBTS_M-1/CELL_M  # valid value before introduction of common cell: //LNBTS-1/LCELL

${FID1981_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                    	"scope": "RFM",
...                    	"minor": "-",
...                    	"info": "-",
...                    	"rfmCpri": "-",
...                    	"rfmFpga": "-",
...                    	"rfmGpp": "-"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                     "date",
...                   	"loadName"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                  }

@{FID_1981_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7115 BASE STATION INFORMATION
...                      7116 BASE STATION SERVICE PROBLEM
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
${FID_1981_WARNING_TIMEOUT}=  900
${FID_1981_CRITICAL_TIMEOUT}=  360




${FID1911_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                     "info": "-",
...                     "minor": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                 }

@{FID_1911_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7115 BASE STATION INFORMATION
...                      7116 BASE STATION SERVICE PROBLEM
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
...                      7655 CELL NOTIFICATION

@{FID4589_RELEASE_STRING_LIST}=
...    MAA
...    AR0
...    5GRU5.0

@{FID4589_RELEASE_LESS_THAN_5_1_STRING_LIST}=
...    FJ0

${FID4589_FAULT_SIGNATURE_SCHEME}=   {
...                   "fixed_value": {
...                    	"category": "POWER_OFF",
...                    	"scope": "RFM",
...                    	"minor": "-",
...                    	"extraInfo": "-",
...                    	"info": "-",
...                    	"rfmCpri": "-",
...                    	"rfmFpga": "-",
...                    	"rfmGpp": "-"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                   	"resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                 "not_empty_value": [
...                  ]
...                 }

@{FID_4589_ALARM_INFO}=  7115 BASE STATION INFORMATION
...                      7652 BASE STATION NOTIFICATION

${FID_4589_APPEAR_TIMEOUT}=  5
${FID_4589_DISAPPEAR_TIMEOUT}=  40

${FID4590_FAULT_SIGNATURE_SCHEME}=   {
...                   "fixed_value": {
...                     "extraInfo": "-",
...                     "minor": "RFM_GPP",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   	"category": "SW_FAILURE|UNKNOWN"
...                   },
...                   "not_empty_value": [
...                     "info",
...                     "rfmGpp"
...                   ]
...                 }

@{FID_4590_ALARM_INFO}=  7115 BASE STATION INFORMATION
...                      7652 BASE STATION NOTIFICATION

${FID_4590_TIMEOUT}=  360

${FID1907_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                     "info": "-",
...                     "minor": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                 }
${FID_1907_TIMEOUT}=  1200
@{FID_1907_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7115 BASE STATION INFORMATION
...                      7116 BASE STATION SERVICE PROBLEM
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
...                      7655 CELL NOTIFICATION

@{FID_1901_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7111 BASE STATION SOFTWARE MANAGEMENT PROBLEM
...                      7115 BASE STATION INFORMATION
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
${FID1901_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                     "info": "-",
...                     "minor": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                 }
${CRITICAL_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                     "category": "-",
...                     "scope": "-",
...                     "minor": "-",
...                     "info": "-",
...                     "extraInfo": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "resetCounter": "-",
...                     "component": "-",
...                     "date": "-",
...                     "loadName": "-"
...                   },
...                   "dynamic_value": [
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                   ]
...                 }

${FID_1901_TIMEOUT}=  540
${RF_CABLINKS_NUMBER}



${1837_NEW_FAULT_NAME_RELEASE}=  SBTS24R2
${1838_NEW_FAULT_NAME_RELEASE}=  SBTS24R2

#----------------------General Variables-----------------------------------------------
${SCFC_REFERENCE_FILE_PATH}=
${OUT_TEST_PRE_ENB_ACTIVE_SW}
@{ALLOWED_ALARMS_TEST}=         Vendor BTS certificate
...                             Synchronization lost
...                             BTS booted at.+?
...                             ToP master service.+?
...                             System information broadcast parameters overflow
...                             BTS reference clock missing
...                             Transmission path failure
...                             SSH enabled
...                             LMP access via port.+?
...                             R&D Service Port enabled
...                             Transmission clock missing
...                             No usable time reference available
...                             Service account root access is enabled
...                             Ethernet port security is disabled
...                             Sanity Check Error
...                             BTS Reset Cause
...                             Diagnostic Check Error

@{ALLOWED_ALARMS_WHEN_OK}=      Vendor BTS certificate
...                             Synchronization lost
...                             BTS booted at.+?
...                             ToP master service.+?
...                             System information broadcast parameters overflow
...                             BTS reference clock missing
...                             SSH enabled
...                             LMP access via port.+?
...                             R&D Service Port enabled
...                             Transmission clock missing
...                             No usable time reference available
...                             Service account root access is enabled
...                             Ethernet port security is disabled
...                             Sanity Check Error
...                             BTS Reset Cause
...                             Diagnostic Check Error

@{ALLOWED_ALARMS_FOR_1936}=     Vendor BTS certificate
...                             Synchronization lost
...                             BTS booted at.+?
...                             ToP master service.+?
...                             TX failure in MIMO
...                             System information broadcast parameters overflow
...                             BTS reference clock missing
...                             Transmission path failure
...                             SSH enabled
...                             LMP access via port.+?
...                             R&D Service Port enabled
...                             Transmission clock missing
...                             No usable time reference available
...                             .*Service account root access is enabled.*
...                             Ethernet port security is disabled
...                             Sanity Check Error
...                             BTS Reset Cause
...                             Diagnostic Check Error

@{ALLOWED_ALARMS_FOR_1937}=     Vendor BTS certificate
...                             Synchronization lost
...                             BTS booted at.+?
...                             ToP master service.+?
...                             TX failure in MIMO
...                             Pipe dangerously overheating
...                             System information broadcast parameters overflow
...                             BTS reference clock missing
...                             Transmission path failure
...                             SSH enabled
...                             LMP access via port.+?
...                             R&D Service Port enabled
...                             Transmission clock missing
...                             No usable time reference available
...                             .*Service account root access is enabled.*
...                             Ethernet port security is disabled
...                             Unit \\Smodule\\S temperature is high\\s*
...                             Sanity Check Error
...                             BTS Reset Cause
...                             Diagnostic Check Error

@{ALLOWED_ALARMS_FOR_1938}=     Vendor BTS certificate
...                             Synchronization lost
...                             BTS booted at.+?
...                             ToP master service.+?
...                             TX failure in MIMO
...                             Unit \\(module\\) dangerously overheating\\s*
...                             System information broadcast parameters overflow
...                             BTS reference clock missing
...                             Transmission path failure
...                             SSH enabled
...                             LMP access via port.+?
...                             R&D Service Port enabled
...                             Transmission clock missing
...                             No usable time reference available
...                             Service account root access is enabled
...                             Ethernet port security is disabled
...                             Sanity Check Error
...                             BTS Reset Cause
...                             Diagnostic Check Error

# @{ALLOWED_ALARMS_FOR_4003}=     Vendor BTS certificate
# ...                             Synchronization lost
# ...                             BTS booted at.+?
# ...                             ToP master service.+?
# ...                             System information broadcast parameters overflow
# ...                             BTS reference clock missing
# ...                             RF Module failure
# ...                             SSH enabled
# ...                             LMP access via port.+?
# ...                             R&D Service Port enabled
# ...                             Transmission clock missing
# ...                             No usable time reference available
# ...                             TX out of order
# ...                             Service account root access is enabled
# ...                             Ethernet port security is disabled
# ...                             Sanity Check Error
# ...                             BTS Reset Cause
# ...                             Diagnostic Check Error

${OUT_CELL_COUNT_FOR_ALL_FRS}
${OUT_IP_FR_UNDER_TEST}
${OUT_NAME_FR_UNDER_TEST}
${OUT_CELL_COUNT_FOR_FR_UNDER_TEST}
@{OUT_ALL_FR_SERIAL_NUMBER_LIST}
${OUT_SUITE_LOGS_DIR_PATH}
${OUT_TEST_LOGS_DIR_PATH}
${OUT_SW_PACKAGE_FILE_PATH}
${OUT_BTSSM_INSTALLER_FILE_PATH}
${ACTIVE_RF_FILE_VERSION}
${WAY_OF_GENERATION_FAULT}
${KEY_STABILITY_TIME}
${ONAIR_STATUS_TIMEOUT}=                360
#----------------------Variables for GREEN RF State-----------------------------------------------
${RF_IM_BLOCKING_STATE_WHEN_OK}=       Unblocked
${RF_IM_LED_STATE_WHEN_OK}=            Green
# #----------------------Variables for Fault 4003-----------------------------------------------
# ${FAULT4003_SF_CMD_CODE}=               1116 1 0 0 0 0
# ${FAULT4003_ARD_CMD_CODE}=              INTALMSET: MODE=ON INTALM=0x00000000,0x10000000
# #Info model variables
# @{FAULT4003_INFOMODEL}=                 {'alarmDetail': 'Transmission path failure', 'faultId': '4003', 'alarmSeverity': 'Minor'}
# @{FAULT4003_ADMIN}=                     {'alarmDetail': 'Transmission path failure', 'faultId': '4003\\D*', 'alarmSeverity': 'Minor'}
# ${F4003_S1_RF_IM_BLOCKING_STATE}=       Unblocked
# ${F4003_S1_RF_IM_LED_STATE_OBSAI}=      RedOffB
# ${F4003_S1_RF_IM_LED_STATE_CPRI}=       Red
#----------------------Variables for Fault 1837-----------------------------------------------
${FAULT1837_SF_CMD_CODE}=               1177 1 0 0 0 0 1
${FAULT1837_ARD_CMD_CODE}=              INTALMSET: MODE=ON INTALM=0x00000000,0x00200000
${FAULT1837_IM_OBJECT}=                 /RU_L-1/TX_PU_L-*               #from SBTS20C
#${FAULT1837_IM_OBJECT}=                 /RU_L-1/VUBUS_L-*/VU_L-*       #for SBTS20B and earlier
${FAULT1837_REASONING_INFO}=            VSWRMajorLimitExceeded
#Info model variables
#@{FAULT1837_INFOMODEL}=                 {'alarmDetail': 'VSWR major alarm', 'faultId': '1837', 'alarmSeverity': 'Critical'}
@{FAULT1837_INFOMODEL_ADMIN}=           {'alarmDetail': 'VSWR major alarm', 'faultId': '1837', 'alarmSeverity': 'Critical'}
@{FAULT1837_ADMIN}=                     {'alarmDetail': 'VSWR major alarm', 'faultId': '1837\\D*', 'alarmSeverity': 'Critical'}
@{FAULT1837_ADMIN_NEW_NAME}=            {'alarmDetail': 'VSWR upper threshold exceeded', 'faultId': '1837\\D*', 'alarmSeverity': 'Critical'}
${F1837_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1837_S1_RF_IM_LED_STATE_OBSAI}=      RedGreenB
${F1837_S1_RF_IM_LED_STATE_CPRI}=       RedOffB
#----------------------Variables for Fault 1838-----------------------------------------------
${FAULT1838_SF_CMD_CODE}=               1176 1 0 0 0 0 1
${FAULT1838_ARD_CMD_CODE}=              INTALMSET: MODE=ON INTALM=0x00000040,0x00000000
${FAULT1838_IM_OBJECT}=                 /RU_L-1/TX_PU_L-*               #from SBTS20C
#${FAULT1838_IM_OBJECT}=                 /RU_L-1/VUBUS_L-*/VU_L-*       #for SBTS20B and earlier
${FAULT1838_REASONING_INFO}=            VSWRMinorLimitExceeded
#Info model variables
#@{FAULT1838_INFOMODEL}=                 {'alarmDetail': 'VSWR minor alarm', 'faultId': '1838', 'alarmSeverity': 'Major'}
@{FAULT1838_INFOMODEL_ADMIN}=           {'alarmDetail': 'VSWR minor alarm', 'faultId': '1838', 'alarmSeverity': 'Major'}
@{FAULT1838_ADMIN}=                     {'alarmDetail': 'VSWR minor alarm', 'faultId': '1838\\D*', 'alarmSeverity': 'Major'}
@{FAULT1838_ADMIN_NEW_NAME}=            {'alarmDetail': 'VSWR lower threshold exceeded', 'faultId': '1838\\D*', 'alarmSeverity': 'Major'}
${F1838_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1838_S1_RF_IM_LED_STATE_OBSAI}=      RedGreenB
${F1838_S1_RF_IM_LED_STATE_CPRI}=       RedOffB
#----------------------Variables for Fault 1923-----------------------------------------------
${FR_UNDER_TEST_SERIAL_NUMBER_FAKE}
${SN_NAME_END}=                         ${EMPTY}
${FAULT1923_SF_CMD_CODE}=               1137 0 0 0 0 0
${FAULT1923_IM_OBJECT}=                 /RU_L-1/STORAGE_L-*
${FAULT1923_REASONING_INFO}=            RadioUnitUnidentified
#Info model variables
#@{FAULT1923_INFOMODEL}=                 {'alarmDetail': 'RF Module failure', 'faultId': '1923', 'alarmSeverity': 'Major'}
@{FAULT1923_INFOMODEL_ADMIN}=           {'alarmDetail': 'Unit unidentified', 'faultId': '1923', 'alarmSeverity': 'Major'}
@{FAULT1923_ADMIN}=                     {'alarmDetail': 'Unit unidentified', 'faultId': '1923\\D*', 'alarmSeverity': 'Major'}
${F1923_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1923_S1_RF_IM_LED_STATE}=            RedOffB
#----------------------Variables for Fault 1932-----------------------------------------------
${FAULT1932_SF_CMD_CODE}=               1163 0 0 0 0 0
${FAULT1932_REASONING_INFO_OBSAI}=      FanNotDetected
${FAULT1932_REASONING_INFO_CPRI}=       FansNotDetected
#Info model variables
#@{FAULT1932_INFOMODEL}=                 {'alarmDetail': 'Fan failure', 'faultId': '1932', 'alarmSeverity': 'Minor'}
@{FAULT1932_INFOMODEL_ADMIN}=           {'alarmDetail': 'No module fan detected', 'faultId': '1932', 'alarmSeverity': 'Minor'}
@{FAULT1932_ADMIN}=                     {'alarmDetail': 'No module fan detected', 'faultId': '1932\\D*', 'alarmSeverity': 'Minor'}
${F1932_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1932_S1_RF_IM_LED_STATE}=            Green
#----------------------Variables for Fault 1933-----------------------------------------------
${FAULT1933_SF_CMD_CODE}=               1164 0 0 0 0 0
${FAULT1933_IM_OBJECT}=                 /FAN_L-*
${FAULT1933_REASONING_INFO}=            AllFansBroken
#Info model variables
#@{FAULT1933_INFOMODEL}=                 {'alarmDetail': 'Fan failure', 'faultId': '1933', 'alarmSeverity': 'Minor'}
@{FAULT1933_INFOMODEL_ADMIN}=           {'alarmDetail': 'Cooling fan broken', 'faultId': '1933', 'alarmSeverity': 'Minor'}
@{FAULT1933_ADMIN}=                     {'alarmDetail': 'Cooling fan broken', 'faultId': '1933\\D*', 'alarmSeverity': 'Minor'}
${F1933_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1933_S1_RF_IM_LED_STATE}=            Red
#----------------------Variables for Fault 1934-----------------------------------------------
${FAULT1934_SF_CMD_CODE}=               1165 0 0 0 0 0
${FAULT1934_IM_OBJECT}=                 /FAN_L-*
${FAULT1934_REASONING_INFO}=            SpeedTooLow
${FAULT1934_PARAMETER_NAME}=            vendor
${FAULT1934_ATTRIBUTE_NAME}=            RPM100max
${FAULT1934_NEW_VALUE}                  2500
${FAULT1934_ATTRIBUTE_TO_FIND_NAME}=
${FAULT1934_ATTRIBUTE_TO_FIND_VALUE}=
#Info model variables
#@{FAULT1934_INFOMODEL}=                 {'alarmDetail': 'Fan failure', 'faultId': '1934', 'alarmSeverity': 'Minor'}
@{FAULT1934_INFOMODEL_ADMIN}=           {'alarmDetail': 'Cooling fan has reduced from the set speed', 'faultId': '1934', 'alarmSeverity': 'Minor'}
@{FAULT1934_ADMIN}=                     {'alarmDetail': 'Cooling fan has reduced from the set speed', 'faultId': '1934\\D*', 'alarmSeverity': 'Minor'}
${F1934_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1934_S1_RF_IM_LED_STATE}=            Green
${F1934_S1_RF_IM_LED_STATE_SF}=         RedOffB
#----------------------Variables for Fault 1936-----------------------------------------------
${FAULT1936_SF_CMD_CODE}=               1167 0 0 0 0 0
${FAULT1936_ARD_CMD_CODE}=              INTALMSET: MODE=ON INTALM=0x00000000,0x00080000
${FAULT1936_REASONING_INFO}=            HighTemperature
${FAULT1936_PARAMETER_NAME}=            Thigh
${FAULT1936_ATTRIBUTE_NAME}=
${FAULT1936_NEW_VALUE}=                 1
${FAULT1936_ATTRIBUTE_TO_FIND_NAME}=
${FAULT1936_ATTRIBUTE_TO_FIND_VALUE}=
@{FAULT1936_INFOMODEL_ADMIN}=           {'alarmDetail': 'Unit \\Smodule\\S temperature is high\\s*', 'faultId': '1936', 'alarmSeverity': 'Minor'}
@{FAULT1936_ADMIN}=                     {'alarmDetail': 'Unit \\Smodule\\S temperature is high\\s*', 'faultId': '1936', 'alarmSeverity': 'Minor'}
#Info model variables
#@{FAULT1936_INFOMODEL}=                 {'alarmDetail': 'Unit \\Smodule\\S temperature is high\\s*', 'faultId': '1936', 'alarmSeverity': 'Minor'}
${F1936_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1936_S1_RF_IM_LED_STATE}=            Green
#----------------------Variables for Fault 1937-----------------------------------------------
${FAULT1937_SF_CMD_CODE}=               1168 0 0 0 0 0
${FAULT1937_ARD_CMD_CODE}=              INTALMSET: MODE=ON INTALM=0x00000000,0x00100000
${FAULT1937_REASONING_INFO}=            DangerouslyOverheated
${FAULT1937_PARAMETER_NAME}=            Thermometer
${FAULT1937_ATTRIBUTE_NAME}=            T_offset
${FAULT1937_NEW_VALUE}=                 100
${FAULT1937_ATTRIBUTE_TO_FIND_NAME}=    type
${FAULT1937_ATTRIBUTE_TO_FIND_VALUE}=   MODULE
#Info model variables

@{FAULT1937_INFOMODEL_ADMIN}=   {'alarmDetail': 'Unit \\(module\\) dangerously overheating\\s*', 'faultId': '1937', 'alarmSeverity': 'Critical'}
@{FAULT1937_INFOMODEL_ADMIN_H}=    {'alarmDetail': 'Unit \\(module\\) dangerously overheating\\s*', 'faultId': '1937', 'alarmSeverity': 'Critical'}
@{FAULT1937_ADMIN}=        {'alarmDetail': 'Unit \\Smodule\\S dangerously overheating\\s*', 'faultId': '1937\\D*', 'alarmSeverity': 'Critical'}
@{FAULT1937_ADMIN_H}=      {'alarmDetail': 'Unit \\Smodule\\S dangerously overheating\\s*', 'faultId': '1937\\D*', 'alarmSeverity': 'Critical'}
#ATTENTION: If cell is located on two or more RFs and it stays in OnAir State during presence of fault 1937, then severity
#ATTENTION: of the fault 1937 is "Major" instead of "Critical".
${F1937_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1937_S1_RF_IM_LED_STATE_OBSAI}=      Red
${F1937_S1_RF_IM_LED_STATE_CPRI}=       RedOffB
#----------------------Variables for Fault 1938-----------------------------------------------
${FAULT1938_SF_CMD_CODE}=               1169 1 0 0 0 0
${FAULT1938_CANCEL_SF_CMD_CODE}=        1169 1 0 1 0 0
${FAULT1938_IM_OBJECT}=                 /RU_L-1/TX_PU_L-*
${FAULT1938_REASONING_INFO}=            SeriouslyOverheated
${FAULT1938_PARAMETER_NAME}=            Thermometer
${FAULT1938_ATTRIBUTE_NAME}=            T_offset
${FAULT1938_NEW_VALUE}=                 100
${FAULT1938_ATTRIBUTE_TO_FIND_NAME}=    type
${FAULT1938_ATTRIBUTE_TO_FIND_VALUE}=   PA
#Info model variables
#@{FAULT1938_INFOMODEL}=                 {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938', 'alarmSeverity': 'Critical'}
#@{FAULT1938_INFOMODEL_H}=               {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938', 'alarmSeverity': 'Critical'}
@{FAULT1938_INFOMODEL_ADMIN}=           {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938', 'alarmSeverity': 'Critical'}
@{FAULT1938_INFOMODEL_ADMIN_H}=         {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938', 'alarmSeverity': 'Critical'}
@{FAULT1938_ADMIN}=                     {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938\\D*', 'alarmSeverity': 'Critical'}
@{FAULT1938_ADMIN_H}=                   {'alarmDetail': 'Pipe dangerously overheating', 'faultId': '1938\\D*', 'alarmSeverity': 'Critical'}
${F1938_S1_RF_IM_BLOCKING_STATE}=       Unblocked
${F1938_S1_RF_IM_LED_STATE}=            RedOffB
#----------------------Variables for Fault 1957-----------------------------------------------
${FAULT1957_SF_CMD_CODE}=           1240 1 0 0 0 0
${FAULT1957_IM_OBJECT}=             /RU_L-1/TX_PU_L-*
${FAULT1957_REASONING_INFO}=        SwitchedOffDueToExtremelyHighVSWR
#Info model variables
#@{FAULT1957_INFOMODEL}=             {'alarmDetail': 'Antenna line switched off due to high VSWR', 'faultId': '1957', 'alarmSeverity': 'Critical'}
@{FAULT1957_INFOMODEL_ADMIN}=       {'alarmDetail': 'Antenna line switched off due to high VSWR', 'faultId': '1957', 'alarmSeverity': 'Critical'}
@{FAULT1957_ADMIN}=                 {'alarmDetail': 'Antenna line switched off due to high VSWR', 'faultId': '1957\\D*', 'alarmSeverity': 'Critical'}
${F1957_S1_RF_IM_BLOCKING_STATE}=    Unblocked
${F1957_S1_RF_IM_LED_STATE}=         RedGreenB
