#!/bin/bash
set +x
# Use the first command-line argument as the zip file path
ZIP_FILE="$1"
# Use the second command-line argument as the error pattern
ERROR_PATTERN="$2"
SKIP_ERROR_PATTERN="$3"

# Declare an associative array to keep track of printed error patterns
declare -A printed_patterns

process_matched_content() {
    local matched_content="$1"
    local zip_file="$2"
    local filename="$3"
    local temp_path="$4"
    if [[ -n "$matched_content" ]]; then
        echo "Match found in $compressed_file/$filename"
        echo "$matched_content" | while IFS= read -r line; do
            if echo "$line" | grep -q "Error Handler exception report"; then
                new_error_pattern=$(echo "$line" | grep -o 'ERR/[A-Za-z0-9]\+')
                if [[ -n "$new_error_pattern" && -z "${printed_patterns[$new_error_pattern]}" ]]; then
                    echo "Using new error pattern: $new_error_pattern in $compressed_file/$filename"
                    if [[ "$filename" == *.xz ]]; then
                        xzcat "$temp_path" 2>/dev/null | grep -a "$new_error_pattern" | grep -v "$SKIP_ERROR_PATTERN" && echo "Match found in $compressed_file/$filename"
                    elif [[ "$filename" == *tar.gz ]]; then
                        tar -xzf "$temp_path" -O | zgrep -a "$new_error_pattern" | grep -v "$SKIP_ERROR_PATTERN" && echo "Match found in $compressed_file/$filename"
                    elif [[ "$filename" == *.gz ]]; then
                        zgrep -a "$new_error_pattern" "$filename" | grep -v "$SKIP_ERROR_PATTERN" && echo "Match found in $compressed_file/$filename"
                    elif [[ "$filename" == *.xz ]]; then
                        xzcat "$filename" 2>/dev/null | grep -a "$new_error_pattern" | grep -v "$SKIP_ERROR_PATTERN" && echo "Match found in $compressed_file/$filename"
                    elif [[ "$filename" == *.txt || "$filename" == *.log ]]; then
                        # Directly search non-compressed files
                        grep -a "$new_error_pattern" "$filename" | grep -v "$SKIP_ERROR_PATTERN" && echo "Match found in $compressed_file/$filename"
                    else
                        unzip -p "$compressed_file" "$filename" 2>/dev/null | grep -a "$new_error_pattern" | grep -v "$SKIP_ERROR_PATTERN" && echo "Match found in $compressed_file/$filename"
                    fi
                    printed_patterns[$new_error_pattern]=1
                fi
            else
                echo "$line"
            fi
        done
    fi
}

# Function to handle .zip files
handle_zip_file() {
    local zip_file="$1"
    unzip -l "$zip_file" | sed '1,3d' | awk '{print $4}' | grep -v '^$' | while read filename; do
    # Skip processing for fmNidd.json
    if [[ "$filename" == *fmNidd.json || "$filename" == *HWR.gz ]]; then
        # echo "Skipping log check for $filename"
        continue
    fi
    if [[ "$filename" != *.dat ]]; then
            basename="${filename##*/}"
            local temp_path=$(mktemp) # Create a unique temporary file
            unzip -p "$zip_file" "$filename" > "$temp_path" 2>/dev/null
            if [[ "$filename" == *.xz ]]; then
                # Handle nested .xz files
                matched_content=$(xzcat "$temp_path" 2>/dev/null | grep -a "$ERROR_PATTERN" | grep -v "$SKIP_ERROR_PATTERN")
                process_matched_content "$matched_content" "$zip_file" "$filename" "$temp_path"
            elif [[ "$filename" == *.zip ]]; then
                # Handle nested zip files
                handle_zip_file "$temp_path" 2>/dev/null
            elif [[ "$filename" == *tar.gz ]]; then
                matched_content=$(tar -xzf "$temp_path" -O | zgrep -a "$ERROR_PATTERN" | grep -v "$SKIP_ERROR_PATTERN")
                process_matched_content "$matched_content" "$zip_file" "$filename" "$temp_path"
            elif [[ "$filename" == *.tgz || "$filename" == *.tar ]]; then
                handle_tar_file "$temp_path" 2>/dev/null
            else
                # Directly search non-compressed files
                matched_content=$(unzip -p "$zip_file" "$filename" 2>/dev/null | grep -a "$ERROR_PATTERN" | grep -v "$SKIP_ERROR_PATTERN")
                process_matched_content "$matched_content" "$zip_file" "$filename" "$temp_path"
            fi
            rm -f "$temp_path"
        fi
    done
}

# Function to handle .tar files
handle_tar_file() {
    local tar_file="$1"
    local temp_dir=$(mktemp -d) # Create a temporary directory
    tar -xf "$tar_file" -C "$temp_dir" # Extract the .tar file to the temporary directory
    find "$temp_dir" -type f | while read file; do
    # Skip processing for fmNidd.json
    if [[ "$file" == *fmNidd.json || "$file" == *HWR.gz ]]; then
        # echo "Skipping log check for $file"
        continue
    fi
    if [[ "$file" == *.zip ]]; then
            # Handle nested zip files
            handle_zip_file "$file" 2>/dev/null
        elif [[ "$file" == *.gz ]]; then
            # Handle nested gz files
            matched_content=$(zgrep -a "$ERROR_PATTERN" "$file" | grep -v "$SKIP_ERROR_PATTERN")
            process_matched_content "$matched_content" "$tar_file" "$file" "$temp_dir"
        elif [[ "$file" == *.xz ]]; then
            # Handle nested .xz files
            matched_content=$(xzcat "$file" 2>/dev/null | grep -a "$ERROR_PATTERN" | grep -v "$SKIP_ERROR_PATTERN")
            process_matched_content "$matched_content" "$tar_file" "$file" "$temp_dir"
        elif [[ "$file" == *.tgz || "$file" == *.tar ]]; then
            handle_tar_file $file 2>/dev/null
        elif [[ "$file" == *.txt || "$file" == *.log ]]; then
            # Directly search non-compressed files
            matched_content=$(grep -a "$ERROR_PATTERN" "$file" | grep -v "$SKIP_ERROR_PATTERN")
            process_matched_content "$matched_content" "$tar_file" "$file" "$temp_dir"
        fi
    done
    rm -rf "$temp_dir" # Clean up the temporary directory
}


# Check if all arguments are provided
if [[ -z "$ZIP_FILE" || -z "$ERROR_PATTERN" || -z "$SKIP_ERROR_PATTERN" ]]; then
    echo "Usage: $0 <zip_file_path> <error_pattern> <skip_error_pattern>"
    exit 1
fi

# Start processing the initial compressed file
# Determine the file type and call the appropriate handler
if [[ "$ZIP_FILE" == *.zip ]]; then
    handle_zip_file "$ZIP_FILE"
elif [[ "$ZIP_FILE" == *.tgz ]]; then
    handle_tar_file "$ZIP_FILE"
else
    echo "Unsupported file type."
fi
