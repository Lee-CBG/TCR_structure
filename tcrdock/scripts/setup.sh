#!/bin/bash
#SBATCH -J setup_batch
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH -p general
#SBATCH -q public
#SBATCH --time=0-2:00:00
#SBATCH -o slurm/slurm.%A_%a.out
#SBATCH -e slurm/slurm.%A_%a.err
#SBATCH --array=0-6			## adjust to number of paths in tsv_paths.txt
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=ggrama@asu.edu
#SBATCH --export=NONE

# === Config
INPUT_LIST="/home/ggrama/tcrgen/scripts/tsv_paths.txt"
LINES_PER_TASK=30

# === Load environment
module load mamba/latest
source activate /home/ggrama/.conda/envs/alphafoldtest

# === Calculate slice range
START_LINE=$((SLURM_ARRAY_TASK_ID * LINES_PER_TASK + 1))
END_LINE=$((START_LINE + LINES_PER_TASK - 1))

# === Extract lines for this task
TASK_LIST=$(sed -n "${START_LINE},${END_LINE}p" "$INPUT_LIST")

# === Run each in parallel
echo "$TASK_LIST" | parallel -j 4 --delay 0.1 '
    tsvfile={}
    target_name=$(basename "$tsvfile" .tsv)
    tsvdir=$(dirname "$tsvfile")
    output_dir="$tsvdir/../user_outputs/$target_name"
    targets_path="$output_dir/targets.tsv"

    if [ -f "$targets_path" ]; then
        echo "Skipping: $targets_path already exists"
        exit 0
    fi

    mkdir -p "$output_dir"
    echo "Running setup: $tsvfile → $output_dir"

    python /home/ggrama/tcrgen/TCRdock/setup_for_alphafold.py \
        --targets_tsvfile "$tsvfile" \
        --output_dir "$output_dir" \
        --new_docking
'

