#!/bin/bash
#SBATCH --job-name=alphafold3_array
#SBATCH --output=logs/alphafold3_%A_%a.out
#SBATCH --error=logs/alphafold3_%A_%a.err
#SBATCH --array=1-2500		### number of JSONs
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --partition=htc
#SBATCH --qos=public
#SBATCH --gres=gpu:1
#SBATCH --time=1:00:00
#SBATCH --export=NONE

# Load CUDA
module load cuda-12.6.1-gcc-12.1.0

# Paths
SIMG=/packages/apps/simg/alphafold-3.0.0.sif
AF3_INPUT_DIR=
AF3_OUTPUT_DIR=
MODEL_DIR=		# heewook has them at /mnt/disk06/user/hlee314/alphafold3/af3.bin.zs
DB_DIR=			# follow database set up from deepminds git, takes about 40 mins

mkdir -p $AF3_OUTPUT_DIR/logs

# Select JSON for this array task
INPUT_JSON=$(ls $AF3_INPUT_DIR/*.json | sed -n "${SLURM_ARRAY_TASK_ID}p")
if [ -z "$INPUT_JSON" ]; then
    echo "No JSON file found for SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
    exit 1
fi

echo "Running AlphaFold 3 on $INPUT_JSON"

# Run AlphaFold 3 inside Apptainer
exec /usr/bin/apptainer exec --nv \
    -B /scratch/$USER:/scratch/$USER \
    $SIMG \
    /bin/bash -c "
        python /app/alphafold/run_alphafold.py \
            --json_path=$INPUT_JSON \
            --model_dir=$MODEL_DIR \
            --db_dir=$DB_DIR \
            --output_dir=$AF3_OUTPUT_DIR
    "

