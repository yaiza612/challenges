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

The idea is use that information to look into specific associations the user may be interesting in and in the future implement also a function to plot that specific network using the miscore as a weight of the nodes of the graph. (Did not have time for this)

The good part of my program is the implementation throught objects, so in the future you can do the consult you want in your object over the protein or gene you are interesting in. 

UPDATE 10/11/2021 I commit this morning because I wanted to update the report with all the list of genes and depth of the recursion 1 but it just takes too long.

UPDATE 11/11/2021 I update the report with the list of genes of tiny txt and depth 1! Because with the whole list take too long, but the important part is that the recursion function works.

## Challenge 3