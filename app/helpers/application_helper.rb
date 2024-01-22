module ApplicationHelper
	def tag_image_path(tag_name)
  	  image_path = "#{tag_name}.png"
	
  	  begin
  	    asset_path(image_path)
  	  rescue Sprockets::Rails::Helper::AssetNotFound
  	    'default.png'
  	  end
  	end
end
