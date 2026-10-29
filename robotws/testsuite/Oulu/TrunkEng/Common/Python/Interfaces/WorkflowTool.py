"""
:author: Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""


import requests
import json
import urllib3
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import PromotedBuildNotFoundFromWft


class WorkflowTool:
    """
    WorkflowTool is used for example to getting names of promoted builds from WorkflowTool.

    WorkflowTool is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("WFT")
    """

    default_promotion_tags = ["4G_FDD_CIT", "4G_FDD_CRT", "4G_FDD_CUSTOMER", "4G_FDD_MAINTENANCE", "4G_FDD_CD",
                              "4G_TDD_CIT", "4G_TDD_CRT", "4G_TDD_CUSTOMER", "4G_TDD_MAINTENANCE", "4G_TDD_CD",
                              "5G_RAN_FDD_CD", "5G_RAN_TDD_CD", "5G_RAN_CIT", "RAN_4G_FDD_CIT", "RAN_4G_FDD_CRT",
                              "RAN_4G_FDD_CUSTOMER", "RAN_4G_FDD_CD", "RAN_4G_TDD_CIT", "RAN_4G_TDD_CRT",
                              "RAN_4G_TDD_CUSTOMER", "RAN_4G_TDD_CD", "RAN_4G_CUSTOMER", "RAN_4G_CRT", "RAN_4G_CIT",
                              "RAN_5G_FDD_CD", "RAN_5G_TDD_CD", "RAN_5G_CIT", "RAN_5G_CRT", "RAN_MRAT_CIT",
                              "RAN_MRAT_CRT", "RAN_MRAT_CUSTOMER", "RAN_MRAT_CD", "SRAN_CD", "REGRESSION", "CDRT",
                              "RAN_5G_TDD_CIT", "RAN_5G_TDD_CRT"]
    retry = 0

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")

    @staticmethod
    def promoted_builds(view=6829, page=1, promotion_tag=None, access_key="FSydUJsdPcQD3kIJcBOL1g8KXBEQvEBdKUODOEVE",
                        output='dict', build_filter=''):
        """
        :param int view: Default value is 6829. Custom view id. Must be generated from
                         https://wft.int.net.nokia.com/ALL/toolbox/db_queries/Promotion
        :param int page: Default is 1 and can have value 1-3. Page on the generated view.
        :param str promotion_tag: Default is None, can have value for example REGRESSION. If not promotion_tag given
                                  then default_promotion_tags are used.
        :param str access_key: Access key needed by the WFT API. Default value is
                               FSydUJsdPcQD3kIJcBOL1g8KXBEQvEBdKUODOEVE.
        :param str output: Output format. Csv string, or dict object. Default value is dict.
        :param str build_filter: Filter for load, default value is SBTS00.
        """
        info('Getting builds from WFT...')
        while WorkflowTool.retry < 4:
            try:
                WorkflowTool.retry += 1
                info(f"{WorkflowTool.retry}. try to get promoted builds from the WFT")
                wft_url = 'https://wft.int.net.nokia.com:8091/api/v1/view/{}.json?view[page]={}&access_key={}'.format(
                        view, page, access_key)
                req = requests.get(wft_url)
                wft_json = json.loads(req.text)
                if promotion_tag is None or promotion_tag == '""' or promotion_tag == '':
                    promotion_tag = WorkflowTool.default_promotion_tags
                elif promotion_tag not in WorkflowTool.default_promotion_tags:
                    info('{} is not found from default promotion tags: {}'.format(promotion_tag,
                                                                                  WorkflowTool.default_promotion_tags))
                else:
                    info("Used promotion tag is {}".format(promotion_tag))
                builds = []
                for tag_name, tag_contents in wft_json["items"].items():
                    if tag_name in promotion_tag:
                        for build in tag_contents:
                            if build_filter in build["build.baseline"]:
                                builds.append(build["build.baseline"])
                info("All found promoted builds: \n" + (",\n".join(builds)))
                WorkflowTool.retry = 0
                if output == 'csv':
                    return ','.join(builds)
                return builds
            except (OSError, ConnectionError, urllib3.exceptions.NewConnectionError, urllib3.exceptions.ProtocolError,
                    urllib3.exceptions.MaxRetryError, urllib3.exceptions.RequestError, urllib3.exceptions.ResponseError,
                    urllib3.exceptions.TimeoutError) as e:
                if "No space left on device" in str(e):
                    error(f"{e.__class__.__name__}:{e}")
                    info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
                if WorkflowTool.retry == 3:
                    error(f"Unable to get information of promoted builds from WFT with promotion tag {promotion_tag}. "
                          f"{e.__class__.__name__}:{e} was raised.\n"
                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    raise PromotedBuildNotFoundFromWft
                else:
                    info(f"Unable to get information of promoted builds from WFT with promotion tag {promotion_tag}. "
                         f"{e.__class__.__name__}:{e} was raised. Wait 60s and re-try.\n"
                         f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    BuiltIn().sleep("60s")

    @staticmethod
    def get_promoted_build(promotion_tag=None, branch="SBTS00", build_filter="ENB"):
        """
        Get name of promoted bts sw builds from WFT.

        :param str promotion_tag: Default None can be for example REGRESSION.
        :param str branch: Default SBTS00 can be for example SBTS23R4.
        :param str build_filter: Default value ENB, can be for example FSM3.
        :raise PromotedBuildNotFoundFromWft: If no promoted build is not found from the WFT.
        :return str: Returns name of the promoted build for example SBTS00_ENB_9999_230906_000010
        """
        branch_filter = "{}_{}_".format(branch, build_filter)
        name_of_promoted_build = ""
        builds = WorkflowTool.promoted_builds(promotion_tag=promotion_tag)
        if "FSM3" in branch:  # FSMr3 trunk branch is SBTS00_FSMR3
            build_filter = "FSM3"
            branch_filter = "{}_".format(branch)
        if not builds:
            error("Could not find any build that is promoted with {p}".format(p=promotion_tag))
            raise PromotedBuildNotFoundFromWft
        else:
            for build in builds:
                if branch_filter in build and (build[:build.find('_')] == branch or "_" in branch):
                    name_of_promoted_build = build
                    break
            if not name_of_promoted_build:
                error("Could not find any build that is promoted with {p} is branch {b} and has {bf} in name. "
                      "With promotion tag {p} all found builds are: {bu}".format(p=promotion_tag, b=branch,
                                                                                 bf=build_filter, bu=builds))
                raise PromotedBuildNotFoundFromWft
            info("Build found for {} with {} promotion tag is: \n{}".format(branch, promotion_tag,
                                                                            name_of_promoted_build))
            return name_of_promoted_build
