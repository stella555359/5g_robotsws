"""
:copyright: Nokia
:author: winnie.he
:contact: winnie.he@nokia-sbell.com
:maintainer winnie.he:
:contact winnie.he@nokia-sbell.com
"""
import requests
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timezone, timedelta
import time
import re
try:
    import robot.api.logger as logging
except ImportError:
    import logging
import json
import os
from abc import ABCMeta, abstractmethod
from taf.internal.aliasing import aliasing_scope
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from .fetcher import pm_fetcher
from module_utils import module_utils
import shutil


Prefix_Name = "OnlyPM_Snapshot_BTS-"


class BaseReq:
    def __init__(self, baseurl):
        self.baseurl = baseurl

    def __reponse_handle(self, respon, url, params):
        if respon.status_code == 200:
            logging.info(
                msg="request success {} params {}".format(
                    url, params))
            return json.loads(respon.content)
        else:
            logging.error(msg="request fail {} params {}".format(url, params))
            logging.error(msg="{}".format(respon.content))
            raise Exception(("request fail {}").format(respon.status_code))

    def post(self, api_post_fix, params, filepath=None):
        url = "{}{}".format(self.baseurl, api_post_fix)
        if filepath is None:
            respon = requests.post(url=url, data=params)
        else:
            if isinstance(filepath, list):
                files = {}
                for i, file in enumerate(filepath):
                    files["file{}".format(i+1)] = open(file, 'rb')
                respon = requests.post(
                    url=url, data=params, files=files, timeout=300)
            else:
                respon = requests.post(
                    url=url, data=params, files={'file': open(filepath, 'rb')}, timeout=300)
        return self.__reponse_handle(respon, url, params)

    def get(self, api_get_fix, params=None):
        url = "{}{}".format(self.baseurl, api_get_fix)
        respon = requests.get(url=url, data=params)
        if respon.status_code == '200':
            logging.info(msg="post success {} params {}".format(url, params))
        return self.__reponse_handle(respon, url, params)


