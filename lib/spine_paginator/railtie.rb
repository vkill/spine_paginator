
module SpinePaginator
  class Railtie < ::Rails::Railtie
  
    initializer "sprockets.spine_paginator", after: "append_asset_paths" do |app|
      next unless app.config.assets.enabled
      app.config.assets.paths << File.expand_path("../../../dist", __FILE__)
    end

  end
end
