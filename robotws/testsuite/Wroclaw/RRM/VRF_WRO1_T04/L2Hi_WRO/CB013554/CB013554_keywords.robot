*** Settings ***
Documentation
...    This file contains general keywords used for testing Feature CB013554.

*** Keywords ***
Enable CB0013554-B1 Parameters
    Enable PMQAP Counters Both
    Enable Minrf1uinterfacedupmqap
    Enable Pdcp F1u And X2u Measurments
    Enable Actiptput

Enable CB0013554-B2 Parameters
    Enable 1354-A
    Enable Tput Counters
    Enable PMQAP Counters Both
    Enable Pdcp F1u And X2u Measurments

Enable CB0013554-ENDC Parameters
    Enable Data Split Mode Over X2
    Enable PMQAP Counters NSA
    Enable Pdcp And Rlc Counters Update At NRPMQAP Level
    Enable Pdcp F1u And X2u Measurments

Enable Actiptput
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_actIpThpt.json
    BuiltIn.Sleep    60s    #time for Cplane

Enable Minrf1uinterfacedupmqap
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_miNrF1UInterfaceDUPmqap.json

Enable 1354-A
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-A_On.json

Enable Duplication
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_NRDRB-3_actX2DuplicateTxNSA3x.json

Enable HO
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas_TDD_FDD.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_NSA_mobility.json

Enable BBPooling
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_BBPooling.json
    Wait For GNB Configured State

Disable actDDDSPeriodOptimization
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_disable_actDDDSPeriodOptimization.json
    BuiltIn.Sleep    60s    #time for Cplane

Disable actDlTxResumeOnPdcpStatRep
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_NRDRB-6_disable_actDlTxResumeOnPdcpStatRep.json