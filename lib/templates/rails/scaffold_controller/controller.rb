<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"
<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  paginated_action only: [:index]

  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]
  before_action :filters, only: [:index]

  respond_to :html, :json

  def index
    @<%= plural_table_name %> = <%= class_name %>
          .filter(@filter)
          .order("#{@order} #{@asc_desc}")
          .page(@kp_page)

    respond_with @<%= plural_table_name %>, layout: "index"
  end

  def show
    respond_with @<%= singular_table_name %>
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    respond_with @<%= singular_table_name %>
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>
    flash[:notice] = "Registro criado com sucesso." if @<%= orm_instance.save %>
    respond_with @<%= singular_table_name %>
  end

  def update
    flash[:notice] = "Registro atualizado com sucesso." if @<%= orm_instance.update("#{singular_table_name}_params") %>
    respond_with @<%= singular_table_name %>
  end

  def destroy
    flash[:notice] = "Registro excluído com sucesso." if @<%= orm_instance.destroy %>
    respond_with @<%= singular_table_name %>
  end

  private

    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end

    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[:<%= singular_table_name %>]
      <%- else -%>
      params.require(:<%= singular_table_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end

    def filters
      @order ||= "<%= attributes_names.first %>"

      if params[:clear] == "true"
        clear_controller_config
      else
        @filter = params[:filter] || get_controller_config(:filter)
        store_controller_config(:filter, @filter)
      end
    end
end
<% end -%>