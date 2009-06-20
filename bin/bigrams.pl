#!/usr/bin/perl

# bigrams.pl - list bigrams from a text ordered by tscore

# Eric Lease Morgan <eric_morgan@infomotions.com>
# June 18, 2009 - first implementation
# June 19, 2009 - tweaked


# require
use lib '../lib';
use Lingua::EN::Bigram;
use Lingua::StopWords qw( getStopWords );
use strict;

# initialize
my $stopwords = &getStopWords( 'en' );
my $file      = $ARGV[ 0 ];
if ( ! $file ) {

	print "Usage: $0 <file>\n";
	exit;
	
}

# slurp
open F, $file or die "Can't open input: $!\n";
my $text = do { local $/; <F> };
close F;

# build bigrams
my $bigrams = Lingua::EN::Bigram->new;
$bigrams->text( $text );

# get counts
my $word_count   = $bigrams->word_count;
my $bigram_count = $bigrams->bigram_count;
my $tscore       = $bigrams->tscore;

# display, sans stop words and punctuation
my $stopwords = &getStopWords( 'en' );
foreach my $bigram ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	# get the tokens of the bigram
	my ( $first_token, $second_token ) = split / /, $bigram;
	
	# skip stopwords and punctuation
	next if ( $$stopwords{ $first_token } );
	next if ( $first_token =~ /[,.?!:;()\-]/ );
	next if ( $$stopwords{ $second_token } );
	next if ( $second_token =~ /[,.?!:;()\-]/ );
	
	# output
	print "$$tscore{ $bigram }\t"           . 
	      "$$word_count{ $first_token }\t"  . 
	      "$$word_count{ $second_token }\t" . 
	      "$$bigram_count{ $bigram }\t"     . 
	      "$bigram\t\n";

}
# done
exit;

