### Time Machine Tools ###

This package is a ruby utility for retrieving data off of Apple time machine backups on non-MacOS systems that do not support time machine's directory hard links (e.g. Linux).

### Installing ###

Installation is through rubygems (see https://rubygems.org/gems/time_machine_tools):

`gem install time_machine_tools`

### Running ###

The gem will install an executable called tm\_copy that will copy a path off of a time machine backup to a directory on another drive.

Usage:

`tm_copy mountpoint sourcepath destpath`

where:

`mountpoint` is the location to which the backup drive is mounted (e.g. /mnt/my\_backup)

`sourcepath` is the source folder you want to copy, specified relative to mountpoint.  Its contents will be copied, but the folder itself will not.

`destpath` is the destination folder.  The contents of sourcepath will be copied (including subfolders, which will be copied recursively) into destpath.

Example:

My time machine backup is mounted at /mnt/backup, and my home directory could be found at the path /Users/myusername on the computer that was backed up.  The path of my backed up computer's root directory relative to the mount point is: Backups.backupdb/computername/Latest/Macintosh HD.  I want to copy the contents of my backup home folder to /home/myusername/mac\_home.  Command:

`tm_copy /mnt/backup Backups.backupdb/computername/Latest/Macintosh\ HD/Users/myusername /home/myusername/mac_home`

### Documentation ###

YARD documentation is available at http://rubydoc.info/gems/time_machine_tools/1.0.0.