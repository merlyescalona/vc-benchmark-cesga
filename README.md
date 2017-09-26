# Sensitivity assessment of variant callers using in silico targeted-sequencing datasets

- Workspace triploid (UVigo):
    - Dataset generated om: `triploid.uvigo.es`
    - Under the user folder:
        - `/home/merly/research/cph-visit/vcs`

## Process overview

1. Simulation of targeted-sequencing data
    - use SimPhy to simulate species/gene trees
    - use NGSphy to simulate diploid individuals
    - use ART to simulate Illumina reads (within NGSphy)
2. Mapping
    - to a closely related reference (a random ingroup sequence)
    - to a more distant reference (outgroup sequence)
3. Variant calling
    - ANGSD
    - VarScan
    - GATK
    - Freebayes
    - Samtools/bcftools

## Simulation features

- Species trees features
    - Replicates:
        - Species tree replicates: 40.000 (considering the scenario a range, U:5:20My)
        - Number of gene trees/number of loci:  F: 5000
    - Species tree:
        - Tree-wide substitution rate: U:0.00000001,0.0000000001 (10-8 - 10-10)
        - Speciation rate (events/time unit): LN:-13.58,1.85
        - Number of taxa: U:10:50
        - Number of diploid individuals per species: 1-10 Uniform
        - Tree-wide effective population size: F:10.000
        - Species tree height (time unit):u: (5- 20 My)
        - Tree-wide generation time: F:1
        - Ratio between ingroup height and the branch from the root to the ingroup:  F:1
- Heterogeneity:
    - Genome-wide
        - Gene-by-lineage-specific parameter (Hyperparameter): LN:1.4,1
    - Specifics
        - Gene-by-lineage-specific locus tree parameter: LN:1.2,1
        - Gene-by-lineage-specific rate heterogeneity modifiers: F:GP
- Sequences
    - Length: 1.000 bp
- NGS
    - Coverage
        - Experiment: U:5-300 (variation)
        - locus: LN: 1.2,1
        - individual:  LN: 1.2,1
    - ART
        - Platform: Illumina
        - Reads type and size: 150 bp PE - 300  bp PE  Max. ART 250bp
        - Fragment size: mean=readsize * 2 - 50; sd=+/-50)
            - 215+-50
            - 375+-100
        - Profile:  default
        - 150 SE vs 150 PE vs 250 PE

# Notes
- Working on Cesga (ft2.cesga.es)
- Environment: SLURM

- Data will be stored under $LUSTRE
```
/mnt/lustre/scratch/home/uvi/be/mef/data
```
- Ouptut of the scripts will be stored under:  $STORE/output
```
/mnt/lustre/scratch/home/uvi/be/mef/output
```
- Error files of the scripts will be stored under:  $STORE/error
```
/mnt/lustre/scratch/home/uvi/be/mef/error
```
- Scripts  will be stored in FT2:
```
/home/uvi/be/mef/vc-benchmark-cesga
```
