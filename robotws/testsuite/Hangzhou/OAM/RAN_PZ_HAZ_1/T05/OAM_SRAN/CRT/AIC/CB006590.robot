*** Settings ***
Documentation     [PURPOSE]
#Suite Setup       Suite Setup For Trace
#Suite Teardown    Suite Teardown For Trace
Force Tags        QCD_MN_RAN    QCP_RAN_ST

#Resource    ../TRACE/CB006590-A_Get_active_UEs.robot
#Resource    ../TRACE/CB006590-C_IP_Traffic_Capturing.robot
#Resource    ../TRACE/CB006590-C_L1_IQ_Data_Capturing.robot
#Resource    ../TRACE/CB006590-B_Get_active_UEs.robot
#Resource    ../TRACE/CB006590-B_Reset_5G_Cell_Group.robot
#Resource    ../TRACE/CB006590-D_Configure_common_UPlane_CPlane_tracing.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/CommonKeywords.robot


*** Variables ***
${TEMP_LOGS_DIR}    /tmp/logs/
${vdu_mplane_ip}    10.108.195.130          #BTS-11322
${cu_mplane_ip}   	10.110.83.133           #BTS-11322
${vdu_username}     Nemuadmin
${vdu_password}     Nokia@123


#*** Test Cases ***
#[1][1.0] Number of active UE per cell monitor with M2M Rest API
#    [Tags]    CB006590   QC_599096  10_5_UTE5GAIC11322
#    [Timeout]    10min
#    [Setup]    CB006590 Setup For AIC vDU
#    CB006590-B Get active Ues
#    [Teardown]    CB006590 Teardown For AIC

#[1][1.0] Cloud-KPI 20 Cell group (5G) reset performance (duration)
#    [Tags]    CB006590   QC_599097  10_5_UTE5GAIC11322
#    [Timeout]    30min
#    [Setup]    CB006590 Setup For AIC vDU
#    CB006590-B Reset 5G Cell Group vDU
#    CB006590-B Reset 5G Cell Group CU
#    [Teardown]    CB006590 Teardown For AIC

#[1]Configure common UPlane CPlane tracing
#    [Tags]    CB006590   QC_599098  10_5_UTE5GAIC11322
#    [Timeout]    30min
#    [Setup]    CB006590 Setup For AIC vDU
#    Configure Common UPlane CPlane Tracing for vDU
#    [Teardown]    CB006590 Teardown For AIC
