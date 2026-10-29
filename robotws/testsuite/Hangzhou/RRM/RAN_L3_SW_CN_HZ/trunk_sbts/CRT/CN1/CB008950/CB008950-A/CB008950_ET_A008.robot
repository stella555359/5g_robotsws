*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-dandan.chen    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${CaSup}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{PARAMS_IN_SWCONFIG_AP}    0x5C0009=1

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_A1sCellAdd_A2_for_NRCELL}
...    @{PARAMS_FOR_CA}
...    NRCELL-11:cellDepType=SA
...    delete:NRCELL-11:configuredEpsTac

@{PARAMS_FOR_NRCELL11_6_NRREL}
...    delete:NRCELL-11/NRREL-1
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:nrDcAllowed=false
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=1
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:nrDcAllowed=false
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-18:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-18:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-18:gNbId=1
...    NRCELL-11/NRREL-18:gNbIdLength=22
...    NRCELL-11/NRREL-18:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-18:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-18:lcrId=18
...    NRCELL-11/NRREL-18:nrDcAllowed=false
...    NRCELL-11/NRREL-18:removeNotAllowed=false
...    NRCELL-11/NRREL-18:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-18:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-18:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-18:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-18:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-19:gNbId=1
...    NRCELL-11/NRREL-19:gNbIdLength=22
...    NRCELL-11/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-19:lcrId=19
...    NRCELL-11/NRREL-19:nrDcAllowed=false
...    NRCELL-11/NRREL-19:removeNotAllowed=false
...    NRCELL-11/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-19:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-19:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-22:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-22:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-22:gNbId=1
...    NRCELL-11/NRREL-22:gNbIdLength=22
...    NRCELL-11/NRREL-22:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-22:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-22:lcrId=22
...    NRCELL-11/NRREL-22:nrDcAllowed=false
...    NRCELL-11/NRREL-22:removeNotAllowed=false
...    NRCELL-11/NRREL-22:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-22:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-22:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-22:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-22:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-23:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-23:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-23:gNbId=1
...    NRCELL-11/NRREL-23:gNbIdLength=22
...    NRCELL-11/NRREL-23:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-23:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-23:lcrId=23
...    NRCELL-11/NRREL-23:nrDcAllowed=false
...    NRCELL-11/NRREL-23:removeNotAllowed=false
...    NRCELL-11/NRREL-23:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-23:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-23:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-23:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-23:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-12:sCellPrio=5
...    NRCELL-11/NRREL-13:sCellPrio=5
...    NRCELL-11/NRREL-18:sCellPrio=5
...    NRCELL-11/NRREL-19:sCellPrio=5
...    NRCELL-11/NRREL-22:sCellPrio=5
...    NRCELL-11/NRREL-23:sCellPrio=5

