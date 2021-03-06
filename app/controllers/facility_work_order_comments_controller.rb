class FacilityWorkOrderCommentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_facility_work_order_comment, only: [:show, :edit, :update, :destroy]

  # GET /facility_work_order_comments
  # GET /facility_work_order_comments.json
  def index
    @facility_work_order_comments = FacilityWorkOrderComment.all
  end

  # GET /facility_work_order_comments/1
  # GET /facility_work_order_comments/1.json
  def show
  end

  # GET /facility_work_order_comments/new
  def new
    @facility_work_order_comment = FacilityWorkOrderComment.new
  end

  # GET /facility_work_order_comments/1/edit
  def edit
  end

  # POST /facility_work_order_comments
  # POST /facility_work_order_comments.json
  def create
    @facility_work_order_comment = FacilityWorkOrderComment.new(facility_work_order_comment_params)
    @facility_work_order_comment.user = current_user
    
    respond_to do |format|
      if @facility_work_order_comment.save
        format.html { redirect_to :back, notice: 'Work order was successfully updated.' }
        format.json { render action: 'show', status: :created, location: @facility_work_order_comment }
      else
        format.html { render action: 'new' }
        format.json { render json: @facility_work_order_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facility_work_order_comments/1
  # PATCH/PUT /facility_work_order_comments/1.json
  def update
    respond_to do |format|
      if @facility_work_order_comment.update(facility_work_order_comment_params)
        format.html { redirect_to @facility_work_order_comment.facility_work_order, notice: 'Facility Work Order comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @facility_work_order_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facility_work_order_comments/1
  # DELETE /facility_work_order_comments/1.json
  def destroy
    @facility_work_order_comment.destroy
    respond_to do |format|
      link = request.referer.split("/")[-2]
      @facility_work_order = @facility_work_order_comment.facility_work_order
      if link == "hidden"
          format.html { redirect_to facility_work_orders_url+"/hidden/"+@facility_work_order.id.to_s, notice: 'Work order was successfully updated.' }
      elsif link == "all"
          format.html { redirect_to facility_work_orders_url+"/all/"+@facility_work_order.id.to_s, notice: 'Work order was successfully updated.' }
      else
          format.html { redirect_to facility_work_orders_url+"/unhidden/"+@facility_work_order.id.to_s, notice: 'Work order was successfully updated.' }
      end
      # format.html { redirect_to @facility_work_order_comment.facility_work_order }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facility_work_order_comment
      @facility_work_order_comment = FacilityWorkOrderComment.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def facility_work_order_comment_params
      params.require(:facility_work_order_comment).permit(:datetime_stamp, :facility_work_order_id, :user_id, :comment_text)
    end
end
