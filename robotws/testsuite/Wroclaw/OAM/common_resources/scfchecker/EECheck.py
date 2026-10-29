
import scfHandler


"""
Documentation
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_2
...  *****************
...  Basic information
...  *****************
...  The scfHandler library is designed to facilitate the retrieval and verification of information within SCF files.
...  Its primary use case is to assist users during testing by identifying missing parameters that can be configured
...  on the test line. This ensures a more streamlined and efficient testing process
...  by providing actionable insights into parameter settings.
...
...  This file is created to allow using defined keywords in RobotFramework.
...  ******************
...  History of changes
...  ******************
...  https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26930 - Creation of library
"""


class EECheck:
    def __init__(self):
        self.scfHandler = scfHandler.ScfHandler()

    def check_ee_activation_feature_on_bts(self):
        self.scfHandler.check_values_ee()
