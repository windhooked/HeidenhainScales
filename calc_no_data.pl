#
# Hannes de Waal (c) 2019
#
# Absolute reference mark decoding on Heidenhain linear scales
# https://www.heidenhain.de/fileadmin/pdb/media/img/571470-2B_Linear_Encoders_For_Numerically_Controlled_Machine_Tools.pdf
#
my $aa = 0; # old a
my $bb = 0; # old b
my $zz = 0; # old z
my @c = ( 0,-1,+1,0,+1,0,0,-1,-1,0,0,+1,0,+1,-1,0 ); # lut 16 states
my $Mrr = 0; # Signal periods between two reference marks

sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}
sub sgn {
	my $x = shift;
	return ($x<=>0) ;# sgn($x)
}
for ( <DATA> ) {
	chomp;
	next if ( /null/);
	my @l = split /\,/;
	my $a = $l[1];
	my $b = $l[2];
	my $z = $l[3];

        my $r = bin2dec("$aa$bb$a$b"); # generate current state for lut
	my $t = bin2dec("$bb$zz$b$z");
	#my $t = bin2dec("$aa$zz$a$z");

	$count += $c[$r];
	$count_Z += $c[$t];

	$N = 1000; #Nominal increment between two fixed reference marks in signal periods (see table below)
	$R =  (2*$Mrr)-$N;
	$D = +1; #direction

	$P1 = (abs($R) - sgn($R) -1) * $N/2 + ( sgn($R) - sgn($D) ) * abs( $Mrr) /2;

	if ( $a != $aa ) {
		$Mrr++; ## number of signal periods between reference marks
	}
	if ( $z != $zz ) {
		printf "d:%10f dp1:%20f P1: %10d R:%5d %5d %10d %10d\n",$count*0.001, $P1-$PP1,$P1, $R, $count, $count - $bc, $count_Z;
		#printf "%10f;%20f;%10d;%5d;%5d;%10d;%10d\n",$count*0.001, $P1*0.001,$P1, $R, $count, $count - $bc, $count_Z;
	        $bc = $count;
		$Mrr = 0;
	}

	$bb = $b;
	$aa = $a;
	$zz = $z;
	$PP1 = $P1;
}
#
