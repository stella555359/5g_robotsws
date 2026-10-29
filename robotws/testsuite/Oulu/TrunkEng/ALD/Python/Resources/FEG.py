from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.LNA import LNA
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import WrongFEGValueException


class FEG:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.lna = LNA()

    @staticmethod
    def compare_feg_values(feg_before, feg_now, affected_antennalines=None):
        """
        Compares the FEG values before and now

        :param List[Tuple(str, int)] feg_before: get FEG tuples from calculate_and_check_feg
        :param List[Tuple(str, int)] feg_now: get FEG tuples from calculate_and_check_feg
        :param (Optional) List[str] affected_antennalines: If given, check affected antennalines
        """
        incorrect_feg_value = False
        for i, fegs in enumerate(feg_before):
            antl_is_checked = False
            if affected_antennalines:
                for antennaline in affected_antennalines:
                    if antennaline in feg_now[i]:
                        if fegs != feg_now[i]:
                            info("Affected antennaline: {}, FEG values OK, before: {}, now: {}".format(
                                antennaline, fegs, feg_now[i]))
                        else:
                            error("Affected antennaline: {}, FEG values NOT OK, no change in value(s)!"
                                  " before: {}, now: {}".format(antennaline, fegs, feg_now[i]))
                            incorrect_feg_value = True
                        antl_is_checked = True
            if not antl_is_checked:
                if fegs == feg_now[i]:
                    info("FEG values OK, before: {}, now: {}".format(fegs, feg_now[i]))
                else:
                    error("FEG values NOT OK, before: {}, now: {}".format(fegs, feg_now[i]))
                    incorrect_feg_value = True

        if incorrect_feg_value:
            error("Incorrect FEG value(s) found.")
            raise WrongFEGValueException

    def calculate_and_check_feg(self):
        """
        Calculates FEG and performs basic FEG value check.

        :return List[Tuple(str, int)]: (antennaline, FEG value)
        """
        checked_radios = []
        feg_tuples = []
        lnas = self.lna.find_lnas_from_bts()
        antennalines = self._get_antennalines_total_losses_and_calc_feg()
        for config_antl, runtime_antl, total_loss, calc_feg in antennalines:
            for lna in lnas:
                if config_antl in lna.data and config_antl not in checked_radios:
                    checked_radios.append(config_antl)
                    feg = lna.gain - total_loss
                    if calc_feg != 0:
                        if feg == calc_feg:
                            info("FEG value OK, {} is {}, calc_feg {}".format(config_antl, feg, calc_feg))
                        else:
                            error("FEG value NOT OK, {} is {}, calc_feg {}".format(config_antl, feg, calc_feg))
                        feg_tuples.append((config_antl, feg))
                        break
                    else:
                        info("FEG value OK, {} is {}".format(config_antl, calc_feg))
                        feg_tuples.append((config_antl, calc_feg))

                elif config_antl not in checked_radios and calc_feg == 0:
                    checked_radios.append(config_antl)
                    info("FEG value OK, {} is {}".format(config_antl, calc_feg))
                    feg_tuples.append((config_antl, calc_feg))
        feg_tuples.sort()
        return feg_tuples

    def _get_antennalines_total_losses_and_calc_feg(self):
        """
        Gets information about antennalines from managed objects

        :return List[Tuple(str, str, int, int)]: (configured ANTL, runtime ANTL, total loss, calculated feg)
        """
        antennalines_and_total_losses = []
        antennalines = self._get_objects("ANTL_R")
        config_antennalines = self._get_objects("ANTL_A")
        for antennaline in antennalines:
            config_antl = antennaline["parameters"]["configDN"]
            runtime_antl = antennaline["distName"].split("/")
            runtime_antl = "{}/{}".format(runtime_antl[-2], runtime_antl[-1])
            calc_feg = antennaline["parameters"]["calcFEG"]
            for config_antennaline in config_antennalines:
                if config_antl in config_antennaline["distName"]:
                    total_loss = config_antennaline["parameters"]["totalLoss"]
                    config_antl = config_antl.replace("_A", "")
                    config_antl = config_antl.split("/")
                    config_antl = "{}/{}".format(config_antl[-2], config_antl[-1])
                    antennalines_and_total_losses.append((config_antl, runtime_antl, total_loss, calc_feg))
        return antennalines_and_total_losses

    def _get_objects(self, obj):
        objects = self.admin.get_managed_objects(obj, timeout=10)
        return objects
