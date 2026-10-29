# -*- coding: utf-8 -*-
"""
Keywords combined from different keyword types e.g. alarm and cell.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

import time
import logging
import datetime
import random

from moler.util.moler_test import MolerTest
from moler.exceptions import ConnectionObserverTimeout, ExecutionException
from moler.device import DeviceFactory

from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue
from taf.internal.sbts.admin.exceptions \
    import AdminApiProcedureFailureException
from taf.internal.robot_typecasts import time_to_seconds

from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    exceptions import StartUpTargetNotMet, SiteNotOnAir, \
    AverageStartupTargetNotMet, LockCellFailure, UnlockCellFailure, \
    LockUnlockTargetNotMet, AverageSwActivationDurationNotMet, \
    SwActivationDurationNotMet, AverageSwUpgradeDurationNotMet,\
    SwUpgradeDurationNotMet, FileNotFound
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import GenericBts, login_logout, login_logout_GUI
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    utilities import load_moler_configuration_from_tl, get_log_path

from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.\
    common.alarm import EnbAlarm, GnbAlarm
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.\
    common.bbu import EnbBbu, GnbBbu
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.\
    common.cell import EnbCell, GnbCell
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.\
    common.link import EnbLink, GnbLink
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.\
    log import EnbLog, GnbLog
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.\
    scf import EnbScf, GnbScf
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.\
    common.ru import EnbRu, GnbRu


class CombinedGenericKeywords(GenericBts):
    """Keywords for eNB and gNB combined from different keyword types e.g.
    alarm and cell"""

    def __init__(self, bts_type, alarm, bbu, cell, link, log, scf, ru):
        """
        Constructor of CombinedGenericKeywords class.
        :param bts_type: GNB|ENB
        :param alarm: Object of EnbAlarm or GnbAlarm
        :param bbu: Object of EnbBbu or GnbBbu
        :param cell: Object of EnbCell or GnbCell class
        :param scf: Object of EnbScf or GnbScf class
        """
        super(CombinedGenericKeywords, self).__init__(bts_type=bts_type)
        self.alarm = alarm
        self.bbu = bbu
        self.cell = cell
        self.link = link
        self.log = log
        self.scf = scf
        self.ru = ru

    @login_logout
    def lock_unlock_all_cells_for_each_group(
            self, bts_id=0, verify_x2_link_drop=True, du_id=0):
        """
        Locks-unlock all cells for each cell group, then locks-unlock
        cell group.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param verify_x2_link_drop: boolean, decides if X2 link drops
         will be verified when all cells are down
        :return: None
        """
        cell_group_ids = self.cell._get_all_cell_group_ids(
            bts_id=bts_id, du_id=du_id)

        cell_ids = list(cell_group_ids)
        for cell_group_id in cell_group_ids:
            cell_ids[cell_group_id] = (
                self.cell._get_cell_ids_in_specific_cell_group(
                    bts_id=bts_id, cell_group_id=cell_group_id,
                    du_id=du_id))
        logging.info("Lock Unlock All Cells For Each Group started")
        for cell_group_id in cell_group_ids:
            logging.info("Group {} started".format(cell_group_id))
            for cell_id in cell_ids[cell_group_id]:
                logging.info("Locking/unlocking cell: {}".format(cell_id))
                self.cell.lock_cell_via_gui(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                self.cell.verify_cell_is_locked(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                if len(cell_ids[cell_group_id]) == 1 and \
                        verify_x2_link_drop is True:
                    self.alarm.verify_alarm_is_active(bts_id=bts_id,
                                                      fault_name="No X2 link"
                                                                 " available",
                                                      du_id=du_id)
                self.cell.unlock_cell_via_gui(bts_id=bts_id,
                                              cell_id=cell_id,
                                              du_id=du_id)
                if len(cell_ids[cell_group_id]) == 1 and \
                        verify_x2_link_drop is True:
                    self.bbu.wait_for_site_to_be_onair(
                        bts_id=bts_id, timeout=480, interval=10)
                    self.alarm.verify_alarm_is_not_active(
                        bts_id=bts_id, fault_name="No X2 link available",
                        du_id=du_id)
                self.cell.wait_for_cell_to_be_onair(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)

            logging.info("Locking cell group : {}".format(cell_group_id))
            self.cell.lock_cell_group_via_gui(
                bts_id=bts_id, cell_group_id=cell_group_id, du_id=du_id)
            if len(cell_group_ids) == 1 and verify_x2_link_drop is True:
                time.sleep(75)
                self.alarm.verify_alarm_is_active(
                    bts_id=bts_id,
                    fault_name="No X2 link available",
                    du_id=du_id)
            logging.info("Unlocking cell group : {}".format(cell_group_id))
            self.cell.unlock_cell_group_via_gui(
                bts_id=bts_id, cell_group_id=cell_group_id, du_id=du_id)
            if len(cell_group_ids) == 1 and verify_x2_link_drop is True:
                self.bbu.wait_for_site_to_be_onair(
                    bts_id=bts_id, timeout=480, interval=10)
                self.alarm.verify_alarm_is_not_active(bts_id=bts_id,
                                                      fault_name="No X2 link available",
                                                      du_id=du_id)
            logging.info("Group {} ended".format(cell_group_id))

    @login_logout
    def block_unblock_all_cells_for_each_group(self, bts_id=0,
                                               verify_x2_link_drop=True,
                                               du_id=0):
        """
        Blocks-unblock all cells for each cell group, then
         blocks-unblock cell group.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param verify_x2_link_drop: boolean, decides if X2 link drops will
         be verified when all cells are down
        :return: None
        """

        cell_group_ids = self.cell._get_all_cell_group_ids(bts_id=bts_id,
                                                           du_id=du_id)
        cell_ids = list(cell_group_ids)
        for cell_group_id in cell_group_ids:
            cell_ids[cell_group_id] = (
                self.cell._get_cell_ids_in_specific_cell_group(
                    bts_id=bts_id, cell_group_id=cell_group_id,
                    du_id=du_id))
        logging.info("Lock Unlock All Cells For Each Group started")
        for cell_group_id in cell_group_ids:
            logging.info("Group {} started".format(cell_group_id))
            for cell_id in cell_ids[cell_group_id]:
                logging.info("Blocking/unblocking cell: {}".format(cell_id))
                self.cell.block_cell(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                self.cell.verify_cell_is_blocked(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                self.cell.unblock_cell(bts_id=bts_id,
                                       cell_id=cell_id, du_id=du_id)
                self.cell.wait_for_cell_to_be_onair(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)

    @login_logout
    def lock_all_cells_and_then_unlock_for_each_group(self, bts_id=0,
                                                      verify_x2_link_drop=True,
                                                      du_id=0):
        """
        Locks all cells for each cell group, then unlocks them all back.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param verify_x2_link_drop: boolean, decides if X2 link drops will
         be verified when all cells are down
        :return: None
        """
        cell_group_ids = self.cell._get_all_cell_group_ids(bts_id=bts_id,
                                                           du_id=du_id)

        cell_ids = list(cell_group_ids)
        for cell_group_id in cell_group_ids:
            cell_ids[cell_group_id] = (
                self.cell._get_cell_ids_in_specific_cell_group(
                    bts_id=bts_id, cell_group_id=cell_group_id,
                    du_id=du_id))
        logging.info("Lock All Cells And Then Unlock For Each Group started")
        for cell_group_id in cell_group_ids:
            logging.info("Group {} started".format(cell_group_id))
            for cell_id in cell_ids[cell_group_id]:
                logging.info("Locking cell: {}".format(cell_id))
                self.cell.lock_cell_via_gui(bts_id=bts_id,
                                            cell_id=cell_id,
                                            du_id=du_id)
                self.cell.verify_cell_is_locked(bts_id=bts_id,
                                                cell_id=cell_id,
                                                du_id=du_id)
            if len(cell_group_ids) == 1 and verify_x2_link_drop is True:
                time.sleep(75)
                self.alarm.verify_alarm_is_active(bts_id=bts_id,
                                                  fault_name="No X2 link "
                                                             "available",
                                                  du_id=du_id)
                x2_link_down = True
            for cell_id in cell_ids[cell_group_id]:
                logging.info("Unlocking cell: {}".format(cell_id))
                self.cell.unlock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                                              du_id=du_id)
                if len(cell_group_ids) == 1 and verify_x2_link_drop is \
                        True and x2_link_down is True:
                    self.bbu.wait_for_site_to_be_onair(
                        bts_id=bts_id, timeout=480, interval=10)
                    self.alarm.verify_alarm_is_not_active(
                        bts_id=bts_id,
                        fault_name="No X2 link available",
                        du_id=du_id)
                    x2_link_down = False
                self.cell.wait_for_cell_to_be_onair(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)
            logging.info("Group {} ended".format(cell_group_id))

    @login_logout
    def block_all_cells_and_then_unblock_one_by_one(self, bts_id=0,
                                                    verify_x2_link_drop=True,
                                                    du_id=0):
        """
        Blocks all cells one by one, then unlbocks them all back.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param verify_x2_link_drop: boolean, decides if X2 link drops
         will be verified when all cells are down
        :return: None
        """
        cells_ids = self.cell._get_all_global_cell_ids(bts_id=bts_id,
                                                       du_id=du_id)
        cells_ids_rand = random.sample(cells_ids, len(cells_ids))
        for cell_id in cells_ids_rand:
            logging.info("Blocking cell: {}".format(cell_id))
            self.cell.block_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
            self.cell.verify_cell_is_blocked(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
            logging.info("Unblocking cell: {}".format(cell_id))
            self.cell.unblock_cell(bts_id=bts_id, cell_id=cell_id,
                                   du_id=du_id)
            self.cell.wait_for_cell_to_be_onair(bts_id=bts_id,
                                                cell_id=cell_id,
                                                du_id=du_id)
        logging.info("All cells unblocking {} ended")

    @login_logout
    def lock_all_cell_groups_and_then_unlock(self, bts_id=0,
                                             verify_x2_link_drop=True,
                                             du_id=0):
        """
        Locks all cell groups, then unlock them back.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param verify_x2_link_drop: boolean, decides if X2 link drops
        will be verified when all cells are down
        :return: None
        """
        cell_group_ids = self.cell._get_all_cell_group_ids(bts_id=bts_id,
                                                           du_id=du_id)

        logging.info("Lock All Cell Groups And Then Unlock started")
        for cell_group_id in cell_group_ids:
            logging.info("Locking cell group : {}".format(cell_group_id))
            self.cell.lock_cell_group_via_gui(
                bts_id=bts_id, cell_group_id=cell_group_id, du_id=du_id)
        if verify_x2_link_drop is True:
            time.sleep(75)
            self.alarm.verify_alarm_is_active(bts_id=bts_id,
                                              fault_name="No X2 link "
                                                         "available",
                                              du_id=du_id)
        for cell_group_id in cell_group_ids:
            logging.info("Unlocking cell group : {}".format(cell_group_id))
            self.cell.unlock_cell_group_via_gui(bts_id=bts_id,
                                                cell_group_id=cell_group_id,
                                                du_id=du_id)
        if verify_x2_link_drop is True:
            self.bbu.wait_for_site_to_be_onair(bts_id=bts_id, timeout=480,
                                               interval=10)
            self.alarm.verify_alarm_is_not_active(bts_id=bts_id,
                                                  fault_name="No X2 link "
                                                             "available",
                                                  du_id=du_id)

    def measure_start_up_time(self, bts_id=0, runs=1, target=0.99,
                              time_target=420,
                              timeout=600, du_id=0,
                              raise_exception=True,
                              reset_type="bts_site_reset",
                              end_measure_time="last_cell_up"):
        """
        Performs bts reset given amount of times, checks if site fully
        recovered and measures start-up time,
        then checks if PASSED to RUNS ratio meets given target.
        :param end_measure_time: first_cell_up or last_cell_up
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param runs: Number of runs
        :param target: Target PASSED to RUNS ratio
        :param time_target: Target start-up time in seconds.
        :param timeout: Wait for onAir after bts reset timeout in seconds.
        :param raise_exception: True/False - raise StartUpTargetNotMet exception
         if avg/ratio not met targets
        :param reset_type: Way of reset. Available: bts_site_reset,
        bts_power_reset, bbmod_reset, ru_reset.
        :return: Dict containing: avg, ratio.
        """
        passed = 0
        failed = 0
        passed_run_times = []
        for run in range(1, int(runs) + 1):
            start_time = datetime.datetime.now()
            MolerTest.info('Run: {}'.format(run))
            GnbLog().start_collecting_btslog(bts_id=bts_id, du_id=du_id)
            try:
                run_result = self._measure_start_up_time(
                    bts_id=bts_id,
                    du_id=du_id,
                    time_target=time_to_seconds(time_target),
                    timeout=time_to_seconds(timeout),
                    reset_type=reset_type,
                    end_measure_time=end_measure_time)

                if isinstance(run_result, datetime.timedelta):
                    passed += 1
                    passed_run_times.append(run_result)
                    current_startup_avg = sum(passed_run_times,
                                              datetime.timedelta(0)) / len(
                        passed_run_times)
                    MolerTest.info("Run: {} passed".format(run))
                    MolerTest.info('Current start-up time average of successful '
                                   'runs: {}'.format(current_startup_avg))
                else:
                    MolerTest.warning("Run: {} failed, start time:"
                                      " {}".format(run, start_time))
                    failed += 1
            except ExecutionException as e:
                failed += 1
                MolerTest.warning("Some unexpected exception occurred: {}/n"
                                  "Please analyze logs!".format(repr(e)))
                MolerTest.warning("Run: {} failed, start time:"
                                  " {}".format(run, start_time))

            self.bbu.wait_for_site_to_be_onair(bts_id=bts_id, du_id=du_id)
            MolerTest.sleep(60)
            GnbLog().stop_collecting_btslog(bts_id=bts_id, du_id=du_id,
                                            log_dir=get_log_path(),
                                            file_prefix='run{}'.format(run))

        passed_ratio = passed / float(runs)
        average_startup_time = None
        MolerTest.info("Passed/runs ratio: {}".format(passed_ratio))
        exceptions = []
        if len(passed_run_times) > 0:
            average_startup_time = (
                    sum(passed_run_times,
                        datetime.timedelta(0)) / len(passed_run_times)).total_seconds()
            MolerTest.info('Start-up time average of total successful '
                           'runs: {} sec'.format(average_startup_time))

            if average_startup_time > int(time_target):
                exceptions.append(
                    AverageStartupTargetNotMet("Average startup time {}s exceed presume "
                                               "value {}s"
                                               .format(average_startup_time,
                                                       time_target)))

        if passed_ratio < float(target):
            exceptions.append(
                StartUpTargetNotMet("Runs: {}\nFailed: {}\nRatio: {}\n"
                                    "Target not met".
                                    format(runs, failed, passed_ratio)))

        if raise_exception and exceptions:
            raise StartUpTargetNotMet("\n".join([repr(e) for e in exceptions]))
        else:
            return {'exceptions': exceptions, 'ratio': passed_ratio,
                    'avg': round(average_startup_time, 1)}

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    @login_logout
    def _measure_start_up_time(
            self, bts_id=0, time_target=420, timeout=600, du_id=0,
            reset_type="bts_site_reset",
            end_measure_time="last_cell_up"):
        """
        Checks if site fully recovered after bts reset, measures time from
        the moment first cell goes Offline
        to the moment last cell goes Online, and checks if it meets given
        time target.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param time_target: Target start-up time in seconds.
        :param timeout: Wait for onAir after bts reset timeout in seconds.
        :param reset_type: Way of reset. Available: bts_site_reset,
         bts_power_reset, bbmod_reset, ru_reset.
        :param end_measure_time: first_cell_up or last_cell_up
        :return: True if start-up time is shorter than time_target,
        otherwise False.
        """
        try:
            max_time_target = time_target * 1.2
            event_name_before_reset = "cell_status_from_online_to_offline"
            if reset_type == 'ru_reset':
                all_ru_ids = self.ru._get_all_radio_ids(bts_id=bts_id,
                                                        du_id=du_id)
                last_ru_id = max(all_ru_ids)
                cell_ids = self.cell._get_all_global_cell_ids(
                    bts_id=bts_id, du_id=du_id, radio_id=last_ru_id)
                event_name_before_reset = "cell_status_from_online_to_failed"
            else:
                cell_ids = self.cell._get_all_global_cell_ids(bts_id=bts_id,
                                                              du_id=du_id)

            syslog = DeviceFactory.get_device(self.syslog_alias.format(
                bts_id, du_id))
            syslog.goto_state('SYSLOG', keep_state=False)
            if reset_type != "bts_power_reset":
                first_cell_down = syslog.get_event(
                    event_name=event_name_before_reset,
                    event_params={"till_occurs_times": 1})
                first_cell_down.start()

            syslog.goto_state('SYSLOG', keep_state=False)

            last_cell_up = syslog.get_event(event_name="cell_status_from_"
                                                       "offline_to_online",
                                            event_params={
                                                "till_occurs_times":
                                                    len(cell_ids)}
                                            )
            last_cell_up.start()

            if reset_type.lower() == "bts_site_reset":
                self.bbu.reset_bts(bts_id=bts_id, du_id=du_id)
            elif reset_type.lower() == "bts_power_reset":
                self.bbu.bts_power_off(bts_id=bts_id, du_id=du_id)
                first_cell_down_result = [{'time': datetime.datetime.now()}]
                self.bbu.bts_power_on(bts_id=bts_id, du_id=du_id)
            elif reset_type.lower() == "bbmod_reset":
                self.bbu.reset_abil_via_gui(bts_id=bts_id, du_id=du_id)
            elif reset_type.lower() == "ru_reset":
                self.ru.reset_radio_unit(bts_id=bts_id, du_id=du_id,
                                         radio_unit_id=last_ru_id,
                                         timeout=timeout,
                                         force_radio_reset=True)
            else:
                raise AttributeError("reset_type={} not supported."
                                     .format(reset_type))

            if reset_type != "bts_power_reset":
                first_cell_down_result = first_cell_down.await_done(timeout=60)

            last_cell_up_result = last_cell_up.await_done(timeout=timeout)

            cell_set = set()
            cell_ids_set = set()

            for cell_event in last_cell_up_result:
                cell_set.add(int(cell_event['groups'][0][7:]))
            cell_ids_set.update(cell_ids)

            if cell_ids_set != cell_set:
                logging.debug("Observer caught desired amount of 'offline to"
                              " online' prints - "
                              "but probably for one of cell print "
                              "occurred twice")
                logging.debug("Dump current BTS status")
                self.bbu.get_bts_info(bts_id=bts_id, du_id=du_id)
                logging.warning("Caught cell ids: {}".format(cell_set))
                logging.warning("Configured cell ids: {}".format(cell_ids_set))
                logging.warning("Cell ids dont match, getting snapshot")
                logging.warning("Snapshot location: {}".format(
                    self.log.collect_snapshot()))
                self.bbu.reset_bts(bts_id=bts_id, du_id=du_id)
                MolerTest.steps_end()
                return

            if end_measure_time == "first_cell_up":
                start_up_time = last_cell_up_result[0]['time'] -\
                                first_cell_down_result[0]['time']
            else:
                start_up_time = last_cell_up_result[len(cell_ids) - 1]['time'] -\
                                first_cell_down_result[0]['time']
            logging.info("Start-up time: {}".format(start_up_time))
            time_limit = datetime.timedelta(seconds=max_time_target)
            MolerTest.steps_end()
            if start_up_time > time_limit:
                logging.warning("Site start-up time too long({}),"
                                " getting snapshot".format(start_up_time))
                logging.warning("Snapshot location:"
                                " {}".
                                format(self.log.collect_snapshot(bts_id=bts_id, du_id=du_id)))
                return
            else:
                return start_up_time
        except AdminApiProcedureFailureException as e:
            if reset_type != "bts_power_reset":
                first_cell_down.cancel()
            last_cell_up.cancel()
            MolerTest.steps_end()
            logging.warning("[AdminApiProcedureFailureException]"
                            " occurred: {}.\n"
                            "Repeating last iteration. Time: "
                            "{}".format(repr(e), datetime.datetime.now()))
            return self._measure_start_up_time(bts_id=bts_id, du_id=du_id,
                                               time_target=time_target,
                                               timeout=timeout,
                                               reset_type=reset_type)
        except ConnectionObserverTimeout:
            try:
                self.cell.verify_setup_of_all_cells(bts_id=bts_id, du_id=du_id)
                MolerTest.steps_end()
                logging.warning("Syslog did not catch all cells status changes,"
                                " but all cells are online.\n"
                                "Repeating last iteration. Time:"
                                " {}".format(datetime.datetime.now()))
                return self._measure_start_up_time(
                    bts_id=bts_id, du_id=du_id,
                    time_target=time_target, timeout=timeout,
                    reset_type=reset_type)
            except IncorrectParameterValue:
                logging.warning("Start-up time exceeded set timeout ({} seconds), "
                                "getting snapshot".format(timeout))
                logging.warning("Snapshot location:"
                                " {}".format(self.log.collect_snapshot(bts_id=bts_id, du_id=du_id)))
                logging.warning("Executing site reset as recovery")
                self.bbu.reset_bts(bts_id=bts_id, du_id=du_id)
                for i in range(5):
                    try:
                        self.bbu.wait_for_site_to_be_onair(bts_id=0, du_id=0,
                                                           timeout=600)
                        logging.warning(
                            "Site recovered, snapshot location: {}".format(
                                self.log.collect_snapshot(bts_id=bts_id,
                                                          du_id=du_id)))
                        break
                    except SiteNotOnAir:
                        logging.warning("Site not on-air after reset, "
                                        "executing RU power reset as "
                                        "recovery")
                        self.ru.power_reset_radio_unit(bts_id=bts_id,
                                                       du_id=du_id)
                MolerTest.steps_end()
                return

    def measure_time_cell_lock_or_unlock(
            self, operation="lock", runs=1, time_target=20, timeout=160,
            bts_id=0,
            du_id=0):
        """
        Performs cell lock and unlock given amount of times and check
         if duration of lock
        and unlock is less than the given time value.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param operation - lock or unlock
        :param runs: Number of runs
        :param time_target: Target lock and unlock time in seconds.
        :param timeout: Wait for value/ regexp found in the syslog.
        :return: average time: Average time lock or unlock
        """
        if operation == "lock":
            runs_time_lock = []
            for run in range(int(runs)):
                logging.info("Run: {} ".format(run))
                lock = self._measure_time_cell_lock_or_unlock(
                    operation=operation, time_target=time_target,
                    timeout=timeout, bts_id=bts_id, du_id=du_id)
                runs_time_lock.append(lock)
            average_time = sum(runs_time_lock) / len(runs_time_lock)
            logging.info("Lock cell. Avg {}, Max {}, Runs: {}"
                         .format(average_time, max(runs_time_lock),
                                 len(runs_time_lock)))

        if operation == "unlock":
            runs_time_unlock = []
            for run in range(int(runs)):
                logging.info("Run: {} ".format(run))
                unlock = self._measure_time_cell_lock_or_unlock(
                    operation=operation, time_target=time_target,
                    timeout=timeout, bts_id=bts_id, du_id=du_id)

                runs_time_unlock.append(unlock)
            average_time = sum(runs_time_unlock) / len(runs_time_unlock)
            logging.info("Unlock cell. Avg {}, Max {},"
                         " Runs: {}".format(average_time,
                                            max(runs_time_unlock),
                                            len(runs_time_unlock)))

        return round(average_time, 1)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    @login_logout
    def _measure_time_cell_lock_or_unlock(
            self, operation="lock", bts_id=0, time_target=20, timeout=160,
            du_id=0):
        """
        Measure time cell lock and unlock and check if it is less than
         the given time value.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param operation - lock or unlock
        :param time_target: Target lock and unlock time in seconds.
        :param timeout: Wait for value/ regexp found in the syslog.
        :return: None
        """
        err_message = ""
        cell_ids = self.cell._get_all_global_cell_ids(bts_id=bts_id,
                                                      du_id=du_id)
        syslog = DeviceFactory.get_device(self.syslog_alias.format(bts_id,
                                                                   du_id))
        time_limit = datetime.timedelta(seconds=int(time_target))
        logging.info("Syslog {}".format(syslog))

        if operation == "lock":
            try:
                syslog.goto_state('SYSLOG')
                lock_request_start = syslog.get_event(
                    event_name="accept_download_request_plan",
                    event_params={"till_occurs_times": 1})
                cell_go_down = syslog.get_event(
                    event_name="cell_status_from_online_to_offline",
                    event_params={"till_occurs_times": 1})
                cell_go_down.start()
                lock_request_start.start()
                self.cell.lock_cell(bts_id=bts_id, cell_id=cell_ids[0],
                                    du_id=du_id)
                lock_request_start_result = lock_request_start.\
                    await_done(int(timeout))
                cell_go_down_result = cell_go_down.await_done(int(timeout))
                self.cell.unlock_cell(bts_id=bts_id, cell_id=cell_ids[0],
                                      du_id=du_id)
                self.cell.wait_for_cell_to_be_onair(cell_id=cell_ids[0])
            except ConnectionObserverTimeout:
                MolerTest.steps_end()
                self.cell.unlock_cell(bts_id=bts_id, cell_id=cell_ids[0],
                                      du_id=du_id)
                raise LockCellFailure("Cell was not properly locked")

            lock_cell_request_time = lock_request_start_result[0]['time']
            cell_go_down_time = cell_go_down_result[0]['time']
            operation_time = cell_go_down_time - lock_cell_request_time
            logging.info("Cell lock time duration: {}".format(operation_time))

            if operation_time > time_limit:
                err_message = ("Cell lock time duration {} exceeded max "
                               "expected time {} seconds"
                               .format(operation_time.total_seconds(),
                                       time_target))

        elif operation == "unlock":
            try:
                self.cell.lock_cell(bts_id=bts_id, cell_id=cell_ids[0],
                                    du_id=du_id)
                self.cell.wait_for_cell_to_be_locked(cell_id=cell_ids[0])
                syslog.goto_state('SYSLOG')
                unlock_request_start = syslog.get_event(
                    event_name="accept_download_request_plan",
                    event_params={"till_occurs_times": 1})
                cell_go_up = syslog.get_event(
                    event_name="cell_status_from_offline_to_online",
                    event_params={"till_occurs_times": 1})
                cell_go_up.start()
                unlock_request_start.start()
                self.cell.unlock_cell(bts_id=bts_id, cell_id=cell_ids[0],
                                      du_id=du_id)
                unlock_request_start_result = \
                    unlock_request_start.await_done(int(timeout))
                cell_go_up_result = cell_go_up.await_done(int(timeout))
            except ConnectionObserverTimeout:
                MolerTest.steps_end()
                raise UnlockCellFailure("Cell was not properly unlocked")

            unlock_cell_request_time = unlock_request_start_result[0]['time']
            cell_go_up_time = cell_go_up_result[0]['time']
            operation_time = cell_go_up_time - unlock_cell_request_time
            logging.info("Cell unlock time duration: {}".format(
                operation_time))

            if operation_time > time_limit:
                err_message = ("Cell unlock time duration {} exceeded "
                               "max expected time {} seconds"
                               .format(operation_time.total_seconds(),
                                       time_target))

        if err_message != "":
            MolerTest.steps_end()
            raise LockUnlockTargetNotMet(err_message)
        else:
            MolerTest.steps_end()
            return operation_time.total_seconds()

    @login_logout
    def measure_cell_lock_unlock_time_via_gui(
            self, bts_id=0, du_id=0, runs=1, target=1, time_target=40,
            timeout=160,
            raise_exception=True):
        """
        Performs cell lock/unlock given amount of times, checks if site
        fully recovered and measures operation time,
        then checks if results meet given target.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param runs: Number of runs
        :param target: passed/all runs ratio
        :param time_target: Target lock/unlock operation time in seconds.
        :param timeout: Wait for value/ regexp found in the syslog.
        :param raise_exception: True/False - raise LockUnlockTargetNotMet
        exception if avg/ratio not met targets
        :return: Dict containing: avg, ratio, exceptions.
        """
        passed = 0
        failed = 0
        passed_run_times = []
        cell_ids = self.cell._get_all_global_cell_ids(bts_id=bts_id,
                                                      du_id=du_id)
        for run in range(1, int(runs) + 1):
            logging.info("Run: {} ".format(run))
            cell_id = random.choice(cell_ids)
            logging.info("Selected cell ID: {}".format(cell_id))
            run_result = self._measure_cell_lock_unlock_time_via_gui(
                time_target=time_target, timeout=timeout,
                bts_id=bts_id, du_id=du_id, cell_id=cell_id)
            if isinstance(run_result, datetime.timedelta):
                passed += 1
                passed_run_times.append(run_result)
                current_lock_unlock_avg = sum(passed_run_times,
                                              datetime.timedelta(0)) / len(passed_run_times)
                logging.info("Run: {} passed. Cell lock/unlock"
                             " time: {} seconds".format(run, run_result))
                logging.info('Current lock/unlock time average of '
                             'successful runs: {}'.
                             format(current_lock_unlock_avg))
            else:
                logging.warning("Run: {} failed".format(run))
                failed += 1
        passed_ratio = passed / float(runs)
        average_lock_unlock_time = None
        logging.info("Passed/runs ratio: {}".format(passed_ratio))
        exceptions = []
        if len(passed_run_times) > 0:
            average_lock_unlock_time = (
                    sum(passed_run_times,
                        datetime.timedelta(0)) / len(passed_run_times)).total_seconds()
            logging.info('Lock/unlock time average of total successful runs:'
                         ' {} sec'.format(average_lock_unlock_time))
            if average_lock_unlock_time > int(time_target):
                exceptions.append(LockUnlockTargetNotMet("Average lock/unlock "
                                                         "time {}s exceed presume "
                                                         "value {}s"
                                                         .format(average_lock_unlock_time, time_target)))
        if passed_ratio < float(target):
            exceptions.append(LockUnlockTargetNotMet("Runs: {}; "
                                                     "Failed: {}; "
                                                     "Ratio: {}; "
                                                     "Target not met".
                                                     format(runs, failed,
                                                            passed_ratio)))
        if raise_exception and exceptions:
            raise LockUnlockTargetNotMet("\n".join([repr(e)
                                                    for e in exceptions]))
        else:
            return {'exceptions': exceptions, 'ratio': passed_ratio,
                    'avg': round(average_lock_unlock_time, 1)}

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def _measure_cell_lock_unlock_time_via_gui(self, bts_id=0, du_id=0,
                                               cell_id=1, time_target=40,
                                               timeout=160):
        """
        Checks if site fully recovered after cell lock/unlock operation,
         measures time from the moment first cell goes
        Offline to the moment last cell goes Online, and checks if it
        meets given time target.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: id of cell to be locked and unlocked.
        :param time_target: Target cell lock/unlock operation time in seconds.
        :param timeout: Wait for value/ regexp found in the syslog.
        :return: Cell lock/unlock time if passed, otherwise None.
        """
        self.log.start_collecting_syslog(bts_id, du_id)
        syslog = DeviceFactory.get_device(self.syslog_alias.format(bts_id,
                                                                   du_id))
        self.log.start_collecting_syslog(bts_id, du_id)
        logging.info("Syslog {}".format(syslog))
        syslog.goto_state('SYSLOG')
        try:
            cell_go_down = syslog.get_event(event_name="cell_status_from"
                                                       "_online_to_offline",
                                            event_params={
                                                "till_occurs_times": 1})
            cell_go_down.start()
            self.cell.lock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                                        du_id=du_id)
            cell_go_down_result = cell_go_down.await_done(int(timeout))
        except ConnectionObserverTimeout:
            MolerTest.steps_end()
            self.cell.unlock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                                          du_id=du_id)
            logging.warning(LockCellFailure("Cell was not properly locked"))
            return None
        try:
            unlock_request_start = syslog.get_event(event_name="accept_download_"
                                                               "request_plan",
                                                    event_params={
                                                        "till_occurs_times":
                                                            1})
            cell_go_up = syslog.get_event(
                event_name="cell_status_from_offline_to_online",
                event_params={"till_occurs_times": 1})
            unlock_request_start.start()
            cell_go_up.start()
            start_unlock = datetime.datetime.now()
            self.cell.unlock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                                          du_id=du_id)
            unlock_request_start_result = unlock_request_start.await_done(
                int(timeout))
            cell_go_up_result = cell_go_up.await_done(int(timeout))
        except ConnectionObserverTimeout:
            MolerTest.steps_end()
            logging.warning(UnlockCellFailure("Cell was not"
                                              " properly unlocked"))
            return None
        cell_go_down_time = cell_go_down_result[0]['time']
        logging.info("Cell lock time: {}".format(cell_go_down_time))
        logging.info("Start Cell unlock time: {}".format(start_unlock))
        unlock_request_start_time = unlock_request_start_result[0]['time']
        logging.info("Cell unlock request time: {}".format(
            unlock_request_start_time))
        cell_go_up_time = cell_go_up_result[0]['time']
        logging.info("Cell unlock time: {}".format(cell_go_up_time))
        time_limit = datetime.timedelta(seconds=int(time_target))
        click_time = unlock_request_start_time - start_unlock
        cell_lock_unlock_time = cell_go_up_time - cell_go_down_time - click_time
        err_message_list = []
        if cell_lock_unlock_time > time_limit:
            err_message_list.append("Cell lock/unlock time duration {}"
                                    " exceeded max expected time {} seconds"
                                    .format(cell_lock_unlock_time.total_seconds(),
                                            time_target))
        if len(err_message_list) > 0:
            MolerTest.steps_end()
            logging.warning(LockUnlockTargetNotMet(err_message_list))
            return None
        self.log.stop_collecting_syslog(bts_id, du_id)
        MolerTest.steps_end()
        return cell_lock_unlock_time

    @login_logout
    def measure_cell_block_unblock_time_via_gui(self, bts_id=0, du_id=0,
                                                runs=1, time_target=40,
                                                timeout=160):
        """
        Performs cell block/unblock given amount of times, checks if site
         fully recovered and measures operation time,
        then checks if results meet given target.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param runs: Number of runs
        :param time_target: Target lock/unlock operation time in seconds.
        :param timeout: Wait for value/ regexp found in the syslog.
        :return: Dict containing: avg, ratio, exceptions.
        """
        passed = 0
        failed = 0
        passed_run_times = []
        run_times = []
        average_lock_unlock_time = None
        time_limit = datetime.timedelta(seconds=int(time_target))
        cell_ids = self.cell._get_all_global_cell_ids(bts_id=bts_id,
                                                      du_id=du_id)
        for run in range(1, int(runs) + 1):
            MolerTest.info("Run: {} ".format(run))
            GnbLog().start_collecting_btslog(bts_id=bts_id, du_id=du_id)
            cell_id = random.choice(cell_ids)
            MolerTest.info("Selected cell ID: {}".format(cell_id))
            run_result = \
                self._measure_cell_block_unblock_time_via_gui(
                    timeout=timeout,
                    bts_id=bts_id,
                    du_id=du_id,
                    cell_id=cell_id)['block_unblock_duration']
            if isinstance(run_result, datetime.timedelta):
                run_times.append(run_result)
                if run_result <= time_limit:
                    passed += 1
                    passed_run_times.append(run_result)
                    average_lock_unlock_time = (
                            sum(passed_run_times,
                                datetime.timedelta(0)) / len(
                                passed_run_times)).total_seconds()
                    MolerTest.info("Run: {} passed.".format(run))
                else:
                    MolerTest.warning("Run: {} failed".format(run))
                    failed += 1

                MolerTest.info("Cell block/unblock time: {} seconds"
                               .format(run_result))
                MolerTest.info('Current block/unblock time average of '
                               'successful runs: {}'.
                               format(average_lock_unlock_time))
            else:
                MolerTest.warning("Cannot measure block/unblock time due to issue "
                                  "with block/unblock")
                MolerTest.warning("Run: {} failed".format(run))
                failed += 1

            GnbLog().stop_collecting_btslog(bts_id=bts_id, du_id=du_id,
                                            log_dir=get_log_path(),
                                            file_prefix='run{}'.format(run))

        passed_ratio = passed / float(runs)
        MolerTest.info("Summary of block/unblock procedure")
        MolerTest.info("Total Runs: {}\n"
                       "Passed: {}\n"
                       "Failed: {}\n"
                       "Ratio: {}\n"
                       "Average time {}\n"
                       "Min time {}\n"
                       "Max time {}".format(runs, passed,
                                            failed, passed_ratio,
                                            average_lock_unlock_time,
                                            min(run_times), max(run_times)))

        return {'ratio': passed_ratio, 'avg': round(
            average_lock_unlock_time, 1)}

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def _measure_cell_block_unblock_time_via_gui(
            self, bts_id=0, du_id=0, cell_id=1, timeout=160):
        """
        Checks if site fully recovered after cell lock/unlock operation,
        measures time from the moment first cell goes
        Offline to the moment last cell goes Online, and checks if
        it meets given time target.
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param cell_id: id of cell to be blocked and unblocked.
        :param timeout: Wait for value/ regexp found in the syslog.
        :return: Cell block/unblock time if passed, otherwise None.

        Block alarm:
                 "severity": "Critical",
                 "alarmId": 7102,
                 "faultId": 49,
        """

        block_fault_id = 49
        self.log.start_collecting_syslog(bts_id, du_id)
        syslog = DeviceFactory.get_device(self.syslog_alias.format(bts_id, du_id))
        syslog.goto_state('SYSLOG')
        try:
            cell_go_down = syslog.get_event(event_name="cell_status_from_"
                                                       "online_to_offline",
                                            event_params={
                                                "till_occurs_times": 1})

            # INF/SysAdapter/URI/GW, [urigw::statemachine::
            # SessionEstablishedState]
            # decoded /MRBTS-1/RAT-1/URI-1/SESSION-127153/BLOCK_IND-0
            # trying to commit
            re_block_request = r'SysAdapter.*\/BLOCK_IND-\d+ trying to commit'
            block_request = syslog.get_event(event_name="wait4",
                                             event_params={
                                                 "detect_patterns":
                                                     [re_block_request],
                                                 "till_occurs_times": 1})
            cell_go_down.start()
            block_request.start()

            self.cell.block_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
            start_waiting_for_alarm_timestamp = datetime.datetime.now()
            self.alarm.wait_for_alarm_activation(fault_id=block_fault_id)
            end_waiting_for_alarm_timestamp = datetime.datetime.now()

            block_request_result = block_request.await_done(15)
            cell_go_down_result = cell_go_down.await_done(int(timeout))

            block_duration = cell_go_down_result[0]['time'] - block_request_result[0]['time']
            awaiting_for_alarm_activation = end_waiting_for_alarm_timestamp - start_waiting_for_alarm_timestamp
            MolerTest.info("Block duration(measured to cell goes to offline"
                           " state) {}".format(block_duration))
            MolerTest.info("Alarm occurred after {}".format(
                awaiting_for_alarm_activation))
        except ConnectionObserverTimeout:
            MolerTest.steps_end()
            self.cell.unblock_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
            MolerTest.warning("Cell was not properly blocked")
            return None
        try:
            cell_go_up = syslog.get_event(event_name="cell_status_from_offline_to"
                                                     "_online",
                                          event_params={
                                              "till_occurs_times": 1})

            # INF/SysAdapter/URI/GW, [urigw::statemachine::SessionEstablishedState]
            # decoded /MRBTS-1/RAT-1/URI-1/SESSION-159953/UNBLOCK_IND-0
            # trying to commit
            re_unblock_request = r'SysAdapter.*\/UNBLOCK_IND-\d+ ' \
                                 r'trying to commit'
            unblock_request = syslog.get_event(
                event_name="wait4",
                event_params={"detect_patterns": [re_unblock_request],
                              "till_occurs_times": 1})
            unblock_request.start()
            cell_go_up.start()

            self.cell.unblock_cell(bts_id=bts_id, cell_id=cell_id,
                                   du_id=du_id)
            start_waiting_for_alarm_timestamp = \
                datetime.datetime.now()
            self.alarm.wait_for_alarm_deactivation(
                fault_id=block_fault_id)
            end_waiting_for_alarm_timestamp = \
                datetime.datetime.now()

            unblock_request_result = unblock_request.await_done(15)
            cell_go_up_result = cell_go_up.await_done(int(timeout))

            unblock_duration = cell_go_up_result[0]['time'] - unblock_request_result[0]['time']
            awaiting_for_alarm_deactivation = \
                end_waiting_for_alarm_timestamp - \
                start_waiting_for_alarm_timestamp
            MolerTest.info("Unblock duration(measured to cell goes"
                           " to online state) {}".format(unblock_duration))
            MolerTest.info("Alarm disappeared after {}".format(
                awaiting_for_alarm_deactivation))
        except ConnectionObserverTimeout:
            MolerTest.steps_end()
            MolerTest.warning("Cell was not properly unblocked")
            return None

        results = {
            'block_unblock_duration': block_duration + unblock_duration,
            'block_duration': block_duration,
            'unblock_duration': unblock_duration,
        }

        self.log.stop_collecting_syslog(bts_id, du_id)
        MolerTest.steps_end()
        return results

    @login_logout
    def remove_cell_from_configuration(self, cell_id, bts_id=0,
                                       cell_group_id=0, du_id=0):
        """
        Removes cell with given id from configuration.
        :param cell_id:     id of cell that will be removed
        :param cell_group_id:            group id of removed cell
        :param bts_id:                   gNB id - related to Test
        Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        cell_ids_in_group = \
            self.cell._get_cell_ids_in_specific_cell_group(
                bts_id=bts_id,
                du_id=du_id,
                cell_group_id=cell_group_id)
        new_cell_ids = []
        for cell_id_in_group in cell_ids_in_group:
            if cell_id_in_group != int(cell_id):
                new_cell_ids.append(cell_id_in_group)
        mrbts_id = self.get_bts_instance_id(bts_id=bts_id, du_id=du_id)
        delta = [{
            'distName': dist_name + "/NRCELL-" + str(cell_id),
            'operation': 'delete',
            'parameters': []
        }, {
            'distName': dist_name + "/NRCELLGRP-" + cell_group_id,
            'operation': 'update',
            'parameters': [{
                'operation': 'update',
                'parameterName': 'nrCellList',
                'value': new_cell_ids
            }]
        }, {
            'distName': dist_name,
            'operation': 'update',
            'parameters': [{
                'operation': 'update',
                'parameterName': 'maxNumScellsDl',
                'value': len(new_cell_ids) - 1
            }]
        }, {
            'distName': "MRBTS-" + str(mrbts_id) +
                        "/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-" +
                        str(cell_id),
            'operation': 'delete',
            'parameters': []
        }]

        self.scf.perform_bts_delta_commissioning(delta=delta)

    @login_logout
    def remove_fr1_cell_and_nrcellgrp_from_configuration(
            self, cell_id, cell_group_id, bts_id=0, du_id=0):
        """
        Removes cell with given id from configuration.
        :param cell_id:     id of cell that will be removed
        :param cell_group_id:            group id of removed cell
        that will be removed
        :param bts_id:                   gNB id - related to Test
         Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        group_ids_in_nrdu = self.cell._get_all_cell_group_ids(
            bts_id=bts_id, du_id=du_id)
        new_group_ids = []
        for group_id_in_nrdu in group_ids_in_nrdu:
            if group_id_in_nrdu != int(cell_group_id):
                new_group_ids.append(str(group_id_in_nrdu))
        mrbts_id = self.get_bts_instance_id(bts_id=bts_id, du_id=du_id)
        delta = [{
            'distName': dist_name + "/NRCELL-" + str(cell_id),
            'operation': 'delete',
            'parameters': []
        }, {
            'distName': dist_name + "/NRCELLGRP-" + str(cell_group_id),
            'operation': 'delete',
            'parameters': []
        }, {
            'distName': "MRBTS-" + str(mrbts_id) +
                        "/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-" + str(cell_id),
            'operation': 'delete',
            'parameters': []
        }, {
            'distName': "MRBTS-" + str(mrbts_id) + "/NRBTS-" +
                        str(mrbts_id) + "/NRDU-1",
            'operation': 'update',
            'parameters': [{
                'operation': 'update',
                'parameterName': 'refNrCellGroup',
                'value': new_group_ids
            }]
        }]

        self.scf.perform_bts_delta_commissioning(delta=delta)

    @login_logout
    def _set_x2_link_to(self, parameter, value, bts_id=0, du_id=0):
        """
        Set parameter and value for eNB or gNB.
        :param bts_id: ID of eNB/gNB
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param parameter: parameter to be changed - administrativeState
        for eNB, x2LinkLock for gNB
        :param value: action to be performed, either 'locked' or 'unlocked'
        :return: None.
        """
        dist_name = self.patterns.x2_link_dist_name.format(
            self.get_bts_instance_id(bts_id, du_id),
            self.get_global_bts_id(bts_id, du_id))

        self.scf.perform_parameter_recommissioning(
            dist_name, parameter, 'update', value,
            skip_parameter_relation_errors=False, should_activate=True,
            timeout=60, bts_id=bts_id, du_id=du_id)

    @login_logout_GUI
    def add_extension_panel_and_configure_proper_beamset_via_gui(
            self, number_of_extenders, prodCodePlanned,
            first_rmod_id, second_rmod_id, loglinkId,
            basicBeamSet, cell_id=None, bts_id=0, du_id=0):
        """
        Configure extension panel or panels and set proper beamset values
         for given configuration.
        :param number_of_extenders:      number of extenders to configure
        :param prodCodePlanned:          value of prodCodePlanned parameter
        of extension panel
        :param first_rmod_id:            id of existing RMOD corresponding
        to radio unit
        :param second_rmod_id:           id of new RMOD corresponding to
        extension panel
        :param loglink_id:               id of the new loglink
        :param basicBeamSet              dict with beam set and angles e.g.
                                         basicBeamSet = {
                                        "Basic Beam Set": "beamSetFR2_6_6_4_2P",
                                        "Left Cell Edge Angle": "90",
                                        "Lower Cell Edge Angle": "110",
                                        "Right Cell Edge Angle": "90",
                                        "Upper Cell Edge Angle": "90"
                                        }
        :param cell_id                  cell id value - set to None to
        configure beam sets for all cells
        :param bts_id:                  bts id - related to Test Line
         configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: None
        """

        self.ru.gui_coam = self.gui_coam
        self.cell.gui_coam = self.gui_coam
        for index in range(number_of_extenders):
            second_rmod_id += index
            loglinkId += index
            loglinkName = "EXTMOD-{}".format(index + 1)
            self.ru._add_new_rmod_based_on_existing_rmod_to_configuration_via_gui(
                prodCodePlanned, first_rmod_id,
                second_rmod_id, bts_id=bts_id,
                du_id=du_id)
            self.ru._add_new_loglink_via_gui(
                loglinkId, loglinkName, first_rmod_id, second_rmod_id,
                bts_id=bts_id,
                du_id=du_id)

        self.cell._set_new_beamset_value_via_gui(
            basicBeamSet, cell_id=cell_id, bts_id=bts_id, du_id=du_id)
        self.gui_coam.activate_plan()

    def measure_du_software_upgrade_time(
            self, path, success_rate, average_target, timeout=2500,
            bts_id=0, du_id=0):
        """
        Perform DU sw upgrade, measure time and verify if meet average
        time target and success rate ratio.
        :param path: list of absolute paths on VM with expected DU
        build to update
        :param bts_id:  default BTS id
        :param du_id: default DU id
        :param success_rate: Target PASSED to RUNS ratio
        :param average_target: Target sw download time in seconds.
        :param timeout:  time in seconds to wait for sw upgrade
        """
        max_target = 1.2 * float(average_target)
        passed = 0
        failed = 0
        runs = len(path)
        passed_time_results = []

        for p in path:
            upgrade_time_result = self._measure_du_software_upgrade_time(
                p, timeout=int(timeout), bts_id=0,
                du_id=0)
            time.sleep(60)

            if upgrade_time_result == "FileNotFound":
                runs -= 1
                logging.warning("FileNotFoundError for {}. Skipping.."
                                ".".format(p))
            elif isinstance(upgrade_time_result, datetime.timedelta):
                if max_target < upgrade_time_result.total_seconds():
                    failed += 1
                else:
                    passed += 1
                    passed_time_results.append(
                        upgrade_time_result.total_seconds())
            else:
                failed += 1

        exceptions = []
        if len(passed_time_results) > 0:
            average_sw_upgrade_time = sum(passed_time_results) / len(
                passed_time_results)
            logging.info("Average SW activation duration {}".format(
                average_sw_upgrade_time))

            if int(average_target) <= int(average_sw_upgrade_time):
                exceptions.append(
                    AverageSwUpgradeDurationNotMet(
                        "Average Sw upgrade time {}s exceed presume "
                        "value {}s".format(average_sw_upgrade_time,
                                           average_target)))

        if runs > 0:
            passed_ratio = passed / runs
            if float(passed_ratio) < float(success_rate):
                exceptions.append(SwUpgradeDurationNotMet(
                    "Runs: {}, Failed: {}, Ratio: {} "
                    "Target not met".format(runs, failed, passed_ratio)))

        if exceptions:
            raise SwUpgradeDurationNotMet("\n".join([repr(e) for e in exceptions]))
        elif runs == 0 or len(passed_time_results) == 0:
            raise SwUpgradeDurationNotMet("No software upgrade was performed"
                                          " or no test passed. "
                                          "Runs: {}, Passed upgrades: {}".
                                          format(runs, len(passed_time_results)))
        else:
            logging.info("Runs: {}, Ratio: {}, Avg time: {} "
                         "Max time: {}".
                         format(runs, passed_ratio, round(average_sw_upgrade_time, 2),
                                max(passed_time_results)))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    @login_logout
    def _measure_du_software_upgrade_time(self, path, timeout=2500,
                                          bts_id=0, du_id=0):
        """
        Perform DU sw activation, measure time and verify if meet average
        time target and success rate ratio.
        :param path: list of absolute paths on VM with expected DU build
         to download
        :param bts_id:  default BTS id
        :param du_id: default DU id
        :param success_rate: Target PASSED to RUNS ratio
        :param average_target: Target sw download time in seconds.
        :param timeout:  time in seconds to wait for sw activation
        """
        try:
            start_update_time = datetime.datetime.now()

            MolerTest.info("Start upgrade sw build - downloading..."
                           " {}".format(start_update_time))
            self.admin.update_software(
                sw_package=path, should_activate=True, timeout=timeout,
                connection=self.rest_alias.format(bts_id, du_id))

            MolerTest.info(
                "Download build Finish {}".format(datetime.datetime.now()))
            cell_ids = self.cell._get_all_global_cell_ids(bts_id=bts_id,
                                                          du_id=du_id)
            MolerTest.info(cell_ids)

            syslog = DeviceFactory.get_device(self.syslog_alias.format(
                bts_id, du_id))
            syslog.goto_state('SYSLOG', keep_state=False)
            first_cell_up = syslog.get_event(
                event_name="cell_status_from_offline_to_online",
                event_params={"till_occurs_times": 1})

            MolerTest.info("FIRST_CELL_UP_RESULT_START_CHECK: {}".format(
                datetime.datetime.now()))
            first_cell_up_result = first_cell_up(timeout=int(timeout))
            MolerTest.info("FIRST_CELL_UP_RESULT" + "".
                           join(map(str, first_cell_up_result)))
            end_update_time = first_cell_up_result[0]['time']
            MolerTest.steps_end()

        except ConnectionObserverTimeout as e:
            logging.warning("ConnectionObserverTimeout: {}".format(e))
            MolerTest.steps_end()
            return

        except FileNotFound:
            MolerTest.steps_end()
            return "FileNotFound"

        MolerTest.info("Start time: " + str(start_update_time) +
                       "   type: " + str(type(start_update_time)))
        MolerTest.info("End time: " + str(end_update_time) +
                       "   type: " + str(type(end_update_time)))
        sw_upgrade_duration = (end_update_time - start_update_time)
        logging.info("Duration of Software Upgrade: {}".format(
            sw_upgrade_duration.total_seconds()))
        return sw_upgrade_duration

    def measure_du_software_activation_time(self, path, success_rate,
                                            average_target,
                                            timeout=900,
                                            bts_id=0,
                                            du_id=0):
        """
        Perform DU sw activation, measure time and verify if meet average
        time target and success rate ratio.
        :param path: list of absolute paths on VM with expected DU
         build to download
        :param bts_id:  default BTS id
        :param du_id: default DU id
        :param success_rate: Target PASSED to RUNS ratio
        :param average_target: Target sw download time in seconds.
        :param timeout:  time in seconds to wait for sw activation
        """
        max_target = 1.2 * float(average_target)
        passed = 0
        failed = 0
        runs = len(path)
        passed_time_results = []

        for p in path:
            activation_time_result =\
                self._measure_du_software_activation_time(p,
                                                          timeout=int(timeout),
                                                          bts_id=0,
                                                          du_id=0)
            time.sleep(120)

            if activation_time_result == "FileNotFound":
                runs -= 1
                logging.warning("FileNotFoundError for {}. Skipping...".format(p))
            elif isinstance(activation_time_result, datetime.timedelta):
                if max_target < activation_time_result.total_seconds():
                    failed += 1
                else:
                    passed += 1
                    passed_time_results.append(
                        activation_time_result.total_seconds())
            else:
                failed += 1

        exceptions = []
        if len(passed_time_results) > 0:
            average_sw_activation_time = sum(passed_time_results) / len(
                passed_time_results)
            logging.info("Average SW activation duration {}".format(
                average_sw_activation_time))

            if int(average_target) <= int(average_sw_activation_time):
                exceptions.append(
                    AverageSwActivationDurationNotMet(
                        "Average Sw activation time {}s exceed presume "
                        "value {}s".format(average_sw_activation_time,
                                           average_target)))

        if runs > 0:
            passed_ratio = passed / runs
            if float(passed_ratio) < float(success_rate):
                exceptions.append(SwActivationDurationNotMet(
                    "Runs: {}, Failed: {}, Ratio: {} Target not met".format(
                        runs, failed, passed_ratio)))

        if exceptions:
            raise SwActivationDurationNotMet("\n".join([repr(e)
                                                        for e in
                                                        exceptions]))
        elif runs == 0 or len(passed_time_results) == 0:
            raise SwActivationDurationNotMet(
                "No software activation was performed or no test "
                "passed. Runs: {}, ""Passed activations: {}".format(
                    runs, len(passed_time_results)))
        else:
            logging.info("Runs: {}, Ratio: {}, Avg time: {} "
                         "Max time: {}".
                         format(runs, passed_ratio,
                                round(average_sw_activation_time, 2),
                                max(passed_time_results)))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    @login_logout
    def _measure_du_software_activation_time(self, path, timeout=1200,
                                             bts_id=0, du_id=0):
        """
        Perform DU sw activation, measure time and verify if meet average
         time target and success rate ratio.
        :param path: list of absolute paths on VM with expected DU build
        to update
        :param bts_id:  default BTS id
        :param du_id: default DU id
        :param timeout:  time in seconds to wait for sw activation
        """
        try:
            MolerTest.info(
                "Prepare build to activation - downloading."
                ".. {}".format(datetime.datetime.now()))
            self.admin.update_software(sw_package=path, should_activate=False,
                                       timeout=timeout,
                                       connection=self.rest_alias.format(
                                           bts_id, du_id))
            MolerTest.info("Download build Finish {}".format(
                datetime.datetime.now()))

            cell_ids = self.cell._get_all_global_cell_ids(
                bts_id=bts_id, du_id=du_id)
            MolerTest.info(cell_ids)

            syslog = DeviceFactory.get_device(
                self.syslog_alias.format(bts_id, du_id))
            syslog.goto_state('SYSLOG', keep_state=False)
            first_cell_down = syslog.get_event(
                event_name="cell_status_from_online_to_offline",
                event_params={"till_occurs_times": 1})
            first_cell_down.start()

            MolerTest.info(
                "Start sw_activation {}".format(datetime.datetime.now()))
            self.admin.update_software(
                sw_package=path, should_activate=True, timeout=timeout,
                connection=self.rest_alias.format(bts_id, du_id))

            first_cell_down_result = first_cell_down.await_done(timeout=200)
            MolerTest.info(
                "First_CELL_down_RESULT" + "".
                join(map(str, first_cell_down_result)))

            syslog.goto_state('SYSLOG', keep_state=False)
            last_cell_up = syslog.get_event(
                event_name="cell_status_from_offline_to_online",
                event_params={"till_occurs_times": len(cell_ids)})
            last_cell_up_result = last_cell_up(timeout=int(timeout))

            self.log.stop_collecting_syslog()
            MolerTest.info(
                "Sw activation finish: {}".format(datetime.datetime.now()))
            MolerTest.info(
                "LAST_CELL_UP_RESULT" + "".join(map(str, last_cell_up_result)))

            start_activation_time = first_cell_down_result[0]['time']
            end_activation_time = last_cell_up_result[len(cell_ids) - 1]['time']
            MolerTest.steps_end()

        except ConnectionObserverTimeout as e:
            logging.warning("ConnectionObserverTimeout: {}".format(e))
            MolerTest.steps_end()
            return

        except FileNotFound:
            MolerTest.steps_end()
            return "FileNotFound"

        MolerTest.info("Start time: " +
                       str(start_activation_time) + "   type: " +
                       str(type(start_activation_time)))
        MolerTest.info("End time: " +
                       str(end_activation_time) + "  type: " +
                       str(type(end_activation_time)))
        sw_activation_time = (end_activation_time - start_activation_time)
        MolerTest.info("Duration of Software {} activation: "
                       "{}".format(path,
                                   sw_activation_time.total_seconds()))
        return sw_activation_time


class CombinedEnbKeywords(CombinedGenericKeywords):
    """Class contains keywords for eNB combined from different keyword
    types e.g. alarm and cell"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.
        """

        super(CombinedEnbKeywords, self).__init__(
            bts_type=CombinedEnbKeywords.bts_type,
            alarm=EnbAlarm(),
            bbu=EnbBbu(),
            cell=EnbCell(),
            link=EnbLink(),
            log=EnbLog(),
            scf=EnbScf(),
            ru=EnbRu())

    def unlock_x2_link(self, enb_id=0, du_id=0):
        """
        Unlock x2 link on eNB.
        :param enb_id: ID of eNB
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: None.
        """
        self._set_x2_link_to(bts_id=enb_id, du_id=du_id,
                             parameter='administrativeState', value='unlocked')

    def lock_x2_link(self, enb_id=0, du_id=0):
        """
        Unlock x2 link on eNB.
        :param enb_id: ID of eNB
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: None.
        """
        self._set_x2_link_to(bts_id=enb_id,
                             du_id=du_id, parameter='administrativeState',
                             value='locked')


class CombinedGnbKeywords(CombinedGenericKeywords):
    """Class contains keywords for gNB combined from different
     keyword types e.g. alarm and cell"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.
        """
        super(CombinedGnbKeywords, self).__init__(
            bts_type=CombinedGnbKeywords.bts_type,
            alarm=GnbAlarm(),
            bbu=GnbBbu(),
            cell=GnbCell(),
            link=GnbLink(),
            log=GnbLog(),
            scf=GnbScf(),
            ru=GnbRu())

    def unlock_x2_link(self, gnb_id=0, du_id=0):
        """
        Unlock x2 link on gNB.
        :param gnb_id: ID of gNB
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None.
        """
        self._set_x2_link_to(bts_id=gnb_id, du_id=du_id,
                             parameter='x2LinkLock',
                             value='unlocked')

    def lock_x2_link(self, gnb_id=0, du_id=0):
        """
        Unlock x2 link on gNB.
        :param gnb_id: ID of gNB
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :return: None.
        """
        self._set_x2_link_to(bts_id=gnb_id, du_id=du_id,
                             parameter='x2LinkLock',
                             value='locked')

    @login_logout
    def get_radio_details_linked_to_cell_id(self, bts_id=0, du_id=0,
                                            cell_id=1,
                                            cell_id_type='physical'):
        """
        Get RMOD information linked to cell_id.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: cell id.
        :param cell_id_type: 'physical' or 'global'
        :return: RMOD info
        """

        bts_info = self.admin.get_bts_info(connection=self.rest_alias.
                                           format(bts_id, du_id))
        rmod_id = self.cell._get_rmod_id_related_to_cell_id(bts_id,
                                                            du_id,
                                                            cell_id,
                                                            cell_id_type,
                                                            bts_info)
        ru_info = self.ru._get_ru_info(bts_id, du_id, rmod_id,
                                       bts_info=bts_info)

        return {'RMOD_ID': rmod_id, 'RU_INFO': ru_info}
