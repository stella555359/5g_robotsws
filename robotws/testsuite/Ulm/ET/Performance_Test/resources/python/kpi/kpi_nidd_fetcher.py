'''
LTEpat deprecation solution

downloads NIDD file and get information about KPIs

source /home/ute/DEVELOPMENT/env_activate
python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/kpi/kpi_nidd_fetcher.py \
    "NR_5192e,NR_5193b" --domain_name 5GNB

'''

import os
import pathlib
import collections
import logging
import argparse
import json
import urllib.request
from tempfile import gettempdir

import xml.etree.ElementTree as etree

logger = logging.getLogger()


class KpiNiddFetcher():
    '''
    This class is responsible for fetching KPI data from NIDD.
        each KPI is calculated using the pm counters based on a formula in the field Formula_with_ID
    '''

    NIDD_FILE_LOCAL_LAST_RESORT_PATH = '/mnt/etlogs/logs/performance/05_jump/all_kpis.xml'
    NIDD_FILE_REMOTE_LAST_RESORT_URL = 'https://esnidd055.emea.nsn-net.net/NIDD/JumpExports/all_kpis.xml'

    def __init__(self, domain_name: str = '5GNB', jump_xml: str = None):
        self.domain_name = domain_name
        if jump_xml is not None:
            self.jump_xml = pathlib.Path(jump_xml)
            logger.debug('found jump_xml: %s', jump_xml)
            if not self.jump_xml.is_file():
                self.jump_xml = KpiNiddFetcher._try_and_get_jump_file()
        else:
            self.jump_xml = KpiNiddFetcher._try_and_get_jump_file()
        try:
            self.tree_root = etree.parse(self.jump_xml).getroot()
        except FileNotFoundError as e:
            raise KpiNiddFetcher.Exc.NiddFileNotFoundError from e
        self.domain_root = self.get_domain_release()

    def get_kpi_obj(self, domain_root: etree.Element, kpi_id: str) -> dict:
        for kpi in domain_root.findall('.//Reporting_suite//KPI'):
            if kpi.find('KPI_ID').text == kpi_id:
                return kpi

    def get_domain_release(self) -> etree.Element:
        for domain in self.tree_root.findall('DomainRelease'):
            if domain.find('DomainName').text == self.domain_name:
                return domain
        raise KpiNiddFetcher.Exc.DomainNameNotFoundError

    def get_kpis_info(self, kpi_id_list: list) -> dict:
        '''
        :return: dictionary with all kpi data
        {
            '< KPI ID >' : {
                "name" : < STR >,
                "description" : < STR >,
                "formula" : < STR >,
                "required_pm_counters" : < LIST >,
            },
            ...c
        }
        '''
        result = {}
        for kpi_id in kpi_id_list:
            try:
                result.update({
                    kpi_id: {
                        'name': self.get_name(kpi_id),
                        'description': self.get_description(kpi_id),
                        'formula': self.get_formula(kpi_id),
                        'required_pm_counters': self.get_required_pm_counters(kpi_id),
                        'object_summary_levels': self.get_object_summary_levels(kpi_id),
                    }
                })
            except AttributeError:
                defualt = collections.defaultdict(lambda: "err")
                defualt.update({
                    'required_pm_counters': ['err'],
                })
                result.update({kpi_id: defualt})
                logger.error("KPI AttributeError: %s", kpi_id)
        return result

    def get_all_kpis(self) -> list:
        kpis = []
        logger.debug("Gathering All KPIs")
        for kpi in self.domain_root.findall('.//Reporting_suite//KPI'):
            text = kpi.find('KPI_ID').text
            logger.debug("    - %s", text)
            kpis.append(text)
        return kpis

    def get_required_pm_counters(self, kpi_id: str) -> list:
        pmc = []
        for piid_obj in self._get_kpi_field(kpi_id, 'Dependencies').findall('Dependendent_PI'):
            pmc.append(piid_obj.find('PI_ID').text)
        return pmc

    def get_object_summary_levels(self, kpi_id: str) -> str:
        return self._get_kpi_field(kpi_id, 'Object_summary_levels').text

    def get_formula(self, kpi_id: str) -> str:
        return self._get_kpi_field(kpi_id, 'Formula').find('Formula_with_ID').text

    def get_name(self, kpi_id: str) -> str:
        return self._get_kpi_field(kpi_id, 'Name').text

    def get_description(self, kpi_id: str) -> str:
        return self._get_kpi_field(kpi_id, 'Description').text

    @staticmethod
    def _try_and_get_jump_file() -> str:
        try:
            logger.debug('jump_xml is not a valid file, downloading from server')
            jump_xml = pathlib.Path(KpiNiddFetcher._download_jump_file())
        except TimeoutError:
            logger.warning("KpiNiddFetcher: _download_jump_file TimeoutError")
            jump_xml = pathlib.Path('.err')
        except urllib.error.URLError:
            logger.warning("KpiNiddFetcher: _download_jump_file urllib.error.URLError")
            jump_xml = pathlib.Path('.err')
        except NotImplementedError:
            logger.warning("KpiNiddFetcher: _download_jump_file NotImplementedError")
            jump_xml = pathlib.Path('.err')
        if not jump_xml.is_file():
            logger.error('Unable to dowmload latest file, using local as last resort')
            jump_xml = pathlib.Path(KpiNiddFetcher.NIDD_FILE_LOCAL_LAST_RESORT_PATH)
        return jump_xml

    def _get_kpi_field(self, kpi_id: str, field: str) -> etree.Element:
        return self.get_kpi_obj(self.domain_root, kpi_id).find(field)

    @staticmethod
    def _download_jump_file(local_target=None) -> str:
        local_target = pathlib.Path(gettempdir()).joinpath('all_kpis.xml') if local_target is None \
            else pathlib.Path(local_target)
        if local_target.is_file():
            logger.debug('File already exist!')
            return local_target
        KpiNiddFetcher.download_with_proxy(KpiNiddFetcher.NIDD_FILE_REMOTE_LAST_RESORT_URL, local_target)
        return local_target

    class Exc:  # pylint: disable=locally-disabled, too-few-public-methods
        '''Exceptions'''

        class DomainNameNotFoundError(Exception):
            '''DomainNameNotFoundError'''

        class NiddFileNotFoundError(Exception):
            '''DomainNameNotFoundError'''

    @staticmethod
    def download_with_proxy(url, filename, proxy_url='http://defra1c-proxy.emea.nsn-net.net:8080'):
        """
        NOKIA GPT:

        Downloads a file from a URL using a specified proxy.

        Args:
            url (str): The URL of the file to download.
            filename (str): The local path to save the downloaded file.
            proxy_url (str): The proxy server URL (e.g., 'http://your.proxy.com:8080').
        """
        try:
            # 1. Define the proxy settings
            proxy_handler = urllib.request.ProxyHandler({
                'http': proxy_url,
                'https': proxy_url
            })

            # 2. Build an opener with the proxy handler
            opener = urllib.request.build_opener(proxy_handler)

            # 3. Install the opener globally
            urllib.request.install_opener(opener)

            # 4. Now, urlretrieve will use the installed proxy
            logger.debug(f"Attempting to download '{url}' to '{filename}' via proxy '{proxy_url}'...")
            urllib.request.urlretrieve(url, filename)
            logger.debug(f"Successfully downloaded '{filename}'.")

        except urllib.error.URLError as e:
            logger.error(f"Error downloading file: {e.reason}")
        except Exception as e:
            logger.error(f"An unexpected error occurred: {e}")


def _parse_arguments():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kpi_ids')
    parser.add_argument('--domain_name', default='5GNB')
    parser.add_argument('--jump_xml', default=None)
    parser.add_argument('--log_level', default='DEBUG')
    return parser.parse_args()


def _main():
    args = _parse_arguments()
    logging.basicConfig(
        format='[%(levelname)7s %(lineno)4s %(filename)-20s] %(message)s',
        datefmt='%H:%M:%S',
        level=getattr(logging, args.log_level)
    )

    try:
        logger.info("Start of %s", os.path.basename(__file__))
        kpi_nidd_manager = KpiNiddFetcher(domain_name=args.domain_name, jump_xml=args.jump_xml)
        print(json.dumps(kpi_nidd_manager.get_kpis_info(args.kpi_ids.split(',')), indent=2))
    except Exception as e:
        logger.exception(e)
    finally:
        logger.info("End of %s", os.path.basename(__file__))


if __name__ == '__main__':
    _main()
