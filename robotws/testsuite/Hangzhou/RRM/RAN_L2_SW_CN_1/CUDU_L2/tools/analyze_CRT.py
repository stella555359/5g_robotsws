import re
import os
import pandas as pd
"""
Usage:
Download CRT data, and name it according to CRT data type.
Put data to CRT_folder
Run script
"""
CRT_folder = "C:\\N-20L6PF1L6CP8-Data\\yuema\\Desktop\\issue\\CRT_report\\2022_6_20\\"
trunk_norun = CRT_folder+"1.csv"
trunk_pr = CRT_folder+"2.csv"
trunk_blocking = CRT_folder+"3.csv"
branch_norun = CRT_folder+"4.csv"
branch_pr = CRT_folder+"5.csv"
branch_blocking = CRT_folder+"6.csv"
combine_file = CRT_folder+"CRT_analysis.csv"
sg_06_csv = CRT_folder+"sg_06.csv"
sg_09_csv = CRT_folder+"sg_09.csv"
report_csv = CRT_folder+"report.csv"
title_csv = CRT_folder+"null.csv"
title = "Test Lab Path,Test Set,Name,QC Status,Platform,Test Subarea,Test Object,Test Entity," \
        "Test Level and Area,Competence Area,Organization,Program Phase,Detailed Auto Level," \
        "Responsible Tester,Feature (TI parameter),Backlog ID,Requirements,Fault Report ID," \
        "Fault Report ID Links,Execution suspended"
suspended_sg06_csv = CRT_folder+"suspended_sg06.csv"
suspended_sg09_csv = CRT_folder+"suspended_sg09.csv"
report_sg06_csv = CRT_folder+"report_suspended_sg06.csv"
report_sg09_csv = CRT_folder+"report_suspended_sg09.csv"


def clean_data(file_path):
    print("clean data file_path={}".format(file_path))
    with open(file_path) as fh:
        # with open(file_path, encoding="utf-8") as fh:
        data = fh.read()
        # data = re.sub('"=HYPERLINK\\("".*?"",""', '', data)
        # data = re.sub('""\\)"', '', data)
        # data = re.sub('\\[1\\]', '', data)
        # data = re.sub('\\[1.0\\] ', '', data)
        if data.startswith("\"sep=,\""):
            data = data[8:]
    with open(file_path, "w") as fh:
        # with open(file_path, "w", encoding="utf-8") as fh:
        fh.write(data)


def clean_all_data(crt_folder):
    files_name_list = os.listdir(crt_folder)
    print("files_name_list={}".format(files_name_list))
    for file_name in files_name_list:
        clean_data(crt_folder+file_name)


def combine_data(crt_folder):
    files_name_list = os.listdir(crt_folder)
    combine_df = pd.read_csv(crt_folder+"null.csv")
    for file_name in files_name_list:
        abs_path = crt_folder+file_name
        if abs_path == trunk_norun:
            print("combine data:{}".format(abs_path))
            temp_df = pd.read_csv(abs_path)
            temp_df["CRT Case Status"] = "trunk_norun"
            combine_df = pd.concat([combine_df, temp_df], sort=False)
            # print(combine_df)
        elif abs_path == trunk_pr:
            print("combine data:{}".format(abs_path))
            temp_df = pd.read_csv(abs_path)
            temp_df["CRT Case Status"] = "trunk_pr"
            combine_df = pd.concat([combine_df, temp_df], sort=False)
            # print(combine_df)
        elif abs_path == trunk_blocking:
            print("combine data:{}".format(abs_path))
            temp_df = pd.read_csv(abs_path)
            temp_df["CRT Case Status"] = "trunk_blocking"
            combine_df = pd.concat([combine_df, temp_df], sort=False)
            # print(temp_df)
        elif abs_path == branch_norun:
            print("combine data:{}".format(abs_path))
            temp_df = pd.read_csv(abs_path)
            temp_df["CRT Case Status"] = "branch_norun"
            combine_df = pd.concat([combine_df, temp_df], sort=False)
            # print(temp_df)
        elif abs_path == branch_pr:
            print("combine data:{}".format(abs_path))
            temp_df = pd.read_csv(abs_path)
            temp_df["CRT Case Status"] = "branch_pr"
            combine_df = pd.concat([combine_df, temp_df], sort=False)
            # print(temp_df)
        elif abs_path == branch_blocking:
            print("combine data:{}".format(abs_path))
            temp_df = pd.read_csv(abs_path)
            temp_df["CRT Case Status"] = "branch_blocking"
            combine_df = pd.concat([combine_df, temp_df], sort=False)
            # print(temp_df)
        else:
            pass
        # print(combine_df)
        combine_df.to_csv(combine_file, index=False)


