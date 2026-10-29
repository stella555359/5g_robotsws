from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase


class GalaxyS23Factory(AdbUeBase):

    def __init__(self, id_):
        super(GalaxyS23Factory, self).__init__(id_)
        self.name = f"UE_{self.id}: Samsung Galaxy S23 {self.ue_sn}"
        self.vonr_active = "mVoiceRegState=0(IN_SERVICE)"
        self.vonr_status_cmd = f"adb -s {self.ue_sn} shell 'dumpsys telephony.registry | grep -m1 mVoiceRegState'"

    def get_vonr_status(self):
        return self.vonr_active in self._execute_adb_command(self.vonr_status_cmd)
