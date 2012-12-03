#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'

#-------------------------------------------------------------------------------


module TT;end
module TT::Plugins;end
module TT::Plugins::SimpleInstaller
  
  
  ### CONSTANTS ### ------------------------------------------------------------
  
  # Plugin information
  PLUGIN_ID       = 'TT_SimpleInstaller'.freeze
  PLUGIN_NAME     = 'Simple Installer'.freeze
  PLUGIN_VERSION  = '1.1.0'.freeze
  
  # @since 1.1.0
  PLATFORM_IS_OSX     = (Object::RUBY_PLATFORM =~ /darwin/i) ? true : false
  PLATFORM_IS_WINDOWS = !PLATFORM_IS_OSX
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Menus
    menu = UI.menu( 'Plugins' )
    m = menu.add_submenu( 'Install' )
    m.add_item( 'ZIP Package' ) { self.install_package( false ) }
    m.add_item( 'RBZ Package' ) { self.install_package }
    m.add_item( 'RB File' )     { self.install_file( 'rb' ) }
    m.add_item( 'RBS File' )    { self.install_file( 'rbs' ) }
    m.add_separator
    m.add_item( 'Open Extension Manager' ) { self.open_extension_manager }
  end 
  
  
  ### LIB FREDO UPDATER ### ----------------------------------------------------
  
  def self.register_plugin_for_LibFredo6
    {   
      :name => PLUGIN_NAME,
      :author => 'thomthom',
      :version => PLUGIN_VERSION.to_s,
      :date => '03 Dec 12',
      :description => 'Adds menu items for easy installation of RBZ or ZIP packaged plugins.',
      :link_info => 'http://sketchucation.com/forums/viewtopic.php?f=323&t=42315'
    }
  end
  
  
  ### MAIN SCRIPT ### ----------------------------------------------------------
  
  # @param [Boolean] rbz True for RBZ packages, false for ZIP.
  #
  # @since 1.0.0
  def self.install_package( rbz = true )
    extension = ( rbz ) ? '*.rbz' : '*.zip'
    file = UI.openpanel( 'Install Plugin Package', nil, extension )
    return if file.nil?
    begin
      Sketchup.install_from_archive( file )
    rescue Interrupt => error
      #UI.messagebox "User said 'no': #{error}"
      puts "User said 'no': #{error}"
    rescue Exception => error
      UI.messagebox "Error during installation: #{error}"
    end
  end
  
  
  # @since 1.0.3
  def self.install_file( format = 'rb' )
    file = UI.openpanel( 'Install Plugin', nil, "*.#{format}" )
    return if file.nil?
    destination = Sketchup.find_support_file( 'Plugins' )
    filename = File.basename( file )
    # Confirm
    message = "Are you sure you want to copy '#{filename}' to your plugins folder?"
    new_file = File.join( destination, filename )
    if File.exist?( new_file )
      message += "\n\nThere is already a version of '#{filename}' installed."
    end
    result = UI.messagebox( message, MB_YESNO )
    return unless result == IDYES
    # Check if file can be created.
    unless File.readable?( file )
      return UI.messagebox( "Could not read source file '#{filename}'. Make sure it is located under a path that only contains ASCII characters." )
    end
    # Copy to plugins folder.
    file_content = nil
    # Read Source
    begin
      File.open( file, 'rb' ) { |io|
        file_content = io.read
      }
    rescue Exception => error
      UI.messagebox( "Error during installation. Could not read source file.\nError: #{error}" )
    end
    # Write destination
    begin
      File.open( new_file, 'wb' ) { |io|
        io.write( file_content )
      }
    rescue Exception => error
      UI.messagebox( "Error during installation. Could not write destination file.\nError: #{error}" )
    end
    # Validate installation. Check for VirtualStore.
    if self.is_virtualized?( new_file )
      virtualfile = self.get_virtual_path( file )
      File.delete( virtualfile )
      UI.messagebox( "Installation failed. You do not have full permissions to the Plugins folder. Windows tried to place the file in VirtualStore." )
    else
      # Load the plugin.
      # Sketchup::load acts as Sketchup::require and therefore we must remove
      # the entries from $LOADED_FEATURES in order for it to reload if the file
      # was updated.
      $LOADED_FEATURES.delete( new_file )
      $LOADED_FEATURES.delete( filename )
      begin
        unless Sketchup::load( new_file )
          UI.messagebox( "Could not automatically load plugin." )
        end
      rescue
        UI.messagebox( "Error during installation. Could not load plugin.\nError: #{error}" )
      end
    end
  end
  
  
  # @return [String]
  # @since 1.0.0
  def self.open_extension_manager
    UI.show_preferences( 'Extensions' )
  end
  
  
  # @return [String]
  # @since 1.1.0
  def self.is_virtualized?( file )
    if PLATFORM_IS_WINDOWS
      virtualfile = self.get_virtual_path( file )
      File.exist?( virtualfile )
    else
      false
    end
  end
  
  
  # @return [String]
  # @since 1.1.0
  def self.get_virtual_path( file )
    if PLATFORM_IS_WINDOWS
      filename = File.basename( file )
      filepath = File.dirname( file )
      # Verify file exists.
      unless File.exist?( file )
        raise ArgumentError, "The file '#{file}' does not exist."
      end
      # See if it can be found in virtual store.
      virtualstore = File.join( ENV['LOCALAPPDATA'], 'VirtualStore' )
      path = filepath.split(':')[1]
      File.join( virtualstore, path, filename )
    else
      file
    end
  end

  
  ### DEBUG ### ----------------------------------------------------------------
  
  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::SimpleInstaller.reload
  #
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    load __FILE__
  ensure
    $VERBOSE = original_verbose
  end

end # module

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------