def do_pivot_table():
    df = pd.read_csv(combine_file)
    foo = pd.pivot_table(
        df, index=["Organization", "Responsible Tester"], columns=["CRT Case Status"])
    print(foo)


def do_cross_table():
    df = pd.read_csv(combine_file)
    df_sg06 = df[df["Organization"] == "RAN_L2_SW_CN_1_SG06"]
    foo_sg06 = pd.crosstab(
        df_sg06["Responsible Tester"], df_sg06["CRT Case Status"])
    df_sg09 = df[df["Organization"] == "RAN_L2_SW_CN_1_SG09"]
    foo_sg09 = pd.crosstab(
        df_sg09["Responsible Tester"], df_sg09["CRT Case Status"])
    print("\nSG06 CRT need to analyze:")
    print(foo_sg06)
    foo_sg06.to_csv(sg_06_csv)
    print("\nSG09 CRT need to analyze:")
    foo_sg09.to_csv(sg_09_csv)
    print(foo_sg09)


def count_suspended_case_for_tester():
    df = pd.read_csv(combine_file)
    df_suspended = df[df["Execution suspended"]]
    df_suspended_sg06 = df_suspended[df_suspended["Organization"]
                                     == "RAN_L2_SW_CN_1_SG06"]
    df_sg06 = df_suspended_sg06.groupby("Responsible Tester").sum()
    df_sg06.to_csv(suspended_sg06_csv)
    df_suspended_sg09 = df_suspended[df_suspended["Organization"]
                                     == "RAN_L2_SW_CN_1_SG09"]
    df_sg09 = df_suspended_sg09.groupby("Responsible Tester").sum()
    df_sg09.to_csv(suspended_sg09_csv)


def print_report_with_suspended_data():
    df_sg06 = pd.read_csv(sg_06_csv)
    df_sg09 = pd.read_csv(sg_09_csv)
    df_sg06_suspended = pd.read_csv(suspended_sg06_csv)
    df_sg09_suspended = pd.read_csv(suspended_sg09_csv)
    df_1 = pd.merge(df_sg06, df_sg06_suspended,
                    on="Responsible Tester", how="left")
    print(df_1)
    df_2 = pd.merge(df_sg09, df_sg09_suspended,
                    on="Responsible Tester", how="left")
    print(df_2)
    df_1.to_csv(report_sg06_csv, index=False)
    df_2.to_csv(report_sg09_csv, index=False)
    with open(report_sg06_csv) as fh:
        data_1 = fh.read()
    with open(report_sg09_csv) as fh:
        data_2 = fh.read()
    with open(report_csv, "w") as fh:
        fh.write("SG06 CRT need to analyze:\n")
        fh.write(data_1)
        fh.write("\nSG09 CRT need to analyze:\n")
        fh.write(data_2)


def print_report():
    with open(sg_06_csv) as fh:
        data_1 = fh.read()
    with open(sg_09_csv) as fh:
        data_2 = fh.read()
    with open(report_csv, "w") as fh:
        fh.write("SG06 CRT need to analyze:\n")
        fh.write(data_1)
        fh.write("\nSG09 CRT need to analyze:\n")
        fh.write(data_2)


def add_title():
    # print(title)
    fh = open(title_csv, "w")
    fh.write(title+"\n")
    fh.close()


add_title()
clean_all_data(CRT_folder)
combine_data(CRT_folder)
do_cross_table()
# print_report()
count_suspended_case_for_tester()
print_report_with_suspended_data()
