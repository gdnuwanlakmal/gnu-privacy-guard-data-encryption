#!/bin/bash

# ====== CONFIGURATION ======
TARGET_DIR="/data/backups"           # Path to your files
RECIPIENT="recipient@example.com"    # Public key email or key ID
MAX_KEEP=9                           # How many latest encrypted files to keep
LOG_FILE="/var/log/gpg_encrypt_sql.log"
# ===========================

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Target directory $TARGET_DIR does not exist." | tee -a "$LOG_FILE"
    exit 1
fi

echo "=== Starting SQL encryption at $(date) ===" | tee -a "$LOG_FILE"

# Step 1: Encrypt and remove originals
find "$TARGET_DIR" -type f -name "*.sql" | while read -r file; do
    echo "Encrypting: $file" | tee -a "$LOG_FILE"
    if gpg --yes --batch --encrypt --recipient "$RECIPIENT" "$file"; then
        rm -f "$file"
        echo "✅ Encrypted and removed: $file" | tee -a "$LOG_FILE"
    else
        echo "❌ Failed to encrypt: $file" | tee -a "$LOG_FILE"
    fi
done

# Step 2: Keep only the newest $MAX_KEEP encrypted files
echo "Pruning old SQL encrypted files, keeping only $MAX_KEEP..." | tee -a "$LOG_FILE"
mapfile -t ENCRYPTED_FILES < <(find "$TARGET_DIR" -type f -name "*.sql.gpg" -printf "%T@ %p\n" | sort -nr | awk '{print $2}')

COUNT=0
for encfile in "${ENCRYPTED_FILES[@]}"; do
    COUNT=$((COUNT+1))
    if [ "$COUNT" -gt "$MAX_KEEP" ]; then
        rm -f "$encfile"
        echo "🗑️ Deleted old encrypted file: $encfile" | tee -a "$LOG_FILE"
    fi
done

echo "=== SQL encryption completed at $(date) ===" | tee -a "$LOG_FILE"
