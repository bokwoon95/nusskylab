require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  describe 'GET #index' do
    context 'user not logged in' do
      it 'should redirect to root_path for non_user' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'user logged in but not admin' do
      login_user
      it 'should render index for adviser users' do
        adviser1 = FactoryGirl.create(:adviser, user_id: subject.current_user.id)
        user1 = FactoryGirl.create(:user, email: '1@student.controller.spec', uid: '1.student.controller.spec')
        user2 = FactoryGirl.create(:user, email: '2@student.controller.spec', uid: '2.student.controller.spec')
        user3 = FactoryGirl.create(:user, email: '3@student.controller.spec', uid: '3.student.controller.spec')
        adviser2 = FactoryGirl.create(:adviser,user: user1)
        team1 = FactoryGirl.create(:team, adviser: adviser1, team_name: '1.team.controller.spec')
        team2 = FactoryGirl.create(:team, adviser: adviser2, team_name: '2.team.controller.spec')
        student1 = FactoryGirl.create(:student, user: user2, team: team1)
        student2 = FactoryGirl.create(:student, user: user3, team: team2)
        expect(response).to render_template(:index)
        expect(assigns(:students).length).to eql Student.all.length
      end

      it 'should redirect to home_link for non_admin' do
        get :index
        expect(response).to redirect_to(controller.get_home_link)
      end
    end

    context 'user logged in and admin' do
      login_admin
      it 'should assign @students' do
        get :index
        expect(assigns(:students).length).to eql Student.all.length
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #new' do
    context 'user not logged in' do
      it 'should redirect to root_path for non_user' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'user logged in but not admin' do
      login_user
      it 'should redirect to home_link for non_admin' do
        get :new
        expect(response).to redirect_to(controller.get_home_link)
      end
    end

    context 'user logged in and admin' do
      login_admin
      it 'should render new for admin user' do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    context 'user not logged in' do
      it 'should redirect to root_path for non_user' do
        post :create
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'user logged in but not admin' do
      login_user
      it 'should redirect to home_link for non_admin' do
        post :create
        expect(response).to redirect_to(controller.get_home_link)
      end
    end

    context 'user logged in and admin' do
      login_admin
      it 'should redirect to advisers with success for admin user' do
        user = FactoryGirl.create(:user, email: '1@adviser.controller.spec', uid: '1.adviser.controller.spec')
        post :create, adviser: {user_id: user.id}
        expect(response).to redirect_to(advisers_path)
        expect(flash[:success]).not_to be_nil
      end

      it 'should redirect to admins with danger for admin user' do
        adviser = FactoryGirl.create(:adviser, user_id: subject.current_user.id)
        post :create, adviser: {user_id: subject.current_user.id}
        expect(response).to redirect_to(new_adviser_path)
        expect(flash[:danger]).not_to be_nil
      end
    end
  end

  describe 'GET #show' do
    context 'user not logged in' do
      it 'should redirect to root_path for non_user' do
        user = FactoryGirl.create(:user, email: '2@adviser.controller.spec', uid: '2.adviser.controller.spec')
        adviser = FactoryGirl.create(:adviser, user_id: user.id)
        get :show, id: adviser.id
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'user logged in but not admin' do
      login_user
      it 'should render show for current adviser' do
        # TODO: check more on the locals of adviser show page
        adviser = FactoryGirl.create(:adviser, user_id: subject.current_user.id)
        get :show, id: adviser.id
        expect(response).to render_template(:show)
        Adviser.find_by(user_id: subject.current_user.id).destroy
      end

      it 'should redirect to home_link for non_admin' do
        user = FactoryGirl.create(:user, email: '2@adviser.controller.spec', uid: '2.adviser.controller.spec')
        adviser = FactoryGirl.create(:adviser, user_id: user.id)
        get :show, id: adviser.id
        expect(response).to redirect_to(controller.get_home_link)
      end
    end

    context 'user logged in and admin' do
      login_admin
      it 'should render show for admin user' do
        user = FactoryGirl.create(:user, email: '2@adviser.controller.spec', uid: '2.adviser.controller.spec')
        adviser = FactoryGirl.create(:adviser, user_id: user.id)
        get :show, id: adviser.id
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'user not logged in' do
      it 'should redirect to root_path for non_user' do
        delete :destroy, id: 1
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'user logged in but not admin' do
      login_user
      it 'should redirect to home_link for non_admin' do
        delete :destroy, id: 1
        expect(response).to redirect_to(controller.get_home_link)
      end
    end

    context 'user logged in and admin' do
      login_admin
      it 'should redirect with success for admin user' do
        user = FactoryGirl.create(:user, email: '2@adviser.controller.spec', uid: '2.adviser.controller.spec')
        adviser = FactoryGirl.create(:adviser, user_id: user.id)
        delete :destroy, id: adviser.id
        expect(response).to redirect_to(advisers_path)
        expect(flash[:success]).not_to be_nil
      end
    end
  end
end
