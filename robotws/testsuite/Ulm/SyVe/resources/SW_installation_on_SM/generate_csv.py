"""
This class has methods which are used by "install_SW.py" and "install_FDSW.py"

author: Mathis Rost
Email: mathis.rost.ext@nokia.com
"""


###############################################################################
# ------------------------------------IMPORTS-------------------------------- #
###############################################################################

import sys
import pandas as pd
import paramiko
import datetime


try:
    sys.path.insert(0, "..")
    from installation import Installation
except ImportError:
    print("The required file 'installation.py' was not found in the dictonary")


###############################################################################
# -----------------------------------VARIABLES------------------------------- #
###############################################################################


path_to_file = "/mnt/etfiles/users/rost/Project_mathis/SW_installation_on_SM"


# ssh-clinet
user = "toor4nsn"
pw = "oZPS0POrRieRtu"
ip = "192.168.255.129"
port = 443


class Edit_table:
    ###########################################################################
    # ----------------------------CLASS-VARIABLES---------------------------- #
    ###########################################################################

    path_to_SW_CSV = ("/mnt/etfiles/images/sbts/mnt/etfiles/" +
                      "users/rost/Project_mathis/SW_installation_on_SM")
    path_to_SW = path_to_SW_CSV
    path_to_config = "/tmp/CRT/testline_configuration"

    # installation object from installation.py
    installation = Installation(path_to_SW)
    FDSW = False

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # pandas dataframe
    df = ""
    table = "SW_versions"

    ###########################################################################
    # -----------------------------CLASS-METHODS----------------------------- #
    ###########################################################################

    def __init__(self, path_to_SW_CSV, FDSW=False):
        self.path_to_SW_CSV = path_to_SW_CSV
        self.FDSW = FDSW

        # generate the table name
        if FDSW:
            self.table = "FDSW_versions"

        # load in DataFrame from exel to edit
        try:
            self.df = pd.read_excel(
                path_to_SW_CSV + "/" + self.table + ".xlsx", index_col=0
            ).reset_index()
            print("Load in excel-file from " + path_to_SW_CSV)

        except Exception as e:
            print(e)
            # generate new data-frame
            print("Generating new excel-file in " + path_to_SW_CSV)
            self.df = pd.DataFrame(
                [], columns=["Testline", "gNB0", "gNB1",
                             "eNB0", "eNB1", "Last Update"]
            )
        self.df.is_copy = False

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    """
    The input is a list of testlines where the FDSW-version is checked
    """

    def set_testlines(self, testlines):
        # all possible modules
        modules = ["gNB_0", "gNB_1", "eNB_0", "eNB_1"]

        # FDSW SW check or SW check
        table = "SW"
        if self.FDSW:
            table = "FDSW"

        # cmd for executing help script via ssh
        cmd = ("python " + path_to_file +
               "/generate_csv_help.py --version " + table)

        # iterating over all testlines
        for t in testlines:
            try:
                (
                    name_VMs,
                    ip_VMs,
                    user_VMs,
                    pw_VMs,
                    main_VM_ip,
                ) = self.installation.get_systemcomponents(t, modules)
            except Exception as e:
                print(e)
                print("could not import " + t + "!")
                print("continue with other testlines.")
                # skip the current import of the non existing testline
                continue

            # store the SW_versions
            installed_SW = []

            # getting the software version of the components of t
            for i in range(len(modules)):
                m = modules[i]
                if m in name_VMs:
                    # connect to VM
                    self.ssh.connect(
                        ip_VMs[i],
                        username=user_VMs[i],
                        password=pw_VMs[i],
                        banner_timeout=200,
                    )
                    stdin, stdout, stderr = self.ssh.exec_command(cmd)
                    for line in stdout:
                        # get current installed SW
                        if line.startswith("current SW on SM: "):
                            found_SW = line[18: line.rfind("/n")]
                            installed_SW.append(found_SW)
                            break

                else:
                    installed_SW.append("-")

            # add testline row
            row = [t] + installed_SW
            self.add_row(row, overwrite=True)
            print(self.df)

        # sorting rows
        self.df.sort_values("Testline", ascending=False)

        # save df in exel sheet
        self.df.to_excel(
            self.path_to_SW_CSV + "/" + self.table + ".xlsx",
            sheet_name=self.table,
            index=False,
        )

        return None

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def delete_testlines(self, testlines):
        for tl in testlines:
            try:
                self.df = self.df.drop(self.df[self.df["Testline"] == tl]
                                       .index)
                print(tl + " was deleted from table!")
            except Exception as e:
                print(e)
                print(tl + " does not exist in the table")

        return None

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def get_testlines(self, testlines):
        rows = []

        for tl in testlines:
            try:
                idx = self.df.index[self.df["Testline"] == tl].tolist()[0]
                rows.append(self.df.loc[idx])

            # handeling the case if the selected TL is not in the excel file
            except Exception as e:
                print(e)
                print(tl + " was not found!")
                rows.append(
                    [
                        tl,
                        "-",
                        "-",
                        "-",
                        "-",
                        "-",
                    ]
                )

        return rows

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def add_row(self, row, overwrite=False):
        # check if there is allready an entry in the dataframe
        tl = row[0]

        # get timestemp
        ts = datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")
        row.append(ts)

        if self.df["Testline"].isin([tl]).any():
            idx = self.df.index[self.df["Testline"] == tl].tolist()[0]

            # replace the old line
            if overwrite:
                self.df.loc[idx] = row

            # just replace non "-" values
            else:
                labels = list(self.df.columns.values)
                for i in range(len(row)):
                    if not row[i] == "-":
                        self.df[labels[i]][idx] = row[i]

        # insert new line
        else:
            print("insert new line!")
            self.df.loc[-1] = row
            self.df.index = self.df.index + 1

        print(self.df)
        return None

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #
    def save_file(self):
        # save df in exel sheet
        self.df.to_excel(
            self.path_to_SW_CSV + "/" + self.table + ".xlsx",
            sheet_name=self.table,
            index=False,
        )


###############################################################################
# ----------------------------------EXECUTION-------------------------------- #
###############################################################################
