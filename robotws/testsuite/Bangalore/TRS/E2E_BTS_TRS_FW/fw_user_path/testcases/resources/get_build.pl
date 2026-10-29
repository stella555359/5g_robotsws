#!/usr/bin/perl

$enb_build 		= $ARGV[0];
$direction 		= $ARGV[1];
$position		= $ARGV[2];

my $linkcontent_file 	= '/tmp/linkcontent';
my $wget_command		= "wget http://files.ute.nsn-rdnet.net/builds/enb/base/ -O $linkcontent_file";
system($wget_command);

open(fh,"<$linkcontent");
@content = <fh>;
close fh;


$enb_build	=~s/SBTS22R3_ENB_9999/SBTS00_ENB_9999/;
$previous_build = "";


if($direction =~ /latest/i)
{
	$enb_build		= extract_major_release($enb_build);
	get_build_name($enb_build, 'tail', $position)
}
elsif($direction =~ /oldest/i)
{
	$enb_build		= extract_major_release($enb_build);
	get_build_name($enb_build, 'head', $position)
}


sub get_build_name
{
	$enb_build 		= shift;
	$head_or_tail	= shift;
	$position		= shift;
	$command		= "cat $linkcontent_file | grep $enb_build"."_ | $head_or_tail -$position";
	$latestbuild	= `$command`;
	if($latestbuild =~ /\>(SBTS.*?)\//i)
	{
		print $1;
	}
        elsif($latestbuild =~ /\>(FL.*?)\//i)
	{
		print $1;
	}
	elsif($latestbuild =~ /\>(TL.*?)\//i)
	{
		print $1;
	}
	else
	{
		print 'NOT FOUND';
	}
}

sub extract_major_release
{
	$enb_build 		= shift;
	if($enb_build =~ /SBTS.*?_\d+_\d+_\d+/)
	{
		@tmp			= split('_', $enb_build);
		return $tmp[0];
	}
	return $enb_build;
}
