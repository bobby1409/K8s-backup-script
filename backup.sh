#!/bin/bash
date=`date +%Y%m%d-%H%M`
dir="<<path of backup file>>"
logfile="/var/log/backup/log-$date.txt"
touch $logfile
##Replace with the specified namespace
namespace=apollo
set +x
declare -a arr=("configmap" "deployment" "ingress" "secret" "service")

if [[ ! -e $dir/$namespace-$date ]]; then
    mkdir $dir/$namespace-$date
elif [[ ! -d $dir/$namespace-$date ]]; then
    echo "$namespace Namespace already exists but is not a directory"
fi
## now loop through the above array
echo "-----$(date) Starting Backup" >> $logfile
for i in "${arr[@]}"

do
        ##Create new folder for backup
   if [[ ! -e $dir/$namespace-$date/$i ]]; then
    mkdir $dir/$namespace-$date/$i
   elif [[ ! -d $dir/$namespace-$date/$i ]]; then
    echo "$namespace/$i already exists but is not a directory"
   fi

   echo "$i"

##Run the main backup
   for t in $(/usr/local/bin/kubectl get $i --kubeconfig="<<path of kubeconfig>>" -n $namespace | awk '{print $1}' | tail -n +2)
   do
    echo "Running backup for: $namespace - $i - $t" | tee -a >> $logfile
    /usr/local/bin/kubectl get $i --kubeconfig="<<path of kubeconfig>>" -n $namespace $t -o yaml > $dir/$namespace-$date/$i/$t.yaml
   done
   # or do whatever with individual element of the array
done
echo "-----$(date) Backup Completed" >> $logfile
set -x