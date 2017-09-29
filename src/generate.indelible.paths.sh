source $HOME/vc-benchmark-cesga/src/vcs.variables.sh

for item in $(find $LUSTRE/data -maxdepth 1 -type d | tail -n+2); do
    echo $item > $HOME/vc-benchmark-cesga/files/${pipelinesName}.3.indelible.folders.txt
done
