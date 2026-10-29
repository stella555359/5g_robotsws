import subprocess
import unittest
from unittest.mock import patch, call

import save_file


class TestSaveFile(unittest.TestCase):
    def setUp(self):
        self.filename = "MyFile.json"
        self.directory = "2019/06/07/11.43.28"
        self.filename_compressed = f"{self.filename}.xz"
        self.user_server = "perfport@5gwebserver.dyn.nesc.nokia.net"
        self.ssh_options = [
            "-o",
            "StrictHostKeyChecking=no",
            "-o",
            "UserKnownHostsFile=/dev/null",
            "-o",
            "ConnectTimeout=10",
            "-o",
            "ConnectionAttempts=2",
        ]
        self.run_args = {
            "shell": False,
            "check": True,
            "universal_newlines": True,
            "stdout": subprocess.PIPE,
            "stderr": subprocess.PIPE,
        }
        self.mock = {
            "run": patch("subprocess.run").start(),
            "report": patch("report.Report.error").start(),
            "stdout": patch("sys.stdout.write").start(),
        }
        self.addCleanup(patch.stopall)

    def test_given_filename_when_save_file_then_file_copied_on_server(self):
        save_file.SaveFile().save(self.directory, self.filename, self.filename, compress=False)

        run_call_1 = call(
            ["ssh"] + self.ssh_options + [self.user_server, "mkdir", "-p", self.directory],
            **self.run_args,
        )
        run_call_2 = call(
            ["scp"]
            + self.ssh_options
            + [self.filename, f"{self.user_server}:{self.directory}/{self.filename}"],
            **self.run_args,
        )
        run_call_3 = call(
            ["ssh"]
            + self.ssh_options
            + [self.user_server, "chmod", "-w", f"{self.directory}/{self.filename}"],
            **self.run_args,
        )
        self.mock["run"].assert_has_calls([run_call_1, run_call_2, run_call_3])
        self.assertEqual(self.mock["run"].call_count, 3)
        self.mock["report"].assert_not_called()
        self.mock["stdout"].assert_not_called()

    def test_given_filename_into_tmpdir_when_save_file_then_file_copied_on_server(self):
        save_file.SaveFile().save(
            self.directory, f"/tmp_dir/{self.filename}", self.filename, compress=False
        )

        run_call_1 = call(
            ["ssh"] + self.ssh_options + [self.user_server, "mkdir", "-p", self.directory],
            **self.run_args,
        )
        run_call_2 = call(
            ["scp"]
            + self.ssh_options
            + [f"/tmp_dir/{self.filename}", f"{self.user_server}:{self.directory}/{self.filename}"],
            **self.run_args,
        )
        run_call_3 = call(
            ["ssh"]
            + self.ssh_options
            + [self.user_server, "chmod", "-w", f"{self.directory}/{self.filename}"],
            **self.run_args,
        )
        self.mock["run"].assert_has_calls([run_call_1, run_call_2, run_call_3])
        self.assertEqual(self.mock["run"].call_count, 3)
        self.mock["report"].assert_not_called()
        self.mock["stdout"].assert_not_called()

    def test_given_filename_when_save_file_then_file_compressed_and_copied_on_server(self):
        save_file.SaveFile().save(
            self.directory, self.filename, f"{self.filename}.xz", compress=True
        )

        run_call_2 = call(
            ["ssh"] + self.ssh_options + [self.user_server, "mkdir", "-p", self.directory],
            **self.run_args,
        )
        run_call_3 = call(
            ["scp"]
            + self.ssh_options
            + [
                self.filename_compressed,
                f"{self.user_server}:{self.directory}/{self.filename_compressed}",
            ],
            **self.run_args,
        )
        run_call_4 = call(
            ["ssh"]
            + self.ssh_options
            + [self.user_server, "chmod", "-w", f"{self.directory}/{self.filename_compressed}"],
            **self.run_args,
        )
        run_call_5 = call(["rm", self.filename_compressed], **self.run_args)

        self.run_args["shell"] = True
        run_call_1 = call(
            f"cat {self.filename} | xz --stdout > {self.filename}.xz", **self.run_args
        )

        calls = [run_call_1, run_call_2, run_call_3, run_call_4, run_call_5]
        self.mock["run"].assert_has_calls(calls)
        self.assertEqual(self.mock["run"].call_count, 5)
        self.mock["report"].assert_not_called()
        self.mock["stdout"].assert_not_called()

    def test_given_filename_when_save_file_then_copy_fails(self):
        command = ["ssh"] + self.ssh_options + [self.user_server, "mkdir", "-p", self.directory]
        self.mock["run"].side_effect = subprocess.CalledProcessError(
            returncode=1, cmd=command, stderr="Error during subprocess.run"
        )

        self.assertRaises(
            subprocess.CalledProcessError,
            save_file.SaveFile().save,
            self.directory,
            self.filename,
            self.filename,
            compress=False,
        )

        self.mock["run"].assert_called_once_with(command, **self.run_args)
        self.mock["report"].assert_called_once_with("Error during subprocess.run")
        self.mock["stdout"].assert_not_called()
