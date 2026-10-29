MEAS_PROFILE_5QI_1 = ("nr-rrc.rrcReconfiguration_element && nr-rrc.drb_ToAddModList == 1 && nr-rrc.drb_Identity == 5"
                      " && nr-rrc.hysteresis == 2 && nr-rrc.timeToTrigger == 5 &&"
                      "nr-rrc.measTriggerQuantity.rsrp == 10 && nr-rrc.measTriggerQuantityOffset.rsrp == 10 &&"
                      "nr-rrc.measTriggerQuantity.rsrp == 10 && nr-rrc.measTriggerQuantity.rsrp == 11")
MEAS_PROFILE_5QI_9 = ("nr-rrc.rrcReconfiguration_element && nr-rrc.hysteresis == 4 && nr-rrc.timeToTrigger == 7 && "
                      "nr-rrc.measTriggerQuantity.rsrp == 20 && nr-rrc.measTriggerQuantityOffset.rsrp == 22 && "
                      "nr-rrc.measTriggerQuantity.rsrp == 20 && nr-rrc.measTriggerQuantity.rsrp == 22")
A_B12 = [MEAS_PROFILE_5QI_1, [MEAS_PROFILE_5QI_9, 2]]
MEAS_PROFILE_ALT_5QI_1 = ("nr-rrc.rrcReconfiguration_element && nr-rrc.drb_ToAddModList == 1 && "
                          "nr-rrc.drb_Identity == 6 && nr-rrc.hysteresis == 2 && nr-rrc.timeToTrigger == 5 && "
                          "nr-rrc.measTriggerQuantity.rsrp == 10 && nr-rrc.measTriggerQuantityOffset.rsrp == 10 && "
                          "nr-rrc.measTriggerQuantity.rsrp == 10 && nr-rrc.measTriggerQuantity.rsrp == 11")
MEAS_PROFILE_DEFAULT = ("nr-rrc.rrcReconfiguration_element && nr-rrc.drb_ToReleaseList == 1 && "
                        "nr-rrc.DRB_Identity == 6 && nr-rrc.measTriggerQuantity.rsrp == 45 && "
                        "nr-rrc.hysteresis == 2 && nr-rrc.timeToTrigger == 9 && "
                        "nr-rrc.measTriggerQuantityOffset.rsrp == 8 && nr-rrc.timeToTrigger == 11 && "
                        "nr-rrc.measTriggerQuantity.rsrp == 46 && nr-rrc.measTriggerQuantity.rsrp == 48 && "
                        "nr-rrc.timeToTrigger == 8")
A_B12_ALT = [MEAS_PROFILE_ALT_5QI_1, MEAS_PROFILE_DEFAULT]
SYSLOG_MOBILITY_PROFILE = ["Mobility profile selected: Profile 1",
                           "Using a2MeasEnabled (true) from mobility profile."]
