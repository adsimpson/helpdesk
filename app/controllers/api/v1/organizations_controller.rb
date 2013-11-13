class Api::V1::OrganizationsController < Api::V1::BaseController
  before_action :load_organization, :except => [:index, :create]

  def index
    authorize Organization
    render :json => Organization.all
  end
  
  def show
    authorize @organization
    render :json => @organization
  end
  
  def create
    @organization = Organization.new
    authorize @organization
    if @organization.update_attributes permitted_params
      render :json => @organization, :status => :created  
    else
      error!(:invalid_resource, @organization.errors, 'Organization has not been created')
    end
  end
  
  def update
    authorize @organization
    if @organization.update_attributes permitted_params
      render :json => @organization, :status => :ok
    else
      error!(:invalid_resource, @organization.errors, 'Organization has not been updated')
    end
  end
  
  def destroy 
    authorize @organization
    @organization.destroy
    render :json => {}, :status => :no_content
  end

private
  
  def load_organization
    @organization = Organization.find params[:id]
  end
  
  def permitted_params
    p = params.require(:organization).permit(policy(@organization).permitted_attributes)
    modify_domain_params p
  end
  
  def modify_domain_params(p)
    # if action = :update & :domains key was included in params, by default flag all existing domains for deletion
    if params[:action] == "update" && params[:organization].has_key?(:domains)
      p[:domains_attributes] = @organization.domains.map do |domain| 
        {id: domain.id, name: domain.name, _destroy: true}
      end
    end
    # convert all passed-in domains in suitable format for :accepts_nested_attributes_for
    # - if name matches an existing domain, remove deletion flag
    # - if name does not match an existing domain, add it as a new domain
    if p.has_key? :domains
      p[:domains_attributes] ||= []
      p[:domains].each do |domain_name|
        domain = domain_name.is_a?(Hash) ? domain_name : {name: domain_name}
        index = p[:domains_attributes].index { |item| item[:name] == domain[:name]}
        if index.nil?
          p[:domains_attributes] << domain
        else
          p[:domains_attributes][index].delete :_destroy
        end
      end
      p.delete :domains
    end
    p
  end

end