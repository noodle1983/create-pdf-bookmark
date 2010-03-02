#!/usr/local/bin/perl

my $input_file = shift | 'input.txt';
$item_index = 0;
my $page_offset = shift | 0;

open INPUT, " < $input_file" or 
	die "can't open $input_file\nerror:$!\n";

open OUTPUT, " > bookmark.xml" or 
	die "$!\n";

print OUTPUT <<END_OF_HEADER;
<?xml version="1.0" encoding="GB2312" ?>
<Bookmarks>
END_OF_HEADER

while (<INPUT>)
{
	chomp ;
	next unless $_;
	handleLine($_);
}

print OUTPUT <<END_OF_TAIL;
</Bookmarks>
END_OF_TAIL

sub handleLine
{
	my $line = shift;

	my $level = 5;
	my $name = $line;
	my $page = $line;

	while ($level)
	{
		last if ( $line =~ /^\t{$level}/);
		$level--;
	}

	$name =~ s/^\t*(.*?)\.{7}.*$/$1/g;

	$page =~ s/(.*?)(\d*)\s*$/$2/g;
	$page += $page_offset;

	print "$level\t$name\t$page\n";
	print OUTPUT <<END_OF_BOOKMARK;
	<Bookmark>
		<Item>$item_index</Item>
		<Level>$level</Level>
		<Name>$name</Name>
		<Color>005500</Color>
		<Style>Plain</Style>
		<Action>
			<Type>Go to a page in this document</Type>
			<Page>$page</Page>
			<Destination>XYZ</Destination>
			<Top>0</Top>
		</Action>
	</Bookmark>

END_OF_BOOKMARK
	$item_index++;
}
