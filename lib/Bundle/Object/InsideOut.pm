package Bundle::Object::InsideOut;

use strict;
use warnings;

our $VERSION = '3.63';
$VERSION = eval $VERSION;

1;

__END__

=head1 NAME

Bundle::Object::InsideOut - A bundle of modules for full Object::InsideOut support

=head1 SYNOPSIS

 perl -MCPAN -e "install Bundle::Object::InsideOut"

=head1 CONTENTS

Test::Harness 3.21              - Used for module testing

Test::Simple 0.94               - Used for module testing

Scalar::Util 1.22               - Used by Object::InsideOut

Pod::Escapes 1.04               - Used by Pod::Simple

Pod::Simple 3.13                - Used by Test::Pod

Test::Pod 1.41                  - Checks POD syntax

Devel::Symdump 2.08             - Used by Pod::Coverage

File::Spec 3.31                 - Used by Pod::Parser

Pod::Parser 1.37                - Used by Pod::Coverage

Pod::Coverage 0.20              - Used by Test::Pod::Coverage

Test::Pod::Coverage 1.08        - Tests POD coverage

threads 1.75                    - Support for threads

threads::shared 1.32            - Support for sharing objects between threads

Want 0.18                       - :lvalue accessor support

Data::Dumper 2.125              - Object serialization support

Storable 2.21                   - Object serialization support

Devel::StackTrace 1.22          - Used by Exception::Class

Class::Data::Inheritable 0.08   - Used by Exception::Class

Exception::Class 1.29           - Error handling

Object::InsideOut 3.63          - Inside-out object support

URI 1.52                        - Used by LWP::UserAgent

HTML::Tagset 3.20               - Used by LWP::UserAgent

HTML::Parser 3.64               - Used by LWP::UserAgent

LWP::UserAgent 5.834            - Used by Math::Random::MT::Auto

Win32::API 0.59                 - Used by Math::Random::MT::Auto (Win XP only)

Math::Random::MT::Auto 6.15     - Support for :SECURE mode

=head1 DESCRIPTION

This bundle includes all the modules used to test and support
Object::InsideOut.

=head1 CAVEATS

For ActivePerl on Win XP, if L<Win32::API> doesn't install using CPAN, then
try installing it using PPM:

 ppm install Win32-API

Obviously, Win32::API will not install on all platforms - just Windows and
Cygwin.

=head1 AUTHOR

Jerry D. Hedden, S<E<lt>jdhedden AT cpan DOT orgE<gt>>

=head1 COPYRIGHT AND LICENSE

Copyright 2006 - 2009 Jerry D. Hedden. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
