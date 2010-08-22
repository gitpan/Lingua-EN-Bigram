package Lingua::EN::Bigram;

# Bigram.pm - Calculate two-, three-, and four-word phrases based on frequency and/or T-Score

# Eric Lease Morgan <eric_morgan@infomotions.com>
# June   18, 2009 - first investigations
# June   19, 2009 - "finished" POD
# August 22, 2010 - added trigrams and quadgrams; can I say "n-grams"?


# include
use strict;
use warnings;

# define
our $VERSION = '0.02';


sub new {

	# get input
	my ( $class ) = @_;
	
	# initialize
	my $self = {};
		
	# return
	return bless $self, $class;
	
}


sub text {

	# get input
	my ( $self, $text ) = @_;
	
	# set
	if ( $text ) { $self->{ text } = $text }
	
	# return
	return $self->{ text };
	
}


sub words {

	# get input
	my ( $self ) = shift;

	# parse
	my $text = $self->text;
	$text =~ tr/a-zA-Z'()\-,.?!;:/\n/cs;
	$text =~ s/([,.?!:;()\-])/\n$1\n/g;
	$text =~ s/\n+/\n/g;
	
	# done
	return split /\n/, lc( $text );

}


sub word_count {

	# get input
	my ( $self ) = shift;

	# initialize
	my @words      = $self->words;
	my %word_count = ();
	
	# do the work
	for ( my $i = 0; $i <= $#words; $i++ ) { $word_count{ $words[ $i ] }++ }

	# done
	return \%word_count;
	
}


sub bigrams {

	# get input
	my ( $self ) = shift;

	# initialize
	my @words   = $self->words;
	my @bigrams = ();
	
	# do the work
	for ( my $i = 0; $i < $#words; $i++ ) { $bigrams[ $i ] = $words[ $i ] . ' ' . $words[ $i + 1 ] }
	
	# done
	return @bigrams;

}


sub bigram_count {

	# get input
	my ( $self ) = shift;

	# initialize
	my @words        = $self->words;
	my @bigrams      = $self->bigrams;
	my %bigram_count = ();
	
	# do the work
	for ( my $i = 0; $i < $#words; $i++ ) { $bigram_count{ $bigrams[ $i ] }++ }
	
	# done
	return \%bigram_count;

}


sub tscore {

	# get input
	my ( $self ) = shift;
	
	# initialize
	my @words        = $self->words;
	my $word_count   = $self->word_count;
	my @bigrams      = $self->bigrams;
	my $bigram_count = $self->bigram_count;

	# calculate t-score
	my %tscore = ();
	for ( my $i = 0; $i < $#words; $i++ ) {

		$tscore{ $bigrams[ $i ] } = ( $$bigram_count{ $bigrams[ $i ] } - 
	                                  $$word_count{ $words[ $i ] } * 
	                                  $$word_count{ $words[ $i + 1 ] } / 
	                                  ( $#words + 1 ) ) / 
	                                  sqrt( $$bigram_count{ $bigrams[ $i ] }
	                                );

	}
	
	# done
	return \%tscore;
	
}


sub trigrams {
	
	# get input
	my ( $self ) = shift;

	# initialize
	my @words    = $self->words;
	my @trigrams = ();
	
	# do the work
	no warnings; 
	for ( my $i = 0; $i < $#words; $i++ ) { $trigrams[ $i ] = $words[ $i ] . ' ' . $words[ $i + 1 ] . ' ' . $words[ $i + 2 ] }
	
	# done
	return @trigrams;

}


sub trigram_count {

	# get input
	my ( $self ) = shift;

	# initialize
	my @words         = $self->words;
	my @trigrams      = $self->trigrams;
	my %trigram_count = ();
	
	# do the work
	for ( my $i = 0; $i < $#words; $i++ ) { $trigram_count{ $trigrams[ $i ] }++ }
	
	# done
	return \%trigram_count;

}


sub quadgrams {
	
	# get input
	my ( $self ) = shift;

	# initialize
	my @words     = $self->words;
	my @quadgrams = ();
	
	# do the work
	no warnings; 
	for ( my $i = 0; $i < $#words; $i++ ) { $quadgrams[ $i ] = $words[ $i ] . ' ' . $words[ $i + 1 ] . ' ' . $words[ $i + 2 ] . ' ' . $words[ $i + 3 ] }
	
	# done
	return @quadgrams;

}


sub quadgram_count {

	# get input
	my ( $self ) = shift;

	# initialize
	my @words          = $self->words;
	my @quadgrams      = $self->quadgrams;
	my %quadgram_count = ();
	
	# do the work
	for ( my $i = 0; $i < $#words; $i++ ) { $quadgram_count{ $quadgrams[ $i ] }++ }
	
	# done
	return \%quadgram_count;

}




=head1 NAME

Lingua::EN::Bigram - Calculate two-, three-, and four-word phrases based on frequency and/or T-Score


=head1 SYNOPSIS

  use Lingua::EN::Bigram;
  $ngram = Lingua::EN::Bigram->new;
  $ngram->text( 'All men by nature desire to know. An indication of this...' );
  $tscore = $ngram->tscore;
  foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	  print "$$tscore{ $_ }\t" . "$_\n";

  }


=head1 DESCRIPTION

This module is designed to: 1) pull out all of the two-, three-, and four-word phrases in a given text, and 2) list these phrases according to their frequency. Using this module is it possible to create lists of the most common phrases in a text as well as order them by their probable occurance, thus implying significance. This process is useful for the purposes of textual analysis and "distant reading".


=head1 METHODS


=head2 new

Create a new, empty Lingua::EN::Bigram object:

  # initalize
  $ngram = Lingua::EN::Bigram->new;


=head2 text

Set or get the text to be analyzed:

  # fill Lingua::EN::Bigram object with content 
  $ngram->text( 'All good things must come to an end...' );

  # get the Lingua::EN::Bigram object's content 
  $text = $ngram->text;


=head2 words

Return a list of all the tokens in a text. Each token will be a word or puncutation mark:

  # get words
  @words = $ngram->words;


=head2 word_count

Return a reference to a hash whose keys are a token and whose values are the number of times the token occurs in the text:

  # get word count
  $word_count = $ngram->word_count;

  # list the words according to frequency
  foreach ( sort { $$word_count{ $b } <=> $$word_count{ $a } } keys %$word_count ) {

    print $$word_count{ $_ }, "\t$_\n";

  }


=head2 bigrams

Return a list of all bigrams in the text. Each item will be a pair of tokens and the tokens may consist of words or puncutation marks:

  # get bigrams
  @bigrams = $ngram->bigrams;


=head2 bigram_count

Return a reference to a hash whose keys are a bigram and whose values are the frequency of the bigram in the text:

  # get bigram count
  $bigram_count = $ngram->bigram_count;

  # list the bigrams according to frequency
  foreach ( sort { $$bigram_count{ $b } <=> $$bigram_count{ $a } } keys %$bigram_count ) {

    print $$bigram_count{ $_ }, "\t$_\n";

  }


=head2 tscore

Return a reference to a hash whose keys are a bigram and whose values are a T-Score -- a probabalistic calculation determining the significance of the bigram occuring in the text:

  # get t-score
  $tscore = $ngram->tscore;

  # list bigrams according to t-score
  foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	  print "$$tscore{ $_ }\t" . "$_\n";

  }


=head2 trigrams

Return a list of all trigrams (three-word phrases) in the text. Each item will include three tokens and the tokens may consist of words or puncutation marks:

  # get trigrams
  @trigrams = $ngram->trigrams;


=head2 trigram_count

Return a reference to a hash whose keys are a trigram and whose values are the frequency of the trigram in the text:

  # get trigram count
  $trigram_count = $ngram->trigram_count;

  # list the trigrams according to frequency
  foreach ( sort { $$trigram_count{ $b } <=> $$trigram_count{ $a } } keys %$trigram_count ) {

    print $$trigram_count{ $_ }, "\t$_\n";

  }


=head2 quadgrams

Return a list of all quadgrams (four-word phrases) in the text. Each item will include four tokens and the tokens may consist of words or puncutation marks:

  # get quadgrams
  @quadgrams = $ngram->quadgrams;


=head2 quadgram_count

Return a reference to a hash whose keys are a quadgram and whose values are the frequency of the quadgram in the text:

  # get quadgram count
  $quadgram_count = $ngram->quadgram_count;

  # list the trigrams according to frequency
  foreach ( sort { $$quadgram_count{ $b } <=> $$quadgram_count{ $a } } keys %$quadgram_count ) {

    print $$quadgram_count{ $_ }, "\t$_\n";

  }


=head1 DISCUSSION

Given the increasing availability of full text materials, this module is intended to help "digital humanists" apply mathematical methods to the analysis of texts. For example, the developer can extract the high-frequency words using the word_count method and allow the user to search for those words in a concordance. The bigram_count method simply returns the frequency of a given bigram, but the tscore method can order them in a more finely tuned manner.

Consider using T-Score-weighted bigrams as classification terms to supplement the "aboutness" of texts. Concatonate many texts together and look for common phrases written by the author. Compare these commonly used phrases to the commonly used phrases of other authors.

Each bigram, trigram, or quadgram includes punctuation. This is intentional. Developers may need want to remove bigrams, trigrams, or quadgrams containing such values from the output. Similarly, no effort has been made to remove commonly used words -- stop words -- from the methods. Consider the use of Lingua::StopWords, Lingua::EN::StopWords, or the creation of your own stop word list to make output more meaningful. The distribution came with a script (bin/n-grams.pl) demonstrating how to remove puncutation and stop words from the displayed output.

Finally, this is not the only module supporting bigram extraction. See also Text::NSP which supports n-gram extraction.


=head1 TODO

There are probably a number of ways the module can be improved:

=over

* the constructor method could take a scalar as input, thus reducing the need for the text method

* the distribution's license should probably be changed to the Perl Aristic License

* the addition of alternative T-Score calculations would be nice

* it would be nice to support n-grams

* make sure the module works with character sets beyond ASCII

=back


=head1 CHANGES

=over

* August 22, 2010 - added trigrams and quadgrams; tweaked documentation; removed bigrams.pl from  the distribution and substituted it wih n-grams.pl

* June 19, 2009 - initial release

=back

=head1 ACKNOWLEDGEMENTS

T-Score, as well as a number of the module's methods, is calculated as per Nugues, P. M. (2006). An introduction to language processing with Perl and Prolog: An outline of theories, implementation, and application with special consideration of English, French, and German. Cognitive technologies. Berlin: Springer.


=head1 AUTHOR

Eric Lease Morgan <eric_morgan@infomotions.com>

=cut

# return true or die
1;
