# Challenges

## Challenge 1
Gems required: 

CSV and date 

``gem install CSV``

To run the program: 

``ruby main.rb genefile stockfile crossfile newfile``

I follow the explanation of the solution saw in class to do the exercise

## Challenge 2

Gems required:

mitab

``gem install mitab``


Important the program need the objects of the challenge 1.

To run the program: 

``ruby main.rb genefile ``

With this program the object Interaction_network is created recursively with the depth you want, and every object contain the whole list of genes object of the network (so you can check if you want the gene_id, gene_name, the go annotations, the Kegg annotations), the whole list of protein objects of the network that contain: 

- gene_id -> corresponding with the gene object of that protein
- uniprot id
- intact id
- links -> contain an array of hashes, every hash contains the protein id of the interactors of that protein and the information of that interaction (type of interaction, pubmed id, miscore...)


The report generated include all the genes that are interacting, however if they are the target of the interaction and not the source I decide don't write the interactions and only write it when they are the source (to reduce size of the file). The interactions retrieved appear with all the information to help the user to research later on in case be interested in one interaction in particular. The report also indicate the depth of every interaction.


The good part of my program is the implementation throught objects, so in the future you can do the consult you want in your object over the protein or gene you are interesting in. 
The idea is use that information to look into specific associations the user may be interesting in and in the future implement also a function to plot that specific network using the miscore as a weight of the nodes of the graph. 





## Challenge 3
Gems required: 

CSV and date 

``gem install CSV``

To run the program: 

``ruby main.rb genefile ``

## Challenge 4 

The orthologues are found using the best reciprocal hits technique. I follow the indications of the paper: https://doi.org/10.1093/bioinformatics/btm585
Where you can find:
  # Based on our results, the recommended parameters for the best detection of orthologs as reciprocal best hits
  # is the combination of soft filtering with a Smith–Waterman final alignment (the -F “m S” -s T options in NCBI's BLASTP).
  # These options resulted in both the highest number of orthologs and the minimal error rates.
  # However, most of the improvement can be achieved using soft filtering (-F “m S”) alone.
They prove that this is the best way to detect the orthologues. 

Nevertheless, to prove that are true orthologues, some complementaries analysis are necessary. After the best reciprocal hits technique, the best practices is do phylogenetic tree analyses of sequences in both species.

To run the program:

``ruby main.rb fasta_file fasta_file``
