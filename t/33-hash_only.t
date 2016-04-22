use strict;
use warnings;

use Test::More 'no_plan';

package Foo; {
    use Object::InsideOut ':hash_only';

    my %data :Field :All(data);
}

package Bar; {
    use Object::InsideOut qw(Foo);

    my %info :Field :All(info);
    #my @foo :Field;
}

package main;

my $obj = Bar->new('data' => 1, 'info' => 2);
is($obj->data(), 1, 'Get data');
is($obj->info(), 2, 'Get info');

eval { Bar->create_field('@misc', ':Field', ':All(misc)'); };
like($@->error, qr/Can't combine 'hash only'/, 'Hash only');
#print($@);

# EOF