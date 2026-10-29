*** Settings ***
Documentation
...    Author: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Maintainer: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_OPERABILITY_PM_GMS
...    References: doors
...    Feature Description: CB012803
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/CB012803/path.robot

Library        String
Library        Telnet
Library        BuiltIn
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn

Library      ta5g_testline_management
#Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta_pcmd



Resource    ../../../../ET/BOAM_VERIF_ET2/resources/pretest_posttest.robot
Resource    ../../../../ET/BOAM_VERIF_ET2/resources/system.robot
Resource    ../../../../ET/BOAM_VERIF_ET2/resources/AirPhone/resources/ute/ute_wts_runner.robot
#Resource    ../../../../ET/BOAM_VERIF_ET1/resources/admin_infomodel.robot

*** Variables ***
${scf_default}=                        ${CURDIR}/scf_AEQE.xml

*** Keywords ***
Full_Commissioning
    FOR    ${i}    IN RANGE    1    101
        Log To Console    Perform commissioning on BTS
        ADMIN Perform Commissioning
        ...     scf_file=${scf_default}
        ...     skip_parameter_relation_errors=True
        Sleep    10
        Log To Console    Iteration ${i} - Waiting for BTS onAir
        Wait Until Keyword Succeeds    900    30    admin_infomodel.ADMIN INFOMODEL Check If BTS Is OnAir
    END

