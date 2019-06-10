#!/usr/bin/perl


use strict;
use English;
use Data::Dumper;

package IBO;


sub new 
{
	my $class = shift;
	my $ppv = shift;

	my $self = {
			inMonth    => 0,
			ppv        => $ppv,
			legs       => 0,
			frontLines => [ ],
			teamSize   => 1,
			gpv        => $ppv,
		   };

	bless $self, $class;

	return $self;
}


sub IncMonth
{
	my $self = shift;

	$self->{inMonth}++;

	#Incrementing month for depth
        foreach my $depNIbo (@{$self->{frontLines}})
        {
                $depNIbo->IncMonth;
        }

}

sub IdentifyPartnersInWnD
{
	my $self    = shift;
	my $sppv    = shift;
	my $idPrtSt = shift;
	my $noOfPrt = shift;

	#Adding new partners starting $idPrtSt month in width
	if ($self->{inMonth} >= $idPrtSt)
	{
		$self->{legs} = $self->{legs} + $noOfPrt;

		for (my $i = 1; $i <= $noOfPrt; $i++)
		{
			my $nIbo = IBO->new($sppv);

			push @{$self->{frontLines}}, $nIbo;
		}
	}

	# This IBO + Team size of frontlines
	$self->{teamSize} = 1;

	#Adding new partners for depth
	foreach my $depNIbo (@{$self->{frontLines}})
	{
		$depNIbo->IdentifyPartnersInWnD($sppv, $idPrtSt, $noOfPrt);

		$self->{teamSize} = $self->{teamSize} + $depNIbo->{teamSize};
	}
}

sub UpdatePPVnCalculateGPV
{
	my $self    = shift;
	my $appv    = shift;
	my $appvSt  = shift;

	$self->{ppv} = $appv if $self->{inMonth} == $appvSt;

	$self->{gpv} = $self->{ppv};

	#Updating PPV for depth
	foreach my $depNIbo (@{$self->{frontLines}})
	{
		$depNIbo->UpdatePPVnCalculateGPV($appv, $appvSt);

		$self->{gpv} = $self->{gpv} + $depNIbo->{gpv};
	}
}

1;

use constant SPPV    => 100; # Starting PPV
use constant APPV    => 200; # Average PPV
use constant APPVST  => 4;   # Average PPV Starting which month in the business
use constant IDPRTST => 4;   # Starts identifying partner from month in the business
use constant NOOFPRT => 1;   # No of Partners identified per month


# Here is our Hero IBO who is looking to go Ruby in 24 months and hence grows Great
my $Hero = IBO->new(SPPV);

for (my $month = 1; $month <=24; $month++)
{
	# Hero starts growing fast
	$Hero->IncMonth();
	$Hero->IdentifyPartnersInWnD(SPPV, IDPRTST, NOOFPRT);
	$Hero->UpdatePPVnCalculateGPV(APPV, APPVST);
	
	print "\n\n";
	print "In Month        : ",$Hero->{inMonth},"\n";
	print "# of Legs       : ",$Hero->{legs},"\n";
	print "Total Team Size : ",$Hero->{teamSize},"\n";
	print "Personal PV     : ",$Hero->{ppv},"\n";
	print "Group PV        : ",$Hero->{gpv},"\n";
	print "\n========================\n";
}