class BaseSiteOperation(object):
    def __init__(self):
        self.counter_re = r"M\d+[A-Z]\d+"
        self.value = {}
        self.fix_value = {}
        self.interval_second = 15 * 60
        self.save_dir = None
        self.utils = module_utils()
        self.scf_path = None
        self.sw = None
        self.bts_id = None
        self.set_save_dir()

    @abstractmethod
    def connect_to(self, host, username, password, port=443):
        pass

    @abstractmethod
    def disconnect(self):
        pass

    @abstractmethod
    def get_scf(self):
        pass

    def get_current_time(self):
        return datetime.now(tz=timezone(timedelta(hours=0)))

    def set_start_time(self, offset_time=0):
        self.start_time = self.get_current_time() + timedelta(seconds=offset_time * 60)

    def set_end_time(self):
        self.end_time = self.get_current_time()

    def set_save_dir(self):
        self.save_dir = self.utils.setup_module_directory(module_name="kpi_module")
        logging.info(f"save dir is {self.save_dir}")

    def move_all_files(self, source_dir, destination_dir):
        if not os.path.exists(destination_dir):
            os.makedirs(destination_dir)

        for filename in os.listdir(source_dir):
            source_file = os.path.join(source_dir, filename)
            destination_file = os.path.join(destination_dir, filename)
            if os.path.isfile(source_file):
                shutil.move(source_file, destination_file)

    def get_site_info(self, product_type, bts_index, du_index=0, oam_ip=None):
        self.oam_info = self.utils.get_site_info(product_type=product_type,
                                                 info_type="oam",
                                                 bts_index=bts_index,
                                                 du_index=du_index)
        self.ssh_info = self.utils.get_site_info(product_type=product_type,
                                                 info_type="ssh",
                                                 bts_index=bts_index,
                                                 du_index=du_index)
        if oam_ip is not None:
            self.oam_info.addr = oam_ip

    def get_pmfile_from_snapshot_file(self, snapshot_file_path):
        zip_file = None
        pmcounter_zip_file_path = None
        base_path = os.path.dirname(snapshot_file_path)
        with open(snapshot_file_path, 'r') as f:
            for line in f.readlines():
                if line.strip().endswith(":"):
                    zip_file = line.strip()
                if re.search(r"_E\d+_counters\.zip", line) is not None and zip_file is not None:
                    pmcounter_zip_file_path = os.path.join(base_path,
                                                           zip_file.replace(":", ""))
                    logging.info(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    os.system(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    pmcounter_zip_file_path = os.path.join(base_path, line.strip())
                    logging.info(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    os.system(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    logging.info(f"gunzip {base_path}/*.gz")
                    os.system(f"gunzip -f {base_path}/*.gz")
        for root, dirs, files in os.walk(self.pmfile_path):
            for file in files:
                if not file.endswith(".xml"):
                    os.remove(os.path.join(root, file))

    def process_gz_files(self):
        for root, dirs, files in os.walk(self.pmfile_path):
            for file in files:
                if file.endswith(".gz"):
                    gz_file_path = os.path.join(root, file)
                    # try to unzip the gz
                    result = os.system(f"gunzip -f {gz_file_path}")
                    # check and remove the unusefull file
                    if result != 0 or not os.path.exists(gz_file_path.replace(".gz", "")):
                        logging.warning(f"Failed to process {gz_file_path}. Deleting it.")
                        os.remove(gz_file_path)


class ClassicalOperation(BaseSiteOperation):
    def __init__(self):
        super().__init__()
        self.alias = "kpi_module_classical"
        self.coam_admin = admin()

    def connect_to(self, host, username, password, port='443'):
        self.alias = self.alias + f"_{host}"
        self.coam_admin.connect_to(bts_host=host,
                                   username=username,
                                   password=password,
                                   # bts_port=port,
                                   name=self.alias,
                                   timeout=90)
        self.host = host

    def connect(self):
        self.alias = self.alias + f"_{self.oam_info.addr}"
        self.coam_admin.connect_to(bts_host=self.oam_info.addr,
                                   username=self.oam_info.username,
                                   password=self.oam_info.password,
                                   # bts_port=port,
                                   name=self.alias,
                                   timeout=90)

    def disconnect(self):
        self.coam_admin.teardown_admin(connection=self.alias)

    def get_scf(self):
        self.coam_admin.get_current_scf_file(local_dir_path=self.pmfile_path,
                                             file_name="scf.xml",
                                             connection=self.alias,
                                             timeout=120)

    def get_bts_id_and_sw(self):
        bts_info = self.coam_admin.get_bts_info(connection=self.alias)
        logging.info(bts_info)
        self.sw = bts_info["swInfo"]["swVersion"]
        self.bts_id = bts_info["mrbtsID"]

    def remove_outof_period_pmfile(self, start_time,  end_time):
        self.process_gz_files()
        for root, dirs, files in os.walk(self.pmfile_path):
            for file in files:
                if file.endswith(".xml"):
                    # BTS1_2011_PM.BTS-1.20241030.081500.ANY.xml
                    t = re.search(r"\d{6,8}\.\d{4,6}", file)
                    if t:
                        file_time = datetime.strptime(t.group(0), "%Y%m%d.%H%M%S").replace(tzinfo=timezone.utc)
                        if file_time < start_time or file_time > end_time:
                            os.remove(os.path.join(root, file))

    def fetcher_pm_file(self):
        self.get_bts_id_and_sw()
        self.pmfile_path = os.path.join(self.save_dir,
                                        f"{Prefix_Name}{self.bts_id}_{self.sw}" + "_" +
                                        datetime.now().strftime("%Y%m%d_%H%M%S"))
        self.fetcher = pm_fetcher.ClassicalPMFetcher(s1_ip=self.oam_info.addr,
                                                     site_name=self.bts_id,
                                                     basedir=self.pmfile_path,
                                                     logdir=self.save_dir)
        self.fetcher.fetch()
        self.remove_outof_period_pmfile(self.start_time, self.end_time)
        return self.pmfile_path

    def pm_file_and_scf(self):
        self.fetcher_pm_file()
        self.get_scf()


class CuOperation(BaseSiteOperation):
    def __init__(self):
        super().__init__()
        self.alias = "kpi_module_cu"
        self.cu_object = cu()

    def connect_to(self, host, username, password, port=''):
        self.alias = self.alias + f"_{host}"
        self.cu_object.connect_to(host=host,
                                  username=username,
                                  password=password,
                                  secure=True,
                                  port=port,
                                  alias=self.alias)

    def connect(self):
        self.alias = self.alias + f"_{self.oam_info.addr}"
        self.cu_object.connect_to(host=self.oam_info.addr,
                                  username=self.oam_info.username,
                                  password=self.oam_info.password,
                                  secure=True,
                                  port=self.oam_info.port,
                                  alias=self.alias)

    def disconnect(self):
        self.cu_object.disconnect(connection=self.alias)

    def get_scf(self):
        self.scf_path = self.cu_object.get_current_plan_file(path=os.path.join(self.pmfile_path, "scf.xml"),
                                                             connection=self.alias)
        return self.scf_path

    def get_sw(self):
        self.sw = self.cu_object.get_active_software_version(connection=self.alias)
        info = self.cu_object.get_cu_state(connection=self.alias)
        logging.info(info)
        self.sw = info["software_version"]
        self.bts_id = info["mrbts_id"]

    def remove_outof_period_pmfile(self, start_time,  end_time):
        self.process_gz_files()
        for root, dirs, files in os.walk(self.pmfile_path):
            for file in files:
                if file.endswith(".xml"):
                    # 20240618.1445+0800-20240618.1450+0800
                    t = re.findall(r"\d{6,8}\.\d{4,6}\+\d{4}", file)
                    if t and len(t) > 0:
                        file_time_start = datetime.strptime(t[0], "%Y%m%d.%H%M%S%z")
                        file_time_end = datetime.strptime(t[1], "%Y%m%d.%H%M%S%z")
                        if file_time_start > end_time or file_time_end < start_time:
                            os.remove(os.path.join(root, file))

    def fetcher_pm_file(self, ip, username, password, namespace):
        self.get_sw()
        self.pmfile_path = os.path.join(self.save_dir,
                                        f"{Prefix_Name}{self.bts_id}_{self.sw}" + "_" +
                                        datetime.now().strftime("%Y%m%d_%H%M%S"))

        os.mkdir(self.pmfile_path)
        self.cu_object.get_local_snapshot(directory=self.pmfile_path,
                                          compressed=False,
                                          connection=self.alias)
        logging.info("get_pmfile_from_snapshot_file")
        pm_zip_path = self.get_pmfile_from_snapshot_file(os.path.join(self.pmfile_path,
                                                         "snapshot_file_list.txt"))
        logging.info(f"pm zip path {pm_zip_path}")
        self.remove_outof_period_pmfile(self.start_time, self.end_time)

    def pm_file_and_scf(self):
        logging.info(f"fetcher pm file {self.ssh_info.addr} {self.ssh_info.namespace}")
        self.fetcher_pm_file(ip=self.ssh_info.addr,
                             username=self.ssh_info.username,
                             password=self.ssh_info.password,
                             namespace=self.ssh_info.namespace)
        self.get_scf()


class DuOperation(BaseSiteOperation):
    def __init__(self):
        super().__init__()
        self.alias = "kpi_module_du"
        self.du_object = vdu()
        self.instance_id = None

    def connect_to(self, host, username, password, port=''):
        self.alias = self.alias + f"_{self.oam_info.addr}"
        self.du_object.connect_to(host=host,
                                  username=username,
                                  password=password,
                                  timeout=60,
                                  port=port,
                                  secure=True,
                                  connection_name=self.alias)

    def connect(self):
        self.alias = self.alias + f"_{self.oam_info.addr}"
        self.du_object.connect_to(host=self.oam_info.addr,
                                  username=self.oam_info.username,
                                  password=self.oam_info.password,
                                  secure=True,
                                  port=self.oam_info.port,
                                  connection_name=self.alias)

    def disconnect(self):
        self.du_object.disconnect(vdu_connection=self.alias)

    def get_scf(self):
        self.scf_path = self.du_object.get_current_plan_file(local_dir_path=self.pmfile_path,
                                                             filename="scf.xml",
                                                             vdu_connection=self.alias)
        return self.scf_path

    def get_sw(self):
        info = self.du_object.get_vdu_state_data(vdu_connection=self.alias)
        logging.info(info)
        self.sw = info["software_version"]
        self.bts_id = info["mrbts_id"]

    def remove_outof_period_pmfile(self, start_time,  end_time):
        self.process_gz_files()
        for root, dirs, files in os.walk(self.pmfile_path):
            for file in files:
                if file.endswith(".xml"):
                    # 20240618.1445+0800-20240618.1450+0800
                    t = re.findall(r"\d{6,8}\.\d{4,6}\+\d{4}", file)
                    if t and len(t) > 0:
                        file_time_start = datetime.strptime(t[0], "%Y%m%d.%H%M%S%z")
                        file_time_end = datetime.strptime(t[1], "%Y%m%d.%H%M%S%z")
                        if file_time_start > end_time or file_time_end < start_time:
                            os.remove(os.path.join(root, file))

    def fetcher_pm_file(self, ip, username, password, namespace):
        self.get_sw()
        self.pmfile_path = os.path.join(self.save_dir,
                                        f"{Prefix_Name}{self.bts_id}_{self.sw}" + "_" +
                                        datetime.now().strftime("%Y%m%d_%H%M%S"))
        if os.path.exists(self.pmfile_path):
            shutil.rmtree(self.pmfile_path)
        os.mkdir(self.pmfile_path)
        self.du_object.get_local_snapshot(directory=self.pmfile_path,
                                          compressed_or_not=False,
                                          filter_regx="counters",
                                          vdu_connection=self.alias)
        logging.info("get_pmfile_from_snapshot_file")
        pm_zip_path = self.get_pmfile_from_snapshot_file(os.path.join(self.pmfile_path,
                                                         "snapshot_file_list.txt"))
        logging.info(f"pm zip path {pm_zip_path}")
        self.remove_outof_period_pmfile(self.start_time, self.end_time)

    def pm_file_and_scf(self):
        self.fetcher_pm_file(ip=self.ssh_info.addr,
                             username=self.ssh_info.username,
                             password=self.ssh_info.password,
                             namespace=self.ssh_info.namespace)
        self.get_scf()


def connect_decorator(func):
    def wrapper(self, *args, **kwargs):
        logging.info("connect to...")
        self.site_handler.connect()
        result = func(self, *args, **kwargs)
        self.site_handler.disconnect()
        logging.info("disconnect to.")
        return result
    return wrapper


class SiteOperationFactory(object):
    def __init__(self):
        self.tl_obj = None
        self.site_handler = None
        self.product_type = None

    def setup_hander(self, product_type, bts_index, du_index, oam_ip):
        self.product_type = product_type
        if product_type in ["vcu", "vdu", "enb", "gnb"]:
            try:
                self.tl_obj = BuiltIn().get_variable_value("${tl}")
            except Exception as e:
                logging.warn(traceback.format_exc())
            if product_type in ["enb", "gnb"]:
                self.site_handler = ClassicalOperation()
            elif "cu" in product_type:
                self.site_handler = CuOperation()
            elif "du" in product_type:
                self.site_handler = DuOperation()
            else:
                raise Exception(f"Can't support this product type {product_type}")
            self.site_handler.get_site_info(product_type, bts_index, du_index, oam_ip)
            return self.site_handler
        else:
            raise Exception(f"Unknown product type {product_type}")

    @connect_decorator
    def handle(self):
        logging.info(f"start to fetch pm file")
        self.site_handler.pm_file_and_scf()
        return self.site_handler.pmfile_path


class BenchmarkKpi(BaseReq):
    DEFAULT_TEMPLATE = "PMKPI_SBTS25R3_5G_up"
    default_owner = "tacase_auto@nokia-sbell.com"

    def __init__(self):
        self.url = "http://kpi1.eecloud.dynamic.nsn-net.net/app_kpi/"
        # self.url = "http://10.109.2.70:4010/app_kpi/"
        BaseReq.__init__(self, self.url)

    def create_report(self, sw1,
                      site_list,
                      starttime1,
                      endtime1,
                      template1,
                      owner,
                      sw2=None,
                      starttime2=None,
                      endtime2=None,
                      template2=None):
        bencsitesws = [{"sw": sw1,
                        "site": site_list,
                        "template": template1,
                        "start_time": starttime1,
                        "end_time": endtime1,
                        "group": 1}]
        if sw2 is not None:
            bencsitesws.append({"sw": sw2,
                                "site": site_list,
                                "template": template2,
                                "start_time": starttime2,
                                "end_time": endtime2,
                                "group": 2})
        params = {"cmd": "new_benchmark",
                  "group_ele": "sw",
                  "owner": owner,
                  "time_offset": 0,
                  "group": json.dumps(bencsitesws)}
        api_post_fix = "apis/new_benchmark"
        return self.post(api_post_fix, params)

    def create_report_by_ziped_pm(self,
                                  file_paths,
                                  template1=None,
                                  template2=None,
                                  owner=None):
        if template1 is None:
            template1 = BenchmarkKpi.DEFAULT_TEMPLATE
        if template2 is None:
            template2 = BenchmarkKpi.DEFAULT_TEMPLATE
        if owner is None:
            owner = BenchmarkKpi.default_owner
        bencsitesws = [{"template": template1,
                        "group": 1}]
        if len(file_paths) == 2:
            bencsitesws.append({"template": template2,
                                "group": 2})
        elif len(file_paths) == 1:
            pass
        else:
            raise Exception("file_paths should be 1 or 2")
        params = {"cmd": "new_benchmark",
                  "group_ele": "sw",
                  "owner": owner,
                  "time_offset": 0,
                  "group": json.dumps(bencsitesws)}
        return self.post("apis/new_zip_benchmark", params, filepath=file_paths)


class KpiModuleFactory(object):
    def __init__(self):
        self.sitefactory_handlers = []
        self.offset_time = 0

    def start_kpi_collection(self, product_type, bts_index, du_index, oam_ip, offset_time=0):
        self.offset_time = int(offset_time) if isinstance(offset_time, str) else offset_time
        sitefactory_handler = SiteOperationFactory()
        sitefactory_handler.setup_hander(product_type, bts_index, du_index, oam_ip)
        self.benchmark = BenchmarkKpi()
        self.sitefactory_handlers.append(sitefactory_handler)
        sitefactory_handler.site_handler.set_start_time(self.offset_time)

    def add_kpi_collection(self, product_type, bts_index, du_index, oam_ip):
        sitefactory_handler = SiteOperationFactory()
        logging.info(f"Adding kpi collection {product_type} {bts_index} {du_index} {oam_ip}")
        sitefactory_handler.setup_hander(product_type, bts_index, du_index, oam_ip)
        self.sitefactory_handlers.append(sitefactory_handler)
        sitefactory_handler.site_handler.set_start_time(self.offset_time)

    def finish_kpi_collection(self):
        origin_path = None
        for i, sitefactory_handler in enumerate(self.sitefactory_handlers):
            sitefactory_handler.site_handler.set_end_time()
            logging.info(f"Finished kpi collection {sitefactory_handler.site_handler.start_time} - \
                {sitefactory_handler.site_handler.end_time}")
            path = sitefactory_handler.handle()
            if i == 0:
                origin_path = path
            else:
                sitefactory_handler.site_handler.move_all_files(path, origin_path)

        # todo zip all pm files
        shutil.make_archive(origin_path, 'zip', origin_path)
        return os.path.join(self.sitefactory_handlers[0].site_handler.save_dir,
                            f"{origin_path}.zip")

    def kpi_report_generate(self,
                            pmfile_zip_path,
                            template=BenchmarkKpi.DEFAULT_TEMPLATE,
                            owner=BenchmarkKpi.default_owner):
        ret = self.benchmark.create_report_by_ziped_pm(file_paths=[pmfile_zip_path],
                                                       template1=template,
                                                       owner=owner)
        if ret["status"] and ret["status"] == "success":
            logging.info(f"Generate report success {ret['url']}")
            return ret["url"]
        else:
            raise Exception(f"Generate report error: {ret}")

    def benchmark_report_generate(self,
                                  pmfile_zip_path1,
                                  pmfile_zip_path2,
                                  template1=None,
                                  template2=None,
                                  owner=BenchmarkKpi.default_owner):
        ret = self.benchmark.create_report_by_ziped_pm(file_paths=[pmfile_zip_path1,
                                                                   pmfile_zip_path2],
                                                       template1=template1,
                                                       template2=template2,
                                                       owner=owner)
        if ret["status"] and ret["status"] == "success":
            logging.info(f"Generate report success {ret['url']}")
            return ret["url"]
        else:
            raise Exception(f"Generate report error: {ret}")


class kpi_operation(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    lookup_handler, configured_kpi_modules = aliasing_scope(
        lookup_arg='alias', lookup_type=KpiModuleFactory)

    def __init__(self):
        self.kpi_module_handler = None

    def start_kpi_collection(self, product_type,
                             bts_index,
                             du_index,
                             server_type,
                             *args,
                             **kwargs):
        oam_ip = kwargs.get("oam_ip", None)
        offset_time = kwargs.get("offset_time", 0)
        self.kpi_module_handler = KpiModuleFactory()
        self.kpi_module_handler.start_kpi_collection(product_type, bts_index, du_index, oam_ip, offset_time)
        self.configured_kpi_modules.add(self.kpi_module_handler,
                                        alias=f"{product_type}_{bts_index}_{du_index}")
        logging.info(f"alias {product_type}_{bts_index}_{du_index}")

    @lookup_handler.implicit_lookup
    def add_kpi_collection(self,
                           product_type,
                           bts_index,
                           du_index,
                           oam_ip=None,
                           alias=None):
        return alias.add_kpi_collection(product_type, bts_index, du_index, oam_ip)

    @lookup_handler.implicit_lookup
    def finish_kpi_collection(self, alias=None):
        return alias.finish_kpi_collection()

    def kpi_report_generate(self, pmfile_zip_path, template=None, owner=BenchmarkKpi.default_owner):
        return self.kpi_module_handler.kpi_report_generate(template=template,
                                                           pmfile_zip_path=pmfile_zip_path,
                                                           owner=owner)

    def benchmark_report_generate(self,
                                  pmfile_zip_path1,
                                  pmfile_zip_path2,
                                  template1=None,
                                  template2=None,
                                  owner=BenchmarkKpi.default_owner):
        return self.kpi_module_handler.benchmark_report_generate(pmfile_zip_path1=pmfile_zip_path1,
                                                                 pmfile_zip_path2=pmfile_zip_path2,
                                                                 template1=template1,
                                                                 template2=template2,
                                                                 owner=owner)
