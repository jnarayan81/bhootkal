#!/bin/bash

# Predict ancestral gene/protein # Author: Jitendra Narayan
# USAGE: ./bhootkal.sh

# Following pre-installed software and tools need to be in yout path
#-Python2 #Perl5
#-clustalo -for mutiple alingments 
#-phyml
#-codeml

#Perl and Python script location
#inFile should contain all fasta sequences
#scriptLoc=/home/jitendra/Desktop/testAncestralReco/scriptBase
#inputLoc=/home/jitendra/Desktop/testAncestralReco/inFile

# location to getopts.sh file
source scriptBase/getopt.sh
USAGE="-o OUT -d DIR -f FASTA -c CTRL -j JONES[ -a START_DATE_TIME ]"
parse_options "${USAGE}" ${@}

#Sequence alignment preparation.
#Make a multiple alignment, either with Mafft-L-INS-i or Clustal-Omega:
#You can opt any other you like, but keep an eye on formating
#mafft-linsi ${DIR}/${FASTA} > TargetSequences.out.fasta

#Remove the directory if it's present, otherwise do nothing.
rm -rf ${OUT} ?

#remove special charater from file
#mostly needed when you have your own formated sequences
sed 's,|,_,g' -i ${DIR}/${FASTA} #fasta #header #sed

#Multiple alignment of all sequences
#Here I prefer clastal omega for alingments - because it is installed by default in my Os
clustalo --in ${DIR}/${FASTA} --out TargetSequences.out.fasta

#It is always recommended to check by eye, To view the alignments in jalview
#jalview TargetSequences.out.fasta

#Formating is a mess, why not one format. We need to format the out file for next run.
#The format of the resulting alignment is FASTA. However, most phylogenetic softwares use PHYLIP format. So, you have to convert it into PHYLIP format.
#Script adapted from online source @
python scriptBase/convert_fasta2phylip.py TargetSequences.out.fasta TargetSequences.out.phy

#As I say, it is upto you to choose
#generate a tree, either with PhyML (one of the most accurate tool) or FastTree (very fast and pretty accurate):
#FastTree -nosupport TargetSequences.out.phy > TargetSequences.out.tree
#NOTE: -nosupport:(we don't want boostrap, as this will cause trouble for further analyses in CodeML).

#Try running phyml -h for all the options

phyml -i TargetSequences.out.phy -d aa -m JTT -c 4 -a e -b 0

#-i = input file
#-d aa: amino acid sequences
#-m JTT: (substitution matrix). JTT works fine for most proteins, but other matrices (WAG, LG) can do slightly better.
#-c 4: (numbers of categories for the gamma distribution)
#-a e: (estimate alpha parameter for the gamma distribution) 
#-b 0: (we don't want boostrap, as this will cause trouble for further analyses in CodeML).

#DNA interleaved sequence file, default parameters :   ./phyml -i seqs1
#AA interleaved sequence file, default parameters :    ./phyml -i seqs2 -d aa
#AA sequential sequence file, with customization :     ./phyml -i seqs3 -q -d aa -m JTT -c 4 -a e


#Move the tree in a file
cp TargetSequences.out.phy_phyml_tree TargetSequences.out.tree

#Visual confirm the tree
#View the tree in NJPlot
#njplot

#Create a control file for ancestral reconstruction "${CTRL}" ### SEE ALL THE PARAMETERS THERE N CHANGE ACCORDINGLY ###
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
cp ${JONES} .
codeml ${CTRL}

#Read more at https://petrov.stanford.edu/software/src/paml3.15/doc/pamlDOC.pdf
#CodeML will also write into many files, but only two are of interest here:
#TargetSequences.out.mlc => Contains many information on evolutionary rates.
#rst => Contains ancestral states for sites and for nodes.

#Extract the sequence in fasta format
python scriptBase/parse_rst.py rst > ancestral_sequences.fasta

#Compute physico-chemical properties on ancestral sequences.
#python scriptBase/compute_pI.py ${DIR}/${FASTA}
#python scriptBase/compute_pI.py ancestral_sequences.fasta

#Map properties on tree.
#python scriptBase/map_on_tree.py ancestral_sequences.fasta TargetSequences.out.tree >  TargetSequences.out_annotated_pI.tree

mkdir ${OUT}
#find . -maxdepth 1 \( ! -type d \) -exec sh -c 'mv "$@"' OUT} _ {} \;

for file in *; do
   if ! [ -d "$file" ]; then
     mv -- "$file" "${OUT}"/
   fi
done

cp ${OUT}/*.ctl ${OUT}/*.sh .


#You can estimating the stability effect of a mutation with FoldX
