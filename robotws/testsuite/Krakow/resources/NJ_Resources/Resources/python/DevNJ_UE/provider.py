from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_UE.common import (
    UeYamlConfiguration,
)
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_UE.common.exceptions import (
    UeNotSupport,
)
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_UE.interfaces import (
    AndroidUe,
    SmawaveUe,
    NewUe,
)


class SupportUeVersion(object):
    """
    Class for getting supported UE version.
    """

    real_android = AndroidUe
    smawave_ue = SmawaveUe
    new_ue = NewUe


class UeProvider(object):
    def __init__(self, ue_index):
        """
        Class for getting UE related information.

        :param ue_index: UE identifier index
        """
        self.ue_info = UeYamlConfiguration()
        self.ue_index = ue_index

    def _get_ue_type(self):
        """
        Get UE type according to the last line of CAPABILITIES in ue_config.yaml file.
        """
        ue_type = self.ue_info.ue_capabilities(ue_index=self.ue_index)[-1]
        if "android" in ue_type.lower():
            ue_type = "real_android"

        return ue_type

    def _get_ue_version(self):
        """
        Get UE version.
        For Android UE, return "common".
        For SMAWave UE, return "smawave_mobile1" for now, if there is new version, it will be "smawave_mobile2", etc.
        """
        ue_version = "common"

        ue_type = self._get_ue_type()
        if "smawave" in ue_type.lower():
            ue_version = "smawave_mobile1"

        return ue_version

    def get_ue_interface(self):
        """
        Get UE interface.
        """
        ue_interface = getattr(SupportUeVersion, self._get_ue_type().lower(), None)

        if not ue_interface:
            error_info = (
                "Cant support this ue type currently, please make new ue keyword request, "
                "or check the last value of CAPABILITIES in ue_config.yaml"
            )
            raise UeNotSupport(error_info)

        return ue_interface(
            ue_info=self.ue_info.setup_ue_variables(),
            ue_index=self.ue_index,
            ue_version=self._get_ue_version().lower(),
        )
