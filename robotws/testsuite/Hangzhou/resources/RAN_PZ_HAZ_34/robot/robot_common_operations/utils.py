import logging
import requests
import re
import json
import os
from robot.libraries.BuiltIn import BuiltIn
from taf.config.testline.info import info as TestlineInfo


__all__ = [
    'get_execution_env_type',
    'get_running_case_qc_id',
    'get_execute_case_scope',
    'initialize_case_environment'
]


# ============================================================================
# Constants
# ============================================================================

# Database API Configuration
DB_API_URL = 'http://10.182.68.169:5000/api/db/'
DB_NAME = "tribe_common_usage"

# REP Portal Configuration
REP_PORTAL_BASE_URL = 'https://rep-portal.ext.net.nokia.com/reports/test-runs/'
REP_PORTAL_COLUMNS_HASH = '3Ahash%3A5a42f6cbb518bbc9fa9a7c19229f283f'

# New Feature Testlines
NEW_FEATURE_TESTLINES = [
    "7_5_UTE5G402T2224",
    "7_5_UTE5G402T2226",
    "7_5_UTE5G402T214",
    "7_5_UTE5G402T2205",
    "7_5_UTE5G402T006",
    "7_5_UTE5G402T2225",
    "7_5_UTE5G402T2200",
]

# Release Patterns
PATTERN_TRUNK_SBTS = r"SBTS(.+)_ENB_999."
PATTERN_TRUNK_VDUCNF = r"vDUCNF00[_.]"
PATTERN_RELEASE_SBTS = r"SBTS(\w+)_ENB_000."
PATTERN_RELEASE_VDUCNF = r"vDUCNF(\d+R\d+)"
PATTERN_RELEASE_VDUCNF_FALLBACK = r"vDUCNF([A-Z]\w*?)(?:_|\d)"


# ============================================================================
# Helper Functions for Common Operations
# ============================================================================

def _get_robot_variables():
    """
    Get all commonly used Robot Framework variables in one place.

    Returns:
        dict: Dictionary containing all common variables
    """
    builtin = BuiltIn()
    return {
        'builtin': builtin,
        'configuration': builtin.get_variable_value("${CONFIGURATION}", default=None),
        'enb_build': builtin.get_variable_value("${ENB_BUILD}", default=None),
        'upload_qc': builtin.get_variable_value("${upload_qc}", default=None),
        'af_path': builtin.get_variable_value("${AF_PATH}", default=None),
        'case_name': builtin.get_variable_value("${TEST NAME}", default=""),
        'suite_path': builtin.get_variable_value("${SUITE SOURCE}", default=""),
        'tl': builtin.get_variable_value("${tl}", default=None),
        'testline_name': builtin.get_variable_value("${testline_name}", default=""),
    }


def _process_suite_source(suite_path):
    """
    Process suite source path to extract Hangzhou testsuite path.

    Args:
        suite_path: Raw suite source path

    Returns:
        str: Processed source path or original if no match
    """
    if not suite_path:
        return suite_path

    matches = re.findall("testsuite.Hangzhou.+", suite_path)
    return matches[0] if matches else suite_path


def _get_testline_name(builtin, configuration):
    """
    Get testline name from testline_name variable or CONFIGURATION.

    Args:
        builtin: Robot Framework BuiltIn library instance
        configuration: CONFIGURATION variable value

    Returns:
        str: Testline name
    """
    tl_name = builtin.get_variable_value("${testline_name}", default="")
    if tl_name:
        return tl_name

    if configuration:
        return configuration.split(".")[-1]

    return ""


def get_execution_env_type():
    """
    Get execution environment type and set related variables.
    This is a wrapper function that maintains backward compatibility.
    """
    vars = _get_robot_variables()
    builtin = vars['builtin']

    # Determine execution environment type
    execution_env_type = _determine_execution_env_type(
        builtin, vars['af_path'], vars['upload_qc'],
        vars['configuration'], vars['enb_build']
    )

    # Determine testline BTS type
    _determine_tl_bts_type(builtin)

    return execution_env_type


def get_execute_case_scope():
    """
    Get execute case scope and set related variables.
    This is a wrapper function that maintains backward compatibility.
    """
    vars = _get_robot_variables()
    builtin = vars['builtin']

    execute_case_scope = _determine_case_scope(vars['case_name'], vars['suite_path'])
    builtin.set_test_variable("${execute_case_scope}", execute_case_scope)

    return execute_case_scope


def is_skipreport_queued_or_tagged():
    queue = os.getenv('CM_QUEUE', default="")
    tags = json.loads(os.getenv('CM_TAGS', default=""))
    return queue.endswith("_SKIPREPORT") or "CM_SKIPREPORT" in tags


