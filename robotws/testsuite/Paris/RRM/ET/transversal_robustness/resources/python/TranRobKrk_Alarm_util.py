import alarms_handler as Almh
import emss_handler as Emsh
import os


def change_cells_parameter_without_gNB_reset():
    Almh.almw.check_detected_alarms()
    Almh.almw.allow_alarm(alarm_id="7115", fault_id="7313", fault_name="NgGnbInitPartialReset")
    Emsh.emss.configure("[{'MOC': 'NRCELL', 'ID': '1', 'actCDrx': 'true'}, "
                        "{'MOC': 'NRCELL', 'ID': '2', 'actDynUlResAlloc': 'true'}, "
                        "{'MOC': 'NRCELL', 'ID': '3', 'actUlDftSOfdm': 'true'}, "
                        "{'MOC': 'NRCELL', 'ID': '4', 'actVoNR': 'true'}]")
    Almh.almw.check_detected_alarms()
    Emsh.emss.configure("[{'MOC': 'NRCELL', 'ID': '1', 'actCDrx': 'false'}, "
                        "{'MOC': 'NRCELL', 'ID': '2', 'actDynUlResAlloc': 'false'}, "
                        "{'MOC': 'NRCELL', 'ID': '3', 'actUlDftSOfdm': 'false'}, "
                        "{'MOC': 'NRCELL', 'ID': '4', 'actVoNR': 'false'}]")
    Almh.almw.check_detected_alarms()
    Almh.almw.disallow_alarm(alarm_id="7115", fault_id="7313", fault_name="NgGnbInitPartialReset")


def change_cells_parameter_with_gNB_reset():
    Almh.almw.check_detected_alarms()
    Almh.almw.allow_alarm(alarm_id="7115", fault_id="7313", fault_name="NgGnbInitPartialReset")
    Almh.almw.allow_alarm(alarm_id="7115", fault_id="7312", fault_name="NgGnbInitFullReset")
    # BHR begin 19/09/2024: allow this alarm as WA till issue is prechecked or fixed
    # BHR begin 04/11/2024: Comment following lines, alarm is no more flow control for FIDs here bollow
    # Almh.almw.allow_alarm(alarm_id="7101", fault_id="1900",
    #                             fault_name="Radio autonomous reset as recovery action")
    # Almh.almw.allow_alarm(alarm_id="7115",
    #                                         fault_id="4602", fault_name="5G cell configuration mismatch")
    # BHR end

    # Emsh.emss.configure("{'MOC': 'NRCELL', 'ID': '1', 'nrCellType': '2DL2UL'}")
    Emsh.emss.configure("{'MOC': 'NRCELL', 'ID': '1', 'timingAdvanceOffset': 'n39936'}")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-1", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-2", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-3", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-4", attribute_name="operationalState",
                                              value="enabled")
    Almh.almw.check_detected_alarms()

    # Emsh.emss.configure("{'MOC': 'NRCELL', 'ID': '1', 'nrCellType': '4DL4UL'}")
    Emsh.emss.configure("{'MOC': 'NRCELL', 'ID': '1', 'timingAdvanceOffset': 'n25600'}")
    # BHR begin 04/11/2024: Comment following lines, alarm is no more flow control for FIDs here bellow
    # try:
    #     Almh.almw.allow_alarm(alarm_id="7116", fault_id="10", fault_name="No connection to unit")
    #     Almh.almw.wait_for_active_alarm(alarm_id="7116", fault_id="10", fault_name="No connection to unit",
    #                                           timeout="10min")
    # except AlarmInactive:
    #    pass
    # else:
    #    with admin_connection() as adminconn:
    #         Almh.almw.allow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    #         Emsh.adminconn.reset(reset_coverage="Site", wait_for_reconnection=False, timeout=600)
    # BHR end
    Almh.almw.check_detected_alarms()

    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-1", attribute_name="operationalState",
                                              value="enabled", timeout=600)
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-2", attribute_name="operationalState",
                                              value="enabled", timeout=600)
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-3", attribute_name="operationalState",
                                              value="enabled", timeout=600)
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-4", attribute_name="operationalState",
                                              value="enabled", timeout=600)
    Emsh.emss.wait_for_enb_on_air()
    Almh.almw.check_detected_alarms()

    # BHR begin 04/11/2024: Commented following lines following alarm has not been allowed before
    # Almh.almw.disallow_alarm(alarm_id="7116", fault_id="10", fault_name="No connection to unit")
    # Almh.almw.disallow_alarm(alarm_id="7114", fault_id="1868",
    #                                 fault_name="BTS configuration error (not enough HW for LCR)")
    # BHR end
    Almh.almw.disallow_alarm(alarm_id="7115", fault_id="7313", fault_name="NgGnbInitPartialReset")
    Almh.almw.disallow_alarm(alarm_id="7115", fault_id="7312", fault_name="NgGnbInitFullReset")
    # BHR begin 19/09/2024: allow this alarm as WA till issue is prechecked or fixed
    # BHR begin 04/11/2024: Comment following lines, alarm is no more flow control for FIDs here bollow
    # Almh.almw.disallow_alarm(alarm_id="7101", fault_id="1900",
    #                                fault_name="Radio autonomous reset as recovery action")
    # Almh.almw.disallow_alarm(alarm_id="7115", fault_id="4602", fault_name="5G cell configuration mismatch")
    # BHR end
    # BHR end
    Almh.almw.check_detected_alarms()


