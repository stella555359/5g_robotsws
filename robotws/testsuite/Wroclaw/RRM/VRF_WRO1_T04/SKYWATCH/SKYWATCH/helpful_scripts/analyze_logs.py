import re
import sys


known_error_prints = ["CTRL_RLF_IND",
                      "No response from proxy for CTRL_UE_MOD_NR_RSP",
                      "T319 expired: No response to NR_RRC_Resume_REQUEST",
                      "Failure in processsing CTRL_CG_CONFIG_CLUBBED_T",
                      "T300 expiration: No response to RRCSetupRequest"]
filtered_ues = []

if len(sys.argv) < 2:
    print("Użycie: python find_ues_with_id_idle_as_first.py <sciezka_do_pliku_log>")
    sys.exit(1)

log_path = sys.argv[1]

with open(log_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

pattern = re.compile(r"UE-?([1-9][0-9]{0,3})(?!\d):?")
error_pattern = re.compile(r"\[ERROR\].*?UE-?([1-9][0-9]{0,3})(?!\d):?")
pass_regex = re.compile(r"(?:[^']*'){1}([^']*)")

first_occurrence = {}  # mapa: fraza -> pierwsza linia, w której występuje

error_lines = [(idx, match.group(1), line) for idx, line in enumerate(lines) if (error_pattern.search(line) and
                                                                                 (match := pass_regex.search(line)))]

for idx, pass_string, line in error_lines:
    match = pattern.search(line)
    if match:
        tag = f"UE{match.group(1)}:"
        if tag not in first_occurrence:
            first_occurrence[tag] = (idx, pass_string, line.strip())

all = {
    tag: (line_num, pass_string, text) for tag, (line_num, pass_string, text) in first_occurrence.items()
}


def search_for_packet_schedule_issue(condition, num_of_errors, context, pass_string):
    num_of_idles = 0
    for id, text in context[:-1]:
        if condition in text:
            num_of_idles += 1
    if num_of_idles >= 2:
        print(f"[TRACKED] FOUND ALREADY KNOWN ISSUE WITH PACKET REMAINS IN BUFFER WHILE {pass_string}")
        num_of_errors += 1
    return num_of_errors


def search_for_last_10_lines_and_filter_out_errors(base):
    new_base = base.copy()
    for tag, (line_num, pass_string, text) in base.items():
        known_error_prints_copy = known_error_prints.copy()
        num_of_errors = 0
        matching_lines = [
            (i, l.strip()) for i, l in enumerate(lines[:line_num + 1])
            if re.search(rf"\b{re.escape(tag).replace(':', '')}-?{tag[-1]}", l) or tag in l
        ]
        context = matching_lines[-10:]
        if "IS IDLE" in pass_string:
            num_of_errors = search_for_packet_schedule_issue("IS IDLE", num_of_errors, context, pass_string)
        elif "Is INACTIVE" in pass_string:
            num_of_errors = search_for_packet_schedule_issue("Is INACTIVE", num_of_errors, context, pass_string)
            known_error_prints_copy.append("IS IDLE")
        else:
            for error in known_error_prints_copy:
                for id, text in context:
                    if error in text:
                        num_of_errors += 1
                        if error == "IS IDLE":
                            print(f"FOUND ALREADY KNOWN ISSUE {error} instead of {pass_string}")
                        else:
                            print(f"FOUND ALREADY KNOWN ISSUE {tag} {error}")
        if num_of_errors:
            del new_base[tag]
            filtered_ues.append(tag)
        else:
            print("=" * 50)
            print(f"TAG: {tag} pass_string: {pass_string} (linia {line_num + 1})")
            print("Kontekst:")
            for i, ctx_line in context:
                print(f"{i+1:>5} {ctx_line}")
    return new_base


all = search_for_last_10_lines_and_filter_out_errors(all)

print("Odfiltrowano UE:")
for tag in filtered_ues:
    print(tag)

print("UE, które nie mają znanych wcześniej błędów:")
for tag in all:
    print(tag)
