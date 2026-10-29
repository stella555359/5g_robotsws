import re
import sys


known_error_prints = ["CTRL_RLF_IND", "No response from proxy for CTRL_UE_MOD_NR_RSP"]
filtered_ues = []
# Wczytaj plik
if len(sys.argv) < 2:
    print("Użycie: python find_ues_with_id_idle_as_first.py <sciezka_do_pliku_log>")
    sys.exit(1)

log_path = sys.argv[1]

with open(log_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Wzorzec dla UEXXX: (1-999)
# pattern = re.compile(r"\bUE([1-9][0-9]{0,2}):\b")
pattern = re.compile(r"UE-?([1-9][0-9]{0,2}):?")
error_pattern = re.compile(r"\[ERROR\].*?UE-?([1-9][0-9]{0,2}):?")

first_occurrence = {}  # mapa: fraza -> pierwsza linia, w której występuje

error_lines = [(idx, line) for idx, line in enumerate(lines) if error_pattern.search(line)]

for idx, line in error_lines:
    match = pattern.search(line)
    if match:
        tag = f"UE{match.group(1)}:"
        # print(tag)
        if tag not in first_occurrence:
            first_occurrence[tag] = (idx, line.strip())
            if tag == "UE259:":
                print(first_occurrence[tag])

# Filtrowanie tylko tych, których pierwsze wystąpienie ma "IS IDLE"
# idle_only = [tag for tag, text in first_occurrence.items() if "IS IDLE" in text]
# inactive_only = [tag for tag, text in first_occurrence.items() if "Is INACTIVE" in text]
idle_only = {
    tag: (line_num, text) for tag, (line_num, text) in first_occurrence.items() if "IS IDLE" in text
}
inactive_only = {
    tag: (line_num, text) for tag, (line_num, text) in first_occurrence.items() if "Is INACTIVE" in text
}


def search_for_last_10_lines_and_filter_out_errors(base):
    new_base = base.copy()
    for tag, (line_num, text) in base.items():
        num_of_errors = 0
        matching_lines = [
            (i, l.strip()) for i, l in enumerate(lines[:line_num + 1])
            if re.search(rf"\b{re.escape(tag).replace(':', '')}-?{tag[-1]}", l) or tag in l
        ]
        context = matching_lines[-10:]
        # print(context)
        for error in known_error_prints:
            for id, text in context:
                if error in text:
                    num_of_errors += 1
                    print(f"FOUND ALREADY KNOWN ISSUE {error}")
        if num_of_errors:
            del new_base[tag]
            filtered_ues.append(tag)
        else:
            print("=" * 50)
            print(f"TAG: {tag} (linia {line_num + 1})")
            print("Kontekst:")
            for i, ctx_line in context:
                print(f"{i+1:>5} {ctx_line}")
    return new_base


idle_only = search_for_last_10_lines_and_filter_out_errors(idle_only)
inactive_only = search_for_last_10_lines_and_filter_out_errors(inactive_only)

print("Odfiltrowano UE:")
for tag in filtered_ues:
    print(tag)

print("Unikalne frazy, które są IS IDLE:")
for tag in idle_only:
    print(tag)
#
print("Unikalne frazy, które są Is INACTIVE:")
for tag in inactive_only:
    print(tag)
