from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking
from datetime import datetime
from time import sleep, time

LEGACY_CELL_COUNTER_PATH_STREAM_SW = ["SBTS23R2", "SBTS23R3", "SBTS23R4", "SBTS24R1"]

MI_NR_PM_COLLECTION = 5
PM_COLLECTION_SECONDS = 60 * MI_NR_PM_COLLECTION


class BtsPmCounters(object):

    def __init__(self):
        self.ips = NetWorking()

    def wait_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self, counter_id, cell_id,
                                                                  gnb_id=0, mi_nr_pm_collection=5,
                                                                  bts_id=Env.GNB_GLOBAL_BTS_ID):
        self.wait_for_new_pm_counters_measurement_interval_data(mi_nr_pm_collection=mi_nr_pm_collection)
        self.get_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter_id=counter_id, cell_id=cell_id,
                                                                      gnb_id=gnb_id, bts_id=bts_id)

    def get_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self, counter_id, cell_id, t_stamp=0, gnb_id=0,
                                                                 bts_id=Env.GNB_GLOBAL_BTS_ID):
        assert sum(self.get_bts_cell_pm_counter(counter_id=counter_id, cell_id=cell_id, gnb_id=gnb_id,
                                                t_stamp=t_stamp, bts_id=bts_id)
                   .values()) > 0, self._fail_msg(counter_id)
        self._success_msg(counter_id)

    def extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self, raw_pm_data, counter_id, cell_id,
                                                                     bts_id=Env.GNB_GLOBAL_BTS_ID, t_stamp=0):
        extracted_pm_counters = self.extract_bts_cell_pm_counter(raw_pm_data, counter_id, cell_id, bts_id=bts_id,
                                                                 t_stamp=t_stamp)
        assert sum(extracted_pm_counters.values()) > 0, \
            self._fail_msg(counter_id)
        self._success_msg(counter_id)

    def get_bts_cell_pm_counter(self, counter_id, cell_id, gnb_id=0, bts_id=Env.GNB_GLOBAL_BTS_ID,
                                t_stamp=0, lmp_ip_if_gnb0=True):
        Logger.info("Getting BTS NRCELL-{} {} PM Counter".format(cell_id, counter_id))
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            counters_data = api.get_pm_counters(counter_ids=counter_id)
        return self.extract_bts_cell_pm_counter(raw_pm_data=counters_data, counter_id=counter_id,
                                                cell_id=cell_id, bts_id=bts_id, t_stamp=t_stamp)

    @staticmethod
    def extract_bts_cell_pm_counter(raw_pm_data, counter_id, cell_id, bts_id=Env.GNB_GLOBAL_BTS_ID, t_stamp=0):
        pm_age = "" if t_stamp == 0 else \
            " not older than {}. Epoch: {}".format(datetime.fromtimestamp(t_stamp), t_stamp)
        Logger.debug("Extracting BTS NRCELL-{} {} PM Counter{}".format(cell_id, counter_id, pm_age))
        cell_objects = raw_pm_data["BTS"]["CELLS"][f"NRCELL-{cell_id}"] \
            if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
            else raw_pm_data["BTS"][f"MRBTS-{bts_id}"][f"NRBTS-{bts_id}"][f"NRCELL-{cell_id}"]
        for cell_object in cell_objects:
            if cell_objects[cell_object].get(counter_id):
                return {timestamp: counter_value for timestamp, counter_value
                        in cell_objects[cell_object].get(counter_id).items() if int(timestamp) >= int(t_stamp)}

    def extract_cell_slice_pm_counters(self, raw_pm_data, slice_name, counter_id, cell_id, mobile_country_code,
                                       mobile_network_code, t_stamp=0, bts_id=Env.GNB_GLOBAL_BTS_ID):
        all_slices = self.extract_cell_slices_pm_counters(raw_pm_data, counter_id, cell_id, mobile_country_code,
                                                          mobile_network_code, t_stamp, bts_id=bts_id)
        Logger.debug("Extracting '{}' {} {} slice PM Counters".format(slice_name, cell_id, counter_id))
        for slice_counters in all_slices:
            if slice_counters.get(slice_name):
                return slice_counters.get(slice_name)
        return {slice_name: {}}

    @staticmethod
    def extract_cell_slices_pm_counters(raw_pm_data, counter_id, cell_id, mobile_country_code, mobile_network_code,
                                        t_stamp=0, bts_id=Env.GNB_GLOBAL_BTS_ID):
        cell = "NRCELL-{}".format(cell_id)
        tracking = f"MCC-{mobile_country_code}{'_' if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW else '/'}" \
                   f"MNC-{mobile_network_code}"
        Logger.debug("Extracting BTS NRCELL-{} {} slices PM Counters".format(cell_id, counter_id))
        slice_objects = raw_pm_data["BTS"]["CELLS"][cell][tracking] \
            if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW \
            else raw_pm_data["BTS"][f"MRBTS-{bts_id}"][f"NRBTS-{bts_id}"][cell][tracking]
        return [{slice_: {timestamp: counter_value for timestamp, counter_value
                          in slice_objects[slice_]["NL1SL"].get(counter_id).items() if int(timestamp) >= int(t_stamp)}}
                for slice_ in slice_objects]

    @staticmethod
    def extract_pm_counter_by_path_after_given_timestamp(raw_pm_data, path, t_stamp=0):
        elem = raw_pm_data.get("BTS")
        for path_elem in path.split("/"):
            elem = elem.get(path_elem)
            assert elem, f"Searched element '{path_elem}' not in given counters tree. " \
                         "Please check path and timestamp of wanted counter"
        counter_values_after_timestamp = {timestamp: counter_value for timestamp, counter_value in elem.items()
                                          if int(timestamp) >= int(t_stamp)}
        counter_value_of_the_oldest_t_stamp = min(counter_values_after_timestamp.items(), key=lambda y: int(y[0]))[1] \
            if counter_values_after_timestamp else None
        return counter_value_of_the_oldest_t_stamp

    @staticmethod
    def extract_cell_plmn_pm_counters(raw_pm_data, counter_id, cell_id, mobile_country_code,
                                      mobile_network_code, t_stamp=0, bts_id=Env.GNB_GLOBAL_BTS_ID):
        cell = "NRCELL-{}".format(cell_id)
        tracking = f"MCC-{mobile_country_code}{'_' if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW else '/'}" \
                   f"MNC-{mobile_network_code}"
        counters = raw_pm_data["BTS"]["CELLS"][cell][tracking]["NCUPL"][counter_id]\
            if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
            else raw_pm_data["BTS"][f"MRBTS-{bts_id}"][f"NRBTS-{bts_id}"][cell][tracking]["NCUPL"][counter_id]
        return {timestamp: counter_value for timestamp, counter_value in counters.items()
                if int(timestamp) >= int(t_stamp)}

    def get_raw_pm_counters(self, counter_ids, gnb_id=0, lmp_ip_if_gnb0=True):
        expected_counters_string = ",".join(counter_ids)
        Logger.info("Getting PM Counters: [{}]".format(expected_counters_string))
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            return api.get_pm_counters(counter_ids=expected_counters_string)

    @staticmethod
    def wait_for_new_pm_counters_measurement_interval_data(mi_nr_pm_collection=5):
        curr_minute = TimeStamp().current_minute
        min_for_new_pm = mi_nr_pm_collection - (curr_minute % mi_nr_pm_collection) + 1
        Logger.info("Waiting {}m for new PM Counters (miNr flag value: {}m)".format(min_for_new_pm,
                                                                                    mi_nr_pm_collection))
        TimeStamp.wait_for_the_unix_timestamp(TimeStamp().unix_timestamp + (min_for_new_pm * 60))

    @staticmethod
    def wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period):
        time_interval_check = 5
        module_minute = time_interval_check - minutes_before_pm_period
        Logger.info(f"Checking BTS time to {minutes_before_pm_period}min before the test PM Counters period")
        current_minute = BtsOs().get_current_minute()
        for _ in range(PM_COLLECTION_SECONDS):
            if current_minute % MI_NR_PM_COLLECTION == module_minute or \
                    (not minutes_before_pm_period and
                     current_minute in [minute for minute in range(0, 60, MI_NR_PM_COLLECTION)]):
                break
            sleep(time_interval_check)
            current_minute = BtsOs().get_current_minute()
        bts_epoch = BtsOs().get_epoch()
        os_epoch = time()
        Logger.info(f"Current minute on BTS is {current_minute}m "
                    f"(BTS epoch:{bts_epoch} vs OS epoch:{os_epoch} and the diff: {bts_epoch - os_epoch:.1f}s)")

    @staticmethod
    def _fail_msg(counter_id):
        return "{} counter not updated (values equal to zero)".format(counter_id)

    @staticmethod
    def _success_msg(counter_id):
        Logger.info("{} counter updated".format(counter_id))
