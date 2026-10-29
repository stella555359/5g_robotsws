*** Settings ***
Documentation  AiC common variables.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

*** Variables ***
# LOG AND CONFIG PATH
${SUITE_LOGS_DIR_PATH}=  ${OUTPUT_DIR}

# VDU OAM HTTP CONNECTION
${VDU_OAM_USERNAME}=  Nemuadmin
${VDU_OAM_PASSWORD}=  Nokia@123

# OCP LOGIN PART
${OCP_LOGIN_USERNAME}=   nokiaadmin
${OCP_LOGIN_PASSWORD}=   nokiaadmin

# DEFAULT CONNECTIONS
${VCU_CONNECTION_DEFAULT}=  default
${VDU_CONNECTION_DEFAULT}=  default
${LTE_VDU_CONNECTION_DEFAULT}=  default_lte

# REST API VERSION
@{VDU_REST_TAF_LIB_SUPPORTED_VERSION}=   cuoam_19b   cuoam_21b  cuoam_22r2  cuoam_22r4  cuoam_23r1  cuoam_23r2  cuoam_23r3  cuoam_23r4
                                    ...  cuoam_24r1  cuoam_24r2  cuoam_24r3  cuoam_25r1  cuoam_25r2  cuoam_25r3  cuoam_26r1  cuoam_26r2
&{VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}=   16.300=cuoam_22r4  15.300=cuoam_22r2  17.300=cuoam_23r1  18.300=cuoam_23r2  19.300=cuoam_23r3
                                           ...  20.300=cuoam_23r4  21.300=cuoam_24r1  22.300=cuoam_24r2  23.300=cuoam_24r3  23.7300=cuaom_24r3
                                           ...  24.300=cuoam_25r1
                                           ...  0.300=${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}

&{SVDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}=  23.300=COAM24R3  24.300=COAM25R1

@{VCU_REST_TAF_LIB_SUPPORTED_VERSION}=   cuoam_19b   cuoam_21b   cuoam_22r4  cuoam_23r1  cuoam_23r2  cuoam_25r2  cuoam_25r3  cuoam_26r1
&{VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}=   15.250=cuoam_21b    16.250=cuoam_22r4  17.250=cuoam_23r1   18.250=cuoam_23r2
                                          ...   0.250=${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}

# PACKAGE INFORMATION
&{PACKAGE_PREFIX}=    0.300=vDUCNF00   0.250=vCUCNF00    14.300=vDUCNF22R2    14.250=vCUCNF22R2   15.250=vCUCNF22R3
                   ...    16.300=vDUCNF22R4   16.250=vCUCNF22R4   17.300=vDUCNF23R1   17.250=vCUCNF23R1
                   ...    18.300=vDUCNF23R2   18.250=vCUCNF23R2   19.300=vDUCNF23R3   19.250=vCUCNF23R3
                   ...    20.250=vCUCNF23R4   20.300=vDUCNF23R4   21.300=vDUCNF24R1   22.300=vDUCNF24R2

# TIMEUOTS
${ACTIVATE_PLAN_TIMEOUT}=           800s
${ACTIVATE_DELTA_PLAN_TIMEOUT}=     600s
${VDU_CELLS_ONAIR_TIMEOUT}=         300s

# RU CREDENTIALS
@{RU_REL6_2}=  rfsw  0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=
&{RU_PASSWORDS}=  AHFII=${RU_REL6_2}  AHPMDG=@{RU_REL6_2}

# VDU PROMPTS
${VDU_CONTAINER_PROMPT}=            bash-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT_ROOT}=       \\[root@\\S+:\\S+\\][\\r\\n]+#\\s
${VDU_OE_SERVER_PROMPT}=            \\[core@\\S+\\s\\S+\\]\\$\\s
${VDU_OE_SERVER_PROMPT_TENANT}=     \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$

# RMOD PROMPTS
${RU_PROMPT_ROOT}=  root@\\S+:\\S+#\\s

# ALLOWED ACTIVE AND HISTORICAL ALARMS
@{VDU_ALLOWED_ALARMS}=
...                    faultId=4592, severity=Warning
@{VCU_ALLOWED_ALARMS}=
...                    faultId=4592, severity=Warning