@{PARAMS_FOR_NRCELL11_extra_15_NRREL}
...    NRCELL-11/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-15:gNbId=1
...    NRCELL-11/NRREL-15:gNbIdLength=22
...    NRCELL-11/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-15:lcrId=15
...    NRCELL-11/NRREL-15:nrDcAllowed=false
...    NRCELL-11/NRREL-15:removeNotAllowed=false
...    NRCELL-11/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-16:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-16:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-16:gNbId=1
...    NRCELL-11/NRREL-16:gNbIdLength=22
...    NRCELL-11/NRREL-16:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-16:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-16:lcrId=16
...    NRCELL-11/NRREL-16:nrDcAllowed=false
...    NRCELL-11/NRREL-16:removeNotAllowed=false
...    NRCELL-11/NRREL-16:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-16:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-16:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-16:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-16:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-17:gNbId=1
...    NRCELL-11/NRREL-17:gNbIdLength=22
...    NRCELL-11/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-17:lcrId=17
...    NRCELL-11/NRREL-17:nrDcAllowed=false
...    NRCELL-11/NRREL-17:removeNotAllowed=false
...    NRCELL-11/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-20:gNbId=1
...    NRCELL-11/NRREL-20:gNbIdLength=22
...    NRCELL-11/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-20:lcrId=20
...    NRCELL-11/NRREL-20:nrDcAllowed=false
...    NRCELL-11/NRREL-20:removeNotAllowed=false
...    NRCELL-11/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-20:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-21:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-21:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-21:gNbId=1
...    NRCELL-11/NRREL-21:gNbIdLength=22
...    NRCELL-11/NRREL-21:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-21:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-21:lcrId=21
...    NRCELL-11/NRREL-21:nrDcAllowed=false
...    NRCELL-11/NRREL-21:removeNotAllowed=false
...    NRCELL-11/NRREL-21:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-21:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-21:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-21:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-21:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-24:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-24:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-24:gNbId=1
...    NRCELL-11/NRREL-24:gNbIdLength=22
...    NRCELL-11/NRREL-24:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-24:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-24:lcrId=24
...    NRCELL-11/NRREL-24:nrDcAllowed=false
...    NRCELL-11/NRREL-24:removeNotAllowed=false
...    NRCELL-11/NRREL-24:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-24:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-24:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-24:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-24:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-25:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-25:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-25:gNbId=1
...    NRCELL-11/NRREL-25:gNbIdLength=22
...    NRCELL-11/NRREL-25:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-25:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-25:lcrId=25
...    NRCELL-11/NRREL-25:nrDcAllowed=false
...    NRCELL-11/NRREL-25:removeNotAllowed=false
...    NRCELL-11/NRREL-25:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-25:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-25:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-25:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-25:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-26:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-26:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-26:gNbId=1
...    NRCELL-11/NRREL-26:gNbIdLength=22
...    NRCELL-11/NRREL-26:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-26:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-26:lcrId=26
...    NRCELL-11/NRREL-26:nrDcAllowed=false
...    NRCELL-11/NRREL-26:removeNotAllowed=false
...    NRCELL-11/NRREL-26:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-26:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-26:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-26:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-26:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-27:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-27:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-27:gNbId=1
...    NRCELL-11/NRREL-27:gNbIdLength=22
...    NRCELL-11/NRREL-27:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-27:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-27:lcrId=27
...    NRCELL-11/NRREL-27:nrDcAllowed=false
...    NRCELL-11/NRREL-27:removeNotAllowed=false
...    NRCELL-11/NRREL-27:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-27:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-27:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-27:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-27:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-28:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-28:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-28:gNbId=1
...    NRCELL-11/NRREL-28:gNbIdLength=22
...    NRCELL-11/NRREL-28:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-28:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-28:lcrId=28
...    NRCELL-11/NRREL-28:nrDcAllowed=false
...    NRCELL-11/NRREL-28:removeNotAllowed=false
...    NRCELL-11/NRREL-28:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-28:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-28:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-28:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-28:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-29:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-29:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-29:gNbId=1
...    NRCELL-11/NRREL-29:gNbIdLength=22
...    NRCELL-11/NRREL-29:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-29:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-29:lcrId=29
...    NRCELL-11/NRREL-29:nrDcAllowed=false
...    NRCELL-11/NRREL-29:removeNotAllowed=false
...    NRCELL-11/NRREL-29:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-29:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-29:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-29:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-29:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-30:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-30:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-30:gNbId=1
...    NRCELL-11/NRREL-30:gNbIdLength=22
...    NRCELL-11/NRREL-30:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-30:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-30:lcrId=30
...    NRCELL-11/NRREL-30:nrDcAllowed=false
...    NRCELL-11/NRREL-30:removeNotAllowed=false
...    NRCELL-11/NRREL-30:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-30:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-30:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-30:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-30:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-31:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-31:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-31:gNbId=1
...    NRCELL-11/NRREL-31:gNbIdLength=22
...    NRCELL-11/NRREL-31:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-31:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-31:lcrId=31
...    NRCELL-11/NRREL-31:nrDcAllowed=false
...    NRCELL-11/NRREL-31:removeNotAllowed=false
...    NRCELL-11/NRREL-31:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-31:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-31:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-31:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-31:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-32:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-32:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-32:gNbId=1
...    NRCELL-11/NRREL-32:gNbIdLength=22
...    NRCELL-11/NRREL-32:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-32:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-32:lcrId=32
...    NRCELL-11/NRREL-32:nrDcAllowed=false
...    NRCELL-11/NRREL-32:removeNotAllowed=false
...    NRCELL-11/NRREL-32:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-32:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-32:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-32:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-32:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-33:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-33:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-33:gNbId=1
...    NRCELL-11/NRREL-33:gNbIdLength=22
...    NRCELL-11/NRREL-33:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-33:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-33:lcrId=33
...    NRCELL-11/NRREL-33:nrDcAllowed=false
...    NRCELL-11/NRREL-33:removeNotAllowed=false
...    NRCELL-11/NRREL-33:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-33:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-33:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-33:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-33:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-15:sCellPrio=5
...    NRCELL-11/NRREL-16:sCellPrio=5
...    NRCELL-11/NRREL-17:sCellPrio=5
...    NRCELL-11/NRREL-20:sCellPrio=5
...    NRCELL-11/NRREL-21:sCellPrio=5
...    NRCELL-11/NRREL-24:sCellPrio=5
...    NRCELL-11/NRREL-25:sCellPrio=5
...    NRCELL-11/NRREL-26:sCellPrio=5
...    NRCELL-11/NRREL-27:sCellPrio=5
...    NRCELL-11/NRREL-28:sCellPrio=5
...    NRCELL-11/NRREL-29:sCellPrio=5
...    NRCELL-11/NRREL-30:sCellPrio=5
...    NRCELL-11/NRREL-31:sCellPrio=5
...    NRCELL-11/NRREL-32:sCellPrio=5
...    NRCELL-11/NRREL-33:sCellPrio=5

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_FOR_A1sCellAdd_A2_for_NRCELL}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_A008_precondition}
...    @{PARAMS_FOR_8290_SCellSwap_enable}
...    @{PARAMS_FOR_NRCELL11_6_NRREL}
...    @{PARAMS_FOR_NRCELL12_14_configure_NRREL_refer_NRCELL_11}

