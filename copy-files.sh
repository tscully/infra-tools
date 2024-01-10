gcloud compute scp install-cp.sh control-plane:/var/tmp
gcloud compute scp kube-ps1.sh control-plane:/var/tmp
gcloud compute scp install-worker.sh  worker-node1:/var/tmp
gcloud compute scp install-worker.sh  worker-node2:/var/tmp
