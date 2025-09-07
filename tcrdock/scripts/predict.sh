#!/bin/bash
#SBATCH --job-name=predict_array
#SBATCH --output=slurm/%x_%A_%a.out
#SBATCH --error=slurm/%x_%A_%a.err
#SBATCH --array=0-160        # ← Adjust this to match number of predictions
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --partition=general
#SBATCH --qos=public
#SBATCH --gres=gpu:a100:1
#SBATCH --time=0:05:00
#SBATCH --mail-type=START,FAIL,END
#SBATCH --mail-user="ggrama@asu.edu"
#SBATCH --export=NONE

# === Load modules and activate conda env
module load mamba/latest
module load cuda-12.4.1-gcc-12.1.0
source activate /home/ggrama/.conda/envs/alphafold

# === Set environment variables ===
export XLA_PYTHON_CLIENT_PREALLOCATE=false
export TF_FORCE_GPU_ALLOW_GROWTH=true
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib

# === Get the line matching this array task
INPUT_LIST="/home/ggrama/tcrgen/scripts/targets_paths.txt"
TARGET_FILE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$INPUT_LIST")

# === Skip empty or missing lines
if [[ -z "$TARGET_FILE" ]] || [[ ! -f "$TARGET_FILE" ]]; then
    echo " No target found for task ID $SLURM_ARRAY_TASK_ID"
    exit 1
fi

# === Prepare output dir
BASENAME=$(basename "$(dirname "$TARGET_FILE")")
PARENT_DIR=$(dirname "$TARGET_FILE")
PRED_DIR="${PARENT_DIR/user_outputs/predictions}"
mkdir -p "$PRED_DIR"

# === Run prediction
echo ">>> Running prediction for: $BASENAME"
python /home/ggrama/tcrgen/TCRdock/run_prediction.py \
    --targets "$TARGET_FILE" \
    --outfile_prefix "$PRED_DIR/${BASENAME}_run" \
    --model_names model_2_ptm \
    --data_dir "/scratch/ggrama/download"
