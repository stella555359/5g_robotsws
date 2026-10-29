import re
import pytz
import os
import datetime
from traceback import format_exception
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, EnvironmentIssue, ErrorFromAdmin,
                                                                        InvalidUserInput)
from testsuite.Oulu.TrunkEng.Common.Python.Resources.ParameterCommissioning import ParameterCommissioning


class ParameterChange(object):

    def __init__(self):
        """
        ParameterChange is a collection of methods needed to change values of commissioning parameter in tests.
        """

        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.commissioning = ParameterCommissioning()

    def change_tx_path_failure_mode(self, selected_mode, add_to_delta=False, delta_file=None):
        """
        With this method you can change commissioning value of txPathFailureMode parameter of class NOKLTE:LNBTS.

        :param str selected_mode: Can have values for example, disableCell or keepCellInService
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        self.commissioning.check_if_class_exists("NOKLTE:LNBTS", "txPathFailureMode")
        if selected_mode not in ["disableCell", "keepCellInService"]:
            warning("{} is not in list [disableCell, keepCellInService] if value is expected you may add "
                    "it to change_tx_path_failure_mode -method to avoid this warning.".format(selected_mode))
        info("Changing txPathFailureMode to {}".format(selected_mode))
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = "MRBTS-{bi}/LNBTS-{bi}".format(bi=bts_id)
        if add_to_delta:
            self.commissioning.add_to_delta(dist_name, "txPathFailureMode", selected_mode, delta_file)
        else:
            self.commissioning.update_parameter(selected_mode, "txPathFailureMode", dist_name)

    def change_act_bb_pooling(self, selected_mode, add_to_delta=False, delta_file=None):
        """
        With this method you can change commissioning value of actBbPooling parameter of class NOKLTE:LNBTS.

        :param str selected_mode: Can have value true or false.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        self.commissioning.check_if_class_exists("NOKLTE:LNBTS", "actBbPooling")
        if selected_mode not in ["true", "false"]:
            warning("{} is not in list [true, false] if value is expected you may add it "
                    "to change_act_bb_pooling -method to avoid this warning.".format(selected_mode))
        info("Changing actBbPooling to {}".format(selected_mode))
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = "MRBTS-{bi}/LNBTS-{bi}".format(bi=bts_id)
        if add_to_delta:
            self.commissioning.add_to_delta(dist_name, "actBbPooling", selected_mode, delta_file)
        else:
            self.commissioning.update_parameter(selected_mode, "actBbPooling", dist_name)

    def change_allow_bb_pool_recovery_reset(self, selected_mode, add_to_delta=False, delta_file=None):
        """
        With this method you can change commissioning value of allowBbPoolRecoveryReset parameter of class
        com.nokia.srbts.eqm:APEQM.

        :param str selected_mode: Can have value true or false.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        self.commissioning.check_if_class_exists("com.nokia.srbts.eqm:APEQM", "allowBbPoolRecoveryReset")
        if selected_mode not in ["true", "false"]:
            warning("{} is not in list [true, false] if value is expected you may add it "
                    "to change_allow_bb_pool_recovery_reset -method to avoid this warning.".format(selected_mode))
        info("Changing allowBbPoolRecoveryReset to {}".format(selected_mode))
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = "MRBTS-{bi}/EQM-1/APEQM-1".format(bi=bts_id)
        if add_to_delta:
            self.commissioning.add_to_delta(dist_name, "allowBbPoolRecoveryReset", selected_mode, delta_file)
        else:
            self.commissioning.update_parameter(selected_mode, "allowBbPoolRecoveryReset", dist_name)

    def change_param_from_fmcadm(self, parameter, selected_mode, add_to_delta=False, delta_file=None):
        """
        With this method you can change commissioning value of actCategoryAlarms parameter of class
        com.nokia.srbts.mnl:FMCADM.

        :param str parameter: Parameter which value will be changed, can be, for example, actCategoryAlarms,
                              actForceAutoReset or actForceUnitAutoReset.
        :param str selected_mode: Value of the parameter.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        self.commissioning.check_if_class_exists("com.nokia.srbts.mnl:FMCADM", parameter)
        # if selected_mode not in ["true", "false"]:
        #     warning(f"{selected_mode} is not in list [true, false] if value is expected you may add it "
        #             f"to change_act_category_alarms -method to avoid this warning.")
        info(f"Changing {parameter} to {selected_mode}")
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = f"MRBTS-{bts_id}/MNL-1/MNLENT-1/FMCADM-1"
        if add_to_delta:
            self.commissioning.add_to_delta(dist_name, parameter, selected_mode, delta_file)
        else:
            self.commissioning.update_parameter(selected_mode, parameter, dist_name)

    def change_param_from_featcadm(self, parameter, selected_mode, add_to_delta=False, delta_file=None, do_reset=False):
        """
        With this method you can change commissioning value of actCategoryAlarms parameter of class
        com.nokia.srbts.mnl:FEATCADM.

        :param str parameter: Parameter which value will be changed, can be, for example, actCategoryAlarms,
                              actForceAutoReset or actForceUnitAutoReset.
        :param str selected_mode: Can have value true or false.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        :param bool do_reset: Default is False and will perform site reset after commissioning manually if True.
        """

        # NOTE, this is only used for changing values of enforcedRecovTimeWindow parameter
        # If there is a need to change other parameters, please update the accepted list of values
        self.commissioning.check_if_class_exists("com.nokia.srbts.mnl:FEATCADM", parameter)
        allowed_list = ["Enforced recovery disabled",
                        "Enforced recovery enabled within 0 - 60 minutes",
                        "Enforced recovery enabled within 0 - 90 minutes",
                        "Enforced recovery enabled within 0 - 120 minutes",
                        "Enforced recovery enabled within 0 - 150 minutes"]
        if selected_mode not in allowed_list:
            warning(f"{selected_mode} is not in list {allowed_list} if value is expected you may add it "
                    f"to change_param_fromfeatcadm -method to avoid this warning.")
        info(f"Changing {parameter} to {selected_mode}")
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = f"MRBTS-{bts_id}/MNL-1/MNLENT-1/FEATCADM-1"
        if add_to_delta:
            self.commissioning.add_to_delta(dist_name, parameter, selected_mode, delta_file)
        else:
            self.commissioning.update_parameter(selected_mode, parameter, dist_name)
        if do_reset:
            info("Perform site reset after commissioning manually")
            status = self.admin.reset_site(detailed_output=True, wait_for_reconnection=False)
            if status['requestStatus'] == "completed":
                info(f"Site reset completed successfully. Status is: {status['requestStatus']}")
            else:
                error(f"Site reset wasn't completed successfully. Status is: {status['requestStatus']}")
                raise EnvironmentIssue

    def change_product_variant_planned(self, selected_mode, add_to_delta=False, delta_file=None):
        """
        With this method you can change commissioning value of productVariantPlanned parameter of class
        com.nokia.srbts.mnl:MNL.

        :param str selected_mode: Can have value for example sBTS or lteBTS.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        self.commissioning.check_if_class_exists("com.nokia.srbts.mnl:MNL", "productVariantPlanned")
        if selected_mode not in ["sBTS", "lteBTS"]:
            warning("{} is not in list [sBTS, lteBTS] if value is expected you may add it "
                    "to change_product_variant_planned -method to avoid this warning.".format(selected_mode))
        info("Changing productVariantPlanned to {}".format(selected_mode))
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = "MRBTS-{bi}/MNL-1".format(bi=bts_id)
        if add_to_delta:
            self.commissioning.add_to_delta(dist_name, "productVariantPlanned", selected_mode, delta_file)
        else:
            self.commissioning.update_parameter(selected_mode, "productVariantPlanned", dist_name)

    def change_bb_card_usage(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change commissioning value of bbCardUsage parameter of class com.nokia.srbts.eqm:BBMOD.

        :param str new_value: Can have value for example 0, 1 or 2.
        :param srt bbmod_or_cell: Default is None, if None then all BBMODs will be updated. If for example 1 then
                                  just BBMOD-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        bbmod_dist_names = self.commissioning.get_all_dist_names("com.nokia.srbts.eqm:BBMOD")
        if new_value not in ["0", "1", "2"]:
            warning("{} is not in list [0, 1, 2] if value is expected you may add it "
                    "to change_bb_card_usage -method to avoid this warning.".format(new_value))
        info("Change bbCardUsage {}.".format(
            "to all BBMOD units" if bbmod_or_cell is None else "of BBMOD-{}".format(bbmod_or_cell)))
        for dist_name in bbmod_dist_names:
            if bbmod_or_cell is None or dist_name[-1] == bbmod_or_cell:
                if add_to_delta:
                    self.commissioning.add_to_delta(dist_name, "bbCardUsage", new_value, delta_file)
                else:
                    self.commissioning.update_parameter(new_value, "bbCardUsage", dist_name)

    def change_dl_mimo_mode(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change Mimo mode, commissioning value of dlMimoMode parameter of class NOKLTE:LNCEL_FDD
        or NOKLTE:LNCEL_TDD.

        :param str new_value: Can have value for example: "SingleTX", "TXDiv", "4-way TXDiv", "Dynamic Open Loop MIMO",
                                                          "Closed Loop Mimo", "Closed Loop MIMO (4x2)",
                                                          "2x2 Closed Loop Spatial Multiplexing".
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        if new_value not in ["SingleTX", "TXDiv", "4-way TXDiv", "Dynamic Open Loop MIMO", "Closed Loop Mimo",
                             "Closed Loop MIMO (4x2)", "2x2 Closed Loop Spatial Multiplexing"]:
            warning(r"{} is not in list [SingleTX, TXDiv, 4-way TXDiv, Dynamic Open Loop MIMO, Closed Loop Mimo,"
                    r"Closed Loop MIMO (4x2), 2x2 Closed Loop Spatial Multiplexing] if value is expected you may add it"
                    r" to change_dl_mimo_mode -method to avoid this warning.".format(new_value))
        self.changes_to_lncel_dd_parameter("dlMimoMode", new_value, bbmod_or_cell, add_to_delta, delta_file)

    def change_sync_sig_tx_mode(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change Sync sign transmission mode, commissioning value of syncSigTxMode parameter of
        class NOKLTE:LNCEL_FDD or NOKLTE:LNCEL_TDD.

        :param str new_value: Can have value for example: "SingleTx", "TxDiv".
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        if new_value not in ["SingleTx", "TxDiv"]:
            warning(r"{} is not in list [SingleTx, TxDiv] if value is expected you may add it"
                    r" to change_sync_sig_tx_mode -method to avoid this warning.".format(new_value))
        self.changes_to_lncel_dd_parameter("syncSigTxMode", new_value, bbmod_or_cell, add_to_delta, delta_file)

    def change_ul_ch_bw(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change Uplink channel bandwidth, commissioning value of ulChBw parameter of class
        NOKLTE:LNCEL_FDD or NOKLTE:LNCEL_TDD.

        :param str new_value: Can have value for example: "1.4 MHz", "3 MHz", "5 MHz", "10 MHz", "15 MHz", "20 MHz"...
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        if new_value not in ["1.4 MHz", "3 MHz", "5 MHz", "10 MHz", "15 MHz", "20 MHz"]:
            warning(r"{} is not in list [1.4 MHz, 3 MHz, 5 MHz, 10 MHz, 15 MHz, 20 MHz] if value is "
                    r"expected you may add it to change_ul_ch_bw -method to avoid this warning.".format(new_value))
        self.changes_to_lncel_dd_parameter("ulChBw", new_value, bbmod_or_cell, add_to_delta, delta_file)

    def change_dl_ch_bw(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change Downlink channel bandwidth, commissioning value of dlChBw parameter of class
        NOKLTE:LNCEL_FDD or NOKLTE:LNCEL_TDD.

        :param str new_value: Can have value for example: "1.4 MHz", "3 MHz", "5 MHz", "10 MHz", "15 MHz", "20 MHz"...
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        if new_value not in ["1.4 MHz", "3 MHz", "5 MHz", "10 MHz", "15 MHz", "20 MHz"]:
            warning(r"{} is not in list [1.4 MHz, 3 MHz, 5 MHz, 10 MHz, 15 MHz, 20 MHz] if value is "
                    r"expected you may add it to change_dl_ch_bw -method to avoid this warning.".format(new_value))
        self.changes_to_lncel_dd_parameter("dlChBw", new_value, bbmod_or_cell, add_to_delta, delta_file)

    def change_act_otdoa(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change Prs activation, commissioning value of actOtdoa parameter of class NOKLTE:LNCEL.

        :param str new_value: Can have value for example: true, false.
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        if new_value not in ["true", "false"]:
            warning("{} is not in list [true, false] if value is expected you may add it "
                    "to change_act_otdoa -method to avoid this warning.".format(new_value))
        self.changes_to_lncel_parameter("actOtdoa", new_value, bbmod_or_cell, add_to_delta, delta_file)

    def change_act_prs_tx_div(self, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change Prs TX diversity, commissioning value of actPrsTxDiv parameter of class
        NOKLTE:LNCEL.

        :param str new_value: Can have value for example: true, false.
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        self.changes_to_lncel_parameter("actPrsTxDiv", new_value, bbmod_or_cell, add_to_delta, delta_file)

    def changes_to_lncel_parameter(self, element, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change commissioning values of class NOKLTE:LNCEL.

        :param str element: Can have value for example: actOtdoa...
        :param str new_value: Can have value for example: true, false...
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        cell_dist_names = self.commissioning.get_all_dist_names("NOKLTE:LNCEL")
        info("Change {} {}.".format(
            element, "to all cells" if bbmod_or_cell is None else "of LNCEL-{}".format(bbmod_or_cell)))
        for dist_name in cell_dist_names:
            if bbmod_or_cell is None or dist_name[-1] == bbmod_or_cell:
                self.logger.debug("update {} of {}={}".format(dist_name, element, new_value))
                if add_to_delta:
                    self.commissioning.add_to_delta(dist_name, element, new_value, delta_file)
                else:
                    self.commissioning.update_parameter(new_value, element, dist_name)

    def changes_to_lncel_dd_parameter(self, element, new_value, bbmod_or_cell, add_to_delta, delta_file):
        """
        With this method you can change commissioning values of class NOKLTE:LNCEL_FDD or
        NOKLTE:LNCEL_TDD.

        :param str element: Can have value for example: syncSigTxMode, dlMimoMode, ulChBw...
        :param str new_value: Can have value for example: "SingleTx", "TxDiv"...
        :param srt bbmod_or_cell: Default is None, if None then all cells will be updated. If for example 1 then
                                  just LNCEL-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        cell_dist_names = self.commissioning.get_all_dist_names("NOKLTE:LNCEL_FDD", fail_test=False)
        if not cell_dist_names:
            info("NOKLTE:LNCEL_FDD were not found try to search NOKLTE:LNCEL_TDD cells")
            cell_dist_names = self.commissioning.get_all_dist_names("NOKLTE:LNCEL_TDD", fail_test=False)
        if not cell_dist_names:
            error("Classes NOKLTE:LNCEL_FDD nor NOKLTE:LNCEL_TDD were not found from the SCF file. Unable "
                  "to update {} parameter.".format(element))
            raise EnvironmentIssue
        info("Change {} {}.".format(
            element, "to all cells" if bbmod_or_cell is None else "of LNCEL-{}".format(bbmod_or_cell)))
        for dist_name in cell_dist_names:
            parse_cell = re.compile(r"MRBTS-\d+.LNBTS-\d+.LNCEL-(?P<cell>\d+).LNCEL_(FDD|TDD)-\d+")
            match = parse_cell.match(dist_name)
            if (bbmod_or_cell is None) or (match and match.group("cell") == bbmod_or_cell):
                self.logger.debug("update {} of {}={}".format(dist_name, element, new_value))
                if add_to_delta:
                    self.commissioning.add_to_delta(dist_name, element, new_value, delta_file)
                else:
                    self.commissioning.update_parameter(new_value, element, dist_name)

    def select_parameter_changing_method(self, parameter_to_change, new_value, bbmod_or_cell=None, add_to_delta=False,
                                         delta_file=None):
        """
        :param str parameter_to_change: Parameter which value will be changed.
        :param str new_value: New value for the parameter.
        :param srt bbmod_or_cell: Default is None, if None then all BBMODs/cells will be updated. If for example 1 then
                                  just BBMOD-1 will be updated.
        :param bool add_to_delta: Default is set to False. If True adds change to delta file.
        :param str delta_file: The identifier of the delta file.
        """
        if parameter_to_change == "txPathFailureMode":
            self.change_tx_path_failure_mode(new_value, add_to_delta, delta_file)
        elif parameter_to_change == "actCategoryAlarms":
            self.change_param_from_fmcadm("actCategoryAlarms", new_value, add_to_delta, delta_file)
        elif parameter_to_change == "productVariantPlanned":
            self.change_product_variant_planned(new_value, add_to_delta, delta_file)
        elif parameter_to_change == "actBbPooling":
            self.change_act_bb_pooling(new_value, add_to_delta, delta_file)
        elif parameter_to_change == "allowBbPoolRecoveryReset":
            self.change_allow_bb_pool_recovery_reset(new_value, add_to_delta, delta_file)
        elif parameter_to_change == "bbCardUsage":
            self.change_bb_card_usage(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "dlMimoMode":
            self.change_dl_mimo_mode(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "syncSigTxMode":
            self.change_sync_sig_tx_mode(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "actOtdoa":
            self.change_act_otdoa(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "actPrsTxDiv":
            self.change_act_prs_tx_div(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "ulChBw":
            self.change_ul_ch_bw(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "dlChBw":
            self.change_dl_ch_bw(new_value, bbmod_or_cell, add_to_delta, delta_file)
        elif parameter_to_change == "actForceAutoReset":
            self.change_param_from_fmcadm("actForceAutoReset", new_value, add_to_delta, delta_file)
        elif parameter_to_change == "actForceUnitAutoReset":
            self.change_param_from_fmcadm("actForceUnitAutoReset", new_value, add_to_delta, delta_file)
        elif parameter_to_change == "enforcedRecovTimeWindow":
            self.change_param_from_featcadm("enforcedRecovTimeWindow", new_value, add_to_delta, delta_file,
                                            do_reset=False)
        elif parameter_to_change == "actCellAutoRecalculation":
            self.change_param_from_fmcadm("actCellAutoRecalculation", new_value, add_to_delta, delta_file)

    def change_multiple_parameters_for_object(self, element_to_change, parameter_and_value_dict):
        """
        With this method you can give multiple parameters and values for the same object.

        :param str element_to_change: Element can be given as distName of object or as a class of object or f.ex. as
                                      LNBTS to which the dist_name will be created.
        :param dict parameter_and_value_dict: Dictionary where parameter is as a key and value as value.
        """
        dist_names = []
        if element_to_change == "LNBTS":
            bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
            element_to_change = "MRBTS-{bi}/LNBTS-{bi}".format(bi=bts_id)
            dist_names.append(element_to_change)
        elif ":" in element_to_change:
            info("User has given managedObject class {} as object to be update.".format(element_to_change))
            dist_names = self.commissioning.get_all_dist_names(element_to_change)
        else:
            dist_names.append(element_to_change)
        for dist_name in dist_names:
            parameter_list = []
            for element, e_value in parameter_and_value_dict.items():
                pdict = {"parameterName": element, "operation": "update", "value": e_value}
                parameter_list.append(pdict)
            self.commissioning.update_multiple_parameters_of_object(dist_name, parameter_list)

    def create_delta_file_and_perform_recommissioning(self, commissioning_parameters):
        """
        Creates delta file from user given values. If you change actCategoryAlarms, remember to re-check the
        active category alarms in the test using KW 'Check If Category Alarms Active'.

        :param dict commissioning_parameters: Dictionary of commissioning parameters.
        """
        if not commissioning_parameters:
            error("Commissioning parameter dictionary is not given")
            raise ScriptIssue
        self.admin.create_delta("Delta_file")
        for element, element_value in commissioning_parameters.items():
            self.select_parameter_changing_method(element, element_value, add_to_delta=True, delta_file="Delta_file")
        self.commissioning.save_delta_file_and_perform_recommissioning(delta_file="Delta_file")
        self.commissioning.wait_after_commissioning()

    def set_vswr_value(self, distname, parameter_value_dict):
        info(f"Changing parameter - threshold to {parameter_value_dict} for {distname}.")
        parameter_list = []
        for element, e_value in parameter_value_dict.items():
            pdict = {"parameterName": element, "operation": "update", "value": e_value}
            parameter_list.append(pdict)
        self.commissioning.update_multiple_parameters_of_object(distname, parameter_list)

    def _get_and_check_if_syslog_line_to_get_bts_time(self, syslog, max_try_times=10):
        """
        Get and check if syslog line to get bts time
        """
        try_time = 0
        line = ''
        while try_time < max_try_times:
            line = syslog.get_last_line_from_syslogs()
            if not line:
                self.logger.debug("Line is empty/None")
            elif line and len(line) < 90:
                self.logger.debug(f"Length of line is {len(line)} it is less than is required to get BTS time.")
            elif line and len(line) > 89:
                self.logger.debug("Syslog line is long enough to get BTS time")
                break
            try_time += 1
        if line and len(line) > 89:
            return line
        else:
            warning(f"Latest syslog line was not long enough to parse BTS time from it (retried {max_try_times} times)")
            return None

    def _get_bts_time(self, text_for_info, syslog):
        """
        Get bts time method gets time of BTS from latest syslog line.

        :param str text_for_info: Text to be printed to eventlog.
        :param syslog: syslog instance
        """
        self.logger.debug("Get BTS time from syslog")
        try:
            line = self._get_and_check_if_syslog_line_to_get_bts_time(syslog)
            if line:
                bts_time = syslog.get_time_of_line_as_datetime_object(line, bts_time=True)
                if bts_time:
                    info(f'{text_for_info}: {bts_time.strftime("%H:%M:%S")}')
        except Exception as e:
            warning(f"Problems to get BTS time from syslog. {e.__class__.__name__}:{e}")
            tb = ''.join(format_exception(type(e), e, e.__traceback__))
            info(tb)

    def update_maintenance_window_values(self, user_given_time="", enable=True, start_time_for_disabling="",
                                         window_duration="30"):
        """
        Enables and updates the maintenanceWindow values from MRBTS-x/MNL-1/MNLENT-1/FMCADM-1 with
        the user given parameters.

        :param str user_given_time: Time to add to current time. Can be f.ex. 1h, 30min, 50s
        :param bool enable: If True, enables the parameter with given values, otherwise disables it.
        :param str start_time_for_disabling: Previously given MW start time used for waiting until the end of MW
        :param str window_duration: Window duration given in minutes, default is 30

        Returns:

        """
        syslog = BuiltIn().get_library_instance("SYSLOGSEARCH")
        self._get_bts_time("BTS time now is", syslog)
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        dist_name = f"MRBTS-{bts_id}/MNL-1/MNLENT-1/FMCADM-1"
        if user_given_time and enable:
            start_time, days_of_week = self.bts.get_current_time_and_return_user_defined_values(
                                                                                        user_given_time=user_given_time,
                                                                                        return_weekdays=True)
        else:
            start_time, days_of_week = "", ""

        graceful_cell_shutdown = "no"
        in_use = "true" if enable else "false"
        try:
            self.admin.create_delta("Delta_file")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Problems when creating delta file. {admin_error.__class__.__name__}:{admin_error} was "
                  f"raised.")
            info(f"{tb}")
            raise ErrorFromAdmin(f"{admin_error.__class__.__name__}:{admin_error}")
        if enable:
            info("Enabling maintenanceWindow with the following values:\n"
                 f"daysOfWeek: {days_of_week}\ngracefulCellShutdown: {graceful_cell_shutdown}\n"
                 f"inUse: {in_use}\nstartTime: {start_time}\nwindowDuration: {window_duration}")
            try:
                self.admin.append_parameter_update_to_delta(dist_name=dist_name, parameter="maintenanceWindow",
                                                            value=[{"daysOfWeek": str(days_of_week),
                                                                    "gracefulCellShutdown": graceful_cell_shutdown,
                                                                    "inUse": in_use,
                                                                    "startTime": start_time,
                                                                    "windowDuration": str(window_duration)}],
                                                            delta_id="Delta_file")
            except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                    AliasLookupError, AdminApiTerminatedException, AliasInUse,
                    AdminApiConnectionClosedException) as admin_error:
                tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
                error(f"Problems when append_parameter_update_to_delta. {admin_error.__class__.__name__}:{admin_error}"
                      f" was raised.")
                info(f"{tb}")
                raise ErrorFromAdmin(f"{admin_error.__class__.__name__}:{admin_error}")
        else:
            info("Disabling maintenanceWindow")
            if start_time_for_disabling:
                info("Waiting until the end of maintenance window and disabling it"
                     f"(start time for disabling is: {start_time_for_disabling})")
                curr_time = datetime.datetime.now(pytz.timezone("Europe/Helsinki"))
                hh_mm = self._safe_split(start_time_for_disabling, ":")
                mw_start_time = curr_time.replace(hour=int(hh_mm[0]), minute=int(hh_mm[1]),
                                                  second=0, microsecond=0)
                end_time = mw_start_time + datetime.timedelta(minutes=int(window_duration))
                time_to_wait = int((end_time - curr_time).total_seconds()) % 86400  # 24h=86400s
                BuiltIn().sleep(f"{time_to_wait}s")
                info(f"Waited for {time_to_wait} seconds.")
                self._get_bts_time("BTS time after wait", syslog)
            try:
                self.admin.append_parameter_delete_to_delta(dist_name=dist_name, parameter="maintenanceWindow",
                                                            delta_id="Delta_file")
            except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                    AliasLookupError, AdminApiTerminatedException, AliasInUse,
                    AdminApiConnectionClosedException) as admin_error:
                tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
                error(f"Problems when append_parameter_delete_to_delta. {admin_error.__class__.__name__}:{admin_error}"
                      f" was raised.")
                info(f"{tb}")
                raise ErrorFromAdmin(f"{admin_error.__class__.__name__}:{admin_error}")
        self.commissioning.save_delta_file_and_perform_recommissioning(delta_file="Delta_file")
        info(f"maintenanceWindow values have been {'enabled' if enable else 'disabled'}.")
        info(f"Saving SCF file")
        self.commissioning.scf.get_scf(extra_name=f"{'enabledMW' if enable else 'disabledMW'}")
        if enable:
            info(f"Waiting until the start of maintenance window ({start_time})")
            curr_time = datetime.datetime.now(pytz.timezone("Europe/Helsinki"))
            hh_mm = self._safe_split(start_time, ":")
            mw_start_time = curr_time.replace(hour=int(hh_mm[0]), minute=int(hh_mm[1]), second=0, microsecond=0)
            time_to_wait = int((mw_start_time - curr_time).total_seconds()) % 86400  # 24h=86400s
            BuiltIn().sleep(f"{time_to_wait}s")
            info(f"Waited for {time_to_wait} seconds.")
            self._get_bts_time("BTS time after wait", syslog)
            return start_time

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)

    def check_power_parameter_values(self, managed_class, power_parameters):
        """
        Checks if parameters of given class are set as expected and if not set them accordingly.

        :param str managed_class: Managed class to check, e.g. "NOKLTE:LNBTS".
        :param dict power_parameters: Dictionary of parameters and their expected values.
        :return list: If all power parameters are as expected or have been set accordingly then None is returned.
                      If some parameters are not as expected, a list of tuples is returned where each tuple is
                      (object_distname, parameter, expected_value).

        Changes for example values of power parameters:
        <managedObject class="NOKLTE:LNBTS" distName="MRBTS-100854/LNBTS-100854">
            <p name="actLBPowerSaving">false</p>
            <p name="actLBRTXPowerSaving">false</p>
        """
        changes_needed = []
        try:
            if not managed_class:
                error("No managed class given to check.")
                raise InvalidUserInput("No managed class given to check.")
            if not power_parameters:
                error("No power parameters given to check.")
                raise InvalidUserInput("No power parameters given to check.")
            if not isinstance(power_parameters, dict):
                error("Parameters given to check_power_parameter_values are not in dictionary format.")
                raise InvalidUserInput("Parameters not given as a dictionary.")
            object_dist = self.commissioning.scf.get_distname_based_on_class(managed_class)
            if object_dist:
                for object_distname in object_dist:
                    for parameter, expected_value in power_parameters.items():
                        current_value = self.commissioning.scf.get_value_from_scf(
                            dist_name=object_distname, p_name=parameter)
                        self.logger.debug(f"Value of {parameter}: {current_value}")
                        if str(current_value).lower() != str(expected_value).lower():
                            info(f"{parameter} has value '{current_value}' but expected value is '{expected_value}' -> "
                                 f"changes are needed.")
                            changes_needed.append((object_distname, parameter, expected_value))
                if not changes_needed:
                    info(f"All {managed_class} parameters have expected values, no need for recommissioning.")
                    return None
                else:
                    return changes_needed
            else:
                self.logger.debug(f"No objects found for class {managed_class}.")
                return None
        except (IndexError, AttributeError, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as ae:
            info(f"Could not find {managed_class} value, cannot check parameters.\n"
                 f"{''.join(format_exception(type(ae), ae, ae.__traceback__))}")
            return None

    def enable_or_disable_power_saving_mode(self, enable_power_saving=True, affected_rat="LTE,5G"):
        """
        Enable or disable power saving mode in LTE or 5G environment or in both.

        :param bool enable_power_saving: True to enable power saving mode, False to disable it. Default is True.
        :param str affected_rat: Affected RAT, can be LTE or 5G or LTE,5G or 5G,LTE. Default is LTE,5G.
        """
        lnbts_list_of_tuples = []
        nrbts_list_of_tuples = []
        if affected_rat not in ["5G", "LTE", "5G,LTE", "LTE,5G"]:
            error("Affected RAT value is not valid. Possible values are 5G or LTE or 5G,LTE or LTE,5G")
            raise InvalidUserInput("Affected RAT value is not valid. Possible values are 5G or LTE or 5G,LTE or LTE,5G")
        if "LTE" in affected_rat:
            lnbts_parameters = {"actLBPowerSaving": str(enable_power_saving).lower()}
            if lnbts_parameters:
                lnbts_list_of_tuples = self.check_power_parameter_values("NOKLTE:LNBTS", lnbts_parameters)
        if "5G" in affected_rat:
            nrbts_parameters = {"actNrLBPowerSaving": str(enable_power_saving).lower()}
            if nrbts_parameters:
                nrbts_list_of_tuples = self.check_power_parameter_values("com.nokia.srbts.nrbts:NRBTS",
                                                                         nrbts_parameters)
        if lnbts_list_of_tuples or nrbts_list_of_tuples:
            self.logger.debug("Some power saving parameters are not set as expected, perform delta commissioning to set"
                              " them.")
            power_parameters_list_of_tuples = []
            if lnbts_list_of_tuples:
                info(f"NOKLTE:LNBTS power saving parameters need to be changed {lnbts_list_of_tuples}.")
                power_parameters_list_of_tuples.extend(lnbts_list_of_tuples)
            if nrbts_list_of_tuples:
                info(f"com.nokia.srbts.nrbts:NRBTS power saving parameters need to be changed "
                     f"{nrbts_list_of_tuples}")
                power_parameters_list_of_tuples.extend(nrbts_list_of_tuples)
            if power_parameters_list_of_tuples:
                delta_commissioning_ok = self.perform_delta_commissioning_for_power_parameters(
                    power_parameters_list_of_tuples)
                if not delta_commissioning_ok:
                    raise ErrorFromAdmin("Delta commissioning for power saving parameters failed.")
            else:
                info("Could not find any parameters that value needs changing, no need for delta commissioning.")

    def perform_delta_commissioning_for_power_parameters(self, power_parameters_list_of_tuples, path_to_delta_file="",
                                                         retry=0):
        """
        Perform delta commissioning for power saving parameters.

        :param list power_parameters_list_of_tuples: List of tuples where each tuple is
                                                     (object_distname, parameter, expected_value)
        :param str path_to_delta_file: Path to delta file where changes will be saved. If not given, a file will be
                                        created in the log directory with timestamp.
        :param int retry: Number of retries if delta commissioning fails. Default is 0 (no retries).
        :return bool: True if delta commissioning was successful, False otherwise.
        """
        if not path_to_delta_file:
            timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
            path_to_delta_file = os.path.join(self.logger.log_dir, f"power_saving_parameters_{timestamp}.json")
        try:
            self.admin.create_delta("power_parameters")
            for list_item in power_parameters_list_of_tuples:
                print(f"Power saving parameter to change: {list_item}")
                object_distname, parameter, expected_value = list_item
                self.admin.append_parameter_update_to_delta(object_distname, parameter, expected_value,
                                                            delta_id="power_parameters")
            self.admin.save_delta(path_to_delta_file, delta_id="power_parameters")
            info(f"Delta commissioning file is saved to {path_to_delta_file}")
            commissioning_result = self.admin.perform_delta_recommissioning(path_to_delta_file,
                                                                            skip_parameter_relation_errors=True)
            info("Delta commissioning finished.")
            self.logger.debug(f"Result: {commissioning_result}")
            return True
        except (IndexError, AttributeError, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}"
            if "because CPlane is busy" in tb and "ErrorCode: 27" in tb and retry == 0:
                info("CPlane is busy, cannot perform delta commissioning for power saving parameters right now, wait"
                     "5min and try again.")
                BuiltIn().sleep("300s")
                return self.perform_delta_commissioning_for_power_parameters(
                    power_parameters_list_of_tuples, path_to_delta_file=path_to_delta_file, retry=1)
            else:
                error(f"Problems when performing delta commissioning with {path_to_delta_file}."
                      f"{admin_error.__class__.__name__}:{admin_error}.")
        BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
        return False

    @staticmethod
    def _remove_not_selected_cells_from_list(all_cells, affected_cells, rat="LTE"):
        """
        Remove not selected cells from all_cells list.

        :param list all_cells: List of all cells.
        :param str affected_cells: String of selected cells.
        :param str rat: RAT to apply the power saving window. Default is LTE. Possible values are 5G or LTE.
        :return list: List of cells that are selected.
        """
        affected_cells_list = affected_cells.split(",")
        if rat != "LTE":
            premier = "NRCell-"
        else:
            premier = "LNCell-"
        selected_cells = []
        for cell in affected_cells_list:
            if premier in cell:
                lcrid = cell.split(premier)[1]
                if lcrid not in all_cells:
                    error(f"Given affected cell '{cell}' ({affected_cells}) is not found among {rat} cells: "
                          f"{all_cells}.")
                    raise InvalidUserInput(f"Given affected cell '{cell}' is not found among {rat} cells.\nNOTE "
                                           f"that the cell should be given as {premier}-<lcrId>, e.g. {premier}-1 so "
                                           f"we know to which rat the cell belongs to.")
                else:
                    selected_cells.append(lcrid)
        user_given_cells = [cell for cell in all_cells if cell in selected_cells]
        info(f"Cells user has selected to be power saving window update for {rat} power group: {user_given_cells}.")
        return user_given_cells

    def update_power_saving_window(self, when_to_start='15min', power_saving_duration='10',
                                   suspend_cell_energy_saving=False, admin_connection="log_admin",
                                   affected_cells="All", affected_rat="LTE,5G"):
        """
        Update Power Saving Window. Updates the values of lbpsPeriodList with user given values. Sets affected cells to
        lbpsCellList and sets lbpsLastCellMinLoad to 100, lbpsCellSOOrder to 100 and lbpsLastCellSOEnabled to true.

        :param str when_to_start: User given time to be added on top of the current time. This will set the start time
                                  of power saving window. Can be given as hour, minutes or seconds <number>h or
                                  <number>min or <number>s e.g. 1h or 20min or 300s.
        :param str power_saving_duration:  Can have value 1-1440 minutes.
        :param bool suspend_cell_energy_saving: Default False lbpsSuspended: notSuspended. If True, suspends NR cell
                                                energy saving: lbpsSuspended = suspended
        :param str admin_connection: Admin connection to be used. Default is "log_admin".
        :param str affected_cells: Cells to apply the power saving window. Default is "All". If specific cells are to be
                                   applied, give a comma separated string of cell ids NOTE this needs to be lcrId
                                   e.g. LNCell-1,LNCell-2...
                                        NRCell-1,NRCell-2...
        :param str affected_rat: RAT to apply the power saving window. Default is 5G. Possible values are 5G or LTE or
                                 5G,LTE

        If 5G of com.nokia.srbts.nrbts:NRPGRP
        <managedObject class="com.nokia.srbts.nrbts:NRPGRP" distName="MRBTS-100503/NRBTS-100503/NRPGRP-1">
        If LTE of NOKLTE:PSGRP
        <managedObject class="NOKLTE:PSGRP" distName="MRBTS-101366/LNBTS-101366/PSGRP-1">

        with the user given parameters:
        <list name="lbpsPeriodList">
            <item>
                <p name="lbpsDayOfWeek">Sun</p>
                <p name="lbpsDuration">10</p>
                <p name="lbpsStartTimeHour">23</p>
                <p name="lbpsStartTimeMinute">59</p>
                <p name="lbpsSuspended">notSuspended</p>
            </item>
        """
        if affected_rat not in ["5G", "LTE", "5G,LTE", "LTE,5G"]:
            error(f"Affected RAT value '{affected_rat}' is not valid. Possible values are '5G' or 'LTE' or '5G,LTE' or "
                  f"'LTE,5G'.")
            raise InvalidUserInput("Value of parameter affected_rat is not valid.")
        power_saving_scf = self.commissioning.scf.get_scf(
            extra_name="power_saving_window", admin_connection=admin_connection, update_scf_path=True)
        lbps_period_dict = self.set_lbps_period_list_parameters(when_to_start, power_saving_duration,
                                                                suspend_cell_energy_saving)
        if "LTE" in affected_rat:
            info("LTE is in affected RATs, check PSGRP cell objects and prepare to update power saving window for LTE "
                 "power group.")
            lte_cells = self._get_all_lcrid_from_managed_object_class("NOKLTE:LNCEL")
            if affected_cells != "All":
                lte_cells = ParameterChange._remove_not_selected_cells_from_list(lte_cells, affected_cells, rat="LTE")
            psgroup_object = self.commissioning.scf.get_distname_based_on_class("NOKLTE:PSGRP")
            if not psgroup_object:
                info("NOKLTE:PSGRP managedObject is missing, add it to SCF.xml")
                self.commissioning.scf.add_power_save_window_managed_object_to_scf(power_saving_scf, "NOKLTE:PSGRP",
                                                                                   lbps_period_dict, lte_cells)
            else:
                info("NOKLTE:PSGRP is already in SCF.xml modify values")
                self.commissioning.scf.modify_power_save_window_to_scf(power_saving_scf, "NOKLTE:PSGRP",
                                                                       lbps_period_dict, lte_cells)

        if "5G" in affected_rat:
            info("5G is in affected RATs, check NR cell objects and prepare to update power saving window for NR "
                 "power group.")
            nr_cells = self._get_all_lcrid_from_managed_object_class("com.nokia.srbts.nrbts:NRCELL")
            if affected_cells != "All":
                nr_cells = ParameterChange._remove_not_selected_cells_from_list(nr_cells, affected_cells, rat="5G")
            nr_group_object = self.commissioning.scf.get_distname_based_on_class("com.nokia.srbts.nrbts:NRPGRP")
            if not nr_group_object:
                info("com.nokia.srbts.nrbts:NRPGRP managedObject is missing, add it to SCF.xml")
                self.commissioning.scf.add_power_save_window_managed_object_to_scf(power_saving_scf,
                                                                                   "com.nokia.srbts.nrbts:NRPGRP",
                                                                                   lbps_period_dict, nr_cells)
            else:
                info("com.nokia.srbts.nrbts:NRPGRP is already in SCF.xml modify values")
                self.commissioning.scf.modify_power_save_window_to_scf(power_saving_scf, "com.nokia.srbts.nrbts:NRPGRP",
                                                                       lbps_period_dict, nr_cells)
            self.commissioning.scf.perform_commissioning_with_scf_file(commissioning_file=power_saving_scf,
                                                                       create_own_connection=False,
                                                                       commissioning_connection=admin_connection)

    def _get_all_lcrid_from_managed_object_class(self, object_class):
        """
        Get all lcrId from managed object class.
        :param str object_class: Managed object class to get lcrIds from.
        """
        lcrids = []
        cell_objects = self.commissioning.scf.get_distname_based_on_class(object_class)
        for cell_object in cell_objects:
            self.logger.debug(f"Cell distName: {cell_object}")
            current_value = self.commissioning.scf.get_value_from_scf(dist_name=cell_object, p_name="lcrId")
            if current_value:
                lcrids.append(str(current_value))
        info(f"All lcrIds from class {object_class}: {lcrids}")
        return lcrids

    def set_lbps_period_list_parameters(self, when_to_start, power_saving_duration, suspend_cell_energy_saving):
        """
        Set lbpsPeriodList parameters for power saving window.

        :param str when_to_start: User given time to be added on top of the current time. This will set the start time
                                  of power saving window. Can be given as hour, minutes or seconds <number>h or
                                  <number>min or <number>s e.g. 1h or 20min or 300s.
        :param str power_saving_duration:  Can have value 1-1440 minutes.
        :param bool suspend_cell_energy_saving: Default False lbpsSuspended: notSuspended. If True, suspends NR cell
                                                energy saving: lbpsSuspended = suspended
        returns: dict lbps parameters
        """
        # LTE and 5G both have same element but for different class
        start_time = self.bts.get_current_time_and_return_user_defined_values(user_given_time=when_to_start,
                                                                              return_weekdays=False)
        if not start_time:
            error(f"Could not get start time based on user given time '{when_to_start}'.")
            raise EnvironmentIssue(f"Could not get start time based on user given time '{when_to_start}'.")
        days_of_week_mapping = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        current_time = datetime.datetime.now(pytz.timezone("Europe/Helsinki"))
        day_of_week = current_time.strftime('%a')
        if not day_of_week or day_of_week not in days_of_week_mapping:
            error(f"Could not get current weekday {day_of_week}. Expected values are: {days_of_week_mapping}")
            raise EnvironmentIssue(f"Could not get current weekday {day_of_week}.")
        start_hours = start_time.split(":")[0]
        start_minutes = start_time.split(":")[1]
        cell_pwr = "suspended" if suspend_cell_energy_saving else "notSuspended"
        info(f"Updating power saving window to start at {start_hours}:{start_minutes} on {day_of_week} for "
             f"{power_saving_duration} minutes and set cells in the power group to {cell_pwr}.")
        lbps = {
            "lbpsDayOfWeek": day_of_week,
            "lbpsDuration": str(power_saving_duration),
            "lbpsStartTimeHour": str(start_hours),
            "lbpsStartTimeMinute": str(start_minutes),
            "lbpsSuspended": cell_pwr
        }
        return lbps
