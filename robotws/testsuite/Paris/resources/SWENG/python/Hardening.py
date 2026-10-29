from __future__ import absolute_import
from operator import itemgetter
import os
import StringTool
from taf.ccs.aashell.check_resources_usage import CheckResourcesUsage, ResourcesUsage


class Hardening(CheckResourcesUsage):
    """
        Class extending CheckResourceUsage object from taf.ccs.aashell
    """

    def are_equal_as_resources_multiple_excl(self, resources_usage1, resources_usage2, exclusion_list):
        """
        It is suggested NOT TO USE this method directly. Please refer to Hardening.robot lib
        encapsulating the methods from this class.

        Check if resources usage from two different points in a test case are equal.
        The elements in each resources_usage are ordered applying _get_resource_obj before comparison.
        Return True  if resource_usage1 is equal to resource_usage2, False if not

        :param dict resources_usage1:           first resource usage dict
        :param dict resources_usage2:           second resource usage dict
        :param Optional[list] exclusion_list:   list of xpath expressions to specify which parameters to exclude
                                                from the check
        :return:                                A boolean indicating if resource udage values are equal

        This example is showing direct usage of this python lib in roboframework code
        for simpler usage please use Hardening.robot lib

        .. code-block:: robotframework

            *** Settings ***
            Library    taf.ccs.aashell

            *** Variables ***
            @{EXCL_LIST}                //bufferPoolFreeCount   OtherStuff

            *** Test Cases ***
            Check Resource Usage Equal
                ${result}               Set Variable            ${False}
                Create AaShell CLI      name=aashell
                Setup    aashell

                ${resources_usage1}=    Get Resources Usage     aashell
                # execute test case
                ${resources_usage2}=    Get Resources Usage     aashell

                ${result}               Are Equal As Resources Multiple Excl
                ...                     ${resources_usage1}
                ...                     ${resources_usage2}
                ...                     ${EXCL_LIST}

                [return]                ${result}
                [Teardown]              Teardown                aashell
        """

        result = False
        if exclusion_list:
            resource1_obj = Hardening._get_resource_obj(resources_usage1)
            resource2_obj = Hardening._get_resource_obj(resources_usage2)
            for element_to_exclude in exclusion_list:
                resource1_obj.remove(element_to_exclude)
                resource2_obj.remove(element_to_exclude)
            result = self._convert(resource1_obj.to_dict()) == \
                self._convert(resource2_obj.to_dict()), "Resources differ"
        else:
            result = self._convert(resources_usage1) == self._convert(resources_usage2), "Resources differ"
        return result

    @staticmethod
    def check_tolerance_values(resource1_obj, resource2_obj, tolerances, differences):
        """
        INTERNAL USAGE
        Get two sorted ResourcesUsage and check the value according to a dict of tolerances.
        tolerances dict keys contain the path, the value contains the maximum value change.
        Differences are stored in the differences list parameter.
        No return value

        :param resource1_obj:         the first resources_usage to be treaten
        :param resource2_obj:         the second resources_usage to be treaten
        :param tolerances:            the tolerances dict to be checked
        :param differences:           the list of differences
        """
        for path in resource1_obj.paths():
            if path in resource2_obj.paths():
                value1 = resource1_obj.xpath(path)
                value2 = resource2_obj.xpath(path)
                if value1 != value2:
                    if path in tolerances:
                        tolerance = tolerances[path]
                        if tolerance == "NO_CHECK":
                            StringTool.console(
                                "\t\tDifference cfg NO_CHECK for {}: {} vs {}".format(
                                    path,
                                    value1,
                                    value2))
                            continue
                        if abs(float(value1[0]) - float(value2[0])) <= float(tolerance):
                            StringTool.console(
                                "\t\tDifference in tolerance for {}: {} vs {}".format(
                                    path,
                                    value1,
                                    value2))
                            continue
                    differences.append(f"Difference found for {path}: {value1} vs {value2}")
            else:
                differences.append(f"Missing path in 2nd object: {path}")

    @staticmethod
    def compare_resources_data_deepdiff(resources_usage1, resources_usage2):
        """
        It is suggested NOT TO USE this method directly. Please refer to Hardening.robot lib
        encapsulating the methods from this class.

        Compare two resource usage objects using compare_resources_data_deepdiff taf.ccs.aashell method
        As this method ignore order, resources are ordered using _get_resource_obj.
        Return a dict containing the differences.

        :param resources_usage1:         first resource usage to compare
        :param resources_usage2:         second resource usage to compare
        :return:                         a dict describing the differences.
        """
        result = CheckResourcesUsage.compare_resources_data_deepdiff(
            Hardening._get_resource_obj(resources_usage1),
            Hardening._get_resource_obj(resources_usage2)
        )
        return result

    @staticmethod
    def diff_resource_usage_with_tolerance(resources_usage1, resources_usage2, tolerance_file_path):
        """
        It is suggested not to use this method directly. Please refer to Hardening.robot lib
        encapsulating the methods from this class.
        Compare two resource usage objects. Only the elements present in the tolerance file are compared.
        Tracked differences are:
        - the changed field values trespassing a maximum difference from tolerance file.
        - the changed paths.
        Return a list of differences (each one is a string). Not checked value, as also values respecting the
        tolerance fork are printed only in the console/log.

        :param resources_usage1:         first resource usage to compare
        :param resources_usage2:         second resource usage to compare
        :param tolerance_file_path:      the path of the csv tolerance file
        :return:                         a differences list, empty if tolerances are respected and paths preserved
        """
        differences = []
        tolerances = {}
        Hardening._read_tolerance_file(tolerance_file_path, tolerances)
        resource1_obj = Hardening._get_resource_obj(resources_usage1)
        resource2_obj = Hardening._get_resource_obj(resources_usage2)
        if resource1_obj.paths() != resource2_obj.paths():
            differences.append("Paths differ")
        Hardening.check_tolerance_values(resource1_obj, resource2_obj, tolerances, differences)
        return differences

    @staticmethod
    def _sort_by_values(input_object):
        """
        INTERNAL USAGE
        Get a ResourcesUsage sorting it on its content, including ID related objects.
        No return value

        :param input_object:         the resources_usage to be treaten
        """
        if isinstance(input_object, list) and len(input_object) > 0:
            if isinstance(input_object[0], dict):
                names_for_sorting = ["l2NrtPoolId", "l2hiPoolId", "l2loPoolId", "l2psPoolId",
                                     "cpUeAppId", "nrCellGrpId",
                                     "nrCellIdentity", "resourceType"]
                for name_for_sorting in names_for_sorting:
                    if name_for_sorting in input_object[0]:
                        input_object.sort(key=itemgetter(name_for_sorting))
                        break
            for item in input_object:
                Hardening._sort_by_values(item)
        elif isinstance(input_object, dict):
            for item in input_object:
                Hardening._sort_by_values(input_object[item])

    @staticmethod
    def _get_resource_obj(resources_usage):
        """
        INTERNAL USAGE
        Get a ResourcesUsage, sorted on its content, including ID related objects.

        :param resources_usage:         the resources_usage to be treaten
        :return:                        the new resources_usage object
        """
        Hardening._sort_by_values(resources_usage)
        resource_obj = ResourcesUsage(resources_usage)
        StringTool.datedConsole("ResourcesUsage object:")
        for path in resource_obj.paths():
            StringTool.console("\t\t{} {}".format(path, resource_obj.xpath(path)))
        return resource_obj

    @staticmethod
    def _read_tolerance_file(tolerance_file_path, tolerance_dict):
        """
        INTERNAL USAGE
        Read a tolerance csv file content, inserting it in a dict passed as a parameter.
        No return value

        :param tolerance_file_path:         the path for file to be treaten
        :param tolerance_dict:              the dict containing the result
        """
        with open(tolerance_file_path, "r") as t_file:
            file_content = t_file.readlines()
        for line in file_content:
            if line.startswith("include"):
                current_path = os.path.dirname(tolerance_file_path)
                included_file_name = line.split("include")[1].strip()
                Hardening._read_tolerance_file(current_path + "/" + included_file_name, tolerance_dict)
            elif not line.startswith("#"):
                tolerance_pattern = line.split(";", 1)[0].strip()
                tolerance_string = line.split(";", 1)[1].strip()
                tolerance_dict[tolerance_pattern] = tolerance_string
                StringTool.datedConsole("{} :: {}".format(tolerance_pattern, tolerance_string), deep=2)
