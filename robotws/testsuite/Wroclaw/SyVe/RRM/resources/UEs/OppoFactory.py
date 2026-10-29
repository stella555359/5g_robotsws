from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase


class OppoFactory(AdbUeBase):

    def __init__(self, id_):
        super(OppoFactory, self).__init__(id_)
        self.name = "UE_{}: OPPO {}".format(self.id, self.ue_sn)
