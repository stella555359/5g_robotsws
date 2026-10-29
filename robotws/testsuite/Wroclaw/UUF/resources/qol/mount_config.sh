#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Absolute paths
BASE_DIR="/home/ute"
TOPOLOGY_CONFIGS_DIR="$BASE_DIR/topology-configs"
TESTLINE_CONFIG_DIR="$BASE_DIR/testline_configuration"

HOST=$(hostname)
suffix=${HOST##*-}

if [[ ${#suffix} != 1 ]]; then
    REALHOST=$HOST
else
    REALHOST=${HOST%-*}
fi
UNDERHOST="${REALHOST//-/_}"

INIT_PATH="$TESTLINE_CONFIG_DIR/$UNDERHOST/__init__.py"

if [ -f "$INIT_PATH" ]; then
    echo "$INIT_PATH exists"
    TOPOLOGY=$(grep 'tl_cloud_topology' "$INIT_PATH" | awk -F"=" '{gsub(/^ +| +$/, "", $2); print $2}' | tr -d '\r\n ",)')
    echo "Extracted TOPOLOGY: '$TOPOLOGY'"

    if [ -n "$TOPOLOGY" ]; then
        echo "Checking directory: $TOPOLOGY_CONFIGS_DIR/$TOPOLOGY"

        if [ -d "$TOPOLOGY_CONFIGS_DIR/$TOPOLOGY" ]; then
            echo "Topology directory exists: $TOPOLOGY_CONFIGS_DIR/$TOPOLOGY"
            # Verify permissions
            if [ -w "$BASE_DIR" ]; then
                echo "Permissions are sufficient to create symbolic links."
                ln -s "$TOPOLOGY_CONFIGS_DIR/$TOPOLOGY" "$BASE_DIR/_${UNDERHOST}_topology_configs"
                ln -s "$TOPOLOGY_CONFIGS_DIR/$TOPOLOGY" "$BASE_DIR/scf_tc"
                ln -s "$TESTLINE_CONFIG_DIR/$UNDERHOST" "$BASE_DIR/init_tc"
                echo "Symbolic links created successfully"
            else
                echo "Insufficient permissions to create symbolic links in $BASE_DIR"
            fi
        else
            echo "Topology directory does not exist in repo or repo not cloned"
        fi
    else
        echo "Topology not detected from init file"
    fi
else
    echo "Init file for this testline does not exist"
fi
