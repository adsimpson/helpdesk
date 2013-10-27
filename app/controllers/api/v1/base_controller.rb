class Api::V1::BaseController < ApplicationController

private
    
  def default_serializer_options
    {
      :namespace => 'V1'
      }
  end

end
