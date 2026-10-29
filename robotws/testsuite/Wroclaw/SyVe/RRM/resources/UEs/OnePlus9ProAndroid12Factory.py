from testsuite.Wroclaw.SyVe.RRM.resources.UEs.OnePlus9ProFactory import OnePlus9ProFactory


class OnePlus9ProAndroid12Factory(OnePlus9ProFactory):

    def __init__(self, id_):
        super(OnePlus9ProAndroid12Factory, self).__init__(id_)
        self.name = "UE_{}: OnePlus 9 Pro (Android 12) {}".format(self.id, self.ue_sn)
        self.airplane_button_location = '974', '376'
