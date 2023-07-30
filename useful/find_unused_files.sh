#!/bin/bash

# Set the EFS mount point
efs_mount="/path/to/efs/mount/point"

# Set the threshold date (30 days ago from the current date)
threshold_date=$(date -d "30 days ago" +%s)

# Function to check if the file has not been accessed within the last 30 days
function is_unused_file() {
    file_path="$1"
    last_accessed=$(stat -c %X "$file_path")
    if [ "$last_accessed" -lt "$threshold_date" ]; then
        return 0  # True (file is not used in the last 30 days)
    else
        return 1  # False (file is used within the last 30 days)
    fi
}

# Ensure the EFS mount point is accessible
if [ ! -d "$efs_mount" ]; then
    echo "Error: EFS mount point not found or not accessible."
    exit 1
fi

# Scan the EFS mount for unused files
echo "Scanning EFS for unused files (not accessed in the last 30 days)..."
while IFS= read -r -d '' file; do
    if is_unused_file "$file"; then
        echo "Unused file: $file"
    fi
done < <(find "$efs_mount" -type f -print0)

echo "Scan completed."