@{PARAMS_FOR_actFlexSCellSelectFr1_enable_add_extra_NRREL}
...    NRBTS:actFlexSCellSelectFr1=true
...    @{PARAMS_FOR_NRCELL15_33_configure_NRREL_refer_NRCELL_11}
...    @{PARAMS_FOR_NRCELL11_extra_15_NRREL}

@{PARAMS_FOR_8290_SCellSwap_enable}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:weightForSCellSelection=50
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67

@{PARAMS_FOR_NRCELL12_14_configure_NRREL_refer_NRCELL_11}
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:nrDcAllowed=false
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-11:gNbId=1
...    NRCELL-13/NRREL-11:gNbIdLength=22
...    NRCELL-13/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-13/NRREL-11:lcrId=11
...    NRCELL-13/NRREL-11:nrDcAllowed=false
...    NRCELL-13/NRREL-11:removeNotAllowed=false
...    NRCELL-13/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-11:gNbId=1
...    NRCELL-14/NRREL-11:gNbIdLength=22
...    NRCELL-14/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-14/NRREL-11:lcrId=11
...    NRCELL-14/NRREL-11:nrDcAllowed=false
...    NRCELL-14/NRREL-11:removeNotAllowed=false
...    NRCELL-14/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-11:gnbPlmn:mncLength=3

