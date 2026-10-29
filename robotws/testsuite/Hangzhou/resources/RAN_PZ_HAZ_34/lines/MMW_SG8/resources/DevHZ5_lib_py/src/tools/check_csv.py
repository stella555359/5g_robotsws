import csv
import re
from robot.libraries.BuiltIn import BuiltIn

builtin_obj = BuiltIn()


class check_csv(object):
    def __init__(self):
        pass

    def _remove_empty(self, list_in):
        list_out = []
        if not isinstance(list_in, list):
            list_in = [list_in]
        for condition in list_in:
            if len(condition.strip()) != 0:
                list_out.append(condition)
        return list_out

    def _convert_conditions(self, list_in):
        list_out = []
        self._remove_empty(list_in)
        for condition in list_in:
            match = re.search(r"([^!<>=]+)([!><=]+)(.*)", condition, re.I)
            if match is not None:
                column_name = match.group(1).strip()
                operator = match.group(2).strip()
                value_exp = match.group(3).strip()
                list_out.append((column_name, operator, value_exp))
            else:
                raise Exception("not support expression {}".format(condition))
        return list_out

    def _check_condition(self, value, operator, target):
        if operator == '=':
            if target.count(","):
                if value in target.split(","):
                    return True
                else:
                    return False
            else:
                if target.count("-"):
                    return float(target.split("-")[0]) <= float(value) <= float(target.split("-")[1])
                else:
                    return value == target
        elif operator == '!=':
            if target.count(","):
                if value not in target.split(","):
                    return True
                else:
                    return False
            else:
                return value != target
        elif operator == '>':
            return float(value) > float(target)
        elif operator == '>=':
            return float(value) >= float(target)
        elif operator == '<':
            return float(value) < float(target)
        elif operator == '<=':
            return float(value) <= float(target)
        else:
            return False

    def check_csv_columns(self, csv_file, filter_conditions, check_conditions):
        filter_conditions = self._remove_empty(filter_conditions)
        check_conditions = self._remove_empty(check_conditions)
        filter_conditions_2 = self._convert_conditions(filter_conditions)
        check_conditions_2 = self._convert_conditions(check_conditions)
        filter_statisfied_num = 0
        wrong_rows = []
        right_rows = []
        with open(csv_file, mode='r', newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                filter_pass = all(self._check_condition(row[col], op, val) for col, op, val in filter_conditions_2)
                if filter_pass:
                    filter_statisfied_num += 1
                    check_pass = all(self._check_condition(row[col], op, val) for col, op, val in check_conditions_2)
                    if check_pass:
                        right_rows.append(row)
                    if not check_pass:
                        wrong_rows.append(row)
        if filter_statisfied_num == 0:
            raise Exception("check csv failed with filter_conditions:{}".format(filter_conditions))
        else:
            print("debug: total {} satisfying filter_conditions:{}, "
                  "wrong rows={} and right rows={} satisfying {}".format(filter_statisfied_num,
                                                                         filter_conditions,
                                                                         len(wrong_rows),
                                                                         len(right_rows),
                                                                         check_conditions))
        if len(wrong_rows):
            # print("debug: have wrong rows:")
            # for row in wrong_rows:
            #     print("-----{}".format(row))
            raise Exception("check csv failed with filter_conditions:{} and check_conditions={}".format(
                filter_conditions, check_conditions))
        else:
            print("debug: check csv succeed with filter_conditions:{} and check_conditions={}".format(
                filter_conditions, check_conditions))

    def get_csv_columns(self, csv_file, columns, filter_conditions=""):
        list_out = []
        filter_conditions = self._remove_empty(filter_conditions)
        filter_conditions_2 = self._convert_conditions(filter_conditions)
        if not isinstance(columns, list):
            columns = [columns]
        columns_values = []
        with open(csv_file, mode='r', newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                if len(filter_conditions):
                    filter_pass = all(self._check_condition(row[col], op, val) for col, op, val in filter_conditions_2)
                else:
                    filter_pass = True
                if filter_pass:
                    columns_values.append([row.get(col, "") for col in columns])
        list2 = list(map(list, zip(*columns_values)))
        for list_in_list in list2:
            list3 = []
            for value in list_in_list:
                if len(value.strip()):
                    list3.append(value.strip())
            list_out.append(list3)
        if len(list_out) == 1:
            return list_out[0]
        else:
            return list_out

    def _check_stepdown(self, steps, stepdown_exp, step_tolerance):
        print("debug: check stepdown:{}".format(stepdown_exp))
        stepdown_act_values = [step for step in steps if step < 0]
        satisfied_num = 0
        not_satisfied = []
        for stepdown_act in stepdown_act_values:
            if float(stepdown_exp) * 0.98 <= float(abs(stepdown_act)) <= float(stepdown_exp) * 1.02:
                satisfied_num += 1
            else:
                not_satisfied.append(stepdown_act)
        print("debug: satisfied_num={}, not_satisfied_num={} for stepdown".format(satisfied_num, len(not_satisfied)))
        if len(not_satisfied):
            print("debug: not satisfying stepdown is {}".format(not_satisfied))
        success_ratio = satisfied_num / (satisfied_num + len(not_satisfied))
        if success_ratio >= float(step_tolerance) / 100:
            print("debug: check stepdown succeed with stepdown_exp={} and step_tolerance={}%, success_ratio={}%".format(
                stepdown_exp, step_tolerance, success_ratio * 100))
        else:
            raise Exception(("check stepdown failed with stepdown_exp={} and step_tolerance={}%, "
                             "success_ratio={}%".format(stepdown_exp, step_tolerance, success_ratio * 100)))

    def _check_stepup(self, steps, stepup_exp_values, step_tolerance):
        stepup_act_values = [step for step in steps if step >= 0]
        stepup_exp_values = sorted(list(set(stepup_exp_values)), key=float)
        print("debug: check stepup:{}".format(stepup_exp_values))
        satisfied_num = 0
        not_satisfied = []
        for stepup_act in stepup_act_values:
            satisfied_flag = False
            for stepup_exp in stepup_exp_values:
                if float(stepup_exp) * 0.98 <= float(stepup_act) <= float(stepup_exp) * 1.02:
                    satisfied_flag = True
                    break
            if satisfied_flag:
                satisfied_num += 1
            else:
                not_satisfied.append(stepup_act)
        print("debug: satisfied_num={}, not_satisfied_num={} for stepup".format(satisfied_num, len(not_satisfied)))
        if len(not_satisfied):
            print("debug: not satisfying stepup is {}".format(not_satisfied))
        success_ratio = satisfied_num / (satisfied_num + len(not_satisfied))
        if success_ratio >= float(step_tolerance) / 100:
            print("debug: check stepup succeed with stepup_exp_values={} "
                  "and step_tolerance={}%, success_ratio={}%".format(stepup_exp_values,
                                                                     step_tolerance, success_ratio * 100))
        else:
            raise Exception(("check stepup failed with stepup_exp_values={} "
                             "and step_tolerance={}%, success_ratio={}%".format(stepup_exp_values,
                                                                                step_tolerance, success_ratio * 100)))

    def _calculate_stepup_exp_values_for_dl(self, targetbler, stepup, stepdown, usedmcs_list, rank_list):
        if stepup == "basic":
            print("step: calculate stepup expected values")
            stepup_basic = float(targetbler) / (1 - float(targetbler)) * float(stepdown)
            stepup_exp_values_values = [stepup_basic]
        elif stepup.startswith("mad"):
            print("step: calculate blerdistfactor and stepup expected values")

            mcs_blerdistfactor_mapping_rank1 = {"mcs1": 1.13, "mcs2": 1.12, "mcs3": 1.1, "mcs4": 1.1, "mcs5": 1.1,
                                                "mcs6": 1.05, "mcs19": 0.9, "mcs20": 0.65, "mcs21": 0.6, "mcs22": 0.6,
                                                "mcs23": 0.6, "mcs24": 0.45, "mcs25": 0.6, "mcs26": 0.5, "mcs27": 0.5}
            mcs_blerdistfactor_mapping_rank2 = {"mcs1": 1.13, "mcs2": 1.12, "mcs3": 1.1, "mcs4": 1.1, "mcs5": 1.1,
                                                "mcs6": 1.05, "mcs18": 0.95, "mcs19": 0.9, "mcs20": 0.65, "mcs21": 0.6,
                                                "mcs22": 0.6, "mcs23": 0.6, "mcs24": 0.6, "mcs25": 0.45, "mcs26": 0.5,
                                                "mcs27": 0.5}
            mcs_blerdistfactor_mapping_rank3 = {"mcs1": 1.13, "mcs2": 1.12, "mcs3": 1.1, "mcs4": 1.1, "mcs5": 1.1,
                                                "mcs6": 1.05, "mcs14": 0.95, "mcs15": 0.95, "mcs16": 0.95,
                                                "mcs17": 0.95,
                                                "mcs18": 0.95, "mcs19": 0.7, "mcs20": 0.65, "mcs21": 0.6, "mcs22": 0.55,
                                                "mcs23": 0.55, "mcs24": 0.55, "mcs25": 0.5, "mcs26": 0.5, "mcs27": 0.5}
            mcs_blerdistfactor_mapping_rank4 = {"mcs1": 1.13, "mcs2": 1.12, "mcs3": 1.1, "mcs4": 1.1, "mcs5": 1.1,
                                                "mcs6": 1.05, "mcs19": 0.6, "mcs20": 0.7, "mcs21": 0.6, "mcs22": 0.5,
                                                "mcs23": 0.5, "mcs24": 0.45, "mcs25": 0.45, "mcs26": 0.4}
            mcs_blerdistfactor_mapping = {"rank1": mcs_blerdistfactor_mapping_rank1,
                                          "rank2": mcs_blerdistfactor_mapping_rank2,
                                          "rank3": mcs_blerdistfactor_mapping_rank3,
                                          "rank4": mcs_blerdistfactor_mapping_rank4}
            blerdistfactor_values = []
            for rank in rank_list:
                for mcs in usedmcs_list:
                    if "mcs{}".format(mcs) in mcs_blerdistfactor_mapping[rank.lower()]:
                        blerdistfactor = mcs_blerdistfactor_mapping[rank.lower()]["mcs{}".format(mcs)]
                    else:
                        blerdistfactor = 1
                    blerdistfactor_values.append(blerdistfactor)
            blerdistfactor_values = list(set(blerdistfactor_values))
            blerdistfactor_values.sort()
            print("debug: usedmcs={}, rank={}".format(usedmcs_list, rank_list))
            print("debug: blerdistfactor={}".format(blerdistfactor_values))
            stepup_exp_values_values = []
            for blerdistfactor in blerdistfactor_values:
                stepup = float(targetbler) / (1 - float(targetbler)) * float(stepdown) * blerdistfactor
                stepup_exp_values_values.append(stepup)
        else:
            print("step: use specified stepup")
            stepup_exp_values_values = [stepup]
        print("debug: expected stepup={}".format(stepup_exp_values_values))
        return stepup_exp_values_values

    def _calculate_stepup_exp_values_for_ul(self, targetbler, stepup, stepdown, usedmcs_list):
        print("step: calculate stepUpFactor and stepup expected values")
        stepup_basic = float(targetbler) / (1 - float(targetbler)) * float(stepdown)
        if stepup == "basic":
            stepup_exp_values_values = [stepup_basic]
        elif stepup.startswith("mcs"):
            if stepup.partition("mcs")[-1].split("_")[0] in usedmcs_list:
                stepUpFactor = stepup.split("_")[-1]
                stepup_mcs = stepup_basic * float(stepUpFactor)
                stepup_exp_values_values = [stepup_basic, stepup_mcs]
            else:
                stepup_exp_values_values = [stepup_basic]
        else:
            stepup_exp_values_values = [stepup]
        print("debug: expected stepup={}".format(stepup_exp_values_values))
        return stepup_exp_values_values

    def _check_link_adaptation_24r3(self,
                                    ttitrace_csv,
                                    targetbler,
                                    stepdown,
                                    stepup="basic",
                                    step_tolerance="95%",
                                    mcstable="QAM256",
                                    lamode="BASICRELIABILITY",
                                    cell_ids="",
                                    rnti="",
                                    ibler=""):
        """
        :param ttitrace_csv:
        :param targetbler:
        :param stepdown:
        :param stepup: default 'basic' means to calculate stepup=targetbler/(1-targetbler)*stepdown.
                       other supported values are mad, it will calculate stepup=
                       targetbler/(1-targetbler)*stepdown*blerDistFactor according to CB009765
                       moreover you can specify it by yourself.
        :param step_tolerance: if actual stepdown(stepup) satisfying percentage of step_tolerance numbers of
                               target stepdown/stepup, the check will pass.
        :param mcstable:
        :param lamode:
        :param cell_ids: no need to specify cell_id if only have one cell in ttitrace log. can support multiple cells,
                         for example cell_ids=11,21.
        :param ibler: format is x%-y%, for example 3%-5%, it means 3%<iber<5%,
                      keep it empty if don't want to check iber.
        :return: None
        """
        rnti_ue1 = builtin_obj.get_variable_value("${UE1_RNTI}", "")
        # rnti_ue1 = "54928"
        if len(rnti.strip()):
            rnti_filter = "rnti={}".format(rnti.strip())
        elif len(rnti_ue1):
            rnti_filter = "rnti={}".format(rnti_ue1)
        else:
            # fake_ues = "0,65534,65535,65521"
            # rnti_filter = "rnti!={}".format(fake_ues)
            rnti_filter = ""

        for cell in cell_ids.strip().split(","):
            if len(cell):
                cell_filter = "lcrId={}".format(cell.strip())
            else:
                cell_filter = ""
            print("step: filter rnti, cell_id and mcsTable to check targetBLER and laMode")
            filters_1 = [rnti_filter, cell_filter, "mcsTable={}".format(mcstable)]
            checks_1 = ["targetBLER={}".format(targetbler), "laMode={}".format(lamode)]
            self.check_csv_columns(ttitrace_csv, filters_1, checks_1)

            print("step: filter rnti, cell_id and targetBLER to check mcsTable")
            filters_2 = [rnti_filter, cell_filter, "targetBLER={}".format(targetbler)]
            self.check_csv_columns(ttitrace_csv, filters_2, "mcsTable={}".format(mcstable))

            # calculate stepup expected values
            if ttitrace_csv.endswith("ttiTrace_dl.csv"):
                filters_3 = [rnti_filter, cell_filter, "isDeltaCqiCalculated=1"]
                rrmDeltaxxx = self.get_csv_columns(ttitrace_csv, filter_conditions=filters_3, columns="rrmDeltaCqi")
                usedmcs_list = self.get_csv_columns(ttitrace_csv, columns="rrmDlUsedMcs", filter_conditions=filters_1)
                usedmcs_list = sorted(list(set(usedmcs_list)), key=int)
                filter_rank = [rnti_filter, cell_filter]
                rank_list = self.get_csv_columns(ttitrace_csv, columns="rank", filter_conditions=filter_rank)
                rank_list = list(set(rank_list))
                stepup_exp_values_values = self._calculate_stepup_exp_values_for_dl(
                    targetbler, stepup, stepdown, usedmcs_list, rank_list)

                # set filter for ibler
                filters_ibler = [rnti_filter, cell_filter, "type=dlFdSchedData"]
            elif ttitrace_csv.endswith("ttiTrace_ul.csv"):
                filters_3 = [rnti_filter, cell_filter, "isDeltaSinrCalculated=1"]
                rrmDeltaxxx = self.get_csv_columns(ttitrace_csv, filter_conditions=filters_3, columns="rrmDeltaSinr")
                usedmcs_list = self.get_csv_columns(ttitrace_csv, columns="rrmUlUsedMcs", filter_conditions=filters_1)
                usedmcs_list = sorted(list(set(usedmcs_list)), key=int)
                filter_rank = [rnti_filter, cell_filter]
                rank_list = self.get_csv_columns(ttitrace_csv, columns="numOfLayers", filter_conditions=filter_rank)
                print("debug: UsedMcs={}, rank={}".format(usedmcs_list, list(set(rank_list))))
                if stepup == "basic" and mcstable == "QAM256":
                    stepup = "mcs19_0.47"
                stepup_exp_values_values = self._calculate_stepup_exp_values_for_ul(
                    targetbler, stepup, stepdown, usedmcs_list)

                # set filter for ibler
                filters_ibler = [rnti_filter, cell_filter, "type=ulFdSchedData"]
            else:
                raise Exception("can't support {}".format(ttitrace_csv))
            # print("debug: len(rrmDeltaxxx)={}, rrmDeltaxxx={}".format(len(rrmDeltaxxx), rrmDeltaxxx))

            # check stepdown and stepup
            steps = [float(rrmDeltaxxx[i]) - float(rrmDeltaxxx[i - 1]) for i in range(1, len(rrmDeltaxxx))]
            # print("steps are {}".format(steps))
            step_tolerance = step_tolerance.replace("%", "")
            self._check_stepdown(steps, stepdown, step_tolerance)
            self._check_stepup(steps, stepup_exp_values_values, step_tolerance)

            print("step: calculate ibler")
            txnumber = self.get_csv_columns(ttitrace_csv, filter_conditions=filters_ibler, columns="txNumber")
            number_1 = txnumber.count("1")
            number_2 = txnumber.count("2")
            ibler_act = number_2 / number_1 * 100
            if ibler.count("-"):
                ibler_exp_min, ibler_exp_max = ibler.replace("%", "").split("-")
                if not float(ibler_exp_min) < float(ibler_act) < float(ibler_exp_max):
                    raise Exception("wrong ibler:{}， not in range of {}-{}".format(ibler_act,
                                                                                   ibler_exp_min,
                                                                                   ibler_exp_max))
                else:
                    print("debug: check ibler succeed, ibler={}%".format(ibler_act))
            else:
                print("debug: ibler={}%".format(ibler_act))

    def _check_link_adaptation_since_25r1(self,
                                          ttitrace_csv,
                                          targetbler,
                                          stepdown,
                                          stepup="basic",
                                          step_tolerance="95%",
                                          mcstable="QAM256",
                                          lamode="BASICRELIABILITY",
                                          cell_ids="",
                                          rnti="",
                                          ibler=""):
        """
        :param ttitrace_csv:
        :param targetbler:
        :param stepdown:
        :param stepup: default 'basic' means to calculate stepup=targetbler/(1-targetbler)*stepdown.
                       other supported values are mad, it will calculate stepup=
                       targetbler/(1-targetbler)*stepdown*blerDistFactor according to CB009765
                       moreover you can specify it by yourself.
        :param step_tolerance: if actual stepdown(stepup) satisfying percentage of step_tolerance numbers of
                               target stepdown/stepup, the check will pass.
        :param mcstable:
        :param lamode:
        :param cell_ids: no need to specify cell_id if only have one cell in ttitrace log. can support multiple cells,
                         for example cell_ids=11,21.
        :param ibler: format is x%-y%, for example 3%-5%, it means 3%<iber<5%,
                      keep it empty if don't want to check iber.
        :return: None
        """
        rnti_ue1 = builtin_obj.get_variable_value("${UE1_RNTI}", "")
        # rnti_ue1 = "54928"
        if len(rnti.strip()):
            rnti_filter = "rnti={}".format(rnti.strip())
        elif len(rnti_ue1):
            rnti_filter = "rnti={}".format(rnti_ue1)
        else:
            # fake_ues = "0,65534,65535,65521"
            # rnti_filter = "rnti!={}".format(fake_ues)
            rnti_filter = ""

        for cell in cell_ids.strip().split(","):
            if len(cell):
                cell_filter = "lcrId={}".format(cell.strip())
            else:
                cell_filter = ""

            if ttitrace_csv.endswith("ttiTrace_dl.csv"):
                print("step: filter rnti, cell_id and dlFdSchedAdditionalData to check targetBLER")
                filters_1 = [rnti_filter, cell_filter, "type=dlFdSchedAdditionalData"]
                checks_1 = ["targetBLER={}".format(targetbler)]
                self.check_csv_columns(ttitrace_csv, filters_1, checks_1)

                print("step: filter rnti, cell_id and dlFdSchedData to check mcsTable and laMode")
                filters_2 = [rnti_filter, cell_filter, "type=dlFdSchedData,dlFdSchedData[]"]
                checks_2 = ["mcsTable={}".format(mcstable), "laMode={}".format(lamode)]
                self.check_csv_columns(ttitrace_csv, filters_2, checks_2)

                # calculate stepup expected values
                filters_3 = [rnti_filter, cell_filter, "isDeltaCqiCalculated=1"]
                rrmDeltaxxx = self.get_csv_columns(ttitrace_csv, filter_conditions=filters_3, columns="rrmDeltaCqi")
                usedmcs_list = self.get_csv_columns(ttitrace_csv, columns="rrmDlUsedMcs", filter_conditions=filters_2)
                usedmcs_list = sorted(list(set(usedmcs_list)), key=int)
                filter_rank = [rnti_filter, cell_filter]
                rank_list = self.get_csv_columns(ttitrace_csv, columns="rank", filter_conditions=filter_rank)
                rank_list = list(set(rank_list))
                stepup_exp_values_values = self._calculate_stepup_exp_values_for_dl(
                    targetbler, stepup, stepdown, usedmcs_list, rank_list)

                # set filter for ibler
                filters_ibler = [rnti_filter, cell_filter, "type=dlFdSchedData"]

            elif ttitrace_csv.endswith("ttiTrace_ul.csv"):
                print("step: filter rnti, cell_id and mcsTable to check targetBLER and laMode")
                filters_1 = [rnti_filter, cell_filter, "mcsTable={}".format(mcstable)]
                checks_1 = ["targetBLER={}".format(targetbler), "laMode={}".format(lamode)]
                self.check_csv_columns(ttitrace_csv, filters_1, checks_1)

                print("step: filter rnti, cell_id and targetBLER to check mcsTable")
                filters_2 = [rnti_filter, cell_filter, "targetBLER={}".format(targetbler)]
                self.check_csv_columns(ttitrace_csv, filters_2, "mcsTable={}".format(mcstable))

                # calculate stepup expected values
                filters_3 = [rnti_filter, cell_filter, "isDeltaSinrCalculated=1"]
                rrmDeltaxxx = self.get_csv_columns(ttitrace_csv, filter_conditions=filters_3, columns="rrmDeltaSinr")
                usedmcs_list = self.get_csv_columns(ttitrace_csv, columns="rrmUlUsedMcs", filter_conditions=filters_1)
                usedmcs_list = sorted(list(set(usedmcs_list)), key=int)
                filter_rank = [rnti_filter, cell_filter]
                rank_list = self.get_csv_columns(ttitrace_csv, columns="numOfLayers", filter_conditions=filter_rank)
                print("debug: UsedMcs={}, rank={}".format(usedmcs_list, list(set(rank_list))))
                if stepup == "basic" and mcstable == "QAM256":
                    stepup = "mcs19_0.47"
                stepup_exp_values_values = self._calculate_stepup_exp_values_for_ul(
                    targetbler, stepup, stepdown, usedmcs_list)

                # set filter for ibler
                filters_ibler = [rnti_filter, cell_filter, "type=ulFdSchedData"]

            else:
                raise Exception("can't support {}".format(ttitrace_csv))
            # print("debug: len(rrmDeltaxxx)={}, rrmDeltaxxx={}".format(len(rrmDeltaxxx), rrmDeltaxxx))

            # check stepdown and stepup
            steps = [float(rrmDeltaxxx[i]) - float(rrmDeltaxxx[i - 1]) for i in range(1, len(rrmDeltaxxx))]
            # print("steps are {}".format(steps))
            step_tolerance = step_tolerance.replace("%", "")
            self._check_stepdown(steps, stepdown, step_tolerance)
            self._check_stepup(steps, stepup_exp_values_values, step_tolerance)

            print("step: calculate ibler")
            txnumber = self.get_csv_columns(ttitrace_csv, filter_conditions=filters_ibler, columns="txNumber")
            number_1 = txnumber.count("1")
            number_2 = txnumber.count("2")
            ibler_act = number_2 / number_1 * 100
            if ibler.count("-"):
                ibler_exp_min, ibler_exp_max = ibler.replace("%", "").split("-")
                if not float(ibler_exp_min) < float(ibler_act) < float(ibler_exp_max):
                    raise Exception("wrong ibler:{}， not in range of {}-{}".format(ibler_act,
                                                                                   ibler_exp_min,
                                                                                   ibler_exp_max))
                else:
                    print("debug: check ibler succeed, ibler={}%".format(ibler_act))
            else:
                print("debug: ibler={}%".format(ibler_act))

    def check_link_adaptation(self,
                              ttitrace_csv,
                              targetbler,
                              stepdown,
                              stepup="basic",
                              step_tolerance="95%",
                              mcstable="QAM256",
                              lamode="BASICRELIABILITY",
                              cell_ids="",
                              rnti="",
                              ibler=""):
        """
        :param ttitrace_csv:
        :param targetbler:
        :param stepdown:
        :param stepup: default 'basic' means to calculate stepup=targetbler/(1-targetbler)*stepdown.
                       other supported values are mad, it will calculate stepup=
                       targetbler/(1-targetbler)*stepdown*blerDistFactor according to CB009765
                       moreover you can specify it by yourself.
        :param step_tolerance: if actual stepdown(stepup) satisfying percentage of step_tolerance numbers of
                               target stepdown/stepup, the check will pass.
        :param mcstable:
        :param lamode:
        :param cell_ids: no need to specify cell_id if only have one cell in ttitrace log. can support multiple cells,
                         for example cell_ids=11,21.
        :param ibler: format is x%-y%, for example 3%-5%, it means 3%<iber<5%,
                      keep it empty if don't want to check iber.
        :return: None
        """
        release = builtin_obj.get_variable_value("${RELEASE}")
        if release == "SBTS24R3":
            self._check_link_adaptation_24r3(ttitrace_csv,
                                             targetbler,
                                             stepdown,
                                             stepup=stepup,
                                             step_tolerance=step_tolerance,
                                             mcstable=mcstable,
                                             lamode=lamode,
                                             cell_ids=cell_ids,
                                             rnti=rnti,
                                             ibler=ibler)
        else:
            self._check_link_adaptation_since_25r1(ttitrace_csv,
                                                   targetbler,
                                                   stepdown,
                                                   stepup=stepup,
                                                   step_tolerance=step_tolerance,
                                                   mcstable=mcstable,
                                                   lamode=lamode,
                                                   cell_ids=cell_ids,
                                                   rnti=rnti,
                                                   ibler=ibler)

    def check_ibler_from_ttitrace(self, ttitrace_csv, cell_id, max_bler):
        if ttitrace_csv.endswith("ttiTrace_dl.csv"):
            event_filter = "type=dlFdSchedData"
        else:
            event_filter = "type=ulFdSchedData"
        for cell in cell_id.split(","):
            filters_ibler = [event_filter, "lcrId={}".format(cell.strip())]
            txnumber = self.get_csv_columns(ttitrace_csv,
                                            filter_conditions=filters_ibler,
                                            columns="txNumber")
            number_1 = txnumber.count("1")
            number_2 = txnumber.count("2")
            if number_1 == 0:
                print("check ber succeed, ibler=0 for cell{}".format(cell))
                continue
            ibler_act = number_2 / number_1 * 100
            if ibler_act > float(max_bler.replace("%", "")):
                raise Exception("cell{}, actual bler is {}%, larger than target：{}".format(cell, ibler_act, max_bler))
            else:
                print("check ber succeed, ibler={}% for cell{}".format(ibler_act, cell))


if __name__ == "__main__":
    check_csv = check_csv()
    ttitrace_csv = r"C:\temp\CB013303_SR_D1_01_Service-aware_BLER_Target_featur\
    gnb_ttitrace_logs_3_adjust_pa\ttiTrace_dl.csv"
    targetbler = 0.08
    stepdown = 0.25
    stepup = "mad_rank4"
    mcstable = "QAM256"
    lamode = "BASICRELIABILITY"
    ibler = "6%-10%"
    check_csv.check_link_adaptation(ttitrace_csv, targetbler, stepdown, stepup,
                                    mcstable=mcstable, ibler=ibler, lamode=lamode)
