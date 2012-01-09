#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'

#-------------------------------------------------------------------------------


# <hotfix>
# Need to ensure the parent namespaces exists. Normally TT_Lib2 defines this.
module TT;end
module TT::Plugins;end
# </hotfix>
module TT::Plugins::SimpleInstaller
  
  
  ### CONSTANTS ### ------------------------------------------------------------
  
  # Plugin information
  PLUGIN_ID       = 'TT_SimpleInstaller'.freeze
  PLUGIN_NAME     = 'Simple Installer'.freeze
  PLUGIN_VERSION  = '1.0.1'.freeze
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Menus
    menu = UI.menu( 'Plugins' )
    m = menu.add_submenu( 'Install' )
    m.add_item( 'ZIP Package' ) { self.install_package( false ) }
    m.add_item( 'RBZ Package' ) { self.install_package }
    m.add_item( 'RB File' ) { self.install_rb }
    m.add_separator
    m.add_item( 'Open Extension Manager' ) { self.open_extension_manager }
  end 
  
  
  ### LIB FREDO UPDATER ### ----------------------------------------------------
  
  def self.register_plugin_for_LibFredo6
    {   
      :name => PLUGIN_NAME,
      :author => 'thomthom',
      :version => PLUGIN_VERSION.to_s,
      :date => '02 Jan 12',
      :description => 'Adds menu items for easy installation of RBZ or ZIP packaged plugins.',
      :link_info => 'http://forums.sketchucation.com/viewtopic.php?f=323&t=42315'
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
  
  
  # @since 1.0.0
  def self.install_rb
    file = UI.openpanel( 'Install Plugin', nil, '*.rb' )
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
    return unless result == 6 # ( MB_YES )
    # Check if file can be created.
    unless File.readable?( file )
      return UI.messagebox( "Could not read source file '#{filename}'. Make sure it is located under a path that only contains ASCII characters." )
    end
    # Copy to plugins folder.
    # (?) No copy method in the standard Ruby lib???
    file_content = nil
    # Read Source
    begin
      File.open( file, 'rb' ) { |io|
        file_content = io.read
      }
    rescue Exception => error
      UI.messagebox "Error during installation. Could not read source file.\nError: #{error}"
    end
    # Write destination
    begin
      File.open( new_file, 'wb' ) { |io|
        io.write( file_content )
      }
    rescue Exception => error
      UI.messagebox "Error during installation. Could not write destination file.\nError: #{error}"
    end
  end
  
  
  # @return [String]
  # @since 1.0.0
  def self.open_extension_manager
    UI.show_preferences( 'Extensions' )
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