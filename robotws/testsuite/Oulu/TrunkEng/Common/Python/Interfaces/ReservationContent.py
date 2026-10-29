import json
import os
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (EnvironmentIssue, InvalidUserInput)


class ReservationContent:
    """
    When environment is reserved from UTE cloud, it creates /opt/ute/reservation.context.json file.
    ReservationContent is used for parsing information that is in file /opt/ute/reservation.context.json. For example
    to check if UPDATE_PATH has been used when making environment reservation.
    With this class you can also parse TAGS that were used when making environment reservation and all possible
    product defaults (n0-n3 software) and software that was requested with UPDATE_PATH TAG.

    ReservationContent is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("ENV_RESERVATION")
    """
    content_json = None

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")

    def read_content_of_file(self):
        """
        This method reads content of file /opt/ute/reservation.context.json
        """
        if os.path.exists("/opt/ute/reservation.context.json"):
            info("Open file /opt/ute/reservation.context.json and read it's content")
            with open("/opt/ute/reservation.context.json", "r") as res_f:
                content = res_f.read()
            if content:
                self.logger.debug(f"Content read: {content}\n, load it.")
                ReservationContent.content_json = json.loads(content)
            else:
                warning("File /opt/ute/reservation.context.json is empty. Check reservation.")
                # error("File /opt/ute/reservation.context.json is empty. Check reservation.")
                # raise EnvironmentIssue
        else:
            warning("Path /opt/ute/reservation.context.json doesn't exists, check reservation.")
            # error("Path /opt/ute/reservation.context.json doesn't exists, check reservation.")
            # raise EnvironmentIssue

    def get_triggering_build(self):
        """
        Get build that has triggered the test run
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        if ReservationContent.content_json:
            for cm_element in ReservationContent.content_json["CM_ARTIFACTS"]:
                self.logger.debug(cm_element)
                if cm_element["type"] == "build":
                    info(f"Build that has triggered the testing is {cm_element['name']}")
                    return cm_element['name']
            error(
                "Couldn't get name of the build that has triggered the test run from /opt/ute/reservation.context.json")
            raise EnvironmentIssue

    def get_build_used_in_update_path_tag(self, raise_error=True):
        """
        Check if TAG UPDATE_PATH is used when reservation was made. If it was used, gets the name of the build and
        returns it. If UPDATE_PATH was not used returns empty string.

        :param bool raise_error: If set True raises error if n0-n3 builds are not found.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        build_number = self.check_if_update_path_used()
        if build_number:
            n_builds = self.get_upgrade_path_product_defaults(raise_error)
            if build_number in n_builds:
                info("Build {}: {} was used in UPDATE_PATH.".format(build_number, n_builds[build_number]))
                return n_builds[build_number]
            else:
                if raise_error:
                    error(f"Build {build_number} was not found from the CM_ARTIFACTS -> upgrade_path -> "
                          f"product_defaults of file /opt/ute/reservation.context.json")
                    raise EnvironmentIssue
                else:
                    info(f"Build {build_number} was not found from the CM_ARTIFACTS -> upgrade_path -> "
                         f"product_defaults of file /opt/ute/reservation.context.json")
                    return ""
        else:
            return ""

    def get_customer_build_used_in_tag(self, raise_error=True):
        """
        Check if TAG UUF_CUSTOMER is used when reservation was made. If it was used, gets the name of the customer and
        build of the customer and returns it. If UUF_CUSTOMER was not used returns empty string.

        :param bool raise_error: If set True raises error if customer builds are not found.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        customer = self.check_if_customer_used()
        if customer:
            customer_deployments = self.get_customer_deployments(raise_error)
            for customer_deployment in customer_deployments:
                if customer == customer_deployment["customer"]:
                    if "deployments" not in customer_deployment:
                        if raise_error:
                            error(f"Customer '{customer}' deployments are not found from the "
                                  f"/opt/ute/reservation.context.json file. Cannot get the build.")
                            raise EnvironmentIssue
                        else:
                            info(f"Customer '{customer}' deployments are not found from the "
                                 f"/opt/ute/reservation.context.json file. Cannot get the build.")
                    for deployment in customer_deployment["deployments"]:
                        if "source_sw_build" in deployment:
                            info(f"Customer '{customer}' has source_sw_build {deployment['source_sw_build']} as "
                                 f"a deployment")
                            return deployment["source_sw_build"]
                        else:
                            if raise_error:
                                error(f"Customer '{customer}' source_sw_build is not found from the "
                                      f"/opt/ute/reservation.context.json file.")
                                raise EnvironmentIssue
                            else:
                                info(f"Customer '{customer}' source_sw_build is not found from the "
                                     f"/opt/ute/reservation.context.json file.")
            if raise_error:
                error(f"Customer '{customer}' is not found from the /opt/ute/reservation.context.json file.")
                raise EnvironmentIssue
        else:
            return ""

    def get_uuf_build_used_in_tag(self):
        """
        Check if TAG UUF_BUILD is used when reservation was made. If it was used, gets the build and returns it.
        If UUF_BUILD was not used returns empty string.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        tags = self.get_tags_used_in_reservation()
        up_sw = ""
        if tags:
            for tag in tags:
                if "UUF_BUILD" in tag:
                    up_sw = tag.split("=")[1]
                    break
        if up_sw:
            info(f"UUF_BUILD={up_sw} was used when test environment reservation was created.")
        else:
            info("UUF_BUILD was not used when test environment reservation was created.")
        return up_sw

    def get_upgrade_path_product_defaults(self, raise_error=True):
        """
        Get product defaults. Returns all found n0-n3 build and raises error if raise_error=True and build are not
        found. If build is not found and raise_error=False return empty string.

        :param bool raise_error: If set True raises error if n0-n3 builds are not found.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        if ReservationContent.content_json:
            for cm_element in ReservationContent.content_json["CM_ARTIFACTS"]:
                self.logger.debug(cm_element)
                if cm_element["type"] == "build":
                    pd = cm_element["properties"]["upgrade_path"]["product_defaults"]
                    self.logger.debug(f"all n0-n3 builds {pd}")
                    return pd
            if raise_error:
                error("Product defaults n0-n3 are not found from the /opt/ute/reservation.context.json file. "
                      "If used software is not promoted the n0-n3 information may not be available in the file.")
                raise EnvironmentIssue
            else:
                info(("Product defaults n0-n3 are not found from the /opt/ute/reservation.context.json file. Check "
                      "reservation. If used software is not promoted the n0-n3 information may not be available."))
                return {}
        else:
            return {}

    def get_customer_deployments(self, raise_error=True):
        """
        Get customer deployments. Returns list of dictionaries including build and raises error if raise_error=True
         and builds are not found. If build is not found and raise_error=False return empty list.

        :param bool raise_error: If set True raises error if n0-n3 builds are not found.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        if ReservationContent.content_json:
            for cm_element in ReservationContent.content_json["CM_ARTIFACTS"]:
                self.logger.debug(cm_element)
                if cm_element["type"] == "build":
                    pd = cm_element["properties"]["upgrade_path"]["customer_deployments"]
                    self.logger.debug(f"all customer_deployments {pd}")
                    return pd
            if raise_error:
                error("Customer deployments are not found from the /opt/ute/reservation.context.json file. "
                      "If used software is not customer deployments information may not be available in the file.")
                raise EnvironmentIssue
            else:
                info("Customer deployments are not found from the /opt/ute/reservation.context.json file. Check "
                     "reservation. If used software is not promoted the customer deployments information may not be "
                     "available.")
                return []
        else:
            return []

    def check_if_update_path_used(self):
        """
        Check if TAG UPDATE_PATH is used when reservation was made. If it was used, get the number of the build.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        tags = self.get_tags_used_in_reservation()
        up_sw = ""
        if tags:
            for tag in tags:
                if "UPDATE_PATH" in tag:
                    up_sw = tag.split("=")[1]
                    break
        if up_sw:
            info("UPDATE_PATH was used when test environment reservation was created.")
        else:
            info("UPDATE_PATH was not used when test environment reservation was created.")
        return up_sw

    def check_if_customer_used(self):
        """
        Check if TAG UUF_CUSTOMER and TAG UUF_CONFIGURATION are used when reservation was made. If were used, get the
        name of the customer.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        tags = self.get_tags_used_in_reservation()
        up_sw = ""
        conf = ""
        if tags:
            for tag in tags:
                if "UUF_CUSTOMER" in tag:
                    up_sw = tag.split("=")[1]
                if "UUF_CONFIGURATION" in tag:
                    conf = tag.split("=")[1]
                if up_sw and conf:
                    break
        if up_sw:
            info("UUF_CUSTOMER was used when test environment reservation was created.")
            if conf:
                info(f"UUF_CONFIGURATION={conf} was used when test environment reservation was created.")
            else:
                info("UUF_CONFIGURATION was not used when test environment reservation was created.")
        else:
            info("UUF_CUSTOMER was not used when test environment reservation was created.")
        return up_sw

    def get_tags_used_in_reservation(self):
        """
        Gets all TAGS that have been used when creating reservation. Returns used TAGS.
        """
        if ReservationContent.content_json is None:
            self.read_content_of_file()
        used_tags = []
        if ReservationContent.content_json:
            for cm_element in ReservationContent.content_json["CM_TAGS"]:
                self.logger.debug(cm_element)
                used_tags.append(cm_element)
        return used_tags

    def check_if_variable_tags_are_given_and_change_values(self):
        """
        Gets all TAGS that have been given when creating reservation. TAGS can be given by QC grid or manually when
        creating reservation. If variable is found from suite variables, changes value of the variable. If variable
        doesn't exist in the suite variables adds new suite variable. TAGS are given in format TAG_NAME=VALUE. For
        example TEST_LOOPS=5. If TAG is given without any value, it sets the variable to empty string, for example
        RELEASE=. Also, some special values are converted to correct format. For example if UE_IN_USE value is "True" it
         is converted to boolean True. If value is "False" it is converted to boolean False.
        """
        all_suite_variables = BuiltIn().get_variables()
        print(f"All suite variables: {all_suite_variables}")
        if "${UE_IN_USE}" in all_suite_variables:  # This if set by TAG it is not present in suite yet
            ue_value = BuiltIn().get_variable_value("${UE_IN_USE}")
            print(f"Variable UE_IN_USE is found from suite variables and has value {ue_value}.")
            if isinstance(ue_value, str) and ue_value:
                if ue_value.lower() == "true":
                    print("UE_IN_USE value is string true. Change value to boolean True.")
                    BuiltIn().set_suite_variable("${UE_IN_USE}", "${True}")
                elif ue_value.lower() == "false" or ue_value.lower() == "":
                    print("UE_IN_USE value is string false or empty string. Change value to boolean False.")
                    BuiltIn().set_suite_variable("${UE_IN_USE}", "${False}")
                else:
                    error("UE_IN_USE value is string, but not string true nor false nor True nor False.")
                    raise InvalidUserInput("UE_IN_USE value is string, but not string true nor string false.")
        tags = self.get_tags_used_in_reservation()
        print("All tags: {}".format(tags))
        if tags:
            for tag in tags:
                if "=" in tag:
                    tag_and_value = tag.split("=")
                    if len(tag_and_value) != 2:  # If TAG is given without value
                        error(f"{tag} is given as a TAG, it is invalid format, expected format is for example "
                              f"TEST_LOOPS=5. Check your TAGs in your reservation.")
                        raise EnvironmentIssue
                    value_of_tag = tag_and_value[1]
                    name_of_tag = "${%s}" % tag_and_value[0]
                    if name_of_tag in all_suite_variables:
                        info(f"Variable {tag_and_value[0]} is given in TAGs and it is found from suite variables. "
                             f"Change value of the variable to {tag_and_value[1]}.")
                    elif name_of_tag not in all_suite_variables:
                        info(f"Variable {tag_and_value[0]} is given in TAGs, but it is not found from suite variables. "
                             f"Add variable {tag_and_value[0]}:{tag_and_value[1]} to suite variables.")
                    if value_of_tag in ("True", "true"):
                        value_of_tag = True     # Convert string "True" to boolean True
                    elif value_of_tag in ("False", "false"):
                        value_of_tag = False    # Convert string "False" to boolean False
                    elif value_of_tag.isdigit():
                        value_of_tag = int(value_of_tag)    # Convert string to integer
                    elif value_of_tag and value_of_tag[0] == '[' and value_of_tag[-1] == ']':
                        info("Given TAG has a list as a variable.")
                        if len(value_of_tag) == 2:
                            value_of_tag = []
                        else:
                            list_content = self._safe_split(value_of_tag[1:-1], ',')
                            value_of_tag = [string_in_list.strip() for string_in_list in list_content]
                    elif value_of_tag in ("None", "NONE", "none"):
                        value_of_tag = None
                    elif value_of_tag in ("EMPTY", "empty", "Empty"):
                        value_of_tag = ""
                    info(f"Set suite variable {name_of_tag} with value {value_of_tag} (new value is given by TAG).")
                    BuiltIn().set_suite_variable(name_of_tag, value_of_tag)

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