class CaseSearcher():
    """
    Case searcher utility class for QC ID management.
    Handles database queries and QC ID retrieval.
    """

    def __init__(self):
        self.db_api_url = DB_API_URL
        self.db_name = DB_NAME
        self.headers = {'Accept': 'application/json'}
        self.new_feature_tl = NEW_FEATURE_TESTLINES

    def get_instance(self, params):
        url = self.db_api_url + self.db_name
        logging.info("Using filter {}".format(params))
        try:
            # Set timeout to 30 seconds (connect timeout: 5s, read timeout: 30s)
            res = requests.get(url, headers=self.headers, params=params, timeout=(5, 30))
            if res.status_code == 200 and len(res.json()) > 0:
                instance_info = res.json()[0]
                qc_id = instance_info["qc_id"]
            else:
                instance_info = None
                qc_id = ""
        except requests.exceptions.Timeout:
            logging.warning(f"Database API request timed out after 30 seconds for URL: {url}")
            instance_info = None
            qc_id = ""
        except requests.exceptions.RequestException as e:
            logging.warning(f"Database API request failed: {e}")
            instance_info = None
            qc_id = ""
        logging.info(f"Got QC_ID {qc_id}")
        return qc_id, instance_info

    @staticmethod
    def generate_filter(release, source, case_name):
        filter = {
            'm_path': {'$regex': release},
            'source': {'$regex': source},
            'ta_case_name': case_name
        }
        return {'q': json.dumps(filter)}

    @staticmethod
    def generate_release_from_build(build):
        """
        Generate release version from build string.

        Args:
            build: Build string (e.g., SBTS00_ENB_9999, vDUCNF27R1)

        Returns:
            str: Release version (e.g., "Trunk", "27R1", "21B") or empty string
        """
        if not build:
            return ""

        # Reuse extract_release logic - treat build string as a filename
        return CaseSearcher._extract_release_from_string(build)

    def generate_case_qc_id(self):
        """
        Generate and set case QC ID and related variables.
        Uses common helper functions to reduce code duplication.
        """
        vars = _get_robot_variables()
        builtin = vars['builtin']

        # Process source path
        source = _process_suite_source(vars['suite_path'])

        # Extract build and release information
        build, release = _extract_build_and_release_info(
            self, vars['af_path'], vars['enb_build']
        )

        logging.info(f"source:{source} ta_case_name:{vars['case_name']} release:{release}")

        # Get QC ID and instance info from database
        qc_id, instance_info = _get_qc_id_and_instance_info(
            self, source, vars['case_name'], release
        )

        # Determine execute case scope with instance info
        execute_case_scope = _determine_case_scope(
            vars['case_name'], vars['suite_path'], instance_info
        )

        # Set test variables
        builtin.set_test_variable("${execute_case_scope}", execute_case_scope)
        builtin.set_test_variable('${CASE_QC_ID}', qc_id)

        # Handle new feature testlines
        tl_name = _get_testline_name(builtin, vars['configuration'])
        if not qc_id and tl_name in self.new_feature_tl:
            builtin.set_test_variable("${execution_env_type}", "DEBUG")

        # Generate and set test run link
        testrun_link = _generate_test_run_link(qc_id, build)
        builtin.set_test_variable("${CASE_TEST_RUN_LINK}", testrun_link)

    @staticmethod
    def extract_version(url):
        # For AF_PATH like: .../System_Release/28.100.45/vDUCNF27R1_28.100.45.zip
        # Extract the build number (28.100.45) from the path
        version_in_path = re.search(r'/System_Release/(\d+\.\d+\.\d+)/', url)
        if version_in_path:
            return version_in_path.group(1)

        # Original patterns
        patterns = [
            r"SBTS\w+_ENB_\d+_\d+_\d+",
            r"vDUCNF\w+_\d+\.\d+\.\d+",  # Match vDUCNFxxRx_xx.xxx.xx format
            r"\d+\.\d+\.\d+"
        ]

        for pattern in patterns:
            matches = re.findall(pattern, url)
            if matches:
                return matches[0]
        return None

    @staticmethod
    def extract_release(url):
        """
        Extract release from AF_PATH URL filename.
        (e.g., vDUCNF27R1 -> 27R1, SBTS00_ENB_9999 -> Trunk)
        """
        filename = url.split('/')[-1]
        return CaseSearcher._extract_release_from_string(filename)

    @staticmethod
    def _extract_release_from_string(text):
        """Shared helper to extract release from any string (filename or build)"""
        # Handle SBTS format: SBTS00_ENB_9999_... -> Trunk
        # SBTS21B_ENB_0000_... -> 21B
        if "SBTS" in text:
            # SBTS with 9999 indicates Trunk
            if re.search(PATTERN_TRUNK_SBTS, text):
                return "Trunk"
            # SBTS with 0000 indicates a release version
            match = re.search(PATTERN_RELEASE_SBTS, text)
            if match:
                return match.group(1)

        # Handle vDUCNF format
        # Check for vDUCNF00 -> Trunk
        if re.search(PATTERN_TRUNK_VDUCNF, text):
            return "Trunk"

        # Extract release pattern like 27R1, 26R1, etc.
        match = re.search(PATTERN_RELEASE_VDUCNF, text)
        if match:
            return match.group(1)

        # Fallback for other vDUCNF formats with letters
        match = re.search(PATTERN_RELEASE_VDUCNF_FALLBACK, text)
        if match:
            return match.group(1)

        return ""


