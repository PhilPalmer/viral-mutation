
/usr/local/bin/mafft \
    --thread 40 --auto --inputorder \
    data/influenza/ird_influenzaA_HA_allspecies.fa \
    > target/flu/clusters/all.fasta

/usr/local/bin/mafft \
    --thread 40 --auto --inputorder \
    data/hiv/HIV-1_env_samelen.fa \
    > target/hiv/clusters/all.fasta

python bin/benchmark_subset.py

##########################
## Potts (Louie et al.) ##
##########################

cd MPF-BML/
matlab -r "fasta_name = '../target/flu/clusters/all_h1.fasta'; mut_name = '../target/flu/mutation/mutations_h1.fa'; main_MPF_BML(fasta_name, mut_name)"
matlab -r "fasta_name = '../target/flu/clusters/all_h3.fasta'; mut_name = '../target/flu/mutation/mutations_h3.fa'; main_MPF_BML(fasta_name, mut_name)"
matlab -r "fasta_name = '../target/hiv/clusters/all_BG505.fasta'; mut_name = '../target/hiv/mutation/mutations_hiv.fa'; main_MPF_BML(fasta_name, mut_name)"
cd ..

######################
## TAPE Transformer ##
######################

sed 's/-//g' target/flu/mutation/mutations_h1.fa > \
    target/flu/mutation/mutations_clean_h1.fasta
sed 's/-//g' target/flu/mutation/mutations_h3.fa > \
    target/flu/mutation/mutations_clean_h3.fasta
sed 's/-//g' target/hiv/mutation/mutations_hiv.fa > \
    target/hiv/mutation/mutations_clean_hiv.fasta

tape-embed transformer \
           target/flu/mutation/mutations_clean_h1.fasta \
           target/flu/embedding/tape_transformer_h1.npz \
           bert-base \
           --tokenizer iupac \
           --batch_size 256
tape-embed transformer \
           target/flu/mutation/mutations_clean_h3.fasta \
           target/flu/embedding/tape_transformer_h3.npz \
           bert-base \
           --tokenizer iupac \
           --batch_size 256
tape-embed transformer \
           target/hiv/mutation/mutations_clean_hiv.fasta \
           target/hiv/embedding/tape_transformer_hiv.npz \
           bert-base \
           --tokenizer iupac \
           --batch_size 128

tape-embed unirep \
           target/flu/mutation/mutations_clean_h1.fasta \
           target/flu/embedding/unirep_h1.npz \
           babbler-1900 \
           --tokenizer unirep \
           --batch_size 256
tape-embed unirep \
           target/flu/mutation/mutations_clean_h3.fasta \
           target/flu/embedding/unirep_h3.npz \
           babbler-1900 \
           --tokenizer unirep \
           --batch_size 256
tape-embed unirep \
           target/hiv/mutation/mutations_clean_hiv.fasta \
           target/hiv/embedding/unirep_hiv.npz \
           babbler-1900 \
           --tokenizer unirep \
           --batch_size 128

########################
## Final calculations ##
########################

declare -a methods=("bepler" "energy" "ecouple" "freq" "tape" "unirep")
declare -a viruses=("h1" "h3" "hiv")

for method in ${methods[@]}
do
    for virus in ${viruses[@]}
    do
        python bin/escape_energy.py method virus
    done
done