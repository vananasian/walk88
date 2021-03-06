class UserRecordsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_user_record, only: [:show, :edit, :update, :destroy]

  # GET /user_records
  # GET /user_records.json
  def index
    user_id = params[:user_id] || current_user.id
    @owner = user_id == current_user.id
    @user = User.find(user_id)
    #@user_records = UserRecord.where(user_id: user_id).order('day desc')[0...14]
    @user_records = UserRecord.where(user_id: user_id).
        paginate(:page => params[:page], :per_page => 30).order('day desc')
  end

  # GET /user_records/1
  # GET /user_records/1.json
  def show
  end

  # GET /user_records/new
  def new
    @user_record = UserRecord.new
    @user_setting = current_user.user_setting
  end

  # GET /user_records/1/edit
  def edit
    @user_setting = current_user.user_setting
  end

  # POST /user_records
  # POST /user_records.json
  def create
    record_params = user_record_params
    record_params[:user_id] = current_user.id
    @user_record = UserRecord.new(record_params)
    if UserRecord.exists?(user_id: @user_record.user_id, day: @user_record.day)
      @user_record = UserRecord.find_by(user_id: @user_record.user_id, day: @user_record.day)
      return update
    end

    respond_to do |format|
      if @user_record.save
        format.html { redirect_to user_records_url, notice: '保存しました' }
        format.json { render action: 'show', status: :created, location: @user_record }
        on_update
      else
        format.html { render action: 'new' }
        format.json { render json: @user_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def on_update
    UserStatus.update_user_status(current_user.id)
  end

  # PATCH/PUT /user_records/1
  # PATCH/PUT /user_records/1.json
  def update
    return redirect_to root_url unless @user_record.user_id == current_user.id
    respond_to do |format|
      if @user_record.update(user_record_params)
        format.html { redirect_to user_records_url, notice: '保存しました' }
        format.json { head :no_content }
        on_update
      else
        format.html { render action: 'edit' }
        format.json { render json: @user_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_records/1
  # DELETE /user_records/1.json
  def destroy
    return redirect_to root_url unless @user_record.user_id == current_user.id
    @user_record.destroy
    on_update
    respond_to do |format|
      format.html { redirect_to user_records_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_record
      @user_record = UserRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_record_params
      params.require(:user_record).permit(:day, :steps, :distance)
    end
end
