from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase


class GalaxyS20Factory(AdbUeBase):

    def __init__(self, id_):
        super(GalaxyS20Factory, self).__init__(id_)
        self.name = "UE_{}: Samsung Galaxy S20 {}".format(self.id, self.ue_sn)
