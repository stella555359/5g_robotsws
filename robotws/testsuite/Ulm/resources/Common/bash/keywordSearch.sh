#!/bin/bash

# ==============================================================================
# Bash-Skript zum rekursiven, case-insensitiven Suchen nach einer Liste von Strings
# im aktuellen Verzeichnis.
# Erweitert, um '_' flexibel zu matchen (Trennzeichen ist obligatorisch).
# Leerzeichen im Suchmuster werden nun als feste Zeichen behandelt.
# Unterstützt nun mehrere Suchlisten mit unterschiedlichen Beschreibungen.
# WICHTIG: Es wurden Wortgrenzen (\b) hinzugefügt, um nur vollständige Matches
#          der gewünschten Pattern zu finden und Überlappungen zu vermeiden.
# KORRIGIERTE ESCAPING-LOGIK FÜR SED-SUCHMUSTER:
#   Alle ERE-Metazeichen im Suchmuster der sed-Befehle selbst werden nun korrekt
#   escaped, um "Invalid preceding regular expression" und "Unmatched ( or \("
#   Fehler zu vermeiden. Dies ist die Standard-Vorgehensweise für sed -E.
# NEU: Das Skript schließt sich selbst von der Suche aus.
# NEU: Debug-Ausgaben wurden entfernt.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Definition der Suchoptionen für grep
#    -r : Rekursive Suche in Unterverzeichnissen
#    -i : Case-insensitive Suche (Groß-/Kleinschreibung ignorieren)
#    -E : Suchmuster als erweiterte reguläre Ausdrücke interpretieren (WICHTIG für [ _] und \b)
#    -n : Zeigt die Zeilennummer der Fundstelle an
#    -H : Zeigt den Dateinamen für jede Fundstelle an (Standard bei -r, aber explizit ist gut)
#    --color=auto : Hebt die Fundstellen farblich hervor (optional)
#    --exclude="$(basename "$0")" : Schließt das Skript selbst von der Suche aus
# ------------------------------------------------------------------------------
GREP_OPTIONS="-r -i -E -n -H --color=auto --exclude=$(basename "$0")"

# ------------------------------------------------------------------------------
# 2. Funktion zum Durchführen der Suche für eine gegebene Liste von Mustern
#    Argumente:
#    $1: Titel/Beschreibung für die aktuelle Suchliste
#    $2: Name des Arrays, das die Suchmuster enthält (z.B. "search_strings[@]")
# ------------------------------------------------------------------------------
perform_search_for_list() {
    local list_title="$1"
    local -n patterns_array="$2" # -n ermöglicht die Referenzierung des Arrays per Name

    echo ""
    echo "==================================================================="
    echo "Starte Suche für: $list_title"
    echo "Flexibles Matching von '_' ist aktiviert (Trennzeichen ist obligatorisch)."
    echo "Leerzeichen im Suchmuster werden als feste Zeichen behandelt."
    echo "Es werden nur vollständige Matches gefunden (durch Wortgrenzen \\b)."
    echo "Das Skript selbst wird von der Suche ausgeschlossen."
    echo "-------------------------------------------------------------------"

    local found_in_this_list=false

    for pattern in "${patterns_array[@]}"; do
        echo ""
        echo "Suche nach: \"$pattern\""
        echo "-------------------------------------------------------------------"

        local escaped_pattern_tmp
        escaped_pattern_tmp=$(printf "%s" "$pattern")

        # Escape alle Regex-Metazeichen für grep -E einzeln.
        # Wichtig: Die Suchmuster in den sed-Befehlen selbst müssen die ERE-Metazeichen
        # korrekt escapen, um sie als Literale zu matchen.

        # Escape Backslash (muss zuerst erfolgen)
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\\/\\\\/g')
        # Escape Punkt
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\./\\./g')
        # Escape eckige Klammern
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\[/\\[/g')
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\]/\\]/g')
        # Escape Stern
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\*/\\*/g')
        # Escape Plus
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\+/\\+/g')
        # Escape Fragezeichen
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\?/\\?/g')
        # Escape geschweifte Klammern
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\{/\\{/g')
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\}/\\}/g')
        # Escape runde Klammern
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\(/\\(/g')
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\)/\\)/g')
        # Escape Pipe
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\|/\\|/g')
        # Escape Caret (Anfang der Zeile)
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\^/\\^/g')
        # Escape Dollar (Ende der Zeile)
        escaped_pattern_tmp=$(printf "%s" "$escaped_pattern_tmp" | sed -E 's/\$/\\$/g')

        local escaped_pattern="$escaped_pattern_tmp"

        # Erstelle das finale reguläre Ausdrucksmuster mit flexiblen Trennzeichen
        # und umschließe es mit Wortgrenzen (\b).
        local regex_pattern
        regex_pattern="\b$(printf "%s" "$escaped_pattern" | sed -E 's/_/[ _]/g')\b"

        # --- DEBUG-AUSGABEN ENTFERNT ---
        # echo "DEBUG: Original Pattern: \"$pattern\""
        # echo "DEBUG: Escaped Pattern: \"$escaped_pattern\""
        # echo "DEBUG: Generierter Regex Pattern (mit flexiblen Trennzeichen und Wortgrenzen): \"$regex_pattern\""
        # echo "DEBUG: Grep-Befehl: grep $GREP_OPTIONS \"$regex_pattern\" ."
        # --- DEBUG-AUSGABEN ENTFERNT ---

        # Führe grep aus.
        # Überprüfen, ob grep Ergebnisse liefert
        if grep $GREP_OPTIONS "$regex_pattern" . > /dev/null; then
            # Wenn grep einen Exit-Code von 0 zurückgibt (Fundstellen), dann ausgeben
            grep $GREP_OPTIONS "$regex_pattern" .
            found_in_this_list=true
        else
            echo "Keine Fundstellen für \"$pattern\" (Regex: \"$regex_pattern\") gefunden."
        fi
        echo "-------------------------------------------------------------------"
    done

    if [ "$found_in_this_list" = true ]; then
        echo "Suche für '$list_title' abgeschlossen. Mindestens ein String wurde gefunden."
    else
        echo "Suche für '$list_title' abgeschlossen. Keine der definierten Strings wurde gefunden."
    fi
    echo "==================================================================="
}

