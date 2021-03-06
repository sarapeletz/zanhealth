class BmetWorkRequestsController < ApplicationController
  load_and_authorize_resource :except => [:public_new, :public_create, :public_show]
before_action :set_bmet_work_requests, only:[:new, :index, :show]
before_action :set_bmet_work_request, only: [:show, :update, :destroy, :edit, :show_hidden, :show_all]
before_action :set_status, only: [:show, :hidden, :all, :show_hidden, :show_all]
before_action :set_users, only: [:show, :hidden, :all, :show_hidden, :show_all], except: [:new, :create]
before_action :set_departments, only: [:show, :hidden, :all, :show_hidden, :show_all]
before_action :set_convert_object, only: [:show, :show_hidden, :show_all]
before_action :set_hidden_bmet_work_requests, only: [:hidden, :show_hidden]
before_action :set_all_bmet_work_requests, only: [:all, :show_all]
before_action :set_items, only: [:show, :show_all, :show_hidden]
skip_before_action :authenticate_user!, only: [:public_new, :public_create, :public_show]

  layout 'layouts/bmet_app'

  def search
  	@bmet_work_requests = BmetWorkRequest.search(params[:q], :size => 100).records
  	@bmet_work_requests = @bmet_work_requests.with_deleted.where(:facility_id => current_user.facility_id).all.order(:created_at).reverse_order()
    @link = bmet_work_requests_url+"/all/"
    render action: 'index'
  end

  def new
    @bmet_work_request = BmetWorkRequest.new
  end

  def index
  end

  def hidden
  	  render 'index'
  end

  def all
  	  render 'index'
  end

  def edit

  end

  def as_csv
    @bmet_work_requests = BmetWorkRequest.with_deleted.where(:facility_id => current_user.facility_id)
    send_data @bmet_work_requests.as_csv, type: "text/csv", filename: "bmet_work_requests.csv"
  end

  def show
    @bmet_work_request.unread = false
    @bmet_work_request.save!
  end
 
  def show_hidden
  	  render 'show'
  end

  def show_all
  	  render 'show'
  end

  def update
    respond_to do |format|
      if @bmet_work_request.update(bmet_work_request_params)
      	  link = request.referer.split("/")[-2]
      	  if link == "hidden"
      	  	  format.html { redirect_to bmet_work_requests_url+"/hidden/"+@bmet_work_request.id.to_s, notice: 'Work request was successfully updated' }
		  elsif link == "all"
		  	  format.html { redirect_to bmet_work_requests_url+"/all/"+@bmet_work_request.id.to_s, notice: 'Work request was successfully updated' }
		  else
        	format.html { redirect_to bmet_work_requests_url+"/unhidden/"+@bmet_work_request.id.to_s, notice: 'Work request was successfully updated.' }
		  end
        format.json { head :no_content }
      else
        format.html { render :back }
        format.json { render json: @bmet_work_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @bmet_work_request = BmetWorkRequest.new(bmet_work_request_params)
    @bmet_work_request.facility_id=current_user.facility_id
    @bmet_work_request.unread = true

    respond_to do |format|
      if @bmet_work_request.save
        format.html { redirect_to bmet_work_requests_url+"/unhidden/"+@bmet_work_request.id.to_s, notice: 'Work order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bmet_work_request }
      else
        format.html { render :back }
        format.json { render json: @bmet_work_request.errors, status: :unprocessable_entity }
      end
    end
  end

    def public_new    
    @bmet_work_request = BmetWorkRequest.new
    @bmet_work_request.facility_id = params[:facility_id]
    render :layout => "application"
  end

  def public_create
    @bmet_work_request = BmetWorkRequest.new(bmet_work_request_params)
    @bmet_work_request.unread = true

    respond_to do |format|
      if @bmet_work_request.save
      #if verify_recaptcha(private_key: ENV['RECAPTCHA_PRIVATE_KEY']) && @bmet_work_request.save
        UserMailer.work_request_received_email(@bmet_work_request).deliver
        format.html { redirect_to '/bmet_work_requests/public_show/'+@bmet_work_request.id.to_s, notice: 'Work order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bmet_work_request }
      else
        format.html { render action: 'public_new', layout: "application" }
        format.json { render json: @bmet_work_request.errors, status: :unprocessable_entity }
      end
    end

  end

  def public_show
    @bmet_work_request = BmetWorkRequest.find_by_id(params[:id])
    render :layout => "application"
  end


  def destroy
    @bmet_work_request.really_destroy!
    respond_to do |format|
      link = request.referer.split("/")[-2]
      if link == "hidden"
        format.html { redirect_to bmet_work_requests_url+"/hidden/", notice: 'Work request was successfully deleted.' }
      elsif link == "all"
        format.html { redirect_to bmet_work_requests_url+"/all/", notice: 'Work request was successfully deleted.' }
      else
        format.html { redirect_to bmet_work_requests_url+"/unhidden/", notice: 'Work request was successfully deleted.' }
      end
      format.json { head :no_content }
    end
  end

  def hide
  	  @bmet_work_request =  BmetWorkRequest.with_deleted.find_by_id(params[:id])
  	  if @bmet_work_request.destroyed?
		 BmetWorkRequest.restore(@bmet_work_request.id)
	  else
	  	  @bmet_work_request.destroy
	  end
	  respond_to do |format|
	  	  link = "/"+request.referer.split("/")[-2]
	  	  if link == "/all"
	  	  	  format.html { redirect_to request.referer }
		  else
		  	  link = bmet_work_requests_url+link
		  	  format.html { redirect_to link }
		  end
		  format.json { head :no_content }
	  end
  end

  private 
    def set_status
      @status= {
        'Unstarted' => 0,
        'In Progress' => 1,
        'Completed' => 2
      }
    end

    def set_users
      @users = User.where(:facility_id => current_user.facility_id).order(:name).to_a
    end

    def set_departments
      @departments = Department.where(:facility_id => current_user.facility_id).order(:name).to_a
    end

    def set_items
      @items = BmetItem.includes(:bmet_model, {:department => :facility}) .where("facilities.id=?",current_user.facility_id).references(:facility).order(:asset_id)
    end

    def set_bmet_work_requests
      @bmet_work_requests = BmetWorkRequest.where(:facility_id => current_user.facility_id).all.order(:created_at).reverse_order()
      @link = bmet_work_requests_url+"/unhidden/"
    end

    def set_hidden_bmet_work_requests
    	@bmet_work_requests = BmetWorkRequest.only_deleted.where(:facility_id => current_user.facility_id).all.order(:created_at).reverse_order()
      @link = bmet_work_requests_url+"/hidden/"
	end

	def set_all_bmet_work_requests
		@bmet_work_requests = BmetWorkRequest.with_deleted.where(:facility_id => current_user.facility_id).all.order(:created_at).reverse_order()
    @link = bmet_work_requests_url+"/all/"
	end

    def set_bmet_work_request
      @bmet_work_request = BmetWorkRequest.with_deleted.find_by_id(params[:id])
      if (@bmet_work_request==nil || @bmet_work_request.facility_id!=current_user.facility_id)
          @bmet_work_request=nil
          redirect_to "/404"
      end
    end

    def bmet_work_request_params
      params.require(:bmet_work_request).permit(:id, :requester, :department, :location, :phone, :email, :description, :created_at, :updated_at, :facility_id, :asset_id, :unread)
    end

    def set_convert_object
      @input_object = BmetWorkOrder.new
      @input_object.description = "Description: "+ @bmet_work_request.description + "\n"+
      "Location: "+@bmet_work_request.location + "\n" +
      "Email: "+@bmet_work_request.email + "\n" +
      "Phone: "+@bmet_work_request.phone + "\n"
      @input_object.pm_origin = nil
      @input_object.wr_origin = @bmet_work_request
    end

end
