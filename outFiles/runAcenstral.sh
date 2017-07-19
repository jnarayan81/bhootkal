#!/bin/bash

#Script location
scriptLoc=/home/jitendra/Desktop/testAncestralReco/scriptBase
inputLoc=/home/jitendra/Desktop/testAncestralReco/inputFile
#Alignment preparation.
#Make a multiple alignment, either with Mafft-L-INS-i or Clustal-Omega:
#mafft-linsi $inputLoc/TargetSequences_ALTAN.txt > TargetSequences_ALTAN.out.fasta

clustalo --in $inputLoc/TargetSequences_ALTAN.txt --out TargetSequences_ALTAN.out.fasta

#To view in jalview
#jalview TargetSequences_ALTAN.out.fasta

#The format of the resulting alignment is FASTA. However, most phylogenetic softwares use PHYLIP format. So, you have to convert it into PHYLIP.
python $scriptLoc/convert_fasta2phylip.py TargetSequences_ALTAN.out.fasta TargetSequences_ALTAN.out.phy

#generate a tree, either with PhyML (one of the most accurate tool) or FastTree (very fast and pretty accurate):
#FastTree -nosupport TargetSequences_ALTAN.out.phy > TargetSequences_ALTAN.out.tree
#NOTE: -nosupport:(we don't want boostrap, as this will cause trouble for further analyses in CodeML).

phyml -i TargetSequences_ALTAN.out.phy -d aa -m JTT -c 4 -a e -b 0

#-i = input file
#-d aa: amino acid sequences
#-m JTT: (substitution matrix). JTT works fine for most proteins, but other matrices (WAG, LG) can do slightly better.
#-c 4: (numbers of categories for the gamma distribution)
#-a e: (estimate alpha parameter for the gamma distribution) 
#-b 0: (we don't want boostrap, as this will cause trouble for further analyses in CodeML).

#Move the tree in a file
cp TargetSequences_ALTAN.out.phy_phyml_tree TargetSequences_ALTAN.out.tree

#View the tree in NJPlot
#njplot

#Create a control file for ancestral reconstruction "control_file.ctl" ### SEE ALL THE PARAMETERS THERE N CHANGE ACCORDINGLY ###
#Explanation of some parameters:
#runmode = 0 => We provide the tree.
#clock = 0 => We don't set a molecular clock. We assume that the genes are evolving at different rate.
#aaDist = 0 => We don't use the physicochemical properties of the amino acid.
#aaRatefile = ./jones.dat => We use the JTT matrix. Other matrix could be used (WAG, etc...)
#model = 2 => We use an empirical model (= substitutions matrix such as JTT).
#fix_alpha = 0 => We estimated the alpha parameter of the gamma distribution.
#alpha = 0.5 => We start the estimation from 0.5
#RateAncestor = 1 => Force the estimation of ancestral states.
#cleandata = 0 => Keep all ambigous data ("-", "X").

#You may have to copy the file "jones.dat" from the dat folder in the PAML package, or indicate its location.
#In BioLinux it is located at /usr/share/paml/dat/jones.dat
cp /usr/share/paml/dat/jones.dat .
codeml control_file_ALTAN.ctl

#CodeML will also write into many files, but only two are of interest here:
#TargetSequences_ALTAN.out.mlc => Contains many information on evolutionary rates.
#rst => Contains ancestral states for sites and for nodes.

#Extract the sequence in fasta format
python $scriptLoc/parse_rst.py rst > ancestral_sequences.fasta

#Compute physico-chemical properties on ancestral sequences.
python $scriptLoc/compute_pI.py $inputLoc/TargetSequences_ALTAN.txt
python $scriptLoc/compute_pI.py ancestral_sequences.fasta

#Map properties on tree.
python $scriptLoc/map_on_tree.py ancestral_sequences.fasta TargetSequences_ALTAN.out.tree >  TargetSequences_ALTAN.out_annotated_pI.tree 

mkdir outFiles
find . -maxdepth 1 \( ! -type d \) -exec sh -c 'mv  "$@" outFiles' _ {} \;

cp outFiles/*.ctl outFiles/*.sh .
