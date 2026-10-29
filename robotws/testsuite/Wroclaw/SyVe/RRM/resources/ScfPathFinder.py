from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from os import walk
from pathlib import Path

DELTA_PATH = "testsuite/Wroclaw/SyVe/RRM/{}/resources/delta/"


class ScfPathFinder(object):

    def __init__(self):
        self._stream = Env.STREAM_SW
        self._scf_dir_path = ""
        self._delta_dir_path = ""
        self._scf_files_list = []
        self._delta_files_list = []

    def get_scf_path_for_feature(self, feature, *parameters):
        """
        Gets matching SCF for test case based on given feature and parameters list.
        Example: ScfPathFinder().get_scf_path_for_feature("5GC01234", "10MHz", "DRX")
          to find the SCF named f.ex.: scf_MRBTS_1234_DRX_featureX_on_10MHz.xml
        located under "testsuite/Wroclaw/SyVe/RRM/5GC01234/resources/SCF/_$stream" directory
        :param feature: full feature number used in the repository path (case sensitive)
        :param parameters: strings starting with underscore to be matched
         in the SCF name to get the required one SCF (case sensitive)
        :return: scf file path
        """
        self._scf_dir_path = f"testsuite/Wroclaw/SyVe/RRM/{feature}/resources/SCF/{self._stream}"
        scf_path = self._get_scf_path_for_feature(*parameters)
        if scf_path is None:
            self._scf_dir_path = f"/home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/{self._stream}"
            scf_path = self._get_scf_path_for_feature(*parameters)
        assert Path(str(scf_path)).is_file(), \
            (f"Problem with finding SCF under testsuite/Wroclaw/SyVe/RRM/{feature}/resources/SCF/{self._stream}"
             f" or {self._scf_dir_path} directory having matching {parameters} in its name")
        return scf_path

    def _get_scf_path_for_feature(self, *parameters):
        self._update_scf_files_list()
        self._filter_scf_files_with_matching_parameters(*parameters)
        if len(self._scf_files_list) == 1:
            return Path(self._scf_dir_path + "/" + self._scf_files_list[0]).absolute()
        elif len(self._scf_files_list) > 1:
            assert False, (f"Problem with SCF filtering files {self._scf_files_list} \n"
                           f"in the'{self._scf_dir_path}' folder to select one for the test!\n"
                           "Check parameters to select only one!")

    def get_delta_path_for_feature(self, feature, reconfig_action):
        self._update_delta_files_list(feature)
        self._filter_delta_files_with_matching_action(reconfig_action)
        assert len(self._delta_files_list) == 1, \
            (f"Problem with delta filtering files {self._delta_files_list} \nin the'{self._delta_dir_path}'"
             f" folder to select one for the test!\nCheck action to select only one!")
        delta_path = Path(self._delta_dir_path + "/" + self._delta_files_list[0]).absolute()
        assert Path(str(delta_path)).is_file(), f"Problem with concatenating of absolute delta path: {delta_path}"
        return delta_path

    def _update_delta_files_list(self, feature):
        self._delta_dir_path = DELTA_PATH.format(feature)
        for _, _, files in walk(self._delta_dir_path):
            self._delta_files_list = [delta_file for delta_file in files if delta_file.endswith("json")]
        assert len(self._delta_files_list) > 0, \
            (f"{self._delta_dir_path} does not contain any delta file to be selected for the test!\n"
             f"Please check if feature:'{feature}' is correct in the path (case sensitive!!)")

    def _update_scf_files_list(self):
        for _, _, files in walk(self._scf_dir_path):
            self._scf_files_list = [scf_file for scf_file in files if scf_file.endswith("xml")]

    def _filter_scf_files_with_matching_parameters(self, *parameters):
        self._scf_files_list = [scf_name for scf_name in self._scf_files_list if
                                all(f"_{parameter}" in scf_name for parameter in parameters)]

    def _filter_delta_files_with_matching_action(self, reconfig_action):
        filtered_delta_files = [delta_name for delta_name in self._delta_files_list if reconfig_action in delta_name]
        assert len(filtered_delta_files) > 0, \
            "There's no delta for action in the filename to be used in the test! (case sensitive!!)\n" \
            f"The files in searched folder are: {self._delta_files_list}"
        self._delta_files_list = filtered_delta_files
