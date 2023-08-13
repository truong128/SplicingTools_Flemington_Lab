use warnings;
use strict; 
use File::Basename;  

my $retained_intron_directory;
my $annotation_file;
my $genome_fasta_file;
my $FDR;
my @RI_files;
my $program_path_name = dirname(__FILE__)."\/RISpliceSiteScoring.pl";

sub program_info {
    print "\n\tRISpliceSiteScoringBatch.pl will generate the following for all files in an input files directory:\n\t\t- lists of splice site scores (for plotting score distributions) for upstream donor and \n\t\t  downstream acceptor sites for statistically significantly changed retained intron events\n\t\t- summary file with average scores\n\n\tNote: Inclusion of annotation file is optional but will generate data for annotated events\n\tfor comparison.\n\n\tUsage: perl RISpliceSiteScoringBatch.pl [OPTIONS] -r <retained intron files directory (rMATS JCEC)> -g <genome fasta file> -f <FDR> -a <bed12 annotation file>\n\n\tRequired:\n\t\t-r <retained intron files directory>\n\t\t-g <genome fasta file>\n\t\t-f <FDR>\n\n\tAdditional:\n\t\t-a <bed12 annotation file> (optional)\n\t\t-h help\n\n\tExample: perl RISpliceSiteScoring.pl -r PATH/RI_input_files_directory -g PATH/genome.fa -a PATH/bed12_annotation.bed -f 0.05\n\n";
    exit;
}

sub options {
    if (scalar @ARGV == 0) {
        program_info;
        exit;
    }  
    for (my $i=0; $i < scalar @ARGV; $i++) {
        if ($ARGV[$i] eq "\-r") {
            $retained_intron_directory = $ARGV[$i+1];
        }
        elsif ($ARGV[$i] eq "\-a") {
            $annotation_file = $ARGV[$i+1];
        }
        elsif ($ARGV[$i] eq "\-g") {
            $genome_fasta_file = $ARGV[$i+1];
        }
        elsif ($ARGV[$i] eq "\-f") {
            $FDR = $ARGV[$i+1];
        }
        elsif ($ARGV[$i] eq "\-h") {
            program_info;
            exit;
        }
    }
}

sub qc {
    if (not defined($FDR)) {
        print "\nFDR not defined!\n";
        program_info;
        exit;
    }
    elsif ($FDR !~ m/^\d/) {
        print "\nFDR is not numeric!\n";
        program_info;
        exit;
    } 
    elsif (not defined($retained_intron_directory)) {
        print "\nRetained intron file directory not defined!\n";
        program_info;
        exit;
    }
    elsif (not defined($genome_fasta_file)) {
        print "\nGenome fasta file not defined!\n";
        program_info;
        exit;
    }
}

sub read_RI_file_dir {
    opendir my $input_dir, "$retained_intron_directory" or die "Can't open retained intron directory: $!";
    foreach my $g (sort readdir $input_dir) {
        next if ($g eq '.' || $g eq '..' || $g eq '.DS_Store');
        my $path_files = $retained_intron_directory."/".$g;
        push(@RI_files, $path_files);
    }
    closedir $input_dir;
}

sub run_program {
        if (scalar @RI_files == 0) {
        print "NO INPUT FILES IN DIRECTORY!!\n\n";
        program_info;
        exit;
    }
    else {
        foreach my $RI_file(@RI_files) {
            print "\t- Processing RI file: ", basename($RI_file), "\n";
            if (defined($annotation_file)) {
                `perl $program_path_name -r $RI_file -a $annotation_file -g $genome_fasta_file -f $FDR`;
            }
            else {
                `perl $program_path_name -r $RI_file -g $genome_fasta_file -f $FDR`;
            }
        }
    }
}
options;
qc;
read_RI_file_dir;
print "\n\n";
run_program;
print "\n";