# ------------------------------------------------------------------------------
# 3. Definition der Suchlisten
# ------------------------------------------------------------------------------

# Erste Suchliste (ursprüngliche Liste)
declare -a search_strings=(
    "provision_vdu_delta_plan"
    "get_provision_vdu_delta_plan_status"
    "fix_vdu_delta_plan_error"
    "get_fix_vdu_delta_plan_operation_status"
    "get_staged_plans_info_list"
    "create_vdu_object_of_delta_plan"
    "get_create_vdu_object_action_status_of_delta_plan"
    "update_vdu_parameter_of_delta_plan"
    "get_update_paras_action_status_of_delta_plan"
    "get_delta_plan_info_list"
    "generate_delta_plan"
    "get_delta_plan_generated_action_status"
    "save_delta_plan_file"
    "delete_mo_of_delta_plan"
    "get_deleting_mo_action_state_of_delta_plan"
    "validate_delta_plan"
    "get_validate_delta_plan_operation_status"
    "update_vdu_parameter_of_staged_plan"
    "get_update_paras_action_status_of_staged_plan"
    "create_vdu_object_of_staged_plan"
    "get_create_vdu_object_action_status_of_staged_plan"
    "delete_mo_of_staged_plan"
    "get_deleting_mo_action_state_of_staged_plan"
    "get_delta_plan_validation_results"
    "copy_managed_objects_into_delta_plan"
    "get_copy_managed_objects_into_delta_plan_status"
    "get_rnic_rest_operation"
    "get_opeartion_state_of_locking_du"
    "get_opeartion_state_of_unlocking_du"
    "provision_vcu_delta_plan"
    "get_provision_vcu_delta_plan_status"
    "get_vms"
    "get_plan_info"
    "get_staged_plans_list"
    "get_current_plan_tree_diff"
    "search_parameters_of_delta_plan"
    "get_delta_plan_list"
    "generate_delta_plan"
    "save_delta_plan_file"
    "get_action_state_of_generating_delta_plan"
    "validate_delta_plan"
    "get_action_state_of_validating_delta_plan"
    "update_parameters_of_delta_plan"
    "create_managed_object_of_delta_plan"
    "get_create_managed_object_action_result"
    "delete_managed_object_of_delta_plan"
    "get_delete_managed_object_action_result"
    "get_latest_validation_result_of_delta_plan"
    "copy_managed_objects_into_delta_plan"
    "get_copy_managed_objects_into_delta_plan_status"
    "fix_delta_plan_validation_error"
    "get_action_state_of_fix_delta_plan"
    "revert_managed_object"
    "get_revert_managed_object_action"
    "get_tree_of_current_plan"
)

# Zweite Suchliste (API-Änderungen)
declare -a api_change_search_strings=(
    "fix_vdu_staged_plan_error"
    "create_ald_reset"
    "delete_certificates_by_id"
    "get_rnic_info_from_plan response" # Beispiel mit Leerzeichen
    "collect_l1_iq_data"
    "delete_file_upload_operation"
)

# ------------------------------------------------------------------------------
# 4. Ausführung der Suchen
# ------------------------------------------------------------------------------
echo "Starte alle Suchvorgänge im aktuellen Verzeichnis..."

# Suche für die erste Liste
perform_search_for_list "Standard-Suchliste" "search_strings"

# Suche für die zweite Liste (API-Änderungen)
perform_search_for_list "API-Änderungen (API-Änderung vermerkt)" "api_change_search_strings"

echo ""
echo "Alle Suchvorgänge abgeschlossen."
echo "==================================================================="
