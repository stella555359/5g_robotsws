from testsuite.Wroclaw.SyVe.RRM.resources.UEs.XiaomiMi11Factory import XiaomiMi11Factory


class XiaomiMi12Factory(XiaomiMi11Factory):

    def __init__(self, id_):
        super(XiaomiMi12Factory, self).__init__(id_)
        self.name = f"UE_{self.id}: Xiaomi Mi 12 {self.ue_sn}"
