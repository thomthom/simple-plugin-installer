#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'extensions.rb'

#-------------------------------------------------------------------------------

module TT
 module Plugins
  module SimpleInstaller

  ### CONSTANTS ### ------------------------------------------------------------

  # Plugin information
  PLUGIN_ID       = 'TT_SimpleInstaller'.freeze
  PLUGIN_NAME     = 'Simple Plugin Installer'.freeze
  PLUGIN_VERSION  = '1.2.0'.freeze

  # Resource paths
  FILENAMESPACE = File.basename( __FILE__, '.rb' )
  PATH_ROOT     = File.dirname( __FILE__ ).freeze
  PATH          = File.join( PATH_ROOT, FILENAMESPACE ).freeze


  ### EXTENSION ### ------------------------------------------------------------

  unless file_loaded?( __FILE__ )
    loader = File.join( PATH, 'core.rb' )
    ex = SketchupExtension.new( PLUGIN_NAME, loader )
    ex.description = 'Adds menu items for easy installation of RBZ or ZIP packaged plugins.'
    ex.version     = PLUGIN_VERSION
    ex.copyright   = 'Thomas Thomassen © 2012–2013'
    ex.creator     = 'Thomas Thomassen (thomas@thomthom.net)'
    Sketchup.register_extension( ex, true )
  end

  end # module SimpleInstaller
 end # module Plugins
end # module TT

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------