# Default serialization configuration

class Api::V1::BaseSerializer < Xibit::Serializer
  # camelize :lower
  
  # Configuration
  
  configure :root,      :instance => true,
                        :collection => true
  
  configure :meta,      :param => :meta,
                        :key => :_meta

  configure :links,     :param => :links,
                        :key => :_links

  configure :partials,  :param => :fields

  # Collection configuration
  
  configure :sorting,   :param => :orderBy
  
  configure :paging,    :param => :page, 
                        :page_size_param => :pageSize, 
                        :default_page_size => 25
  
  configure :search,   :active => true
  
  sort_attributes :id

end