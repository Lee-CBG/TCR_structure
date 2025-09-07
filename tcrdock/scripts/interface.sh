#!/bin/bash
#SBATCH --job-name=interface_array
#SBATCH --array=0-1
#SBATCH --output=slurm/%x_%A_%a.out
#SBATCH --error=slurm/%x_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --partition=general
#SBATCH --qos=public
#SBATCH --time=0:10:00
#SBATCH --mail-type=START,FAIL,END
#SBATCH --mail-user="ggrama@asu.edu"
#SBATCH --export=NONE

# === Rosetta env ===
export ROSETTA_BIN=/scratch/ggrama/rosetta/rosetta.source.release-371/main/source/bin
export PATH=$ROSETTA_BIN:$PATH

# === Input list: full paths to relaxed PDBs ===
INPUT_LIST="/home/ggrama/tcrgen/scripts/relabeled_paths.txt"

# === Get PDB for this array index ===
PDB=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$INPUT_LIST")
BASE=$(basename "$PDB" .pdb)

# === Derive stage directory (e.g., scp-select)
PRED_DIR=$(dirname "$PDB")                                 # .../relaxed
STAGE_DIR=$(dirname "$PRED_DIR")                           # .../scp-select
SCORES_DIR="${STAGE_DIR}/interface_scores"
LOGS_DIR="${STAGE_DIR}/interface_logs"

mkdir -p "$SCORES_DIR" "$LOGS_DIR"

# === Output paths ===
SCORE_OUT="${SCORES_DIR}/${BASE}_scores.sc"
LOG_OUT="${LOGS_DIR}/${BASE}.log"

# === Skip if already scored ===
if [[ -f "$SCORE_OUT" ]]; then
    echo "✅ Already scored: $BASE"
    exit 0
fi

# === Run InterfaceAnalyzer ===
echo "⏳ Running InterfaceAnalyzer on $BASE"
"$ROSETTA_BIN/InterfaceAnalyzer.linuxgccrelease" \
    -s "$PDB" \
    -interface A_B \
    -ignore_unrecognized_res \
    -pack_separated \
    -nstruct 1 \
    -out:file:scorefile "$SCORE_OUT" \
    -out:path:all "$SCORES_DIR" \
    -out:file:score_only true \
    > "$LOG_OUT" 2>&1

