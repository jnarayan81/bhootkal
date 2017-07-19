#!/bin/bash

#self BLAST a genome -- Expecting you have blast and samtools installed in your system
#Author: Jitendra Narayan
#USAGE: ./seqSearch.sh

#Common settings
scriptBase=/home/jitendra/Desktop/testAncestralReco/scriptBase
FASTAFILE=uniprot-taxonomyAmammalia.fasta
MYDB=myDB
OUTFILE=seeMatchingHits
THREAD=7
SEQ=mySeq.fa

echo "User $USER provided $# arguments, Detail of the arguments: $@"

if [ -f $MYDB.nhr ]
then
  echo "BLAST database for FASTAFILE genome exists"
else
  echo "Thanks for testing this script $USER; Me creating creating blastDB named $MYDB for you";
  makeblastdb -in $FASTAFILE -parse_seqids -dbtype prot -out $MYDB
fi

#if [ $1 = "extract" ]
#then
#  echo "Extracting the sequence $2 for you from $FASTAFILE -- MAKE SURE U HAVE ADDED CORRECT NAME"
#  samtools faidx MergedContigs.fasta
#  samtools faidx MergedContigs.fasta $2 > $2.fa
#  SEQ=$2.fa
#elif [ $1 = "all" ]
#then
#  echo "You want entire sequence to blast"
#  SEQ=$FASTAFILE
#else
#  echo "Something went wrong $USER - Contact jitendra"
#fi

echo "Doing alignments -- BLASting";
#blastp -query $SEQ -db $MYDB -evalue 1e-5 -num_threads $THREAD -max_target_seqs 10 -outfmt '6 qseqid staxid qstart qend sseqid sstart send evalue length frames qcovs' -out $OUTFILE;
blastp -query $SEQ -db $MYDB -evalue 1e-5 -num_threads $THREAD -outfmt '6 qseqid staxid qstart qend sseqid sstart send evalue length frames qcovs' -out $OUTFILE;

echo "Extracting the hits"
#awk -F '\t' '{print $4}' $OUTFILE > idList
perl $scriptBase/extractFasta.pl $OUTFILE $FASTAFILE finalSeq.fa 90 #90 is coverage filter

#mkdir blastResults
#find . -maxdepth 1 \( ! -type d \) -exec sh -c 'mv  "$@" blastResults' _ {} \;

echo "DONE successfully :)"