def change_gNB_parameter_with_gNB_reset():
    Almh.almw.check_detected_alarms()
    Almh.almw.allow_alarm(alarm_id="7115", fault_id="7312", fault_name="NgGnbInitFullReset")
    # BHR begin 04/11/2024: Comment following lines, alarm is no more allowed
    # Almh.almw.allow_alarm(alarm_id="7101", fault_id="1900",
    #                            fault_name="Radio autonomous reset as recovery action")
    # BHR end.

    Emsh.emss.configure_and_wait("{'MOC': 'NRBTS', 'ID': '1', 'actGnbInitRlf': 'false'}")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-1", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-2", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-3", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-4", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_enb_on_air()
    Almh.almw.check_detected_alarms()

    Emsh.emss.configure_and_wait("{'MOC': 'NRBTS', 'ID': '1', 'actGnbInitRlf': 'true'}")
    # BHR begin 04/11/2024: Comment following lines, alarm is no more flow control for FIDs here bellow
    # try:
    #     Almh.almw.allow_alarm(alarm_id="7116", fault_id="1900", fault_name="RF module configuring failed")
    #     Almh.almw.wait_for_active_alarm(alarm_id="7116", fault_id="1900",
    #                                           fault_name="RF module configuring failed", timeout="10min")
    # except AlarmInactive:
    #     pass
    # else:
    #     with Emsh.admin_connection() as adminconn:
    #         Almh.almw.allow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    #         adminconn.reset(reset_coverage="Site", wait_for_reconnection=False, timeout=600)
    # BHR end
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-1", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-2", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-3", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-4", attribute_name="operationalState",
                                              value="enabled")
    Emsh.emss.wait_for_enb_on_air()
    Almh.almw.check_detected_alarms()

    Almh.almw.disallow_alarm(alarm_id="7115", fault_id="7312", fault_name="NgGnbInitFullReset")
    # BHR begin 04/11/2024: Comment following lines, alarm is no more allowed
    # Almh.almw.disallow_alarm(alarm_id="7101", fault_id="1900",
    #                                fault_name="Radio autonomous reset as recovery action")
    # BHR end
    # BHR begin 04/11/2024: Comment following lines, alarm is no more flow control for FIDs here bellow
    # Emsh.almw.disallow_alarm(alarm_id="7116", fault_id="1900", fault_name="RF module configuring failed")
    # Emsh.almw.disallow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    # BHR end
