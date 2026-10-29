#!/bin/bash

BASE_DIR="/home/ute/.ute-ca/executions/"

cd "$BASE_DIR" || exit
#!/bin/bash

BASE_DIR="/home/ute/.ute-ca/executions/"

HIGHEST_NUM_DIR=""

find_highest_num_dir() {
    local highest_dir=$(find "$BASE_DIR" -maxdepth 1 -type d -name '[0-9]*' | sort -n | tail -1)
    echo "$highest_dir"
}

while true; do
    NEW_HIGHEST_DIR=$(find_highest_num_dir)

    if [[ "$NEW_HIGHEST_DIR" != "$HIGHEST_NUM_DIR" ]]; then
        HIGHEST_NUM_DIR="$NEW_HIGHEST_DIR"
        echo "Switching to new highest numerical directory: $HIGHEST_NUM_DIR"

        if [[ -f "$HIGHEST_NUM_DIR/logs/agent.log" ]]; then
            echo "Starting to watch $HIGHEST_NUM_DIR/logs/agent.log..."
            tail -n 20 "$HIGHEST_NUM_DIR/logs/agent.log" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/  \+/ /g'
            sleep 2
            clear
        else
            echo "agent.log does not exist in the directory $HIGHEST_NUM_DIR"
        fi
    else
        if [[ -f "$HIGHEST_NUM_DIR/logs/agent.log" ]]; then
            tail -n 20 "$HIGHEST_NUM_DIR/logs/agent.log" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/  \+/ /g'
            sleep 2
            clear
        fi
    fi
done