@{PARAMS_FOR_NRCELL15_33_configure_NRREL_refer_NRCELL_11}
...    NRCELL-15/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-15/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-15/NRREL-11:gNbId=1
...    NRCELL-15/NRREL-11:gNbIdLength=22
...    NRCELL-15/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-15/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-15/NRREL-11:lcrId=11
...    NRCELL-15/NRREL-11:nrDcAllowed=false
...    NRCELL-15/NRREL-11:removeNotAllowed=false
...    NRCELL-15/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-15/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-15/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-15/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-15/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-16/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-16/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-16/NRREL-11:gNbId=1
...    NRCELL-16/NRREL-11:gNbIdLength=22
...    NRCELL-16/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-16/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-16/NRREL-11:lcrId=11
...    NRCELL-16/NRREL-11:nrDcAllowed=false
...    NRCELL-16/NRREL-11:removeNotAllowed=false
...    NRCELL-16/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-16/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-16/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-16/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-16/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-17/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-17/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-17/NRREL-11:gNbId=1
...    NRCELL-17/NRREL-11:gNbIdLength=22
...    NRCELL-17/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-17/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-17/NRREL-11:lcrId=11
...    NRCELL-17/NRREL-11:nrDcAllowed=false
...    NRCELL-17/NRREL-11:removeNotAllowed=false
...    NRCELL-17/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-17/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-17/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-17/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-17/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-18/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-18/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-18/NRREL-11:gNbId=1
...    NRCELL-18/NRREL-11:gNbIdLength=22
...    NRCELL-18/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-18/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-18/NRREL-11:lcrId=11
...    NRCELL-18/NRREL-11:nrDcAllowed=false
...    NRCELL-18/NRREL-11:removeNotAllowed=false
...    NRCELL-18/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-18/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-18/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-18/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-18/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-19/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-19/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-19/NRREL-11:gNbId=1
...    NRCELL-19/NRREL-11:gNbIdLength=22
...    NRCELL-19/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-19/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-19/NRREL-11:lcrId=11
...    NRCELL-19/NRREL-11:nrDcAllowed=false
...    NRCELL-19/NRREL-11:removeNotAllowed=false
...    NRCELL-19/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-19/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-19/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-19/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-19/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-20/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-20/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-20/NRREL-11:gNbId=1
...    NRCELL-20/NRREL-11:gNbIdLength=22
...    NRCELL-20/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-20/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-20/NRREL-11:lcrId=11
...    NRCELL-20/NRREL-11:nrDcAllowed=false
...    NRCELL-20/NRREL-11:removeNotAllowed=false
...    NRCELL-20/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-20/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-20/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-20/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-20/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-21/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-21/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-21/NRREL-11:gNbId=1
...    NRCELL-21/NRREL-11:gNbIdLength=22
...    NRCELL-21/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-21/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-21/NRREL-11:lcrId=11
...    NRCELL-21/NRREL-11:nrDcAllowed=false
...    NRCELL-21/NRREL-11:removeNotAllowed=false
...    NRCELL-21/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-21/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-21/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-21/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-21/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-23/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-23/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-23/NRREL-11:gNbId=1
...    NRCELL-23/NRREL-11:gNbIdLength=22
...    NRCELL-23/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-23/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-23/NRREL-11:lcrId=11
...    NRCELL-23/NRREL-11:nrDcAllowed=false
...    NRCELL-23/NRREL-11:removeNotAllowed=false
...    NRCELL-23/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-23/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-23/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-23/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-23/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-24/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-24/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-24/NRREL-11:gNbId=1
...    NRCELL-24/NRREL-11:gNbIdLength=22
...    NRCELL-24/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-24/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-24/NRREL-11:lcrId=11
...    NRCELL-24/NRREL-11:nrDcAllowed=false
...    NRCELL-24/NRREL-11:removeNotAllowed=false
...    NRCELL-24/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-24/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-24/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-24/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-24/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-25/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-25/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-25/NRREL-11:gNbId=1
...    NRCELL-25/NRREL-11:gNbIdLength=22
...    NRCELL-25/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-25/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-25/NRREL-11:lcrId=11
...    NRCELL-25/NRREL-11:nrDcAllowed=false
...    NRCELL-25/NRREL-11:removeNotAllowed=false
...    NRCELL-25/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-25/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-25/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-25/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-25/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-26/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-26/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-26/NRREL-11:gNbId=1
...    NRCELL-26/NRREL-11:gNbIdLength=22
...    NRCELL-26/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-26/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-26/NRREL-11:lcrId=11
...    NRCELL-26/NRREL-11:nrDcAllowed=false
...    NRCELL-26/NRREL-11:removeNotAllowed=false
...    NRCELL-26/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-26/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-26/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-26/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-26/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-27/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-27/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-27/NRREL-11:gNbId=1
...    NRCELL-27/NRREL-11:gNbIdLength=22
...    NRCELL-27/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-27/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-27/NRREL-11:lcrId=11
...    NRCELL-27/NRREL-11:nrDcAllowed=false
...    NRCELL-27/NRREL-11:removeNotAllowed=false
...    NRCELL-27/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-27/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-27/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-27/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-27/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-11:gNbId=1
...    NRCELL-28/NRREL-11:gNbIdLength=22
...    NRCELL-28/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-11:lcrId=11
...    NRCELL-28/NRREL-11:nrDcAllowed=false
...    NRCELL-28/NRREL-11:removeNotAllowed=false
...    NRCELL-28/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-28/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-29/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-29/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-29/NRREL-11:gNbId=1
...    NRCELL-29/NRREL-11:gNbIdLength=22
...    NRCELL-29/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-29/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-29/NRREL-11:lcrId=11
...    NRCELL-29/NRREL-11:nrDcAllowed=false
...    NRCELL-29/NRREL-11:removeNotAllowed=false
...    NRCELL-29/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-29/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-29/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-29/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-29/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-30/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-30/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-30/NRREL-11:gNbId=1
...    NRCELL-30/NRREL-11:gNbIdLength=22
...    NRCELL-30/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-30/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-30/NRREL-11:lcrId=11
...    NRCELL-30/NRREL-11:nrDcAllowed=false
...    NRCELL-30/NRREL-11:removeNotAllowed=false
...    NRCELL-30/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-30/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-30/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-30/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-30/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-31/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-31/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-31/NRREL-11:gNbId=1
...    NRCELL-31/NRREL-11:gNbIdLength=22
...    NRCELL-31/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-31/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-31/NRREL-11:lcrId=11
...    NRCELL-31/NRREL-11:nrDcAllowed=false
...    NRCELL-31/NRREL-11:removeNotAllowed=false
...    NRCELL-31/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-31/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-31/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-31/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-31/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-32/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-32/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-32/NRREL-11:gNbId=1
...    NRCELL-32/NRREL-11:gNbIdLength=22
...    NRCELL-32/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-32/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-32/NRREL-11:lcrId=11
...    NRCELL-32/NRREL-11:nrDcAllowed=false
...    NRCELL-32/NRREL-11:removeNotAllowed=false
...    NRCELL-32/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-32/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-32/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-32/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-32/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-33/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-33/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-33/NRREL-11:gNbId=1
...    NRCELL-33/NRREL-11:gNbIdLength=22
...    NRCELL-33/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-33/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-33/NRREL-11:lcrId=11
...    NRCELL-33/NRREL-11:nrDcAllowed=false
...    NRCELL-33/NRREL-11:removeNotAllowed=false
...    NRCELL-33/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-33/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-33/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-33/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-33/NRREL-11:gnbPlmn:mncLength=3

