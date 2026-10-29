import glob


def is_eligible_kpi(kpi_id, eligible_kpis):
    is_selected = False
    for eligible_kpi_id in eligible_kpis:
        if eligible_kpi_id == kpi_id:
            is_selected = True
            break
    return is_selected


def update_eligible_kpi_comment(kpi_id, kpi_comment, eligible_kpis):
    for eligible_kpi_id in eligible_kpis:
        if eligible_kpi_id == kpi_id:
            eligible_kpis[eligible_kpi_id] = kpi_comment
            break


def add_eligible_kpi(kpi_id, eligible_kpis):
    if not is_eligible_kpi(kpi_id, eligible_kpis):
        eligible_kpis[kpi_id] = "To be updated"


def analyze_kpi(file_name, eligible_kpis, output_csv):
    kpi_file = open(file_name, "r")
    line = kpi_file.readline()
    step_name = "unknown"
    pm_file_date = "unknown"
    pm_file_time = "unknown"
    oam_id = "unknown"
    test_status = "FAILED"
    kpis = []
    while line:
        if line.startswith("Parsing:Contraints file"):
            step_name = line.split("/")[-1].split(".csv")[0]
        if line.startswith("Parsing:PM file"):
            pm_file_date = line.split("/")[-1].split(".")[2]
            pm_file_time = line.split("/")[-1].split(".")[3][0:4]
        if "Searching Cnt/Kpi matching OAM_ID" in line:
            oam_id = line.split("=", 2)[-1].strip()
        if line.startswith("    Cnt[") or line.startswith("    Kpi["):
            kpi_id = line.split(":")[1].split("=")[0].strip()
            if kpi_id[-1].isalpha():
                kpi_id = kpi_id[:-1]
            kpi_value = line.split("=")[1].split("DESC")[0].strip()
            kpi_comment = line.split("DESC=")[1].strip()
            if is_eligible_kpi(kpi_id, eligible_kpis):
                kpis.append({"oam_id": oam_id, "kpi_id": kpi_id, "kpi_value": kpi_value})
                update_eligible_kpi_comment(kpi_id, kpi_comment, eligible_kpis)
        if line.startswith("  Constraint["):
            kpi_id = line.split("ROOT:")[1].split(" ", 1)[0]
            add_eligible_kpi(kpi_id, eligible_kpis)
        if line.startswith("Constraints Synthesis:"):
            test_status = "PASSED"
        if line.startswith("  Number of "):
            if "Number of PASSED" not in line:
                number_of_errors = line.split(":")[1].strip()
                if number_of_errors != "0":
                    test_status = "FAILED"
        line = kpi_file.readline()
    kpi_file.close()
    for kpi in kpis:
        output_csv.write(f"{pm_file_date},NA,{pm_file_date}-{pm_file_time},NA,NA,NA,NA,")
        output_csv.write(f"NA,NA,NA,{step_name},KPI or Counter_{test_status},{kpi['kpi_id']},")
        output_csv.write(f"{kpi['kpi_value']},NA,NA,NA,{kpi['oam_id']}\n")
    print(f"End of analysis for {file_name}, test status {test_status}")


def read_eligible_kpis():
    eligible_kpis = {}
    eligible_kpis_file = open("/ceph/VRF/COMMON/TranRob/TranRob/kpi/eligible_kpi.csv", "r")
    for line in eligible_kpis_file.readlines():
        kpi_id = line.split(",", 1)[0].strip()
        kpi_comment = line.split(",")[-1].strip()
        add_eligible_kpi(kpi_id, eligible_kpis)
        update_eligible_kpi_comment(kpi_id, kpi_comment, eligible_kpis)
    eligible_kpis_file.close()
    return eligible_kpis


def write_eligible_kpis(eligible_kpis):
    eligible_kpis_file = open("/ceph/VRF/COMMON/TranRob/TranRob/kpi/eligible_kpi.csv", "w")
    for eligible_kpi in sorted(eligible_kpis.keys()):
        eligible_kpis_file.write(f"{eligible_kpi.ljust(12)}, {eligible_kpis[eligible_kpi]}\n")
    eligible_kpis_file.close()


def create_kpi_history():
    eligible_kpis = read_eligible_kpis()
    output_csv = open("/ceph/VRF/COMMON/TranRob/TranRob/kpi/kpi_history.csv", "w")
    output_csv.write("run date,crtUteRun Log,jenkinsID,Test Line,Topology,ENB_BUILD,enbBuildShort,AP version,")
    output_csv.write("robot path,robot file,STEP,Failure type,Failed Object,Value 0,Value 1,Value 2,Value 3,Value 4\n")
    for file_name in glob.glob("/ceph/VRF/COMMON/TranRob/TranRob/kpi/*.kpi"):
        analyze_kpi(file_name, eligible_kpis, output_csv)
    output_csv.close()
    write_eligible_kpis(eligible_kpis)


if __name__ == "__main__":
    create_kpi_history()
