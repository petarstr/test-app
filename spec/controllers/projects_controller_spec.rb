require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:user_1) { User.find_by(email: 'test_user@gmail.com') }

  # Skip before hook when specified
  before do |example|
    sign_in_as(user_1) unless example.metadata[:skip_before]
  end

  describe 'GET #index' do
    context 'when not signed in' do
      it 'redirects to root', :skip_before do
        get :index
        expect(assigns(:projects)).to be nil
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'when signed in user' do
      it 'collects projects from all users' do
        get :index
        expect(assigns(:projects)).to eq Project.all
      end
    end
  end

  describe 'GET #show' do
    it 'shows a specific project' do
      get :show, params: { id: user_1.projects.first.id }
      expect(assigns(:project)).to eq user_1.projects.first
    end
  end

  describe 'GET #new' do
    it 'prepares new project' do
      get :new
      expect(assigns(:project).new_record?).to be true
    end
  end

  describe 'POST #create' do
    context 'when project name is not present' do
      it 'does not create a record' do
        post :create, params: { project: { project_name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when project name is present' do
      it 'creates a new project' do
        post :create, params: { project: { project_name: 'Such a great project' } }
        project = Project.find_by(project_name: 'Such a great project')
        expect(project).to be_truthy
        expect(project.user_id).to eq user_1.id
      end
    end
  end

  describe 'PUT #update' do
    let(:project) { Project.find_or_create_by(project_name: 'Such a great project', user_id: user_1.id) }
    let(:wrong_user) { User.find_by(email: 'another_test_user@gmail.com') }

    context 'when the user is not the creator of the project' do
      it 'redirects to root', :skip_before do
        sign_in_as(wrong_user)
        put :update, params: { id: project.id, project: { project_name: 'valid name'} }
        expect(response).to redirect_to root_url
      end
    end

    context 'when the user owns the project' do
      it 'updates project' do
        put :update, params: { id: project.id, project: { project_name: 'valid name'} }
        expect(project.reload.project_name).to eq 'valid name'
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:project) { Project.find_or_create_by(project_name: 'Such a great project', user_id: user_1.id) }
    let(:wrong_user) { User.find_by(email: 'another_test_user@gmail.com') }

    context 'when the user is not the creator of the project' do
      it 'redirects to root', :skip_before do
        sign_in_as(wrong_user)
        delete :destroy, params: { id: project.id }
        expect(response).to redirect_to root_url
        expect(project.reload).to be_truthy
      end
    end

    context 'when the user owns the project' do
      it 'deletes the project' do
        delete :destroy, params: { id: project.id }
        expect(Project.find_by(id: project.id)).to be nil
      end
    end
  end
end