def get_running_case_qc_id():
    cs = CaseSearcher()
    cs.generate_case_qc_id()


def _determine_execution_env_type(builtin, af_path, upload_qc, configuration, enb_build):
    """
    Determine the execution environment type based on available variables.

    Args:
        builtin: Robot Framework BuiltIn library instance
        af_path: AF_PATH variable value
        upload_qc: upload_qc variable value
        configuration: CONFIGURATION variable value
        enb_build: ENB_BUILD variable value

    Returns:
        str: execution_env_type (CI/DEBUG/UTE_CLOUD)
    """
    logging.info(f"[DEBUG] CONFIGURATION: {configuration}")
    logging.info(f"[DEBUG] ENB_BUILD: {enb_build}")
    logging.info(f"[DEBUG] upload_qc: {upload_qc}")
    logging.info(f"[DEBUG] AF_PATH: {af_path}")

    if af_path is not None:
        if upload_qc is True or upload_qc == "true":
            execution_env_type = "CI"
        else:
            execution_env_type = "DEBUG"
    elif configuration is not None and enb_build is not None:
        try:
            if is_skipreport_queued_or_tagged():
                execution_env_type = "DEBUG"
            else:
                execution_env_type = "UTE_CLOUD"
        except Exception as e:
            logging.warning(
                f"[DEBUG] Error checking skipreport status: {e}, defaulting to DEBUG"
            )
            execution_env_type = "DEBUG"
    else:
        execution_env_type = "DEBUG"

    builtin.set_test_variable("${execution_env_type}", execution_env_type)
    return execution_env_type


def _determine_tl_bts_type(builtin):
    """
    Determine the testline BTS type (cloud or classical).

    Args:
        builtin: Robot Framework BuiltIn library instance

    Returns:
        str: tl_bts_type (cloud/classical)
    """
    tl = builtin.get_variable_value("${tl}", default=None)
    if tl and tl.gnbs is not None:
        tl_info = TestlineInfo()
        is_cloud_bts = tl_info.has_cloudBts(tl)
        tl_bts_type = "cloud" if is_cloud_bts else "classical"
    else:
        tl_bts_type = "classical"

    builtin.set_test_variable("${tl_bts_type}", tl_bts_type)
    return tl_bts_type


def _determine_case_scope(case_name, suite_path, instance_info=None):
    """
    Determine execute case scope based on case name, suite path, and instance info.

    Priority order:
    1. e2e: if case_name contains 'e2e' and org contains 'HAZ_T03'
    2. UUF: if 'uuf' in case_name or suite_path
    3. Regression: default

    Args:
        case_name: Test case name
        suite_path: Test suite path
        instance_info: Optional database instance info containing org field

    Returns:
        str: execute_case_scope (e2e/UUF/Regression)
    """
    case_name_lower = case_name.lower() if case_name else ""
    suite_path_lower = suite_path.lower() if suite_path else ""

    # Check for e2e scope (highest priority)
    if "e2e" in case_name_lower:
        if instance_info and "org" in instance_info:
            org = instance_info.get("org", "")
            if "HAZ_T03" in org:
                logging.info(
                    f"Set execute_case_scope to 'e2e' based on "
                    f"org field: {org} and case_name: {case_name}"
                )
                return "e2e"

    # Check for UUF scope
    if "uuf" in case_name_lower or "uuf" in suite_path_lower:
        return "UUF"

    # Default to Regression
    return "Regression"