@{ADDITIONAL_COMMON_VDU_ALLOWED_ALARMS}=
@{ADDITIONAL_COMMON_VCU_ALLOWED_ALARMS}=

@{VDU_HISTORICAL_ALLOWED_ALARMS}=  @{VDU_ALLOWED_ALARMS}
@{VCU_HISTORICAL_ALLOWED_ALARMS}=  @{VCU_ALLOWED_ALARMS}

@{ADDITIONAL_COMMON_HISTORICAL_VDU_ALLOWED_ALARMS}=
@{ADDITIONAL_COMMON_HISTORICAL_VCU_ALLOWED_ALARMS}=

@{LTE_VDU_ALLOWED_ALARMS}=  @{EMPTY}

@{ADDITIONAL_COMMON_LTE_VDU_ALLOWED_ALARMS}=

@{LTE_VDU_HISTORICAL_ALLOWED_ALARMS}=  @{LTE_VDU_ALLOWED_ALARMS}

@{ADDITIONAL_COMMON_HISTORICAL_LTE_VDU_ALLOWED_ALARMS}=

# 4592     BTS Reset Cause

# FAULT ALARMING INFO
@{FID_1901_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
                    ...  7111 BASE STATION SOFTWARE MANAGEMENT PROBLEM
                    ...  7115 BASE STATION INFORMATION
                    ...  7652 BASE STATION NOTIFICATION
                    ...  7653 CELL FAULTY
                    ...  7654 CELL OPERATION DEGRADED

@{FID_1907_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
                    ...  7115 BASE STATION INFORMATION
                    ...  7116 BASE STATION SERVICE PROBLEM
                    ...  7652 BASE STATION NOTIFICATION
                    ...  7653 CELL FAULTY
                    ...  7654 CELL OPERATION DEGRADED
                    ...  7655 CELL NOTIFICATION

@{FID_4589_ALARM_INFO}=  7115 BASE STATION INFORMATION
                    ...  7652 BASE STATION NOTIFICATION

@{FID_4590_ALARM_INFO}=  7115 BASE STATION INFORMATION
                    ...  7652 BASE STATION NOTIFICATION

@{FID_1911_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
                    ...  7115 BASE STATION INFORMATION
                    ...  7116 BASE STATION SERVICE PROBLEM
                    ...  7652 BASE STATION NOTIFICATION
                    ...  7653 CELL FAULTY
                    ...  7654 CELL OPERATION DEGRADED
                    ...  7655 CELL NOTIFICATION

@{FID_4701_ALARM_INFO}=  7100 BASE STATION HARDWARE PROBLEM
                    ...  7115 BASE STATION INFORMATION

@{FID_4700_ALARM_INFO}=  7100 BASE STATION HARDWARE PROBLEM
                    ...  7115 BASE STATION INFORMATION

@{FID_4699_ALARM_INFO}=  7100 BASE STATION HARDWARE PROBLEM
                    ...  7115 BASE STATION INFORMATION

@{FID_4698_ALARM_INFO}=  7100 BASE STATION HARDWARE PROBLEM
                    ...  7115 BASE STATION INFORMATION

# FAULT SIGNATURE SECTION
&{FAULT_SIGNATURE_DICT}=                                    # GENERIC DICTIONARY
                     ...    category=SW_FAILURE             # string to validate
                     ...    component=sn_to_check           # "_to_check" means dynamic value
                     ...    date=date_to_check              # "_to_check" means dynamic value
                     ...    extraInfo=nr_cells_to_check     # "_to_check" means dynamic value
                     ...    loadName=loadname_to_check      # "_to_check" means dynamic value
                     ...    resetCounter=int_to_check       # "_to_check" means dynamic value
                     ...    scope=RFM                       # string to validate

&{FAULT_SIGNATURE_DICT_4590}=                                    # CUSTOM DICTIONARY
                          ...    category=UNKNOWN                # string to validate
                          ...    component=sn_to_check           # "_to_check" means dynamic value
                          ...    date=date_to_check              # "_to_check" means dynamic value
                          ...    extraInfo=NR:none               # string to validate
                          ...    loadName=loadname_to_check      # "_to_check" means dynamic value
                          ...    resetCounter=int_to_check       # "_to_check" means dynamic value
                          ...    scope=RFM                       # string to validate

&{FAULT_SIGNATURE_DICT_4589}=                                    # CUSTOM DICTIONARY
                          ...    category=POWER_OFF              # string to validate
                          ...    component=sn_to_check           # "_to_check" means dynamic value
                          ...    date=date_to_check              # "_to_check" means dynamic value
                          ...    extraInfo=NR:none               # string to validate
                          ...    loadName=loadname_to_check      # "_to_check" means dynamic value
                          ...    resetCounter=int_to_check       # "_to_check" means dynamic value
                          ...    scope=RFM                       # string to validate

# TEST MODELS PARAMETERS
&{FDD_PARAMS}=    downlink_p_max=39
           ...    downlink_ru_mode=NR_only
           ...    prach_configuration_index=12
           ...    pucch_format=F1
           ...    pucch_num_symbol=14
           ...    pucch_largest_prb_index=105

&{TDD_PARAMS}=    downlink_p_max=20
           ...    prach_configuration_index=93
           ...    pucch_format=F0
           ...    pucch_num_symbol=2
           ...    pucch_largest_prb_index=272

# SNAPSHOT RU HW FAMILY NAMES
&{RMOD_HW_FAMILY_DICT}  AAFB=rel5.1
...  AAIB=rel5.1
...  AAIC=rel5.1
...  AEEGA=cta6
...  AEFIA=cta6
...  AEQB=mmimo-srm6
...  AEQE=mmimo-srm6
...  AEQH=mmimo-srm6
...  AEQI=mmimo-srm6
...  AEQJ=mmimo-srm6
...  AEQM=mmimo-srm6
...  AEQP=mmimo-srm6
...  AEQQ=mmimo-srm6
...  AEQU=mmimo-srm6
...  AEQV=mmimo-srm6
...  AEQW=mmimo-srm6
...  AEQY=mmimo-srm6
...  AEQZ=mmimo-srm6
...  AHAA=rel5.1
...  AHAB=rel5.1
...  AHBB=rel5.1
...  AHBC=rel5.1
...  AHBCA=rel5.1
...  AHBCB=rel5.1
...  AHBCC=rel5.1
...  AHBCD=rel5.1
...  AHBOA=rel5.1
...  AHCA=rel5.1
...  AHCA-B=rel5.1
...  AHCC=rel5.1
...  AHCE=rel5.1
...  AHCF=rel5.1
...  AHCG=rel5.1
...  AHDA=rel5.1
...  AHDB=rel5.1
...  AHDC=rel5.1
...  AHEB=rel5.1
...  AHEC=rel5.1
...  AHED=rel5.1
...  AHEE=rel5.1
...  AHEGA=rel5.1
...  AHEGB=rel5.1
...  AHEGC=rel5.1
...  AHEGG=frm6
...  AHEGH =frm6
...  AHEGHA=frm6
...  AHEGI=rel5.1
...  AHEGJ=rel5.1
...  AHEGSA=frm6
...  AHEH=rel5.1
...  AHFB=rel5.1
...  AHFIA=rel5.1
...  AHFIB=rel5.1
...  AHFIC=rel5.1
...  AHFIE=rel5.1
...  AHFIF=rel5.1
...  AHFIG=rel5.1
...  AHFIHA=frm6
...  AHFII=frm6
...  AHGA=rel5.1
...  AHGC=rel5.1
...  AHGD=rel5.1
...  AHGE=rel5.1
...  AHGF=rel5.1
...  AHHA=rel5.1
...  AHHB=rel5.1
...  AHIB=rel5.1
...  AHLBA=rel5.1
...  AHLBBA=rel5.1
...  AHLJA=rel5.1
...  AHLOA=rel5.1
...  AHLOB=frm6
...  AHMA=rel5.1
...  AHNA=rel5.1
...  AHOA=rel5.1
...  AHPB=rel5.1
...  AHPC=rel5.1
...  AHPCA=rel5.1
...  AHPCB=rel5.1
...  AHPCDB=rel5.1
...  AHPD=rel5.1
...  AHPDA=rel5.1
...  AHPDC=frm6
...  AHPDD=frm6
...  AHPE=rel5.1
...  AHPG=rel5.1
...  AHPJ=rel5.1
...  AHPL=rel5.1
...  AHPMDA=rel5.1
...  AHPMDB=rel5.1
...  AHPMDD=rel5.1
...  AHPMDG=frm6
...  AHPMDH=rel5.1
...  AHPMDI=rel5.1
...  AHPMDJ=rel5.1
...  AHRA=rel5.1
...  AHSA=rel5.1
...  AHSB=rel5.1
...  AKFA=fru6
...  AKHC=fru6
...  AKHD=fru6
...  AKHM=fru6
...  AKNA=fru6
...  AKNB=fru6
...  AKQA=fru6
...  AKQI=fru6
...  AKQJ=fru6
...  AKQL=fru6
...  AKQW=fru6
...  AKQZ=fru6
...  ANEGA=rel5.1
...  AQHA=cta6
...  AQHB=cta6
...  AQHC=cta6
...  AQNA=cta6
...  AQQA=cta6
...  AQQC=cta6
...  AQQE=cta6
...  AQQF=cta6
...  AQQH=cta6
...  AQQJ=cta6
...  AQQK=cta6
...  AQQL=cta6
...  AQQN=cta6
...  AQQQ=cta6
...  AQQQA=cta6
...  AQQS=cta6
...  AQQT=cta6
...  AQQV=cta6
...  AQQY=cta6
...  ARCA=rel5.1
...  ARDA=rel5.1
...  ARDB=rel5.1
...  AREA=rel5.1
...  ARGA=rel5.1
...  ARHA=rel5.1
...  ARMA=rel5.1
...  ARPA=rel5.1
...  ARPB=rel5.1
...  AVHA=srm7
...  AVHQA=srm7
...  AVHQB=srm7
...  AVNB=srm7
...  AVQA=srm7
...  AVQC=srm7
...  AVQD=srm7
...  AVQE=srm7
...  AVQF=srm7
...  AVQG=srm7
...  AVQK=srm7
...  AVQL=srm7
...  AVQQ=srm7
...  AVQQA=srm7
...  AVQQB=srm7
...  AVQQC=srm7
...  AVQR=srm7
...  AVQY=srm7
...  AWGQA=fru6
...  AWGQB=fru6
...  AWHHJ=fru6
...  AWHNA=fru6
...  AWHNB=fru6
...  AWHQ2=fru6
...  AWHQ2=fru6
...  AWHQ3=fru6
...  AWHQN=fru6
...  AWHQU=fru6
...  AWHQW=fru6
...  AWHQX=fru6
...  AWKUA=srm7
...  AWKUB=srm7
...  AWKUC=srm7
...  AWKUD=srm7
...  AWKWA=srm7
...  AWKWB=srm7
...  AWMFIA=frm6
...  AWPHA=fru6
...  AWPHB=fru6
...  AWPNA=fru6
...  AWPNB=fru6
...  AWPQY=fru6
...  AWPQZ=fru6
...  AWPTC=fru6
...  AWPTD=fru6
...  AZFGA=rel5.1
...  AZHA=rel5.1
...  AZHE=rel5.1
...  AZHL=erm6
...  AZHM=erm6
...  AZHN=erm6
...  AZNA=rel5.1
...  AZNB=rel5.1
...  AZNC=rel5.1
...  AZND=rel5.1
...  AZNE=rel5.1
...  AZQC=rel5.1
...  AZQD=rel5.1
...  AZQE=rel5.1
...  AZQF=rel5.1
...  AZQI=erm6
...  AZQJ=erm6
...  AZQO=erm6
...  AZQP=erm6
...  AZQR=rel5.1
...  AZQS=erm6
...  AZQU=erm6
...  AZQW=erm6
...  AZRA=rel5.1
...  AZRB=rel5.1
...  AZRC=rel5.1
...  AZTA=erm6
