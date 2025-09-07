#!/bin/bash
#SBATCH -J relax_array
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=16G
#SBATCH --time=00:15:00
#SBATCH -p general
#SBATCH -q public
#SBATCH -o slurm/slurm.%A_%a.out
#SBATCH -e slurm/slurm.%A_%a.err
#SBATCH --array=0-200
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=ggrama@asu.edu

export ROSETTA_BIN=/scratch/ggrama/rosetta/rosetta.source.release-371/main/source/bin
export PATH=$ROSETTA_BIN:$PATH

INPUT_LIST="/home/ggrama/tcrgen/scripts/pdb_paths.txt"

# === Grab the PDB for this array task ===
PDB=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$INPUT_LIST")
BASE=$(basename "$PDB" .pdb)

# Fix: correctly derive the stage directory (e.g., scp-select)
PRED_DIR=$(dirname "$PDB")                                 # .../predictions/user_targets_*
STAGE_DIR=$(dirname "$(dirname "$PRED_DIR")")              # .../scp-select
RELAX_DIR="${STAGE_DIR}/relaxed"

mkdir -p "$RELAX_DIR"

"$ROSETTA_BIN/relax.linuxgccrelease" \
    -s "$PDB" \
    -relax:default_repeats 5 \
    -nstruct 1 \
    -out:suffix _relaxed \
    -out:path:all "$RELAX_DIR" \
    > "$RELAX_DIR/${BASE}_relax.log" 2>&1