@{NRCELL_18_maxNumOfSCellAlloc_set_0}
...    NRCELL-18:maxNumOfSCellAlloc=0

@{A008_recover_parameter}
...    NRCELL-18:maxNumOfSCellAlloc=250

@{NRCELL_18_maxNumOfSCellAlloc_set_250}
...    NRCELL-18:maxNumOfSCellAlloc=250

#3CC band66 band25 band25
${SA_Capa_A008}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C8000E00365FFFE5FFFE0541B10758636869315020F2CA4
...    D1068032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B90001C006D2AAA92AAA80AA3626EB04610D
...    04083A41A00B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FFC00170000381506C18D608CA1A0810796526CA0D0
...    0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001720003800DA555525555015C6C25D608C21A08107
...    483401B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8002E0000702A8D899AC1184341020E90680
...    2CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0541B11B582308682041F28340195B262AC4873E2
...    38F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000005C0000E008BC3C41000E230000000B0102F0F09400389A0000042C040
...    BC5C28000E2080071180000105808178B830001C41000E268000030B0102F0F0A000389A0000102C040B83C28000E208000050B0102F0F10
...    400388C0000182C040BC3C41000E268000070B0102F170A0003882001C41000010160205E2E14000711800388C0000242C040BC3C46000E2
...    680000C0B0102F17060003830001C4100001A160227DE3E208007130003898001C4C00001C160205E2E20800713400389A00003C2C040BC7
...    C41000E20800713400389A0000402C040A01C280000220078B830001C41000E128000030B01020120234028809B01060260BA00698461448
...    9B1CF870A244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E
...    7C3851226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8700D861C08902040D8E7C30D898C6318C6318C6318C
...    6318C63F417001E00140E0A00E0601280380030120020301F02001000000008000010040000100200000C010000080080000500400003002
...    00001C01000010047062F2A2F262F266F066F062F066F2A6F26680E0C000000C000300002030000C000100C000300006030000C000200C00
...    030000A030000C000300C00030000E0300003F83417CAA0BE4D05F2382F83417C1A0BE0D05F2A8285801200340A001108080100202004008
...    4040200401004008402008010080100202004008804028050100E01C04040080808030060200801040401002010020042020100200801002
...    1010020040401002100802004020040080801002201004008040080101002004402004008080100202004008804008010100200404008010
...    808010020200801080C0300680500A060180340280503002006004008C0C0080180700206020014010020300600E024018180300701200C4
...    0201C008080900602024018C04038010100E00404048030101200C002008010D50F8000810182030385058606880889098A0C0C8D8E0E8F9
...    09293139414951697A0A0C1680

