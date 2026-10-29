# from __future__ import absolute_import, division, print_function, unicode_literals, with_statement

import inspect
import json
import re
import warnings

import requests
import zipfile

# http://stackoverflow.com/questions/32075135/python-3-in-memory-zipfile-error-string-argument-expected-got-bytes
from io import BytesIO
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Name:         ReportingLibrary2
# Description:  Sends test execution data to Reporting Portal and trough it,
#               to HP Quality Center
# Author:       Hubert Trela
# Author-email: hubert.trela.ext@nokia.com
# Created:      12-20-1016
# ---------------------------------------------------------------------------
# noinspection PyShadowingNames


class TaReportingLibrary:
    def __init__(self):
        warnings.warn(
            "{} is depreciated and will be removed soon! Please use ta_reporting library instead.".format(
                self.__class__.__name__
            ),
            DeprecationWarning,
        )
        self.server_url = (
            r"https://rep-portal.wroclaw.nsn-rdnet.net/testbook/upload/flame5/"
        )

    def report_to_rp(
        self,
        result,
        name,
        testline,
        build,
        test_set,
        ca="GVE",
        start="now",
        end=None,
        qc_test_lab_path=None,
        qc_test_instance_name=None,
        comment=None,
        tool="Robot",
        domain="MN_5G",
        project="5G",
        logs_link=None,
        testline_slave=None,
        rfs_configuration_id=None,
        build_slave=None,
        add_info=None,
        steps=None,
        features=None,
        pi_results=None,
    ):
        result = self._normalize_tests_result(result)
        testline = self._check_testline_name(testline)
        if qc_test_lab_path and re.match("Root.*", qc_test_lab_path):
            print("1:qc_test_lab_path:%s" % qc_test_lab_path)
            qc_test_lab_path = qc_test_lab_path.replace("Root\\", "")
        if str(start).lower() == "now":
            start = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logger.info(
                "Test start time is not specified. Setting start time to: " + start
            )
        if not end:
            end = start
            logger.info("Test end time is not specified. Setting start time to: " + end)
        if not qc_test_lab_path:
            logger.warn(
                "No qc_test_lab_path specified. Test will not be reported to qc!"
            )

        print("build:%s" % build)
        release, gnb, brand, packet, names = build.split("_", 4)
        if brand.find("9999") >= 0:
            release1 = release.lstrip("SBTS")
            active_build = build.replace(release1, "00")
            release = "Trunk"
        elif brand.find("0000") >= 0:
            active_build = build
            release = "5G21B"
        else:
            active_build = (
                release
                + "_"
                + brand.lstrip("0")
                + "."
                + packet.lstrip("0")
                + "."
                + names.lstrip("0")
            )
        print("***************************")
        print("active_build:%s" % active_build)
        build = active_build
        print("build:%s" % build)
        print("2:qc_test_lab_path:%s" % qc_test_lab_path)
        if qc_test_lab_path.find("Trunk") >= 0:
            domain = "MN_RAN"
            project = "RAN_ST"
        if qc_test_lab_path.find(release) >= 0:
            report_json = self._create_report_json(
                name=name,
                result=result,
                testline=testline,
                build=build,
                test_set=test_set,
                ca=ca,
                start=start,
                end=end,
                qc_test_lab_path=qc_test_lab_path,
                qc_test_instance_name=qc_test_instance_name,
                comment=comment,
                tool=tool,
                domain=domain,
                project=project,
                logs_link=logs_link,
                testline_slave=testline_slave,
                rfs_configuration_id=rfs_configuration_id,
                build_slave=build_slave,
                add_info=add_info,
                steps=steps,
                features=features,
                pi_results=pi_results,
            )
            imz = InMemoryZip().append(name + ".json", report_json)
            r = requests.post(
                self.server_url,
                files={name + ".zip": imz.in_memory_data.getvalue()},
                proxies={"http": ""},
            )
            logger.info(r.status_code)
        if r.status_code != requests.codes.ok:
            logger.info(requests.code.ok)
            logger.info(r.status_code)
            logger.info(type(r.status_code))
            raise HttpPostError(
                "Report post request resulted with error. Http post error code: "
                + r.status_code
            )
        if not re.match("\\S{32}", r.text):
            raise UnexpectedHttpReportResponseError(
                "Server should respond to report with hash code."
            )
        else:
            logger.info(
                "Report sent properly. Verify your test result here:\n\t"
                "https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?file_hash="
                + r.text
            )
        #            logger.info("Report sent properly. Verify your test result here:\n\t"
        #                        "https://rep-portal.wroclaw.nsn-rdnet.net/reports/test_runs/content_hash/" + r.text)
        return r.text

    def _create_report_json(
        self,
        name,
        result,
        testline,
        build,
        test_set,
        ca="GVE",
        start="now",
        end=None,
        qc_test_lab_path=None,
        qc_test_instance_name=None,
        comment=None,
        tool="Robot",
        domain="MN_5G",
        project="5G",
        logs_link=None,
        testline_slave=None,
        rfs_configuration_id=None,
        build_slave=None,
        add_info=None,
        steps=None,
        features=None,
        pi_results=None,
    ):
        if result:
            result = "passed"
        elif not result:
            result = "failed"
        else:
            raise WrongResultArgumentError()

        main_dict = self._generate_main_report(
            name=name,
            result=result,
            start=start,
            end=end,
            ca=ca,
            testline=testline,
            tool=tool,
            domain=domain,
            project=project,
            logs_link=logs_link,
            testline_slave=testline_slave,
            rfs_configuration_id=rfs_configuration_id,
        )
        tc_dict = [
            self._generate_test_case_report(
                name=name,
                result=result,
                build=build,
                testline=testline,
                test_set=test_set,
                timestamp=end,
                qc_test_lab_path=qc_test_lab_path,
                qc_test_instance_name=qc_test_instance_name,
                build_slave=build_slave,
                comment=comment,
                addinfo=add_info,
                steps=steps,
                features=features,
                pi_results=pi_results,
            )
        ]
        main_dict["test_cases"] = tc_dict
        print("3:qc_test_lab_path:%s" % qc_test_lab_path)
        raport_json = json.dumps(main_dict, ensure_ascii=False)
        logger.info("Created report json: " + raport_json)
        return raport_json

    @staticmethod
    def _normalize_tests_result(result):
        if str(result).lower() in ["true", "pass", "passed", "1"]:
            return True
        elif str(result).lower() in ["false", "fail", "failed", "0"]:
            return False
        else:
            raise WrongResultArgumentError(
                "Wrong result value!'\nActual tesult:\t" + result + "\t"
                "Expected values:\ntrue\\pass\\passed\\1\nor\nfalse\\fail\\failed\\0"
            )

    @staticmethod
    def _generate_main_report(
        name,
        result,
        start,
        end,
        ca,
        testline,
        tool=None,
        domain=None,
        project=None,
        logs_link=None,
        testline_slave=None,
        rfs_configuration_id=None,
    ):
        # all those params are used in fact by inspect.currentframe()
        # i didn't want to convert this params to args and kwars, so i can force
        # user to use those specified params
        arg, _, _, locals = inspect.getargvalues(inspect.currentframe())
        return {k: v for k, v in locals.items() if k in arg and v}

    @staticmethod
    def _generate_test_case_report(
        name,
        result,
        build,
        testline,
        test_set,
        timestamp,
        qc_test_lab_path=None,
        qc_test_instance_name=None,
        build_slave=None,
        comment=None,
        addinfo=None,
        steps=None,
        features=None,
        pi_results=None,
    ):

        if not qc_test_instance_name and qc_test_lab_path:
            qc_test_instance_name = name

        # all those params are used in fact by inspect.currentframe()
        # i didn't want to convert this params to args and kwars, so i can force
        # user to use those specified params
        arg, _, _, locals = inspect.getargvalues(inspect.currentframe())
        return {k: v for k, v in locals.items() if k in arg and v}

    @staticmethod
    def _check_testline_name(testline_name):
        proper_tesline_syntax_regex = "\\w+_\\w+_(TL|CLOUD)\\S+\\d{3}"
        fixable_testline_syntax_regex = "\\w+-\\w+-(TL|CLOUD)\\S+\\d{3}"
        if re.match(proper_tesline_syntax_regex, testline_name):
            return testline_name
        elif re.match(fixable_testline_syntax_regex, testline_name):
            testline_name_fixed = testline_name.replace("-", "_")
            logger.warn(
                "Your testline name should be:\n"
                + testline_name_fixed
                + "\ninstead of:\n"
                + testline_name
                + "Rename it to remove this warning."
            )
            logger.info("Fixed testline name.")
            return testline_name_fixed
        else:
            raise ImproperTestLineNameError(
                "Testline name should match regex '"
                + proper_tesline_syntax_regex
                + "'."
                "\nTL - for local test line\nCLOUD - fur ute cloud test lines"
            )


