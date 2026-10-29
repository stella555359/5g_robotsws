from RfsListenerLib import RfsElasticSearchContextManager
from tools import (get_timestamp)
from tzlocal import get_localzone_name
from datetime import datetime
import pytz
import logging

logging.basicConfig(level=logging.INFO)


class BenchmarkDb(object):
    def __init__(self):
        self.url = "http://rfs-tools-timisoara.emea.nsn-net.net"
        self.port = 9200
        self.index_name = "benchmark_db_dev"
        self.api_key = "LUt2TGo1d0JtU2xVQVNRamY4Skw6cXFleERpenJfMmV6QW1JVGhha18zUQ=="
        self.els_db = None

    def setup_db(self, url=None, port=None, index_name=None, api_key=None):
        """
        Configures the Elasticsearch database connection.
        :param url: (str, optional): The URL of the Elasticsearch server.
        :param port: (int, optional): The port of the Elasticsearch server. Defaults to 9200.
        :param index_name: Elasticsearch Index Name or Index alias
        :param api_key: Elasticsearch API key
        """

        if url is not None:
            self.url = str(url)
        if port is not None:
            self.port = int(port)
        if index_name is not None:
            self.index_name = str(index_name)
        if api_key is not None:
            self.api_key = str(api_key)

        self.els_db = RfsElasticSearchContextManager()
        self.els_db.url = self.url
        self.els_db.port = self.port
        self.els_db.index = self.index_name
        self.els_db.api_key = self.api_key

    def check_if_record_exists_for_bts(self, bts_id, tc_name, template_id, cycles):
        """
        Check if record exists in the database for the given BTS ID, test case name, template ID, and cycles.
        :param bts_id: Identifier of BTS, can be BTS name or BTS id
        :type bts_id: str
        :param tc_name: name of TC, e.g. 'General_SiSo_KPI_PM_Counters_benchmarking'
        :type tc_name: str
        :param template_id: id of template that user what to use in Scout Comparator report
        :type template_id: str
        :param cycles: number of full quarter cycles counted starting from the nearest quarter, e.g. there's 11:10, and
                    it's 5 minutes before quarter 11:15, so for 3 cycles starting counting at quarter 15 the ending
                    quarter will be 12:00
        :type cycles: Union[str, int]
        :return: True if record exists, False otherwise
        :rtype: bool
        """
        query_data = {"bts_name": str(bts_id),
                      "tc_name": tc_name,
                      "template_id": str(template_id),
                      "cycles": str(cycles)}
        logging.debug(f"BTS query data: {query_data}")
        return self.els_db.check_query_match(index_name=self.index_name, match_fields_dict=query_data)

    def read_data_for_bts(self, bts_id, tc_name, template_id, cycles):
        """
        Read data from the database for the given BTS ID, test case name, template ID, and cycles.
        :param bts_id: Identifier of BTS, can be BTS name or BTS id
        :type bts_id: str
        :param tc_name: name of TC, e.g. 'General_SiSo_KPI_PM_Counters_benchmarking'
        :type tc_name: str
        :param template_id: id of template that user what to use in Scout Comparator report
        :type template_id: str
        :param cycles: number of full quarter cycles counted starting from the nearest quarter, e.g. there's 11:10, and
                        it's 5 minutes before quarter 11:15, so for 3 cycles starting counting at quarter 15 the ending
                        quarter will be 12:00
        :type cycles: Union[str, int]
        :return: The newest record matching the query, or None if no records are found
        :rtype: dict or None
        """
        query_data = {"bts_name": str(bts_id),
                      "tc_name": tc_name,
                      "template_id": str(template_id),
                      "cycles": str(cycles)}
        logging.debug(f"BTS query data: {query_data}")
        query_result = self.els_db.build_and_execute_query(index_name=self.index_name,
                                                           match_fields_dict=query_data,
                                                           last_match_only=True)
        logging.debug(f"BTS query result: {query_result}")

        bts_records = []

        if query_result is not None:
            for docs in query_result:
                bts_records.append(docs['_source'])

        if bts_records:
            return bts_records[0]
        else:
            return None

    def read_all_data_for_bts(self, bts_id, tc_name, template_id, cycles):
        """
        Read all data from the database for the given BTS ID, test case name, template ID, and cycles.
        :param bts_id: Identifier of BTS, can be BTS name or BTS id
        :type bts_id: str
        :param tc_name: name of TC, e.g. 'General_SiSo_KPI_PM_Counters_benchmarking'
        :type tc_name: str
        :param template_id: id of template that user what to use in Scout Comparator report
        :type template_id: str
        :param cycles: number of full quarter cycles counted starting from the nearest quarter, e.g. there's 11:10, and
                        it's 5 minutes before quarter 11:15, so for 3 cycles starting counting at quarter 15 the ending
                        quarter will be 12:00
        :type cycles: Union[str, int]
        :return: A list of all records matching the query, empty list if no records are fount
        :rtype: list
        """
        query_data = {"bts_name": str(bts_id),
                      "tc_name": tc_name,
                      "template_id": str(template_id),
                      "cycles": str(cycles)}
        logging.debug(f"BTS query data: {query_data}")
        query_result = self.els_db.build_and_execute_query(index_name=self.index_name,
                                                           match_fields_dict=query_data,
                                                           last_match_only=False)
        logging.debug(f"BTS query result: {query_result}")

        bts_records = []
        if query_result is not None:
            for docs in query_result:
                bts_records.append(docs['_source'])

        return bts_records

    def save_datetime_for_bts(self, bts_id, tc_name, template_id, start_date, end_date, cycles, sw_version=""):
        """
        Saves start and end datetime of desired KPIs and PMs counters collection time range
        user want to verify in the future. Timezone is automatically added to `start_datetime` and `end_datetime`
        args based on VM settings. To prevent discrepancies, make sure timezone on VM anb BTS are the same.

        :param bts_id: Identifier of BTS, cand be BTS name or BTS id
        :type bts_id: str
        :param tc_name: name of TC, e.g. 'General_SiSo_KPI_PM_Counters_benchmarking'
        :type tc_name: str
        :param template_id: id of template that user what to use in Scout Comparator report
        :type template_id: str
        :param start_date: start datetime of KPIs and PMs counters collection,
                               datetime provided as string must have specified format %Y-%m-%d %H:%M:%S
        :type start_date: datetime object or str
        :param end_date: end datetime of KPIs and PMs counters collection,
                             datetime provided as string must have specified format %Y-%m-%d %H:%M:%S
        :type end_date: datetime object or str
        :param cycles: number of full quarter cycles counted starting from the nearest quarter, e.g. there's 11:10, and
                       it's 5 minutes before quarter 11:15, so for 3 cycles starting counting at quarter 15 the ending
                       quarter will be 12:00
        :type cycles: Union[str, int]
        :param sw_version:  Optional, sw_version of BTS
        :type sw_version: str
        """
        dict_data = {"bts_name": str(bts_id),
                     "tc_name": str(tc_name),
                     "template_id": str(template_id),
                     "start_date": self.format_time(start_date),
                     "end_date": self.format_time(end_date),
                     "cycles": str(cycles),
                     "sw_version": str(sw_version),
                     'created_at': get_timestamp(),
                     'updated_at': get_timestamp(),
                     'local_time_zone': get_localzone_name(),
                     }
        logging.debug(f"BTS save data: {dict_data}")

        self.els_db.send_test_data(dict_data)

    @staticmethod
    def format_time(time):
        """
        Converts a datetime object or string to a formatted string in the format '%Y-%m-%dT%H:%M:%S' with UTC timezone.
        """
        if isinstance(time, datetime):
            time = time.strftime("%Y-%m-%d %H:%M:%S")
        datetime_object = datetime.strptime(time.split('.')[0], '%Y-%m-%d %H:%M:%S').replace(second=0)
        string_time = '{:%Y-%m-%dT%H:%M:%S}'.format(datetime_object.replace(tzinfo=pytz.utc))
        return string_time
