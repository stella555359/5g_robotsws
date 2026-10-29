from testsuite.Wroclaw.SyVe.RRM.resources.UEs.GalaxyS21UltraFactory import GalaxyS21UltraFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.Nokia83Factory import Nokia83Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.OnePlus9ProFactory import OnePlus9ProFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.OnePlus9ProAndroid12Factory import OnePlus9ProAndroid12Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TafUeFactory import TafUeFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UteUeFactory import UteUeFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AskeyAtAdbFactory import AskeyAtAdbFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.QualcommSdx65Factory import QualcommSdx65Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.QualcommSdx55Factory import QualcommSdx55Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.SmWaveAtFactory import SmWaveAtFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.XiaomiMi11Factory import XiaomiMi11Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.XiaomiMi12Factory import XiaomiMi12Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.GalaxyS20Factory import GalaxyS20Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.CompalAtAdbFactory import CompalAtAdbFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.MediatekFactory import MediatekFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.GalaxyS23Factory import GalaxyS23Factory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.OppoFactory import OppoFactory
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.SerialAtUeFactory import SerialAtUeFactory
import ute_ue.ue

GALAXY_S21_ULTRA = "GALAXY_S21_ULTRA"
GALAXY_S20 = "GALAXY_S20"
GALAXY_S23 = "GALAXY_S23"
TAF_UE = "TAF_UE"
UTE_UE = "UTE_UE"
NOKIA_8_3 = "NOKIA_8_3"
ONEPLUS_9_PRO = "ONEPLUS_9_PRO"
ONEPLUS_9_PRO_ANDROID12 = "ONEPLUS_9_PRO_ANDROID12"
ASKEY_AT_ADB = "ASKEY_AT_ADB"
QUALCOMM_SDX65 = "QUALCOMM_SDX65"
QUALCOMM_SDX55 = 'QUALCOMM_SDX55'
SMAWAVE_AT_SSH = "SMAWAVE_AT_SSH"
XIAOMI_MI11 = "XIAOMI_MI11"
XIAOMI_MI12 = "XIAOMI_MI12"
COMPAL = "COMPAL"
MEDIATEK = "MEDIATEK"
OPPO = "OPPO"
SERIAL_AT = "SERIAL_AT"


class UeFactory(object):

    @staticmethod
    def get_ue(model, id_, capabilities):
        """
        Prepares proper UE for the abstract UE class
        :param model: Model of the target UE
        :param id_: Order number of the UE, one greater than the testline init file
        :param capabilities: Taf/ute library parameter only
        :return: UE model object
        """
        if model == GALAXY_S21_ULTRA:
            return GalaxyS21UltraFactory(id_)
        elif model == NOKIA_8_3:
            return Nokia83Factory(id_)
        elif model == ONEPLUS_9_PRO:
            return OnePlus9ProFactory(id_)
        elif model == ONEPLUS_9_PRO_ANDROID12:
            return OnePlus9ProAndroid12Factory(id_)
        elif model == QUALCOMM_SDX65:
            return QualcommSdx65Factory(id_)
        elif model == QUALCOMM_SDX55:
            return QualcommSdx55Factory(id_)
        elif model == TAF_UE:
            return TafUeFactory(id_, capabilities)
        elif model == UTE_UE:
            return UteUeFactory(id_, capabilities)
        elif model == ASKEY_AT_ADB:
            return AskeyAtAdbFactory(id_)
        elif model == SMAWAVE_AT_SSH:
            return SmWaveAtFactory(id_)
        elif model == XIAOMI_MI11:
            return XiaomiMi11Factory(id_)
        elif model == XIAOMI_MI12:
            return XiaomiMi12Factory(id_)
        elif model == GALAXY_S20:
            return GalaxyS20Factory(id_)
        elif model == COMPAL:
            return CompalAtAdbFactory(id_)
        elif model == MEDIATEK:
            return MediatekFactory(id_)
        elif model == GALAXY_S23:
            return GalaxyS23Factory(id_)
        elif model == OPPO:
            return OppoFactory(id_)
        elif model == SERIAL_AT:
            return SerialAtUeFactory(id_)
        else:
            raise NotImplementedError("{} model is not yet implemented".format(model))
