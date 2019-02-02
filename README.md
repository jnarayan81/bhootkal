# bhootkal
Ancestral Gene/Protein Prediction

bhoot-kal (hindi:भूत-काल; english:preterite; french: le passé simple) is a pipeline to predict ancestral protein sequences. It serving to denote sequence level evolutionary events that took place or were completed in the past.

### Following pre-installed software and tools needs to be in your path
```
#-Python2 
#Perl5
#-clustalo -for mutiple alingments 
#-phyml
#-codeml
```

### Run
```
./bhootkal.sh
./bhootkal.sh -o outFolder -d /home/jitendra/Desktop/testAncestralReco/inFile -f TargetSequences.out.fasta -j /usr/share/paml/dat/jones.dat -c control_file.ctl

```

