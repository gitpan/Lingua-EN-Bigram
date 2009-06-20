package Lingua::EN::Bigram;

# Bigram.pm - Calculate significant two-word phrases based on frequency and/or T-Score

# Eric Lease Morgan <eric_morgan@infomotions.com>
# June 18, 2009 - first investigations
# June 19, 2009 - "finished" POD


# include
use strict;

# define
our $VERSION = '0.01';


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




=head1 NAME

Lingua::EN::Bigram - Calculate significant two-word phrases based on frequency and/or T-Score


=head1 SYNOPSIS

  use Lingua::EN::Bigram;
  $bigram = Lingua::EN::Bigram->new;
  $bigram->text( 'All men by nature desire to know. An indication of this...' );
  $tscore = $bigram->tscore;
  foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	  print "$$tscore{ $_ }\t" . "$_\n";

  }


=head1 DESCRIPTION

This module is designed to: 1) pull out all of the two-word phrases (collocations or "bigrams") in a given text, and 2) list these phrases according to thier frequency and/or T-Score. Using this module is it possible to create list of the most common two-word phrases in a text as well as order them by their probable occurance, thus implying significance.


=head1 METHODS


=head2 new

Create a new, empty bigram object:

  # initalize
  $bigram = Lingua::EN::Bigram->new;


=head2 text

Set or get the text to be analyzed:

  # set the attribute
  $bigram->text( 'All good things must come to an end...' );

  # get the attribute
  $text = $bigram->text;


=head2 words

Return a list of all the tokens in a text. Each token will be a word or puncutation mark:

  # get words
  @words = $bigram->words;


=head2 word_count

Return a reference to a hash whose keys are a token and whose values are the number of times the token occurs in the text:

  # get word count
  $word_count = $bigram->word_count;

  # list the words according to frequency
  foreach ( sort { $$word_count{ $b } <=> $$word_count{ $a } } keys %$word_count ) {

    print $$word_count{ $_ }, "\t$_\n";

  }


=head2 bigrams

Return a list of all bigrams in the text. Each item will be a pair of tokens and the tokens may consist of words or puncutation marks:

  # get bigrams
  @bigrams = $bigram->bigrams;


=head2 bigram_count

Return a reference to a hash whose keys are a bigram and whose values are the frequency of the bigram in the text:

  # get bigram count
  $bigram_count = $bigram->bigram_count;

  # list the bigrams according to frequency
  foreach ( sort { $$bigram_count{ $b } <=> $$bigram_count{ $a } } keys %$bigram_count ) {

    print $$bigram_count{ $_ }, "\t$_\n";

  }


=head2 tscore

Return a reference to a hash whose keys are a bigram and whose values are a T-Score -- a probabalistic calculation determining the significance of bigram occuring in the text:

  # get t-score
  $tscore = $bigram->tscore;

  # list bigrams according to t-score
  foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	  print "$$tscore{ $_ }\t" . "$_\n";

  }


=head1 DISCUSSION

Given the increasing availability of full text materials, this module is intended to help "digital humanists" apply mathematical methods to the analysis of texts. For example, the developer can extract the high-frequency words using the word_count method and allow the user to search for those words in a concordance. The bigram_count method simply returns the frequency of a given bigram, but the tscore method can order them in a more finely tuned manner.

Consider using T-Score-weighted bigrams as classification terms to supplement the "aboutness" of texts. Concatonate many texts together and look for common phrases written by the author. Compare these commonly used phrases to the commonly used phrases of other authors.

Each bigram includes punctuation. This is intentional. Developers may need want to remove bigrams containing such values from the output. Similarly, no effort has been made to remove commonly used words -- stop words -- from the methods. Consider the use of Lingua::StopWords, Lingua::EN::StopWords, or the creation of your own stop word list to make output more meaningful. The distribution came with a script (bin/bigrams.pl) demonstrating how to remove puncutation and stop words from the displayed output.

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


=head1 ACKNOWLEDGEMENTS

T-Score is calculated as per Nugues, P. M. (2006). An introduction to language processing with Perl and Prolog: An outline of theories, implementation, and application with special consideration of English, French, and German. Cognitive technologies. Berlin: Springer. Page 109.


=head1 AUTHOR

Eric Lease Morgan <eric_morgan@infomotions.com>

=cut

# return true or die
1;
