import os
import zipfile

from downloader import AdminCLIDownloader


class AdminCLIScript(object):
    def __init__(self):
        self.downloader = AdminCLIDownloader
        self.root_path = "/home/ute/btsauto/"

    def get_admin_cli(self, basename):
        cli_path = os.path.join(
            self.root_path, "_".join([basename, "ADMIN_CLI"]))
        if os.path.exists(cli_path):
            return cli_path
        else:
            return self._update_admin_cli(basename)

    def _update_admin_cli(self, basename):
        archive_path = self.downloader(
            basename).download_package_from_repository()
        directory_path = self._unzip_archive(archive_path)
        self._remove_file(archive_path)
        self._make_scripts_executable(directory_path)
        return directory_path

    def _make_scripts_executable(self, root_path):
        for sh_file in self._get_sh_files_list(root_path):
            self._add_execute_permission(sh_file)
        self._add_execute_permission(self._get_node_path(root_path))

    @staticmethod
    def _unzip_archive(path):
        directory_path, extension = os.path.splitext(path)
        with zipfile.ZipFile(path, "r") as admin_cli_zip_file:
            admin_cli_zip_file.extractall(directory_path)
        return directory_path

    @staticmethod
    def _remove_file(file_path):
        os.remove(file_path)

    @staticmethod
    def _get_sh_files_list(path):
        return [os.path.join(path, a) for a in os.listdir(path) if a.endswith(".sh")]

    @staticmethod
    def _get_node_path(root_path):
        return os.path.join(root_path, "node", "linux", "bin", "node")

    @staticmethod
    def _add_execute_permission(script_path):
        if not os.access(script_path, os.X_OK):
            os.chmod(script_path, 0o555)
