#The Page class renders html pages for the server
module Entityjs
  
  class Page
    
    def self.render_play
      self.set_vars("play.html")
    end
    
    def self.render_tests
      self.set_vars('tests.html', true)
    end
    
    def self.render_entityjs_src(path)
      path = Entityjs::root+'/src/'+path
      
      return IO.read(path)
    end
    
    def self.render_script(path)
      return Compile.script_to_js(path)
    end
    
    def self.render_eunit(path)
      IO.read(Entityjs::root+"/public/qunit/#{path}")
    end
    
    protected
    #defines varaibles on the template htmls for view on webpage
    def self.set_vars(path, tests=false)
      contents = IO.read("#{Entityjs::root}/public/#{path}")
      
      #reload config for changes
      Config.instance.reload
      
      #set width, height and canvas id
      contents = contents.sub("$WIDTH", Config.instance.width.to_s)
      contents = contents.sub("$HEIGHT", Config.instance.height.to_s)
      contents = contents.sub("$CANVAS_ID", Config.instance.canvas_id)
      
      #set javascript srcs
      contents.sub("$JS", self.compile_js_html(tests))
    end
    
    #compiles html js tags for render on webpage
    def self.compile_js_html(tests=false)
      js = %Q(
      <script type='text/javascript'>
      window.addEventListener\('load', function(){
          #{Build.js_config}
          re.version = '#{VERSION}';
        
        }\);
      </script>
)
      ent = Dirc.find_entity_src_url(Config.instance.entity_ignore)
      srcs = Dirc.find_scripts_url(Config.instance.scripts_ignore, Config.instance.scripts_order)
      
      if tests
        tests_src = Dirc.find_tests_url(Config.instance.tests_ignore)
      else
        tests_src = []
      end
      
      merg = ent | srcs | tests_src
      
      merg.each do |s|
        js += "\t<script src='#{s}' type='text/javascript'></script>\n"
      end
      
      return js
    end
    
  end
  
end