@{3CC_NRCELL_11_scell_NRCELL_20_22}
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:69, scellIdx:1] configure_1_1
...    pcid:71, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{3CC_NRCELL_11_scell_NRCELL_20_24}
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:69, scellIdx:1] configure_1_1
...    pcid:73, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{3CC_NRCELL_11_scell_NRCELL_18_25}
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:67, scellIdx:1] configure_1_1
...    pcid:74, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{3CC_NRCELL_11_scell_NRCELL_19_22}
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:68, scellIdx:1] configure_1_1
...    pcid:71, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{3CC_NRCELL_11_scell_NRCELL_21_23}
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:70, scellIdx:1] configure_1_1
...    pcid:72, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{2CC_NRCELL_21_scell_NRCELL_11}
...    pcid:70, scellIdx:0] configure_0_1
...    pcid:70, scellIdx:0] configure_1_1
...    pcid:60, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{1CC_NRCELL_21}
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1

@{A008_PM_Counters_Check}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=6
...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=6
...    NRCELL-11:NCAC:${RRC_RECONF_ADD2DLSCELL_ATT_SA}=6
...    NRCELL-11:NCAC:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}=6
...    NRCELL-11:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:RSACU:${GNB_SCELL_2_ADMI_REQ_SA}=6
...    NRCELL-11:RSACU:${GNB_SCELL_2_ADMI_SUCC_SA}=6
...    NRCELL-18:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-19:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-20:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-21:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-22:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-23:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-24:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-21:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-21:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-21:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1
...    NRCELL-21:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
...    NRCELL-21:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-21:RSACU:${GNB_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-21:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=1

${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07003
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07004
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
${GNB_SCELL_2_ADMI_REQ_SA}    M55138C02501
${GNB_SCELL_2_ADMI_SUCC_SA}    M55138C02502
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505
${RRC_RECONF_ADD1DLSCELL_SUCC_SA}    M55118C05506
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502

*** Test Cases ***
CB008950-ET-A008_scell_selection_during_A1_with_equal_Scellprio_for_SA_intragNB_CA_RAC_failure_as_maxNumOfScellAlloc_and_cell_lock
    [Documentation]
    ...    1. This user scenario validates the SCell selection for SA UE among same frequency SCell candidates when there
    ...    are more than 2 SCell candidates on the same SCell carrier frequency, NRREL/sCellPrio is set to equal value and
    ...    A1 based SCell addition method is applied. gNB uses a round robin approach as in CB008290 to determine the
    ...    preferred SCell each time it selects the frequency for SCell Addition or SCell change.
    ...    2. Configuration
    ...    24FDD cell detail:
    ...                       Cell-11  Cell-12_13  cell14  cell15-17  Cell-18-21  Cell-22-25  Cell-26-29  Cell-30-33 cell34
    ...          Band          n66     n66          n66       n66       n25        n25          n71         n71       n66
    ...           Pci          60      61_62        63        64-66     67-70      71-74         75-78       79-82    83
    ...     Bandwidth          10      10           10        20        20         20            15         10        10
    ...          gscn         5300    5397         5429       5350      4872       4931          1566       1603      5300
    ...         Ssbfreq      424090   431790      434410    427970    389790      394570       125310      128210    424090
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. precondition: make a background UE85 on NRCELL-11 to test the online will not result cellreset
    ...           under NRCELL-11, configure 6 NRREL refer to cell_12/13 on F2, cell18/19 on F3, cell22/23 on F4.
    ...           sCellPrio are all equal.
    ...            nrcell-12/13/14 configure nrcell-11 as scell.
    ...           b. actFlexSCellSelectFr1 enable
    ...           under NRCELL-11, configure more 15 NRREL:
    ...           cell20/21 on F3, cell24/25/26/27 on F4, cell28/29/30/31 on F5, cell32/33 on F6, cell15/16/17on F7
    ...           nrcell15-33 configured NRCELL-1 as scell
    ...           c. NRCELL_18_maxNumOfSCellAlloc_set_0 and Lock Cell19
    ...           d. Attach 3UE covbasedA1 to test roundrobin when nrcell-18-19 not working
    ...           UE81 FFF 3CC_NRCELL_11_scell_NRCELL_20_22, traffic is ok. then release
    ...           UE82 FFF 3CC_NRCELL_11_scell_NRCELL_21_23, traffic is ok. then release
    ...           UE83 FFF 3CC_NRCELL_11_scell_NRCELL_20_24, traffic is ok. then release
    ...           e. UE84 FF blindly 2CC_NRCELL_21_scell_NRCELL_11 to test nrcell-11 can be scell
    ...           f. NRCELL_18_maxNumOfSCellAlloc_set_250 and unLock Cell19
    ...           g. Attach 3UE covbasedA1 to test roundrobin when nrcell-18-19 not working
    ...           UE81 FFF 3CC_NRCELL_11_scell_NRCELL_18_25, traffic is ok. then release
    ...           UE82 FFF 3CC_NRCELL_11_scell_NRCELL_19_22, traffic is ok. then release
    ...           UE83 FFF 3CC_NRCELL_11_scell_NRCELL_21_23, traffic is ok. then release
    ...           h: check UE84/85 are still alive.
    ...           i: counter is as expected value.

    [Tags]    A008    QC_325405    CA_LABEL-3F(10Mhz_n66_20M_n25_20M_n25)
    Precondition for CB008950 A008
    Delta Commission Parameters    ${NRCELL_18_maxNumOfSCellAlloc_set_0}
    Lock Cell19
    Attach 3UE to test roundrobin when nrcell-18-19 not working
    UE attach and Scell added blindly    ue_id=84    CC_num=2    UE_Capabilities=${SA_Capa_A008}
    ...    DLTput_expect=135    expect_regexp=${2CC_NRCELL_21_scell_NRCELL_11}
    Delta Commission Parameters    ${NRCELL_18_maxNumOfSCellAlloc_set_250}
    unlock cell and check cell on air
    Attach 3UE to test roundrobin when nrcell-18-19 working
    Check Throughput with Type    ue_id=84    Tput_expect=90    CC_num=2    type=pdsch
    Check Throughput with Type    ue_id=85    Tput_expect=7    CC_num=1    type=pdsch
    Check Counters    ${A008_PM_Counters_Check}
    [Teardown]    Teardown for CB008950    ${A008_recover_parameter}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/FS/24cells

Precondition for CB008950 A008
    Clear Counter files    True
    UE attach and Scell added blindly    ue_id=85    CC_num=1    cell_id=11    UE_Capabilities=${SA_Capa_A008}
    ...    expect_regexp=${1CC_NRCELL_21}    dl_traffic=10    DLTput_expect=7
    OnlineParamChange    ${PARAMS_FOR_A008_precondition}
    OnlineParamChange    ${PARAMS_FOR_actFlexSCellSelectFr1_enable_add_extra_NRREL}

unlock cell and check cell on air
    Unlock Cell19
    Cells Should Be Onair    check_sib=${False}

Attach 3UE to test roundrobin when nrcell-18-19 not working
    UE attach and Scell added covebasedA1    ue_id=81    UE_Capabilities=${SA_Capa_A008}    expect_regexp=${3CC_NRCELL_11_scell_NRCELL_20_22}
    UE attach and Scell added covebasedA1    ue_id=82    UE_Capabilities=${SA_Capa_A008}    expect_regexp=${3CC_NRCELL_11_scell_NRCELL_21_23}
    UE attach and Scell added covebasedA1    ue_id=83    UE_Capabilities=${SA_Capa_A008}    expect_regexp=${3CC_NRCELL_11_scell_NRCELL_20_24}

Attach 3UE to test roundrobin when nrcell-18-19 working
    UE attach and Scell added covebasedA1    ue_id=81    UE_Capabilities=${SA_Capa_A008}    expect_regexp=${3CC_NRCELL_11_scell_NRCELL_18_25}
    UE attach and Scell added covebasedA1    ue_id=82    UE_Capabilities=${SA_Capa_A008}    expect_regexp=${3CC_NRCELL_11_scell_NRCELL_19_22}
    UE attach and Scell added covebasedA1    ue_id=83    UE_Capabilities=${SA_Capa_A008}    expect_regexp=${3CC_NRCELL_11_scell_NRCELL_21_23}

Teardown for CB008950
    [Arguments]    ${Restore_params}
    Unlock Cell19
    Delta Commission Parameters    ${Restore_params}
    Cells Should Be Onair    check_sib=${False}
    Common Test Teardown And Stop Capture Logs

UE attach and Scell added covebasedA1
    [Arguments]    ${ue_id}=1    ${CC_num}=3    ${UE_Capabilities}=${SA_Capa_A008}    ${expect_regexp}=${3CC_NRCELL_11_scell_NRCELL_20_22}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    cell_id=11    expect_regexp=${expect_regexp}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=135    CC_num=${CC_num}    type=pdsch
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=13    CC_num=1    type=pusch
    Release UE    ue_id=${ue_id}

UE attach and Scell added blindly
    [Arguments]    ${ue_id}=1    ${CC_num}=2    ${UE_Capabilities}=${SA_Capa_A008}    ${cell_id}=21
    ...    ${expect_regexp}=${2CC_NRCELL_21_scell_NRCELL_11}    ${dl_traffic}=150    ${DLTput_expect}=60    ${ULTput_expect}=13
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    SA CA UE Setup PDU Session And Check CA Addition blindly Successfully    ue_id=${ue_id}    cell_id=${cell_id}    expect_regexp=${expect_regexp}
    Traffic Send    ue_id=${ue_id}    dl_traffic=${dl_traffic}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=${DLTput_expect}    CC_num=${CC_num}    type=pdsch
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=${ULTput_expect}    CC_num=1    type=pusch

Release UE
    [Arguments]    ${ue_id}=1
    Release Ues    ue_type=sa    ue_id=${ue_id}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session And Check CA Addition Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=${EMPTY}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    Initial Context Setup Successful
    UE Send A1 Trigger Scell Addition    ${ue_id}    424090    ${expect_regexp}

SA CA UE Setup PDU Session And Check CA Addition blindly Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=${EMPTY}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}

Traffic Send
    [Arguments]    ${ue_id}=1    ${dl_traffic}=150
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=${dl_traffic}    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=15    UE ${ue_id}: UDP UL

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_A008}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}


