"""
DEPRECATED: This module is deprecated. Use EnvironmentManager instead.
This file is kept for backward compatibility only.
"""
import warnings
from EnvironmentManager import reportTestEnvironment

# Re-export all necessary items for backward compatibility
from EnvironmentManager import (
    PipRequirements,
    SystemArguments,
    getPyRoboWiresharkVersion,
    getCurrentGitStatusComplete,
    getKindOfRun,
    report_print,
    warning_obsolete_python,
    OPS,
    ROOT_PROJECT_NAME,
    citOrCrt,
    localEnv
)


def generateReport(TLConfig, isConsole=True, updateLibraries=True):
    """
    DEPRECATED: Use EnvironmentManager.reportTestEnvironment() instead.
    This function is kept for backward compatibility only.
    """
    warnings.warn(
        "GenerateReport.generateReport() is deprecated. Use EnvironmentManager.reportTestEnvironment() instead.",
        DeprecationWarning,
        stacklevel=2
    )
    return reportTestEnvironment(TLConfig, isConsole=isConsole, updateLibraries=updateLibraries)
