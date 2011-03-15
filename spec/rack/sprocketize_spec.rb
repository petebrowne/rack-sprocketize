require 'spec_helper'

describe Rack::Sprocketize do
  it 'concatenates javascripts' do
    within_construct do |c|
      c.file 'app/javascripts/main.js',      %{//= require <plugin>\n//= require "_plugin"}
      c.file 'app/javascripts/another.js',   '1'
      c.file 'vendor/javascripts/plugin.js', '2'
      c.file 'app/javascripts/_plugin.js',   '3'
      
      app.call(request)
      
      File.read('public/javascripts/main.js').should == "2\n3"
      File.read('public/javascripts/another.js').should == "1"
    end
  end
    
  it 'does not compress the output' do
    reveal_const :JSMin do
      within_construct do |c|
        c.file 'app/javascripts/main.js', '1'
      
        JSMin.should_not_receive(:minify)
        app.call(request)
        File.read('public/javascripts/main.js').should == '1'
      end
    end
  end
  
  context 'when main files are updated' do
    it 'concatenates again' do
      within_construct do |c|
        c.file 'app/javascripts/main.js', '1'
        
        app.call(request)
        sleep 1
        c.file 'app/javascripts/main.js', '2'
        
        app.call(request)
        File.read('public/javascripts/main.js').should == '2'
      end
    end
  end
  
  context 'when required files are updated' do
    it 'concatenates again' do
      within_construct do |c|
        c.file 'app/javascripts/main.js',    %{//= require "_plugin"}
        c.file 'app/javascripts/_plugin.js', '1'
        
        app.call(request)
        sleep 1
        c.file 'app/javascripts/_plugin.js', '2'
        
        app.call(request)
        File.read('public/javascripts/main.js').should == '2'
      end
    end
  end
  
  context 'when files are added' do
    it 'concatenates the new files' do
      within_construct do |c|
        c.file 'app/javascripts/main.js', '1'
        
        app.call(request)
        sleep 1
        c.file 'app/javascripts/another.js', %{//= require "_plugin"}
        c.file 'app/javascripts/_plugin.js', '2'
        
        app.call(request)
        File.read('public/javascripts/another.js').should == '2'
      end
    end
  end
  
  context 'when there are no changes' do
    it 'does not concatenate' do
      within_construct do |c|
        c.file 'app/javascripts/main.js', '1'
        
        app.call(request)
        sleep 1
        
        output_file = Pathname.new('public/javascripts/main.js')
        expect {
          app.call(request)
        }.to_not change(output_file, :mtime)
      end
    end
  end
  
  context 'with :always_check set to false' do
    it 'does not concatenate' do
      within_construct do |c|
        c.file 'app/javascripts/main.js', '1'
        
        app(:always_check => false).call(request)
        sleep 1
        c.file 'app/javascripts/main.js', '2'
        
        app.call(request)
        File.read('public/javascripts/main.js').should == '1'
      end
    end
  end
  
  context 'with :always_compress set to true' do
    context 'with jsmin required' do
      it 'compresses the output' do
        reveal_const :JSMin do
          within_construct do |c|
            c.file 'app/javascripts/main.js', '1'
          
            JSMin.should_receive(:minify).with("1\n").and_return('compressed')
            app(:always_compress => true).call(request)
            File.read('public/javascripts/main.js').should == 'compressed'
          end
        end
      end
    end
    
    context 'with packr required' do
      it 'compresses the output' do
        reveal_const :Packr do
          within_construct do |c|
            c.file 'app/javascripts/main.js', '1'
          
            Packr.should_receive(:pack).with("1\n", :shrink_vars => true).and_return('compressed')
            app(:always_compress => true).call(request)
            File.read('public/javascripts/main.js').should == 'compressed'
          end
        end
      end
    end
    
    context 'with yui/compressor required' do
      it 'compresses the output' do
        reveal_const :YUI do
          within_construct do |c|
            c.file 'app/javascripts/main.js', '1'
          
            compressor = double(:compressor)
            compressor.should_receive(:compress).with("1\n").and_return('compressed')
            YUI::JavaScriptCompressor.should_receive(:new).with(:munge => true).and_return(compressor)
            app(:always_compress => true).call(request)
            File.read('public/javascripts/main.js').should == 'compressed'
          end
        end
      end
    end
    
    context 'with closure-compiler required' do
      it 'compresses the output' do
        reveal_const :Closure do
          within_construct do |c|
            c.file 'app/javascripts/main.js', '1'
          
            compiler = double(:compiler)
            compiler.should_receive(:compile).with("1\n").and_return('compressed')
            Closure::Compiler.should_receive(:new).and_return(compiler)
            app(:always_compress => true).call(request)
            File.read('public/javascripts/main.js').should == 'compressed'
          end
        end
      end
    end
      
    context 'with an already minified file' do
      it 'does not compress the output' do
        reveal_const :JSMin do
          within_construct do |c|
            c.file 'app/javascripts/main.min.js', '1'
          
            JSMin.should_not_receive(:minify)
            app(:always_compress => true).call(request)
            File.read('public/javascripts/main.min.js').should == '1'
          end
        end
      end
    end
  end
  
  context 'in a production environment' do
    before do
      Rails = double(:rails, :env => 'production')
    end
    
    after do
      Object.send(:remove_const, :Rails)
    end
    
    it 'concatenates only one time' do
      within_construct do |c|
        c.file 'app/javascripts/main.js', '1'
        
        app.call(request)
        sleep 1
        c.file 'app/javascripts/main.js', '2'
        
        app.call(request)
        File.read('public/javascripts/main.js').should == '1'
      end
    end
    
    it 'compresses the output' do
      reveal_const :JSMin do
        within_construct do |c|
          c.file 'app/javascripts/main.js', '1'
        
          JSMin.should_receive(:minify).with("1\n").and_return('compressed')
          app.call(request)
          File.read('public/javascripts/main.js').should == 'compressed'
        end
      end
    end
    
    context 'with a :sprocketize param' do
      it 'concatenates again' do
        within_construct do |c|
          c.file 'app/javascripts/main.js', '1'
          
          app.call(request)
          sleep 1
          c.file 'app/javascripts/main.js', '2'
          
          app.call request('/?sprocketize=1')
          File.read('public/javascripts/main.js').should == '2'
        end
      end
    end
    
    context 'with :always_check set to true' do
      it 'concatenates again' do
        within_construct do |c|
          c.file 'app/javascripts/main.js', '1'
          
          app(:always_check => true).call(request)
          sleep 1
          c.file 'app/javascripts/main.js', '2'
          
          app.call(request)
          File.read('public/javascripts/main.js').should == '2'
        end
      end
    end
  end
end
