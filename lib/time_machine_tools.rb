#--
# /* ***** BEGIN LICENSE BLOCK *****
#  *
#  * time_machine_tools.rb
#  * Copyright (c) 2012 Colin J. Fuller
#  *
#  * Permission is hereby granted, free of charge, to any person obtaining a copy
#  * of this software and associated documentation files (the Software), to deal
#  * in the Software without restriction, including without limitation the rights
#  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  * copies of the Software, and to permit persons to whom the Software is
#  * furnished to do so, subject to the following conditions:
#  *
#  * The above copyright notice and this permission notice shall be included in
#  * all copies or substantial portions of the Software.
#  *
#  * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  * SOFTWARE.
#  *
#  * ***** END LICENSE BLOCK ***** */
#++

##
#  Time machine tools is a utility for copying data off an Apple time machine
#  backup on a system (e.g. linux) that does not support the type of hard links
#  used for the backup.
#  
#  usage (with install through rubygems):
#  
#  gem install time_machine_tools
#  tm_copy mountpoint sourcepath destpath
#
#  where mountpoint is the location to which the backup drive is mounted (e.g. /mnt/my_backup)
#        sourcepath is the source folder you want to copy, specified relative to mountpoint.  Its contents
#                   will be copied, but the folder itself will not.
#        destpath is the destination folder.  The contents of sourcepath will be copied (including
#               subfolders, which will be copied recursively) into destpath.
#

require 'fileutils'

module TimeMachineTools
  
  Dirlisting_prefix = "dir_"
  Entries_dir = ".HFS+ Private Directory Data\r"
  

  class TMCopier
    
    ##
    # Creates a new TMCopier.
    # @param mount_point        the path to which the backup drive is mounted
    # @param path_to_dir_entries        the path relative to mount_point that contains the numbered directories for the backup
    #                                   this defaults to the hidden folder ".HFS+ Private Directory Data\r", which to my knowledge
    #                                   is the standard location for time machine backups.
    #
    def initialize(mount_point, path_to_dir_entries=Entries_dir)
      
      @path_to_dir_entries = path_to_dir_entries
      @mount_point = mount_point
      
      #I think all the linked directories are numbered higher than this.
      @min_link_count = 1000
      
    end
    
    attr_accessor :min_link_count
    
    ##
    # Maps a path that would have existed on the system being backed up to its actual path on the time machine drive.
    # @param path       the path to be mapped (which is relative to the root of the filesystem being backed up).
    # @return           a string containing the path to the actual location of the directory on the backup drive.
    #
    def get_non_linked_dir_path_for_path(path)
            
      #check if the directory exists (either as an actual directory or hard link) or whether we need to get the parent first
      
      if File.exist?(path) then
                
        #check first if we can go and get it directly
        
        if File.directory?(path) then
          
          return path
        
        end
        
        #otherwise, find the index from hard link count
        
        index = File.stat(path).nlink
        
        final_dir = File.join(@mount_point, @path_to_dir_entries, Dirlisting_prefix + index.to_s)
        
        return final_dir
        
      end
      
      #recursively get the parent directory
      
      split_path = File.split(path)
            
      parent_path = get_non_linked_dir_path_for_path(split_path[0])
      
      get_non_linked_dir_path_for_path(File.join(parent_path, split_path[1]))
      
    end
    
    ##
    # Copy the contents of the named directory into the named destination.
    # @param origin_path        the directory whose *contents* will be copied.  The directory itself will not be copied.
    # @param dest_path          the directory into which the contents of origin_path will be copied.
    #
    def copy_dir(origin_path, dest_path)
      
      p origin_path if $DEBUG

      real_dir = get_non_linked_dir_path_for_path(origin_path)
                        
      unless File.exist?(dest_path) and File.directory?(dest_path) then
      
        Dir.mkdir(dest_path)
        
      end
      
      Dir.foreach(real_dir) do |f|
        
        next if f == "." or f == ".."
        
        full_path= File.join(real_dir, f)
                
        #check if this is a hard link to a directory
        if File.exist?(full_path) and (not File.directory?(full_path)) and File.stat(full_path).nlink > @min_link_count then
          full_path = get_non_linked_dir_path_for_path(full_path)
        end
        
        if File.directory?(full_path) then
          copy_dir(full_path, File.join(dest_path, f))
        else
 
          if File.exist?(full_path) and not File.symlink?(full_path) then
          
            FileUtils.cp(full_path, dest_path)
            
          end
          
        end
        
      end
        
      nil
      
    end
    
  end

end

if __FILE__ == $0 then
  
  mount_point = ARGV[0]
  source_path = ARGV[1]
  dest_path = ARGV[2]
    
  tmc = TimeMachineTools::TMCopier.new(mount_point)
    
  origin_path = File.join(mount_point, source_path)

  tmc.copy_dir(origin_path, dest_path)
  
end




