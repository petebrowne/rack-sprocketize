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
  
  context 'in a production environment' do
    before do
      Rails = double(:rails, :env => double(:env, :to_s => 'production'))
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
  end
end
