# -*- coding: utf-8 -*-
"""
Specific keywords for feature 5GC000431

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import re
import logging
from datetime import datetime
from datetime import timedelta
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout_GUI
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning as GnbScf
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns as GnbDNP
from moler.device import DeviceFactory

gnb_bbu = GnbBbu()
gnb_scf = GnbScf()
gnb_dnp = GnbDNP()


@load_moler_configuration_from_tl()
def _get_formatted_date_from_bts(delay=0):
    """
    Get time from BTS in specific format
    :return: dict
    :return: example:
    {
        'lbpsStartTimeMinute': '37',
        'lbpsDayOfWeek': 'Fri',
        'lbpsStartTimeHour': '09'
    }
    """
    bts = DeviceFactory.get_device(name=gnb_bbu.ssh_alias.format('0', '0'))
    cmd = bts.get_cmd(cmd_name="date", cmd_params={'options': '-s \"{} minutes\"'.format(delay)})
    cmd_ret = cmd()
    lbps_params_dict = {
        'lbpsDayOfWeek': cmd_ret['DAY_NAME'][0:3].encode("utf-8"),
        'lbpsStartTimeHour': cmd_ret['TIME']['HOUR'].encode("utf-8"),
        'lbpsStartTimeMinute': cmd_ret['TIME']['MINUTE'].encode("utf-8")
    }
    return lbps_params_dict


def turn_on_lbps_for_specific_time(how_many_mins_lbps_should_work=10, delay=0):
    """
    Turn on lbps for specific time, _get_formatted_date_from_bts()
    date to start took from _get_formatted_date_from_bts
    :param how_many_mins_lbps_should_work: time in minutes how long lbps should work
    :param delay: how many mins lbps start should be delayed
    :return:
    {
        "type": "ADMIN_API",
        "payload":
            {"errorCode": 0,
             "requestStatus": "completed",
             "requestId": 56883,
             "requestMessage":
                {"commissioningResult":
                    {"isGoingToTriggerReset": false,
                     "activationResult":
                        {"resultNode":
                            {"distName": "/MRBTS-1/RAT-1/URI-1/SESSION-67/PLAN_ACTIVATE_IND-1/PLAN_ACTIVATE_RESULT-1",
                            "parameters":
                                {"result": "Success",
                                "feedback": "",
                                "resetCoverage": ["None"],
                                "rejectedObjects": []}},
                    "indicationDistName": "/MRBTS-1/RAT-1/URI-1/SESSION-67/PLAN_ACTIVATE_IND-1"}},
                 "validationResult":
                    {"niddValidationResult":
                        {"status": "OK",
                         "logs":
                            {"skippedElements": null,
                             "missingObjectsErrors": null,
                             "definitionErrors": null,
                             "maxOccurrencesErrors": null}},
                         "pdlValidationResult":
                            {"status": "OK",
                             "logs":
                                {"hardwareErrors": [],
                                 "relationErrors": []}}},
                 "modifiedObjectsDistNames":
             {"deleted": [],
              "modified": ["MRBTS-51102/NRBTS-51102/NRPGRP-0"]}},
              "time": "10:14:17 AM"}
    }
    """
    lbps_parameter = _get_formatted_date_from_bts(delay)
    lbps_parameter['lbpsDuration'] = how_many_mins_lbps_should_work
    lbps_parameter['lbpsSuspended'] = 'notSuspended'
    lbps_parameter_list = [
        {
            'parameterName': 'lbpsPeriodList',
            'operation': 'update',
            'value': [lbps_parameter]
        }
    ]
    return gnb_scf.perform_object_recommissioning(dist_name='MRBTS-{}/NRBTS-{}/NRPGRP-0',
                                                  parameter=lbps_parameter_list,
                                                  operation='update')


class GnbPowerSaving(GenericBts):
    """Class contains Power Saving keywords for gNB"""

    def __init__(self):
        """
        Constructor of Gnb Power Saving class.
        """
        super(GnbPowerSaving, self).__init__(bts_type='GNB')

    @login_logout_GUI
    def turn_on_lbps_for_specific_time_selenium(self, how_many_mins_lbps_should_work=10, node_index=0,  delay=0,
                                                power_group_id=0, activate_plan_despite_errors=False, bts_id=0,
                                                du_id=0):
        """
        Turn on load-based power saving for specific time, _get_formatted_date_from_bts()
        date to start took from _get_formatted_date_from_bts

        :param how_many_mins_lbps_should_work: time in minutes how long lbps should work
        :param delay: how many mins lbps start should be delayed
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param node_index: node index
        :type node_index: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        }
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        lbps_parameter = _get_formatted_date_from_bts(delay)
        lbps_parameter['lbpsDuration'] = how_many_mins_lbps_should_work
        lbps_parameter['lbpsSuspended'] = 'notSuspended'
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving day of week',
                                          new_value=lbps_parameter['lbpsDayOfWeek'].decode("utf-8"),
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving duration',
                                          new_value=lbps_parameter['lbpsDuration'],
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving start time hour',
                                          new_value=str(lbps_parameter['lbpsStartTimeHour']),
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving start time minute',
                                          new_value=str(lbps_parameter['lbpsStartTimeMinute']),
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-Based Power Saving Suspended',
                                          new_value=str(lbps_parameter['lbpsSuspended']),
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors,
                                    sbts=gui_alias)

    @login_logout_GUI
    def set_last_cell_switch_off_value(self, value, power_group_id, node_index=0, activate_plan_despite_errors=False,
                                       bts_id=0, du_id=0):
        """
        Enable/disable last cell switch off value in power group.

        :param value: true or false, whether last cell could be switched off or not
        :param power_group_id: power group id
        :param node_index: node index
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :type value: str
        :type power_group_id: int
        :type node_index: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name(gnb_dnp.bts_dist_name, bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving last cell switch off enabled',
                                          abbr='lbpsLastCellSOEnabled',
                                          new_value=value,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def turn_on_lbps_for_specific_time_step_by_step_selenium(self, lbps_day_of_week='Mon', lbps_duration_in_min=10,
                                                             lbps_start_time_hour=0, lbps_start_time_minute=0,
                                                             node_index=0, bts_id=0, du_id=0,
                                                             power_group_id=0, activate_plan_despite_errors=False):
        """
        Turn on load-based power saving for specific time. In order to set the time,
        the parameters are set directly on gNB

        :param lbps_day_of_week: the day in which lbps should work
        :param lbps_duration_in_min: time in minutes how long lbps should work
        :param lbps_start_time_hour: the hour in which lbps should start work
        :param lbps_start_time_minute: the minute in which lbps should start work
        :param node_index: node index
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :type lbps_day_of_week: enum
        :type lbps_duration_in_min: int
        :type lbps_start_time_hour: int
        :type lbps_start_time_minute: int
        :type power_group_id: int
        :type node_index: int
        :return: None
        }
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        lbps_suspended = 'notSuspended'
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving day of week',
                                          new_value=lbps_day_of_week.decode("utf-8"),
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving duration',
                                          new_value=lbps_duration_in_min,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving start time hour',
                                          new_value=lbps_start_time_hour,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving start time minute',
                                          new_value=lbps_start_time_minute,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-Based Power Saving Suspended',
                                          new_value=str(lbps_suspended),
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)

        activation_status = self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors,
                                                        sbts=gui_alias)
        if not activation_status:
            self.gui_coam.undo_changes(sbts=gui_alias)
            self.gui_coam.validate_plan(sbts=gui_alias)
            raise ValueError('Plan activation is unsuccessful')

    @login_logout_GUI
    def turn_on_lbps_for_specific_percentage_step_by_step_selenium(self, lbps_max_load=70, lbps_min_load=20,
                                                                   lbps_last_min_load=0, power_group_id=0, du_id=0,
                                                                   bts_id=0, activate_plan_despite_errors=False):
        """
        Turn on load-based power saving for specific percentage load. In order to set the percentage load,
        the parameters are set directly on gNB

        :param lbps_max_load: the maximum load for lbps
        :param lbps_min_load:  the minimum load for lbps
        :param lbps_last_min_load: the minimum load for the last cell
        :param power_group_id: power group id
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bts_id:  ID of gNB/eNB, default 0
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :type lbps_max_load: int
        :type lbps_min_load: int
        :type lbps_last_min_load: int
        :type power_group_id: int
        :return: None
        }
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving maximum load',
                                          new_value=lbps_max_load,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving minimum load',
                                          new_value=lbps_min_load,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving last cell minimum load',
                                          new_value=lbps_last_min_load,
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)

        activation_status = self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors,
                                                        sbts=gui_alias)
        if not activation_status:
            self.gui_coam.undo_changes(sbts=gui_alias)
            self.gui_coam.validate_plan(sbts=gui_alias)
            raise ValueError('Plan activation is unsuccessful')

    @login_logout_GUI
    def add_new_power_saving_period_list(self, how_many_mins_lbps_should_work=10, node_index=0, delay=0,
                                         power_group_id=0, activate_plan_despite_errors=False, bts_id=0, du_id=0):
        """
        Add new power saving period list

        :param how_many_mins_lbps_should_work: time in minutes how long lbps should work
        :param delay: how many mins lbps start should be delayed
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param node_index: node index
        :type node_index: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        }
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.add_element(dist_name=power_group_dist_name,
                                  filter_param='Load-based power saving period list',
                                  abbr='lbpsPeriodList', sbts=gui_alias)
        self.turn_on_lbps_for_specific_time_selenium(power_group_id=power_group_id, node_index=node_index,
                                                     how_many_mins_lbps_should_work=how_many_mins_lbps_should_work,
                                                     delay=delay)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def remove_power_saving_period_list(self, power_group_id, node_index=0, activate_plan_despite_errors=False,
                                        bts_id=0, du_id=0):

        """
        Remove power saving period list

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :param node_index: node index
        :type power_group_id: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.remove_element(dist_name=power_group_dist_name,
                                     filter_param='Load-based power saving period list',
                                     abbr='lbpsPeriodList',
                                     node_index=node_index,
                                     sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def add_new_power_group(self, power_group_id, cell_id, cell_switch_off_order=100, node_index=0,
                            activate_plan_despite_errors=False, bts_id=0, du_id=0):

        """
        Add new power group.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used
        :type cell_id: int
        :param power_group_id: power group id
        :type power_group_id: int
        :param cell_switch_off_order: cell switch off order
        :type cell_switch_off_order: int
        :param node_index: node index
        :type node_index: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='NRPGRP',
                                 id_value=power_group_id,
                                 is_load_default_values=True,
                                 sbts=gui_alias)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving cell switch off order',
                                          new_value=cell_switch_off_order,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='NR cell configuration identifier',
                                          new_value=cell_id,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.turn_on_lbps_for_specific_time_selenium(power_group_id=power_group_id, node_index=node_index,
                                                     how_many_mins_lbps_should_work=10, delay=0)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def remove_power_group(self, power_group_id, activate_plan_despite_errors=False, bts_id=0, du_id=0):

        """
        Remove power group.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.remove_object(object_name=power_group_dist_name, sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def check_if_cell_will_not_be_added_to_two_power_groups(self, power_group_id, cell_id, cell_switch_off_order,
                                                            node_index, bts_id=0, du_id=0):
        """
        Check if cell will not be added to two power groups.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used
        :type cell_id: int
        :param power_group_id: power group id
        :type power_group_id: int
        :param cell_switch_off_order: cell switch off order
        :type cell_switch_off_order: int
        :param node_index: node index
        :type node_index: int
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.add_element(dist_name=power_group_dist_name,
                                  filter_param='Load-based power saving cell list',
                                  abbr='lbpsCellList',
                                  sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='Load-based power saving cell switch off order',
                                          new_value=cell_switch_off_order,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=power_group_dist_name,
                                          filter_param='NR cell configuration identifier',
                                          new_value=cell_id,
                                          node_index=int(node_index),
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        try:
            self.gui_coam.activate_plan(sbts=gui_alias)
        except Exception as e:
            logging.info("Cell was not added to two power groups. Exception message {}".format(e))

    @login_logout_GUI
    def remove_cell_from_power_group(self, power_group_id, node_index, activate_plan_despite_errors=False,  bts_id=0,
                                     du_id=0):
        """
        Remove cell from power group.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param node_index: node index
        :type node_index: int
        :param activate_plan_despite_errors: allow to activate plan despite validation errors
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        self.gui_coam.remove_element(dist_name=power_group_dist_name,
                                     filter_param='Load-based power saving cell list',
                                     abbr='lbpsCellList',
                                     node_index=node_index,
                                     sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    @login_logout_GUI
    def check_if_last_cell_will_not_be_removed_from_power_group(self, power_group_id, node_index, bts_id=0, du_id=0):
        """
        Check if last cell will not be removed from power group.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param node_index: node index
        :type node_index: int
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        try:
            self.gui_coam.remove_element(dist_name=power_group_dist_name,
                                         filter_param='Load-based power saving cell list',
                                         abbr='lbpsCellList',
                                         node_index=node_index,
                                         sbts=self.gui_alias.format(bts_id, du_id))
        except Exception as e:
            logging.info("Last cell was not removed from power group. Exception message {}".format(e))

    @login_logout_GUI
    def get_power_saving_period_time_start(self, power_group_id, node_index, bts_id=0,  du_id=0):
        """
        Get power saving period time start.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param node_index: node index
        :type node_index: int
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        hour = self.gui_coam.get_parameter_value(dist_name=power_group_dist_name,
                                                 filter_param='Load-based power saving start time hour',
                                                 node_index=int(node_index),
                                                 sbts=gui_alias)
        minute = self.gui_coam.get_parameter_value(dist_name=power_group_dist_name,
                                                   filter_param='Load-based power saving start time minute',
                                                   node_index=int(node_index),
                                                   sbts=gui_alias)
        hour = re.findall(r'\d+', hour)
        minute = re.findall(r'\d+', minute)
        return str(hour[0]), str(minute[0])

    @login_logout_GUI
    def get_power_saving_period_time_end(self, power_group_id, node_index, bts_id=0,  du_id=0):
        """
        Get power saving period time end.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :type power_group_id: int
        :param node_index: node index
        :type node_index: int
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name, str(power_group_id))
        hour = self.gui_coam.get_parameter_value(dist_name=power_group_dist_name,
                                                 filter_param='Load-based power saving start time hour',
                                                 node_index=int(node_index),
                                                 sbts=gui_alias)
        minute = self.gui_coam.get_parameter_value(dist_name=power_group_dist_name,
                                                   filter_param='Load-based power saving start time minute',
                                                   node_index=int(node_index),
                                                   sbts=gui_alias)
        duration = self.gui_coam.get_parameter_value(dist_name=power_group_dist_name,
                                                     filter_param='Load-based power saving duration',
                                                     node_index=int(node_index),
                                                     sbts=gui_alias)

        hour = re.findall(r'\d+', hour)
        minute = re.findall(r'\d+', minute)
        duration = re.findall(r'\d+', duration)
        lista = [hour[0], minute[0]]
        time = str(" ".join(lista))
        time_format = datetime.strptime(time, "%H %M")
        now_plus_10 = time_format + timedelta(minutes=int(duration[0]))
        hour = now_plus_10.hour
        minute = now_plus_10.minute
        return str(hour), str(minute)

    def verify_time_frame_ended(self, power_group_id, node_index, bts_id=0,  du_id=0):
        """
        Get power saving period time end and check if it ended.

        :param node_index: node index
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :return: None
        """
        hour, minute = self.get_power_saving_period_time_end(power_group_id, node_index, bts_id, du_id)
        now = datetime.now()
        if int(hour) < now.hour or (int(hour) == now.hour and int(minute) < now.minute):
            logging.info('Feature activation time frame has ended')
        else:
            raise Exception('Feature activation time has not ended')

    def verify_time_frame_started(self, power_group_id, node_index, bts_id=0,  du_id=0):
        """
        Get power saving period time start and check if it started.

        :param node_index: node index
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param power_group_id: power group id
        :return: None
        """
        hour, minute = self.get_power_saving_period_time_start(power_group_id, node_index, bts_id, du_id)
        now = datetime.now()
        if int(hour) < now.hour or (int(hour) == now.hour and int(minute) < now.minute):
            logging.info('Feature activation time frame has started')
        else:
            raise Exception('Feature activation time has not started')

    @load_moler_configuration_from_tl()
    def get_formatted_date_from_bts(self):
        """
        Get time from BTS in specific format
        :return: dict
        :return: example:
        {
            'lbpsStartTimeMinute': '37',
            'lbpsDayOfWeek': 'Fri',
            'lbpsStartTimeHour': '09'
        }
        """
        lbps_parameter = _get_formatted_date_from_bts(delay=0)
        regex = "^0+(?!$)"
        hour = lbps_parameter['lbpsStartTimeHour']
        hour = re.sub(regex, "", hour.decode('UTF-8'))
        minute = lbps_parameter['lbpsStartTimeMinute']
        minute = re.sub(regex, "", minute.decode('UTF-8'))
        return hour, minute
