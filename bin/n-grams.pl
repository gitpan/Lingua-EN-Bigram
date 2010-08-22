#!/usr/bin/perl

# n-grams.pl - list top 10 bi-grams from a text ordered by tscore, and
#              list top 10 tri-grams and 4-grams ordered by number of occurances

# Eric Lease Morgan <eric_morgan@infomotions.com>
# June   18, 2009 - first implementation
# June   19, 2009 - tweaked
# August 22, 2009 - added tri-grams and 4-grams


# require
use lib '../lib';
use Lingua::EN::Bigram;
use Lingua::StopWords qw( getStopWords );
use strict;

# initialize
my $stopwords = &getStopWords( 'en' );

# sanity check
my $file = $ARGV[ 0 ];
if ( ! $file ) {

	print "Usage: $0 <file>\n";
	exit;
	
}

# slurp
open F, $file or die "Can't open input: $!\n";
my $text = do { local $/; <F> };
close F;

# build n-grams
my $ngrams = Lingua::EN::Bigram->new;
$ngrams->text( $text );

# get bi-gram counts
my $bigram_count = $ngrams->bigram_count;
my $tscore       = $ngrams->tscore;

# display top ten bi-grams, sans stop words and punctuation
my $index = 0;
print "Bi-grams (T-Score, count, bi-gram)\n";
foreach my $bigram ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	# get the tokens of the bigram
	my ( $first_token, $second_token ) = split / /, $bigram;
	
	# skip stopwords and punctuation
	next if ( $$stopwords{ $first_token } );
	next if ( $first_token =~ /[,.?!:;()\-]/ );
	next if ( $$stopwords{ $second_token } );
	next if ( $second_token =~ /[,.?!:;()\-]/ );
	
	# increment
	$index++;
	last if ( $index > 10 );

	# output
	print "$$tscore{ $bigram }\t"           . 
	      "$$bigram_count{ $bigram }\t"     . 
	      "$bigram\t\n";

}
print "\n";

# get tri-gram counts
my $trigram_count = $ngrams->trigram_count;

# process the first top 10 tri-grams
$index = 0;
print "Tri-grams (count, tri-gram)\n";
foreach my $trigram ( sort { $$trigram_count{ $b } <=> $$trigram_count{ $a } } keys %$trigram_count ) {

	# get the tokens of the bigram
	my ( $first_token, $second_token, $third_token ) = split / /, $trigram;
	
	# skip punctuation
	next if ( $first_token  =~ /[,.?!:;()\-]/ );
	next if ( $second_token =~ /[,.?!:;()\-]/ );
	next if ( $third_token  =~ /[,.?!:;()\-]/ );

	# skip stopwords; results are often more interesting if these are commented out
	#next if ( $$stopwords{ $first_token } );
	#next if ( $$stopwords{ $second_token } );
	#next if ( $$stopwords{ $third_token } );
	
	# increment
	$index++;
	last if ( $index > 10 );
	
	# echo
	print $$trigram_count{ $trigram }, "\t$trigram\n";
	
}
print "\n";

# get quad-gram counts
my $quadgram_count = $ngrams->quadgram_count;

# process the first top 10 tri-grams
$index = 0;
print "Quad-grams (count, quad-gram)\n";
foreach my $quadgram ( sort { $$quadgram_count{ $b } <=> $$quadgram_count{ $a } } keys %$quadgram_count ) {

	# get the tokens of the bigram
	my ( $first_token, $second_token, $third_token, $fourth_token ) = split / /, $quadgram;
	
	# skip punctuation
	next if ( $first_token  =~ /[,.?!:;()\-]/ );
	next if ( $second_token =~ /[,.?!:;()\-]/ );
	next if ( $third_token  =~ /[,.?!:;()\-]/ );
	next if ( $fourth_token =~ /[,.?!:;()\-]/ );

	# skip stopwords; results are often more interesting if these are commented out
	#next if ( $$stopwords{ $first_token } );
	#next if ( $$stopwords{ $second_token } );
	#next if ( $$stopwords{ $third_token } );
	#next if ( $$stopwords{ $fourth_token } );
	
	# increment
	$index++;
	last if ( $index > 10 );
	
	# echo
	print $$quadgram_count{ $quadgram }, "\t$quadgram\n";
	
}
print "\n";

# done
exit;

