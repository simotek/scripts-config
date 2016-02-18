# My default fish config that just loads tacklebox.

set tacklebox_path ~/src/config/tackle
set tacklebox_modules virtualfish virtualhooks
set tacklebox_plugins python extract find-in colors
set tacklebox_theme simotek

#initialise tacklebox
source ~/src/config/tacklebox/tacklebox.fish
set PYTHONPATH $PYTHONPATH:/opt/python/lib/python2.7/site-packages