def _extract_build_and_release_info(cs, af_path, enb_build):
    """
    Extract build and release information from AF_PATH or ENB_BUILD.

    Args:
        cs: CaseSearcher instance
        af_path: AF_PATH variable value
        enb_build: ENB_BUILD variable value

    Returns:
        tuple: (build, release)
    """
    if af_path:
        build = cs.extract_version(af_path)
        release = cs.extract_release(af_path)
    else:
        build = enb_build
        release = cs.generate_release_from_build(build) if build else ""

    return build, release


def _get_qc_id_and_instance_info(cs, source, case_name, release):
    """
    Get QC ID and instance info from database.

    Args:
        cs: CaseSearcher instance
        source: Test suite source path
        case_name: Test case name
        release: Release version

    Returns:
        tuple: (qc_id, instance_info)
    """
    qc_id = ""
    instance_info = None

    if source and case_name and release:
        filter_params = cs.generate_filter(release, source, case_name)
        qc_id, instance_info = cs.get_instance(filter_params)

    return qc_id, instance_info


def _handle_new_feature_testlines(builtin, cs, qc_id, execution_env_type, configuration=None):
    """
    Handle special case for new feature testlines.

    Args:
        builtin: Robot Framework BuiltIn library instance
        cs: CaseSearcher instance
        qc_id: QC ID
        execution_env_type: Current execution environment type
        configuration: CONFIGURATION variable value (optional)

    Returns:
        str: Updated execution_env_type
    """
    tl_name = _get_testline_name(builtin, configuration)

    if not qc_id and tl_name in cs.new_feature_tl:
        builtin.set_test_variable("${execution_env_type}", "DEBUG")
        execution_env_type = "DEBUG"

    return execution_env_type


def _generate_test_run_link(qc_id, build):
    """
    Generate test run link for REP portal.

    Args:
        qc_id: QC ID
        build: Build version

    Returns:
        str: Test run link URL or empty string
    """
    if qc_id and build:
        return (
            f"{REP_PORTAL_BASE_URL}?build={build}&columns=%{REP_PORTAL_COLUMNS_HASH}"
            f"&limit=5&qc_test_instance_id={qc_id}"
        )
    return ""


def initialize_case_environment():
    """
    Integrated function that initializes case environment by:
    1. Getting and setting execution environment type (CI/DEBUG/UTE_CLOUD)
    2. Getting and setting execute case scope (UUF/Regression/e2e)
    3. Getting and setting case QC ID and test run link

    This function combines get_execution_env_type, get_execute_case_scope,
    and get_running_case_qc_id into a single call.

    Returns:
        dict: Contains execution_env_type, execute_case_scope, tl_bts_type, and qc_id
    """
    # Get all required variables in one call
    vars = _get_robot_variables()
    builtin = vars['builtin']
    cs = CaseSearcher()

    # 1. Determine execution environment type
    execution_env_type = _determine_execution_env_type(
        builtin, vars['af_path'], vars['upload_qc'],
        vars['configuration'], vars['enb_build']
    )

    # 2. Determine testline BTS type
    tl_bts_type = _determine_tl_bts_type(builtin)

    # 3. Extract build and release information
    build, release = _extract_build_and_release_info(
        cs, vars['af_path'], vars['enb_build']
    )

    # 4. Process source path for QC ID lookup
    source = _process_suite_source(vars['suite_path'])

    logging.info(f"source:{source} ta_case_name:{vars['case_name']} release:{release}")

    # 5. Get QC ID and instance info from database
    qc_id, instance_info = _get_qc_id_and_instance_info(
        cs, source, vars['case_name'], release
    )

    # 6. Determine execute case scope with instance info
    execute_case_scope = _determine_case_scope(
        vars['case_name'], vars['suite_path'], instance_info
    )

    # 7. Set test variables
    builtin.set_test_variable("${execute_case_scope}", execute_case_scope)
    builtin.set_test_variable('${CASE_QC_ID}', qc_id)

    # 8. Handle new feature testlines
    execution_env_type = _handle_new_feature_testlines(
        builtin, cs, qc_id, execution_env_type, vars['configuration']
    )

    # 9. Generate and set test run link
    testrun_link = _generate_test_run_link(qc_id, build)
    builtin.set_test_variable("${CASE_TEST_RUN_LINK}", testrun_link)

    # 10. Log final initialization results
    logging.info(
        f"[INIT] execution_env_type: {execution_env_type}, "
        f"execute_case_scope: {execute_case_scope}, "
        f"tl_bts_type: {tl_bts_type}, qc_id: {qc_id}"
    )

    return {
        'execution_env_type': execution_env_type,
        'execute_case_scope': execute_case_scope,
        'tl_bts_type': tl_bts_type,
        'qc_id': qc_id
    }
