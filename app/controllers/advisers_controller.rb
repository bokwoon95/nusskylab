class AdvisersController < ApplicationController
  layout 'advisers_mentors'

  def index
    @advisers = Adviser.all
  end

  def new
    @adviser = Adviser.new
    render_new_template and return
  end

  def create
    # create separate render template for create and use_existing
    user_params = get_user_params
    user = User.new(user_params)
    if user.save
      create_adviser_for_user_and_respond(user)
    else
      render 'new', locals: {
                    users: User.all,
                    user: user
                  }
    end
  end

  def use_existing
    user = User.find(params[:adviser][:user_id])
    if user
      create_adviser_for_user_and_respond(user)
    else
      render 'new', locals: {
                    users: User.all,
                    user: user
                  }
    end
  end

  def show
    @adviser = Adviser.find(params[:id])
    milestones, teams_submissions, own_evaluations = get_data_for_adviser
    render locals: {
             milestones: milestones,
             teams_submissions: teams_submissions,
             own_evaluations: own_evaluations
           }
  end

  def edit
    @adviser = Adviser.find(params[:id])
  end

  def update
    @adviser = Adviser.find(params[:id])
    if update_user
      redirect_to @adviser
    else
      render 'edit'
    end
  end

  def destroy
    @adviser = Adviser.find(params[:id])
    @adviser.destroy
    redirect_to advisers_path
  end

  private
  def get_user_params
    user_param = params.require(:user).permit(:user_name, :email, :uid, :provider)
  end

  def create_adviser_for_user_and_respond(user)
    @adviser = Adviser.new(user_id: user.id)
    if @adviser.save
      redirect_to advisers_path
    else
      render_new_template
    end
  end

  def update_user
    user = @adviser.user
    user_param = get_user_params
    user_param[:uid] = user.uid
    user_param[:provider] = user.provider
    user.update(user_param) ? user : nil
  end

  def get_data_for_adviser
    milestones = Milestone.all
    teams_submissions = {}
    own_evaluations = {}
    milestones.each do |milestone|
      teams_submissions[milestone.id] = {}
      own_evaluations[milestone.id] = {}
      @adviser.teams.each do |team|
        team_sub = Submission.find_by(milestone_id: milestone.id,
                                      team_id: team.id)
        teams_submissions[milestone.id][team.id] = team_sub
        if team_sub
          own_evaluations[milestone.id][team.id] =
            PeerEvaluation.find_by(submission_id: team_sub.id,
                                   adviser_id: @adviser.id)
        end
      end
    end
    return milestones, teams_submissions, own_evaluations
  end

  def render_new_template
    render 'new', locals: {
                  users: User.all,
                  user: User.new
                }
  end
end