# -*- coding:utf-8 -*-

import os
import sys
import re
import urllib
import urllib.request
import gzip
import zipfile
import shutil
import socket
from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET
from pkg_resources import resource_filename


class PmCounterMetaRise(object):
    def __init__(self, file_name, cache_dir="/tmp/rise", server_reachable=True, server_proxy=None):
        self._server_url = "http://esnidd055.emea.nsn-net.net/NIDD/JumpExports/"
        self._xml_file_name = file_name
        self._server_xml_url = "%s%s" % (self._server_url, self._xml_file_name)
        self._cache_dir = cache_dir
        self._local_xml_file_path = "%s/%s" % (self._cache_dir,
                                               self._xml_file_name)
        self._server_reachable = server_reachable
        self._proxy = server_proxy
        self._update_error = None
        self._cache_updated = False
        self._default_opener = urllib.request.build_opener()

        self._maps = {}

        self._init_cache()

        try:
            if self._server_reachable:
                if self._proxy is not None:
                    urllib.request.install_opener(
                        urllib.request.build_opener(
                            urllib.request.ProxyHandler({'http': self._proxy})))
                else:
                    urllib.request.install_opener(self._default_opener)

                self._update_cache()
                self._init_inverse_map("measurement_name_to_id", "measurement_id_to_name")
                self._init_inverse_map("pi_name_to_id", "pi_id_to_name")
            else:
                from local_lte_sbts_maps import maps1_measurement_id_to_name
                from local_lte_sbts_maps import maps2_pi_id_to_name
                # from local_lte_sbts_maps import maps3_pi_id_to_description
                from local_lte_sbts_maps import maps4_pi_id_to_time_aggregation_function
                from local_lte_sbts_maps import maps5_measurement_name_to_id
                from local_lte_sbts_maps import maps6_pi_name_to_id
                total_maps = {"measurement_id_to_name": maps1_measurement_id_to_name.maps1_measurement_id_to_name,
                              "pi_id_to_name": maps2_pi_id_to_name.maps2_pi_id_to_name,
                              # "pi_id_to_description": maps3_pi_id_to_description.maps3_pi_id_to_description,
                              "pi_id_to_time_aggregation_function":
                                  maps4_pi_id_to_time_aggregation_function.maps4_pi_id_to_time_aggregation_function,
                              "measurement_name_to_id": maps5_measurement_name_to_id.maps5_measurement_name_to_id,
                              "pi_name_to_id": maps6_pi_name_to_id.maps6_pi_name_to_id}
                self.set_maps(maps=total_maps)
        except Exception as e:
            pass

    @property
    def server_reachable(self):
        return self._server_reachable

    @property
    def proxy(self):
        return self._proxy

    @property
    def update_error(self):
        return self._update_error

    @property
    def cache_updated(self):
        return self._cache_updated

    @property
    def cache_dir(self):
        return self._cache_dir

    def _init_cache(self):
        if not os.path.isdir(self._cache_dir):
            os.makedirs(self._cache_dir)

    def _url_open(self, url, timeout=None):
        return urllib.request.urlopen(
            url, **({} if timeout is None else {"timeout": timeout}))

    def _file_open(self, file_name, mode="r"):
        return open(file_name, mode)

    def __download(self, url, local_file_name):
        if self._server_reachable:
            file_in = self._url_open(url)
            with self._file_open(local_file_name, "w") as file_out:
                for line in file_in:
                    if type(line) is bytes:
                        file_out.write(line.decode("utf-8"))
                    else:
                        file_out.write(line)
        else:
            local_gzip_file = os.path.join(os.path.dirname(__file__),
                                           "local",
                                           "%s.zip" % self._xml_file_name.split(".")[0])
            with zipfile.ZipFile(local_gzip_file, 'r') as zip_ref:
                zip_ref.extractall(os.path.join(os.path.dirname(__file__), "local"))
            shutil.copy2(os.path.join(os.path.dirname(__file__), "local", self._xml_file_name), self._cache_dir)

    # def _check_server_reachability(self):
    #     for timeout in (1, 5):
    #         for proxy in (None, r"http//10.144.1.10:8080", r"squid1:8080"):
    #             try:
    #                 urllib.request.install_opener(self._default_opener if proxy is None else
    #                                               urllib.request.build_opener(
    #                                                   urllib.request.ProxyHandler({'http': proxy})))
    #                 self._url_open(self._server_url, timeout=timeout)
    #                 self._server_reachable = True
    #                 self._proxy = proxy
    #                 return
    #             except (urllib.request.URLError, socket.timeout):
    #                 urllib.request.install_opener(self._default_opener)

    def _get_map(self, root, parent_tag, from_tag, to_tag):
        map_ = {}
        for element in root.findall(".//%s" % parent_tag):
            map_[element.find(from_tag).text] = element.find(to_tag).text
        return map_

    def _get_maps_from_xml_file(self):
        with self._file_open(self._local_xml_file_path) as file_:
            root = ET.fromstring(file_.read())
        maps = {}

        # eg:  '8019':'LTE_ISYS_HO_GSM_NB'
        maps["measurement_id_to_name"] = self._get_map(
            root, "Measurement", "MeasurementID", "Name")

        # eg:  'M51125C10': 'ipsecSaNotFound'
        maps["pi_id_to_name"] = self._get_map(root, "PI", "PI_ID", "Name")

        # eg:  'M51125C10': 'Sum of all received ESP or AH packets ad
        maps["pi_id_to_description"] = self._get_map(
            root, "PI", "PI_ID", "Description")

        # eg:  'M8062C6': 'sum', 'M8062C5': 'max', 'M8062C4': 'min'
        maps["pi_id_to_time_aggregation_function"] = self._get_map(
            root, "PI", "PI_ID", "Time_Aggregation_Function")

        return maps

    def _update_cache(self):
        try:
            self.__download("%s%s" % (self._server_url, self._xml_file_name), self._local_xml_file_path)
            maps = self._get_maps_from_xml_file()
            self.set_maps(maps)
            self._remove_file(self._local_xml_file_path)
            self._cache_updated = True
        except Exception as exception:
            self._update_error = exception

    def _gzip_open(self, file_name, mode="rb"):
        return gzip.open(file_name, mode)

    def _remove_file(self, file_name):
        os.remove(file_name)

    def _init_inverse_map(self, inverse_map_name, map_name):
        if sys.version < "3":
            self._maps[inverse_map_name] = {
                v: k for k, v in self._maps[map_name].iteritems()}
        else:
            self._maps[inverse_map_name] = {
                v: k for k, v in self._maps[map_name].items()}

    def get_measurement_name(self, measurement_id):
        return self._maps["measurement_id_to_name"][measurement_id]

    def get_measurement_id(self, measurement_name):
        return self._maps["measurement_name_to_id"][measurement_name]

    def get_pi_name(self, pi_id):
        return self._maps["pi_id_to_name"][pi_id]

    def get_pi_id(self, pi_name):
        return self._maps["pi_name_to_id"][pi_name]

    def get_pi_description(self, pi_id):
        return self._maps["pi_id_to_description"][pi_id]

    def get_pi_time_aggregation_function(self, pi_id):
        return self._maps["pi_id_to_time_aggregation_function"][pi_id]

    def get_maps(self):
        return self._maps

    def set_maps(self, maps):
        self._maps = maps


