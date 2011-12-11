#!/usr/local/bin/perl
use Encode;

my $input_file = shift | 'input.txt';
$item_index = 0;
my $page_offset = shift | 0;

my $cache_line;
my $line_in_cache = 0;

open INPUT, " < $input_file" or 
	die "can't open $input_file\nerror:$!\n";

open OUTPUT, " > bookmark2.xml" or 
	die "$!\n";

print OUTPUT <<END_OF_HEADER;
<?xml version="1.0" encoding="utf-8" ?>
<Bookmark>
END_OF_HEADER

my $line;
while ($line = getLine())
{
	handleLine($line);
}

print OUTPUT <<END_OF_TAIL;
</Bookmark>
END_OF_TAIL

exit 0;

sub handleLine
{
	my $line = shift;

	(my $level, my $name, my $page, my $tab) = parseLine($line);
	my $next_level = $level;
	
	print "$level\t$name\t$page\n";
	print OUTPUT <<END_OF_BOOKMARK_BEGIN;
	$tab<Title Page="$page XYZ 0.000000 0.000000 0.000000" Color="0 0.33333 0" Action="GoTo" >$name
END_OF_BOOKMARK_BEGIN
	
	while ($line = getLine())
	{
		(my $next_level, my $name, my $page, my $tab) = parseLine($line);
		if ($next_level <= $level)
		{
			pushbackLine($line);
			last;
		}
		handleLine($line);
	}

	print OUTPUT <<END_OF_BOOKMARK_END;
	$tab</Title>
END_OF_BOOKMARK_END
	
	$item_index++;
}

sub getLine
{
	if ($line_in_cache)
	{
		$line_in_cache = 0;
		return $cache_line;
	}
	my $line = <INPUT>;
	chomp $line;
	return $line;
}

sub pushbackLine
{
	die "error: cache is occupied!\n" if ($line_in_cache);
	$cache_line = shift;
	$line_in_cache = 1;
}

sub parseLine
{
	my $line = shift;

	my $level = 5;
	my $name = $line;
	my $page = $line;
	my $tab = "";

	while ($level)
	{
		if ( $line =~ /^(\t{$level})/)
		{
			$tab = $1;
			last;
		}
		$level--;
		
	}

	$name =~ s/^\t*\s*(.*?)\s*\.{7}.*$/$1/g;
	$name =~ s/\</\&lt;/g;
	$name =~ s/\>/\&gt;/g;

	$page =~ s/(.*?)(\d*)\s*$/$2/g;
	$page += $page_offset;
	
	print "$tab$level\t$name\t$page\n";
	$name = encode("utf8", decode(gbk=>$name));
	return ($level, $name, $page, $tab);
}
