*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for RU Resiliency testing

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM     #Organization
...      TA_LEVEL_22                 #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout
Library     SSHLibrary

*** Variables ***

${TestLine_Name}          10_5_UTESRAN028T36955
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241016_000001
&{UE_INFO}                R3CRC011CQD=350166285465436    RFCNC0RNFJH=353158260231187
${serials}                R3CRC011CQD

*** Test Cases ***
RU Resiliency
    [Tags]    QC_63471    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     Author: jun.6.ma@nokia-sbell.com
    ...     this is the case run in TMO-58 testline whose BTS ID is 37548
    [Setup]    Common Test Setup For RRM
    Parameter_Update          # parameter update, feature activation in controlled scenario
    Get_Parameters            # parameter check
    Log to console    \n Begin to reset bbmod
    BTS Operation    operation=bbmod_reset     product_type=gnb    bts_index=0    distname_id=BBMOD-1      need_verify=yes
    sleep    10s
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n BBMOD Reset Done and Cells onAir
    sleep    10s
    log to console    \n Start to collect Snapshot
    Collect Coam Snapshot    name=RU_Resiliency_CB010846_AHFIB_BBMODReset
    log to console    \n Snapshot collected... Case END
    [Teardown]    Teardown_for_Ru_Resiliency

*** Keywords ***
Teardown_for_Ru_Resiliency
    Get SCF Internal Id By Scout    no_ute=False
    #Common Test Teardown For RRM
Parameter_Update
    @{para_list}      Create List     actRuResetResiliency        cntrldResetMplaneBreakTime
    @{mo_list}        Create List     MRBTS-37548/MNL-1/MNLENT-1/FEATCADM-1       MRBTS-37548/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List     true        220||300||600
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...     para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    \n >>> Paramter update result: ${out}
Get_Parameters
    @{para_list}    Create List   cntrldResetMplaneBreakTime
    @{mo_list}      Create List   MRBTS-37548/MNL-1/MNLENT-1/FEATCADM-1
    ${out}          Parameter Operation    operation=parameter_value_check   product_type=gnb
    ...     para_list=${para_list}    mo_list=${mo_list}
    Log To Console    \n >>> Parameter Check Result: ${out}