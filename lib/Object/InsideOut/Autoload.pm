package Object::InsideOut; {

use strict;
use warnings;
no warnings 'redefine';

# Handles :Automethods and foreign inheritance
sub AUTOLOAD
{
    my ($TREE_TOP_DOWN, $TREE_BOTTOM_UP, $HERITAGE, $AUTOMETHODS, @args) = @_;

    *Object::InsideOut::AUTOLOAD = sub
    {
        my $thing = $_[0];

        # Extract the class and method names from the fully-qualified name
        my ($class, $method) = our $AUTOLOAD =~ /(.*)::(.*)/;

        # Handle superclass calls
        my $super;
        if ($class =~ /::SUPER$/) {
            $class =~ s/::SUPER//;
            $super = 1;
        }

        # Find a something to handle the method call
        my ($code_type, $code_dir, %code_refs);
        foreach my $pkg (@{$$TREE_BOTTOM_UP{$class}}) {
            # Skip self's class if SUPER
            if ($super && $class eq $pkg) {
                next;
            }

            # Check with heritage objects/classes
            if (exists($$HERITAGE{$pkg})) {
                my ($heritage, $classes) = @{$$HERITAGE{$pkg}};
                if (Scalar::Util::blessed($thing)) {
                    if (exists($$heritage{$$thing})) {
                        # Check objects
                        foreach my $obj (@{$$heritage{$$thing}}) {
                            if (my $code = $obj->can($method)) {
                                shift;
                                unshift(@_, $obj);
                                goto $code;
                            }
                        }
                    } else {
                        # Check classes
                        foreach my $pkg (keys(%{$classes})) {
                            if (my $code = $pkg->can($method)) {
                                @_ = @_;   # Perl 5.8.5 bug workaround
                                goto $code;
                            }
                        }
                    }
                } else {
                    # Check classes
                    foreach my $pkg (keys(%{$classes})) {
                        if (my $code = $pkg->can($method)) {
                            shift;
                            unshift(@_, $pkg);
                            goto $code;
                        }
                    }
                }
            }

            # Check with Automethod
            if (my $automethod = $$AUTOMETHODS{$pkg}) {
                # Call the Automethod to get a code ref
                local $CALLER::_ = $_;
                local $_ = $method;
                local $SIG{__DIE__} = 'OIO::trap';
                if (my ($code, $ctype) = $automethod->(@_)) {
                    if (ref($code) ne 'CODE') {
                        # Not a code ref
                        OIO::Code->die(
                            'message' => ':Automethod did not return a code ref',
                            'Info'    => ":Automethod in package '$pkg' invoked for method '$method'");
                    }

                    if (defined($ctype)) {
                        my ($type, $dir) = $ctype =~ /(\w+)(?:[(]\s*(.*)\s*[)])?/;
                        if ($type && $type =~ /CUM/i) {
                            if ($code_type) {
                                $type = ':Cumulative';
                                $dir = ($dir && $dir =~ /BOT/i) ? 'bottom up' : 'top down';
                                if ($code_type ne $type || $code_dir ne $dir) {
                                    # Mixed types
                                    my ($pkg2) = keys(%code_refs);
                                    OIO::Code->die(
                                        'message' => 'Inconsistent code types returned by :Automethods',
                                        'Info'    => "Class '$pkg' returned type $type($dir), and class '$pkg2' returned type $code_type($code_dir)");
                                }
                            } else {
                                $code_type = ':Cumulative';
                                $code_dir = ($dir && $dir =~ /BOT/i) ? 'bottom up' : 'top down';
                            }
                            $code_refs{$pkg} = $code;
                            next;
                        }
                        if ($type && $type =~ /CHA/i) {
                            if ($code_type) {
                                $type = ':Chained';
                                $dir = ($dir && $dir =~ /BOT/i) ? 'bottom up' : 'top down';
                                if ($code_type ne $type || $code_dir ne $dir) {
                                    # Mixed types
                                    my ($pkg2) = keys(%code_refs);
                                    OIO::Code->die(
                                        'message' => 'Inconsistent code types returned by :Automethods',
                                        'Info'    => "Class '$pkg' returned type $type($dir), and class '$pkg2' returned type $code_type($code_dir)");
                                }
                            } else {
                                $code_type = ':Chained';
                                $code_dir = ($dir && $dir =~ /BOT/i) ? 'bottom up' : 'top down';
                            }
                            $code_refs{$pkg} = $code;
                            next;
                        }

                        # Unknown automethod code type
                        OIO::Code->die(
                            'message' => "Unknown :Automethod code type: $ctype",
                            'Info'    => ":Automethod in package '$pkg' invoked for method '$method'");
                    }

                    if ($code_type) {
                        # Mixed types
                        my ($pkg2) = keys(%code_refs);
                        OIO::Code->die(
                            'message' => 'Inconsistent code types returned by :Automethods',
                            'Info'    => "Class '$pkg' returned an 'execute immediately' type, and class '$pkg2' returned type $code_type($code_dir)");
                    }

                    # Just a one-shot - execute it
                    @_ = @_;   # Perl 5.8.5 bug workaround
                    goto $code;
                }
            }
        }

        if ($code_type) {
            my $tree = ($code_dir eq 'bottom up') ? $TREE_BOTTOM_UP : $TREE_TOP_DOWN;
            my $code = ($code_type eq ':Cumulative')
                            ? create_CUMULATIVE($tree, \%code_refs)
                            : create_CHAINED($tree, \%code_refs);
            @_ = @_;   # Perl 5.8.5 bug workaround
            goto $code;
        }

        # Failed to AUTOLOAD
        my $type = ref($thing) ? 'object' : 'class';
        OIO::Method->die('message' => qq/Can't locate $type method "$method" via package "$class"/);
    };


    # Do the original call
    @_ = @args;
    goto &Object::InsideOut::AUTOLOAD;
}

}  # End of package's lexical scope


# Ensure correct versioning
($Object::InsideOut::VERSION == 1.43) or die("Version mismatch\n");
