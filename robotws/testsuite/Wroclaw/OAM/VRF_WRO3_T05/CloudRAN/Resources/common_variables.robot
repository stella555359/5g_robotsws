*** Settings ***
Documentation  AiC common variables.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: szymon.romanowski@nokia.com

*** Variables ***
#-------------- LOG AND CONFIG PATH ---------
${SUITE_LOGS_DIR_PATH}=         ${OUTPUT_DIR}

#-------VDU OAM HTTP CONNECTION -------
${VDU_OAM_USERNAME}=    Nemuadmin
${VDU_OAM_PASSWORD}=    Nokia@123

# ----------  OCP Login part -----------------
${OCP_LOGIN_USERNAME}=   nokiaadmin
${OCP_LOGIN_PASSWORD}=   nokiaadmin

###### Internal useage , please do not change it if you do not know it well #############
@{VDU_REST_TAF_LIB_SUPPORTED_VERSION}=   cuoam_19b   cuoam_21b  cuoam_22r2  cuoam_22r4  cuoam_23r1  cuoam_23r2   cuoam_23r3
&{VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}=   16.300=cuoam_22r4  15.300=cuoam_22r2  17.300=cuoam_23r1    18.300=cuoam_23r2
                                          ...  0.300=${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}
@{VCU_REST_TAF_LIB_SUPPORTED_VERSION}=   cuoam_19b   cuoam_21b   cuoam_22r4  cuoam_23r1  cuoam_23r2
&{VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}=   15.250=cuoam_21b    16.250=cuoam_22r4  17.250=cuoam_23r1   18.250=cuoam_23r2
                                          ...   0.250=${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}

# ----------- Package information --------------
&{PACKAGE_PREFIX}=    0.300=vDUCNF00   0.250=vCUCNF00    14.300=vDUCNF22R2    14.250=vCUCNF22R2   15.250=vCUCNF22R3
                   ...    16.300=vDUCNF22R4   16.250=vCUCNF22R4   17.300=vDUCNF23R1   17.250=vCUCNF23R1
                   ...    18.300=vDUCNF23R2   18.250=vCUCNF23R2

# ----------- Timeuots --------------
${ACTIVATE_PLAN_TIMEOUT}=           600s
${ACTIVATE_DELTA_PLAN_TIMEOUT}=     600s

# ----------- RU credentials --------------
@{RU_REL6_2}=  rfsw  0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=
&{RU_PASSWORDS}=  AHFII=${RU_REL6_2}  AHPMDG=@{RU_REL6_2}

# ----------- VDU prompts --------------
${VDU_CONTAINER_PROMPT}=            bash-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT_ROOT}=       \\[root@\\S+:\\S+\\][\\r\\n]+#\\s
${VDU_OE_SERVER_PROMPT}=            \\[core@\\S+\\s\\S+\\]\\$\\s
${VDU_OE_SERVER_PROMPT_TENANT}=     \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$

# ----------- RMOD prompts --------------
${RU_PROMPT_ROOT}=                  root@\\S+:\\S+#\\s

# ----------- Allowed alarm --------------
@{VDU_ALLOWED_ALARMS}=   BTS reference clock missing
...	                 BTS time not corrected

@{VCU_ALLOWED_ALARMS}=   BTS reference clock missing
...	                 BTS time not corrected

#@{VDU_ALLOWED_ALARMS}=  BTS reference clock missing
#...	                    Cell blocked
#
#@{VCU_ALLOWED_ALARMS}=   BTS reference clock missing
#...	                     Matching ServedCell not found over F1-C

# ----------- Expected faults for watchdog --------------
&{FAULT_16}=    fault_id=16    fault_name=Unit synchronization failed    severity=minor
&{FAULT_16_critical}=    fault_id=16    fault_name=Unit synchronization failed    severity=critical
&{FAULT_49}=    fault_id=49    fault_name=Cell blocked    severity=critical
&{FAULT_4298}=    fault_id=4298    fault_name=ToP reference missing    severity=minor
&{FAULT_4298_critical}=    fault_id=4298    fault_name=ToP reference missing    severity=critical
&{FAULT_4298_major}=    fault_id=4298    fault_name=ToP reference missing    severity=major
&{FAULT_4405}=    fault_id=4405    fault_name=No usable time reference available    severity=minor
&{FAULT_4592}=    fault_id=4592    fault_name=BTS Reset Cause    severity=warning
&{FAULT_7104}=    fault_id=7104    fault_name=Matching ServedCell not found over F1-C    severity=critical
&{FAULT_4647}=    fault_id=4647    fault_name=UTC out of sync    severity=minor
&{FAULT_4681}=    fault_id=4681    fault_name=Diagnostic Check Error    severity=minor
&{FAULT_7504}=    fault_id=7504    fault_name=F1 SCTP endpoint in DU    severity=critical
&{FAULT_7505}=    fault_id=7505    fault_name=F1 SCTP setup in DU    severity=critical
