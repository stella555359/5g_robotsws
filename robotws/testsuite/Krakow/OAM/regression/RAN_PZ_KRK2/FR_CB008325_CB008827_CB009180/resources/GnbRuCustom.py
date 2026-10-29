# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor
"""

import time
import logging
from taf.rfrl.bts.devices.exceptions import WrongRadioModuleStatus
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as GnbRu


class GnbRuCustom(GnbRu):

    def __init__(self):
        super(GnbRuCustom, self).__init__()

    @login_logout
    def reset_all_asirmod_radio_units(self, bts_id=0, du_id=0, timeout=120,
                                      reset_type='Soft', force_radio_reset=False, radio_type='asirmod'):
        all_ru_ids = self._get_all_radio_ids(bts_id=bts_id, du_id=du_id, radio_type=radio_type)
        for ru_type in all_ru_ids:
            for ru_id in all_ru_ids[ru_type]:
                dist_name = self.reset_radio_unit(radio_unit_id=ru_id, timeout=timeout, reset_type=reset_type,
                                                  force_radio_reset=force_radio_reset, bts_id=bts_id, du_id=du_id,
                                                  radio_type=ru_type)
                radio_name = dist_name.split("/")[-1]
                radio_reset_status = False
                for attempt in range(5):
                    try:
                        self.verify_asirmod_radio_module_status_during_radio_module_reset(radio_name=radio_name,
                                                                                          bts_id=bts_id, du_id=du_id,
                                                                                          radio_type=radio_type)
                        radio_reset_status = True
                    except WrongRadioModuleStatus as e:
                        logging.info(e)
                        time.sleep(10)
                    finally:
                        if not radio_reset_status:
                            raise AssertionError("Failed to validate radio {} reset status.".format(dist_name))

    @login_logout
    def reset_radio_unit(self, bts_id=0, radio_unit_id=1, du_id=0, timeout=600,
                         reset_type='Soft', force_radio_reset=False, radio_type='rmod'):
        dist_name = self._get_configured_ru_dist_name(bts_id=bts_id, ru_id=radio_unit_id, du_id=du_id,
                                                      radio_type=radio_type)
        alias = self.rest_alias.format(bts_id, du_id)
        if force_radio_reset:
            self.admin.reset_unit(dist_name=dist_name, timeout=timeout, connection=alias, reset_type=reset_type,
                                  force_radio_reset=force_radio_reset)
        else:
            self.admin.reset_unit(dist_name=dist_name, timeout=timeout, connection=alias, reset_type=reset_type)
        return dist_name

    @login_logout
    def verify_all_asirmod_radio_module_status(self, bts_id=0, bts_state="online", du_id=0, radio_type='asirmod'):
        """
        Get number of radios, and check module status for each one
        :param bts_id:      BTS id - related to Test Line configuration. Default: 0
        :param bts_state:   BTS state - related to Test Line status. Default: online
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param radio_type:  "rmod", "asirmod" or "all" if you want to include all RUs. Default: "all"
        :type radio_type:   str
        :return:
        """
        rus_info = self._get_all_rus_info(bts_id=bts_id, du_id=du_id, radio_type=radio_type)
        number_of_radios = len(rus_info)
        ru_in_wrong_status = []
        for radio_id in range(number_of_radios):
            ru_status = rus_info[radio_id]["status"]
            self._unify_statuses(ru_status, required_keys=['availabilityStatus', 'operationalState',
                                                           'administrativeState'])
            try:
                self._verify_asirmod_radio_module_status(bts_state, ru_status["operationalState"],
                                                         ru_status["availabilityStatus"],
                                                         ru_status["administrativeState"])
            except WrongRadioModuleStatus as e:
                if 'configuration' not in rus_info[radio_id]['id']:
                    logging.warning('There is RU connected, with wrong status, but not configured: {}. Object skipped'
                                    .format(rus_info[radio_id]['id']['internal']))
                    continue
                ru_name = self._get_ru_object_name_from_dist_name(dist_name=rus_info[radio_id]['id']['configuration'])
                ru_in_wrong_status.append({
                    "ru_id": ru_name,
                    "error msg": e
                })
        if ru_in_wrong_status:
            raise WrongRadioModuleStatus("Wrong statuses for RU IDs: {}".format(
                ru_in_wrong_status), ru_in_wrong_status)

    @staticmethod
    def _verify_asirmod_radio_module_status(bts_state, operational_state, availability_status, administrative_state):
        """
        Check if statuses of all params are correct
        :param bts_state            BTS state - related to Test Line status. Default: online
        :type bts_state:            basestring
        :param operational_state    Operational state of bts. Default: none
        :type operational_state     basestring
        :param availability_status  Availability status of BTS. Default: none
        :type availability_status   basestring
        :param administrative_state BTS state checked only if BTS state is locked or unlocked
        :type administrative_state  basestring
        :return                     none
        """
        info = ("BTS status is: {}, operational state is: {}, availability status is: {},administrative state "
                "is: {}".format(bts_state, operational_state, availability_status, administrative_state))

        if bts_state == "online" and operational_state == "enabled" and availability_status == "online":
            logging.info(info)
        else:
            raise WrongRadioModuleStatus(info)

    @login_logout
    def verify_asirmod_radio_module_status_during_radio_module_reset(self, radio_name, bts_id=0, du_id=0,
                                                                     radio_type='asirmod'):
        rus_info = self._get_all_rus_info(bts_id=bts_id, du_id=du_id, radio_type=radio_type)
        for radio in rus_info:
            ru_name = self._get_ru_object_name_from_dist_name(dist_name=radio['id']['configuration'])
            if ru_name != radio_name:
                continue
            ru_status = radio["status"]
            self._unify_statuses(ru_status, required_keys=['availabilityStatus', 'operationalState',
                                                           'administrativeState'])
            try:
                self._verify_asirmod_radio_module_status_during_radio_module_reset(ru_status["operationalState"],
                                                                                   ru_status["availabilityStatus"],
                                                                                   ru_status["administrativeState"])
            except WrongRadioModuleStatus as e:
                if 'configuration' not in radio['id']:
                    logging.warning('There is RU connected, with wrong status, but not configured: {}. Object skipped'
                                    .format(radio['id']['internal']))
                    continue

                ru_in_wrong_status = {
                    "ru_id": ru_name,
                    "error msg": e
                }
                if ru_in_wrong_status:
                    raise WrongRadioModuleStatus("Wrong statuses for RU IDs: {}".format(
                        ru_in_wrong_status), ru_in_wrong_status)

    @staticmethod
    def _verify_asirmod_radio_module_status_during_radio_module_reset(operational_state,
                                                                      availability_status, administrative_state):
        """
        Check if statuses of all params are correct
        :param operational_state    Operational state of bts. Default: none
        :type operational_state     basestring
        :param availability_status  Availability status of BTS. Default: none
        :type availability_status   basestring
        :param administrative_state BTS state checked only if BTS state is locked or unlocked
        :type administrative_state  basestring
        :return                     none
        """
        info = ("RU status is: operational state is: {}, availability status is: {}, administrative state "
                "is: {}".format(operational_state, availability_status, administrative_state))

        if operational_state == "disabled" and availability_status == "offline" and administrative_state == "unlocked":
            logging.info(info)
        else:
            raise WrongRadioModuleStatus(info)