def merge_ltesbts_counter_from_xml():
    server_url = "http://esnidd055.emea.nsn-net.net/NIDD/JumpExports/"
    meta_lte_xml_regexp = r"FL\d+[A-Z]*_all_counters.xml"
    meta_sbts_xml_regexp = r"SBTS\d+[A-Z]*_PM_all_counters.xml"

    server_reachable = False
    server_proxy = None
    for proxy in (None, r"http//10.144.1.10:8080", r"squid1:8080"):
        try:
            if proxy is not None:
                proxy_handler = urllib.request.ProxyHandler({"http": r"http//10.144.1.10:8080"})
                opener1 = urllib.request.build_opener(proxy_handler)
            else:
                opener1 = urllib.request.build_opener()
            resp = opener1.open(server_url)
            server_reachable = True
            server_proxy = proxy
            break
        except Exception as e:
            continue

    if server_reachable:
        nidd_soup = BeautifulSoup(resp, "html.parser")
        html = nidd_soup.prettify()
        root = ET.fromstring(html)

        meta_lte = []
        meta_sbts = []
        for link in nidd_soup.find_all("a"):
            if re.match(pattern=meta_lte_xml_regexp, string=link.text):
                meta_lte.append(link.text)
            elif re.match(pattern=meta_sbts_xml_regexp, string=link.text):
                meta_sbts.append(link.text)

        meta_lte_latest = meta_lte[-1]
        meta_sbts_latest = meta_sbts[-1]
        meta_lte = PmCounterMetaRise(file_name=meta_lte_latest,
                                     server_reachable=server_reachable,
                                     server_proxy=server_proxy)
        meta_sbts = PmCounterMetaRise(file_name=meta_sbts_latest,
                                      server_reachable=server_reachable,
                                      server_proxy=server_proxy)

        lte_maps = meta_lte.get_maps()
        sbts_maps = meta_sbts.get_maps()
        merged_maps = {}
        for _dict in lte_maps:
            sub_dict = {}
            sub_dict.update(lte_maps[_dict])
            sub_dict.update(sbts_maps[_dict])
            merged_maps[_dict] = sub_dict
        meta_sbts.set_maps(merged_maps)
        return meta_sbts
    else:
        meta_sbts = PmCounterMetaRise(file_name=None,
                                      server_reachable=server_reachable,
                                      server_proxy=server_proxy)
        return meta_sbts


if __name__ == "__main__":
    pass
