from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TafUeFactory import TafUeFactory


class UteUeFactory(TafUeFactory):

    def __init__(self, id_, capabilities):
        super(UteUeFactory, self).__init__(id_, capabilities)
        self.name = "UE_{}".format(id_)
        self.alias = "UE_{}".format(id_)
        self.lib_ = "ute_ue"
