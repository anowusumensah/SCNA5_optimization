#!/bin/bash -l
#
#SBATCH -N 1
#SBATCH -c 40
#SBATCH -J X_PSO_WT_12347
#SBATCH -o %x.out%j
#SBATCH --mail-type=ALL
#SBATCH --mail-user=carp.simulation@gmail.com


#
# A sample MATLAB job on Turing or Wahab

enable_lmod
# Load the Matlab Module
module load container_env matlab/R2022a



# Run Matlab
crun.matlab matlab -nodisplay -nodesktop -r "Run_Zheng_Score_PSO_WT_12347_New, exit"