class InMemoryZip(object):
    """
    http://stackoverflow.com/questions/2463770/python-in-memory-zip-library
    answer by: Anthon
    """

    def __init__(self):
        # Create the in-memory file-like object
        self.in_memory_data = BytesIO()
        # Create the in-memory zipfile
        self.in_memory_zip = zipfile.ZipFile(
            self.in_memory_data, "w", zipfile.ZIP_DEFLATED, False
        )
        self.in_memory_zip.debug = 3

    def append(self, filename_in_zip, file_contents):
        """Appends a file with name filename_in_zip and contents of
        file_contents to the in-memory zip."""
        # assert isinstance(filename_in_zip, unicode)
        self.in_memory_zip.writestr(
            filename_in_zip,
            file_contents,
        )
        for zfile in self.in_memory_zip.filelist:
            zfile.create_system = 0
        self.in_memory_zip.close()
        return self  # so you can daisy-chain

    def writetofile(self, filename):
        """Writes the in-memory zip to a file."""
        # Mark the files as having been created on Windows so that
        # Unix permissions are not inferred as 0000
        for zfile in self.in_memory_zip.filelist:
            zfile.create_system = 0
        self.in_memory_zip.close()
        with open(filename, "wb") as f:
            f.write(self.in_memory_data.getvalue())


class ImproperTestLineNameError(Exception):
    pass


class WrongResultArgumentError(Exception):
    pass


class HttpPostError(Exception):
    pass


class UnexpectedHttpReportResponseError(Exception):
    pass
