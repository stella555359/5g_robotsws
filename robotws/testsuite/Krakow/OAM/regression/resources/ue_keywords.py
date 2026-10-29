from taf.rfrl.ue.custom_ues import AndroidUe


def attach_ue_via_adb(airplane_mode_coordinates, ue_id=0):
    ue = AndroidUe(ue_id=ue_id, airplane_mode_coordinates=airplane_mode_coordinates)
    ue.attach_ue()


def detach_ue_via_adb(airplane_mode_coordinates, ue_id=0):
    ue = AndroidUe(ue_id=ue_id, airplane_mode_coordinates=airplane_mode_coordinates)
    ue.detach_ue()
