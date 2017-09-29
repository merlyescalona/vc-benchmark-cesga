################################################################################
# Variables
################################################################################
pipelinesName="vcs"
MYRANDOMSEED=523911721 # echo "$RANDOM$RANDOM"
CLUSTERENV="slurm"
################################################################################
# PATHS
################################################################################
WD="$HOME/$pipelinesName"
folderJOBS="$HOME/vc-benchmark-cesga/jobs"
folderDATA="$LUSTRE/data"
folderOUTPUT="$LUSTRE/output"
folderERROR="$LUSTRE/error"
folderINFO="$LUSTRE/info"
fileJOBS="$folderINFO/jobs.sent.txt"
