################################################################################
# Variables
################################################################################
pipelinesName="vcs"
MYRANDOMSEED=523911721 # echo "$RANDOM$RANDOM"
CLUSTERENV="sge"
################################################################################
# PATHS
################################################################################
WD="$HOME/$pipelinesName"
folderJOBS="$HOME/vc-benchmark-cesga/jobs"
folderDATA="$WD/data"
folderOUTPUT="$WD/output"
folderERROR="$WD/error"
folderINFO="$WD/info"
fileJOBS="$folderINFO/jobs.sent.txt"
