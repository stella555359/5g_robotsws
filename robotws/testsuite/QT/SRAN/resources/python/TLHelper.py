from taf.config.testline.gnb.gnb import ClassicalBts, CloudBts
from taf.config.testline.ue import Airphone, Prisma, TM500, Qualcomm, MediaTek, Android


class TLHelper(object):
    """
    Class used for getting variables from testline_configuration_5G needed to launch specific keywords in QT scope.
    """

    def __init__(self, testline):
        self.testline = testline
        self.my_ues = []

    @property
    def dus(self):
        return self.testline.gnbs[0].dus if self.is_cloud() else self.testline.gnbs[0].du

    @property
    def ues(self):
        return self.testline.ues

    @property
    def ue_types(self):
        return dict(airphone=Airphone, prisma=Prisma, viavi=TM500, qualcomm=Qualcomm, oneplus=Android, samsung=Android,
                    petrus=Android, askey=Android)

    def is_cloud(self):
        return True if isinstance(self.testline.gnbs[0], CloudBts) else False

    def is_classical(self):
        return True if isinstance(self.testline.gnbs[0], ClassicalBts) else False

    def is_multidu(self):
        if self.is_cloud() and self.has_du():
            return True if len(self.dus) > 1 else False
        else:
            return False

    def has_ue(self):
        if self.ues:
            return True
        else:
            print('No UE defined in testline object.')
            return False

    def has_du(self):
        if self.dus:
            return True
        else:
            print('No DU defined in testline object.')
            return False

    def get_ues(self):
        for ue in self.ues:
            for k, v in self.ue_types.items():
                if isinstance(ue, v):
                    if isinstance(ue, Android):
                        self.my_ues.append(ue.ue_type)
                    else:
                        self.my_ues.append(k)
        return self.ue_types

    def define_ue(self):
        if self.has_ue():
            self.get_ues()
            return self.my_ues[0]
        else:
            return None
