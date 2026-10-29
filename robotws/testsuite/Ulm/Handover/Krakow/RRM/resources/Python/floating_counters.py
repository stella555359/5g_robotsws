"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
import copy
import os
import sys
import threading
import time
import traceback
import xmltodict
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


def _get_robot_context():
    try:
        from robot.running.context import EXECUTION_CONTEXTS
        return EXECUTION_CONTEXTS.current
    except Exception:
        pass
    return None


def _is_dry_run():
    try:
        current_context = _get_robot_context()
        if current_context.dry_run:
            return True
    except Exception:
        pass
    return False


class floating_counters(object):
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, forbidden_period=35):
        self.ROBOT_LIBRARY_LISTENER = self
        self.counter_interface = BuiltIn().get_library_instance('ta5g_pm_counters')
        self.forbidden_period = int(forbidden_period)
        self.sleep_for_start = 10
        self.is_running = threading.Event()
        self._thread_started = threading.Semaphore(0)
        self._thread_stopped = threading.Semaphore(0)
        self.collected_filepaths = []
        self.last_timestamp = None
        self.merged_filepath = None
        self.thread = None
        self.exception = None

    def _end_test(self, name, attr):
        if _is_dry_run():
            return
        if self.is_running.is_set():
            logger.info('[FLOATING COUNTERS] Forcing stop due to end of TC, files will not be merged.'
                        ' Still have to wait for next pm files arrival', also_console=True)
            self.stop_collecting_counters(force=True)

    def start_collecting_counters(self):
        self._raise_when_exception_occured()
        self.merged_filepath = None
        self.collected_filepaths = []
        self.last_timestamp = None
        logger.info(
            '[FLOATING COUNTERS] Waiting for next interval before start', also_console=True)
        self.counter_interface.wait_for_next_full_pm_interval()
        self.last_timestamp = time.time()
        logger.info('[FLOATING COUNTERS] Sleeping additional {}s'.format(
            self.sleep_for_start), also_console=True)
        time.sleep(self.sleep_for_start)
        self.thread = threading.Thread(target=self._collect_counters_in_thread)
        self.thread.start()
        self._thread_started.acquire()

    def stop_collecting_counters(self, force=False):
        if force is False:
            self.wait_if_remaining_time_in_forbidden_period()
        self.is_running.clear()
        logger.info('[FLOATING COUNTERS] Stop collecting called',
                    also_console=True)
        self._thread_stopped.acquire()
        self._raise_when_exception_occured()
        logger.info('[FLOATING COUNTERS] Collected {} PM files'.format(len(self.collected_filepaths)),
                    also_console=True)
        if force is True:
            return
        merged_files = self._merge_counter_files()
        return merged_files

    def _merge_counter_files(self):
        logger.info('[FLOATING COUNTERS] Merging {} PM files'.format(len(self.collected_filepaths)),
                    also_console=True)
        return floating_counters.merge_files(self.collected_filepaths)

    def _estimate_time_to_next_counters(self, interval_in_mins=5):
        current_time = time.time()
        elapsed_time_s = int(current_time - self.last_timestamp)
        time_to_end_of_inetrval = interval_in_mins * 60 - elapsed_time_s
        return time_to_end_of_inetrval

    def wait_if_remaining_time_in_forbidden_period(self):
        waiting_offset = 10
        time_to_next_counters = self._estimate_time_to_next_counters()
        logger.info('[FLOATING COUNTERS] Estimated time to next counters: {}s'.format(time_to_next_counters),
                    also_console=True)
        if time_to_next_counters < self.forbidden_period:
            logger.info('[FLOATING COUNTERS] Remaining time: {} in forbidden period: {}\n'
                        'Waiting to start next period before stopping collection'
                        .format(time_to_next_counters, self.forbidden_period), also_console=True)
            time.sleep(time_to_next_counters + waiting_offset)

    def wait_remaining_time_of_counter_period(self):
        waiting_offset = 10
        time_to_next_counters = self._estimate_time_to_next_counters()
        logger.info('[FLOATING COUNTERS] Estimated time to next counters: {}s, waiting'.format(time_to_next_counters),
                    also_console=True)
        time.sleep(time_to_next_counters + waiting_offset)

    def _raise_when_exception_occured(self):
        if self.exception is not None:
            raise Exception(str(self.exception))

    def _collect_counters_in_thread(self):
        logger.info(
            '[FLOATING COUNTERS] Background collection started', also_console=True)
        self.is_running.set()
        self._thread_started.release()
        while self.is_running.is_set():
            try:
                self.counter_interface.wait_for_next_full_pm_interval()
                self.last_timestamp = time.time()
                new_pm_file = self.counter_interface.get_latest_unpacked_full_pm_counters_file()
                self.collected_filepaths.append(new_pm_file)
                logger.info('[FLOATING COUNTERS] Got new PM file, collected: {}'.format(len(self.collected_filepaths)),
                            also_console=True)
            except Exception as e:
                logger.error('[FLOATING COUNTERS] Exception in collecting thread occurs: {}'
                             .format(e))
                self.exception = e
                traceback.print_exc()
        self._thread_stopped.release()
        logger.info(
            '[FLOATING COUNTERS] Background collection stopped', also_console=True)

    @staticmethod
    def merge_dict(d, u):
        """
            Merge two dictionaries. Manage nested dictionary and multiple values with same key.
            Return merged dict
        """
        for k, v in u.items():
            if isinstance(v, dict):
                # print('item for key:{} is dict'.format(k))
                if isinstance(d[k], list):
                    print('mismatch in intervals: {}'.format(
                        [dd['@interval'] for dd in d[k] if '@interval' in dd]))
                    indexes_with_15_int = []
                    for index, measurement in enumerate(d[k]):
                        if '@interval' in measurement and int(measurement['@interval']) == int('15'):
                            indexes_with_15_int.append(index)
                    for index in indexes_with_15_int:
                        d[k].remove(d[k][index])
                    print('Removed: {}  x 15 min intervals'.format(
                        len(indexes_with_15_int)))
                    assert len(
                        d[k]) == 1, 'After removal of 15 min periods, we should have only 1 item in list'
                    d[k] = d[k][0]
                # print(pprint.pformat(u[k]))
                # print(pprint.pformat(d[k]))
                floating_counters.merge_dict(d[k], v)
            elif isinstance(v, list):
                # print('item for key:{} is list'.format(k))
                if isinstance(d[k], dict):
                    try:
                        print('mismatch in intervals: {}'.format(
                            [dd['@interval'] for dd in v if '@interval' in dd]))
                        indexes_with_15_int = []
                        for index, measurement in enumerate(v):
                            if '@interval' in measurement and int(measurement['@interval']) == int('15'):
                                indexes_with_15_int.append(index)
                        for index in indexes_with_15_int:
                            v.remove(v[index])
                    except Exception as e:
                        print('Encountered exception: {} with traceback:\n{}\n\nbut continuing...'
                              .format(e, traceback.format_exc()))
                    print('Removed: {}  x 15 min intervals'.format(
                        len(indexes_with_15_int)))
                    assert len(
                        v) == 1, 'After removal of 15 min periods, we should have only 1 item in list'
                    floating_counters.merge_dict(d[k], v[0])
                    continue

                for index, vv in enumerate(v):
                    # print('single list item:{}'.format(vv))
                    # print(type(d[k][index]))
                    floating_counters.merge_dict(d[k][index], vv)
            else:
                if k[0] == 'M':
                    # print('counter item')
                    try:
                        value = int(v)
                    except ValueError:
                        value = float(v)
                    if k in d:
                        # print(type(d[k]), type(value))
                        try:
                            new_value = d[k] + value
                        except TypeError:
                            new_value = type(value)(d[k]) + value
                        d[k] = new_value
                    else:
                        # only when counter not in first file but added in following
                        d[k] = value
                else:
                    # print('Old: {}-{}'.format(k, d[k]))
                    # print('New not appliead: {}-{}'.format(k, v))
                    # leave old value, not relevant for counter checking
                    pass
        return d

    @staticmethod
    def merge_files(filepath_list, merged_file_name='counters_merged_intervals.xml'):
        file_list = copy.deepcopy(filepath_list)
        if len(file_list) == 1:
            return file_list[0]
        print('Started merging files: {}'.format(len(filepath_list)))
        merged_dict = None
        while len(file_list):
            print('Merging {}/{}'.format(len(filepath_list) -
                  len(file_list) + 1, len(filepath_list)))
            file_to_merge = file_list.pop(0)
            with open(os.path.abspath(file_to_merge), 'r') as file_to_merge_handle:
                dict_to_merge = xmltodict.parse(
                    file_to_merge_handle.read(), dict_constructor=dict)
            if merged_dict is None:
                merged_dict = copy.deepcopy(dict_to_merge)
                continue
            merged_dict = floating_counters.merge_dict(copy.deepcopy(merged_dict),
                                                       copy.deepcopy(dict_to_merge))
        log_directory = os.path.dirname(os.path.abspath(filepath_list[0]))
        merged_file_filepath = os.path.join(log_directory, merged_file_name)
        print('Processed counters:'
              '\n{}'
              '\nSaving merged counters: {}'.format("\n".join(filepath_list),
                                                    merged_file_filepath))
        with open(merged_file_filepath, 'w') as file_to_save_handle:
            file_to_save_handle.write(xmltodict.unparse(merged_dict))
        print('Counters successfully saved')
        return merged_file_filepath


if __name__ == "__main__":
    # Open input files
    # assert len(sys.argv) >= 3, 'Need >=2 files to merge'
    floating_counters.merge_files([r'C:\Users\krawczuk\Downloads\PM.BTS-1.20230921.192000.ANY.xml',
                                   r'C:\Users\krawczuk\Downloads\PM.BTS-1.20230921.191500.ANY.xml'])
    # floating_counters.merge_files(sys.argv[1:])
