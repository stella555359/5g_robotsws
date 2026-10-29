*** Settings ***
Documentation    This is about common variables used for cb010411 CA feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G401T2112
${CA_GROUP_TYPE}    F+T
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}
${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}           ${TRUE}    # For debug tput issue
${NSA_SA}  SA
@{carrierAggregationSupportList_F_T_UL_DL}  ca_Fdd_Fr1Tdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa  ca_Fdd_Fr1Tdd_Sa  ca_Fdd_Fr1Tdd_Nsa  ca_Fdd_Any_Sa  ca_Fdd_Fdd
...    ca_Fr1Tdd_Fdd_Sa_WithUl    ca_Fr1Tdd_Sa    ca_Fr1Tdd_Any_Sa
${DL_TO_UL_CONTRIBUTION_RATIO}    50    # Should be 101 when no UL CA, otherwise PDL error exists

${DL_TPUT_IPERF_4CC}         3500M
${DL_TPUT_IPERF_6CC}         4000M

${UL_TPUT_IPERF}         300M

${INA_PRO_REL_SCELL_ATT_SA}         M55118C10511
${INA_PRO_REL_SCELL_SUC_SA}          M55118C10512

${TIMER_FOR_MODIFY_VIA_API}    5min
${TPUT_AVG_PERCENT_COMMON}    0.9
${TPUT_MIN_PERCENT_COMMON}    0.8
