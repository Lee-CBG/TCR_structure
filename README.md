# TCRGen Structural Analysis
Pipeline for modeling and evaluating T-cell receptor (TCR) CDR3β loop structures from generated sequences, using a modified TCRDock and AlphaFold pipeline.

## Compile experimentally solved structures
Access TCR3d Database for pMHC–TCR complex structures associated with your epitope(s).  
From each PDB entry, extract:
- Peptide
- CDR3α and CDR3β (available under the “structures” dropdown: alpha and beta fields)

Run [ANARCI](https://opig.stats.ox.ac.uk/webapps/sabdab-sabpred/sabpred/anarci/) (with --ig_seqtype TCR) on α and β chains to determine V and J gene usage.

Write metadata to a .csv file with the following required fields:

`{'Peptide', 'TRAV', 'TRAJ', 'CDR3α', 'TRBV', 'TRBJ', 'CDR3β', 'PDB ID'}`

### Determine fidelity of TCRDock predictions
Prior to sequence alignment, compare relaxed predicted structures to the solved experimental ones using Cα RMSD.  
Filter out predictions with an RMSD greater than 2 Å to retain only high-confidence models. (see rmsd.ipynb)  

## Alphafold env
Run alphafold_env.yaml (based on Alphafold and TCRDock requirements), tensorflow-cpu had a tendency to silently upgrade and cause dependancy conflicts so ensure that you are running 2.12.0.   
  
After activating, run:  
`python download_blast.py`  
  
^ found in TCRdock dir in this repo, ensure you clone because I modified some of the scripts to handle nonsense controls/negative samples downstream. 
Pengfei should have access to my /scratch/ggrama/download directory with the correct alphafold docker files used in predict.sh, if not, follow step 1-3 in [alphafold/docker](https://github.com/google-deepmind/alphafold/blob/main/README.md). 

## Rosetta Applications
Rosetta Relax and Interface Analyzer can be downloaded [here](https://rosettacommons.org/software/download/) as a non-commerical user (version 3.14). 
Required binaries:
`relax.linuxgccrelease`
`InterfaceAnalyzer.linuxgccrelease`

## Generated sequences
After determining replicable IDs, follow workflow in rmsd.ipynb  
Additional analysis pipelines can be found in interface_analysis.ipynb

## Visualizations
interface_analysis.ipynb will output potential bonds within each CDR3β:epitope pair, visualizations can be produced using ChimeraX and the indicicies of both the peptide and CDR3β using the following commands (use relabeled .pdbs):  
`select /A:(peptide indicies) | /B:(CDR3β indicies)`  
`hbonds /A:376-384 restrict /B:986-998 reveal true showDist true`  

  ![Candidate sequence identified using workflow in interface_analysis.ipynb, visualized using commands above.](images/gen5_scp-chain_105_H_bond.png)
