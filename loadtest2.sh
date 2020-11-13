#!/bin/bash

if [ "x$DBBENCH_USER" == "x" ]
then
	DBBENCH_USER=root
fi

if [ "x$DBBENCH_PASSWD" == "x" ]
then
	DBBENCH_PASSWD=root
fi

it=100000
sl=100ms
th=30

VERSION=1.0.1

while getopts ":i:s:t:v:" opt
do
  case ${opt} in
    i ) # process option i
	it=$OPTARG
      ;;
    s ) # process option s
	sl=$OPTARG
      ;;
    t ) # process option t
	th=$OPTARG
      ;;
    v ) # process option v
	echo "$0 Version $VERSION"
	exit 0
      ;;
    \? ) echo "Usage: $0 [-i <iterationcount:100000>] [-s <sleeptime:100ms>] [-t <parallelthreadcount:30>] [-v]"
	echo " [optional <must be provided if flag is used:default if flag is not used>]"
	echo " This script runs all benchmarks in the scripts directory that match 'cockroach*.sql'"
	echo " NOTE: you must set the DBBENCH_USER and DBBENCH_PASSWD environment variables"
	exit 1
      ;;
  esac
done

# comment out these 4 lines if you want to use port forwarding
echo "Setting up single node for testing $( date )"
docker run --name dbbench-cockroach -d -p 26257:26257 -p 8080:8080 cockroachdb/cockroach:latest start --insecure
echo "Waiting for Docker to be available $( date )"
sleep 1

export PATH=.:$PATH

for sc in $( ls scripts/cockroach_bench2.sql )
do
  echo "Running dbbench $sc $( date )"
  dbbench cockroach --noinit --noclean --iter $it --script $sc --sleep $sl --threads $th --user $DBBENCH_USER --pass $DBBENCH_PASSWD
  echo "
======================================================================
"
done

# comment out these 3 lines if you want to use port forwarding
echo "Shutting down CRDB $( date )"
docker stop dbbench-cockroach
docker rm dbbench-cockroach

echo "dbbench complete $( date )"
